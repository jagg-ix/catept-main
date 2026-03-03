#!/usr/bin/env python3
"""Phase 4E: Build a reduced 2x2 effective non-Hermitian Hamiltonian per S.

This is a *diagnostic* layer (PT-like bookkeeping), not a claim that the full
optical system is exactly 2-level PT-symmetric QM.

We:
- Read the fitted lambda_ent from Phase 5 (paper-faithful prediction protocol).
- For each slit separation S in the Phase 5 prediction set, construct a
  PT-symmetric 2x2 Hamiltonian H_S = [[i b, c],[c, -i b]].
  * b is set from the fitted coherence decay rate: b = lambda_ent/2.
  * c is set by a simple scaling with the delay: c = pi / (|S| seconds).
    This ties the coupling timescale to the slit separation timescale.
- Compute whether the spectrum is real (unbroken PT-like condition c>b).
- Construct a metric eta via eigenvector factorization eta = W^H W, W=V^{-1}.
- Report pseudo-Hermiticity residual ||H^H eta - eta H||.
- Export a conventional closed-form C operator for the unbroken case.

Outputs are written to PAPER_TABLES/PT_HAMILTONIAN_2x2/.
"""

from __future__ import annotations

import argparse
import json
import math
import os
from dataclasses import dataclass
from typing import Dict, List, Tuple

import numpy as np
import pandas as pd


SIGMA_X = np.array([[0.0, 1.0], [1.0, 0.0]], dtype=np.complex128)
SIGMA_Z = np.array([[1.0, 0.0], [0.0, -1.0]], dtype=np.complex128)


def load_lambda_ent_inv_s(pred_status_json: str) -> float:
    with open(pred_status_json, "r", encoding="utf-8") as f:
        d = json.load(f)
    lam = float(d.get("lambda_ent_best_inv_s", float("nan")))
    if not np.isfinite(lam) or lam < 0:
        raise ValueError(f"Invalid lambda_ent_best_inv_s in {pred_status_json}: {lam}")
    return lam


def read_S_list(visibility_predictions_csv: str) -> List[float]:
    df = pd.read_csv(visibility_predictions_csv)
    # supports either S_fs or slit_separation_fs
    for col in ("S_fs", "S", "slit_separation_fs"):
        if col in df.columns:
            S = sorted({float(x) for x in df[col].values if np.isfinite(x)})
            return S
    raise ValueError(f"No S column found in {visibility_predictions_csv}. Columns: {list(df.columns)}")


def construct_H(b_inv_s: float, S_fs: float) -> Tuple[np.ndarray, float]:
    # coupling scale from the delay timescale
    t_s = abs(S_fs) * 1e-15
    if t_s <= 0:
        raise ValueError("S must be nonzero")
    c_inv_s = math.pi / t_s
    H = np.array([[1j * b_inv_s, c_inv_s], [c_inv_s, -1j * b_inv_s]], dtype=np.complex128)
    return H, c_inv_s


def metric_from_right_evecs(H: np.ndarray) -> Tuple[np.ndarray, float, float]:
    # Right eigenvectors columns in V
    w, V = np.linalg.eig(H)
    # If V is ill-conditioned, this will be reflected in eta's condition number.
    W = np.linalg.inv(V)
    eta = W.conj().T @ W
    # residual pseudo-Hermiticity
    resid = np.linalg.norm(H.conj().T @ eta - eta @ H)
    cond_eta = np.linalg.cond(eta)
    return eta, resid, cond_eta


def C_operator_closed_form(b_inv_s: float, c_inv_s: float) -> Tuple[np.ndarray, float, bool]:
    """Closed-form C for the PT-symmetric 2x2 Hamiltonian.

    For H = [[i b, c],[c, -i b]], unbroken region is |b|<|c|.
    Define sin(theta) = b/c, cos(theta) = sqrt(1-(b/c)^2).
    Then C = (1/cos theta) (sigma_x + i sin theta sigma_z).
    """
    if c_inv_s <= 0:
        return np.full((2, 2), np.nan + 1j * np.nan), float("nan"), False
    r = b_inv_s / c_inv_s
    if abs(r) >= 1.0:
        return np.full((2, 2), np.nan + 1j * np.nan), float("nan"), False
    cos_theta = math.sqrt(1.0 - r * r)
    C = (SIGMA_X + 1j * r * SIGMA_Z) / cos_theta
    return C, cos_theta, True


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--pred_status", default="PAPER_TABLES/PREDICTIONS/status.json")
    ap.add_argument("--pred_vis", default="PAPER_TABLES/PREDICTIONS/visibility_predictions.csv")
    ap.add_argument("--out", default="PAPER_TABLES/PT_HAMILTONIAN_2x2")
    args = ap.parse_args()

    os.makedirs(args.out, exist_ok=True)

    lam_inv_s = load_lambda_ent_inv_s(args.pred_status)
    b_inv_s = 0.5 * lam_inv_s
    S_list = read_S_list(args.pred_vis)

    rows = []
    for S_fs in S_list:
        if abs(S_fs) < 1e-9:
            continue
        H, c_inv_s = construct_H(b_inv_s, S_fs)
        eigvals = np.linalg.eigvals(H)
        # Unbroken PT-like condition: c>b
        unbroken = bool(c_inv_s > abs(b_inv_s))
        eta, resid, cond_eta = metric_from_right_evecs(H)
        C, cos_theta, C_ok = C_operator_closed_form(b_inv_s, c_inv_s)

        def mat_flat(M: np.ndarray, prefix: str) -> Dict[str, float]:
            out = {}
            for i in range(2):
                for j in range(2):
                    out[f"{prefix}{i}{j}_re"] = float(np.real(M[i, j]))
                    out[f"{prefix}{i}{j}_im"] = float(np.imag(M[i, j]))
            return out

        row = {
            "S_fs": float(S_fs),
            "lambda_ent_inv_s": float(lam_inv_s),
            "b_inv_s": float(b_inv_s),
            "c_inv_s": float(c_inv_s),
            "pt_unbroken": int(unbroken),
            "eig0_re": float(np.real(eigvals[0])),
            "eig0_im": float(np.imag(eigvals[0])),
            "eig1_re": float(np.real(eigvals[1])),
            "eig1_im": float(np.imag(eigvals[1])),
            "pseudoherm_resid": float(resid),
            "cond_eta": float(cond_eta),
            "C_ok": int(C_ok),
            "cos_theta": float(cos_theta) if np.isfinite(cos_theta) else float("nan"),
        }
        row.update(mat_flat(eta, "eta_"))
        row.update(mat_flat(C, "C_"))
        rows.append(row)

    df = pd.DataFrame(rows).sort_values("S_fs")
    out_csv = os.path.join(args.out, "hamiltonian_2x2_table.csv")
    df.to_csv(out_csv, index=False)

    # summary markdown (tool-generated)
    n = len(df)
    n_unbroken = int(df["pt_unbroken"].sum()) if n else 0
    worst_cond = float(df["cond_eta"].max()) if n else float("nan")
    worst_resid = float(df["pseudoherm_resid"].max()) if n else float("nan")

    summary = {
        "lambda_ent_best_inv_s": lam_inv_s,
        "b_inv_s": b_inv_s,
        "count_S": n,
        "count_unbroken": n_unbroken,
        "worst_cond_eta": worst_cond,
        "worst_pseudoherm_resid": worst_resid,
        "notes": [
            "This is a reduced 2x2 PT-like diagnostic model.",
            "b is set from fitted coherence decay (lambda_ent/2).",
            "c is set by c=pi/(|S| seconds) to tie coupling timescale to the delay.",
            "Metric eta is constructed as eta=(V^{-1})^H (V^{-1}).",
            "C is exported only in the unbroken region |b|<|c|.",
        ],
    }
    with open(os.path.join(args.out, "summary.json"), "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)

    md = []
    md.append("# Phase 4E: 2x2 PT-like Hamiltonian diagnostic\n")
    md.append(f"- Fitted lambda_ent: **{lam_inv_s:.6g} 1/s** (from Phase 5 status.json)\n")
    md.append(f"- b=lambda/2: **{b_inv_s:.6g} 1/s**\n")
    md.append(f"- S values analyzed: **{n}**\n")
    md.append(f"- Unbroken condition (c>b) holds for: **{n_unbroken}/{n}**\n")
    md.append("\n## Files\n")
    md.append("- `hamiltonian_2x2_table.csv`: per-S Hamiltonian/metric/C exports\n")
    md.append("- `summary.json`: machine-readable summary\n")
    md.append("\n## Notes\n")
    md.extend([f"- {x}\n" for x in summary["notes"]])

    with open(os.path.join(args.out, "README.md"), "w", encoding="utf-8") as f:
        f.write("".join(md))

    with open(os.path.join(args.out, "STATUS.txt"), "w", encoding="utf-8") as f:
        f.write("OK\n")


if __name__ == "__main__":
    main()
