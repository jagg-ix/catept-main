"""CFL-style step control when evolving in entropic proper time.

We use an entropic clock ``tau`` defined by ``d tau / d t = lambda``.
Reparameterizing does not remove CFL constraints; it changes how you choose
steps: enforce CFL in coordinate time ``t``, then map to ``Delta tau``.

This module provides small utilities to do that consistently.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

import numpy as np


def cfl_dt_bound(dx: float, a_max: float, cfl_max: float = 0.9, eps: float = 1e-30) -> float:
    """Coordinate-time CFL bound for explicit hyperbolic updates.

    Args:
        dx: Spatial grid scale.
        a_max: Maximum characteristic speed.
        cfl_max: Maximum allowed Courant number (scheme-dependent; 0.9 is conservative).
        eps: Protect against divide-by-zero.

    Returns:
        Upper bound on dt.
    """
    if dx <= 0:
        raise ValueError("dx must be > 0")
    a = max(float(a_max), eps)
    return float(cfl_max) * float(dx) / a


def dissipation_dt_bound(lambda_max: float, alpha_scheme: float = 1.0, eps: float = 1e-30) -> float:
    """Coordinate-time bound for a linear decay mode u'=-lambda u.

    This is integrator-dependent. For example:
      - Explicit Euler is stable for 0 <= dt*lambda <= 2.

    Args:
        lambda_max: Maximum dissipation rate.
        alpha_scheme: Method stability radius along negative real axis (conservative default=1).
        eps: Protect against divide-by-zero.

    Returns:
        Upper bound on dt.
    """
    lam = max(float(lambda_max), eps)
    return float(alpha_scheme) / lam


def dtau_from_dt(dt: float, lambda_eff: float) -> float:
    """Convert coordinate-time step dt to entropic-time step d_tau."""
    return float(dt) * float(lambda_eff)


def dt_from_dtau(dtau: float, lambda_eff: float, eps: float = 1e-30) -> float:
    """Convert entropic-time step d_tau to coordinate-time step dt."""
    lam = max(float(lambda_eff), eps)
    return float(dtau) / lam


@dataclass(frozen=True)
class CFLClock:
    """Step controller for tau-evolution with coordinate-time CFL guards.

    This object is meant to be reusable across:
    - explicit PDE solvers (dx and a_max are known)
    - i-PI socket drivers (dx/a_max may be unknown; then only the dissipation
      guard is available)
    """

    # Spatial scale (optional in MD-style workflows)
    dx: Optional[float] = None
    # Default characteristic speed (optional)
    a_max_default: Optional[float] = None
    # Bounds
    cfl_max: float = 0.9
    alpha_scheme: float = 1.0
    eps: float = 1e-30

    def suggest_dt(
        self,
        *,
        a_max: Optional[float] = None,
        lambda_max: Optional[float] = None,
    ) -> Optional[float]:
        """Suggest a stable coordinate-time step.

        Args:
            a_max: Maximum characteristic speed.
            lambda_max: Optional maximum dissipation rate for an additional stability guard.

        Returns:
            dt <= min(dt_cfl, dt_lambda).
        """
        # CFL guard (needs dx + a_max)
        dx = self.dx
        a = a_max if a_max is not None else self.a_max_default
        dt_candidates = []
        if dx is not None and a is not None:
            dt_candidates.append(cfl_dt_bound(dx, a, self.cfl_max, self.eps))

        # Dissipation guard (always available if lambda_max is provided)
        if lambda_max is not None:
            dt_candidates.append(dissipation_dt_bound(lambda_max, self.alpha_scheme, self.eps))

        if not dt_candidates:
            return None
        return min(dt_candidates)

    def courant_number(self, dt: float, *, a_max: Optional[float] = None) -> float:
        """Compute Courant number C = a*dt/dx if dx and a are known.

        If dx or a are unknown, returns NaN.
        """
        dx = self.dx
        a = a_max if a_max is not None else self.a_max_default
        if dx is None or a is None:
            return float("nan")
        return float(a) * float(dt) / float(dx)

    def suggest_dtau(
        self,
        *,
        a_max: Optional[float] = None,
        lambda_eff: float,
        lambda_max: Optional[float] = None,
    ) -> Optional[float]:
        """Suggest a stable entropic-time step.

        The controller chooses dt in coordinate time, then maps to d_tau.

        Args:
            a_max: Maximum characteristic speed.
            lambda_eff: Effective local lambda for the step (e.g., min/avg over grid).
            lambda_max: Optional maximum dissipation rate.

        Returns:
            d_tau = lambda_eff * dt.
        """
        dt = self.suggest_dt(a_max=a_max, lambda_max=lambda_max)
        if dt is None:
            return None
        return dtau_from_dt(dt, lambda_eff)


def lambda_effective(lam: np.ndarray, mode: str = "min") -> float:
    """Compute an effective scalar lambda from a field.

    Args:
        lam: Array of lambda values.
        mode: "min" (most conservative), "mean", or "max".

    Returns:
        Scalar effective lambda.
    """
    if lam.size == 0:
        return 0.0
    if mode == "min":
        return float(np.min(lam))
    if mode == "mean":
        return float(np.mean(lam))
    if mode == "max":
        return float(np.max(lam))
    raise ValueError("mode must be one of: min, mean, max")
