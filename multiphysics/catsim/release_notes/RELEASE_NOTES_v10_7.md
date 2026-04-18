# Release Notes — v10.7-material-backends-pyscf-eps

Date: 2026-01-21

Implements an opt-in **frequency-dependent ε(ω)** exporter using PySCF TDDFT on a
molecular/supercell approximation, producing a canonical table:

  f_THz, eps_real, eps_imag

This completes the **structure → PySCF → ε(ω) → Drude fit → MEEP** loop at the
artifact level, with explicit provenance and stated approximations.

Guarantee:
- Paper-companion reproduction remains unchanged.
