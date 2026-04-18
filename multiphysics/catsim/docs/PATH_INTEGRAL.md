# Complex-Action Path Integral in the Simulator

This repo already contains a general complex-action path-integral scaffold:

- `catsim_core.qg.path_integral` (1D toy functional integral with weights `exp(i E/ħ - S_I/ħ)`)

To make the **interferometer readout** explicitly use the same split (oscillatory phase + damping),
we added:

- `catsim_core.qg.phase_path_integral` — phase-trajectory PI for visibility
- `catsim_quantum.sgi_path_integral_readout` — SGI readout adapter that uses it

## How to run (SGI Fig. 8, time-grid mode)

```bash
make sgi_scan_fig8_pi
```

Outputs:
- `PAPER_TABLES/ADVANCED/UI/SGI/scan_fig8_pi_001/run_manifest.json` (records bath + quantum settings)
- overlay CSVs in the same directory

## Notes

- This layer does **not** re-derive any CAT/EPT equations. It only provides an auditable
  *path-integral weight* pathway for visibility estimation, controlled via the SGI harness flags.
