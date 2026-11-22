function S = main(mode)
%MAIN  Run the Faqra Club microgrid study and write the results/ folder.
%
%   main            full study (about 250 LPs, half of them small
%                   dispatch-only runs; 15 to 20 minutes with HiGHS)
%   main('quick')   input checks, 48-h test, reference, base case at the four
%                   tilts and its finance metrics, with figures (2 minutes)
%   S = main(...)   also returns all results in one struct
%
% Steps of the full study
%   1. read inputs/ and compare them with inputs/inputs_summary.md
%   2. run the 48-hour hand-checkable tests (tests/test_small_case.m)
%   3. base case for PV tilt 30/40/50/60 and its reference (grid + diesel);
%      the cheapest tilt becomes the base case
%   4. one-at-a-time sensitivities, each compared with its own reference
%   5. diesel price sweep
%   6. finance: dispatch with degraded PV in later years, then NPV, IRR and
%      payback for the base case and selected runs
%   7. weather robustness: base-case sizes fixed, dispatch only, 2014-2023
%   8. cross-check against tools/prototype_lp.py
%   9. tables (CSV), figures (PNG) and README.md in results/
%
% The briefs are docs/fable_prompt.md and docs/fable_prompt_round2.md.
%
% Requires MATLAB with the Optimization Toolbox (linprog). From R2024a
% linprog uses the HiGHS dual simplex by default; with older releases the run
% time is untested, so try main('quick') first. It also runs in GNU Octave
% with python3 + scipy (see solve_lp.m).

if nargin < 1, mode = 'full'; end
quick = strcmpi(mode, 'quick');

here   = fileparts(mfilename('fullpath'));
outdir = fullfile(fileparts(here), 'results');
addpath(here);
addpath(fullfile(here, 'tests'));
if ~exist(outdir, 'dir'), mkdir(outdir); end
t_all = tic;

% ------------------------------------------------------------- 1. inputs
fprintf('\n== Inputs ==\n');
D = load_inputs();
chk = check_inputs(D);
fprintf('%d input checks against inputs_summary.md: all passed.\n', numel(chk));

% --------------------------------------------------------------- 2. test
fprintf('\n== 48-hour tests ==\n');
test_small_case();

S = struct();
S.mode = mode;
S.D    = D;
S.chk  = chk;
cache  = struct('key', {{}}, 'K', {{}});      % reference runs already solved

% ------------------------------------------------- 3. tilt and base case
fprintf('\n== Base case: PV tilt ==\n');
tilts = D.par.pv.base_tilt_deg_candidates(:)';
Ktilt = [];  Rtilt = cell(1, numel(tilts));
for j = 1:numel(tilts)
    b = scenarios(D, tilts(j));
    [K, Rtilt{j}, cache] = run_one(b, D, cache, 'tilt');
    Ktilt = [Ktilt, K]; %#ok<AGROW>
end
assert(all([Ktilt.ok]), 'main:base', 'A base-case LP did not solve.');
[~, jbest] = min([Ktilt.cost]);
best_tilt  = tilts(jbest);
fprintf('Cheapest tilt: %d deg.\n', best_tilt);

[base, sens, sweep] = scenarios(D, best_tilt);
S.tilts = tilts;      S.best_tilt = best_tilt;
S.Ktilt = Ktilt;
S.base  = base;       S.Rbase = Rtilt{jbest};   S.Kbase = Ktilt(jbest);
S.Kbase.category = 'base';
S.sens  = sens;       S.sweep = sweep;          % scenario definitions

% reference of the base case (already solved and cached; keep its dispatch)
S.Rref = build_and_solve(as_reference(base), D);
S.Kref = postprocess(S.Rref);
S.Kref.category = 'reference';

S.Ksens = [];  S.Ksweep = [];  S.Kwx = [];  S.Kwx_fixed = [];  S.cross = [];
S.Kdeg = [];
if ~quick
    % ------------------------------------------------- 4. sensitivities
    fprintf('\n== Sensitivities (one at a time, tilt %d) ==\n', best_tilt);
    Ksens = [];
    for j = 1:numel(sens)
        [K, ~, cache] = run_one(sens(j), D, cache, 'sensitivity');
        Ksens = [Ksens, K]; %#ok<AGROW>
    end
    S.Ksens = Ksens;

    % ------------------------------------------- 5. diesel price sweep
    fprintf('\n== Diesel price sweep ==\n');
    Ksweep = [];
    for j = 1:numel(sweep)
        [K, ~, cache] = run_one(sweep(j), D, cache, 'diesel_sweep');
        Ksweep = [Ksweep, K]; %#ok<AGROW>
    end
    S.Ksweep = Ksweep;
end

% ---------------------------------------------------------- 6. finance
% NPV, IRR and payback. Each run needs the dispatch of later project years,
% when the PV has degraded: sizes fixed, dispatch only.
fprintf('\n== Finance: dispatch with degraded PV, NPV, IRR, payback ==\n');
[S.fin, S.Kdeg, cache] = run_finance(base, S.Kbase, D, cache, [], []);
if ~quick
    names = {'batt_125', 'batt_350', 'irr_low', 'export_nm', 'grid_none', 'diesel_capex'};
    names = [names, {sens(strcmp({sens.group}, 'Grid export') & ~strcmp({sens.name}, 'export_nm')).name}];
    for j = 1:numel(names)
        q = find(strcmp({sens.name}, names{j}), 1);
        assert(~isempty(q), 'main:finance', 'Scenario %s not found.', names{j});
        if Ksens(q).ok
            [S.fin, S.Kdeg, cache] = run_finance(sens(q), Ksens(q), D, cache, S.fin, S.Kdeg);
        end
    end
    for j = 1:numel(sweep)
        if Ksweep(j).ok
            [S.fin, S.Kdeg, cache] = run_finance(sweep(j), Ksweep(j), D, cache, S.fin, S.Kdeg);
        end
    end

    % ------------------------------------------- 7. weather robustness
    % PV and battery fixed at the base case, dispatch re-optimized for each
    % weather year. "Elastic": load may be shed beyond the LPSP limit, and
    % critical load may be shed, at a penalty, so the run shows by how much
    % the design falls short instead of being infeasible.
    fprintf('\n== Weather years (base-case PV and battery) ==\n');
    years = weather_years(D, best_tilt);
    Kwx = [];  Kwx_fixed = [];
    for y = years
        w = base;
        w.name   = sprintf('weather_%d', y);
        w.label  = sprintf('Weather year %d', y);
        w.group  = 'Weather year';
        w.pv_col = sprintf('y%d_t%d', y, best_tilt);
        w.elastic = true;
        % main variant: diesel limited to the existing plant, taken as the
        % rating that carries the reference case today
        w.fix = struct('P_pv', S.Kbase.P_pv, 'E_b', S.Kbase.E_b, 'P_b', S.Kbase.P_b);
        w.cap = struct('P_d', S.Kref.P_d);
        [K, ~, cache] = run_one(w, D, cache, 'weather');
        Kwx = [Kwx, K]; %#ok<AGROW>
        % second variant: diesel limited to what the base case needs
        w.name = sprintf('weather_%d_dgfixed', y);
        w.cap  = struct();
        w.fix.P_d = S.Kbase.P_d;
        [K, ~, cache] = run_one(w, D, cache, 'weather_dgfixed');
        Kwx_fixed = [Kwx_fixed, K]; %#ok<AGROW>
    end
    S.years = years;  S.Kwx = Kwx;  S.Kwx_fixed = Kwx_fixed;

    % -------------------------------------- 8. cross-check, prototype
    fprintf('\n== Cross-check against tools/prototype_lp.py ==\n');
    [S.cross, cache] = crosscheck(D, cache, S.Kbase); %#ok<ASGLU>
end

% --------------------------------------------------------------- 9. output
S.info = struct();
S.info.date = datestr(now, 'yyyy-mm-dd HH:MM');
if exist('OCTAVE_VERSION', 'builtin') ~= 0
    S.info.software = ['GNU Octave ' version];
else
    S.info.software = ['MATLAB ' version];
end
S.info.solver = S.Rbase.solver;
S.info.run_time = toc(t_all);

fprintf('\n== Writing results to %s ==\n', outdir);
write_outputs(outdir, S);
plot_results(outdir, S);
fprintf('Done in %.0f s.\n', toc(t_all));
if nargout == 0, clear S; end
end

% =========================================================================
function [K, R, cache] = run_one(s, D, cache, category, quiet)
% Solve scenario s, compare it with its own reference, print one line.
if nargin < 5, quiet = false; end
[Kref, cache] = reference_kpis(s, D, cache);
R = build_and_solve(s, D);
K = postprocess(R, Kref);
K.category = category;
if ~K.ok
    fprintf('  %-22s NOT SOLVED: %s\n', s.name, ['exitflag ' num2str(R.exitflag) ' ' R.message]);
elseif ~quiet
    fprintf(['  %-22s cost %8.0f $/yr  LCOE %.4f  PV %6.0f kWp  BESS %6.0f kWh  DG %5.0f kW' ...
             '  LPSP %.2f%%  saving %5.1f%%  (%.1f s)\n'], s.name, K.cost, K.lcoe, K.P_pv, ...
            K.E_b, K.P_d, 100 * K.lpsp, 100 * K.savings_frac, R.solve_time);
end
end

% =========================================================================
function [Kref, cache] = reference_kpis(s, D, cache)
% KPIs of the reference (grid + diesel only) that belongs to scenario s.
% References are cached: scenarios that differ only in PV, battery or export
% parameters share one.
key = sprintf('%s|%s|%s|%.6g|%.6g|%.6g|%.6g|%.6g|%.6g|%.6g|%.6g|%.6g|%.6g|%.6g|%d', ...
              s.load_case, s.load_col, s.grid_col, s.price_diesel, s.fuel_a, s.fuel_b, ...
              s.om_dg, s.c_d, s.n_d, s.i, s.c_grid, s.lpsp_max, s.m_min, peak_or(s.P_gmax), ...
              s.no_shed_ski);
hit = find(strcmp(cache.key, key), 1);
if ~isempty(hit)
    Kref = cache.K{hit};
    return
end
Kref = postprocess(build_and_solve(as_reference(s), D));
assert(Kref.ok, 'main:reference', 'Reference of %s did not solve.', s.name);
cache.key{end + 1} = key;
cache.K{end + 1}   = Kref;
end

% =========================================================================
function v = peak_or(P_gmax)
if isempty(P_gmax), v = -1; else, v = P_gmax; end
end

% =========================================================================
function [fin, Kdeg, cache] = run_finance(s, K, D, cache, fin, Kdeg)
% Finance metrics of the sized run (s, K): dispatch-only runs for the later
% project years with degraded PV, then NPV, IRR and payback (finance.m).
E     = D.par.economics.npv;
years = E.pv_degradation_dispatch_years(:)';
deg   = D.par.pv.degradation_pct_yr(2) / 100;
assert(years(1) == 1, 'main:years', 'The first dispatch year must be year 1.');
Kyr = K;                                  % year 1: the sizing run itself
for y = years(2:end)
    d = s;
    d.name     = sprintf('%s_y%d', s.name, y);
    d.label    = sprintf('%s, project year %d', s.label, y);
    d.group    = 'PV degradation';
    d.pv_scale = (1 - deg) ^ (y - 1);     % a(t) (1 - 0.007)^(y-1)
    d.elastic  = true;
    d.fix = struct('P_pv', K.P_pv, 'E_b', K.E_b, 'P_b', K.P_b);
    if s.c_d > 0
        d.fix.P_d = K.P_d;                % sets bought new: the rating bought
    else
        d.cap = struct('P_d', K.ref_P_d); % existing plant: carries the reference
    end
    [Ky, ~, cache] = run_one(d, D, cache, 'degradation', true);
    assert(Ky.ok, 'main:degradation', 'Dispatch of %s did not solve.', d.name);
    Kyr  = [Kyr, Ky]; %#ok<AGROW>
    Kdeg = [Kdeg, Ky]; %#ok<AGROW>
end
F = finance(s, K, Kyr, years, D.par);
fprintf(['  %-22s NPV %9.0f $  IRR %5.1f%%  payback %4.1f yr (discounted %4.1f)' ...
         '  later-year LPSP max %.3f%%\n'], s.name, F.npv, 100 * F.irr, F.payback, ...
        F.payback_disc, 100 * F.max_lpsp_later);
fin = [fin, struct('name', s.name, 'K', K, 'F', F)];
end

% =========================================================================
function years = weather_years(D, tilt)
names = fieldnames(D.pvmy);
years = [];
for j = 1:numel(names)
    tok = sscanf(names{j}, 'y%d_t%d');
    if numel(tok) == 2 && tok(2) == tilt, years(end + 1) = tok(1); end %#ok<AGROW>
end
years = sort(years);
end

% =========================================================================
function [X, cache] = crosscheck(D, cache, Kbase)
% Reproduce tools/prototype_lp.py with this model, then remove its
% simplifications one at a time to explain the gap to the base case.
%
% The prototype differs from the model in these ways:
%   - battery O&M taken as 2.5 % of the annualized capex (CRF x 192 x 1.025)
%     instead of 2.5 % of the capex per year;
%   - grid connection of 5 MW (never limiting);
%   - a cost of 1e-4 $/kWh on charging; PV tilt 40 deg;
%   - LPSP limit 1 % (its base runs), no T1 lift reserve.
p = scenarios(D, 40);
p.P_gmax    = 5000;
p.om_b_frac = D.par.battery.om_pct_capex_yr(2) / 100 * crf(p.i, p.n_b);
p.c_ch      = 1e-4;
p.lpsp_max  = 0.01;
p.E_res     = 0;

% name, changes, and the prototype's result from docs/fable_prompt.md:
% [PV kWp, BESS kWh, cost $/yr, LCOE $/kWh, renewable fraction, diesel MWh]
runs = {'Reference (grid + diesel)', {},                      [0    0    493382 0.342 0.00 962]
        'Base, LPSP 1%',             {},                      [1048 2893 281198 0.195 0.76 110]
        'Base, LPSP 0%',             {'lpsp_max', 0},         [1048 2893 286706 0.197 0.76 125]
        'No grid at all',            {'grid_col', 'u_none'},  [1091 2941 307399 0.213 0.77 387]};
X.rows = struct('label', {}, 'proto', {}, 'model', {});
for j = 1:size(runs, 1)
    q = p;
    q.name = sprintf('proto_%d', j);  q.label = runs{j, 1};  q.group = 'Cross-check';
    for a = 1:2:numel(runs{j, 2}), q.(runs{j, 2}{a}) = runs{j, 2}{a + 1}; end
    if j == 1, q = as_reference(q); end
    [K, ~, cache] = run_one(q, D, cache, 'crosscheck');
    X.rows(end + 1) = struct('label', runs{j, 1}, 'proto', runs{j, 3}, 'model', ...
        [K.P_pv, K.E_b, K.cost, K.lcoe, K.re_frac, K.E_diesel / 1000]);
end

% Gap from the prototype's base case to the base case of this study
X.steps = struct('label', {}, 'K', {});
q = p;  q.name = 'gap_1_prototype';
[K, ~, cache] = run_one(q, D, cache, 'crosscheck');
X.steps(end + 1) = struct('label', 'Prototype settings (tilt 40, LPSP 1%)', 'K', K);
q.c_ch = 0;  q.om_b_frac = D.par.battery.om_pct_capex_yr(2) / 100;  q.name = 'gap_2_om';
[K, ~, cache] = run_one(q, D, cache, 'crosscheck');
X.steps(end + 1) = struct('label', 'Battery O&M as a share of capex per year; no charging cost', 'K', K);
q.P_gmax = [];  q.name = 'gap_3_grid';
[K, ~, cache] = run_one(q, D, cache, 'crosscheck');
X.steps(end + 1) = struct('label', 'Grid connection = peak load instead of 5 MW', 'K', K);
q.lpsp_max = D.par.reliability.lpsp_energy_max;  q.name = 'gap_4_lpsp';
[K, ~, cache] = run_one(q, D, cache, 'crosscheck');
X.steps(end + 1) = struct('label', sprintf('LPSP limit %g%%', 100 * q.lpsp_max), 'K', K);
q.E_res = D.par.lift_T1_recovery.energy_reserve_kWh(2);  q.name = 'gap_5_reserve';
[K, ~, cache] = run_one(q, D, cache, 'crosscheck');
X.steps(end + 1) = struct('label', 'T1 lift recovery reserve in the battery', 'K', K);
X.steps(end + 1) = struct('label', sprintf('Cheapest tilt (%s) = base case', Kbase.name), 'K', Kbase);
end
