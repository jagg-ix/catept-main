import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus28
import NavierStokesClean.CATEPT.Imported.Batch20260408_Part7

/-!
# CATEPT Imported Batch 20260408 (AllPlus32)

Extended import anchor:
- Top-28 baseline (`Batch20260408_AllPlus28`)
- next-tranche Part 7 (`#29-#32`)
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus32

def top28Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus28.totalModuleCount

def part7Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.Part7.moduleCount

def totalModuleCount : Nat := top28Count + part7Count

theorem totalModuleCount_is_32 : totalModuleCount = 32 := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus32
