# Phase 4E: 2x2 PT-like Hamiltonian diagnostic
- Fitted lambda_ent: **3.7037e+11 1/s** (from Phase 5 status.json)
- b=lambda/2: **1.85185e+11 1/s**
- S values analyzed: **19**
- Unbroken condition (c>b) holds for: **19/19**

## Files
- `hamiltonian_2x2_table.csv`: per-S Hamiltonian/metric/C exports
- `summary.json`: machine-readable summary

## Notes
- This is a reduced 2x2 PT-like diagnostic model.
- b is set from fitted coherence decay (lambda_ent/2).
- c is set by c=pi/(|S| seconds) to tie coupling timescale to the delay.
- Metric eta is constructed as eta=(V^{-1})^H (V^{-1}).
- C is exported only in the unbroken region |b|<|c|.
