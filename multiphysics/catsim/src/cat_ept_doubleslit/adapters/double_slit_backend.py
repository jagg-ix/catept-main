"""CAT/EPT backend adapter for the temporal double-slit (Tirole) harness.

This module is the *single* place where the UI/runner should obtain CAT/EPT-based
predictions and fitted parameters for the temporal double-slit dataset.

Design goals:
- Keep UI runners thin: they pass measured spectra (f, intensity) and receive
  predictions + fitted parameters.
- Use existing package modules (models/fit/observables). Do not re-implement
  CAT/EPT math in the UI layer.
"""

from __future__ import annotations

from dataclasses import asdict
from typing import Any, Dict, Optional

import numpy as np

from ..observables import extract_fringe_spacing_THz
from ..fit import fit_rate_grid_temporal
from ..models import temporal_double_slit_spectrum

def _estimate_separation_s_from_spectrum(f_thz: np.ndarray, intensity: np.ndarray) -> float:
    """Estimate time-slit separation Δt from fringe spacing.

    For cos(2π f Δt), the fringe spacing in frequency is Δf = 1/Δt.
    """
    f_thz = np.asarray(f_thz, dtype=float)
    y = np.asarray(intensity, dtype=float)
    # Use a broad band for initial estimate
    band = float(max(0.5, (f_thz.max() - f_thz.min()) * 0.8))
    spacing_thz = float(extract_fringe_spacing_THz(f_thz, y, band_THz=band))
    spacing_hz = spacing_thz * 1e12
    if spacing_hz <= 0:
        raise ValueError("Could not estimate fringe spacing (non-positive)")
    return 1.0 / spacing_hz

def _estimate_slit_rise_s(f_thz: np.ndarray, intensity: np.ndarray) -> float:
    """Crude envelope-width estimate for Gaussian slit rise time σ.

    Model envelope: exp(-(σ^2)(2π f)^2). We estimate f_half where envelope~1/2.
    This is a heuristic; users should override with known apparatus settings when available.
    """
    f = np.asarray(f_thz, dtype=float) * 1e12
    y = np.asarray(intensity, dtype=float)
    # Normalize and smooth-ish by sorting
    idx = np.argsort(f)
    f = f[idx]; y = y[idx]
    y = y - np.min(y)
    if np.max(y) > 0:
        y = y / np.max(y)
    # Find frequency where y drops below 0.5 on high-frequency side
    mid = np.argmax(y)
    tail = y[mid:]
    ftail = f[mid:]
    j = np.where(tail <= 0.5)[0]
    if len(j) == 0:
        # fallback: use max frequency
        f_half = float(ftail[-1])
    else:
        f_half = float(ftail[j[0]])
    if f_half <= 0:
        f_half = float(np.median(f[f>0]))
    # σ = sqrt(ln2) / (2π f_half)
    return float(np.sqrt(np.log(2.0)) / (2.0*np.pi*f_half))

def compute_double_slit_observables(
    *,
    f_thz: np.ndarray,
    intensity: np.ndarray,
    separation_s: Optional[float] = None,
    slit_rise_s: Optional[float] = None,
    visibility0: float = 1.0,
    lambda0_s_inv: float = 1.0e15,
    rate_grid: Optional[np.ndarray] = None,
    fit_affine: bool = True,
) -> Dict[str, Any]:
    """Compute CAT/EPT (entropic mode) prediction + best-fit rate for a spectrum.

    Returns a JSON-serializable dict with:
    - inferred/used separation_s, slit_rise_s
    - fit result (best_rate, scale/offset if affine)
    - predicted spectrum and visibility used
    """
    f_thz = np.asarray(f_thz, dtype=float)
    y = np.asarray(intensity, dtype=float)

    sep = float(separation_s) if separation_s is not None else _estimate_separation_s_from_spectrum(f_thz, y)
    sig = float(slit_rise_s) if slit_rise_s is not None else _estimate_slit_rise_s(f_thz, y)

    f_hz = f_thz * 1e12

    fit = fit_rate_grid_temporal(
        f_hz=f_hz,
        y=y,
        separation_s=sep,
        slit_rise_s=sig,
        visibility0=float(visibility0),
        mode="entropic",
        rate_grid=rate_grid,
        fit_affine=bool(fit_affine),
        lambda0_s_inv=float(lambda0_s_inv),
    )

    # Build predicted spectrum with best-fit rate (entropic mode)
    I_pred, V_eff = temporal_double_slit_spectrum(
        f_hz=f_hz,
        separation_s=sep,
        slit_rise_s=sig,
        visibility0=float(visibility0),
        mode="entropic",
        lambda_ent_s_inv=float(fit.best_rate),
        lambda0_s_inv=float(lambda0_s_inv),
    )

    # Apply affine fit if used in the fit
    if fit_affine:
        I_pred_aff = fit.scale * I_pred + fit.offset
    else:
        I_pred_aff = I_pred

    resid = y - I_pred_aff

    return {
        "mode": "entropic",
        "inputs": {
            "separation_s": sep,
            "slit_rise_s": sig,
            "visibility0": float(visibility0),
            "lambda0_s_inv": float(lambda0_s_inv),
            "fit_affine": bool(fit_affine),
        },
        "fit": {
            "best_rate": float(fit.best_rate),
            "rate_name": str(fit.rate_name),
            "rmse": float(fit.rmse),
            "scale": float(fit.scale),
            "offset": float(fit.offset),
            "V_effective_fit": float(fit.V_effective),
        },
        "pred": {
            "V_effective_model": float(V_eff),
        },
        "arrays": {
            "f_thz": f_thz.tolist(),
            "intensity_pred": I_pred_aff.tolist(),
            "residual": resid.tolist(),
        }
    }
