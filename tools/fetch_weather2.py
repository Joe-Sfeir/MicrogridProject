"""Supplementary weather downloads (cross-checks for the first fetch).

1. ERA5 (0.25 deg) via Open-Meteo: snowfall, precipitation, radiation, snow depth,
   temperature. The ERA5-Land feed on Open-Meteo carries temperature and snow
   depth only, so snowfall and radiation come from ERA5.
2. PVGIS seriescalc with the PVGIS-ERA5 radiation database (tilts 0 and 40), to
   compare with the SARAH-3 satellite series (satellite retrievals can mistake
   snow cover for cloud in winter).
Stdlib only. Writes to data/weather/.
"""
import csv, json, os, time, urllib.parse, urllib.request

LAT, LON = 33.985, 35.811
YEARS = list(range(2014, 2026))
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "weather")
os.makedirs(OUT, exist_ok=True)

def get(url, params, tries=4):
    full = url + "?" + urllib.parse.urlencode(params)
    for k in range(tries):
        try:
            with urllib.request.urlopen(urllib.request.Request(full, headers={"User-Agent": "eece675-microgrid-study"}), timeout=180) as r:
                return r.read().decode()
        except Exception as e:  # noqa
            err = e; time.sleep(3 * (k + 1))
    raise RuntimeError(str(err))

VARS = ["temperature_2m", "snow_depth", "snowfall", "precipitation", "shortwave_radiation",
        "direct_radiation", "diffuse_radiation", "wind_speed_10m", "cloud_cover"]
times, data = [], {v: [] for v in VARS}
for y in YEARS:
    try:
        js = json.loads(get("https://archive-api.open-meteo.com/v1/archive", {
            "latitude": LAT, "longitude": LON, "start_date": f"{y}-01-01", "end_date": f"{y}-12-31",
            "hourly": ",".join(VARS), "models": "era5", "timezone": "GMT"}))
        times += js["hourly"]["time"]
        for v in VARS:
            data[v] += js["hourly"][v]
        print("ERA5", y, "ok, elevation", js.get("elevation"))
    except Exception as e:
        print("ERA5", y, "FAILED", e)
    time.sleep(1)
with open(os.path.join(OUT, "era5_hourly.csv"), "w", newline="") as f:
    w = csv.writer(f); w.writerow(["time_utc"] + VARS)
    for i, t in enumerate(times):
        w.writerow([t] + [data[v][i] for v in VARS])

for tilt in (0, 40):
    rows = []
    for y in range(2014, 2024):
        try:
            js = json.loads(get("https://re.jrc.ec.europa.eu/api/v5_3/seriescalc", {
                "lat": LAT, "lon": LON, "startyear": y, "endyear": y, "pvcalculation": 1,
                "peakpower": 1, "loss": 14, "angle": tilt, "aspect": 0, "components": 1,
                "usehorizon": 1, "raddatabase": "PVGIS-ERA5", "outputformat": "json"}))
            rows += js["outputs"]["hourly"]
        except Exception as e:
            print("PVGIS-ERA5", tilt, y, "FAILED", e)
        time.sleep(0.3)
    if rows:
        with open(os.path.join(OUT, f"pvgis_era5_hourly_tilt{tilt}.csv"), "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)
        print("PVGIS-ERA5 tilt", tilt, len(rows), "hours")
