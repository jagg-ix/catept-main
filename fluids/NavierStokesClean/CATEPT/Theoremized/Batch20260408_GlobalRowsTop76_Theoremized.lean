import Mathlib
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_GlobalRowsTop73_Theoremized
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_G152_DSFModalLogic0121
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_G235_ComplexPathIntegral0039
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_G225_DSFNumerics0374

/-!
# Batch 20260408 Theoremization - Global Top-76 Aggregate

Extends top-73 with strict non-duplicate rows `(152, 235, 225)`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.GlobalTop76

def newlyAddedRows : Finset Nat := {152, 235, 225}

theorem newlyAddedRows_card : newlyAddedRows.card = 3 := by
  decide

def globalTop76Count : Nat := 76

theorem globalTop76Count_eq : globalTop76Count = 73 + newlyAddedRows.card := by
  norm_num [globalTop76Count, newlyAddedRows_card]

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.GlobalTop76
