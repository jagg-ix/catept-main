import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus68
import NavierStokesClean.CATEPT.Imported.Batch20260408_Part17

/-!
# CATEPT Imported Batch 20260408 (AllPlus72)

Extended import anchor:
- Top-68 baseline (`Batch20260408_AllPlus68`)
- next-tranche Part 17 (`#69-#72`)
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus72

def top68Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus68.totalModuleCount

def part17Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.Part17.moduleCount

def totalModuleCount : Nat := top68Count + part17Count

theorem totalModuleCount_is_72 : totalModuleCount = 72 := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus72
