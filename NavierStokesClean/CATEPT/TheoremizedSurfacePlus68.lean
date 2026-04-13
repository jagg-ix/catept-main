-- Opt-in CATEPT theoremized surface (extended Top-68).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus68
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top68

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus68

def importedTop68Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus68.totalModuleCount

def theoremizedTop68Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top68.totalModuleCount

theorem importedTop68Count_is_68 : importedTop68Count = 68 := by
  simpa [importedTop68Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus68.totalModuleCount_is_68

theorem theoremizedTop68Count_is_68 : theoremizedTop68Count = 68 := by
  simpa [theoremizedTop68Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top68.totalModuleCount_is_68

theorem theoremizedTop68_matches_importedTop68 : theoremizedTop68Count = importedTop68Count := by
  rw [theoremizedTop68Count_is_68, importedTop68Count_is_68]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus68
