import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 228

Complete finite Euclidean path-integral scaffold adapted from
`0488_complete_working_version.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G228

noncomputable section

open scoped BigOperators

def harmonicPotential (ω x : ℝ) : ℝ := (ω ^ 2 * x ^ 2) / 2

def euclideanLagrangian (ω x p : ℝ) : ℝ := (p ^ 2) / 2 + harmonicPotential ω x

def stepWeight (β ω x p : ℝ) : ℝ := Real.exp (-β * euclideanLagrangian ω x p)

def finitePartition (β ω : ℝ) {n : Nat} (xs ps : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, stepWeight β ω (xs i) (ps i)

theorem harmonicPotential_nonneg (ω x : ℝ) : 0 ≤ harmonicPotential ω x := by
  unfold harmonicPotential
  nlinarith

theorem euclideanLagrangian_nonneg (ω x p : ℝ) : 0 ≤ euclideanLagrangian ω x p := by
  unfold euclideanLagrangian
  nlinarith [harmonicPotential_nonneg ω x]

theorem stepWeight_pos (β ω x p : ℝ) : 0 < stepWeight β ω x p := by
  unfold stepWeight
  exact Real.exp_pos _

theorem finitePartition_nonneg (β ω : ℝ) {n : Nat} (xs ps : Fin n → ℝ) :
    0 ≤ finitePartition β ω xs ps := by
  unfold finitePartition
  exact Finset.sum_nonneg (by
    intro i hi
    exact (stepWeight_pos β ω (xs i) (ps i)).le)

theorem finitePartition_pos_of_nonempty
    (β ω : ℝ) {n : Nat} (h : 0 < n) (xs ps : Fin n → ℝ) :
    0 < finitePartition β ω xs ps := by
  let i0 : Fin n := ⟨0, h⟩
  have hterm : 0 < stepWeight β ω (xs i0) (ps i0) := stepWeight_pos β ω (xs i0) (ps i0)
  have hle : stepWeight β ω (xs i0) (ps i0) ≤ finitePartition β ω xs ps := by
    unfold finitePartition
    exact Finset.single_le_sum
      (fun i hi => (stepWeight_pos β ω (xs i) (ps i)).le)
      (by simp [i0])
  exact lt_of_lt_of_le hterm hle

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G228
