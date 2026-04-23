-- Opt-in CATEPT theoremized surface (extended Top-72).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus72
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top72

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus72

def importedTop72Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus72.totalModuleCount

def theoremizedTop72Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top72.totalModuleCount

theorem importedTop72Count_is_72 : importedTop72Count = 72 := by
  simpa [importedTop72Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus72.totalModuleCount_is_72

theorem theoremizedTop72Count_is_72 : theoremizedTop72Count = 72 := by
  simpa [theoremizedTop72Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top72.totalModuleCount_is_72

theorem theoremizedTop72_matches_importedTop72 : theoremizedTop72Count = importedTop72Count := by
  rw [theoremizedTop72Count_is_72, importedTop72Count_is_72]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus72
