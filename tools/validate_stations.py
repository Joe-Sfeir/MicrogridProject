"""Validate PVGIS-SARAH3 and PVGIS-ERA5 irradiance against Lebanese ground stations.

Ground data: World Bank / ESMAP solar measurement campaign in Lebanon
(Fraunhofer ISE, stations Ras Baalbak and LARI Tal Amara, 1-min RSI data),
published on energydata.info. Only monthly aggregates are committed.
"""
import csv, io, json, os, re, time, urllib.parse, urllib.request
from collections import defaultdict

OUT = os.path.join(os.path.dirname(__file__), "..", "data", "validation")
os.makedirs(OUT, exist_ok=True)
UA = {"User-Agent": "eece675-microgrid-study"}

def http(url, tries=4):
    for k in range(tries):
        try:
            return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=600)
        except Exception as e:  # noqa
            err = e; time.sleep(5 * (k + 1))
    raise RuntimeError(f"{url}: {err}")

pkg = json.load(http("https://energydata.info/api/3/action/package_show?id=lebanon-solar-radiation-measurements"))["result"]
with open(os.path.join(OUT, "esmap_package.json"), "w") as f:
    json.dump({k: pkg.get(k) for k in ("title", "notes", "license_title", "license_id", "author", "organization", "metadata_created", "metadata_modified", "url")}
              | {"resources": [{k: r.get(k) for k in ("name", "url", "format", "size", "description")} for r in pkg["resources"]]}, f, indent=1, default=str)
res = {r["name"]: r["url"] for r in pkg["resources"]}
print(json.dumps(res, indent=1))

FALLBACK = {"RasBaalbak": (34.26, 36.42), "LariTalAmara": (33.86, 35.99)}
lines = ["# Ground-station check of PVGIS irradiance (Lebanon, ESMAP campaign)", "",
         f"Dataset: {pkg.get('title')}; licence: {pkg.get('license_title')}; source: energydata.info", ""]

for st in ("LariTalAmara", "RasBaalbak"):
    hdr_name = next((n for n in res if st in n and "Header" in n), None)
    qc_name = next((n for n in res if st in n and "QC" in n), None)
    lat, lon, elev = *FALLBACK[st], None
    if hdr_name:
        txt = http(res[hdr_name]).read().decode(errors="replace")
        open(os.path.join(OUT, f"{st}_header.csv"), "w").write(txt)
        for ln in txt.splitlines():
            l = ln.lower()
            m = re.findall(r"-?\d+\.\d+", ln)
            if "latitude" in l and m: lat = float(m[0])
            if "longitude" in l and m: lon = float(m[0])
            if ("elevation" in l or "altitude" in l) and re.findall(r"\d+(?:\.\d+)?", ln): elev = re.findall(r"\d+(?:\.\d+)?", ln)[0]
    print(st, lat, lon, elev)
    # stream the QC CSV and build daily GHI sums
    daily = defaultdict(float); cnt = defaultdict(int)
    r = http(res[qc_name])
    tio = io.TextIOWrapper(r, encoding="utf-8", errors="replace")
    header = None; ti = gi = None; step_h = 1 / 60
    for ln in tio:
        if header is None:
            if re.search(r"\bGHI\b", ln, re.I) and ("time" in ln.lower() or "date" in ln.lower()):
                sep = ";" if ln.count(";") > ln.count(",") else ","
                header = [h.strip().strip('"') for h in ln.strip().split(sep)]
                ti = next(i for i, h in enumerate(header) if "time" in h.lower() or "date" in h.lower())
                gi = next(i for i, h in enumerate(header) if re.fullmatch(r"GHI.*", h, re.I))
                print(st, "header:", header[:12], "time col", header[ti], "ghi col", header[gi])
            continue
        p = ln.strip().split(sep)
        if len(p) <= gi: continue
        try:
            g = float(p[gi])
        except ValueError:
            continue
        if g != g or g < -50 or g > 1500: continue
        day = p[ti].strip().strip('"')[:10]
        daily[day] += max(g, 0) * step_h / 1000.0; cnt[day] += 1
    good = {d: v for d, v in daily.items() if cnt[d] >= 0.9 * 1440}
    print(st, "days", len(daily), "good days", len(good))
    mon = defaultdict(list)
    for d, v in good.items():
        ym = d[:7].replace("/", "-")
        mon[ym].append(v)
    months = sorted(mon)
    # PVGIS SARAH3 and ERA5 for the same years
    years = sorted({int(m[:4]) for m in months})
    pv = {}
    for db in ("PVGIS-SARAH3", "PVGIS-ERA5"):
        acc = defaultdict(float); n = defaultdict(int)
        for y in years:
            try:
                js = json.load(http("https://re.jrc.ec.europa.eu/api/v5_3/seriescalc?" + urllib.parse.urlencode({
                    "lat": lat, "lon": lon, "startyear": y, "endyear": y, "angle": 0, "components": 1,
                    "usehorizon": 1, "raddatabase": db, "outputformat": "json"})))
                for h in js["outputs"]["hourly"]:
                    t = h["time"]; ym = f"{t[:4]}-{t[4:6]}"
                    acc[ym] += (h["Gb(i)"] + h["Gd(i)"]) / 1000.0; n[ym] += 1
            except Exception as e:
                print(db, y, "failed", e)
        pv[db] = {ym: acc[ym] / (n[ym] / 24) for ym in acc if n[ym]}
    with open(os.path.join(OUT, f"{st}_monthly_ghi.csv"), "w", newline="") as f:
        w = csv.writer(f); w.writerow(["month", "ground_kwh_m2_day", "ground_days", "pvgis_sarah3", "pvgis_era5"])
        for ym in months:
            w.writerow([ym, round(sum(mon[ym]) / len(mon[ym]), 3), len(mon[ym]),
                        round(pv["PVGIS-SARAH3"].get(ym, float("nan")), 3), round(pv["PVGIS-ERA5"].get(ym, float("nan")), 3)])
    lines += [f"## {st} ({lat}, {lon}, elev {elev})", "", "| Month | Ground | days | SARAH-3 | ERA5 |", "|---|---|---|---|---|"]
    for ym in months:
        lines.append(f"| {ym} | {sum(mon[ym])/len(mon[ym]):.2f} | {len(mon[ym])} | {pv['PVGIS-SARAH3'].get(ym, float('nan')):.2f} | {pv['PVGIS-ERA5'].get(ym, float('nan')):.2f} |")
    lines.append("")
open(os.path.join(OUT, "summary.md"), "w").write("\n".join(lines))
print("\n".join(lines))
