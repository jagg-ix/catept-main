#!/usr/bin/env python3
"""Fit the temporal double-slit model to the SQLite time-domain trace.

This script compares:
  (A) standard model (no entropic time damping): lambda = 0
  (B) entropic-time model (damping): lambda is fitted >= 0

It performs a lightweight grid search (numpy-only) and prints a small report.

Example:
  PYTHONPATH=src python scripts/compare_fit_time_domain.py \
    --db data/tirole_double_slit.sqlite3 \
    --experiment 8
"""

from __future__ import annotations

import argparse
import math
from dataclasses import dataclass

import numpy as np

from cat_ept_doubleslit.db import load_time_domain
from cat_ept_doubleslit.models import temporal_double_slit_pattern


@dataclass
class FitResult:
    separation_s: float
    slit_rise_s: float
    visibility: float
    lambda_s: float
    offset: float
    scale: float
    sse: float


def _best_offset_scale(y: np.ndarray, p: np.ndarray) -> tuple[float, float, float]:
    """Solve y ≈ offset + scale * p in least squares; return (offset, scale, sse)."""
    A = np.vstack([np.ones_like(p), p]).T
    # least squares
    (offset, scale), *_ = np.linalg.lstsq(A, y, rcond=None)
    resid = y - (offset + scale * p)
    sse = float(resid @ resid)
    return float(offset), float(scale), sse


def grid_fit(
    t_s: np.ndarray,
    y: np.ndarray,
    *,
    fit_lambda: bool,
    sep_range_fs: tuple[float, float] = (5.0, 80.0),
    rise_range_fs: tuple[float, float] = (0.1, 20.0),
    lambda_range_ps_inv: tuple[float, float] = (0.0, 5.0),
    n_sep: int = 80,
    n_rise: int = 60,
    n_lambda: int = 50,
) -> FitResult:
    # Parameter grids (converted to SI)
    sep_grid = np.linspace(sep_range_fs[0], sep_range_fs[1], n_sep) * 1e-15
    rise_grid = np.linspace(rise_range_fs[0], rise_range_fs[1], n_rise) * 1e-15
    if fit_lambda:
        lambda_grid = np.linspace(lambda_range_ps_inv[0], lambda_range_ps_inv[1], n_lambda) * 1e12
    else:
        lambda_grid = np.array([0.0])

    best: FitResult | None = None

    for sep in sep_grid:
        for rise in rise_grid:
            for lam in lambda_grid:
                # vis0 set to 1 in pattern; we absorb amplitude into scale and allow visibility as separate multiplier
                p0 = temporal_double_slit_pattern(t_s, sep, rise, vis0=1.0, lambda_s=lam)
                # Visibility (0..1) is a multiplicative factor on the modulation; approximate by mixing with mean
                # We model: p = (1 - V) * mean(p0) + V * p0
                mean_p0 = float(np.mean(p0))
                for V in (0.2, 0.35, 0.5, 0.65, 0.8, 0.9, 1.0):
                    p = (1.0 - V) * mean_p0 + V * p0
                    off, sc, sse = _best_offset_scale(y, p)
                    if best is None or sse < best.sse:
                        best = FitResult(
                            separation_s=float(sep),
                            slit_rise_s=float(rise),
                            visibility=float(V),
                            lambda_s=float(lam),
                            offset=float(off),
                            scale=float(sc),
                            sse=float(sse),
                        )

    assert best is not None
    return best


def _fmt_fs(x_s: float) -> str:
    return f"{x_s*1e15:.3g} fs"


def _fmt_lambda(x: float) -> str:
    if x == 0:
        return "0"
    # show in ps^-1
    return f"{x/1e12:.3g} ps^-1"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True)
    ap.add_argument("--experiment", required=True, help="integer id or figure_ref")
    ap.add_argument("--sep-min-fs", type=float, default=5.0)
    ap.add_argument("--sep-max-fs", type=float, default=80.0)
    ap.add_argument("--rise-min-fs", type=float, default=0.1)
    ap.add_argument("--rise-max-fs", type=float, default=20.0)
    ap.add_argument("--lambda-max-psinv", type=float, default=5.0)
    args = ap.parse_args()

    exp = args.experiment
    exp_id = int(exp) if exp.isdigit() else None
    ref = None if exp.isdigit() else exp

    delay_fs, refl = load_time_domain(args.db, experiment_id=exp_id, ref=ref)
    t_s = delay_fs * 1e-15
    y = refl.astype(float)

    # normalize y to zero-mean / unit variance to stabilize (offset + scale will undo)
    y = (y - np.mean(y)) / (np.std(y) + 1e-12)

    common_kwargs = dict(
        sep_range_fs=(args.sep_min_fs, args.sep_max_fs),
        rise_range_fs=(args.rise_min_fs, args.rise_max_fs),
        lambda_range_ps_inv=(0.0, args.lambda_max_psinv),
    )

    std = grid_fit(t_s, y, fit_lambda=False, **common_kwargs)
    ent = grid_fit(t_s, y, fit_lambda=True, **common_kwargs)

    # AIC comparison (Gaussian errors, unknown sigma): AIC = n*log(SSE/n) + 2k
    n = len(y)
    def aic(sse: float, k: int) -> float:
        return n * math.log(sse / n) + 2 * k

    aic_std = aic(std.sse, k=5)  # sep,rise,V,offset,scale
    aic_ent = aic(ent.sse, k=6)  # + lambda

    print("== Time-domain fit (standard vs entropic) ==")
    print(f"Samples: {n}")
    print("\nStandard (lambda fixed 0):")
    print(f"  separation: {_fmt_fs(std.separation_s)}")
    print(f"  slit rise : {_fmt_fs(std.slit_rise_s)}")
    print(f"  visibility: {std.visibility:.2f}")
    print(f"  SSE      : {std.sse:.4g}   AIC: {aic_std:.3g}")

    print("\nEntropic (lambda fitted >=0):")
    print(f"  separation: {_fmt_fs(ent.separation_s)}")
    print(f"  slit rise : {_fmt_fs(ent.slit_rise_s)}")
    print(f"  visibility: {ent.visibility:.2f}")
    print(f"  lambda   : {_fmt_lambda(ent.lambda_s)}")
    print(f"  SSE      : {ent.sse:.4g}   AIC: {aic_ent:.3g}")

    delta = aic_std - aic_ent
    print("\nModel preference (lower AIC is better):")
    if delta > 10:
        print(f"  Strong support for entropic model (ΔAIC ≈ {delta:.2f}).")
    elif delta > 2:
        print(f"  Moderate support for entropic model (ΔAIC ≈ {delta:.2f}).")
    elif delta < -2:
        print(f"  Standard model preferred (ΔAIC ≈ {delta:.2f}).")
    else:
        print(f"  Inconclusive (ΔAIC ≈ {delta:.2f}).")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
