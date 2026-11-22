"""Build the hourly (8,760 h) input files for the Faqra microgrid LP.

Outputs (inputs/):
  load_low.csv, load_base.csv, load_high.csv   hourly load by block, kW
  pv_per_kWp.csv                                hourly PV output per kWp, by irradiance case and tilt, kW/kWp
  grid_availability.csv                         hourly grid on/off (1 = EDL supplies), several scenarios
  inputs_summary.md                             annual energy, peaks and checks

Every parameter below is taken from docs/research/*.md (see the parameter IDs in the
comments) and docs/data_inventory.md. Model clock: calendar year 2026, one row per UTC
hour. Behavioural schedules (opening hours, lighting, occupancy) use the local clock of
Asia/Beirut including daylight-saving time; the local time is written in each file.
Run: python3 -I tools/build_inputs.py   (needs numpy)
"""
import csv, json, math, os
from datetime import datetime, timedelta, timezone, date
from zoneinfo import ZoneInfo
import numpy as np

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
W = os.path.join(ROOT, "data", "weather")
OUT = os.path.join(ROOT, "inputs")
os.makedirs(OUT, exist_ok=True)
TZ = ZoneInfo("Asia/Beirut")
YEAR = 2026
SC = ("low", "base", "high")
IDX = {"low": 0, "base": 1, "high": 2}

# ---------------------------------------------------------------- calendar
utc0 = datetime(YEAR, 1, 1, tzinfo=timezone.utc)
UTC = [utc0 + timedelta(hours=h) for h in range(8760)]
LOC = [t.astimezone(TZ) for t in UTC]
HOUR = np.array([t.hour for t in LOC])
MON = np.array([t.month for t in LOC])
DATE = [t.date() for t in LOC]
WKD = np.array([t.weekday() for t in LOC])          # 0 = Monday

def in_range(d, m1, d1, m2, d2):
    """Inclusive month/day window within one calendar year (no wrap)."""
    return (d.month, d.day) >= (m1, d1) and (d.month, d.day) <= (m2, d2)

def is_holiday(d):
    # Christmas / New Year / Armenian Christmas school break (24 Dec - 6 Jan), chalets.md (d)
    return in_range(d, 12, 24, 12, 31) or in_range(d, 1, 1, 1, 6)

WEEKEND = np.array([(t.weekday() >= 5) or is_holiday(t.date()) for t in LOC])

def period(d):
    """Chalet / water occupancy period, chalets.md (d): ski 20 Dec-31 Mar, summer 1 Jul-15 Sep."""
    if in_range(d, 12, 20, 12, 31) or in_range(d, 1, 1, 3, 31):
        return "ski"
    if in_range(d, 7, 1, 9, 15):
        return "summer"
    return "shoulder"

PER = np.array([period(d) for d in DATE])

# chalets.md (d): occupancy factor by period and day type (low, base, high)
OCC = {("ski", True): (0.50, 0.70, 0.90), ("ski", False): (0.10, 0.20, 0.35),
       ("summer", True): (0.50, 0.70, 0.90), ("summer", False): (0.30, 0.45, 0.65),
       ("shoulder", True): (0.15, 0.25, 0.40), ("shoulder", False): (0.03, 0.05, 0.15)}

def occ_series(s):
    return np.array([OCC[(PER[i], bool(WEEKEND[i]))][IDX[s]] for i in range(8760)])

# ---------------------------------------------------------------- 1. ski lifts (lifts.md)
LIFT = {  # name: (type, H m, L m, Q p/h, P_rated low/base/high kW)
    "T1": ("chair", 240, 880, 1200, (110, 150, 160)),
    "T2": ("surface", 140, 540, 1000, (40, 50, 60)),
    "T3": ("surface", 150, 410, 600, (24, 30, 36)),
    "T4": ("surface", 30, 230, 350, (4, 5.5, 9)),
}
LP = {  # lifts.md (a)
    "m": (75, 80, 85), "mu": (0.06, 0.12, 0.12), "eta": (0.95, 0.90, 0.85),
    "phi_chair": (0.30, 0.375, 0.45), "phi_surf": (0.20, 0.30, 0.40),
    "hours": ((9, 16), (8, 16), (8, 17)), "days": (60, 80, 100),
    "S": (5000, 10700, 26000), "r": (6, 8, 12), "wk_ratio": 3.0,
}
# Ride share by local hour 08..16 (Szlosarek 2019 Table 5, lifts.md (c)); hour 16-17 for the 9-h day
# reuses the 15-16 value (assumed).
SHARE = {8: 0.108, 9: 0.216, 10: 0.186, 11: 0.159, 12: 0.070, 13: 0.095, 14: 0.095, 15: 0.070, 16: 0.070}

def ski_days(s):
    """Season of D operating days: the December part starts on 20/22 Dec, the rest runs from 1 Jan."""
    D = LP["days"][IDX[s]]
    dec_start = {"low": None, "base": 22, "high": 20}[s]
    dec_days = 0 if dec_start is None else 31 - dec_start + 1
    jan_days = D - dec_days
    out = set()
    d0 = date(YEAR, 1, 1)
    for k in range(jan_days):
        out.add(d0 + timedelta(days=k))
    if dec_start:
        for k in range(dec_days):
            out.add(date(YEAR, 12, dec_start) + timedelta(days=k))
    return out

def lifts(s):
    i = IDX[s]
    h0, h1 = LP["hours"][i]
    hrs = list(range(h0, h1))
    sh = np.array([SHARE[h] for h in hrs]); sh = sh / sh.sum()
    days = ski_days(s)
    nwe = sum(1 for d in days if (d.weekday() >= 5 or is_holiday(d)))
    nwd = len(days) - nwe
    S, r = LP["S"][i], LP["r"][i]
    sk_wd = S / (nwd + LP["wk_ratio"] * nwe)                 # lifts.md b4
    Qtot = sum(v[3] for v in LIFT.values())
    P = np.zeros(8760); Pi = {k: np.zeros(8760) for k in LIFT}
    for t in range(8760):
        d = DATE[t]
        if d not in days or HOUR[t] not in hrs:
            continue
        sk = sk_wd * (LP["wk_ratio"] if WEEKEND[t] else 1.0)
        rides = sk * r * sh[hrs.index(HOUR[t])]
        for k, (typ, H, L, Q, Pr) in LIFT.items():
            Prated = Pr[i]
            phi = LP["phi_chair"][i] if typ == "chair" else LP["phi_surf"][i]
            Heff = H if typ == "chair" else H + LP["mu"][i] * math.sqrt(L * L - H * H)
            e = LP["m"][i] * 9.81 * Heff / (LP["eta"][i] * 3.6e6)  # kWh per ride, lifts.md b1
            p = min(Prated, phi * Prated + rides * Q / Qtot * e)
            Pi[k][t] = p; P[t] += p
    return P, Pi, days

# ---------------------------------------------------------------- 2. hotel and restaurants (hotel_restaurants.md, tools/research/hotel_calc.py)
PROF = json.load(open(os.path.join(ROOT, "data", "hotel_restaurant_profiles.json")))
HOCC = [0.70, 0.75, 0.60, 0.32, 0.33, 0.43, 0.60, 0.60, 0.38, 0.32, 0.24, 0.50]
HSCALE = {"low": 0.643, "base": 1.0, "high": 1.25}
HP = {"low": dict(area=25 * 25, eui=86, fv=0.15), "base": dict(area=49.8 * 25, eui=105, fv=0.25),
      "high": dict(area=77.1 * 25, eui=130, fv=0.35)}
RP = {"low": dict(area=3 * 232.3, eui=65.7, fv=0.54), "base": dict(area=3 * 511, eui=90, fv=0.54),
      "high": dict(area=3 * 511, eui=270, fv=0.54)}
OCC_REF = 0.75
WINTER_M = {1, 2, 3, 4, 10, 11, 12}

def daysplit(o):
    wd = o * 7 / 9; we = min(1.0, 2 * wd)
    if we == 1.0:
        wd = (7 * o - 2) / 5
    return wd, we

def hospitality(s, kind):
    P = HP[s] if kind == "hotel" else RP[s]
    key = "hotel" if kind == "hotel" else "rest"
    Eref = P["area"] * P["eui"]                     # kWh/yr at reference occupancy
    fv = P["fv"]; ff = 1 - fv
    out = np.zeros(8760)
    for t in range(8760):
        m = MON[t]
        o = min(0.95, HOCC[m - 1] * HSCALE[s])
        wd, we = daysplit(o)
        weekend = LOC[t].weekday() >= 5           # Sat/Sun as in the source calc
        oo = we if weekend else wd
        daily = Eref / 365 * (ff + fv * oo / OCC_REF)
        prof = PROF[f"{key}_{'winter' if m in WINTER_M else 'summer'}_{'weekend' if weekend else 'weekday'}"]
        out[t] = daily * prof[HOUR[t]]
    return out

# ---------------------------------------------------------------- 3. chalets (chalets.md)
CH_N = (350, 400, 400)
CH_KWH = {"ski": (16.1, 24.8, 40.0), "summer": (16.1, 16.1, 24.8), "shoulder": (16.1, 18.9, 24.8)}
CH_STBY_KW = (0.030, 0.050, 0.100)
# Spanish P2.0TD winter profile shifted -1 h (chalets.md (c)); row k = hour ending k  -> index k-1 = hour starting k-1
CH_WD = [0.0301, 0.0267, 0.0249, 0.0243, 0.0251, 0.0288, 0.0365, 0.0400, 0.0419, 0.0437, 0.0436, 0.0442,
         0.0468, 0.0481, 0.0458, 0.0438, 0.0445, 0.0498, 0.0557, 0.0602, 0.0607, 0.0540, 0.0445, 0.0364]
CH_WE = [0.0330, 0.0288, 0.0264, 0.0254, 0.0254, 0.0265, 0.0293, 0.0338, 0.0418, 0.0473, 0.0482, 0.0480,
         0.0504, 0.0513, 0.0472, 0.0440, 0.0436, 0.0480, 0.0522, 0.0551, 0.0567, 0.0525, 0.0458, 0.0394]

def chalets(s):
    i = IDX[s]; occ = occ_series(s); N = CH_N[i]
    out = np.zeros(8760)
    for t in range(8760):
        prof = CH_WE if WEEKEND[t] else CH_WD
        out[t] = N * (occ[t] * CH_KWH[PER[t]][i] * prof[HOUR[t]] + (1 - occ[t]) * CH_STBY_KW[i])
    return out

# ---------------------------------------------------------------- 4. auxiliaries (water_aux.md)
# C2 road-lighting lit fraction for hours 05, 06, 16, 17, 18, 19 by month; hours 0-4 and 20-23 = 1; 7-15 = 0
LIT = {1: (1.00, 0.67, 0.17, 0.99, 1, 1), 2: (1.00, 0.37, 0, 0.69, 1, 1), 3: (0.81, 0.04, 0, 0.25, 0.94, 1),
       4: (0.97, 0.14, 0, 0, 0.01, 0.87), 5: (0.60, 0, 0, 0, 0, 0.49), 6: (0.43, 0, 0, 0, 0, 0.20),
       7: (0.62, 0, 0, 0, 0, 0.20), 8: (0.94, 0.03, 0, 0, 0, 0.61), 9: (1.00, 0.32, 0, 0, 0.27, 0.99),
       10: (0.97, 0.53, 0.04, 0.21, 0.89, 1), 11: (0.99, 0.16, 0.41, 1.00, 1, 1), 12: (1.00, 0.57, 0.49, 1.00, 1, 1)}
ROAD_KW = (15.5, 24.7, 53.7); DIM = (0.5, 0.7, 1.0)                  # R5, R7

def road(s):
    i = IDX[s]; out = np.zeros(8760)
    for t in range(8760):
        h = HOUR[t]; m = MON[t]
        if h <= 4:
            f = DIM[i]
        elif h >= 20:
            f = 1.0
        elif 7 <= h <= 15:
            f = 0.0
        else:
            f = LIT[m][{5: 0, 6: 1, 16: 2, 17: 3, 18: 4, 19: 5}[h]]
        out[t] = ROAD_KW[i] * f
    return out

W8 = (259, 367, 506); W15 = (0.44, 1.06, 1.96)                        # m3/d peak day, kWh/m3
W6 = (233, 294, 354); T3 = 0.8; T5 = (0.33, 0.60, 1.16)               # m3/d consumption, return, kWh/m3

def water(s):
    i = IDX[s]; occ = occ_series(s)
    return W8[i] * occ * W15[i] / 24.0                                 # flat default (C3), deferrable

def wwtp(s):
    i = IDX[s]; occ = occ_series(s)
    return W6[i] * occ * T3 * T5[i] / 24.0                             # C4, flow-based

SPORT_KW = (7.0, 16.3, 29.3); SPORT_F = {20: 0.80, 21: 0.90, 22: 0.75}  # S9, C5

def sports(s):
    i = IDX[s]; out = np.zeros(8760)
    for t in range(8760):
        h = HOUR[t]; m = MON[t]
        if h not in SPORT_F:
            continue
        f = SPORT_F[h] * (0.5 if s == "low" else 1.0)
        if 6 <= m <= 9 or (s == "high" and m in (5, 10) and LOC[t].weekday() >= 5):
            out[t] = SPORT_KW[i] * f
    return out

def pool(s):                                                            # C6
    out = np.zeros(8760)
    for t in range(8760):
        d = DATE[t]; h = HOUR[t]
        if s == "base" and in_range(d, 6, 15, 9, 30):
            out[t] = 4.5
        elif s == "low" and in_range(d, 7, 1, 9, 30) and 8 <= h < 20:
            out[t] = 1.5
        elif s == "high" and in_range(d, 6, 1, 9, 30):
            out[t] = 10.2
    return out

E3 = (22, 22, 30); E4 = (0.5, 2, 5); OCC_AVG = (0.180, 0.275, 0.423)   # E3, E4, W9
EV_SHARE = {7: .05 / 3, 8: .05 / 3, 9: .05 / 3, 10: .25 / 3, 11: .25 / 3, 12: .25 / 3,
            13: .35 / 4, 14: .35 / 4, 15: .35 / 4, 16: .35 / 4, 17: .25 / 3, 18: .25 / 3, 19: .25 / 3,
            20: .10 / 4, 21: .10 / 4, 22: .10 / 4, 23: .10 / 4}            # C7

def ev(s):
    i = IDX[s]; occ = occ_series(s); out = np.zeros(8760)
    for t in range(8760):
        h = HOUR[t]
        e_day = E4[i] * occ[t] / OCC_AVG[i] * E3[i] / 0.93
        stby = (0.607 if 7 <= h <= 23 else 0.018) if s != "low" else 0.018
        out[t] = e_day * EV_SHARE.get(h, 0.0) + stby
    return out

SEC_KW = (1.46, 2.92, 5.71)                                             # C8
OFF_PK = (3.0, 8.1, 13.5)                                               # O4, C9

def security(s):
    return np.full(8760, SEC_KW[IDX[s]])

def offices(s):
    pk = OFF_PK[IDX[s]]
    return np.array([pk if (LOC[t].weekday() < 5 and 8 <= HOUR[t] < 17) else 0.2 * pk for t in range(8760)])

# Critical share of each block during outages (water_aux.md (d); hotel/restaurant shares assumed, see register)
CRIT = {"water_pumping": 1.0, "wastewater": 1.0, "security": 1.0, "road_lighting": 0.30, "offices": 0.30,
        "hotel": 0.30, "restaurants": 0.30, "lifts": 0.0, "chalets": 0.0, "sports": 0.0, "pool": 0.0, "ev": 0.0}

# ---------------------------------------------------------------- build loads
summary = []
blocks_order = ["lifts", "hotel", "restaurants", "chalets", "road_lighting", "water_pumping", "wastewater",
                "sports", "pool", "ev", "security", "offices"]
for s in SC:
    Pl, Pli, sdays = lifts(s)
    B = {"lifts": Pl, "hotel": hospitality(s, "hotel"), "restaurants": hospitality(s, "rest"),
         "chalets": chalets(s), "road_lighting": road(s), "water_pumping": water(s), "wastewater": wwtp(s),
         "sports": sports(s), "pool": pool(s), "ev": ev(s), "security": security(s), "offices": offices(s)}
    club = sum(B[k] for k in blocks_order if k != "chalets")
    total = club + B["chalets"]
    crit = sum(CRIT[k] * B[k] for k in blocks_order)
    ski = np.array([d in sdays for d in DATE]).astype(int)
    with open(os.path.join(OUT, f"load_{s}.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["hour", "time_utc", "time_local", "month", "hour_local", "weekend_or_holiday", "ski_day"]
                   + [f"{k}_kW" for k in blocks_order] + ["club_total_kW", "total_kW", "critical_kW", "lift_T1_kW"])
        for t in range(8760):
            w.writerow([t + 1, UTC[t].strftime("%Y-%m-%d %H:%M"), LOC[t].strftime("%Y-%m-%d %H:%M"), MON[t], HOUR[t],
                        int(WEEKEND[t]), ski[t]] + [round(float(B[k][t]), 3) for k in blocks_order]
                       + [round(float(club[t]), 3), round(float(total[t]), 3), round(float(crit[t]), 3),
                          round(float(Pli["T1"][t]), 3)])
    row = {"scenario": s, "ski_days": int(len(sdays))}
    for k in blocks_order:
        row[k] = (round(B[k].sum() / 1000, 1), round(B[k].max(), 1))
    row["club_total"] = (round(club.sum() / 1000, 1), round(club.max(), 1))
    row["total"] = (round(total.sum() / 1000, 1), round(total.max(), 1), int(np.argmax(total)))
    row["critical"] = (round(crit.sum() / 1000, 1), round(crit.max(), 1))
    row["winter_DecMar_MWh"] = round(total[(MON == 12) | (MON <= 3)].sum() / 1000, 1)
    summary.append(row)

# ---------------------------------------------------------------- PV per kWp
def read_pvgis(fn, year):
    """Hourly P (W per kWp) and POA (W/m2) for a given year, mapped to (month, day, utc hour)."""
    out = {}
    for r in csv.DictReader(open(fn)):
        tm = r["time"]
        if int(tm[:4]) != year:
            continue
        m, d, h = int(tm[4:6]), int(tm[6:8]), int(tm[9:11])
        if m == 2 and d == 29:
            continue
        out[(m, d, h)] = (float(r["P"]), float(r["Gb(i)"]) + float(r["Gd(i)"]) + float(r["Gr(i)"]),
                          float(r["T2m"]))
    return out

REP_YEAR = 2015   # SARAH-3 year whose annual and Dec-Mar tilt-40 yields are closest to the 2014-2023 means
GSA_K = [1.241, 1.118, 1.198, 1.022, 1.037, 1.038, 1.004, 0.995, 0.993, 1.034, 1.077, 1.142]
TILTS = [30, 40, 50, 60]
key = [(t.month, t.day, t.hour) for t in UTC]

# weather drivers for the snow model, same year: ERA5-Land temperature (downscaled), ERA5 precipitation
def read_om(fn, col, year):
    out = {}
    for r in csv.DictReader(open(fn)):
        tm = r["time_utc"]
        if int(tm[:4]) != year:
            continue
        m, d, h = int(tm[5:7]), int(tm[8:10]), int(tm[11:13])
        try:
            out[(m, d, h)] = float(r[col])
        except ValueError:
            out[(m, d, h)] = 0.0
    return out

Tair = read_om(os.path.join(W, "era5land_hourly_downscaled.csv"), "temperature_2m", REP_YEAR)
PRmm = read_om(os.path.join(W, "era5_hourly.csv"), "precipitation", REP_YEAR)
T_SNOW = 1.0         # deg C rain/snow threshold (see register)
SNOW_RATIO = 1.0     # cm of snow per mm of water (10:1)

def marion_coverage(poa, tilt):
    """pvlib.snow.coverage_nrel logic (Marion et al. 2013): returns hourly coverage fraction 0..1."""
    cov = np.zeros(8760); c = 0.0
    slide = 0.197 * math.sin(math.radians(tilt))
    for t in range(8760):
        k = key[t]
        ta = Tair.get(k, 5.0)
        snowfall = PRmm.get(k, 0.0) * SNOW_RATIO if ta <= T_SNOW else 0.0
        if snowfall >= 1.0:          # threshold_snowfall = 1 cm/h
            c = 1.0
        elif ta > poa[t] / -80.0:    # can slide when T_air > POA / m, m = -80 W/m2/C
            c = max(0.0, c - slide)
        cov[t] = c
    return cov

pv_cols, pv_data, pv_stats = [], [], []
for tilt in TILTS:
    d = read_pvgis(os.path.join(W, f"pvgis_hourly_tilt{tilt}.csv"), REP_YEAR)
    P = np.array([d.get(k, (0, 0, 0))[0] / 1000.0 for k in key])
    poa = np.array([d.get(k, (0, 0, 0))[1] for k in key])
    kmon = np.array([GSA_K[t.month - 1] for t in UTC])
    cov = marion_coverage(poa, tilt)
    low = P; base = P * kmon
    base_snow = base * (1 - cov)
    low_snow = low * (1 - cov)
    pv_cols += [f"base_t{tilt}", f"base_t{tilt}_snow", f"low_t{tilt}", f"low_t{tilt}_snow", f"snowcov_t{tilt}"]
    pv_data += [base, base_snow, low, low_snow, cov]
    win = (MON == 12) | (MON <= 3)
    pv_stats.append((tilt, base.sum(), base_snow.sum(), low.sum(), base[win].sum(), base_snow[win].sum(),
                     1 - base_snow[win].sum() / base[win].sum()))
dE = read_pvgis(os.path.join(W, "pvgis_era5_hourly_tilt40.csv"), REP_YEAR)
hi = np.array([dE.get(k, (0, 0, 0))[0] / 1000.0 for k in key])
poaE = np.array([dE.get(k, (0, 0, 0))[1] for k in key])
covE = marion_coverage(poaE, 40)
pv_cols += ["high_t40", "high_t40_snow"]; pv_data += [hi, hi * (1 - covE)]
with open(os.path.join(OUT, "pv_per_kWp.csv"), "w", newline="") as f:
    w = csv.writer(f); w.writerow(["hour", "time_utc", "time_local"] + pv_cols)
    for t in range(8760):
        w.writerow([t + 1, UTC[t].strftime("%Y-%m-%d %H:%M"), LOC[t].strftime("%Y-%m-%d %H:%M")]
                   + [round(float(c[t]), 4) for c in pv_data])

# ---------------------------------------------------------------- grid availability
edl = {}
for r in csv.DictReader(open(os.path.join(ROOT, "data", "grid", "edl_faqra_feeder_hourly.csv"))):
    y, m, dd = map(int, r["date"].split("-"))
    edl[(y, m, dd)] = [int(r[f"h{h:02d}"]) for h in range(24)]

def u_base(t):
    lt = LOC[t]
    y = 2025 if lt.month >= 11 else 2026           # Nov 2025 - Oct 2026 measured year
    row = edl.get((y, lt.month, lt.day))
    return row[lt.hour] if row else 0

def block(hours):
    return lambda t: 1 if HOUR[t] in hours else 0

G = {"u_base_feeder": [u_base(t) for t in range(8760)],
     "u_4h": [block(range(0, 4))(t) for t in range(8760)],
     "u_8h": [block(range(0, 8))(t) for t in range(8760)],
     "u_12h": [block(range(0, 12))(t) for t in range(8760)],
     "u_none": [0] * 8760}
# 72 h outage on the base profile, starting at 00:00 local on the Friday before the highest-load winter Saturday
base_total = np.loadtxt(os.path.join(OUT, "load_base.csv"), delimiter=",", skiprows=1, usecols=(-3,))
tpk = int(np.argmax(np.where((MON <= 3) | (MON == 12), base_total, 0)))
d_start = DATE[tpk] - timedelta(days=1)
u72 = list(G["u_base_feeder"])
for t in range(8760):
    if d_start <= DATE[t] <= d_start + timedelta(days=2):
        u72[t] = 0
G["u_base_plus72h_outage"] = u72
with open(os.path.join(OUT, "grid_availability.csv"), "w", newline="") as f:
    w = csv.writer(f); w.writerow(["hour", "time_utc", "time_local"] + list(G))
    for t in range(8760):
        w.writerow([t + 1, UTC[t].strftime("%Y-%m-%d %H:%M"), LOC[t].strftime("%Y-%m-%d %H:%M")] + [G[k][t] for k in G])

# ---------------------------------------------------------------- summary
L = ["# Input files: summary", "", "Generated by `tools/build_inputs.py`. Model clock: 2026, one row per UTC hour (8,760 rows); "
     "`time_local` is Asia/Beirut with DST. All powers in kW (hourly averages = kWh per hour).", "",
     "## Load (`load_low.csv`, `load_base.csv`, `load_high.csv`)", "",
     "Each block: annual MWh / peak kW. The three files are the low, base (middle) and high scenarios; every file "
     "contains all blocks (lifts, hotel, restaurants, chalets, auxiliaries).", "",
     "| Block | " + " | ".join(SC) + " |", "|---|---|---|---|"]
for k in blocks_order + ["club_total", "critical"]:
    L.append(f"| {k} | " + " | ".join(f"{r[k][0]} MWh / {r[k][1]} kW" for r in summary) + " |")
L.append("| **total (club + chalets)** | " + " | ".join(f"**{r['total'][0]} MWh / {r['total'][1]} kW**" for r in summary) + " |")
L.append("| total, Dec-Mar | " + " | ".join(f"{r['winter_DecMar_MWh']} MWh" for r in summary) + " |")
L.append("| ski operating days | " + " | ".join(str(r["ski_days"]) for r in summary) + " |")
for r in summary:
    t = r["total"][2]
    L.append(f"\n{r['scenario']}: coincident peak {r['total'][1]} kW at {LOC[t].strftime('%a %d %b %H:%M')} local.")
L += ["", "## PV (`pv_per_kWp.csv`), kW per kWp", "",
      f"Weather year {REP_YEAR} (SARAH-3 year closest to the 2014-2023 mean in annual and Dec-Mar yield). "
      "`base_*` = SARAH-3 scaled monthly to Solargis (Global Solar Atlas); `low_*` = SARAH-3 unscaled; "
      "`high_t40` = PVGIS-ERA5. `_snow` columns apply the Marion (2013) snow-coverage model "
      "(pvlib coverage_nrel logic) with ERA5-Land temperature and ERA5 precipitation; `snowcov_*` is the coverage fraction. "
      "PVGIS output includes 14% system losses and temperature effects.", "",
      "| Tilt | Base kWh/kWp | Base with snow | Low (SARAH-3) | Base Dec-Mar | Base Dec-Mar with snow | Dec-Mar snow loss |",
      "|---|---|---|---|---|---|---|"]
for s_ in pv_stats:
    L.append(f"| {s_[0]} | {s_[1]:.0f} | {s_[2]:.0f} | {s_[3]:.0f} | {s_[4]:.0f} | {s_[5]:.0f} | {100*s_[6]:.1f}% |")
L.append(f"| 40 (ERA5, high) | {hi.sum():.0f} | {(hi*(1-covE)).sum():.0f} | | | | |")
L += ["", "## Grid (`grid_availability.csv`), 1 = EDL supplies", ""]
for k, v in G.items():
    L.append(f"- `{k}`: {sum(v)} h/yr ({sum(v)/365:.1f} h/day)")
L.append(f"\nThe 72 h outage runs {d_start} to {d_start + timedelta(days=2)} (local), around the highest winter load of the base case.")
open(os.path.join(OUT, "inputs_summary.md"), "w").write("\n".join(L) + "\n")
print("\n".join(L))
