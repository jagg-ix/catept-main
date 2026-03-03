# Release Notes — v10.14-double-slit-pred-overlay

Date: 2026-01-21

Implements the next overlay step for the Double-slit UI module:

- Extends `scripts/ui_modules/double_slit_run.py` to produce **baseline predicted** traces
  for the extracted measured data using a conservative polynomial smoothing model:
  - `pred_spectra.csv` + `residuals_spectra.csv`
  - `pred_time_domain.csv` + `residuals_time_domain.csv`
  - RMSE metrics stored in `summary.json`

- Updates the Streamlit Double-slit page to plot measured vs predicted overlays and residuals.

Note:
This is a conservative baseline (smoothing) intended to establish the artifact contract and UI overlays.
Next step is to replace the baseline with a physics-forward model for time diffraction / ENZ response.
