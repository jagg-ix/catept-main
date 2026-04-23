import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 241

Fourier-relative gravity scaffold adapted from
`0191_lean4_module_fourierrelativegravity..lean`.
-/

set_option autoImplicit false

open scoped BigOperators

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G241

noncomputable section

abbrev FourierMode := ℕ → ℂ

def modePower (phi : FourierMode) (k : ℕ) : ℝ := ‖phi k‖ ^ 2

def truncationEnergy (phi : FourierMode) (N : ℕ) : ℝ :=
  (Finset.range (N + 1)).sum (fun k => modePower phi k)

structure RelativeGravityModel where
  G0 : ℝ
  α : ℝ
  G0_pos : 0 < G0
  α_nonneg : 0 ≤ α

def effectiveCoupling (M : RelativeGravityModel) (phi : FourierMode) (N : ℕ) : ℝ :=
  M.G0 + M.α * truncationEnergy phi N

theorem modePower_nonneg (phi : FourierMode) (k : ℕ) : 0 ≤ modePower phi k := by
  simp [modePower]

theorem truncationEnergy_nonneg (phi : FourierMode) (N : ℕ) : 0 ≤ truncationEnergy phi N := by
  unfold truncationEnergy
  exact Finset.sum_nonneg (by
    intro k hk
    exact modePower_nonneg phi k)

theorem effectiveCoupling_ge_base
    (M : RelativeGravityModel) (phi : FourierMode) (N : ℕ) :
    M.G0 ≤ effectiveCoupling M phi N := by
  unfold effectiveCoupling
  have hNonneg : 0 ≤ M.α * truncationEnergy phi N :=
    mul_nonneg M.α_nonneg (truncationEnergy_nonneg phi N)
  linarith

theorem effectiveCoupling_pos
    (M : RelativeGravityModel) (phi : FourierMode) (N : ℕ) :
    0 < effectiveCoupling M phi N := by
  have hge : M.G0 ≤ effectiveCoupling M phi N := effectiveCoupling_ge_base M phi N
  linarith [M.G0_pos, hge]

theorem effectiveCoupling_step
    (M : RelativeGravityModel) (phi : FourierMode) (N : ℕ) :
    effectiveCoupling M phi (N + 1)
      = effectiveCoupling M phi N + M.α * modePower phi (N + 1) := by
  unfold effectiveCoupling truncationEnergy
  rw [Finset.sum_range_succ]
  ring

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G241
