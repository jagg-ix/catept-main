import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Crosswalk28
import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus32
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top32

/-!
# Batch 20260408 - Imported/Theoremized Crosswalk (Top-32)

Lean-native row coverage crosswalk extension from Top-28 to Top-32.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk32

open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk28

def rows : List RowCoverage :=
  Crosswalk28.rows ++
  [ CATEPT 29 "Batch20260408_29_0061_prompt" "Batch20260408_29_Prompt0061"
  , CATEPT 30 "Batch20260408_30_0126_complete_fixed_version" "Batch20260408_30_CompleteFixedVersion0126"
  , CATEPT 31 "Batch20260408_31_0011_reply_4_physical_measurement_process" "Batch20260408_31_PhysicalMeasurementProcess0011"
  , CATEPT 32 "Batch20260408_32_0012_reply_5_hopfalgebraframework_impleme" "Batch20260408_32_HopfAlgebraFrameworkImplement0012"
  ]

theorem rows_length_is_32 : rows.length = 32 := by
  simp [rows, Crosswalk28.rows_length_is_28]

def importedCount : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus32.totalModuleCount

def theoremizedCount : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top32.totalModuleCount

theorem crosswalk_consistent_with_imported_count : rows.length = importedCount := by
  rw [rows_length_is_32]
  simpa [importedCount] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus32.totalModuleCount_is_32

theorem crosswalk_consistent_with_theoremized_count : rows.length = theoremizedCount := by
  rw [rows_length_is_32]
  simpa [theoremizedCount] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top32.totalModuleCount_is_32

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk32
