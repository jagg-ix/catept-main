"""Diagnostic analysis: decoherence timescales, regime classification.

Rewritten from ``qutip_catept_extension.py`` concepts to follow QuTiP
conventions: flat functions, NumPy-style docstrings, no singleton
classes.

Requires
--------
``qutip`` for operator-based analysis.  Pure-number functions
(``quantum_classical_boundary``, ``analyze_qubit``, ``analyze_cavity``)
work without QuTiP.
"""

from __future__ import annotations

from typing import Any, Dict, Optional, Tuple

import numpy as np

# Physical constants
K_B = 1.380_649e-23    # J/K
HBAR = 1.054_571_817e-34  # J s
K_B_EV = 8.617_333_262e-5  # eV/K


def _require_qutip():
    try:
        import qutip as qt  # type: ignore
    except ImportError as e:
        raise ImportError(
            "QuTiP is required for operator-based analysis.  "
            "Install with:  pip install qutip"
        ) from e
    return qt


def decoherence_timescales(
    c_ops: list,
    rho: Optional[Any] = None,
) -> Tuple[float, float]:
    """Extract T1 and T2 decoherence times from collapse operators.

    For a two-level system the conventions are:

    - ``T1 = 1 / gamma_1`` (energy relaxation via amplitude damping)
    - ``T2 = 1 / (gamma_1/2 + gamma_phi)`` (dephasing)

    where ``gamma_1 = <c_relax^dag c_relax>`` and
    ``gamma_phi = <c_deph^dag c_deph>``.

    Parameters
    ----------
    c_ops : list of Qobj
        Collapse operators.  The first 2x2 operator is assumed to be
        relaxation; subsequent 2x2 operators contribute to pure
        dephasing.
    rho : Qobj, optional
        Density matrix for computing expectation values.  If ``None``,
        rates are estimated from the operator norms.

    Returns
    -------
    T1 : float
        Energy relaxation time (seconds).
    T2 : float
        Dephasing time (seconds).

    Examples
    --------
    >>> import qutip as qt
    >>> gamma_1, gamma_phi = 1e3, 500
    >>> c_ops = [np.sqrt(gamma_1) * qt.sigmam(),
    ...          np.sqrt(gamma_phi) * qt.sigmaz()]
    >>> T1, T2 = decoherence_timescales(c_ops)
    """
    qt = _require_qutip()

    gamma_1 = 0.0
    gamma_phi = 0.0

    for c in c_ops:
        cdc = c.dag() * c
        if rho is not None:
            rate = float(qt.expect(cdc, rho).real)
        else:
            rate = float(np.real(np.trace(cdc.full())))

        if c.shape == (2, 2) and gamma_1 == 0.0:
            gamma_1 = rate
        else:
            gamma_phi += rate

    T1 = 1.0 / gamma_1 if gamma_1 > 0 else float("inf")
    denom = gamma_1 / 2.0 + gamma_phi
    T2 = 1.0 / denom if denom > 0 else float("inf")
    return T1, T2


def quantum_classical_boundary(
    H: Any,
    T: float,
) -> Dict[str, Any]:
    """Classify quantum vs classical regime.

    The classification uses the quantum parameter ``xi = E_gap / (k_B T)``:

    - ``xi > 10``: quantum regime
    - ``xi < 0.1``: classical regime
    - otherwise: intermediate

    Parameters
    ----------
    H : Qobj or float
        Hamiltonian (eigenenergies extracted) or energy scale (joules).
    T : float
        Temperature (kelvin).

    Returns
    -------
    dict
        Keys: ``regime``, ``xi``, ``E_quantum``, ``E_thermal``, ``T``.

    Examples
    --------
    >>> # Superconducting qubit at 20 mK
    >>> result = quantum_classical_boundary(HBAR * 2*np.pi*5e9, 0.02)
    >>> result['regime']
    'quantum'
    """
    if hasattr(H, "eigenenergies"):
        energies = H.eigenenergies()
        E_scale = float(energies[1] - energies[0]) if len(energies) > 1 else float(energies[0])
    elif isinstance(H, (int, float)):
        E_scale = float(H)
    else:
        raise TypeError("H must be a Qobj or a numeric energy scale")

    E_thermal = K_B * T
    xi = E_scale / E_thermal if E_thermal > 0 else float("inf")

    if xi > 10:
        regime = "quantum"
    elif xi < 0.1:
        regime = "classical"
    else:
        regime = "intermediate"

    return {
        "regime": regime,
        "xi": xi,
        "E_quantum": E_scale,
        "E_thermal": E_thermal,
        "T": T,
    }


def quantum_speed_limit(
    H: Any,
    psi_i: Any,
    psi_f: Any,
) -> float:
    """Mandelstam-Tamm quantum speed limit.

    Minimum time for a quantum state to evolve from ``|psi_i>`` to
    ``|psi_f>``:

        tau_QSL = hbar * arccos(|<psi_f|psi_i>|) / Delta_E

    Parameters
    ----------
    H : Qobj
        Hamiltonian.
    psi_i : Qobj
        Initial state ket.
    psi_f : Qobj
        Target state ket.

    Returns
    -------
    tau_QSL : float
        Quantum speed limit time (seconds).

    Examples
    --------
    >>> import qutip as qt
    >>> H = qt.sigmax()
    >>> tau = quantum_speed_limit(H, qt.basis(2, 0), qt.basis(2, 1))
    """
    qt = _require_qutip()

    inner = psi_f.dag() * psi_i
    # QuTiP 5 returns a scalar; QuTiP 4 returns a Qobj
    if hasattr(inner, "full"):
        overlap = abs(float(inner.full()[0, 0]))
    else:
        overlap = abs(complex(inner))
    overlap = min(overlap, 1.0)
    theta = np.arccos(overlap)

    E = float(qt.expect(H, psi_i))
    E2 = float(qt.expect(H * H, psi_i))
    Delta_E = np.sqrt(max(E2 - E**2, 0.0))

    if Delta_E > 0:
        return HBAR * theta / Delta_E
    return float("inf")


def analyze_qubit(
    omega: float = 2 * np.pi * 5e9,
    T1: float = 1e-3,
    T2: float = 0.5e-3,
    T: float = 0.02,
) -> Dict[str, float]:
    """Complete CAT/EPT characterisation of a superconducting qubit.

    Parameters
    ----------
    omega : float, optional
        Qubit frequency (rad/s), default 5 GHz.
    T1 : float, optional
        Energy relaxation time (s), default 1 ms.
    T2 : float, optional
        Dephasing time (s), default 0.5 ms.
    T : float, optional
        Temperature (K), default 20 mK.

    Returns
    -------
    dict
        Decoherence rates, thermal occupation, regime classification.
    """
    gamma_1 = 1.0 / T1
    gamma_phi = max(1.0 / T2 - gamma_1 / 2.0, 0.0)
    lambda_quantum = gamma_1 + gamma_phi

    if T > 0 and HBAR * omega / (K_B * T) < 500:
        n_thermal = 1.0 / (np.exp(HBAR * omega / (K_B * T)) - 1)
    else:
        n_thermal = 0.0

    regime = quantum_classical_boundary(HBAR * omega, T)

    return {
        "omega": omega,
        "frequency_GHz": omega / (2 * np.pi * 1e9),
        "T1": T1,
        "T2": T2,
        "T": T,
        "gamma_1": gamma_1,
        "gamma_phi": gamma_phi,
        "lambda_quantum": lambda_quantum,
        "n_thermal": n_thermal,
        "regime": regime["regime"],
        "xi": regime["xi"],
    }


def analyze_cavity(
    omega_c: float = 2 * np.pi * 10e9,
    kappa: float = 1e6,
    T: float = 0.02,
    n_photons: int = 10,
) -> Dict[str, float]:
    """Complete CAT/EPT characterisation of a cavity mode.

    Parameters
    ----------
    omega_c : float, optional
        Cavity frequency (rad/s), default 10 GHz.
    kappa : float, optional
        Cavity decay rate (1/s), default 1 MHz.
    T : float, optional
        Temperature (K), default 20 mK.
    n_photons : int, optional
        Average photon number, default 10.

    Returns
    -------
    dict
        Cavity parameters and CAT/EPT rates.
    """
    if T > 0 and HBAR * omega_c / (K_B * T) < 500:
        n_thermal = 1.0 / (np.exp(HBAR * omega_c / (K_B * T)) - 1)
    else:
        n_thermal = 0.0

    return {
        "omega_c": omega_c,
        "frequency_GHz": omega_c / (2 * np.pi * 1e9),
        "kappa": kappa,
        "T": T,
        "n_photons": n_photons,
        "n_thermal": n_thermal,
        "lambda_cavity": kappa * n_photons,
        "lambda_thermal": kappa * n_thermal,
        "Q_factor": omega_c / kappa,
        "tau_photon": 1.0 / kappa,
    }
