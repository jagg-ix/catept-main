import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 229

Path-integral variable scoping fix scaffold adapted from
`0491_fix_proper_variable_scoping_and_inne.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G229

noncomputable section

def innerKernel (β x y : ℝ) : ℝ := Real.exp (-β * (y - x) ^ 2)

def scopedWeight (β x y z : ℝ) : ℝ :=
  let inner := innerKernel β x y
  inner * innerKernel β y z

def scopedWeightExpanded (β x y z : ℝ) : ℝ :=
  innerKernel β x y * innerKernel β y z

theorem scopedWeight_eq_expanded (β x y z : ℝ) :
    scopedWeight β x y z = scopedWeightExpanded β x y z := by
  unfold scopedWeight scopedWeightExpanded
  rfl

theorem innerKernel_pos (β x y : ℝ) : 0 < innerKernel β x y := by
  unfold innerKernel
  exact Real.exp_pos _

theorem scopedWeight_pos (β x y z : ℝ) : 0 < scopedWeight β x y z := by
  rw [scopedWeight_eq_expanded]
  unfold scopedWeightExpanded
  exact mul_pos (innerKernel_pos β x y) (innerKernel_pos β y z)

theorem innerKernel_symm (β x y : ℝ) :
    innerKernel β x y = innerKernel β y x := by
  unfold innerKernel
  ring_nf

theorem scopedWeight_swap_first_factor (β x y z : ℝ) :
    scopedWeight β x y z = innerKernel β y x * innerKernel β y z := by
  rw [scopedWeight_eq_expanded]
  unfold scopedWeightExpanded
  rw [innerKernel_symm β x y]

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G229
