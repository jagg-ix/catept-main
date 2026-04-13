-- Opt-in CATEPT theoremized surface (extended Top-36).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus36
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top36

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus36

def importedTop36Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus36.totalModuleCount

def theoremizedTop36Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top36.totalModuleCount

theorem importedTop36Count_is_36 : importedTop36Count = 36 := by
  simpa [importedTop36Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus36.totalModuleCount_is_36

theorem theoremizedTop36Count_is_36 : theoremizedTop36Count = 36 := by
  simpa [theoremizedTop36Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top36.totalModuleCount_is_36

theorem theoremizedTop36_matches_importedTop36 : theoremizedTop36Count = importedTop36Count := by
  rw [theoremizedTop36Count_is_36, importedTop36Count_is_36]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus36
