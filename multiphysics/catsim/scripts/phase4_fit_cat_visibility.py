#!/usr/bin/env python3
"""Phase 4 — Fit paper-style CAT/EPT visibility and predict other sets.

Model:
    V(S) = (2*eta/(1+eta^2)) * exp(-lambda_ent * |S|)

We fit (eta, lambda_ent) on a chosen figure subset (default: Fig_2f) and then
predict visibility for all rows in PAPER_TABLES/OBSERVABLES/obs_spectral.csv.

Outputs are written to PAPER_TABLES/CAT_PAPER_FAITHFUL/.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np


def vcl_from_eta(eta: float) -> float:
    eta = float(eta)
    if eta <= 0:
        return 0.0
    return (2.0 * eta) / (1.0 + eta * eta)


def model_visibility(eta: float, lambda_ent: float, S_s: np.ndarray) -> np.ndarray:
    Vcl = vcl_from_eta(eta)
    return Vcl * np.exp(-float(lambda_ent) * np.abs(S_s))


def load_obs_csv(path: Path) -> List[Dict[str, str]]:
    with path.open("r", newline="") as f:
        reader = csv.DictReader(f)
        return list(reader)


def rows_to_arrays(rows: List[Dict[str, str]], visibility_col: str) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    S_fs = []
    V = []
    mask_ok = []
    for r in rows:
        try:
            s = float(r.get("slit_separation_fs", "nan"))
            v = float(r.get(visibility_col, "nan"))
        except Exception:
            continue
        if not np.isfinite(s) or not np.isfinite(v):
            continue
        # Keep only physical-ish visibility values in (0,1].
        if v <= 0 or v > 1.5:
            continue
        S_fs.append(s)
        V.append(min(v, 1.0))
        mask_ok.append(True)
    S_fs = np.asarray(S_fs, dtype=float)
    V = np.asarray(V, dtype=float)
    S_s = np.abs(S_fs) * 1e-15
    return S_s, V, S_fs


def fit_eta_lambda(S_s: np.ndarray, V: np.ndarray) -> Dict[str, float]:
    """Coarse grid + local refine on (eta, lambda_ent).

    This stays simple/robust and avoids dependencies beyond numpy.
    """
    # Search ranges:
    eta_grid = np.logspace(-2, 2, 401)  # 0.01 .. 100
    lam_grid = np.linspace(0.0, 6e15, 601)  # 0 .. 6e15 s^-1

    best = {"eta": 1.0, "lambda_ent": 0.0, "rmse": float("inf")}

    for eta in eta_grid:
        Vcl = vcl_from_eta(eta)
        if Vcl <= 0:
            continue
        # For fixed eta, we can solve lambda by 1D search.
        for lam in lam_grid:
            pred = Vcl * np.exp(-lam * np.abs(S_s))
            rmse = float(np.sqrt(np.mean((pred - V) ** 2)))
            if rmse < best["rmse"]:
                best = {"eta": float(eta), "lambda_ent": float(lam), "rmse": rmse}

    # Small local refinement around best.
    eta0 = best["eta"]
    lam0 = best["lambda_ent"]
    eta_ref = np.logspace(np.log10(eta0) - 0.2, np.log10(eta0) + 0.2, 121)
    lam_ref = np.linspace(max(lam0 - 5e14, 0.0), lam0 + 5e14, 201)
    for eta in eta_ref:
        Vcl = vcl_from_eta(eta)
        for lam in lam_ref:
            pred = Vcl * np.exp(-lam * np.abs(S_s))
            rmse = float(np.sqrt(np.mean((pred - V) ** 2)))
            if rmse < best["rmse"]:
                best = {"eta": float(eta), "lambda_ent": float(lam), "rmse": rmse}

    return best


def summarize_by_figure(rows: List[Dict[str, str]], pred_by_idx: Dict[int, float], visibility_col: str) -> List[Dict[str, str]]:
    # Collect per figure RMSE
    by_fig: Dict[str, List[float]] = {}
    for i, r in enumerate(rows):
        if i not in pred_by_idx:
            continue
        fig = r.get("figure_ref", "?")
        try:
            v = float(r.get(visibility_col, "nan"))
        except Exception:
            continue
        if not np.isfinite(v) or v <= 0:
            continue
        v = min(v, 1.0)
        err2 = (pred_by_idx[i] - v) ** 2
        by_fig.setdefault(fig, []).append(err2)

    out = []
    for fig, errs in sorted(by_fig.items()):
        rmse = math.sqrt(sum(errs) / max(len(errs), 1))
        out.append({"figure_ref": fig, "rmse": f"{rmse:.6g}", "n": str(len(errs))})
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--obs", default="PAPER_TABLES/OBSERVABLES/obs_spectral.csv")
    ap.add_argument("--fit_figure", default="Fig_2f", help="Figure_ref used as the single S-set for fitting")
    ap.add_argument("--visibility_col", default="visibility_paper", choices=["visibility_paper", "visibility_robust"])
    ap.add_argument("--outdir", default="PAPER_TABLES/CAT_PAPER_FAITHFUL")
    args = ap.parse_args()

    obs_path = Path(args.obs)
    rows = load_obs_csv(obs_path)

    fit_rows = [r for r in rows if r.get("figure_ref") == args.fit_figure]
    if len(fit_rows) < 5:
        raise SystemExit(f"Not enough rows for fit_figure={args.fit_figure}: {len(fit_rows)}")

    S_s, V, S_fs = rows_to_arrays(fit_rows, args.visibility_col)
    fit = fit_eta_lambda(S_s, V)

    eta = fit["eta"]
    lam = fit["lambda_ent"]
    Vcl = vcl_from_eta(eta)

    # Predict for all rows
    pred_by_idx: Dict[int, float] = {}
    pred_rows: List[Dict[str, str]] = []
    for i, r in enumerate(rows):
        try:
            s_fs = float(r.get("slit_separation_fs", "nan"))
        except Exception:
            continue
        if not np.isfinite(s_fs):
            continue
        s_s = abs(s_fs) * 1e-15
        pred = float(model_visibility(eta, lam, np.asarray([s_s]))[0])
        pred_by_idx[i] = pred
        rr = dict(r)
        rr["pred_visibility"] = f"{pred:.12g}"
        rr["fit_eta"] = f"{eta:.12g}"
        rr["fit_lambda_ent_inv_s"] = f"{lam:.12g}"
        rr["fit_Vcl"] = f"{Vcl:.12g}"
        pred_rows.append(rr)

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    # Write fit params
    with (outdir / "fit_params.json").open("w") as f:
        json.dump({
            "fit_figure": args.fit_figure,
            "visibility_col": args.visibility_col,
            "eta": eta,
            "lambda_ent_inv_s": lam,
            "Vcl": Vcl,
            "rmse_fitset": fit["rmse"],
        }, f, indent=2)

    # Write predictions table
    pred_csv = outdir / "predicted_visibility.csv"
    with pred_csv.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(pred_rows[0].keys()))
        writer.writeheader()
        for r in pred_rows:
            writer.writerow(r)

    # Write summary per figure
    summary = summarize_by_figure(rows, pred_by_idx, args.visibility_col)
    summary_csv = outdir / "rmse_by_figure.csv"
    with summary_csv.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["figure_ref", "rmse", "n"])
        writer.writeheader()
        for r in summary:
            writer.writerow(r)

    # Also produce a human-readable note
    with (outdir / "STATUS.txt").open("w") as f:
        f.write("Phase 4 CAT/EPT paper-style visibility fit\n")
        f.write(f"Fit set: {args.fit_figure} using {args.visibility_col}\n")
        f.write(f"eta={eta:.6g}  lambda_ent={lam:.6g}  Vcl={Vcl:.6g}  rmse_fitset={fit['rmse']:.6g}\n")

    print(f"Wrote: {outdir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
