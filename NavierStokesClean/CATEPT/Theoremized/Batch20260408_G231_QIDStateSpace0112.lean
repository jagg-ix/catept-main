import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 231

QID state-space scaffold adapted from
`0112_implementation_for_qidstatespace.lea.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G231

noncomputable section

structure QIDState where
  amplitude : ℝ
  phase : ℝ
  density : ℝ
  density_nonneg : 0 ≤ density

def qidNorm (s : QIDState) : ℝ :=
  Real.sqrt (s.amplitude ^ 2 + s.phase ^ 2)

def qidDistance (s₁ s₂ : QIDState) : ℝ :=
  |s₁.amplitude - s₂.amplitude| + |s₁.phase - s₂.phase|

theorem qidDistance_nonneg (s₁ s₂ : QIDState) : 0 ≤ qidDistance s₁ s₂ := by
  unfold qidDistance
  positivity

theorem qidDistance_self (s : QIDState) : qidDistance s s = 0 := by
  unfold qidDistance
  simp

theorem qidDistance_symm (s₁ s₂ : QIDState) : qidDistance s₁ s₂ = qidDistance s₂ s₁ := by
  unfold qidDistance
  rw [abs_sub_comm (s₁.phase) (s₂.phase)]

theorem qidNorm_nonneg (s : QIDState) : 0 ≤ qidNorm s := by
  unfold qidNorm
  exact Real.sqrt_nonneg _

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G231
