# Simulator UI (Streamlit)

The UI is designed to be **reproducibility-first**:
- orchestrate existing Make targets and scripts
- visualize generated artifacts (CSV/JSON)
- avoid embedding physics logic in the UI layer

## Install
```bash
pip install -r requirements-ui.txt
```

## Run
From repo root:
```bash
streamlit run ui/app.py
```

## Modules
- Double slit: run pipelines and plot generated CSVs (fringes/intensity/etc.)
- Twin paradox (electrons): proper-time + worldline visualization scaffold
- Black hole ringdown: synthetic generator + single-mode fit scaffold

## Notes
The twin paradox and ringdown pages are self-contained scaffolds right now.
The intended next step is to connect them to the repo's physics kernels and artifact outputs
as those stabilize.


## Run module CLIs (Make targets)
- `make run_double_slit`
- `make run_twin_paradox`
- `make run_ringdown_fit`

See `docs/UI_MODULE_CONTRACTS.md`.


### Double slit measured extraction
The Double-slit UI uses `python -m scripts.ui_modules.double_slit_run` to extract measured spectra/time-domain traces from the SQLite DB into a run directory.


### Double slit physics (multilayer)
Run: `make run_double_slit_physics_multilayer` for air|film|substrate normal-incidence reflection + auto time-shift alignment.


### Double slit physics (general stack)
Use `--stack-json` to run N-layer transfer-matrix optics. Example spec: `data/materials/stack_example_air_ito_glass.json`.
Make target: `make run_double_slit_physics_stack`.


### Time-trace mode auto-selection
Set `--time-trace-mode auto` to compute both field and magnitude fits and store the best-RMSE mode in `summary.json` under `physics_metrics.time_trace_mode_auto_best`.


## Stern–Gerlach Interferometer (SGI)
Run harness: `make run_sgi_harness`.
UI page: `3_Stern_Gerlach_Interferometer.py`.
Extended backend behavior is invoked via adapters only (see `sgi_backend_bridge.py`).


### SGI closure tuning
Use `--auto-close` to tune pulse durations in the GR baseline model.
Make: `make run_sgi_harness_close`.


### SGI shaped pulses
Use `--shape tanh --ramp-frac 0.15` to smooth gradient edges (baseline trajectory only).
Make: `make run_sgi_harness_close_shaped`.
