#!/usr/bin/env python3
"""Phase 6.2 (ADVANCED / proxy): modular proxy K = -log rho.

We build a reduced 2x2 density matrix from extracted spectral coherence.

Assumptions (explicit, proxy-level):
  - Two arms have approximately equal populations p1=p2=1/2.
  - Visibility V relates to coherence magnitude via V = 2 |rho_12|.
  - We set a complex phase of rho_12 using the extracted asymmetry_fraction
    as a sign proxy (no strong physical claim; purely for a stable log).

We compute the modular generator:
    K = -log(rho)
via eigendecomposition and export K entries per S.

We also perform a toy pseudo-hermiticity diagnostic:
  - Construct a toy non-Hermitian H = sigma_x - i * kappa * K
  - Solve for a Hermitian metric eta from H^† eta = eta H (least squares)
  - Export residual and cond(eta)

Outputs:
  PAPER_TABLES/ADVANCED/MODULAR_PROXY/
    - modular_proxy_table.csv
    - summary.json
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from cat_ept_doubleslit.utils.run_id import compute_run_id

from catsim_core.data_sources.export import write_data_sources_json

import numpy as np
import pandas as pd


def logm_2x2(rho: np.ndarray) -> np.ndarray:
    """Matrix log for 2x2 PSD matrix using eigendecomposition."""
    vals, vecs = np.linalg.eig(rho)
    vals = np.real_if_close(vals)
    # Guard against tiny/negative due to numerical noise
    vals = np.clip(np.real(vals), 1e-12, None)
    L = np.diag(np.log(vals))
    inv = np.linalg.inv(vecs)
    return vecs @ L @ inv


def solve_metric_pseudohermiticity(H: np.ndarray) -> tuple[np.ndarray, float]:
    """Solve for Hermitian eta from H^† eta = eta H.

    We parameterize eta as [[a, b+ic],[b-ic, d]] with real a,b,c,d.
    Solve linear equations for (a,b,c,d) up to scale.
    """
    # Unknowns x = [a,b,c,d]
    a,b,c,d = 0,1,2,3
    # Build eta(x)
    # Condition: H^† eta - eta H = 0 (2x2 complex -> 4 complex eq)
    def eta_from(x: np.ndarray) -> np.ndarray:
        return np.array([[x[a], x[b] + 1j*x[c]],[x[b] - 1j*x[c], x[d]]], dtype=complex)

    # Linearize: each entry is linear in x
    # Build A x = 0 in R^{8x4} from real/imag parts
    A = []
    for i in range(2):
        for j in range(2):
            # compute coefficient for each basis variable
            row_re = []
            row_im = []
            for k in range(4):
                x = np.zeros(4)
                x[k] = 1.0
                eta_k = eta_from(x)
                M = H.conj().T @ eta_k - eta_k @ H
                row_re.append(np.real(M[i,j]))
                row_im.append(np.imag(M[i,j]))
            A.append(row_re)
            A.append(row_im)
    A = np.array(A, dtype=float)
    # Find null vector via SVD
    _, _, Vt = np.linalg.svd(A)
    x = Vt[-1,:]
    # Normalize
    x = x / (np.linalg.norm(x) + 1e-12)
    eta = eta_from(x)
    resid = float(np.linalg.norm(H.conj().T @ eta - eta @ H))
    return eta, resid


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--obs_spectral", default="PAPER_TABLES/OBSERVABLES/obs_spectral.csv")
    ap.add_argument("--out", default="PAPER_TABLES")
    ap.add_argument("--figure", default="Fig_2f")
    ap.add_argument("--visibility_col", default="visibility_paper")
    ap.add_argument("--kappa", type=float, default=0.1)
    args = ap.parse_args()

    obs = pd.read_csv(args.obs_spectral)
    obs = obs[(obs["figure_ref"] == args.figure)]
    if len(obs) == 0:
        raise SystemExit(f"No rows for figure {args.figure} in {args.obs_spectral}")

    out_dir = Path(args.out) / "ADVANCED" / "MODULAR_PROXY"
    out_dir.mkdir(parents=True, exist_ok=True)

    # Estimate Vcl from smallest-|S| points (robust)
    obs = obs.copy()
    obs["absS"] = obs["slit_separation_fs"].abs()
    vcl = float(np.nanpercentile(obs.loc[obs["absS"] <= np.nanpercentile(obs["absS"], 20), args.visibility_col], 95))
    vcl = max(min(vcl, 0.999999), 1e-6)

    rows = []
    sigma_x = np.array([[0,1],[1,0]], dtype=complex)
    for _, r in obs.iterrows():
        S = float(r["slit_separation_fs"])
        V = float(r.get(args.visibility_col, np.nan))
        if not np.isfinite(V) or V <= 0:
            continue
        V = min(max(V, 1e-6), 0.999999)
        # coherence magnitude
        coh = 0.5 * V
        # phase proxy from asymmetry sign (bounded)
        a = float(r.get("asymmetry_fraction", 0.0))
        a = 0.0 if not np.isfinite(a) else float(np.clip(a, -0.99, 0.99))
        phi = float(np.sign(a) * np.arcsin(abs(a)))
        rho12 = coh * np.exp(1j*phi)
        rho = np.array([[0.5, rho12],[np.conj(rho12), 0.5]], dtype=complex)
        # ensure PSD by clipping coherence if necessary
        # eigenvalues: 1/2 ± |rho12|
        maxcoh = 0.5 - 1e-9
        if abs(rho12) > maxcoh:
            rho12 = maxcoh * rho12/abs(rho12)
            rho = np.array([[0.5, rho12],[np.conj(rho12), 0.5]], dtype=complex)

        K = -logm_2x2(rho)
        H = sigma_x - 1j * args.kappa * K
        eta, resid = solve_metric_pseudohermiticity(H)
        cond = float(np.linalg.cond(eta)) if np.all(np.isfinite(eta)) else float("nan")

        rows.append(
            {
                "slit_separation_fs": S,
                "V": V,
                "Vcl_est": vcl,
                "phi_proxy": phi,
                "rho12_re": float(np.real(rho12)),
                "rho12_im": float(np.imag(rho12)),
                "K00": float(np.real(K[0,0])),
                "K01_re": float(np.real(K[0,1])),
                "K01_im": float(np.imag(K[0,1])),
                "K11": float(np.real(K[1,1])),
                "eta00": float(np.real(eta[0,0])),
                "eta01_re": float(np.real(eta[0,1])),
                "eta01_im": float(np.imag(eta[0,1])),
                "eta11": float(np.real(eta[1,1])),
                "pseudoherm_resid": resid,
                "cond_eta": cond,
            }
        )

    df = pd.DataFrame(rows).sort_values("slit_separation_fs")
    df.to_csv(out_dir / "modular_proxy_table.csv", index=False)
    summary = {
        "figure": args.figure,
        "visibility_col": args.visibility_col,
        "Vcl_est": vcl,
        "kappa": args.kappa,
        "note": "ADVANCED/proxy: 2x2 rho from visibility with equal populations; K=-log rho; toy pseudo-hermiticity check for H=sigma_x - i kappa K.",
        "rows": int(len(df)),
        "median_pseudoherm_resid": float(df["pseudoherm_resid"].median()) if len(df) else None,
        "median_cond_eta": float(df["cond_eta"].median()) if len(df) else None,
    }
    # Deterministic run_id (no timestamps): bundle version + primary inputs.
    repo_root = Path(__file__).resolve().parents[1]
    bv_path = repo_root / 'BUNDLE_VERSION.txt'
    bundle_version = bv_path.read_text().strip() if bv_path.exists() else 'unknown'
    run_id = compute_run_id(
        bundle_version=bundle_version,
        script_id='phase6.2_modular_proxy',
        db_path=args.obs_spectral,
        config_paths=[],
    )
    summary['run_id'] = run_id
    (out_dir / 'run_id.txt').write_text(run_id + '\n')

    # Deterministic provenance for offline/repro bundles.
    write_data_sources_json(out_dir / 'data_sources.json', repo_root=repo_root)

    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    (out_dir / "STATUS.txt").write_text("OK\n")
    (out_dir / "STATUS.md").write_text(
        "# Phase 6.2 — Modular proxy diagnostic\n\n"
        f"- figure: `{args.figure}`\n"
        f"- visibility column: `{args.visibility_col}`\n"
        f"- kappa: {args.kappa}\n"
        f"- rows: {int(len(df))}\n"
        "- status: **OK**\n"
        f"- run_id: `{run_id}`\n\n"
        "This phase is a toy (proxy) diagnostic. It reconstructs a 2×2 density matrix from visibility and checks a pseudo-Hermiticity residual for a model generator.\n"
        "See `modular_proxy_table.csv` and `summary.json`.\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
