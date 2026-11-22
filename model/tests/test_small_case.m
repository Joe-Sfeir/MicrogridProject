function test_small_case()
%TEST_SMALL_CASE  48-hour toy cases with answers that can be checked by hand.
%
% Run from anywhere:  run('model/tests/test_small_case.m')  or  test_small_case
% Each case uses round parameters (not the Faqra inputs), a flat 100 kW load
% and two identical days, so the optimum follows from simple arithmetic.
% The function stops with an error at the first failed check.
%
%   Case 1  island PV + battery (no grid, diesel priced out)
%   Case 2  status quo: grid half of the time, diesel otherwise
%   Case 3  case 2 with LPSP_max = 5 % and a 60 kW critical load
%   Case 4  dispatch-only with a diesel set that is too small (elastic run)
%   Case 5  case 1 with the cold-weather capacity factor 0.87
%   Case 6  case 1 with the battery cost split into energy and power parts

addpath(fileparts(fileparts(mfilename('fullpath'))));
fprintf('test_small_case\n');

T  = 48;
hr = mod((0:T - 1)', 24) + 1;                 % hour of day, 1..24
sun = double(hr >= 7 & hr <= 18);             % 12 sun hours per day
eta = 0.95;

% ---------------------------------------------------------------- Case 1
% Night load: 12 h x 100 kW = 1200 kWh, all from the battery.
%   SOC swing        = 1200 / eta_dis                  = 1263.158 kWh
%   E_b              = swing / (1 - SOC_min)           = 1403.509 kWh
%   charging energy  = swing / eta_ch                  = 1329.640 kWh per day
%   P_pv             = (1200 + 1329.640) / (12 x 0.8)  =  263.504 kWp
%   P_b              = 1329.640 / 12                   =  110.803 kW
s = toy_scenario();
s.name = 'toy1_island';
s.price_diesel = 1000;                        % diesel priced out
s.series = toy_series(T, 100, 30, 0.8 * sun, zeros(T, 1));
[R, K] = run_case(s);
swing = 1200 / eta;
E_b   = swing / 0.9;
E_ch  = swing / eta;
P_pv  = (1200 + E_ch) / (12 * 0.8);
P_b   = E_ch / 12;
cost  = P_pv * (crf(0.10, 20) * 1000 + 20) + E_b * (crf(0.10, 10) * 300 + 0.02 * 300) + 0.02 * 2400;
near(R.P_pv, P_pv, 'case 1: P_pv');
near(R.E_b,  E_b,  'case 1: E_b');
near(R.P_b,  P_b,  'case 1: P_b');
near(K.cost, cost, 'case 1: annualized cost');
near(K.E_diesel, 0, 'case 1: diesel energy');
near(K.E_curt,   0, 'case 1: curtailment');
near(K.E_dis, 2400, 'case 1: battery discharge');
near(K.re_frac, (2400 + 2 * E_ch) / 4800, 'case 1: PV used / load');
near(max(R.soc), E_b,       'case 1: SOC reaches E_b');
near(min(R.soc), 0.1 * E_b, 'case 1: SOC reaches SOC_min E_b');

% ---------------------------------------------------------------- Case 2
% Grid on in 6-hour blocks (24 h of 48), no PV and no battery.
%   grid 2400 kWh, diesel 2400 kWh, P_d = 100 kW
%   fuel = (a + b) x 2400 = 0.27 x 2400 = 648 L
%   cost = 0.25 x 2400 + 1.5 x 648 + 0.01 x 2400 = 1596 $
grid_on = double(mod(floor((0:T - 1)' / 6), 2) == 0);
s = toy_scenario();
s.name = 'toy2_reference';
s.fix = struct('P_pv', 0, 'E_b', 0, 'P_b', 0);
s.series = toy_series(T, 100, 60, 0.8 * sun, grid_on);
[R, K] = run_case(s);
near(K.E_grid,   2400, 'case 2: grid energy');
near(K.E_diesel, 2400, 'case 2: diesel energy');
near(R.P_d,       100, 'case 2: P_d');
near(K.fuel_L,    648, 'case 2: fuel');
near(K.cost,     1596, 'case 2: cost');
near(K.lcoe, 1596 / 4800, 'case 2: LCOE');
near(K.co2_t, (2.68 * 648 + 0.70 * 2400) / 1000, 'case 2: CO2');
near(K.chk_udg_gap, 0, 'case 2: u_dg = p_dg');

% ---------------------------------------------------------------- Case 3
% As case 2 with LPSP_max = 5 %: 240 kWh may be shed, and it is shed in
% diesel hours (0.415 $/kWh) rather than grid hours (0.25 $/kWh). Spread
% over the 24 diesel hours this is 10 kW, so P_d = 90 kW.
%   cost = 600 + (1.5 x 0.27 + 0.01) x 2160 = 1496.4 $
s.name = 'toy3_lpsp';
s.lpsp_max = 0.05;
[R, K] = run_case(s);
near(K.E_uns_n,   240, 'case 3: non-critical shedding');
near(K.E_uns_c,     0, 'case 3: critical load served');
near(K.lpsp,     0.05, 'case 3: LPSP');
near(K.E_diesel, 2160, 'case 3: diesel energy');
near(R.P_d,        90, 'case 3: P_d');
near(K.cost,   1496.4, 'case 3: cost');
assert(all(R.ls_n <= 40 + 1e-6), 'case 3: ls_n above the non-critical load');
assert(all(R.ls_n(grid_on == 1) < 1e-6), 'case 3: load shed while the grid is on');

% ---------------------------------------------------------------- Case 4
% Dispatch-only with fixed sizes and LPSP_max = 0, elastic.
%   P_d = 80 kW: 20 kW short in 24 diesel hours -> 480 kWh non-critical unserved
%   P_d = 30 kW: 70 kW short -> 40 kW non-critical + 30 kW critical unserved
s.name = 'toy4_elastic';
s.lpsp_max = 0;
s.elastic = true;
s.fix.P_d = 80;
[~, K] = run_case(s);
near(K.E_uns_n, 480, 'case 4a: non-critical unserved');
near(K.E_uns_c,   0, 'case 4a: critical unserved');
near(K.lpsp,   0.10, 'case 4a: LPSP');
s.fix.P_d = 30;
[~, K] = run_case(s);
near(K.E_uns_n, 960, 'case 4b: non-critical unserved');
near(K.E_uns_c, 720, 'case 4b: critical unserved');
near(K.cost, 600 + (1.5 * 0.27 + 0.01) * 720, 'case 4b: cost excludes penalties');

% ---------------------------------------------------------------- Case 5
% Case 1 with usable capacity x 0.87 in every hour: E_b = swing / (0.9 x 0.87)
s = toy_scenario();
s.name = 'toy5_cold';
s.price_diesel = 1000;
s.cold_factor = 0.87;
s.series = toy_series(T, 100, 30, 0.8 * sun, zeros(T, 1));
[R, ~] = run_case(s);
near(R.E_b, swing / (0.9 * 0.87), 'case 5: E_b with cold derating');
near(R.P_pv, P_pv, 'case 5: P_pv unchanged');

% ---------------------------------------------------------------- Case 6
% Case 1 with split battery cost: same sizes, cost on E_b and on P_b.
s.name = 'toy6_split';
s.cold_factor = 1;
s.batt_cost_mode = 'split';
[R, K] = run_case(s);
cost = P_pv * (crf(0.10, 20) * 1000 + 20) + ...
       (E_b * 200 + P_b * 200) * (crf(0.10, 10) + 0.02) + 0.02 * 2400;
near(R.E_b, E_b, 'case 6: E_b');
near(R.P_b, P_b, 'case 6: P_b');
near(K.cost, cost, 'case 6: cost');

fprintf('All small-case tests passed.\n');
end

% =========================================================================
function [R, K] = run_case(s)
% Solve and apply the checks that must hold for every run.
R = build_and_solve(s);
assert(R.ok, '%s: solver did not return an optimal solution (%s)', s.name, R.message);
K = postprocess(R);
tol = 1e-6;
assert(K.chk_balance < tol, '%s: power balance residual %.2e kW', s.name, K.chk_balance);
assert(K.chk_soc < tol, '%s: SOC balance or cyclic residual %.2e kWh', s.name, K.chk_soc);
assert(K.chk_simul_kW < tol, '%s: simultaneous charge and discharge', s.name);
assert(all(R.soc <= R.E_b + tol) && all(R.soc >= s.soc_min * R.E_b - tol), '%s: SOC bounds', s.name);
assert(all(R.p_ch <= R.P_b + tol) && all(R.p_dis <= R.P_b + tol), '%s: battery power', s.name);
assert(R.P_b <= s.c_max * R.E_b + tol, '%s: C-rate', s.name);
assert(all(R.p_g <= R.series.ug * R.P_gmax + tol), '%s: grid limit', s.name);
assert(all(R.p_dg <= R.u_dg + tol) && all(R.u_dg <= R.P_d + tol), '%s: diesel limits', s.name);
assert(all(R.p_dg >= s.m_min * R.u_dg - tol), '%s: diesel minimum load', s.name);
assert(K.chk_cost < 1e-6 * max(1, K.cost), '%s: cost breakdown does not match objective', s.name);
fprintf('  %-16s ok  (%s, %d variables)\n', s.name, R.solver, R.n_var);
end

% =========================================================================
function near(actual, expected, what)
tol = 1e-5 * max(1, abs(expected));
assert(abs(actual - expected) <= tol, '%s: got %.6f, expected %.6f', what, actual, expected);
end

% =========================================================================
function ser = toy_series(T, load_kW, crit_kW, a, ug)
ser.L     = load_kW * ones(T, 1);
ser.Lc    = crit_kW * ones(T, 1);
ser.a     = a(:);
ser.ug    = ug(:);
ser.month = ones(T, 1);                       % January
end

% =========================================================================
function s = toy_scenario()
% Round toy parameters. The field list is the full interface of a scenario.
s = struct();
s.name = 'toy';  s.label = 'toy';  s.group = 'test';  s.side = '';
s.dt = 1;
s.i  = 0.10;
s.c_pv = 1000;  s.om_pv = 20;  s.n_pv = 20;
s.batt_cost_mode = 'allin';
s.c_b_allin = 300;  s.c_bE = 200;  s.c_bP = 200;  s.om_b_frac = 0.02;  s.n_b = 10;
s.eta_ch = 0.95;  s.eta_dis = 0.95;  s.soc_min = 0.1;  s.c_max = 0.5;
s.c_deg = 0.02;   s.c_ch = 0;
s.cold_factor = 1;  s.cold_months = [12 1 2 3];
s.price_diesel = 1.5;  s.fuel_a = 0.02;  s.fuel_b = 0.25;  s.om_dg = 0.01;
s.c_d = 0;  s.n_d = 15;  s.m_min = 0.3;
s.c_grid = 0.25;
s.lpsp_max = 0;  s.re_min = 0;
s.P_gmax = [];
s.co2_diesel = 2.68;  s.co2_grid = 0.70;
s.fix = struct();
s.elastic = false;  s.pen_ls_n = 10;  s.pen_ls_c = 1000;
s.tie = 1e-3;
s.series = [];
end
