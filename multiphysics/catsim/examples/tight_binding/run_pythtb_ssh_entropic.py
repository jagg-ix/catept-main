"""PythTB + CAT/EPT wiring demo (SSH chain at fixed k).

This example:
1) Builds the 1D SSH tight-binding model in PythTB.
2) Evolves an initial Bloch state at a fixed k point.
3) Compares coordinate-time stepping vs entropic-time stepping.

The purpose is to validate the plumbing:
- PythTB provides H_R(k)
- CAT/EPT provides optional H_I (damping) and tau mapping
- metric redshift can be inserted via `MetricField`

Run:

  pip install -e '.[pythtb]'
  PYTHONPATH=src python examples/tight_binding/run_pythtb_ssh_entropic.py
"""

from __future__ import annotations

import numpy as np

from cat_ept_doubleslit.metrics.redshift import minkowski_metric
from cat_ept_doubleslit.tight_binding.pythtb_backend import (
    PythTBBackend,
    PythTBRunConfig,
    evolve_bloch_state_t,
    evolve_bloch_state_tau,
)


def make_ssh_model(t1: float = 1.0, t2: float = 1.5):
    # Soft import handled inside backend; import here for clarity.
    from pythtb import tb_model

    # 1D lattice with 2 orbitals in the unit cell.
    lat = [[1.0]]
    orb = [[0.0], [0.5]]
    model = tb_model(1, 1, lat, orb)
    # intracell hop
    model.set_hop(t1, 0, 1, [0])
    # intercell hop
    model.set_hop(t2, 1, 0, [1])
    return model


def main():
    model = make_ssh_model()
    backend = PythTBBackend(model)

    k = np.array([0.2])
    psi0 = np.array([1.0, 0.0], dtype=complex)

    # Simple constant imaginary term: H_I = gamma * I (pure damping).
    gamma = 0.05

    def H_I_fn(_k, _t, _psi):
        return gamma * np.eye(2)

    cfg = PythTBRunConfig(
        k=k,
        psi0=psi0,
        t0=0.0,
        t_final=10.0,
        dt=0.02,
        lambda_eff=2.0,
        H_I_fn=H_I_fn,
        metric=minkowski_metric(),
        use_entropic_time=False,
    )

    t_grid, tau_grid, psi_grid = evolve_bloch_state_t(backend, cfg)
    norms = np.linalg.norm(psi_grid, axis=1)
    print("Coordinate-time evolution:")
    print("  final t=", t_grid[-1], " final tau=", tau_grid[-1], " final ||psi||=", norms[-1])

    cfg_tau = PythTBRunConfig(
        **{**cfg.__dict__, "use_entropic_time": True, "dt": 0.02}  # interpret dt as d_tau
    )
    t2_grid, tau2_grid, psi2_grid = evolve_bloch_state_tau(backend, cfg_tau)
    norms2 = np.linalg.norm(psi2_grid, axis=1)
    print("Entropic-time evolution:")
    print("  final t=", t2_grid[-1], " final tau=", tau2_grid[-1], " final ||psi||=", norms2[-1])


if __name__ == "__main__":
    main()
