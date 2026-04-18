# Release Notes — v10.5-material-backends-meep-TR

Date: 2026-01-21

Upgrades the optional MEEP validation runner to compute real transmission/reflection spectra:
- Uses fitted Drude parameters (best_fit.json) and explicit SI→MEEP unit conversion
- Runs a minimal 1D slab scattering simulation with flux normalization
- Emits T(ω), R(ω), and A(ω)=1-T-R tables when `meep` is installed
- Falls back to dry-run manifest if `meep` is unavailable

Guarantee:
- Paper-companion reproduction remains unchanged.
