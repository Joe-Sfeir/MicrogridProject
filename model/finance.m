function F = finance(s, K, Kyr, years, P)
%FINANCE  NPV, IRR and payback of a microgrid design against its reference.
%
%   F = finance(s, K, Kyr, years, P)
%
%   s      scenario of the sizing run
%   K      its KPIs, computed against its reference (postprocess(R, Kref))
%   Kyr    KPIs of the dispatch-only runs with degraded PV, one per element
%          of `years`; Kyr(1) is year 1 (no degradation yet)
%   years  project years of those runs, e.g. [1 5 10 15 20 25]
%   P      parameters.json (D.par): economics.npv, the base discount rate,
%          pv.degradation_pct_yr
%
% Cash flows are in constant USD, unlevered and before tax (R3 of
% docs/fable_prompt_round2.md):
%   year 0     - (PV capex + battery capex)
%   year y     + OPEX of the reference - OPEX of the microgrid in year y,
%              OPEX = grid energy + fuel + diesel O&M + PV O&M + battery O&M
%              - export credit. The battery throughput (degradation) cost is
%              left out: wear is paid for by the replacement.
%              OPEX of the microgrid rises as the PV degrades; it is taken
%              from the dispatch-only runs and interpolated linearly.
%   year 15    - battery replacement
%   year N     + salvage: remaining life of the PV and of the second battery,
%              linear
% If the diesel sets are bought new (c_d > 0), the difference in diesel capex
% between the microgrid and the reference is treated the same way (year 0,
% replacement after its life, salvage).
%
%   F.table      one row per year 0..N (columns named in F.columns)
%   F.years, F.cf, F.disc, F.cum, F.cum_disc    the cash-flow series
%   F.npv, F.irr, F.payback, F.payback_disc
%   F.npv_repl_low     NPV with the low battery replacement cost
%   F.curve_rate, F.curve_npv    NPV against the discount rate
%   F.npv_simple, F.npv_annualized, F.gap, F.gap_*    consistency check (R3.8)

E   = P.economics.npv;
assert(E.exclude_degradation_cost_from_cash_flow, 'finance:throughput', ...
       'The cash flow leaves the battery throughput cost out; parameters.json says otherwise.');
N   = E.horizon_yr;
assert(years(1) == 1 && years(end) >= N, 'finance:years', ...
       'The dispatch years must run from year 1 to the horizon (%d years).', N);
rate = P.economics.real_discount_rate(2);          % base real discount rate
deg = P.pv.degradation_pct_yr(2) / 100;            % PV degradation per year
y   = 1:N;

% ---------------------------------------------------------------- investment
capex_pv = s.c_pv * K.P_pv;
switch s.batt_cost_mode
    case 'allin', capex_b = s.c_b_allin * K.E_b;
    case 'split', capex_b = s.c_bE * K.E_b + s.c_bP * K.P_b;
end
capex_d = s.c_d * (K.P_d - K.ref_P_d);             % 0 when the sets are sunk
capex0  = capex_pv + capex_b + capex_d;

% -------------------------------------------------------------------- OPEX
ip = @(field) interp1(years(:), reshape([Kyr.(field)], [], 1), y(:))';
opex_ref = K.ref_opex * ones(1, N);
opex_mg  = ip('opex');
saving   = opex_ref - opex_mg;

% ------------------------------------------------- replacement and salvage
[cf, repl, salv] = cash_flows(E.battery_replacement_cost_per_kWh(2), s, K, E, N, capex_pv, capex_d, capex0, saving);
M = cashflow_metrics(cf, rate);

F = struct();
F.name = s.name;  F.label = s.label;
F.horizon = N;    F.rate = rate;
F.capex_pv = capex_pv;  F.capex_b = capex_b;  F.capex_d = capex_d;  F.capex0 = capex0;
F.opex_ref = K.ref_opex;
F.opex_mg_first = opex_mg(1);  F.opex_mg_last = opex_mg(end);
F.saving_first  = saving(1);   F.saving_last  = saving(end);
F.replacement_b = E.battery_replacement_cost_per_kWh(2) * K.E_b;
F.salvage = salv(end);
F.npv = M.npv;  F.irr = M.irr;  F.payback = M.payback;  F.payback_disc = M.payback_disc;

% NPV with the low battery replacement cost (sensitivity)
cf_low = cash_flows(E.battery_replacement_cost_per_kWh(1), s, K, E, N, capex_pv, capex_d, capex0, saving);
Ml = cashflow_metrics(cf_low, rate);
F.npv_repl_low = Ml.npv;

% NPV against the discount rate (the cash flows do not change with it)
F.curve_rate = E.discount_rate_curve(:)';
F.curve_npv  = zeros(size(F.curve_rate));
for j = 1:numel(F.curve_rate)
    Mj = cashflow_metrics(cf, F.curve_rate(j));
    F.curve_npv(j) = Mj.npv;
end
F.cf = cf;                                  % net cash flow, years 0..N
F.years = 0:N;
F.disc = M.disc;  F.cum = M.cum;  F.cum_disc = M.cum_disc;

% shedding in the later years (PV degraded, diesel limited to the plant)
F.max_lpsp_later  = max([Kyr.lpsp]);
F.max_uns_c_later = max([Kyr.E_uns_c]);
F.max_P_d_later   = max([Kyr.P_d]);              % diesel rating used, largest over the years

% yearly table
F.columns = {'year', 'pv_output_factor', 'capex', 'battery_replacement', 'diesel_replacement', ...
             'salvage', 'opex_reference', 'opex_microgrid', 'grid_energy', 'fuel', 'diesel_om', ...
             'pv_om', 'battery_om', 'export_credit', 'saving', 'net_cash_flow', 'discount_factor', ...
             'discounted_cash_flow', 'cumulative_cash_flow', 'cumulative_discounted_cash_flow'};
z = zeros(1, N);
F.table = [ (0:N)', ...
            [NaN, (1 - deg) .^ (y - 1)]', ...
            [-capex0, z]', ...
            [0, -repl(1, :)]', ...
            [0, -repl(2, :)]', ...
            [0, salv]', ...
            [0, opex_ref]', ...
            [0, opex_mg]', ...
            [0, ip('c_grid')]', [0, ip('c_fuel')]', [0, ip('c_dg_om')]', [0, ip('c_pv_om')]', ...
            [0, ip('c_b_om')]', [0, -ip('c_export')]', ...
            [0, saving]', ...
            cf(:), ...
            (1 ./ (1 + rate) .^ (0:N))', ...
            M.disc(:), M.cum(:), M.cum_disc(:) ];

% ------------------------------------------------ consistency check (R3.8)
% Without PV degradation, replacement and salvage, the NPV should be close
% to (annualized-cost saving) / CRF(i, N). The two differ because the
% annualized cost spreads each component over its own life, not over N
% years, and contains the battery throughput cost:
%   gap = capex_pv (CRF(i,n_pv)/CRF(i,N) - 1) + capex_b (CRF(i,n_b)/CRF(i,N) - 1)
%       + capex_d (CRF(i,n_d)/CRF(i,N) - 1) + throughput cost / CRF(i,N)
cN = crf(rate, N);
Ms = cashflow_metrics([-capex0, (K.ref_opex - Kyr(1).opex) * ones(1, N)], rate);
F.npv_simple     = Ms.npv;
F.npv_annualized = K.savings / cN;
F.gap     = F.npv_simple - F.npv_annualized;
F.gap_pv  = capex_pv * (crf(rate, s.n_pv) / cN - 1);
F.gap_b   = capex_b  * (crf(rate, s.n_b)  / cN - 1);
F.gap_d   = capex_d  * (crf(rate, s.n_d)  / cN - 1);
F.gap_deg = (K.c_b_deg + K.c_ch) / cN;
F.gap_unexplained = F.gap - (F.gap_pv + F.gap_b + F.gap_d + F.gap_deg);
end

% =========================================================================
function [cf, repl, salv] = cash_flows(repl_per_kWh, s, K, E, N, capex_pv, capex_d, capex0, saving)
% Net cash flow of years 0..N for a given battery replacement cost ($/kWh).
% repl: row 1 battery, row 2 diesel (positive = money spent); salv: salvage.
repl = zeros(2, N);
salv = zeros(1, N);
% PV: no replacement within N years; salvage for the remaining life
salv(N) = salv(N) + capex_pv * max(0, s.n_pv - N) / s.n_pv;
% battery: replaced once, in the year given in parameters.json; the second
% battery has (year + life - N) years left at the end
yb = E.battery_replacement_year;
cb = repl_per_kWh * K.E_b;
if yb <= N
    repl(1, yb) = cb;
    salv(N) = salv(N) + cb * min(1, max(0, yb + s.n_b - N) / s.n_b);
end
% diesel, only if bought new: replaced after its life
if capex_d ~= 0 && s.n_d < N
    repl(2, s.n_d) = capex_d;
    salv(N) = salv(N) + capex_d * min(1, max(0, 2 * s.n_d - N) / s.n_d);
elseif capex_d ~= 0
    salv(N) = salv(N) + capex_d * max(0, s.n_d - N) / s.n_d;
end
cf = [-capex0, saving - repl(1, :) - repl(2, :) + salv];
end
