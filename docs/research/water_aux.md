# Faqra Club: water, pumping and auxiliary loads (research note)

Scope: water supply and pumping, wastewater treatment, 20 km road lighting, sports floodlighting, pool filtration, the EV fast charger, security/CCTV/gates, and offices/workshop.
Site: 33.985 N, 35.811 E, 1,735–1,975 m.
Calculation script: `tools/research/water_aux_calc.py`. Run it with `python3 -I`. Every number in sections (a)–(c) can be reproduced from it.

Status legend:
- **verified**: read in the cited source during this session.
- **derived**: computed from verified inputs. The derivation is shown in (b).
- **assumed**: no source found. The value is a placeholder and is listed in (f).

Occupancy note. To stay consistent with the chalet block (`research/chalets.md`, section (d)), the water and WWTP blocks scale with the same equivalent full-occupancy days per year: Low 65.6, Base 100.5, High 154.4. These give annual-average occupancy factors of 0.180, 0.275 and 0.423.

---

## Key facility facts found

1. **"600 m³" facility.**
   - The Faqra Club brochure says "600 cubic meters water treatment facility". The home page says "600 CBM" water treatment facility. Neither gives a basis such as per day or storage.
   - The same brochure gives: 20 km of roads, more than 400 families, 24-h security at the entrance, a hotel with 20 rooms and 5 suites, and 3 tennis courts.
   - The home page also lists 5 snowplows, 4 ski lifts, 3 restaurants, 2,400,000 m² of managed land, 500,000 m² of green spaces, and 5,000 poplars along the roads.
2. **The Club runs its own wastewater collection and treatment plant.**
   - BGR Special Report No. 16 (2013), §5.1.1.1, p. 43, describes it as one where "the wastewater of the residences is collected, then treated and reused for lawn irrigation".
   - Figures 22–23 of that report show "Wastewater Treatment Plant of Faqra Club".
   - **Inference (derived):** the "600 m³ water treatment facility" is most plausibly this WWTP with a design capacity of about 600 m³/day. The check: estate consumption at full occupancy is 233–354 m³/d (see W1–W6), so wastewater at an 0.8 return factor is about 190–280 m³/d. A 600 m³/d plant would therefore have roughly 2× headroom, which is a normal peaking allowance.
   - The alternative reading, a 600 m³ potable reservoir, cannot be excluded. It would equal about 1.6 days of Base peak-day supply.
   - The report carries both readings. Only the WWTP reading changes the electrical load.
3. **Potable water source.**
   - BGR SR16 (p. 17) says Chabrouh Dam "provides potable water for the upper Keserwan district". The dam crest is at 1,618 m (Wikipedia, Chabrouh Dam).
   - Nothing found says whether Faqra Club is fed from that network, from Labbane spring, or from private wells.
   - BGR SR16 (p. 20) says the Labbane spring feeds an irrigation canal for the Kfardebian irrigation scheme. It is not cited as potable supply for the Club.
   - The Club sits 117–357 m above the Chabrouh crest. Any supply from the regional network therefore has to be pumped up through the estate. This is the basis for the head range used below.
4. **EV charging (G Charge network station pages).**
   - The "Faqra Club Charging Station", inside Faqra Club next to Casper & Gambini's, has 1 charger with 1×CCS2 and 1×GBT connectors. It is open 07:00–24:00. The page lists maximum power as "60 kW & 150 kW", but its FAQ says "fast charging up to 60 kW".
   - A second G Charge page, "Faqra Charging Station – Auberge de Faqra, inside Faqra Club", has the same specifications. This may be a separate unit or a duplicate listing.
   - A "Solipro Offices" location is also mapped.
   - Separately, the MEDCO network lists "Medco Faqra" with 2×60 kW DC and 2×22 kW AC. That is probably the MEDCO fuel station on the Faqra road, outside the Club.

---

## (a) Parameter table

### Water supply and pumping

| # | Parameter | Low | Base | High | Unit | Source (short cite + location) | Status |
|---|---|---|---|---|---|---|---|
| W1 | Families in estate | 400 | 400 | 400 | families | Faqra Club brochure ("more than 400 families") | verified |
| W2 | Persons per household (Lebanon) | 3.8 | 3.8 | 3.8 | persons | CAS/ILO LFHLCS 2018–19, reported in Arab News 2019 | verified (secondary report) |
| W3 | Domestic demand per capita | 140 | 180 | 220 | l/c/d | MoEW NWSS 2010: slide 35 (rural 140 conservative / urban 180 moderate) and slide 38 (urban high 220 in 2035) | verified |
| W4 | Hotel guests at full occupancy | 50 | 50 | 50 | persons | 25 keys (brochure: 20 rooms + 5 suites) × 2 guests | derived (2/room assumed) |
| W5 | Tourist demand | 400 | 400 | 400 | l/tourist/d | MoEW NWSS 2010, slide 27 | verified |
| W6 | Consumption at full occupancy | 233 | 294 | 354 | m³/d | W1·W2·W3 + W4·W5 | derived |
| W7 | Distribution losses (NRW) | 10 | 20 | 30 | % | NWSS 2010, slide 34 (UfW targets 30% by 2020, 20% by 2035). Low value assumed for a small private network | verified (Base/High) / assumed (Low) |
| W8 | Pumped volume, peak day (full occupancy) | 259 | 367 | 506 | m³/d | W6/(1−W7) | derived |
| W9 | Annual-average occupancy factor | 0.180 | 0.275 | 0.423 | – | chalets.md (d): 65.6 / 100.5 / 154.4 equivalent days ÷ 365 | derived (assumed calibration) |
| W10 | Annual pumped volume | 16,969 | 36,883 | 78,171 | m³/yr | W8·W9·365 | derived |
| W11 | Static + friction head | 120 | 265 | 360 | m | Low: half the estate's 240 m elevation span (only upper zones boosted). Base: 240 m span + 10% friction. High: Chabrouh crest 1,618 m to estate top 1,975 m | derived |
| W12 | Theoretical lifting energy | 0.00272 | 0.00272 | 0.00272 | kWh/(m³·m) | ρg/3.6×10⁶. Plappally & Lienhard 2012 §2.2 quote "0.00272 kWh/m³ m" | verified |
| W13 | Empirical specific pumping energy (groundwater, CA) | – | 0.004 | – | kWh/(m³·m) | Plappally & Lienhard 2012 §2.2, citing refs [16],[29] | verified |
| W14 | Implied wire-to-water efficiency | 0.75 | 0.68 | 0.50 | – | Base = W12/W13. Low/High bracket the range: DOE pool-pump guide puts average single-speed pumps at 30–70% and PM motors at ~90% | derived |
| W15 | Specific pumping energy | 0.44 | 1.06 | 1.96 | kWh/m³ | W12·W11/W14 | derived |
| W16 | Pump electrical rating (peak day delivered in 20 h) | 5.6 | 19.5 | 49.7 | kW | W8/20 h × W15 | derived |
| W17 | **Annual pumping energy** | **7.4** | **39.2** | **153.4** | MWh/yr | W10·W15 | derived |
| W18 | Groundwater pumping, California range (cross-check) | 0.14 | – | 0.69 | kWh/m³ | Plappally & Lienhard 2012 §2.2 | verified |
| W19 | Raw-water pumping, river to plant (cross-check) | 0.02 | – | 0.05 | kWh/m³ | Plappally & Lienhard 2012 (Fig. 7 discussion) | verified |

### Wastewater treatment (WWTP, Club-owned)

| # | Parameter | Low | Base | High | Unit | Source | Status |
|---|---|---|---|---|---|---|---|
| T1 | WWTP existence, reuse for lawn irrigation | – | yes | – | – | BGR SR16 (2013) §5.1.1.1 p. 43, Figs 22–23 | verified |
| T2 | Design capacity (reading of "600 CBM") | – | 600 | – | m³/d | Faqra Club brochure/home page. Daily basis inferred | derived/uncertain |
| T3 | Return factor (wastewater/consumption) | 0.8 | 0.8 | 0.8 | – | No source fetched | assumed |
| T4 | Annual wastewater treated | 12,217 | 23,605 | 43,775 | m³/yr | W6·W9·365·T3 | derived |
| T5 | Specific energy, secondary treatment | 0.33 | 0.60 | 1.16 | kWh/m³ | Low/Base: Plappally & Lienhard 2012 Table 14, activated sludge 0.33–0.60 (lagoon 0.09–0.29, trickling filter 0.18–0.42). High: Longo et al. 2016 §3, median 3.01 kWh/kgCOD_removed for PE < 2,000 (vs 0.69 for PE > 100,000) × 0.43 kg COD/m³ × 0.9 removal | verified (Low/Base) / derived (High; 430 mg/L medium-strength COD from Metcalf & Eddy, not re-checked) |
| T6 | **Annual WWTP energy (flow-based)** | **4.0** | **14.2** | **50.8** | MWh/yr | T4·T5 | derived |
| T7 | Average WWTP power | 0.46 | 1.62 | 5.80 | kW | T6/8,760 | derived |
| T8 | Stress bound: design flow at 0.60 kWh/m³ | – | – | 15.0 kW / 131 MWh | – | 600 m³/d × 0.60 | derived |

### Road lighting (20 km)

| # | Parameter | Low | Base | High | Legacy HPS | Unit | Source | Status |
|---|---|---|---|---|---|---|---|---|
| R1 | Lit road length | 20 | 20 | 20 | 20 | km | Faqra Club brochure ("20 km of secured and well maintained roads"). Lighting of the full length is assumed. OSM will refine | verified (length) / assumed (fully lit, single-sided) |
| R2 | Pole spacing | 40 | 30 | 25 | 30 | m | LRC NLPIP 2011, App. A: LED spacings 125–190 ft (38–58 m) and HPS 195 ft (59 m) on a 7.9 m road with 7.6 m mounting. Spacing/height ratio 5–7.8 applied to ~6 m estate poles gives 30–40 m; 25 m allows for winding mountain roads | derived |
| R3 | Number of poles | 501 | 667 | 801 | 667 | – | R1/R2 + 1 | derived |
| R4 | Luminaire input power | 31 | 37 | 67 | 127.4 | W | Low: Signify UniStreet gen2 (BGP281) min 31 W / 4,100 lm, "residential streets". Base: Signify CoreLine Malaga BRP102 LED58, 37 W / 5,162 lm / 140 lm/W. High: UniStreet gen2 max 67 W / 10,440 lm. Legacy: LRC NLPIP 2011, "100 W" HPS measured at 127.4 W system | verified |
| R5 | Connected load | 15.5 | 24.7 | 53.7 | 85.0 | kW | R3·R4 | derived |
| R6 | Dusk-to-dawn hours (sunset→sunrise) | 4,314 | 4,314 | 4,314 | 4,314 | h/yr | NOAA solar-position algorithm, 33.985 N; see (c). JRC 2019 p. 13: "1 year for road lighting typically corresponds to 4000h" | derived (consistent with verified 4,000 h) |
| R7 | Dimming 00:00–05:00 | 50% | 70% | none | none | output level | JRC 2019 p. 8: P-class levels "could be cut by 30–35%" without loss of perceived security; UNI 11248 allows up to 4 class reductions | verified (practice) / assumed (schedule) |
| R8 | Full-power-equivalent hours | 3,402 | 3,767 | 4,314 | 4,314 | h/yr | R6 with R7 | derived |
| R9 | **Annual energy** | **52.8** | **93.0** | **231.5** | 366.6 | MWh/yr | R5·R8 | derived |

LED vs HPS (LRC NLPIP 2011, verified):

| Luminaire type | System power (W) | Single-sided pole spacing | Power per km |
|---|---|---|---|
| LED (2011 vintage) | 67–90 | 125–190 ft (38–58 m) | 1.26–1.91 kW/km |
| HPS | 127.4 | 195 ft (59 m) | 2.14 kW/km |

Power per km is derived. Modern 140 lm/W LEDs (R4) give 0.8–2.1 kW/km at 25–40 m spacing.

### Sports floodlighting

| # | Parameter | Low (EN 12193 Class III) | Base (Class II) | High (Class I) | Unit | Source | Status |
|---|---|---|---|---|---|---|---|
| S1 | Required illuminance, tennis and padel, outdoor | 200 | 300 | 500 | lx (U 0.6/0.7/0.7) | LEDVANCE Sports Facility Lighting brochure 01/2024 (EN 12193 table). LTA 2026 recommends 400–500 lx average on the principal play area | verified |
| S2 | Tennis, LED, per court | 1.80 | 3.12 | 4.64 | kW | LEDVANCE 2024, standard calculations: 12×150 W / 8×290 + 4×200 W / 16×290 W | verified |
| S3 | Tennis per court, cross-checks | 2.4 (LED) | – | 5.5 (metal halide) | kW | Australian Energy Foundation / Tennis Victoria, "Chip the Charge" 2022 | verified |
| S4 | Number of tennis courts | 3 | 3 | 3 | – | Faqra Club home page and brochure | verified |
| S5 | Padel, per court | 0.80 | 1.20 | 2.00 | kW | LEDVANCE 2024: 8×100 / 8×150 / 8×150 + 4×200 W. Manufacturer range 1.2–1.6 kW standard, 2.9 kW TV (Analistas Padel guide) | verified |
| S6 | Number of padel courts | 1 | 2 | 2 | – | Count not published | assumed |
| S7 | Basketball court (28×15 m) | 0.80 | 1.80 | 1.80 | kW | LEDVANCE 2024: Class III 8×100 W, Class II 12×150 W | verified |
| S8 | Football pitch | 0 | 2.7 | 9.6 | kW | High: LEDVANCE 2024, 7-a-side 65×44 m, 16×600 W (~220 lx). Base: area-scaled to a 40×20 m 5-a-side (9.6 × 800/2,860). Pitch size unknown | verified (High) / derived (Base) |
| S9 | Connected load | 7.0 | 16.3 | 29.3 | kW | sum | derived |
| S10 | Full-load-equivalent floodlit hours | 150 | 300 | 500 | h/yr | See (b). LTA 2026: floodlit courts give 3,500 vs 2,500 playable h/yr in the UK (+1,000 h), an upper bound for a far longer season | assumed (bounded by verified LTA figure) |
| S11 | **Annual energy** | **1.1** | **4.9** | **14.7** | MWh/yr | S9·S10 | derived |

### Pool (outdoor, summer, unheated)

| # | Parameter | Low | Base | High | Unit | Source | Status |
|---|---|---|---|---|---|---|---|
| P1 | Pool volume | 150 | 300 | 500 | m³ | Not published. 300 m³ ≈ 20×10×1.5 m | assumed |
| P2 | Turnover time | 6 | 6 | 6 | h | Hunt & Easley 2012 (DOE/GO-102012-3534) §2: "Normal operation should never have a turnover time under six hours". Max filtration rate = volume/360 gpm (APSP) | verified (as design bound) |
| P3 | Total dynamic head | 12 | 15 | 18 | m | No numeric TDH in the DOE guide | assumed |
| P4 | Wire-to-water efficiency | 0.55 | 0.45 | 0.40 | – | Hunt & Easley 2012: single-speed pumps 30–70%, example motor 78%, PM VS motors ~90% | derived |
| P5 | Pump electrical power | 1.5 | 4.5 | 10.2 | kW | ρgQH/η with Q = P1/P2 | derived |
| P6 | Cross-check: residential 1.5 hp single-speed pump | – | 2.0 | – | kW | Hunt & Easley 2012 (measured 2.07 kW) | verified |
| P7 | Operating hours and season | 12 h × 92 d | 24 h × 107 d | 24 h × 122 d | – | DOE Energy Saver: residential pumps 6 h/d. Commercial 24 h recirculation (MAHC 4.7.1.10 not verified). Season Jul–Sep / mid-Jun–Sep / Jun–Sep | assumed |
| P8 | **Annual energy** | **1.6** | **11.7** | **29.9** | MWh/yr | P5·P7 | derived |

Note that the brochure mentions a hotel pool and also a community pool, which may be the same pool. If there are two pools, double the figures.

### EV fast charger

| # | Parameter | Low | Base | High | Unit | Source | Status |
|---|---|---|---|---|---|---|---|
| E1 | Charger rated power | 60 | 60 | 150 | kW | G Charge Faqra Club station page ("60 kW & 150 kW"; FAQ "up to 60 kW"). 1 charger, CCS2 + GBT, 07:00–24:00 | verified (inconsistent page) |
| E2 | AC input at rated output (η 0.93) | 64.5 | 64.5 | 161 | kW | NREL EVSE characterization 2025: efficiency >92% at ≥50 kW (Delta 350 kW) | derived |
| E3 | Energy per session | 22 | 22 | 30 | kWh | DOE VTO FOTW #1319 (2023): paid DCFC average 22.0 kWh in 42 min (EVWATTS, 2020–23). High assumed | verified (Low/Base) / assumed (High) |
| E4 | Sessions per day (annual average) | 0.5 | 2 | 5 | sessions/d | No Lebanese utilisation data found. Physical maximum ≈ 17 h × 60/42 ≈ 24 sessions/d | assumed |
| E5 | Standby power | 0.018 | 0.435 | 0.607 | kW | NREL 2025 (Delta 350 kW): sleep 17.6 W, active standby 607 W. Base = 17 h active (opening hours) + 7 h sleep | verified (Low/High) / derived (Base) |
| E6 | **Annual energy** | **4.5** | **21.1** | **64.2** | MWh/yr | E3·E4/0.93·365 + E5·8,760 | derived |

### Security, gates, CCTV (24/7)

| # | Parameter | Low | Base | High | Unit | Source | Status |
|---|---|---|---|---|---|---|---|
| C1 | IP camera max power | 11.0 | 11.0 | 17.1 | W | Hikvision DS-2CD2T47G1-L datasheet (802.3af class 3, max 11 W PoE). iDS-2CD2T47G2-V-XS datasheet (802.3at, 17.1 W PoE, with white-light/IR) | verified |
| C2 | Number of cameras | 30 | 60 | 120 | – | Not published | assumed |
| C3 | NVR, PoE switch and network overhead | 25 | 25 | 25 | % of camera load | No source | assumed |
| C4 | Gate barriers | 1 | 2 | 3 | – | Brochure mentions "the entrance". Count assumed | assumed |
| C5 | Barrier motor | 220 W, 2–3 s per stroke, 100% duty | | | | FAAC 620 technical data | verified |
| C6 | Barrier standby (controller, loop detector, lamp) | 50 | 50 | 50 | W each | No source | assumed |
| C7 | Guardhouse(s): lighting, PCs, comms, small heater | 1.0 | 2.0 | 3.0 | kW continuous | No source | assumed |
| C8 | **Security block** | **1.46** | **2.92** | **5.71** | kW flat | sum | derived |
| C9 | Annual | 12.8 | 25.6 | 50.1 | MWh/yr | ×8,760 | derived |

Barrier motor energy is negligible: 1,000 cycles/d × 2 strokes × 2.5 s × 220 W = 0.31 kWh/d.

### Offices and maintenance buildings

| # | Parameter | Low | Base | High | Unit | Source | Status |
|---|---|---|---|---|---|---|---|
| O1 | Electricity intensity, naturally ventilated cellular office | 36 (good practice) | 48 (typical) | 48 | kWh/(m²·yr) | UK Energy Efficiency Office, Energy Consumption Guide 19 (1991), Table 1, Type 1 | verified |
| O2 | Floor area (offices + workshop) | 300 | 600 | 1,000 | m² | To be replaced by OSM building footprints | assumed |
| O3 | **Annual energy** | **10.8** | **28.8** | **48.0** | MWh/yr | O1·O2 | derived |
| O4 | Working-hours peak (schedule in (c)) | 3.0 | 8.1 | 13.5 | kW | O3 / (2,250 h + 0.2 × 6,510 h) | derived |

### Block summary

| Block | Low kW | Base kW | High kW | Low MWh/yr | Base MWh/yr | High MWh/yr | Shape |
|---|---|---|---|---|---|---|---|
| Water pumping (rating) | 5.6 | 19.5 | 49.7 | 7.4 | 39.2 | 153.4 | deferrable, storage-backed |
| WWTP (average) | 0.46 | 1.62 | 5.80 | 4.0 | 14.2 | 50.8 | ~flat 24/7 |
| Road lighting (connected) | 15.5 | 24.7 | 53.7 | 52.8 | 93.0 | 231.5 | dusk–dawn |
| Sports floodlights (connected) | 7.0 | 16.3 | 29.3 | 1.1 | 4.9 | 14.7 | summer evenings |
| Pool filtration | 1.5 | 4.5 | 10.2 | 1.6 | 11.7 | 29.9 | summer, 24 h or daytime |
| EV fast charger (AC peak) | 64.5 | 64.5 | 161 | 4.5 | 21.1 | 64.2 | stochastic 07–24 h |
| Security/CCTV/gates | 1.46 | 2.92 | 5.71 | 12.8 | 25.6 | 50.1 | flat 24/7 |
| Offices/workshop (peak) | 3.0 | 8.1 | 13.5 | 10.8 | 28.8 | 48.0 | weekday 08–17 |
| **Total** | – | – | – | **95.0** | **238.5** | **642.6** | |

Road lighting is the largest auxiliary energy block in every scenario: 39% of Base. Water pumping is second in the High case. The EV charger is the largest instantaneous load, but it has a small energy share.

---

## (b) Derivation notes

1. **Water demand.**
   - Persons at full occupancy = 400 × 3.8 = 1,520.
   - Hotel = 25 keys × 2 = 50 guests at 400 l/tourist/d (NWSS). This gives 20 m³/d.
   - Base: 1,520 × 0.180 + 20 = 294 m³/d consumed. Pumped = 294/(1 − 0.20) = 367 m³/d.
   - Staff, restaurants, horses (equestrian club) and the ski area are not counted separately. Treat this as a gap. The NWSS urban per-capita figure partly covers commercial uses.
   - Irrigation of 500,000 m² of green space is supplied by treated effluent (BGR). Its pumping is not included (see gaps).
2. **Head.**
   - The estate spans 1,735–1,975 m, a 240 m difference.
   - If the bulk supply enters near the bottom, as it would from a regional network below, the static lift to the top storage is about 240 m. Adding 10% for friction gives 265 m (Base).
   - High assumes lift from the Chabrouh crest level of 1,618 m to 1,975 m, which is 357 m (rounded to 360 m).
   - Low assumes that only the upper half of the estate is boosted (120 m).
   - All three values are geometric derivations. A site visit or utility data would replace them.
3. **Specific pumping energy.**
   - E = ρgH/(3.6×10⁶ η) = 0.002725·H/η kWh/m³.
   - Base η = 0.68 is the value implied by Plappally & Lienhard's empirical 0.004 kWh/m³/m.
   - Base: 0.002725 × 265/0.68 = 1.06 kWh/m³.
4. **Pump rating.** The peak-day volume is pumped in 20 h. Base: 367/20 = 18.4 m³/h × 1.06 = 19.5 kW. In practice this is likely 2 duty pumps plus 1 standby across booster stages.
5. **WWTP energy.**
   - Flow-based estimate uses the activated-sludge range from Plappally & Lienhard (Table 14, US data).
   - The High value applies the Longo et al. 2016 small-plant median (PE < 2,000: 3.01 kWh/kgCOD_removed). It is converted with medium-strength COD 430 mg/L and 90% removal, giving 1.16 kWh/m³.
   - Small extended-aeration plants often run blowers on timers regardless of inflow. Real consumption at low occupancy can therefore sit nearer a fixed floor. The stress bound is 600 m³/d × 0.60 = 15 kW (131 MWh/yr).
6. **Road lighting.**
   - Poles = 20,000 m / spacing + 1. All poles are on one side, and no gate or junction high-mast lighting is included.
   - Hours come from the NOAA solar-position approximation at 33.985 N with zenith 90.833°. This gives sunset→sunrise = 4,314 h/yr. Using civil-twilight darkness instead gives 3,990 h/yr.
   - Photocells normally switch between these two, which matches JRC's "4000 h". The 4,314 h value is used and is slightly conservative.
   - The terrain horizon is ignored.
   - Base dimming is to 70% from 00:00 to 05:00, following the JRC remark that 30–35% reduction is acceptable on P-class roads.
7. **Sports floodlit hours.**
   - Base season is June–September (122 days).
   - Courts are lit after dusk (19:50–20:20 clock in June–August). The average across all courts is 2.45 full-load-equivalent hours per evening, which gives 300 h/yr.
   - Low is 150 h. High is 500 h, adding shoulder-month weekend evenings.
   - LTA's "+1,000 h/yr" for floodlit UK courts is an upper bound and is not used directly.
8. **Pool.**
   - Q = V/6 h. Base: 50 m³/h at 15 m and η = 0.45 gives 4.5 kW.
   - The residential cross-check is 2 kW for a 1.5 hp pump, so a hotel pool at 2–5× that is consistent.
9. **EV charger.**
   - AC energy = sessions × 22 kWh / 0.93.
   - Base: 2 × 22/0.93 × 365 = 17.3 MWh, plus 3.8 MWh standby.
   - The standby figures come from a 350 kW unit (NREL). A 60 kW cabinet is likely lower, so Base is conservative.
10. **Security.** 60 cameras × 11 W = 0.66 kW. Adding 25% network overhead, 2 barrier standbys and 2 kW of guardhouse load gives 2.9 kW flat.
11. **Offices.**
    - Annual energy = intensity × area.
    - Peak assumes 250 working days × 9 h at peak, with the remaining 6,510 h at 20% of peak.

---

## (c) Hourly and seasonal schedules (for the 8,760-h LP input)

### C1. Night-hour table, 33.985 N (sunset→sunrise; NOAA algorithm, computed)

| Month | J | F | M | A | M | J | J | A | S | O | N | D | Year |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| h/day | 13.84 | 13.06 | 12.05 | 10.99 | 10.09 | 9.62 | 9.82 | 10.58 | 11.58 | 12.64 | 13.57 | 14.06 | – |
| h/month | 429 | 366 | 374 | 330 | 313 | 289 | 304 | 328 | 348 | 392 | 407 | 436 | **4,314** |
| civil-dark h/day | 12.93 | 12.20 | 11.22 | 10.13 | 9.17 | 8.66 | 8.87 | 9.70 | 10.75 | 11.80 | 12.69 | 13.14 | 3,990 |

Solstice times (clock, with DST): 21 Jun sunrise 05:25, sunset 19:50. 21 Dec sunrise 06:38, sunset 16:31.

### C2. Road-lighting lit fraction by clock hour (monthly average, DST applied; multiply by connected kW)

Hours 07–15 are 0 in every month. Hours 00–04 and 20–23 are 1.00 in every month.

| Month | h05 | h06 | h16 | h17 | h18 | h19 |
|---|---|---|---|---|---|---|
| Jan | 1.00 | 0.67 | 0.17 | 0.99 | 1 | 1 |
| Feb | 1.00 | 0.37 | 0 | 0.69 | 1 | 1 |
| Mar | 0.81 | 0.04 | 0 | 0.25 | 0.94 | 1 |
| Apr | 0.97 | 0.14 | 0 | 0 | 0.01 | 0.87 |
| May | 0.60 | 0 | 0 | 0 | 0 | 0.49 |
| Jun | 0.43 | 0 | 0 | 0 | 0 | 0.20 |
| Jul | 0.62 | 0 | 0 | 0 | 0 | 0.20 |
| Aug | 0.94 | 0.03 | 0 | 0 | 0 | 0.61 |
| Sep | 1.00 | 0.32 | 0 | 0 | 0.27 | 0.99 |
| Oct | 0.97 | 0.53 | 0.04 | 0.21 | 0.89 | 1 |
| Nov | 0.99 | 0.16 | 0.41 | 1.00 | 1 | 1 |
| Dec | 1.00 | 0.57 | 0.49 | 1.00 | 1 | 1 |

Dimming multiplier for hours 00–04: Low 0.5, Base 0.7, High 1.0.

### C3. Water pumping (deferrable)

- Daily energy: E_d = W8 × occ(d) × W15. Base on a full-occupancy day: 367 × 1.06 = 390 kWh/d. Base on an empty day: 0. Hotel and staff flows make the real floor greater than 0 (gap).
- occ(d) comes from the chalets.md (d) calendar:

| Period | Occupancy (Low / Base / High) |
|---|---|
| Ski-season weekend | 0.50 / 0.70 / 0.90 |
| Ski-season weekday | 0.10 / 0.20 / 0.35 |
| Summer weekend | 0.50 / 0.70 / 0.90 |
| Summer weekday | 0.30 / 0.45 / 0.65 |
| Shoulder weekend | 0.15 / 0.25 / 0.40 |
| Shoulder weekday | 0.03 / 0.05 / 0.15 |

- Constraints:
  - 0 ≤ P_pump(t) ≤ W16.
  - Storage balance: S(t+1) = S(t) + P_pump(t)/e − demand(t), with S_max = 600 m³ under the reservoir reading. If that reading is wrong, use the actual reservoir volume.
  - Domestic draw follows a diurnal curve, but pumping can be shifted into PV hours.
- Default non-optimised profile: flat over 24 h.

### C4. WWTP

- Flat 24 h at T7 × occupancy-scaled daily flow.
- Recommended form: a fixed floor of 50% of the Base average (0.8 kW) plus a flow-proportional part.
- No source was found for the 50% floor. It reflects timer-run aeration and is marked assumed.

### C5. Sports floodlights (fraction of connected kW)

| Season | Months | Hour 20–21 | Hour 21–22 | Hour 22–23 |
|---|---|---|---|---|
| Base summer | Jun–Sep | 0.80 | 0.90 | 0.75 |

- All other months and hours are 0.
- High adds weekend evenings in May and October at the same shape.
- Low uses half the Base fractions.

### C6. Pool filtration

| Scenario | Season | Hours | Level |
|---|---|---|---|
| Base | 15 Jun – 30 Sep | 24 h | constant 4.5 kW (single-speed) |
| Low | Jul–Sep | 08:00–20:00 | 1.5 kW, PV-aligned |
| High | Jun–Sep | 24 h | 10.2 kW |

### C7. EV charger

- Hourly energy share across opening hours (assumed):

| Hours | Share |
|---|---|
| 07–10 | 0.05 |
| 10–13 | 0.25 |
| 13–17 | 0.35 |
| 17–20 | 0.25 |
| 20–24 | 0.10 |

- Scale sessions/day by occupancy relative to the annual average: occ(d)/0.275 in Base.
- Model each session as a block of ~22 min at 60 kW (22 kWh), or use expected-value hourly energy in the LP.
- Standby: 0.607 kW during 07–24 and 0.018 kW otherwise (Base average 0.435 kW).

### C8. Security/CCTV/gates

Flat 24/7 at C8. Camera maximum ratings include IR/white light, so no separate night increment is applied.

### C9. Offices/workshop

| Period | Level |
|---|---|
| Weekdays 08:00–17:00 | 1.0 × peak (O4) |
| All other hours | 0.2 × peak |

Workshop winter extras (snowplow engine/battery heaters) are not included (gap).

---

## (d) Critical / non-critical classification

Basis:
- **NFPA 70 (NEC) Arts 700/701/702**, summarised by Mike Holt in EC&M (2006).
  - Emergency systems (Art. 700) protect people during evacuation and must transfer within 10 s.
  - Legally required standby (Art. 701) "typically supply such loads as communications systems, ventilation and smoke removal systems, sewage disposal, lighting". It may include fire pumps, and must transfer within 60 s.
  - Optional standby (Art. 702) covers "heating and refrigeration systems, data-processing systems" and any load the owner chooses.
- **NFPA 110** sets the performance of the emergency and standby power supply.
- The REopt (NREL) user manual defines critical load as "the load that must be met during a grid outage".

| Block | Class | Basis / outage strategy |
|---|---|---|
| Fire-fighting supply / booster pumps (part of water pumping) | **Critical (life safety)** | NEC Arts 695/700 and 701 (fire pumps). The pump rating must be available. Size the critical share as the booster pump(s) feeding hydrants and the fire reserve in storage. |
| Potable water pumping | **Critical, deferrable** | Public health. Storage (600 m³ if a reservoir) gives ~1.6 days at Base peak, or several days at typical occupancy. During an outage, pump only to keep the reservoir above a minimum level. In the LP, set a minimum storage S_min and use the full rating when charging. |
| WWTP (aeration, lift pumps) | **Critical, short interruptions tolerable** | NEC Art. 701 lists "sewage disposal". BGR SR16 notes poorly treated effluent reused for irrigation risks contaminating the Jeita spring (karst). Allow interruptions of a few hours. Keep lift/transfer pumps on. |
| Security, gates, CCTV, comms, guardhouses | **Critical** | NEC 701 "communications systems". Continuous estate access control and surveillance; small (1.5–5.7 kW). Gate barriers must work or fail open. |
| Road lighting | **Partly critical** | NEC 701 lists "lighting". Serve a reduced set during outages: gates, junctions, hotel access and snowplow routes (assumed ~25–35% of poles at the dimmed level). The remainder is sheddable. |
| Offices / workshop | **Partly critical** | IT/communications and workshop critical tools (and snowplow pre-heat in winter) are critical (Art. 702/701). The rest is non-critical. Assumed critical share 30%. |
| Pool filtration | Non-critical | Can stop for 1–2 days with chemical dosing. Optional standby. |
| Sports floodlights | Non-critical | Discretionary. |
| EV charger | Non-critical (curtailable) | Commercial service. Can be curtailed or set to power-limited mode. |

Peak critical-load estimate (Base, derived):

| Component | kW |
|---|---|
| Water pump (one booster) | 19.5 |
| WWTP | 1.6 |
| Security | 2.9 |
| 30% of road lighting at 70% level | 0.3 × 24.7 × 0.7 = 5.2 |
| 30% of offices peak | 2.4 |
| **Total** | **≈ 31.6** |

Peak connected load of all aux blocks together is about 142 kW (Base; sum of the Base kW column in the block summary). The critical share is therefore about 22% of peak power. It is a larger share of energy, because water pumping and security run continuously.

---

## (e) BibTeX

```bibtex
@article{Plappally2012,
  author  = {Plappally, A. K. and Lienhard V, J. H.},
  title   = {Energy requirements for water production, treatment, end use, reclamation, and disposal},
  journal = {Renewable and Sustainable Energy Reviews},
  volume  = {16}, number = {7}, pages = {4818--4848}, year = {2012},
  doi     = {10.1016/j.rser.2012.05.022},
  note    = {Sec. on groundwater: 0.00272 (theoretical) and 0.004 kWh/m3/m (empirical); Table 14: secondary treatment energy intensities}
}
@article{Longo2016,
  author  = {Longo, S. and d'Antoni, B. M. and Bongards, M. and Chaparro, A. and Cronrath, A. and Fatone, F. and Lema, J. M. and Mauricio-Iglesias, M. and Soares, A. and Hospido, A.},
  title   = {Monitoring and diagnosis of energy consumption in wastewater treatment plants. A state of the art and proposals for improvement},
  journal = {Applied Energy}, volume = {179}, pages = {1251--1268}, year = {2016},
  doi     = {10.1016/j.apenergy.2016.07.043},
  note    = {Fig. 3A: median 3.01 kWh/kgCOD (PE<2k) to 0.69 (PE>100k). Author list and pages to be checked against the publisher page}
}
@techreport{BGR2013SR16,
  author      = {{BGR} and {CDR}},
  title       = {Hazards to Groundwater and Assessment of Pollution Risk in the Jeita Spring Catchment},
  institution = {German-Lebanese Technical Cooperation Project Protection of Jeita Spring, Federal Institute for Geosciences and Natural Resources (BGR) / Council for Development and Reconstruction (CDR)},
  type = {Special Report}, number = {16}, year = {2013}, address = {Raifoun, Lebanon},
  url = {https://www.pseau.org/outils/ouvrages/bgr_special_report_no_16_hazards_to_groundwater_and_assessment_of_pollution_risk_in_the_jeita_spring_catchment_2013.pdf},
  note = {Sec. 5.1.1.1, p. 43; Figs 22--23 (Faqra Club WWTP); p. 17 (Chabrouh supplies upper Keserwan)}
}
@misc{MoEW2010NWSS,
  author = {{Ministry of Energy and Water, Lebanon}},
  title  = {National Water Sector Strategy},
  year   = {2010}, note = {Approved by Council of Ministers Decision No. 2, 9 March 2012; slides 27, 34, 35, 38},
  url    = {https://andp.unescwa.org/sites/default/files/2021-09/National%20water%20sector%20strategy.pdf}
}
@misc{FaqraClubBrochure,
  author = {{Faqra Club / Solipro}}, title = {About Faqra Club (brochure)}, year = {2016},
  url = {https://www.faqraclub.com/Content/uploads/Brochure/160504034543628~About Faqra Club.pdf},
  note = {600 m3 water treatment facility; 20 km roads; >400 families; hotel 20 rooms + 5 suites; 3 tennis courts. Year inferred from file name}
}
@techreport{Donatello2019JRC,
  author = {Donatello, S. and Rodr{\'i}guez Quintero, R. and Gama Caldas, M. and Wolf, O. and Van Tichelen, P. and Van Hoof, V. and Geerken, T.},
  title  = {Revision of the {EU} Green Public Procurement Criteria for Road Lighting and traffic signals},
  institution = {European Commission, Joint Research Centre}, number = {EUR 29631 EN, JRC115406}, year = {2019},
  doi = {10.2760/372897}, note = {p. 13: 4000 h/yr; p. 8: P-class dimming 30--35\%}
}
@techreport{LRC2011Streetlights,
  author = {{National Lighting Product Information Program}},
  title  = {Streetlights for Local Roads}, institution = {Lighting Research Center, Rensselaer Polytechnic Institute},
  type = {Specifier Reports}, volume = {14}, number = {1}, year = {2011},
  url = {https://www.lrc.rpi.edu/programs/NLPIP/pdf/print/SR_StreetlightsLocal.pdf}
}
@misc{Signify_UniStreetGen2,
  author = {{Signify}}, title = {UniStreet gen2 (BGP281/282) product family leaflet}, year = {2024},
  url = {https://www.signify.com/api/assets/v1/file/Signify/content/LP_CF_BGP281_EU.en_AA.PROF.CF/UniStreet_gen2.pdf}
}
@misc{Signify_Malaga,
  author = {{Signify}}, title = {CoreLine Malaga LED BRP102 LED58/740 I DM datasheet}, year = {2024},
  url = {https://www.signify.com/api/assets/v1/file/Signify/content/910925869859_EU.en_BG.PROF.FP/BRP102_LED58_740_I_DM.pdf}
}
@misc{LEDVANCE2024Sports,
  author = {{LEDVANCE}}, title = {Sports Facility Lighting: {LED} solutions for every application (application brochure)}, year = {2024},
  url = {https://ledvance.com/00_Free_To_Use/asset-13190195_sports_facility_lighting_application_brochure_2024.pdf}
}
@misc{LTA2026Floodlighting,
  author = {{Lawn Tennis Association}}, title = {External Floodlighting Principles (guidance note)}, year = {2026},
  url = {https://www.lta.org.uk/siteassets/roles/venues/file/floodlighting-guidance-note-2026.pdf}
}
@misc{AEF2022ChipTheCharge,
  author = {{Australian Energy Foundation} and {Tennis Victoria}}, title = {Chip the Charge: {LED} energy efficient lighting}, year = {2022},
  url = {https://www.tennis.com.au/wp-content/uploads/2023/02/EEP-LED-Energy-Efficient-Lighting.pdf}
}
@techreport{HuntEasley2012,
  author = {Hunt, A. and Easley, S.},
  title  = {Measure Guideline: Replacing Single-Speed Pool Pumps with Variable Speed Pumps for Energy Savings},
  institution = {U.S. Department of Energy, Building America (BARA)}, number = {DOE/GO-102012-3534}, year = {2012},
  url = {https://www1.eere.energy.gov/buildings/publications/pdfs/building_america/measure_guide_pool_pump.pdf}
}
@misc{DOE_FOTW1319,
  author = {{U.S. DOE Vehicle Technologies Office}}, title = {Fact of the Week \#1319: EV charging at paid DC fast charging stations average 42 minutes per session},
  year = {2023}, url = {https://www.energy.gov/cmei/vehicles/articles/fotw-1319-december-4-2023-ev-charging-paid-dc-fast-charging-stations-average}
}
@techreport{Davidson2026EVSE,
  author = {Davidson, K. and Paschedag, D. and Tolbert, I. and Jackson, D. and Gadamsetty, P. and Kogalur, N. and Gaxiola, M. and Shinde, S.},
  title  = {EVs@Scale: NextGen Profiles EVSE Characterization 2025},
  institution = {National Renewable Energy Laboratory}, number = {NLR/TP-5400-98814}, year = {2026},
  url = {https://afdc.energy.gov/files/u/publication/evs-at-scale-nextgen-profiles-evse-characterization-2025}
}
@misc{GCharge_FaqraClub,
  author = {{G Charge EV Network}}, title = {Faqra Club Charging Station}, year = {2025},
  url = {https://gchargeev.com/faqra-club-charging-station/}
}
@misc{Hikvision_G1L, author = {{Hikvision}}, title = {DS-2CD2T47G1-L 4 MP ColorVu bullet network camera datasheet}, url = {https://us-legacy.hikvision.com/sites/default/files/data_sheet/cv_ds-2cd2t47g1-l_040320na.pdf}}
@misc{Hikvision_G2VXS, author = {{Hikvision}}, title = {iDS-2CD2T47G2-V-XS datasheet}, year = {2025}, url = {https://assets.hikvision.com/prd/normal/all/doc/m000176847/iDS-2CD2T47G2-V-XS_Datasheet_20250730.pdf}}
@misc{FAAC620, author = {{FAAC}}, title = {620 road barrier technical data}, url = {https://cdn.shopify.com/s/files/1/0618/1365/3674/files/FAAC_620.pdf}}
@techreport{EEO1991ECG19,
  author = {{Energy Efficiency Office, UK Department of Energy}}, title = {Energy Consumption Guide 19: Energy efficiency in offices},
  institution = {Best Practice Programme, HMSO}, year = {1991}, url = {https://www.aivc.org/sites/default/files/airbase_5416.pdf}, note = {Table 1}
}
@misc{Holt2006NEC,
  author = {Holt, M.}, title = {Legally Required and Optional Standby Systems}, howpublished = {EC\&M (Electrical Construction \& Maintenance)}, year = {2006},
  url = {https://www.ecmweb.com/code-basics/legally-required-and-optional-standby-systems}
}
@manual{NFPA70, organization = {National Fire Protection Association}, title = {NFPA 70: National Electrical Code, Articles 695, 700, 701, 702}, year = {2023}}
@manual{NFPA110, organization = {National Fire Protection Association}, title = {NFPA 110: Standard for Emergency and Standby Power Systems}, year = {2022}}
@manual{EN12193, organization = {CEN}, title = {EN 12193:2018 Light and lighting -- Sports lighting}, year = {2018}}
@manual{EN13201, organization = {CEN}, title = {EN 13201-2:2015 Road lighting -- Part 2: Performance requirements}, year = {2015}}
@techreport{NREL2021REopt, author = {{NREL}}, title = {REopt Lite Web Tool User Manual}, institution = {National Renewable Energy Laboratory}, number = {NREL/TP-7A40-79235}, year = {2021}, note = {Sec. 8.1 critical load definition}}
@book{MetcalfEddy2003, author = {{Metcalf \& Eddy} and Tchobanoglous, G. and Burton, F. L. and Stensel, H. D.}, title = {Wastewater Engineering: Treatment and Reuse}, edition = {4th}, publisher = {McGraw-Hill}, year = {2003}, isbn = {0070418780}, note = {Typical medium-strength COD 430 mg/L: table/page NOT re-verified}}
```

Only Plappally 2012, Longo 2016 and the JRC 2019 report carry a DOI. The rest are grey literature, standards or datasheets, so they have URLs or no identifier. There is no DOI for NWSS, BGR SR16, LRC or the DOE/NREL reports. OSTI DOIs may exist for the DOE/NREL reports but were not looked up.

---

## (f) Gaps and items to verify

1. **"600 CBM" basis.** Daily WWTP capacity (preferred reading) or a reservoir volume. BGR confirms a Club WWTP exists but gives no capacity. Searching news gave nothing.
2. **Water source and head.**
   - No public source says whether the Club gets water from the Establishment of Water Beirut & Mount Lebanon network (Chabrouh), from Labbane/Assal springs, or from private wells.
   - The head (120/265/360 m) is geometric.
   - Groundwater in this karst (C2b Mdairej Formation) is deep. If wells are used, add the drawdown depth to the head (High could exceed 360 m).
3. **Non-domestic water.** Restaurants, equestrian club (horses), ski area, staff, snowmaking (none found), and irrigation reuse pumping are not included. Irrigation uses treated effluent over up to 500,000 m² of green space and could be a real summer load. It needs a head and volume, which were not found.
4. **Occupancy factors** come from chalets.md (assumed, calibrated to Alpine data). BGR Table 1 lists "Faqra" population as 3,000 (Oct–Mar) and 3,378 (May–Sep), much higher than the factors imply. That figure likely covers the wider Faqra locality and is not used.
5. **COD 430 mg/L** (Metcalf & Eddy, medium strength) was used for the High WWTP conversion. The table and page were not re-checked.
6. **MAHC turnover / 24-h recirculation requirement (§4.7.1.10)** could not be read; the PDF text was truncated. Pool volume, TDH and the number of pools are assumed.
7. **Padel court count, football pitch size, basketball count** are not published. OSM (leisure=pitch, sport=*) can fix these.
8. **EV.**
   - The G Charge page is inconsistent (60 vs 150 kW).
   - It is unclear whether "Faqra Club" and "Auberge de Faqra" are 1 or 2 units.
   - There is no utilisation data for Lebanon, so sessions/day is assumed.
   - The gchargeev.com/locations page could not be fetched (rate limited).
9. **Security.** Camera count, gate count, guardhouse load and network overhead are assumed. Only per-device ratings are verified.
10. **Offices and workshop floor area.** Take from OSM. ECG19 (1991, UK) is old and from a heating climate. An updated benchmark (CIBSE TM46/Guide F) was not fetched.
11. **Snowplow engine/battery heaters and workshop heating** (winter, nights) are not quantified.
12. **Road-lighting reality check.**
    - Pole spacing and the share of the 20 km actually lit are assumed.
    - Street View or OSM highway=street_lamp nodes would give the real pole count. The lamp type in place (LED vs HPS) is unknown.
    - The legacy HPS case (85 kW, 367 MWh) shows the stakes of this one assumption.
13. **EN 13201-2 P-class illuminance values** were not re-verified. Luminaire choices rest on datasheets and LRC spacings rather than a P-class photometric calculation.
