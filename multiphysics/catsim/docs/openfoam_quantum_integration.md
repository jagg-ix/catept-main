# OpenFOAM + Quantum Integration (CAT/EPT)

This document describes the CAT/EPT hydrodynamics path implemented in
`catsim_core.cfd.openfoam_adapter` and how it interoperates with quantum
components.

## What Is Implemented

The OpenFOAM compatibility adapter now supports:

1. Entropic proper time stepping
- Uses `d tau_ent = lambda * dt`.
- Accepts a target `dtau_target` and computes coordinate-time `dt`.

2. CFL-safe step selection
- Reuses `cat_ept_doubleslit.numerics.cfl_clock.CFLClock`.
- Enforces coordinate-time bounds before converting back to `dtau`.

3. Complex action bookkeeping per hydro step
- Real increment: `dS_R = ∫ (1/2 rho |v|^2 - p) dV dt`
- Imaginary increment: `dS_I = hbar * d tau_ent`
- Weight: `exp(i dS_R/hbar - dS_I/hbar)`

4. Quantum bridge payload
- Produces a normalized payload with:
  - timeline (`t_s`, `tau_ent_s`, `lambda_s_inv`, `dt_s`, `dtau_ent_s`)
  - qutip complex-action controls
  - `oqupy` and `kwant` config fragments
  - hydro feedback (`Re_eff`, `nu_eff`, CFL status)

## Core API

File:
- `simulations/catsim/src/catsim_core/cfd/openfoam_adapter.py`

Key methods:
- `OpenFOAMAdapter.evolve_entropic_step(...)`
- `OpenFOAMAdapter.to_quantum_bridge_payload(step)`
- `OpenFOAMAdapter.choose_stable_dt(...)`
- `OpenFOAMAdapter.compute_complex_action_increment(...)`

## DSL Surface

`OpenFOAMFlow` now accepts additional controls:

- `dtau_target`
- `dx`
- `characteristic_length`
- `a_max`
- `pressure`
- `cell_volume`

Compiler output includes:
- CFL fields (`cfl_number`, `cfl_limit`, `cfl_passed`)
- entropic-time fields (`t_s`, `tau_ent_s`, `dt_s`, `dtau_ent_s`, `lambda_s_inv`)
- complex-action fields (`complex_action_real`, `complex_action_imag`, `complex_action_phase_rad`, `complex_weight_*`)
- `quantum_bridge` payload

## Minimal Example

```python
from catsim_core.cfd.openfoam_adapter import make_openfoam_adapter
import numpy as np

adapter = make_openfoam_adapter({
    "lambda_const": 0.2,
    "nu_kinematic": 1e-4,
    "rho": 1.0,
    "cfl_max": 0.5,
})

step = adapter.evolve_entropic_step(
    velocity=np.array([2.0, 0.0, 0.0]),
    length_scale=1.0,
    dtau_target=1e-3,
    dx=0.1,
    pressure=0.2,
    volume=1.0,
)

payload = adapter.to_quantum_bridge_payload(step)
```

## Integration Pattern Across Physics Layers

1. Hydrodynamics (OpenFOAM adapter):
- produce CFL-valid entropic step + complex-action weight

2. Quantum simulators:
- `oqupy`: use `payload["oqupy_config"]`
- `kwant`: use `payload["kwant_config"]`
- qutip/non-Hermitian path: use `payload["qutip_complex_action"]`

3. Spacetime coupling:
- feed `lambda_s_inv` and/or fluid stress proxies into Complex-EFE bridges
- keep timeline contract aligned (`t_s`, `tau_ent_s`, `lambda_s_inv`)
