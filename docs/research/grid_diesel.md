# Grid (EDL) and diesel parameters for the Faqra Club PV + battery microgrid LP

Compiled 22 Nov 2026 for AUB EECE 675. Every number below has a source. Values marked **derived** are my own arithmetic on a cited number, and the method is given. Values marked **assumption** are modelling choices, not data. Exchange rate: 89,500 LL/$ (project convention). The MoEW generator-tariff tables and L'Orient Today use 89,700 LL/$, a 0.2% difference.

Companion data files, both in this folder:
- `edl_faqra_feeder_hourly.csv`: the hourly on/off record for the EDL **Faqra feeder (فقرا)** of the **Faitroun (فيطرون) substation**, Keserwan. 699 days from 2024-12-01 to 2026-10-31; 2025-05-10 is missing. Columns: date, h00…h23 (1 = energised), on_hours. Retrieved from EDL's public "Daily feeding" tool (https://edl.gov.lb/feeding.php, accessed 2026-11-22). I assume `timeN` means the clock hour N:00–N+1:00, local time; the tool does not state this.
- `edl_faqra_raw.txt`: the same data as interval strings, exactly as retrieved (`yymmdd:start-end,...`).

---

## Key finding: there is measured hourly EDL data for the Faqra feeder

EDL publishes hourly energisation records for each 20 kV outgoing feeder. Its July 2026 statement points the public to this tool; it says the data come from M3 smart meters (An-Nahar, 13 Jul 2026). The Faitroun substation has six feeders: Harajel, Ayoun el-Simane, **Faqra**, Faitroun–Achkout, **Kfardebian** and Mairouba. I pulled the full record for the Faqra feeder and the Kfardebian feeder. These are the closest available proxy for grid availability at Faqra Club. **Assumption:** the club is supplied from, or behind, this feeder; this has not been verified with EDL.

### Faqra feeder (EDL, Faitroun S/S): monthly statistics (derived from EDL data)

| Month | Mean h/day | Min | Median | Max | Mean on-blocks/day | Zero-supply days | Longest outage (h) |
|---|---|---|---|---|---|---|---|
| 2024-12 | 9.0 | 0 | 9 | 18 | 1.6 | 3 | 55 |
| 2025-01 | 10.5 | 0 | 10 | 22 | 1.4 | 4 | 39 |
| 2025-02 | 6.4 | 0 | 7 | 17 | 1.4 | 3 | 45 |
| 2025-03 | 8.6 | 0 | 10 | 22 | 1.0 | 6 | 102 |
| 2025-04 | 13.3 | 0 | 14 | 24 | 1.3 | 1 | 45 |
| 2025-05 | 14.1 | 3 | 14 | 24 | 1.8 | 0 | 32 |
| 2025-06 | 14.1 | 0 | 14 | 24 | 1.4 | 2 | 82 |
| 2025-07 | 11.4 | 4 | 12 | 19 | 2.3 | 0 | 23 |
| 2025-08 | 11.0 | 3 | 12 | 19 | 2.1 | 0 | 27 |
| 2025-09 | 14.6 | 1 | 14 | 22 | 2.2 | 0 | 23 |
| 2025-10 | 13.0 | 0 | 12 | 22 | 1.9 | 1 | 40 |
| 2025-11 | 11.7 | 0 | 10 | 24 | 1.3 | 1 | 46 |
| 2025-12 | 7.5 | 0 | 7 | 17 | 1.7 | 2 | 59 |
| 2026-01 | 7.9 | 0 | 7 | 23 | 1.5 | 5 | 69 |
| 2026-02 | 11.8 | 0 | 9 | 24 | 1.3 | 2 | 34 |
| 2026-03 | 10.5 | 0 | 9 | 24 | 1.3 | 4 | 73 |
| 2026-04 | 8.3 | 0 | 9 | 17 | 1.0 | 7 | 85 |
| 2026-05 | 6.2 | 0 | 6 | 17 | 0.9 | 10 | 70 |
| 2026-06 | 7.9 | 0 | 8 | 17 | 1.2 | 6 | 78 |
| 2026-07 | 5.1 | 0 | 3 | 16 | 1.0 | 7 | 86 |
| 2026-08 | 5.8 | 0 | 5 | 15 | 2.0 | 4 | 62 |
| 2026-09 | 5.5 | 0 | 6 | 14 | 1.8 | 4 | 50 |
| 2026-10 | 9.5 | 4 | 9 | 22 | 2.1 | 0 | 25 |

Summary statistics (derived):
- **Whole period:** mean **9.71 h/day**, an availability of 40.4%. Daily-hours percentiles: P10 = 0, P25 = 6, P50 = 9, P75 = 14, P90 = 18. There were 72 zero-supply days (10.3%) and 17 full 24-hour days.
- **By year:** Dec 2024–Nov 2025 averaged 11.5 h/day; Dec 2025–Oct 2026 averaged 7.8 h/day.
- **Ski season (Dec–Mar, n = 242 days):** mean **9.0 h/day**, median 8, P25 = 6, P75 = 12, P90 = 17. There were 29 zero days (12%).
- **Kfardebian feeder, same substation:** whole-period mean 10.4 h/day, with the same monthly pattern; for example Jul 2026 = 5.0 and Sep 2025 = 15.0. The two feeders' daily patterns differed on 343 of 699 days, so supply is switched feeder by feeder.
- **Outage durations:** continuous outages lasted a mean 11.5 h; P50 = 7 h, P90 = 24 h. In 23 months there were 92 outages of at least 24 h, 22 of at least 48 h, 7 of at least 72 h, and 1 of at least 96 h; the maximum was **102 h** (Mar 2025).
- **On-block durations:** mean 7.8 h; P10 = 2, P50 = 5, P90 = 17, maximum 44.

**Timing within the day (derived; % of days the feeder is energised at each clock hour)**

| Hour | 00 | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| All days | 41 | 43 | 46 | 50 | 52 | 52 | 51 | 52 | 52 | 48 | 48 | 46 | 42 | 40 | 30 | 29 | 28 | 27 | 29 | 29 | 29 | 34 | 35 | 37 |
| Dec–Mar | 37 | 38 | 40 | 47 | 50 | 52 | 50 | 50 | 48 | 48 | 47 | 45 | 35 | 31 | 25 | 26 | 26 | 23 | 22 | 24 | 27 | 36 | 37 | 37 |

Supply is concentrated between about 03:00 and 12:00. The afternoon and evening, 14:00–20:00, are the least supplied hours. That window coincides with the evening peak of a hospitality load and with zero PV output after about 16:30 in winter.

**Predictability (derived):**
- P(on at hour h | on at the same hour the previous day) = 0.38, against a base rate of 0.40. Day-to-day timing therefore carries essentially no information.
- At a 3-day lag the same probability rises to **0.53**, and the same-hour agreement is 0.65 versus 0.53 at a 1-day lag. Partial 3-day periodicity also shows at lag 6. This matches a **3-day rotating block schedule**, visible in Nov 2025 and Feb–Mar 2026. Typical sequence: Day A **00–08**, Day B **08–14 + 21–24**, Day C **00–24** (or 03–24). The rotation is interrupted often by zero days and irregular days, especially in crisis months.
- The most frequent whole-day patterns: none (72 days), 0–14 (21), 0–8 (21), 0–7 (20), 0–24 (17), 0–12 (15), 7–24 (10).
- This agrees with press reports that supply comes "at unpredictable times" (The National, 14 Oct 2026). EDL says it supplies all regions "in a fair and equal manner" and that it has not published any timetable (An-Nahar, 13 Aug 2026). I found no published hourly schedule for Keserwan; the feeder record above is the only hourly source.

### National and regional context, 2018–2026

| Date | EDL supply | Source |
|---|---|---|
| 2018 | Outages averaged 2.8 h/day in Beirut, **5.6 h/day in Mount Lebanon**, and over 10 h/day in Baalbek-Hermel and Akkar. Outages rise in summer and winter. | World Bank 2020, p. 12 and Fig. 2 |
| 2019–2023 | Supply fell to about 2 h/day after 2019. | Olleik et al. 2026, arXiv:2606.17807 |
| Mid-Aug 2024 | Near-total blackout: all thermal units off; "1–2 h in rotation" planned. | L'Orient Today, art. 1424333 |
| Dec 2024 | About 4–6 h/day, raised to 6–8 h/day for the holidays (+200 MW at Zahrani). | L'Orient Today, art. 1440942 |
| Jan 2025 | 9–10 h/day; minister targeted 12 h/day from March 2025. | LBCI, 24 Jan 2025 |
| End Feb 2026 | 7–9 h/day average. | Minister Saddi, via Libnanews 25 Aug 2026 |
| 13 Jul 2026 | About **4 h/day** average; ~500 MW available; 1,000 MW needed for grid stability. | EDL statement, An-Nahar 13 Jul 2026 |
| Aug 2026 | Some areas (Tripoli) at about 2 h/day. | Libnanews 25 Aug 2026 |
| 6 Sep 2026 | About 4 h/day; restarting Zouk and Jiyeh could add 2.5–3 h. | An-Nahar 6 Sep 2026 |

The Faqra feeder tracks these national swings: 13–15 h/day in spring–autumn 2025, and 5–6 h/day in Jul–Sep 2026.

### EDL tariff applicable to a resort on MV

Source: EDL notice of 6 Feb 2024, applied to bills from May 2023 onward (edl.gov.lb/news.php?nid=429; my translation):
- **Low-voltage subscribers:** 10 ¢/kWh for the first 100 kWh/month and 27 ¢/kWh above that, plus **25 ¢ per ampere** of subscribed capacity per month.
- **Former "exceptional" tariffs** (industrial, agricultural, **tourism**, places of worship): **27 ¢/kWh on all consumption**.
- **Private substations** (MV customers who own their transformer): **27 ¢/kWh on all consumption**. Subscription fee **$0.6 per kVA per month**, replacing $0.7 for supply stations and $1.05 for ordinary private substations. **Reactive energy: 10 ¢/kVArh** for kVArh above 75% of active consumption.
- The "rehabilitation fee" was abolished. It had been $4.3 or $8.6/month on LV and 17.5 ¢/kVA on private substations.
- The 20% mark-up on the Sayrafa rate was removed. Bills are converted at the BdL rate; VAT and stamp duty are added.
- **There is no time-of-use energy rate and no kW-based demand charge in the current MV tariff.** The only capacity charge is the $0.6/kVA/month subscription.

Before the reform, MV customers paid time-of-use rates. AUB's MV account in 2017 paid 5.3 ¢/kWh at night, 7.3 ¢ mid-day and 21.3 ¢ at peak (Chedid et al. 2020, Table 4). Those rates no longer apply.

Possible future increase:
- In Oct 2022 a rise to 37 ¢/kWh was floated if state bodies kept not paying (BusinessNews.com.lb, 10 Oct 2022).
- In Sept 2026 EDL put its production cost at about 35–37 ¢/kWh against the 27 ¢ tariff, and its board is studying a fuel-indexed tariff (An-Nahar 6 Sep 2026).
- Cabinet declined a variable tariff in Oct 2026 (LBCI, 2 Oct 2026).

### Private-generator (MoEW) tariff history (official monthly guidance; LL/kWh)

| Bills for | Standard | Above 700 m / rural (+10%) | $/kWh above 700 m @ 89,500 | Source |
|---|---|---|---|---|
| Jun 2024 | 31,725 | 34,897 | 0.39 | L'Orient Today 1418920 |
| Jan 2025 | 30,436 | 33,479 | 0.37 | L'Orient Today 1445726 |
| Jun 2025 | 31,634 | 34,797 | 0.39 | L'Orient Today 1467480 |
| Jan 2026 | 28,355 | 31,190 | 0.35 | L'Orient Today 1493337 |
| Feb 2026 | 30,244 | n/a | — | L'Orient Today 1546224 |
| Apr 2026 | 49,395 | (+10%) | 0.61 (derived) | L'Orient Today 1505310 |
| Jun 2026 | 41,973 | — | — | Libnanews 9 Sep 2026 |
| Jul 2026 | 40,746 | (+10%) | 0.50 (derived) | L'Orient Today 1542775 |
| Aug 2026 | 48,241 | (+10%) | 0.59 (derived) | L'Orient Today 1546224 |
| Sep 2026 | 52,840 | **58,124** | **0.65** | MoEW (given in brief) |
| ~Oct 2026 | "around 60 ¢ or more" | — | ≥0.66 (derived) | LBCI 2 Oct 2026 |

Fixed monthly fees in Aug 2026 were LL385,000 for 5 A, LL685,000 for 10 A, and LL300,000 per additional 5 A (L'Orient Today 1546224).

---

## (a) Parameter table

| Parameter | Low | Base | High | Unit | Source (short cite + page/table) | Status |
|---|---|---|---|---|---|---|
| EDL supply, Faqra feeder, monthly mean | 5.1 | 9.7 | 14.6 | h/day | EDL feeding data, Faitroun S/S, feeder فقرا, Dec 2024–Oct 2026. Low = Jul 2026, base = 699-day mean, high = Sep 2025. | Derived from official primary data |
| EDL supply, Faqra feeder, ski season Dec–Mar | 6.4 | 9.0 | 11.8 | h/day | Same data; monthly means Feb 2025 / season mean / Feb 2026 | Derived |
| EDL supply, national cross-check | 4 | 7–9 | 10 (12 target) | h/day | EDL 13 Jul 2026 (An-Nahar); Saddi Feb 2026 (Libnanews); LBCI 24 Jan 2025 | Official / press |
| Share of days with zero EDL supply | 0 (Oct 2026) | 10.3 (12 in Dec–Mar) | 32 (May 2026) | % of days | EDL feeder data | Derived |
| Longest continuous EDL outage | 24 (typical month) | 72 | 102 | h | EDL feeder data: 7 events ≥ 72 h and 1 ≥ 96 h in 23 months | Derived |
| EDL energy tariff, MV private substation or tourism | 0.27 | 0.27 | 0.37 | $/kWh | EDL notice 6 Feb 2024 (bills from May 2023). High = 37 ¢ escalation floated (BusinessNews 10 Oct 2022) ≈ EDL cost 35–37 ¢ (An-Nahar 6 Sep 2026). | Official (low/base); high is a scenario |
| EDL MV subscription (capacity) charge | 0.6 | 0.6 | 1.05 | $/kVA/month | EDL notice 6 Feb 2024. High = pre-2024 ordinary private-substation rate. | Official |
| EDL reactive-energy charge | 0.10 | 0.10 | 0.10 | $/kVArh above 0.75 × kWh | EDL notice 6 Feb 2024 | Official |
| EDL demand charge (per kW) | 0 | 0 | 0 | $/kW-month | EDL notice 6 Feb 2024: none exists | Official |
| EDL LV alternative | 0.10 / 0.27 | 0.27 marginal | — | $/kWh | EDL notice 6 Feb 2024, plus 0.25 $/A/month | Official |
| Private-generator tariff, above 700 m | 0.35 | 0.65 | 0.66 | $/kWh | Low: MoEW Jan 2026, 31,190 LL (L'Orient 1493337). Base: MoEW Sep 2026, 58,124 LL. High: "≈60 ¢ or more" standard × 1.1 (LBCI 2 Oct 2026). | Official / press; high derived |
| Diesel price (retail, MoEW weekly) | 0.80 | 1.41 | 1.52 | $/L | Low: mean of 12 dated points Sep 2023–Feb 2026 (range 0.715–0.978). Base: LL 2,524,000 per 20 L on 13 Nov 2026 (LBCI). High: LL 2,726,000 per 20 L on 2 Oct 2026 (LBCI). | Official prices via press; low derived |
| Fuel-curve intercept a (F = a·P_rated + b·P) | 0.005 | 0.017 | 0.081 | L/h per kW_rated | Datasheet fits (section c). High = literature/HOMER legacy value 0.08145 (also 0.08415 in Alramlawi et al. 2018). | Derived (base); literature (high) |
| Fuel-curve slope b | 0.225 | 0.242 | 0.255 | L/kWh | Datasheet fits (section c); HOMER 0.246 lies inside the range | Derived |
| Implied full-load specific fuel use (a + b) | 0.255 | 0.259 | 0.327 (HOMER) | L/kWh | Derived. Field check: World Bank 2020 Table 4 gives 3.2 kWh/L, i.e. 0.31 L/kWh, for a Lebanese 500 kVA neighbourhood set. | Derived |
| Minimum genset loading | — | 30 | — | % of rated | Cat white paper (Jabeck 2013); Richa 2018 thesis §B.3; Bou Gebrael et al. 2026 use a 30% fuel-curve breakpoint | Manufacturer / thesis |
| Genset variable O&M (non-fuel) | 0.010 | 0.0128 | 0.014 | $/kWh | Richa 2018 §B.3; World Bank 2020 Table 4 p. 25; Bou Gebrael et al. 2026 Table 7 | Published |
| Same, per operating hour (400 kWe set at 70% load) | 2.8 | 3.6 | 3.9 | $/h | Derived: O&M $/kWh × 280 kW | Derived |
| Genset fixed O&M | 9.3 | — | 84 | $/kW-yr | Marqusee et al. 2021 Table 3; Bou Gebrael et al. 2026 Table 7 | Published |
| Genset lifetime | 15,000 | 20,000 | 25,000 | operating h | World Bank 2020 p. 29; Richa 2018 §B.3. Base = midpoint. | Published; base is an assumption |
| Genset capital cost | 94 | 750 | 800 | $/kW | Low: World Bank 2020 Table 5, $37,500 for a 500 kVA set ÷ 400 kW, equipment and installation only (derived). Base: Marqusee et al. 2021 Table 3 (EDG $750/kW). High: Bou Gebrael et al. 2026 Table 7. | Published / derived |
| Diesel CO₂ emission factor | 2.64 | 2.68 | 2.70 | kg CO₂/L | Base: Richa 2018 (22.4 lb/gal); consistent with IPCC 2006 74,100 kg/TJ × 43.0 MJ/kg × 0.84 kg/L = 2.68 (derived). High: US EPA Hub 2025 Table 1/2, 10.21 kg/gal = 2.697. Low: implied by Tarnini 2023 Tables 5–6 (2,205,901 kg ÷ 835,176 L). | Official / derived |
| Diesel energy content | — | 10.0 (LHV) | 10.7 (HHV) | kWh/L | LHV: IPCC 2006 NCV 43.0 MJ/kg × 0.84 kg/L = 36.1 MJ/L (derived). HHV: EPA 2025, 0.138 MMBtu/gal = 38.5 MJ/L (derived). | Official / derived |
| Lebanese grid emission factor | 0.55 | 0.70 | 0.75 | kg CO₂/kWh | IFI Default Grid Factors v2.0 (Jul 2019): combined margin 552 (firm) / **697 (intermittent: use for PV)** g/kWh. High: Richa 2018 §B.2. Cross-check: BTR1 2024, 1,444 Gg CO₂ (1.A.1, 2022) ÷ 2,138 GWh EDL output = 0.68 (derived). | Official / derived |
| Exchange rate | — | 89,500 | 89,700 | LL/$ | Project convention; MoEW generator tables and L'Orient Today use 89,700 | — |

Notes on the table:
- The diesel price is the MoEW-set retail price for automotive diesel, quoted per 20 L. The MoEW generator-tariff tables use an almost identical "diesel can" price, e.g. LL 2,675,217 per 20 L in Sep 2026. Bulk delivered mazout for a resort may differ; there is no public price series for it.
- O&M, lifetime and capex are generic or literature values, not Lebanese vendor quotes.

### Diesel price points ($/L at 89,500 LL/$; derived from LL per 20 L)

| Date | LL/20 L | $/L | Source |
|---|---|---|---|
| 2023-07-14 | (70,950 LL/L) | 0.78 | WFP Logistics Cluster DLCA |
| 2023-09-22 | 1,750,000 | 0.978 | LBCI 724233 |
| 2024-01-19 | 1,476,000 | 0.825 | LBCI 748499 |
| 2024-03-19 | 1,548,000 | 0.865 | LBCI 760926 |
| 2024-08-20 | 1,404,000 | 0.784 | LBCI 790962 |
| 2024-12 | 1,370,383 | 0.766 | MoEW table via L'Orient 1445726 |
| 2025-01 | 1,409,783 | 0.788 | MoEW table via L'Orient 1445726 |
| 2025-02-28 | 1,382,000 | 0.772 | LBCI 840832 |
| 2025-06 | 1,477,750 | 0.826 | MoEW table via L'Orient 1467480 |
| 2025-08-22 | 1,319,000 | 0.737 | LBCI 874081 |
| 2025-12-23 | 1,280,000 | 0.715 | LBCI 896158 |
| 2026-01 | 1,292,237 | 0.722 | MoEW table via L'Orient 1493337 |
| 2026-02 (late) | 1,398,957 | 0.782 | MoEW via L'Orient 1549484 |
| 2026-03 (mid) | 2,122,000 | 1.185 | L'Orient 1499946 |
| 2026-04-14 | 2,495,000 | 1.394 | LBCI 924518 |
| 2026-07-24 | 2,209,000 | 1.234 | LBCI 948610 |
| 2026-08-21 | 2,399,000 | 1.340 | LBCI 953619 |
| 2026-09 | 2,675,217 | 1.495 | MoEW via L'Orient 1549484 |
| 2026-10-02 | 2,726,000 | 1.523 | LBCI 960821 |
| 2026-10-27 | 2,576,000 | 1.439 | LBCI 964911 |
| 2026-11-13 | 2,524,000 | 1.410 | LBCI 967760 |

The price was stable at about $0.72–0.98/L from 2023 to Feb 2026 (mean 0.80). From March 2026 it jumped to $1.2–1.5/L, after the regional war and the Hormuz disruption (L'Orient 1499946, 1541638). LBCI pages do not print the unit; LL per 20 L is the Lebanese convention and matches the MoEW figures.

---

## (b) Recommended outage scenarios for the LP, and their basis

The LP takes u_g(t) ∈ {0,1} as data. I recommend three layers.

**1. Empirical (preferred for annual or seasonal runs).** Use `edl_faqra_feeder_hourly.csv` directly as u_g(t). For the ski season use Dec 2024–Mar 2025 and Dec 2025–Mar 2026 (242 days, mean 9.0 h/day). For a full year, choose either Dec 2024–Nov 2025 (11.5 h/day) or Dec 2025–Oct 2026 (7.8 h/day, crisis year). For Monte Carlo, bootstrap whole days by month, or by 3-day block to keep the rotation.

**2. Representative deterministic days (for typical-day LPs).** This follows Chedid et al. 2020, who simulated four representative days per month so that each recurring blackout slot was covered, with the timing taken from observed data.

| Scenario | EDL hours | u_g = 1 during (local time) | Basis |
|---|---|---|---|
| E4-night | 4 | 00–04 | Crisis level: national ~4 h/day (EDL Jul 2026); Faqra Jul–Sep 2026 means 5.1–5.8 h, median 3–6 h |
| E4-day | 4 | 08–12 | Same level, alternate slot; 03–12 is the most-supplied window |
| E8-night (base) | 8 | 00–08 | Most frequent observed patterns 0–8 / 0–7 (41 days); ski-season median 8 h |
| E8-split | 9 | 08–14 and 21–24 | Observed Day-B pattern in the 3-day rotation (e.g. 9 Feb, 12 Feb, 6 Mar 2026) |
| E8-evening (stress) | 8 | 12–20 complement, i.e. on 00–04 and 20–24 | Worst case for the resort: no grid in the afternoon and evening ramp. 14–20 is supplied on only 22–27% of winter days. **Assumption** built on the hourly profile. |
| E12 | 12–14 | 00–12 (or 00–14) | Observed 0–12 (15 days) and 0–14 (21 days); Apr–Oct 2025 monthly means 13–15 h |
| R3 (3-day rotation) | 8 / 9 / 24, mean 13.7 | Day A 00–08; Day B 08–14 and 21–24; Day C 00–24 | Observed Nov 2025 and Feb–Mar 2026; lag-3 autocorrelation in the data |
| E0 | 0 | none | 10.3% of all days and 12% of winter days had zero supply |

**3. Multi-day outage (resilience and battery-sizing stress).**
- **O72:** 72 h with u_g = 0, placed in the peak-load week (e.g. a Christmas/New Year or February weekend). Basis: 7 outages of at least 72 h in 23 months, about 3.7 per year (derived).
- **O102:** 102 h, the longest observed, Mar 2025.
- National total-blackout precedent: Aug 2024, when all thermal units were shut for lack of fuel (L'Orient 1424333). EDL also warns that a general blackout is possible "at any time" when available generation is below about 1,000 MW (EDL 13 Jul 2026), or 450 MW (EDL 13 Aug 2026).

The data also give a random-timing option. If a stochastic formulation is wanted, block start times can be drawn from the empirical hourly profile above. Ouanes et al. 2025 is a methodological precedent: uniformly random start times and fixed-duration outages in chance-constrained dispatch. It is not a Lebanese study.

### How the literature represented Lebanese outages

| Study | Outage representation |
|---|---|
| **Chedid, Sawwas & Fares 2020**, *Energy* 200:117510 (AUB campus MV microgrid) | Measured 2017 EDL cut-off profile, deterministic (Tables 2–3). Most days had 3-h cut-offs: 252 days per year, plus 18 / 12 / 12 / 8 days with 4 / 5 / 6 / 7-h cut-offs. The cut-off occurred in one of four slots: 07–10, 10–13, 13–16 or 16–19. Sizing used 4 representative days per month to cover every slot. The day was split into an "active hours" window, from the first cut-off or peak-tariff hour to the last, solved by dynamic programming, and a "night hours" charging window solved by rules. TOU EDL tariff 0.053 / 0.073 / 0.213 $/kWh (Table 4). Diesel: FC(t) = ρ·P_DG(t) + τ·P_DG,rated (Eq. 3), the same linear form as this LP. Existing gensets supplied 35% of the 2017 load (Table 13). |
| **Chedid, Baydoun, Eid, Tarhini & Ghajar 2015**, ICCEP, pp. 134–139 (small industrial user) | The abstract only says the techno-economic analysis "accounts for the expected return to full supply", the government expansion plans and tariff rises. The full text (IEEE Xplore, PDF only) was not read; see Gaps. |
| **Richa 2018**, AUB M.E. thesis (advisor Karaki) | Deterministic scheduled pattern of "five outages every two days" (Fig. 5). 913 outages/yr: 548 of 4 h and 365 of 6 h, about 12 h/day of outage (derived). HOMER validation used a linear fuel curve (intercept 3.36 L/h, slope 0.251 L/h/kW). |
| **AUB M.E. thesis 2019** (advisor Chedid), community microgrids "under scheduled blackouts" | Scheduled (deterministic) blackouts with daily cost minimisation; hours not available from the abstract. |
| **Tarnini, Alsayed, El Ghaly & Chahine 2023**, *Sustainability* 15:7695 (BAU campus) | The grid was not modelled. Gensets were run as prime power because EDL gave "4 h each day" at best. The paper used a 20 L/h per 100 kVA rule of thumb and HOMER-library gensets. |
| **Bou Gebrael, Olleik & Zwickl-Bernhard 2026**, arXiv:2603.16893 | The grid was not modelled; the private generator operator sets the outage schedule. Fuel curve is piecewise with breakpoints at 30% and 60% of capacity. |
| **Alramlawi et al. 2018**, IEEE EEEIC (PV–battery–diesel MG under scheduled blackouts; motivated by countries such as Lebanon, but no site named) | Deterministic periodic blackout: 8 h blackout in a 16 h on-off cycle, binary α_g(t). F = 0.246·P + 0.08415·P_n (L/h), diesel $1.5/L, 500 kVA DG. |
| **"Decision Analysis Framework for Decentralized HRES in Lebanon under uncertainty of grid existence and tariff prices"** (AUB ScholarWorks) | Stochastic versus deterministic treatment of whether and when the grid exists, i.e. long-term availability, not hourly timing. |
| **World Bank 2020**, *Distributed Power Generation for Lebanon* | Regional average outage hours for 2018 (no hourly timing) and seasonal increases in summer and winter. |

The common practice in these studies is to use deterministic blocks drawn from measured or announced schedules, picking representative days to cover the timing slots. None of the Lebanese papers I found used a stochastic hourly timing model. The 2024–2026 Faqra feeder data now show irregular block timing: weak day-to-day correlation, only a partial 3-day rotation, and 10% zero days. That argues for (i) several timing variants per supply level and (ii) a multi-day outage case, rather than one fixed daily block.

---

## (c) Genset fuel-curve fit (prime ratings, manufacturer datasheets)

Fit per unit: F/P_rated = a + b·(P/P_rated), least squares over the datasheet points (script `../fit_fuel.py`, derived).

| Genset (50 Hz unless noted) | P_rated, prime (kWe) | 25% (L/h) | 50% (L/h) | 75% (L/h) | 100% (L/h) | a (L/h/kW_r) | b (L/kWh) | R² |
|---|---|---|---|---|---|---|---|---|
| Cummins C275 D5, QSL9-G5, 250 kVA prime; DS22-CPGK RevD (2012) | 200 | 14.2 | 25.8 | 38.3 | 52.5 | 0.0042 | 0.2548 | 0.998 |
| Cummins C500 D5, QSZ13-G5, 455 kVA prime; EMERD-5935-EN (08/17) | 364 | 32.9 | 51.6 | 71.9 | 94.3 | 0.0317 | 0.2247 | 0.998 |
| Cummins C550 D5e, QSX15-G8, 500 kVA prime; SS11-CPGK (©2010) | 400 | 33.36 | 57.37 | 80.61 | 104.24 | 0.0248 | 0.2359 | 1.000 |
| Caterpillar DE550E0, C15, 500 kVA prime; LEHE1638-00 (©2017), perf. DM8494 | 400 | 32.7 | 54.0 | 76.2 | 102.0 | 0.0217 | 0.2301 | 0.998 |
| Caterpillar DE850E0, C18, 770 kVA prime; LEHE1817-02 (10/18) | 616 | 44 | 80 | 118 | 162 | 0.0049 | 0.2545 | 0.998 |
| Perkins 2506C-E15TAG2 engine, 500 kVA / 400 kWe typical prime; Pub. 1846/04/09 (©2006) | 400 | — | 55 | 81 | 106 | 0.0104 | 0.2550 | 1.000 |
| **Pooled (all points)** | | | | | | **0.0168** | **0.2419** | |

FG Wilson P550-3, which uses the Perkins 2506A-E15TAG2 engine and is rated 500 kVA / 400 kWe prime, lists 97.2 L/h at 100% prime only (FG Wilson range table, hellopro). That gives 0.243 L/kWh, consistent with the fit.

Comparison with the HOMER default (a = 0.08145, b = 0.246) on specific fuel use (L/kWh) at 25 / 50 / 75 / 100% load:
- Pooled datasheet fit: 0.309 / 0.276 / 0.264 / 0.259.
- HOMER default: 0.572 / 0.409 / 0.355 / 0.327.

The slopes agree within 2%. The HOMER intercept is about 5 times the datasheet intercept, so HOMER overstates part-load consumption: +85% at 25% load and +26% at full load. Modern 250–800 kVA prime sets are close to proportional, with a/(a+b) ≈ 2–12%.

**Recommendation for the LP:**
- Base: a = 0.017 L/h/kW_rated, b = 0.242 L/kWh.
- Sensitivity on a: from 0.005 (best datasheet) up to 0.081 (HOMER/legacy). The high value also stands in for real-world degradation. The World Bank's Lebanese field figure of 0.31 L/kWh at about 85% load (Table 4; p. 30 fn. 45: 88 L/h at 85% load of a 500 kVA set) is about 20% above datasheet values.

Caveats:
- Datasheet figures are at ISO/reference conditions, near sea level and 25 °C. At 1,735–1,975 m, available power is derated. The derate figures were not collected (see Gaps); in the LP, reduce P_rated rather than changing a and b.
- Fuel-consumption tolerance is typically ±5% on these sheets.

The pooled sample covers 250–770 kVA prime ratings from three makers.

---

## (d) BibTeX

```bibtex
@article{Chedid2020Energy,
  author  = {Chedid, Riad and Sawwas, Ahmad and Fares, Dima},
  title   = {Optimal design of a university campus micro-grid operating under unreliable grid considering {PV} and battery storage},
  journal = {Energy}, volume = {200}, pages = {117510}, year = {2020},
  doi     = {10.1016/j.energy.2020.117510}, note = {Tables 2--5, 13; Eq. (3)}
}
@inproceedings{Chedid2015ICCEP,
  author    = {Chedid, R. and Baydoun, I. and Eid, S. and Tarhini, S. and Ghajar, R.},
  title     = {Techno-economic analysis of a {PV} generator operating in a hybrid diesel-unreliable grid system},
  booktitle = {2015 International Conference on Clean Electrical Power (ICCEP)},
  pages     = {134--139}, year = {2015}, publisher = {IEEE},
  doi       = {10.1109/ICCEP.2015.7177613}
}
@article{Tarnini2023,
  author  = {Tarnini, Mohamad and Alsayed, Mohammad and El Ghaly, Abdallah and Chahine, Khaled},
  title   = {Towards Energy Sustainability in University Campuses: A Case Study of {Beirut Arab University}},
  journal = {Sustainability}, volume = {15}, number = {9}, pages = {7695}, year = {2023},
  doi     = {10.3390/su15097695}
}
@mastersthesis{Richa2018,
  author = {Richa, Antoinette Abdo},
  title  = {Optimal Design of Hybrid Renewable Energy Systems in {Lebanon}},
  school = {American University of Beirut, Dept. of Electrical and Computer Engineering},
  year   = {2018}, note = {Advisor S. Karaki; ET:6776},
  url    = {https://scholarworks.aub.edu.lb/bitstream/handle/10938/21332/et-6776.pdf}
}
@mastersthesis{AUB2019CommunityMG,
  author = {{AUB ECE M.E. thesis (author not listed on record)}},
  title  = {Optimal Configuration and Energy Dispatch Strategies of Power Sources in Community Microgrid Under Scheduled Blackouts},
  school = {American University of Beirut}, year = {2019}, note = {Advisor R. Chedid},
  url    = {https://scholarworks.aub.edu.lb/items/8fa86287-0b41-48e7-be22-eac766b4c38f}
}
@misc{AUBDecisionAnalysisHRES,
  title = {Decision Analysis Framework for Decentralized Hybrid Renewable Energy Systems in {Lebanon} Under the Uncertainty of Grid Existence and Tariff Prices},
  howpublished = {AUB ScholarWorks record (authors/year not listed on record)},
  url = {https://scholarworks.aub.edu.lb/items/09a938fc-d570-4261-a5c7-9a090b0d6b25}
}
@inproceedings{Alramlawi2018,
  author    = {Alramlawi, Mansour and Gabash, Aouss and Mohagheghi, Erfan and Li, Pu},
  title     = {Optimal Operation of {PV}-Battery-Diesel MicroGrid for Industrial Loads Under Grid Blackouts},
  booktitle = {18th IEEE Int. Conf. on Environment and Electrical Engineering (EEEIC)},
  address   = {Palermo, Italy}, year = {2018}, eprint = {1807.05753}, archivePrefix = {arXiv},
  url       = {https://arxiv.org/abs/1807.05753}
}
@misc{BouGebrael2026,
  author = {Bou Gebrael, E. and Olleik, M. and Zwickl-Bernhard, S.},
  title  = {Cleaner energy microgrids under market power and limited regulation in developing countries},
  year   = {2026}, eprint = {2603.16893}, archivePrefix = {arXiv},
  url    = {https://arxiv.org/abs/2603.16893}, note = {Tables 2, 3, 7}
}
@misc{Olleik2026,
  author = {Olleik, M. and Dbouk, H. M. and Neumann, A. and Bou Gebrael, E. and Zwickl-Bernhard, S.},
  title  = {Household coping mechanisms under grid failure: Evidence from a high electrification context in {Lebanon}},
  year   = {2026}, eprint = {2606.17807}, archivePrefix = {arXiv},
  url    = {https://arxiv.org/abs/2606.17807}
}
@article{Ouanes2025,
  author  = {Ouanes, N. and Gonz{\'a}lez Grand{\'o}n, T. and Heitsch, H. and Henrion, R.},
  title   = {Optimizing the economic dispatch of weakly-connected mini-grids under uncertainty using joint chance constraints},
  journal = {Annals of Operations Research}, volume = {344}, pages = {499--531}, year = {2025},
  doi     = {10.1007/s10479-024-06287-9}
}
@article{Marqusee2021,
  author  = {Marqusee, Jeffrey and Becker, William and Ericson, Sean},
  title   = {Resilience and economics of microgrids with {PV}, battery storage, and networked diesel generators},
  journal = {Advances in Applied Energy}, volume = {3}, pages = {100049}, year = {2021},
  doi     = {10.1016/j.adapen.2021.100049}, note = {Table 3: EDG capital 750 \$/kW, fixed O\&M 9.3 \$/kW/yr}
}
@techreport{WorldBank2020DPG,
  author      = {{World Bank}},
  title       = {Distributed Power Generation for {Lebanon}: Market Assessment and Policy Pathways},
  institution = {World Bank, ESMAP}, year = {2020},
  url         = {https://documents1.worldbank.org/curated/en/353531589865018948/pdf/Distributed-Power-Generation-for-Lebanon-Market-Assessment-and-Policy-Pathways.pdf},
  note        = {p. 12 and Fig. 2 (regional outages); Tables 4--7, pp. 25--30 (genset costs)}
}
@misc{EDLFeeding2026,
  author       = {{{\'E}lectricit{\'e} du Liban}},
  title        = {Daily feeding (\textarabic{التغذية اليومية}) -- Faitroun substation, feeders Faqra and Kfardebian, 2024-12-01 to 2026-10-31},
  howpublished = {Online database},
  url          = {https://edl.gov.lb/feeding.php}, note = {Accessed 2026-11-22}
}
@misc{EDLTariff2024,
  author = {{{\'E}lectricit{\'e} du Liban}},
  title  = {Calculation of electricity bills for issues from May 2023 onward (Arabic notice, Beirut, 6 Feb 2024)},
  year   = {2024}, url = {https://edl.gov.lb/news.php?nid=429}
}
@misc{MoEW2022Plan,
  author = {{Ministry of Energy and Water and {\'E}lectricit{\'e} du Liban}},
  title  = {Setting {Lebanon}'s Electricity Sector on a Financially Sustainable Growth Path},
  year   = {2022}, month = mar,
  url    = {https://energyandwater.gov.lb/mediafiles/articles/doc-100777-2022_03_31_10_19_47.pdf}
}
@misc{IFI2019,
  author = {{IFI Technical Working Group on GHG Accounting}},
  title  = {The {IFI} Dataset of Default Grid Factors v.2.0},
  year   = {2019}, month = jul,
  url    = {https://unfccc.int/sites/default/files/resource/Harmonized_Grid_Emission_factor_data_set.pdf}
}
@techreport{LebanonBTR1,
  author      = {{Ministry of Environment, Lebanon / UNDP}},
  title       = {Lebanon's First Biennial Transparency Report ({BTR1}) on Climate Change},
  institution = {MoE/UNDP/GEF}, year = {2024},
  url         = {https://unfccc.int/sites/default/files/resource/CC%20Lebanon%20BTR%20-%20Final.pdf},
  note        = {p. 25 (EDL 2,138 GWh in 2022); p. 27 Table 1 (1.A.1 = 1,444.16 Gg CO2)}
}
@misc{EPA2025Hub,
  author = {{U.S. Environmental Protection Agency}},
  title  = {{GHG} Emission Factors Hub 2025},
  year   = {2025},
  url    = {https://www.epa.gov/system/files/documents/2025-01/ghg-emission-factors-hub-2025.pdf},
  note   = {Table 1: Distillate Fuel Oil No. 2, 0.138 MMBtu/gal, 10.21 kg CO2/gal}
}
@incollection{IPCC2006Vol2Ch1,
  author    = {Gómez, D. R. and Watterson, J. D. and others},
  title     = {Chapter 1: Introduction},
  booktitle = {2006 {IPCC} Guidelines for National Greenhouse Gas Inventories, Vol. 2: Energy},
  publisher = {IGES}, year = {2006},
  url       = {https://www.ipcc-nggip.iges.or.jp/public/2006gl/vol2.html},
  note      = {Table 1.2 NCV gas/diesel oil 43.0 TJ/Gg; Table 1.4 CO2 74,100 kg/TJ}
}
@misc{Jabeck2013Cat,
  author = {Jabeck, Brian},
  title  = {The Impact of Generator Set Underloading},
  howpublished = {Caterpillar Electric Power white paper}, year = {2013}, month = oct,
  url    = {https://www.cat.com/en_US/by-industry/electric-power/Articles/White-papers/the-impact-of-generator-set-underloading.html}
}
@misc{CumminsC275D5,  title = {C275 D5 Diesel Generator Set Data Sheet, DS22-CPGK Rev D}, author = {{Cummins Power Generation}}, year = {2012}, url = {https://www.taranispower.com.au/wp-content/uploads/2020/08/C275-D5.pdf}}
@misc{CumminsC500D5,  title = {C500 D5 Data Sheet, EMERD-5935-EN}, author = {{Cummins Inc.}}, year = {2017}, url = {https://yorpower.com/wp-content/uploads/2025/07/C500D5.pdf}}
@misc{CumminsC550D5e, title = {C550 D5e Data Sheet, SS11-CPGK}, author = {{Cummins Power Generation}}, year = {2010}, url = {https://cdn.shopify.com/s/files/1/0531/1715/7528/files/C550-D5E-Cummins-Generator-Datasheet.pdf}}
@misc{CumminsC700D5,  title = {C700 D5 Data Sheet, EA-S-CC-20 V2}, author = {{Cummins Power Generation}}, year = {2012}, url = {https://cdn.shopify.com/s/files/1/0531/1715/7528/files/C700-D5-Cummins-Generator-Datasheet.pdf}, note = {100\% load only: 140 L/h prime at 512 kWe}}
@misc{CatDE550E0, title = {Cat C15 Diesel Generator Sets DE550E0, LEHE1638-00}, author = {{Caterpillar}}, year = {2017}, url = {https://www.hampshiregenerators.co.uk/wp-content/uploads/2023/08/CAT-DE550E0-550kVA-Diesel-Generator.pdf}}
@misc{CatDE850E0, title = {Cat C18 Diesel Generator Set DE850E0, LEHE1817-02}, author = {{Caterpillar}}, year = {2018}, url = {https://cdn.shopify.com/s/files/1/0083/3581/8788/files/C18.pdf}}
@misc{Perkins2506C, title = {2506C-E15TAG2 ElectropaK, Publication 1846/04/09}, author = {{Perkins Engines Company Ltd.}}, year = {2006}, url = {https://cdn.shopify.com/s/files/1/0531/1715/7528/files/2506C-E15TAG2_ElectropaK.pdf}}
@misc{FGWilsonRange, title = {{FG Wilson} diesel generator set range (ratings and fuel consumption at 100\% load)}, author = {{FG Wilson}}, url = {https://hellopro.fr//documentation/pdf_prod/2/7/5/2889971_a156157cd75f67392de1d62057f29f41_11336572.pdf}}
@misc{AnNahar20260713, author = {{An-Nahar}}, title = {{EDL} presents the reality of electricity supply and operational challenges (Arabic)}, year = {2026}, month = jul, note = {13 Jul 2026}, url = {https://www.annahar.com/lebanon/329444}}
@misc{AnNahar20260813, author = {{An-Nahar}}, title = {{EDL}: no discrimination in supply between regions (Arabic)}, year = {2026}, month = aug, note = {13 Aug 2026}, url = {https://www.annahar.com/lebanon/338332}}
@misc{AnNahar20260906, author = {{An-Nahar}}, title = {Fuel tanker awaits letter of credit; {EDL} towards raising tariff (Arabic)}, year = {2026}, month = sep, note = {6 Sep 2026}, url = {https://www.annahar.com/economy/344770}}
@misc{Libnanews20260825, author = {{Libnanews}}, title = {Electricity from {Lebanon} hit by oil shock}, year = {2026}, note = {25 Aug 2026}, url = {https://en.libnanews.com/l-electricity-from-lebanon-hit-by-oil-shock/}}
@misc{Libnanews20260909, author = {{Libnanews}}, title = {Electricity in {Lebanon}: promises against cuts}, year = {2026}, note = {9 Sep 2026}, url = {https://en.libnanews.com/electricity-in-lebanon-promises-against-cuts/}}
@misc{LBCI20250124, author = {{LBCI}}, title = {Energy Minister Walid Fayad: Lebanon to receive 12 hours of electricity}, year = {2025}, note = {24 Jan 2025}, url = {https://www.lbcgroup.tv/news/lebanon-news/833176/}}
@misc{LBCI20261002, author = {{LBCI}}, title = {{Lebanon}'s electricity tariff dilemma: pay more to {EDL} or pay more to generators?}, year = {2026}, note = {2 Oct 2026}, url = {https://www.lbcgroup.tv/news/news-bulletin-reports/960902/}}
@misc{TheNational20261014, author = {{The National}}, title = {Lebanon's power failure: diesel generators, \$300-a-month bills}, year = {2026}, note = {14 Oct 2026}, url = {https://www.thenationalnews.com/news/mena/2026/10/14/wake-up-and-smell-the-diesel-multibillion-dollar-generators-industry-fuelling-lebanons-corruption/}}
@misc{BusinessNews2022, author = {{BusinessNews.com.lb}}, title = {State electricity price raised to 27 cents/kWh}, year = {2022}, note = {10 Oct 2022}, url = {https://www.businessnews.com.lb/cms/Story/StoryDetails/11137/}}
@misc{LOrient1424333, author = {{L'Orient Today}}, title = {Near-total blackout by {EDL}: what to expect in the coming days}, year = {2024}, url = {https://today.lorientlejour.com/article/1424333/}}
@misc{LOrient1440942, author = {{L'Orient Today}}, title = {{EDL} announces it will supply 6 to 8 hours of power per day during holiday season}, year = {2024}, url = {https://today.lorientlejour.com/article/1440942/}}
@misc{LOrientGenTariffs, author = {{L'Orient Today}}, title = {Monthly generator tariff reports (articles 1418920, 1445726, 1467480, 1493337, 1505310, 1542775, 1546224)}, year = {2024--2026}, url = {https://today.lorientlejour.com/article/1546224/}}
@misc{LOrient1549484, author = {{L'Orient Today}}, title = {In numbers: {Lebanon}'s diesel prices nearly doubled since late February}, year = {2026}, url = {https://today.lorientlejour.com/article/1549484/}}
@misc{LOrient1499946, author = {{L'Orient Today}}, title = {Gasoline up more than 25\% since start of war in {Lebanon}, diesel up 50\%}, year = {2026}, url = {https://today.lorientlejour.com/article/1499946/}}
@misc{LBCIfuel, author = {{LBCI}}, title = {Weekly fuel price updates (articles 724233, 748499, 760926, 790962, 840832, 874081, 896158, 924518, 948610, 953619, 960821, 964911, 967760)}, year = {2023--2026}, url = {https://www.lbcgroup.tv/news/economy/967760/lebanons-fuel-prices-fall/en}}
@misc{WFPDLCA2023, author = {{WFP Logistics Cluster}}, title = {{Lebanon} Logistics Capacity Assessment: Fuel Overview}, year = {2023}, url = {https://dlca.logcluster.org/node/1692}, note = {diesel 70,950 LBP/L = 0.78 USD/L, 14 Jul 2023}}
```

---

## (e) Gaps and caveats

1. **Feeder-to-site mapping is not verified.** I assume Faqra Club is on the EDL "Faqra" 20 kV feeder of Faitroun S/S. The club may have a dedicated MV connection or sit on another feeder. Ask EDL's Jounieh/Keserwan office, or check the club's meter, before relying on the series. The data record feeder energisation at the substation outlet; downstream faults (e.g. snow and ice on overhead lines) are not captured.
2. **The meaning of `time0…time23` is inferred** (clock hour, local time). EDL's tool does not document it. 2025-05-10 is missing, and 12 duplicated dates were dropped; one of them had conflicting values, and the first record was kept.
3. **Chedid et al. 2015 (ICCEP):** the full text is a PDF on IEEE Xplore and was not opened, because PDFs were not downloaded. Its outage representation is known only from the abstract.
4. **EDL Cost Recovery Plan Addendum (Dec 2025)** is a PDF on edl.gov.lb and was not read. It may contain the proposed fuel-indexed tariff. No new tariff had been adopted by Nov 2026 (LBCI 2 Oct 2026; Libnanews 20 Nov 2026).
5. **No published hourly EDL timetable for Keserwan or Mount Lebanon** was found. EDL says it rations "equally" and publishes only after-the-fact meter data.
6. **HOMER default 0.08145 / 0.246:** current HOMER Pro documentation gives no default values; it shows only worked examples. Some literature gives the intercept as 0.08415 (e.g. Alramlawi et al. 2018), others as 0.08145. The original source, often attributed to Skarstein & Uhlen (1989), was not verified.
7. **Altitude and temperature derating** of gensets at about 1,800–2,000 m was not collected; each datasheet's derate curve applies. Cold-climate performance was not checked either.
8. **Genset capex is not Lebanon-specific for 2026.** The World Bank figure (2020) covers equipment only for a 500 kVA set; the $750–800/kW figures are installed costs from US and Lebanese modelling studies. No 2026 Lebanese vendor quotes were found.
9. **Bulk or wholesale diesel for commercial delivery:** there is no public series. Retail MoEW prices are used as a proxy. Monthly MoEW price bulletins were not available directly from energyandwater.gov.lb; prices are taken from press reports of the bulletins.
10. **Grid emission factor:** the IFI v2.0 dataset dates from Jul 2019, before the crisis. Lebanon's BTR1 publishes no grid EF; 0.68 is my derivation. With EDL running mostly on diesel/HFO and private gensets at the margin, the effective marginal EF for displaced grid power is likely close to the diesel genset value: about 2.68 kg/L × 0.26–0.31 L/kWh = 0.70–0.83 kg/kWh (derived).
11. Lebanese VAT and stamp duty on EDL bills are not quantified here.
