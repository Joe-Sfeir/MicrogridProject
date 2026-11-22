# Cost and Technical Parameters: PV, LFP BESS, PCS, Cold-Climate Effects, Degradation Cost, Discount Rate

Project: EECE 675, LP sizing of a PV + BESS + diesel microgrid for Faqra Club (1,735–1,975 m, Lebanon).
Compiled: 22 Nov 2026. All money is in USD unless marked. "Derived" means computed by me from the cited numbers; the method is in Section (b).

Status legend:
- **Sourced**: the number appears in the cited source.
- **Derived**: computed from sourced numbers (method in Section b).
- **Proxy**: sourced, but for a different scale, region or chemistry than Faqra. Use with care.
- **Gap**: no defensible public number found.

---

## (a) Parameter table

### A1. PV array

| Parameter | Low | Base | High | Unit | Source (short cite + page/table) | Status |
|---|---|---|---|---|---|---|
| PV capex, Lebanon, all-PV average turnkey 2023 | – | 1,003 | – | $/kWp | LCEC 2025 (2023 Solar PV Status Report), p. 24, average turnkey price series (2022: 1,019; 2021: 1,266) | Sourced |
| PV capex, Lebanon, systems **without** batteries 2023 | – | ≈738 | – | $/kWp | LCEC 2025, p. 28 chart (≈844 in 2021); values read from chart | Sourced (chart-read, ±) |
| PV capex, Lebanon, systems **with** batteries 2023 | – | ≈1,384 | – | $/kWp | LCEC 2025, p. 28 chart (≈1,664 in 2021) | Sourced (chart-read, ±) |
| PV capex, Lebanese case studies | 600 | 964 | – | $/kW | 600: Tarnini et al. 2023, §2.4 (USD 330,000 for ~550 kW on-grid incl. inverters; derived ≈600 $/kW). 964: Bou Gebrael et al. 2026 (arXiv), Table 7 (year-0 PV capex, no original citation given) | Derived / Sourced |
| PV capex, utility-scale global weighted average 2024 | – | 691 | – | $/kW | IRENA 2025 (RPGC 2024 summary), Table S1 p. 4 | Sourced |
| PV capex, US commercial rooftop benchmark (200 kWdc) | – | 1,780 (2023); 1,660 (2024) | 1,990 (2022) | $/kWdc | NREL ATB 2024 Commercial PV (base year 2022: $1.99/Wdc; 2023: $1.78/Wdc); ATB 2025 Commercial PV (2024: $1.66/Wdc) | Proxy (US) |
| PV capex, US distributed by size, H1 2024 medians | 1,650 (1–5 MW) | 2,230 (0.5–1 MW) | 2,610 (100–500 kW) | $/kWdc | NREL Spring 2024 Solar Industry Update (Feldman et al.), slides 52, 57 | Proxy (US) |
| PV capex, Lazard C&I/community | 1,750 | – | 2,950 | $/kW | Lazard LCOE+ (July 2026), p. 26 | Proxy (US) |
| **Recommended PV capex for LP (flat/ground, Lebanon)** | **600** | **750** | **1,003** | $/kWp | Low: Tarnini 2023 derived / WB PAD-scale; Base: LCEC 2023 no-battery systems (≈738, rounded); High: LCEC 2023 all-system average | Derived (selection) |
| PV capex, alpine ground-mounted (snow/steep terrain), Switzerland | 2,231 | 3,457 | 4,182 | EUR/kW | Đukan et al. 2024, Appl. Energy 375:124019, §3 (low = best case >2,000 m with road + grid access and no rock substructure; 4,182 = "very high" with markup) | Proxy (Swiss, upper-bound sensitivity) |
| Extra cost for snow-load / steep-tilt mounting (as %) | – | – | – | % | No public number. Đukan 2024 says racking cost rises on steeper, exposed slopes "to withstand extreme snow and wind" but gives no split. DOE FEMP (2023/2026) is qualitative only (ASCE 7 ice loads, prioritize module load rating) | **Gap** |
| PV fixed O&M | 11 | 18 | 22 | $/kW-yr | Low: LBNL Utility-Scale Solar 2025, slide 35 (median ≈$11/kWac-yr). Base: NREL ATB 2025 Commercial PV ($17.63/kWdc-yr, 2024) and ATB 2024 (≈$19, 2023); Lazard 2026 C&I $13–20. High: Bou Gebrael 2026, Table 7 (22, Lebanon); ATB 2024 utility-scale PV ($22/kWac-yr, 2023) | Sourced |
| PV lifetime | 25 | 30 | 35 | yr | 25: World Bank PAD P180501 (2024), para 64 (PV useful life). 30: NREL ATB 2024 (commercial & utility PV). 35: LBNL 2025, slide 44 (design life for 2021+ projects) | Sourced |
| PV degradation | 0.5 | 0.7 | 0.88 | %/yr | 0.5: Jordan & Kurtz 2013 (median of ~2,000 rates). 0.7: NREL ATB 2024 baseline; Jordan et al. 2022 site-level median ≈0.68. 0.88: Jordan et al. 2022 inverter-level mean. Jordan 2022 Table 4: cool-zone (T3) c-Si median ≈0.48%/yr | Sourced |
| PV project-level performance decline (incl. failures, soiling) | – | – | 1.6 | %/yr | LBNL 2025, slide 42 (US utility fleet, includes inverter failures, stuck trackers, soiling) | Proxy (stress case only) |

### A2. LFP battery (BESS)

| Parameter | Low | Base | High | Unit | Source (short cite + page/table) | Status |
|---|---|---|---|---|---|---|
| Li-ion pack price, stationary storage, 2025 | – | 70 | – | $/kWh | BNEF 2025 Battery Price Survey press release (9 Dec 2025) | Sourced |
| LFP pack price, all segments, 2025 | – | 81 | – | $/kWh | BNEF 2025 press release | Sourced |
| Li-ion pack price, all-segment average | – | 108 (2025) | 115 (2024) | $/kWh | BNEF 2025; BNEF 2024 press release (10 Dec 2024) | Sourced |
| C&I LIB pack ex-factory price (4 h) | – | – | 199 | $/kWh | NREL ATB 2024 Commercial Battery Storage, Table 1 (2022 USD; 1 h $211, 2 h $215, 6 h $174, 8 h $164) | Proxy (US) |
| Turnkey BESS system, global average 2025 | 110 (4 h) | 117 (all) | 177 (Europe) | $/kWh | BNEF 2025 ESS Cost Survey, via energy-storage.news (10 Dec 2025) | Sourced (secondary report of BNEF) |
| All-in BESS capex, utility ≥4 h, outside China/US, Oct 2025 | – | 125 | – | $/kWh | Ember 2025: ≈$75/kWh core equipment (enclosure + PCS + EMS, delivered from China) + ≈$50/kWh EPC and grid (range $30–100) | Sourced |
| Utility BESS installed cost, global 2024 | – | 192 | – | $/kWh | IRENA 2025 (RPGC 2024 summary), pp. 3, 9 | Sourced |
| Utility BESS 4 h, US, 2024 start cost | – | – | 334 | $/kWh | Cole, Ramasamy & Turan 2025 (NREL/TP-6A40-93281), §3 p. 7, Table 2 p. 16. 2025 projection: low 295 / mid 321 / high 350 | Proxy (US) |
| Utility BESS, Lazard (2 h / 4 h) | 270 | – | 580 (2 h) / 365 (4 h) | $/kWh | Lazard LCOE+ July 2026, p. 38 | Proxy (US) |
| US utility battery all-in 2024 (LBNL) | – | – | 458 | $/kWh | LBNL 2025, slide 68 | Proxy (US) |
| LFP retail modules in Lebanon (Nov 2022) | – | ≈147 | – | $/kWh | Tarnini et al. 2023, §3 (USD 2,200 per 15 kWh LiFePO4 unit) | Derived (module only, no BOS) |
| Course GA slides value | – | – | 350 | $/kWh | EECE 675 course slides (given in the brief) | Course value |
| **Recommended all-in BESS (incl. PCS, ~4 h)** | **125** | **192** | **334** | $/kWh | Ember 2025 / IRENA 2025 / Cole et al. 2025 | Sourced (selection) |
| Two-part cost: energy component | 90 | 139 | 241 | $/kWh | High: Cole et al. 2025 §2.2, Fig. 2 ($241/kWh). Low and base: Cole split scaled to Ember and IRENA totals (factors 0.374 and 0.575) | High sourced; Low and Base derived |
| Two-part cost: power component (PCS + power-related BOS) | 139 | 214 | 372 | $/kW | High: Cole et al. 2025 §2.2 ($372/kW). Low and base: same scaling as the energy component | High sourced; Low and Base derived |
| Battery fixed O&M | 2.0 | 2.5 | 4.0 | % of capex per yr | 2.0: Ember 2025 (≈$2.5/kWh-yr). 2.5: NREL ATB 2024 commercial and utility battery. 4.0: Cole et al. 2025 p. 11; ATB 2025 commercial battery. PNNL 2022: 0.43% of direct capex (≈$4.59/kW-yr, 10 MW/4 h) | Sourced |
| Battery fixed O&M in $/kWh-yr (at the base capex above) | 2.5 | 4.8 | 13.4 | $/kWh-yr | 2%×125; 2.5%×192; 4%×334. Lazard 2026 utility: $3.75–8.75/kWh-yr | Derived |
| Battery variable O&M | 0 | 0 | 0.0006 | $/kWh | NREL ATB / Cole 2025 (VOM = 0); Bou Gebrael 2026, Table 7 (0.0006) | Sourced |
| Calendar life (system) | 10 | 15 | 20 | yr | 10: course slides; Seger et al. 2023 (10-yr design horizon). 15: NREL ATB 2024; Cole et al. 2025 p. 12 ("conservative"); Megapack standard warranty. 20: Ember 2025; Lazard 2026 p. 38; Megapack extended warranty | Sourced |
| Cycle life to EOL (full equivalent cycles) | 3,500 | 8,000 | 10,000–12,000 | cycles | 3,500: CATL 310 Ah spec (to ≈80%, 0.5C, 100% DoD); EVE LF280 ≥2,500 (no fixture) / ≥3,500 (with fixture) to 80%. 8,000: CATL 314 Ah, lower bound of 8,000–10,000 (energy-storage.news). 10,000–12,000: Ember 2025 (typical guarantees); PNNL 2022 (10,000 cycles at 80% DoD warranty) | Sourced |
| Annual capacity fade (guaranteed) | – | ≤2 | – | %/yr | Ember 2025 (≈65% usable after 20 yr) | Sourced |
| End-of-life SOH (replacement trigger) | 60 | 80 | – | % of nominal | 80%: EVE LF280 spec; Lockhart et al. 2019 (NREL/TP-7A40-73238). CATL 310 Ah: stop at 70%. 60%: Seger 2023 (second-life batteries) | Sourced |
| Round-trip efficiency (AC–AC) | 0.85 | 0.90 | 0.92–0.937 | – | 0.85: NREL ATB 2024; Cole 2025 p. 12. 0.90: Ember 2025; course (η_ch = η_dis = 0.9487). 0.92 (2 h) and 0.937 (4 h): Tesla Megapack 2 XL datasheet rev 1.5.1, at 25 °C, including thermal losses. Lazard: 86–92% | Sourced |
| Usable DoD (SOC window) | 80 (SOC 20–100%) | 90 | 100 | % | 80: Lockhart et al. 2019 (min SOC 20% for Li-ion); PNNL 2022 warranty basis. 90: Lazard 2026 p. 38. 100: cell cycle-life ratings (EVE, CATL) | Sourced |
| C-rate / P ≤ 0.5·E | – | 0.5C | 1C (cell) | – | Course slides; CATL 310 Ah standard 0.5C/0.5C; EVE LF280 1C fast charge at 10–45 °C | Sourced |
| Battery replacement cost | 70 | 139 | 241 | $/kWh | Low: BNEF 2025 stationary pack. Base and high: energy component above. Seger 2023: 75 €/kWh (second-life electrochemistry replacement); 500 €/kWh installed incl. power electronics | Sourced / Derived |

### A3. Inverter / PCS and BOS

| Parameter | Low | Base | High | Unit | Source | Status |
|---|---|---|---|---|---|---|
| Battery central inverter, ex-factory | 97.5 | – | – | $/kWdc | NREL ATB 2024 Commercial Battery Storage, Table 1 (2022 USD; inverter/storage ratio 1.67) | Proxy (US) |
| PCS + power-related BOS (installed) | 139 | 214 | 372 | $/kW | As in A2, two-part power component | High sourced; Low and Base derived |
| Residential battery-based inverter | – | – | 183 | $/kWh | NREL ATB 2024 Residential Battery, Table 1 (converted from 5 kW / 12.5 kWh; ≈457 $/kW, derived) | Proxy (residential) |
| PV inverter $/kW, commercial | – | – | – | $/kW | ATB 2025 commercial PV projects inverter power electronics at ≈$0.06/Wdc in 2030 (conservative R&D case). No base-year value found in accessible text | **Gap** (bundled in PV capex) |
| PCS / inverter lifetime | 10 | 15 | 20 | yr | 15: NREL ATB 15-yr battery-system life (PCS included); Megapack 15-yr all-inclusive warranty. 20: Megapack extended warranty. 10: PNNL 2022 major power-equipment refurbishment at 30% of power-equipment cost every 10 yr | Sourced (PV-inverter-specific life: **Gap**) |
| EPC + grid-connection share of BESS all-in | 29 | 40 | 57 | % of total | Ember 2025: EPC + grid ≈50 of 125 $/kWh = 40%. With the 30–100 $/kWh range on top of 75 $/kWh equipment: 30/105 = 29%, 100/175 = 57%. (Cole 2025, separately: power-related ≈28% of a 4 h cost, 372/1,336) | Derived |
| Lebanon battery premium (with vs. without battery) | – | ≈600 (2023), ≈800 (2021) | – | $/kWp | LCEC 2025, p. 28 | Sourced (chart-read) |

### A4. Cold-climate behaviour of LFP (Faqra winters near 0 °C, snow)

| Parameter | Low | Base | High | Unit | Source | Status |
|---|---|---|---|---|---|---|
| Charging allowed below 0 °C cell temperature | – | **No** | – | – | EVE LF280 spec, Table 1 (no charge below 0 °C); CATL 310 Ah spec (charge range 0–60 °C) | Sourced |
| Max charge rate vs cell temperature | 0 (0 °C); 0.1C (5 °C); 0.25C (10–15 °C) | 0.7C (20 °C) | 1.0C (25–45 °C) | C | CATL 310 Ah spec, charge-current table. EVE LF280: 0.2C at 0–10 °C; 0.5C standard and 1C fast at 10–45 °C | Sourced |
| Discharge temperature range (cell) | −20 | – | 55–60 | °C | EVE LF280 (−20 to 55 °C); CATL 310 Ah (−20 to 60 °C) | Sourced |
| Discharge capacity vs 20–25 °C | 42.4 (−20 °C) | 72.2 (−10 °C) | 86.7 (0 °C) | % | Liao et al. 2012, Electrochim. Acta 60:269–273, Fig. 2a (Li/LiFePO4 half-cell, 0.3C, charged at 20 °C) | Sourced (lab cell) |
| Capacity at −20 °C, commercial LFP cells | ≈70 | – | – | % | EVE LF280: ≥70% at −20 °C (0.2C). CATL 310 Ah: ≥217 Ah, i.e. ≈70% of 310 Ah (derived) | Sourced |
| Container operating ambient range | −30 | – | 50 | °C | Tesla Megapack 2 XL datasheet (−30 to 50 °C); Sungrow PowerTitan 2.0 ST5015 datasheet V3 (−30 to 50 °C, LFP 314 Ah, liquid cooling, IP55, altitude ≤4,000 m, derating above 45 °C) | Sourced |
| HVAC/heating auxiliary energy as share of charged energy (cold US climates, enclosure held at 15–40 °C) | 8 | – | 34 | % | Olis et al. 2023, Energy 278:127878, p. 15 (8% Massachusetts with PCS inside; 34% Fairbanks AK with PCS outside; NMC). Same study: required kWh +42–300%, capex +43–296% vs constant-temperature models | Proxy (NMC, US climates) |
| System-level efficiency penalty from auxiliaries | 8 | – | 13 | percentage points | Schimpe et al. 2018, Appl. Energy 210:211–229 (abstract: overall efficiency 8–13 pp below conversion efficiency for PV-battery and PCR use) | Sourced |
| Container aux load, 5 MWh liquid-cooled block | 0.8 | – | 1.6 | % of PCS kW (continuous) | Rathore, Energy Central blog (Dec 2025): 11–22 kW for 1.375 MVA PCS; winter (5–10 °C) 12–17 kW | Proxy (non-peer-reviewed) |
| **Recommended LP treatment** | Aux = 0 beyond datasheet RTE (Megapack RTE includes thermal at 25 °C) | Aux = 8% of charged energy in Dec–Mar | Aux = 15% plus winter usable-energy derate to 0.867 (0 °C) | – | See derivation note (b5) | Derived |

### A5. Degradation cost in LP form

| Parameter | Low | Base | High | Unit | Source | Status |
|---|---|---|---|---|---|---|
| Throughput degradation cost, per kWh **discharged** (c = C_rep / (N_cyc·DoD·√η_rt)) | 0.008 | 0.020 | 0.093 | $/kWh | Inputs: low C_rep = 70, N = 10,000, DoD 0.9, η = 0.90; base 139 / 8,000 / 0.9 / 0.90; high 241 / 3,500 / 0.8 / 0.85. Formula after the HOMER Pro "battery wear cost" definition | Derived |
| Same, per kWh of **charge + discharge** throughput | 0.004 | 0.010 | 0.043 | $/kWh | Half of the above (no √η) | Derived |
| Seger et al. 2023 basis (supports linear form) | – | – | – | – | Seger et al. 2023, §2.2 and Fig. 4: monthly SoH loss is linear in normalized exchanged energy (R² > 0.98); ignoring degradation underestimates cost by >20%. Gives no $/kWh-cycled value | Sourced (method only) |

### A6. Discount rate, inflation, lifetime

| Parameter | Low | Base | High | Unit | Source | Status |
|---|---|---|---|---|---|---|
| Discount rate, nominal USD | 8.7 | 10 | 15.4–16.9 | % | 8.7: IRENA 2023 (Cost of Financing), p. 11, MEA solar PV simple average CoC, nominal after-tax 2019–21. 10: World Bank PAD P180501 (Sep 2024), paras 64, 67, 69 (economic and financial discount rate for Lebanon RE). High: derived WACC from UNDP DREI Lebanon 2025 (CoE 21% interviews or 26% CAPM; CoD 13%, USD), assuming 70/30 debt/equity | Sourced / Derived |
| Lebanon cost of equity (USD) | 16 (2017) | 21 | 26 | % | UNDP DREI 2018 Key Points p. 2 (16%); UNDP DREI 2025 Exec. Summary p. 26 (21% interviews; 26% CAPM) | Sourced |
| Lebanon cost of debt (USD) | – | 13 | – | % | UNDP DREI 2025, p. 26 | Sourced |
| Benchmarks: Jordan (CoE/CoD), Germany | – | 15 / 7 (Jordan) | – | % | UNDP DREI 2025, p. 26 (Germany 8 / 4) | Sourced |
| Other WACC references | 3.26 (LBNL US, real) | 7 (Ember BESS) | 7.7 (Lazard US, nominal) | % | LBNL 2025, slide 44; Ember 2025; Lazard 2026, p. 7 (60% debt at 8% / 40% equity at 12%). IRENA ≤2021 LCOE: real 7.5% for OECD/China, 10% for the rest of the world | Sourced |
| US inflation (USD-denominated project) | – | 2.7 (2025) | 2.9 (2024) | %/yr | BLS, "CPI 2025 in review" (21 Jan 2026), CPI-U Dec–Dec | Sourced |
| Lebanon CPI inflation (LBP) | 14.8 (2025) | 45.24 (2024) | 221.3 (2023) | %/yr | CAS via L'Orient Today (2026). Do not use for a USD model | Sourced |
| **Discount rate, real USD (for LP)** | **5.84** | **7.11** | **12.37** | % | Fisher conversion of 8.7 / 10 / 15.4% nominal at 2.7% inflation | Derived |
| Project lifetime | 20 | 25 | 25 | yr | UNDP DREI 2025 (PV savings over 20 yr); World Bank PAD 2024 (25-yr analysis period) | Sourced |

---

## (b) Derivation notes

**b1. CRF.** CRF(i, n) = i(1+i)^n / ((1+i)^n − 1). Annualized capex for the LP = CRF × capex. Use the **real** rate with constant-dollar costs (the LP has no escalation). Use the **nominal** rate only if fuel and O&M are escalated.

| i (real) | n = 10 | n = 15 | n = 20 | n = 25 | n = 30 |
|---|---|---|---|---|---|
| 5.00% | 0.1295 | 0.0963 | 0.0802 | 0.0710 | 0.0651 |
| 5.84% (low) | 0.1348 | 0.1019 | 0.0861 | 0.0770 | 0.0714 |
| 7.00% | 0.1424 | 0.1098 | 0.0944 | 0.0858 | 0.0806 |
| **7.11% (base)** | **0.1431** | **0.1106** | **0.0952** | **0.0867** | 0.0815 |
| 8.00% | 0.1490 | 0.1168 | 0.1019 | 0.0937 | 0.0888 |
| 10.00% | 0.1627 | 0.1315 | 0.1175 | 0.1102 | 0.1061 |
| 12.37% (high) | 0.1796 | 0.1497 | 0.1369 | 0.1307 | 0.1275 |
| 15.40% (high, if treated as real) | 0.2023 | 0.1743 | 0.1633 | 0.1584 | 0.1561 |

Recommended pairing: PV with n = 25 (CRF 0.0867 at base), BESS with n = 15 (0.1106; calendar life) or 10 (0.1431; course), PCS with n = 15, diesel per its own life. An alternative to a separate battery CRF is a project-life CRF plus a discounted replacement in year L_bat. With the base rate, the replacement factor is 1/(1.0711)^15 = 0.357 (derived).

**b2. Real rate (Fisher).** r = (1 + n)/(1 + π) − 1 with π = 2.7%:
- 8.7% nominal gives 5.84% real.
- 10% gives 7.11%.
- 15.4% gives 12.37%.
- 16.9% gives 13.83%.

The DREI WACC is derived as 0.7×13% + 0.3×21% = 15.4%, or 0.7×13% + 0.3×26% = 16.9%. DREI does not publish a debt share. The 70/30 split is my assumption, matching the LBNL 70/30 capital structure (Lazard uses 60/40). These are pre-tax approximations.

**b3. BESS two-part cost.** Cole et al. (2025) give total cost ($/kW) = 241·d + 372. For d = 4 h that is 1,336 $/kW (334 $/kWh). The energy share is 964/1,336 = 72%.

The same split is applied to the all-in $/kWh totals of IRENA (192) and Ember (125) through scale factors 192/334 = 0.575 and 125/334 = 0.374:
- Base: 139 $/kWh + 214 $/kW.
- Low: 90 $/kWh + 139 $/kW.

For a 0.5C (2 h) system the all-in cost per kWh is higher. For example, base: 139 + 214/2 = 246 $/kWh (derived). Use C_E·E + C_P·P directly in the LP, with the PCS variable carrying C_P.

**b4. Degradation cost.** HOMER defines wear cost as c_bw = C_rep / (N_batt·Q_lifetime·√η_rt). Q_lifetime per kWh of nominal capacity is approximated by N_cyc·DoD, ignoring the fade-weighted average. In the LP: Σ_t c_deg·P_dis,t·Δt, or c_deg/2·(P_ch + P_dis)·Δt. Seger et al. (2023) show the capacity loss is close to linear in normalized exchanged energy, which justifies the linear form.

Caveats:
- Degradation is not purely throughput-driven. Calendar ageing exists, and cold charging causes lithium plating; the chemistry is why the cells forbid charging below 0 °C.
- If you both charge the degradation cost and annualize a battery replacement every L years, you double-count. Use one or the other, or set L by cycle count.

**b5. Cold-climate LP constraints (recommended).**
1. **Charging.** If the BESS is an outdoor container with a thermal system (Megapack or PowerTitan class, rated −30 to 50 °C), assume cells are held in their window and charging is allowed. Add a heating aux load P_aux,t = α·P_ch,t, with α = 0.08 (base) in Dec–Mar, from the Olis et al. 2023 mildest cold site. If you model an unheated cabinet, impose P_ch,t = 0 when T_cell < 0 °C and P_ch ≤ 0.1E at 5 °C (CATL table).
2. **Usable energy.** Without heating, derate E_usable by 0.867 at 0 °C and 0.722 at −10 °C (Liao 2012, lab cell). Commercial cells guarantee ≥70% at −20 °C.
3. **Altitude.** The Sungrow PowerTitan 2.0 is rated to 4,000 m, so Faqra (≤1,975 m) needs no altitude derate per that datasheet.

**b6. PV capex selection.** The Lebanese market price (LCEC 2023: ≈738 $/kWp without batteries; 1,003 $/kWp overall) sits between the IRENA global utility average (691) and US commercial benchmarks (1,660–2,610). The LCEC data cover mostly small and medium systems, with no size split. For a resort-scale ground or roof array, base = 750 is a defensible choice.

The Swiss alpine range (2,231–4,182 EUR/kW) reflects helicopter transport, rock drilling and Swiss labor. Treat it as a high-side sensitivity, not as base. Faqra has road access, so it is closest to Đukan's "best case".

---

## (c) BibTeX

```bibtex
@techreport{IRENA2025RPGC,
  author = {{IRENA}}, title = {Renewable Power Generation Costs in 2024 (Summary)},
  institution = {International Renewable Energy Agency}, address = {Abu Dhabi}, year = {2025},
  url = {https://www.irena.org/-/media/Files/IRENA/Agency/Publication/2025/Jul/IRENA_TEC_RPGC_in_2024_Summary_2025.pdf}}

@techreport{IRENA2023Financing,
  author = {{IRENA}}, title = {The Cost of Financing for Renewable Power},
  institution = {International Renewable Energy Agency}, address = {Abu Dhabi}, year = {2023},
  url = {https://www.irena.org/Publications/2023/May/The-cost-of-financing-for-renewable-power}}

@misc{NREL_ATB2024_ComPV,
  author = {{National Renewable Energy Laboratory}}, title = {2024 Annual Technology Baseline: Commercial PV},
  year = {2024}, url = {https://atb.nrel.gov/electricity/2024/commercial_pv}}

@misc{NREL_ATB2024_UtilPV,
  author = {{National Renewable Energy Laboratory}}, title = {2024 Annual Technology Baseline: Utility-Scale PV},
  year = {2024}, url = {https://atb.nrel.gov/electricity/2024/utility-scale_pv}}

@misc{NREL_ATB2025_ComPV,
  author = {{National Laboratory of the Rockies (formerly NREL)}}, title = {2025 Annual Technology Baseline: Commercial PV},
  year = {2025}, url = {https://atb.nlr.gov/electricity/2025/commercial_pv}}

@misc{NREL_ATB2024_ComBatt,
  author = {{National Renewable Energy Laboratory}}, title = {2024 Annual Technology Baseline: Commercial Battery Storage},
  year = {2024}, url = {https://atb.nrel.gov/electricity/2024/commercial_battery_storage}}

@misc{NREL_ATB2024_UtilBatt,
  author = {{National Renewable Energy Laboratory}}, title = {2024 Annual Technology Baseline: Utility-Scale Battery Storage},
  year = {2024}, url = {https://atb.nrel.gov/electricity/2024/utility-scale_battery_storage}}

@misc{NREL_ATB2024_ResBatt,
  author = {{National Renewable Energy Laboratory}}, title = {2024 Annual Technology Baseline: Residential Battery Storage},
  year = {2024}, url = {https://atb.nrel.gov/electricity/2024/residential_battery_storage}}

@misc{NREL_ATB2025_ComBatt,
  author = {{National Laboratory of the Rockies (formerly NREL)}}, title = {2025 Annual Technology Baseline: Commercial Battery Storage},
  year = {2025}, url = {https://atb.nlr.gov/electricity/2025/commercial_battery_storage}}

@techreport{Cole2025,
  author = {Cole, Wesley and Ramasamy, Vignesh and Turan, Merve}, title = {Cost Projections for Utility-Scale Battery Storage: 2025 Update},
  institution = {National Renewable Energy Laboratory}, number = {NREL/TP-6A40-93281}, address = {Golden, CO}, year = {2025},
  url = {https://docs.nrel.gov/docs/fy25osti/93281.pdf}}

@techreport{Ramasamy2023,
  author = {Ramasamy, Vignesh and Zuboy, Jarett and Woodhouse, Michael and O'Shaughnessy, Eric and Feldman, David and Desai, Jal and Walker, Andy and Margolis, Robert and Basore, Paul},
  title = {U.S. Solar Photovoltaic System and Energy Storage Cost Benchmarks, With Minimum Sustainable Price Analysis: Q1 2023},
  institution = {National Renewable Energy Laboratory}, number = {NREL/TP-7A40-87303}, year = {2023},
  url = {https://www.nrel.gov/docs/fy23osti/87303.pdf}}

@misc{Feldman2024Spring,
  author = {Feldman, David and Zuboy, Jarett and Dummit, Krysta and Stright, Dana and Heine, Matthew and Grossman, Shayna and Margolis, Robert},
  title = {Spring 2024 Solar Industry Update}, howpublished = {NREL presentation}, year = {2024}, month = may,
  url = {https://nrel.gov/docs/fy24osti/90042.pdf}}

@misc{Feldman2024Fall,
  author = {Feldman, David and Zuboy, Jarett and Dummit, Krysta and Stright, Dana and Heine, Matthew and Grossman, Shayna and Narayanaswami, Meenakshi and Margolis, Robert},
  title = {Fall 2024 Solar Industry Update}, howpublished = {NREL presentation}, year = {2024}, month = oct,
  url = {https://nrel.gov/docs/fy25osti/92257.pdf}}

@misc{Seel2025LBNL,
  author = {Seel, Joachim and Mulvaney Kemp, Julie and Cheyette, Anna and Gorman, Will and Darghouth, Naim and Robson, Dana and Rand, Joe and Jeong, Seongeun},
  title = {Utility-Scale Solar, 2025 Edition (Slides)}, howpublished = {Lawrence Berkeley National Laboratory}, year = {2025},
  url = {https://emp.lbl.gov/sites/default/files/2025-10/Utility%20Scale%20Solar%202025%20Edition%20Slides.pdf}}

@techreport{Lazard2026,
  author = {{Lazard}}, title = {Levelized Cost of Energy+ (LCOE v19.0, LCOS v11.0)}, institution = {Lazard}, year = {2026}, month = jul,
  url = {https://lazard.com/media/sdvdrvc5/lazards-lcoeplus_vf.pdf}}

@misc{ESN2025Lazard,
  author = {{Energy-Storage.news}}, title = {Lazard says US energy storage cost reduction in 2025 offsets prior pandemic-driven increases},
  year = {2025}, url = {https://www.energy-storage.news/lazard-says-us-energy-storage-cost-reduction-in-2025-offsets-prior-pandemic-driven-increases/}}

@misc{BNEF2025Pack,
  author = {{BloombergNEF}}, title = {Lithium-Ion Battery Pack Prices Fall to \$108 per Kilowatt-Hour, Despite Rising Metal Prices (press release)},
  year = {2025}, month = dec, note = {9 Dec 2025},
  url = {https://about.bnef.com/insights/clean-energy/lithium-ion-battery-pack-prices-fall-to-108-per-kilowatt-hour}}

@misc{BNEF2024Pack,
  author = {{BloombergNEF}}, title = {Lithium-Ion Battery Pack Prices See Largest Drop Since 2017, Falling to \$115 per Kilowatt-Hour (press release)},
  year = {2024}, month = dec, note = {10 Dec 2024},
  url = {https://about.bnef.com/insights/clean-transport/lithium-ion-battery-pack-prices-see-largest-drop-since-2017-falling-to-115-per-kilowatt-hour-bloombergnef/}}

@misc{ESN2025BNEFEmber,
  author = {{Energy-Storage.news}}, title = {Battery storage system prices continue to fall sharply, BNEF and Ember reports find},
  year = {2025}, url = {https://www.energy-storage.news/battery-storage-system-prices-continue-to-fall-sharply-bnef-and-ember-reports-find/}}

@misc{Ember2025,
  author = {Rangelova, Kostantsa and Jones, Dave}, title = {How cheap is battery storage?}, howpublished = {Ember}, year = {2025}, month = dec,
  url = {https://ember-energy.org/latest-insights/how-cheap-is-battery-storage/}}

@techreport{PNNL2022,
  author = {Viswanathan, Vilayanur and Mongird, Kendall and Franks, Ryan and Li, Xiaolin and Sprenkle, Vincent and Baxter, Richard},
  title = {2022 Grid Energy Storage Technology Cost and Performance Assessment}, institution = {Pacific Northwest National Laboratory},
  number = {PNNL-33283}, year = {2022}, url = {https://www.sandia.gov/app/uploads/sites/256/2024/02/ESGC-Cost-Performance-Report-2022-PNNL-33283.pdf}}

@techreport{Lockhart2019,
  author = {Lockhart, Eric and Li, Xiangkun and Booth, Samuel and Salasovich, James and Olis, Dan and Elsworth, James and Lisell, Lars},
  title = {Comparative Study of Techno-Economics of Lithium-Ion and Lead-Acid Batteries in Micro-Grids in Sub-Saharan Africa},
  institution = {National Renewable Energy Laboratory}, number = {NREL/TP-7A40-73238}, year = {2019},
  url = {https://www.nrel.gov/docs/fy19osti/73238.pdf}}

@techreport{LCEC2025PV,
  author = {El Hajj, Mohamad and Abou Moussa, Hadi and Mikhael, Grace}, title = {The 2023 Solar PV Status Report for Lebanon (7th ed.)},
  institution = {Lebanese Center for Energy Conservation (LCEC)}, address = {Beirut}, year = {2025}, month = apr,
  url = {https://lcec.org.lb/sites/default/files/2025-10/Solar%20PV%20Status%20Report%202023_VF.pdf}}

@article{Tarnini2023,
  author = {Tarnini, Mohamad and Alsayed, Mohammad and El Ghaly, Abdallah and Chahine, Khaled},
  title = {Towards Energy Sustainability in University Campuses: A Case Study of Beirut Arab University},
  journal = {Sustainability}, volume = {15}, number = {9}, pages = {7695}, year = {2023}, doi = {10.3390/su15097695}}

@misc{BouGebrael2026,
  author = {Bou Gebrael, Elsa and Olleik, Majd and Zwickl-Bernhard, Sebastian},
  title = {Cleaner energy microgrids under market power and limited regulation in developing countries},
  howpublished = {arXiv:2603.16893}, year = {2026}, url = {https://arxiv.org/abs/2603.16893}}

@techreport{WB2024PAD,
  author = {{World Bank}}, title = {Project Appraisal Document: Lebanon Renewable Energy and System Reinforcement Project (P180501), Report No. PAD00147},
  institution = {World Bank}, year = {2024}, month = sep,
  url = {https://documents1.worldbank.org/curated/en/099091124181525582/txt/BOSIB1c260299b0c71a0c11b95eb42d17a7.txt}}

@techreport{UNDP2025DREI,
  author = {{UNDP}}, title = {Lebanon: Derisking Renewable Energy Investment 2025}, institution = {United Nations Development Programme},
  year = {2026}, url = {https://www.undp.org/sites/g/files/zskgke326/files/2026-01/lebanon_derisking_renewable_energy_investment_2025.pdf}}

@techreport{UNDP2018DREI,
  author = {{UNDP}}, title = {Derisking Renewable Energy Investment: Lebanon -- Key Points}, institution = {United Nations Development Programme},
  year = {2018}, url = {https://www.undp.org/sites/g/files/zskgke326/files/publications/DREI%20Lebanon_Key%20Points%20(English)%20(Jun%202018)%20(FINAL).pdf}}

@misc{BLS2026CPI,
  author = {{U.S. Bureau of Labor Statistics}}, title = {Consumer Price Index: 2025 in review}, howpublished = {The Economics Daily}, year = {2026},
  url = {https://www.bls.gov/opub/ted/2026/consumer-price-index-2025-in-review.htm}}

@misc{LOrient2026Infl,
  author = {{L'Orient Today}}, title = {Lebanon's inflation rate at 14.8\% in 2025 marks its second straight annual decline}, year = {2026},
  url = {https://today.lorientlejour.com/article/1492339/lebanons-inflation-rate-at-148-in-2025-marks-its-second-straight-annual-decline.html}}

@article{JordanKurtz2013,
  author = {Jordan, Dirk C. and Kurtz, Sarah R.}, title = {Photovoltaic Degradation Rates---an Analytical Review},
  journal = {Progress in Photovoltaics: Research and Applications}, volume = {21}, number = {1}, pages = {12--29}, year = {2013}, doi = {10.1002/pip.1182}}

@article{Jordan2022,
  author = {Jordan, Dirk C. and Anderson, Kevin and Perry, Kirsten and Muller, Matthew and Deceglie, Michael and White, Robert and Deline, Chris},
  title = {Photovoltaic fleet degradation insights}, journal = {Progress in Photovoltaics: Research and Applications},
  volume = {30}, number = {10}, pages = {1166--1175}, year = {2022}, doi = {10.1002/pip.3566}}

@article{Dukan2024,
  author = {{\DJ}ukan, Mak and Gut, David and Gumber, Anurag and Steffen, Bjarne},
  title = {Harnessing solar power in the Alps: A study on the financial viability of mountain PV systems},
  journal = {Applied Energy}, volume = {375}, pages = {124019}, year = {2024}, doi = {10.1016/j.apenergy.2024.124019}}

@misc{DOEFEMPWinter,
  author = {{U.S. Department of Energy, Federal Energy Management Program}}, title = {Solar Photovoltaic Hardening for Resilience -- Winter Weather},
  year = {2023}, note = {updated 2026}, url = {https://www.energy.gov/node/4829003}}

@article{Seger2023,
  author = {Seger, Pedro V. H. and Rigo-Mariani, R{\'e}my and Thivel, Pierre-Xavier and Riu, Delphine},
  title = {A storage degradation model of Li-ion batteries to integrate ageing effects in the optimal management and design of an isolated microgrid},
  journal = {Applied Energy}, volume = {333}, pages = {120584}, year = {2023}, doi = {10.1016/j.apenergy.2022.120584}}

@misc{HOMERWear,
  author = {{UL Solutions / HOMER Energy}}, title = {HOMER Pro Manual: Battery Wear Cost},
  url = {https://support.ul-renewables.com/homer-manual-pro/battery_wear_cost.html}}

@article{Liao2012,
  author = {Liao, Lixia and Zuo, Pengjian and Ma, Yulin and Chen, XinQun and An, Yongxin and Gao, Yunzhi and Yin, Geping},
  title = {Effects of temperature on charge/discharge behaviors of LiFePO4 cathode for Li-ion batteries},
  journal = {Electrochimica Acta}, volume = {60}, pages = {269--273}, year = {2012}, doi = {10.1016/j.electacta.2011.11.041}}

@article{Olis2023,
  author = {Olis, Walker and Rosewater, David and Nguyen, Tu and Byrne, Raymond H.},
  title = {Impact of heating and cooling loads on battery energy storage system sizing in extreme cold climates},
  journal = {Energy}, volume = {278}, pages = {127878}, year = {2023}, doi = {10.1016/j.energy.2023.127878}}

@article{Schimpe2018,
  author = {Schimpe, Michael and Naumann, Maik and Truong, Nam and Hesse, Holger C. and Santhanagopalan, Shriram and Saxon, Aron and Jossen, Andreas},
  title = {Energy efficiency evaluation of a stationary lithium-ion battery container storage system via electro-thermal modeling and detailed component analysis},
  journal = {Applied Energy}, volume = {210}, pages = {211--229}, year = {2018}, doi = {10.1016/j.apenergy.2017.10.129}}

@misc{EVE_LF280,
  author = {{EVE Energy Co., Ltd.}}, title = {LF280 3.2V 280Ah LFP Cell Product Specification (version E)},
  url = {https://mikrocontroller.net/attachment/572319/LF280-280Ah-product_specification-version-e.pdf}}

@misc{CATL_310Ah,
  author = {{Contemporary Amperex Technology Co. Ltd. (CATL)}}, title = {Specification for 310Ah LFP Energy Storage Cell, Model 001CB0Y0, Rev. 1.5},
  url = {https://cdn.shopify.com/s/files/1/0559/0830/2937/files/CATL_310ah_Spec.pdf}}

@misc{Critchley_LFPcells,
  author = {Critchley, Liam}, title = {Beyond 314Ah: a comparison of large-format LFP battery cells for BESS}, howpublished = {Energy-Storage.news},
  url = {https://www.energy-storage.news/beyond-314ah-a-comparison-of-large-format-lfp-battery-cells-for-bess/}}

@misc{TeslaMegapack2XL,
  author = {{Tesla, Inc.}}, title = {Megapack 2 XL Datasheet, rev. 1.5.1}, year = {2023},
  url = {https://portal.ct.gov/-/media/csc/3_petitions-medialibrary/petitions_medialibrary/mediapetitionnos1601-1700/pe1607/petitionersubmissions/supplement-attachment-a---megapack_2_xl_datasheet.pdf}}

@misc{SungrowPT2,
  author = {{Sungrow Power Supply Co., Ltd.}}, title = {PowerTitan 2.0 ST5015kWh-2500kW-2h / 1250kW-4h Datasheet, Version 3}, year = {2023},
  url = {https://uk.sungrowpower.com/upload/file/20240307/EN_DS_ST5015kWh-2500kW-2h_1250kW-4h_Datasheet.pdf}}

@misc{Rathore2025Aux,
  author = {Rathore, Bhawani Singh}, title = {BESS 5 MWh Aux consumption}, howpublished = {Energy Central blog}, year = {2025},
  url = {https://www.energycentral.com/energy-biz/post/bess-5-mwh-aux-consumption-nB19OmDcUfffS2B}}
```

---

## (d) Gaps and caveats

1. **Snow-load / steep-tilt mounting premium.** No public source gives a % or $/W premium. The only quantitative anchor is the Swiss alpine capex range (Đukan 2024; 2,231–4,182 EUR/kW), which bundles remoteness, helicopter logistics and Swiss labor. Recommend a ±20–50% PV-capex sensitivity. That range is my **assumption**; no source supports it.
2. **IRENA RPGC 2024 full report** (5th/95th percentiles, PV O&M, country breakdowns, regional WACC) could not be read: the PDF was blocked to the fetch tool, and in-browser text extraction was not permitted. Only summary figures (691 $/kW; 192 $/kWh) are used.
3. **UNDP DREI 2025 Annex A** (Lebanon PV/BESS capex, debt share, post-derisking rates) was not readable (25 MB PDF truncated). The DREI-based WACC uses an **assumed** 70/30 debt/equity split.
4. **PV inverter $/kW and lifetime.** No accessible base-year value. PV inverter cost is bundled in the PV capex rows. PCS life uses battery-system proxies (ATB 15 yr; Megapack warranty).
5. **LCEC battery/no-battery prices** were read off a chart (±≈5%). LCEC gives no size breakdown, so the "commercial 100 kW–2 MW Lebanon" price is not separately available.
6. **Seger et al. 2023** gives no $/kWh-cycled value. The study used second-life batteries with 500 €/kWh installed and 75 €/kWh replacement. The throughput costs in A5 are **derived**.
7. **Cold-climate aux energy.** The peer-reviewed data (Olis 2023) are for NMC in US climates (Fairbanks to Massachusetts) with a 15–40 °C enclosure setpoint. Faqra's winters (~0 °C mean) are milder than all of them except perhaps Massachusetts. No LFP-specific peer-reviewed HVAC share for mild-cold mountain sites was found. The **P3 Group 2022** study requested in the brief was **not found** publicly.
8. **Liao 2012** capacity ratios are from a Li/LiFePO4 half-cell at 0.3C, not a commercial graphite/LFP cell. Commercial cell specs give ≥70% at −20 °C, much better than Liao's 42%. Use Liao as a conservative bound.
9. **Most $/kWh BESS figures are utility-scale.** A 0.5–5 MWh commercial system in Lebanon will likely sit above Ember/BNEF (125 $/kWh) because of shipping, EPC scale and no grid-connection economies. Hence base = IRENA 192 and high = Cole 334. Course slides use 350.
10. **Lebanese bank-sector risk.** UNDP DREI 2025 implies a USD WACC of ~15–17%, far above the World Bank PAD's 10%. The discount rate is the most influential uncertainty for the CRF. Run sensitivity at 5.8 / 7.1 / 12.4% real.
11. **Lazard facility life** for PV (25–35 yr) was garbled in the extracted text. ATB, WB and LBNL figures are used instead.
12. **Energy-storage.news** reports BNEF's 2025 ESS survey ($117/kWh). The BNEF primary survey is paywalled.
