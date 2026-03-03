"""OQuPy backend (optional).

OQuPy (Open Quantum Systems in Python) supports non-Markovian open-system
simulations (e.g., TEMPO). In this repo we use it as a **lambda/tau_ent provider**
and as a reference reduced-dynamics engine.

We keep the integration minimal:
  - run a TEMPO calculation (when available),
  - compute von Neumann entropy S(t) of the reduced state,
  - approximate lambda(t) = (1/k_B) dS/dt (up to user-chosen conventions),
  - return tau_ent(t) = ∫ lambda dt.

This file is guarded by soft-import; users must install the optional extra:
    pip install -e '.[oqupy]'
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, Optional, Tuple

import numpy as np


K_B = 1.380_649e-23


def _require_oqupy():
    try:
        import oqupy  # type: ignore
    except Exception as e:  # pragma: no cover
        raise ImportError(
            "OQuPy is required for this backend. Install with: pip install -e '.[oqupy]'"
        ) from e
    return oqupy


def von_neumann_entropy(rho: np.ndarray, base: float = np.e) -> float:
    """Compute S = -Tr rho log rho."""
    rho = np.asarray(rho, dtype=complex)
    w = np.linalg.eigvalsh((rho + rho.conjugate().T) / 2.0)
    w = np.clip(w.real, 0.0, 1.0)
    nz = w[w > 0]
    return float(-(nz * (np.log(nz) / np.log(base))).sum())


@dataclass(frozen=True)
class OqupyEntropyTrace:
    tlist_s: np.ndarray
    entropy: np.ndarray
    lambda_s_inv: np.ndarray
    tau_ent: np.ndarray


def entropy_trace_from_states(
    tlist_s: np.ndarray,
    rho_t: np.ndarray,
    *,
    k_B: float = K_B,
    entropy_base: float = np.e,
) -> OqupyEntropyTrace:
    """Given rho(t) samples, compute S(t), lambda(t)= (1/k_B) dS/dt, tau(t)."""
    t = np.asarray(tlist_s, dtype=float)
    if rho_t.ndim != 3:
        raise ValueError("rho_t must be shape (T, d, d)")

    S = np.array([von_neumann_entropy(rho_t[i], base=entropy_base) for i in range(len(t))], dtype=float)
    # Simple finite difference for dS/dt
    dSdt = np.gradient(S, t, edge_order=1)
    lam = np.maximum(0.0, dSdt / float(k_B))
    # Trapezoid integration tau = ∫ lambda dt
    tau = np.empty_like(t)
    tau[0] = 0.0
    for i in range(1, len(t)):
        dt = t[i] - t[i - 1]
        tau[i] = tau[i - 1] + 0.5 * (lam[i] + lam[i - 1]) * dt
    return OqupyEntropyTrace(tlist_s=t, entropy=S, lambda_s_inv=lam, tau_ent=tau)


def tempo_spin_boson_entropy_trace(
    *,
    tlist_s: np.ndarray,
    H_sys: np.ndarray,
    rho0: np.ndarray,
    coupling_op: np.ndarray,
    bath: Any,
    tempo_parameters: Any,
    k_B: float = K_B,
) -> OqupyEntropyTrace:
    """Run a TEMPO simulation and return entropy/lambda/tau traces.

    Parameters are intentionally generic to avoid overconstraining user choices.
    """
    oqupy = _require_oqupy()

    system = oqupy.System(oqupy.operators.from_matrix(H_sys))
    initial_state = oqupy.operators.from_matrix(rho0)
    coup = oqupy.operators.from_matrix(coupling_op)

    # TEMPO object creation depends on OQuPy version; we keep this intentionally minimal.
    tempo = oqupy.Tempo(
        system=system,
        bath=bath,
        initial_state=initial_state,
        parameters=tempo_parameters,
        coupling_operator=coup,
    )
    dyn = tempo.compute_dynamics()
    # OQuPy Dynamics exposes density matrices; try common accessors.
    if hasattr(dyn, "states"):
        rho_list = dyn.states
    elif hasattr(dyn, "rho_t"):
        rho_list = dyn.rho_t
    else:
        raise TypeError("Unsupported OQuPy Dynamics object; cannot extract rho(t)")

    rho_t = np.asarray([np.asarray(r) for r in rho_list], dtype=complex)
    return entropy_trace_from_states(tlist_s=tlist_s, rho_t=rho_t, k_B=k_B)
