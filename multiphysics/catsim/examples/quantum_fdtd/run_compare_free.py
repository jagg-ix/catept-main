"""Compare FDTD vs QuTiP on a free-particle wave packet.

This is a direct executable version of the workflow sketched in 23.md.

Run:
  PYTHONPATH=src python examples/quantum_fdtd/run_compare_free.py

Optional:
  pip install -e '.[qutip]'
"""

from __future__ import annotations

import numpy as np

from cat_ept_doubleslit.quantum_fdtd import free_potential, gaussian_plane_wave, fdtd_tdse
from cat_ept_doubleslit.quantum_fdtd.plotting import plot_wavefunction, compare_probabilities

try:
    from cat_ept_doubleslit.quantum_fdtd.qutip_driver import run_qutip
    QUTIP_OK = True
except Exception:
    QUTIP_OK = False


def main():
    # Grid and initial state (close to 23.md numbers)
    L = 4.0e-9
    Nx = 1001
    x = np.linspace(0.0, L, Nx)
    U = free_potential(Nx)
    psi0 = gaussian_plane_wave(x, xc=L / 4.0, s=1.6e-10, lam=1.0e-10)

    # FDTD run
    res = fdtd_tdse(U, x, psi0, Nt=8000, record_every=400)
    psi_fdtd = res.psi_t[-1]
    prob_fdtd = np.abs(psi_fdtd) ** 2

    plot_wavefunction(x, psi_fdtd, title="FDTD final wavefunction")

    if QUTIP_OK:
        tlist = np.linspace(0.0, res.dt_s * 8000, 50)
        states, _ = run_qutip(U, x, psi0, tlist)
        psi_qutip = np.asarray(states[-1].full()).reshape(-1)
        prob_qutip = np.abs(psi_qutip) ** 2

        compare_probabilities(x, prob_fdtd, prob_qutip, title="|ψ|²: FDTD vs QuTiP (final)")
    else:
        print("QuTiP not installed; only ran FDTD. Install extras with: pip install -e '.[qutip]'")

    import matplotlib.pyplot as plt

    plt.show()


if __name__ == "__main__":
    main()
