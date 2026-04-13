import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top20
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Part5_Theoremized

/-!
# Batch 20260408 - Unified Theoremized Top-24 Surface

Extended theoremized import anchor:
- Top20 theoremized baseline
- Part5 theoremized rows `#21-#24`
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top24

def top20Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top20.totalModuleCount

def part5Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Part5.moduleCount

def totalModuleCount : Nat := top20Count + part5Count

theorem totalModuleCount_is_24 : totalModuleCount = 24 := by
  decide

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top24
