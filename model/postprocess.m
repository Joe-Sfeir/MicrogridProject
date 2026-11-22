function K = postprocess(R, Kref)
%POSTPROCESS  Key results (KPIs) and checks for one solved run.
%
%   K = postprocess(R)          KPIs of run R (from build_and_solve.m)
%   K = postprocess(R, Kref)    also savings against the reference run Kref
%
% Energies are in kWh per year, costs in $ per year, CO2 in tonnes per year.
% Definitions:
%   served energy       load minus unserved load
%   cost                annualized cost as in the LP objective (with the
%                       battery throughput cost and minus any export credit)
%   cost_no_deg         the same without the battery throughput cost, which
%                       pays for battery wear a second time (R5.3)
%   opex                yearly cash operating cost for the finance metrics:
%                       grid energy + fuel + diesel O&M + PV O&M + battery
%                       O&M - export credit (no throughput cost, R3.2)
%   LCOE                annualized cost / served energy
%   renewable fraction  PV used on site / load, where PV used on site is
%                       PV used minus PV exported;
%                       re_frac_served = 1 - (grid + diesel) / served energy
%   LPSP                unserved energy / load (energy-based)
%   battery cycles      energy discharged / E_b (equivalent full cycles per year)
%   shedding            uns_hours (hours with any unserved load), uns_max_kW
%                       and uns_max_hour (largest shed hour and its index),
%                       shares of the unserved energy on ski days
%                       (uns_ski_frac), in Dec-Mar (uns_winter_frac) and in
%                       the 7 consecutive days with the most shedding
%                       (uns_week_frac, starting at hour uns_week_start)
%   dg_short_n1/2/3     diesel hours that 1, 2 or 3 equal sets totalling P_d
%                       could not cover with each running set at or above
%                       the minimum load: 0 < p_dg < m_min P_d / n  (R5.2)

s  = R.s;
dt = s.dt;
K  = struct();
K.name  = s.name;
K.label = s.label;
K.group = s.group;
K.side  = s.side;
K.ok    = R.ok;
K.solver = R.solver;
K.solve_time = R.solve_time;
K.n_var = R.n_var;  K.n_eq = R.n_eq;  K.n_ineq = R.n_ineq;  K.n_nz = R.n_nz;

num = {'P_pv', 'E_b', 'P_b', 'P_d', 'P_gmax', 'cost', 'cost_no_deg', 'opex', 'c_pv_capex', ...
       'c_pv_om', 'c_b_capex', 'c_b_om', 'c_d_capex', 'c_grid', 'c_fuel', 'c_dg_om', 'c_b_deg', ...
       'c_ch', 'c_export', 'lcoe', 'lcoe_no_deg', 'E_load', 'E_served', 'E_pv_avail', 'E_pv_used', ...
       'E_export', 'E_curt', 'curt_frac', 'E_grid', 'E_diesel', 'fuel_L', 'E_dis', 'E_ch', 'cycles', ...
       're_frac', 're_frac_served', 'E_uns_c', 'E_uns_n', 'lpsp', 'uns_hours', 'uns_max_kW', ...
       'uns_max_hour', 'uns_winter_frac', 'uns_ski_frac', 'uns_week_frac', 'uns_week_start', ...
       'co2_t', 'co2_diesel_t', 'co2_grid_t', 'peak_load', 'chk_balance', 'chk_soc', ...
       'chk_simul_kW', 'chk_simul_h', 'chk_dg_curt_h', 'chk_dg_grid_h', 'chk_dg_charge_h', ...
       'chk_udg_gap', 'chk_reserve', 'chk_export', 'chk_imp_exp_kW', 'dg_hours', 'dg_short_n1', 'dg_short_n2', ...
       'dg_short_n3', 'chk_cost', 'ref_cost', 'ref_lcoe', 'ref_P_d', 'ref_opex', 'savings', ...
       'savings_frac', 'savings_no_deg', 'savings_no_deg_frac', 'co2_saved_t'};
for j = 1:numel(num), K.(num{j}) = NaN; end
if ~R.ok
    return
end

L = R.series.L;
T = R.T;
k = cost_coefficients(s);

% ------------------------------------------------------------------- sizes
K.P_pv = R.P_pv;  K.E_b = R.E_b;  K.P_b = R.P_b;  K.P_d = R.P_d;  K.P_gmax = R.P_gmax;

% ----------------------------------------------------------------- energies
K.peak_load  = max(L);
K.E_load     = sum(L) * dt;
K.E_uns_c    = sum(R.ls_c) * dt;
K.E_uns_n    = sum(R.ls_n) * dt;
K.E_served   = K.E_load - K.E_uns_c - K.E_uns_n;
K.E_pv_avail = sum(R.series.a) * R.P_pv * dt;
K.E_pv_used  = sum(R.p_pv) * dt;                % on site + exported
K.E_export   = sum(R.p_ex) * dt;
K.E_curt     = sum(R.p_cur) * dt;
K.E_grid     = sum(R.p_g) * dt;
K.E_diesel   = sum(R.p_dg) * dt;
K.E_dis      = sum(R.p_dis) * dt;
K.E_ch       = sum(R.p_ch) * dt;
K.fuel_L     = sum(s.fuel_a * R.u_dg + s.fuel_b * R.p_dg) * dt;   % F = a u_dg + b p_dg

K.curt_frac = safe_div(K.E_curt, K.E_pv_avail);
K.cycles    = safe_div(K.E_dis, R.E_b);
K.re_frac   = (K.E_pv_used - K.E_export) / K.E_load;
K.re_frac_served = 1 - (K.E_grid + K.E_diesel) / K.E_served;
K.lpsp      = (K.E_uns_c + K.E_uns_n) / K.E_load;

% ------------------------------------------------- when and where load is shed
uns = R.ls_c + R.ls_n;
E_uns = sum(uns);
K.uns_hours = sum(uns > 1e-6);
[K.uns_max_kW, K.uns_max_hour] = max(uns);
K.uns_winter_frac = safe_div(sum(uns(ismember(R.series.month, [12 1 2 3]))), E_uns);
K.uns_ski_frac    = safe_div(sum(uns(R.series.ski)), E_uns);
w  = min(168, T);                                % 7 consecutive days
cs = cumsum([0; uns]);
[in_week, K.uns_week_start] = max(cs(w + 1:end) - cs(1:end - w));
K.uns_week_frac = safe_div(in_week, E_uns);
if K.uns_hours == 0
    K.uns_max_hour = NaN;  K.uns_week_start = NaN;
end

% -------------------------------------------------------------------- costs
K.c_pv_capex = k.pv_capex * R.P_pv;
K.c_pv_om    = k.pv_om * R.P_pv;
K.c_b_capex  = k.b_capex_E * R.E_b + k.b_capex_P * R.P_b;
K.c_b_om     = k.b_om_E * R.E_b + k.b_om_P * R.P_b;
K.c_d_capex  = k.d_capex * R.P_d;
K.c_grid     = k.grid * K.E_grid;
K.c_fuel     = s.price_diesel * K.fuel_L;
K.c_dg_om    = k.dg_om * K.E_diesel;
K.c_b_deg    = k.deg * K.E_dis;
K.c_ch       = k.ch * K.E_ch;
K.c_export   = -k.ex * K.E_export;              % credit: negative cost
K.cost = K.c_pv_capex + K.c_pv_om + K.c_b_capex + K.c_b_om + K.c_d_capex + ...
         K.c_grid + K.c_fuel + K.c_dg_om + K.c_b_deg + K.c_ch + K.c_export;
K.cost_no_deg = K.cost - K.c_b_deg;
K.opex = K.c_grid + K.c_fuel + K.c_dg_om + K.c_pv_om + K.c_b_om + K.c_export;
K.lcoe = K.cost / K.E_served;
K.lcoe_no_deg = K.cost_no_deg / K.E_served;

% ---------------------------------------------------------------- emissions
K.co2_diesel_t = s.co2_diesel * K.fuel_L / 1000;
K.co2_grid_t   = s.co2_grid * K.E_grid / 1000;
K.co2_t        = K.co2_diesel_t + K.co2_grid_t;

% ------------------------------------------------------------------- checks
tol = 1e-6;                                        % kW
next = [(2:T)'; 1];
% power balance (1') closes every hour
K.chk_balance = max(abs(R.p_pv + R.p_dis + R.p_g + R.p_dg + R.ls_c + R.ls_n - L - R.p_ch - R.p_ex));
% battery energy balance (3a), including the cyclic condition soc(T+1) = soc(1)
K.chk_soc = max(abs(R.soc(next) - R.soc - s.eta_ch * R.p_ch * dt + R.p_dis * dt / s.eta_dis));
% simultaneous charge and discharge
both = min(R.p_ch, R.p_dis);
K.chk_simul_kW = max(both);
K.chk_simul_h  = sum(both > tol);
% diesel should not run while PV is curtailed, while cheaper grid energy is
% available, or to charge the battery
dg_on = R.p_dg > tol;
K.dg_hours        = sum(dg_on);
K.chk_dg_curt_h   = sum(dg_on & R.p_cur > tol);
if k.fuel_u + k.fuel_p + k.dg_om > k.grid          % grid energy is the cheaper one
    K.chk_dg_grid_h = sum(dg_on & (R.series.ug * R.P_gmax - R.p_g - R.p_ex) > tol);
else
    K.chk_dg_grid_h = 0;                           % diesel is cheaper: nothing to check
end
K.chk_dg_charge_h = sum(dg_on & R.p_ch > tol);
% committed capacity above output (0 means the plant always runs at full
% load of what is committed, so constraint (5c) is not binding)
K.chk_udg_gap = max(R.u_dg - R.p_dg);
% (R5.2) diesel hours that n equal sets totalling P_d cannot cover at or
% above the minimum load: with k of the n sets running the output range is
% [k m_min P_d/n, k P_d/n], and these ranges overlap, so only outputs below
% m_min P_d / n are out of reach
K.dg_short_n1 = sum(dg_on & R.p_dg < s.m_min * R.P_d / 1 - tol);
K.dg_short_n2 = sum(dg_on & R.p_dg < s.m_min * R.P_d / 2 - tol);
K.dg_short_n3 = sum(dg_on & R.p_dg < s.m_min * R.P_d / 3 - tol);
% (R5.1) T1 lift reserve: largest shortfall of soc below SOC_min E_b + E_res
% at the start or the end of an hour in which the lift runs (0 = respected)
K.chk_reserve = max([0; s.soc_min * R.E_b + s.E_res - R.soc(R.series.hold_res)]) * (s.E_res > 0);
% export limits (4') and (4''): largest violation (0 = respected)
K.chk_export = max([0; R.p_g + R.p_ex - R.series.ug * R.P_gmax; R.p_ex - R.p_pv]);
% import and export in the same hour (kW): a wash when credit = tariff
K.chk_imp_exp_kW = max(min(R.p_g, R.p_ex));
% cost from the breakdown equals the cost part of the solver objective
K.chk_cost = abs(K.cost - R.obj_cost);

% ---------------------------------------------------------------- reference
if nargin >= 2 && ~isempty(Kref)
    K.ref_cost     = Kref.cost;
    K.ref_lcoe     = Kref.lcoe;
    K.ref_P_d      = Kref.P_d;
    K.ref_opex     = Kref.opex;
    K.savings      = Kref.cost - K.cost;
    K.savings_frac = K.savings / Kref.cost;
    K.savings_no_deg      = Kref.cost_no_deg - K.cost_no_deg;
    K.savings_no_deg_frac = K.savings_no_deg / Kref.cost_no_deg;
    K.co2_saved_t  = Kref.co2_t - K.co2_t;
end
end

% =========================================================================
function q = safe_div(a, b)
if b > 0, q = a / b; else, q = 0; end
end
