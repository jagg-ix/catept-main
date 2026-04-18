"""Backend comparison utilities.

These helpers cross-check small toy evolutions across backends.

They are designed to:
- avoid hard dependencies (QuTiP is optional),
- be numerically simple (dense matrices),
- support CAT/EPT reparameterization (tau stepping via lambda_eff).

Use these in examples/benchmarks and development work, not as production code.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

import numpy as np

from ..complex_action.nonhermitian import effective_generator_t, effective_generator_tau


def _matrix_exp_via_eig(a: np.ndarray) -> np.ndarray:
    """Dense expm via eigendecomposition (good for small matrices)."""
    w, v = np.linalg.eig(a)
    return (v @ np.diag(np.exp(w))) @ np.linalg.inv(v)


@dataclass(frozen=True)
class CompareResult:
    max_abs_error: float
    l2_error: float
    note: str = ""


def _qutip_available() -> bool:
    try:
        import qutip  # noqa: F401
        return True
    except Exception:
        return False


def dense_step_evolve_nonhermitian_t(
    H_R: np.ndarray,
    H_I: np.ndarray,
    psi0: np.ndarray,
    t_final: float,
    dt: float,
    hbar: float,
) -> np.ndarray:
    """Reference evolution using a dense matrix exponential each step."""
    psi = np.asarray(psi0, dtype=complex)
    t = 0.0
    while t + 1e-15 < t_final:
        dti = min(dt, t_final - t)
        G = effective_generator_t(H_R=H_R, H_I=H_I, hbar=hbar)
        U = _matrix_exp_via_eig(G * dti)
        psi = U @ psi
        t += dti
    return psi


def dense_step_evolve_nonhermitian_tau(
    H_R: np.ndarray,
    H_I: np.ndarray,
    psi0: np.ndarray,
    tau_final: float,
    dtau: float,
    lambda_eff: float,
    hbar: float,
) -> np.ndarray:
    """Dense evolution stepping in entropic proper time tau (constant lambda_eff)."""
    if lambda_eff <= 0:
        raise ValueError("lambda_eff must be > 0")
    psi = np.asarray(psi0, dtype=complex)
    tau = 0.0
    while tau + 1e-15 < tau_final:
        dti = min(dtau, tau_final - tau)
        G = effective_generator_tau(H_R=H_R, H_I=H_I, hbar=hbar, lam=lambda_eff)
        U = _matrix_exp_via_eig(G * dti)
        psi = U @ psi
        tau += dti
    return psi


def compare_dense_vs_qutip_nonhermitian_t(
    H_R: np.ndarray,
    H_I: np.ndarray,
    psi0: np.ndarray,
    t_final: float,
    dt: float,
    hbar: float = 1.054_571_817e-34,
) -> CompareResult:
    """Compare dense stepping vs QuTiP sesolve for coordinate-time evolution."""
    dense_final = dense_step_evolve_nonhermitian_t(H_R, H_I, psi0, t_final, dt, hbar)

    if not _qutip_available():
        return CompareResult(
            max_abs_error=float("nan"),
            l2_error=float("nan"),
            note="QuTiP not installed; dense_final computed only.",
        )

    from ..open_quantum.qutip_backend import evolve_nonhermitian_t

    tlist = np.arange(0.0, t_final + 1e-15, dt, dtype=float)
    res = evolve_nonhermitian_t(H_R, H_I, psi0, tlist_s=tlist, hbar=hbar)

    # QuTiP states are Qobj kets.
    import qutip as qt  # type: ignore

    q_final = np.asarray(qt.Qobj(res.states[-1]).full()).reshape(-1)

    diff = dense_final - q_final
    return CompareResult(
        max_abs_error=float(np.max(np.abs(diff))),
        l2_error=float(np.linalg.norm(diff)),
        note="OK",
    )


def compare_dense_vs_qutip_nonhermitian_tau(
    H_R: np.ndarray,
    H_I: np.ndarray,
    psi0: np.ndarray,
    tau_final: float,
    dtau: float,
    lambda_eff: float,
    hbar: float = 1.054_571_817e-34,
) -> CompareResult:
    """Compare dense tau stepping vs QuTiP tau mode (constant lambda_eff)."""
    dense_final = dense_step_evolve_nonhermitian_tau(
        H_R, H_I, psi0, tau_final, dtau, lambda_eff, hbar
    )

    if not _qutip_available():
        return CompareResult(
            max_abs_error=float("nan"),
            l2_error=float("nan"),
            note="QuTiP not installed; dense_final computed only.",
        )

    from ..open_quantum.qutip_backend import evolve_nonhermitian_tau

    taulist = np.arange(0.0, tau_final + 1e-15, dtau, dtype=float)
    res = evolve_nonhermitian_tau(
        H_R, H_I, psi0, taulist=taulist, lambda_eff=lambda_eff, hbar=hbar
    )

    import qutip as qt  # type: ignore

    q_final = np.asarray(qt.Qobj(res.states[-1]).full()).reshape(-1)
    diff = dense_final - q_final
    return CompareResult(
        max_abs_error=float(np.max(np.abs(diff))),
        l2_error=float(np.linalg.norm(diff)),
        note="OK",
    )
