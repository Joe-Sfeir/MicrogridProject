# Faqra Club ski lifts: electrical demand parameters

Scope: the four Faqra lifts (T1 to T4). Every value below is either taken from a cited source (**verified**), computed from cited inputs with the steps shown (**derived**), or chosen where nothing was found (**assumed**, with the reason given). Calculation scripts are in `tools/research/lifts.py` and `tools/research/energy.py`.

## 0. What is published about the Faqra lifts

| Lift | Type | Length | Base / top (m) | Vertical rise H | Speed | Capacity | Source |
|---|---|---|---|---|---|---|---|
| T1 | 2-seat fixed-grip chairlift | 880 m | 1,735 / 1,975 | **240 m** | 2.10 m/s (about 7 min 40 s ride) | 1,200 p/h | skiresort.com lift page l112103 |
| T2 | T-bar | 540 m | 1,835 / 1,975 | **140 m** | 2.50 m/s (about 4 min) | 1,000 p/h | skiresort.com l112104 |
| T3 | J-bar | 410 m | 1,800 / 1,950 | **150 m** | 2.50 m/s (about 3 min) | 600 p/h | skiresort.com l112105 |
| T4 | Low rope tow (baby lift) | 230 m | 1,735 / 1,765 | **30 m** | 1.50 m/s (about 2 min 50 s) | 350 p/h | skiresort.com l112106 |

- **Not found anywhere:** the manufacturer, build year, drive type and motor kW of any Faqra lift. skiresort.com leaves these fields empty. lift-world.info has no Faqra entry; its Lebanon page covers only Mzaar Kfardebian, with 14 chairlifts built by Poma and Montaz Mautino between 1993 and 2014 (one is a second-hand 1995 Poma 2-CLF, "Rocher": 750 m, 196 m rise, 1,200 p/h, 2.5 m/s). No kW figures are given for any Lebanese lift. Quality: skiresort.com and lift-world.info are enthusiast and commercial databases, not official, but their figures are internally consistent (for example, length divided by speed matches the stated ride time).
- The terrain-model H_i values can be checked against the skiresort.com rises above. Note that T1 (1,735 to 1,975 m) spans the full 1,735 to 1,975 m resort range given in the brief.
- Vanat (2025, p. 225): Faqra "is a private ski club, meaning the club owns the land, the 4 lifts and all other facilities".

## (a) Parameter table

Scenario logic: "low" combines all the low-energy choices and "high" all the high-energy ones, so together they bracket the result.

| Parameter | Low | Base | High | Unit | Source (short cite + location) | Status |
|---|---|---|---|---|---|---|
| H, vertical rise T1/T2/T3/T4 | 240/140/150/30 | 240/140/150/30 | 240/140/150/30 | m | skiresort.com lift pages | verified (database) |
| Design passenger mass m | 75 | 80 | 85 | kg | 80 kg: Austrian Schleppliftrichtlinien 1999 §4.5.1a; Szlosarek 2019 §5 | base verified; ±5 assumed |
| Ski-track friction coefficient (surface lifts) μ_t | 0.06 | 0.12 | 0.12 | – | 0.12: Schleppliftrichtlinien §4.5.1b ("Reibwert in der Schleppspur") | base verified (design value); low assumed |
| Drive efficiency η (motor + inverter + gearbox) | 0.95 | 0.90 | 0.85 | – | 0.90: Szlosarek 2019 §4 (from Zegg 2010); 0.95: Leitner 2023 pp. 4–5 (DirectDrive) | verified / derived |
| **P_rated T1** (2-seat fixed-grip chair) | 110 | 150 | 160 | kW | derived: 62.8 kW × (1.77 / 2.43 / 2.55); ratios from Viesi 2023 Table 1 | derived |
| **P_rated T2** (T-bar) | 40 | 50 | 60 | kW | derived (Note b2) from Viesi Table 1 (Larici J-bar) and French TK spec sheets | derived |
| **P_rated T3** (J-bar) | 24 | 30 | 36 | kW | derived (Note b2) | derived |
| **P_rated T4** (rope tow) | 4 | 5.5 | 9 | kW | derived (Note b2); French baby lift sheets 2–4 kW | derived |
| Sum of rated lift power | 178 | 235.5 | 265 | kW | sum of the four rows above | derived |
| No-load fraction φ0 = P0/P_rated, chairlift | 0.30 | 0.375 | 0.45 | – | 0.375: Blasuttigh 2023 (750 kW / 2 MW); 0.44: Zegg 2010 split in Szlosarek Table 1 (Note b3) | verified / derived |
| No-load fraction, surface lifts | 0.20 | 0.30 | 0.40 | – | none found; set below chairlift because ski friction scales with load (Note b3) | assumed |
| Energy per ride e_i = m·g·H_eff/η, T1/T2/T3/T4 | – | 0.058/0.049/0.047/0.014 | – | kWh per ride | physics; H_eff = H + μ_t·L_horizontal for surface lifts | derived |
| Operating hours per day | 7 (09–16) | 8 (08–16) | 9 (08–17) | h | brief (08–16); Szlosarek 2019 §6 (9–16); Viesi 2023 §4.4 (8–17) | verified (range) |
| Ski operating days per season | 60 | 80 | 100 | d | brief; Vanat 2025 p. 224 (season about 4 months, mid-Dec to early Apr); L'Orient Today (Zaarour open only 2–3 weeks in a poor year) | assumed within cited bounds |
| Snowless year | 0 | 0 | 0 | d | brief (2015) | given |
| Lebanon skier visits per year | – | 300,000 | – | skier-days | Vanat 2025 p. 225 (country box) | verified (industry report) |
| Mzaar share of national skier visits | – | about 75 % | – | – | Vanat 2025 p. 225 | verified |
| Lebanese lifts / ski areas | – | 46 / 6 | – | – | Vanat 2025 p. 225 (Mzaar 18 lifts, Faqra 4) | verified |
| **Faqra skier-days per season S** | 5,000 | 10,700 | 26,000 | skier-days | Note b4 | derived |
| Lift rides per skier-day r | 6 | 8 | 12 | rides | 8.3 = 10 M entrances / 1.2 M skier-days, Viesi 2023 §2 | base derived; range assumed |
| Weekend/holiday share of operating days w | 0.35 | 0.35 | 0.35 | – | 2/7 of days plus Christmas and New Year | assumed |
| Weekend-day to weekday skier ratio | 3 | 3 | 3 | – | no Lebanese data found; LBC 2024 reports hotels "fully booked on weekends" | assumed |
| Skiers per weekday / weekend day | 49 / 147 | 79 / 236 | 153 / 459 | skiers | derived from S, D, w and the ratio | derived |
| Hourly ride profile (shape) | – | see (c) | – | – | Szlosarek 2019 Table 5 (7-h day) | derived |
| Season-average load factor (rides ÷ capacity) | 1.3–4 % | 2.5–7.5 % | 6.5–19 % | % | model output; Madonna di Campiglio measured 26–33 % (Viesi Table 2) | derived |
| **Seasonal lift energy** | **20.8** | **56.6** | **119.6** | MWh/season | model, Note b5 | derived |
| Peak lift demand (season-model days) | 55 | 102 | 177 | kW | model; weekend 09–10 h | derived |
| Peak lift demand (design capacity day, base parameters) | – | 208 | – | kW | Szlosarek Table 5 loading applied to Faqra | derived |
| kWh per skier-day (check) | 4.2 | 5.3 | 4.6 | kWh | compare Note b6 | derived |
| kWh per ride (check) | 0.69 | 0.66 | 0.38 | kWh | compare Viesi 0.16–0.38 | derived |
| Critical recovery load, T1 (if electric) | 25 | 30 | 38 | kW for 30–90 min | EN 13223:2015 §6.4.2 (≥ 0.5 m/s, 3 × recovery time), Note b7 | derived |

## (b) Derivation notes

**b1. Physics.** Lifting one person through height H takes m·g·H. With m = 80 kg, the shaft power needed to carry capacity Q (persons per hour) up H (m) is

P_lift = 80 × 9.81 × H × Q / 3.6e6 = 2.18e-4 × H × Q kW.

For surface lifts, the skier's skis also slide on snow, so the effective height is H_eff = H + μ_t·L_h, where L_h = √(L² − H²) and μ_t = 0.12 (Schleppliftrichtlinien §4.5.1b). The electrical power is

P(t) = P0 + u(t)·Q·m·g·H_eff / (η·3.6e6), capped at P_rated,

where u(t) is passenger loading as a fraction of capacity. This is the same form as Blasuttigh's P = P0 + (p/(Pmax·Δt))·(Pf − P0), but the load-dependent slope comes from physics rather than from (Pf − P0). A cross-check of the slope: Szlosarek's gondola used 3,044 kWh for 9,055 riders over a 671.65 m rise. That is 0.50 Wh per person per metre, against 0.218 Wh per person per metre of pure lifting work (80 kg), so about 44 % of the energy goes into the lift itself and the rest is rolling friction, air drag, station load and drive losses.

**b2. Installed motor power.** These are benchmarks from Viesi et al. 2023, Table 1 (Madonna di Campiglio, mostly Doppelmayr lifts). "Ratio" is installed kW divided by P_lift.

| Lift | Type | H (m) | L (m) | Q (p/h) | Installed kW | P_lift (kW) | Ratio |
|---|---|---|---|---|---|---|---|
| Nube d'Argento | 2-seat fixed-grip (Doppelmayr 1984) | 150 | 875 | 1,200 | 100 | 39.2 | 2.55 |
| Vagliana | 2-seat fixed-grip (1981) | 185 | 786 | 1,028 | 100 | 41.5 | 2.41 |
| Miramonti | 2-seat fixed-grip (Nascivera 1981) | 183 | 466 | 1,125 | 110 | 44.9 | 2.45 |
| Fevri | 3-seat fixed-grip (1988) | 368 | 1,057 | 1,500 | 260 | 120.3 | 2.16 |
| Pancugolo | 4-seat fixed-grip (2012) | 212 | 447 | 1,600 | 131 | 73.9 | 1.77 |
| Larici | J-bar (2008) | 78 | 394 | 720 | 20.8 | 12.2 | 1.70 |

For Larici, the ratio using H_eff (μ = 0.12) is 1.07.

- **T1:** P_lift = 2.18e-4 × 240 × 1,200 = 62.8 kW.
  - Low: × 1.77 (the newest lift, Pancugolo) = 110 kW.
  - Base: × 2.43 (mean of the three 2-seaters) ≈ 150 kW.
  - High: × 2.55 = 160 kW.
  - Nube d'Argento (880 m, 1,200 p/h, 2.5 m/s, 100 kW) is the closest twin, but its rise is 90 m lower.
- **Surface lifts.** Two Larici-based rules: (i) 1.70 × P_lift, or (ii) 1.07 × P(H_eff, μ = 0.12). The French spec sheets give a third check on kW per (m·p/h): Courteloz TK 372 m / 750 p/h / 18 kW, Plan Lachail TK 835 m / 720 p/h / 55 kW, Mauret TK 723 m / 900 p/h / 73 kW. Their 6.5e-5 to 1.1e-4 kW per (m·p/h) brackets the results. These sheets are classified-ad documents (low quality) and give no rise.
  - T2: rule (i) 52 kW, rule (ii) 47 kW, L·Q band 35–60 kW, so 40 / 50 / 60 kW.
  - T3 (39 % average grade): rule (i) 33 kW, rule (ii) 27 kW, L·Q band 16–28 kW, so 24 / 30 / 36 kW.
  - T4: rule (i) 3.9 kW, rule (ii) 4.7 kW, L·Q band 5.2–9.0 kW. French baby lifts are 2 kW (60 m / 257 p/h) and 4 kW (148 m / 514 p/h). So 4 / 5.5 / 9 kW.
- With the base parameters, the uncapped full-load power of T2 (64 kW) and T3 (37.5 kW) is above P_rated, because μ = 0.12 is a conservative design value. The model caps output at P_rated. This only matters on a design capacity day.

**b3. No-load fraction.** Blasuttigh 2023 uses 750 kW at no load against 2 MW at full load for 8 lifts, which gives 0.375. That is the base value for the chairlift.

A second check comes from the Zegg et al. (2010) power split for a detachable chairlift at 65 % workload, as reported in Szlosarek Table 1: 40 % passenger lift, 40 % rolling resistance, 11 % drive losses, 5 % station infrastructure, 4 % air drag.
- Treat rolling resistance, air drag, infrastructure and a proportional share of drive losses as no-load: P0 ≈ 0.55·P(0.65).
- Extrapolating the passenger term to full load gives P_full ≈ 1.24·P(0.65), so P0/P_full ≈ 0.44. This is the basis for the high value of 0.45.
- At T1's lower speed of 2.1 m/s the friction coefficient is smaller. Szlosarek §4 gives μ = 0.0096 + 0.0052·v, which is 0.021 at 2.1 m/s against 0.036 at 5 m/s. So the real φ0 for T1 is probably nearer 0.30–0.375.

For surface lifts, most resistance is ski friction, which grows with the number of skiers. Rope rollers (μ = 0.03, Schleppliftrichtlinien §4.5.1c) and drive losses make up the no-load part. No measured value was found, so 0.20 / 0.30 / 0.40 is **assumed**.

**b4. Faqra skier-days.** Vanat 2025 gives Lebanon 300,000 skier visits per year, with Mzaar at about 75 % (≈225,000 on 18 lifts). That leaves ≈75,000 visits on the remaining 28 lifts, about 2,680 per lift. Faqra's 4 lifts therefore give ≈10,700 skier-days (**base**).
- High: the national average of 6,522 visits per lift × 4 = 26,000.
- Low: ≈0.5 × base = 5,000, reflecting Faqra being a members' club and the poor seasons described in L'Orient Today.

Per day, with D days, w = 0.35 and a weekend factor of 3, weekday skiers n_wd = S / (D·(0.65 + 0.35 × 3)) and weekend skiers are 3·n_wd. Daily rides are split between lifts in proportion to capacity (**assumed**).

**b5. Seasonal energy.** E = Σ_days Σ_h Σ_i P_i(h), from `energy.py`.
- **Low 20.8 MWh:** 178 kW rated, 7 h, 60 days.
- **Base 56.6 MWh:** 686 kWh on a weekday, 746 kWh on a weekend day.
- **High 119.6 MWh:** 1,126 kWh on a weekday, 1,325 kWh on a weekend day.

No-load running is 86–94 % of the energy, because predicted utilisation is very low. The number of lifts running each day and φ0 therefore drive the result far more than skier numbers do. If the club runs only T1 and T4 on weekdays, base energy falls by roughly 20–25 %. That is an operating choice and would need to be modelled explicitly.

A benchmark-only estimate gives a similar range. Multiplying S by 5.3 kWh per skier-day (WKO: Austrian ropeways only) gives 26 / 57 / 138 MWh.

**b6. Benchmark cross-check.**

| Benchmark | Value | Model result | Comment |
|---|---|---|---|
| WKO Tirol 2022 p. 4: ropeways' share of 18 kWh per skier-day | 5.3 kWh per skier-day | 4.2–5.3 | consistent |
| Madonna di Campiglio (Viesi 2023 §2): 3.2–3.7 GWh / 0.85–1.25 M skier-days | 2.6–4.4 kWh per skier-day | 4.2–5.3 | Faqra slightly higher, as expected at low utilisation |
| Viesi Table 2: per entrance, at 26–33 % load factor | 0.16–0.38 kWh per ride | 0.38–0.69 | Faqra higher; Viesi Fig. 10 shows efficiency worsening at low load |
| Scuderi 2025: whole resort, not lifts only | ~20 kWh per skier-day | – | do not compare directly |
| Verbier (BFE 2019): whole site | 7.2 kWh per guest-day | – | about 2/3 to 3/4 of it is lifts |

**b7. Critical load in an outage.**
- **Surface lifts (T2–T4):** passengers are on the ground and simply let go. No powered evacuation is needed, so these are fully sheddable (derived from how surface lifts work; the Schleppliftrichtlinien contain no evacuation-drive clause, only an inspection drive at ≤ 0.3 m/s, §6.5.5).
- **T1 chairlift:** EN 13223:2015 §6.4 requires a recovery drive that runs at **≥ 0.5 m/s** (§6.4.2), is designed to run for **3 × the maximum required recovery time** (§6.4.2), can be brought into operation **within 15 min** (§6.4.7a), and has electrical equipment separate from the main drive (§6.4.6).
- Recovery drives are commonly separate internal-combustion units. A news report on a Feb 2025 outage at Silver Mountain (Idaho) describes a "gas-powered" evacuation motor that failed after about 10 min, after which skiers were evacuated by rope (low-quality source, illustrative only). If Faqra's T1 recovery drive is engine-driven, the critical electrical load is only controls and safety circuits. No kW figure was found for these.
- If the recovery is done electrically through the microgrid:
  - Power: P_rec ≈ (0.5 / 2.1) × P_full(T1) ≈ 0.24 × 126 kW ≈ 30 kW (base; range 25–38 kW from the P_rated range). This scales the full-load rope force to the lower speed and slightly overstates the result, because rolling losses fall at lower speed.
  - Time to clear the line: 880 m / 0.5 m/s ≈ 29 min.
  - Energy: ≈ 15 kWh for one clearance, or ≈ 45 kWh at the 3× design duration.
  - Recommendation: reserve ≥ 30 kW and 15–45 kWh of battery for T1 during operating hours.

## (c) Hourly utilisation profiles (24 values; hour h covers h:00–h+1:00, base scenario)

**Basis.** Szlosarek et al. 2019, Table 5 ("variation vehicles" column) gives the vehicles needed each hour on a representative Austrian ski day (09–16 h), out of a fleet of 84. Dividing by 84 gives the capacity fraction for a busy day: 0.952, 0.821, 0.702, 0.310 (lunch dip), 0.417, 0.417, 0.310. The 08–09 h value is set to half of 09–10 h (**assumed** ramp-up, since Faqra opens at 08:00). The normalised shape (share of daily rides) is:

`[0,0,0,0,0,0,0,0, 0.108,0.216,0.186,0.159,0.070,0.095,0.095,0.070, 0,0,0,0,0,0,0,0]`

**Passenger loading u(h)** (rides per hour ÷ total capacity of 3,150 p/h, base):

- Weekday (79 skiers × 8 rides): `[0,0,0,0,0,0,0,0, 0.022,0.043,0.037,0.032,0.014,0.019,0.019,0.014, 0,0,0,0,0,0,0,0]`
- Weekend/holiday (236 skiers): `[0,0,0,0,0,0,0,0, 0.065,0.130,0.112,0.096,0.042,0.057,0.057,0.042, 0,0,0,0,0,0,0,0]`
- Design capacity day (raw Szlosarek fractions): `[0,0,0,0,0,0,0,0, 0.476,0.952,0.821,0.702,0.310,0.417,0.417,0.310, 0,0,0,0,0,0,0,0]`

**Resulting electrical demand P(h)/P_rated,total** (base, 235.5 kW, including no-load):

- Weekday: `[0,0,0,0,0,0,0,0, 0.362,0.376,0.372,0.368,0.357,0.360,0.360,0.357, 0,0,0,0,0,0,0,0]` (85–89 kW)
- Weekend: `[0,0,0,0,0,0,0,0, 0.390,0.432,0.420,0.410,0.375,0.384,0.384,0.375, 0,0,0,0,0,0,0,0]` (88–102 kW)
- Design capacity day (kW): `[0,…, 154,208,199,189,129,145,145,129, 0,…]`, 1,299 kWh/day

**Caveats.**
- The Szlosarek day is for a gondola, where the morning rush is pronounced. Lifts inside a ski area such as Faqra's probably have a flatter profile, but no measured profile for in-area lifts was found.
- Night-time demand is set to 0. Viesi 2023 §4.2 notes some constant demand outside operating hours (possibly anemometer heaters), but gives no number.

## (d) BibTeX

```bibtex
@article{Szlosarek2019,
  author  = {Szlosarek, Robert and Yan, Chenguang and Kr{\"o}ger, Matthias and Nu{\ss}baumer, Christian},
  title   = {Energy efficiency of ropeways: a model-based analysis},
  journal = {Public Transport},
  volume  = {11}, number = {3}, pages = {617--635}, year = {2019},
  doi     = {10.1007/s12469-019-00212-1}
}
@article{Viesi2023,
  author  = {Viesi, Diego and Baldessari, Gianni and Polderman, Annemarie and Sala, Stefano and Zanetti, Alberto and Bolognese, Michele and Pellegrini, Chiara and Crema, Luigi},
  title   = {Developing and testing an ``Integrated Energy Management System'' in a ski resort: The ``Living Lab Madonna di Campiglio''},
  journal = {Cleaner Energy Systems},
  volume  = {4}, pages = {100050}, year = {2023},
  doi     = {10.1016/j.cles.2022.100050}
}
@article{Blasuttigh2023,
  author  = {Blasuttigh, Nicola and Pastore, Stefano and Scorrano, Mariangela and Danielis, Romeo and Massi Pavan, Alessandro},
  title   = {Vehicle-to-ski: A {V2G} optimization-based cost and environmental analysis for a ski resort},
  journal = {Sustainable Energy Technologies and Assessments},
  volume  = {55}, pages = {102916}, year = {2023},
  doi     = {10.1016/j.seta.2022.102916}
}
@techreport{Vanat2025,
  author      = {Vanat, Laurent},
  title       = {2025 International Report on Snow \& Mountain Tourism: Overview of the key industry figures for ski resorts},
  institution = {Laurent Vanat Consulting}, address = {Geneva, Switzerland},
  year        = {2025}, month = apr, note = {17th ed., Lebanon pp. 224--225}
}
@standard{EN13223,
  title        = {{EN} 13223:2015 Safety requirements for cableway installations designed to carry persons -- Drive systems and other mechanical equipment},
  organization = {European Committee for Standardization (CEN)}, year = {2015}
}
@misc{Schlepplift1999,
  author       = {{Bundesministerium f{\"u}r Wissenschaft und Verkehr}},
  title        = {Schleppliftrichtlinien: Richtlinien f{\"u}r die Anmeldung, die Errichtung und den Betrieb von Schleppliften},
  howpublished = {Republik {\"O}sterreich, Zl. 239028/15-II/C/13-1998},
  year         = {1999},
  url          = {https://www.wko.at/oe/transport-verkehr/seilbahnen/schleppliftrichtlinien-2.pdf}
}
@misc{WKO2022,
  author       = {{Wirtschaftskammer Tirol, Fachgruppe Seilbahnen}},
  title        = {Energie und Seilbahnen -- Fakten versus Mythen (Langfassung)},
  year         = {2022}, note = {Version 08.08.2022},
  url          = {https://wko.at/tirol/transport-verkehr/seilbahnen/energie-langfassung-110822.pdf}
}
@misc{SBS2022,
  author = {{Seilbahnen Schweiz}},
  title  = {2022 Wertsch{\"o}pfung und Stromverbrauch (Faktenblatt)}, year = {2022},
  url    = {https://seilbahn.net/snn/konfig/uploads/pdf/679.pdf}
}
@misc{Leitner2023,
  author = {{LEITNER AG}},
  title  = {Sustainable Ropeway Operation}, year = {2023},
  url    = {https://www.leitner.com/fileadmin/userdaten/05-Unternehmen/Nachhaltigkeit/SUSTAINABLE_ROPEWAY_OPERATION_2023_EN.pdf}
}
@misc{Vogel2019,
  author = {Vogel, Benedikt},
  title  = {Skifahren mit richtig dosierter Energie (Pilotprojekt Smart Ski Resort, Verbier)},
  howpublished = {Bundesamt f{\"u}r Energie BFE}, year = {2019},
  url    = {https://pubdb.bfe.admin.ch/de/publication/download/9944}
}
@misc{SkiresortFaqra,
  author = {{Skiresort Service International}},
  title  = {Faqra -- ski lifts T1, T2, T3, T4 (lift pages l112103--l112106)},
  year   = {2026}, note = {Accessed 22 Nov. 2026},
  url    = {https://www.skiresort.com/en/ski-resort/faqra/ski-lifts/}
}
@misc{LiftWorldMzaar,
  author = {{Lift-World}},
  title  = {Lift database: Mzaar Kfardebian, Lebanon},
  year   = {2026}, note = {Accessed 22 Nov. 2026},
  url    = {https://lift-world.info/en/lifts/place/mzaar_kfardebian/index.htm}
}
```

Not recommended as formal citations, but used as checks:
- L'Orient Today, "Decent winter season for Lebanon's ski resorts" (today.lorientlejour.com/article/1371186). Qualitative only; the Zaarour "2–3 weeks" quote.
- LBC, "By the numbers: Lebanon's ski season" (17 Jan 2024). 75,000 to 100,000 "enthusiasts"; hotels full at weekends.
- domaines-skiables.fr surface lift spec sheets (classified ads, low quality).
- Coeur d'Alene Press, 17 Feb 2025, Silver Mountain evacuation (news).
- Zegg, Küng and Grossrieder (2010), *Energiemanagement Bergbahnen*, Seilbahnen Schweiz. Cited only second-hand via Szlosarek; the original was not seen.

## (e) Gaps

1. **No Faqra motor nameplate kW, manufacturer, year or drive type** is published anywhere. P_rated is benchmark-derived (±25 %). This is the largest single uncertainty, because no-load running dominates the energy.
2. **No Faqra or Lebanese skier counts per resort.** S is derived from national totals (Vanat). There are also no Lebanese weekday/weekend splits or season-day statistics: the weekend factor of 3, w = 0.35 and D = 60–100 are assumed.
3. **No measured no-load fraction for surface lifts.** φ0 = 0.2–0.4 is assumed.
4. **Hourly profile** comes from one Austrian gondola (Szlosarek Table 5), not from in-area lifts or from Lebanon.
5. **Whether all four lifts run on low-demand weekdays** is unknown. This changes energy by roughly 20–25 %.
6. **T1's recovery drive type** (diesel/petrol or electric) and its kW are unknown, as is the controls and heating standby load outside operating hours.
7. **Motor inrush/start power** was not found. EN 13223 §6.2.1 only requires a "smooth" start. Lifts built in the 1990s may use DC drives or direct-on-line starts; worth checking in the transient analysis.
8. The Vanat Lebanon figures come from the 2025 edition ("average skier visits", averaged over recent seasons). Per-season variation, such as a 2015-type snowless year, is not published.
