"""Demo: QuTiP non-Hermitian evolution with entropic proper time.

This example is meant to be small and educational:
  - define a 2-level system
  - evolve with H = H_R - i H_I (norm decays)
  - define lambda(t) and compute tau_ent(t)
  - optionally apply a metric redshift factor sqrt(-g00) to lambda.

Run:
  pip install -e '.[qutip]'
  PYTHONPATH=src python examples/open_quantum/run_qutip_entropic_clock.py
"""

from __future__ import annotations

import numpy as np

from cat_ept_doubleslit.metrics.redshift import minkowski_metric, schwarzschild_metric
from cat_ept_doubleslit.open_quantum.qutip_backend import evolve_nonhermitian_t, reparameterize_t_to_tau


def main():
    # Two-level system
    omega = 2 * np.pi * 10.0  # rad/s
    gamma = 1.0  # 1/s (simple damping scale)

    # Pauli matrices
    sz = np.array([[1.0, 0.0], [0.0, -1.0]])
    proj1 = np.array([[0.0, 0.0], [0.0, 1.0]])

    H_R = 0.5 * omega * sz
    H_I = gamma * proj1

    # Initial state |+> = (|0> + |1>)/sqrt(2)
    psi0 = np.array([1.0, 1.0], dtype=complex) / np.sqrt(2)

    tlist = np.linspace(0.0, 1.0, 200)  # seconds

    # Metric choice: Minkowski by default
    metric = minkowski_metric()
    # Or: Schwarzschild redshift around a 10-solar-mass BH at r=30 km
    # metric = schwarzschild_metric(mass_kg=10.0 * 1.98847e30)
    x = np.array([0.0, 0.0, 30_000.0])  # position vector for redshift sampling

    # Define lambda(t) (optionally redshifted)
    def lambda_t(t_s: float) -> float:
        return gamma * metric.redshift_factor(t_s, x)

    lam_values = np.array([lambda_t(t) for t in tlist], dtype=float)
    tau = reparameterize_t_to_tau(tlist, lam_values)

    res = evolve_nonhermitian_t(
        H_R=H_R,
        H_I=H_I,
        psi0=psi0,
        tlist_s=tlist,
        hbar=1.0,  # set ħ=1 for toy model
        normalize_output=False,
    )

    # Print a tiny summary
    print("t_final =", tlist[-1])
    print("tau_ent_final =", tau[-1])
    # Norm decay
    last = np.asarray(res.states[-1].full()).reshape(-1)
    print("||psi||^2(final) =", float(np.vdot(last, last).real))


if __name__ == "__main__":
    main()
