"""Ringdown fitter: single damped sinusoid (baseline) with optional grid search.

Artifact contract:
- ringdown_fit.csv: t_s, h, h_fit, resid
- fit_params.json
- run_manifest.json

Inputs:
- Either: --input-csv (columns t_s,h) OR --synthetic to generate a test signal.

Fit:
- For fixed (f, tau), solve A,B in:
    h_fit = exp(-(t-t0)/tau) * (A cos(2π f (t-t0)) + B sin(2π f (t-t0)))
- Optional grid search over f,tau to minimize RMSE.
"""

from __future__ import annotations
import argparse, json, csv, math
from pathlib import Path
import numpy as np
from ._manifest import write_manifest

def load_csv(path: Path):
    t=[]; h=[]
    with path.open("r", newline="", encoding="utf-8") as fp:
        r=csv.DictReader(fp)
        # accept t or t_s
        tkey = "t_s" if "t_s" in r.fieldnames else ("t" if "t" in r.fieldnames else r.fieldnames[0])
        hkey = "h" if "h" in r.fieldnames else r.fieldnames[1]
        for row in r:
            t.append(float(row[tkey])); h.append(float(row[hkey]))
    return np.array(t), np.array(h)

def synth(fs, dur, f0, tau, phi, noise, seed=0):
    rng=np.random.default_rng(seed)
    n=int(fs*dur)
    t=np.arange(n)/fs
    y=np.exp(-t/tau)*np.cos(2*math.pi*f0*t + phi)
    y = y + noise*rng.standard_normal(n)
    return t, y

def fit_fixed(t, h, t0, f, tau):
    tw = t - t0
    m = tw >= 0
    tw = tw[m]; hw = h[m]
    e = np.exp(-tw/tau)
    C = e*np.cos(2*math.pi*f*tw)
    S = e*np.sin(2*math.pi*f*tw)
    X = np.vstack([C,S]).T
    coeff, *_ = np.linalg.lstsq(X, hw, rcond=None)
    A, B = coeff
    hfit = X@coeff
    resid = hw - hfit
    rmse = float(np.sqrt(np.mean(resid**2))) if len(resid)>0 else float("nan")
    return {"A": float(A), "B": float(B), "rmse": rmse, "tw": tw, "hw": hw, "hfit": hfit, "resid": resid}

def main() -> int:
    ap=argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--input-csv", default=None)
    ap.add_argument("--synthetic", action="store_true")
    ap.add_argument("--fs", type=float, default=4096.0)
    ap.add_argument("--dur", type=float, default=0.5)
    ap.add_argument("--f0", type=float, default=250.0)
    ap.add_argument("--tau", type=float, default=0.08)
    ap.add_argument("--phi", type=float, default=0.2)
    ap.add_argument("--noise", type=float, default=0.05)
    ap.add_argument("--seed", type=int, default=0)

    ap.add_argument("--t0", type=float, default=0.05)
    ap.add_argument("--f-guess", type=float, default=250.0)
    ap.add_argument("--tau-guess", type=float, default=0.08)

    ap.add_argument("--grid-search", action="store_true")
    ap.add_argument("--fmin", type=float, default=100.0)
    ap.add_argument("--fmax", type=float, default=500.0)
    ap.add_argument("--nf", type=int, default=60)
    ap.add_argument("--taumin", type=float, default=0.01)
    ap.add_argument("--taumax", type=float, default=0.2)
    ap.add_argument("--ntau", type=int, default=40)
    args=ap.parse_args()

    out_dir=Path(args.out); out_dir.mkdir(parents=True, exist_ok=True)

    if args.synthetic or args.input_csv is None:
        t,h = synth(args.fs, args.dur, args.f0, args.tau, args.phi, args.noise, seed=args.seed)
        input_desc = {"synthetic": True, "fs": args.fs, "dur": args.dur, "f0": args.f0, "tau": args.tau, "phi": args.phi, "noise": args.noise, "seed": args.seed}
    else:
        t,h = load_csv(Path(args.input_csv))
        input_desc = {"synthetic": False, "input_csv": str(Path(args.input_csv).resolve())}

    best_f = args.f_guess
    best_tau = args.tau_guess
    best = fit_fixed(t,h,args.t0,best_f,best_tau)

    if args.grid_search:
        fgrid = np.linspace(args.fmin, args.fmax, max(5,args.nf))
        taugrid = np.linspace(args.taumin, args.taumax, max(5,args.ntau))
        best_rmse = best["rmse"]
        for f0 in fgrid:
            for tau0 in taugrid:
                r = fit_fixed(t,h,args.t0,float(f0),float(tau0))
                if r["rmse"] < best_rmse:
                    best_rmse = r["rmse"]
                    best_f = float(f0); best_tau = float(tau0)
                    best = r

    # Write artifacts on windowed data (t>=t0)
    tw = best["tw"] + args.t0
    out_csv = out_dir/"ringdown_fit.csv"
    with out_csv.open("w", newline="", encoding="utf-8") as fp:
        w=csv.writer(fp)
        w.writerow(["t_s","h","h_fit","resid"])
        for ti, hi, hf, rr in zip(tw, best["hw"], best["hfit"], best["resid"]):
            w.writerow([f"{float(ti):.12g}", f"{float(hi):.12g}", f"{float(hf):.12g}", f"{float(rr):.12g}"])

    fit_params = {
        "t0_s": args.t0,
        "f_hz": best_f,
        "tau_s": best_tau,
        "A": best["A"],
        "B": best["B"],
        "rmse": best["rmse"],
        "grid_search": bool(args.grid_search),
        "input": input_desc,
    }
    (out_dir/"fit_params.json").write_text(json.dumps(fit_params, indent=2, sort_keys=True))

    write_manifest(out_dir, {
        "module": "ringdown",
        "artifacts": {
            "ringdown_fit_csv": str(out_csv),
            "fit_params_json": str(out_dir/"fit_params.json"),
        },
        "params": {
            "t0": args.t0,
            "f_guess": args.f_guess,
            "tau_guess": args.tau_guess,
            "grid_search": bool(args.grid_search),
            "grid": {"fmin": args.fmin, "fmax": args.fmax, "nf": args.nf, "taumin": args.taumin, "taumax": args.taumax, "ntau": args.ntau},
        },
        "notes": ["Single-mode damped sinusoid baseline; extend to multi-mode later."],
    })
    print("Wrote ringdown artifacts to", out_dir)
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
