-- Opt-in CATEPT theoremized surface (extended Top-52).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus52
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top52

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus52

def importedTop52Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus52.totalModuleCount

def theoremizedTop52Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top52.totalModuleCount

theorem importedTop52Count_is_52 : importedTop52Count = 52 := by
  simpa [importedTop52Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus52.totalModuleCount_is_52

theorem theoremizedTop52Count_is_52 : theoremizedTop52Count = 52 := by
  simpa [theoremizedTop52Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top52.totalModuleCount_is_52

theorem theoremizedTop52_matches_importedTop52 : theoremizedTop52Count = importedTop52Count := by
  rw [theoremizedTop52Count_is_52, importedTop52Count_is_52]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus52
