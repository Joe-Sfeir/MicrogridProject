# Results: Faqra Club PV + battery microgrid (LP model)

Written by `model/main.m` on 2026-11-22 13:29 with GNU Octave 8.4.0. Solver: HiGHS dual simplex (scipy, called from GNU Octave). Run time 325 s. Do not edit by hand: re-run `main` to regenerate every file in this folder.

**These numbers were produced with GNU Octave and HiGHS, not with MATLAB.** The model code is the same; in MATLAB `solve_lp.m` calls `linprog`. Re-run `main` in MATLAB before quoting the numbers in the paper. The optimal cost of an LP is unique, so the costs should agree; sizes and the hourly dispatch can differ slightly where several solutions are equally cheap.

## Base case

Base load (club + chalets, 1,457 MWh/yr, peak 519 kW), measured EDL feeder availability, base irradiance with snow loss, all parameters at base, LPSP limit 1%. PV tilt 30 deg is the cheapest of the four tilts.

| | Reference (grid + diesel) | Base case (PV + battery + grid + diesel) |
|---|---|---|
| PV | 0 | 983 kWp |
| Battery | 0 | 2,622 kWh / 790 kW |
| Diesel rating needed | 429 kW | 233 kW |
| Annualized cost | 493,382 $/yr | 294,277 $/yr |
| LCOE | 0.342 $/kWh | 0.204 $/kWh |
| Grid energy | 480 MWh | 294 MWh |
| Diesel energy | 962 MWh | 152 MWh |
| Fuel | 249,173 L | 39,410 L |
| Renewable fraction (PV used / load) | 0% | 72.7% |
| PV curtailed | | 29.4% of available PV |
| LPSP achieved | 1.00% | 1.00% |
| Unserved critical load | 0.0 kWh | 0.0 kWh |
| Battery cycles | | 218 per year |
| CO2 | 1,004 t/yr | 311 t/yr |

Saving against the reference: **199,105 $/yr (40.4%)**, and 693 t CO2 per year.

Cost breakdown of the base case ($/yr): PV capex 60,040, PV O&M 17,685, battery capex 55,655, battery O&M 12,585, battery degradation 11,406, diesel capex 0, fuel 55,569, diesel O&M 1,948, grid energy 79,389.

## PV tilt

| Case | PV kWp | BESS kWh | Diesel kW | Cost $/yr | LCOE $/kWh | Saving | Renewable | Diesel MWh | LPSP |
|---|---|---|---|---|---|---|---|---|---|
| Base case, tilt 30 | 983 | 2,622 | 233 | 294,277 | 0.204 | 40.4% | 72.7% | 152 | 1.00% |
| Base case, tilt 40 | 1,014 | 2,660 | 230 | 294,428 | 0.204 | 40.3% | 73.6% | 149 | 1.00% |
| Base case, tilt 50 | 1,042 | 2,603 | 230 | 297,181 | 0.206 | 39.8% | 73.2% | 154 | 1.00% |
| Base case, tilt 60 | 1,098 | 2,524 | 231 | 303,331 | 0.210 | 38.5% | 72.4% | 161 | 1.00% |

## Sensitivities (one change at a time from the base case)

"Saving" compares each case with its own reference, that is grid + diesel only under the same load, grid availability, prices and LPSP limit.

| Case | PV kWp | BESS kWh | Diesel kW | Cost $/yr | LCOE $/kWh | Saving | Renewable | Diesel MWh | LPSP |
|---|---|---|---|---|---|---|---|---|---|
| Base case, tilt 30 | 983 | 2,622 | 233 | 294,277 | 0.204 | 40.4% | 72.7% | 152 | 1.00% |
| Load: low load | 457 | 1,112 | 87 | 127,237 | 0.201 | 41.4% | 74.4% | 67 | 1.00% |
| Load: high load | 2,326 | 6,372 | 463 | 679,649 | 0.200 | 41.5% | 74.7% | 323 | 1.00% |
| Boundary: club loads only | 371 | 954 | 49 | 98,894 | 0.190 | 44.3% | 78.5% | 35 | 1.00% |
| Irradiance: SARAH-3 unscaled | 954 | 2,446 | 247 | 303,830 | 0.211 | 38.4% | 68.9% | 176 | 1.00% |
| Irradiance: ERA5 (tilt 40) | 1,058 | 2,684 | 164 | 244,604 | 0.170 | 50.4% | 86.0% | 84 | 1.00% |
| Snow loss: no snow loss | 1,000 | 2,699 | 221 | 289,101 | 0.200 | 41.4% | 74.6% | 137 | 1.00% |
| Snow loss: 15% in Dec-Mar | 989 | 2,521 | 236 | 298,973 | 0.207 | 39.4% | 71.0% | 161 | 1.00% |
| Grid supply: 4 h/day | 985 | 2,398 | 281 | 302,358 | 0.210 | 42.5% | 71.3% | 217 | 1.00% |
| Grid supply: 8 h/day | 923 | 2,340 | 248 | 292,864 | 0.203 | 42.1% | 69.8% | 136 | 1.00% |
| Grid supply: 12 h/day | 921 | 2,350 | 206 | 287,907 | 0.200 | 39.7% | 69.8% | 90 | 1.00% |
| Grid supply: no grid | 1,080 | 2,820 | 330 | 320,304 | 0.222 | 41.3% | 75.6% | 400 | 1.00% |
| Grid supply: +72 h outage | 981 | 2,613 | 252 | 295,581 | 0.205 | 40.2% | 72.6% | 166 | 1.00% |
| Diesel price: 0.80 $/L | 722 | 1,479 | 373 | 241,360 | 0.167 | 23.9% | 58.1% | 633 | 1.00% |
| Diesel price: 1.52 $/L | 1,011 | 2,814 | 226 | 298,360 | 0.207 | 42.7% | 74.4% | 138 | 1.00% |
| Battery cost: 125 $/kWh | 1,019 | 2,929 | 223 | 268,534 | 0.186 | 45.6% | 75.1% | 132 | 1.00% |
| Battery cost: 334 $/kWh | 859 | 1,666 | 272 | 334,190 | 0.232 | 32.3% | 62.9% | 243 | 1.00% |
| Battery cost: 350 $/kWh | 845 | 1,586 | 276 | 337,720 | 0.234 | 31.6% | 61.8% | 254 | 1.00% |
| PV capex: 600 $/kWp | 1,079 | 2,776 | 224 | 281,879 | 0.195 | 42.9% | 75.3% | 136 | 1.00% |
| PV capex: 1003 $/kWp | 911 | 2,406 | 243 | 313,522 | 0.217 | 36.5% | 70.0% | 173 | 1.00% |
| Discount rate: 5.8% | 1,025 | 2,815 | 226 | 282,065 | 0.196 | 42.8% | 74.7% | 137 | 1.00% |
| Discount rate: 12.4% | 795 | 1,855 | 268 | 341,398 | 0.237 | 30.8% | 63.3% | 229 | 1.00% |
| LPSP limit: LPSP 0% | 983 | 2,622 | 354 | 299,785 | 0.206 | 39.9% | 72.7% | 167 | 0.00% |
| LPSP limit: LPSP 0.5% | 983 | 2,622 | 267 | 297,031 | 0.205 | 40.1% | 72.7% | 159 | 0.50% |
| LPSP limit: LPSP 2% | 983 | 2,622 | 186 | 288,770 | 0.202 | 40.8% | 72.7% | 138 | 2.00% |
| LPSP limit: LPSP 5% | 983 | 2,622 | 93 | 272,246 | 0.197 | 42.2% | 72.7% | 94 | 5.00% |
| Cold-weather derating: capacity x 0.87 in Dec-Mar | 982 | 2,751 | 240 | 296,248 | 0.205 | 40.0% | 73.2% | 155 | 1.00% |
| Diesel replaced: 750 $/kW | 1,018 | 2,818 | 208 | 312,010 | 0.216 | 41.0% | 74.5% | 138 | 1.00% |
| Battery cost form: 139 $/kWh + 214 $/kW | 999 | 2,840 | 226 | 288,731 | 0.200 | 41.5% | 73.7% | 141 | 1.00% |
| Grid connection: 5 MW connection | 980 | 2,642 | 211 | 293,035 | 0.203 | 40.6% | 72.8% | 130 | 1.00% |

## Weather robustness (base-case sizes fixed, dispatch re-optimized)

PV yield of each weather year 2014-2023 at tilt 30 deg, same load and grid. Load may be shed beyond the LPSP limit at a penalty, so a shortfall shows up as LPSP above 1% or as unserved critical load. (a) keeps the diesel rating at the base-case value of 233 kW; (b) lets the diesel rating be as large as needed, since the existing sets also carry the status quo.

| Year | (a) cost $/yr | (a) LPSP | (a) unserved critical kWh | (b) cost $/yr | (b) LPSP | (b) diesel kW | (b) diesel MWh |
|---|---|---|---|---|---|---|---|
| 2014 | 271,645 | 1.00% | 0.0 | 271,645 | 1.00% | 189 | 118 |
| 2015 | 294,277 | 1.00% | 0.0 | 294,277 | 1.00% | 233 | 152 |
| 2016 | 304,866 | 1.30% | 0.0 | 306,206 | 1.00% | 271 | 180 |
| 2017 | 300,742 | 1.02% | 0.0 | 300,511 | 1.00% | 252 | 167 |
| 2018 | 298,004 | 1.07% | 0.0 | 298,106 | 1.00% | 257 | 162 |
| 2019 | 296,799 | 1.33% | 0.0 | 298,291 | 1.00% | 272 | 168 |
| 2020 | 300,071 | 1.00% | 0.0 | 300,071 | 1.00% | 229 | 151 |
| 2021 | 278,594 | 1.00% | 0.0 | 278,594 | 1.00% | 200 | 128 |
| 2022 | 303,652 | 1.00% | 0.0 | 303,652 | 1.00% | 228 | 160 |
| 2023 | 287,376 | 1.00% | 0.0 | 287,376 | 1.00% | 224 | 144 |

Worst year with all sizes fixed: LPSP 1.33% (2019), unserved critical load 0.0 kWh, cost up to 304,866 $/yr (2016) against 294,277 $/yr in the design year. With the diesel rating free: worst cost 306,206 $/yr (2016), worst LPSP 1.00%, unserved critical load 0.0 kWh, diesel rating up to 272 kW.

## Cross-check against `tools/prototype_lp.py`

With the prototype's settings (tilt 40 deg, 5 MW grid connection, battery O&M as 2.5% of the annualized capex, 1e-4 $/kWh on charging) the model gives the prototype's results:

| Run | PV kWp | BESS kWh | Cost $/yr | LCOE $/kWh | Renewable fraction | Diesel MWh |
|---|---|---|---|---|---|---|
| Reference (grid + diesel), prototype | 0 | 0 | 493,382 | 0.342 | 0% | 962 |
| Reference (grid + diesel), this model | 0 | 0 | 493,382 | 0.342 | 0% | 962 |
| Base, LPSP 1%, prototype | 1,048 | 2,893 | 281,198 | 0.195 | 76% | 110 |
| Base, LPSP 1%, this model | 1,048 | 2,893 | 281,198 | 0.195 | 76% | 110 |
| Base, LPSP 0%, prototype | 1,048 | 2,893 | 286,706 | 0.197 | 76% | 125 |
| Base, LPSP 0%, this model | 1,048 | 2,893 | 286,706 | 0.197 | 76% | 125 |
| No grid at all, prototype | 1,091 | 2,941 | 307,399 | 0.213 | 77% | 387 |
| No grid at all, this model | 1,091 | 2,941 | 307,399 | 0.213 | 77% | 387 |

The prototype reports a diesel rating of 499 to 519 kW. That number is arbitrary there: the rating has no cost, so any value above the largest diesel output is optimal. This model returns the smallest rating that is enough (see the notes below).

From the prototype to the base case of this study:

| Step | PV kWp | BESS kWh | Cost $/yr | LCOE $/kWh |
|---|---|---|---|---|
| 1. Prototype settings (tilt 40) | 1,048 | 2,893 | 281,198 | 0.195 |
| 2. Battery O&M = 2.5% of capex per year; no charging cost | 1,013 | 2,665 | 293,194 | 0.203 |
| 3. Grid connection = peak load instead of 5 MW | 1,014 | 2,660 | 294,428 | 0.204 |
| 4. Cheapest tilt (base_t30) = base case | 983 | 2,622 | 294,277 | 0.204 |

## Checks

- Inputs: 84 of 84 annual sums and peaks match `inputs/inputs_summary.md` (`input_checks.csv`).
- 48-hour test (`model/tests/test_small_case.m`): all hand-calculated cases reproduced.
- Base case LP: 87,606 variables, 26,280 equality and 70,082 inequality constraints, 261,186 non-zeros. Solver status: optimal. Solve time 6.4 s.
- Power balance residual: at most 2.3e-13 kW in any hour.
- Battery energy balance and cyclic condition: residual at most 3.9e-12 kWh.
- Simultaneous charge and discharge: 0 hours (largest overlap 0.0e+00 kW).
- Diesel: runs 841 hours. Hours with diesel while PV is curtailed: 0; while the grid has spare capacity: 0; while the battery charges: 0.
- Committed capacity: u_dg equals p_dg in every hour (largest gap 0.0e+00 kW), so the minimum-load constraint (5c) never binds and fuel use is (a + b) = 0.259 L/kWh.
- In 57 of the 841 diesel hours the output is below 30% of the full rating of 233 kW, which one single set of that size could not do.
- Across the 33 sizing runs: largest power balance residual 4.1e-12 kW, largest overlap of charge and discharge 0.0e+00 kW.

## Choices made where the brief left room

- **Grid connection.** `P_gmax` is fixed to the peak of the scenario's load (519 kW in the base case). It has no cost in the objective, so it cannot be a free decision. The `grid_5MW` sensitivity shows the effect of a connection that never limits.
- **Zero-cost sizes.** The diesel rating (existing sets, capex 0) and, with the all-in battery cost, the PCS rating have no cost, so the LP alone does not fix them. A tie-breaker of 0.001 $/kW-yr makes the solver return the smallest rating that is enough. It is excluded from every reported cost.
- **Battery cost.** Base: all-in 192 $/kWh on `E_b`, with the power rating limited to 0.5C. O&M is 2.5% of the capex per year. `batt_split` uses 139 $/kWh + 214 $/kW instead.
- **Reference.** Grid + diesel only, with the same LPSP limit as the case it is compared with, so it may also shed up to 1% of the load.
- **Snow 15%.** The series without snow, multiplied by 0.85 in December to March.
- **Cold-weather derating.** The usable capacity (1 - SOC_min) E_b is multiplied by the factor in December to March (upper SOC bound lowered).
- **Dispatch-only runs.** Penalties of 10 $/kWh on shedding above the LPSP limit and 1000 $/kWh on unserved critical load rank the goals. They are numerical weights, not a value of lost load, and are excluded from the reported cost.
- **Definitions.** Renewable fraction = PV used / load (course slides). Battery cycles = energy discharged / E_b. LPSP = unserved energy / load. LCOE = annualized cost / served energy.

## Not in the model

PV degradation over the years, the EDL fixed charge (0.6 $/kVA per month), grid export, the T1 lift recovery reserve, and a renewable-share constraint (constraint 7 is implemented, `re_min`, but no target value is given in `parameters.json`, so no run uses it).

## Files

| File | Content |
|---|---|
| `runs_all.csv` | Every run: sizes, cost breakdown, energies, emissions, checks, solver |
| `table_base_vs_reference.csv` | Base case next to the reference |
| `table_tilt.csv` | Base case at tilt 30/40/50/60 |
| `table_sensitivities.csv` | Base case and all sensitivities |
| `table_weather_years.csv` | Dispatch-only runs for 2014-2023, (a) and (b) |
| `table_crosscheck_prototype.csv` | Comparison with the Python prototype |
| `tornado_lcoe.csv` | Data of the tornado chart |
| `dispatch_base_hourly.csv` | Hourly dispatch of the base case (8,760 rows) |
| `input_checks.csv` | Loaded series against `inputs/inputs_summary.md` |
| `fig_dispatch_winter_week.png` | Dispatch in the week of the highest-load ski weekend |
| `fig_dispatch_summer_week.png` | Dispatch in a summer week |
| `fig_soc_year.png` | Battery state of charge over the year |
| `fig_monthly_energy.png` | Monthly energy balance |
| `fig_tornado_lcoe.png` | Sensitivity of the LCOE |
