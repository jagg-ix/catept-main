-- Opt-in CATEPT theoremized surface (extended Top-28).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus28
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top28

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus28

def importedTop28Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus28.totalModuleCount

def theoremizedTop28Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top28.totalModuleCount

theorem importedTop28Count_is_28 : importedTop28Count = 28 := by
  simpa [importedTop28Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus28.totalModuleCount_is_28

theorem theoremizedTop28Count_is_28 : theoremizedTop28Count = 28 := by
  simpa [theoremizedTop28Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top28.totalModuleCount_is_28

theorem theoremizedTop28_matches_importedTop28 : theoremizedTop28Count = importedTop28Count := by
  rw [theoremizedTop28Count_is_28, importedTop28Count_is_28]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus28
