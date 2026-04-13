import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Crosswalk32
import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus36
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top36

/-!
# Batch 20260408 - Imported/Theoremized Crosswalk (Top-36)

Lean-native row coverage crosswalk extension from Top-32 to Top-36.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk36

open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk28
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk32

def rows : List RowCoverage :=
  Crosswalk32.rows ++
  [ CATEPT 33 "Batch20260408_33_0222_quantumpathintegral_euclidintegrabil" "Batch20260408_33_QuantumPathIntegralEuclidIntegrability0222"
  , CATEPT 34 "Batch20260408_34_0142_the_graviton_field_equations_maxwell" "Batch20260408_34_GravitonFieldEquationsMaxwell0142"
  , CATEPT 35 "Batch20260408_35_0102_uqg_covarianteom_ext" "Batch20260408_35_UQGCovariantEOMExt0102"
  , CATEPT 36 "Batch20260408_36_0103_uqg_covariantgsl" "Batch20260408_36_UQGCovariantGSL0103"
  ]

theorem rows_length_is_36 : rows.length = 36 := by
  simp [rows, Crosswalk32.rows_length_is_32]

def importedCount : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus36.totalModuleCount

def theoremizedCount : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top36.totalModuleCount

theorem crosswalk_consistent_with_imported_count : rows.length = importedCount := by
  rw [rows_length_is_36]
  simpa [importedCount] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus36.totalModuleCount_is_36

theorem crosswalk_consistent_with_theoremized_count : rows.length = theoremizedCount := by
  rw [rows_length_is_36]
  simpa [theoremizedCount] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top36.totalModuleCount_is_36

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk36
