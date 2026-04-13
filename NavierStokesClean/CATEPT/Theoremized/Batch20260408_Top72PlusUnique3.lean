import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Part18Unique_Theoremized

/-!
# Batch 20260408 - Top72 + Unique3 Aggregate

Aggregate surface that extends Top72 with three deduplicated unique rows
(77,78,79), yielding 75 theoremized modules total.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top72PlusUnique3

def top72Count : Nat :=
  72

theorem top72Count_is_72 : top72Count = 72 := by
  rfl

def uniqueCount : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Part18Unique.moduleCount

def totalModuleCount : Nat := top72Count + uniqueCount

theorem totalModuleCount_is_75 : totalModuleCount = 75 := by
  decide

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top72PlusUnique3
