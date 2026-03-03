"""Lightweight fitting utilities (numpy-only).

We avoid SciPy on purpose to keep the bundle runnable everywhere.

Strategy:
- Assume geometry may be known; fit only (scale, offset, visibility0, rate).
- Rate is searched over a grid; for each candidate rate, solve linear least squares for scale/offset.

This is sufficient to compare:
  - standard mode best-fit gamma
  - entropic mode best-fit lambda_ent

If you want full multi-parameter nonlinear fits later, this module is the right place to extend.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal, Optional, Tuple

import numpy as np

from .models import double_slit_intensity, Mode


@dataclass(frozen=True)
class FitResult:
    mode: Mode
    rate_name: str
    rate_value: float
    visibility0: float
    scale: float
    offset: float
    sse: float
    predicted_visibility: Optional[float] = None


def _linear_fit(a: np.ndarray, y: np.ndarray) -> Tuple[float, float]:
    """Fit y ~ s*a + b (least squares)."""
    A = np.column_stack([a, np.ones_like(a)])
    (s, b), *_ = np.linalg.lstsq(A, y, rcond=None)
    return float(s), float(b)


def fit_rate_grid(
    x_m: np.ndarray,
    y: np.ndarray,
    wavelength_m: float,
    slit_sep_m: float,
    slit_width_m: float,
    screen_dist_m: float,
    mode: Mode,
    visibility0: float = 1.0,
    flight_time_s: Optional[float] = None,
    rate_grid: Optional[np.ndarray] = None,
    *,
    fit_affine: bool = True,
) -> FitResult:
    """Grid-fit the decoherence rate (gamma or lambda_ent), returning best SSE."""

    x = np.asarray(x_m, dtype=float)
    y = np.asarray(y, dtype=float)

    if rate_grid is None:
        # conservative default grid spanning from 0 to 1e6 1/s (adjust as needed)
        rate_grid = np.concatenate([
            np.linspace(0.0, 1e3, 200),
            np.linspace(1e3, 1e6, 200)
        ])

    best: Optional[FitResult] = None

    for r in rate_grid:
        if mode == "standard":
            I_model, V = double_slit_intensity(
                x_m=x,
                wavelength_m=wavelength_m,
                slit_sep_m=slit_sep_m,
                slit_width_m=slit_width_m,
                screen_dist_m=screen_dist_m,
                visibility0=visibility0,
                mode=mode,
                flight_time_s=flight_time_s,
                gamma_s_inv=float(r),
                lambda_ent_s_inv=0.0,
            )
            rate_name = "gamma_s_inv"
        else:
            I_model, V = double_slit_intensity(
                x_m=x,
                wavelength_m=wavelength_m,
                slit_sep_m=slit_sep_m,
                slit_width_m=slit_width_m,
                screen_dist_m=screen_dist_m,
                visibility0=visibility0,
                mode=mode,
                flight_time_s=flight_time_s,
                gamma_s_inv=0.0,
                lambda_ent_s_inv=float(r),
            )
            rate_name = "lambda_ent_s_inv"

        if fit_affine:
            s, b = _linear_fit(I_model, y)
            resid = y - (s * I_model + b)
        else:
            s, b = 1.0, 0.0
            resid = y - I_model
        sse = float(np.sum(resid**2))

        fr = FitResult(
            mode=mode,
            rate_name=rate_name,
            rate_value=float(r),
            visibility0=float(visibility0),
            scale=float(s),
            offset=float(b),
            sse=sse,
        )

        if best is None or fr.sse < best.sse:
            best = fr

    assert best is not None
    return best


def fit_rate_grid_temporal(
    f_hz: np.ndarray,
    y: np.ndarray,
    *,
    separation_s: float,
    slit_rise_s: float,
    visibility0: float = 1.0,
    mode: str = "standard",
    rate_grid: np.ndarray | None = None,
    fit_affine: bool = False,
    lambda0_s_inv: float = 1.0e15,
) -> FitResult:
    """Fit rate for a temporal double-slit spectrum.

    This uses the analytic model from `temporal_double_slit_spectrum` and fits:
      y ≈ scale * I(f; rate) + offset
    for each candidate `rate` in `rate_grid`.

    The returned FitResult stores the best candidate.
    """
    from .models import temporal_double_slit_spectrum

    if rate_grid is None:
        rate_grid = np.linspace(0.0, 1e4, 200)

    # Clean inputs
    f_hz = np.asarray(f_hz, dtype=float)
    y = np.asarray(y, dtype=float)

    best: FitResult | None = None

    for r in rate_grid:
        if mode == "standard":
            I, V = temporal_double_slit_spectrum(
                f_hz=f_hz,
                separation_s=separation_s,
                slit_rise_s=slit_rise_s,
                visibility0=visibility0,
                mode="standard",
                gamma_s_inv=float(r),
            )
        elif mode == "entropic":
            I, V = temporal_double_slit_spectrum(
                f_hz=f_hz,
                separation_s=separation_s,
                slit_rise_s=slit_rise_s,
                visibility0=visibility0,
                mode="entropic",
                lambda_ent_s_inv=float(r),
                lambda0_s_inv=float(lambda0_s_inv),
            )
        else:
            raise ValueError(f"Unknown mode: {mode}")

        if fit_affine:
            # Allows matching arbitrary amplitude/offset but makes the rate 
            # partially degenerate with overall scaling for temporal spectra.
            A = np.vstack([I, np.ones_like(I)]).T
            scale, offset = np.linalg.lstsq(A, y, rcond=None)[0]
            resid = y - (scale * I + offset)
            sse = float(np.sum(resid**2))
        else:
            # For temporal spectra, the decoherence rate is only identifiable if
            # intensity is already normalized to the model range. We therefore
            # default to comparing directly (scale=1, offset=0).
            scale, offset = 1.0, 0.0
            resid = y - I
            sse = float(np.sum(resid**2))

        rate_name = "gamma_s_inv" if mode == "standard" else "lambda_ent_s_inv"
        cand = FitResult(
            mode=mode,
            rate_name=rate_name,
            rate_value=float(r),
            visibility0=float(visibility0),
            scale=float(scale),
            offset=float(offset),
            sse=float(sse),
            predicted_visibility=float(V),
        )
        if best is None or cand.sse < best.sse:
            best = cand

    assert best is not None
    return best
