# TeNPy integration

This repo optionally integrates with **TeNPy (Tensor Network Python)** to support 1D tensor-network simulations (MPS/TEBD) alongside the existing
finite-difference, QuTiP, OQuPy, and EinsteinPy components.

## Install

TeNPy is distributed on PyPI as `physics-tenpy` (module name `tenpy`).

```bash
pip install -e '.[tenpy]'
```

## Why this exists

TeNPy provides efficient algorithms (e.g., TEBD/DMRG) for strongly correlated 1D systems.
In this simulator we use it for:

- cross-checks of simple unitary dynamics (baseline validation)
- controlled introduction of non-unitary dynamics through complex-time steps (opt-in)
- mapping to an alternative monotone clock (e.g., entropic proper time) via
  `d\tau = \lambda dt`, without claiming that this removes CFL/stability constraints.

## Example

```bash
PYTHONPATH=src python examples/tensor_networks/run_tenpy_tebd_entropic.py --L 16 --t_final 2.0 --dt 0.02
PYTHONPATH=src python examples/tensor_networks/run_tenpy_tebd_entropic.py --use_entropic_time --lambda_eff 5.0
```

The entropic-clock mode interprets `--dt` as `d\tau` per step and maps it to
coordinate time `dt = d\tau / \lambda_eff`.
