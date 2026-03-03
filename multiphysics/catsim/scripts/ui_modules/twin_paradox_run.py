"""Twin paradox runner: worldlines + proper time (SR baseline).

Outputs:
- worldline_A.csv, worldline_B.csv (t_s, x_m, v_m_s, gamma, tau_s)
- summary.json (tau totals, delta)
- run_manifest.json

Trajectories:
- inertial: A at rest, B moves at constant v for duration T
- out_and_back: A at rest, B goes out at v for T_leg then back at -v for T_leg
"""

from __future__ import annotations
import argparse, json, csv, math
from pathlib import Path
import numpy as np
from ._manifest import write_manifest

c = 299792458.0

def gamma_from_v(v):
    return 1.0 / math.sqrt(max(1e-30, 1.0 - (v/c)**2))

def integrate_tau(t, v):
    # tau = ∫ sqrt(1 - v^2/c^2) dt  (v piecewise constant per sample)
    dt = np.diff(t)
    factor = np.sqrt(np.clip(1.0 - (v[:-1]/c)**2, 0.0, 1.0))
    tau = np.concatenate([[0.0], np.cumsum(dt*factor)])
    return tau

def write_worldline(path: Path, t, x, v):
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["t_s","x_m","v_m_s","gamma","tau_s"])
        tau = integrate_tau(t, v)
        for ti, xi, vi, taui in zip(t, x, v, tau):
            gi = 1.0 / math.sqrt(max(1e-30, 1.0 - (vi/c)**2))
            w.writerow([f"{float(ti):.12g}", f"{float(xi):.12g}", f"{float(vi):.12g}", f"{gi:.12g}", f"{float(taui):.12g}"])
    return float(tau[-1])

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--scenario", choices=["inertial","out_and_back"], default="out_and_back")
    ap.add_argument("--v-frac", type=float, default=0.8, help="v/c for B")
    ap.add_argument("--T", type=float, default=1e-6, help="duration seconds (inertial)")
    ap.add_argument("--T-leg", type=float, default=1e-6, help="leg duration seconds (out_and_back)")
    ap.add_argument("--n", type=int, default=1000)
    args = ap.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    n = max(10, args.n)
    if args.scenario == "inertial":
        T = args.T
        t = np.linspace(0.0, T, n)
        # A at rest
        xA = np.zeros_like(t); vA = np.zeros_like(t)
        # B constant v
        vB = np.full_like(t, args.v_frac*c)
        xB = vB * t
    else:
        T = 2*args.T_leg
        t1 = np.linspace(0.0, args.T_leg, n//2, endpoint=False)
        t2 = np.linspace(args.T_leg, 2*args.T_leg, n - len(t1))
        t = np.concatenate([t1, t2])
        xA = np.zeros_like(t); vA = np.zeros_like(t)
        v_out = args.v_frac*c
        vB = np.where(t < args.T_leg, v_out, -v_out)
        # integrate x
        xB = np.zeros_like(t)
        for i in range(1, len(t)):
            dt = t[i]-t[i-1]
            xB[i] = xB[i-1] + vB[i-1]*dt

    tauA = write_worldline(out_dir/"worldline_A.csv", t, xA, vA)
    tauB = write_worldline(out_dir/"worldline_B.csv", t, xB, vB)

    summary = {
        "scenario": args.scenario,
        "v_frac": args.v_frac,
        "tauA_s": tauA,
        "tauB_s": tauB,
        "delta_tau_s": tauA - tauB,
        "T_coord_s": float(t[-1]),
        "c_m_s": c,
    }
    (out_dir/"summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True))

    write_manifest(out_dir, {
        "module": "twin_paradox",
        "artifacts": {
            "worldline_A_csv": str(out_dir/"worldline_A.csv"),
            "worldline_B_csv": str(out_dir/"worldline_B.csv"),
            "summary_json": str(out_dir/"summary.json"),
        },
        "params": {"scenario": args.scenario, "v_frac": args.v_frac, "T": args.T, "T_leg": args.T_leg, "n": n},
        "notes": ["SR baseline proper-time integrator; no acceleration/GR yet."],
    })

    print("Wrote twin paradox artifacts to", out_dir)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
