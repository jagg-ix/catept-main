"""Electromagnetics backends.

This subpackage houses FDTD-style electromagnetics backends that can be used
alongside the CAT/EPT stack:

* Entropic proper time stepping via :class:`cat_ept_doubleslit.clock.entropic_clock.EntropicClock`
* Complex-action (non-Hermitian) hooks at the level of effective material loss
  or envelope modulation (kept conservative; no physics over-claims)
* Optional metric redshift factor via :func:`cat_ept_doubleslit.metrics.redshift.redshift_factor`

All optional third-party dependencies are *soft-imported*.
"""

from .meep_backend import (
    has_meep,
    MeepRunConfig,
    build_basic_2d_double_slit,
    run_meep_with_entropic_clock,
)

__all__ = [
    "has_meep",
    "MeepRunConfig",
    "build_basic_2d_double_slit",
    "run_meep_with_entropic_clock",
]
