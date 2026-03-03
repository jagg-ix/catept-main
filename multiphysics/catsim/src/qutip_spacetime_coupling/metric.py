"""Standard metric tensors for entropic spacetime coupling.

Provides symbolic metric construction using SymPy.  These metrics
can be fed into the curvature and complex_efe modules.

Requires
--------
``sympy`` (soft-imported at call time).
"""

from __future__ import annotations

from typing import Sequence, Tuple

import numpy as np


def _require_sympy():
    try:
        import sympy as sp
    except ImportError as e:
        raise ImportError(
            "SymPy is required for symbolic metric operations.  "
            "Install with:  pip install sympy"
        ) from e
    return sp


def schwarzschild_metric(
    coords: Sequence | None = None,
    M: float | None = None,
) -> Tuple:
    """Schwarzschild metric in standard coordinates.

    Parameters
    ----------
    coords : sequence of sympy.Symbol, optional
        Coordinate symbols ``(t, r, theta, phi)``.  Created if ``None``.
    M : float or sympy.Symbol, optional
        Black hole mass.  If ``None``, uses a symbolic ``M``.

    Returns
    -------
    g : sympy.Matrix, shape (4, 4)
        Metric tensor.
    coords : tuple of sympy.Symbol
        Coordinate symbols.
    params : dict
        ``{"M": M_symbol}``.

    Examples
    --------
    >>> g, coords, params = schwarzschild_metric()
    >>> g.shape
    (4, 4)
    """
    sp = _require_sympy()

    if coords is None:
        t, r, theta, phi = sp.symbols("t r theta phi", real=True)
    else:
        t, r, theta, phi = coords

    if M is None:
        M_sym = sp.Symbol("M", positive=True, real=True)
    else:
        M_sym = sp.sympify(M)

    f = 1 - 2 * M_sym / r

    g = sp.diag(-f, 1 / f, r**2, r**2 * sp.sin(theta) ** 2)

    return g, (t, r, theta, phi), {"M": M_sym}


def kerr_metric(
    coords: Sequence | None = None,
    M: float | None = None,
    a_spin: float | None = None,
) -> Tuple:
    """Kerr metric in Boyer-Lindquist coordinates.

    Parameters
    ----------
    coords : sequence of sympy.Symbol, optional
        ``(t, r, theta, phi)``.
    M : float or sympy.Symbol, optional
        Mass.
    a_spin : float or sympy.Symbol, optional
        Spin parameter ``a = J/M``.

    Returns
    -------
    g : sympy.Matrix, shape (4, 4)
        Metric tensor.
    coords : tuple
    params : dict
        ``{"M": ..., "a": ...}``.

    Examples
    --------
    >>> g, coords, params = kerr_metric()
    >>> g.shape
    (4, 4)
    """
    sp = _require_sympy()

    if coords is None:
        t, r, theta, phi = sp.symbols("t r theta phi", real=True)
    else:
        t, r, theta, phi = coords

    M_sym = sp.Symbol("M", positive=True) if M is None else sp.sympify(M)
    a_sym = sp.Symbol("a", real=True) if a_spin is None else sp.sympify(a_spin)

    Sigma = r**2 + a_sym**2 * sp.cos(theta) ** 2
    Delta = r**2 - 2 * M_sym * r + a_sym**2

    g = sp.zeros(4)
    g[0, 0] = -(1 - 2 * M_sym * r / Sigma)
    g[0, 3] = -2 * M_sym * r * a_sym * sp.sin(theta) ** 2 / Sigma
    g[3, 0] = g[0, 3]
    g[1, 1] = Sigma / Delta
    g[2, 2] = Sigma
    g[3, 3] = (r**2 + a_sym**2 + 2 * M_sym * r * a_sym**2 * sp.sin(theta) ** 2 / Sigma) * sp.sin(theta) ** 2

    return sp.Matrix(g), (t, r, theta, phi), {"M": M_sym, "a": a_sym}


def minkowski_metric(
    coords: Sequence | None = None,
    signature: str = "-+++",
) -> Tuple:
    """Minkowski metric in Cartesian or spherical coordinates.

    Parameters
    ----------
    coords : sequence of sympy.Symbol, optional
        ``(t, x, y, z)`` or ``(t, r, theta, phi)``.
    signature : str
        ``"-+++"`` (default) or ``"+++-"``.

    Returns
    -------
    g : sympy.Matrix, shape (4, 4)
    coords : tuple
    params : dict
    """
    sp = _require_sympy()

    if coords is None:
        coords = sp.symbols("t x y z", real=True)

    if signature == "-+++":
        g = sp.diag(-1, 1, 1, 1)
    elif signature == "+++-":
        g = sp.diag(1, 1, 1, -1)
    else:
        raise ValueError(f"Unknown signature: {signature}")

    return g, tuple(coords), {}


def metric_determinant(g) -> "sp.Expr":
    """Compute metric determinant.

    Parameters
    ----------
    g : sympy.Matrix
        Metric tensor.

    Returns
    -------
    det_g : sympy.Expr
    """
    sp = _require_sympy()
    return sp.simplify(g.det())


def evaluate_metric(
    g,
    coords: Sequence,
    point: dict,
) -> np.ndarray:
    """Numerically evaluate a symbolic metric at a point.

    Parameters
    ----------
    g : sympy.Matrix
        Symbolic metric.
    coords : sequence of sympy.Symbol
        Coordinates.
    point : dict
        ``{symbol: value}`` mapping.

    Returns
    -------
    g_num : ndarray, shape (d, d)
        Numerical metric values.

    Examples
    --------
    >>> g, coords, p = schwarzschild_metric(M=1.0)
    >>> g_num = evaluate_metric(g, coords, {coords[0]: 0, coords[1]: 10, coords[2]: np.pi/2, coords[3]: 0})
    """
    sp = _require_sympy()
    d = g.shape[0]
    g_num = np.empty((d, d), dtype=float)
    for i in range(d):
        for j in range(d):
            expr = g[i, j]
            val = float(expr.subs(point))
            g_num[i, j] = val
    return g_num
