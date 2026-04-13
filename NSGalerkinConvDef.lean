import NavierStokesClean.Galerkin.FourierTriadicKernel

/-!
Legacy-compat leverage surface for `NSGalerkinConvDef.lean`.
The clean stack uses `FourierTriadicKernel` as the concrete triadic interface.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NSGalerkinConvDef

open NavierStokesClean.Galerkin

lemma triadK_off_resonance {N : ℕ} (wvec : Fin N → WaveVec3)
    (k j l : Fin N) (h : wvec k ≠ wvec j + wvec l) :
    triadicKCoeff wvec k j l = 0 :=
  triadicKCoeff_off_resonance wvec k j l h

lemma triadK_resonant {N : ℕ} (wvec : Fin N → WaveVec3)
    (k j l : Fin N) (h : wvec k = wvec j + wvec l) :
    triadicKCoeff wvec k j l = (waveVecDot3 (wvec k) (wvec j) : ℚ) / waveVecMag2_3 (wvec k) :=
  triadicKCoeff_resonant wvec k j l h

lemma triadK_cases {N : ℕ} (wvec : Fin N → WaveVec3) (k j l : Fin N) :
    triadicKCoeff wvec k j l = 0 ∨
      triadicKCoeff wvec k j l = (waveVecDot3 (wvec k) (wvec j) : ℚ) / waveVecMag2_3 (wvec k) :=
  triadicKCoeff_cases wvec k j l

end NavierStokesClean.LegacyCompat.NSGalerkinConvDef
