-- Opt-in CATEPT theoremized surface (extended Top-64).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus64
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top64

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus64

def importedTop64Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus64.totalModuleCount

def theoremizedTop64Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top64.totalModuleCount

theorem importedTop64Count_is_64 : importedTop64Count = 64 := by
  simpa [importedTop64Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus64.totalModuleCount_is_64

theorem theoremizedTop64Count_is_64 : theoremizedTop64Count = 64 := by
  simpa [theoremizedTop64Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top64.totalModuleCount_is_64

theorem theoremizedTop64_matches_importedTop64 : theoremizedTop64Count = importedTop64Count := by
  rw [theoremizedTop64Count_is_64, importedTop64Count_is_64]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus64

