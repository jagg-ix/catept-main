-- Opt-in CATEPT theoremized surface (extended Top-32).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus32
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top32

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus32

def importedTop32Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus32.totalModuleCount

def theoremizedTop32Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top32.totalModuleCount

theorem importedTop32Count_is_32 : importedTop32Count = 32 := by
  simpa [importedTop32Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus32.totalModuleCount_is_32

theorem theoremizedTop32Count_is_32 : theoremizedTop32Count = 32 := by
  simpa [theoremizedTop32Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top32.totalModuleCount_is_32

theorem theoremizedTop32_matches_importedTop32 : theoremizedTop32Count = importedTop32Count := by
  rw [theoremizedTop32Count_is_32, importedTop32Count_is_32]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus32
