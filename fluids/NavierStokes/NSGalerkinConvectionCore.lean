import NavierStokes.Core.NSFieldFourierComplex

/-!
# NSGalerkinConvectionCore

Shared core definitions for Galerkin convection modules.
-/

namespace NavierStokes.GalerkinConvection

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel

/-- A Galerkin basis for an N-mode system: wavevectors with the Galerkin
    frequency cutoff. -/
structure GalerkinBasis (N : Nat) where
  wvec    : Fin N → WaveVec
  freq_le : ∀ i : Fin N, waveVecMag2 (wvec i) ≤ (galerkinN : Rat) ^ 2

/-- Extract the `GalerkinBasis` from an `NSFieldGalerkinK`. -/
def NSFieldGalerkinK.toBasis (v : NSFieldGalerkinK) : GalerkinBasis v.N :=
  { wvec := v.wvec, freq_le := v.freq_le }

end NavierStokes.GalerkinConvection

