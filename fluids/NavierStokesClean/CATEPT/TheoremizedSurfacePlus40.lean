-- Opt-in CATEPT theoremized surface (extended Top-40).

import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus40
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top40

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.TheoremizedSurfacePlus40

def importedTop40Count : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus40.totalModuleCount

def theoremizedTop40Count : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top40.totalModuleCount

theorem importedTop40Count_is_40 : importedTop40Count = 40 := by
  simpa [importedTop40Count] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus40.totalModuleCount_is_40

theorem theoremizedTop40Count_is_40 : theoremizedTop40Count = 40 := by
  simpa [theoremizedTop40Count] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top40.totalModuleCount_is_40

theorem theoremizedTop40_matches_importedTop40 : theoremizedTop40Count = importedTop40Count := by
  rw [theoremizedTop40Count_is_40, importedTop40Count_is_40]

end NavierStokesClean.CATEPT.TheoremizedSurfacePlus40

