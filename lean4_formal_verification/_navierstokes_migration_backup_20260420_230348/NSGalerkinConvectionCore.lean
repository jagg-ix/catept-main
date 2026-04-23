import NavierStokes.Core.NSFieldFourierComplex
import NavierStokes.Galerkin.NSGalerkinPhysicalTriadKernel

/-!
# NSGalerkinConvectionCore

Shared core definitions for Galerkin convection modules.

## Stage 225 update

`GalerkinBasis.triadK` no longer has a zero-placeholder default.  The only
construction site (`NSFieldGalerkinK.toBasis`) now supplies the physical kernel
`physicalTriadKCoeff v.wvec` from `NSGalerkinPhysicalTriadKernel`.  This makes
`galerkinConvection` non-trivial and `galerkin_enstrophy_production_le_nuP`
honest (no longer vacuously proved via production = 0).
-/

namespace NavierStokes.GalerkinConvection

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinPhysicalTriadKernel

/-- A Galerkin basis for an N-mode system: wavevectors with the Galerkin
    frequency cutoff plus a triadic interaction kernel.

    `triadK` carries the (non-zero) physical interaction coefficients.
    All construction sites must supply a concrete kernel; the physical
    default is provided by `NSFieldGalerkinK.toBasis` via `physicalTriadKCoeff`. -/
structure GalerkinBasis (N : Nat) where
  wvec    : Fin N → WaveVec
  freq_le : ∀ i : Fin N, waveVecMag2 (wvec i) ≤ (galerkinN : Rat) ^ 2
  triadK  : Fin N → Fin N → Fin N → Rat

/-- Extract the `GalerkinBasis` from an `NSFieldGalerkinK`.

    Uses the physical triadic interaction kernel `physicalTriadKCoeff v.wvec`
    (Stage 225: replaces the former zero-placeholder default).
    Marked `noncomputable` because `physicalTriadKCoeff` is an opaque axiom. -/
noncomputable def NSFieldGalerkinK.toBasis (v : NSFieldGalerkinK) : GalerkinBasis v.N :=
  { wvec := v.wvec, freq_le := v.freq_le, triadK := physicalTriadKCoeff v.wvec }

end NavierStokes.GalerkinConvection
