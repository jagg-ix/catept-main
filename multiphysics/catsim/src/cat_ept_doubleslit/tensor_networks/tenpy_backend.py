r"""TeNPy integration (optional).

This module provides a thin compatibility layer between this simulator and
TeNPy (Tensor Network Python) for 1D lattice dynamics (MPS/TEBD).

Key idea for CAT/EPT usage:
- Keep the physical dynamics defined in coordinate time t.
- Allow stepping in an alternative monotone clock \tau (e.g., entropic proper time)
  with mapping d\tau = \lambda(t) dt.
- For explicit/TEBD stepping, we use dt = d\tau / \lambda_eff per step.

We do *not* claim TeNPy enforces relativistic causality; the CFL-style logic is
implemented separately in cat_ept_doubleslit.numerics.cfl_clock.

Install:
    pip install -e '.[tenpy]'

Notes:
- TeNPy is distributed on PyPI as `physics-tenpy`, but imported as `tenpy`.
  See TeNPy installation docs.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Tuple

import math

import numpy as np


def has_tenpy() -> bool:
    """Return True if the `tenpy` module is importable."""
    try:
        import tenpy  # noqa: F401

        return True
    except Exception:
        return False


@dataclass
class TEBDRunConfig:
    """Configuration for a simple TEBD run."""

    L: int = 20
    dt: complex = 0.02
    t_final: float = 2.0

    # Model: XXZ + optional field
    Jxy: float = 1.0
    Jz: float = 1.0
    hz: float = 0.0

    # TEBD
    chi_max: int = 100
    svd_min: float = 1e-10
    order: int = 2

    # Entropic clock
    use_entropic_time: bool = False
    lambda_eff: float = 1.0  # constant effective lambda (s^-1) for demo/validation


def _require_tenpy() -> None:
    if not has_tenpy():
        raise ImportError(
            "TeNPy is not installed. Install with `pip install physics-tenpy` "
            "or `pip install -e '.[tenpy]'` in this repo."
        )


def run_xxz_tebd(config: TEBDRunConfig) -> Dict[str, np.ndarray]:
    """Run a minimal XXZ TEBD simulation with TeNPy.

    Returns a dict containing:
      - 't': coordinate time samples
      - 'tau': entropic time samples (if enabled; else tau==t)
      - 'sz': expectation values <S^z_i> averaged over i

    The evolution step used by TEBD is `dt_step`.
    If `use_entropic_time=True`, we interpret `config.dt` as a step in \tau,
    and convert to coordinate time via dt = d\tau / lambda_eff.

    For a simple "complex action" demonstration, you may pass a complex
    `config.dt` (e.g., dt = dt_real - 1j*dt_imag), which corresponds to a
    complex-time evolution. Whether this is meaningful depends on the model
    and the user's interpretation; we keep it as an opt-in numerical facility.
    """

    _require_tenpy()

    # Import TeNPy lazily.
    from tenpy.algorithms import tebd
    from tenpy.models.spins import SpinChain
    from tenpy.networks.mps import MPS

    # Model params
    model_params = {
        "L": int(config.L),
        "S": 0.5,
        "Jx": float(config.Jxy),
        "Jy": float(config.Jxy),
        "Jz": float(config.Jz),
        "hz": float(config.hz),
        "bc_MPS": "finite",
    }
    model = SpinChain(model_params)

    # Initial state: Neel product state |up,down,up,down,...>
    product_state = ["up" if (i % 2 == 0) else "down" for i in range(config.L)]
    psi = MPS.from_product_state(model.lat.mps_sites(), product_state, bc="finite")

    # TEBD engine
    tebd_params = {
        "dt": config.dt,  # may be complex
        "order": int(config.order),
        "N_steps": 1,
        "trunc_params": {"chi_max": int(config.chi_max), "svd_min": float(config.svd_min)},
        "verbose": 0,
    }
    engine = tebd.Engine(psi, model, tebd_params)

    # Time bookkeeping
    if config.use_entropic_time:
        lam = max(float(config.lambda_eff), 1e-30)
        dt_coord = complex(config.dt) / lam
        dtau = complex(config.dt)
    else:
        dt_coord = complex(config.dt)
        dtau = complex(config.dt)

    n_steps = int(math.ceil(float(config.t_final) / float(abs(dt_coord.real) if dt_coord.real != 0 else abs(dt_coord))))
    n_steps = max(n_steps, 1)

    t_list: List[float] = [0.0]
    tau_list: List[float] = [0.0]
    sz_list: List[float] = [float(np.mean(psi.expectation_value("Sz")))]

    t = 0.0
    tau = 0.0

    for _ in range(n_steps):
        engine.run()

        # Update times using real parts for bookkeeping
        t += float(dt_coord.real)
        tau += float(dtau.real)

        t_list.append(t)
        tau_list.append(tau)
        sz_list.append(float(np.mean(psi.expectation_value("Sz"))))

        if t >= config.t_final:
            break

    return {
        "t": np.asarray(t_list, dtype=float),
        "tau": np.asarray(tau_list, dtype=float),
        "sz": np.asarray(sz_list, dtype=float),
    }
