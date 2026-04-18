# Release Notes — v10.15-double-slit-physics-predictor

Date: 2026-01-21

Adds a first physics-forward predictor for the Double-slit temporal dataset:

- Extends `scripts/ui_modules/double_slit_run.py` with `--physics-enabled`:
  - Loads eps(ω) table CSV (default: `data/materials/ITO_eps_table_proxy.csv`)
  - Computes normal-incidence slab reflection coefficient r(ω) using transfer-matrix/Fresnel relations
  - Predicts spectra via R(ω)=|r|^2 (normalized) → `pred_spectra_physics.csv`
  - Predicts time-domain via IFFT of complex r(ω) on a uniform grid → `pred_time_domain_physics.csv`
  - Computes affine-aligned residuals + RMSE → `residuals_*_physics.csv` and `summary.json`

- Updates Streamlit Double-slit UI page:
  - Adds a physics predictor toggle + eps-table path + slab thickness + NFFT controls
  - Adds measured vs predicted (physics) overlays + residual plots
- Adds `make run_double_slit_physics` (fixed run dir).

Note:
This is a conservative first-principles optical proxy. Next step is to replace slab assumptions with the experiment-specific optical layout (beam path, reference arm, gating) and/or MEEP-validated geometry.
