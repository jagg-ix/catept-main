"""Curvature tensors from metric (SymPy-based).

Computes Christoffel symbols, Riemann tensor, Ricci tensor, and
scalar curvature.  All functions are pure SymPy with no external
GR library dependency.

Source
------
Consolidated from ``catsim_core/metric/curvature.py`` and
``catsim_core/metric/entropic_tensors.py`` (Christoffel computation).
"""

from __future__ import annotations

from typing import Sequence


def _require_sympy():
    try:
        import sympy as sp
    except ImportError as e:
        raise ImportError(
            "SymPy is required for curvature computation.  "
            "Install with:  pip install sympy"
        ) from e
    return sp


def inverse_metric(g):
    """Compute inverse metric g^{mu nu}.

    Parameters
    ----------
    g : sympy.Matrix, shape (d, d)
        Metric tensor.

    Returns
    -------
    g_inv : sympy.Matrix, shape (d, d)
    """
    sp = _require_sympy()
    return sp.simplify(g.inv())


def christoffel_symbols(g, coords: Sequence):
    """Levi-Civita Christoffel symbols Gamma^lam_{mu nu}.

    Parameters
    ----------
    g : sympy.Matrix, shape (d, d)
        Metric tensor.
    coords : sequence of sympy.Symbol
        Coordinate symbols.

    Returns
    -------
    Gamma : sympy.MutableDenseNDimArray, shape (d, d, d)
        ``Gamma[lam, mu, nu]``.

    Examples
    --------
    >>> from qutip_spacetime_coupling.metric import minkowski_metric
    >>> g, coords, _ = minkowski_metric()
    >>> Gamma = christoffel_symbols(g, coords)
    """
    sp = _require_sympy()
    dim = g.shape[0]
    g_inv = inverse_metric(g)
    Gamma = sp.MutableDenseNDimArray.zeros(dim, dim, dim)
    for lam in range(dim):
        for mu in range(dim):
            for nu in range(dim):
                s = 0
                for rho in range(dim):
                    s += g_inv[lam, rho] * (
                        sp.diff(g[rho, nu], coords[mu])
                        + sp.diff(g[rho, mu], coords[nu])
                        - sp.diff(g[mu, nu], coords[rho])
                    )
                Gamma[lam, mu, nu] = sp.simplify(sp.Rational(1, 2) * s)
    return Gamma


def riemann_tensor(Gamma, coords: Sequence):
    """Riemann curvature tensor R^rho_{sigma mu nu}.

    Parameters
    ----------
    Gamma : sympy.MutableDenseNDimArray, shape (d, d, d)
        Christoffel symbols.
    coords : sequence of sympy.Symbol
        Coordinate symbols.

    Returns
    -------
    R : sympy.MutableDenseNDimArray, shape (d, d, d, d)
        ``R[rho, sigma, mu, nu]``.
    """
    sp = _require_sympy()
    dim = int(Gamma.shape[0])
    R = sp.MutableDenseNDimArray.zeros(dim, dim, dim, dim)
    for rho in range(dim):
        for sig in range(dim):
            for mu in range(dim):
                for nu in range(dim):
                    term = (
                        sp.diff(Gamma[rho, nu, sig], coords[mu])
                        - sp.diff(Gamma[rho, mu, sig], coords[nu])
                    )
                    quad = 0
                    for lam in range(dim):
                        quad += (
                            Gamma[rho, mu, lam] * Gamma[lam, nu, sig]
                            - Gamma[rho, nu, lam] * Gamma[lam, mu, sig]
                        )
                    R[rho, sig, mu, nu] = sp.simplify(term + quad)
    return R


def ricci_tensor(Riemann):
    """Ricci tensor R_{sigma nu} = R^rho_{sigma rho nu}.

    Parameters
    ----------
    Riemann : sympy.MutableDenseNDimArray, shape (d, d, d, d)
        Riemann curvature tensor.

    Returns
    -------
    Ric : sympy.Matrix, shape (d, d)
    """
    sp = _require_sympy()
    dim = int(Riemann.shape[0])
    Ric = sp.MutableDenseMatrix.zeros(dim, dim)
    for sig in range(dim):
        for nu in range(dim):
            s = 0
            for rho in range(dim):
                s += Riemann[rho, sig, rho, nu]
            Ric[sig, nu] = sp.simplify(s)
    return sp.Matrix(Ric)


def ricci_scalar(Ric, g):
    """Ricci scalar R = g^{mu nu} R_{mu nu}.

    Parameters
    ----------
    Ric : sympy.Matrix, shape (d, d)
        Ricci tensor.
    g : sympy.Matrix, shape (d, d)
        Metric tensor.

    Returns
    -------
    R : sympy.Expr
    """
    sp = _require_sympy()
    g_inv = inverse_metric(g)
    return sp.simplify((g_inv * Ric).trace())


def kretschner_scalar(Riemann, g):
    """Kretschner scalar K = R_{abcd} R^{abcd}.

    Parameters
    ----------
    Riemann : sympy.MutableDenseNDimArray, shape (d, d, d, d)
        Riemann tensor R^rho_{sigma mu nu}.
    g : sympy.Matrix, shape (d, d)
        Metric tensor.

    Returns
    -------
    K : sympy.Expr

    Notes
    -----
    This is the full contraction of the Riemann tensor with itself,
    useful for detecting true singularities vs coordinate artifacts.
    """
    sp = _require_sympy()
    dim = int(Riemann.shape[0])
    g_inv = inverse_metric(g)

    # Lower the upper index: R_{rho sigma mu nu} = g_{rho lam} R^lam_{sigma mu nu}
    R_down = sp.MutableDenseNDimArray.zeros(dim, dim, dim, dim)
    for rho in range(dim):
        for sig in range(dim):
            for mu in range(dim):
                for nu in range(dim):
                    s = 0
                    for lam in range(dim):
                        s += g[rho, lam] * Riemann[lam, sig, mu, nu]
                    R_down[rho, sig, mu, nu] = s

    # K = g^{ra} g^{sb} g^{mc} g^{nd} R_{rsmn} R_{abcd}
    K = 0
    for r in range(dim):
        for s in range(dim):
            for m in range(dim):
                for n in range(dim):
                    for a in range(dim):
                        for b in range(dim):
                            for cc in range(dim):
                                for d in range(dim):
                                    K += (
                                        g_inv[r, a]
                                        * g_inv[s, b]
                                        * g_inv[m, cc]
                                        * g_inv[n, d]
                                        * R_down[r, s, m, n]
                                        * R_down[a, b, cc, d]
                                    )
    return sp.simplify(K)
