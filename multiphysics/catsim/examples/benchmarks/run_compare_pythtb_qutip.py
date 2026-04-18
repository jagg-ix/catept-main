"""Compare dense evolution vs QuTiP for a PythTB Hamiltonian.

This script builds a simple SSH model (2 orbitals) using PythTB, extracts the
Bloch Hamiltonian at a fixed k-point, then compares:
  1) dense expm stepping, and
  2) QuTiP sesolve,
for both coordinate time and entropic proper time (constant lambda_eff).

Usage:
  pip install -e '.[pythtb,qutip]'
  PYTHONPATH=src python examples/benchmarks/run_compare_pythtb_qutip.py
"""

from __future__ import annotations

import numpy as np

from cat_ept_doubleslit.benchmarks.compare_backends import (
    compare_dense_vs_qutip_nonhermitian_t,
    compare_dense_vs_qutip_nonhermitian_tau,
)
from cat_ept_doubleslit.tight_binding.pythtb_backend import PythTBBackend


def build_ssh_model(t1: float = 1.0, t2: float = 1.3):
    import pythtb  # type: ignore

    lat = [[1.0]]
    orb = [[0.0], [0.5]]
    model = pythtb.tb_model(1, 1, lat, orb)
    model.set_hop(t1, 0, 1, [0])
    model.set_hop(t2, 1, 0, [1])
    return model


def main() -> int:
    tb = build_ssh_model()
    backend = PythTBBackend(tb)

    k = np.asarray([0.2], dtype=float)
    H_R = backend.hamiltonian(k)

    # A small imaginary term to test non-Hermitian plumbing (damping on site 0).
    H_I = np.zeros_like(H_R)
    H_I[0, 0] = 0.05

    psi0 = np.asarray([1.0, 0.0], dtype=complex)

    print("Hamiltonian H_R(k):")
    print(H_R)

    t_final = 1.0
    dt = 0.01

    r_t = compare_dense_vs_qutip_nonhermitian_t(H_R, H_I, psi0, t_final, dt)
    print("\nCoordinate-time comparison:")
    print(r_t)

    tau_final = 1.0
    dtau = 0.01
    lambda_eff = 3.0

    r_tau = compare_dense_vs_qutip_nonhermitian_tau(
        H_R, H_I, psi0, tau_final, dtau, lambda_eff
    )
    print("\nEntropic-time (tau) comparison:")
    print(r_tau)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
