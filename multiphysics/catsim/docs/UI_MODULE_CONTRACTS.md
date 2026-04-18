# UI module artifact contracts (v10.12)

The UI is manifest-driven. Each module writes `run_manifest.json` in its run directory.

Root: `PAPER_TABLES/ADVANCED/UI/<MODULE>/run_XXX/`

## Double slit
Artifacts:
- `pred_intensity.csv` (x_m, I_pred)
- `summary.json` (visibility estimate, params)
- `run_manifest.json`

## Twin paradox
Artifacts:
- `worldline_A.csv`, `worldline_B.csv` (t_s, x_m, v_m_s, gamma, tau_s)
- `summary.json` (tauA, tauB, delta)
- `run_manifest.json`

## Ringdown
Artifacts:
- `ringdown_fit.csv` (t_s, h, h_fit, resid) for t>=t0
- `fit_params.json` (t0, f, tau, A,B, RMSE, input description)
- `run_manifest.json`


### Double slit (temporal overlays)
Additional artifacts from `double_slit_run.py` when SQLite extraction succeeds:
- `pred_spectra.csv`, `residuals_spectra.csv`
- `pred_time_domain.csv`, `residuals_time_domain.csv`
Metrics are stored in `summary.json`.


### Double slit (physics predictor)
When `--physics-enabled` is passed to `double_slit_run.py`, additional artifacts may be produced:
- `pred_spectra_physics.csv`, `residuals_spectra_physics.csv`
- `pred_time_domain_physics.csv`, `residuals_time_domain_physics.csv`
Physics assumptions: normal-incidence slab optics using eps-table; time-domain from IFFT of complex reflection coefficient.


### Double slit physics time-trace modes
Additional physics artifacts:
- `pred_time_domain_physics_field.csv`
- `pred_time_domain_physics_mag.csv`
Runner flag `--time-trace-mode {mag|field}` selects which series is compared to the measured reflectivity when computing residuals.


### SGI harness artifacts
Per-run directory contains:
- arm_plus.csv, arm_minus.csv (t,z,v,a)
- summary.json (closure metrics + GR baseline + optional extended backend output)
- run_manifest.json


SGI summary.json adds `closure_tuning` when auto-close is enabled (solver mode, best metrics, history, pulses string).
