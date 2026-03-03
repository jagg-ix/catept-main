# Release Notes — v10.8-material-backends-deepen-loop

Date: 2026-01-21

Deepens the pymatgen + PySCF + MEEP loop with opt-in realism upgrades:

- Supercell builder (pymatgen): CIF → supercell CIF + provenance
- Static ε0 estimator (finite-field polarizability): produces a documented ε0 proxy
- ε(ω) comparison report: ab-initio vs measured tables over a band, with RMSE + overlays

Guarantees:
- Paper-companion reproduction remains unchanged.
- All targets are opt-in and produce dry-run manifests if optional deps are missing.
