import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus40
import NavierStokesClean.CATEPT.Imported.Batch20260408_Part10

/-!
# CATEPT Imported Batch 20260408 (AllPlus44)

Extended import anchor:
- Top-40 baseline (`Batch20260408_AllPlus40`)
- next-tranche Part 10 (`#41-#44`)
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus44

def top40Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus40.totalModuleCount

def part10Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.Part10.moduleCount

def totalModuleCount : Nat := top40Count + part10Count

theorem totalModuleCount_is_44 : totalModuleCount = 44 := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus44

