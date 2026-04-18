"""Astropy bridge utilities (optional).

Design goal
-----------
Astropy is used here as a *foundational* interoperability layer for astronomy:

- units and constants
- coordinate frames and time scales
- FITS / metadata interoperability (future)

Important nuance for CAT/EPT
----------------------------
In this project, entropic proper time ``tau_ent`` may be used as the *integrator*
step variable, with coordinate time ``t`` treated as a derived quantity via

    d tau_ent = lambda(t, state) dt.

That means we do **not** require Astropy's ``Time`` class to be the primary time
parameter. Instead:

- we keep a minimal float ``t_s`` in seconds in the numerical core
- Astropy types are supported at the boundaries (IO / user-facing config)

This module provides small helpers to accept Astropy quantities/time objects
*without coupling* the core solver to Astropy.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Optional, Tuple


def has_astropy() -> bool:
    try:  # pragma: no cover
        import astropy  # noqa: F401

        return True
    except Exception:
        return False


def _import_units():
    from astropy import units as u

    return u


def is_quantity(x: Any) -> bool:
    if not has_astropy():
        return False
    u = _import_units()
    return isinstance(x, u.Quantity)


def to_float_seconds(x: Any) -> float:
    """Convert ``x`` to seconds as a float.

    Accepts:
    - float/int (assumed seconds)
    - astropy.units.Quantity with time units
    - astropy.time.TimeDelta

    Raises
    ------
    TypeError if the type is unsupported.
    """
    if isinstance(x, (int, float)):
        return float(x)

    if not has_astropy():
        raise TypeError(
            "Astropy is not installed, but a non-float time value was provided. "
            "Install with: pip install -e '.[astropy]'"
        )

    u = _import_units()
    try:
        from astropy.time import TimeDelta

        if isinstance(x, TimeDelta):
            return float(x.to_value(u.s))
    except Exception:
        pass

    if isinstance(x, u.Quantity):
        return float(x.to_value(u.s))

    raise TypeError(f"Unsupported time type {type(x)}")


def quantity(value: float, unit: str):
    """Create an Astropy quantity if Astropy is available; else raise."""
    if not has_astropy():
        raise RuntimeError("Astropy is not installed")
    u = _import_units()
    return float(value) * getattr(u, unit)


@dataclass(frozen=True)
class CoordinateTime:
    """A light wrapper for coordinate time.

    - ``t_s`` is the authoritative numeric representation (seconds)
    - ``time_obj`` may hold an astropy.time.Time for user-facing IO

    This avoids forcing the whole codebase to depend on astropy.time.Time.
    """

    t_s: float
    time_obj: Optional[Any] = None


def parse_time(t: Any, *, scale: str = "tdb") -> CoordinateTime:
    """Parse coordinate time input.

    Accepts:
    - float seconds
    - astropy.time.Time (any scale)

    Returns
    -------
    CoordinateTime with both a float seconds value and the original object.

    Notes
    -----
    This is *optional* and intended for user-facing wrappers only.
    The numerical core should use floats.
    """
    if isinstance(t, (int, float)):
        return CoordinateTime(t_s=float(t), time_obj=None)

    if not has_astropy():
        raise TypeError(
            "Astropy is not installed, but a Time object was provided. "
            "Install with: pip install -e '.[astropy]'"
        )

    from astropy.time import Time

    if isinstance(t, Time):
        # Use seconds since Unix epoch as a neutral numeric coordinate.
        # Users can choose a physically meaningful origin at the wrapper level.
        t2 = t.to_value("unix")
        return CoordinateTime(t_s=float(t2), time_obj=t)

    raise TypeError(f"Unsupported time type {type(t)}")
