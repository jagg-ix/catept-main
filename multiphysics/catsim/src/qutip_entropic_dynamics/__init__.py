"""QuTiP Entropic Dynamics — entropic proper-time extensions for QuTiP.

This package consolidates the CAT/EPT (Constructive Approximation Theory /
Entropic Proper Time) framework into a self-contained library structured
for eventual contribution to QuTiP.

Core modules (no QuTiP dependency)
----------------------------------
- :mod:`entropy` — von Neumann entropy, production rate, relative entropy
- :mod:`reparameterize` — coordinate time <-> entropic proper time transforms
- :mod:`result` — ``EntropicResult`` container

Solver modules (require QuTiP)
------------------------------
- :mod:`dynamics` — Lindblad, Schrodinger, complex-action, and tau solvers
- :mod:`nonmarkov` — TEMPO non-Markovian dynamics (requires OQuPy)

Analysis modules
----------------
- :mod:`analysis` — decoherence timescales, regime classification
- :mod:`enz` — ENZ material dispersion and frequency-dependent visibility

Quick start
-----------
>>> from qutip_entropic_dynamics import entropy_vn, tau_from_lambda
>>> from qutip_entropic_dynamics import entropic_mesolve  # requires qutip
"""

from __future__ import annotations

__version__ = "0.1.0"

# --- Core (always available) ------------------------------------------------

from .entropy import (
    entropy_vn,
    entropy_production_rate,
    entropy_relative,
    entropy_trace,
)

from .reparameterize import (
    LambdaProfile,
    tau_from_lambda,
    tau_entropic,
    lambda0_from_cfl,
)

from .result import EntropicResult

# --- ENZ (always available, numpy-only) -------------------------------------

from .enz import (
    DrudeParams,
    DRUDE_ITO,
    DRUDE_AZO,
    DRUDE_GZO,
    eps_drude,
    refractive_index,
    group_velocity_drude,
    enz_frequency,
    enz_wavelength,
    enhancement_factor,
    enz_decoherence_rate,
    frequency_dependent_visibility,
)

# --- Analysis (mostly numpy, some functions need qutip) --------------------

from .analysis import (
    quantum_classical_boundary,
    analyze_qubit,
    analyze_cavity,
)

# --- Solvers (lazy imports — only fail when called without qutip) -----------

def __getattr__(name: str):
    """Lazy import for solver functions that require qutip/oqupy."""
    _dynamics_names = {
        "entropic_mesolve",
        "entropic_sesolve",
        "evolve_complex_action",
        "evolve_in_tau",
    }
    _nonmarkov_names = {"entropic_tempo"}
    _analysis_qutip_names = {
        "decoherence_timescales",
        "quantum_speed_limit",
    }

    if name in _dynamics_names:
        from . import dynamics
        return getattr(dynamics, name)
    if name in _nonmarkov_names:
        from . import nonmarkov
        return getattr(nonmarkov, name)
    if name in _analysis_qutip_names:
        from . import analysis
        return getattr(analysis, name)

    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")


__all__ = [
    # result
    "EntropicResult",
    # entropy
    "entropy_vn",
    "entropy_production_rate",
    "entropy_relative",
    "entropy_trace",
    # reparameterize
    "LambdaProfile",
    "tau_from_lambda",
    "tau_entropic",
    "lambda0_from_cfl",
    # enz
    "DrudeParams",
    "DRUDE_ITO",
    "DRUDE_AZO",
    "DRUDE_GZO",
    "eps_drude",
    "refractive_index",
    "group_velocity_drude",
    "enz_frequency",
    "enz_wavelength",
    "enhancement_factor",
    "enz_decoherence_rate",
    "frequency_dependent_visibility",
    # analysis
    "quantum_classical_boundary",
    "analyze_qubit",
    "analyze_cavity",
    "decoherence_timescales",
    "quantum_speed_limit",
    # dynamics (lazy)
    "entropic_mesolve",
    "entropic_sesolve",
    "evolve_complex_action",
    "evolve_in_tau",
    # nonmarkov (lazy)
    "entropic_tempo",
]
