# Hotel and restaurant electricity demand for Faqra Club (L'Auberge de Faqra, 25 keys, plus 3 restaurants)

Prepared for EECE 675 (LP microgrid feasibility study). Research date: 22 Nov 2026.
Scope: **electricity only**. Space heating, domestic hot water (DHW) and cooking are excluded wherever the evidence supports it, because in Lebanon these loads run on diesel and LPG (see §B.4).

Status legend:
- **verified**: the value was read in the cited source during this research.
- **derived**: computed from verified values, with the derivation shown in §B.
- **assumed**: no source was found, so the value is a modelling choice that must be stated in the report.

The calculation scripts are in the repository:
- `tools/research/hotel_profiles.py`
- `tools/research/hotel_calc.py`

The profile output is in `data/hotel_restaurant_profiles.json`.

---

## (a) Parameter table

### A.1 Hotel (L'Auberge de Faqra: 20 rooms + 5 suites = 25 keys)

| Parameter | Low | Base | High | Unit | Source (short cite + page/table) | Status |
|---|---|---|---|---|---|---|
| Gross floor area per key | 25 | 49.8 | 77.1 | m²/key | Low: Hotels4Climate A1.1, p.22, mountain 4★ hotel, 5,261 kWh/room ÷ 210 kWh/m². Base: Bohdanowicz & Martinac 2007, Table 3, Scandic means, 14.2 MWh/room ÷ 285 kWh/m². High: same table, Hilton, 28.1 MWh/room ÷ 364.3 kWh/m². | derived. Replace with the OSM footprint × floors when available. |
| Hotel gross floor area (25 keys) | 625 | 1,245 | 1,927 | m² | area per key × 25 | derived |
| Electricity intensity, excluding heating, DHW and cooking (at benchmark occupancy) | 86 | 105 | 130 | kWh/m²·yr | Low: Hotels4Climate mountain hotel, 210 kWh/m² × 41% non-thermal end uses (Fig. 9, p.26). Base: CIBSE TM46:2008 Table 1, "Hotel", typical electricity. High: EIA CBECS 2018 Table C14, lodging 14.4 kWh/ft² = 155 kWh/m², × 0.84 (Table E5, excluding space heating 7, water heating 5 and cooking 4 of 100). | low/high derived; base verified (via secondary reproduction of TM46) |
| Lower reference (official DE) | 24.5 (no cooling) to 30.9 | | | kWh/m²·yr (net floor area) | BMWi/BMI Bekanntmachung 15.04.2021, Anlage 1 Tab. 1, row 36 "Hotels/Pensionen", electricity partial values: ventilation 9.1 + lighting 8.6 + cooling 3.5 + cooling auxiliary 2.9 + other 6.8 | verified (sum derived). Shown for context only; not used. |
| Occupancy-dependent share of hotel electricity | 15 | 25 | 35 | % | Bohdanowicz & Martinac 2007, eqs. (1)–(2): marginal energy is 0.003 MWh per guest-night and floor area is the dominant regressor. Arenhart et al. 2024, Table 2: pooled correlation between occupancy and hotel energy r = 0.20 (not significant). | derived |
| Benchmark reference occupancy (occ_ref) | 0.75 | 0.75 | 0.75 | – | Hotels4Climate A1.1, Table 15: 4★ annual occupancy 60–87% (CY) and 70–92% (GR). Midpoint ≈ 0.75. | derived |
| Annual mean occupancy, Faqra | 0.31 | 0.48 | 0.60 | – | §D | derived/assumed |
| **Hotel annual electricity** | **49** | **119** | **233** | MWh/yr | calc.py: area × EUI × [(1−f_v) + f_v·occ/occ_ref], summed by month and weekday/weekend | derived |
| Per key | 1.96 | 4.76 | 9.32 | MWh/key·yr | as above | derived |
| Per occupied room-night | 17.4 | 27.2 | 42.6 | kWh/occupied room-night | as above | derived |
| Cross-check: electricity per guest-night | | ≈16.8 | | kWh/guest-night | Hotels4Climate mountain hotel, 40.9 kWh/GN × 41% non-thermal share. With 1.6–1.7 guests per occupied room (assumed), this gives about 27–29 kWh per occupied room-night, which matches the base case. | derived |
| **Hotel peak demand** | **9.5** | **25** | **50** | kW | peak day (ski weekend, occupancy capped at 100%) × hotel-profile peak/mean of 1.55–1.60 | derived |
| Cross-check: ITP rule, peak = annual / 5,000 h | 9.8 | 23.8 | 46.6 | kW | ITP, *Sustainable Hotel Siting, Design and Construction* (2005), Ch. 9, p.4: "Electricity: 5,000 hours" full-load hours | verified rule; values derived |
| Hotel mean load | 5.6 | 13.6 | 26.6 | kW | annual / 8,760 | derived |
| Hourly profile peak/mean | 1.55 | 1.59 | 1.60 | – | §C | derived |

### A.2 Restaurants (Le Grill, People, Khaymeh), excluding the Panorama events venue

| Parameter | Low | Base | High | Unit | Source | Status |
|---|---|---|---|---|---|---|
| Floor area per restaurant | 232 | 511 | 511 | m² | DOE Commercial Reference Buildings (OpenEI wiki): Quick Service Restaurant 2,500 ft², Full Service Restaurant 5,500 ft² | verified (US prototypes). Replace with OSM. |
| Total restaurant area (×3) | 697 | 1,533 | 1,533 | m² | ×3 | assumed basis |
| Electricity intensity, excluding cooking, space heating and DHW (year-round operation) | 65.7 | 90 | 270 | kWh/m²·yr | Low: Bekanntmachung 2021, Anlage 1, row 38 "Gaststätten": 13.7 + 19.7 + 3.8 + 3.3 + 25.2. Base: CIBSE TM46 Table 1, "Restaurant", electricity 90 (UK; cooking mostly gas). High: CBECS 2018 C14, food service 43.8 kWh/ft² = 471 kWh/m², × 35/61 (Table E5, excluding cooking 10, space heating 4, water heating 3 and cooling 7). | low/high derived; base verified (secondary) |
| CBECS variant including cooling | | | 325 | kWh/m²·yr | 471 × 42/61 | derived |
| Fixed (activity-independent) share | 46 | 46 | 46 | % | CBECS 2018 E5: refrigeration 16 of the 35 bn kWh non-cooking, non-thermal electricity in food service | derived |
| Activity proxy | as hotel occupancy | | | – | LBCI 17 Jan 2024: about 200 restaurants around the ski centres reach 80% demand in season, with minimal demand off-season | verified anchor |
| **Restaurant annual electricity (3 restaurants)** | **31** | **111** | **369** | MWh/yr | calc.py | derived |
| **Restaurant peak demand (3 restaurants)** | **6.6** | **25** | **79** | kW | calc.py; profile peak/mean 1.26–1.42 | derived |
| Hourly profile peak/mean | 1.26 | 1.27 (winter) / 1.42 (summer) | 1.42 | – | §C | derived |
| Panorama venue (up to 750 guests), if modelled | – | ≈1,045 m² net dining | – | m² | 750 × 15 ft² net per occupant (IBC Table 1004.5, "unconcentrated (tables and chairs)", as reproduced in WAC 51-54A-1004) | derived. Event-driven, so model it separately (gap). |

### A.3 Evidence values not used directly but recommended for citation

| Quantity | Value | Source | Status |
|---|---|---|---|
| Hilton / Scandic total energy (2004), mean | 364.3 / 285.0 kWh/m²·yr; 28.1 / 14.2 MWh/room·yr; 89.5 / 47.8 kWh/GN (medians 79.5 / 45.4) | Bohdanowicz & Martinac 2007, Table 3 (N = 184) | verified |
| Regression models of total energy | E_upscale = 0.227A + 0.003gn + 0.003fc + 0.006l + 1142 (R² 0.75); E_mid = 0.177A + 244.6hc + 0.003gn + 0.009fc − 66.9 (R² 0.83), in MWh | Bohdanowicz & Martinac 2007, eqs. (1)–(2) | verified |
| Hotels4Climate category KPIs (total energy) | 4★ seasonal / 4★ non-seasonal / 5★ non-seasonal: 22.9 / 29.8 / 39.5 kWh/GN; 150.6 / 247.1 / 352.9 kWh/m²; 7,454 / 11,263 / 17,293 kWh/room | Kastanias (OEB) 2021, slide 24 | verified |
| Mountain hotel end-use split (total energy) | cooling/ventilation 10%, heating 45%, DHW 14%, lighting 7%, process 21%, other 3% | Hotels4Climate A1.1, Fig. 9, p.26 | verified (read from chart labels) |
| LPG in Cypriot/Greek hotels | "main source in kitchens", about 10% of hotel energy | Hotels4Climate A1.1, p.16 | verified |
| US lodging electricity by end use, 2018 (bn kWh) | total 100: space heating 7, cooling 12, ventilation 25, water heating 5, lighting 15, cooking 4, refrigeration 8, office 1, computing 2, other 21 | EIA CBECS 2018, Table E5 | verified |
| US food service electricity by end use, 2018 (bn kWh) | total 61: space heating 4, cooling 7, ventilation 7, water heating 3, lighting 4, cooking 10, refrigeration 16, other 8 | EIA CBECS 2018, Table E5 | verified |
| US electricity intensity, 2018 | food service 43.8 kWh/ft² (212 MWh per building); lodging 14.4 kWh/ft² (484 MWh per building) | EIA CBECS 2018, Table C14 | verified |
| US chain restaurants (n = 888) | about 83–115 kWh/ft²·yr electricity by store type; mean about 103 | Hedrick, Smith & Field 2011, NREL/SR-5500-50547, Table 2-1, p.9 (ratio of means computed by me) | derived |
| UK fast-food benchmark | 890 kWh/m² typical, 820 good practice; kitchen basis about 4,750 kWh/m² of kitchen | as cited in Eid et al. 2025 (Energies 18:1377) | verified (secondary) |
| Lebanese hotels (26 surveyed, 2012) | 36.24 MWh/room·yr average **total** energy (EDL + generator + boiler diesel + LPG), range 1 to over 100; 2,183 L diesel per room·yr; 5★ highest | MoE/UNDP 2015, *Energy consumption in the commercial and institutional sector*, §4.5, Fig. 4-7 | verified |
| Lebanese LPG use | C&I sector used 30,053 t LPG (2012), 84% of it by restaurants; LPG "mainly used in kitchens in restaurants, hotels, and hospitals" | MoE/UNDP 2015, §3.4, Fig. 3-8 | verified |
| Lebanese boiler diesel | 170,584 t diesel for thermal use in C&I; hotels' share is higher for boiler diesel than for generator diesel (hotels > 25% of water-heating diesel) | MoE/UNDP 2015, §3.3, Fig. 3-6 | verified |
| Restaurants' reliance on private generation | 39% of electricity | MoE/UNDP 2015, §4.1, Fig. 4-1 | verified |
| Full-service hotel (US, about 300 rooms), daily load | load curve "relatively flat" in all seasons and on all days; about 400 kW base load against about 200 kW peak cooling | Placet et al. 2010, ACEEE Summer Study | verified (qualitative) |

---

## (b) Derivation notes

**B.1 Hotel electricity intensity**

- **Low, 86 kWh/m².** Hotels4Climate's only mountain hotel (Cyprus, 4★, year-round) uses 210 kWh/m²·yr of total energy. Its end-use split (Fig. 9) is: heating 45%, DHW 14%, cooling/ventilation 10%, lighting 7%, process 21%, other 3%.
  - In Faqra, heating and DHW run on diesel or fireplaces (§B.4). The remaining shares are 10 + 7 + 21 + 3 = 41%, and 210 × 0.41 = 86 kWh/m².
  - "Process" includes kitchens, which partly use LPG, so 86 is an upper estimate for this building and works as a "low" scenario only together with the small area per key.
- **Base, 105 kWh/m².** This is the CIBSE TM46 "Hotel" typical electricity benchmark. UK hotels heat mainly with gas (the fossil-thermal benchmark is 330), so the 105 figure is close to "electricity without heating, DHW or most cooking". That matches Faqra's fuel situation.
- **High, 130 kWh/m².** CBECS 2018 lodging uses 14.4 kWh/ft² × 10.764 = 155 kWh/m². Removing electric space heating (7%), water heating (5%) and cooking (4%) leaves 84%, which gives 130 kWh/m².
  - This value keeps cooling (12%), which a 1,800 m site barely needs. Keeping it is a conservative margin for summer and for ventilation.
- **Occupancy adjustment.** The benchmarks describe hotels at normal occupancy (taken as 0.75; §A.1). Faqra's annual occupancy is about 0.48, so the monthly electricity is
  `E_m = E_ref/365 × d_m × [(1 − f_v) + f_v × occ_m / 0.75]`.
- **Derivation of the variable share f_v = 0.25.** Bohdanowicz & Martinac's regression gives a marginal 3 kWh of **total** energy per guest-night. Floor area is the dominant regressor, and guest-nights have low t-values (0.29 and 0.57).
  - Relative to roughly 16 kWh/GN of electricity (A.1 cross-check), 3/16 ≈ 19%. Adding the food-cover effect (another 3–9 kWh per cover in total energy) gives about 25%.
  - The 2024 meta-analysis (Arenhart et al.) found no significant pooled correlation between occupancy and hotel energy (r = 0.20, p = 0.08). This supports a mostly fixed load.
- **Hotel peak.** The peak is the largest hourly value over all days:
  `daily energy (month, day type) × max(hourly fraction)`.
  - The maximum falls on a February ski weekend, when weekend occupancy is capped at 100%. That cap is consistent with LBCI's "fully booked on weekends" (17 Jan 2024).
  - Cross-check: the ITP design rule (5,000 full-load hours) gives 23.8 kW against 25.0 kW in the base case.

**B.2 Restaurant intensity and floor area**

- **Floor-area basis.** No restaurant capacities are published on the Faqra Club site, and OSM footprints are pending. The base case therefore uses the DOE Full Service Restaurant prototype (5,500 ft² = 511 m²) for each of the 3 restaurants. The low case uses the Quick Service prototype (2,500 ft² = 232 m²).
- **Intensity range.** TM46 Restaurant electricity (90) is the base, because UK restaurant cooking is predominantly gas, like LPG in Lebanon.
  - The German official partial values for "Gaststätten" (electric part 65.7) are the low case.
  - CBECS 2018 food service with cooking, space heating, DHW and cooling removed (270) is the high case. US restaurants have long hours, heavy refrigeration and partly electric kitchens, so it sits well above European values.
- **Fixed share 46%.** In CBECS, refrigeration is 16 of the 35 bn kWh of non-cooking, non-thermal food-service electricity. Refrigeration runs around the clock whether or not the restaurant is busy.
- **Activity.** Restaurant activity follows the same monthly occupancy factors as the hotel (§D). This is supported by LBCI's report of about 80% restaurant demand in the ski season and minimal demand off-season.
- **If the restaurants close completely in some months**, which no source confirms, set the activity to 0 and keep only refrigeration, or none at all.

**B.3 Panorama events venue**

- Up to 750 guests × 15 ft² net per occupant (IBC "unconcentrated, tables and chairs") gives 11,250 ft² ≈ 1,045 m² of dining floor.
- The load is driven by events. No source gives event frequency, so it is not in the restaurant totals.
- If included at the base intensity (90 kWh/m²·yr) for year-round operation, it would add up to about 94 MWh/yr. That is an upper bound for a venue used only at events.

**B.4 Heating fuel: do not count electric heating (base case)**

- **Hotels.** In Lebanese commercial and institutional buildings, boilers are "almost entirely diesel-fired, with a few using LPG, biomass, or solar". Hotels hold a larger share of boiler (water and space heating) diesel than of generator diesel (MoE/UNDP 2015, §3.3 and §4.3).
- **Cooking.** LPG is "mainly used in kitchens in restaurants, hotels, and hospitals", and restaurants use 84% of C&I-sector LPG (MoE/UNDP 2015, §3.4). Households (MICS 2011 Palestinian camps survey, HC6) cook with LPG in 98.1% of cases; that sample is not representative of Faqra, but it shows the national norm.
- **Residential heating.** The UNSD/ESCWA 2019 mission report says LPG is used "for space and water heating", gas/diesel oil is used for space and water heating, and fuelwood is used mostly by households for heating. It also says the quantities are not compiled.
- **No quantitative national split of heating fuels was found**, in any official or peer-reviewed source; see the gaps in §F.
- **Decision for the model.** Exclude electric space heating and DHW from the hotel and restaurant electricity, consistent with the diesel boilers and fireplaces stated in the brief.
- **Sensitivity.** If the hotel heats with electric heat pumps or heaters, add a heating load. The Hotels4Climate mountain hotel has 45% of 210 kWh/m² for heating, which is about 95 kWh/m² of thermal energy. Divide by a COP of about 2.5–3 for heat pumps, or use about 1 for resistance heating. This would roughly double the winter hotel electricity.

---

## (c) Normalized 24-h profiles (fractions of daily energy; each column sums to 1)

**Basis (derived).** Each profile is an energy-weighted mix of end-use schedules from the US DOE/PNNL ASHRAE 90.1 prototype buildings, taken from the NREL openstudio-standards `ashrae_90_1.schedules.json` file (notes field "From DOE Prototype Buildings").

- **Hotel ("HotelSmall") schedules and weights.** Weights are the CBECS 2018 Table E5 lodging end-use energies, with heating, water heating, cooking and cooling removed.
  - Ventilation and pumps: 25, flat.
  - Interior lighting: 12, `BLDG_LIGHT_GUESTROOM_SCH_2010`.
  - Exterior lighting: 3, on between sunset and sunrise. Sun times were computed with the NOAA solar algorithm for 33.985 N, 35.811 E:
    - 15 Jan: sunrise 06:42, sunset 16:49 (UTC+2).
    - 15 Jul: sunrise 05:36, sunset 19:49 (UTC+3).
  - Refrigeration: 8, flat.
  - Office: 3, `Lobby_Eqp_Sch`.
  - Plug loads and other: 21, `GuestRoom_Eqp_Sch_Base`.
  - The 80/20 split of lighting into interior and exterior is an assumption.
- **Restaurant ("RestaurantSitDown") schedules and weights.** Weights are the CBECS 2018 Table E5 food-service end-use energies.
  - Refrigeration: 16, flat.
  - Ventilation: 7, `HVACOperationSchd`.
  - Lighting: 4, `BLDG_LIGHT_DINING_SCH_2013`.
  - Other: 8, `BLDG_EQUIP_SCH`.
  - Summer only, cooling: 7, shaped by `BLDG_OCC_SCH`.
- **Day types.** Hotel weekday = `Wkdy` and weekend = `Default`. Restaurant weekday = `Wkdy` and weekend = `Sat`. Lebanon's weekend is Saturday and Sunday.
- **Seasons.** Winter applies Oct–Apr and summer May–Sep. For the hotel, only the exterior-lighting hours differ between seasons. For the restaurant, cooling is added in summer.

| Hour | Hotel winter weekday | Hotel winter weekend | Hotel summer weekday | Hotel summer weekend | Restaurant winter weekday | Restaurant winter weekend | Restaurant summer weekday | Restaurant summer weekend |
|---|---|---|---|---|---|---|---|---|
| 00-01 | 0.0307 | 0.0308 | 0.0319 | 0.0321 | 0.0320 | 0.0325 | 0.0276 | 0.0281 |
| 01-02 | 0.0299 | 0.0308 | 0.0311 | 0.0321 | 0.0215 | 0.0215 | 0.0179 | 0.0179 |
| 02-03 | 0.0289 | 0.0286 | 0.0301 | 0.0298 | 0.0220 | 0.0221 | 0.0184 | 0.0184 |
| 03-04 | 0.0289 | 0.0286 | 0.0301 | 0.0298 | 0.0215 | 0.0215 | 0.0179 | 0.0179 |
| 04-05 | 0.0289 | 0.0286 | 0.0301 | 0.0298 | 0.0232 | 0.0233 | 0.0193 | 0.0194 |
| 05-06 | 0.0328 | 0.0307 | 0.0324 | 0.0303 | 0.0376 | 0.0373 | 0.0323 | 0.0311 |
| 06-07 | 0.0560 | 0.0431 | 0.0540 | 0.0410 | 0.0397 | 0.0391 | 0.0351 | 0.0336 |
| 07-08 | 0.0662 | 0.0521 | 0.0662 | 0.0521 | 0.0409 | 0.0402 | 0.0420 | 0.0436 |
| 08-09 | 0.0472 | 0.0644 | 0.0472 | 0.0644 | 0.0442 | 0.0445 | 0.0447 | 0.0472 |
| 09-10 | 0.0472 | 0.0532 | 0.0472 | 0.0532 | 0.0459 | 0.0462 | 0.0462 | 0.0466 |
| 10-11 | 0.0340 | 0.0360 | 0.0340 | 0.0360 | 0.0511 | 0.0508 | 0.0466 | 0.0463 |
| 11-12 | 0.0336 | 0.0346 | 0.0336 | 0.0346 | 0.0529 | 0.0525 | 0.0540 | 0.0528 |
| 12-13 | 0.0336 | 0.0346 | 0.0336 | 0.0346 | 0.0517 | 0.0513 | 0.0590 | 0.0529 |
| 13-14 | 0.0336 | 0.0346 | 0.0336 | 0.0346 | 0.0506 | 0.0502 | 0.0560 | 0.0519 |
| 14-15 | 0.0336 | 0.0346 | 0.0336 | 0.0346 | 0.0494 | 0.0490 | 0.0491 | 0.0479 |
| 15-16 | 0.0336 | 0.0346 | 0.0336 | 0.0346 | 0.0494 | 0.0490 | 0.0451 | 0.0469 |
| 16-17 | 0.0342 | 0.0351 | 0.0336 | 0.0346 | 0.0511 | 0.0508 | 0.0476 | 0.0484 |
| 17-18 | 0.0456 | 0.0426 | 0.0426 | 0.0396 | 0.0511 | 0.0516 | 0.0525 | 0.0491 |
| 18-19 | 0.0538 | 0.0551 | 0.0508 | 0.0521 | 0.0500 | 0.0504 | 0.0575 | 0.0562 |
| 19-20 | 0.0571 | 0.0569 | 0.0549 | 0.0547 | 0.0488 | 0.0493 | 0.0566 | 0.0593 |
| 20-21 | 0.0652 | 0.0628 | 0.0665 | 0.0641 | 0.0477 | 0.0481 | 0.0556 | 0.0542 |
| 21-22 | 0.0646 | 0.0642 | 0.0659 | 0.0655 | 0.0465 | 0.0470 | 0.0487 | 0.0523 |
| 22-23 | 0.0481 | 0.0495 | 0.0494 | 0.0508 | 0.0382 | 0.0384 | 0.0388 | 0.0431 |
| 23-24 | 0.0331 | 0.0337 | 0.0344 | 0.0350 | 0.0331 | 0.0333 | 0.0316 | 0.0348 |
| Peak/mean | 1.59 | 1.55 | 1.60 | 1.57 | 1.27 | 1.26 | 1.42 | 1.42 |

**How to use the profiles.** `P(t) [kW] = E_day(month, day type) [kWh] × fraction(hour)`, where E_day comes from §A and §D.

**Raw source schedules**, for the appendix; values are fractions of design load, hours 0–23.

- Hotel guest-room equipment, weekday:
  0.11×6, 0.62, 0.90, 0.43, 0.43, 0.26×7, 0.51, 0.51, 0.49, 0.66, 0.70, 0.35, 0.11.
- Hotel guest-room lighting (2010), weekday:
  0.1859, 0.1452, 0.0945×3, 0.1859, 0.4121, 0.5259, 0.4121, 0.4121, 0.2087×6, 0.2130, 0.2149, 0.6297, 0.8342, 0.9380, 0.8342, 0.6297, 0.3083.
- Hotel guest-room occupancy, weekday:
  1.0×6, 0.77, 0.43, 0.43, 0.20×6, 0.31, 0.54×3, 0.77, 0.77, 0.89, 1.0, 1.0.
- Sit-down restaurant occupancy, weekday:
  0.05, 0×4, 0.05, 0.10, 0.40×3, 0.20, 0.50, 0.80, 0.70, 0.40, 0.20, 0.25, 0.50, 0.80×3, 0.50, 0.35, 0.20.
- Sit-down restaurant occupancy, Saturday:
  0.05, 0×5, 0.05, 0.50, 0.50, 0.40, 0.20, 0.45, 0.50, 0.50, 0.35, 0.30, 0.30, 0.30, 0.70, 0.90, 0.70, 0.65, 0.55, 0.35.

**Caveat.** These are US prototype schedules. Lebanese dinner service typically runs later (about 20:00–24:00), and no measured Lebanese profile was found. A defensible sensitivity case is to shift the restaurant evening block 1–2 h later.

---

## (d) Monthly occupancy factors (hotel occupancy; also used as the restaurant activity proxy)

**Evidence found**

| Evidence | Value | Source | Status |
|---|---|---|---|
| Kfardebian hotels (12 of 19), Feb 2026 | 75% occupancy | LBCI, 9 Feb 2026, "In the numbers: Lebanon's winter tourism rebounds…" (LBCI statistics) | verified |
| Higher Keserwan, Feb 2026 bookings (includes Kfardebian) | 70% | same article, citing the Lebanese Hotel Association | verified |
| Ski-season weekends | hotels and guesthouses "fully booked", 100% | LBCI, 17 Jan 2024 | verified |
| Summer 2025, regional (non-Beirut) | "exceeded 60%" (Beirut 80–90% from 10 Jul) | Achkar, Hotel Owners Syndicate, via LBCI 27 Aug 2025 and TravelMole 2 Sep 2025 | verified |
| July 2026, mountain areas | about 60% on weekends, about 30% on weekdays (Beirut about 40%) | Achkar, via LBCI 27 Jul 2026 | verified |
| Summer 2026 | some Mount Lebanon hotels that usually open 3 months a year decided to stay closed; about 50% of bookings cancelled (the war had lasted over 100 days by 12 Jun 2026) | An-Nahar, 12 Jun 2026 | verified |
| Ski season | early December to early April | Wikipedia, "Mzaar Kfardebian" | weak source; verify with the resort |
| National monthly visitor arrivals (General Security, via CAS/MoT, BRITE series 4401) | see the shape below | Central Administration of Statistics, Ministry of Tourism, via BLOMINVEST BRITE | verified |
| Beirut 4–5★ occupancy (EY, monthly, 2011–Jan 2024) | for example, 2018: 49.1, 61.3, 63.5, 68.5, 50.9, 60.9, 73.0, 73.3, 72.3, 69.6, 68.5, 69.7%. 2023: 36.8, 35.6, 38.2, 33.4, 49.2, 57.4, 64.6, 53.6, 62.2, 31.8, 12.5, 21.4% | EY Middle East Hotel Benchmark via BRITE series 2899 | verified. City hotels, not representative of Faqra. |

**National arrivals relative to July** (mean of 2017, 2018, 2023 and 2025; 2019 was excluded because of the Oct–Dec 2019 crisis). This is derived from BRITE 4401; the Jan–Dec ratios are:
0.374, 0.390, 0.422, 0.529, 0.544, 0.719, 1.000, 0.833, 0.635, 0.532, 0.401, 0.543.

**Base monthly occupancy factors (normal year, comparable to 2023 or 2025)**

| Month | Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Occupancy (base) | 0.70 | 0.75 | 0.60 | 0.32 | 0.33 | 0.43 | 0.60 | 0.60 | 0.38 | 0.32 | 0.24 | 0.50 |
| Status | assumed (between the ski-weekend 100% and the Feb anchor) | **verified anchor** | assumed (late ski season) | derived: 0.60 × 0.529 | derived: 0.60 × 0.544 | derived: 0.60 × 0.719 | **verified anchor** (>60%) | anchor (Aug is the national peak and has the festival; arrivals ratio 0.83 not applied) | derived: 0.60 × 0.635 | derived: 0.60 × 0.532 | derived: 0.60 × 0.401 | assumed (season opening plus holidays) |

**Scenarios**

- Annual mean occupancy: base 0.48, low 0.31, high 0.60.
- **Low = base × 0.643.** This is the ratio of the July 2026 mountain weekly average, (2×60 + 5×30)/7 = 38.6%, to the 60% normal-summer anchor. It represents a disrupted year like 2024 or 2026.
- **High = base × 1.25**, capped at 0.95 (assumed). The capped Feb value of 0.94 is consistent with full ski weekends.
- **Weekday/weekend split (derived).** July 2026 shows a weekend/weekday ratio of 60/30 = 2. Therefore weekday occupancy = 7·occ/9 and weekend occupancy = 2× that, capped at 1.
- **Shoulder months** (Apr–May, Oct–Nov) come from national arrivals. A ski and summer resort is probably quieter than the national average in these months, so they may overstate demand slightly.

**Resulting monthly electricity factors** (daily energy ÷ annual daily mean, base case; fixed loads damp the swing):

| Month | Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Hotel | 1.080 | 1.099 | 1.044 | 0.941 | 0.945 | 0.982 | 1.044 | 1.044 | 0.963 | 0.941 | 0.912 | 1.007 |
| Restaurants | 1.196 | 1.240 | 1.106 | 0.857 | 0.865 | 0.955 | 1.106 | 1.106 | 0.910 | 0.857 | 0.786 | 1.018 |

---

## (e) BibTeX

```bibtex
@article{Bohdanowicz2007,
  author  = {Bohdanowicz, Paulina and Martinac, Ivo},
  title   = {Determinants and benchmarking of resource consumption in hotels---Case study of {Hilton International} and {Scandic} in {Europe}},
  journal = {Energy and Buildings},
  volume  = {39}, number = {1}, pages = {82--95}, year = {2007},
  doi     = {10.1016/j.enbuild.2006.05.005}
}
@article{Arenhart2024,
  author  = {Arenhart, Rodrigo Schons and Martins, Tailon and Ueda, Renan Mitsuo and Souza, Adriano Mendon{\c{c}}a and Zanini, Roselaine Ruviaro},
  title   = {Energy use and its contributors in hotel buildings: A systematic review and meta-analysis},
  journal = {PLoS ONE}, volume = {19}, number = {10}, pages = {e0309745}, year = {2024},
  doi     = {10.1371/journal.pone.0309745}
}
@techreport{Hotels4Climate2020,
  author      = {Charalambous, Anthi and Kastanias, Panayiotis and Koutsokoumnis, Neoptolemos and Ikkos, Aris and Kyriakides, Michalis and Mylonas, Sotiris and Schneider, Madeline and Weir, Jessica and Barckhausen, Anton},
  title       = {Assessment of {Cyprus} and {Greece} hotels: Structural characteristics, energy and {GHG} emissions performance indicators ({Hotels4Climate} Deliverable {A1.1})},
  institution = {OEB, INSETE, adelphi}, address = {Nicosia}, year = {2020}, month = dec,
  url         = {https://www.oeb.org.cy/wp-content/uploads/2021/04/AI.1-Report-on-characteristics-of-the-hotel-industry-in-Cyprus-and-Greece_v41-1.pdf}
}
@techreport{MoE2015CI,
  author      = {Diab, Ronald and Hajj Chehadeh, Nader and Bou Ghanem, Lara and Medawar, Nathalie and Zbeidy, Rana and Khoury, Ricardo},
  title       = {Energy consumption in the commercial and institutional sector},
  institution = {Ministry of Environment / UNDP / GEF (prepared by ELARD and EEG), Lebanon's First Biennial Update Report},
  address     = {Beirut}, year = {2015},
  url         = {https://climatechange.moe.gov.lb/viewfile.aspx?id=256}
}
@techreport{CIBSE_TM46,
  author      = {Field, John and others},
  title       = {{TM46}: Energy Benchmarks},
  institution = {Chartered Institution of Building Services Engineers (CIBSE)},
  address     = {London}, year = {2008}, isbn = {9781903287958}
}
@misc{EIA_CBECS2018,
  author = {{U.S. Energy Information Administration}},
  title  = {2018 Commercial Buildings Energy Consumption Survey: Consumption and Expenditures Tables {C14} and {E5}},
  year   = {2022},
  url    = {https://www.eia.gov/consumption/commercial/data/2018/}
}
@techreport{Hedrick2011,
  author      = {Hedrick, Roger and Smith, Vernon and Field, Kristin},
  title       = {Restaurant Energy Use Benchmarking Guideline},
  institution = {National Renewable Energy Laboratory}, number = {NREL/SR-5500-50547},
  address     = {Golden, CO}, year = {2011},
  doi         = {10.2172/1019165}
}
@misc{BMWi2021Vergleichswerte,
  author = {{Bundesministerium f{\"u}r Wirtschaft und Energie and Bundesministerium des Innern, f{\"u}r Bau und Heimat}},
  title  = {Bekanntmachung der Regeln f{\"u}r Energieverbrauchswerte und der Vergleichswerte im Nichtwohngeb{\"a}udebestand vom 15. April 2021},
  howpublished = {Bundesanzeiger, BAnz AT 03.05.2021 B1}, year = {2021}
}
@techreport{Deru2011,
  author      = {Deru, Michael and Field, Kristin and Studer, Daniel and Benne, Kyle and Griffith, Brent and Torcellini, Paul and Liu, Bing and Halverson, Mark and Winiarski, David and Rosenberg, Michael and Yazdanian, Mehry and Huang, Joe and Crawley, Drury},
  title       = {{U.S. Department of Energy} Commercial Reference Building Models of the National Building Stock},
  institution = {National Renewable Energy Laboratory}, number = {NREL/TP-5500-46861}, year = {2011},
  doi         = {10.2172/1009264}
}
@misc{OpenStudioStandards,
  author = {{National Renewable Energy Laboratory}},
  title  = {openstudio-standards: {ASHRAE} 90.1 prototype building schedules (ashrae\_90\_1.schedules.json, ``From DOE Prototype Buildings'')},
  url    = {https://github.com/NREL/openstudio-standards}, note = {Accessed 22 Nov 2026}
}
@misc{ITP2005,
  author = {{International Tourism Partnership}},
  title  = {Sustainable Hotel Siting, Design and Construction, Chapter 9: Energy},
  year   = {2005}, note = {Digital release 2014},
  url    = {https://sustainablehospitalityalliance.org/wp-content/uploads/2020/06/Sustainable-Hotel-Siting-Design-and-Construction-Chapter-9.pdf}
}
@misc{BRITE_arrivals,
  author = {{Central Administration of Statistics and Ministry of Tourism (Lebanon)}},
  title  = {Total Visitor Arrivals to Lebanon, monthly (series 4401)},
  howpublished = {BLOMINVEST BRITE}, year = {2026},
  url    = {https://brite.blominvestbank.com/series/Total-Visitor-Arrivals-to-Lebanon-4401/}
}
@misc{BRITE_EY,
  author = {{EY Middle East Hotel Benchmark Survey}},
  title  = {Beirut Hotel Occupancy Rate ({EY}), monthly (series 2899)},
  howpublished = {BLOMINVEST BRITE}, year = {2024},
  url    = {https://brite.blominvestbank.com/series/Beirut-Hotel-Occupancy-Rate-EY-2899/}
}
@misc{LBCI2026Feb,
  author = {Nawchi, Marie Ange},
  title  = {In the numbers: {Lebanon}'s winter tourism rebounds as ski season lifts hotel occupancy},
  howpublished = {LBCI}, year = {2026}, month = feb,
  url    = {https://www.lbcgroup.tv/news/news-bulletin-reports/904394/in-the-numbers-lebanons-winter-tourism-rebounds-as-ski-season-lifts-ho/en}
}
@misc{LBCI2026Jul,
  author = {{LBCI}},
  title  = {Beirut hotels see 40\% occupancy as {Lebanon}'s tourism sector picks up},
  year   = {2026}, month = jul,
  url    = {https://www.lbcgroup.tv/news/economy/949204/beirut-hotels-see-40-occupancy-as-lebanons-tourism-sector-picks-up/en}
}
@misc{LBCI2024Jan,
  author = {{LBCI}},
  title  = {By the numbers: A closer look at {Lebanon}'s ski season---80\% demand, 100\% hotel occupancy},
  year   = {2024}, month = jan,
  url    = {https://www.lbcgroup.tv/news/news-bulletin-reports/748171/by-the-numbers-a-closer-look-at-lebanons-ski-season-80-demand-100-hotel-occupancy/en}
}
@misc{LBCI2025Aug,
  author = {{LBCI}},
  title  = {Lebanon's summer tourism season shows positive results: {Beirut}'s occupancy at 80--90\%},
  year   = {2025}, month = aug,
  url    = {https://www.lbcgroup.tv/news/lebanon-news/875004/lebanons-summer-tourism-season-shows-positive-results-beiruts-occupanc/en}
}
@misc{AnNahar2026,
  author = {{An-Nahar}},
  title  = {Lebanon's summer tourism under strain as war pressures deepen across key sectors},
  year   = {2026}, month = jun,
  url    = {https://en.annahar.com/en/319593/between-escalation-and-optimism-were-summer-2026-reservations-canceled}
}
@inproceedings{Placet2010,
  author    = {Placet, Marylynn and Katipamula, Srinivas and Liu, Bing and Dirks, James and Xie, Yulong and Sullivan, Greg and Walent, Joe and Williamson, Bob},
  title     = {Energy End-Use Patterns in Full-Service Hotels: A Case Study},
  booktitle = {ACEEE Summer Study on Energy Efficiency in Buildings}, year = {2010},
  url       = {https://www.aceee.org/files/proceedings/2010/data/papers/1984.pdf}
}
@misc{UNSD2019Lebanon,
  author = {{United Nations Statistics Division and UN-ESCWA}},
  title  = {Technical Assistance to {Lebanon} on Improving Energy Statistics for Sustainable Development: Assessment Mission Report},
  year   = {2019},
  url    = {https://unstats.un.org/unsd/energystats/events/2019-Beirut/Lebanon%20Report%20Final.pdf}
}
@misc{IBC_T1004,
  author = {{International Code Council}},
  title  = {International Building Code, Table 1004.5 Maximum floor area allowances per occupant (as adopted in WAC 51-54A-1004)},
  url    = {https://lawfilesext.leg.wa.gov/Law/WAC/WAC%20%2051%20%20TITLE/WAC%20%2051%20-%2054A%20CHAPTER/WAC%20%2051%20-%2054A-1004.htm}
}
@article{Eid2025,
  author  = {Eid, Elias and Foster, Alan and Alvarez, Graciela and Campbell, Robin and Evans, Judith},
  title   = {Assessment of Energy Consumption and Greenhouse Gas Emissions in a {UK} Quick-Service Restaurant Using {EnergyPlus}},
  journal = {Energies}, volume = {18}, number = {6}, pages = {1377}, year = {2025},
  doi     = {10.3390/en18061377}
}
```

DOI notes:
- `Hedrick2011` (10.2172/1019165) and `Deru2011` (10.2172/1009264) use OSTI-style DOIs. OSTI ID 1019165 was seen for Hedrick, but neither DOI was resolved during this research, so confirm both before submission.
- All other DOIs were read on the publisher or index pages.

---

## (f) Gaps and caveats

1. **No electricity-only, peer-reviewed benchmark for mountain or ski hotels was found.** Hotel values are either total-energy benchmarks reduced by end-use shares (Hotels4Climate, CBECS) or the TM46 electricity benchmark (CIBSE, an industry and professional body).
   - Not obtained: Pieri et al. 2015 (Attica), Farrou et al. 2012 (Greece), Priyadarsini et al. 2009 (Singapore), and the TU Wien Alpine-hotel theses. The last could not be fetched.
   - The electricity share in Bohdanowicz's Fig. 1 is only available as an image.
2. **The fixed/variable split** is inferred from total-energy regressions. No electricity-specific occupancy regression was found.
3. **Hourly profiles are US prototype schedules**, not measured Lebanese or Mediterranean data. No published measured hourly hotel or restaurant electricity curve was found. Borowski et al. 2022 (CLIMA, DOI 10.34641/clima.2022.187) measured thermal loads only, and Placet et al. 2010 gives only "relatively flat".
   - Lebanese meal times are later than US prototype schedules assume.
   - The outdoor pool pump (summer) is **not** included. Treat it as a separate load with a pump rating from a datasheet.
4. **No mountain-specific monthly occupancy series exists in the public sources found.** Monthly factors rest on three verified anchors: Feb 75% in Kfardebian, Jul/Aug >60% regional, and mountain weekend/weekday 60/30% in July 2026. National arrivals fill the shoulder months, and Jan, Mar and Dec are assumed.
   - 2026 is a disrupted year: arrivals fell to 15,775 in Mar 2026 and 25,686 in Apr 2026, against 102,647 in Apr 2025, and mountain hotels closed in summer 2026. Use "low" for 2026-like conditions.
5. **No Lebanese quantitative split of space-heating fuels** (diesel, LPG, wood, electricity) was found. UNSD/ESCWA (2019) states that these quantities are not compiled. Evidence for "do not count electric heating" is qualitative but official: the MoE/UNDP 2015 boiler and LPG findings.
6. **Restaurant floor areas are placeholders** (DOE prototypes) until OSM footprints arrive. Restaurant intensity spans 4× between the German official value and US CBECS, so the base uses the European TM46 value.
7. **Self-generation context.** Restaurants get 39% of their electricity from private generation (MoE/UNDP 2015). This is relevant for the diesel baseline the microgrid would displace.
8. **TM46 values** were read from a secondary reproduction (greencalculus.com, which matches TM46:2008 Table 1). The original PDF is paywalled. The ITP Table 11 benchmark rows could not be mapped to hotel types from the PDF text, so they were not used.
