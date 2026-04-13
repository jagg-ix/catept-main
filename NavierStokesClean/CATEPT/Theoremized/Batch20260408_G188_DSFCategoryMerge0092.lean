import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 188

DSF category-merge scaffold adapted from
`0092_implementation_for_dsfcategory_merge.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G188

noncomputable section

def categoryMerge (A B : Finset Nat) : Finset Nat := A ∪ B

def categoryIntersect (A B : Finset Nat) : Finset Nat := A ∩ B

theorem categoryMerge_comm (A B : Finset Nat) :
    categoryMerge A B = categoryMerge B A := by
  unfold categoryMerge
  exact Finset.union_comm A B

theorem categoryMerge_assoc (A B C : Finset Nat) :
    categoryMerge (categoryMerge A B) C = categoryMerge A (categoryMerge B C) := by
  unfold categoryMerge
  exact Finset.union_assoc A B C

theorem left_subset_categoryMerge (A B : Finset Nat) : A ⊆ categoryMerge A B := by
  intro x hx
  unfold categoryMerge
  exact Finset.mem_union.mpr (Or.inl hx)

theorem categoryIntersect_subset_left (A B : Finset Nat) : categoryIntersect A B ⊆ A := by
  intro x hx
  unfold categoryIntersect at hx
  exact (Finset.mem_inter.mp hx).1

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G188
