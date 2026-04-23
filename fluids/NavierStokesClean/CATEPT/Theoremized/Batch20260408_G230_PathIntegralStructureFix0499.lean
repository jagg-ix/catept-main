import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 230

Path-integral structure-field fix scaffold adapted from
`0499_1._fix_structures.lean_-_use_as_fiel.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G230

noncomputable section

structure KernelConfig where
  beta : ℝ
  mass : ℝ
  beta_pos : 0 < beta
  mass_nonneg : 0 ≤ mass

def gaussianKernel (K : KernelConfig) (dx : ℝ) : ℝ :=
  Real.exp (-K.beta * K.mass * dx ^ 2)

def composeKernel (K : KernelConfig) (dx1 dx2 : ℝ) : ℝ :=
  gaussianKernel K dx1 * gaussianKernel K dx2

theorem gaussianKernel_pos (K : KernelConfig) (dx : ℝ) :
    0 < gaussianKernel K dx := by
  unfold gaussianKernel
  exact Real.exp_pos _

theorem gaussianKernel_nonneg (K : KernelConfig) (dx : ℝ) :
    0 ≤ gaussianKernel K dx := (gaussianKernel_pos K dx).le

theorem composeKernel_pos (K : KernelConfig) (dx1 dx2 : ℝ) :
    0 < composeKernel K dx1 dx2 := by
  unfold composeKernel
  exact mul_pos (gaussianKernel_pos K dx1) (gaussianKernel_pos K dx2)

theorem gaussianKernel_even (K : KernelConfig) (dx : ℝ) :
    gaussianKernel K (-dx) = gaussianKernel K dx := by
  unfold gaussianKernel
  ring_nf

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G230
