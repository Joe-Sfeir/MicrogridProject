function [base, sens, sweep] = scenarios(D, tilt)
%SCENARIOS  Base case, one-at-a-time sensitivities and the diesel price sweep.
%
%   base                = scenarios(D)          base case at PV tilt 40 deg
%   [base, sens]        = scenarios(D, tilt)    base case at the given tilt and a
%                                               struct array of sensitivities,
%                                               each changing one thing
%   [base, sens, sweep] = scenarios(D, tilt)    also the diesel price sweep
%
% Every number is the base (middle) value of inputs/parameters.json; low and
% high are elements 1 and 3 of the same arrays. Use as_reference.m to get the
% status-quo version (no PV, no battery) of any scenario.
%
% Fields used for reporting: name (identifier), label (text on charts),
% group (row of the tornado chart), side ('low', 'high' or '').

if nargin < 2 || isempty(tilt), tilt = 40; end
P = D.par;
LOW = 1;  BASE = 2;  HIGH = 3;

% ------------------------------------------------------------------- base
s = struct();
s.name  = sprintf('base_t%d', tilt);
s.label = sprintf('Base case, tilt %d', tilt);
s.group = 'Base';
s.side  = '';

% input series
s.load_case = 'base';                    % load_low.csv / load_base.csv / load_high.csv
s.load_col  = 'total_kW';                % boundary: club + chalets
s.pv_col    = sprintf('base_t%d_snow', tilt);
s.snow_flat_decmar = 0;                  % extra flat Dec-Mar loss on pv_col (0 = none)
s.grid_col  = 'u_base_feeder';
s.series    = [];                        % series are read from D

% time and economics
s.dt = P.time.dt_h;
s.i  = P.economics.real_discount_rate(BASE);

% PV
s.c_pv  = P.pv.capex_per_kWp(BASE);
s.om_pv = P.pv.om_per_kW_yr(BASE);
s.n_pv  = P.pv.life_yr(BASE);

% battery ("use either the all-in cost on E_b (base) or the split; not both")
s.batt_cost_mode = 'allin';
s.c_b_allin = P.battery.capex_allin_per_kWh(BASE);
s.c_bE      = P.battery.capex_energy_per_kWh(BASE);
s.c_bP      = P.battery.capex_pcs_per_kW(BASE);
s.om_b_frac = P.battery.om_pct_capex_yr(BASE) / 100;
s.n_b       = P.battery.life_yr(BASE);
s.eta_ch    = P.battery.eta_ch;
s.eta_dis   = P.battery.eta_dis;
s.soc_min   = P.battery.soc_min_frac(BASE);
s.c_max     = P.battery.c_rate_max;
s.c_deg     = P.battery.degradation_cost_per_kWh_discharged(BASE);
s.c_ch      = 0;                         % optional small cost on charging
s.cold_factor = P.battery.cold_capacity_factor_decmar(BASE);   % 1.0 = no derating
s.cold_months = [12 1 2 3];
% T1 chairlift recovery reserve kept in the battery while the lift runs (R5.1)
s.E_res = P.lift_T1_recovery.energy_reserve_kWh(BASE);

% diesel
s.price_diesel = P.diesel.price_per_L(BASE);
s.fuel_a = P.diesel.fuel_a_L_per_h_per_kWrated(BASE);
s.fuel_b = P.diesel.fuel_b_L_per_kWh(BASE);
s.om_dg  = P.diesel.om_per_kWh(BASE);
s.c_d    = P.diesel.capex_per_kW(BASE);  % 0: existing sets are a sunk cost
s.n_d    = P.diesel.life_yr;
s.m_min  = P.diesel.min_load_frac;

% grid
s.c_grid = P.grid.edl_tariff_per_kWh(BASE);
s.P_gmax = [];                           % [] = peak of the scenario's load
% export of PV surplus (R2): off in the base case
s.export = false;                        % constraints (4'), (4'') active
s.c_ex   = 0;                            % $/kWh credited for exported PV
s.export_cap_import = false;             % (4''') annual export <= annual import

% reliability
s.lpsp_max = P.reliability.lpsp_energy_max;      % 0 from round 2: no shedding
s.no_shed_ski = false;                   % true: ls_n = 0 on ski days (R1 variant)
s.re_min   = 0;                          % constraint (7) off

% emissions
s.co2_diesel = P.diesel.co2_kg_per_L;
s.co2_grid   = P.grid.co2_kg_per_kWh;

% run control
s.fix      = struct();                   % fixed sizes, e.g. s.fix.P_pv = 0
s.cap      = struct();                   % size limits, e.g. s.cap.P_d = 519
s.pv_scale = 1;                          % multiplier on the PV series (degradation)
s.elastic  = false;                      % true only for dispatch-only runs
s.pen_ls_n = 10;                         % $/kWh, numerical weights for elastic runs
s.pen_ls_c = 1000;
s.tie      = 1e-3;                       % $/kW-yr tie-breaker on zero-cost sizes
s.tie_ex   = 1e-5;                       % $/kWh tie-breaker on export

base = s;
if nargout < 2, return; end

% ---------------------------------------------------------- sensitivities
sens = base([]);

% load
sens = add(sens, base, 'load_low',  'Load', 'low',  'low load',  'load_case', 'low');
sens = add(sens, base, 'load_high', 'Load', 'high', 'high load', 'load_case', 'high');
sens = add(sens, base, 'club_only', 'Boundary', '', 'club loads only', 'load_col', 'club_total_kW');

% irradiance (the optimistic series exists for tilt 40 only)
sens = add(sens, base, 'irr_low',  'Irradiance', 'low',  'SARAH-3 unscaled', ...
           'pv_col', sprintf('low_t%d_snow', tilt));
sens = add(sens, base, 'irr_high', 'Irradiance', 'high', 'ERA5 (tilt 40)', 'pv_col', 'high_t40_snow');

% snow loss: none, and a flat loss in Dec-Mar on the series without snow
snow_high = P.pv.snow_loss_dec_mar_pct{HIGH} / 100;
sens = add(sens, base, 'snow_0',  'Snow loss', 'low', 'no snow loss', ...
           'pv_col', sprintf('base_t%d', tilt));
sens = add(sens, base, 'snow_15', 'Snow loss', 'high', sprintf('%g%% in Dec-Mar', 100 * snow_high), ...
           'pv_col', sprintf('base_t%d', tilt), 'snow_flat_decmar', snow_high);

% grid availability
sens = add(sens, base, 'grid_4h',   'Grid supply', '', '4 h/day',  'grid_col', 'u_4h');
sens = add(sens, base, 'grid_8h',   'Grid supply', '', '8 h/day',  'grid_col', 'u_8h');
sens = add(sens, base, 'grid_12h',  'Grid supply', '', '12 h/day', 'grid_col', 'u_12h');
sens = add(sens, base, 'grid_none', 'Grid supply', '', 'no grid',  'grid_col', 'u_none');
sens = add(sens, base, 'grid_72h_outage', 'Grid supply', '', '+72 h outage', ...
           'grid_col', 'u_base_plus72h_outage');

% diesel price
v = P.diesel.price_per_L;
sens = add(sens, base, 'diesel_low',  'Diesel price', 'low',  sprintf('%.2f $/L', v(LOW)),  'price_diesel', v(LOW));
sens = add(sens, base, 'diesel_high', 'Diesel price', 'high', sprintf('%.2f $/L', v(HIGH)), 'price_diesel', v(HIGH));

% battery cost (all-in, $/kWh): low, high and the course-slide value
v = [P.battery.capex_allin_per_kWh([LOW HIGH]); P.battery.capex_course_slides_per_kWh];
sd = {'low', 'high', 'high'};
for j = 1:numel(v)
    sens = add(sens, base, sprintf('batt_%d', round(v(j))), 'Battery cost', sd{j}, ...
               sprintf('%d $/kWh', round(v(j))), 'c_b_allin', v(j));
end

% PV capex
v = P.pv.capex_per_kWp;
sens = add(sens, base, 'pv_capex_low',  'PV capex', 'low',  sprintf('%d $/kWp', round(v(LOW))),  'c_pv', v(LOW));
sens = add(sens, base, 'pv_capex_high', 'PV capex', 'high', sprintf('%d $/kWp', round(v(HIGH))), 'c_pv', v(HIGH));

% discount rate
v = P.economics.real_discount_rate;
sens = add(sens, base, 'rate_low',  'Discount rate', 'low',  sprintf('%.1f%%', 100 * v(LOW)),  'i', v(LOW));
sens = add(sens, base, 'rate_high', 'Discount rate', 'high', sprintf('%.1f%%', 100 * v(HIGH)), 'i', v(HIGH));

% reliability limit (the base value is skipped: it is the base case)
v = P.reliability.lpsp_sweep(:)';
for x = v(abs(v - base.lpsp_max) > 1e-12)
    sens = add(sens, base, sprintf('lpsp_%s', strrep(sprintf('%g', 100 * x), '.', 'p')), ...
               'LPSP limit', '', sprintf('LPSP %g%%', 100 * x), 'lpsp_max', x);
end
% R1 variant: 1% of the load may be shed, but never on a ski day (the 1% is
% set by the round-2 brief; it is not a key of parameters.json)
sens = add(sens, base, 'lpsp1_offpeak', 'LPSP limit', '', 'LPSP 1%, none on ski days', ...
           'lpsp_max', 0.01, 'no_shed_ski', true);

% grid export of PV surplus (R2). The model always applies (4') and (4''):
% check that parameters.json still asks for them.
X = P.grid.export;
assert(X.only_when_grid_energised && X.only_from_pv, 'scenarios:export', ...
       'The model exports only PV and only while the grid is on; parameters.json says otherwise.');
sens = add(sens, base, 'export_nm', 'Grid export', '', ...
           sprintf('net metering at %.2f $/kWh', X.net_metering_credit_per_kWh), ...
           'export', true, 'c_ex', X.net_metering_credit_per_kWh, 'export_cap_import', true);
for x = X.export_price_sweep_per_kWh(:)'
    sens = add(sens, base, sprintf('export_p%s', strrep(sprintf('%.2f', x), '.', 'p')), ...
               'Grid export', '', sprintf('sold at %.2f $/kWh', x), 'export', true, 'c_ex', x);
end

% T1 chairlift recovery reserve removed (R5.1: what the reserve costs)
sens = add(sens, base, 'no_T1_reserve', 'T1 lift reserve', '', 'no reserve', 'E_res', 0);

% cold-weather battery derating in Dec-Mar
v = P.battery.cold_capacity_factor_decmar(HIGH);
sens = add(sens, base, 'batt_cold', 'Cold-weather derating', '', ...
           sprintf('capacity x %.2f in Dec-Mar', v), 'cold_factor', v);

% diesel sets must be replaced (capex not sunk)
v = P.diesel.capex_per_kW(HIGH);
sens = add(sens, base, 'diesel_capex', 'Diesel replaced', '', sprintf('%d $/kW', round(v)), 'c_d', v);

% battery cost as energy + PCS parts instead of the all-in value
sens = add(sens, base, 'batt_split', 'Battery cost form', '', ...
           sprintf('%d $/kWh + %d $/kW', round(base.c_bE), round(base.c_bP)), 'batt_cost_mode', 'split');

% grid connection not limiting (the bound used in tools/prototype_lp.py)
sens = add(sens, base, 'grid_5MW', 'Grid connection', '', '5 MW connection', 'P_gmax', 5000);
if nargout < 3, return; end

% ------------------------------------------------- diesel price sweep (R4)
sweep = base([]);
for x = P.diesel.price_sweep_per_L(:)'
    sweep = add(sweep, base, sprintf('dsweep_%s', strrep(sprintf('%.2f', x), '.', 'p')), ...
                'Diesel price sweep', '', sprintf('%.2f $/L', x), 'price_diesel', x);
end
end

% =========================================================================
function sens = add(sens, base, name, group, side, label, varargin)
% Copy the base case, change the given fields, append to the list.
s = base;
s.name = name;  s.group = group;  s.side = side;  s.label = label;
for j = 1:2:numel(varargin)
    assert(isfield(s, varargin{j}), 'scenarios:field', 'Unknown field %s.', varargin{j});
    s.(varargin{j}) = varargin{j + 1};
end
sens(end + 1) = s;
end
