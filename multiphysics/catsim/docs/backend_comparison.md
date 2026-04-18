# Backend comparison harness

This repo intentionally supports multiple "engines" (FDTD, QuTiP, OQuPy, TeNPy, PythTB) while sharing a single set of CAT/EPT "wiring" layers:

- **Clock**: entropic proper time `tau_ent` via `d tau = lambda dt`
- **Complex action**: non-Hermitian generator `H = H_R - i H_I`
- **Metric**: redshift factor `sqrt(-g00)` (EinsteinPy optional)

Because backends differ in what they natively provide, we include a small comparison harness for *toy* problems.

## What the harness does

`cat_ept_doubleslit.benchmarks.compare_backends` compares:

- a simple **dense matrix-exponential stepper** (reference), versus
- **QuTiP** `sesolve` (when installed)

for the same `(H_R, H_I, psi0)`.

It supports:
- coordinate time stepping (t)
- entropic proper time stepping (tau) with constant `lambda_eff`

## Why this matters

- Confirms the non-Hermitian and tau reparameterization plumbing is consistent.
- Provides a regression check when integrating new backends.

## Running the example

```bash
pip install -e '.[pythtb,qutip]'
PYTHONPATH=src python examples/benchmarks/run_compare_pythtb_qutip.py
```

If QuTiP is not installed, the script will still run the dense evolution and print a note.
