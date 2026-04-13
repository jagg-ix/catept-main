-- Opt-in CATEPT theoremized surface (extended Top-48).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus48
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top48

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus48

def importedTop48Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus48.totalModuleCount

def theoremizedTop48Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top48.totalModuleCount

theorem importedTop48Count_is_48 : importedTop48Count = 48 := by
  simpa [importedTop48Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus48.totalModuleCount_is_48

theorem theoremizedTop48Count_is_48 : theoremizedTop48Count = 48 := by
  simpa [theoremizedTop48Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top48.totalModuleCount_is_48

theorem theoremizedTop48_matches_importedTop48 : theoremizedTop48Count = importedTop48Count := by
  rw [theoremizedTop48Count_is_48, importedTop48Count_is_48]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus48
