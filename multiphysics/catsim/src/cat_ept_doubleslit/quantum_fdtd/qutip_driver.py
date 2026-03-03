"""QuTiP-based TDSE propagation.

Implements the idea from 23.md: build a finite-difference Hamiltonian and use
qt.sesolve for clean propagation and easy expectation values.

This is an optional backend: it raises ImportError if qutip is unavailable.
"""

from __future__ import annotations

import numpy as np

from .observables import HBAR, M_E, E_CHARGE, compute_observables

try:
    import qutip as qt

    QUTIP_AVAILABLE = True
except Exception:
    qt = None  # type: ignore
    QUTIP_AVAILABLE = False


def _laplacian_dense(N: int, dx: float) -> np.ndarray:
    lap = np.zeros((N, N), dtype=float)
    for i in range(1, N - 1):
        lap[i, i - 1] = 1.0
        lap[i, i] = -2.0
        lap[i, i + 1] = 1.0
    lap /= dx**2
    return lap


def run_qutip(
    U_eV: np.ndarray,
    x: np.ndarray,
    psi0: np.ndarray,
    tlist: np.ndarray,
    m: float = M_E,
    *,
    Gamma_eV: np.ndarray | None = None,
    normalize_output: bool = False,
):
    """Propagate using QuTiP sesolve.

    Args:
        U_eV: potential in eV
        x: position grid (m)
        psi0: initial complex wavefunction (normalized)
        tlist: array of times (s)
        m: particle mass (kg)

    Returns:
        states: list of QuTiP states
        obs_final: observables at final time
    """
    if not QUTIP_AVAILABLE:
        raise ImportError("QuTiP is required for run_qutip (pip install '.[qutip]')")

    x = np.asarray(x, dtype=float)
    dx = float(x[1] - x[0])
    N = len(x)

    U_eV = np.asarray(U_eV, dtype=float)
    if len(U_eV) != N:
        raise ValueError("U_eV and x must have same length")

    lap = _laplacian_dense(N, dx)
    H_R = (-(HBAR**2) / (2.0 * float(m))) * lap + np.diag(U_eV * E_CHARGE)

    if Gamma_eV is None:
        H = H_R
    else:
        Gamma_eV = np.asarray(Gamma_eV, dtype=float)
        if len(Gamma_eV) != N:
            raise ValueError("Gamma_eV and x must have same length")
        H_I = np.diag(Gamma_eV * E_CHARGE)
        H = H_R - 1j * H_I

    H_qobj = qt.Qobj(H)
    psi0_qobj = qt.Qobj(np.asarray(psi0, dtype=complex))

    result = qt.sesolve(
        H_qobj,
        psi0_qobj,
        np.asarray(tlist, dtype=float),
        options=qt.Options(normalize_output=normalize_output),
    )
    obs_final = compute_observables(result.states[-1], U_eV, x, m=m)

    return result.states, obs_final
