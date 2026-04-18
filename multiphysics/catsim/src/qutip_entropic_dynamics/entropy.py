"""Standalone entropy computation (no QuTiP dependency).

All functions operate on NumPy arrays representing density matrices.
This module is the single source of truth for entropy calculations
across the package.

Source
------
Best of ``oqupy_backend.py:von_neumann_entropy`` (eigenvalue-based,
numerically stable) combined with relative entropy from
``qutip_catept_extension.py``.
"""

from __future__ import annotations

import numpy as np


def entropy_vn(rho: np.ndarray, base: float = np.e) -> float:
    """Von Neumann entropy of a density matrix.

    Computes ``S = -Tr(rho log rho)`` from the eigenvalues of the
    Hermitian part of *rho*.  Eigenvalues are clipped to ``[0, 1]``
    for numerical stability.

    Parameters
    ----------
    rho : ndarray, shape (d, d)
        Density matrix (may be complex).
    base : float, optional
        Logarithm base.  Use ``np.e`` (default) for nats, ``2`` for bits.

    Returns
    -------
    S : float
        Von Neumann entropy (non-negative).

    Examples
    --------
    >>> import numpy as np
    >>> rho_pure = np.diag([1.0, 0.0])
    >>> entropy_vn(rho_pure)
    0.0
    >>> rho_mixed = np.diag([0.5, 0.5])
    >>> np.isclose(entropy_vn(rho_mixed, base=2), 1.0)
    True
    """
    rho = np.asarray(rho, dtype=complex)
    # Symmetrise to guarantee real eigenvalues
    rho_h = (rho + rho.conjugate().T) / 2.0
    w = np.linalg.eigvalsh(rho_h)
    w = np.clip(w.real, 0.0, 1.0)
    nz = w[w > 0]
    if nz.size == 0:
        return 0.0
    return float(-(nz * (np.log(nz) / np.log(base))).sum())


def entropy_production_rate(
    S: np.ndarray,
    t: np.ndarray,
    k_B: float = 1.380_649e-23,
) -> np.ndarray:
    """Entropy production rate lambda(t) = (1/k_B) dS/dt.

    Uses ``numpy.gradient`` for a smooth finite-difference estimate.
    Negative rates are clipped to zero (entropy cannot decrease in a
    Markovian channel).

    Parameters
    ----------
    S : ndarray, shape (N,)
        Von Neumann entropy trace.
    t : ndarray, shape (N,)
        Corresponding time values (seconds).
    k_B : float, optional
        Boltzmann constant.  Set to ``1.0`` if *S* is already in natural
        units.

    Returns
    -------
    lam : ndarray, shape (N,)
        Entropy production rate (1/s), non-negative.

    Examples
    --------
    >>> t = np.linspace(0, 1, 100)
    >>> S = 1 - np.exp(-t)  # monotonically increasing
    >>> lam = entropy_production_rate(S, t, k_B=1.0)
    >>> np.all(lam >= 0)
    True
    """
    S = np.asarray(S, dtype=float)
    t = np.asarray(t, dtype=float)
    dSdt = np.gradient(S, t, edge_order=1)
    return np.maximum(0.0, dSdt / float(k_B))


def entropy_relative(rho: np.ndarray, sigma: np.ndarray) -> float:
    """Quantum relative entropy S(rho || sigma).

    Computes ``S(rho||sigma) = Tr(rho log rho) - Tr(rho log sigma)``
    in the shared eigenbasis.  Returns ``+inf`` if the support of *rho*
    is not contained in the support of *sigma*.

    Parameters
    ----------
    rho : ndarray, shape (d, d)
        Density matrix.
    sigma : ndarray, shape (d, d)
        Reference density matrix.

    Returns
    -------
    S_rel : float
        Relative entropy (non-negative, possibly ``+inf``).

    Examples
    --------
    >>> rho = np.diag([0.5, 0.5])
    >>> np.isclose(entropy_relative(rho, rho), 0.0)
    True
    """
    rho = np.asarray(rho, dtype=complex)
    sigma = np.asarray(sigma, dtype=complex)

    # Diagonalise both
    w_rho, U_rho = np.linalg.eigh((rho + rho.conj().T) / 2)
    w_sigma, U_sigma = np.linalg.eigh((sigma + sigma.conj().T) / 2)

    w_rho = np.clip(w_rho.real, 0.0, 1.0)
    w_sigma = np.clip(w_sigma.real, 0.0, 1.0)

    # Support check: rho has weight where sigma is zero → infinite
    rho_support = w_rho > 1e-15
    sigma_support = w_sigma > 1e-15

    # Express rho in sigma's eigenbasis
    # rho_in_sigma = U_sigma^dag @ rho @ U_sigma
    rho_in_sigma = U_sigma.conj().T @ ((rho + rho.conj().T) / 2) @ U_sigma
    rho_diag_in_sigma = np.real(np.diag(rho_in_sigma))
    rho_diag_in_sigma = np.clip(rho_diag_in_sigma, 0.0, 1.0)

    # Check support condition
    for i in range(len(w_sigma)):
        if rho_diag_in_sigma[i] > 1e-15 and w_sigma[i] < 1e-15:
            return float("inf")

    # Tr(rho log rho)
    nz_rho = w_rho[w_rho > 1e-15]
    tr_rho_log_rho = float((nz_rho * np.log(nz_rho)).sum())

    # Tr(rho log sigma) in sigma eigenbasis
    tr_rho_log_sigma = 0.0
    for i in range(len(w_sigma)):
        if w_sigma[i] > 1e-15 and rho_diag_in_sigma[i] > 1e-15:
            tr_rho_log_sigma += rho_diag_in_sigma[i] * np.log(w_sigma[i])

    return float(tr_rho_log_rho - tr_rho_log_sigma)


def entropy_trace(
    tlist_s: np.ndarray,
    rho_t: np.ndarray,
    k_B: float = 1.380_649e-23,
    base: float = np.e,
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Compute S(t), lambda(t), tau_ent(t) from a trajectory of density matrices.

    Parameters
    ----------
    tlist_s : ndarray, shape (N,)
        Time array (seconds).
    rho_t : ndarray, shape (N, d, d)
        Density matrices at each time step.
    k_B : float, optional
        Boltzmann constant.
    base : float, optional
        Logarithm base for entropy.

    Returns
    -------
    S : ndarray, shape (N,)
        Von Neumann entropy at each time.
    lam : ndarray, shape (N,)
        Entropy production rate at each time.
    tau : ndarray, shape (N,)
        Entropic proper time at each time.

    Examples
    --------
    >>> t = np.linspace(0, 1, 50)
    >>> rho = np.array([np.diag([0.5+0.5*np.exp(-ti), 0.5-0.5*np.exp(-ti)]) for ti in t])
    >>> S, lam, tau = entropy_trace(t, rho, k_B=1.0)
    """
    t = np.asarray(tlist_s, dtype=float)
    if rho_t.ndim != 3:
        raise ValueError("rho_t must have shape (N, d, d)")

    S = np.array(
        [entropy_vn(rho_t[i], base=base) for i in range(len(t))],
        dtype=float,
    )
    lam = entropy_production_rate(S, t, k_B=k_B)

    # Trapezoid integration for tau_ent
    tau = np.empty_like(t)
    tau[0] = 0.0
    for i in range(1, len(t)):
        dt = t[i] - t[i - 1]
        tau[i] = tau[i - 1] + 0.5 * (lam[i] + lam[i - 1]) * dt
    return S, lam, tau
