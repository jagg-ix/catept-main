import NavierStokes.NSFieldFourierComplex

/-!
# NSGalerkinConvectionCore

Shared core definitions for Galerkin convection modules.
-/

namespace NavierStokes.GalerkinConvection

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel

/-- A Galerkin basis for an N-mode system: wavevectors with the Galerkin
    frequency cutoff plus a triadic interaction kernel.

    `triadK` has a default zero kernel so legacy basis constructors stay valid
    while concrete files progressively supply calibrated coefficients. -/
structure GalerkinBasis (N : Nat) where
  wvec    : Fin N → WaveVec
  freq_le : ∀ i : Fin N, waveVecMag2 (wvec i) ≤ (galerkinN : Rat) ^ 2
  triadK  : Fin N → Fin N → Fin N → Rat := fun _ _ _ => 0

/-- Extract the `GalerkinBasis` from an `NSFieldGalerkinK`. -/
def NSFieldGalerkinK.toBasis (v : NSFieldGalerkinK) : GalerkinBasis v.N :=
  { wvec := v.wvec, freq_le := v.freq_le }

end NavierStokes.GalerkinConvection
