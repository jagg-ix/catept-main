"""Demo: OQuPy reduced dynamics -> entropy(t) -> lambda(t) -> tau_ent(t).

This example is intentionally a *template* because OQuPy setups vary by model.
It shows the data flow that matters for CAT/EPT style integration:

  rho(t)  ->  S(t)  ->  lambda(t) = (1/k_B) dS/dt  ->  tau_ent(t)=∫lambda dt

Run:
  pip install -e '.[oqupy]'
  PYTHONPATH=src python examples/open_quantum/run_oqupy_entropy_tau.py

If you already have an OQuPy Dynamics object from your model, you can skip
TEMPO entirely and just call entropy_trace_from_states().
"""

from __future__ import annotations

import numpy as np

from cat_ept_doubleslit.open_quantum.oqupy_backend import entropy_trace_from_states


def main():
    # Example placeholder: a simple dephasing channel density matrix trajectory.
    # Replace this with rho(t) from OQuPy.
    tlist = np.linspace(0.0, 1.0, 200)
    rho_t = np.zeros((len(tlist), 2, 2), dtype=complex)
    for i, t in enumerate(tlist):
        p = 0.5
        coh = 0.5 * np.exp(-2.0 * t)
        rho_t[i] = np.array([[p, coh], [coh.conjugate(), 1 - p]])

    trace = entropy_trace_from_states(tlist_s=tlist, rho_t=rho_t)
    print("tau_ent_final =", trace.tau_ent[-1])
    print("lambda_max =", float(np.max(trace.lambda_s_inv)))


if __name__ == "__main__":
    main()
