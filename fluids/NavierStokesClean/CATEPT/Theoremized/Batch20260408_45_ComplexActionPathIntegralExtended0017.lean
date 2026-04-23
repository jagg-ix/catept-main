import Mathlib.Analysis.Complex.Basic
import NavierStokesClean.CATEPT.Foundations

/-!
# Batch 20260408 Theoremization - CATEPT Row 45 (Complex Action Path Integral Extended 0017)

Complex-action path-weight wrappers with entropic-time compatibility.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B45

noncomputable section

open NavierStokesClean.CATEPT

/-- Complex action packed as `S_R + i*S_I`. -/
def row45_complexAction (S_R S_I : ℝ) : ℂ := Complex.mk S_R S_I

/-- Path-weight kernel `exp(i*S/ℏ)`. -/
def row45_amplitude (hbar S_R S_I : ℝ) : ℂ :=
  Complex.exp ((-(S_I / hbar) : ℂ) + (((S_R / hbar : ℝ) : ℂ) * Complex.I))

/-- Amplitude norm equals damping envelope `exp(-S_I/ℏ)`. -/
theorem row45_norm_amplitude
    (hbar S_R S_I : ℝ) :
    ‖row45_amplitude hbar S_R S_I‖ = Real.exp (-S_I / hbar) := by
  unfold row45_amplitude
  rw [Complex.norm_exp]
  simp [neg_div]

/-- For nonnegative imaginary action, the amplitude norm is bounded by 1. -/
theorem row45_norm_amplitude_le_one
    (hbar S_R S_I : ℝ) (h_hbar : 0 < hbar) (hSI : 0 ≤ S_I) :
    ‖row45_amplitude hbar S_R S_I‖ ≤ 1 := by
  rw [row45_norm_amplitude hbar S_R S_I]
  rw [← Real.exp_zero]
  apply Real.exp_le_exp.mpr
  exact div_nonpos_of_nonpos_of_nonneg (by linarith) (le_of_lt h_hbar)

/-- Entropic time is nonnegative for nonnegative imaginary action. -/
theorem row45_entropic_time_nonneg
    (hbar S_I : ℝ) (h_hbar : 0 < hbar) (hSI : 0 ≤ S_I) :
    0 ≤ entropic_time hbar S_I :=
  eq003_entropic_time_nonneg hbar S_I h_hbar hSI

/-- Combined row-45 closure witness. -/
theorem row45_path_weight_bundle
    (hbar S_R S_I : ℝ) (h_hbar : 0 < hbar) (hSI : 0 ≤ S_I) :
    ‖row45_amplitude hbar S_R S_I‖ = Real.exp (-S_I / hbar) ∧
      ‖row45_amplitude hbar S_R S_I‖ ≤ 1 ∧
      0 ≤ entropic_time hbar S_I := by
  exact ⟨row45_norm_amplitude hbar S_R S_I,
    row45_norm_amplitude_le_one hbar S_R S_I h_hbar hSI,
    row45_entropic_time_nonneg hbar S_I h_hbar hSI⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B45
