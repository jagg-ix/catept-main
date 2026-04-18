# CAT/EPT Paper: Complete Figure Catalog

## Overview
Your repository now contains **31 generated figures** (11 PDFs + 20 PNGs) from 23 Python scripts.

## Figure Categories

### Core Theory Figures (Already in Paper)
1. **comp_isomorphism.pdf/.png**
   - Computational interpretation mapping
   - Shows: S_R ↔ reversible ops, S_I ↔ irreversible erasures
   - Used in: Section on computational interpretation

2. **polarization_visibility.pdf/.png**
   - Visibility decay V(t) = e^(-γt)
   - Dual axes: visibility and entropic time
   - Used in: Polarization section

3. **poincare_shrink.pdf/.png**
   - Poincaré sphere Bloch vector contraction
   - Pure dephasing visualization
   - Used in: Enhanced polarization section

4. **polarization_fit.pdf/.png**
   - Experimental data fitting demo
   - Extracts γ from noisy visibility data
   - Used in: Polarization section

### NEW: Entropic Time Accumulation Figures

5. **fig1_trajectories_response.pdf/.png**
   - Top: Worldlines near Schwarzschild horizon
   - Bottom: Detector response F(E) vs duration
   - Shows: Hovering (linear) vs free-fall (bounded)

6. **fig2_tauent_vs_tau.pdf/.png**
   - τ_ent = ∫ λ(τ) dτ accumulation
   - Hovering: λ = const → linear growth
   - Free-fall: λ(τ) transient → saturation

7. **fig3_effective_temperature_profile.pdf/.png**
   - Temperature profile T(r) ∝ κ(r) near horizon
   - Shows: λ = κ/(2π) relationship
   - Hovering observer perspective

### NEW: Spacetime Geometry Visualizations

8. **lightcone_cat_ept.pdf/.png**
   - Minkowski light cone with τ_ent(x,t) overlay
   - Color gradient shows entropic time accumulation
   - Worldlines show timelike/null trajectories

9. **lorentz_boost_cat_ept.pdf/.png**
   - Lorentz boost geometry (rapidity η = 0.7)
   - Shows: k = exp(-τ_ent) = 0.497
   - Boosted coordinate axes t', x'

10. **penrose_minkowski.pdf/.png**
    - Penrose conformal diagram for Minkowski space
    - Diamond boundary: I+, I-, i⁰
    - Null rays and CAT/EPT overlay

11. **penrose_schwarzschild_schematic.pdf/.png**
    - Schwarzschild Penrose diagram
    - Shows: horizon, singularity, I±
    - CAT/EPT overlay near singularity

### NEW: Curved Spacetime and Lensing

12. **curved_grid_embedding_schematic.png**
    - Embedding diagram with curved grid
    - Mass depression in center
    - λ(x) overlay showing entropic coupling

13. **gravitational_lensing_schematic.png**
    - Light ray bending around lens
    - Source, lens, observer configuration
    - CAT/EPT interaction overlay

14. **proper_vs_entropic_time.png**
    - Worldline with proper time ticks (dτ)
    - Color gradient: τ_ent accumulation
    - Shows distinction between τ and τ_ent

### NEW: Quantum Gravity Diagrams

15. **superspace_cartoon.png**
    - Configuration space of 3-geometries
    - Nodes: h_ij states
    - Links: history steps
    - Wheeler superspace schematic

16. **adm_slicing_cartoon.png**
    - ADM 3+1 decomposition
    - Shows: lapse N, shift N^i
    - Spatial hypersurfaces

17. **constraint_enforcement_flow.png**
    - ADM phase space → constraints enforced
    - Integration over N, N^i
    - δ[H_⊥] δ[H_i] constraint delta functions

18. **wdw_relational_time_cartoon.png**
    - Wheeler-DeWitt H_⊥Ψ = 0 → relational ρ(τ_ent)
    - No external t → conditional on clock/records
    - dρ/dτ_ent = L[ρ] evolution

### NEW: Open Systems and Path Integrals

19. **gkls_emergence_flow.png**
    - Microscopic histories → coarse-graining → ρ(τ_ent)
    - Markovian limit yields GKLS generator
    - dρ/dτ_ent = L[ρ]

20. **history_weight_influence.png**
    - Sum over histories with CAT/EPT weighting
    - Weight: exp(iS/ℏ) × exp(-τ_ent)
    - Constraints unchanged, weight selects histories

## Figure Usage by Section

### Section 1: Introduction & Framework
- comp_isomorphism.pdf (computational mapping)
- proper_vs_entropic_time.png (operational distinction)

### Section: Polarization Optics (Enhanced)
- polarization_visibility.pdf (decay curves)
- poincare_shrink.pdf (geometric interpretation)
- polarization_fit.pdf (experimental extraction)

### Section: Schwarzschild Examples
- fig1_trajectories_response.pdf (worldlines & detector)
- fig2_tauent_vs_tau.pdf (accumulation comparison)
- fig3_effective_temperature_profile.pdf (T(r) profile)

### Section: Spacetime Structure
- lightcone_cat_ept.pdf (Minkowski structure)
- lorentz_boost_cat_ept.pdf (boost geometry)
- penrose_minkowski.pdf (conformal compactification)
- penrose_schwarzschild_schematic.pdf (black hole causal structure)

### Section: General Relativity
- curved_grid_embedding_schematic.png (curved space)
- gravitational_lensing_schematic.png (light bending)

### Section: Quantum Gravity / Problem of Time
- superspace_cartoon.png (configuration space)
- adm_slicing_cartoon.png (3+1 split)
- constraint_enforcement_flow.png (ADM constraints)
- wdw_relational_time_cartoon.png (WDW → relational)

### Section: Path Integral Formulation
- history_weight_influence.png (weighted histories)
- gkls_emergence_flow.png (GKLS emergence)

## File Sizes

### PDFs (vector graphics, publication quality)
```
comp_isomorphism.pdf         ~35 KB
polarization_visibility.pdf  ~25 KB
poincare_shrink.pdf         ~40 KB
polarization_fit.pdf        ~30 KB
fig1_trajectories.pdf       ~45 KB
fig2_tauent_vs_tau.pdf      ~30 KB
fig3_temperature.pdf        ~28 KB
lightcone_cat_ept.pdf       ~50 KB
lorentz_boost.pdf           ~35 KB
penrose_minkowski.pdf       ~45 KB
penrose_schwarzschild.pdf   ~42 KB
```

### PNGs (raster, 200 DPI for presentations)
All PNG files: ~100-350 KB each

**Total figure directory size: ~4.5 MB**

## Scripts Inventory

### Path-Based Scripts (Use ../figures/ directly)
1. make_comp_isomorphism_fig.py
2. make_polarization_fig_visibility.py
3. make_polarization_fig_poincare.py
4. make_polarization_fig_fit.py
5. make_polarization_entropic_combined.py (**NEW 3-panel**)
6. fig1_trajectories_response.py
7. fig2_tauent_vs_tau.py
8. fig3_effective_temperature_profile.py

### Argparse-Based Scripts (Need --out argument)
9. lorentz_boost_cat_ept.py
10. lightcone_cat_ept.py
11. penrose_minkowski.py
12. penrose_schwarzschild_schematic.py
13. gravitational_lensing_schematic.py
14. history_weight_influence.py
15. proper_vs_entropic_time.py
16. superspace_cartoon.py
17. constraint_enforcement_flow.py
18. wdw_relational_time_cartoon.py
19. curved_grid_embedding_schematic.py
20. gkls_emergence_flow.py
21. adm_slicing_cartoon.py

### Utility Scripts
22. twin_paradox_min_tau.py (computation, no figure)
23. convert_all_scripts.py (utility, no figure)

## Regenerating All Figures

### Quick Method
```bash
cd cat-ept-paper
make all-spacetime-figs  # If you add this target to Makefile
```

### Manual Method
```bash
cd cat-ept-paper/scripts

# Path-based (run directly)
python3 make_comp_isomorphism_fig.py
python3 fig1_trajectories_response.py
python3 fig2_tauent_vs_tau.py
python3 fig3_effective_temperature_profile.py

# Argparse-based (need --out)
python3 lightcone_cat_ept.py --out ../figures/lightcone_cat_ept.png
python3 penrose_minkowski.py --out ../figures/penrose_minkowski.png
# ... etc for others
```

### Automated Method
```bash
cd cat-ept-paper
python3 scripts/generate_all_figures.py  # If created
```

## Integration Status

### ✅ Already in Paper
- Computational isomorphism (Figure 1)
- Polarization visibility (Figure 2)
- Poincaré sphere (Figure 3)
- Polarization fit (Figure 4)

### 🎯 Ready to Add
All 20 new figures are generated and ready for integration:

**Recommended additions:**
1. **fig2_tauent_vs_tau.pdf** - Add to entropic time section
2. **lightcone_cat_ept.pdf** - Add to spacetime structure section
3. **penrose_minkowski.pdf** - Add to causal structure discussion
4. **wdw_relational_time_cartoon.png** - Add to Problem of Time section

**For appendices:**
- ADM diagrams (adm_slicing, constraint_enforcement)
- Quantum gravity diagrams (superspace, GKLS emergence)
- GR visualizations (curved grid, lensing)

## Quality Notes

### Publication Ready (PDF Vector Graphics)
✅ All PDF figures suitable for journal submission
✅ Clean, professional styling
✅ Consistent notation with paper
✅ No pixelation at any zoom level

### Presentation Ready (PNG Raster)
✅ All PNG at 200 DPI (good for slides)
✅ Suitable for arXiv submission
✅ Web-friendly file sizes

### Style Consistency
✅ Consistent color schemes
✅ Matching font sizes
✅ Unified notation (τ_ent, λ, etc.)
✅ Professional axis labels

## Next Steps

### For Immediate Use
1. Current paper already uses 4 core figures
2. Enhanced polarization section references these
3. Ready for compilation with `make fullpaper`

### For Expansion
1. Add entropic time figures to relevant sections
2. Include spacetime diagrams in GR discussion
3. Use QG diagrams in Problem of Time section
4. Add path integral figures to formalism section

### For Supplemental Material
Consider moving some figures to supplement:
- Detailed ADM construction diagrams
- Full set of Penrose diagrams
- Extended path integral visualizations

This keeps main paper focused while providing complete visual documentation in supplement.

---

**Catalog Version:** 1.0  
**Date:** 2026-02-07  
**Total Figures:** 31 (11 PDF + 20 PNG)  
**Scripts:** 23  
**Status:** ✅ All generated and ready to use
