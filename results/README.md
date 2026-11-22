# Results: Faqra Club PV + battery microgrid (LP model)

Written by `model/main.m` on 2026-11-22 15:03 with GNU Octave 8.4.0. Solver: HiGHS dual simplex (scipy, called from GNU Octave). Run time 595 s. Do not edit by hand: re-run `main` to regenerate every file in this folder. The briefs are `docs/fable_prompt.md` and `docs/fable_prompt_round2.md`.

**These numbers were produced with GNU Octave and HiGHS, not with MATLAB.** The model code is the same; in MATLAB `solve_lp.m` calls `linprog`. Re-run `main` in MATLAB before quoting the numbers in the paper. The optimal cost of an LP is unique, so the costs should agree; sizes and the hourly dispatch can differ slightly where several solutions are equally cheap. From R2024a `linprog` uses HiGHS by default; with older releases it uses another dual simplex, whose run time on this problem has not been tested: start with `main('quick')`.

## Base case

Base load (club + chalets, 1,457 MWh/yr, peak 519 kW), measured EDL feeder availability, base irradiance with snow loss, all parameters at base. LPSP limit 0% (no load may be shed). The battery keeps 30 kWh above its minimum from the start to the end of every hour in which the T1 chairlift runs. PV tilt 30 deg is the cheapest of the 4 tilts.

| | Reference (grid + diesel) | Base case (PV + battery + grid + diesel) |
|---|---|---|
| PV | 0 | 976 kWp |
| Battery | 0 | 2,623 kWh / 786 kW |
| Diesel rating needed | 519 kW | 354 kW |
| Annualized cost | 498,890 $/yr | 299,859 $/yr |
| LCOE | 0.342 $/kWh | 0.206 $/kWh |
| Annualized cost without the battery throughput cost | 498,890 $/yr | 288,466 $/yr |
| Grid energy | 480 MWh | 295 MWh |
| Diesel energy | 977 MWh | 168 MWh |
| Fuel | 252,947 L | 43,392 L |
| Renewable fraction (PV used on site / load) | 0% | 72.6% |
| PV curtailed | | 29.0% of available PV |
| LPSP achieved | 0.00% | 0.00% |
| Unserved critical load | 0.0 kWh | 0.0 kWh |
| Battery cycles | | 217 per year |
| CO2 | 1,014 t/yr | 323 t/yr |

Saving against the reference: **199,031 $/yr (39.9%)**, and 691 t CO2 per year.

Cost breakdown of the base case ($/yr): PV capex 59,616, PV O&M 17,560, battery capex 55,686, battery O&M 12,592, battery throughput 11,393, diesel capex 0, fuel 61,182, diesel O&M 2,144, grid energy 79,685.

**Battery wear is in the annualized cost twice.** The battery capex is recovered over its 15-year calendar life, and each kWh discharged also costs 0.020 $ (throughput cost). Both pay for wear. Cycle life is not the limit: 217 cycles per year over 15 years is 3,257 cycles, against 8,000 for the cells. The throughput cost stays in the LP because it stops pointless cycling. Costs with it are the conservative figures; without it the base case costs 288,466 $/yr and saves 210,424 $/yr (42.2%). The tables give both.

Finance over 25 years at a real discount rate of 7.11%: investment 1,235,352 $, **NPV 2,326,775 $, real IRR 25.8%, simple payback 3.8 years, discounted payback 4.6 years** (section "Finance").

## Why the base case allows no load shedding

The first round used an LPSP limit of 1%. The table shows where the model puts the shedding when it is allowed. Only non-critical load is shed.

| Case | Shed MWh | Hours | Largest shed hour | On ski days | In Dec-Mar | In the worst 7 days (starting) | Diesel kW | Cost saving vs base $/yr |
|---|---|---|---|---|---|---|---|---|
| LPSP 0.5% | 7.3 | 56 | 232 kW, 2026-01-11 13:00 | 96% | 100% | 64% (2026-01-05) | 268 | 2,754 |
| LPSP 1% | 14.6 | 117 | 266 kW, 2026-01-11 13:00 | 92% | 100% | 48% (2026-01-05) | 233 | 5,508 |
| LPSP 2% | 29.1 | 178 | 313 kW, 2026-01-11 13:00 | 92% | 100% | 36% (2026-01-05) | 187 | 11,016 |
| LPSP 5% | 72.9 | 344 | 417 kW, 2026-01-10 12:00 | 89% | 99% | 27% (2026-01-05) | 94 | 27,539 |
| LPSP 1%, none on ski days | 14.6 | 95 | 453 kW, 2026-03-21 20:00 | 0% | 47% | 22% (2026-03-24) | 354 | 5,508 |

With a 1% limit, 92% of the shed energy falls on ski days and 48% within seven consecutive days starting 2026-01-05; up to 266 kW is shed at a time, against a peak load of 519 kW. The whole allowance is worth 5,508 $/yr. This is why the base case now requires that no load is shed.

The mechanism: every kWh that is shed saves the same diesel cost (0.378 $/kWh), whatever the hour, so *when* to shed is a tie in cost. The diesel rating has no cost either (existing sets), and the tie-breaker of 0.001 $/kW-yr on it decides: the model sheds in the hours with the highest diesel output, because that lowers the rating it reports (the "Diesel kW" column). The reference case has the same LPSP limit as the case it is compared with, so it also changed to no shedding.

`lpsp1_offpeak` allows 1% of the load to be shed but never on a ski day. It sheds 14.6 MWh in 95 hours (47% in December to March), saves 5,508 $/yr against the base case, and needs a diesel rating of 354 kW (base case 354 kW). Which of the other hours it sheds is again a tie in cost: the pattern in the table is one of many that cost the same.

## PV tilt

| Case | PV kWp | BESS kWh | Diesel kW | Cost $/yr | LCOE $/kWh | Saving | Saving without throughput cost | Renewable | Diesel MWh | LPSP |
|---|---|---|---|---|---|---|---|---|---|---|
| Base case, tilt 30 | 976 | 2,623 | 354 | 299,859 | 0.206 | 39.9% | 42.2% | 72.6% | 168 | 0.00% |
| Base case, tilt 40 | 1,014 | 2,660 | 349 | 300,032 | 0.206 | 39.9% | 42.2% | 73.6% | 164 | 0.00% |
| Base case, tilt 50 | 1,040 | 2,604 | 351 | 302,832 | 0.208 | 39.3% | 41.6% | 73.1% | 169 | 0.00% |
| Base case, tilt 60 | 1,090 | 2,528 | 354 | 309,024 | 0.212 | 38.1% | 40.4% | 72.2% | 176 | 0.00% |

The two cheapest tilts differ by 174 $/yr (0.06% of the cost).

## Sensitivities (one change at a time from the base case)

"Saving" compares each case with its own reference, that is grid + diesel only under the same load, grid availability, prices and LPSP limit.

| Case | PV kWp | BESS kWh | Diesel kW | Cost $/yr | LCOE $/kWh | Saving | Saving without throughput cost | Renewable | Diesel MWh | LPSP |
|---|---|---|---|---|---|---|---|---|---|---|
| Base case, tilt 30 | 976 | 2,623 | 354 | 299,859 | 0.206 | 39.9% | 42.2% | 72.6% | 168 | 0.00% |
| Load: low load | 457 | 1,112 | 143 | 129,662 | 0.203 | 40.9% | 43.2% | 74.4% | 73 | 0.00% |
| Load: high load | 2,328 | 6,381 | 723 | 692,723 | 0.202 | 41.1% | 43.4% | 74.7% | 357 | 0.00% |
| Boundary: club loads only | 368 | 955 | 92 | 100,916 | 0.192 | 43.8% | 46.4% | 78.3% | 41 | 0.00% |
| Irradiance: SARAH-3 unscaled | 954 | 2,446 | 363 | 309,370 | 0.212 | 38.0% | 40.2% | 68.9% | 191 | 0.00% |
| Irradiance: ERA5 (tilt 40) | 1,063 | 2,713 | 284 | 250,240 | 0.172 | 49.8% | 52.3% | 86.3% | 97 | 0.00% |
| Snow loss: no snow loss | 1,000 | 2,715 | 345 | 294,692 | 0.202 | 40.9% | 43.3% | 74.7% | 151 | 0.00% |
| Snow loss: 15% in Dec-Mar | 989 | 2,521 | 356 | 304,517 | 0.209 | 39.0% | 41.2% | 71.0% | 176 | 0.00% |
| Grid supply: 4 h/day | 985 | 2,398 | 362 | 307,941 | 0.211 | 42.1% | 44.3% | 71.3% | 231 | 0.00% |
| Grid supply: 8 h/day | 923 | 2,340 | 340 | 298,436 | 0.205 | 41.6% | 43.9% | 69.8% | 150 | 0.00% |
| Grid supply: 12 h/day | 918 | 2,367 | 288 | 293,470 | 0.201 | 39.2% | 41.6% | 69.9% | 104 | 0.00% |
| Grid supply: no grid | 1,080 | 2,820 | 434 | 325,893 | 0.224 | 40.8% | 42.7% | 75.6% | 414 | 0.00% |
| Grid supply: +72 h outage | 979 | 2,623 | 379 | 301,163 | 0.207 | 39.8% | 42.0% | 72.7% | 181 | 0.00% |
| Diesel price: 0.80 $/L | 719 | 1,483 | 457 | 244,602 | 0.168 | 23.7% | 25.8% | 58.1% | 648 | 0.00% |
| Diesel price: 1.52 $/L | 1,011 | 2,814 | 348 | 304,357 | 0.209 | 42.2% | 44.5% | 74.4% | 153 | 0.00% |
| Battery cost: 125 $/kWh | 1,015 | 2,929 | 344 | 274,086 | 0.188 | 45.1% | 47.5% | 75.0% | 147 | 0.00% |
| Battery cost: 334 $/kWh | 859 | 1,666 | 390 | 339,824 | 0.233 | 31.9% | 33.7% | 62.9% | 258 | 0.00% |
| Battery cost: 350 $/kWh | 838 | 1,587 | 394 | 343,365 | 0.236 | 31.2% | 32.9% | 61.7% | 269 | 0.00% |
| PV capex: 600 $/kWp | 1,073 | 2,787 | 348 | 287,474 | 0.197 | 42.4% | 44.7% | 75.3% | 151 | 0.00% |
| PV capex: 1003 $/kWp | 908 | 2,410 | 363 | 319,087 | 0.219 | 36.0% | 38.2% | 69.9% | 188 | 0.00% |
| Discount rate: 5.8% | 1,019 | 2,818 | 347 | 287,645 | 0.197 | 42.3% | 44.7% | 74.5% | 152 | 0.00% |
| Discount rate: 12.4% | 794 | 1,874 | 384 | 346,977 | 0.238 | 30.5% | 32.4% | 63.4% | 243 | 0.00% |
| LPSP limit: LPSP 0.5% | 976 | 2,623 | 268 | 297,105 | 0.205 | 40.1% | 42.4% | 72.6% | 160 | 0.50% |
| LPSP limit: LPSP 1% | 976 | 2,623 | 233 | 294,351 | 0.204 | 40.3% | 42.6% | 72.6% | 153 | 1.00% |
| LPSP limit: LPSP 2% | 976 | 2,623 | 187 | 288,843 | 0.202 | 40.8% | 43.1% | 72.6% | 138 | 2.00% |
| LPSP limit: LPSP 5% | 976 | 2,623 | 94 | 272,320 | 0.197 | 42.2% | 44.6% | 72.6% | 95 | 5.00% |
| LPSP limit: LPSP 1%, none on ski days | 976 | 2,623 | 354 | 294,351 | 0.204 | 40.3% | 42.6% | 72.6% | 153 | 1.00% |
| Grid export: net metering at 0.27 $/kWh | 1,129 | 2,517 | 356 | 228,322 | 0.157 | 54.2% | 56.4% | 72.2% | 165 | 0.00% |
| Grid export: sold at 0.00 $/kWh | 976 | 2,623 | 354 | 299,859 | 0.206 | 39.9% | 42.2% | 72.6% | 168 | 0.00% |
| Grid export: sold at 0.05 $/kWh | 1,098 | 2,774 | 348 | 288,382 | 0.198 | 42.2% | 44.6% | 75.7% | 150 | 0.00% |
| Grid export: sold at 0.10 $/kWh | 1,199 | 2,773 | 346 | 274,671 | 0.189 | 44.9% | 47.4% | 77.0% | 145 | 0.00% |
| Grid export: sold at 0.15 $/kWh | 1,283 | 2,773 | 346 | 259,693 | 0.178 | 47.9% | 50.4% | 77.9% | 141 | 0.00% |
| Grid export: sold at 0.20 $/kWh | 1,344 | 2,779 | 345 | 243,729 | 0.167 | 51.1% | 53.6% | 78.5% | 138 | 0.00% |
| Grid export: sold at 0.27 $/kWh | 1,465 | 2,819 | 342 | 218,813 | 0.150 | 56.1% | 58.6% | 78.1% | 132 | 0.00% |
| T1 lift reserve: no reserve | 983 | 2,622 | 354 | 299,785 | 0.206 | 39.9% | 42.2% | 72.7% | 167 | 0.00% |
| Cold-weather derating: capacity x 0.87 in Dec-Mar | 982 | 2,751 | 362 | 301,853 | 0.207 | 39.5% | 41.8% | 73.1% | 170 | 0.00% |
| Diesel replaced: 750 $/kW | 1,012 | 2,818 | 308 | 325,726 | 0.224 | 39.9% | 42.1% | 74.4% | 153 | 0.00% |
| Battery cost form: 139 $/kWh + 214 $/kW | 999 | 2,840 | 347 | 294,274 | 0.202 | 41.0% | 43.4% | 73.7% | 156 | 0.00% |
| Grid connection: 5 MW connection | 980 | 2,642 | 319 | 298,619 | 0.205 | 40.1% | 42.5% | 72.8% | 145 | 0.00% |

Across the load scenarios and the base case the cost ranges from 129,662 to 692,723 $/yr and the LCOE from 0.202 to 0.206 $/kWh.

The T1 lift reserve of 30 kWh costs 74 $/yr: the base case costs 299,859 $/yr with it and 299,785 $/yr without (`no_T1_reserve`).

## Diesel price sweep

Sizes re-optimized at each price, each compared with the reference at the same price. The observed Lebanese range in 2023-2026 is 0.80 to 1.52 $/L; the base price is 1.41 $/L.

| Diesel $/L | PV kWp | BESS kWh | Diesel kW | Grid MWh | Diesel MWh | Cost $/yr | Saving $/yr | Saving | NPV $ | IRR | Discounted payback yr |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0.60 | 491 | 726 | 478 | 0 | 874 | 207,786 | 37,302 | 15.2% | 421,155 | 15.7% | 8.1 |
| 0.80 | 719 | 1,483 | 457 | 0 | 648 | 244,602 | 75,966 | 23.7% | 885,438 | 18.2% | 6.8 |
| 1.00 | 839 | 2,007 | 437 | 241 | 307 | 275,309 | 119,873 | 30.3% | 1,391,944 | 21.0% | 5.8 |
| 1.20 | 919 | 2,362 | 364 | 309 | 190 | 289,987 | 155,784 | 34.9% | 1,825,762 | 23.1% | 5.2 |
| 1.41 | 976 | 2,623 | 354 | 295 | 168 | 299,859 | 199,031 | 39.9% | 2,326,775 | 25.8% | 4.6 |
| 1.60 | 1,017 | 2,820 | 347 | 285 | 152 | 307,512 | 239,438 | 43.8% | 2,793,943 | 28.1% | 4.2 |
| 1.80 | 1,025 | 2,851 | 346 | 283 | 150 | 315,326 | 282,213 | 47.2% | 3,285,821 | 31.3% | 3.7 |
| 2.00 | 1,048 | 2,921 | 344 | 278 | 145 | 322,950 | 325,178 | 50.2% | 3,782,501 | 34.1% | 3.4 |

Break-even of own diesel against EDL energy: `diesel.breakeven_vs_edl_per_L` = 1.063 $/L, which counts the slope of the fuel curve only, (0.27 - 0.0128) / 0.242 = 1.063 $/L. The LP runs the sets at full load of what is committed, so its own break-even includes the no-load term: (0.27 - 0.0128) / (0.017 + 0.242) = 0.993 $/L. Below it diesel energy is cheaper than grid energy. In the sweep, grid import is at most 0.0 MWh at the prices below it (0.60, 0.80 $/L) and at least 241 MWh at the prices above it (from 1.00 $/L).

## Grid export (sensitivity; the base case has no export)

PV surplus may be exported while the feeder is on, within the connection capacity shared with import (4'), and only PV is exported (4''). Net metering credits each exported kWh at the tariff, up to the year's import (4'''): the rest is forfeited. The price sweep sells every exported kWh at the given price with no annual cap. Sizes are re-optimized in every case.

| Case | Exported MWh | Grid import MWh | Curtailed (base 29.0%) | PV kWp (change) | BESS kWh (change) | Cost $/yr | Saving $/yr | Saving | NPV $ |
|---|---|---|---|---|---|---|---|---|---|
| Base case, no export | 0 | 295 | 29.0% | 976 | 2,623 | 299,859 | 199,031 | 39.9% | 2,326,775 |
| net metering at 0.27 $/kWh | 301 | 301 | 21.5% | 1,129 (+153) | 2,517 (-106) | 228,322 | 270,568 | 54.2% | 3,097,926 |
| sold at 0.00 $/kWh | 0 | 295 | 29.0% | 976 (+0) | 2,623 (+0) | 299,859 | 199,031 | 39.9% | 2,326,775 |
| sold at 0.05 $/kWh | 256 | 272 | 19.0% | 1,098 (+123) | 2,774 (+151) | 288,382 | 210,508 | 42.2% | 2,465,832 |
| sold at 0.10 $/kWh | 288 | 258 | 22.9% | 1,199 (+223) | 2,773 (+150) | 274,671 | 224,219 | 44.9% | 2,618,093 |
| sold at 0.15 $/kWh | 311 | 249 | 26.1% | 1,283 (+307) | 2,773 (+150) | 259,693 | 239,197 | 47.9% | 2,784,724 |
| sold at 0.20 $/kWh | 327 | 245 | 28.3% | 1,344 (+368) | 2,779 (+156) | 243,729 | 255,161 | 51.1% | 2,962,536 |
| sold at 0.27 $/kWh | 374 | 254 | 32.4% | 1,465 (+489) | 2,819 (+196) | 218,813 | 280,077 | 56.1% | 3,239,603 |

At a price of 0 export has no value: 0.0 MWh is exported and the cost is 299,859 $/yr, against 299,859 $/yr in the base case.

Where exporting is a tie in cost (price 0, or a credit equal to the tariff, where importing and exporting in the same hour would cost nothing) a tie-breaker of 1e-05 $/kWh on export makes the model export only what has value. Largest import and export in the same hour over the export cases: 0.0e+00 kW.

Net metering: 301 MWh exported against 301 MWh imported, so the grid bill is 0 $/yr (base case 79,685 $/yr). The cost falls by 71,537 $/yr against the base case.

## Finance: NPV, IRR and payback

Cash flows in constant USD, unlevered and before tax, over 25 years, discounted at the base real rate of 7.11%. No loan structure is assumed.

- Year 0: PV and battery capex. The existing diesel sets are a sunk cost.
- Years 1 to 25: saving = cash operating cost of the reference minus that of the microgrid. The operating cost is grid energy, fuel, diesel O&M, PV O&M and battery O&M, less any export credit. The battery throughput cost is left out: wear is paid for by the replacement.
- PV output falls by 0.7% per year. Dispatch is re-optimized with the sizes fixed for years 1, 5, 10, 15, 20, 25, with the diesel limited to the reference rating (the existing plant), and interpolated linearly in between.
- Year 15: battery replaced at 192 $/kWh. Year 25: salvage for the remaining life of the PV and of the second battery, linear.

Base case: investment 1,235,352 $ (PV 731,671, battery 503,680). Saving 325,726 $ in year 1 and 307,595 $ in year 25. Battery replacement 503,680 $, salvage 289,839 $. **NPV 2,326,775 $, IRR 25.8%, simple payback 3.8 years, discounted payback 4.6 years.** With the low battery replacement cost of 125 $/kWh the NPV is 2,378,984 $. The yearly figures are in `cashflow_base.csv`. The replacement is costed at the base value in every run, also in the battery-cost sensitivities; `table_finance.csv` gives the NPV with the low value next to it.

NPV of the base case against the discount rate (`fig_npv_vs_rate.png`):

| Rate | 0.00% | 2.00% | 4.00% | 6.00% | 7.11% | 8.00% | 10.00% | 12.37% | 15.00% |
|---|---|---|---|---|---|---|---|---|---|
| NPV $ | 6,480,730 | 4,775,093 | 3,572,772 | 2,705,175 | 2,326,775 | 2,064,599 | 1,581,056 | 1,148,789 | 791,528 |

| Run | Investment $ | Saving year 1 $ | Saving year 25 $ | NPV $ | IRR | Payback yr | Discounted payback yr |
|---|---|---|---|---|---|---|---|
| Base case, tilt 30 | 1,235,352 | 325,726 | 307,595 | 2,326,775 | 25.8% | 3.8 | 4.6 |
| Battery cost: 125 $/kWh | 1,127,214 | 339,274 | 320,201 | 2,570,375 | 29.6% | 3.3 | 3.9 |
| Battery cost: 350 $/kWh | 1,184,077 | 276,914 | 263,852 | 1,889,856 | 22.8% | 4.3 | 5.3 |
| Irradiance: SARAH-3 unscaled | 1,185,272 | 310,609 | 293,266 | 2,215,056 | 25.6% | 3.8 | 4.6 |
| Grid export: net metering at 0.27 $/kWh | 1,329,686 | 403,962 | 374,989 | 3,097,926 | 29.8% | 3.3 | 3.9 |
| Grid supply: no grid | 1,351,277 | 361,198 | 342,631 | 2,612,689 | 26.2% | 3.8 | 4.5 |
| Diesel replaced: 750 $/kW | 1,142,143 | 332,272 | 313,956 | 2,531,899 | 28.6% | 3.4 | 4.1 |
| Grid export: sold at 0.00 $/kWh | 1,235,352 | 325,726 | 307,595 | 2,326,775 | 25.8% | 3.8 | 4.6 |
| Grid export: sold at 0.05 $/kWh | 1,356,373 | 348,597 | 330,977 | 2,465,832 | 25.1% | 3.9 | 4.7 |
| Grid export: sold at 0.10 $/kWh | 1,431,544 | 368,551 | 350,504 | 2,618,093 | 25.2% | 3.9 | 4.7 |
| Grid export: sold at 0.15 $/kWh | 1,494,332 | 388,726 | 369,172 | 2,784,724 | 25.4% | 3.9 | 4.7 |
| Grid export: sold at 0.20 $/kWh | 1,541,353 | 408,617 | 387,427 | 2,962,536 | 26.0% | 3.8 | 4.6 |
| Grid export: sold at 0.27 $/kWh | 1,639,746 | 441,522 | 419,323 | 3,239,603 | 26.4% | 3.7 | 4.5 |
| Diesel price sweep: 0.60 $/L | 507,649 | 85,840 | 77,641 | 421,155 | 15.7% | 6.0 | 8.1 |
| Diesel price sweep: 0.80 $/L | 823,844 | 157,994 | 146,467 | 885,438 | 18.2% | 5.2 | 6.8 |
| Diesel price sweep: 1.00 $/L | 1,014,447 | 222,019 | 206,736 | 1,391,944 | 21.0% | 4.6 | 5.8 |
| Diesel price sweep: 1.20 $/L | 1,142,801 | 272,884 | 255,612 | 1,825,762 | 23.1% | 4.2 | 5.2 |
| Diesel price sweep: 1.41 $/L | 1,235,352 | 325,726 | 307,595 | 2,326,775 | 25.8% | 3.8 | 4.6 |
| Diesel price sweep: 1.60 $/L | 1,304,534 | 373,296 | 354,413 | 2,793,943 | 28.1% | 3.5 | 4.2 |
| Diesel price sweep: 1.80 $/L | 1,316,137 | 417,250 | 397,740 | 3,285,821 | 31.3% | 3.2 | 3.7 |
| Diesel price sweep: 2.00 $/L | 1,346,570 | 463,213 | 443,585 | 3,782,501 | 34.1% | 2.9 | 3.4 |

In the diesel-replacement case both the reference and the microgrid buy new sets, so the cash flow carries the difference in diesel capex (-158,124 $: the microgrid needs 308 kW, the reference 519 kW), again after 15 years, with its salvage. Its later-year dispatch is limited to the rating that was bought.

Later project years: with the diesel limited to the reference rating no load can go unserved, because that rating alone carries the peak; what changes is how much diesel is used. The base case needs 354 kW of diesel in year 1 and up to 356 kW in the later years, of the 519 kW available. Largest LPSP over all finance runs and years: 0.009% (run `diesel_capex`, whose diesel is limited to the rating it bought); largest unserved critical energy 0.0 kWh.

Consistency check for the base case: without PV degradation, replacement and salvage the NPV is 2,523,204 $. The annualized-cost saving divided by CRF(i, 25) is 2,296,623 $. The gap of 226,581 $ has four parts: the annualized cost spreads the PV over 30 years, not 25 (-43,766 $), and the battery over 15 years (138,884 $); the diesel capex difference (0 $); and the throughput cost, which is in the annualized cost only (131,463 $). Unexplained: 0 $.

## Weather robustness (base-case PV and battery, dispatch re-optimized)

PV yield of each weather year 2014-2023 at tilt 30 deg, same load and grid. Main variant: the diesel is limited to the existing plant, taken as the rating that carries the reference case (519 kW). That rating alone carries the peak, so in this variant no load can go unserved: its results are the cost and the diesel rating used. Second variant: the diesel is limited to what the base case needs (354 kW); load may be shed at a penalty, so a shortfall shows up as LPSP above 0% or as unserved critical load.

| Year | Cost $/yr | LPSP | Unserved critical kWh | Diesel kW used | Diesel MWh | Second variant: LPSP | Second variant: unserved critical kWh |
|---|---|---|---|---|---|---|---|
| 2014 | 277,378 | 0.00% | 0.0 | 340 | 134 | 0.00% | 0.0 |
| 2015 | 299,859 | 0.00% | 0.0 | 354 | 168 | 0.00% | 0.0 |
| 2016 | 311,776 | 0.00% | 0.0 | 383 | 196 | 0.00% | 0.0 |
| 2017 | 306,084 | 0.00% | 0.0 | 349 | 183 | 0.00% | 0.0 |
| 2018 | 303,712 | 0.00% | 0.0 | 392 | 177 | 0.01% | 0.0 |
| 2019 | 303,958 | 0.00% | 0.0 | 392 | 184 | 0.00% | 0.0 |
| 2020 | 305,678 | 0.00% | 0.0 | 326 | 167 | 0.00% | 0.0 |
| 2021 | 284,329 | 0.00% | 0.0 | 347 | 143 | 0.00% | 0.0 |
| 2022 | 309,221 | 0.00% | 0.0 | 351 | 176 | 0.00% | 0.0 |
| 2023 | 293,000 | 0.00% | 0.0 | 340 | 159 | 0.00% | 0.0 |

Main variant: worst-year cost 311,776 $/yr (2016) against 299,859 $/yr in the design year, worst LPSP 0.00%, unserved critical load at most 0.0 kWh, diesel rating used up to 392 kW. Second variant: worst LPSP 0.01% (2018), unserved critical load at most 0.0 kWh.

## Cross-check against `tools/prototype_lp.py`

The model was run with the prototype's settings (tilt 40 deg, 5 MW grid connection, battery O&M as 2.5% of the annualized capex, 1e-4 $/kWh on charging, no lift reserve, LPSP as in each row). Largest difference to the prototype over the four runs: 0 $/yr in cost, 0.5 kWp of PV, 0.4 kWh of battery.

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

The prototype reports a diesel rating of 499 to 519 kW. That number is arbitrary there: the rating has no cost, so any value above the largest diesel output is optimal. This model returns the smallest rating that is enough.

From the prototype to the base case of this study:

| Step | PV kWp | BESS kWh | Cost $/yr | LCOE $/kWh |
|---|---|---|---|---|
| 1. Prototype settings (tilt 40, LPSP 1%) | 1,048 | 2,893 | 281,198 | 0.195 |
| 2. Battery O&M as a share of capex per year; no charging cost | 1,013 | 2,665 | 293,194 | 0.203 |
| 3. Grid connection = peak load instead of 5 MW | 1,014 | 2,660 | 294,428 | 0.204 |
| 4. LPSP limit 0% | 1,014 | 2,660 | 299,936 | 0.206 |
| 5. T1 lift recovery reserve in the battery | 1,014 | 2,660 | 300,032 | 0.206 |
| 6. Cheapest tilt (base_t30) = base case | 976 | 2,623 | 299,859 | 0.206 |

## Checks

- Inputs: 84 of 84 annual sums and peaks match `inputs/inputs_summary.md` (`input_checks.csv`).
- 48-hour tests (`model/tests/test_small_case.m`): all hand-calculated cases reproduced, including export limits, the net-metering cap, the lift reserve and NPV/IRR.
- Base case LP: 96,366 variables, 26,280 equality and 70,082 inequality constraints, 278,706 non-zeros. Solver exit flag 1 (1 = optimal). Solve time 5.5 s.
- Power balance residual: at most 1.1e-13 kW in any hour.
- Battery energy balance and cyclic condition: residual at most 1.0e-12 kWh.
- Simultaneous charge and discharge: 0 hours (largest overlap 0.0e+00 kW).
- T1 lift reserve: largest shortfall 0.0e+00 kWh at the start or end of the 640 hours in which the lift runs.
- Diesel: runs 776 hours. Hours with diesel while PV is curtailed: 0; while the grid has spare capacity: 0; while the battery charges: 0.
- Dispatch-only run with the design weather year (2015) and the base-case PV and battery: cost differs from the base case by 0.00 $/yr.
- The sweep point at the base diesel price differs from the base case by 0.00 $/yr.
- Across the 50 sizing runs: largest power balance residual 2.3e-13 kW, largest overlap of charge and discharge 0.0e+00 kW, largest violation of the export limits 0.0e+00 kW and of the lift reserve 0.0e+00 kWh.

## Diesel sets and minimum load

The committed-capacity form (5) gives u_dg = p_dg in every hour (largest gap 0.0e+00 kW in the base case). It treats the plant as many small sets, so the 30% minimum load never binds and fuel use is (a + b) = 0.259 L/kWh. The existing plant is assumed to be several sets that together carry the reference case (519 kW). The LP is kept as it is; this check counts, for the base case, the diesel hours (of 776) that equal sets could not cover with each running set at or above 30%:

| Plant | 1 set | 2 sets | 3 sets |
|---|---|---|---|
| Sets totalling the rating the base case needs (354 kW) | 96 h | 40 h | 32 h |
| Sets totalling the existing plant (519 kW) | 287 h | 63 h | 39 h |

Full-load efficiency in every hour understates fuel use in both cases. The reference burns 5.8 times the fuel of the microgrid (252,947 against 43,392 L), so the same relative part-load penalty would add more cost to the reference: on that reading the reported savings are conservative.

## Modelling choices

- **Grid connection.** `P_gmax` is fixed to the peak of the scenario's load (519 kW in the base case); import and export share it. The `grid_5MW` sensitivity shows a connection that never limits.
- **EDL fixed charge.** 0.6 $/kVA per month is paid on the same connection in the reference and in the microgrid, so it cancels in every saving, NPV and IRR. It is not part of the absolute costs or of the LCOE.
- **Existing diesel plant.** Its capacity is not known. It is taken as the rating that carries the reference case (519 kW in the base case), in several sets, at no capital cost. Runs with fixed PV and battery (weather years, later project years) limit the diesel to that rating.
- **Zero-cost sizes.** The diesel rating and, with the all-in battery cost, the PCS rating have no cost, so the LP alone does not fix them. A tie-breaker of 0.001 $/kW-yr makes the solver return the smallest rating that is enough. It is excluded from every reported cost.
- **T1 lift reserve.** In every hour in which the T1 chairlift runs the battery holds at least SOC_min E_b + 30 kWh (EN 13223 recovery drive), at the start and at the end of the hour. The brief states the rule for the start of the hour; the end is added so that the reserve is there while the lift runs. The reference has no battery, so the rule does not apply there: its recovery drive runs on the gensets, as today.
- **Battery cost.** All-in 192 $/kWh on `E_b`, with the power rating limited to 0.5C. O&M is 2.5% of the capex per year. `batt_split` uses 139 $/kWh + 214 $/kW instead.
- **Snow 15%.** The series without snow, multiplied by 0.85 in December to March.
- **Cold-weather derating.** The usable capacity (1 - SOC_min) E_b is multiplied by the factor in December to March (upper SOC bound lowered).
- **Dispatch-only runs.** Penalties of 10 $/kWh on shedding above the LPSP limit and 1000 $/kWh on unserved critical load rank the goals. They are numerical weights, not a value of lost load, and are excluded from the reported cost.
- **Definitions.** Renewable fraction = PV used on site / load. Battery cycles = energy discharged / E_b. LPSP = unserved energy / load. LCOE = annualized cost / served energy.

## Not in the model

- PV degradation in the sizing LP: sizes are optimized for the output of year 1; degradation enters the finance metrics only.
- Part-load fuel curves and unit commitment of the diesel sets (see "Diesel sets and minimum load").
- A renewable-share target: constraint 7 is implemented (`re_min`), but there is no target, so it is off.
- Financing: no debt, tax or inflation; the NPV-against-rate curve and the IRR stand in for it.

## Files

| File | Content |
|---|---|
| `runs_all.csv` | Reference, tilts, sensitivities, diesel sweep, weather years, cross-check steps and later-year dispatch runs: sizes, cost breakdown, energies, emissions, checks, solver |
| `table_base_vs_reference.csv` | Base case next to the reference |
| `table_tilt.csv` | Base case at tilt 30/40/50/60 |
| `table_finance.csv` | Investment, savings, NPV, IRR, payback and the consistency check per run |
| `cashflow_base.csv` | Yearly cash flow of the base case |
| `table_sensitivities.csv` | Base case and all sensitivities |
| `table_lpsp_shedding.csv` | Where the load is shed for each LPSP limit |
| `table_export.csv` | Net metering and the export price sweep |
| `table_diesel_sweep.csv` | Diesel price sweep |
| `table_weather_years.csv` | Dispatch-only runs for 2014-2023, both variants |
| `table_crosscheck_prototype.csv` | Comparison with the Python prototype |
| `tornado_lcoe.csv` | Data of the tornado chart |
| `dispatch_base_hourly.csv` | Hourly dispatch of the base case (8,760 rows) |
| `input_checks.csv` | Loaded series against `inputs/inputs_summary.md` |
| `fig_dispatch_winter_week.png` | Dispatch in the week of the highest-load ski weekend |
| `fig_dispatch_summer_week.png` | Dispatch in a summer week |
| `fig_soc_year.png` | Battery state of charge over the year |
| `fig_monthly_energy.png` | Monthly energy balance |
| `fig_cashflow.png` | Yearly and cumulative discounted cash flow of the base case |
| `fig_npv_vs_rate.png` | NPV of the base case against the discount rate, IRR marked |
| `fig_diesel_sweep.png` | Saving, NPV, PV and battery size against the diesel price |
| `fig_tornado_lcoe.png` | Sensitivity of the LCOE |
