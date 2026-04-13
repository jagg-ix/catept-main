import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus52
import NavierStokesClean.CATEPT.Imported.Batch20260408_Part13

/-!
# CATEPT Imported Batch 20260408 (AllPlus56)

Extended import anchor:
- Top-52 baseline (`Batch20260408_AllPlus52`)
- next-tranche Part 13 (`#53-#56`)
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus56

def top52Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus52.totalModuleCount

def part13Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.Part13.moduleCount

def totalModuleCount : Nat := top52Count + part13Count

theorem totalModuleCount_is_56 : totalModuleCount = 56 := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus56
