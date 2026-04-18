# Release Notes — v10.13-double-slit-sqlite-wiring

Date: 2026-01-21

Implements the next step for the Double-slit UI module:

- Adds `scripts/ui_modules/double_slit_run.py` which:
  - extracts measured spectra/time-domain traces from SQLite into the UI run dir
  - writes `meas_spectra.csv` and `meas_time_domain.csv`
  - generates baseline `pred_intensity.csv` (spatial placeholder)
  - writes `summary.json` + `run_manifest.json`

- Updates `make run_double_slit` to use the new runner.
- Updates UI page to support DB path + experiment selection and create timestamped runs.

Note:
Measured outputs are temporal (spectra/time-domain). The spatial `pred_intensity.csv` is kept as a placeholder baseline.
Next step is to implement a time-diffraction forward model producing predicted spectra/time-domain for direct overlay.
