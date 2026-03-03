# Phase 5: Paper-faithful prediction protocol

Figure ref: `Fig_2f`

Train S (fs): [500.0]

Test points: 19

## Fitted parameters (train set)

- Phase poly: phi0=0.151612, phi1=5.54116e+11 rad/s, phi2=7.49885e+23 rad/s^2
- lambda_ent (CAT coherence): 3.7037e+11 1/s (ceiling 1/dt=5e+15 1/s)

## Test-set mean absolute error (MAE)

- Visibility MAE: standard=0.821952, CAT=0.71065 (n=19)
- Period MAE (THz): standard=0.0803713, CAT=0.0803713 (n=20)
- Asymmetry MAE: standard=0.179554, CAT=0.18576 (n=20)

## Gate

- constraints_ok: True
- CAT improves or ties visibility MAE: True
- **gate_pass**: True


## PT diagnostics (calibrated 2x2 reduction)

This is an *auxiliary* diagnostic layer: we fit a single coefficient k on the same train S and evaluate pseudo-Hermiticity conditioning/residuals on the full S sweep.

- k_calibrated: 1.0000001685893696
- PT-unbroken fraction: 1.0
- Median ||H^†η-ηH||: 1.6610177318132093e-11
- Median cond(η): 1.0018356890754807

PT gate thresholds (reported, not used to override Phase 5):

- pt_unbroken_fraction >= 0.9
- eta_residual_median <= 1e-06
- eta_cond_median <= 100000000.0

- pt_gate_pass: True
