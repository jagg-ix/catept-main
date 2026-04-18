# Release Notes — v10.17-stack-transfermatrix-presets

Date: 2026-01-21

Adds the requested "next-2" upgrades for the Double-slit temporal physics pipeline:

## General N-layer transfer-matrix optics
- Implements characteristic-matrix method at normal incidence for:
  incident | layer1 | layer2 | ... | substrate
- Layers and substrate can be specified with:
  - constant n, or
  - ε(ω) tables (CSV) -> n(ω)=sqrt(ε)

## Pipeline-style time-trace presets
- Adds `TimeTraceParams.preset` with `tirole_default`:
  - hann window
  - centered delay axis using fftshift (delay ~ [-T/2, +T/2])

## Runner + UI wiring
- `double_slit_run.py` now supports:
  - `--substrate-eps-table`
  - `--stack-json`
  - `--preset tirole_default|custom`
- UI exposes these controls.
- Adds sample stack spec:
  `data/materials/stack_example_air_ito_glass.json`

## Make target
- `make run_double_slit_physics_stack`
