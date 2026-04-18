"""Spacetime coupling for entropic dynamics (QuTiP-compatible).

Bridges general-relativistic geometry with quantum entropy production:

- **metric**: Schwarzschild/Kerr metric loading + numerical evaluation
- **curvature**: Riemann, Ricci, scalar curvature (SymPy or numeric)
- **entropic_stress**: Entropic stress tensor S_uv and imaginary curvature Lambda_uv
- **complex_efe**: Complex Einstein field equations residual
- **coupler**: SpacetimeCoupler mapping curvature -> lambda_eff(t)
- **hawking**: Hawking radiation, Unruh effect, black hole thermodynamics

Requires
--------
``numpy`` for all modules.  ``sympy`` for symbolic tensor computation.
``qutip`` and ``einsteinpy`` are optional (soft-imported).
"""

from __future__ import annotations

__version__ = "0.1.0"

# NumPy-only public API (always available)
from .coupler import SpacetimeCoupler, make_identity_coupler, make_schwarzschild_coupler
from .hawking import (
    hawking_temperature,
    unruh_temperature,
    thermal_occupation,
    schwarzschild_redshift,
    isco_radius,
    hawking_entropy_rate,
)

__all__ = [
    # coupler
    "SpacetimeCoupler",
    "make_identity_coupler",
    "make_schwarzschild_coupler",
    # hawking
    "hawking_temperature",
    "unruh_temperature",
    "thermal_occupation",
    "schwarzschild_redshift",
    "isco_radius",
    "hawking_entropy_rate",
]


def __getattr__(name: str):
    """Lazy imports for SymPy-dependent modules."""
    _sympy_names = {
        # metric
        "schwarzschild_metric",
        "kerr_metric",
        "minkowski_metric",
        "metric_determinant",
        # curvature
        "christoffel_symbols",
        "riemann_tensor",
        "ricci_tensor",
        "ricci_scalar",
        "kretschner_scalar",
        # entropic_stress
        "entropic_stress_tensor",
        "imaginary_curvature_tensor",
        "covariant_hessian_scalar",
        "dalembertian",
        # complex_efe
        "einstein_tensor",
        "complex_efe_residual",
        "ComplexEFEResult",
    }
    if name in _sympy_names:
        if name in ("schwarzschild_metric", "kerr_metric", "minkowski_metric", "metric_determinant"):
            from . import metric as _m
            return getattr(_m, name)
        elif name in ("christoffel_symbols", "riemann_tensor", "ricci_tensor", "ricci_scalar", "kretschner_scalar"):
            from . import curvature as _c
            return getattr(_c, name)
        elif name in ("entropic_stress_tensor", "imaginary_curvature_tensor", "covariant_hessian_scalar", "dalembertian"):
            from . import entropic_stress as _es
            return getattr(_es, name)
        elif name in ("einstein_tensor", "complex_efe_residual", "ComplexEFEResult"):
            from . import complex_efe as _ce
            return getattr(_ce, name)
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
