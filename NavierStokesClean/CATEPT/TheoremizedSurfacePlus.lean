-- Opt-in CATEPT theoremized surface (extended Top-24).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top24

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus

def importedTop24Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus.totalModuleCount

def theoremizedTop24Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top24.totalModuleCount

theorem importedTop24Count_is_24 : importedTop24Count = 24 := by
  simpa [importedTop24Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus.totalModuleCount_is_24

theorem theoremizedTop24Count_is_24 : theoremizedTop24Count = 24 := by
  simpa [theoremizedTop24Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top24.totalModuleCount_is_24

theorem theoremizedTop24_matches_importedTop24 : theoremizedTop24Count = importedTop24Count := by
  rw [theoremizedTop24Count_is_24, importedTop24Count_is_24]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus
