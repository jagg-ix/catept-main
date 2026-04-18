"""Entropic stress tensor S_uv and imaginary curvature Lambda_uv.

Implements the CAT/EPT tensor objects:

- Entropic stress tensor ``S_{mu nu}`` (Eq. 36):
  ``S_{mu nu} = 1/2 (-nabla_mu phi nabla_nu phi + g_{mu nu} (nabla phi)^2)``

- Imaginary curvature tensor ``Lambda_{mu nu}`` (Eq. 37):
  Constructed from ``nabla_mu nabla_nu phi`` with selectable models.

Source
------
Consolidated from ``catsim_core/metric/entropic_tensors.py``.
"""

from __future__ import annotations

from typing import Sequence


def _require_sympy():
    try:
        import sympy as sp
    except ImportError as e:
        raise ImportError(
            "SymPy is required for tensor computation.  "
            "Install with:  pip install sympy"
        ) from e
    return sp


def _covariant_derivative_scalar(phi, coords, mu):
    """nabla_mu phi = d_mu phi for a scalar field."""
    sp = _require_sympy()
    return sp.diff(phi, coords[mu])


def covariant_hessian_scalar(phi, g, coords, Gamma=None):
    """Covariant Hessian nabla_mu nabla_nu phi for a scalar field.

    Parameters
    ----------
    phi : sympy.Expr
        Scalar field.
    g : sympy.Matrix, shape (d, d)
        Metric tensor.
    coords : sequence of sympy.Symbol
        Coordinates.
    Gamma : sympy.MutableDenseNDimArray, optional
        Christoffel symbols.  Computed from ``g`` if ``None``.

    Returns
    -------
    H : sympy.Matrix, shape (d, d)
        ``H[mu, nu] = nabla_mu nabla_nu phi``.
    """
    sp = _require_sympy()
    from .curvature import christoffel_symbols

    dim = g.shape[0]
    if Gamma is None:
        Gamma = christoffel_symbols(g, coords)

    H = sp.MutableDenseMatrix.zeros(dim, dim)
    for mu in range(dim):
        for nu in range(dim):
            term = sp.diff(phi, coords[mu], coords[nu])
            corr = 0
            for lam in range(dim):
                corr += Gamma[lam, mu, nu] * sp.diff(phi, coords[lam])
            H[mu, nu] = sp.simplify(term - corr)
    return sp.Matrix(H)


def dalembertian(phi, g, coords, Gamma=None):
    """d'Alembertian Box phi = g^{mu nu} nabla_mu nabla_nu phi.

    Parameters
    ----------
    phi : sympy.Expr
        Scalar field.
    g : sympy.Matrix
        Metric tensor.
    coords : sequence of sympy.Symbol
        Coordinates.
    Gamma : optional
        Christoffel symbols.

    Returns
    -------
    box_phi : sympy.Expr
    """
    sp = _require_sympy()
    from .curvature import inverse_metric

    g_inv = inverse_metric(g)
    H = covariant_hessian_scalar(phi, g, coords, Gamma=Gamma)
    dim = g.shape[0]
    s = 0
    for mu in range(dim):
        for nu in range(dim):
            s += g_inv[mu, nu] * H[mu, nu]
    return sp.simplify(s)


def entropic_stress_tensor(phi, g, coords, Gamma=None):
    """Entropic stress tensor S_{mu nu} (Eq. 36).

    ``S_{mu nu} = 1/2 (-nabla_mu phi nabla_nu phi + g_{mu nu} (nabla phi)^2)``

    Parameters
    ----------
    phi : sympy.Expr
        Entropic scalar field.
    g : sympy.Matrix, shape (d, d)
        Metric tensor.
    coords : sequence of sympy.Symbol
        Coordinates.
    Gamma : optional
        Christoffel symbols.

    Returns
    -------
    S : sympy.Matrix, shape (d, d)
        Entropic stress tensor.

    Examples
    --------
    >>> import sympy as sp
    >>> t, x = sp.symbols("t x")
    >>> g = sp.diag(-1, 1)
    >>> phi = sp.Function("phi")(t, x)
    >>> S = entropic_stress_tensor(phi, g, (t, x))
    """
    sp = _require_sympy()
    from .curvature import inverse_metric

    dim = g.shape[0]
    g_inv = inverse_metric(g)

    grad = [_covariant_derivative_scalar(phi, coords, mu) for mu in range(dim)]

    grad_sq = 0
    for mu in range(dim):
        for nu in range(dim):
            grad_sq += g_inv[mu, nu] * grad[mu] * grad[nu]
    grad_sq = sp.simplify(grad_sq)

    S = sp.MutableDenseMatrix.zeros(dim, dim)
    for mu in range(dim):
        for nu in range(dim):
            S[mu, nu] = sp.simplify(
                sp.Rational(1, 2) * (-grad[mu] * grad[nu] + g[mu, nu] * grad_sq)
            )
    return sp.Matrix(S)


def imaginary_curvature_tensor(
    phi,
    g,
    coords,
    Gamma=None,
    *,
    mode: str = "trace_adjusted",
    dim_override: int | None = None,
    alpha=None,
):
    """Imaginary curvature tensor Lambda_{mu nu}.

    Constructed from ``nabla_mu nabla_nu phi`` with selectable models.

    Modes
    -----
    hessian
        ``Lambda = Hess(phi)``
    trace_adjusted (default)
        ``Lambda = Hess(phi) - (1/d) g Box(phi)``
    einstein_like
        ``Lambda = Hess(phi) - (1/2) g Box(phi)``
    trace_adjusted_weighted
        ``Lambda = Hess(phi) - alpha g Box(phi)``

    Parameters
    ----------
    phi : sympy.Expr
        Entropic scalar field.
    g : sympy.Matrix
        Metric tensor.
    coords : sequence of sympy.Symbol
        Coordinates.
    Gamma : optional
        Christoffel symbols.
    mode : str
        Model selection (default ``"trace_adjusted"``).
    dim_override : int, optional
        Override dimension ``d`` in trace subtraction.
    alpha : sympy.Expr, optional
        Coefficient for ``trace_adjusted_weighted`` mode.

    Returns
    -------
    Lambda : sympy.Matrix, shape (d, d)

    Examples
    --------
    >>> import sympy as sp
    >>> t, x = sp.symbols("t x")
    >>> g = sp.diag(-1, 1)
    >>> phi = t**2 + x**2
    >>> L = imaginary_curvature_tensor(phi, g, (t, x))
    """
    sp = _require_sympy()
    from .curvature import christoffel_symbols as _cs

    dim = g.shape[0]
    d = int(dim_override) if dim_override is not None else dim
    if Gamma is None:
        Gamma = _cs(g, coords)

    H = covariant_hessian_scalar(phi, g, coords, Gamma=Gamma)
    box = dalembertian(phi, g, coords, Gamma=Gamma)

    if mode == "hessian":
        coeff = sp.Integer(0)
    elif mode == "trace_adjusted":
        coeff = sp.Rational(1, d)
    elif mode == "einstein_like":
        coeff = sp.Rational(1, 2)
    elif mode == "trace_adjusted_weighted":
        if alpha is None:
            raise ValueError("mode='trace_adjusted_weighted' requires alpha")
        coeff = alpha
    else:
        raise ValueError(f"Unknown Lambda mode: {mode}")

    Lam = sp.MutableDenseMatrix.zeros(dim, dim)
    for mu in range(dim):
        for nu in range(dim):
            Lam[mu, nu] = sp.simplify(H[mu, nu] - coeff * g[mu, nu] * box)
    return sp.Matrix(Lam)
