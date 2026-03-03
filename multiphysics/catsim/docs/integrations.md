# Optional integrations (EinsteinPy + i-PI)

This repository provides **glue code** (bridges) to connect GR/geodesic tooling and i-PI workflows.

## EinsteinPy

EinsteinPy can be used to generate geodesic trajectories (e.g., Schwarzschild/Kerr) and export them to XYZ for i-PI.
See `cat_ept_doubleslit.integration.einsteinpy_bridge.GeodesicToIPIBridge`.

## i-PI

i-PI is a separate project that provides the MD/PIMD engine and the socket protocol.
Install with:

```bash
pip install ipi
```

The examples under `/examples/*` are i-PI input templates.

## What this repo *does not* do (yet)

- It does not bundle i-PI’s socket client implementation.
- It does not implement a full i-PI driver loop (protocol).

That’s intentional: there are multiple valid ways to wire i-PI:
- socket clients (custom code)
- `i-pi-py_driver`
- `ffdirect` to run PES directly inside i-PI

If you want, we can add a dedicated socket client in this repo next.

## OGRePy (symbolic tensor engine)

OGRePy is useful when you want **exact symbolic** Christoffels, curvature,
and geodesic equations, then *numerically* evaluate them in the simulator
or inside an i-PI driver.

This repo supports OGRePy in a **plain-Python** workflow (no notebooks)
via a small patch helper:

```bash
python tools/patch_ogrepy_no_ipython.py --installed
```

That patch is based on your upstream fork-diff (`third_party/patches/OGRePy.patch`)
but implemented as a robust text rewrite (so it survives upstream refactors).

Once OGRePy imports, use:

```python
from cat_ept_doubleslit.integration.ogrepy_entropic_bridge import EntropicTimeMap
```

to reparameterize ODEs from coordinate time to entropic proper time.

## PythTB (tight-binding)

PythTB provides compact tight-binding Hamiltonians (Bloch H(k)) and
topology utilities. In this repo we wrap a `tb_model` as a Hamiltonian
provider so it can be combined with:

- entropic proper time (`EntropicClock`),
- complex-action / non-Hermitian damping (`H = H_R - i H_I`), and
- metric redshift (`sqrt(-g00)`) as a scalar modifier on `lambda`.

See `docs/pythtb_integration.md` and `cat_ept_doubleslit.tight_binding.pythtb_backend`.

## Backend comparison

See `docs/backend_comparison.md` and `examples/benchmarks/run_compare_pythtb_qutip.py` for a minimal cross-backend validation harness (dense expm vs QuTiP) that is compatible with CAT/EPT time reparameterization.

## Astropy + REBOUND

For broader astrophysics interoperability:

- **Astropy** is used at boundaries for units, constants, and (optionally) coordinate-time objects.
  The numerical core continues to use plain floats (seconds) so that entropic proper time can remain a first-class stepping variable when requested.
- **REBOUND** is provided as an optional N-body backend; we treat it as a coordinate-time solver and track `tau_ent` alongside `t`.

See `docs/astro_integrations.md`, `cat_ept_doubleslit.astro.astropy_bridge`, and `cat_ept_doubleslit.integration.rebound_backend`.

## Meep (electromagnetics / FDTD)

Meep is integrated as an optional electromagnetics backend that can be driven by
**entropic proper time** stepping. This does *not* remove Courant/CFL-style
constraints; it changes how coordinate-time increments are chosen when stepping
in \(\tau\).

See `docs/meep_integration.md` and `cat_ept_doubleslit.electromagnetics.meep_backend`.
