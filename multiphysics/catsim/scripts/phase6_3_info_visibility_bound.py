#!/usr/bin/env python3
"""Phase 6.3 (ADVANCED): Information–visibility bound (proxy + GKLS-rate estimator).

We compute PASS/FAIL per S using:
  q = -ln(V/V0)
  DeltaI_bits = beta_eff * |S| / ln2   (proxy)

Where beta_eff is read from COLLISION_OPERATOR_COMPARE (Phase 4D).

Outputs (written under PAPER_TABLES/ADVANCED/BOUNDS/):
  - info_visibility_bound.csv            (selected estimator per --deltaI_mode)
  - info_visibility_bound_proxy.csv      (auto proxy: prefer D, else beta)
  - info_visibility_bound_gkls.csv       (GKLS-rate proxy)
  - info_visibility_bound_compare.csv    (residuals/MAE for D, beta, GKLS)
  - summary.json
  - STATUS.txt
  - STATUS.md
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from cat_ept_doubleslit.utils.run_id import compute_run_id

from catsim_core.data_sources.export import write_data_sources_json

import numpy as np
import pandas as pd

from cat_ept_doubleslit.advanced.bounds import (
    delta_I_bits_from_distinguishability,
    delta_I_bits_from_gkls_rate,
    delta_I_bits_proxy,
    info_visibility_bound_pass,
)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--obs_spectral", default="PAPER_TABLES/OBSERVABLES/obs_spectral.csv")
    ap.add_argument("--collision_rates", default="PAPER_TABLES/COLLISION_OPERATOR_COMPARE/collision_rates.csv")
    ap.add_argument("--min_pass_rate", type=float, default=0.80, help="Gate: required fraction of PASS rows")
    ap.add_argument("--out", default="PAPER_TABLES")
    ap.add_argument("--figure", default="Fig_2f")
    ap.add_argument("--visibility_col", default="visibility_paper")
    ap.add_argument("--V0", type=float, default=1.0)
    ap.add_argument(
        "--distinguishability_col",
        default="asym_frac",
        help="Observable column to use as a which-path distinguishability proxy D (0..1).",
    )
    ap.add_argument(
        "--deltaI_mode",
        default="auto",
        choices=["auto", "D", "beta", "gkls"],
        help=(
            "How to compute DeltaI_bits. "
            "auto: prefer D (if present), else beta proxy; "
            "D: use distinguishability only; "
            "beta: use collision-rate proxy only; "
            "gkls: use lambda_ent from Phase 5 as a GKLS-style rate proxy."
        ),
    )
    ap.add_argument(
        "--gkls_window",
        default="S",
        choices=["S", "probe_fwhm"],
        help="Time window to use for DeltaI_bits in gkls mode: S (|slit separation|) or probe_fwhm (from obs column if present).",
    )
    ap.add_argument("--require_pass_rate", type=float, default=0.0, help="If >0, require at least this fraction of PASS rows to call overall PASS/PARTIAL.")
    ap.add_argument("--require_all_pass", action="store_true")
    args = ap.parse_args()

    obs = pd.read_csv(args.obs_spectral)
    obs = obs[obs["figure_ref"] == args.figure].copy()
    if len(obs) == 0:
        raise SystemExit(f"No obs rows for {args.figure}")

    # collision rates may be indexed by slit separation with varying column names
    col = pd.read_csv(args.collision_rates)
    # try common column names
    if "slit_separation_fs" in col.columns:
        s_col = "slit_separation_fs"
    elif "S_fs" in col.columns:
        s_col = "S_fs"
    else:
        s_col = col.columns[0]
    b_col = (
        "nu_RTA_inv_s" if "nu_RTA_inv_s" in col.columns else
        "nu_rta_inv_s" if "nu_rta_inv_s" in col.columns else
        "beta_eff_inv_s" if "beta_eff_inv_s" in col.columns else
        "beta_over_lambda" if "beta_over_lambda" in col.columns else
        None
    )
    if b_col is None:
        # allow missing; will produce NaNs
        col["nu_RTA_inv_s"] = np.nan
        b_col = "nu_RTA_inv_s"

    col = col[[s_col, b_col]].rename(columns={s_col: "slit_separation_fs", b_col: "beta_eff_inv_s"})
    # Robust merge: round to 1e-6 fs to avoid float formatting mismatches
    obs["S_key"] = obs["slit_separation_fs"].round(6)
    col["S_key"] = col["slit_separation_fs"].round(6)
    merged = obs.merge(col.drop(columns=["slit_separation_fs"]), on="S_key", how="left")
    merged["slit_separation_fs"] = merged["S_key"]

    # Phase 5 lambda (needed for gkls mode)
    phase5_status = Path(args.out) / "PREDICTIONS" / "status.json"
    lambda_phase5 = float("nan")
    if phase5_status.exists():
        try:
            lambda_phase5 = float(json.loads(phase5_status.read_text()).get("lambda_ent_best_inv_s", float("nan")))
        except Exception:
            lambda_phase5 = float("nan")

    rows = []
    for _, r in merged.iterrows():
        S = float(r["slit_separation_fs"])
        V = float(r.get(args.visibility_col, np.nan))
        beta = float(r.get("beta_eff_inv_s", np.nan))
        if not np.isfinite(V) or V <= 0:
            continue
        # Candidate DeltaI estimators
        D = float(r.get(args.distinguishability_col, np.nan))
        dib_D = delta_I_bits_from_distinguishability(D) if np.isfinite(D) else float("nan")
        dib_beta = delta_I_bits_proxy(beta, S)

        # GKLS-style proxy uses lambda_ent (Phase 5) integrated over a chosen window
        if args.gkls_window == "probe_fwhm":
            window_fs = float(r.get("probe_fwhm_fs", np.nan))
            if not np.isfinite(window_fs):
                window_fs = abs(S)
        else:
            window_fs = abs(S)
        dib_gkls = delta_I_bits_from_gkls_rate(lambda_phase5, window_fs) if np.isfinite(lambda_phase5) else float("nan")

        # Choose estimator according to mode
        if args.deltaI_mode == "D":
            dib_used = dib_D
            note = "D_proxy"
        elif args.deltaI_mode == "beta":
            dib_used = dib_beta
            note = "beta_proxy"
        elif args.deltaI_mode == "gkls":
            dib_used = dib_gkls
            note = "gkls_rate_proxy"
        else:
            # auto: prefer D, else gkls if available, else beta
            if np.isfinite(dib_D):
                dib_used, note = dib_D, "D_proxy"
            elif np.isfinite(dib_gkls):
                dib_used, note = dib_gkls, "gkls_rate_proxy"
            else:
                dib_used, note = dib_beta, "beta_proxy" if np.isfinite(dib_beta) else "missing_inputs"
        passed = bool(np.isfinite(dib_used) and info_visibility_bound_pass(V, dib_used, V0=args.V0))
        rows.append(
            {
                "slit_separation_fs": S,
                "visibility": V,
                "beta_eff_inv_s": beta,
                "D_proxy": D,
                "deltaI_bits_from_D": dib_D,
                "deltaI_bits_from_beta": dib_beta,
                "lambda_phase5_inv_s": lambda_phase5,
                "deltaI_bits_from_gkls": dib_gkls,
                "gkls_window_fs": window_fs,
                "deltaI_bits_used": dib_used,
                "q_loss": float(-np.log(max(V, 1e-300) / args.V0)),
                "rhs_half_deltaI": float(0.5 * dib_used) if np.isfinite(dib_used) else np.nan,
                "PASS": bool(passed),
                "note": note,
            }
        )

    out_dir = Path(args.out) / "ADVANCED" / "BOUNDS"
    out_dir.mkdir(parents=True, exist_ok=True)

    # Deterministic run_id (no timestamps): bundle version + primary inputs.
    repo_root = Path(__file__).resolve().parents[1]
    bv_path = repo_root / 'BUNDLE_VERSION.txt'
    bundle_version = bv_path.read_text().strip() if bv_path.exists() else 'unknown'
    run_id = compute_run_id(
        bundle_version=bundle_version,
        script_id='phase6.3_info_visibility_bound',
        db_path=args.obs_spectral,
        config_paths=[args.collision_rates],
    )
    df = pd.DataFrame(rows).sort_values("slit_separation_fs")

    # Always write a deterministic "proxy" view (auto but excluding GKLS)
    df_proxy = df.copy()
    # auto: prefer D else beta (never GKLS)
    def _pick_proxy(row: pd.Series) -> tuple[float, str]:
        dib_D = row.get("deltaI_bits_from_D", np.nan)
        dib_beta = row.get("deltaI_bits_from_beta", np.nan)
        if np.isfinite(dib_D):
            return float(dib_D), "D_proxy"
        if np.isfinite(dib_beta):
            return float(dib_beta), "beta_proxy"
        return float("nan"), "missing_inputs"

    proxy_vals = df_proxy.apply(_pick_proxy, axis=1, result_type="expand")
    df_proxy["deltaI_bits_used"] = proxy_vals[0]
    df_proxy["note"] = proxy_vals[1]
    df_proxy["rhs_half_deltaI"] = 0.5 * df_proxy["deltaI_bits_used"]
    df_proxy["PASS"] = df_proxy.apply(
        lambda r: bool(np.isfinite(r["deltaI_bits_used"]) and info_visibility_bound_pass(r["visibility"], r["deltaI_bits_used"], V0=args.V0)),
        axis=1,
    )

    # Always write a deterministic "gkls" view
    df_gkls = df.copy()
    df_gkls["deltaI_bits_used"] = df_gkls["deltaI_bits_from_gkls"]
    df_gkls["note"] = "gkls_rate_proxy"
    df_gkls["rhs_half_deltaI"] = 0.5 * df_gkls["deltaI_bits_used"]
    df_gkls["PASS"] = df_gkls.apply(
        lambda r: bool(np.isfinite(r["deltaI_bits_used"]) and info_visibility_bound_pass(r["visibility"], r["deltaI_bits_used"], V0=args.V0)),
        axis=1,
    )

    # Selected (per CLI) stays as primary output
    df.to_csv(out_dir / "info_visibility_bound.csv", index=False)
    df_proxy.to_csv(out_dir / "info_visibility_bound_proxy.csv", index=False)
    df_gkls.to_csv(out_dir / "info_visibility_bound_gkls.csv", index=False)

    # Comparator: residuals and MAE for each estimator
    comp = pd.DataFrame({"slit_separation_fs": df["slit_separation_fs"].values, "q_loss": df["q_loss"].values})
    for tag, colname in [
        ("D", "deltaI_bits_from_D"),
        ("beta", "deltaI_bits_from_beta"),
        ("gkls", "deltaI_bits_from_gkls"),
    ]:
        rhs = 0.5 * df[colname]
        comp[f"rhs_half_deltaI_{tag}"] = rhs
        comp[f"residual_{tag}"] = comp["q_loss"] - rhs
        comp[f"PASS_{tag}"] = df.apply(
            lambda r: bool(np.isfinite(r.get(colname, np.nan)) and info_visibility_bound_pass(r["visibility"], float(r[colname]), V0=args.V0)),
            axis=1,
        )

    # MAE residuals (ignore NaNs)
    mae = {}
    for tag in ("D", "beta", "gkls"):
        v = comp[f"residual_{tag}"].to_numpy(dtype=float)
        v = v[np.isfinite(v)]
        mae[f"mae_residual_{tag}"] = float(np.mean(np.abs(v))) if len(v) else float("nan")
    comp.to_csv(out_dir / "info_visibility_bound_compare.csv", index=False)

    # Gate status computed on the *selected* df
    n = int(len(df))
    n_pass = int(df["PASS"].sum()) if n else 0
    pass_rate = (n_pass / n) if n else 0.0

    status = "FAIL"
    if n == 0:
        status = "FAIL"
    elif args.require_all_pass:
        status = "PASS" if n_pass == n else "FAIL"
    else:
        status = "PASS" if n_pass == n else ("PARTIAL" if n_pass > 0 else "FAIL")
    if args.require_pass_rate and pass_rate < args.require_pass_rate:
        status = "FAIL"

    (out_dir / "STATUS.txt").write_text(status + "\n")
    (out_dir / "STATUS.md").write_text(
        "# Phase 6.3 — Information–visibility bound\n\n"
        f"- figure: `{args.figure}`\n"
        f"- visibility column: `{args.visibility_col}`\n"
        f"- deltaI_mode (selected output): `{args.deltaI_mode}`\n"
        f"- rows: {n}\n"
        f"- pass: {n_pass}\n"
        f"- pass_rate: {pass_rate:.3f}\n"
        f"- status: **{status}**\n"
        f"- run_id: `{run_id}`\n\n"
        "This phase writes three views of the bound: `info_visibility_bound.csv` (selected by CLI),\n"
        "`info_visibility_bound_proxy.csv` (D/beta only), and `info_visibility_bound_gkls.csv` (GKLS-rate proxy).\n"
    )

    summary = {
        "figure": args.figure,
        "visibility_col": args.visibility_col,
        "V0": args.V0,
        "deltaI_mode": args.deltaI_mode,
        "gkls_window": args.gkls_window,
        "lambda_phase5_inv_s": lambda_phase5,
        "rows": n,
        "pass": n_pass,
        "pass_rate": pass_rate,
        "status": status,
        **mae,
        "note": "ADVANCED: DeltaI is reported from D proxy, collision-rate proxy, and GKLS-rate proxy (Phase 5 lambda_ent). Compare residuals in info_visibility_bound_compare.csv.",
    }
    summary['run_id'] = run_id

    (out_dir / 'run_id.txt').write_text(run_id + '\n')

    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))

    # Deterministic provenance for offline/repro bundles: what public datasets/APIs are referenced by this repo.
    # Written per-phase so any sub-run can be audited independently.
    write_data_sources_json(out_dir / "data_sources.json", repo_root=repo_root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
