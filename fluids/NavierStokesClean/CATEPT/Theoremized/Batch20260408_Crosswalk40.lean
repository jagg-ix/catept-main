import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Crosswalk36
import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus40
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top40

/-!
# Batch 20260408 - Imported/Theoremized Crosswalk (Top-40)

Lean-native row coverage crosswalk extension from Top-36 to Top-40.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk40

open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk28
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk32
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk36

def rows : List RowCoverage :=
  Crosswalk36.rows ++
  [ CATEPT 37 "Batch20260408_37_0019_1_utt_finalapp_namespace" "Batch20260408_37_UTTFinalAppNamespace0019"
  , CATEPT 38 "Batch20260408_38_0176_order2compare" "Batch20260408_38_Order2Compare0176"
  , CATEPT 39 "Batch20260408_39_0004_reply_2_dsfcore_and_trefoil_structur" "Batch20260408_39_DSFCoreAndTrefoilStructure0004"
  , CATEPT 40 "Batch20260408_40_0037_extended_ads_cft_dimensional_scaling" "Batch20260408_40_ExtendedAdSCFTDimensionalScaling0037"
  ]

theorem rows_length_is_40 : rows.length = 40 := by
  simp [rows, Crosswalk36.rows_length_is_36]

def importedCount : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus40.totalModuleCount

def theoremizedCount : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top40.totalModuleCount

theorem crosswalk_consistent_with_imported_count : rows.length = importedCount := by
  rw [rows_length_is_40]
  simpa [importedCount] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus40.totalModuleCount_is_40

theorem crosswalk_consistent_with_theoremized_count : rows.length = theoremizedCount := by
  rw [rows_length_is_40]
  simpa [theoremizedCount] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top40.totalModuleCount_is_40

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk40

