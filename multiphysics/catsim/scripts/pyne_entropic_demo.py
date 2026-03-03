"""Optional PyNE demo wired to CAT/EPT time contract.

This demo is deterministic and runs even without the PyNE dependency; if PyNE
is installed it simply marks it as available in summary.json.

It exports a decay-only TimeSeriesContract with (t, tau_ent, lambda) columns so
other modules (metrics, QuTiP, tensor exports) can consume it.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np


def _ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def _load_phi_profile(path: Path) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    import pandas as pd
    df = pd.read_csv(path)
    if "tau_ent_s" in df.columns:
        tau = df["tau_ent_s"].to_numpy(dtype=float)
        t = tau.copy()
        lam = np.ones_like(tau)
        return t, tau, lam
    if "t_s" in df.columns:
        t = df["t_s"].to_numpy(dtype=float)
        phi = df["phi"].to_numpy(dtype=float)
        dphi = np.gradient(phi, t, edge_order=1)
        lam = np.maximum(dphi, 0.0)
        tau = np.cumsum(lam * np.gradient(t, edge_order=1))
        return t, tau, lam
    raise ValueError("phi_profile missing coordinate column")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--nuclide", default="ni56")
    ap.add_argument("--half_life_s", type=float, default=6.075 * 24 * 3600.0)  # Ni-56 ~6.075 d
    ap.add_argument("--phi_profile_csv")
    ap.add_argument("--n", type=int, default=200)
    ap.add_argument("--dt_s", type=float, default=3600.0)
    args = ap.parse_args()

    out = Path(args.out)
    _ensure_dir(out)

    from catsim_core.pyne.adapter import DecayProbe, build_pyne_decay_timeseries, pyne_available
    from catsim_core.export.timeline import export_timeseries_csv

    if args.phi_profile_csv:
        t_s, tau_ent_s, lambda_s_inv = _load_phi_profile(Path(args.phi_profile_csv))
    else:
        t_s = np.arange(int(args.n), dtype=float) * float(args.dt_s)
        lambda_s_inv = np.zeros_like(t_s)
        tau_ent_s = np.zeros_like(t_s)

    probe = DecayProbe(nuclide=str(args.nuclide), half_life_s=float(args.half_life_s))
    ts = build_pyne_decay_timeseries(
        probe=probe,
        t_s=t_s,
        tau_ent_s=tau_ent_s,
        lambda_s_inv=lambda_s_inv,
    )
    export_timeseries_csv(ts, out / "timeseries.csv")

    summary = {
        "nuclide": str(args.nuclide),
        "half_life_s": float(args.half_life_s),
        "pyne_available": bool(pyne_available()),
    }
    (out / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True))
    (out / "STATUS.md").write_text("# pyne demo\n\n- status: OK\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
