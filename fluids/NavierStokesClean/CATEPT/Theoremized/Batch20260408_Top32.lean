import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top28
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Part7_Theoremized

/-!
# Batch 20260408 - Unified Theoremized Top-32 Surface

Extended theoremized import anchor:
- Top28 theoremized baseline
- Part7 theoremized rows `#29-#32`
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top32

def top28Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top28.totalModuleCount

def part7Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Part7.moduleCount

def totalModuleCount : Nat := top28Count + part7Count

theorem totalModuleCount_is_32 : totalModuleCount = 32 := by
  decide

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top32
