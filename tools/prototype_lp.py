"""Quick Python/HiGHS prototype of the base-case LP, used only to check that the inputs give a feasible,
sensible model before the MATLAB build. Simplified: battery all-in cost on E_b, grid capped at 5 MW, PV tilt 40.
Run: pip install scipy; python3 tools/prototype_lp.py"""
import json, sys, time, numpy as np, scipy.sparse as sp
from scipy.optimize import linprog
import os
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "inputs") + "/"
P = json.load(open(R + "parameters.json"))
def col(fn, name):
    import csv
    rows = list(csv.DictReader(open(R + fn)))
    return np.array([float(r[name]) for r in rows])
def run(load_col="total_kW", loadf="load_base.csv", pvcol="base_t40_snow", ucol="u_base_feeder", lpsp=0.01, ref=False, diesel_price=1.41):
    L = col(loadf, load_col); C = col(loadf, "critical_kW" if load_col == "total_kW" else "critical_kW")
    a = col("pv_per_kWp.csv", pvcol); u = col("grid_availability.csv", ucol)
    T = len(L); i = 0.0711
    crf = lambda n: i * (1 + i) ** n / ((1 + i) ** n - 1)
    c_pv = crf(30) * 750 + 18; c_b = crf(15) * 192 * 1.025  # incl. 2.5% O&M approx
    ef, ech = 0.9487, 0.9487
    # variable blocks
    names = ["ppv", "pcur", "pch", "pdis", "soc", "pg", "pdg", "udg", "lsn"]
    nb = len(names); N = nb * T + 3  # + P_pv, E_b, P_d
    ix = {n: np.arange(k * T, (k + 1) * T) for k, n in enumerate(names)}
    IPV, IEB, IPD = nb * T, nb * T + 1, nb * T + 2
    c = np.zeros(N)
    c[ix["pg"]] = 0.27
    c[ix["pdg"]] = diesel_price * 0.242 + 0.0128
    c[ix["udg"]] = diesel_price * 0.017
    c[ix["pdis"]] = 0.020
    c[ix["pch"]] = 1e-4
    c[IPV] = c_pv; c[IEB] = c_b; c[IPD] = 0.0
    rows, cols, vals, rhs_eq = [], [], [], []
    Aeq = []; beq = []
    r = 0
    def add(rlist, cl, vl):
        pass
    # equality: balance, pv, soc
    I = []; J = []; V = []; b = []
    for t in range(T):
        # balance
        for n, s in (("ppv", 1), ("pdis", 1), ("pg", 1), ("pdg", 1), ("lsn", 1), ("pch", -1)):
            I.append(r); J.append(ix[n][t]); V.append(s)
        b.append(L[t]); r += 1
    for t in range(T):  # pv
        I += [r, r, r]; J += [ix["ppv"][t], ix["pcur"][t], IPV]; V += [1, 1, -a[t]]; b.append(0); r += 1
    for t in range(T):  # soc
        tn = (t + 1) % T
        I += [r, r, r, r]; J += [ix["soc"][tn], ix["soc"][t], ix["pch"][t], ix["pdis"][t]]; V += [1, -1, -ech, 1 / ef]; b.append(0); r += 1
    Aeq = sp.csr_matrix((V, (I, J)), shape=(r, N)); beq = np.array(b)
    I = []; J = []; V = []; b = []; r = 0
    for t in range(T):
        I += [r, r]; J += [ix["soc"][t], IEB]; V += [1, -1]; b.append(0); r += 1            # soc <= Eb
        I += [r, r]; J += [ix["soc"][t], IEB]; V += [-1, 0.10]; b.append(0); r += 1         # soc >= 0.1Eb
        I += [r, r]; J += [ix["pch"][t], IEB]; V += [1, -0.5]; b.append(0); r += 1           # pch <= 0.5Eb
        I += [r, r]; J += [ix["pdis"][t], IEB]; V += [1, -0.5]; b.append(0); r += 1
        I += [r, r]; J += [ix["pdg"][t], ix["udg"][t]]; V += [1, -1]; b.append(0); r += 1     # pdg <= udg
        I += [r, r]; J += [ix["udg"][t], IPD]; V += [1, -1]; b.append(0); r += 1              # udg <= Pd
        I += [r, r]; J += [ix["pdg"][t], ix["udg"][t]]; V += [-1, 0.3]; b.append(0); r += 1   # pdg >= .3 udg
    for t in range(T):
        I.append(r); J.append(ix["lsn"][t]); V.append(1.0)
    b.append(lpsp * L.sum()); r += 1
    Aub = sp.csr_matrix((V, (I, J)), shape=(r, N)); bub = np.array(b)
    bounds = [(0, None)] * N
    for t in range(T):
        bounds[ix["pg"][t]] = (0, 5000 * u[t])
        bounds[ix["lsn"][t]] = (0, max(0.0, L[t] - C[t]))
    if ref:
        bounds[IPV] = (0, 0); bounds[IEB] = (0, 0)
    t0 = time.time()
    res = linprog(c, A_ub=Aub, b_ub=bub, A_eq=Aeq, b_eq=beq, bounds=bounds, method="highs")
    x = res.x
    out = dict(status=res.status, msg=res.message[:40], cost=res.fun, secs=round(time.time() - t0, 1),
               Ppv=x[IPV], Eb=x[IEB], Pd=x[IPD],
               pv_used=x[ix["ppv"]].sum(), curt=x[ix["pcur"]].sum(), grid=x[ix["pg"]].sum(), diesel=x[ix["pdg"]].sum(),
               lsn=x[ix["lsn"]].sum(), load=L.sum(),
               fuel_L=(0.017 * x[ix["udg"]] + 0.242 * x[ix["pdg"]]).sum(), dis=x[ix["pdis"]].sum())
    out["RF"] = out["pv_used"] / out["load"]; out["LPSP"] = out["lsn"] / out["load"]; out["LCOE"] = out["cost"] / (out["load"] - out["lsn"])
    return out
if __name__ == "__main__":
    for name, kw in [("reference", dict(ref=True)), ("base", {}), ("base_lpsp0", dict(lpsp=0.0)),
                     ("grid_none", dict(ucol="u_none")), ("load_high", dict(loadf="load_high.csv")), ("load_low", dict(loadf="load_low.csv"))]:
        o = run(**kw)
        print(name, {k: (round(v, 3) if isinstance(v, float) else v) for k, v in o.items()}, flush=True)
