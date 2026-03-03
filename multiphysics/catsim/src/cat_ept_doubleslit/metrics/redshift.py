"""Metric helpers (EinsteinPy optional).

This module provides a *minimal* interface for using a spacetime metric to
modulate entropic rates (e.g., via a redshift factor sqrt(-g00)).

We do **not** attempt to build a full GR stack here; instead we expose a simple
callable for g00(t, x) and offer a few convenient constructors.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Optional, Tuple

import numpy as np
import math


G_SI = 6.67430e-11
C_SI = 299_792_458.0


G00Fn = Callable[[float, np.ndarray], float]


@dataclass(frozen=True)
class MetricField:
    """A lightweight metric handle.

    Parameters
    ----------
    g00:
        Callable returning g00(t_s, x_vec_m) (dimensionless), signature (-,+,+,+).
    """

    g00: G00Fn

    def redshift_factor(self, t_s: float, x_vec_m: np.ndarray) -> float:
        """Return sqrt(-g00) for static observers.

        For Minkowski: g00 = -1 -> factor 1.
        """

        g00 = float(self.g00(t_s, np.asarray(x_vec_m, dtype=float)))
        if g00 >= 0:
            raise ValueError(f"Expected g00 < 0 for timelike coordinate, got {g00}")
        return float(np.sqrt(-g00))


def minkowski_metric() -> MetricField:
    return MetricField(g00=lambda t, x: -1.0)


def schwarzschild_metric(mass_kg: float) -> MetricField:
    """Static Schwarzschild g00 in Schwarzschild coordinates.

    g00 = -(1 - 2GM/(c^2 r))
    """

    rs = 2.0 * G_SI * float(mass_kg) / (C_SI ** 2)

    def g00(_t: float, x: np.ndarray) -> float:
        r = float(np.linalg.norm(x))
        if r <= rs:
            # Inside horizon Schwarzschild t becomes spacelike; keep conservative.
            raise ValueError("Schwarzschild g00 undefined for r <= r_s in these coordinates")
        return -(1.0 - rs / r)

    return MetricField(g00=g00)


def einsteinpy_metric_adapter(metric_obj: object, coord_fn: Callable[[float, np.ndarray], Tuple[float, float, float, float]]) -> MetricField:
    """Wrap an EinsteinPy metric object as a MetricField.

    Parameters
    ----------
    metric_obj:
        An EinsteinPy metric instance (e.g., einsteinpy.metric.Schwarzschild).
    coord_fn:
        Maps (t_s, x_vec_m) -> coordinate tuple expected by the metric.

    Notes
    -----
    EinsteinPy is optional; we avoid importing it at module import time.
    """

    def g00(t_s: float, x_vec_m: np.ndarray) -> float:
        coords = coord_fn(t_s, x_vec_m)
        # EinsteinPy metrics usually provide metric_covariant(coords)
        if hasattr(metric_obj, "metric_covariant"):
            g_cov = metric_obj.metric_covariant(coords)
            return float(g_cov[0, 0])
        raise TypeError("metric_obj does not expose metric_covariant")

    return MetricField(g00=g00)


def kerr_metric(mass_kg: float, *, a_star: float = 0.0) -> MetricField:
    """Approximate Kerr g00 (Boyer–Lindquist), expressed as a MetricField over Cartesian x.

    We use the analytic Kerr g_tt component in geometric units (G=c=1):
        g_tt = -(1 - 2 M r / Σ)
        Σ = r^2 + a^2 cos^2θ
    where:
        M_geo = GM/c^2   (meters)
        a_len = a_star * M_geo  (meters), with 0<=a_star<=1 for subextremal spin.

    Mapping from Cartesian x=(x,y,z) to (r,θ):
        r = ||x||
        cosθ = z/r

    Notes
    -----
    * This is used only as a *redshift factor provider* sqrt(-g00) for static observers.
    * Inside the ergosphere g_tt becomes >=0; we raise for conservativeness.
    * This does not attempt frame dragging terms (g_tφ) for observers with angular motion.
    """

    M_geo = (G_SI * float(mass_kg)) / (C_SI ** 2)
    a_star = float(a_star)
    if a_star < 0.0:
        raise ValueError("a_star must be >= 0")
    a_len = a_star * M_geo

    def g00(_t: float, x: np.ndarray) -> float:
        r = float(np.linalg.norm(x))
        if r <= 0:
            raise ValueError("Kerr g00 undefined at r=0")
        cos_th = float(x[2] / r)
        Sigma = (r*r) + (a_len*a_len) * (cos_th*cos_th)
        if Sigma <= 0:
            raise ValueError("Invalid Kerr Σ")
        gtt = -(1.0 - (2.0 * M_geo * r) / Sigma)
        return float(gtt)

    return MetricField(g00=g00)
