import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus56
import NavierStokesClean.CATEPT.Imported.Batch20260408_Part14

/-!
# CATEPT Imported Batch 20260408 (AllPlus60)

Extended import anchor:
- Top-56 baseline (`Batch20260408_AllPlus56`)
- next-tranche Part 14 (`#57-#60`)
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus60

def top56Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus56.totalModuleCount

def part14Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.Part14.moduleCount

def totalModuleCount : Nat := top56Count + part14Count

theorem totalModuleCount_is_60 : totalModuleCount = 60 := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus60

