-- Opt-in CATEPT theoremized surface (extended Top-56).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus56
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top56

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus56

def importedTop56Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus56.totalModuleCount

def theoremizedTop56Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top56.totalModuleCount

theorem importedTop56Count_is_56 : importedTop56Count = 56 := by
  simpa [importedTop56Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus56.totalModuleCount_is_56

theorem theoremizedTop56Count_is_56 : theoremizedTop56Count = 56 := by
  simpa [theoremizedTop56Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top56.totalModuleCount_is_56

theorem theoremizedTop56_matches_importedTop56 : theoremizedTop56Count = importedTop56Count := by
  rw [theoremizedTop56Count_is_56, importedTop56Count_is_56]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus56
