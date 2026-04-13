import NavierStokesClean.CATEPT.Foundations
import NavierStokesClean.CATEPT.PathIntegrals

/-!
# Batch 20260408 Theoremization - CATEPT Row 37 (UTT FinalApp Namespace 0019)

Probability-damping wrappers aligned with the UTT namespace seed.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B37

noncomputable section

open NavierStokesClean.CATEPT

/-- UTT-style probability map from imaginary action. -/
def utt_probability (S_I : ℝ) : ℝ := Real.exp (-2 * S_I)

/-- UTT probability is exactly CAT/EPT damping at `ℏ = 1/2`. -/
theorem row37_probability_eq_damping_half (S_I : ℝ) :
    utt_probability S_I = path_integral_damping (1 / 2) S_I := by
  unfold utt_probability path_integral_damping
  congr 1
  ring

/-- UTT probability is strictly positive. -/
theorem row37_probability_pos (S_I : ℝ) :
    0 < utt_probability S_I := by
  unfold utt_probability
  exact Real.exp_pos _

/-- UTT probability is contractive (`≤ 1`) when `S_I ≥ 0`. -/
theorem row37_probability_le_one_of_nonneg (S_I : ℝ) (hS : 0 ≤ S_I) :
    utt_probability S_I ≤ 1 := by
  rw [row37_probability_eq_damping_half]
  have hh : 0 < (1 / 2 : ℝ) := by norm_num
  exact eq054_damping_magnitude (hbar := (1 / 2 : ℝ)) (S_I := S_I) hh hS

/-- Combined row-37 closure witness: positivity + contractivity + entropic nonnegativity. -/
theorem row37_probability_entropic_bundle
    (hbar S_I : ℝ)
    (h_hbar : 0 < hbar)
    (hS : 0 ≤ S_I) :
    0 < utt_probability S_I ∧
      utt_probability S_I ≤ 1 ∧
      0 ≤ entropic_time hbar S_I := by
  exact ⟨row37_probability_pos S_I,
    row37_probability_le_one_of_nonneg S_I hS,
    eq003_entropic_time_nonneg hbar S_I h_hbar hS⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B37

