# Prompt: build the MATLAB LP model for the Faqra Club microgrid

You are writing the MATLAB optimization model for a university course paper (AUB EECE 675):
a techno-economic feasibility study of a PV + battery (BESS) microgrid with diesel backup for Faqra Club,
a mountain ski resort in Lebanon (1,735–1,975 m) supplied by an unreliable grid (EDL).

## Ground rules

1. **All inputs are already prepared.** Read them from the repository; do not invent numbers.
   Every scalar is in `inputs/parameters.json` (arrays are [low, base, high]); hourly series are CSV files in
   `inputs/`. Sources for every value are in `docs/assumption_register.md` and `docs/data_inventory.md`.
   If you need a value that is not there, stop and list it as a question rather than assuming it.
2. **Follow the course formulation.** The course's example ("MG Optimization Example Using LP Only") is a single
   linear program solved with `linprog`. Keep the model a pure LP (no binaries). The extensions below stay linear.
3. **Transparent, testable code.** Plain MATLAB with the Optimization Toolbox (problem-based `optimproblem` /
   `optimvar` is preferred for readability; `linprog` with the HiGHS dual simplex, which is the default, solves it).
   Comment every constraint with its equation number from this prompt.
4. Units: kW, kWh, $, hours. Δt = 1 h, T = 8,760.

## Input files (repository branch `claude/project-thread-2mmf0w` of Joe-Sfeir/MicrogridProject)

| File | Content |
|---|---|
| `inputs/load_low.csv`, `load_base.csv`, `load_high.csv` | 8,760 rows. Columns: `hour`, `time_utc`, `time_local`, `month`, `hour_local`, `weekend_or_holiday`, `ski_day`, one column per block in kW (`lifts_kW`, `hotel_kW`, `restaurants_kW`, `chalets_kW`, `road_lighting_kW`, `water_pumping_kW`, `wastewater_kW`, `sports_kW`, `pool_kW`, `ev_kW`, `security_kW`, `offices_kW`), `club_total_kW` (everything except chalets), `total_kW`, `critical_kW`, `lift_T1_kW` |
| `inputs/pv_per_kWp.csv` | 8,760 rows, kW per kWp installed. `base_t{30,40,50,60}_snow` = base case (with snow loss); `base_t*` without snow; `low_t*` / `low_t*_snow` = pessimistic irradiance; `high_t40` / `high_t40_snow` = optimistic irradiance; `snowcov_t*` = snow coverage fraction |
| `inputs/pv_per_kWp_multiyear.csv` | Base irradiance with snow for each weather year 2014–2023 and tilt: columns `y{year}_t{tilt}` |
| `inputs/grid_availability.csv` | 8,760 rows of 0/1 (1 = EDL supplies): `u_base_feeder` (measured), `u_4h`, `u_8h`, `u_12h`, `u_none`, `u_base_plus72h_outage` |
| `inputs/parameters.json` | All scalar parameters (costs, efficiencies, lifetimes, tariffs, fuel curve, discount rate) |
| `inputs/inputs_summary.md` | Annual energies, peaks and checks you can use to validate that files were read correctly |

All series share the same 8,760 time index (UTC hours of 2026; `time_local` is Lebanese local time).

## Decision variables

Sizes (≥ 0): `P_pv` (kWp), `E_b` (kWh), `P_b` (kW, PCS rating), `P_d` (kW, diesel rating), `P_gmax` (kW, grid
connection; fix it to a large bound or to the base-case peak if you prefer it not to be a decision).

Hourly (≥ 0, t = 1..T): `p_pv(t)` PV used, `p_cur(t)` PV curtailed, `p_ch(t)`, `p_dis(t)`, `soc(t)` (kWh),
`p_g(t)` grid import, `p_dg(t)` diesel output, `u_dg(t)` diesel committed capacity, `ls_c(t)` unserved critical
load, `ls_n(t)` unserved non-critical load.

## Constraints

1. Power balance: `p_pv + p_dis + p_g + p_dg + ls_c + ls_n = L(t) + p_ch`, with L(t) = `total_kW` (base boundary).
2. PV: `p_pv(t) + p_cur(t) = a(t) · P_pv`, where a(t) is the chosen `pv_per_kWp` column.
3. Battery: `soc(t+1) = soc(t) + η_ch·p_ch(t)·Δt − p_dis(t)·Δt/η_dis`, cyclic `soc(T+1) = soc(1)`;
   `SOC_min·E_b ≤ soc(t) ≤ E_b`; `p_ch(t), p_dis(t) ≤ P_b`; `P_b ≤ c_max·E_b` (c_max = 0.5).
   Optional cold-weather case: multiply the usable capacity by 0.87 in Dec–Mar.
4. Grid: `p_g(t) ≤ u_g(t) · P_gmax` (u_g from `grid_availability.csv`). No export in the base case.
5. Diesel (committed-capacity relaxation, Palmintier & Webster 2014): `p_dg(t) ≤ u_dg(t) ≤ P_d`,
   `p_dg(t) ≥ m_min·u_dg(t)` with m_min = 0.30. Fuel `F(t) = a·u_dg(t) + b·p_dg(t)` (L/h).
6. Unserved load: `ls_c(t) ≤ critical_kW(t)`, `ls_n(t) ≤ total_kW(t) − critical_kW(t)`;
   **critical load must be met: Σ ls_c = 0** (or fix ls_c = 0);
   **reliability: Σ ls_n ≤ LPSP_max · Σ L(t)** (energy-based LPSP; base LPSP_max = 1%).
7. Optional (sensitivity only): renewable share as in the course slides, Σ p_pv ≥ RE_min · Σ L.

## Objective: minimum annualized cost ($/yr)

`CRF(i, n_pv)·c_pv·P_pv + O&M_pv·P_pv`
`+ CRF(i, n_b)·(c_bE·E_b + c_bP·P_b) + O&M_b`  (or the all-in $/kWh value on E_b, see parameters)
`+ CRF(i, n_d)·c_d·P_d`  (base: c_d = 0, because the club's existing gensets are kept as backup and are a sunk cost;
sensitivity: c_d = 750 $/kW if they must be replaced; diesel life 15 yr)
`+ Σ_t [ c_grid·p_g(t) + c_fuel·F(t) + c_om,d·p_dg(t) + c_deg·p_dis(t) ]`
`+ VOLL·Σ ls_n(t)` only if you choose a penalty formulation instead of constraint 6 (default: no penalty).

CRF(i, n) = i(1+i)^n / ((1+i)^n − 1), real discount rate i from `parameters.json`. Each component uses its
own lifetime. Report LCOE = annualized cost / served energy.

## Runs to produce

1. **Reference (status quo):** P_pv = E_b = P_b = 0 (grid + diesel only). This is what the microgrid is compared to.
2. **Base case:** base load, `base_t{tilt}_snow` for each tilt 30/40/50/60 (report all four, pick the cheapest),
   `u_base_feeder`, all parameters at base, LPSP_max = 1%.
3. **Sensitivities** (one at a time from the base case):
   - load low / high; club loads only (`club_total_kW` and the matching critical load);
   - irradiance low (`low_t*_snow`) / high (`high_t40_snow`); snow loss 0 (`base_t*`) and 15% of Dec–Mar;
   - grid `u_4h`, `u_8h`, `u_12h`, `u_none`, `u_base_plus72h_outage`;
   - diesel price low / high; battery cost 125, 334 and 350 $/kWh; PV capex low / high; discount rate low / high;
   - LPSP_max ∈ {0, 0.5, 1, 2, 5}%;
   - cold-weather battery derating.
4. **Weather robustness:** fix the base-case sizes and re-run dispatch only for each year in
   `pv_per_kWp_multiyear.csv`; report the worst-year LPSP, unserved critical load and cost.

## Outputs

- A results table per run: sizes, annualized cost and its breakdown, LCOE, savings vs reference, grid and diesel
  energy, fuel litres, renewable fraction, curtailment, achieved LPSP, unserved critical energy, battery cycles,
  CO₂ (diesel 2.68 kg/L, grid 0.70 kg/kWh).
- Figures: dispatch for a winter week (include the highest-load ski weekend) and a summer week; SOC over the year;
  monthly energy balance (PV, battery, grid, diesel, load); tornado chart of the sensitivities.
- Write results to `results/` as CSV and PNG, and a short `results/README.md`.

## Code structure

```
model/
  main.m                 % runs everything, writes results/
  load_inputs.m          % reads CSVs and parameters.json into a struct
  build_and_solve.m      % builds the LP for one scenario struct, returns sizes and dispatch
  scenarios.m            % defines base, reference and sensitivity scenario structs
  postprocess.m          % KPIs, tables
  plot_results.m
  tests/test_small_case.m  % 48-hour toy case with a hand-checkable answer; energy-balance and SOC checks
```

## Checks before reporting

- The annual sums of the loaded series match `inputs/inputs_summary.md`.
- The power balance closes to < 1e-6 kW every hour; the SOC trajectory is cyclic; no simultaneous large charge
  and discharge (if it appears, add a small cost on `p_ch` or report it).
- Diesel never runs when PV + battery + grid could serve the load at lower cost.
- Report solver status, run time and problem size for the base case.
