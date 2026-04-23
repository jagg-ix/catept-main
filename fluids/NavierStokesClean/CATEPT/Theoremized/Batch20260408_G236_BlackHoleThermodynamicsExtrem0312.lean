import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 236

Black-hole thermodynamics extremality scaffold adapted from
`0312_2.3_black-hole_thermodynamics_extrem.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G236

noncomputable section

structure KerrProxy where
  mass : ℝ
  angMom : ℝ
  mass_nonneg : 0 ≤ mass

def extremalityGap (K : KerrProxy) : ℝ := K.mass ^ 2 - |K.angMom|

def isSubExtremal (K : KerrProxy) : Prop := 0 ≤ extremalityGap K

def hawkingTemperatureProxy (K : KerrProxy) : ℝ := extremalityGap K

def bekensteinHawkingEntropyProxy (K : KerrProxy) : ℝ :=
  K.mass ^ 2 + Real.sqrt (max 0 (extremalityGap K))

theorem subExtremal_iff_massSq_ge_absSpin (K : KerrProxy) :
    isSubExtremal K ↔ |K.angMom| ≤ K.mass ^ 2 := by
  unfold isSubExtremal extremalityGap
  constructor
  · intro h
    exact sub_nonneg.mp h
  · intro h
    exact sub_nonneg.mpr h

theorem extremalityGap_eq_zero_of_massSq_eq_absSpin
    (K : KerrProxy) (h : K.mass ^ 2 = |K.angMom|) :
    extremalityGap K = 0 := by
  unfold extremalityGap
  linarith

theorem hawkingTemperatureProxy_nonneg_of_subExtremal
    (K : KerrProxy) (hSub : isSubExtremal K) :
    0 ≤ hawkingTemperatureProxy K := by
  simpa [hawkingTemperatureProxy] using hSub

theorem entropyProxy_ge_massSq (K : KerrProxy) :
    K.mass ^ 2 ≤ bekensteinHawkingEntropyProxy K := by
  unfold bekensteinHawkingEntropyProxy
  have hsqrt : 0 ≤ Real.sqrt (max 0 (extremalityGap K)) := Real.sqrt_nonneg _
  linarith

theorem entropyProxy_nonneg (K : KerrProxy) :
    0 ≤ bekensteinHawkingEntropyProxy K := by
  have hMassSq : 0 ≤ K.mass ^ 2 := sq_nonneg K.mass
  have hGe : K.mass ^ 2 ≤ bekensteinHawkingEntropyProxy K := entropyProxy_ge_massSq K
  linarith

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G236
