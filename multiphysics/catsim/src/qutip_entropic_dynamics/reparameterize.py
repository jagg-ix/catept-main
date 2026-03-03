"""Coordinate time <-> entropic proper time transforms.

Provides the mapping between laboratory time *t* and entropic proper
time *tau_ent* defined by:

    d(tau_ent) = lambda(t) dt
    tau_ent(t) = integral_0^t lambda(t') dt'

where lambda(t) is the entropy production rate.

Source
------
Best of ``entropic_time.py`` (LambdaProfile, tau_entropic, CFL) and
``qutip_backend.py:reparameterize_t_to_tau`` (trapezoid integration).
"""

from __future__ import annotations

from typing import Callable, Optional

import numpy as np


class LambdaProfile:
    """Time-dependent entropic rate profile.

    Wraps a callable ``fn(t) -> lambda(t)`` with shape validation.

    Parameters
    ----------
    fn : callable
        Function mapping time array to rate array.  Must return the same
        shape as its input.

    Examples
    --------
    >>> profile = LambdaProfile(lambda t: 1e3 * np.ones_like(t))
    >>> profile(np.array([0.0, 1.0]))
    array([1000., 1000.])
    """

    def __init__(self, fn: Callable[[np.ndarray], np.ndarray]):
        self._fn = fn

    def __call__(self, t: np.ndarray) -> np.ndarray:
        t = np.asarray(t, dtype=float)
        vals = np.asarray(self._fn(t), dtype=float)
        if vals.shape != t.shape:
            raise ValueError(
                f"LambdaProfile must return same shape as input t "
                f"(got {vals.shape} vs {t.shape})"
            )
        return vals

    def __repr__(self) -> str:
        return f"LambdaProfile({self._fn!r})"


def tau_from_lambda(
    tlist: np.ndarray,
    lambda_values: np.ndarray,
) -> np.ndarray:
    """Compute tau_ent(t) by trapezoid integration.

    Parameters
    ----------
    tlist : ndarray, shape (N,)
        Coordinate time array (seconds).
    lambda_values : ndarray, shape (N,)
        Entropy production rate at each time step (1/s).

    Returns
    -------
    tau : ndarray, shape (N,)
        Entropic proper time, starting from zero.

    Raises
    ------
    ValueError
        If shapes do not match.

    Examples
    --------
    >>> t = np.linspace(0, 1, 100)
    >>> lam = 2.0 * np.ones_like(t)  # constant rate
    >>> tau = tau_from_lambda(t, lam)
    >>> np.isclose(tau[-1], 2.0)
    True
    """
    t = np.asarray(tlist, dtype=float)
    lam = np.asarray(lambda_values, dtype=float)
    if t.shape != lam.shape:
        raise ValueError(
            f"tlist and lambda_values must have the same shape "
            f"(got {t.shape} vs {lam.shape})"
        )
    tau = np.empty_like(t)
    tau[0] = 0.0
    for i in range(1, len(t)):
        dt = t[i] - t[i - 1]
        tau[i] = tau[i - 1] + 0.5 * (lam[i] + lam[i - 1]) * dt
    return tau


def tau_entropic(
    T: float,
    lambda_ent: float,
    profile: Optional[LambdaProfile] = None,
    n: int = 4096,
) -> float:
    """Compute total entropic proper time for a duration *T*.

    Parameters
    ----------
    T : float
        Total coordinate time (seconds).  Must be non-negative.
    lambda_ent : float
        Constant entropic rate (1/s).  Used when *profile* is ``None``.
    profile : LambdaProfile, optional
        Time-dependent rate.  If given, *lambda_ent* is ignored and
        the profile is numerically integrated over ``[0, T]``.
    n : int, optional
        Number of integration quadrature points (default 4096).

    Returns
    -------
    tau : float
        Total entropic proper time (seconds).

    Raises
    ------
    ValueError
        If *T* < 0 or rates are negative.

    Examples
    --------
    >>> tau_entropic(1.0, 5.0)
    5.0
    >>> profile = LambdaProfile(lambda t: 2 * t)
    >>> np.isclose(tau_entropic(1.0, 0.0, profile=profile), 1.0)
    True
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
        raise ValueError("lambda_ent(t) must be non-negative everywhere")
    return float(np.trapezoid(lam, t))


def lambda0_from_cfl(dt_s: float, safety: float = 0.95) -> float:
    """Reference rate lambda_0 from a CFL-style time-step constraint.

    The CAT/EPT phase reparameterization uses:

        g(lambda) = 1 / (1 + lambda / lambda_0)

    If the solver stability constraint is ``dt <= dt_max``, a conservative
    reference scale is ``lambda_0 ~ safety / dt_max``.

    Parameters
    ----------
    dt_s : float
        Effective stable time step (seconds).
    safety : float, optional
        Multiplier in ``(0, 1]``, default 0.95.

    Returns
    -------
    lambda0 : float
        Reference rate (1/s).

    Examples
    --------
    >>> lambda0_from_cfl(1e-15)  # femtosecond time step
    9.5e+14
    """
    if dt_s <= 0:
        raise ValueError("dt_s must be > 0")
    if not (0 < safety <= 1.0):
        raise ValueError("safety must be in (0, 1]")
    return float(safety / dt_s)
