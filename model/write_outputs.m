function write_outputs(outdir, S)
%WRITE_OUTPUTS  Write the result tables (CSV) and results/README.md.
%
%   write_outputs(outdir, S)     S is the struct built by main.m
%
% Files
%   runs_all.csv                   every run, every KPI and check
%   table_base_vs_reference.csv    base case next to the status quo
%   table_tilt.csv                 base case for each PV tilt
%   table_sensitivities.csv        one-at-a-time sensitivities
%   table_weather_years.csv        base-case sizes, dispatch for 2014-2023
%   table_crosscheck_prototype.csv comparison with tools/prototype_lp.py
%   tornado_lcoe.csv               data of the tornado chart
%   dispatch_base_hourly.csv       hourly dispatch of the base case
%   input_checks.csv               loaded series vs inputs_summary.md
%   README.md                      short summary of all of the above

full = ~isempty(S.Ksens);

% ------------------------------------------------------------ all runs
all_runs = [S.Kref, S.Ktilt];
if full
    all_runs = [all_runs, S.Ksens, S.Kwx, S.Kwx_free];
    for j = 1:numel(S.cross.steps) - 1
        all_runs = [all_runs, S.cross.steps(j).K]; %#ok<AGROW>
    end
end
write_runs(fullfile(outdir, 'runs_all.csv'), all_runs, spec_all());

% --------------------------------------------------- base vs reference
sp = spec_all();
sp = sp(6:end - 6, :);                         % numbers only, without solver details
fid = fopen(fullfile(outdir, 'table_base_vs_reference.csv'), 'w');
fprintf(fid, 'quantity,reference,base_case\n');
for j = 1:size(sp, 1)
    fprintf(fid, '%s,%s,%s\n', sp{j, 1}, cellstr_of(S.Kref, sp(j, :)), cellstr_of(S.Kbase, sp(j, :)));
end
fclose(fid);

write_runs(fullfile(outdir, 'table_tilt.csv'), S.Ktilt, spec_short());

% -------------------------------------------------------- input checks
fid = fopen(fullfile(outdir, 'input_checks.csv'), 'w');
fprintf(fid, 'check,expected_inputs_summary,loaded,tolerance,pass\n');
for j = 1:numel(S.chk)
    fprintf(fid, '%s,%.10g,%.10g,%.3g,%d\n', strrep(S.chk(j).name, ',', ';'), S.chk(j).expected, ...
            S.chk(j).actual, S.chk(j).tol, S.chk(j).pass);
end
fclose(fid);

% ----------------------------------------------------- hourly dispatch
R = S.Rbase;
fid = fopen(fullfile(outdir, 'dispatch_base_hourly.csv'), 'w');
fprintf(fid, ['hour,time_local,load_kW,critical_kW,grid_available,pv_available_kW,p_pv_kW,p_cur_kW,' ...
              'p_ch_kW,p_dis_kW,soc_kWh,p_g_kW,p_dg_kW,u_dg_kW,ls_c_kW,ls_n_kW\n']);
M = [R.series.L, R.series.Lc, R.series.ug, R.series.a * R.P_pv, R.p_pv, R.p_cur, R.p_ch, R.p_dis, ...
     R.soc, R.p_g, R.p_dg, R.u_dg, R.ls_c, R.ls_n];
tl = S.D.load.base.time_local;
for t = 1:R.T
    fprintf(fid, '%d,%s', t, tl{t});
    fprintf(fid, ',%.3f', M(t, :));
    fprintf(fid, '\n');
end
fclose(fid);

if full
    write_runs(fullfile(outdir, 'table_sensitivities.csv'), [S.Kbase, S.Ksens], spec_short());
    write_runs(fullfile(outdir, 'table_weather_years.csv'), [S.Kwx, S.Kwx_free], spec_short());

    % cross-check with the Python prototype
    fid = fopen(fullfile(outdir, 'table_crosscheck_prototype.csv'), 'w');
    fprintf(fid, ['run,source,pv_kWp,bess_kWh,cost_USD_yr,lcoe_USD_kWh,renewable_fraction,' ...
                  'diesel_MWh\n']);
    for j = 1:numel(S.cross.rows)
        r = S.cross.rows(j);
        fprintf(fid, '%s,prototype_lp.py,%.0f,%.0f,%.0f,%.3f,%.2f,%.0f\n', strrep(r.label, ',', ''), r.proto);
        fprintf(fid, '%s,this model with prototype settings,%.1f,%.1f,%.0f,%.4f,%.4f,%.1f\n', ...
                strrep(r.label, ',', ''), r.model);
    end
    for j = 1:numel(S.cross.steps)
        K = S.cross.steps(j).K;
        fprintf(fid, 'gap step %d: %s,this model,%.1f,%.1f,%.0f,%.4f,%.4f,%.1f\n', j, ...
                strrep(S.cross.steps(j).label, ',', ''), K.P_pv, K.E_b, K.cost, K.lcoe, K.re_frac, ...
                K.E_diesel / 1000);
    end
    fclose(fid);

    % tornado data
    Tn = tornado_data(S.Kbase, S.Ksens, 'lcoe');
    fid = fopen(fullfile(outdir, 'tornado_lcoe.csv'), 'w');
    fprintf(fid, 'group,lcoe_low_USD_kWh,case_low,lcoe_base_USD_kWh,lcoe_high_USD_kWh,case_high\n');
    for j = 1:numel(Tn)
        fprintf(fid, '%s,%.4f,%s,%.4f,%.4f,%s\n', Tn(j).group, Tn(j).lo, strrep(Tn(j).lo_label, ',', ''), ...
                Tn(j).base, Tn(j).hi, strrep(Tn(j).hi_label, ',', ''));
    end
    fclose(fid);
end

write_readme(fullfile(outdir, 'README.md'), S);
end

% =========================================================================
function sp = spec_all()
% Columns of the run tables: header, KPI field, multiplier, number format.
sp = {
    'name',                        'name',           1,     '%s'
    'category',                    'category',       1,     '%s'
    'group',                       'group',          1,     '%s'
    'label',                       'label',          1,     '%s'
    'solved',                      'ok',             1,     '%d'
    'pv_kWp',                      'P_pv',           1,     '%.1f'
    'bess_kWh',                    'E_b',            1,     '%.1f'
    'bess_kW',                     'P_b',            1,     '%.1f'
    'diesel_kW',                   'P_d',            1,     '%.1f'
    'grid_connection_kW',          'P_gmax',         1,     '%.1f'
    'cost_USD_yr',                 'cost',           1,     '%.0f'
    'lcoe_USD_kWh',                'lcoe',           1,     '%.4f'
    'reference_cost_USD_yr',       'ref_cost',       1,     '%.0f'
    'savings_USD_yr',              'savings',        1,     '%.0f'
    'savings_pct',                 'savings_frac',   100,   '%.1f'
    'cost_pv_capex_USD_yr',        'c_pv_capex',     1,     '%.0f'
    'cost_pv_om_USD_yr',           'c_pv_om',        1,     '%.0f'
    'cost_bess_capex_USD_yr',      'c_b_capex',      1,     '%.0f'
    'cost_bess_om_USD_yr',         'c_b_om',         1,     '%.0f'
    'cost_bess_degradation_USD_yr','c_b_deg',        1,     '%.0f'
    'cost_diesel_capex_USD_yr',    'c_d_capex',      1,     '%.0f'
    'cost_fuel_USD_yr',            'c_fuel',         1,     '%.0f'
    'cost_diesel_om_USD_yr',       'c_dg_om',        1,     '%.0f'
    'cost_grid_USD_yr',            'c_grid',         1,     '%.0f'
    'load_MWh',                    'E_load',         1e-3,  '%.1f'
    'served_MWh',                  'E_served',       1e-3,  '%.1f'
    'pv_available_MWh',            'E_pv_avail',     1e-3,  '%.1f'
    'pv_used_MWh',                 'E_pv_used',      1e-3,  '%.1f'
    'pv_curtailed_MWh',            'E_curt',         1e-3,  '%.1f'
    'curtailment_pct',             'curt_frac',      100,   '%.1f'
    'grid_MWh',                    'E_grid',         1e-3,  '%.1f'
    'diesel_MWh',                  'E_diesel',       1e-3,  '%.1f'
    'fuel_L',                      'fuel_L',         1,     '%.0f'
    'bess_discharge_MWh',          'E_dis',          1e-3,  '%.1f'
    'bess_cycles_per_yr',          'cycles',         1,     '%.1f'
    'renewable_fraction_pct',      're_frac',        100,   '%.1f'
    'non_grid_diesel_share_pct',   're_frac_served', 100,   '%.1f'
    'lpsp_pct',                    'lpsp',           100,   '%.3f'
    'unserved_noncritical_kWh',    'E_uns_n',        1,     '%.1f'
    'unserved_critical_kWh',       'E_uns_c',        1,     '%.1f'
    'shedding_hours',              'uns_hours',      1,     '%d'
    'shedding_max_kW',             'uns_max_kW',     1,     '%.1f'
    'shedding_share_dec_mar_pct',  'uns_winter_frac',100,   '%.1f'
    'co2_t',                       'co2_t',          1,     '%.1f'
    'co2_saved_t',                 'co2_saved_t',    1,     '%.1f'
    'diesel_hours',                'dg_hours',       1,     '%d'
    'diesel_hours_below_30pct',    'dg_below_min_h', 1,     '%d'
    'check_balance_kW',            'chk_balance',    1,     '%.1e'
    'check_soc_kWh',               'chk_soc',        1,     '%.1e'
    'check_simultaneous_kW',       'chk_simul_kW',   1,     '%.1e'
    'check_diesel_while_curtail_h','chk_dg_curt_h',  1,     '%d'
    'check_diesel_grid_spare_h',   'chk_dg_grid_h',  1,     '%d'
    'check_diesel_charging_h',     'chk_dg_charge_h',1,     '%d'
    'solve_time_s',                'solve_time',     1,     '%.1f'
    'variables',                   'n_var',          1,     '%d'
    'equalities',                  'n_eq',           1,     '%d'
    'inequalities',                'n_ineq',         1,     '%d'
    'nonzeros',                    'n_nz',           1,     '%d'
    'solver',                      'solver',         1,     '%s'
    };
end

% =========================================================================
function sp = spec_short()
% The columns of the paper tables.
sp = spec_all();
keep = {'name', 'group', 'label', 'pv_kWp', 'bess_kWh', 'bess_kW', 'diesel_kW', 'cost_USD_yr', ...
        'lcoe_USD_kWh', 'reference_cost_USD_yr', 'savings_USD_yr', 'savings_pct', 'grid_MWh', ...
        'diesel_MWh', 'fuel_L', 'renewable_fraction_pct', 'curtailment_pct', 'lpsp_pct', ...
        'unserved_noncritical_kWh', 'unserved_critical_kWh', 'bess_cycles_per_yr', 'co2_t', 'co2_saved_t'};
sp = sp(ismember(sp(:, 1), keep), :);
end

% =========================================================================
function write_runs(fname, K, sp)
fid = fopen(fname, 'w');
fprintf(fid, '%s\n', strjoin(sp(:, 1)', ','));
for j = 1:numel(K)
    c = cell(1, size(sp, 1));
    for q = 1:size(sp, 1)
        c{q} = cellstr_of(K(j), sp(q, :));
    end
    fprintf(fid, '%s\n', strjoin(c, ','));
end
fclose(fid);
end

% =========================================================================
function str = cellstr_of(K, sprow)
% One table cell as text.
v = K.(sprow{2});
if ischar(v)
    str = strrep(v, ',', ';');
elseif isnan(v)
    str = '';
else
    str = sprintf(sprow{4}, double(v) * sprow{3});
    if ~isempty(regexp(str, '^-0(\.0+)?$', 'once')), str = str(2:end); end    % no "-0.0"
end
end

% =========================================================================
function write_readme(fname, S)
full = ~isempty(S.Ksens);
B = S.Kbase;  F = S.Kref;  s = S.base;
fid = fopen(fname, 'w');
p = @(varargin) fprintf(fid, varargin{:});

p('# Results: Faqra Club PV + battery microgrid (LP model)\n\n');
p('Written by `model/main.m` on %s with %s. Solver: %s. ', S.info.date, S.info.software, S.info.solver);
p('Run time %.0f s. Do not edit by hand: re-run `main` to regenerate every file in this folder.\n\n', S.info.run_time);
if ~isempty(strfind(S.info.software, 'Octave')) %#ok<STREMP>
    p(['**These numbers were produced with GNU Octave and HiGHS, not with MATLAB.** The model code is the ' ...
       'same; in MATLAB `solve_lp.m` calls `linprog`. Re-run `main` in MATLAB before quoting the numbers ' ...
       'in the paper. The optimal cost of an LP is unique, so the costs should agree; sizes and the hourly ' ...
       'dispatch can differ slightly where several solutions are equally cheap.\n\n']);
end
if ~full
    p('**Quick run:** only the reference and the base case were solved. Run `main` for the full study.\n\n');
end

% ------------------------------------------------------------ headline
p('## Base case\n\n');
p(['Base load (club + chalets, %s MWh/yr, peak %.0f kW), measured EDL feeder availability, base ' ...
   'irradiance with snow loss, all parameters at base, LPSP limit %g%%. PV tilt %d deg is the cheapest ' ...
   'of the four tilts.\n\n'], commas(B.E_load / 1000), B.peak_load, 100 * s.lpsp_max, S.best_tilt);
p('| | Reference (grid + diesel) | Base case (PV + battery + grid + diesel) |\n|---|---|---|\n');
p('| PV | 0 | %s kWp |\n', commas(B.P_pv));
p('| Battery | 0 | %s kWh / %s kW |\n', commas(B.E_b), commas(B.P_b));
p('| Diesel rating needed | %.0f kW | %.0f kW |\n', F.P_d, B.P_d);
p('| Annualized cost | %s $/yr | %s $/yr |\n', commas(F.cost), commas(B.cost));
p('| LCOE | %.3f $/kWh | %.3f $/kWh |\n', F.lcoe, B.lcoe);
p('| Grid energy | %s MWh | %s MWh |\n', commas(F.E_grid / 1000), commas(B.E_grid / 1000));
p('| Diesel energy | %s MWh | %s MWh |\n', commas(F.E_diesel / 1000), commas(B.E_diesel / 1000));
p('| Fuel | %s L | %s L |\n', commas(F.fuel_L), commas(B.fuel_L));
p('| Renewable fraction (PV used / load) | 0%% | %.1f%% |\n', 100 * B.re_frac);
p('| PV curtailed | | %.1f%% of available PV |\n', 100 * B.curt_frac);
p('| LPSP achieved | %.2f%% | %.2f%% |\n', 100 * F.lpsp, 100 * B.lpsp);
p('| Unserved critical load | %.1f kWh | %.1f kWh |\n', F.E_uns_c, B.E_uns_c);
p('| Load shedding | %d h, up to %.0f kW | %d h, up to %.0f kW |\n', F.uns_hours, F.uns_max_kW, ...
  B.uns_hours, B.uns_max_kW);
p('| Battery cycles | | %.0f per year |\n', B.cycles);
p('| CO2 | %s t/yr | %s t/yr |\n\n', commas(F.co2_t), commas(B.co2_t));
p('Saving against the reference: **%s $/yr (%.1f%%)**, and %s t CO2 per year.\n\n', ...
  commas(B.savings), 100 * B.savings_frac, commas(B.co2_saved_t));
p('Cost breakdown of the base case ($/yr): PV capex %s, PV O&M %s, battery capex %s, battery O&M %s, ', ...
  commas(B.c_pv_capex), commas(B.c_pv_om), commas(B.c_b_capex), commas(B.c_b_om));
p('battery degradation %s, diesel capex %s, fuel %s, diesel O&M %s, grid energy %s.\n\n', ...
  commas(B.c_b_deg), commas(B.c_d_capex), commas(B.c_fuel), commas(B.c_dg_om), commas(B.c_grid));

p(['The %g%% of load that may be shed is non-critical load only. The model uses the allowance in ' ...
   'the hours that set the diesel rating: load is shed in %d hours, up to %.0f kW at a time, and %.0f%% ' ...
   'of the shed energy falls in December to March (`fig_dispatch_winter_week.png` shows some of these ' ...
   'hours). With LPSP 0%% nothing is shed; the `lpsp_0` sensitivity gives the cost and the diesel rating ' ...
   'of that design.\n\n'], 100 * s.lpsp_max, B.uns_hours, B.uns_max_kW, 100 * B.uns_winter_frac);

% ---------------------------------------------------------------- tilt
p('## PV tilt\n\n');
md_runs(fid, S.Ktilt, false);
ct = sort([S.Ktilt.cost]);
p(['The two cheapest tilts differ by %s $/yr (%.2f%% of the cost), so the choice between them is not ' ...
   'decided by cost.\n\n'], commas(ct(2) - ct(1)), 100 * (ct(2) - ct(1)) / ct(1));

if full
    % ------------------------------------------------------ sensitivities
    p('## Sensitivities (one change at a time from the base case)\n\n');
    p(['"Saving" compares each case with its own reference, that is grid + diesel only under the same ' ...
       'load, grid availability, prices and LPSP limit.\n\n']);
    md_runs(fid, [B, S.Ksens], true);
    Kl = S.Ksens(strcmp({S.Ksens.group}, 'Load'));
    if ~isempty(Kl)
        p(['The load scenarios change the size of the system and its cost (%s to %s $/yr) much more than ' ...
           'the LCOE.\n\n'], commas(min([Kl.cost])), commas(max([Kl.cost])));
    end
    bad = S.Ksens(~[S.Ksens.ok]);
    for j = 1:numel(bad)
        p('- `%s` did not solve (infeasible or solver error).\n', bad(j).name);
    end
    if ~isempty(bad), p('\n'); end

    % ------------------------------------------------------ weather years
    p('## Weather robustness (base-case sizes fixed, dispatch re-optimized)\n\n');
    p(['PV yield of each weather year 2014-2023 at tilt %d deg, same load and grid. Load may be shed beyond ' ...
       'the LPSP limit at a penalty, so a shortfall shows up as LPSP above %g%% or as unserved critical ' ...
       'load. (a) keeps the diesel rating at the base-case value of %.0f kW; (b) lets the diesel rating ' ...
       'be as large as needed, since the existing sets also carry the status quo.\n\n'], ...
       S.best_tilt, 100 * s.lpsp_max, B.P_d);
    p(['| Year | (a) cost $/yr | (a) LPSP | (a) unserved critical kWh | (b) cost $/yr | (b) LPSP | ' ...
       '(b) diesel kW | (b) diesel MWh |\n|---|---|---|---|---|---|---|---|\n']);
    for j = 1:numel(S.years)
        a = S.Kwx(j);  b = S.Kwx_free(j);
        p('| %d | %s | %.2f%% | %.1f | %s | %.2f%% | %.0f | %.0f |\n', S.years(j), commas(a.cost), ...
          100 * a.lpsp, a.E_uns_c, commas(b.cost), 100 * b.lpsp, b.P_d, b.E_diesel / 1000);
    end
    [~, ja] = max([S.Kwx.lpsp]);  [~, jc] = max([S.Kwx.cost]);  [~, jb] = max([S.Kwx_free.cost]);
    p(['\nWorst year with all sizes fixed: LPSP %.2f%% (%d), unserved critical load %.1f kWh, cost up to ' ...
       '%s $/yr (%d) against %s $/yr in the design year. With the diesel rating free: worst cost ' ...
       '%s $/yr (%d), worst LPSP %.2f%%, unserved critical load %.1f kWh, diesel rating up to %.0f kW.\n\n'], ...
       100 * S.Kwx(ja).lpsp, S.years(ja), max([S.Kwx.E_uns_c]), commas(S.Kwx(jc).cost), S.years(jc), ...
       commas(B.cost), commas(S.Kwx_free(jb).cost), S.years(jb), 100 * max([S.Kwx_free.lpsp]), ...
       max([S.Kwx_free.E_uns_c]), max([S.Kwx_free.P_d]));

    % --------------------------------------------------------- cross-check
    p('## Cross-check against `tools/prototype_lp.py`\n\n');
    p(['With the prototype''s settings (tilt 40 deg, 5 MW grid connection, battery O&M as 2.5%% of the ' ...
       'annualized capex, 1e-4 $/kWh on charging) the model gives the prototype''s results:\n\n']);
    p(['| Run | PV kWp | BESS kWh | Cost $/yr | LCOE $/kWh | Renewable fraction | Diesel MWh |\n' ...
       '|---|---|---|---|---|---|---|\n']);
    for j = 1:numel(S.cross.rows)
        r = S.cross.rows(j);
        p('| %s, prototype | %s | %s | %s | %.3f | %.0f%% | %.0f |\n', r.label, commas(r.proto(1)), ...
          commas(r.proto(2)), commas(r.proto(3)), r.proto(4), 100 * r.proto(5), r.proto(6));
        p('| %s, this model | %s | %s | %s | %.3f | %.0f%% | %.0f |\n', r.label, commas(r.model(1)), ...
          commas(r.model(2)), commas(r.model(3)), r.model(4), 100 * r.model(5), r.model(6));
    end
    p(['\nThe prototype reports a diesel rating of 499 to 519 kW. That number is arbitrary there: the ' ...
       'rating has no cost, so any value above the largest diesel output is optimal. This model returns ' ...
       'the smallest rating that is enough (see the notes below).\n\n']);
    p('From the prototype to the base case of this study:\n\n');
    p('| Step | PV kWp | BESS kWh | Cost $/yr | LCOE $/kWh |\n|---|---|---|---|---|\n');
    for j = 1:numel(S.cross.steps)
        K = S.cross.steps(j).K;
        p('| %d. %s | %s | %s | %s | %.3f |\n', j, S.cross.steps(j).label, commas(K.P_pv), commas(K.E_b), ...
          commas(K.cost), K.lcoe);
    end
    p('\n');
end

% -------------------------------------------------------------- checks
p('## Checks\n\n');
p('- Inputs: %d of %d annual sums and peaks match `inputs/inputs_summary.md` (`input_checks.csv`).\n', ...
  sum([S.chk.pass]), numel(S.chk));
p('- 48-hour test (`model/tests/test_small_case.m`): all hand-calculated cases reproduced.\n');
p(['- Base case LP: %s variables, %s equality and %s inequality constraints, %s non-zeros. ' ...
   'Solver status: optimal. Solve time %.1f s.\n'], commas(B.n_var), commas(B.n_eq), commas(B.n_ineq), ...
   commas(B.n_nz), B.solve_time);
p('- Power balance residual: at most %.1e kW in any hour.\n', B.chk_balance);
p('- Battery energy balance and cyclic condition: residual at most %.1e kWh.\n', B.chk_soc);
p('- Simultaneous charge and discharge: %d hours (largest overlap %.1e kW).\n', B.chk_simul_h, B.chk_simul_kW);
if full
    jd = find(abs([S.Kwx.E_pv_avail] - B.E_pv_avail) < 1e-6 * B.E_pv_avail, 1);
    if ~isempty(jd)
        p(['- Dispatch-only run with the design weather year (%d) and the base-case sizes gives the ' ...
           'base-case cost again (difference %.2f $/yr).\n'], S.years(jd), abs(S.Kwx(jd).cost - B.cost));
    end
end
p(['- Diesel: runs %d hours. Hours with diesel while PV is curtailed: %d; while the grid has spare ' ...
   'capacity: %d; while the battery charges: %d.\n'], B.dg_hours, B.chk_dg_curt_h, B.chk_dg_grid_h, ...
   B.chk_dg_charge_h);
if B.chk_udg_gap < 1e-6
    p(['- Committed capacity: u_dg equals p_dg in every hour (largest gap %.1e kW), so the minimum-load ' ...
       'constraint (5c) never binds and fuel use is (a + b) = %.3f L/kWh.\n'], B.chk_udg_gap, ...
       s.fuel_a + s.fuel_b);
else
    p('- Committed capacity: u_dg exceeds p_dg by up to %.1f kW.\n', B.chk_udg_gap);
end
p(['- In %d of the %d diesel hours the output is below %g%% of the full rating of %.0f kW, which one ' ...
   'single set of that size could not do.\n'], B.dg_below_min_h, B.dg_hours, 100 * s.m_min, B.P_d);
if full
    K = [S.Ktilt, S.Ksens];  K = K([K.ok]);
    p(['- Across the %d sizing runs: largest power balance residual %.1e kW, largest overlap of charge ' ...
       'and discharge %.1e kW.\n'], numel(K), max([K.chk_balance]), max([K.chk_simul_kW]));
end
p('\n');

% --------------------------------------------------------------- notes
p('## Choices made where the brief left room\n\n');
p(['- **Grid connection.** `P_gmax` is fixed to the peak of the scenario''s load (%.0f kW in the base ' ...
   'case). It has no cost in the objective, so it cannot be a free decision. The `grid_5MW` sensitivity ' ...
   'shows the effect of a connection that never limits.\n'], B.P_gmax);
p(['- **Zero-cost sizes.** The diesel rating (existing sets, capex 0) and, with the all-in battery cost, ' ...
   'the PCS rating have no cost, so the LP alone does not fix them. A tie-breaker of %g $/kW-yr makes ' ...
   'the solver return the smallest rating that is enough. It is excluded from every reported cost. ' ...
   'One consequence: which hours are shed under the LPSP limit is also a tie in cost (every diesel kWh ' ...
   'costs the same), and the tie-breaker settles it by shedding at the diesel peaks.\n'], s.tie);
p(['- **Battery cost.** Base: all-in %g $/kWh on `E_b`, with the power rating limited to %gC. O&M is ' ...
   '%g%% of the capex per year. `batt_split` uses %g $/kWh + %g $/kW instead.\n'], s.c_b_allin, s.c_max, ...
   100 * s.om_b_frac, s.c_bE, s.c_bP);
p(['- **Reference.** Grid + diesel only, with the same LPSP limit as the case it is compared with, so ' ...
   'it may also shed up to %g%% of the load.\n'], 100 * s.lpsp_max);
p(['- **Snow 15%%.** The series without snow, multiplied by 0.85 in December to March.\n']);
p(['- **Cold-weather derating.** The usable capacity (1 - SOC_min) E_b is multiplied by the factor in ' ...
   'December to March (upper SOC bound lowered).\n']);
p(['- **Dispatch-only runs.** Penalties of %g $/kWh on shedding above the LPSP limit and %g $/kWh on ' ...
   'unserved critical load rank the goals. They are numerical weights, not a value of lost load, and ' ...
   'are excluded from the reported cost.\n'], s.pen_ls_n, s.pen_ls_c);
p(['- **Definitions.** Renewable fraction = PV used / load (course slides). Battery cycles = energy ' ...
   'discharged / E_b. LPSP = unserved energy / load. LCOE = annualized cost / served energy.\n\n']);

p('## Not in the model\n\n');
p(['PV degradation over the years, the EDL fixed charge (0.6 $/kVA per month), grid export, the T1 lift ' ...
   'recovery reserve, and a renewable-share constraint (constraint 7 is implemented, `re_min`, but no ' ...
   'target value is given in `parameters.json`, so no run uses it).\n\n']);

% --------------------------------------------------------------- files
p('## Files\n\n');
p('| File | Content |\n|---|---|\n');
p('| `runs_all.csv` | Every run: sizes, cost breakdown, energies, emissions, checks, solver |\n');
p('| `table_base_vs_reference.csv` | Base case next to the reference |\n');
p('| `table_tilt.csv` | Base case at tilt 30/40/50/60 |\n');
if full
    p('| `table_sensitivities.csv` | Base case and all sensitivities |\n');
    p('| `table_weather_years.csv` | Dispatch-only runs for 2014-2023, (a) and (b) |\n');
    p('| `table_crosscheck_prototype.csv` | Comparison with the Python prototype |\n');
    p('| `tornado_lcoe.csv` | Data of the tornado chart |\n');
end
p('| `dispatch_base_hourly.csv` | Hourly dispatch of the base case (8,760 rows) |\n');
p('| `input_checks.csv` | Loaded series against `inputs/inputs_summary.md` |\n');
p('| `fig_dispatch_winter_week.png` | Dispatch in the week of the highest-load ski weekend |\n');
p('| `fig_dispatch_summer_week.png` | Dispatch in a summer week |\n');
p('| `fig_soc_year.png` | Battery state of charge over the year |\n');
p('| `fig_monthly_energy.png` | Monthly energy balance |\n');
if full
    p('| `fig_tornado_lcoe.png` | Sensitivity of the LCOE |\n');
end
fclose(fid);
end

% =========================================================================
function md_runs(fid, K, with_saving)
% Markdown table of runs.
fprintf(fid, '| Case | PV kWp | BESS kWh | Diesel kW | Cost $/yr | LCOE $/kWh | Saving | Renewable | Diesel MWh | LPSP |\n');
fprintf(fid, '|---|---|---|---|---|---|---|---|---|---|\n');
for j = 1:numel(K)
    k = K(j);
    if ~k.ok
        fprintf(fid, '| %s | not solved | | | | | | | | |\n', k.name);
        continue
    end
    name = k.label;
    if with_saving && ~strcmp(k.group, 'Base'), name = [k.group ': ' k.label]; end
    fprintf(fid, '| %s | %s | %s | %.0f | %s | %.3f | %.1f%% | %.1f%% | %.0f | %.2f%% |\n', name, ...
            commas(k.P_pv), commas(k.E_b), k.P_d, commas(k.cost), k.lcoe, 100 * k.savings_frac, ...
            100 * k.re_frac, k.E_diesel / 1000, 100 * k.lpsp);
end
fprintf(fid, '\n');
end

% =========================================================================
function str = commas(x)
% Integer with thousands separators.
x = round(x);
str = regexprep(sprintf('%.0f', abs(x)), '(\d)(?=(\d{3})+$)', '$1,');
if x < 0, str = ['-' str]; end
end
