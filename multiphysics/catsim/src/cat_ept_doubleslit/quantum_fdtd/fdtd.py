"""A tiny explicit TDSE solver (baseline validator).

This intentionally favors simplicity over performance/robustness; for production
use an unconditionally stable method (Crank-Nicolson) or a dedicated library.

We implement an explicit forward-Euler step:
    psi_{n+1} = psi_n - i dt / ħ * H psi_n

For stability, dt must scale like O(dx^2) for the kinetic term. We compute a
conservative dt suggestion by default and optionally clamp using a CFLClock-like
interface.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Optional

import numpy as np

from .observables import HBAR, M_E, E_CHARGE, compute_observables


def _laplacian_matrix(N: int, dx: float) -> np.ndarray:
    lap = np.zeros((N, N), dtype=float)
    for i in range(1, N - 1):
        lap[i, i - 1] = 1.0
        lap[i, i] = -2.0
        lap[i, i + 1] = 1.0
    lap /= dx**2
    return lap


@dataclass
class FDTDSolverResult:
    x: np.ndarray
    t: np.ndarray
    psi_t: list[np.ndarray]
    observables_t: list[dict]
    dt_s: float


def suggest_dt_tdse(dx: float, m: float = M_E, safety: float = 0.2) -> float:
    """A conservative explicit-step suggestion for TDSE.

    For the kinetic operator eigenvalues ~ O(1/dx^2), explicit Euler requires a
    dt that shrinks like m dx^2 / ħ. The exact stability region depends on the
    integrator; we use a conservative constant.
    """
    dx = float(dx)
    if dx <= 0:
        raise ValueError("dx must be positive")
    return float(safety) * (2.0 * float(m) * dx**2 / HBAR)


def fdtd_tdse(
    U_eV: np.ndarray,
    x: np.ndarray,
    psi0: np.ndarray,
    Nt: int,
    dt_s: float | None = None,
    m: float = M_E,
    record_every: int = 100,
) -> FDTDSolverResult:
    """Propagate a 1D wavefunction under a static potential.

    Args:
        U_eV: potential array in eV
        x: position grid (m)
        psi0: initial wavefunction, complex numpy array
        Nt: number of steps
        dt_s: optional explicit step (seconds). If None, choose a conservative
              dt based on dx.
        m: particle mass (kg)
        record_every: record every k steps

    Returns:
        FDTDSolverResult with snapshots.
    """
    Nt = int(Nt)
    if Nt <= 0:
        raise ValueError("Nt must be positive")

    x = np.asarray(x, dtype=float)
    dx = float(x[1] - x[0])
    N = len(x)

    U_eV = np.asarray(U_eV, dtype=float)
    if len(U_eV) != N:
        raise ValueError("U_eV and x must have same length")

    psi = np.asarray(psi0, dtype=complex).copy()

    if dt_s is None:
        dt_s = suggest_dt_tdse(dx, m=m)
    dt_s = float(dt_s)

    # Hamiltonian as dense matrix (fine for small demo grids)
    lap = _laplacian_matrix(N, dx)
    H = (-(HBAR**2) / (2.0 * float(m))) * lap + np.diag(U_eV * E_CHARGE)

    psi_t: list[np.ndarray] = []
    observables_t: list[dict] = []
    t_samples: list[float] = []

    for n in range(Nt + 1):
        if n % max(1, int(record_every)) == 0:
            psi_t.append(psi.copy())
            observables_t.append(compute_observables(psi, U_eV, x, m=m))
            t_samples.append(n * dt_s)

        if n == Nt:
            break

        psi = psi - 1j * dt_s / HBAR * (H @ psi)

        # Hard Dirichlet boundaries (absorbing layers would be better)
        psi[0] = 0.0
        psi[-1] = 0.0

        # renormalize gently to control Euler drift (baseline validator)
        norm = np.sqrt(np.sum(np.abs(psi) ** 2) * dx)
        if norm > 0:
            psi = psi / norm

    return FDTDSolverResult(
        x=x,
        t=np.asarray(t_samples, dtype=float),
        psi_t=psi_t,
        observables_t=observables_t,
        dt_s=dt_s,
    )


def fdtd_tdse_complex_action(
    U_eV: np.ndarray,
    Gamma_eV: np.ndarray,
    x: np.ndarray,
    psi0: np.ndarray,
    Nt: int,
    dt_s: float | None = None,
    *,
    m: float = M_E,
    record_every: int = 100,
    lambda_fn: Optional[Callable[[float, np.ndarray], float]] = None,
    use_entropic_time: bool = False,
    lambda_floor: float = 0.0,
):
    """TDSE with a non-Hermitian (complex-action) term.

    We simulate:
        i ħ dψ/dt = (H_R - i H_I) ψ

    where:
        H_R = kinetic + U(x)
        H_I = diag(Gamma(x))

    If ``use_entropic_time=True`` we step in entropic proper time τ and use
    the reparameterized generator:

        i ħ dψ/dτ = (H_R - i H_I)/λ ψ

    where λ(t) is supplied by ``lambda_fn(t, state)->1/s``.
    """

    Nt = int(Nt)
    if Nt <= 0:
        raise ValueError("Nt must be positive")

    x = np.asarray(x, dtype=float)
    dx = float(x[1] - x[0])
    N = len(x)

    U_eV = np.asarray(U_eV, dtype=float)
    Gamma_eV = np.asarray(Gamma_eV, dtype=float)
    if len(U_eV) != N or len(Gamma_eV) != N:
        raise ValueError("U_eV, Gamma_eV and x must have same length")

    psi = np.asarray(psi0, dtype=complex).copy()

    if dt_s is None:
        dt_s = suggest_dt_tdse(dx, m=m)
    dt_s = float(dt_s)

    lap = _laplacian_matrix(N, dx)
    H_R = (-(HBAR**2) / (2.0 * float(m))) * lap + np.diag(U_eV * E_CHARGE)
    H_I = np.diag(Gamma_eV * E_CHARGE)

    psi_t: list[np.ndarray] = []
    observables_t: list[dict] = []
    t_samples: list[float] = []

    tau = 0.0
    t = 0.0

    def lam_at(t_s: float) -> float:
        if lambda_fn is None:
            return 1.0
        lam = float(lambda_fn(t_s, psi))
        if lam < 0:
            raise ValueError("lambda must be >= 0")
        return lam

    for n in range(Nt + 1):
        if n % max(1, int(record_every)) == 0:
            psi_t.append(psi.copy())
            obs = compute_observables(psi, U_eV, x, m=m)
            obs["tau_ent"] = float(tau)
            obs["lambda"] = float(lam_at(t)) if lambda_fn is not None else 1.0
            observables_t.append(obs)
            t_samples.append(t)

        if n == Nt:
            break

        lam = lam_at(t)
        lam_eff = max(lam, float(lambda_floor))
        if use_entropic_time:
            if lam_eff <= 0:
                raise ValueError("lambda=0: cannot step in entropic time without lambda_floor")
            # step variable is tau; we interpret dt_s as d(tau) when in entropic mode
            dtau = dt_s
            dt = dtau / lam_eff
        else:
            dt = dt_s
            dtau = lam * dt

        # Euler step for non-Hermitian generator
        psi = psi + dt * ((-1j / HBAR) * (H_R @ psi) - (1.0 / HBAR) * (H_I @ psi))

        psi[0] = 0.0
        psi[-1] = 0.0

        norm = np.sqrt(np.sum(np.abs(psi) ** 2) * dx)
        if norm > 0:
            psi = psi / norm

        t += dt
        tau += dtau

    return FDTDSolverResult(
        x=x,
        t=np.asarray(t_samples, dtype=float),
        psi_t=psi_t,
        observables_t=observables_t,
        dt_s=dt_s,
    )
