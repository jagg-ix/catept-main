# Release Notes — v10.21-sgi-templates-closure-solver

Date: 2026-01-21

Improves the SGI harness with experiment-facing ergonomics while preserving strict layering:

## Added pulse templates
- `split_mirror_recombine` (3-pulse)
- `four_pulse_close` (4-pulse)

## Added GR-baseline closure solver
- `--auto-close` tunes pulse durations to reduce final arm closure errors (dz, dv).
- Modes:
  - `scale_last` (1D grid over last pulse duration)
  - `two_pulse`  (2D grid over two pulse durations)

## UI updates
- template selector + template parameters
- closure tuning controls
- displays solver history / best settings in `summary.json`

## Make targets
- `make run_sgi_harness_close`
