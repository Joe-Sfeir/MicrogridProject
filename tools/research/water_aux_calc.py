"""Calculations for water/pumping/auxiliary loads, Faqra Club (33.985 N, 35.811 E).
All inputs are documented in research/water_aux.md. Run: python3 -I water_aux_calc.py
"""
import math, datetime as dt
import numpy as np

LAT, LON = 33.985, 35.811
TZ_STD = 2.0  # Lebanon EET (UTC+2); DST (UTC+3) late Mar - late Oct

def sun_times(day, zenith_deg=90.833):
    """NOAA general solar position approximation; returns (sunrise, sunset) in local *standard* time hours."""
    n = day.timetuple().tm_yday
    g = 2 * math.pi / 365 * (n - 1)
    eqt = 229.18 * (0.000075 + 0.001868 * math.cos(g) - 0.032077 * math.sin(g)
                    - 0.014615 * math.cos(2 * g) - 0.040849 * math.sin(2 * g))
    decl = (0.006918 - 0.399912 * math.cos(g) + 0.070257 * math.sin(g) - 0.006758 * math.cos(2 * g)
            + 0.000907 * math.sin(2 * g) - 0.002697 * math.cos(3 * g) + 0.00148 * math.sin(3 * g))
    lat = math.radians(LAT)
    cosH = (math.cos(math.radians(zenith_deg)) / (math.cos(lat) * math.cos(decl)) - math.tan(lat) * math.tan(decl))
    H = math.degrees(math.acos(max(-1, min(1, cosH))))
    noon = 720 - 4 * LON - eqt + TZ_STD * 60  # minutes, local standard time
    return (noon - 4 * H) / 60, (noon + 4 * H) / 60

def is_dst(day):
    # EU-style rule used in Lebanon: last Sunday of March to last Sunday of October
    y = day.year
    def last_sun(m):
        d = dt.date(y, m + 1, 1) - dt.timedelta(days=1) if m < 12 else dt.date(y, 12, 31)
        return d - dt.timedelta(days=(d.weekday() + 1) % 7)
    return last_sun(3) <= day < last_sun(10)

year = 2025
days = [dt.date(year, 1, 1) + dt.timedelta(days=i) for i in range(365)]
month_night = np.zeros(12); month_civil = np.zeros(12); month_days = np.zeros(12)
# hourly lit fraction per month (clock time incl. DST), for lighting schedule
lit = np.zeros((12, 24))
for d in days:
    sr, ss = sun_times(d)
    csr, css = sun_times(d, 96.0)
    m = d.month - 1
    month_days[m] += 1
    month_night[m] += 24 - (ss - sr)
    month_civil[m] += 24 - (css - csr)
    off = 1.0 if is_dst(d) else 0.0
    sr_c, ss_c = sr + off, ss + off
    for h in range(24):
        a, b = h, h + 1
        day_overlap = max(0, min(b, ss_c) - max(a, sr_c))
        lit[m, h] += 1 - day_overlap
lit /= month_days[:, None]

print("Month  days  sunset->sunrise h/day  h/month   civil-dusk->dawn h/day")
for m in range(12):
    print(f"{m+1:>5} {month_days[m]:>4.0f} {month_night[m]/month_days[m]:>10.2f} {month_night[m]:>12.0f} {month_civil[m]/month_days[m]:>12.2f}")
print("Annual sunset->sunrise hours:", round(month_night.sum()), " civil-twilight dark hours:", round(month_civil.sum()))
for d in [dt.date(year, 6, 21), dt.date(year, 12, 21)]:
    sr, ss = sun_times(d); off = 1 if is_dst(d) else 0
    print(d, "sunrise %.2f sunset %.2f (clock)" % (sr + off, ss + off))

# ---------------- Road lighting ----------------
L_km = 20.0
cases = {
    "low":  dict(spacing=40, W=31.0, dim=(0.5, 0, 5)),    # 50% level 00-05
    "base": dict(spacing=30, W=37.0, dim=(0.7, 0, 5)),    # 70% level 00-05
    "high": dict(spacing=25, W=67.0, dim=(1.0, 0, 5)),    # no dimming
    "legacy_HPS": dict(spacing=30, W=127.4, dim=(1.0, 0, 5)),
}
print("\nRoad lighting")
road = {}
for k, c in cases.items():
    n = math.floor(L_km * 1000 / c["spacing"]) + 1
    kw = n * c["W"] / 1000
    lev, h0, h1 = c["dim"]
    prof = lit.copy()
    prof[:, h0:h1] *= lev
    E = sum(kw * prof[m].sum() * month_days[m] for m in range(12)) / 1000
    full_h = sum(lit[m].sum() * month_days[m] for m in range(12))
    road[k] = (n, kw, E)
    print(f"{k:>10}: poles={n}, P={kw:.1f} kW, full-power-equiv hours={E*1000/kw:.0f}, lit hours={full_h:.0f}, E={E:.1f} MWh/yr")

print("\nHourly lit fraction (rows=month, cols=hour 0..23):")
for m in range(12):
    print(m + 1, " ".join(f"{x:.2f}" for x in lit[m]))

# ---------------- Water pumping ----------------
print("\nWater")
rho_g = 1000 * 9.81 / 3.6e6  # kWh/m3/m = 0.002725
sc = {
    # persons at full occupancy, l/c/d, hotel persons, l/tourist/d, NRW, occupancy factor(annual avg), head m, eta_w2w
    "low":  dict(fam=400, hh=3.8, lcd=140, hotel=25*2, ltd=400, nrw=0.10, occ=65.6/365, H=120, eta=0.75),
    "base": dict(fam=400, hh=3.8, lcd=180, hotel=25*2, ltd=400, nrw=0.20, occ=100.5/365, H=265, eta=0.68),
    "high": dict(fam=400, hh=3.8, lcd=220, hotel=25*2, ltd=400, nrw=0.30, occ=154.4/365, H=360, eta=0.50),
}
water = {}
for k, s in sc.items():
    cons_full = (s["fam"] * s["hh"] * s["lcd"] + s["hotel"] * s["ltd"]) / 1000  # m3/d
    pumped_full = cons_full / (1 - s["nrw"])
    e_spec = rho_g * s["H"] / s["eta"]  # kWh/m3
    V_yr = pumped_full * s["occ"] * 365
    E = V_yr * e_spec / 1000
    P_peak = pumped_full / 20 * e_spec  # pump sized to deliver peak-day volume in 20 h
    ww_yr = cons_full * s["occ"] * 365 * 0.8
    water[k] = dict(cons_full=cons_full, pumped_full=pumped_full, e_spec=e_spec, V_yr=V_yr, E=E, P_peak=P_peak, ww_yr=ww_yr)
    print(f"{k}: consumption@full={cons_full:.0f} m3/d, pumped@full={pumped_full:.0f} m3/d, e={e_spec:.3f} kWh/m3, "
          f"V={V_yr:,.0f} m3/yr, E={E:.1f} MWh/yr, P_pump={P_peak:.1f} kW, avg={E*1000/8760:.1f} kW, WW={ww_yr:,.0f} m3/yr")

print("\nWWTP")
ww_e = {"low": 0.33, "base": 0.60, "high": 1.16}
for k in sc:
    E_flow = water[k]["ww_yr"] * ww_e[k] / 1000
    print(f"{k}: flow-based E={E_flow:.1f} MWh/yr avg {E_flow*1000/8760:.2f} kW")
E_design = 600 * 0.60 * 365 / 1000
print(f"design-capacity bound: 600 m3/d x 0.60 = {600*0.6:.0f} kWh/d = {600*0.6/24:.1f} kW, {E_design:.0f} MWh/yr")
print("Longo small-plant conversion: 3.01 kWh/kgCOD x 0.43 kg/m3 x 0.9 =", round(3.01 * 0.43 * 0.9, 2), "kWh/m3")

# ---------------- Pool ----------------
print("\nPool")
pool = {"low": (150, 6, 12, 0.55, 12, 92), "base": (300, 6, 15, 0.45, 24, 107), "high": (500, 6, 18, 0.40, 24, 122)}
for k, (V, T, H, eta, hrs, days_) in pool.items():
    Q = V / T  # m3/h
    P = 1000 * 9.81 * (Q / 3600) * H / eta / 1000
    E = P * hrs * days_ / 1000
    print(f"{k}: V={V} m3, Q={Q:.0f} m3/h, H={H} m, eta={eta}, P={P:.2f} kW, {hrs} h/d x {days_} d -> {E:.1f} MWh/yr")

# ---------------- Sports lighting ----------------
print("\nSports lighting")
sports = {
    # (tennis kW/court, n_tennis, padel kW, n_padel, basketball kW, football kW, hours/yr per facility)
    "low":  (1.80, 3, 0.80, 1, 0.80, 0.0, 150),
    "base": (3.12, 3, 1.20, 2, 1.80, 2.7, 300),
    "high": (4.64, 3, 2.00, 2, 1.80, 9.6, 500),
}
for k, (tk, nt, pk, npad, bk, fk, hrs) in sports.items():
    P = tk * nt + pk * npad + bk + fk
    print(f"{k}: connected={P:.1f} kW, E={P*hrs/1000:.1f} MWh/yr at {hrs} h/yr full-load-equivalent")
print("football 5-a-side scaling: 9.6 kW x 800/2860 =", round(9.6 * 800 / 2860, 2))

# ---------------- EV ----------------
print("\nEV")
ev = {"low": (0.5, 22, 0.018), "base": (2, 22, 0.435), "high": (5, 30, 0.607)}
for k, (n, e, sb) in ev.items():
    E_ch = n * e / 0.93 * 365 / 1000
    E_sb = sb * 8760 / 1000
    print(f"{k}: {n} sess/d x {e} kWh /0.93 -> {E_ch:.1f} MWh/yr; standby {sb} kW -> {E_sb:.2f} MWh/yr; total {E_ch+E_sb:.1f}")
print("base standby derivation: (17*0.607+7*0.0176)/24 =", round((17 * 0.607 + 7 * 0.0176) / 24, 3), "(350 kW unit; scaled x60/350?)")

# ---------------- Security ----------------
print("\nSecurity / CCTV")
sec = {"low": (30, 11.0, 1, 1.0), "base": (60, 11.0, 2, 2.0), "high": (120, 17.1, 3, 3.0)}
for k, (ncam, wcam, ngate, gh_kw) in sec.items():
    cams = ncam * wcam / 1000
    nvr = 0.25 * cams  # network/NVR/PoE overhead (assumed 25%)
    gates = ngate * 0.05  # controller+loop detector+lighting standby, assumed 50 W each
    P = cams + nvr + gates + gh_kw
    print(f"{k}: cams {cams:.2f} kW + net/NVR {nvr:.2f} + gates {gates:.2f} + guardhouses {gh_kw} = {P:.2f} kW -> {P*8.76:.1f} MWh/yr")
print("barrier motor energy at 1000 cycles/d:", round(1000 * 2 * 2.5 * 220 / 3.6e6, 2), "kWh/d")

# ---------------- Offices / workshop ----------------
print("\nOffices")
for k, (A, q) in {"low": (300, 36), "base": (600, 48), "high": (1000, 48)}.items():
    print(f"{k}: {A} m2 x {q} kWh/m2/yr = {A*q/1000:.1f} MWh/yr, avg {A*q/8760:.2f} kW")
