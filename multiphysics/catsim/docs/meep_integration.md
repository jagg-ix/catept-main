# Meep integration

This repo integrates **Meep** (MIT Photonic Bands / FDTD) as an *optional*
electromagnetics backend, compatible with the simulator's CAT/EPT stack:

* **Entropic proper time** stepping: \(d\tau = \lambda\,dt\)
* **Complex-action / non-Hermitian** hooks: represented conservatively as
  effective loss/envelope modulation (no claims that Meep "implements" quantum
  dynamics)
* **Metric redshift factor** (EinsteinPy): \(\lambda_{\text{eff}} = \sqrt{-g_{00}}\,\lambda\)

The integration is purposely lightweight:

* `cat_ept_doubleslit.electromagnetics.meep_backend` provides
  - a basic 2D double-slit builder
  - a runner that can step in **\(\tau\)** (recommended for CAT/EPT experiments)
  - optional CFL-style dt guards via `CFLClock`

## Gravity/metric coupling via Astropy transforms

Meep uses user-chosen **simulation units** (you pick what "1.0" means).
Your GR/metric stack in this repo (`MetricField` and EinsteinPy adapters)
expects **SI** coordinates: \(t\) in seconds and \(\vec{x}\) in meters.

To bridge this cleanly, use `MeepToPhysicalMap`:

* `length_unit_m`: meters per Meep length unit (e.g. `1e-6` for microns)
* `time_unit_s`: seconds per Meep time unit

The runner will evaluate the metric redshift factor at a **reference point**
in the Meep cell (config `metric_ref_point`). For weak fields over a small
cell this is typically sufficient; if you need spatially varying metrics, the
next step is to sample `g00` on a grid and build a field-dependent
\(\lambda_{\text{eff}}(x,t)\).

Astropy is used at the boundary to help you define these unit conversions and
coordinate transforms; the core stepping stays float-based.

## Why CFL still matters

Meep is an **explicit** FDTD solver whose internal timestep is controlled by the
Courant factor. Reparameterizing time does **not** remove the causality/stability
constraint — it changes how you *choose* the physical time increment \(\Delta t\)
when you decide to advance by a fixed \(\Delta \tau\).

In tau-stepping mode, we do:

\[
\Delta t = \frac{\Delta\tau}{\lambda_{\text{eff}}(t)}
\]

and then ask Meep to run until the new coordinate time.

## "Compliance" style checks (suggestions)

The module exposes small hooks to help enforce the constraints you listed:

* **Spatial resolution**: avoid 1-voxel interfaces (use `resolution >= 16` as a
  practical floor for discontinuities)
* **Convergence**: run the same config at increasing resolution and verify
  monotonic approach of spectra/fluxes
* **Time sampling**: enforce Nyquist-like sampling for your fastest modulation
  and a Courant-safe bound for dt
* **PML**: make PML thick enough for <1e-6 reflections across your bandwidth

This repo does not hardcode your acceptance thresholds; it provides the places
to plug them in, and keeps the logic testable.

## Installation

Meep is usually installed via conda-forge:

```bash
conda install -c conda-forge pymeep
```

If you use pip, availability depends on your platform; the repo keeps imports
soft so the rest of the simulator works even without Meep.

## Quick start

```bash
pip install -e '.[meep]'
PYTHONPATH=src python examples/electromagnetics/run_meep_double_slit_entropic.py
```
