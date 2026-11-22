# Faqra Club PV-BESS microgrid (EECE 675)

Feasibility study of a PV + battery microgrid with diesel backup for Faqra Club, Lebanon.

- `docs/data_inventory.md`: summary of every model input, with low/base/high values and sources.
- `docs/research/`: detailed sourced reports per block (lifts, hotel and restaurants, chalets, water and auxiliaries, grid and diesel, costs and battery).
- `data/weather/`: hourly PVGIS (SARAH-3 and ERA5, tilts 0-60°), ERA5-Land, ERA5 and NASA POWER series for the site.
- `data/site/`: OpenStreetMap buildings, roads and lifts around Faqra.
- `data/grid/`: EDL hourly on/off record of the Faqra 20 kV feeder (Faitroun substation), Dec 2024 - Oct 2026.
- `tools/`: download scripts (run by the GitHub Actions workflows in `.github/workflows/`) and research calculation scripts.
- `inputs/`: the prepared model inputs (8,760-hour load, PV and grid series, `parameters.json`).
- `model/`: the MATLAB LP model (sizing + hourly dispatch, grid export, NPV/IRR/payback). Run `main` in MATLAB
  (Optimization Toolbox) from the `model/` folder; `main('quick')` solves only the reference and the base case.
  `model/tests/test_small_case.m` holds 48-hour cases with hand-calculated answers. The modelling briefs are
  `docs/fable_prompt.md` (round 1) and `docs/fable_prompt_round2.md` (round 2: no load shedding in the base
  case, grid export, finance metrics, diesel price sweep).
- `results/`: tables (CSV), figures (PNG) and a summary (`results/README.md`) written by `model/main.m`.
