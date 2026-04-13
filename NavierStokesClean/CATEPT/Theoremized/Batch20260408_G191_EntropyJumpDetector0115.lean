import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 191

Entropy-jump detector protocol scaffold adapted from
`0115_implementation_for_entropyjumpdetect.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G191

noncomputable section

structure EntropyJumpDetector where
  threshold : ℝ
  threshold_nonneg : 0 ≤ threshold

def entropyJump (ePrev eNext : ℝ) : ℝ := eNext - ePrev

def jumpDetected (D : EntropyJumpDetector) (ePrev eNext : ℝ) : Prop :=
  D.threshold ≤ |entropyJump ePrev eNext|

def stableTransition (D : EntropyJumpDetector) (ePrev eNext : ℝ) : Prop :=
  |entropyJump ePrev eNext| < D.threshold

theorem jumpDetected_of_abs_ge_threshold
    (D : EntropyJumpDetector) (ePrev eNext : ℝ)
    (h : D.threshold ≤ |entropyJump ePrev eNext|) :
    jumpDetected D ePrev eNext := h

theorem not_jumpDetected_of_stableTransition
    (D : EntropyJumpDetector) (ePrev eNext : ℝ)
    (h : stableTransition D ePrev eNext) :
    ¬ jumpDetected D ePrev eNext := by
  intro hJump
  unfold stableTransition at h
  exact not_lt_of_ge hJump h

theorem stable_or_detected
    (D : EntropyJumpDetector) (ePrev eNext : ℝ) :
    stableTransition D ePrev eNext ∨ jumpDetected D ePrev eNext := by
  by_cases h : |entropyJump ePrev eNext| < D.threshold
  · exact Or.inl h
  · exact Or.inr (le_of_not_gt h)

theorem entropyJump_zero_iff (e : ℝ) : entropyJump e e = 0 := by
  simp [entropyJump]

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G191
