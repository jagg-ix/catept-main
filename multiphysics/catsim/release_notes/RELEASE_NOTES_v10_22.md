# Release Notes — v10.22-sgi-solver-plots-shaped-pulses

Date: 2026-01-21

Adds two improvements to the SGI harness (still strict layering; no CAT/EPT equations added):

## Pulse edge shaping (GR baseline worldlines)
- `--shape none|tanh`
- `--ramp-frac` controls tanh ramp fraction per pulse.
- Closure solver supports the same shaping parameters.

## Solver history export + UI plots
- When auto-close is enabled, writes `closure_solver_history.csv`.
- UI plots objective and closure errors vs scan parameter(s).
- New Make target:
  - `make run_sgi_harness_close_shaped`
