import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus36
import NavierStokesClean.CATEPT.Imported.Batch20260408_Part9

/-!
# CATEPT Imported Batch 20260408 (AllPlus40)

Extended import anchor:
- Top-36 baseline (`Batch20260408_AllPlus36`)
- next-tranche Part 9 (`#37-#40`)
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus40

def top36Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus36.totalModuleCount

def part9Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.Part9.moduleCount

def totalModuleCount : Nat := top36Count + part9Count

theorem totalModuleCount_is_40 : totalModuleCount = 40 := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus40

