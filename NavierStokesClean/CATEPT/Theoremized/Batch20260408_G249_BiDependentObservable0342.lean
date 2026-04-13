import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 249

Observable bi-dependence scaffold adapted from
`0342_claim_1b_observables_depend_on_both_.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G249

noncomputable section

def biObservable (state kernel : ℝ) : ℝ := state + kernel

theorem biObservable_depends_on_state
    {s1 s2 k : ℝ} (h : s1 ≠ s2) :
    biObservable s1 k ≠ biObservable s2 k := by
  intro hEq
  apply h
  unfold biObservable at hEq
  linarith

theorem biObservable_depends_on_kernel
    {k1 k2 s : ℝ} (h : k1 ≠ k2) :
    biObservable s k1 ≠ biObservable s k2 := by
  intro hEq
  apply h
  unfold biObservable at hEq
  linarith

theorem biObservable_joint_split
    (s1 s2 k1 k2 : ℝ) :
    biObservable s1 k1 - biObservable s2 k2 = (s1 - s2) + (k1 - k2) := by
  unfold biObservable
  ring

theorem biObservable_additive (s k a b : ℝ) :
    biObservable (s + a) (k + b) = biObservable s k + (a + b) := by
  unfold biObservable
  ring

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G249
