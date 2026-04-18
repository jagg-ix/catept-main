# Release Notes — v10.19-auto-mode-dual-overlay

Date: 2026-01-21

Enhances Double-slit temporal physics comparisons:

- Adds `--time-trace-mode auto`:
  - computes affine fits for both `field` (Re[r(t)]) and `mag` (|r(t)|)
  - selects the lower-RMSE mode automatically
  - stores:
    - `physics_metrics.time_domain_affine_mag`
    - `physics_metrics.time_domain_affine_field`
    - `physics_metrics.time_trace_mode_auto_best`

- UI now:
  - shows dual overlays (measured vs field AND measured vs mag) when available
  - exposes `auto` choice in the selector
  - displays the auto-chosen mode in a highlighted banner.

- Make target `run_double_slit_physics_stack_modes` now uses `--time-trace-mode auto`.
