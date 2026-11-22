# Faqra weather data: summary

Site 33.985 N, 35.811 E. Years requested 2014-2025.

## Fetch log

- PVGIS horizon: ok
- PVGIS TMY: ok, months from years [2007, 2020, 2019, 2006, 2017, 2009, 2015, 2016, 2015, 2022, 2013, 2011]
- PVGIS tilt 0 year 2024: not available (https://re.jrc.ec.europa.eu/api/v5_3/seriescalc: HTTP Error 400: BAD REQUEST)
- PVGIS tilt 0 year 2025: not available (https://re.jrc.ec.europa.eu/api/v5_3/seriescalc: HTTP Error 400: BAD REQUEST)
- PVGIS tilt 0: 87648 hours, years 2014-2023
- PVGIS tilt 30 year 2024: not available (https://re.jrc.ec.europa.eu/api/v5_3/seriescalc: HTTP Error 400: BAD REQUEST)
- PVGIS tilt 30 year 2025: not available (https://re.jrc.ec.europa.eu/api/v5_3/seriescalc: HTTP Error 400: BAD REQUEST)
- PVGIS tilt 30: 87648 hours, years 2014-2023
- PVGIS tilt 40 year 2024: not available (https://re.jrc.ec.europa.eu/api/v5_3/seriescalc: HTTP Error 400: BAD REQUEST)
- PVGIS tilt 40 year 2025: not available (https://re.jrc.ec.europa.eu/api/v5_3/seriescalc: HTTP Error 400: BAD REQUEST)
- PVGIS tilt 40: 87648 hours, years 2014-2023
- PVGIS tilt 50 year 2024: not available (https://re.jrc.ec.europa.eu/api/v5_3/seriescalc: HTTP Error 400: BAD REQUEST)
- PVGIS tilt 50 year 2025: not available (https://re.jrc.ec.europa.eu/api/v5_3/seriescalc: HTTP Error 400: BAD REQUEST)
- PVGIS tilt 50: 87648 hours, years 2014-2023
- PVGIS tilt 60 year 2024: not available (https://re.jrc.ec.europa.eu/api/v5_3/seriescalc: HTTP Error 400: BAD REQUEST)
- PVGIS tilt 60 year 2025: not available (https://re.jrc.ec.europa.eu/api/v5_3/seriescalc: Remote end closed connection wi)
- PVGIS tilt 60: 87648 hours, years 2014-2023
- ERA5-Land downscaled: 105192 hours, elevation used 1710.0 m
- ERA5-Land gridcell: 105192 hours, elevation used 1522.0 m
- NASA POWER: 105192 hours

## Monthly means

| Month | GHI PVGIS | GHI ERA5-L | GHI NASA | T PVGIS | T ERA5-L | T NASA | Snow depth ERA5-L (m, daily max) | Snowfall ERA5-L (cm/day) |
|---|---|---|---|---|---|---|---|---|
| 1 | 1.77 | - | 2.65 | 2.2 | 1.8 | 11.7 | 0.04 | - |
| 2 | 2.63 | - | 3.58 | 3.7 | 2.4 | 12.0 | 0.03 | - |
| 3 | 3.64 | - | 4.77 | 6.7 | 5.4 | 14.1 | 0.01 | - |
| 4 | 5.70 | - | 6.26 | 11.3 | 9.5 | 17.6 | 0.00 | - |
| 5 | 7.10 | - | 7.35 | 16.1 | 13.7 | 21.2 | 0.00 | - |
| 6 | 8.06 | - | 8.10 | 19.3 | 17.6 | 24.3 | 0.00 | - |
| 7 | 8.27 | - | 7.98 | 22.5 | 20.4 | 26.6 | 0.00 | - |
| 8 | 7.45 | - | 7.15 | 22.7 | 20.7 | 26.6 | 0.00 | - |
| 9 | 6.08 | - | 6.07 | 20.4 | 18.4 | 25.3 | 0.00 | - |
| 10 | 4.23 | - | 4.56 | 15.7 | 13.9 | 22.3 | 0.00 | - |
| 11 | 2.83 | - | 3.20 | 9.5 | 8.4 | 18.2 | 0.00 | - |
| 12 | 1.94 | - | 2.50 | 5.3 | 4.4 | 14.0 | 0.00 | - |

GHI in kWh/m2/day, T in deg C.

## PVGIS yield per tilt (kWh/kWp, 14% system loss, horizon on, no snow)

| Tilt | Annual mean | Annual min | Annual max | Dec-Feb mean |
|---|---|---|---|---|
| 0 | 1393 | 1342 | 1451 | 149 |
| 30 | 1484 | 1424 | 1559 | 198 |
| 40 | 1449 | 1387 | 1526 | 205 |
| 50 | 1382 | 1320 | 1458 | 208 |
| 60 | 1283 | 1223 | 1356 | 206 |
