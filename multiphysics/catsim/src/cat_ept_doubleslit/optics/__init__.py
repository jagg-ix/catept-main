"""Optics backends (optional) with CAT/EPT entropic-time interoperability.

This package provides a thin, *optional* integration layer for multiple optics libraries.
All engines consume the same entropic-time contract used throughout the repo:

- t_s: coordinate time samples [s]
- tau_ent_s: entropic proper time samples [s] (dimensionless in natural units, but we keep seconds for bookkeeping)
- lambda_eff_s_inv: effective entropy production rate λ(t) [1/s]

The engines are expected to be side-effect free and return portable NumPy arrays so the
rest of the repo (QuTiP, EinsteinPy, OGRePy, PySCF, PyNE, etc.) can interoperate without
backend-specific glue.
"""

from .registry import create_engine, list_backends
from .types import OpticsRunResult, OpticsEngine

__all__ = [
    "OpticsEngine",
    "OpticsRunResult",
    "create_engine",
    "list_backends",
]
