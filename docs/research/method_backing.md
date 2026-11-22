# Method backing: Faqra Club PV + battery + diesel LP sizing (EECE 675)

How this was checked: the full texts of the Elsevier papers were read through AUB EZproxy (ScienceDirect). The DOIs were confirmed by resolving them through doi.org to the article page, plus Crossref where noted. NREL, HOMER, PVGIS, pvlib, MDPI and Nature pages were read directly.
Notes are paraphrased with exact numbers and locations. Short quoted fragments are kept verbatim.
"UNVERIFIED" means I did not read the text or did not resolve the DOI myself.

---

## 1. Reliability: energy-based LPSP ≤ 1% + zero unserved critical load in outages

**Verdict: PARTLY supported.** Using an energy-based LPSP and a hard critical-load constraint is standard practice and well supported. The **1% value is defensible but arbitrary**. It is at the strict end of what the literature uses for PV/wind/battery systems. Papers that include a diesel genset often use **0%**. The 1% value has to be justified, for example by showing that the non-critical load can be shed, and it should be tested with a sensitivity sweep.

**Sources**

- **Yang, Zhou, Lu, Fang (2008), Sol. Energy 82(4):354–367.** LPSP is defined as the probability of insufficient supply (Sect. 4, Eq. 20). Note that its formula is **time-based**: power-failure hours divided by T, not energy. In Sect. 6.1 and Table 6 the system is sized for "desired LPSP" of **1% and 2%**. That gives annualized costs of US$10,600 and US$9,708, with achieved LPSP of 0.97% and 1.96%. Sizing uses the typical meteorological year 1989.
  → **Supports** a 1–2% target range. **Qualifies** the choice: Yang's LPSP counts time, ours counts energy, so say this explicitly.
- **Borhanazad et al. (2014), Renew. Energy 71:295–306.** Sect. 4.2, Eq. (11) defines the **energy-based** LPSP as Σ(deficit)/Σ(load). Their optimal PV/wind/diesel/battery solutions for three Iranian sites have LPSP of **7–9%** (results table).
  → **Supports** the energy-based definition. It shows that published targets are often much looser than 1%.
- **Kaabeche & Ibtiouen (2014), Sol. Energy 103:171–182.** In Sect. 5.1, reliability is the Total Energy Deficit (TED), i.e. energy not supplied divided by energy required over 1 year. Because the PV/wind/diesel/battery strategy allows no deficit, the **allowed TED is 0%** ("zero load rejection").
  → **Qualifies** the choice: once a diesel genset is present, 0% unmet energy is the usual benchmark.
- **Dufo-López & Bernal-Agustín (2005), Sol. Energy 79:33–46.** The Conclusions report that 0% unmet load can be reached with PV-Diesel systems at low total cost, but is very hard to reach with PV-only systems.
  → Same qualification as Kaabeche.
- **Lian et al. (2019), Energy Convers. Manage. 199:112027** (review). Sect. 3.1.1 calls LPSP "currently the most popular index" for hybrid renewable energy systems (HRES) and gives both the energy form (Eq. 1) and the time form (Eq. 2). Sect. 3.1.2–3.1.3 define LOLP (also energy-ratio over 8760 h) and EENS. I found no "typical range" statement in this review.
- **HOMER Pro manual, "Maximum annual capacity shortage"** (official software documentation). This is the maximum allowed capacity-shortage fraction, i.e. total shortage divided by total load. Systems above it are infeasible. Setting it to zero sizes the system for even the very high peak loads. No default value is stated on the page.
  → **Supports** framing the limit as an energy fraction.
- **Critical load / resilience**
  - **Cutler et al. (2017), REopt technical report, NREL/TP-7A40-70022.** REopt is a mixed-integer linear program (MILP) (Exec. Summary p. iii; Sect. 1.4 p. 6). Sect. 1.3.1 (pp. 3–4) says the load can be reduced to a "critical" load during an outage, and the model ensures "the critical load is met for a given grid outage duration". Sect. 1.5 p. 8 uses 8,760 hourly steps.
  - **NREL (2020), "REopt Lite Tutorial: Resilience Inputs", NREL/FS-7A40-76676, p. 2.** "The critical load is the load that must be met during the specified grid outage." The critical load is entered as 0–200% of the typical load (p. 3).
  - **Anderson et al. (2018), Sustainability 10(4):933.** In the case study (Sect. 3.1) the critical load is **30%** of the typical load. Sect. 2.1 uses 10,000 simulated outages of 1–9 days in REopt.
  - **NFPA 110** (Emergency and Standby Power Systems). Level 1 applies where failure "could result in loss of human life or serious injuries". The NEC 700/701/702 categories (emergency, legally required standby, optional standby) are the usual basis for classifying critical loads. This is only a secondary characterization (CSE Magazine). Cite NFPA 110 §4.4 directly (section number UNVERIFIED).
  - **IEEE Std 446-1995 (Orange Book).** It is listed as "Inactive-Reserved" on standards.ieee.org, so cite it only as historical practice.
  - **Domain-specific (ropeways):** prEN 13223:2025 has clauses 6.3 "Auxiliary drive", 6.4 "Recovery drive and evacuation drive" and 6.7.2 "Internal combustion engines". These are relevant to classifying chairlift evacuation drives as critical. I could see only the clause headings; the requirement text is UNVERIFIED.
  - **Hospital microgrid (Sci. Rep. 2026):** Nazartalab & Alavi-Rad, Sci. Rep. 16:5475, doi:10.1038/s41598-026-34992-x. Life-support loads "must be fully supplied at all times". However, the optimization treats this as a criticality-weighted objective and reports ≥95% supply to life-critical loads. → **Weak support** for a hard 100% constraint. I could not find any "**Eissa 2026 Sci. Rep.**" paper on critical loads (UNVERIFIED, do not cite).

**Recommended adjustments**

1. Call it "energy-based LPSP (= unmet-load fraction)" and cite Borhanazad Eq. 11, Lian Eq. 1 and HOMER.
2. Run a sensitivity sweep of LPSP over {0, 0.5, 1, 2, 5}%. Justify 1% by saying that only shed-able non-critical load is affected. Kaabeche and Dufo-López show 0% is cheap with a genset, so a reviewer will ask why 1% is allowed.
3. Model critical-load supply as a hard constraint, as REopt does. Base the critical-load list on NFPA 110 / NEC 700–701 classes and on ropeway evacuation drives.

---

## 2. Full 8,760-h year instead of representative days

**Verdict: WELL supported.**

- **Kotzur et al. (2018), Renew. Energy 117:474–487.**
  - Sect. 4.2 (residential supply system): with all typical-period designs, optimal PV capacity is **overestimated** and **storage capacities are underestimated** because typical periods smooth the profiles.
  - End of Sect. 4.3 (island system): typical-period aggregation fails because the sequence of periods is not modelled, so long-term storage cannot be properly accounted for.
  - Sect. 6 (Conclusion): systems heavily relying on storage "cannot be properly represented by independent typical days at all", and not by independent typical weeks either.
- **Pfenninger (2017), Appl. Energy 197:1–13.**
  - Abstract: the best time-reduction method "depends heavily on input data and the setup of model constraints"; there is no one-size-fits-all approach.
  - Sect. 5: methods with time resolution far below 1-hourly, or with few typical days, should be used with caution at high renewable shares. Studies should justify and validate any reduction for their own model.
- **Hoffmann et al. (2020), Energies 13(3):641** (review of 130+ TSA papers). The abstract says each method's performance "depends on the justifiability of its assumptions" and notes a growing literature on bounding the error from time-series aggregation (TSA). I read only the abstract.
- **Cutler et al. (2017), REopt technical report, Sect. 1.5 p. 8:** the typical step is 1 h, giving 8,760 steps. This is the practitioner precedent for a full-year LP/MILP.

**Adjustment:** none. State that the problem is small enough to solve the full year, so aggregation error is avoided, and cite Kotzur's finding that storage is underestimated.

---

## 3. One representative weather year (closest to multi-year mean on annual and winter PV yield) + multi-year sensitivity

**Verdict: PARTLY supported.** The selection principle matches TMY practice, and the multi-year sensitivity is exactly what the literature asks for. However, all sources warn that one year, typical or not, **under-sizes storage** and does not cover bad years.

- **Wilcox & Marion (2008), Users Manual for TMY3, NREL/TP-581-43156.**
  - Sect. 2.1, pp. 11–12: typical months are chosen with Finkelstein–Schafer statistics, then ranked by closeness to the long-term mean and median.
  - Preface p. iii: TMY data represent "typical rather than extreme conditions" and are "not suited for designing systems to meet the worst-case conditions".
  → **Supports** "closest to mean" as an accepted principle. Choosing a whole real year, instead of TMY's spliced months, keeps multi-day weather sequences intact, which matters for storage. **Qualifies** the choice on worst-case design.
- **Javed et al. (2023), Renew. Sustain. Energy Rev. 183:113514.** The authors use 43 years of hourly data with MILP sizing of off-grid systems. Abstract and highlights:
  - Designs sized on longer periods are up to **94% more robust** than single-year designs.
  - Single-year sizing "may result in under/overestimations".
  - Short periods "could underestimate energy storage capacities".
  → **Strongly supports** the multi-year sensitivity. It **qualifies** relying on one design year.
- **Pfenninger (2017).** Abstract: results with high PV/wind shares from a single or few years "are likely unreliable". Sect. 5: use "not just a single year (for example, a typical meteorological year) but as long a time series as possible".
- **Yang et al. (2008)** sized on a TMY year (1989), so there is precedent in the HRES literature.

**Adjustment (recommended):** keep the representative year for the main LP. Add a **multi-year feasibility check**: fix the optimal design, re-run dispatch for every available year, and report the worst-year LPSP and the critical-load coverage. If affordable, also solve the LP over all years or over the worst year (Javed 2023).

---

## 4. Correcting satellite irradiance to long-term monthly means of a reference dataset; snow-related underestimation

**Verdict: PARTLY supported.** Monthly bias correction is an established "site adaptation" technique. Strictly, though, site adaptation means correcting against **ground measurements**. Correcting one model to another model's monthly means is weaker. It is defensible only if the reference dataset is shown to be better validated in the region. The evidence that satellite retrievals underestimate over snow is solid.

- **Polo et al. (2016), Sol. Energy 132:25–37** (IEA SHC Task 46 survey).
  - Abstract: site adaptation means correcting satellite or model irradiance with **short-term local ground measurements** to remove systematic errors and bias.
  - Sect. 4.2.1 "Bias removal by linear adaptation": the simplest method removes the mean bias deviation from the whole dataset (Eq. 2 is a linear fit correction).
  - Sect. 4.2 also notes that DNI bias is often monthly or annual.
  → **Supports** the monthly-bias method. **Qualifies** the choice if the reference is not ground data.
- **Sengupta et al. (2021), IEA PVPS Task 16 Best Practices Handbook, 3rd ed., NREL/TP-5D00-77635.** Sect. 4.8 "Site Adaptation: Merging Measurements and Models" (p. 4-14). Sect. 2.7.4 (p. 2-11) says measurements improve long-term modelled series through site adaptation. I did not read the text of Sect. 4.8.
- **Urraca et al. (2018), Sol. Energy 164:339–354.**
  - Abstract: ERA5 has a mean bias of **+4.05 W/m²** worldwide (41 BSRN stations) and **+4.54 W/m²** in Europe (294 stations). Its results degrade in coastal areas and **mountains**. It overestimates under cloudy skies and underestimates slightly under clear skies.
  - Sect. 5: SARAH underestimates at high latitudes because of snow-detection problems. In the Alps it underestimates, "probably due to snow detection issues", while it overestimates in the Pyrenees.
  → **Supports** both the ERA5 bias claim and the snow claim. Faqra, at 1,735–1,975 m, is mountainous, which strengthens the case.
- **PVGIS documentation (JRC, "Data sources & calculation methods")**
  - Sect. 1.1: snow "can be mistaken for clouds".
  - Sect. 1.2: snow on the ground "may be seen as clouds by the method which then calculates too low irradiance".
  - Sect. 1.1 also says reanalysis (ERA5) accuracy is generally not as good as satellite data.

**Adjustment:**
- Name the reference dataset, e.g. PVGIS-SARAH or Solargis, and cite its regional validation.
- Call the procedure "monthly bias correction to a reference climatology, analogous to site adaptation (Polo 2016 §4.2.1)", not site adaptation proper.
- Report results both with and without the correction.
- In winter months with snow cover, the reference itself, if satellite-based, may be biased low. Say this explicitly.

---

## 5. Snow-loss model (Marion 2013 via pvlib); rain/snow partition at ~1 °C; 10:1 snow-to-liquid ratio

**Verdict: Marion/pvlib WELL supported, with caveats. The 1 °C threshold is WELL supported. The 10:1 ratio is WEAK: better values exist.**

- **Marion, Schaefer, Caine, Sanchez (2013), Sol. Energy 97:112–121.**
  - Six systems in Colorado and Wisconsin. Monthly snow losses were as high as 90%. Annual losses ranged from 1% to 12% (Abstract).
  - Model algorithm, Step 4: snow slides when Ta − G/m > 0, with **m = −80 W/m²/°C** (Fig. 4 slope).
  - The slide amount comes from Fig. 7 and is a function of tilt, in tenths of slant height.
  - Accuracy: modelled annual losses were within **0.5% absolute** of measured losses for non-residential systems, and about **1.5% lower** for residential systems. The standard deviation of monthly differences was **10.5% absolute**.
  - **Important:** the original model detects new snow from the **daily snow-depth increase**, not from an hourly snowfall threshold.
  - Limitations: sliding is impeded once snow has accumulated at the base of the panels. The Conclusions list further unmodelled factors: back-side heating, friction, ice at the interface, and freeze–thaw cycles.
- **pvlib `snow.coverage_nrel` (pvlib docs; Holmgren et al. 2018 JOSS)**
  - Defaults: `threshold_snowfall=1.0` (cm/h), `can_slide_coefficient=-80.0` (W/m²/°C), `slide_amount_coefficient=0.197`, `threshold_depth=1.0`.
  - The docs note that in Marion et al. the coefficient is called m and the slide amount is given in tenths of slant height.
  → **Confirms** all three parameters. The 1 cm/h hourly-snowfall trigger is **pvlib's adaptation** (via Ryberg & Freeman 2017), not Marion's original daily-depth rule. Say so.
- **Ryberg & Freeman (2017), NREL/TP-6A20-68705** (SAM implementation)
  - pp. 7–10: the model reduced annual error from **9.7% to −2.2%** (Forrestal, 0° tilt) and from **8.5% to 4.4%** (RSF2, 10° tilt).
  - p. 2: it does not account for snow melting or wind removal (except for flat systems).
  - p. 3: it was designed for tilts of **10°–45°**, and the 1.97 constant was determined for **roof-mounted** systems.
  - p. 3: depth thresholds are set to 1 cm, consistent with snow-depth measurement uncertainty.
  - p. 16: no time-delayed effects.
- **Townsend & Powers (2011, IEEE PVSC)**: UNVERIFIED, not read.
- **Jennings, Winchell, Livneh, Molotch (2018), Nat. Commun. 9:1148.**
  - Abstract: the 50% rain–snow air-temperature threshold averages **1.0 °C** across the Northern Hemisphere, ranging **−0.4 to 2.4 °C** for 95% of stations.
  - Continental climates have the warmest thresholds and maritime climates the coolest. Mountain ranges are generally warmer (Results).
  - Methods that include **humidity (RH or wet-bulb)** outperform temperature-only methods.
  → **Supports** 1 °C. Suggest a ±1 °C sensitivity, or a wet-bulb method if RH is available (ERA5 provides dew point).
- **Baxter, Graves, Moore (2005), Weather Forecast. 20(5):729–744.** Abstract: a mean snow-to-liquid ratio (SLR) of **13** is more appropriate for much of the US than the "often-assumed value of 10". There is considerable spatial variation and a skewed distribution.
  → **Contradicts** 10:1 as a universal value. Lebanon is not covered.
- **Density-based alternatives**
  - Hedstrom & Pomeroy (1998), Hydrol. Process. 12(10–11):1611–1625: fresh-snow density ρ = 67.92 + 51.25·exp(T/2.59) kg/m³. The coefficient is UNVERIFIED in the original: Helfricht et al. (2018) print it as 51.52.
  - Helfricht et al. (2018), HESS 22:2655–2668, doi:10.5194/hess-22-2655-2018: high-mountain sub-daily new-snow density. DOI taken from the article URL; not separately resolved.

**Adjustment:**
- Keep pvlib/Marion. State the parameters and that the 1 cm/h trigger is pvlib's.
- Note the tilt range (10–45°) and that the slide coefficient was fitted on roof-mounted systems.
- Suggest a ground-clearance assumption so that snow at the base does not bury the lower row edge.
- Replace fixed 10:1 with either a temperature-dependent density (Hedstrom–Pomeroy) or a 10–13:1 sensitivity, citing Baxter 2005.

---

## 6. Bottom-up hourly load reconstruction with no metering; low/base/high scenarios

**Verdict: WELL supported** for the method. Scenario practice is supported through Mandelli's multi-profile approach.

- **Mandelli, Brivio, Colombo, Merlo (2016), Sustain. Energy Technol. Assess. 18:34–47.**
  - Abstract: off-grid PV sizing has to match uncertain demand. They build profiles bottom-up from users' electric needs (LoadProGen), then generate many plausible profiles (150 profiles in 10 scenarios, Table 4).
  - Results: "optimum system configurations are significantly affected by load profiles". They propose picking the robust solution across profiles.
  - The Introduction cites Boait et al.'s bottom-up Monte Carlo approach based on appliance features.
- **Lombardi, Balderrama, Quoilin, Colombo (2019), Energy 177:433–444 (RAMP).** Abstract: an open-source bottom-up stochastic model for areas with high-uncertainty, interview-based data. Validated against a real system with errors **<2%** on all selected indicators.
- **Deru et al. (2011), DOE Commercial Reference Building Models, NREL/TP-5500-46861.**
  - Table 1 (p. 6) includes **Large Hotel, Small Hotel, Full-Service and Quick-Service Restaurant**.
  - Hourly schedules are in Appendix B (e.g. Table B-11, full-service restaurant).
  - Sect. 5.1.3 (p. 14): plug and process load intensity is hard to determine because measured data are scarce. Sources include Jiang et al. 2008 for small hotels and Huang et al. 1991 for large hotels (Table 7).
- **Mandelli et al. (2016), RSER 58:1621–1646** (review). Its literature tables flag several studies that analyse "load profile influence" on sizing. There is no explicit method statement to quote.

**Adjustment:** present low/base/high as a structured uncertainty set, as in Mandelli 2016, and report the design that is robust across them. Validate the base case against any available data, such as the EDL feeder data or diesel fuel logs.

---

## 7. Linear diesel fuel curve F = a·P_rated + b·P; minimum-load issue in LP

**Verdict: WELL supported** for the fuel curve. Minimum load is a **known LP limitation** and must be discussed.

- **Skarstein & Uhlen (1989), Wind Engineering 13(2):72–87.** This is the original source of a = 0.08415 and b = 0.246 L/kWh. It was not read; journal, volume and issue are as cited by Dufo-López 2005. Pages and DOI are UNVERIFIED.
- **Dufo-López & Bernal-Agustín (2005), Sol. Energy 79:33–46.**
  - Eqs. (13)–(14): fuel cost = Pr_fuel·(B·P_Ngen + A·P_gen), with **A = 0.246 L/kWh and B = 0.08415 L/kWh** "(Skarstein and Ulhen, 1989)".
  - Table 5: the minimum diesel output tested was **15% and 30% of rated**, and it affects the optimal dispatch and the net present cost (NPC).
- **HOMER Pro manual, "Generator fuel curve intercept coefficient".** F = F0·Y_gen + F1·P_gen, with F0 in L/h/kW_rated and F1 in L/h/kW_output. Fuel = 0 when the genset is off. The worked 50 kW example gives F0 = 0.033 and F1 = 0.273. No default values are stated on the page.
- **Azoumah et al. (2011), Energy Policy**: UNVERIFIED, not read.
- **Minimum load in LP.** The no-load term a·P_rated and a minimum stable output both require on/off binaries, i.e. a MILP. A standard LP relaxation uses continuous "committed capacity" (clustered unit commitment).
  - Palmintier & Webster (2014), IEEE Trans. Power Syst. 29(3):1089–1098, doi:10.1109/TPWRS.2013.2293127 (Crossref-verified).
  - The MIT working-paper abstract reports that careful aggregation introduces errors of 0.05–0.9%.

**Adjustment:**
- Apply the intercept to a continuous committed-capacity variable u_t (P_t ≤ u_t ≤ P_rated, F_t = a·u_t + b·P_t, P_t ≥ m·u_t with m ≈ 0.25–0.30). This is linear, it avoids charging no-load fuel every hour, and it keeps a minimum-load proxy.
- Alternatively, report fuel with and without the intercept as bounds.
- State that the 0.08415/0.246 values are for a generic genset, and check them against a manufacturer datasheet for the chosen size.

---

## 8. Throughput-based battery degradation cost in the LP

**Verdict: WELL supported** as a first-order linear approach. Note what it leaves out: calendar ageing.

- **Bordin, Anuta, Crossland, Lascurain Gutierrez, Dent, Vigo (2017), Renew. Energy 101:417–430** (open access).
  - Sect. 2: the battery bank needs replacement once its total throughput equals its **lifetime throughput**.
  - Eq. (2): degradation cost **B = R/(L·E)**, where R is the replacement cost, L the lifetime throughput (kWh) and E the square root of round-trip efficiency. It is charged per kWh discharged.
  - Eq. (1): L_n = Q_max·DoD_n·cycles_n. Table 1 shows throughput is roughly constant across DoD (e.g. 1,350 kWh at 50% DoD vs 1,296 kWh at 80% for a 2.7 kWh battery).
  - The paper also has a per-cycle cost variant that needs binaries.
- **Seger, Rigo-Mariani, Thivel, Riu (2023), Appl. Energy 333:120584**, doi:10.1016/j.apenergy.2022.120584. Abstract: to first order, Li-ion ageing depends on initial state of health (SoH) and on the **energy exchanged normalised by nominal capacity**. Ignoring degradation leads to inaccurate results and underestimates costs by more than 20%. Their simplified model is formulated as a MILP.
  → **Supports** the throughput linearisation for Li-ion.

**Adjustment:** combine the throughput cost with a **calendar-life cap**, i.e. replace at the earlier of throughput or calendar years. Throughput alone misses calendar ageing, which Seger's SoH dependence implies matters. Take L from the chosen Li-ion datasheet (cycles × DoD × capacity).

---

## BibTeX

DOIs marked `% verified` resolved via doi.org to the article (EZproxy) and/or matched Crossref metadata.

```bibtex
@article{Yang2008,
  author = {Yang, Hongxing and Zhou, Wei and Lu, Lin and Fang, Zhaohong},
  title = {Optimal sizing method for stand-alone hybrid solar--wind system with {LPSP} technology by using genetic algorithm},
  journal = {Solar Energy}, volume = {82}, number = {4}, pages = {354--367}, year = {2008},
  doi = {10.1016/j.solener.2007.08.005}} % verified

@article{Borhanazad2014,
  author = {Borhanazad, Hanieh and Mekhilef, Saad and Gounder Ganapathy, Velappa and Modiri-Delshad, Mostafa and Mirtaheri, Ali},
  title = {Optimization of micro-grid system using {MOPSO}},
  journal = {Renewable Energy}, volume = {71}, pages = {295--306}, year = {2014},
  doi = {10.1016/j.renene.2014.05.006}} % verified

@article{Kaabeche2014,
  author = {Kaabeche, Abdelhamid and Ibtiouen, Rachid},
  title = {Techno-economic optimization of hybrid photovoltaic/wind/diesel/battery generation in a stand-alone power system},
  journal = {Solar Energy}, volume = {103}, pages = {171--182}, year = {2014},
  doi = {10.1016/j.solener.2014.02.017}} % DOI verified; volume/pages from memory -- check

@article{DufoLopez2005,
  author = {Dufo-L{\'o}pez, Rodolfo and Bernal-Agust{\'i}n, Jos{\'e} L.},
  title = {Design and control strategies of {PV}-Diesel systems using genetic algorithms},
  journal = {Solar Energy}, volume = {79}, number = {1}, pages = {33--46}, year = {2005},
  doi = {10.1016/j.solener.2004.10.004}} % verified (issue no. from memory)

@article{Lian2019,
  author = {Lian, Jijian and Zhang, Yusheng and Ma, Chao and Yang, Yang and Chaima, Evance},
  title = {A review on recent sizing methodologies of hybrid renewable energy systems},
  journal = {Energy Conversion and Management}, volume = {199}, pages = {112027}, year = {2019},
  doi = {10.1016/j.enconman.2019.112027}} % verified

@article{Mandelli2016review,
  author = {Mandelli, Stefano and Barbieri, Jacopo and Mereu, Riccardo and Colombo, Emanuela},
  title = {Off-grid systems for rural electrification in developing countries: Definitions, classification and a comprehensive literature review},
  journal = {Renewable and Sustainable Energy Reviews}, volume = {58}, pages = {1621--1646}, year = {2016},
  doi = {10.1016/j.rser.2015.12.338}} % verified

@techreport{Cutler2017REopt,
  author = {Cutler, Dylan and Olis, Dan and Elgqvist, Emma and Li, Xiangkun and Laws, Nick and DiOrio, Nick and Walker, Andy and Anderson, Kate},
  title = {{REopt}: A Platform for Energy System Integration and Optimization},
  institution = {National Renewable Energy Laboratory}, number = {NREL/TP-7A40-70022}, year = {2017}}

@misc{NREL2020REoptRes,
  author = {{National Renewable Energy Laboratory}},
  title = {{REopt Lite} Tutorial: Resilience Inputs},
  howpublished = {NREL/FS-7A40-76676}, year = {2020}}

@article{Anderson2018,
  author = {Anderson, Kate and Laws, Nicholas D. and Marr, Spencer and Lisell, Lars and Jimenez, Tony and Case, Tria and Li, Xiangkun and Lohmann, Dag and Cutler, Dylan},
  title = {Quantifying and Monetizing Renewable Energy Resiliency},
  journal = {Sustainability}, volume = {10}, number = {4}, pages = {933}, year = {2018},
  doi = {10.3390/su10040933}} % verified (MDPI page)

@article{Nazartalab2026,
  author = {Nazartalab, P. and Alavi-Rad, H.},
  title = {Resilience-oriented optimization of hospital microgrids with critical load support using {ESS} and {PV} under grid outage conditions},
  journal = {Scientific Reports}, volume = {16}, pages = {5475}, year = {2026},
  doi = {10.1038/s41598-026-34992-x}} % verified via PMC page

@misc{HOMERcapshort,
  author = {{UL Solutions / HOMER Energy}},
  title = {{HOMER Pro} User Manual: Maximum Annual Capacity Shortage; Generator Fuel Curve Intercept Coefficient},
  howpublished = {\url{https://support.ul-renewables.com/homer-manual-pro/}}, note = {accessed 2026-11-22}}

@misc{NFPA110,
  author = {{National Fire Protection Association}},
  title = {{NFPA 110}: Standard for Emergency and Standby Power Systems},
  year = {2022}} % edition year UNVERIFIED -- use the edition you consult

@article{Pfenninger2017,
  author = {Pfenninger, Stefan},
  title = {Dealing with multiple decades of hourly wind and {PV} time series in energy models: A comparison of methods to reduce time resolution and the planning implications of inter-annual variability},
  journal = {Applied Energy}, volume = {197}, pages = {1--13}, year = {2017},
  doi = {10.1016/j.apenergy.2017.03.051}} % DOI verified; pages from memory -- check

@article{Kotzur2018,
  author = {Kotzur, Leander and Markewitz, Peter and Robinius, Martin and Stolten, Detlef},
  title = {Impact of different time series aggregation methods on optimal energy system design},
  journal = {Renewable Energy}, volume = {117}, pages = {474--487}, year = {2018},
  doi = {10.1016/j.renene.2017.10.017}} % verified

@article{Hoffmann2020,
  author = {Hoffmann, Maximilian and Kotzur, Leander and Stolten, Detlef and Robinius, Martin},
  title = {A Review on Time Series Aggregation Methods for Energy System Models},
  journal = {Energies}, volume = {13}, number = {3}, pages = {641}, year = {2020},
  doi = {10.3390/en13030641}} % verified (Crossref)

@techreport{Wilcox2008TMY3,
  author = {Wilcox, Stephen and Marion, William},
  title = {Users Manual for {TMY3} Data Sets},
  institution = {National Renewable Energy Laboratory}, number = {NREL/TP-581-43156}, year = {2008}}

@article{Javed2023,
  author = {Javed, Muhammad Shahzad and Jurasz, Jakub and Guezgouz, Mohammad and Canales, Fausto A. and Ruggles, Tyler H. and Ma, Tao},
  title = {Impact of multi-annual renewable energy variability on the optimal sizing of off-grid systems},
  journal = {Renewable and Sustainable Energy Reviews}, volume = {183}, pages = {113514}, year = {2023},
  doi = {10.1016/j.rser.2023.113514}} % verified

@article{Polo2016,
  author = {Polo, J. and Wilbert, S. and Ruiz-Arias, J. A. and Meyer, R. and Gueymard, C. and S{\'u}ri, M. and Mart{\'i}n, L. and Mieslinger, T. and Blanc, P. and Grant, I. and Boland, J. and Ineichen, P. and Remund, J. and Escobar, R. and Troccoli, A. and Sengupta, M. and Nielsen, K. P. and Renne, D. and Geuder, N. and Cebecauer, T.},
  title = {Preliminary survey on site-adaptation techniques for satellite-derived and reanalysis solar radiation datasets},
  journal = {Solar Energy}, volume = {132}, pages = {25--37}, year = {2016},
  doi = {10.1016/j.solener.2016.03.001}} % verified

@techreport{Sengupta2021,
  author = {Sengupta, Manajit and Habte, Aron and Wilbert, Stefan and Gueymard, Christian and Remund, Jan},
  title = {Best Practices Handbook for the Collection and Use of Solar Resource Data for Solar Energy Applications: Third Edition},
  institution = {National Renewable Energy Laboratory}, number = {NREL/TP-5D00-77635}, year = {2021}}

@article{Urraca2018,
  author = {Urraca, Ruben and Huld, Thomas and Gracia-Amillo, Ana and Martinez-de-Pison, Francisco Javier and Kaspar, Frank and Sanz-Garcia, Andres},
  title = {Evaluation of global horizontal irradiance estimates from {ERA5} and {COSMO-REA6} reanalyses using ground and satellite-based data},
  journal = {Solar Energy}, volume = {164}, pages = {339--354}, year = {2018},
  doi = {10.1016/j.solener.2018.02.059}} % verified

@misc{PVGISdocs,
  author = {{European Commission Joint Research Centre}},
  title = {{PVGIS} data sources \& calculation methods},
  howpublished = {\url{https://joint-research-centre.ec.europa.eu/photovoltaic-geographical-information-system-pvgis/general-information/data-sources-calculation-methods_en}},
  note = {accessed 2026-11-22}}

@article{Marion2013,
  author = {Marion, Bill and Schaefer, Robert and Caine, Holden and Sanchez, Glenn},
  title = {Measured and modeled photovoltaic system energy losses from snow for {Colorado} and {Wisconsin} locations},
  journal = {Solar Energy}, volume = {97}, pages = {112--121}, year = {2013},
  doi = {10.1016/j.solener.2013.07.029}} % verified

@techreport{Ryberg2017,
  author = {Ryberg, David and Freeman, Janine},
  title = {Integration, Validation, and Application of a {PV} Snow Coverage Model in {SAM}},
  institution = {National Renewable Energy Laboratory}, number = {NREL/TP-6A20-68705}, year = {2017}}

@article{Holmgren2018,
  author = {Holmgren, William F. and Hansen, Clifford W. and Mikofski, Mark A.},
  title = {pvlib python: a python package for modeling solar energy systems},
  journal = {Journal of Open Source Software}, volume = {3}, number = {29}, pages = {884}, year = {2018},
  doi = {10.21105/joss.00884}} % UNVERIFIED in this session (from memory) -- check

@article{Jennings2018,
  author = {Jennings, Keith S. and Winchell, Taylor S. and Livneh, Ben and Molotch, Noah P.},
  title = {Spatial variation of the rain--snow temperature threshold across the {Northern Hemisphere}},
  journal = {Nature Communications}, volume = {9}, pages = {1148}, year = {2018},
  doi = {10.1038/s41467-018-03629-7}} % verified (Nature page)

@article{Baxter2005,
  author = {Baxter, Martin A. and Graves, Charles E. and Moore, James T.},
  title = {A Climatology of Snow-to-Liquid Ratio for the Contiguous {United States}},
  journal = {Weather and Forecasting}, volume = {20}, number = {5}, pages = {729--744}, year = {2005},
  doi = {10.1175/WAF856.1}} % verified (Crossref)

@article{Hedstrom1998,
  author = {Hedstrom, N. R. and Pomeroy, J. W.},
  title = {Measurements and modelling of snow interception in the boreal forest},
  journal = {Hydrological Processes}, volume = {12}, number = {10--11}, pages = {1611--1625}, year = {1998},
  doi = {10.1002/(SICI)1099-1085(199808/09)12:10/11<1611::AID-HYP684>3.0.CO;2-4}} % verified (Crossref)

@article{Mandelli2016load,
  author = {Mandelli, Stefano and Brivio, Claudio and Colombo, Emanuela and Merlo, Marco},
  title = {Effect of load profile uncertainty on the optimum sizing of off-grid {PV} systems for rural electrification},
  journal = {Sustainable Energy Technologies and Assessments}, volume = {18}, pages = {34--47}, year = {2016},
  doi = {10.1016/j.seta.2016.09.010}} % verified

@article{Lombardi2019,
  author = {Lombardi, Francesco and Balderrama, Sergio and Quoilin, Sylvain and Colombo, Emanuela},
  title = {Generating high-resolution multi-energy load profiles for remote areas with an open-source stochastic model},
  journal = {Energy}, volume = {177}, pages = {433--444}, year = {2019},
  doi = {10.1016/j.energy.2019.04.097}} % verified

@techreport{Deru2011,
  author = {Deru, Michael and Field, Kristin and Studer, Daniel and Benne, Kyle and Griffith, Brent and Torcellini, Paul and Liu, Bing and Halverson, Mark and Winiarski, Dave and Rosenberg, Michael and Yazdanian, Mehry and Huang, Joe and Crawley, Drury},
  title = {{U.S. Department of Energy} Commercial Reference Building Models of the National Building Stock},
  institution = {National Renewable Energy Laboratory}, number = {NREL/TP-5500-46861}, year = {2011}}

@article{Skarstein1989,
  author = {Skarstein, {\O}yvind and Uhlen, Kjetil},
  title = {Design considerations with respect to long-term diesel saving in wind/diesel plants},
  journal = {Wind Engineering}, volume = {13}, number = {2}, pages = {72--87}, year = {1989}} % pages, author given names, DOI UNVERIFIED (not read)

@article{Palmintier2014,
  author = {Palmintier, Bryan S. and Webster, Mort D.},
  title = {Heterogeneous Unit Clustering for Efficient Operational Flexibility Modeling},
  journal = {IEEE Transactions on Power Systems}, volume = {29}, number = {3}, pages = {1089--1098}, year = {2014},
  doi = {10.1109/TPWRS.2013.2293127}} % verified (Crossref)

@article{Bordin2017,
  author = {Bordin, Chiara and Anuta, Harold Oghenetejiri and Crossland, Andrew and Lascurain Gutierrez, Isabel and Dent, Chris J. and Vigo, Daniele},
  title = {A linear programming approach for battery degradation analysis and optimization in offgrid power systems with solar energy integration},
  journal = {Renewable Energy}, volume = {101}, pages = {417--430}, year = {2017},
  doi = {10.1016/j.renene.2016.08.066}} % verified

@article{Seger2023,
  author = {Seger, Pedro V. H. and Rigo-Mariani, R{\'e}my and Thivel, Pierre-Xavier and Riu, Delphine},
  title = {A storage degradation model of {Li-ion} batteries to integrate ageing effects in the optimal management and design of an isolated microgrid},
  journal = {Applied Energy}, volume = {333}, pages = {120584}, year = {2023},
  doi = {10.1016/j.apenergy.2022.120584}} % verified (RePEc record)
```

### Not verified / not to cite as-is
- "Eissa 2026 Sci. Rep.": not found.
- Townsend & Powers 2011, Azoumah 2011, Amillo 2014, Askarzadeh: not read.
- Lebanese/MENA peer-reviewed LPSP study: none found in the time available. Only AUB theses turned up, at scholarworks.aub.edu.lb.
- IEEE 446 is inactive-reserved.
- The EN 13223 clause content was not read.
