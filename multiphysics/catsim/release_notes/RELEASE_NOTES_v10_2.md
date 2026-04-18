# Release Notes — v10.2-material-backends-eps-meep

Date: 2026-01-21

Extends v10.1 with optional backends to:
- Convert optical-constants tables (n,k) into epsilon tables ε(ω)
- Export ε(ω) tables into a MEEP-friendly dispersive material stub

Guarantees:
- Paper-companion reproduction remains unchanged.
- These tools are opt-in and run only when invoked.
