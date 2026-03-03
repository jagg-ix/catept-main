"""Optional pynucastro demo wired to CAT/EPT time contract.

This is intentionally lightweight: it builds a TimeSeriesContract from a
pynucastro rate probe and exports it to CSV, using the same (t, tau_ent, lambda)
timeline contract as other backends.

If pynucastro is not installed, the script emits SKIP artifacts and exits 0.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path

import numpy as np


def _ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def _load_phi_profile(path: Path) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Return (t_s, tau_ent_s, lambda_s_inv) from tensor_profile_*.csv.

    The profile CSV uses either coordinate time (t_s) or entropic time (tau_ent_s)
    as its coordinate column. We normalize to the repo's contract.
    """
    import pandas as pd

    df = pd.read_csv(path)
    if "tau_ent_s" in df.columns:
        tau = df["tau_ent_s"].to_numpy(dtype=float)
        # In tau-coordinate profiles, tau is already entropic time.
        t = tau.copy()
        lam = np.ones_like(tau)
        return t, tau, lam
    if "t_s" in df.columns:
        t = df["t_s"].to_numpy(dtype=float)
        if "phi" not in df.columns:
            raise ValueError("phi_profile missing 'phi' column")
        phi = df["phi"].to_numpy(dtype=float)
        # lambda_like already exists but we recompute from phi for robustness
        # (piecewise finite differences).
        dphi = np.gradient(phi, t, edge_order=1)
        lam = np.maximum(dphi, 0.0)
        # tau_ent = ∫ lambda dt
        tau = np.cumsum(lam * np.gradient(t, edge_order=1))
        return t, tau, lam
    raise ValueError("phi_profile missing 't_s' or 'tau_ent_s' coordinate column")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--rate_name", default="c12(a,g)o16")
    ap.add_argument("--T9", type=float, default=1.0)
    ap.add_argument("--rho", type=float, default=1e5)
    ap.add_argument("--phi_profile_csv")
    ap.add_argument("--n", type=int, default=200)
    ap.add_argument("--dt_s", type=float, default=1.0)
    args = ap.parse_args()

    out = Path(args.out)
    _ensure_dir(out)

    summary = {
        "rate_name": str(args.rate_name),
        "T9": float(args.T9),
        "rho": float(args.rho),
        "skipped": False,
    }

    try:
        from catsim_core.pynucastro.adapter import NuclearRateProbe, build_pynucastro_timeseries, pynucastro_available
        from catsim_core.export.timeline import export_timeseries_csv
    except Exception as e:
        raise

    if not pynucastro_available():
        summary["skipped"] = True
        summary["skip_reason"] = "pynucastro not available"
        (out / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True))
        (out / "STATUS.md").write_text("# pynucastro demo\n\n- status: SKIP\n")
        return 0

    if args.phi_profile_csv:
        t_s, tau_ent_s, lambda_s_inv = _load_phi_profile(Path(args.phi_profile_csv))
    else:
        t_s = np.arange(int(args.n), dtype=float) * float(args.dt_s)
        lambda_s_inv = np.zeros_like(t_s)
        tau_ent_s = np.zeros_like(t_s)

    probe = NuclearRateProbe(rate_name=str(args.rate_name), T9=float(args.T9), rho=float(args.rho))
    ts = build_pynucastro_timeseries(
        probe=probe,
        t_s=t_s,
        tau_ent_s=tau_ent_s,
        lambda_s_inv=lambda_s_inv,
    )
    export_timeseries_csv(ts, out / "timeseries.csv")
    (out / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True))
    (out / "STATUS.md").write_text("# pynucastro demo\n\n- status: OK\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
