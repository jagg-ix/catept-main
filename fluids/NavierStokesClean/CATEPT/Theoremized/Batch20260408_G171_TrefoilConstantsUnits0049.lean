import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 171

Physical constants/units scaffold extracted from
`0049_part_1_module_setup_constants_units_.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G171

noncomputable section

namespace Const

def hbar : ℝ := 1.054571817 / (10 : ℝ) ^ (34 : ℕ)
def c : ℝ := 2.99792458 * (10 : ℝ) ^ (8 : ℕ)
def kB : ℝ := 1.380649 / (10 : ℝ) ^ (23 : ℕ)
def G : ℝ := 6.67430 / (10 : ℝ) ^ (11 : ℕ)

def alphaInv : ℝ := 137.035999084
def alpha : ℝ := 1 / alphaInv
def e : ℝ := 1.602176634 / (10 : ℝ) ^ (19 : ℕ)

def m_e : ℝ := 9.109383713 / (10 : ℝ) ^ (31 : ℕ)
def m_mu : ℝ := 1.883531627 / (10 : ℝ) ^ (28 : ℕ)

def muB (m : ℝ) : ℝ := e * hbar / (2 * m)

def alphaAtMu : ℝ := alpha

theorem alphaAtMu_eq_alpha : alphaAtMu = alpha := rfl

theorem alphaInv_pos : 0 < alphaInv := by
  norm_num [alphaInv]

theorem alpha_mul_alphaInv : alpha * alphaInv = 1 := by
  have hne : alphaInv ≠ 0 := ne_of_gt alphaInv_pos
  unfold alpha
  field_simp [hne]

theorem muB_formula (m : ℝ) : muB m = e * hbar / (2 * m) := rfl

theorem muB_scaling (m : ℝ) (hm : m ≠ 0) :
    muB m * m = e * hbar / 2 := by
  unfold muB
  field_simp [hm]

end Const

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G171
