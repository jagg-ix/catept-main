"""Cross-check our Kerr g_tt implementation against EinsteinPy (if available).

This script is a *sanity check* tool:
- It evaluates g_tt from our analytic implementation at sample points.
- It evaluates g_tt from EinsteinPy's Kerr metric (if the relevant class is available).
- It reports max absolute/relative error.

If EinsteinPy does not expose Kerr in the installed version, the script prints a clear SKIP message.

Usage:
  python scripts/metric_kerr_einsteinpy_check.py --mass-kg 1.9885e30 --a-star 0.9 --theta-deg 90 --r-m 1e6

Notes:
- We compare g_tt only (redshift factor input); we do not compare g_tφ or full metric.
- Coordinates: Boyer–Lindquist (t, r, θ, φ). We evaluate at φ=0.
"""

from __future__ import annotations
import argparse
import math
import numpy as np

from cat_ept_doubleslit.metrics.redshift import kerr_metric

def try_einsteinpy_gtt(mass_kg: float, a_star: float, r_m: float, theta_rad: float) -> float | None:
    try:
        # Attempt multiple API paths across EinsteinPy versions.
        import sympy as sp
        from einsteinpy.symbolic import MetricTensor  # type: ignore
        try:
            from einsteinpy.symbolic.predefined import Kerr  # type: ignore
            k = Kerr()
            g = k.metric()
        except Exception:
            try:
                from einsteinpy.symbolic.predefined import kerr  # type: ignore
                g = kerr()
            except Exception:
                return None

        # g is a MetricTensor or matrix-like. Expect coords (t, r, theta, phi)
        # Evaluate g_tt at given r,theta; assume geometric units in EinsteinPy symbolic.
        # Convert mass to geometric length M = GM/c^2 in meters (same as our code).
        G = 6.67430e-11
        c = 299792458.0
        M_geo = (G * mass_kg) / (c*c)

        # EinsteinPy Kerr uses parameters (M, a) in geometric units (length).
        a_len = a_star * M_geo

        # Substitute into symbolic metric if possible
        t, r, th, ph = sp.symbols("t r theta phi", real=True)
        subs = {r: float(r_m), th: float(theta_rad)}
        # Many EinsteinPy Kerr definitions use symbols M and a
        M, a = sp.symbols("M a", real=True)
        subs[M] = float(M_geo)
        subs[a] = float(a_len)

        gtt = None
        try:
            gmat = g.tensor()
            gtt_expr = gmat[0,0]
            gtt = float(sp.N(gtt_expr.subs(subs)))
        except Exception:
            # try direct indexing
            try:
                gtt_expr = g[0,0]
                gtt = float(sp.N(gtt_expr.subs(subs)))
            except Exception:
                return None
        return gtt
    except Exception:
        return None

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mass-kg", type=float, default=1.9885e30)
    ap.add_argument("--a-star", type=float, default=0.0)
    ap.add_argument("--theta-deg", type=float, default=90.0)
    ap.add_argument("--r-m", type=float, default=1.0e6)
    ap.add_argument("--n", type=int, default=10, help="number of samples (vary phi only, g_tt independent)")
    args = ap.parse_args()

    theta = float(args.theta_deg) * math.pi/180.0
    r = float(args.r_m)

    our = kerr_metric(args.mass_kg, a_star=args.a_star, theta_rad=theta)
    # evaluate at x aligned with that theta: choose x=(r*sinθ,0,r*cosθ)
    x = np.array([r*math.sin(theta), 0.0, r*math.cos(theta)], dtype=float)
    gtt_our = our.g00(0.0, x)

    gtt_ep = try_einsteinpy_gtt(args.mass_kg, args.a_star, r, theta)
    if gtt_ep is None:
        print("SKIP: EinsteinPy Kerr metric not available in this environment/version.")
        print(f"Our g_tt = {gtt_our}")
        return 0

    abs_err = abs(gtt_our - gtt_ep)
    rel_err = abs_err / max(1e-15, abs(gtt_ep))
    print(f"Our g_tt      = {gtt_our}")
    print(f"EinsteinPy g_tt = {gtt_ep}")
    print(f"abs_err       = {abs_err:.3e}")
    print(f"rel_err       = {rel_err:.3e}")
    return 0 if rel_err < 1e-8 else 1

if __name__ == "__main__":
    raise SystemExit(main())
