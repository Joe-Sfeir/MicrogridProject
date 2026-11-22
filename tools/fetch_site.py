"""Download public site-geometry data for Faqra Club from OpenStreetMap.

- Overpass API: ski lifts (aerialway), pistes, buildings, roads, street lamps,
  amenities inside a bounding box around the Faqra ski area and club.
- Open-Meteo elevation API (Copernicus DEM GLO-90): elevation of lift ends.
Writes data/site/osm_raw.json, lifts.csv, buildings.csv, roads.csv, summary.md.
Stdlib only.
"""
import csv, json, math, os, time, urllib.parse, urllib.request
from collections import defaultdict

S, W, N, E = 33.96, 35.78, 34.03, 35.86
OUT = os.path.join(os.path.dirname(__file__), "..", "data", "site")
os.makedirs(OUT, exist_ok=True)
UA = {"User-Agent": "eece675-microgrid-study"}

def http(url, data=None, tries=4):
    for k in range(tries):
        try:
            req = urllib.request.Request(url, data=data, headers=UA)
            with urllib.request.urlopen(req, timeout=300) as r:
                return r.read().decode()
        except Exception as e:  # noqa
            err = e; time.sleep(5 * (k + 1))
    raise RuntimeError(str(err))

bb = f"{S},{W},{N},{E}"
q = f"""[out:json][timeout:180];
(
 way["aerialway"]({bb}); node["aerialway"]({bb});
 way["piste:type"]({bb});
 way["building"]({bb}); relation["building"]({bb});
 way["highway"]({bb});
 node["highway"="street_lamp"]({bb});
 nwr["amenity"]({bb}); nwr["tourism"]({bb}); nwr["leisure"]({bb});
 nwr["man_made"]({bb}); nwr["power"]({bb});
 nwr["landuse"]({bb}); nwr["place"]({bb});
);
out tags geom;"""
raw = None
for ep in ["https://overpass-api.de/api/interpreter", "https://overpass.kumi.systems/api/interpreter"]:
    try:
        raw = http(ep, data=urllib.parse.urlencode({"data": q}).encode()); break
    except Exception as e:
        print("overpass failed", ep, e)
js = json.loads(raw)
with open(os.path.join(OUT, "osm_raw.json"), "w") as f:
    json.dump(js, f)
els = js["elements"]

def hav(a, b):
    R = 6371000.0
    la1, lo1, la2, lo2 = map(math.radians, (a[0], a[1], b[0], b[1]))
    h = math.sin((la2 - la1) / 2) ** 2 + math.cos(la1) * math.cos(la2) * math.sin((lo2 - lo1) / 2) ** 2
    return 2 * R * math.asin(math.sqrt(h))

def length(geom):
    pts = [(g["lat"], g["lon"]) for g in geom]
    return sum(hav(pts[i], pts[i + 1]) for i in range(len(pts) - 1))

def area(geom):
    pts = [(g["lat"], g["lon"]) for g in geom]
    if len(pts) < 3: return 0.0
    lat0 = math.radians(sum(p[0] for p in pts) / len(pts))
    xy = [(math.radians(p[1]) * 6371000 * math.cos(lat0), math.radians(p[0]) * 6371000) for p in pts]
    return abs(sum(xy[i][0] * xy[i + 1][1] - xy[i + 1][0] * xy[i][1] for i in range(len(xy) - 1))) / 2

def elevations(pts):
    out = []
    for i in range(0, len(pts), 100):
        chunk = pts[i:i + 100]
        u = "https://api.open-meteo.com/v1/elevation?" + urllib.parse.urlencode({
            "latitude": ",".join(f"{p[0]:.6f}" for p in chunk),
            "longitude": ",".join(f"{p[1]:.6f}" for p in chunk)})
        out += json.loads(http(u))["elevation"]; time.sleep(1)
    return out

lifts = [e for e in els if e["type"] == "way" and "aerialway" in e.get("tags", {})]
ends = []
for l in lifts:
    g = l["geometry"]; ends += [(g[0]["lat"], g[0]["lon"]), (g[-1]["lat"], g[-1]["lon"])]
el = elevations(ends) if ends else []
with open(os.path.join(OUT, "lifts.csv"), "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["osm_id", "name", "aerialway", "length_m_horiz", "z_start_m", "z_end_m", "rise_m",
                "slope_length_m", "capacity_tag", "occupancy_tag", "duration_tag", "lat_start", "lon_start", "lat_end", "lon_end"])
    for i, l in enumerate(lifts):
        t = l["tags"]; L = length(l["geometry"]); z0, z1 = el[2 * i], el[2 * i + 1]
        g = l["geometry"]
        w.writerow([l["id"], t.get("name", ""), t.get("aerialway"), round(L), z0, z1, round(abs(z1 - z0)),
                    round(math.hypot(L, z1 - z0)), t.get("aerialway:capacity", ""), t.get("aerialway:occupancy", ""),
                    t.get("aerialway:duration", ""), g[0]["lat"], g[0]["lon"], g[-1]["lat"], g[-1]["lon"]])

with open(os.path.join(OUT, "buildings.csv"), "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["osm_id", "building", "name", "amenity", "tourism", "levels", "footprint_m2", "lat", "lon"])
    for e in els:
        t = e.get("tags", {})
        if e["type"] == "way" and "building" in t and "geometry" in e:
            g = e["geometry"]
            w.writerow([e["id"], t.get("building"), t.get("name", ""), t.get("amenity", ""), t.get("tourism", ""),
                        t.get("building:levels", ""), round(area(g)), g[0]["lat"], g[0]["lon"]])

rl = defaultdict(float); lit = defaultdict(float)
with open(os.path.join(OUT, "roads.csv"), "w", newline="") as f:
    w = csv.writer(f); w.writerow(["osm_id", "highway", "name", "lit", "length_m"])
    for e in els:
        t = e.get("tags", {})
        if e["type"] == "way" and "highway" in t and "geometry" in e:
            L = length(e["geometry"]); rl[t["highway"]] += L
            if t.get("lit") == "yes": lit[t["highway"]] += L
            w.writerow([e["id"], t["highway"], t.get("name", ""), t.get("lit", ""), round(L)])

named = [e for e in els if e.get("tags", {}).get("name") and not ("highway" in e["tags"] and e["type"] == "way")]
lines = ["# Faqra site geometry (OpenStreetMap)", "", f"Bounding box {bb}. Elements: {len(els)}.", "",
         "## Lifts", "", "| name | type | horiz. length m | rise m |", "|---|---|---|---|"]
for i, l in enumerate(lifts):
    t = l["tags"]; lines.append(f"| {t.get('name','')} | {t.get('aerialway')} | {length(l['geometry']):.0f} | {abs(el[2*i+1]-el[2*i]):.0f} |")
nb = sum(1 for e in els if e["type"] == "way" and "building" in e.get("tags", {}))
lines += ["", f"Buildings mapped: {nb}", f"Street lamps mapped: {sum(1 for e in els if e.get('tags',{}).get('highway')=='street_lamp')}",
          "", "## Road length by type (km)", ""] + [f"- {k}: {v/1000:.2f} (lit {lit[k]/1000:.2f})" for k, v in sorted(rl.items(), key=lambda x: -x[1])]
lines += ["", "## Named features", ""] + sorted({f"- {e['tags'].get('name')} | " + ", ".join(f"{k}={v}" for k, v in e['tags'].items() if k in ('amenity','tourism','leisure','building','aerialway','man_made','power','place','landuse')) for e in named})
with open(os.path.join(OUT, "summary.md"), "w") as f:
    f.write("\n".join(lines))
print("\n".join(lines))
