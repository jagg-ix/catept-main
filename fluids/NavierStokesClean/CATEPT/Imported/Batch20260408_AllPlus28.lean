import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus
import NavierStokesClean.CATEPT.Imported.Batch20260408_Part6

/-!
# CATEPT Imported Batch 20260408 (AllPlus28)

Extended import anchor:
- Top-24 baseline (`Batch20260408_AllPlus`)
- next-tranche Part 6 (`#25-#28`)
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus28

def top24Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus.totalModuleCount

def part6Count : Nat := NavierStokesClean.CATEPT.Imported.Batch20260408.Part6.moduleCount

def totalModuleCount : Nat := top24Count + part6Count

theorem totalModuleCount_is_28 : totalModuleCount = 28 := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus28
