#!/usr/bin/env python3
"""Phase 4B — Paper-faithful CAT/EPT protocol + residual tables + PT export.

Inputs (produced by Phase 1 & 2):
  - PAPER_TABLES/OBSERVABLES/obs_spectral.csv
  - PAPER_TABLES/OBSERVABLES/obs_time_domain.csv

Outputs (Phase 4B):
  - PAPER_TABLES/CAT_PAPER_FAITHFUL/fit_params.json
  - PAPER_TABLES/CAT_PAPER_FAITHFUL/predicted_visibility.csv
  - PAPER_TABLES/CAT_PAPER_FAITHFUL/rmse_by_figure.csv
  - PAPER_TABLES/CAT_PAPER_FAITHFUL_PT/pt_metric_tables.csv
  - PAPER_TABLES/BASELINE_VS_CAT/residuals_summary.csv
  - PAPER_TABLES/BASELINE_VS_CAT/per_S_residuals.csv

What it does:
  (1) Fit the paper visibility model on a single S-set (default: figure_ref=Fig_2f).
      Model: V(S) = V_cl(eta) * exp(-lambda_ent * |S|)
      where V_cl(eta) = 2 eta / (1+eta^2).
  (2) Lock slit edge parameters (alpha,beta) from time-domain observables when available,
      and record the implied "single operator" constraint proxy:
          beta_eff ≈ 1/decay_tau  and  alpha_eff ≈ log(81)/rise_10_90.
      These are written to fit_params.json to make the constraint auditable.
  (3) Compare baseline vs CAT on the SAME prediction task (out-of-fit-set RMSE), and
      write residual tables.
  (4) Export a minimal PT-symmetric QM representation of the fitted visibility decay:
      define q(S) = -ln( V(S) / V_cl ), so that q(S) = lambda_ent * |S|.
      Then, using the common PT-QM ansatz η = e^{-Q} and C = e^Q P,
      we export a toy 2x2 construction with Q = q σ_y and P = [[0,1],[1,0]].

Note: The PT export is a *toy reduced model* intended for bookkeeping and to
connect to your paper's notation (metric operator η and C operator), not to
claim the full system is exactly PT-symmetric.
"""

from __future__ import annotations

import argparse
import csv
import json
import math
from dataclasses import asdict
from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np


def _read_csv(path: Path) -> List[Dict[str, str]]:
    with path.open("r", newline="") as f:
        return list(csv.DictReader(f))


def vcl_from_eta(eta: float) -> float:
    eta = float(eta)
    if eta <= 0:
        return 0.0
    return (2.0 * eta) / (1.0 + eta * eta)


def fit_eta_lambda(S_s: np.ndarray, V: np.ndarray) -> Dict[str, float]:
    """Simple grid search + local refine (no SciPy)."""
    eta_grid = np.logspace(-2, 2, 401)
    lam_grid = np.linspace(0.0, 6e15, 601)

    best = {"eta": 1.0, "lambda_ent": 0.0, "rmse": float("inf")}
    for eta in eta_grid:
        Vcl = vcl_from_eta(eta)
        if Vcl <= 0:
            continue
        for lam in lam_grid:
            pred = Vcl * np.exp(-lam * np.abs(S_s))
            rmse = float(np.sqrt(np.mean((pred - V) ** 2)))
            if rmse < best["rmse"]:
                best = {"eta": float(eta), "lambda_ent": float(lam), "rmse": rmse}

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


def _filter_rows_for_fit(rows: List[Dict[str, str]], figure_ref: str, visibility_col: str) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    S_fs: List[float] = []
    V: List[float] = []
    for r in rows:
        if r.get("figure_ref") != figure_ref:
            continue
        try:
            s = float(r.get("slit_separation_fs", "nan"))
            v = float(r.get(visibility_col, "nan"))
        except Exception:
            continue
        if not (np.isfinite(s) and np.isfinite(v)):
            continue
        if v <= 0 or v > 1.5:
            continue
        S_fs.append(s)
        V.append(min(v, 1.0))

    S_fs_arr = np.asarray(S_fs, dtype=float)
    V_arr = np.asarray(V, dtype=float)
    S_s_arr = np.abs(S_fs_arr) * 1e-15
    return S_s_arr, V_arr, S_fs_arr


def _summarize_rmse_by_figure(rows: List[Dict[str, str]], pred: np.ndarray, visibility_col: str) -> List[Dict[str, str]]:
    by_fig: Dict[str, List[float]] = {}
    for r, p in zip(rows, pred):
        try:
            v = float(r.get(visibility_col, "nan"))
        except Exception:
            continue
        if not np.isfinite(v) or v <= 0:
            continue
        v = min(v, 1.0)
        fig = r.get("figure_ref", "?")
        by_fig.setdefault(fig, []).append((p - v) ** 2)

    out: List[Dict[str, str]] = []
    for fig, errs in sorted(by_fig.items()):
        rmse = math.sqrt(sum(errs) / max(len(errs), 1))
        out.append({"figure_ref": fig, "rmse": f"{rmse:.6g}", "n": str(len(errs))})
    return out


def _load_time_domain_constraints(path: Path) -> Dict[float, Dict[str, float]]:
    """Return dict S_fs -> {rise_10_90_fs, decay_tau_fs} (if present)."""
    if not path.exists():
        return {}
    rows = _read_csv(path)
    out: Dict[float, Dict[str, float]] = {}
    for r in rows:
        try:
            s = float(r.get("slit_separation_fs", "nan"))
        except Exception:
            continue
        if not np.isfinite(s):
            continue
        d: Dict[str, float] = {}
        for k in ("rise_10_90_fs", "decay_tau_fs"):
            try:
                val = float(r.get(k, "nan"))
            except Exception:
                val = float("nan")
            if np.isfinite(val) and val > 0:
                d[k] = val
        if d:
            out[s] = d
    return out


def _infer_alpha_beta_from_time_domain(td: Dict[float, Dict[str, float]]) -> Dict[str, float]:
    """Infer representative alpha/beta from available time-domain rows.

    Uses robust medians:
      alpha ≈ ln(81)/rise_10_90
      beta  ≈ 1/decay_tau
    """
    ln81 = math.log(81.0)
    alphas = []
    betas = []
    for _, d in td.items():
        if "rise_10_90_fs" in d:
            alphas.append(ln81 / (d["rise_10_90_fs"] * 1e-15))
        if "decay_tau_fs" in d:
            betas.append(1.0 / (d["decay_tau_fs"] * 1e-15))

    out = {}
    if alphas:
        out["alpha_inv_s_median"] = float(np.median(np.asarray(alphas)))
    if betas:
        out["beta_inv_s_median"] = float(np.median(np.asarray(betas)))
    # Single-operator proxy: record ratio beta/alpha when both exist.
    if "alpha_inv_s_median" in out and "beta_inv_s_median" in out:
        out["beta_over_alpha"] = float(out["beta_inv_s_median"] / max(out["alpha_inv_s_median"], 1e-30))
    return out


def _pt_export_table(S_fs: np.ndarray, V: np.ndarray, Vcl: float, lambda_ent: float) -> List[Dict[str, str]]:
    """Export toy PT metric tables.

    Define q(S)= -ln(V/Vcl) = lambda_ent*|S|.
    Build Q = q sigma_y (toy), eta = exp(-Q), C = exp(Q) P.

    We export scalar q and the corresponding 2x2 matrices entries.
    """
    P = np.asarray([[0.0, 1.0], [1.0, 0.0]])
    sigma_y = np.asarray([[0.0, -1.0], [1.0, 0.0]])  # real representation (i*sigma_y stripped)

    out: List[Dict[str, str]] = []
    for s_fs, v in zip(S_fs, V):
        s_s = abs(s_fs) * 1e-15
        q = float(lambda_ent * s_s)
        # exp(q sigma_y) = cosh(q) I + sinh(q) sigma_y
        I = np.eye(2)
        expQ = math.cosh(q) * I + math.sinh(q) * sigma_y
        expmQ = math.cosh(q) * I - math.sinh(q) * sigma_y
        C = expQ @ P
        eta = expmQ
        out.append({
            "slit_separation_fs": f"{s_fs:.12g}",
            "visibility_used": f"{min(float(v),1.0):.12g}",
            "Vcl": f"{Vcl:.12g}",
            "q_scalar": f"{q:.12g}",
            "eta_00": f"{eta[0,0]:.12g}",
            "eta_01": f"{eta[0,1]:.12g}",
            "eta_10": f"{eta[1,0]:.12g}",
            "eta_11": f"{eta[1,1]:.12g}",
            "C_00": f"{C[0,0]:.12g}",
            "C_01": f"{C[0,1]:.12g}",
            "C_10": f"{C[1,0]:.12g}",
            "C_11": f"{C[1,1]:.12g}",
        })
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--obs_spectral", default="PAPER_TABLES/OBSERVABLES/obs_spectral.csv")
    ap.add_argument("--obs_time", default="PAPER_TABLES/OBSERVABLES/obs_time_domain.csv")
    ap.add_argument("--fit_figure", default="Fig_2f")
    ap.add_argument("--visibility_col", default="visibility_paper", choices=["visibility_paper", "visibility_robust"])
    ap.add_argument("--out", default="PAPER_TABLES")
    args = ap.parse_args()

    obs_rows = _read_csv(Path(args.obs_spectral))
    if not obs_rows:
        raise SystemExit(f"No rows in {args.obs_spectral}")

    S_s_fit, V_fit, S_fs_fit = _filter_rows_for_fit(obs_rows, args.fit_figure, args.visibility_col)
    if len(S_s_fit) < 5:
        raise SystemExit(f"Not enough fit rows for figure {args.fit_figure}: {len(S_s_fit)}")

    fit = fit_eta_lambda(S_s_fit, V_fit)
    eta = fit["eta"]
    lam = fit["lambda_ent"]
    Vcl = vcl_from_eta(eta)

    # Predict for all rows that have slit_separation_fs and the visibility column.
    all_S_fs = []
    all_V_obs = []
    all_fig = []
    for r in obs_rows:
        try:
            s = float(r.get("slit_separation_fs", "nan"))
            v = float(r.get(args.visibility_col, "nan"))
        except Exception:
            continue
        if not (np.isfinite(s) and np.isfinite(v)):
            continue
        if v <= 0:
            continue
        all_S_fs.append(s)
        all_V_obs.append(min(v, 1.0))
        all_fig.append(r.get("figure_ref", "?"))

    all_S_fs_arr = np.asarray(all_S_fs, dtype=float)
    all_S_s_arr = np.abs(all_S_fs_arr) * 1e-15
    all_V_obs_arr = np.asarray(all_V_obs, dtype=float)

    V_pred = Vcl * np.exp(-lam * np.abs(all_S_s_arr))

    # Residuals for baseline vs CAT: baseline is "lambda=0" using only Vcl term.
    V_base = Vcl * np.ones_like(V_pred)
    rmse_base = float(np.sqrt(np.mean((V_base - all_V_obs_arr) ** 2)))
    rmse_cat = float(np.sqrt(np.mean((V_pred - all_V_obs_arr) ** 2)))

    # Time-domain constraints (single-operator proxy)
    td = _load_time_domain_constraints(Path(args.obs_time))
    td_infer = _infer_alpha_beta_from_time_domain(td) if td else {}

    out_root = Path(args.out)
    out_cat = out_root / "CAT_PAPER_FAITHFUL"
    out_pt = out_root / "CAT_PAPER_FAITHFUL_PT"
    out_cmp = out_root / "BASELINE_VS_CAT"
    out_cat.mkdir(parents=True, exist_ok=True)
    out_pt.mkdir(parents=True, exist_ok=True)
    out_cmp.mkdir(parents=True, exist_ok=True)

    # (1) Write paper-faithful fit + predictions
    fit_params = {
        "fit_figure": args.fit_figure,
        "visibility_col": args.visibility_col,
        "eta": eta,
        "Vcl": Vcl,
        "lambda_ent_inv_s": lam,
        "rmse_fitset": fit["rmse"],
        "baseline_rmse_all": rmse_base,
        "cat_rmse_all": rmse_cat,
        "time_domain_single_operator_proxy": td_infer,
        "notes": {
            "V_model": "V(S)=Vcl(eta)*exp(-lambda_ent*|S|)",
            "baseline": "baseline uses lambda_ent=0 with same Vcl",
        },
    }
    with (out_cat / "fit_params.json").open("w") as f:
        json.dump(fit_params, f, indent=2)

    pred_csv = out_cat / "predicted_visibility.csv"
    with pred_csv.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["figure_ref", "slit_separation_fs", "visibility_obs", "visibility_pred", "visibility_base", "resid_cat", "resid_base"])
        writer.writeheader()
        for fig, s_fs, v_obs, v_p, v_b in zip(all_fig, all_S_fs_arr, all_V_obs_arr, V_pred, V_base):
            writer.writerow({
                "figure_ref": fig,
                "slit_separation_fs": f"{s_fs:.12g}",
                "visibility_obs": f"{v_obs:.12g}",
                "visibility_pred": f"{float(v_p):.12g}",
                "visibility_base": f"{float(v_b):.12g}",
                "resid_cat": f"{float(v_p - v_obs):.12g}",
                "resid_base": f"{float(v_b - v_obs):.12g}",
            })

    # RMSE by figure for CAT predictions
    rows_for_summary = [
        {"figure_ref": fig, "slit_separation_fs": str(s), args.visibility_col: str(v)}
        for fig, s, v in zip(all_fig, all_S_fs_arr.tolist(), all_V_obs_arr.tolist())
    ]
    summary = _summarize_rmse_by_figure(rows_for_summary, V_pred, args.visibility_col)
    with (out_cat / "rmse_by_figure.csv").open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["figure_ref", "rmse", "n"])
        w.writeheader()
        for r in summary:
            w.writerow(r)

    with (out_cat / "STATUS.txt").open("w") as f:
        f.write("Phase 4B — CAT paper-faithful visibility fit + prediction\n")
        f.write(f"fit_figure={args.fit_figure}  visibility_col={args.visibility_col}\n")
        f.write(f"eta={eta:.6g}  lambda_ent={lam:.6g}  Vcl={Vcl:.6g}\n")
        f.write(f"baseline_rmse_all={rmse_base:.6g}  cat_rmse_all={rmse_cat:.6g}\n")

    # (3) Baseline vs CAT residual summary
    with (out_cmp / "residuals_summary.csv").open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["metric", "baseline", "cat"])
        w.writeheader()
        w.writerow({"metric": "rmse_all", "baseline": f"{rmse_base:.12g}", "cat": f"{rmse_cat:.12g}"})
        w.writerow({"metric": "rmse_fitset", "baseline": "(not fit)", "cat": f"{fit['rmse']:.12g}"})

    # per-S residuals table (aggregated by |S| and by figure)
    perS: Dict[Tuple[str, float], List[float]] = {}
    perS_base: Dict[Tuple[str, float], List[float]] = {}
    for fig, s_fs, v_obs, v_p, v_b in zip(all_fig, all_S_fs_arr, all_V_obs_arr, V_pred, V_base):
        key = (fig, float(s_fs))
        perS.setdefault(key, []).append(float(v_p - v_obs))
        perS_base.setdefault(key, []).append(float(v_b - v_obs))

    with (out_cmp / "per_S_residuals.csv").open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["figure_ref", "slit_separation_fs", "resid_cat_mean", "resid_base_mean", "abs_err_cat", "abs_err_base", "n"])
        w.writeheader()
        for (fig, s_fs), errs in sorted(perS.items(), key=lambda x: (x[0][0], abs(x[0][1]))):
            eb = perS_base[(fig, s_fs)]
            mean_cat = float(np.mean(np.asarray(errs)))
            mean_base = float(np.mean(np.asarray(eb)))
            abs_cat = float(np.mean(np.abs(np.asarray(errs))))
            abs_base = float(np.mean(np.abs(np.asarray(eb))))
            w.writerow({
                "figure_ref": fig,
                "slit_separation_fs": f"{s_fs:.12g}",
                "resid_cat_mean": f"{mean_cat:.12g}",
                "resid_base_mean": f"{mean_base:.12g}",
                "abs_err_cat": f"{abs_cat:.12g}",
                "abs_err_base": f"{abs_base:.12g}",
                "n": str(len(errs)),
            })

    # (4) PT metric export table (toy)
    pt_rows = _pt_export_table(all_S_fs_arr, all_V_obs_arr, Vcl, lam)
    with (out_pt / "pt_metric_tables.csv").open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(pt_rows[0].keys()))
        w.writeheader()
        for r in pt_rows:
            w.writerow(r)

    with (out_pt / "README.txt").open("w") as f:
        f.write("Toy PT export for bookkeeping\n")
        f.write("We use q(S)=-ln(V/Vcl)=lambda_ent*|S| and build Q=q*sigma_y, eta=e^{-Q}, C=e^Q P.\n")
        f.write("This connects to the standard PT-QM relations eta=e^{-Q} and C=e^Q P (see uploaded PT-symmetric QM notes).\n")

    print(f"Wrote: {out_cat}, {out_cmp}, {out_pt}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
