"""QuTiP backend.

This backend provides reference evolution for:
  1) unitary Schrödinger evolution (sesolve),
  2) GKLS/Lindblad evolution (mesolve), and
  3) non-Hermitian evolution H = H_R - i H_I.

It also supports evolving in entropic proper time by rescaling the generator
according to tau_ent = ∫ lambda dt.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Sequence, Tuple

import numpy as np


def _require_qutip():
    try:
        import qutip as qt  # type: ignore
    except Exception as e:  # pragma: no cover
        raise ImportError(
            "QuTiP is required for this backend. Install with: pip install -e '.[qutip]'"
        ) from e
    return qt


@dataclass(frozen=True)
class QutipResult:
    tlist: np.ndarray
    states: List[object]
    expect: Dict[str, np.ndarray]


def evolve_nonhermitian_t(
    H_R: np.ndarray,
    H_I: np.ndarray,
    psi0: np.ndarray,
    tlist_s: np.ndarray,
    hbar: float = 1.054_571_817e-34,
    normalize_output: bool = False,
    e_ops: Optional[Dict[str, np.ndarray]] = None,
):
    """Evolve iħ dψ/dt = (H_R - i H_I) ψ using QuTiP's sesolve.

    Notes
    -----
    This is intended for small Hilbert spaces (toy models, validation cases).
    """

    qt = _require_qutip()

    H = (H_R - 1j * H_I) / hbar
    H_q = qt.Qobj(H)
    psi_q = qt.Qobj(psi0)
    tlist_s = np.asarray(tlist_s, dtype=float)

    q_e_ops = None
    if e_ops:
        q_e_ops = {k: qt.Qobj(v) for k, v in e_ops.items()}

    res = qt.sesolve(
        H_q,
        psi_q,
        tlist_s,
        e_ops=q_e_ops,
        options=qt.Options(normalize_output=normalize_output),
    )

    expect = {}
    if e_ops:
        for i, k in enumerate(e_ops.keys()):
            expect[k] = np.asarray(res.expect[i], dtype=float)

    return QutipResult(tlist=tlist_s, states=list(res.states), expect=expect)


def evolve_gkls_t(
    H_R: np.ndarray,
    rho0: np.ndarray,
    tlist_s: np.ndarray,
    c_ops: Sequence[np.ndarray],
    hbar: float = 1.054_571_817e-34,
    e_ops: Optional[Dict[str, np.ndarray]] = None,
):
    """Evolve GKLS/Lindblad master equation using QuTiP's mesolve."""

    qt = _require_qutip()
    H = H_R / hbar
    H_q = qt.Qobj(H)
    rho_q = qt.Qobj(rho0)
    tlist_s = np.asarray(tlist_s, dtype=float)

    q_c_ops = [qt.Qobj(c) for c in c_ops]

    q_e_ops = None
    if e_ops:
        q_e_ops = {k: qt.Qobj(v) for k, v in e_ops.items()}

    res = qt.mesolve(H_q, rho_q, tlist_s, c_ops=q_c_ops, e_ops=q_e_ops)

    expect = {}
    if e_ops:
        for i, k in enumerate(e_ops.keys()):
            expect[k] = np.asarray(res.expect[i], dtype=float)

    return QutipResult(tlist=tlist_s, states=list(res.states), expect=expect)


def reparameterize_t_to_tau(tlist_s: np.ndarray, lambda_values: np.ndarray) -> np.ndarray:
    """Compute tau(t) by trapezoid integration."""
    t = np.asarray(tlist_s, dtype=float)
    lam = np.asarray(lambda_values, dtype=float)
    if t.shape != lam.shape:
        raise ValueError("tlist_s and lambda_values must have the same shape")
    tau = np.empty_like(t)
    tau[0] = 0.0
    for i in range(1, len(t)):
        dt = t[i] - t[i - 1]
        tau[i] = tau[i - 1] + 0.5 * (lam[i] + lam[i - 1]) * dt
    return tau


def evolve_nonhermitian_tau(
    H_R: np.ndarray,
    H_I: np.ndarray,
    psi0: np.ndarray,
    taulist: np.ndarray,
    lambda_eff: float,
    hbar: float = 1.054_571_817e-34,
    normalize_output: bool = False,
    e_ops: Optional[Dict[str, np.ndarray]] = None,
):
    """Evolve in entropic proper time tau assuming constant lambda_eff.

    From reparameterization:
        i ħ dψ/dτ = (H_R - i H_I)/λ ψ.

    This is a useful *validation mode* and a practical mode for cases where
    lambda can be treated as constant on a window.
    """

    if lambda_eff <= 0:
        raise ValueError("lambda_eff must be > 0 for tau evolution")
    H_Rs = H_R / float(lambda_eff)
    H_Is = H_I / float(lambda_eff)
    return evolve_nonhermitian_t(
        H_Rs,
        H_Is,
        psi0,
        tlist_s=np.asarray(taulist, dtype=float),
        hbar=hbar,
        normalize_output=normalize_output,
        e_ops=e_ops,
    )


def evolve_complex_action_variable_lambda_t(
    H_R: np.ndarray,
    J: np.ndarray,
    psi0: np.ndarray,
    tlist_s: np.ndarray,
    lambda_fn: Callable[[float], float],
    hbar: float = 1.054_571_817e-34,
    normalize_output: bool = False,
    e_ops: Optional[Dict[str, np.ndarray]] = None,
) -> Tuple[QutipResult, np.ndarray, np.ndarray]:
    """Evolve a complex-action generator with *time-dependent* lambda(t).

    Implements the CAT/EPT-compatible form:

        i ħ dψ/dt = (H_R - i ħ λ(t) J) ψ

    where J is a Hermitian operator representing the dissipative channel.

    Returns
    -------
    (result, lambda_values, tau_ent_values)
        tau_ent is computed as tau_ent(t) = ∫ λ(t) dt via trapezoid rule.
    """

    qt = _require_qutip()

    t = np.asarray(tlist_s, dtype=float)
    lam = np.asarray([float(lambda_fn(float(tt))) for tt in t], dtype=float)
    if np.any(lam < 0):
        raise ValueError("lambda_fn produced negative values; CAT/EPT requires lambda >= 0")

    # Prebuild Qobj operators
    H_Rq = qt.Qobj(np.asarray(H_R, dtype=complex) / hbar)
    Jq = qt.Qobj(np.asarray(J, dtype=complex))
    psi_q = qt.Qobj(np.asarray(psi0, dtype=complex))

    # Time-dependent coefficient for the imaginary sector: -i * lambda(t) * J
    def lam_coeff(tt, _args):
        return float(lambda_fn(float(tt)))

    H = [H_Rq, [-1j * Jq, lam_coeff]]

    q_e_ops = None
    if e_ops:
        q_e_ops = {k: qt.Qobj(v) for k, v in e_ops.items()}

    res = qt.sesolve(
        H,
        psi_q,
        t,
        e_ops=q_e_ops,
        options=qt.Options(normalize_output=normalize_output),
    )

    expect = {}
    if e_ops:
        for i, k in enumerate(e_ops.keys()):
            expect[k] = np.asarray(res.expect[i], dtype=float)

    tau = reparameterize_t_to_tau(t, lam)
    return QutipResult(tlist=t, states=list(res.states), expect=expect), lam, tau


def evolve_complex_action_tau_from_profile(
    H_R: np.ndarray,
    J: np.ndarray,
    psi0: np.ndarray,
    tlist_s: np.ndarray,
    lambda_fn: Callable[[float], float],
    hbar: float = 1.054_571_817e-34,
    normalize_output: bool = False,
    e_ops: Optional[Dict[str, np.ndarray]] = None,
) -> Tuple[QutipResult, np.ndarray, np.ndarray]:
    """Evolve in entropic time tau using a time-dependent lambda profile.

    Uses reparameterization dτ = λ(t) dt.

    The entropic-time generator is taken as:

        i ħ dψ/dτ = (H_R/λ(t(τ)) - i ħ J) ψ

    This keeps the imaginary sector constant in τ while rescaling the
    Hamiltonian part by 1/λ.

    Returns (result, lambda_values_on_t, tau_values_on_t).
    """

    qt = _require_qutip()
    t = np.asarray(tlist_s, dtype=float)
    lam_t = np.asarray([float(lambda_fn(float(tt))) for tt in t], dtype=float)
    if np.any(lam_t <= 0):
        raise ValueError("lambda_fn must be > 0 for tau evolution")

    tau_t = reparameterize_t_to_tau(t, lam_t)

    # Build interpolation from tau -> 1/lambda(t(tau)).
    # We keep this simple and deterministic using linear interpolation.
    def inv_lambda_of_tau(tau, _args):
        return float(np.interp(float(tau), tau_t, 1.0 / lam_t))

    H_Rq = qt.Qobj(np.asarray(H_R, dtype=complex) / hbar)
    Jq = qt.Qobj(np.asarray(J, dtype=complex))
    psi_q = qt.Qobj(np.asarray(psi0, dtype=complex))

    H = [[H_Rq, inv_lambda_of_tau], -1j * Jq]

    q_e_ops = None
    if e_ops:
        q_e_ops = {k: qt.Qobj(v) for k, v in e_ops.items()}

    res = qt.sesolve(
        H,
        psi_q,
        tau_t,
        e_ops=q_e_ops,
        options=qt.Options(normalize_output=normalize_output),
    )

    expect = {}
    if e_ops:
        for i, k in enumerate(e_ops.keys()):
            expect[k] = np.asarray(res.expect[i], dtype=float)

    return QutipResult(tlist=tau_t, states=list(res.states), expect=expect), lam_t, tau_t
