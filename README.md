# Faqra Club PV-BESS microgrid (EECE 675)

- `tools/fetch_weather.py` downloads public site weather data (PVGIS, ERA5-Land via Open-Meteo, NASA POWER).
- `.github/workflows/fetch-weather.yml` runs it on GitHub Actions and commits the results to `data/weather/`.
