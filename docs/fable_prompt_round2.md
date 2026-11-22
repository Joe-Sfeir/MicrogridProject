# Round 2 changes to the Faqra microgrid model

Start from your final first-round commit (`ac991d7` on `claude/ecstatic-faraday-te6tny`). Then merge `claude/project-thread-2mmf0w`. It changes `inputs/parameters.json`
(new keys `grid.export`, `economics.npv` and `diesel.price_sweep_per_L`, and `reliability.lpsp_energy_max` = 0)
and adds this file. The same ground rules apply as in `docs/fable_prompt.md`: read every number from the
inputs, keep the model a pure LP, and comment each new constraint with its number from this brief.

Joe's decisions, made after reviewing the first results:

1. Peak-season shedding is not acceptable. The base case changes to no shedding (LPSP 0%).
2. Add a scenario in which surplus PV is sold to the grid.
3. Compute NPV and the related finance metrics.
4. Make the diesel price a main sensitivity, because oil prices are volatile.
5. The existing generators are kept as a sunk cost (no change: `c_d` = 0, with the 750 $/kW case as a
   sensitivity).

## Answers to your open questions

- **Existing genset capacity.** It is not known and we will not ask the club for it. Assume the existing plant
  can carry the reference case, that is the peak load (519 kW in the base case), and that it consists of
  several sets. Wherever a run needs a diesel limit (weather years, PV-degradation years), use the
  reference's P_d, and treat weather-robustness variant (b) as the main one.
- **EDL fixed charge.** It cancels in the savings, because both cases keep the same connection. See R5.4.
- **Renewable-share target.** There is none. Constraint 7 stays off.
- **Grid connection at the peak, and the diesel tie-breaker.** Both confirmed.

## R1. Base case reliability: LPSP 0%

- Set the base `lpsp_max` to `reliability.lpsp_energy_max` (now 0) and regenerate every run from it. Keep the
  sweep {0, 0.5, 1, 2, 5}%.
- For each sweep run with LPSP > 0, report where the shedding falls:
  - the share of shed energy on ski days (`ski_day` = 1) and in Dec–Mar;
  - the number of hours with shedding;
  - the date of the largest shed hour.

  The finding to document is that the 1% allowance is taken almost entirely in the peak ski week, which is
  why the base case moves to 0%.
- Explain the mechanism in `results/README.md`. Every shed kWh saves the same diesel cost, so *when* to shed is
  a tie, and the 0.001 $/kW-yr tie-breaker on the zero-cost diesel rating settles it by shedding at the diesel
  peaks, which are the ski-season peaks. The reference case also changes to LPSP 0%, which follows
  automatically because it shares `lpsp_max`.
- Add one variant, `lpsp1_offpeak`: LPSP 1%, but `ls_n(t) = 0` on every hour with `ski_day` = 1. It shows
  what a seasonal reliability rule would save.

## R2. Grid export (sensitivity runs only; the base case has no export)

Add a variable `p_ex(t) ≥ 0` with these constraints:

- **(1')** Balance: `p_pv + p_dis + p_g + p_dg + ls_c + ls_n = L + p_ch + p_ex`.
- **(4')** `p_g(t) + p_ex(t) ≤ u_g(t)·P_gmax`. Export happens only while the feeder is energised: grid-tied
  inverters must stop exporting when the grid is down (IEEE 1547-2018 anti-islanding), and the connection
  capacity is shared.
- **(4'')** `p_ex(t) ≤ p_pv(t)`. Only PV is exported. Both Law 318/2023 and the 2011 EDL scheme cover
  renewable surplus. Without this limit the LP would run diesel to export whenever diesel is cheap.

Two cases:

- **`export_nm`, net metering.** Each exported kWh is credited at the EDL tariff, `grid.export.net_metering_credit_per_kWh`.
  - Objective term: `− c_grid·Σ p_ex`.
  - **(4''')** Annual cap: `Σ p_ex ≤ Σ p_g`. Credits are banked for 12 months, and surplus beyond the year's
    import is forfeited.
  - Rationale: Law 318/2023 compensates "a percentage" of the year-end surplus, but the regulator has not set
    the percentage. Zero is the conservative choice, and it matches the 2011 EDL scheme.
- **`export_price_sweep`, export sold at a price `c_ex`.** Use each value in
  `grid.export.export_price_sweep_per_kWh` with no annual cap. This is the peer-to-peer sale that Law
  318/2023 allows. No price is regulated yet, so present it as a break-even sweep bounded by the EDL tariff.

For each case, re-optimise the sizes and report:

- exported MWh;
- curtailment before and after;
- the change in PV and battery size;
- annualised cost, saving vs reference, NPV.

## R3. Finance: NPV, IRR and payback (post-processing)

Use `economics.npv` throughout: a 25-year horizon and the base real discount rate. Cash flows are in constant
2026 USD, unlevered and pre-tax. We do not know who would fund the project, so no loan structure is assumed;
the discount-rate curve and the IRR stand in for financing.

1. **Year 0:** PV capex + battery capex (all-in `c_b_allin·E_b`). The diesel cost is 0 (sunk).
2. **Years 1–25: savings(y) = OPEX_ref − OPEX_mg(y).** OPEX covers:
   - grid energy;
   - fuel;
   - diesel O&M;
   - PV O&M;
   - battery O&M;
   - export credit (when there is one).

   **Leave out the 0.020 $/kWh battery degradation cost.** It only shapes the dispatch; in the cash flow,
   battery wear is paid for by the year-15 replacement, so including both would count it twice.
3. **PV degradation:** 0.7 %/yr, `pv.degradation_pct_yr` base.
   - Re-run dispatch only, with sizes fixed, using `a(t)·(1 − 0.007)^(y−1)` for each y in
     `pv_degradation_dispatch_years`. Interpolate OPEX_mg linearly between those years.
   - In these runs, the diesel capacity limit is the reference run's P_d. The existing sets cover the peak
     today.
   - Keep LPSP 0 and use elastic penalties if needed. Report any shedding that appears in later years.
4. **Battery replacement:** in year 15 at `battery_replacement_cost_per_kWh` base × E_b. The low value is used
   as a sensitivity.
5. **Salvage value in year 25:** linear remaining life. That is 5/30 of PV capex and 5/15 of the battery
   replacement cost.
6. **Outputs:**
   - NPV;
   - real IRR;
   - simple payback and discounted payback (years);
   - a yearly cash-flow CSV;
   - a cumulative discounted cash-flow figure;
   - an NPV-vs-discount-rate curve over `discount_rate_curve`, with the IRR marked.
7. **Runs to compute these for:**
   - base;
   - battery 125 / 350 $/kWh;
   - irradiance low;
   - every diesel-sweep point;
   - `export_nm`;
   - grid `u_none`;
   - diesel replacement at 750 $/kW.
8. **Consistency check:** with no PV degradation, no replacement and no salvage, NPV should be close to
   (annualised-cost saving) / CRF(i, 25). Report the gap and why it exists (different component lives).

## R4. Diesel price sweep

- Re-optimise sizes for each price in `diesel.price_sweep_per_L`, covering 0.60–2.00 $/L. The observed
  Lebanese range in 2023–2026 is 0.80–1.52; the sweep extends it on both sides.
- For each price, report:
  - PV, battery and diesel size;
  - grid MWh and diesel MWh;
  - saving vs reference (re-run the reference at the same price);
  - NPV and IRR.
- Make one figure: saving and NPV against diesel price, with PV and battery size on a second panel.
- Mark the analytic break-even `diesel.breakeven_vs_edl_per_L`, (0.27 − 0.0128)/0.242 = 1.06 $/L. Below it,
  own diesel is cheaper per kWh than EDL energy, so the model stops buying grid power. With the no-load term
  at full load, it is about 1.0 $/L. Check that the sweep shows this switch.

## R5. Smaller fixes from the code review

1. **T1 chairlift recovery reserve** (EN 13223:2015 §6.4; `lift_T1_recovery` in `parameters.json`). In every
   hour with `lift_T1_kW(t) > 0`, require `soc(t) ≥ SOC_min·E_b + E_res` (base `E_res` = 30 kWh). The
   reserve is small next to the battery, but it closes an item listed under "Not in the model". Report the
   cost change.
2. **Diesel unit size.** The committed-capacity relaxation gives `u_dg = p_dg` in every hour. In effect it
   treats the plant as many small sets, so the 30% minimum load never binds (57 base-case hours are below 30%
   of the full rating). Keep the LP as it is. Add a post-processing check: the number of diesel hours that
   one, two or three equal sets totalling P_d could not cover at ≥ 30% load each. State in the README that
   the existing plant is assumed to be several sets. Note that running diesel at full-load efficiency
   favours the reference more than the microgrid, because the reference burns six times more diesel, so the
   reported savings are conservative.
3. **Battery wear is counted twice in the annualised cost.** The calendar-life CRF on E_b and the
   0.020 $/kWh throughput cost both pay for battery wear. Cycle life is not the binding limit: 218 cycles/yr
   × 15 yr = 3,270 cycles, against 8,000 for the cells. Keep the term in the LP, because it stops pointless
   cycling. In the tables, report the cost both with it (the conservative figure) and without it, and say so
   in the README.
4. **EDL fixed charge** (0.6 $/kVA·month). Both the reference and the microgrid keep the same connection
   (`P_gmax` = peak), so it cancels in the savings. Say this in the README instead of listing it as not
   modelled.
5. **README files.** Update `results/README.md` (base case, the "Not in the model" list, the new tables). In
   the top-level `README.md`, point to both briefs.

## Deliverables

- Regenerate `results/` with the LPSP-0 base case.
- Add these files:
  - `table_lpsp_shedding.csv`
  - `table_export.csv`
  - `table_finance.csv`
  - `cashflow_base.csv`
  - `table_diesel_sweep.csv`
  - `fig_cashflow.png`
  - `fig_npv_vs_rate.png`
  - `fig_diesel_sweep.png`
- Update `results/README.md`.
- Keep the 48 h test passing. Add toy cases for (a) constraints 4' and 4'': no export while u_g = 0 and no
  export above PV; (b) net-metering credits capped at the year's import; (c) the T1 reserve; (d) NPV and IRR
  computed by hand for a two-year cash flow.
- Run in Octave as before. Joe will re-run it in MATLAB.
