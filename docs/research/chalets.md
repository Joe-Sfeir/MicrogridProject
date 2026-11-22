# Chalet (second-home) electricity demand: Faqra Club, Kfardebian

Scope: this is a separate load block for the ~350 to 400+ residential chalets in the gated estate. Report it in two variants, with and without the chalets on the club network. All values are reconstructed from public sources; there are no site measurements.

Status key:
- **verified**: the number was read directly in the cited source.
- **derived**: the number was computed from verified inputs, and the derivation is shown in Section (b).
- **assumed**: this is a modelling choice. Its basis is stated, and it should be replaced if better data appear.

Some sources could only be read as abstracts, metadata or excerpts through web tools. These are marked "(abstract)" or "(excerpt)" and listed again under Gaps.

---

## (a) Parameter table

| # | Parameter | Low | Base | High | Unit | Source (short cite + page/table) | Status |
|---|---|---|---|---|---|---|---|
| 1 | Number of chalets / households in the estate | 350 | 400 | 400 | chalets | ~350 large chalets (2014) and >400 families (2026), both supplied by the project brief. ">400" is a lower bound, so High is not raised without a source. | verified (brief) |
| 2 | Urban Lebanese household consumption, primary home, pre-crisis | – | 6,907 (= 18.9 kWh/d) | – | kWh/hh/yr | Houri & Ibrahim-Korfali 2005, abstract (509 urban households) | verified (abstract) |
| 3 | Summer share of annual household consumption | – | 28 | – | % | Houri & Ibrahim-Korfali 2005, abstract | verified (abstract) |
| 4 | Top-income-quintile consumption, "peak months" | – | 755 (≈24.8 kWh/d) | – | kWh/month | World Bank 2009, SIA Report 48993-LB, Table 2.4 (2008 survey) | verified |
| 5 | Top-income-quintile consumption, "off-peak months" | – | 489 (≈16.1 kWh/d) | – | kWh/month | World Bank 2009, Table 2.4 | verified |
| 6 | Lowest-quintile consumption, peak / off-peak months | 488 / 295 | – | – | kWh/month | World Bank 2009, Table 2.4 | verified |
| 7 | Average EDL subscription level by quintile (lowest → highest) | 12.9 | – | 16.8 | A | World Bank 2009, Table 2.4 | verified |
| 8 | Share of households subscribed to EDL at 10 or 15 A / at 20 A | 69 / 16 | – | – | % | World Bank 2009, ¶35 | verified |
| 9 | Typical private-generator subscription | 5 | 6.5 (avg) | – | A | World Bank 2009, ¶27–28: "vast majority" take 5 A; average 6.5 A | verified |
| 10 | Generator customer split, 5 A / 10 A / 15 A | 60 / 25 / 15 | – | – | % of customers | World Bank 2020, *Distributed Power Generation for Lebanon*, pp. 24 & 30, Table 3. Footnote 43 (p. 31): affluent areas often need ≥15 A | verified |
| 11 | Average neighbourhood-generator supply, post-crisis (Nov 2021 – Jan 2022) | – | 7 | – | A | HRW 2023, *Cut Off From Life Itself*, HRW/CRI survey of n≈1,209 households | verified |
| 12 | Implied consumption per generator customer | 214 | 308 | – | kWh/month | World Bank 2020: p. 31, Table 8 (66,880 kWh / 312 customers); pp. 23–24 (4 TWh / 1.08 M customers) | derived |
| 13 | Post-crisis daily demand: regression intercept and season effects | – | 14.0 (intercept); summer +11.5, winter +6.3 | – | kWh/day | Olleik et al. 2026, arXiv:2606.17807, regression Table 6 (survey n=984, 2025) | verified (coefficients only; sample mean not reported) |
| 14 | Effect per extra room (extended model) | – | +1.4 | – | kWh/day/room | Olleik et al. 2026, Table 6. Column alignment is uncertain in the HTML text. | verified (caution) |
| 15 | "Average Lebanese house" consumption from collected EDL bills | – | – | 1,200 (= 40 kWh/d) | kWh/month | Richa 2018, AUB M.Eng. thesis (bills collected by the author; weak source) | verified (weak) |
| 16 | Households using electricity for space heating (any use) | – | 48 | – | % | World Bank 2009, ¶19, Fig. 2.3 | verified |
| 17 | Primary dwellings with **electric** heating as primary means (central 2.0 + non-central 15.1) | – | 17.1 | – | % of sample | CAS 2004 National Survey of Household Living Conditions; IHSN catalogue 8279, variables rpd27/rpd28 (unweighted counts, n=12,981) | verified (unweighted) |
| 18 | **Secondary** dwellings with electric primary heating (central 1.3 + non-central 6.8) | – | 8.1 | – | % of sec. dwellings | CAS 2004, rsd27/rsd28 (n=851 secondary dwellings reporting) | verified (unweighted) |
| 19 | Secondary dwellings with gas-oil (diesel) central heating / kerosene-gas-oil stove | – | 5.5 / 12.6 | – | % | CAS 2004, rsd29/rsd30 | verified (unweighted) |
| 20 | Secondary dwellings with no heating system | – | 48.1 | – | % | CAS 2004, rsd34 | verified (unweighted) |
| 21 | Electric space heating in the chalet model | none (diesel boiler + fireplace) | none beyond what is embedded in row 4 | supplementary electric heating (row 15 level) | – | Rows 16–20. The brief states chalets have fireplaces and heating systems. | assumed |
| 22 | Occupied-day consumption, **winter** (ski season) | 16.1 | 24.8 | 40.0 | kWh/day | Low = row 5; Base = row 4; High = row 15 | derived |
| 23 | Occupied-day consumption, **summer** (Jul to mid-Sep, no AC at 1,800 m) | 16.1 | 16.1 | 24.8 | kWh/day | Low/Base = row 5 (off-peak months, i.e. no AC peak); High = row 4 | derived |
| 24 | Occupied-day consumption, **shoulder** seasons | 16.1 | 18.9 | 24.8 | kWh/day | Base = row 2 ÷ 365 | derived |
| 25 | Unoccupied standby load (always-on loads, controls, standby) | 30 | 50 | 100 | W | Meier 2001, LBNL-49377: field studies 30 W (China) to >100 W (NZ, US), weighted mean ≈50 W. Ross & Meier 2000, LBNL-45967: mean 67 W, range 14–169 W. | verified (range) / assumed (mapping) |
| 26 | Second-home occupancy in Alpine ski resorts (median) | – | 14–15.4 | – | weeks/yr | Drouet 2025, *Geogr. Helv.* 80:363: French resorts 14.5 wk, Nendaz 14 wk, Kranjska Gora 15.4 wk (n=1,181) | verified |
| 27 | Equivalent full-occupancy days per chalet | 65.6 | 100.5 | 154.4 | days/yr | Calibrated so that Base equals row 26 (14.4 wk). See Section (d). | derived |
| 28 | **Annual energy per chalet** | **1,270** | **2,340** | **5,210** | kWh/chalet/yr | Sum of occupied energy (rows 22–24 × Section d) and standby (row 25) | derived |
| 29 | **Aggregate annual chalet energy** | **445** | **938** | **2,085** | MWh/yr | Row 28 × row 1 | derived |
| 30 | Individual (undiversified) chalet max demand | 3.5 | 3.5 | 9.7 | kW | Low/Base: 16.8 A (row 7) × 220 V × PF 0.95 (PF from World Bank 2020, p. 24). High: Less & Walker 2026, *Appl. Energy* 410:127422, mean 15-min max demand of US homes = 9.7 kW | derived / verified |
| 31 | Normalised-profile peak-hour share of daily energy | 0.0567 (weekend) | 0.0567 | 0.0607 (weekday) | – | Spanish official residential profile P2.0TD (BOE-A-2024-27398, Annex III), 15 & 18 Jan 2025. See Section (c). | derived |
| 32 | Occupancy on the design (peak) day: ski-season weekend | 0.50 | 0.70 | 0.90 | fraction of chalets | Section (d) | assumed |
| 33 | Coincidence factor c(N), Rusck formula | 0.25 | 0.34 | 0.22 | – | Rusck 1956 via Fürst et al. 2020 (CIRED), Eq. 8: c(N)=c∞+(1−c∞)/√N, with c∞ = mean/peak of an individual load | derived |
| 34 | **Diversified peak per occupied chalet** | **0.91** | **1.41** | **2.27** | kW | Row 22 × row 31 (profile method). Rusck cross-check: 0.88 / 1.18 / 2.09 kW. | derived |
| 35 | **Aggregate diversified chalet peak (hourly)** | **160** | **394** | **816** | kW | Row 34 × row 32 × row 1. Rusck cross-check: 155 / 331 / 752 kW. | derived |
| 36 | Aggregate peak if every chalet is occupied on a weekday-type winter evening | 213 | 602 | 971 | kW | N × daily kWh × 0.0607 | derived (stress case) |

---

## (b) Derivation notes

### 1. Daily energy on an occupied day

There is no Lebanese data for a 200 m² mountain chalet. I bracket it with Lebanese household data for the **top income quintile**, which is the closest proxy for owners of large chalets.

- **World Bank 2009, Table 2.4 (2008 survey).** The highest quintile used 755 kWh/month in "peak months" and 489 kWh/month in "off-peak months".
  - Converted: 755 × 12 / 365 = 24.8 kWh/day, and 489 × 12 / 365 = 16.1 kWh/day.
  - The report does not define peak and off-peak months. EDL bills bi-monthly, so whether these figures are monthly or bi-monthly should be checked in the full report.
  - The figures sit close to Houri & Ibrahim-Korfali's 6,907 kWh/yr (575 kWh/month average). That consistency supports reading them as monthly.
- **Base, winter: 24.8 kWh/day.** These are peak-month consumption levels. Nationally, 48% of households used some electricity for space heating (World Bank 2009, ¶19), so this value already contains a typical share of electric heating plus lighting and water heating. 75% of households heat water with electricity (World Bank 2009, ¶19).
- **Base, summer: 16.1 kWh/day.** At 1,735–1,975 m the summer cooling load is small. The off-peak-month level is therefore a better match than a coastal summer peak.
- **Base, shoulder: 18.9 kWh/day.** This is Houri's annual mean: 6,907 / 365.
- **High.**
  - Winter: 40 kWh/day, from Richa 2018 (1,200 kWh/month; weak source, author-collected bills). This represents chalets with substantial electric heating, for example heat-pump AC or oil-filled radiators in addition to a boiler.
  - Summer and shoulder: 24.8 kWh/day.
- **Low.** 16.1 kWh/day all year. This represents diesel central heating, a wood fireplace and gas cooking, with electricity used only for lighting, appliances and boiler auxiliaries.
- **Post-crisis check (Olleik et al. 2026, n=984, 2025 survey).**
  - The regression intercept is ≈14 kWh/day. Summer adds +11.5 and winter +6.3 kWh/day. Low-SES households use −8.9 kWh/day and medium-SES −4.2 kWh/day relative to the reference group, which is presumably high SES.
  - A high-SES winter day is therefore about 14 + 6.3 ≈ 20 kWh/day. That falls inside the Low–Base winter range above.
  - The summer coefficient reflects mostly coastal cooling, so it is not transferred to the chalets.
- **Floor area.** The brief gives 200–220 m². Olleik's room coefficient (+1.4 kWh/day per room) suggests a large chalet with 3–5 more rooms than an average apartment would use about 4–7 kWh/day more. This supports using top-quintile values rather than national means.
  - Mediterranean benchmarks are lower. The EU average is 3.6 MWh/dwelling/yr (Odyssee-Mure). Italian monitored households used 1.2–3.4 MWh/yr (Besagni et al. 2020, Table 7). Panayiotou et al. 2010 report on 500 Cypriot buildings, but electricity per dwelling is not in the abstract. Lebanese household use was already "similar to Western Europe" (Houri 2005), so these benchmarks are not used to scale up.

### 2. Heating and electric-heating share

The CAS 2004 National Survey of Household Living Conditions (IHSN catalogue LBN_2004_HLC_v01_M, 13,003 households) asked separately about the primary dwelling and the **secondary dwelling**. Counts below are unweighted sample counts; the catalogue warns they are not population estimates.

| Primary heating means | Primary dwellings (n=12,981) | Secondary dwellings (n=851) |
|---|---|---|
| Shared building central heating | 0.7% | 0.6% |
| Individual electric central heating | 2.0% | 1.3% |
| Electric non-central heaters | 15.1% | 6.8% |
| Individual gas-oil (diesel) central heating | 5.8% | 5.5% |
| Kerosene / gas-oil stove (sobia) | 29.2% | 12.6% |
| Gas (LPG) heater | 32.1% | 13.6% |
| Charcoal / firewood | 17.4% | 6.1% |
| Other | 0.3% | n/r |
| None | 8.2% | 48.1% |

Primary-dwelling categories sum above 100%, which implies multiple answers were allowed.

What the qualitative sources add:
- Wood use and diesel use rise with altitude. Households above about 700 m rely more on wood. Diesel heating is pronounced at higher altitude. (World Vision / Qualisus 2023, key-informant interviews; qualitative.)
- Diesel was the predominant heating fuel before 2019. Since the crisis, use has shifted toward wood because diesel became more expensive. (Same source.)

Taken together, a large chalet with "fireplaces and heating systems" most plausibly uses a diesel (mazout) boiler plus a wood fireplace. Electric heating is a minority option (about 8–17%), so it appears only in the High case.

The boiler burner, circulation pumps and controls draw typically a few hundred watts while firing. That auxiliary load is folded into the winter daily kWh and is not modelled separately.

### 3. Annual per-chalet energy

E = Σ_periods (days × occupancy × kWh/day of that season) + (365 − occupied days) × standby W × 24.

| Scenario | Occupied energy | Standby energy | Total | Equivalent rate |
|---|---|---|---|---|
| Base | 2,026 kWh | 264.5 d × 0.05 kW × 24 = 317 kWh | **2,344 kWh/yr** | ≈34% of a full-time urban household (6,907 kWh) |
| Low | 1,057 kWh | 216 kWh | **1,272 kWh/yr** | – |
| High | 4,706 kWh | 505 kWh | **5,212 kWh/yr** | – |

Aggregate energy is the per-chalet total × N:
- Low: 445 MWh/yr
- Base: 938 MWh/yr
- High: 2,085 MWh/yr

### 4. Diversified peak

**Primary method: profile.** The Spanish P2.0TD profile is the standardised load shape of millions of small residential customers, so it is already fully diversified.

1. Diversified hourly peak per occupied chalet = daily kWh × peak-hour share.
2. The peak-hour share is 0.0567 on a Saturday and 0.0607 on a weekday.
3. Aggregate = that value × occupied chalets on the design day.
4. The design day is a ski-season Saturday evening, with occupancy 0.5 / 0.7 / 0.9.

**Cross-check: Rusck coincidence factor** (Rusck 1956; restated by Fürst et al. 2020, Eq. 8):
- c(N) = c∞ + (1 − c∞)/√N
- c∞ is the mean-to-peak ratio of an individual load.
- Base:
  - mean = 24.8/24 = 1.03 kW; individual peak = 3.5 kW; c∞ = 0.295.
  - N = 280 occupied chalets gives c = 0.337.
  - Peak per chalet = 1.18 kW, aggregate = 331 kW.
- Low: c = 0.253 gives an aggregate of 155 kW.
- High (individual peak 9.7 kW): c = 0.215 gives an aggregate of 752 kW.

The two methods agree within about 15%. I recommend the **profile method** values (160 / 394 / 816 kW) because they are more conservative and consistent with the hourly LP formulation.

Two caveats:
- The hourly-average peak understates 15-minute peaks by a modest amount, which matters for inverter sizing. A margin of about 10–20% is suggested; this is an assumption.
- Stress case: 100% occupancy (for example New Year or a wartime refuge) on a weekday-shaped winter evening gives 602 kW in Base.

---

## (c) 24-h normalised load profiles (fraction of daily energy, sum = 1)

**Basis.** The profiles come from the official Spanish initial consumption profile P2.0TD for residential and small customers (≤15 kW) without hourly metering. Source: Resolución DGPEM of 23 Dec 2024, BOE-A-2024-27398, Annex III, profile for 2025. In that table, "Hora" h covers the clock interval (h−1, h]. Each day's 24 coefficients were normalised to a sum of 1.

- **Winter weekday:** Wednesday 15 January 2025.
- **Winter weekend:** Saturday 18 January 2025.
- **Cross-check:** Wednesday 17 Jan 2024 (BOE-A-2023-26634) has an almost identical shape, with peak hour 22.

**Clock adjustment.** Spain runs on CET while it lies geographically near UTC±0, so its clock-time evening peak (21–22 h) is about 1–1.5 h later relative to the sun than in Lebanon. JICA 2023 (p. 2-6) reports that Lebanon's system peak occurs in the lighting hours 18:00–21:00.

The "Lebanon-shifted" columns therefore move the Spanish shape **1 h earlier**. This is derived, and is the recommended version for the LP. Hour h means the interval h−1 to h, local time.

| Hour | Winter weekday (Spain, raw) | Winter weekend (Spain, raw) | **Winter weekday (shifted −1 h)** | **Winter weekend (shifted −1 h)** |
|---|---|---|---|---|
| 1 | 0.0364 | 0.0394 | 0.0301 | 0.0330 |
| 2 | 0.0301 | 0.0330 | 0.0267 | 0.0288 |
| 3 | 0.0267 | 0.0288 | 0.0249 | 0.0264 |
| 4 | 0.0249 | 0.0264 | 0.0243 | 0.0254 |
| 5 | 0.0243 | 0.0254 | 0.0251 | 0.0254 |
| 6 | 0.0251 | 0.0254 | 0.0288 | 0.0265 |
| 7 | 0.0288 | 0.0265 | 0.0365 | 0.0293 |
| 8 | 0.0365 | 0.0293 | 0.0400 | 0.0338 |
| 9 | 0.0400 | 0.0338 | 0.0419 | 0.0418 |
| 10 | 0.0419 | 0.0418 | 0.0437 | 0.0473 |
| 11 | 0.0437 | 0.0473 | 0.0436 | 0.0482 |
| 12 | 0.0436 | 0.0482 | 0.0442 | 0.0480 |
| 13 | 0.0442 | 0.0480 | 0.0468 | 0.0504 |
| 14 | 0.0468 | 0.0504 | 0.0481 | 0.0513 |
| 15 | 0.0481 | 0.0513 | 0.0458 | 0.0472 |
| 16 | 0.0458 | 0.0472 | 0.0438 | 0.0440 |
| 17 | 0.0438 | 0.0440 | 0.0445 | 0.0436 |
| 18 | 0.0445 | 0.0436 | 0.0498 | 0.0480 |
| 19 | 0.0498 | 0.0480 | 0.0557 | 0.0522 |
| 20 | 0.0557 | 0.0522 | 0.0602 | 0.0551 |
| 21 | 0.0602 | 0.0551 | **0.0607** | **0.0567** |
| 22 | **0.0607** | **0.0567** | 0.0540 | 0.0525 |
| 23 | 0.0540 | 0.0525 | 0.0445 | 0.0458 |
| 24 | 0.0445 | 0.0458 | 0.0364 | 0.0394 |

Shape statistics:
- Weekday: peak/mean 1.46, load factor 0.69.
- Weekend: peak/mean 1.36, load factor 0.74.

**Summer occupied-day profile: gap.** I could not extract the July rows of BOE Annex III; the web text is truncated after January and PDF parsing was blocked in this session. The recommended interim approach (assumed):
- Use the **same shifted weekend/weekday shapes for summer**. At 1,800 m there is essentially no cooling load, so the shape is driven by lighting, cooking and appliances, as in winter.
- Optionally flatten the evening peak by 1 h, since July sunset in Beirut is about 19:50 compared with about 17:00 in January. This option is an assumption.

To close the gap, copy Annex III rows for "Mes 7" (e.g. Wed 16 Jul and Sat 19 Jul 2025) from https://www.boe.es/diario_boe/txt.php?id=BOE-A-2024-27398. Alternatively, digitise Olleik et al. 2026 Fig. 12 / Appendix A, which gives Lebanese seasonal profiles by stratum. Note that the Spanish July shape contains an air-conditioning afternoon hump that should not be transferred to Faqra.

**Unoccupied chalet:** use a flat standby profile at the constant 30 / 50 / 100 W of row 25, i.e. 1/24 per hour.

---

## (d) Occupancy factors by period (fraction of chalets occupied on a day in that period)

Calendar, 365 days (assumed):
- **Ski season:** about 20 Dec to 31 Mar. Within it:
  - 40 weekend and holiday days (Saturdays and Sundays plus Christmas, New Year, Orthodox and Armenian Christmas, and Lebanese school breaks).
  - 62 weekdays.
- **Summer:** 1 Jul to 15 Sep, with 22 weekend days and 55 weekdays.
- **Shoulder:** April–June and mid-September to mid-December, with 53 weekend days and 133 weekdays.

| Period | Days | Low | Base | High | Season for kWh/day |
|---|---|---|---|---|---|
| Ski season, weekends & holidays | 40 | 0.50 | 0.70 | 0.90 | winter |
| Ski season, weekdays | 62 | 0.10 | 0.20 | 0.35 | winter |
| Summer, weekends | 22 | 0.50 | 0.70 | 0.90 | summer |
| Summer, weekdays | 55 | 0.30 | 0.45 | 0.65 | summer |
| Shoulder, weekends | 53 | 0.15 | 0.25 | 0.40 | shoulder |
| Shoulder, weekdays | 133 | 0.03 | 0.05 | 0.15 | shoulder |
| **Equivalent full-occupancy days/yr** | 365 | **65.6** | **100.5** | **154.4** | |

**Basis.**
- The factors are **assumed**, but the Base set is calibrated to the documented median occupancy of Alpine ski-resort second homes. Drouet 2025 reports 14–15.4 weeks/yr, about 98–108 days, including personal use, lending and rental. Base gives 100.5 days (14.4 weeks).
- Drouet 2025 also reports:
  - 54% of French owners stay between 2 weeks and 3 months.
  - About 13% never use the home themselves; 81% of those rent it out.
  - Stays of 6 months or longer are rare.
  - Owners living within 1 h are over-represented among those staying more than 3 months. Faqra is about 1 h from Beirut, which supports the High case.
- **Low** (≈66 days, 9.4 weeks) reflects reduced use or crisis-era absence.
- **High** (≈154 days, 22 weeks) reflects proximity to Beirut, remote work, and use as a refuge during the 2024 conflict. The last point is anecdotal in the press (L'Orient Today 2024, "eternal refuge for Lebanon's elite"); I could not open that article.
- The weekend-heavy shape is consistent with Lebanese ski-area reporting: hotels and guesthouses "fully booked on weekends" in the ski season, with minimal off-season interest (LBCI news). That source is not peer-reviewed.

For the LP, multiply the occupied-day profile × kWh/day × N × occupancy factor of each calendar day, and add N × (1 − factor) × standby load. Annual aggregate energy then reproduces row 29.

---

## (e) BibTeX

```bibtex
@article{Houri2005,
  author  = {Houri, Ahmad and Ibrahim-Korfali, Samira},
  title   = {Residential energy consumption patterns: the case of {Lebanon}},
  journal = {International Journal of Energy Research},
  volume  = {29}, number = {8}, pages = {755--766}, year = {2005},
  doi     = {10.1002/er.1086}
}
@techreport{WorldBank2009SIA,
  author      = {{World Bank}},
  title       = {Lebanon -- Social Impact Analysis: Electricity and Water Sectors},
  institution = {The World Bank}, address = {Washington, DC},
  number      = {Report No. 48993-LB}, year = {2009}, month = jun,
  url         = {http://hdl.handle.net/10986/18890},
  note        = {Table 2.4 and paras. 19, 27--28, 35, 37}
}
@techreport{WorldBank2020DPG,
  author      = {{World Bank}},
  title       = {Distributed Power Generation for {Lebanon}: Market Assessment and Policy Pathways},
  institution = {The World Bank}, address = {Washington, DC}, year = {2020},
  url         = {https://documents1.worldbank.org/curated/en/353531589865018948/pdf/Distributed-Power-Generation-for-Lebanon-Market-Assessment-and-Policy-Pathways.pdf},
  note        = {pp. 23--24, 30--31; Tables 3 and 8}
}
@techreport{HRW2023,
  author      = {{Human Rights Watch}},
  title       = {``Cut Off From Life Itself'': {Lebanon}'s Failure on the Right to Electricity},
  institution = {Human Rights Watch}, year = {2023}, month = mar,
  url         = {https://www.hrw.org/report/2023/03/09/cut-life-itself/lebanons-failure-right-electricity}
}
@misc{Olleik2026,
  author        = {Olleik, Majd and Dbouk, Haytham M. and Neumann, Anne and Bou Gebrael, Elsa and Zwickl-Bernhard, Sebastian},
  title         = {Household coping mechanisms under grid failure: Evidence from a high electrification context in {Lebanon}},
  year          = {2026}, eprint = {2606.17807}, archivePrefix = {arXiv},
  url           = {https://arxiv.org/abs/2606.17807}
}
@misc{Dbouk2025data,
  author    = {Dbouk, Haytham and Olleik, Majd and Farhat, Raghid and Bou Gebrael, Elsa},
  title     = {Survey on household electricity demand patterns in {Lebanon}},
  year      = {2025}, publisher = {Zenodo},
  doi       = {10.5281/zenodo.16906657}
}
@article{Dagher2023,
  author  = {Dagher, Leila and Jamali, Ibrahim and Abi Younes, Oussama},
  title   = {Extreme energy poverty: The aftermath of {Lebanon}'s economic collapse},
  journal = {Energy Policy}, volume = {183}, pages = {113783}, year = {2023},
  doi     = {10.1016/j.enpol.2023.113783},
  note    = {DOI inferred from Elsevier article-number pattern; verify}
}
@misc{CAS2004HLC,
  author       = {{Central Administration of Statistics (Lebanon)}},
  title        = {The National Survey of Household Living Conditions 2004, Multipurpose Survey},
  year         = {2005}, howpublished = {Microdata, IHSN Survey Catalog ID LBN\_2004\_HLC\_v01\_M},
  url          = {https://catalog.ihsn.org/catalog/8279},
  note         = {Variables rpd26--rpd34 (primary dwelling heating), rsd26--rsd34 (secondary dwelling heating), rs1}
}
@techreport{WorldVision2023,
  author      = {{Qualisus Consulting for World Vision Lebanon}},
  title       = {Winterisation Methods Report},
  institution = {World Vision}, year = {2023},
  url         = {https://www.wvi.org/sites/default/files/2023-11/Winterisation%20Methods%20Report_Final_0.pdf}
}
@mastersthesis{Richa2018,
  author = {Richa, Antoinette Abdo},
  title  = {Optimal Design of Hybrid Renewable Energy Systems in {Lebanon}},
  school = {American University of Beirut}, year = {2018},
  url    = {https://scholarworks.aub.edu.lb/bitstream/handle/10938/21332/et-6776.pdf}
}
@article{Drouet2025,
  author  = {Drouet, Quentin},
  title   = {The ``inhabitant footprints'' of second home owners in {Alpine} resort communities: anyone at home?},
  journal = {Geographica Helvetica}, volume = {80}, number = {4}, pages = {363--381}, year = {2025},
  doi     = {10.5194/gh-80-363-2025}
}
@misc{BOE2024profiles,
  author       = {{Direcci{\'o}n General de Pol{\'i}tica Energ{\'e}tica y Minas}},
  title        = {Resoluci{\'o}n de 23 de diciembre de 2024 por la que se aprueba el perfil de consumo y el m{\'e}todo de c{\'a}lculo a efectos de liquidaci{\'o}n de energ{\'i}a \ldots\ para el a{\~n}o 2025},
  howpublished = {Bolet{\'i}n Oficial del Estado, BOE-A-2024-27398, 30 Dec 2024, Annex III (profile P2.0TD)},
  year         = {2024},
  url          = {https://www.boe.es/diario_boe/txt.php?id=BOE-A-2024-27398}
}
@inproceedings{Furst2020,
  author    = {F{\"u}rst, Kristoffer and Chen, Peiyuan and Gu, Irene Yu-Hua and Tong, Lang},
  title     = {Improved peak load estimation from single and multiple consumer categories},
  booktitle = {CIRED 2020 Berlin Workshop},
  series    = {CIRED -- Open Access Proceedings Journal},
  pages     = {178--181}, year = {2020},
  doi       = {10.1049/oap-cired.2021.0300},
  note      = {Eq. 8 restates Rusck (1956) coincidence factor}
}
@article{Rusck1956,
  author  = {Rusck, S.},
  title   = {The simultaneous demand in distribution network supplying domestic consumers},
  journal = {ASEA Journal}, volume = {29}, pages = {59--61}, year = {1956},
  note    = {No DOI; cite via F{\"u}rst et al. 2020}
}
@article{LessWalker2026,
  author  = {Less, Brennan D. and Walker, Iain S.},
  title   = {Characterizing peak electricity demand for {U.S.} households: an assessment of end-use loads and demand factors},
  journal = {Applied Energy}, volume = {410}, pages = {127422}, year = {2026},
  doi     = {10.1016/j.apenergy.2026.127422}
}
@techreport{Meier2001,
  author      = {Meier, Alan K.},
  title       = {A worldwide review of standby power use in homes},
  institution = {Lawrence Berkeley National Laboratory}, number = {LBNL-49377}, year = {2001},
  url         = {https://www.osti.gov/biblio/795343}, note = {OSTI ID 795343}
}
@techreport{RossMeier2000,
  author      = {Ross, J. P. and Meier, Alan K.},
  title       = {Whole-House Measurements of Standby Power Consumption},
  institution = {Lawrence Berkeley National Laboratory}, number = {LBNL-45967}, year = {2000},
  url         = {https://standby.lbl.gov/publications/whole-house-measurements-standby}
}
@article{Besagni2020,
  author  = {Besagni, Giorgio and Premoli Vil{\`a}, Lidia and Borgarello, Marco},
  title   = {Italian Household Load Profiles: A Monitoring Campaign},
  journal = {Buildings}, volume = {10}, number = {12}, pages = {217}, year = {2020},
  doi     = {10.3390/buildings10120217}
}
@article{Panayiotou2010,
  author  = {Panayiotou, G. P. and Kalogirou, S. A. and Florides, G. A. and Maxoulis, C. N. and others},
  title   = {The characteristics and the energy behaviour of the residential building stock of {Cyprus} in view of {Directive} 2002/91/{EC}},
  journal = {Energy and Buildings}, volume = {42}, number = {11}, pages = {2083--2089}, year = {2010},
  doi     = {10.1016/j.enbuild.2010.06.018}
}
@techreport{JICA2023,
  author      = {{Japan International Cooperation Agency} and {NEWJEC Inc.} and {Kansai Transmission and Distribution}},
  title       = {Data Collection Survey on Electricity Sector in {Lebanon}: Final Report},
  institution = {JICA}, year = {2023}, month = nov,
  url         = {https://openjicareport.jica.go.jp/pdf/1000051515_01.pdf},
  note        = {p. 2-6: system peak in lighting hours 18:00--21:00}
}
@techreport{PudneyWhaley2018,
  author      = {Pudney, Peter and Whaley, David},
  title       = {After-diversity electricity demand of low energy households},
  institution = {CRC for Low Carbon Living, Project RP3017}, year = {2018},
  url         = {https://unisa.edu.au/siteassets/research/node-lcl/research-projects/published---rp3017-after-diversity-demand-report---final.pdf}
}
```

Optional sources in the BibTeX above:
- Panayiotou 2010, Besagni 2020 and Pudney & Whaley 2018 are context or benchmarks only. Pudney & Whaley report a measured ADMD of 2.2–2.9 kW per detached low-energy home in Adelaide, which sits above our 0.9–2.3 kW because those homes have AC.
- Dagher 2023 is context on energy poverty: 78% of households cannot keep warm (p. 4).

---

## (f) Gaps and cautions

1. **Faqra-specific facts.** These are unknown:
   - whether chalets are on the club network
   - their actual heating systems
   - their EDL or generator subscriptions
   - any metered data

   The chalet block is therefore reported separately, with and without.
2. **World Bank 2009 "peak / off-peak months" (Table 2.4).** The definition, and whether the values are monthly or bi-monthly, were not visible in the extracted text. Check pp. near Table 2.4 in the PDF.
3. **CAS 2004 heating shares.** These are unweighted sample counts from the microdata catalogue, from 2004, and not split by altitude. The UNDP/CAS *Living Conditions of Households 2007* report has Table 6-2 (main heating by governorate, p. 54) and Table 3-2 (built area, p. 48), but I could not extract those pages; the text is truncated online.
4. **No Lebanese per-m² electricity intensity** was found. Panayiotou 2010 (Cyprus) electricity per dwelling and per m² is in the full text only. Houri 2005 has area correlations, but only the abstract was readable; the Wiley PDF did not render as text.
5. **Summer profile.** The Spanish P2.0TD July rows were not extracted (see Section c). Lebanese measured profiles exist only as figures (Olleik 2026, Fig. 12 / Appendix A) or in the raw Zenodo survey (2 GB).
6. **Occupancy factors** are assumed and calibrated to Alpine data (Drouet 2025). No Lebanese second-home occupancy study was found. AUB has a thesis on Dhour Abadiyeh summer villas that may be worth checking: https://scholarworks.aub.edu.lb/items/db0eda9c-9722-4d64-b781-491d926e915c
7. **Coincidence factor.** The Rusck formula is documented, but no Lebanese or Mediterranean fitted c∞ was found. c∞ is derived from our own mean/peak assumptions. The profile method is preferred.
8. **Individual peak.** Base uses the 2008 top-quintile EDL subscription of 16.8 A. Luxury chalets may have 30–60 A three-phase connections; no source was found. High uses US data from Less & Walker 2026.
9. **Post-crisis behaviour.** Many households now have rooftop PV and batteries: 58% of the Olleik 2026 sample own PV. If the chalets have their own PV, net demand on the club network would be lower. Not modelled.
10. **DOI to verify.** Dagher 2023 (pattern-inferred).
