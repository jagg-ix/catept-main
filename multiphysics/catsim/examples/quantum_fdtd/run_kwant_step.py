"""Kwant step-potential transmission/reflection demo (from 23.md).

Run:
  pip install -e '.[kwant]'
  PYTHONPATH=src python examples/quantum_fdtd/run_kwant_step.py
"""

from __future__ import annotations

from cat_ept_doubleslit.quantum_fdtd.kwant_driver import make_step_system


def main():
    import kwant

    sys = make_step_system(L_sites=100, U0=0.2)
    smatrix = kwant.smatrix(sys, energy=0.1)
    T = smatrix.transmission(1, 0)
    R = smatrix.transmission(0, 0)
    print(f"Transmission: {T:.3f}")
    print(f"Reflection: {R:.3f}")


if __name__ == "__main__":
    main()
