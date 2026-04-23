import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus32
import NavierStokesClean.CATEPT.Imported.Batch20260408_Part8

/-!
# CATEPT Imported Batch 20260408 (AllPlus36)

Extended import anchor:
- Top-32 baseline (`Batch20260408_AllPlus32`)
- next-tranche Part 8 (`#33-#36`)
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus36

def top32Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus32.totalModuleCount

def part8Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.Part8.moduleCount

def totalModuleCount : Nat := top32Count + part8Count

theorem totalModuleCount_is_36 : totalModuleCount = 36 := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus36
