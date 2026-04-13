-- Opt-in CATEPT theoremized surface (extended Top-60).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus60
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top60

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus60

def importedTop60Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus60.totalModuleCount

def theoremizedTop60Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top60.totalModuleCount

theorem importedTop60Count_is_60 : importedTop60Count = 60 := by
  simpa [importedTop60Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus60.totalModuleCount_is_60

theorem theoremizedTop60Count_is_60 : theoremizedTop60Count = 60 := by
  simpa [theoremizedTop60Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top60.totalModuleCount_is_60

theorem theoremizedTop60_matches_importedTop60 : theoremizedTop60Count = importedTop60Count := by
  rw [theoremizedTop60Count_is_60, importedTop60Count_is_60]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus60

