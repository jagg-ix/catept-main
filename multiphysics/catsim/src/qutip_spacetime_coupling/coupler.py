"""Spacetime coupler: maps curvature to effective lambda(t).

The SpacetimeCoupler composes gravitational redshift, complex EFE
residual, and base entropy production rate into a single effective
dissipation rate:

    lambda_eff(t) = lambda_base(t) * a(t) * (1 + g * r(t))

where ``a(t) = sqrt(-g00)`` is the redshift factor and ``r(t)`` is
the EFE residual norm.

Source
------
Consolidated from ``catsim_core/spacetime/coupler.py``.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, Optional, Sequence

import numpy as np


@dataclass(frozen=True)
class SpacetimeCoupler:
    """Scalar coupling functions derived from a spacetime model.

    Parameters
    ----------
    lambda_base : callable
        Base entropy production rate ``lambda(t)`` (1/s).
    redshift_fn : callable, optional
        Redshift factor ``a(t) = sqrt(-g00(t))``.  Identity if ``None``.
    efe_residual_fn : callable, optional
        Complex EFE residual norm ``r(t)`` for gating.
    efe_gain : float
        Scaling for residual modulation (default 0).

    Examples
    --------
    >>> coupler = SpacetimeCoupler(lambda_base=lambda t: 1e3)
    >>> coupler.lambda_eff(0.0)
    1000.0
    """

    lambda_base: Callable[[float], float]
    redshift_fn: Optional[Callable[[float], float]] = None
    efe_residual_fn: Optional[Callable[[float], float]] = None
    efe_gain: float = 0.0

    def redshift_factor(self, t_s: float) -> float:
        """Gravitational redshift factor at time *t*."""
        if self.redshift_fn is None:
            return 1.0
        return float(self.redshift_fn(float(t_s)))

    def efe_residual_norm(self, t_s: float) -> float:
        """Complex EFE residual norm at time *t*."""
        if self.efe_residual_fn is None:
            return 0.0
        return float(self.efe_residual_fn(float(t_s)))

    def lambda_eff(self, t_s: float) -> float:
        """Effective entropy production rate.

        Composition:
            lambda_eff(t) = lambda_base(t) * a(t) * (1 + efe_gain * r(t))

        Parameters
        ----------
        t_s : float
            Coordinate time (seconds).

        Returns
        -------
        lam : float
            Effective rate (1/s).
        """
        lam = float(self.lambda_base(float(t_s)))
        a = self.redshift_factor(t_s)
        r = self.efe_residual_norm(t_s)
        mod = 1.0 + float(self.efe_gain) * float(r)
        return float(lam) * float(a) * float(mod)

    def evaluate_on(self, tlist: np.ndarray) -> np.ndarray:
        """Evaluate lambda_eff on a time grid.

        Parameters
        ----------
        tlist : ndarray, shape (N,)
            Time array.

        Returns
        -------
        lam_eff : ndarray, shape (N,)
        """
        return np.array([self.lambda_eff(float(t)) for t in tlist], dtype=float)


def make_identity_coupler(lambda_base: Callable[[float], float]) -> SpacetimeCoupler:
    """Create a coupler with no gravitational corrections.

    Parameters
    ----------
    lambda_base : callable
        Base rate function.

    Returns
    -------
    SpacetimeCoupler
    """
    return SpacetimeCoupler(lambda_base=lambda_base)


def make_schwarzschild_coupler(
    lambda_base: Callable[[float], float],
    M: float,
    r_m: float,
    *,
    efe_gain: float = 0.0,
) -> SpacetimeCoupler:
    """Create a coupler with Schwarzschild redshift.

    Parameters
    ----------
    lambda_base : callable
        Base entropy production rate.
    M : float
        Black hole mass (kg).
    r_m : float
        Radial coordinate (m).
    efe_gain : float
        EFE residual gain.

    Returns
    -------
    SpacetimeCoupler

    Examples
    --------
    >>> coupler = make_schwarzschild_coupler(
    ...     lambda t: 1e3, M=1.989e30, r_m=1e6)
    >>> coupler.redshift_factor(0.0)  # doctest: +SKIP
    """
    G = 6.674_30e-11
    c = 2.997_924_58e8
    r_s = 2 * G * M / c**2

    def redshift(t):
        return np.sqrt(max(1.0 - r_s / r_m, 0.0))

    return SpacetimeCoupler(
        lambda_base=lambda_base,
        redshift_fn=redshift,
        efe_gain=efe_gain,
    )


def make_self_consistent_coupler(
    lambda_base: Callable[[float], float],
    efe_residual_fn: Callable[[float], float],
    *,
    redshift_fn: Optional[Callable[[float], float]] = None,
    efe_gain: float = 0.1,
) -> SpacetimeCoupler:
    """Create a coupler with EFE residual feedback for self-consistency.

    Unlike ``make_schwarzschild_coupler`` which leaves ``efe_residual_fn``
    unpopulated, this factory wires a live residual function so that
    ``lambda_eff`` actively modulates the entropic rate based on the
    Complex EFE residual norm.

    Parameters
    ----------
    lambda_base : callable
        Base entropy production rate ``lambda(t)`` (1/s).
    efe_residual_fn : callable
        Complex EFE residual norm ``r(t)``.
    redshift_fn : callable, optional
        Redshift factor ``a(t)``.
    efe_gain : float
        Scaling for residual modulation.

    Returns
    -------
    SpacetimeCoupler
    """
    return SpacetimeCoupler(
        lambda_base=lambda_base,
        redshift_fn=redshift_fn,
        efe_residual_fn=efe_residual_fn,
        efe_gain=efe_gain,
    )


def export_coupler_csv(
    *,
    out_csv: str,
    t_s: Sequence[float],
    coupler: SpacetimeCoupler,
) -> None:
    """Export coupler traces to CSV.

    Parameters
    ----------
    out_csv : str
        Output file path.
    t_s : sequence of float
        Time values.
    coupler : SpacetimeCoupler
    """
    import csv
    from pathlib import Path

    p = Path(out_csv)
    p.parent.mkdir(parents=True, exist_ok=True)
    with p.open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["t_s", "redshift_factor", "efe_residual_norm", "lambda_eff_s_inv"])
        for t in t_s:
            w.writerow([
                float(t),
                coupler.redshift_factor(float(t)),
                coupler.efe_residual_norm(float(t)),
                coupler.lambda_eff(float(t)),
            ])
