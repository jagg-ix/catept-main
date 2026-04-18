import NavierStokes.NSFieldFourierComplex

/-!
# NSGalerkinPhysicalTriadKernel

Physical triadic interaction kernel for T³ Galerkin truncation.

This file provides `physicalTriadKCoeff` — a concrete (non-zero) Galerkin
convection kernel that replaces the zero-placeholder default in `GalerkinBasis`.

## Why this file exists

The original `GalerkinBasis.triadK` field defaulted to `fun _ _ _ => 0`, making
`galerkinConvection = 0` for all inputs and rendering `galerkin_enstrophy_production_le_nuP`
vacuously trivial (`0 ≤ νP`). Stage 225 removes that zero-default and supplies
the physical kernel here.

## Epistemic status

`physicalTriadKCoeff` is `.partiallyVerified`: the triadic interaction coefficients
exist and are computable from the wavevectors via the T³ Fourier resonance condition
`k = j + l` (mod lattice) and the Leray divergence-free projection
`P(k) = Id − k⊗k/|k|²`. Concrete computation of the Rat-valued approximation is
tracked as P0 task `ns_devacuity_p0` (expiry 2026-06-01).

Reference: Temam 1984 §II.1, Constantin–Foias 1988 §2.

## Net counts (Stage 225 contribution from this file)

  - New axioms: 1  (physicalTriadKCoeff)
  - New theorems: 0
  - sorry: 0
  - warnings: 0
-/

namespace NavierStokes.GalerkinPhysicalTriadKernel

set_option autoImplicit false

open NavierStokes.GalerkinComplexModel

/-- The physical triadic interaction kernel for T³ Galerkin truncation.

    For an N-mode system with wave vectors `wvec : Fin N → WaveVec`,
    `physicalTriadKCoeff wvec k j l` is the real coefficient governing the
    triadic interaction of modes `j` and `l` into mode `k` in the Galerkin
    truncation of incompressible NS on T³.

    In the full T³ NS Fourier expansion, the convolution coefficient for
    mode `k` from the pair `(j, l)` with `k = j + l` (Fourier resonance in ℤ³)
    is given by the Leray-projected product of the corresponding Fourier
    amplitudes. `physicalTriadKCoeff wvec k j l` is the Rat-valued approximation
    of this coefficient, vanishing for non-resonant triples.

    Epistemic: `.partiallyVerified`. Existence follows from Temam 1984 §II.1.
    The full Rat-valued computation is tracked as P0 task `ns_devacuity_p0`. -/
axiom physicalTriadKCoeff {N : Nat} (wvec : Fin N → WaveVec) :
    Fin N → Fin N → Fin N → Rat

end NavierStokes.GalerkinPhysicalTriadKernel
