# Quick Integration Guide: Polarization Section

## Where to Add in Main Paper

The polarization section (`polarization_section_PRL.tex`) should be inserted **immediately after** the existing visibility and decoherence discussion.

### Exact Location

In `main.tex`, find this section:

```latex
\subsection{Experimental manifestation: Visibility and decoherence}
\label{subsec:experimental_visibility}

We now connect the theoretical framework to experimental observables through 
the visibility of quantum interference patterns...
```

**After this entire subsection ends**, insert:

```latex
% ========== INSERT POLARIZATION MODULE HERE ==========
\input{polarization_section_PRL}
% ======================================================
```

## What Gets Added

The polarization section adds (~4 pages PRL-style):

1. **Two-mode formalism** (Stokes operators, Schwinger SU(2))
2. **Pure dephasing master equation** 
3. **Visibility-entropic time relation**: τ_ent = -ln(V/V₀)
4. **Computational bounds connection** (Margolus-Levitin + Landauer)
5. **Experimental protocol** (6-step measurement procedure)
6. **Chiral asymmetry prediction** (falsifiable: δλ/λ ~ 10⁻⁸)
7. **Π-parameter integration** (Π_pol ~ 10⁻¹⁰)

## Key Figure

The section references Figure `polarization_entropic_combined` which shows:
- **(a)** Poincaré sphere with Bloch vector decay
- **(b)** Visibility decay V(t) for two rates
- **(c)** Entropic time accumulation τ_ent(t)

This figure is **publication-ready** and can go in PRL main text.

## Files to Copy

### 1. LaTeX Content
```bash
cp polarization_section_PRL.tex your-repo/latex/
```

### 2. Figure Scripts
```bash
cp make_polarization_entropic_combined.py your-repo/scripts/
cp make_poincare_decay_enhanced.py your-repo/scripts/
cp make_tau_ent_comparison.py your-repo/scripts/
```

### 3. Build System
```bash
cp Makefile_enhanced your-repo/Makefile
```

## Build Instructions

```bash
cd your-repo

# Generate new figures
make pol-figs

# Compile paper
make fullpaper
```

## Result

You'll get:
- ✓ Clean experimental platform (polarization)
- ✓ Direct τ_ent measurement protocol
- ✓ Connection to information theory (Landauer/Margolus-Levitin)
- ✓ Falsifiable prediction (chiral splitting)
- ✓ Publication-quality 3-panel figure
- ✓ PRL-friendly length (~4 pages)

## What NOT to Include (Keep for Supplement)

These are in `polarization_module.tex` but too long for PRL main text:
- Full QRF formalism (relational Hilbert spaces)
- Complexified Pauli algebra details
- Extended theorem-proof structure
- Synchronization cost derivations
- Entangled photon treatment

**Recommendation:** Put these in supplemental material if submitting to PRL.

## Cross-References to Update

The polarization section references:
- `Section~\ref{subsec:computational}` - Your Margolus-Levitin section
- `Figure~\ref{fig:comp_isomorphism}` - Computational isomorphism diagram
- `Section~\ref{subsec:operational_meaning}` - Page-Wootters discussion

Make sure these labels exist in your main.tex or update them to match your actual labels.

## Bibliography Additions

Add to `references.bib` if not already present:

```bibtex
@article{Saito2023,
  author = {Saito, H.},
  title = {Quantum-mechanical representation of polarization of coherent light},
  journal = {Phys. Rev. A},
  volume = {107},
  pages = {043702},
  year = {2023},
  doi = {10.1103/PhysRevA.107.043702}
}
```

## Testing Checklist

After integration:
- [ ] Paper compiles without errors
- [ ] New figure generates correctly
- [ ] Cross-references resolve
- [ ] Bibliography complete
- [ ] Equation numbers sequential
- [ ] Total length acceptable for target venue

## Length Control

**Current section:** ~4 pages (2-column PRL format)

**To shorten (if needed):**
- Remove chiral asymmetry paragraph (-0.5 pages)
- Condense experimental protocol to 3 steps (-0.3 pages)  
- Remove Π-parameter integration (-0.3 pages)
- Combine eqs. (eq:pol_HI) and (eq:landauer_pol) (-0.2 pages)

**Minimum viable:** ~2.5 pages with just:
- Two-mode formalism
- Visibility = entropic time relation
- Key figure
- Experimental protocol

## PRL Submission Strategy

**Main Text:**
- Use `polarization_section_PRL.tex` (this file)
- Include Figure `polarization_entropic_combined`
- ~4 pages total addition

**Supplemental Material:**
- Use full `polarization_module.tex`
- Include all additional figures
- Full QRF treatment
- Mathematical details

This gives reviewers complete picture while keeping main text tight.

## Contact for Issues

If figures don't generate:
1. Check Python packages: `pip install matplotlib numpy scipy`
2. Verify paths in scripts use `../figures/`
3. Check Makefile targets match script names

If compilation fails:
1. Ensure `\input{polarization_section_PRL}` path is correct
2. Check all `\label{}` and `\ref{}` are defined
3. Run `bibtex` explicitly if bibliography errors

---

**Quick Start (5 minutes):**
```bash
# 1. Copy files
cp polarization_section_PRL.tex latex/
cp make_polarization_entropic_combined.py scripts/
cp Makefile_enhanced Makefile

# 2. Edit main.tex - add after visibility section:
#    \input{polarization_section_PRL}

# 3. Build
make pol-combined  # Generate key figure
make fullpaper     # Compile with bibliography
```

You're done! The section integrates cleanly and adds substantial experimental content.
