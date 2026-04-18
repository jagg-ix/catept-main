# PythTB integration

This repo integrates **PythTB** as an *optional* backend that provides
tight-binding Hamiltonians `H_R(k)` for small orbital bases. PythTB itself
is focused on constructing tight-binding models and computing band/topology
quantities.

We wrap a PythTB `tb_model` so it can participate in the same CAT/EPT flows
as the other backends (FDTD, QuTiP, OQuPy, TeNPy).

## Install

```bash
pip install -e '.[pythtb]'
```

PythTB is published on PyPI as `pythtb`.

## Core flow (architecture)

### Shared CAT/EPT layering (existing architecture)

All backends in this repo follow the same layering pattern:

1) **Model layer**: defines a generator of dynamics (Hamiltonian, Liouvillian,
   or integrator equations).
2) **Clock layer**: defines the mapping between coordinate time `t` and
   entropic proper time `tau_ent`:

   `d tau = lambda(t, state) dt`, with `lambda >= 0`.

3) **Metric layer (optional)**: provides a scalar redshift factor
   `z = sqrt(-g00)`, which can modify `lambda` conservatively:

   `lambda_eff = z * lambda`.

4) **Backend layer**: performs actual evolution/propagation and emits
   observables.

This separation is already present in the repo via:
- `cat_ept_doubleslit.clock.entropic_clock`
- `cat_ept_doubleslit.metrics.redshift`
- `cat_ept_doubleslit.complex_action.nonhermitian`

### PythTB-specific flow

PythTB provides **static** Bloch Hamiltonians `H_R(k)`.
To make it compatible with CAT/EPT, we add two small adapters:

**A) Hamiltonian provider**

```python
backend = PythTBBackend(tb_model)
H_R = backend.hamiltonian(k)
```

**B) Evolution wrapper**

We evolve a state vector in the orbital basis using:

`i ħ dψ/dt = (H_R - i H_I) ψ`

and allow reparameterization to entropic time:

`i ħ dψ/dtau = (H_R - i H_I)/lambda_eff ψ`.

The module:
- `cat_ept_doubleslit.tight_binding.pythtb_backend.evolve_bloch_state_t`
- `cat_ept_doubleslit.tight_binding.pythtb_backend.evolve_bloch_state_tau`

implements these loops with a small dense-matrix exponential.

## How to connect EinsteinPy + CAT/EPT to PythTB

The integration point is `lambda_eff`:

1) Get a metric factor (EinsteinPy or analytic metric):
   - `z = sqrt(-g00)`
2) Provide a base `lambda` from your open-system/complex-action model.
3) Use `lambda_eff = z * lambda` in the entropic clock.

In code this is expressed by passing a `MetricField` into `PythTBRunConfig`.

## Comparison vs current architecture

| Backend | Native object | Typical size | Native time evolution | What we add |
|---|---|---:|---|---|
| FDTD | grid wavefunction | large | explicit stepping | entropic dtau + complex damping |
| QuTiP | operators + states | small/med | `sesolve/mesolve` | tau mapping + complex-action wiring |
| OQuPy | influence functional / rho(t) | small/med | TEMPO family | entropy→lambda→tau extraction |
| TeNPy | MPS/MPO | med/large 1D | TEBD | tau-step mapping |
| **PythTB** | Bloch `H(k)` | small | mostly static (bands) | **state evolution wrapper + tau mapping + metric redshift** |

Key difference: PythTB is most naturally used for band/topology calculations.
This repo uses it as a compact Hamiltonian source, and supplies an explicit
evolution wrapper so it can sit in the same CAT/EPT pipeline.

## Example

See `examples/tight_binding/run_pythtb_ssh_entropic.py`.
