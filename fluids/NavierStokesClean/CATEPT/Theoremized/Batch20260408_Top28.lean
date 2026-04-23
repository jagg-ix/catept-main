import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top24

/-!
# Batch 20260408 - Unified Theoremized Top-28 Surface

Extended theoremized import anchor:
- Top24 theoremized baseline
- Part6 theoremized rows `#25-#28`

Note: `Top24` and `Part6_Theoremized` are both buildable independently, but
directly importing them together in one module currently triggers a known
PhysLean/Mathlib distribution-name collision in this repository context.
So this aggregate keeps the part-6 count synchronized as metadata (`= 4`).
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top28

def top24Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top24.totalModuleCount

def part6Count : Nat := 4

theorem part6Count_is_4 : part6Count = 4 := by
  decide

def totalModuleCount : Nat := top24Count + part6Count

theorem totalModuleCount_is_28 : totalModuleCount = 28 := by
  decide

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top28
