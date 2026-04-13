import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 254

Complex-action analysis scaffold adapted from
`0021_analysis_of_complex_action_in_the_co.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G254

noncomputable section

structure ComplexActionPoint where
  Sre : ℝ
  Sim : ℝ

def actionAsComplex (A : ComplexActionPoint) : ℂ :=
  (A.Sre : ℂ) + (A.Sim : ℂ) * Complex.I

def dampingWeight (A : ComplexActionPoint) : ℝ :=
  Real.exp (-A.Sim)

def oscillatoryPhase (A : ComplexActionPoint) : ℂ :=
  Complex.exp (Complex.I * actionAsComplex A)

theorem actionAsComplex_re (A : ComplexActionPoint) :
    (actionAsComplex A).re = A.Sre := by
  simp [actionAsComplex]

theorem actionAsComplex_im (A : ComplexActionPoint) :
    (actionAsComplex A).im = A.Sim := by
  simp [actionAsComplex]

theorem dampingWeight_pos (A : ComplexActionPoint) :
    0 < dampingWeight A := by
  unfold dampingWeight
  exact Real.exp_pos _

theorem dampingWeight_nonneg (A : ComplexActionPoint) :
    0 ≤ dampingWeight A := by
  exact (dampingWeight_pos A).le

theorem dampingWeight_le_one_of_im_nonneg
    (A : ComplexActionPoint) (h : 0 ≤ A.Sim) :
    dampingWeight A ≤ 1 := by
  unfold dampingWeight
  have hneg : -A.Sim ≤ 0 := by linarith
  simpa using Real.exp_le_exp.mpr hneg

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G254
