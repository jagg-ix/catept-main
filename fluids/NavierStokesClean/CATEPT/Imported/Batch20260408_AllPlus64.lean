import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus60
import NavierStokesClean.CATEPT.Imported.Batch20260408_Part15

/-!
# CATEPT Imported Batch 20260408 (AllPlus64)

Extended import anchor:
- Top-60 baseline (`Batch20260408_AllPlus60`)
- next-tranche Part 15 (`#61-#64`)
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus64

def top60Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus60.totalModuleCount

def part15Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.Part15.moduleCount

def totalModuleCount : Nat := top60Count + part15Count

theorem totalModuleCount_is_64 : totalModuleCount = 64 := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus64

