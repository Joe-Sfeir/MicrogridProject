"""Download site weather and PV-resource data for Faqra Club.

Sources (all public, no account needed):
  - PVGIS v5.3 (EU JRC), SARAH-3 satellite irradiance: hourly POA irradiance
    and 1 kWp PV output for several tilts, plus the horizon profile and a TMY.
  - ERA5-Land reanalysis (Copernicus), served by the Open-Meteo archive API:
    hourly temperature, snow depth, snowfall, radiation, wind.
  - NASA POWER: hourly GHI and temperature, as an independent cross-check.

Run with plain Python 3 (stdlib only). Writes CSV files to data/weather/
and a short summary to data/weather/summary.md.
"""
import csv, json, os, sys, time, urllib.request, urllib.parse
from collections import defaultdict

LAT, LON = 33.985, 35.811          # Faqra ski area (Elie's summary, skiresort.com)
YEARS = list(range(2014, 2026))    # 2014-2025; each source returns what it has
TILTS = [0, 30, 40, 50, 60]        # deg, south-facing (aspect 0 in PVGIS)
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "weather")
os.makedirs(OUT, exist_ok=True)
log = []

def get(url, params, tries=4):
    full = url + "?" + urllib.parse.urlencode(params)
    for k in range(tries):
        try:
            req = urllib.request.Request(full, headers={"User-Agent": "eece675-microgrid-study"})
            with urllib.request.urlopen(req, timeout=180) as r:
                return r.read().decode()
        except Exception as e:  # noqa
            err = e
            time.sleep(3 * (k + 1))
    raise RuntimeError(f"{url}: {err}")

def note(s):
    print(s); log.append(s)

# ---------------- PVGIS ----------------
PV = "https://re.jrc.ec.europa.eu/api/v5_3/"
pv_yearly = {}
try:
    hz = json.loads(get(PV + "printhorizon", {"lat": LAT, "lon": LON, "outputformat": "json"}))
    with open(os.path.join(OUT, "pvgis_horizon.csv"), "w", newline="") as f:
        w = csv.writer(f); w.writerow(["azimuth_deg", "horizon_height_deg"])
        for p in hz["outputs"]["horizon_profile"]:
            w.writerow([p["A"], p["H_hor"]])
    note("PVGIS horizon: ok")
except Exception as e:
    note(f"PVGIS horizon FAILED: {e}")

try:
    tmy = json.loads(get(PV + "tmy", {"lat": LAT, "lon": LON, "usehorizon": 1, "outputformat": "json"}))
    rows = tmy["outputs"]["tmy_hourly"]
    keys = list(rows[0].keys())
    with open(os.path.join(OUT, "pvgis_tmy.csv"), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=keys); w.writeheader(); w.writerows(rows)
    note(f"PVGIS TMY: ok, months from years {[m['year'] for m in tmy['outputs']['months_selected']]}")
except Exception as e:
    note(f"PVGIS TMY FAILED: {e}")

pv_meta = None
for tilt in TILTS:
    allrows = []
    for y in YEARS:
        try:
            js = json.loads(get(PV + "seriescalc", {
                "lat": LAT, "lon": LON, "startyear": y, "endyear": y,
                "pvcalculation": 1, "peakpower": 1, "loss": 14, "pvtechchoice": "crystSi",
                "mountingplace": "free", "angle": tilt, "aspect": 0,
                "components": 1, "usehorizon": 1, "raddatabase": "PVGIS-SARAH3",
                "outputformat": "json"}))
            pv_meta = pv_meta or js.get("inputs")
            allrows += js["outputs"]["hourly"]
        except Exception as e:
            note(f"PVGIS tilt {tilt} year {y}: not available ({str(e)[:80]})")
        time.sleep(0.3)
    if not allrows:
        continue
    keys = list(allrows[0].keys())
    with open(os.path.join(OUT, f"pvgis_hourly_tilt{tilt}.csv"), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=keys); w.writeheader(); w.writerows(allrows)
    yrs = defaultdict(float); win = defaultdict(float)
    for r in allrows:
        yr, mo = int(r["time"][:4]), int(r["time"][4:6])
        yrs[yr] += r["P"] / 1000.0
        if mo in (12, 1, 2):
            win[yr] += r["P"] / 1000.0
    pv_yearly[tilt] = (dict(yrs), dict(win))
    note(f"PVGIS tilt {tilt}: {len(allrows)} hours, years {min(yrs)}-{max(yrs)}")
if pv_meta:
    with open(os.path.join(OUT, "pvgis_inputs.json"), "w") as f:
        json.dump(pv_meta, f, indent=1)

# ---------------- ERA5-Land via Open-Meteo ----------------
OM = "https://archive-api.open-meteo.com/v1/archive"
VARS = ["temperature_2m", "snow_depth", "snowfall", "precipitation", "shortwave_radiation",
        "direct_radiation", "diffuse_radiation", "wind_speed_10m", "relative_humidity_2m"]
for tag, extra in [("downscaled", {}), ("gridcell", {"elevation": "nan"})]:
    times, data, elev = [], {v: [] for v in VARS}, None
    for y in YEARS:
        end = f"{y}-12-31"
        try:
            js = json.loads(get(OM, {"latitude": LAT, "longitude": LON, "start_date": f"{y}-01-01",
                                     "end_date": end, "hourly": ",".join(VARS),
                                     "models": "era5_land", "timezone": "GMT", **extra}))
            elev = js.get("elevation")
            h = js["hourly"]
            times += h["time"]
            for v in VARS:
                data[v] += h[v]
        except Exception as e:
            note(f"ERA5-Land {tag} {y}: FAILED ({str(e)[:80]})")
        time.sleep(1)
    if times:
        with open(os.path.join(OUT, f"era5land_hourly_{tag}.csv"), "w", newline="") as f:
            w = csv.writer(f); w.writerow(["time_utc"] + VARS)
            for i, t in enumerate(times):
                w.writerow([t] + [data[v][i] for v in VARS])
        note(f"ERA5-Land {tag}: {len(times)} hours, elevation used {elev} m")

# ---------------- NASA POWER ----------------
NP = "https://power.larc.nasa.gov/api/temporal/hourly/point"
P_VARS = ["ALLSKY_SFC_SW_DWN", "ALLSKY_SFC_SW_DIFF", "T2M", "WS10M"]
prow = {}
for y in YEARS:
    try:
        js = json.loads(get(NP, {"parameters": ",".join(P_VARS), "community": "RE",
                                 "longitude": LON, "latitude": LAT, "start": f"{y}0101",
                                 "end": f"{y}1231", "format": "JSON", "time-standard": "UTC"}))
        par = js["properties"]["parameter"]
        for t in par[P_VARS[0]]:
            prow[t] = [par[v][t] for v in P_VARS]
    except Exception as e:
        note(f"NASA POWER {y}: FAILED ({str(e)[:80]})")
    time.sleep(1)
if prow:
    with open(os.path.join(OUT, "nasapower_hourly.csv"), "w", newline="") as f:
        w = csv.writer(f); w.writerow(["time_utc_YYYYMMDDHH"] + P_VARS)
        for t in sorted(prow):
            w.writerow([t] + prow[t])
    note(f"NASA POWER: {len(prow)} hours")

# ---------------- Summary ----------------
def monthly(path, tcol, parse, cols, agg):
    s = defaultdict(lambda: defaultdict(list))
    if not os.path.exists(path):
        return None
    with open(path) as f:
        for r in csv.DictReader(f):
            y, m, d = parse(r[tcol])
            for c in cols:
                try:
                    v = float(r[c])
                except (TypeError, ValueError):
                    continue
                if v < -900:  # fill values
                    continue
                s[c][(y, m, d)].append(v)
    out = {}
    for c in cols:
        bym = defaultdict(list)
        for (y, m, d), vals in s[c].items():
            bym[m].append(agg[c](vals))
        out[c] = {m: sum(v) / len(v) for m, v in sorted(bym.items())}
    return out

lines = ["# Faqra weather data: summary", "", f"Site {LAT} N, {LON} E. Years requested {YEARS[0]}-{YEARS[-1]}.", ""]
lines += ["## Fetch log", ""] + [f"- {l}" for l in log] + [""]

daily_kwh = lambda v: sum(v) / 1000.0   # hourly W/m2 -> kWh/m2/day
mean = lambda v: sum(v) / len(v)
mx = lambda v: max(v)
srcs = {}
p0 = os.path.join(OUT, "pvgis_hourly_tilt0.csv")
srcs["PVGIS GHI (tilt 0)"] = monthly(p0, "time", lambda t: (t[:4], int(t[4:6]), t[6:8]),
                                    ["Gb(i)", "Gd(i)", "T2m"], {"Gb(i)": daily_kwh, "Gd(i)": daily_kwh, "T2m": mean})
e = os.path.join(OUT, "era5land_hourly_downscaled.csv")
srcs["ERA5-Land"] = monthly(e, "time_utc", lambda t: (t[:4], int(t[5:7]), t[8:10]),
                            ["shortwave_radiation", "temperature_2m", "snow_depth", "snowfall"],
                            {"shortwave_radiation": daily_kwh, "temperature_2m": mean,
                             "snow_depth": mx, "snowfall": sum})
n = os.path.join(OUT, "nasapower_hourly.csv")
srcs["NASA POWER"] = monthly(n, "time_utc_YYYYMMDDHH", lambda t: (t[:4], int(t[4:6]), t[6:8]),
                             ["ALLSKY_SFC_SW_DWN", "T2M"], {"ALLSKY_SFC_SW_DWN": daily_kwh, "T2M": mean})

lines += ["## Monthly means", "", "| Month | GHI PVGIS | GHI ERA5-L | GHI NASA | T PVGIS | T ERA5-L | T NASA | Snow depth ERA5-L (m, daily max) | Snowfall ERA5-L (cm/day) |",
          "|---|---|---|---|---|---|---|---|---|"]
def g(src, col, m, scale=1.0, nd=2):
    try:
        return f"{srcs[src][col][m] * scale:.{nd}f}"
    except Exception:
        return "-"
for m in range(1, 13):
    try:
        ghi_pv = f"{srcs['PVGIS GHI (tilt 0)']['Gb(i)'][m] + srcs['PVGIS GHI (tilt 0)']['Gd(i)'][m]:.2f}"
    except Exception:
        ghi_pv = "-"
    lines.append(f"| {m} | {ghi_pv} | {g('ERA5-Land','shortwave_radiation',m)} | {g('NASA POWER','ALLSKY_SFC_SW_DWN',m)} | "
                 f"{g('PVGIS GHI (tilt 0)','T2m',m,nd=1)} | {g('ERA5-Land','temperature_2m',m,nd=1)} | {g('NASA POWER','T2M',m,nd=1)} | "
                 f"{g('ERA5-Land','snow_depth',m)} | {g('ERA5-Land','snowfall',m)} |")
lines += ["", "GHI in kWh/m2/day, T in deg C.", ""]

if pv_yearly:
    lines += ["## PVGIS yield per tilt (kWh/kWp, 14% system loss, horizon on, no snow)", "",
              "| Tilt | Annual mean | Annual min | Annual max | Dec-Feb mean |", "|---|---|---|---|---|"]
    for tilt, (yrs, win) in pv_yearly.items():
        a = list(yrs.values()); wv = list(win.values())
        lines.append(f"| {tilt} | {mean(a):.0f} | {min(a):.0f} | {max(a):.0f} | {mean(wv):.0f} |")
    lines.append("")
with open(os.path.join(OUT, "summary.md"), "w") as f:
    f.write("\n".join(lines))
print("\n".join(lines))
