-- Opt-in CATEPT theoremized surface.
--
-- This file is intentionally NOT imported by `NavierStokesClean.lean` so the default
-- build surface remains stable and minimal. Helpers can opt in explicitly when they
-- need extracted/imported + theoremized Top-20 overlays.

import NavierStokesClean.CATEPT.Imported.Batch20260408_All
import NavierStokesClean.CATEPT.Imported.Batch20260418
import NavierStokesClean.CATEPT.Imported.Batch20260419
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

/-- Run-19 imported scaffold module count (separate from top-20 queue). -/
def importedRun19Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260418.moduleCount

/-- Run-19 queue is currently a 2-module provenance+obligation scaffold. -/
theorem importedRun19Count_is_2 : importedRun19Count = 2 := by
  simpa [importedRun19Count]
    using NavierStokesClean.CATEPT.Imported.Batch20260418.moduleCount_matches

/-- AQFT-1 imported scaffold module count (separate from top-20 queue). -/
def importedAQFT1Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260419.moduleCount

/-- AQFT-1 queue currently exports 2 modules (scaffold + identities). -/
theorem importedAQFT1Count_is_2 : importedAQFT1Count = 2 := by
  simpa [importedAQFT1Count]
    using NavierStokesClean.CATEPT.Imported.Batch20260419.moduleCount_matches

end NavierStokesClean.CATEPT.TheoremizedSurface
