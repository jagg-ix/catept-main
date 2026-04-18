"""Optional PythTB backend.

Goals:
1) Make PythTB models usable as Hamiltonian providers in the simulator.
2) Provide a minimal evolution loop compatible with:
   - coordinate time (t)
   - entropic proper time (tau_ent) via d tau = lambda dt
   - complex-action/non-Hermitian evolution via H = H_R - i H_I.

PythTB itself focuses on *static* tight-binding models and Berry-phase style
post-processing. Here we wrap it in a small adapter layer so it fits the same
"backend" shape as QuTiP/FDTD/TeNPy.

This module is *soft-import safe*: it can be imported without pythtb installed.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Iterable, Optional, Tuple

import numpy as np

from ..clock.entropic_clock import EntropicClock
from ..complex_action.nonhermitian import (
    effective_generator_t,
    effective_generator_tau,
)
from ..metrics.redshift import MetricField, minkowski_metric


def has_pythtb() -> bool:
    try:
        import pythtb  # noqa: F401

        return True
    except Exception:
        return False


def _require_pythtb():
    if not has_pythtb():
        raise ImportError(
            "PythTB is not installed. Install with: pip install -e '.[pythtb]'"
        )


def _matrix_exp_via_eigh(a: np.ndarray) -> np.ndarray:
    """Compute expm(a) for a (small) dense matrix via eigendecomposition.

    For PythTB use cases the Hamiltonian matrices are typically small
    (number of orbitals per cell).
    """

    w, v = np.linalg.eig(a)
    # exp(A) = V diag(exp(w)) V^{-1}
    return (v @ np.diag(np.exp(w))) @ np.linalg.inv(v)


@dataclass(frozen=True)
class PythTBRunConfig:
    """Configuration for Bloch-state evolution at a fixed k-point.

    Attributes:
        k: k-point in reciprocal coordinates (length = dim_k).
        psi0: initial state vector in orbital basis.
        t0: starting coordinate time.
        t_final: ending coordinate time.
        dt: coordinate time step (seconds) OR tau step if use_entropic_time.
        lambda_eff: constant lambda used for tau mapping when use_entropic_time.
        hbar: Planck constant over 2pi (J*s).
        H_I_fn: optional imaginary Hamiltonian term provider H_I(k, t, psi).
        metric: optional metric field used to redshift lambda (sqrt(-g00)).
        use_entropic_time: if True, integrates in tau with constant lambda_eff.
    """

    k: np.ndarray
    psi0: np.ndarray
    t0: float
    t_final: float
    dt: float
    lambda_eff: float = 1.0
    hbar: float = 1.054_571_817e-34
    H_I_fn: Optional[Callable[[np.ndarray, float, np.ndarray], np.ndarray]] = None
    metric: MetricField = minkowski_metric()
    use_entropic_time: bool = False


class PythTBBackend:
    """Wrap a PythTB tb_model as a Hamiltonian provider."""

    def __init__(self, tb_model):
        _require_pythtb()
        self.model = tb_model

    def hamiltonian(self, k: np.ndarray) -> np.ndarray:
        """Return the Bloch Hamiltonian H_R(k) in the orbital basis."""

        # PythTB returns a numpy matrix/array.
        return np.asarray(self.model._gen_ham(k))


def evolve_bloch_state_t(
    backend: PythTBBackend,
    cfg: PythTBRunConfig,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Evolve a Bloch state at fixed k using coordinate time steps.

    Returns (t_grid, tau_grid, psi_grid)
    - tau_grid is computed via tau = ∫ lambda dt using lambda_eff redshifted.
    """

    H_R = backend.hamiltonian(cfg.k)

    # Redshift lambda if a metric is provided.
    z = cfg.metric.redshift_factor()
    lam = max(cfg.lambda_eff * z, 0.0)
    clock = EntropicClock(lambda_fn=lambda _t: lam)

    times: list[float] = [cfg.t0]
    taus: list[float] = [0.0]
    psis: list[np.ndarray] = [np.asarray(cfg.psi0, dtype=complex)]

    t = cfg.t0
    tau = 0.0
    while t + 1e-15 < cfg.t_final:
        dt = min(cfg.dt, cfg.t_final - t)

        H_I = (
            np.zeros_like(H_R)
            if cfg.H_I_fn is None
            else np.asarray(cfg.H_I_fn(cfg.k, t, psis[-1]))
        )

        G = effective_generator_t(H_R=H_R, H_I=H_I, hbar=cfg.hbar)
        U = _matrix_exp_via_eigh(G * dt)
        psi_next = U @ psis[-1]

        t_next = t + dt
        tau_next = tau + clock.dtau_from_dt(t, dt)

        times.append(t_next)
        taus.append(tau_next)
        psis.append(psi_next)

        t, tau = t_next, tau_next

    return np.asarray(times), np.asarray(taus), np.vstack(psis)


def evolve_bloch_state_tau(
    backend: PythTBBackend,
    cfg: PythTBRunConfig,
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Evolve a Bloch state at fixed k using tau-steps.

    Here cfg.dt is interpreted as d_tau per step.
    Coordinate time is reconstructed as dt = d_tau / (lambda_eff * redshift).
    """

    H_R = backend.hamiltonian(cfg.k)
    z = cfg.metric.redshift_factor()
    lam = max(cfg.lambda_eff * z, 1e-30)

    times: list[float] = [cfg.t0]
    taus: list[float] = [0.0]
    psis: list[np.ndarray] = [np.asarray(cfg.psi0, dtype=complex)]

    t = cfg.t0
    tau = 0.0
    while t + 1e-15 < cfg.t_final:
        d_tau = cfg.dt
        dt = min(d_tau / lam, cfg.t_final - t)
        d_tau = dt * lam

        H_I = (
            np.zeros_like(H_R)
            if cfg.H_I_fn is None
            else np.asarray(cfg.H_I_fn(cfg.k, t, psis[-1]))
        )

        G_tau = effective_generator_tau(H_R=H_R, H_I=H_I, hbar=cfg.hbar, lam=lam)
        U = _matrix_exp_via_eigh(G_tau * d_tau)
        psi_next = U @ psis[-1]

        t_next = t + dt
        tau_next = tau + d_tau

        times.append(t_next)
        taus.append(tau_next)
        psis.append(psi_next)

        t, tau = t_next, tau_next

    return np.asarray(times), np.asarray(taus), np.vstack(psis)
