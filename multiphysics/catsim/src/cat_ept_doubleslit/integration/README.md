# Integrations: EinsteinPy + i-PI + OGRePy

This folder is intentionally **optional**: the core `cat-ept-double-slit` package runs with only NumPy + Matplotlib.

## Install optional deps

```bash
pip install -e .
# GR/geodesics
pip install einsteinpy
# i-PI server + python API
pip install ipi
# Optional (only if you use the QuTiP post-processing bridge)
pip install qutip
# If you use OGRePy symbolic metrics, install OGRePy in your environment.
```

## What’s here

- `einsteinpy_bridge.py`: helper to export EinsteinPy trajectories into i-PI XYZ; and an OGRePy→driver factory.
- `ogrepy_ipi_bridge.py`: OGRePy EntropicMetric → i-PI driver glue + optional i-PI→QuTiP post-processing helper.

## Notes

- The bridges use **soft imports** and will warn (not crash) if optional deps are missing.
- The example folders in the repo (`/examples/*`) contain i-PI XML input templates demonstrating expected wiring.
