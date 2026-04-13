-- Opt-in CATEPT theoremized surface.
--
-- This file is intentionally NOT imported by `NavierStokesClean.lean` so the default
-- build surface remains stable and minimal. Helpers can opt in explicitly when they
-- need extracted/imported + theoremized Top-20 overlays.

import NavierStokesClean.CATEPT.Imported.Batch20260408_All
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top20

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurface

/-- Imported top-20 scaffold count. -/
def importedTop20Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.All.totalModuleCount

/-- Theoremized top-20 count. -/
def theoremizedTop20Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top20.totalModuleCount

/-- Imported scaffold surface is exactly 20 modules. -/
theorem importedTop20Count_is_20 : importedTop20Count = 20 := by
  simpa [importedTop20Count]
    using NavierStokesClean.CATEPT.Imported.Batch20260408.All.totalModuleCount_is_20

/-- Theoremized surface is exactly 20 modules. -/
theorem theoremizedTop20Count_is_20 : theoremizedTop20Count = 20 := by
  simpa [theoremizedTop20Count]
    using NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top20.totalModuleCount_is_20

/-- Count-level closure: theoremized top-20 aligns with imported top-20 scaffold count. -/
theorem theoremized_matches_imported_count : theoremizedTop20Count = importedTop20Count := by
  rw [theoremizedTop20Count_is_20, importedTop20Count_is_20]

end NavierStokesClean.CATEPT.TheoremizedSurface
