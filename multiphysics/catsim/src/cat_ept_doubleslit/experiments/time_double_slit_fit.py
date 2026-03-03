from __future__ import annotations

"""Lightweight fitting utilities for the *time double-slit* spectrum model.

This module intentionally avoids SciPy so the repo remains easy to run in minimal
environments. The fit routine is therefore a pragmatic, robust coordinate-search.

Use-case:
  - Fit a simple phase evolution model (e.g. polynomial chirp) to an observed
    spectrum asymmetry.
  - Keep CAT/EPT toggles explicit, so you can run the same fit with
    ``use_cat_ept=False`` and ``use_cat_ept=True``.
"""

from dataclasses import dataclass
from typing import Callable, Dict, Optional, Tuple

import numpy as np

from .time_double_slit import TimeDoubleSlitConfig, bandpass_normalize, phase_poly, simulate_time_double_slit


def _interp_to(x_src: np.ndarray, y_src: np.ndarray, x_tgt: np.ndarray) -> np.ndarray:
    """1D linear interpolation with safe edge fill."""
    return np.interp(x_tgt, x_src, y_src, left=float(y_src[0]), right=float(y_src[-1]))


def spectrum_loss_l2(f_obs_hz: np.ndarray, I_obs: np.ndarray, f_sim_hz: np.ndarray, I_sim: np.ndarray) -> float:
    """Compute a simple L2 loss on normalized intensity over the observed grid."""
    I_sim_i = _interp_to(f_sim_hz, I_sim, f_obs_hz)
    d = I_sim_i - I_obs
    return float(np.mean(d * d))


@dataclass
class PhasePolyParams:
    """Parameters for :func:`phase_poly`.

    Units:
      - phi0: rad
      - phi1: rad/s
      - phi2: rad/s^2
    """

    phi0: float = 0.0
    phi1_rad_per_s: float = 0.0
    phi2_rad_per_s2: float = 0.0

    def to_phase_fn(self) -> Callable[[np.ndarray], np.ndarray]:
        return lambda t_s: phase_poly(t_s, self.phi0, self.phi1_rad_per_s, self.phi2_rad_per_s2)


@dataclass
class FitResult:
    best_params: PhasePolyParams
    best_loss: float
    history: Tuple[Tuple[PhasePolyParams, float], ...]


def fit_phase_poly_to_spectrum(
    f_obs_hz: np.ndarray,
    I_obs: np.ndarray,
    base_cfg: TimeDoubleSlitConfig,
    band_half_width_hz: float = 15e12,
    init: Optional[PhasePolyParams] = None,
    step0: Optional[PhasePolyParams] = None,
    n_rounds: int = 25,
) -> FitResult:
    """Fit a minimal chirp phase model to an observed spectrum.

    Strategy: greedy coordinate-search with geometric step decay.
    This is robust for 3 parameters and avoids external deps.
    """

    f_obs_hz = np.asarray(f_obs_hz, dtype=float)
    I_obs = np.asarray(I_obs, dtype=float)
    # normalize observed in-band
    f0 = float(base_cfg.f0_hz)
    f_obs_b, I_obs_b = bandpass_normalize(f_obs_hz, I_obs, f0, band_half_width_hz)

    p = init or PhasePolyParams(0.0, 0.0, 0.0)
    # default step sizes: small-ish but meaningful
    s = step0 or PhasePolyParams(phi0=0.2, phi1_rad_per_s=2.0 * np.pi * 0.25e12, phi2_rad_per_s2=2.0 * np.pi * 0.10e24)

    def eval_loss(params: PhasePolyParams) -> float:
        cfg = TimeDoubleSlitConfig(**{**base_cfg.__dict__})
        cfg.phase_fn = params.to_phase_fn()
        sim = simulate_time_double_slit(cfg)
        f_sim_b, I_sim_b = bandpass_normalize(sim["freq_hz"], sim["intensity"], f0, band_half_width_hz)
        return spectrum_loss_l2(f_obs_b, I_obs_b, f_sim_b, I_sim_b)

    best = PhasePolyParams(p.phi0, p.phi1_rad_per_s, p.phi2_rad_per_s2)
    best_loss = eval_loss(best)
    hist = [(PhasePolyParams(best.phi0, best.phi1_rad_per_s, best.phi2_rad_per_s2), best_loss)]

    # coordinate-search with step shrink
    for r in range(int(n_rounds)):
        improved = False
        for key in ("phi0", "phi1_rad_per_s", "phi2_rad_per_s2"):
            step_val = getattr(s, key)
            for sign in (+1.0, -1.0):
                cand = PhasePolyParams(best.phi0, best.phi1_rad_per_s, best.phi2_rad_per_s2)
                setattr(cand, key, getattr(cand, key) + sign * step_val)
                loss = eval_loss(cand)
                hist.append((PhasePolyParams(cand.phi0, cand.phi1_rad_per_s, cand.phi2_rad_per_s2), loss))
                if loss < best_loss:
                    best, best_loss = cand, loss
                    improved = True
        # shrink steps if no improvement; otherwise, shrink gently
        shrink = 0.75 if improved else 0.5
        s = PhasePolyParams(s.phi0 * shrink, s.phi1_rad_per_s * shrink, s.phi2_rad_per_s2 * shrink)
        # stop if steps are tiny
        if abs(s.phi0) < 1e-4 and abs(s.phi1_rad_per_s) < 1e6 and abs(s.phi2_rad_per_s2) < 1e12:
            break

    return FitResult(best_params=best, best_loss=float(best_loss), history=tuple(hist))
