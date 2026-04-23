import NavierStokesClean.CATEPT.Theoremized.Batch20260408_77_ComplexActionCoreStructures0410
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_78_ComplexActionCoreStructuresVariant0427
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_79_ComplexActionCoreStructuresFixed0467

/-!
# Batch 20260408 - CATEPT Part18 Unique Theoremized Surface

Deduplicated continuation tranche containing admitted unique rows `#77,#78,#79`.
Duplicate rows `#73,#74,#75,#76,#80` are intentionally skipped.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.Part18Unique

def moduleCount : Nat := 3

def coveredRows : List Nat := [77, 78, 79]

def skippedDuplicateRows : List Nat := [73, 74, 75, 76, 80]

theorem moduleCount_matches : coveredRows.length = moduleCount := by
  decide

theorem skippedDuplicateRows_count : skippedDuplicateRows.length = 5 := by
  decide

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.Part18Unique
