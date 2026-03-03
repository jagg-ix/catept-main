"""Entropic proper time utilities.

We keep this intentionally conservative:
- If lambda_ent is a constant rate (1/s), then tau_ent = lambda_ent * T.
- If you later want a profile lambda_ent(t), extend integrate_lambda.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Optional

import numpy as np


@dataclass(frozen=True)
class LambdaProfile:
    """Optional time-dependent entropic rate profile."""

    fn: Callable[[np.ndarray], np.ndarray]

    def __call__(self, t: np.ndarray) -> np.ndarray:
        vals = np.asarray(self.fn(t), dtype=float)
        if vals.shape != t.shape:
            raise ValueError("LambdaProfile must return same shape as input t")
        return vals


def tau_entropic(T: float, lambda_ent: float, profile: Optional[LambdaProfile] = None, n: int = 4096) -> float:
    """Compute entropic proper time tau_ent.

    Parameters
    ----------
    T:
        Total coordinate time / lab time duration (seconds).
    lambda_ent:
        Constant entropic rate (1/s). Used if profile is None.
    profile:
        Optional time-dependent entropic rate profile.
    n:
        Number of integration points (only used if profile is provided).
    """
    if T < 0:
        raise ValueError("T must be non-negative")

    if profile is None:
        if lambda_ent < 0:
            raise ValueError("lambda_ent must be non-negative")
        return float(lambda_ent * T)

    t = np.linspace(0.0, float(T), int(n), dtype=float)
    lam = profile(t)
    if np.any(lam < 0):
        raise ValueError("lambda_ent(t) must be non-negative")
    return float(np.trapezoid(lam, t))


def lambda0_from_cfl_time_step(
    dt_s: float,
    *,
    safety: float = 0.95,
) -> float:
    """Reference rate \lambda_0 inferred from a CFL-style time-step constraint.

    In the repo we use \lambda_0 as the scale that controls how strongly the
    CAT/EPT entropic rate reparameterizes the *phase* accumulation:

        g(\lambda) = 1 / (1 + \lambda/\lambda_0).

    If a solver must obey a stability/sampling constraint dt <= dt_max,
    a conservative associated rate scale is \lambda_0 ~ 1/dt_max.

    Parameters
    ----------
    dt_s:
        The effective stable/accurate time step (seconds).
    safety:
        Multiplier in (0,1] to keep the bound conservative.
    """
    if dt_s <= 0:
        raise ValueError("dt_s must be > 0")
    if not (0 < safety <= 1.0):
        raise ValueError("safety must be in (0,1]")
    return float(safety / dt_s)
