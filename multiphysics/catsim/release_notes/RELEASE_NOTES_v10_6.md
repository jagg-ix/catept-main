# Release Notes — v10.6-material-backends-pyscf-bridge

Date: 2026-01-21

Adds an optional **PySCF bridge** to deepen the pymatgen→(ab initio)→ε(ω)→MEEP loop:

- Structure→PySCF periodic cell builder (from CIF) with provenance output
- SCF ground-state runner (optional) that writes checkpoint + basic summaries
- A clearly labeled placeholder interface for frequency-dependent ε(ω) (RPA/TDDFT),
  designed to be swapped in once a specific PySCF workflow is chosen.

Guarantees:
- Paper-companion reproduction remains unchanged.
- Everything in this release is opt-in and degrades to dry-run manifests if dependencies are absent.
