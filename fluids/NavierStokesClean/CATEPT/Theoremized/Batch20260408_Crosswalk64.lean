import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Crosswalk60
import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus64
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top64

/-!
# Batch 20260408 - Imported/Theoremized Crosswalk (Top-64)

Lean-native row coverage crosswalk extension from Top-60 to Top-64.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk64

open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk28
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk32
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk36
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk40
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk44
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk48
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk52
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk56
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk60

def rows : List RowCoverage :=
  Crosswalk60.rows ++
  [ CATEPT 61 "Batch20260408_61_0074_discrete_measurement_extension" "Batch20260408_61_DiscreteMeasurementExtension0074"
  , CATEPT 62 "Batch20260408_62_0277_kms_condition_spectral_proof" "Batch20260408_62_KMSSpectralProof0277"
  , CATEPT 63 "Batch20260408_63_0277_kms_condition_spectral_proof_variant" "Batch20260408_63_KMSSpectralProofVariant0277"
  , CATEPT 64 "Batch20260408_64_0285_complex_einstein_equations_eq3" "Batch20260408_64_ComplexEinsteinEquationEq30285"
  ]

theorem rows_length_is_64 : rows.length = 64 := by
  simp [rows, Crosswalk60.rows_length_is_60]

def importedCount : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus64.totalModuleCount

def theoremizedCount : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top64.totalModuleCount

theorem crosswalk_consistent_with_imported_count : rows.length = importedCount := by
  rw [rows_length_is_64]
  simpa [importedCount] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus64.totalModuleCount_is_64

theorem crosswalk_consistent_with_theoremized_count : rows.length = theoremizedCount := by
  rw [rows_length_is_64]
  simpa [theoremizedCount] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top64.totalModuleCount_is_64

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk64

