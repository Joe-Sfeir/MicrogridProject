"""HiGHS bridge for GNU Octave. MATLAB does not use this file (it calls linprog directly).

Octave has no linprog with HiGHS, so solve_lp.m writes the LP to a MAT-file, runs this
script, and reads the solution back. Same solver family as MATLAB's linprog default
(HiGHS dual simplex). Needs: pip install scipy.

Usage: python3 highs_bridge.py <in.mat> <out.mat>
"""
import sys
import warnings

import numpy as np
import scipy.io as sio
import scipy.sparse as sp
from scipy.optimize import linprog


def main(fin, fout):
    warnings.simplefilter("ignore", DeprecationWarning)
    m = sio.loadmat(fin)
    f = np.asarray(m["f"], dtype=float).ravel()

    def mat(key):
        a = m.get(key)
        if a is None or a.shape[0] == 0:
            return None
        return sp.csr_matrix(a)

    def vec(key):
        v = m[key]
        v = v.toarray() if sp.issparse(v) else np.asarray(v)
        return v.astype(float).ravel()

    A, Aeq = mat("A"), mat("Aeq")
    res = linprog(
        f,
        A_ub=A, b_ub=vec("b") if A is not None else None,
        A_eq=Aeq, b_eq=vec("beq") if Aeq is not None else None,
        bounds=np.column_stack([vec("lb"), vec("ub")]),
        method="highs-ds",
    )
    out = {"status": float(res.status), "message": str(res.message),
           "nit": float(getattr(res, "nit", float("nan")))}
    if res.status == 0:
        out["x"] = np.asarray(res.x, dtype=float).reshape(-1, 1)
        out["fval"] = float(res.fun)
    sio.savemat(fout, out)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
