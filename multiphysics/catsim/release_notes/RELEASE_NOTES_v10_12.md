# Release Notes — v10.12-ui-module-clis

Date: 2026-01-21

Begins implementation of the three UI modules by adding stable CLI entrypoints + artifact contracts:

- Double slit: `scripts/ui_modules/double_slit_predict.py` (baseline Fraunhofer model, CSV + manifest)
- Twin paradox: `scripts/ui_modules/twin_paradox_run.py` (worldlines + proper time, CSV + manifest)
- Ringdown: `scripts/ui_modules/ringdown_fit.py` (single-mode fit with grid search option, CSV + params + manifest)

Adds Make targets:
  - run_double_slit
  - run_twin_paradox
  - run_ringdown_fit

Updates UI pages to select module runs via `run_manifest.json` rather than "latest CSV glob".
