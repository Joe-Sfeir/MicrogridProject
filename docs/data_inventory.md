# Faqra Club microgrid: input data inventory (Phase 2)

Status: **Level C, scenario-based feasibility study.** No site measurements and no contact with the club.
Every input below comes from public data and is tagged **verified** (a source states it), **derived**
(computed from cited inputs) or **assumed**. Full tables, derivations, 24-hour profiles and BibTeX are in
`docs/research/*.md`.

Last updated 22 Nov 2026.

## 1. Weather and PV resource (`data/weather/`)

Site 33.985 N, 35.811 E (Faqra Club). Hourly series, 2014–2023 (PVGIS) and 2014–2025 (ERA5, ERA5-Land, NASA POWER).

| Month | GHI PVGIS-SARAH3 | GHI PVGIS-ERA5 | GHI NASA POWER | T ERA5-Land (1,710 m) | PV 40° SARAH3 | PV 40° ERA5 |
|---|---|---|---|---|---|---|
| Jan | 1.77 | 2.97 | 2.65 | 1.8 | 1.95 | 3.98 |
| Feb | 2.63 | 4.00 | 3.58 | 2.4 | 2.65 | 4.65 |
| Mar | 3.64 | 5.05 | 4.77 | 5.4 | 3.23 | 4.90 |
| Apr | 5.70 | 6.59 | 6.26 | 9.5 | 4.44 | 5.27 |
| May | 7.10 | 7.52 | 7.35 | 13.7 | 4.84 | 5.14 |
| Jun | 8.06 | 8.11 | 8.10 | 17.6 | 5.05 | 5.08 |
| Jul | 8.27 | 8.13 | 7.98 | 20.4 | 5.24 | 5.14 |
| Aug | 7.45 | 7.41 | 7.15 | 20.7 | 5.31 | 5.30 |
| Sep | 6.08 | 6.20 | 6.07 | 18.4 | 5.12 | 5.34 |
| Oct | 4.23 | 4.54 | 4.56 | 13.9 | 4.20 | 4.76 |
| Nov | 2.83 | 3.26 | 3.20 | 8.4 | 3.25 | 4.09 |
| Dec | 1.94 | 2.62 | 2.50 | 4.4 | 2.25 | 3.61 |
| **Year** | | | | | **1,449 kWh/kWp** | **1,742 kWh/kWp** |

GHI in kWh/m²/day, T in °C, PV in kWh/kWp/day (1 kWp, 14% system loss, terrain horizon on, no snow loss).

- **Key finding: the satellite and reanalysis sources agree within ~5% from May to September but differ by
  30–40% in December–March.** PVGIS's own documentation warns that with snow on the ground the satellite method
  "may be seen as clouds ... which then calculates too low irradiance", so SARAH-3 is likely too low in winter.
  ERA5 tends to read high in mountain areas (same documentation). The true winter resource is probably between them.
  This matters most, because winter is the binding season.
- **Tilt (SARAH-3):** annual yield is highest at 30° (1,484 kWh/kWp); Dec–Feb yield is flat from 40° to 60°
  (205–208 kWh/kWp) versus 198 at 30°. Steeper tilt also sheds snow faster (Marion 2013).
- **Horizon:** the terrain blocks the east up to 13° (Sannine ridge) and the south by about 5°; included in all PVGIS series.
- **Temperature:** use ERA5-Land downscaled to 1,710 m. NASA POWER's temperature is ~10 °C too warm in winter
  (its grid cell is at low elevation), so NASA is used for irradiance cross-checks only.
- **Snow:** reanalysis snow depth is unusable at this site (ERA5-Land peaks at 0.4 m, ERA5 at 0; field
  observations give 53–76 cm median depth, Fayad 2017). Snow loss will be modelled with the Marion method driven
  by ERA5-Land temperature and ERA5 precipitation/snowfall timing, bounded by the 0 / 3–8 / 15% loss scenarios.
- Not possible: a ground-station check against the World Bank ESMAP Lebanon stations (Ras Baalbak, Tal Amara),
  because energydata.info requires a login to download.

## 2. Site geometry (`data/site/`, OpenStreetMap)

- **Faqra's four lifts are not mapped in OSM** (all mapped lifts in the area belong to Mzaar Kfardebian).
  Lift geometry comes from skiresort.com: T1 880 m / 240 m rise, T2 540 m / 140 m, T3 410 m / 150 m, T4 230 m / 30 m.
- Within 0.8–1.2 km of the club: 422–586 buildings, median footprint 172–175 m², and 15–23 km of residential
  road. This agrees with the club's own figures (20 km of lit roads, 350–450 chalets of 200–220 m²).

## 3. Load blocks (`docs/research/`)

Annual energy in MWh/yr. Low and high are each block's own extremes, so the totals are outer bounds rather than
a coherent scenario. The coincident peak comes from the hourly build (next step), not from adding block peaks.

| Block | Low | Base | High | Block peak, base | Critical in outage | Main basis |
|---|---|---|---|---|---|---|
| Ski lifts T1–T4 | 21 | 57 | 120 | 102 kW (weekend); 208 kW at full capacity | T1 recovery drive, ~30 kW for 30–90 min | Physics (mgHQ) scaled by measured chairlift ratios (Viesi 2023); no-load share (Blasuttigh 2023); 10,700 skier-days (Vanat 2025) |
| Hotel, 25 keys | 49 | 119 | 233 | 25 kW | Essentials (lighting, refrigeration, fire) | CIBSE / Hotels4Climate / Bohdanowicz 2007; 75% fixed load; monthly occupancy from Lebanese press and arrivals |
| Restaurants, 3 | 31 | 111 | 369 | 25 kW | Refrigeration | CIBSE, German and US benchmarks; cooking on LPG excluded |
| Road lighting, 20 km | 53 | 93 | 232 | 25 kW | ~30%, dimmed | 501–801 LED poles at 31–67 W; 4,314 h/yr dusk to dawn |
| Water pumping | 7 | 39 | 153 | 20 kW | Yes | 140–220 L/person/day; 120–360 m head; 0.004 kWh/m³ per m (Plappally 2012) |
| Wastewater plant ("600 m³") | 4 | 14 | 51 | 1.6 kW | Yes (short gaps tolerable) | 0.33–0.60 kWh/m³ (Plappally 2012) |
| Sports lights, pool, EV, security, offices | 31 | 92 | 207 | EV 64.5 kW AC; others < 20 kW | Security and IT | Datasheets; DOE pool guide; DOE EV sessions |
| **Club total (base boundary)** | **196** | **525** | **1,365** | | **~60–90 kW (rough)** | |
| Chalets, 350–400 (separate case) | 445 | 938 | 2,085 | 394 kW (ski Saturday evening) | No | World Bank 2009, Houri 2005; 100 occupied days (Drouet 2025) |

Cross-check: Elie's two desk studies gave 0.3 / 0.6–0.9 / 1.3–1.8 GWh for the club loads; our base of 0.53 GWh
sits at the low end of that range, mainly because our lift energy is lower (low skier traffic means short
operating hours at part load).

## 4. Grid availability and tariffs (`data/grid/`)

- **Measured grid availability for the area:** EDL publishes hourly on/off records for each 20 kV feeder.
  The **Faqra feeder** of the Faitroun substation has 699 days of data (Dec 2024 – Oct 2026):
  mean 9.7 h/day (9.0 h/day in Dec–Mar), 10% of days with no supply at all, seven outages of 72 h or more
  (longest 102 h, March 2025). Supply is most likely 03:00–12:00 (~50%) and least likely 14:00–20:00 (~28%).
  *Assumption:* the club is supplied from this feeder; unverified.
- EDL MV/tourism tariff (EDL notice, 6 Feb 2024): 0.27 $/kWh flat + 0.6 $/kVA/month; no time-of-use rate.
- Private generator tariff above 700 m: 0.65 $/kWh (MoEW, Sept 2026); used only as a benchmark.

## 5. Diesel generator

| Parameter | Low | Base | High | Source |
|---|---|---|---|---|
| Diesel price ($/L) | 0.80 | 1.41 | 1.52 | Lebanese price bulletins, 2023–Nov 2026 |
| Fuel curve intercept a (L/h per kW rated) | 0.005 | 0.017 | 0.081 | Fit to 6 datasheets, 250–770 kVA (Cummins, CAT, Perkins); high = HOMER default |
| Fuel curve slope b (L/kWh) | 0.225 | 0.242 | 0.255 | Same fit (HOMER 0.246) |
| O&M ($/kWh) | 0.010 | 0.013 | 0.014 | |
| Capex ($/kW) | 94 | 750 | 800 | Existing sets: sunk cost |
| Minimum stable load | 30% | | | Caterpillar; cannot be enforced in a pure LP, checked after optimization |
| Emissions | 2.68 kg CO₂/L diesel; grid 0.70 kg CO₂/kWh | | | EPA; IFI 2019 |

## 6. PV, battery and economics

| Parameter | Low | Base | High | Source |
|---|---|---|---|---|
| PV capex ($/kWp) | 600 | 750 | 1,003 | LCEC 2023 Lebanon PV status report; IRENA 2024 |
| PV O&M ($/kW-yr) | 11 | 18 | 22 | |
| PV life (yr) / degradation (%/yr) | 25 / 0.5 | 30 / 0.7 | 35 / 0.88 | |
| LFP BESS all-in ($/kWh) | 125 | 192 | 334 | Ember 2025 / IRENA 2024 / NREL (Cole 2025). Course slides use 350. |
| Split form: energy ($/kWh) + PCS ($/kW) | 90 + 139 | 139 + 214 | 241 + 372 | High pair from Cole 2025; others scaled |
| BESS life (yr) / cycles | 10 / 3,500 | 15 / 8,000 | 20 / 10,000 | Datasheets |
| Round-trip efficiency | 0.85 | 0.90 | 0.93 | Course slides use 0.90 |
| Degradation cost ($/kWh discharged) | 0.008 | 0.020 | 0.093 | Derived, HOMER wear-cost form; linear form per Seger 2023 |
| Cold: no charging below 0 °C cell temperature; capacity 87% at 0 °C | | | | LFP datasheets (EVE, CATL); outdoor containers rated −30 to 50 °C |
| Real discount rate | 5.8% | 7.1% | 12.4% | IRENA, World Bank 2024 Lebanon PAD, UNDP 2025 |
| CRF at 7.1%: 10 / 15 / 20 / 25 yr | 0.143 / 0.111 / 0.095 / 0.087 | | | Derived |

## 7. Open decisions

1. **Chalets:** keep them out of the base boundary and run them as a separate case (they double the energy).
2. **Winter irradiance:** use SARAH-3 as the conservative base and ERA5 as the optimistic case, or the mean of the two.
3. **Grid availability:** use the measured Faqra-feeder year (Nov 2025 – Oct 2026) as u_g(t) in the base case,
   with fixed 4/8/12 h blocks and a 72 h outage as sensitivities.
4. **Battery cost:** base 192 $/kWh all-in from current sources vs 350 $/kWh on the course slides (to confirm with the GA).
5. **Time resolution:** full 8,760-hour year.

## 8. Known gaps

Faqra's lift motor ratings and build years; the club's water source and pumping head; the meaning of "600 m³";
pool size; EV sessions per day; whether the club is on the Faqra feeder; Lebanese hourly load curves (US and
Spanish shapes are used and shifted); summer chalet profile; bulk diesel price for businesses.
