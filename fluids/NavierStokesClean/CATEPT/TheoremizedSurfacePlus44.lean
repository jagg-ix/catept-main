-- Opt-in CATEPT theoremized surface (extended Top-44).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus44
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top44

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus44

def importedTop44Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus44.totalModuleCount

def theoremizedTop44Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top44.totalModuleCount

theorem importedTop44Count_is_44 : importedTop44Count = 44 := by
  simpa [importedTop44Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus44.totalModuleCount_is_44

theorem theoremizedTop44Count_is_44 : theoremizedTop44Count = 44 := by
  simpa [theoremizedTop44Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top44.totalModuleCount_is_44

theorem theoremizedTop44_matches_importedTop44 : theoremizedTop44Count = importedTop44Count := by
  rw [theoremizedTop44Count_is_44, importedTop44Count_is_44]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus44

