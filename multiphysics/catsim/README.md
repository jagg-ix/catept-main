# CATSim -- Double-Slit Simulator (Optical Frequencies)

Simulates double-slit interference patterns in two modes:

1. **Standard time**: coherence decays with a conventional rate gamma over flight time T.
2. **Entropic proper time (CAT/EPT)**: coherence decays with an entropic rate lambda_ent using the visibility law V = V_0 exp(-lambda T/2).

The purpose is to test whether an entropic-proper-time parameterization materially changes inferred parameters when fitting to experimental data.

## Quick Start

```bash
make unit_check
make db_fast
make phase3
make phase5
make phase6
make paper_all
```

## Quantum TDSE Validation

The `cat_ept_doubleslit.quantum_fdtd` subpackage provides:

- A minimal explicit TDSE solver (finite-difference time-domain, baseline validator)
- An optional QuTiP backend (`pip install -e '.[qutip]'`)
- An optional Kwant step-scattering demo (`pip install -e '.[kwant]'`)

```bash
PYTHONPATH=src python examples/quantum_fdtd/run_compare_free.py
PYTHONPATH=src python examples/quantum_fdtd/run_kwant_step.py
```

## Open Quantum Backends

Reference backends for open quantum evolution:

- `qutip_backend` -- unitary, GKLS, and non-Hermitian evolution (H = H_R - i H_I)
- `oqupy_backend` -- entropy/lambda/tau traces from reduced dynamics (optional)

```bash
pip install -e '.[qutip]'
PYTHONPATH=src python examples/open_quantum/run_qutip_entropic_clock.py

pip install -e '.[oqupy]'
PYTHONPATH=src python examples/open_quantum/run_oqupy_entropy_tau.py
```

## Tight-Binding Backend (PythTB)

PythTB provides a Bloch Hamiltonian H(k) source, evolved using the same CAT/EPT clock and complex-action wiring.

```bash
pip install -e '.[pythtb]'
PYTHONPATH=src python examples/tight_binding/run_pythtb_ssh_entropic.py
```

## Data Fitting

Fit experimental CSV data (columns: `x_m`, `counts` or `intensity`):

```bash
cat-ept-fit --csv data.csv --mode entropic \
  --wavelength_m 532e-9 --slit_sep_m 80e-6 --slit_width_m 10e-6 --screen_dist_m 1.2 \
  --grid-min 0 --grid-max 5e4 --grid-n 2000 --out-json fit_entropic.json
```

Compare the best-fit score between entropic and standard modes.

## Temporal Double Slit (Tirole et al.)

Spectral fringe model using two Gaussian time-windows separated by `separation_s`, producing frequency-domain interference cos(2 pi f Delta_t).

```bash
python run_simulate.py --config configs/temporal_default.json --outdir out_temporal
```

## Data Pipeline (XLSX to SQLite)

```bash
cd data_pipeline/user_scripts
pip install -r requirements.txt
export DATA_DIR=../source_data
make load
```

Produces `double_slit.sqlite3` with tidy CSVs and a verification report.

## Directory Layout

- `src/cat_ept_doubleslit/` -- core library
- `scripts/` -- fitting and batch run helpers
- `examples/` -- 9 categories (quantum FDTD, open quantum, entropic, tensor networks, tight binding, electromagnetics, benchmarks, astro, time double slit)
- `data_pipeline/` -- XLSX extraction and SQLite loading
- `TIROLE_DB/` -- experimental database
- `PAPER_TABLES/` -- generated paper tables
- `lean/` -- Lean4 proofs for simulation results
- `docs/` -- integration guides and backend comparisons
- `configs/` -- example configuration files

## Requirements

- Python 3.8+, NumPy, SciPy, matplotlib
- Optional: QuTiP, Kwant, OQuPy, Astropy, MEEP, TenPy, PythTB, EinsteinPy

## Scope

This simulator provides a controlled way to compare entropic-time and conventional-time decay laws. It does not assert that the entropic model is correct a priori; it is a test harness for comparing the two parameterizations against data.
