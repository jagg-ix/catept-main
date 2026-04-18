"""Complex Einstein Field Equations (CAT/EPT).

Implements the complex EFE:

    G_{mu nu} + i Lambda_{mu nu} = kappa (T_{mu nu} + i S_{mu nu})

where the real sector is standard GR and the imaginary sector
encodes entropic dynamics.

Source
------
Consolidated from ``catsim_core/ogrepy/complex_efe.py``.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Sequence


def _require_sympy():
    try:
        import sympy as sp
    except ImportError as e:
        raise ImportError(
            "SymPy is required for complex EFE computation.  "
            "Install with:  pip install sympy"
        ) from e
    return sp


@dataclass(frozen=True)
class ComplexEFEResult:
    """Result of complex EFE residual computation.

    Attributes
    ----------
    G : sympy.Matrix
        Einstein tensor.
    Lambda : sympy.Matrix
        Imaginary curvature tensor.
    S : sympy.Matrix
        Entropic stress tensor.
    residual : sympy.Matrix
        Complex-valued residual ``(G + i Lambda) - kappa (T + i S)``.
    residual_fro_norm : sympy.Expr
        Frobenius norm of the residual (for gating).
    """

    G: object  # sp.Matrix
    Lambda: object  # sp.Matrix
    S: object  # sp.Matrix
    residual: object  # sp.Matrix
    residual_fro_norm: object  # sp.Expr


def einstein_tensor(*, g, coords: Sequence, Gamma=None):
    """Compute Einstein tensor G_{mu nu} from metric.

    Parameters
    ----------
    g : sympy.Matrix
        Metric tensor.
    coords : sequence of sympy.Symbol
        Coordinates.
    Gamma : optional
        Christoffel symbols.

    Returns
    -------
    G : sympy.Matrix, shape (d, d)

    Examples
    --------
    >>> from qutip_spacetime_coupling.metric import minkowski_metric
    >>> g, coords, _ = minkowski_metric()
    >>> G = einstein_tensor(g=g, coords=coords)
    """
    sp = _require_sympy()
    from .curvature import christoffel_symbols, riemann_tensor, ricci_tensor, inverse_metric

    if Gamma is None:
        Gamma = christoffel_symbols(g, coords)

    Riem = riemann_tensor(Gamma, coords)
    Ric = ricci_tensor(Riem)
    g_inv = inverse_metric(g)
    R = sp.simplify((g_inv * Ric).trace())
    G = sp.simplify(Ric - sp.Rational(1, 2) * g * R)
    return sp.Matrix(G)


def complex_efe_residual(
    *,
    g,
    coords: Sequence,
    phi,
    T=None,
    kappa=None,
    lambda_mode: str = "trace_adjusted",
) -> ComplexEFEResult:
    """Compute complex EFE residual.

    Residual:
        R_{mu nu} := (G_{mu nu} + i Lambda_{mu nu}) - kappa (T_{mu nu} + i S_{mu nu})

    Parameters
    ----------
    g : sympy.Matrix
        Metric tensor.
    coords : sequence of sympy.Symbol
        Coordinates.
    phi : sympy.Expr
        Entropic scalar field.
    T : sympy.Matrix, optional
        Real stress-energy tensor.  Zero if ``None``.
    kappa : sympy.Expr, optional
        Coupling ``kappa = 8 pi G / c^4``.  Uses 1 if ``None``.
    lambda_mode : str
        Mode for imaginary curvature tensor (default ``"trace_adjusted"``).

    Returns
    -------
    ComplexEFEResult

    Examples
    --------
    >>> import sympy as sp
    >>> from qutip_spacetime_coupling.metric import minkowski_metric
    >>> g, coords, _ = minkowski_metric()
    >>> phi = coords[0]  # trivial field
    >>> result = complex_efe_residual(g=g, coords=coords, phi=phi)
    """
    sp = _require_sympy()
    from .curvature import christoffel_symbols
    from .entropic_stress import entropic_stress_tensor, imaginary_curvature_tensor

    dim = g.shape[0]
    if T is None:
        T = sp.zeros(dim)
    if kappa is None:
        kappa = sp.Integer(1)

    Gamma = christoffel_symbols(g, coords)
    G = einstein_tensor(g=g, coords=coords, Gamma=Gamma)
    S = entropic_stress_tensor(phi, g, coords, Gamma=Gamma)
    Lambda = imaginary_curvature_tensor(phi, g, coords, Gamma=Gamma, mode=lambda_mode)

    residual = sp.Matrix(G + sp.I * Lambda - kappa * (T + sp.I * S))

    res_sq = 0
    for i in range(dim):
        for j in range(dim):
            res_sq += sp.simplify(residual[i, j] * sp.conjugate(residual[i, j]))

    return ComplexEFEResult(
        G=G,
        Lambda=Lambda,
        S=S,
        residual=residual,
        residual_fro_norm=sp.simplify(sp.sqrt(res_sq)),
    )
