import NavierStokesClean.CATEPT.Imported.Batch20260408_All
import NavierStokesClean.CATEPT.Imported.Batch20260408_Part5

/-!
# CATEPT Imported Batch 20260408 (AllPlus)

Extended import anchor:
- Top-20 baseline (`Batch20260408_All`)
- next-tranche Part 5 (`#21-#24`)
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus

def top20Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.All.totalModuleCount

def part5Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.Part5.moduleCount

def totalModuleCount : Nat := top20Count + part5Count

theorem totalModuleCount_is_24 : totalModuleCount = 24 := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus
