# Release Notes — v10.16-double-slit-multilayer-timealign

Date: 2026-01-21

Upgrades the Double-slit temporal physics predictor to be more experiment-faithful:

- Implements multilayer normal-incidence optics:
  air | film(ε_film(ω)) | substrate(n_sub)
  producing r(ω) and R(ω)=|r|^2.

- Constructs time-domain prediction by:
  - interpolating r(ω) onto a uniform positive-frequency grid
  - applying a window (hann/none)
  - building a Hermitian spectrum
  - IFFT → real impulse response r(t)
  - exporting delay axis in fs.

- Adds optional auto time-shift alignment via cross-correlation before affine residual computation.

Artifacts added per run:
- pred_spectra_physics.csv + residuals_spectra_physics.csv
- pred_time_domain_physics.csv + residuals_time_domain_physics.csv
- physics metrics (affine params, RMSE, optional time_shift_fs) stored in summary.json.

UI:
- Adds physics controls (eps table path, thickness, substrate n, NFFT, window, auto shift)
- Adds physics overlays section.

Make:
- `make run_double_slit_physics_multilayer`
