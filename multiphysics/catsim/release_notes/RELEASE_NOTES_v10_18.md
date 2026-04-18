# Release Notes — v10.18-time-trace-modes

Date: 2026-01-21

Extends the Double-slit temporal physics comparison to support different interpretations of the measured "reflectivity vs delay" trace.

## Time-trace variants exported
From the IFFT-based construction of r(t):
- `pred_time_domain_physics_field.csv` : real field-like trace (Re[r(t)])
- `pred_time_domain_physics_mag.csv`   : magnitude-like trace (|r(t)|)

## Residual computation mode
New runner flag:
- `--time-trace-mode {mag|field}`
Selects which predicted series is compared to the measured reflectivity when computing affine residuals and RMSE.

## UI
Adds a selector for the comparison mode and plots the available predicted trace.

## Make
Adds:
- `make run_double_slit_physics_stack_modes`
