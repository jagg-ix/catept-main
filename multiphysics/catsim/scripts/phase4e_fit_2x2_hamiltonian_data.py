#!/usr/bin/env python3
"""Phase 4E (improved): data-fitted 2x2 effective PT-like Hamiltonian diagnostics.

We build, for each slit separation S, a reduced 2x2 non-Hermitian Hamiltonian

    H = [[ Delta + i*gamma,  J],
         [ J,            -Delta - i*gamma ]]

and choose parameters (Delta, J, gamma) from the *observable tables*:

  - fringe spacing df_THz  -> oscillation angular frequency omega = 2*pi*df*1e12
  - visibility V(S)        -> decoherence generator q(S) = max(0, -ln(V/Vcl))
                              and lambda_eff(S) = q / (|S|*1e-15)
                              then gamma = lambda_eff/2
  - asymmetry fraction a   -> maps to Delta via Delta = clip(a, -0.9, 0.9) * s
                              where s = omega/2

Given s = omega/2, we solve for J from the eigenvalue relation
  s^2 = J^2 + Delta^2 - gamma^2  (unbroken PT -> s^2 >= 0)

Then we test pseudo-Hermiticity by solving H^dagger eta = eta H over Hermitian
eta (up to scale) and report residuals + condition number.

Outputs are written under PAPER_TABLES/PT_HAMILTONIAN_2x2_DATA/.

This is intentionally conservative: it is a *diagnostic mapping* that lets you
audit whether a PT-like reduction is numerically consistent with the extracted
observables. It is not a claim of fundamental equivalence.
"""

from __future__ import annotations

import argparse
import json
import math
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Tuple

import numpy as np
import pandas as pd


def _safe_float(x) -> float:
    try:
        if x is None:
            return float("nan")
        return float(x)
    except Exception:
        return float("nan")


def estimate_vcl(obs: pd.DataFrame, vcol: str) -> float:
    """Estimate V_cl from data if not provided.

    Use the 95th percentile visibility among the smallest 20% |S| points.
    """
    df = obs.copy()
    df["absS"] = df["slit_separation_fs"].abs()
    df = df[np.isfinite(df[vcol]) & np.isfinite(df["absS"]) & (df["absS"] > 0)]
    if len(df) == 0:
        return 1.0
    cutoff = np.quantile(df["absS"].values, 0.2)
    small = df[df["absS"] <= cutoff]
    if len(small) == 0:
        small = df.nsmallest(max(1, min(10, len(df))), "absS")
    v = np.clip(small[vcol].values.astype(float), 1e-9, 1.0)
    return float(np.quantile(v, 0.95))


@dataclass
class FitRow:
    S_fs: float
    df_THz: float
    omega: float
    s: float
    visibility: float
    q: float
    lambda_eff: float
    gamma: float
    asym: float
    Delta: float
    J: float
    pt_unbroken: bool
    eta_residual: float
    eta_cond: float


def solve_eta_pseudohermiticity(H: np.ndarray, rcond: float = 1e-12) -> Tuple[np.ndarray, float]:
    """Solve H^dagger eta = eta H for Hermitian eta.

    Parameterize eta = [[a, c+id],[c-id, b]] with real (a,b,c,d).
    Solve linear system for (a,b,c,d) up to scale via least squares.
    Return eta (scaled so trace=2) and residual norm.
    """
    # Unknowns x = [a, b, c, d]
    a, b, c, d = 0, 1, 2, 3
    # Build eta from x
    # We enforce equality of each matrix entry (complex) -> 4 real equations per entry.
    # But 2x2 gives 4 complex eqs = 8 real; enough.
    def eta_from(x):
        A = x[a]
        B = x[b]
        C = x[c]
        D = x[d]
        return np.array([[A, C + 1j * D], [C - 1j * D, B]], dtype=complex)

    # Linearize: vec(H^dagger eta - eta H) = 0
    # Each entry is linear in x.
    M = []
    y = []
    # unit vectors for each variable
    basis = [np.array([1, 0, 0, 0], float), np.array([0, 1, 0, 0], float), np.array([0, 0, 1, 0], float), np.array([0, 0, 0, 1], float)]
    for i in range(2):
        for j in range(2):
            # compute coefficient for each variable
            coeffs = []
            for e in basis:
                E = eta_from(e)
                Z = H.conj().T @ E - E @ H
                coeffs.append(Z[i, j])
            # equation: sum_k coeffs[k]*x[k] = 0
            # split real/imag
            row_re = [float(np.real(cc)) for cc in coeffs]
            row_im = [float(np.imag(cc)) for cc in coeffs]
            M.append(row_re)
            y.append(0.0)
            M.append(row_im)
            y.append(0.0)
    M = np.array(M, float)
    y = np.array(y, float)

    # Solve least squares with a scale fix: add constraint trace(eta)=2 => a+b=2
    M2 = np.vstack([M, np.array([1.0, 1.0, 0.0, 0.0], float)])
    y2 = np.concatenate([y, np.array([2.0], float)])
    x, *_ = np.linalg.lstsq(M2, y2, rcond=rcond)
    eta = eta_from(x)
    res = H.conj().T @ eta - eta @ H
    residual = float(np.linalg.norm(res))
    return eta, residual


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--obs_spectral", default="PAPER_TABLES/OBSERVABLES/obs_spectral.csv")
    ap.add_argument("--out", default="PAPER_TABLES")
    ap.add_argument("--figure", default="Fig_2f")
    ap.add_argument("--visibility_col", default="visibility_paper")
    ap.add_argument("--vcl", type=float, default=0.0, help="If <=0, estimate from data")
    ap.add_argument("--max_rows", type=int, default=0, help="If >0, limit rows for debugging")
    args = ap.parse_args()

    obs_path = Path(args.obs_spectral)
    out_root = Path(args.out)
    out_dir = out_root / "PT_HAMILTONIAN_2x2_DATA"
    out_dir.mkdir(parents=True, exist_ok=True)

    df = pd.read_csv(obs_path)
    df = df[df["figure_ref"] == args.figure].copy()
    if args.max_rows and args.max_rows > 0:
        df = df.head(args.max_rows).copy()

    # Clean
    df["slit_separation_fs"] = df["slit_separation_fs"].apply(_safe_float)
    df["fringe_spacing_THz"] = df["fringe_spacing_THz"].apply(_safe_float)
    df[args.visibility_col] = df[args.visibility_col].apply(_safe_float)
    df["asymmetry_fraction"] = df["asymmetry_fraction"].apply(_safe_float)

    df = df[np.isfinite(df["slit_separation_fs"]) & np.isfinite(df["fringe_spacing_THz"]) & np.isfinite(df[args.visibility_col])]
    df = df[df["slit_separation_fs"].abs() > 1e-9]
    if len(df) == 0:
        raise SystemExit(f"No usable rows for {args.figure} in {obs_path}")

    vcl = args.vcl if args.vcl and args.vcl > 0 else estimate_vcl(df, args.visibility_col)
    vcl = float(np.clip(vcl, 1e-6, 1.0))

    rows: Dict[float, FitRow] = {}
    eps = 1e-24
    for _, r in df.iterrows():
        S_fs = float(r["slit_separation_fs"])
        absS_s = abs(S_fs) * 1e-15
        df_THz = float(r["fringe_spacing_THz"])
        # cycles/s
        omega = 2.0 * math.pi * df_THz * 1e12
        s = 0.5 * omega

        V = float(np.clip(float(r[args.visibility_col]), 1e-9, 1.0))
        q = max(0.0, -math.log(V / vcl))
        lambda_eff = q / max(absS_s, 1e-30)
        gamma = 0.5 * lambda_eff

        asym = float(r.get("asymmetry_fraction", 0.0))
        if not np.isfinite(asym):
            asym = 0.0
        # Map asymmetry to Delta (bounded so J remains real)
        aclip = float(np.clip(asym, -0.9, 0.9))
        Delta = aclip * s

        # Solve J^2 = s^2 + gamma^2 - Delta^2
        J2 = s * s + gamma * gamma - Delta * Delta
        J = math.sqrt(max(J2, eps))
        pt_unbroken = (s * s > 0.0) and (J2 > 0.0)

        H = np.array([[Delta + 1j * gamma, J], [J, -Delta - 1j * gamma]], dtype=complex)
        eta, residual = solve_eta_pseudohermiticity(H)
        # Condition number of eta (real 2x2 from hermitian eta)
        try:
            eta_cond = float(np.linalg.cond(eta))
        except Exception:
            eta_cond = float("nan")

        rows[S_fs] = FitRow(
            S_fs=S_fs,
            df_THz=df_THz,
            omega=omega,
            s=s,
            visibility=V,
            q=q,
            lambda_eff=lambda_eff,
            gamma=gamma,
            asym=asym,
            Delta=Delta,
            J=J,
            pt_unbroken=pt_unbroken,
            eta_residual=float(residual),
            eta_cond=eta_cond,
        )

    # Write table
    out_rows = []
    for S_fs in sorted(rows.keys(), key=lambda x: abs(x)):
        fr = rows[S_fs]
        out_rows.append(
            {
                "S_fs": fr.S_fs,
                "absS_fs": abs(fr.S_fs),
                "fringe_spacing_THz": fr.df_THz,
                "omega_rad_per_s": fr.omega,
                "s_half_omega": fr.s,
                "visibility": fr.visibility,
                "Vcl_used": vcl,
                "q": fr.q,
                "lambda_eff_inv_s": fr.lambda_eff,
                "gamma_inv_s": fr.gamma,
                "asymmetry_fraction": fr.asym,
                "Delta": fr.Delta,
                "J": fr.J,
                "pt_unbroken": fr.pt_unbroken,
                "eta_residual_norm": fr.eta_residual,
                "eta_condition_number": fr.eta_cond,
            }
        )
    out_df = pd.DataFrame(out_rows)
    out_csv = out_dir / "hamiltonian_2x2_datafit.csv"
    out_df.to_csv(out_csv, index=False)

    # Summary + status
    unbroken = int(out_df["pt_unbroken"].sum())
    n = int(len(out_df))
    summary = {
        "figure": args.figure,
        "n": n,
        "pt_unbroken_count": unbroken,
        "pt_unbroken_fraction": (unbroken / n) if n else 0.0,
        "Vcl_used": vcl,
        "eta_residual_median": float(np.nanmedian(out_df["eta_residual_norm"].values)),
        "eta_cond_median": float(np.nanmedian(out_df["eta_condition_number"].values)),
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    status = "OK" if unbroken == n else "WARN"
    (out_dir / "STATUS.txt").write_text(status + "\n")
    (out_dir / "README.md").write_text(
        """# Phase 4E (improved): data-fitted 2x2 PT-like Hamiltonian diagnostics

This folder is generated by `scripts/phase4e_fit_2x2_hamiltonian_data.py`.

We construct a reduced 2x2 non-Hermitian Hamiltonian per slit separation **S** using
observable tables (visibility, fringe spacing, asymmetry). This is a **diagnostic mapping**
to audit pseudo-Hermiticity / PT-like consistency; it is **not** a claim that the full
experiment is exactly described by a 2x2 PT Hamiltonian.
"""
    )


if __name__ == "__main__":
    main()
