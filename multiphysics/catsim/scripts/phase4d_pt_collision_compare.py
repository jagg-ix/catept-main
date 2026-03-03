#!/usr/bin/env python3
"""Phase 4D: PT-systems + collision-operator comparison.

This script consumes *tool-generated* Phase 1-4 artifacts and produces new tool outputs.

PT part (toy 2×2 reduced model)
--------------------------------
From extracted visibility V(S) (Fig_2f), define
  Vcl = 2η/(1+η^2)  (from CAT_PAPER_FAITHFUL/fit_params.json if available)
  q(S) = max(0, -ln(max(V(S),eps)/max(Vcl,eps)))
Then export 2×2 operators:
  sigma_y = [[0,-i],[i,0]]
  P = [[0,1],[1,0]]
  Qop = q*sigma_y
  eta = exp(-Qop)
  C = exp(Qop) P

Collision operator part (RTA proxy)
-----------------------------------
From time-domain decay tau_decay(S) (Fig_2g), define
  beta_eff(S) = 1/tau_decay(S)
  nu_RTA(S) = beta_eff(S)
Compare beta_eff and nu_RTA against the CAT/EPT coherence rate lambda_ent (from spectral Phase 4C).

NOTE: This is *not* a full implementation of a linear Boltzmann collision operator kernel. It is a
relaxation-time proxy that exposes the rate layer needed to connect to a collision-operator picture.
"""

import argparse
import json
from pathlib import Path

import numpy as np
import pandas as pd


def _load_json(path: Path):
    if not path.exists():
        return None
    try:
        return json.loads(path.read_text())
    except Exception:
        return None


def _exp_matrix_sigma_y(a: float):
    """Return exp(a*sigma_y) for sigma_y=[[0,-i],[i,0]].

    Since sigma_y^2 = I, exp(a*sigma_y) = cosh(a) I + sinh(a) sigma_y.
    """
    ca = float(np.cosh(a))
    sa = float(np.sinh(a))
    I = np.eye(2, dtype=np.complex128)
    sy = np.array([[0.0, -1.0j], [1.0j, 0.0]], dtype=np.complex128)
    return ca * I + sa * sy


def build_pt_tables(obs_spectral_csv: Path, fit_params_json: Path, out_dir: Path, eps: float = 1e-12):
    out_dir.mkdir(parents=True, exist_ok=True)

    df = pd.read_csv(obs_spectral_csv)
    # default: use Fig_2f only
    df = df[df["figure_ref"].astype(str) == "Fig_2f"].copy()
    if df.empty:
        raise RuntimeError("No Fig_2f rows found in obs_spectral.csv")

    params = _load_json(fit_params_json) or {}
    Vcl = float(params.get("Vcl", 1.0))
    eta_fit = float(params.get("eta", np.nan))

    # Choose a visibility column preference order
    vis_col = None
    for cand in ["visibility_paper", "visibility_robust", "visibility"]:
        if cand in df.columns:
            vis_col = cand
            break
    if vis_col is None:
        raise RuntimeError("No visibility column found in obs_spectral.csv")

    rows = []
    P = np.array([[0.0, 1.0], [1.0, 0.0]], dtype=np.complex128)

    for _, r in df.iterrows():
        S_fs = float(r["slit_separation_fs"])
        V = float(r[vis_col])
        Vn = max(V, eps)
        Vcln = max(Vcl, eps)
        q = max(0.0, -float(np.log(Vn / Vcln)))

        # eta = exp(-Qop) where Qop = q*sigma_y
        eta_op = _exp_matrix_sigma_y(-q)
        C_op = _exp_matrix_sigma_y(q) @ P

        rows.append(
            {
                "S_fs": S_fs,
                "visibility": V,
                "Vcl": Vcl,
                "q": q,
                "eta_00": eta_op[0, 0],
                "eta_01": eta_op[0, 1],
                "eta_10": eta_op[1, 0],
                "eta_11": eta_op[1, 1],
                "C_00": C_op[0, 0],
                "C_01": C_op[0, 1],
                "C_10": C_op[1, 0],
                "C_11": C_op[1, 1],
            }
        )

    out_csv = out_dir / "pt_metric_tables.csv"
    out_df = pd.DataFrame(rows)
    # split complex entries into real/imag columns (CSV-friendly)
    for col in [c for c in out_df.columns if out_df[c].dtype == object or np.iscomplexobj(out_df[c].iloc[0])]:
        if col in ["S_fs", "visibility", "Vcl", "q"]:
            continue
        out_df[f"{col}_re"] = out_df[col].apply(lambda z: np.real(z))
        out_df[f"{col}_im"] = out_df[col].apply(lambda z: np.imag(z))
        out_df.drop(columns=[col], inplace=True)

    out_df.to_csv(out_csv, index=False)

    (out_dir / "README.md").write_text(
        """# PT_SYSTEMS (Phase 4D)

This folder contains a **reduced 2×2 PT-symmetric bookkeeping export** driven by extracted visibility.

- Input visibility is taken from `PAPER_TABLES/OBSERVABLES/obs_spectral.csv` (Fig_2f).
- The classical visibility prefactor `Vcl` is taken from `PAPER_TABLES/CAT_PAPER_FAITHFUL/fit_params.json` if present:
  \(V_{cl}=2\eta/(1+\eta^2)\).
- We define \(q(S)=\max(0,-\ln(V/V_{cl}))\), and then export
  - \(\eta_{op}=e^{-Q}\) with \(Q=q\sigma_y\)
  - \(C=e^{Q}P\)

This is **not** a claim that the full optical system is exactly PT-symmetric. It is a compact operator export
that lets you track the standard PT objects (metric and C-operator) as a function of the extracted decoherence
quantity \(q(S)\).
"""
    )

    return {"Vcl": Vcl, "eta_fit": eta_fit, "visibility_column": vis_col, "rows": len(out_df)}


def build_collision_compare(obs_time_csv: Path, spectral_fit_params_json: Path, out_dir: Path):
    out_dir.mkdir(parents=True, exist_ok=True)

    df = pd.read_csv(obs_time_csv)
    df = df[df["figure_ref"].astype(str) == "Fig_2g"].copy()
    if df.empty:
        raise RuntimeError("No Fig_2g rows found in obs_time_domain.csv")

    params = _load_json(spectral_fit_params_json) or {}
    lam_ent = np.nan
    try:
        lam_ent = float(params.get("cat", {}).get("lambda_ent_best_inv_s", np.nan))
    except Exception:
        lam_ent = np.nan

    rows = []
    for _, r in df.iterrows():
        S_fs = float(r["slit_separation_fs"])
        tau_fs = float(r["decay_tau_fs"])
        rise_fs = float(r["rise_10_90_fs"])
        # convert to seconds
        tau_s = tau_fs * 1e-15
        rise_s = rise_fs * 1e-15
        beta_eff = (1.0 / tau_s) if tau_s > 0 else np.nan
        nu_rta = beta_eff
        alpha_eff = (np.log(81.0) / rise_s) if rise_s > 0 else np.nan
        rows.append(
            {
                "S_fs": S_fs,
                "decay_tau_fs": tau_fs,
                "rise_10_90_fs": rise_fs,
                "beta_eff_inv_s": beta_eff,
                "alpha_eff_inv_s": alpha_eff,
                "nu_rta_inv_s": nu_rta,
                "lambda_ent_inv_s": lam_ent,
                "beta_over_lambda": (beta_eff / lam_ent) if (np.isfinite(beta_eff) and np.isfinite(lam_ent) and lam_ent > 0) else np.nan,
            }
        )

    out_df = pd.DataFrame(rows)
    out_df.to_csv(out_dir / "collision_rates.csv", index=False)

    # global RTA summary
    med_tau_fs = float(np.nanmedian(out_df["decay_tau_fs"].values))
    med_beta = float(np.nanmedian(out_df["beta_eff_inv_s"].values))

    (out_dir / "README.md").write_text(
        f"""# COLLISION_OPERATOR_COMPARE (Phase 4D)

This folder contains a **relaxation-time (RTA) proxy** comparison that connects the time-domain decay
extracted from Fig_2g to a collision-operator rate layer.

- From each time-domain trace we extract a decay constant \(\tau_{{decay}}(S)\) and define
  \(\beta_{{eff}}(S)=1/\tau_{{decay}}(S)\).
- In the simplest relaxation-time approximation (RTA) to a linear Boltzmann collision operator,
  the collision frequency \(\nu\) acts as a single exponential relaxation rate. The proxy mapping is
  \(\nu_{{RTA}}(S)=\beta_{{eff}}(S)\).

We also record the CAT/EPT **coherence decay** rate \(\lambda_{{ent}}\) from the spectral calibration
(Phase 4C) for side-by-side comparison.

## Tool summaries
- median decay tau (fs): {med_tau_fs:.3f}
- median beta_eff (1/s): {med_beta:.6e}
- lambda_ent from spectral fit (1/s): {lam_ent if np.isfinite(lam_ent) else 'NaN'}

**Note:** This is not a full collision integral (kernel) implementation. It provides the rate layer
needed to compare to a collision-operator picture (e.g., Saveliev-style linear Boltzmann operators)
without over-claiming details that are not encoded in the dataset.
"""
    )

    return {"rows": len(out_df), "median_decay_tau_fs": med_tau_fs, "median_beta_eff_inv_s": med_beta, "lambda_ent_inv_s": lam_ent}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--paper_tables", default="PAPER_TABLES", help="Root PAPER_TABLES folder")
    args = ap.parse_args()

    paper = Path(args.paper_tables)
    obs_spec = paper / "OBSERVABLES" / "obs_spectral.csv"
    obs_time = paper / "OBSERVABLES" / "obs_time_domain.csv"
    cat_fit = paper / "CAT_PAPER_FAITHFUL" / "fit_params.json"
    spectral_fit = paper / "SPECTRAL_PREDICTIONS" / "fit_params.json"

    pt_out = paper / "PT_SYSTEMS"
    col_out = paper / "COLLISION_OPERATOR_COMPARE"

    pt_meta = build_pt_tables(obs_spec, cat_fit, pt_out)
    col_meta = build_collision_compare(obs_time, spectral_fit, col_out)

    (paper / "PHASE4D_STATUS.json").write_text(json.dumps({"pt": pt_meta, "collision": col_meta}, indent=2))
    print("Phase 4D complete")


if __name__ == "__main__":
    main()
