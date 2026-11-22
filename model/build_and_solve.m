function R = build_and_solve(s, D)
%BUILD_AND_SOLVE  Build and solve the sizing + dispatch LP for one scenario.
%
%   R = build_and_solve(s, D)
%
%   s   scenario struct (see scenarios.m): every scalar parameter, the names
%       of the input series to use, and optional fixed sizes in s.fix
%   D   inputs from load_inputs.m. Not needed when the scenario carries its
%       own series in s.series (used by tests/test_small_case.m).
%
%   R   result struct: sizes, hourly dispatch, solver status and problem size
%
% The model is a single linear program (no integer variables), as in the
% course example "MG Optimization Example Using LP Only". Equation numbers
% (1) to (7) are those of docs/fable_prompt.md.
%
% Units: kW, kWh, $, hours. Every variable is >= 0.
%
% Decision vector
%   hourly (T values each):
%     p_pv    PV power used                 p_g    grid import
%     p_cur   PV power curtailed            p_dg   diesel output
%     p_ch    battery charging power        u_dg   diesel committed capacity
%     p_dis   battery discharging power     ls_c   unserved critical load
%     soc     stored energy at the start    ls_n   unserved non-critical load
%             of hour t (kWh)
%   scalars:
%     P_pv (kWp), E_b (kWh), P_b (kW), P_d (kW), P_gmax (kW),
%     x_lpsp (kWh of non-critical shedding above the LPSP limit; fixed to 0
%             except in dispatch-only runs with s.elastic = true)

if nargin < 2, D = []; end
t_build = tic;

% ------------------------------------------------------------------ series
ser = get_series(s, D);
L   = ser.L(:);                 % load, kW
Lc  = ser.Lc(:);                % critical part of the load, kW
a   = ser.a(:);                 % PV output per kWp installed, kW/kWp
ug  = ser.ug(:);                % grid availability, 0/1
T   = numel(L);
dt  = s.dt;
Lnc = max(L - Lc, 0);           % non-critical part of the load, kW
E_load = sum(L) * dt;           % kWh

assert(all(Lc <= L + 1e-9), 'build_and_solve:critical', 'Critical load exceeds total load.');
assert(numel(a) == T && numel(ug) == T && numel(Lc) == T, 'build_and_solve:length', ...
       'Input series have different lengths.');

% Usable-capacity factor of the battery: 1, or s.cold_factor in s.cold_months
kcap = ones(T, 1);
kcap(ismember(ser.month(:), s.cold_months)) = s.cold_factor;

% Grid connection: a fixed number, or the peak of this scenario's load
if isempty(s.P_gmax), P_gmax = max(L); else, P_gmax = s.P_gmax; end

% --------------------------------------------------------------- variables
hv = {'p_pv', 'p_cur', 'p_ch', 'p_dis', 'soc', 'p_g', 'p_dg', 'u_dg', 'ls_c', 'ls_n'};
ix = struct();
for j = 1:numel(hv)
    ix.(hv{j}) = (j - 1) * T + (1:T)';
end
n0 = numel(hv) * T;
ix.P_pv = n0 + 1;  ix.E_b = n0 + 2;  ix.P_b = n0 + 3;
ix.P_d  = n0 + 4;  ix.P_gmax = n0 + 5;  ix.x_lpsp = n0 + 6;
nvar = n0 + 6;

% --------------------------------------------------------------- objective
% Annualized cost, $/yr:
%   CRF(i,n_pv) c_pv P_pv + O&M_pv P_pv
% + CRF(i,n_b) (c_bE E_b + c_bP P_b) + O&M_b      (or the all-in $/kWh on E_b)
% + CRF(i,n_d) c_d P_d
% + sum_t [ c_grid p_g + c_fuel (a u_dg + b p_dg) + c_om,d p_dg + c_deg p_dis ] dt
k = cost_coefficients(s);
c = zeros(nvar, 1);
c(ix.P_pv)  = k.pv_capex + k.pv_om;
c(ix.E_b)   = k.b_capex_E + k.b_om_E;
c(ix.P_b)   = k.b_capex_P + k.b_om_P;
c(ix.P_d)   = k.d_capex;
c(ix.p_g)   = k.grid * dt;
c(ix.u_dg)  = k.fuel_u * dt;
c(ix.p_dg)  = (k.fuel_p + k.dg_om) * dt;
c(ix.p_dis) = k.deg * dt;
c(ix.p_ch)  = k.ch * dt;

% Tie-breakers. A size with zero cost (P_d when the gensets are sunk, P_b
% with the all-in battery cost) is not determined by the LP. A negligible
% cost (s.tie, $/kW-yr) makes the solver return the smallest rating that is
% enough. It is not part of the reported cost.
tb = zeros(nvar, 1);
if c(ix.P_b) == 0, tb(ix.P_b) = s.tie; end
if c(ix.P_d) == 0, tb(ix.P_d) = s.tie; end

% Penalties, only for dispatch-only runs with fixed sizes (s.elastic): they
% keep the LP feasible and rank the goals: serve critical load first, then
% respect the LPSP limit, then minimize cost. They are numerical weights, not
% a value of lost load, and are not part of the reported cost.
pen = zeros(nvar, 1);
if s.elastic
    pen(ix.ls_c)   = s.pen_ls_c * dt;
    pen(ix.x_lpsp) = s.pen_ls_n;
end
f = c + tb + pen;

% -------------------------------------------------------------- equalities
next = [(2:T)'; 1];                 % cyclic: hour after T is hour 1
ceq = new_block();

% (1) power balance:  p_pv + p_dis + p_g + p_dg + ls_c + ls_n = L + p_ch
ceq = add_rows(ceq, {ix.p_pv, ix.p_dis, ix.p_g, ix.p_dg, ix.ls_c, ix.ls_n, ix.p_ch}, ...
                  {1, 1, 1, 1, 1, 1, -1}, L);

% (2) PV:  p_pv + p_cur = a(t) P_pv
ceq = add_rows(ceq, {ix.p_pv, ix.p_cur, ix.P_pv}, {1, 1, -a}, zeros(T, 1));

% (3a) battery energy:  soc(t+1) = soc(t) + eta_ch p_ch dt - p_dis dt / eta_dis,
%      cyclic: soc(T+1) = soc(1)
ceq = add_rows(ceq, {ix.soc(next), ix.soc, ix.p_ch, ix.p_dis}, ...
                  {1, -1, -s.eta_ch * dt, dt / s.eta_dis}, zeros(T, 1));

% ------------------------------------------------------------ inequalities
cin = new_block();

% (3b) soc(t) <= E_b; with the cold-weather option the usable capacity
%      (1 - SOC_min) E_b is multiplied by kcap(t) (0.87 in Dec-Mar)
cin = add_rows(cin, {ix.soc, ix.E_b}, {1, -(s.soc_min + kcap * (1 - s.soc_min))}, zeros(T, 1));

% (3c) soc(t) >= SOC_min E_b
cin = add_rows(cin, {ix.soc, ix.E_b}, {-1, s.soc_min}, zeros(T, 1));

% (3d) p_ch(t) <= P_b      (3e) p_dis(t) <= P_b
cin = add_rows(cin, {ix.p_ch,  ix.P_b}, {1, -1}, zeros(T, 1));
cin = add_rows(cin, {ix.p_dis, ix.P_b}, {1, -1}, zeros(T, 1));

% (3f) P_b <= c_max E_b
cin = add_rows(cin, {ix.P_b, ix.E_b}, {1, -s.c_max}, 0);

% (4) grid:  p_g(t) <= u_g(t) P_gmax   (no export)
cin = add_rows(cin, {ix.p_g, ix.P_gmax}, {1, -ug}, zeros(T, 1));

% (5a) diesel:  p_dg(t) <= u_dg(t)
cin = add_rows(cin, {ix.p_dg, ix.u_dg}, {1, -1}, zeros(T, 1));

% (5b) u_dg(t) <= P_d
cin = add_rows(cin, {ix.u_dg, ix.P_d}, {1, -1}, zeros(T, 1));

% (5c) p_dg(t) >= m_min u_dg(t)
cin = add_rows(cin, {ix.p_dg, ix.u_dg}, {-1, s.m_min}, zeros(T, 1));

% (6c) reliability, energy-based LPSP:  sum ls_n dt <= LPSP_max sum L dt
%      (x_lpsp is 0 unless s.elastic)
cin = add_sum_row(cin, [ix.ls_n; ix.x_lpsp], [dt * ones(T, 1); -1], s.lpsp_max * E_load);

% (7) optional renewable share (course slides):  sum p_pv dt >= RE_min sum L dt
if s.re_min > 0
    cin = add_sum_row(cin, ix.p_pv, -dt * ones(T, 1), -s.re_min * E_load);
end

Aeq = sparse(vertcat(ceq.I{:}), vertcat(ceq.J{:}), vertcat(ceq.V{:}), ceq.m, nvar);
beq = vertcat(ceq.b{:});
A   = sparse(vertcat(cin.I{:}), vertcat(cin.J{:}), vertcat(cin.V{:}), cin.m, nvar);
b   = vertcat(cin.b{:});

% ------------------------------------------------------------------ bounds
lb = zeros(nvar, 1);
ub = inf(nvar, 1);

% (6a) ls_c(t) <= critical load, and (6d) critical load must be met: ls_c = 0
if s.elastic
    ub(ix.ls_c) = Lc;
else
    ub(ix.ls_c) = 0;
end
% (6b) ls_n(t) <= non-critical load
ub(ix.ls_n) = Lnc;

if ~s.elastic, ub(ix.x_lpsp) = 0; end

% Grid connection is a fixed number (it has no cost in the objective)
lb(ix.P_gmax) = P_gmax;  ub(ix.P_gmax) = P_gmax;

% Fixed sizes: reference case (PV = battery = 0) and dispatch-only runs
fx = {'P_pv', 'E_b', 'P_b', 'P_d'};
for j = 1:numel(fx)
    if isfield(s.fix, fx{j}) && ~isempty(s.fix.(fx{j}))
        lb(ix.(fx{j})) = s.fix.(fx{j});
        ub(ix.(fx{j})) = s.fix.(fx{j});
    end
end

build_time = toc(t_build);

% ------------------------------------------------------------------- solve
[x, fval, exitflag, info] = solve_lp(f, A, b, Aeq, beq, lb, ub);

% ------------------------------------------------------------------ result
R = struct();
R.s          = s;
R.ok         = (exitflag == 1) && ~isempty(x);
R.exitflag   = exitflag;
R.solver     = info.solver;
R.message    = info.message;
R.iterations = info.iterations;
R.solve_time = info.time;
R.build_time = build_time;
R.n_var      = nvar;
R.n_eq       = size(Aeq, 1);
R.n_ineq     = size(A, 1);
R.n_nz       = nnz(Aeq) + nnz(A);
R.T          = T;
R.series     = struct('L', L, 'Lc', Lc, 'a', a, 'ug', ug, 'month', ser.month(:), 'kcap', kcap);
if ~R.ok
    return
end

x(abs(x) < 1e-9) = 0;           % remove solver noise around zero
for j = 1:numel(hv)
    R.(hv{j}) = x(ix.(hv{j}));
end
R.P_pv   = x(ix.P_pv);
R.E_b    = x(ix.E_b);
R.P_b    = x(ix.P_b);
R.P_d    = x(ix.P_d);
R.P_gmax = x(ix.P_gmax);
R.x_lpsp = x(ix.x_lpsp);
R.obj_solver = fval;            % includes tie-breakers and penalties
R.obj_cost   = c' * x;          % annualized cost only, $/yr
end

% =========================================================================
function ser = get_series(s, D)
% Hourly series for the scenario: load, critical load, PV per kWp, grid, month.
if isfield(s, 'series') && ~isempty(s.series)
    ser = s.series;             % supplied directly (test cases)
    return
end
ld = D.load.(s.load_case);
ser.L     = ld.(s.load_col);
ser.Lc    = ld.critical_kW;     % all critical load is club load (chalets: 0%)
ser.month = D.month;
if isfield(D.pv, s.pv_col)
    ser.a = D.pv.(s.pv_col);
else
    ser.a = D.pvmy.(s.pv_col);  % one weather year of the multi-year file
end
if s.snow_flat_decmar > 0       % flat snow loss in Dec-Mar on a no-snow series
    w = ismember(ser.month, [12 1 2 3]);
    ser.a(w) = ser.a(w) * (1 - s.snow_flat_decmar);
end
ser.ug = D.grid.(s.grid_col);
end

% =========================================================================
function blk = new_block()
blk = struct('I', {{}}, 'J', {{}}, 'V', {{}}, 'b', {{}}, 'm', 0);
end

% =========================================================================
function blk = add_rows(blk, cols, coefs, rhs)
% Append numel(rhs) constraint rows. Term j puts coefs{j} (a scalar or one
% value per row) in column cols{j} (one column for all rows, or one per row).
n = numel(rhs);
rows = blk.m + (1:n)';
for j = 1:numel(cols)
    cj = cols{j}(:);
    vj = coefs{j}(:);
    if isscalar(cj), cj = repmat(cj, n, 1); end
    if isscalar(vj), vj = repmat(vj, n, 1); end
    blk.I{end + 1, 1} = rows;
    blk.J{end + 1, 1} = cj;
    blk.V{end + 1, 1} = vj;
end
blk.b{end + 1, 1} = rhs(:);
blk.m = blk.m + n;
end

% =========================================================================
function blk = add_sum_row(blk, cols, coefs, rhs)
% Append one constraint row:  sum_j coefs(j) x(cols(j)) <= rhs.
blk.I{end + 1, 1} = repmat(blk.m + 1, numel(cols), 1);
blk.J{end + 1, 1} = cols(:);
blk.V{end + 1, 1} = coefs(:);
blk.b{end + 1, 1} = rhs;
blk.m = blk.m + 1;
end
