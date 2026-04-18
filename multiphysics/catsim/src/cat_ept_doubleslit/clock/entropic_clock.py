"""Entropic proper time utilities.

This module provides a *software* abstraction for switching from coordinate/parametric
time ``t`` (seconds) to entropic proper time ``tau_ent``.

Core definition (as used throughout the user's papers):

    tau_ent(t) = \int_0^t lambda(s) ds,   with lambda >= 0.

Numerically, we treat ``lambda`` as either:
  - a user supplied scalar function of (t, state), or
  - a value returned by an open-system backend (e.g., GKLS / OQuPy).

IMPORTANT NUMERICS NOTE:
  Reparameterizing time does *not* remove CFL-like stability constraints for explicit
  hyperbolic solvers. It changes how the step is *chosen* (adaptive stepping), but the
  causality/stability constraints still apply in coordinate time.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Optional, Protocol, Tuple

import numpy as np


class LambdaFn(Protocol):
    def __call__(self, t_s: float, state: object | None = None) -> float:  # pragma: no cover
        ...


@dataclass(frozen=True)
class EntropicClock:
    """Tracks (t, tau_ent) consistently.

    Parameters
    ----------
    lambda_fn:
        Dissipation / entropy-production rate lambda(t, state) in 1/s.
    lambda_floor:
        Minimum lambda used for numeric safety when converting dtau->dt.
        (Physically, lambda can be 0 in the unitary limit; numerically, this
         floor only applies *when a conversion is requested*.)
    """

    lambda_fn: LambdaFn
    lambda_floor: float = 0.0

    def lambda_at(self, t_s: float, state: object | None = None) -> float:
        lam = float(self.lambda_fn(t_s, state))
        if lam < 0:
            raise ValueError(f"lambda must be >= 0, got {lam}")
        return lam

    def dtau_from_dt(self, t_s: float, dt_s: float, state: object | None = None) -> float:
        """Compute d(tau_ent) from dt using lambda(t, state)."""
        lam = self.lambda_at(t_s, state)
        return lam * float(dt_s)

    def dt_from_dtau(self, t_s: float, dtau: float, state: object | None = None) -> float:
        """Compute dt from d(tau_ent). If lambda=0, uses lambda_floor."""
        lam = self.lambda_at(t_s, state)
        lam_eff = max(lam, float(self.lambda_floor))
        if lam_eff <= 0:
            raise ValueError("Cannot convert dtau->dt with lambda=0 and lambda_floor=0")
        return float(dtau) / lam_eff


def integrate_tau(
    t_grid_s: np.ndarray,
    lambda_values: np.ndarray,
    tau0: float = 0.0,
) -> np.ndarray:
    """Cumulative trapezoid integration for tau_ent(t).

    This is a helper for backends that return lambda(t) samples.
    """
    t_grid_s = np.asarray(t_grid_s, dtype=float)
    lam = np.asarray(lambda_values, dtype=float)
    if t_grid_s.ndim != 1 or lam.ndim != 1 or t_grid_s.shape != lam.shape:
        raise ValueError("t_grid_s and lambda_values must be 1D arrays with the same shape")
    if np.any(lam < 0):
        raise ValueError("lambda_values must be >= 0")
    tau = np.empty_like(t_grid_s)
    tau[0] = float(tau0)
    for i in range(1, len(t_grid_s)):
        dt = t_grid_s[i] - t_grid_s[i - 1]
        tau[i] = tau[i - 1] + 0.5 * (lam[i] + lam[i - 1]) * dt
    return tau
