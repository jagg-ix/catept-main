import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 262

Finite path-integral kernel scaffold adapted from
`0011_lean4_code.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G262

noncomputable section

open scoped BigOperators

def discreteAction (x y : ℝ) : ℝ := (y - x) ^ 2

def pathKernel (β x y : ℝ) : ℝ := Real.exp (-β * discreteAction x y)

def finiteSelfPartition (β : ℝ) {n : Nat} (states : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, pathKernel β (states i) (states i)

theorem pathKernel_pos (β x y : ℝ) : 0 < pathKernel β x y := by
  unfold pathKernel
  exact Real.exp_pos _

theorem pathKernel_nonneg (β x y : ℝ) : 0 ≤ pathKernel β x y :=
  (pathKernel_pos β x y).le

theorem pathKernel_self_eq_exp_zero (β x : ℝ) :
    pathKernel β x x = 1 := by
  simp [pathKernel, discreteAction]

theorem finiteSelfPartition_nonneg (β : ℝ) {n : Nat} (states : Fin n → ℝ) :
    0 ≤ finiteSelfPartition β states := by
  unfold finiteSelfPartition
  exact Finset.sum_nonneg (by
    intro i hi
    exact pathKernel_nonneg β (states i) (states i))

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G262
