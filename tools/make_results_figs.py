"""Figures for the results section of the paper.

Reads the CSV files that model/main.m writes to results/ and writes PDF and PNG files to paper/figs/,
in the same style as tools/make_paper_figs.py. Run from the repository root:
    python3 tools/make_results_figs.py            (reads results/)
    RESULTS=path/to/results python3 tools/make_results_figs.py
"""
import csv
import os
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
RES = Path(os.environ.get("RESULTS", ROOT / "results"))
OUT = ROOT / "paper" / "figs"
OUT.mkdir(parents=True, exist_ok=True)

C = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300", "#6250d6", "#e34948"]
INK, INK2, GRID, SHADE = "#0b0b0b", "#52514e", "#e4e3df", "#f1f0ec"
W1 = 3.5
plt.rcParams.update({
    "font.family": "serif", "font.size": 8, "axes.titlesize": 8, "axes.labelsize": 8,
    "xtick.labelsize": 7, "ytick.labelsize": 7, "legend.fontsize": 7,
    "axes.edgecolor": INK2, "axes.labelcolor": INK, "xtick.color": INK2, "ytick.color": INK2,
    "axes.spines.top": False, "axes.spines.right": False, "axes.grid": True, "grid.color": GRID,
    "grid.linewidth": 0.5, "axes.axisbelow": True, "legend.frameon": False,
    "savefig.dpi": 300, "savefig.bbox": "tight", "savefig.pad_inches": 0.02,
})
MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
# One colour per energy source, the same in every figure (fixed categorical order).
SRC = {"PV": C[0], "Battery": C[1], "Grid": C[2], "Diesel": C[3]}


def read(name):
    with open(RES / name, newline="") as f:
        return list(csv.DictReader(f))


def col(rows, name, typ=float):
    return np.array([typ(r[name]) if r[name] != "" else np.nan for r in rows])


def save(fig, name):
    fig.savefig(OUT / f"{name}.pdf")
    fig.savefig(OUT / f"{name}.png")
    plt.close(fig)


def panel_label(ax, s):
    ax.text(0.0, 1.02, s, transform=ax.transAxes, ha="left", va="bottom", fontsize=8, color=INK)


# ------------------------------------------------------------ dispatch, one winter and one summer week
H = read("dispatch_base_hourly.csv")
tl = [r["time_local"] for r in H]
d = {k: col(H, k) for k in ("load_kW", "p_pv_kW", "p_dis_kW", "p_ch_kW", "p_g_kW", "p_dg_kW",
                            "grid_available", "soc_kWh")}


def week(start, end):
    return np.array([i for i, t in enumerate(tl) if start <= t < end])


weeks = [("(a) Ski season, Fri 2 to Thu 8 January", "2026-01-02", "2026-01-09"),
         ("(b) Summer, Mon 3 to Sun 9 August", "2026-08-03", "2026-08-10")]
fig, axes = plt.subplots(2, 1, figsize=(W1, 3.3), sharey=True)
for ax, (title, a, b) in zip(axes, weeks):
    idx = week(a, b)
    x = np.arange(len(idx) + 1)
    ext = lambda v: np.append(v[idx], v[idx][-1])
    # grid outages as a light band
    off = ext(d["grid_available"]) < 0.5
    ax.fill_between(x, -800, 800, where=off, step="post", color=SHADE, lw=0, label="Grid off")
    base = np.zeros(len(x))
    for name, key in (("PV", "p_pv_kW"), ("Battery", "p_dis_kW"), ("Grid", "p_g_kW"), ("Diesel", "p_dg_kW")):
        v = ext(d[key])
        ax.fill_between(x, base, base + v, step="post", color=SRC[name], lw=0,
                        label=name if name != "Battery" else "Battery discharge")
        base = base + v
    ax.fill_between(x, 0, -ext(d["p_ch_kW"]), step="post", color=SRC["Battery"], alpha=0.45, lw=0,
                    label="Battery charge")
    ax.step(x, ext(d["load_kW"]), where="post", color=INK, lw=0.9, label="Load")
    ax.axhline(0, color=INK2, lw=0.5)
    ax.set_xlim(0, len(idx))
    ax.set_xticks(range(0, len(idx) + 1, 24))
    ax.set_xticklabels([str(int(t[8:10])) for t in [tl[i] for i in idx[::24]]] + [""])
    ax.set_ylim(-800, 800)
    ax.set_yticks([-800, -400, 0, 400, 800])
    ax.set_ylabel("Power (kW)")
    ax.grid(axis="x", visible=False)
    panel_label(ax, title)
axes[1].set_xlabel("Day of month (ticks at local midnight)")
h, l = axes[0].get_legend_handles_labels()
order = [l.index(n) for n in ("PV", "Battery discharge", "Grid", "Diesel", "Battery charge", "Load", "Grid off")]
axes[1].legend([h[i] for i in order], [l[i] for i in order], ncol=4, loc="upper center",
               bbox_to_anchor=(0.5, -0.28), handlelength=1.2, columnspacing=0.9)
fig.subplots_adjust(hspace=0.38)
save(fig, "res_dispatch_weeks")

# ------------------------------------------------------------ monthly energy by source
month = np.array([int(t[5:7]) for t in tl])
pv_av = col(H, "pv_available_kW")
cur = col(H, "p_cur_kW")
M = lambda v: np.array([v[month == m].sum() / 1000 for m in range(1, 13)])
parts = [("PV used", M(d["p_pv_kW"]), SRC["PV"]), ("Grid", M(d["p_g_kW"]), SRC["Grid"]),
         ("Diesel", M(d["p_dg_kW"]), SRC["Diesel"])]
fig, ax = plt.subplots(figsize=(W1, 2.3))
x = np.arange(12)
bottom = np.zeros(12)
for name, v, c in parts:
    ax.bar(x, v, 0.72, bottom=bottom, color=c, label=name, edgecolor="white", linewidth=0.6)
    bottom += v
ax.bar(x, M(cur), 0.72, bottom=bottom, color="white", edgecolor=SRC["PV"], hatch="////", linewidth=0.6,
       label="PV curtailed")
ax.plot(x, M(d["load_kW"]), color=INK, lw=1.2, marker="o", ms=2.5, label="Load")
ax.set_xticks(x, MONTHS)
ax.set_ylabel("Energy (MWh/month)")
ax.grid(axis="x", visible=False)
ax.legend(ncol=5, loc="upper center", bbox_to_anchor=(0.5, -0.12), handlelength=1.2, columnspacing=0.8)
save(fig, "res_monthly_energy")
print("monthly PV curtailed MWh:", np.round(M(cur)).astype(int).tolist())
print("monthly diesel MWh:", np.round(M(d["p_dg_kW"])).astype(int).tolist())

# ------------------------------------------------------------ finance: cash flow and NPV against rate
CF = read("cashflow_base.csv")
yr = col(CF, "year", int)
disc = col(CF, "discounted_cash_flow") / 1e6
cum = col(CF, "cumulative_discounted_cash_flow") / 1e6
F = {r["name"]: r for r in read("table_finance.csv")}["base_t30"]
fig, axes = plt.subplots(2, 1, figsize=(W1, 3.9))
ax = axes[0]
ax.bar(yr, disc, 0.7, color=C[0], alpha=0.35, lw=0, label="Discounted cash flow of the year")
ax.plot(yr, cum, color=C[0], lw=1.6, marker="o", ms=2.5, label="Cumulative discounted cash flow")
ax.axhline(0, color=INK2, lw=0.5)
pb = float(F["payback_discounted_yr"])
ax.annotate(f"discounted payback {pb:.1f} yr", (pb, 0), xytext=(pb + 1.5, -0.8), fontsize=7, color=INK2,
            arrowprops=dict(arrowstyle="-", color=INK2, lw=0.5))
ax.annotate("battery replaced", (15, disc[15]), xytext=(15, 0.75), ha="center", fontsize=7, color=INK2,
            arrowprops=dict(arrowstyle="-", color=INK2, lw=0.5))
ax.text(25, cum[-1] + 0.15, f"NPV {cum[-1]:.2f} M\\$", ha="right", va="bottom", fontsize=7, color=INK)
ax.set_xlim(-0.8, 25.8)
ax.set_ylim(-1.5, 3.0)
ax.set_xlabel("Project year")
ax.set_ylabel("Million \\$ (2026 prices)")
ax.legend(loc="upper left", handlelength=1.5, borderaxespad=0.2)
ax.grid(axis="x", visible=False)
panel_label(ax, "(a) Base case at 7.11% real discount rate")


def npv(cf, r):
    return sum(c / (1 + r) ** t for t, c in enumerate(cf))


cf = col(CF, "net_cash_flow")
rates = np.linspace(0, 0.30, 121)
irr = float(F["irr_pct"]) / 100
ax = axes[1]
ax.plot(rates * 100, [npv(cf, r) / 1e6 for r in rates], color=C[0], lw=1.6)
ax.axhline(0, color=INK2, lw=0.5)
for r, lab in ((0.0711, "base 7.11%"), (0.1237, "12.37%")):
    v = npv(cf, r) / 1e6
    ax.plot(r * 100, v, "o", color=C[0], ms=4, mec="white", mew=0.8)
    ax.annotate(f"{lab}: {v:.2f} M\\$", (r * 100, v), xytext=(6, 4), textcoords="offset points",
                fontsize=7, color=INK2)
ax.plot(irr * 100, 0, "o", color=C[1], ms=4.5, mec="white", mew=0.8)
ax.annotate(f"IRR {irr * 100:.1f}%", (irr * 100, 0), xytext=(0, 7), textcoords="offset points",
            ha="center", fontsize=7, color=INK)
ax.set_xlim(0, 30)
ax.set_xlabel("Real discount rate (%)")
ax.set_ylabel("NPV (million \\$)")
panel_label(ax, "(b) NPV over 25 years against the discount rate")
fig.subplots_adjust(hspace=0.55)
save(fig, "res_finance")

# ------------------------------------------------------------ diesel price sweep
S = read("table_diesel_sweep.csv")
p = col(S, "diesel_price_USD_L")
fig, axes = plt.subplots(2, 1, figsize=(W1, 3.7), sharex=True)
for ax in axes:
    ax.axvspan(0.80, 1.52, color=SHADE, lw=0)
    ax.axvline(0.993, color=INK2, lw=0.6, ls="--")
    ax.grid(axis="x", visible=False)
ax = axes[0]
v = col(S, "npv_USD") / 1e6
ax.plot(p, v, color=C[0], lw=1.6, marker="o", ms=3)
ib = int(np.argmin(abs(p - 1.41)))
ax.plot(p[ib], v[ib], "o", color=C[0], ms=5.5, mec=INK, mew=0.8)
for i in (0, ib, len(p) - 1):
    ax.annotate(f"IRR {float(S[i]['irr_pct']):.0f}%", (p[i], v[i]), xytext=(6, -9),
                textcoords="offset points", ha="left", fontsize=7, color=INK2)
axes[1].set_xlim(0.52, 2.2)
ax.set_ylim(-0.4, 4.2)
ax.set_ylabel("NPV (million \\$)")
ax.text(1.16, 3.85, "observed 2023–2026", ha="center", fontsize=7, color=INK2)
panel_label(ax, "(a) NPV of the re-optimized system")
ax = axes[1]
ax.plot(p, col(S, "grid_MWh"), color=SRC["Grid"], lw=1.6, marker="o", ms=3, label="Grid import")
ax.plot(p, col(S, "diesel_MWh"), color=SRC["Diesel"], lw=1.6, marker="s", ms=3, label="Diesel")
ax.text(0.993, 900, " diesel = grid\n cost per kWh", fontsize=7, color=INK2, va="top")
ax.set_ylim(0, 950)
ax.set_ylabel("Energy (MWh/yr)")
ax.set_xlabel("Diesel price (\\$/L)")
ax.set_xticks([0.6, 0.8, 1.0, 1.2, 1.41, 1.6, 1.8, 2.0])
ax.legend(loc="center right", handlelength=1.5)
panel_label(ax, "(b) Energy bought in the re-optimized system")
fig.subplots_adjust(hspace=0.35)
save(fig, "res_diesel_sweep")


# ------------------------------------------------------------ compact economics figure for the paper
fig, axes = plt.subplots(2, 1, figsize=(W1, 3.4))
ax = axes[0]
ax.bar(yr, disc, 0.7, color=C[0], alpha=0.35, lw=0, label="Yearly, discounted")
ax.plot(yr, cum, color=C[0], lw=1.6, marker="o", ms=2.5, label="Cumulative, discounted")
ax.axhline(0, color=INK2, lw=0.5)
ax.annotate(f"payback {pb:.1f} yr", (pb, 0), xytext=(pb + 1.5, -0.8), fontsize=7, color=INK2,
            arrowprops=dict(arrowstyle="-", color=INK2, lw=0.5))
ax.annotate("battery replaced", (15, disc[15]), xytext=(15, 0.75), ha="center", fontsize=7, color=INK2,
            arrowprops=dict(arrowstyle="-", color=INK2, lw=0.5))
ax.text(25, cum[-1] + 0.15, f"NPV {cum[-1]:.2f} M\\$", ha="right", va="bottom", fontsize=7, color=INK)
ax.set_xlim(-0.8, 25.8)
ax.set_ylim(-1.5, 3.0)
ax.set_xlabel("Project year")
ax.set_ylabel("Million \\$")
ax.legend(loc="upper left", handlelength=1.5, borderaxespad=0.2)
ax.grid(axis="x", visible=False)
panel_label(ax, "(a) Base-case cash flow at 7.11% real discount rate")
ax = axes[1]
ax.axvspan(0.80, 1.52, color=SHADE, lw=0)
ax.grid(axis="x", visible=False)
v = col(S, "npv_USD") / 1e6
ax.plot(p, v, color=C[0], lw=1.6, marker="o", ms=3)
ax.plot(p[ib], v[ib], "o", color=C[0], ms=5.5, mec=INK, mew=0.8)
for i in (0, ib, len(p) - 1):
    ax.annotate(f"IRR {float(S[i]['irr_pct']):.0f}%", (p[i], v[i]), xytext=(6, -9),
                textcoords="offset points", ha="left", fontsize=7, color=INK2)
ax.set_xlim(0.52, 2.2)
ax.set_ylim(-0.4, 4.2)
ax.set_xticks([0.6, 0.8, 1.0, 1.2, 1.41, 1.6, 1.8, 2.0])
ax.text(1.16, 3.85, "observed 2023\u20132026", ha="center", fontsize=7, color=INK2)
ax.set_xlabel("Diesel price (\\$/L)")
ax.set_ylabel("NPV (million \\$)")
panel_label(ax, "(b) NPV with sizes re-optimized at each diesel price")
fig.subplots_adjust(hspace=0.62)
save(fig, "res_economics")

# ------------------------------------------------------------ tornado on the saving
T = read("table_sensitivities.csv")
base = float(T[0]["savings_pct"])
skip = {"Base", "T1 lift reserve", "Grid connection", "Battery cost form"}
groups = {}
for r in T:
    if r["group"] in skip:
        continue
    groups.setdefault(r["group"], []).append((float(r["savings_pct"]), r["label"]))
rows = []
for g, v in groups.items():
    lo, hi = min(v), max(v)
    if max(abs(lo[0] - base), abs(hi[0] - base)) > 0.05:
        rows.append((g, lo, hi))
rows.sort(key=lambda r: max(base - r[1][0], r[2][0] - base, 0))
fig, ax = plt.subplots(figsize=(W1, 3.0))
for k, (g, lo, hi) in enumerate(rows):
    if lo[0] < base:
        ax.barh(k, lo[0] - base, left=base, height=0.62, color=C[1], lw=0)
        ax.text(lo[0] - 0.5, k, lo[1].replace("; ", ", "), ha="right", va="center", fontsize=6, color=INK2)
    if hi[0] > base:
        ax.barh(k, hi[0] - base, left=base, height=0.62, color=C[0], lw=0)
        ax.text(hi[0] + 0.5, k, hi[1].replace("; ", ", "), ha="left", va="center", fontsize=6, color=INK2)
ax.axvline(base, color=INK, lw=0.8)
ax.set_yticks(range(len(rows)), [r[0] for r in rows])
ax.set_xlim(12, 76)
ax.set_xlabel(f"Saving against the reference (%), base case {base:.1f}%")
ax.grid(axis="y", visible=False)
ax.tick_params(axis="y", length=0)
save(fig, "res_tornado")

print("written:", sorted(p.name for p in OUT.glob("res_*")))
