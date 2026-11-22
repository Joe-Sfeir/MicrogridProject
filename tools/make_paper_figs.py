"""Figures for Section III (site and input data) of the paper.

Reads the prepared inputs and the EDL feeder record; writes PDF and PNG files to paper/figs/.
Run from the repository root:  python3 tools/make_paper_figs.py
"""
import csv
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "paper" / "figs"
OUT.mkdir(parents=True, exist_ok=True)

# Reference categorical palette (fixed order) and neutral inks
C = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300", "#6250d6", "#e34948"]
INK, INK2, GRID = "#0b0b0b", "#52514e", "#e4e3df"
W1 = 3.5  # IEEE single column, inches

plt.rcParams.update({
    "font.family": "serif", "font.size": 8, "axes.titlesize": 8, "axes.labelsize": 8,
    "xtick.labelsize": 7, "ytick.labelsize": 7, "legend.fontsize": 7,
    "axes.edgecolor": INK2, "axes.labelcolor": INK, "xtick.color": INK2, "ytick.color": INK2,
    "axes.spines.top": False, "axes.spines.right": False, "axes.grid": True, "grid.color": GRID,
    "grid.linewidth": 0.5, "axes.axisbelow": True, "legend.frameon": False,
    "savefig.dpi": 300, "savefig.bbox": "tight", "savefig.pad_inches": 0.02,
})
MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


def read(path):
    with open(path, newline="") as f:
        rows = list(csv.DictReader(f))
    return rows


def col(rows, name, typ=float):
    return np.array([typ(r[name]) for r in rows])


def save(fig, name):
    fig.savefig(OUT / f"{name}.pdf")
    fig.savefig(OUT / f"{name}.png")
    plt.close(fig)


# ------------------------------------------------------------ load, monthly energy by group
L = read(ROOT / "inputs" / "load_base.csv")
month = col(L, "month", int)
groups = [
    ("Chalets", ["chalets_kW"]),
    ("Ski lifts", ["lifts_kW"]),
    ("Hotel and restaurants", ["hotel_kW", "restaurants_kW"]),
    ("Road lighting", ["road_lighting_kW"]),
    ("Water and wastewater", ["water_pumping_kW", "wastewater_kW"]),
    ("Other club loads", ["sports_kW", "pool_kW", "ev_kW", "security_kW", "offices_kW"]),
]
E = np.array([[sum(col(L, c)[month == m].sum() for c in cols) / 1000 for m in range(1, 13)]
              for _, cols in groups])
fig, ax = plt.subplots(figsize=(W1, 2.3))
x = np.arange(12)
bottom = np.zeros(12)
for j, (name, _) in enumerate(groups):
    ax.bar(x, E[j], 0.72, bottom=bottom, color=C[j], label=name, edgecolor="white", linewidth=0.6)
    bottom += E[j]
crit = col(L, "critical_kW")
ax.plot(x, [crit[month == m].sum() / 1000 for m in range(1, 13)],
        color=INK, lw=1.2, marker="o", ms=2.5, label="Critical load")
ax.set_xticks(x, MONTHS)
ax.set_ylabel("Energy (MWh/month)")
ax.set_ylim(0, max(bottom) * 1.08)
ax.grid(axis="x", visible=False)
ax.legend(ncol=2, loc="upper center", bbox_to_anchor=(0.5, -0.12), handlelength=1.2, columnspacing=1.0)
save(fig, "load_monthly")

# ------------------------------------------------------------ load, typical days
tl = [r["time_local"] for r in L]
total = col(L, "total_kW")
club = col(L, "club_total_kW")
hloc = col(L, "hour_local", int)


def day(date):
    idx = [i for i, t in enumerate(tl) if t.startswith(date)]
    idx = sorted(idx, key=lambda i: hloc[i])
    return hloc[idx], total[idx], club[idx]


days = [("Peak ski Saturday, 3 Jan", "2026-01-03", C[0]),
        ("Winter weekday, 14 Jan", "2026-01-14", C[1]),
        ("Summer Saturday, 8 Aug", "2026-08-08", C[2])]
fig, ax = plt.subplots(figsize=(W1, 2.0))
for name, d, c in days:
    h, tot, cl = day(d)
    ax.step(np.append(h, 24), np.append(tot, tot[-1]), where="post", color=c, lw=1.6, label=name)
ax.set_xlim(0, 24)
ax.set_xticks(range(0, 25, 3))
ax.set_xlabel("Local time (h)")
ax.set_ylabel("Load (kW)")
ax.set_ylim(0, 560)
ax.legend(loc="upper center", bbox_to_anchor=(0.5, -0.25), ncol=2, handlelength=1.5, columnspacing=1.0)
save(fig, "load_days")

# ------------------------------------------------------------ PV resource, monthly yield
P = read(ROOT / "inputs" / "pv_per_kWp.csv")
pm = np.array([int(r["time_local"][5:7]) for r in P])
series = [("PVGIS-SARAH-3 (low)", "low_t40_snow", C[1], "s"),
          ("SARAH-3 scaled to Solargis (base)", "base_t40_snow", C[0], "o"),
          ("PVGIS-ERA5 (high)", "high_t40_snow", C[2], "^")]
fig, ax = plt.subplots(figsize=(W1, 2.0))
for name, c_, color, mk in series:
    v = col(P, c_)
    y = [v[pm == m].sum() for m in range(1, 13)]
    ax.plot(x, y, color=color, lw=1.6, marker=mk, ms=3.5, label=name)
ax.set_xticks(x, MONTHS)
ax.set_ylabel("PV yield (kWh/kWp per month)")
ax.set_ylim(0, None)
ax.legend(loc="lower center", handlelength=1.5)
save(fig, "pv_monthly")

# ------------------------------------------------------------ EDL feeder supply, model year
G = read(ROOT / "data" / "grid" / "edl_faqra_feeder_hourly.csv")
G = [r for r in G if "2025-11-01" <= r["date"] <= "2026-10-31"]
M = np.array([[int(r[f"h{h:02d}"]) for h in range(24)] for r in G]).T  # 24 x days
fig, ax = plt.subplots(figsize=(W1, 1.9))
cmap = matplotlib.colors.ListedColormap(["#f1f0ec", C[0]])
ax.imshow(M, aspect="auto", cmap=cmap, interpolation="nearest", origin="lower",
          extent=[0, M.shape[1], 0, 24])
starts = [i for i, r in enumerate(G) if r["date"].endswith("-01")]
labels = [MONTHS[int(G[i]["date"][5:7]) - 1] for i in starts]
ax.set_xticks(starts, labels)
ax.set_yticks([0, 6, 12, 18, 24])
ax.set_ylabel("Hour of day")
ax.grid(False)
for s in ("left", "bottom"):
    ax.spines[s].set_visible(False)
ax.tick_params(length=0)
hd = M.sum(axis=0)
print(f"EDL model year: mean {hd.mean():.2f} h/day")
save(fig, "grid_heatmap")

print("written:", sorted(p.name for p in OUT.iterdir()))
