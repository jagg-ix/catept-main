# Mapping to the Imperial / Tirole et al. optical double-slit experiment

This simulator is intentionally **dataset-agnostic**:

- If you have the experiment’s source data (often shipped as Excel “source data” tabs),
  export each tab to CSV (as in your workflow notes) and then point `scripts/fit_to_csv.py`
  at the particular tab corresponding to the interference pattern.

## Expected columns

- `x_m`: screen coordinate in meters
- `counts` (preferred) or `intensity`

If your raw data is in pixels, convert pixels → meters using your camera calibration.

## Where CAT/EPT enters

The only change between modes is **how the coherence/visibility decays**:

- Standard: `V = V0 exp(-gamma T/2)`
- Entropic: `V = V0 exp(-tau_ent/2)` with `tau_ent = lambda_ent * T`

So the *experiment-facing test* is:

> Does the entropic-time parameterization provide a better (or more stable) fit than standard-time,
> when you hold the optical geometry fixed and fit the decay law?

