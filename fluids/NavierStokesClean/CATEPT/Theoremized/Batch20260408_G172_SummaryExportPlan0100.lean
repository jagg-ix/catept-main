import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 172

PhysLean-compatible export summary scaffold extracted from
`0100_summary_of_export_plan.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G172

noncomputable section

namespace Const

def hbar : ℝ := 1.054571817 / (10 : ℝ) ^ (34 : ℕ)
def c : ℝ := 2.99792458 * (10 : ℝ) ^ (8 : ℕ)
def G : ℝ := 6.67430 / (10 : ℝ) ^ (11 : ℕ)
def e : ℝ := 1.602176634 / (10 : ℝ) ^ (19 : ℕ)
def alphaInv : ℝ := 137.035999084
def alpha : ℝ := 1 / alphaInv

def m_e : ℝ := 9.109383713 / (10 : ℝ) ^ (31 : ℕ)
def m_mu : ℝ := 1.883531627 / (10 : ℝ) ^ (28 : ℕ)

def ihbar : ℂ := Complex.I * hbar

theorem ihbar_re : Complex.re ihbar = 0 := by
  unfold ihbar
  simp

theorem ihbar_im : Complex.im ihbar = hbar := by
  unfold ihbar
  simp

theorem alphaInv_pos : 0 < alphaInv := by
  norm_num [alphaInv]

theorem alpha_mul_alphaInv : alpha * alphaInv = 1 := by
  have hne : alphaInv ≠ 0 := ne_of_gt alphaInv_pos
  unfold alpha
  field_simp [hne]

end Const

structure ComplexAction where
  realPart : ℝ
  imagPart : ℝ

def actionAsComplex (S : ComplexAction) : ℂ :=
  ⟨S.realPart, S.imagPart⟩

theorem actionAsComplex_re (S : ComplexAction) :
    Complex.re (actionAsComplex S) = S.realPart := rfl

theorem actionAsComplex_im (S : ComplexAction) :
    Complex.im (actionAsComplex S) = S.imagPart := rfl

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G172
