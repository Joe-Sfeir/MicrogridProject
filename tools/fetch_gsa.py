"""Global Solar Atlas (World Bank / Solargis) long-term monthly averages at the site.
Used as an independent third source for monthly GHI, especially in winter.
Writes data/weather/gsa_lta.json (raw) and gsa_monthly.csv."""
import csv, json, os, urllib.request
LAT, LON = 33.985, 35.811
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "weather")
urls = [f"https://api.globalsolaratlas.info/data/lta?loc={LAT},{LON}",
        f"https://api.globalsolaratlas.info/data/pvcalc?loc={LAT},{LON}"]
for u in urls:
    try:
        req = urllib.request.Request(u, headers={"User-Agent": "Mozilla/5.0 eece675-microgrid-study", "Accept": "application/json",
                                                "Referer": "https://globalsolaratlas.info/"})
        txt = urllib.request.urlopen(req, timeout=120).read().decode()
        name = "gsa_lta.json" if "lta" in u else "gsa_pvcalc.json"
        open(os.path.join(OUT, name), "w").write(txt)
        print(u, "ok", txt[:3000])
    except Exception as e:
        print(u, "FAILED", e)
try:
    js = json.load(open(os.path.join(OUT, "gsa_lta.json")))
    m = js["monthly"]["data"]
    keys = [k for k in m if isinstance(m[k], list)]
    with open(os.path.join(OUT, "gsa_monthly.csv"), "w", newline="") as f:
        w = csv.writer(f); w.writerow(["month"] + keys)
        for i in range(12):
            w.writerow([i + 1] + [m[k][i] for k in keys])
except Exception as e:
    print("parse failed", e)
