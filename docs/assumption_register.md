# Assumption register

Every number and modelling choice that enters the Faqra LP, with its value, source and status.
**Status:** V = verified (a source states it), D = derived from cited inputs (derivation in `docs/research/`),
A = assumed (no source found; reason given). **Backing:** strong / partial / weak, i.e. how well the literature
supports the choice. Values are base (low–high). Full citations and BibTeX are in `docs/research/*.md`.

Last updated 22 Nov 2026.

## 1. Modelling choices

| ID | Choice | Backing | Key sources | Note |
|---|---|---|---|---|
| M1 | Joint sizing + hourly dispatch as one LP, minimizing annualized cost | strong | GA course slides; Cutler 2017 (REopt, NREL/TP-7A40-70022); León 2023; Chedid 2020 | |
| M2 | Full 8,760-h year, Δt = 1 h | strong | Kotzur 2018 (representative days under-size storage); Pfenninger 2017; REopt §1.5 | |
| M3 | Representative weather year 2015 (closest to the 2014–2023 mean in annual and Dec–Mar yield) | partial | TMY selection logic (Wilcox & Marion 2008, NREL TMY3 manual); Javed 2023 | Single years under-size storage: re-run dispatch of the chosen design for all 10 years and report the worst-year LPSP (`pv_per_kWp_multiyear.csv`) |
| M4 | Reliability: energy-based LPSP ≤ 1% | partial | Borhanazad 2014 Eq. 11; Lian 2019 Eq. 1; HOMER "max annual capacity shortage"; Yang 2008 (time-based, 1–2%) | With a genset, 0% is common (Kaabeche 2014; Dufo-López 2005). Sweep LPSP over 0, 0.5, 1, 2, 5% and justify 1% as shedding of non-critical load only |
| M5 | Zero unserved critical load (hard constraint) | strong | Cutler 2017 §1.3.1; NREL FS-7A40-76676 p. 2; Anderson 2018 (critical = 30% of load); NFPA 110 / NEC 700–702 classes | |
| M6 | Bottom-up hourly load from end-use benchmarks and standard schedules, low/base/high | strong | Mandelli 2016 (LoadProGen); Lombardi 2019 (RAMP); Deru 2011 (DOE reference buildings) | |
| M7 | Satellite irradiance (PVGIS SARAH-3) scaled monthly to Solargis long-term means | partial | Polo 2016 §4.2.1 (monthly bias removal); Urraca 2018 (SARAH low over snow, ERA5 high in mountains); PVGIS docs ("snow ... may be seen as clouds") | Strict site adaptation needs ground data, which is not available. SARAH-3 unscaled (low) and PVGIS-ERA5 (high) bracket it |
| M8 | Snow loss: Marion 2013 model in pvlib form (slide 0.197·sin β per h, m = −80 W/m²/°C, 1 cm/h trigger) | strong (caveats) | Marion 2013; Holmgren 2018 (pvlib); Ryberg & Freeman 2017 | Fitted for 10–45° tilts; the hourly trigger is pvlib's adaptation of Marion's daily rule. Bounds 0% and 15% |
| M9 | Rain/snow split at 1.0 °C air temperature | strong | Jennings 2018 (Nat. Commun., global mean threshold 1.0 °C) | |
| M10 | Snow-to-liquid ratio 10:1 | weak | Baxter 2005 (13:1 more typical) | Sensitivity at 13:1 changes Dec–Mar loss by +0.3–0.4 points only |
| M11 | Linear diesel fuel F = a·u + b·P with continuous committed capacity u (P ≤ u ≤ P_rated, P ≥ 0.3u) | strong | Skarstein & Uhlen 1989 via Dufo-López 2005; HOMER manual; Palmintier & Webster 2014 | Minimum load needs binaries; the committed-capacity relaxation is the accepted LP form |
| M12 | Throughput battery degradation cost per kWh discharged, B = R/(L·√η_rt), plus a calendar-life replacement | strong | Bordin 2017 Eq. 2; Seger 2023 | |
| M13 | Grid availability from the measured EDL Faqra feeder (Nov 2025 – Oct 2026) | strong (data) / A (that the club is on this feeder) | EDL daily feeding records (edl.gov.lb/feeding.php); Chedid 2020 used measured cut-offs | Fixed 4/8/12 h blocks and a 72 h outage as sensitivities |
| M14 | Cost analysis in real USD, CRF annualization | strong | GA slides; standard engineering economics | |

## 2. Site, weather and PV

| ID | Parameter | Base (low–high) | Source | Status |
|---|---|---|---|---|
| S1 | Site 33.985 N, 35.811 E; 1,735–1,975 m | – | skiresort.com; OSM (Faqra Club node 33.984 N, 35.810 E) | V |
| S2 | Annual PV yield, tilt 40°, base irradiance, with snow | 1,497 kWh/kWp (low 1,434; high 1,736) | PVGIS v5.3 SARAH-3 × Solargis ratios; PVGIS-ERA5 | D |
| S3 | Monthly Solargis/SARAH-3 GHI ratios | 1.24, 1.12, 1.20, 1.02, 1.04, 1.04, 1.00, 1.00, 0.99, 1.03, 1.08, 1.14 | Global Solar Atlas v2 (Solargis) vs PVGIS SARAH-3 | D |
| S4 | PV system losses | 14% | PVGIS default | V |
| S5 | Dec–Mar snow loss, tilt 40° | 4.0% (0–15%) | Marion model on ERA5-Land T and ERA5 precipitation | D |
| S6 | Terrain horizon | up to 13° east, ~5° south | PVGIS horizon (SRTM) | V |
| S7 | Inter-annual spread of Dec–Mar yield, tilt 40° | 299–433 kWh/kWp (2014–2023) | PVGIS SARAH-3 multi-year | D |

## 3. Loads (annual MWh, base (low–high); details in `docs/research/`)

| ID | Block | Energy | Key parameters and sources | Status |
|---|---|---|---|---|
| L1 | Ski lifts T1–T4 | 57 (21–120) | Rise/length/capacity: skiresort.com (V). Motor kW 150/50/30/5.5: physics m·g·H·Q scaled by installed-to-lifting ratios of 5 chairlifts (Viesi 2023 Table 1) (D). No-load share 0.375: Blasuttigh 2023 (V). Skier-days 10,700: Vanat 2025 national totals (D). Weekend factor 3 (A). Hourly shape: Szlosarek 2019 Table 5 (V) | D |
| L2 | Hotel, 25 keys | 119 (49–233) | 105 kWh/m²·yr (CIBSE TM46) (V); 49.8 m²/key (Hotels4Climate, Bohdanowicz 2007) (V); 25% occupancy-dependent (D); monthly occupancy from Lebanese press and arrivals data (D/A); hourly shape: DOE small-hotel reference schedules (V) | D |
| L3 | Restaurants, 3 | 111 (31–369) | 90 kWh/m²·yr (CIBSE) (V); 3 × 511 m² (DOE reference full-service restaurant) (A); cooking on LPG excluded (MoE/UNDP 2015) (V) | D |
| L4 | Chalets, 400 | 932 (443–2,076) | 24.8 / 16.1 / 18.9 kWh per occupied day winter/summer/shoulder (World Bank 2009 Table 2.4; Houri 2005) (V); 100 occupied days/yr calibrated to Drouet 2025 (D); standby 50 W (Meier 2001) (V); profile: Spanish official P2.0TD, shifted −1 h (V/D) | D |
| L5 | Road lighting, 20 km | 93 (53–232) | 667 poles at 37 W LED (Signify datasheet, LRC spacing) (V/D); 4,314 h/yr dusk to dawn (NOAA, computed) (D); 70% dimming 00–05 (JRC 2019) (V) | D |
| L6 | Water pumping | 39 (7–153) | 180 L/person/day (MoEW NWSS 2010) (V); 3.8 persons/household (CAS) (V); 265 m head (D); 0.004 kWh/m³·m (Plappally 2012) (V) | D |
| L7 | Wastewater plant | 14 (4–51) | 0.60 kWh/m³ (Plappally 2012 Table 14) (V); flow from L6 × 0.8 (A) | D |
| L8 | Sports lights, pool, EV, security, offices | 92 (31–207) | LEDVANCE 2024; DOE pool guide; DOE EV session 22 kWh; NREL EVSE standby; Hikvision/FAAC datasheets; UK office guide. Counts of cameras, padel courts, office area and EV sessions: A | D/A |
| L9 | Critical shares | security, water, wastewater 100%; road lighting and offices 30%; hotel and restaurants 30%; lifts, chalets, pool, sports, EV 0% | NEC 700–702 / NFPA 110 classes (water_aux.md (d)); hotel/restaurant 30% matches Anderson 2018's 30% critical load (A) | D/A |
| L10 | T1 chairlift recovery drive | 30 kW, 15–45 kWh reserve during operating hours | EN 13223:2015 §6.4 (0.5 m/s, 3× recovery time) (V/D) | D |
| L11 | Totals | 1,457 MWh/yr, peak 519 kW (639 / 220 kW – 3,434 / 1,066 kW) | sum of blocks | D |

## 4. Grid, diesel, storage and economics

| ID | Parameter | Base (low–high) | Source | Status |
|---|---|---|---|---|
| G1 | EDL supply, model year | 8.1 h/day (Nov 2025 – Oct 2026); 699-day mean 9.7 | EDL feeder records | V |
| G2 | EDL tariff, MV/tourism | 0.27 $/kWh (0.27–0.37) + 0.6 $/kVA·month | EDL notice, 6 Feb 2024; high = EDL cost-recovery level | V |
| G3 | Grid export | none in base (Law 318/2023 net metering as a sensitivity) | Law 318/2023 | V |
| D1 | Diesel price | 1.41 $/L (0.80–1.52) | Lebanese price bulletins 2023–Nov 2026 | V |
| D2 | Fuel curve a, b | 0.017, 0.242 L/kWh (HOMER/Skarstein: 0.0815–0.084, 0.246) | fit to 6 genset datasheets 250–770 kVA | D |
| D3 | Minimum stable load | 30% of committed capacity | Caterpillar guidance; Dufo-López 2005 Table 5 | V |
| D4 | Genset O&M | 0.013 $/kWh (0.010–0.014) | grid_diesel.md | V/D |
| D5 | Genset capex | 750 $/kW (0 if existing units are kept) | grid_diesel.md | V |
| B1 | LFP BESS all-in capex | 192 $/kWh (125–334; course slides 350) | IRENA 2024; Ember 2025; Cole 2025 (NREL) | V |
| B2 | Split: energy + PCS | 139 $/kWh + 214 $/kW | scaled from Cole 2025 | D |
| B3 | Round-trip efficiency | 0.90 (0.85–0.93); η_ch = η_dis = 0.9487 | datasheets; GA slides | V |
| B4 | Usable SOC window | 10–100% (0–20% minimum) | datasheets | V |
| B5 | Max C-rate | 0.5C | GA slides; datasheets | V |
| B6 | Life | 15 yr (10–20), 8,000 cycles | datasheets | V |
| B7 | Degradation cost | 0.020 $/kWh discharged (0.008–0.093) | Bordin 2017 Eq. 2 with B1, B6 | D |
| B8 | Cold weather | heated enclosure assumed; capacity 87% at 0 °C as a sensitivity | LFP datasheets (EVE, CATL); lab data | V/A |
| P1 | PV capex | 750 $/kWp (600–1,003) | LCEC 2023 PV status report; IRENA 2024 | V |
| P2 | PV O&M | 18 $/kW·yr (11–22) | IRENA / NREL ATB | V |
| P3 | PV life, degradation | 30 yr, 0.7%/yr | datasheets, NREL ATB | V |
| E1 | Real discount rate | 7.1% (5.8–12.4%) | IRENA MEA WACC; World Bank 2024 Lebanon PAD; UNDP 2025 | D |
| E2 | Project life | 25 yr | common practice; PV life | A |
| E3 | Emissions | diesel 2.68 kg CO₂/L; grid 0.70 kg CO₂/kWh | EPA; IFI 2019 | V |

## 5. Known weak points to state in the paper

1. Lift motor ratings and skier numbers are benchmark-derived; no Faqra data exist.
2. Chalet occupancy and the critical share of hotel/restaurant load are assumed, calibrated to published ranges.
3. The irradiance correction uses a reference dataset, not ground measurements.
4. The club's connection to the Faqra feeder is assumed.
5. LPSP = 1% is a design choice; a sweep is reported.
