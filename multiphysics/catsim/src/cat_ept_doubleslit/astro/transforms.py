"""Astropy-facing coordinate/time transforms.

This module keeps *Astropy objects at the boundary*.

Core design rule
----------------
The simulator core evolves in plain floats (SI seconds, meters) wherever
possible. When you want Astropy's units, time objects, or coordinate frames,
convert at the boundary and keep the inner loops free of heavy dependencies.

Meep mapping
------------
Meep typically uses user-chosen "simulation units" (e.g., 1 unit = 1 micron).
To let Meep runs interact with gravitational metrics from the rest of the repo
(`MetricField` / EinsteinPy adapters), we provide a simple, explicit mapping
from Meep's coordinate space to physical SI coordinates.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Tuple

import numpy as np


def has_astropy() -> bool:
    try:
        import astropy  # noqa: F401

        return True
    except Exception:
        return False


@dataclass(frozen=True)
class MeepToPhysicalMap:
    """Map Meep (dimensionless) coordinates to physical SI.

    Parameters
    ----------
    length_unit_m:
        How many meters correspond to one Meep length unit.
        Example: 1e-6 means 1 Meep unit = 1 micron.
    time_unit_s:
        How many seconds correspond to one Meep time unit.
        Meep commonly uses c=1 in its unit system; you decide how to map that
        to SI for metric evaluation.
    origin_m:
        Physical SI origin (meters) corresponding to Meep (0,0,0).
    """

    length_unit_m: float
    time_unit_s: float
    origin_m: Tuple[float, float, float] = (0.0, 0.0, 0.0)

    def x_vec_m(self, meep_xyz: Tuple[float, float, float]) -> np.ndarray:
        xyz = np.asarray(meep_xyz, dtype=float) * float(self.length_unit_m)
        return xyz + np.asarray(self.origin_m, dtype=float)

    def t_s(self, meep_t: float) -> float:
        return float(meep_t) * float(self.time_unit_s)


def quantity_to_si(value: object, *, default_unit: Optional[str] = None) -> float:
    """Convert a value to a float in SI.

    Supports:
    - plain float/int
    - astropy Quantity (if installed)

    Parameters
    ----------
    default_unit:
        If provided and value is a plain number, interpret as this astropy unit
        string (e.g., 'm', 's'). Only used when astropy is installed.
    """

    if isinstance(value, (int, float)):
        if default_unit is None or not has_astropy():
            return float(value)
        import astropy.units as u

        return float((float(value) * u.Unit(default_unit)).to_value(u.si))

    if has_astropy():
        import astropy.units as u

        if isinstance(value, u.Quantity):
            return float(value.to_value(u.si))

    raise TypeError(f"Unsupported value type for SI conversion: {type(value)}")


def skycoord_to_icrs_cartesian_m(skycoord: object) -> np.ndarray:
    """Convert an Astropy SkyCoord to ICRS Cartesian coordinates (meters)."""

    if not has_astropy():
        raise ImportError("astropy is not installed")

    from astropy.coordinates import SkyCoord
    import astropy.units as u

    if not isinstance(skycoord, SkyCoord):
        raise TypeError("skycoord must be an astropy.coordinates.SkyCoord")

    c = skycoord.icrs.cartesian
    return np.array([c.x.to_value(u.m), c.y.to_value(u.m), c.z.to_value(u.m)], dtype=float)
