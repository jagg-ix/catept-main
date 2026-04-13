import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Crosswalk56
import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus60
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top60

/-!
# Batch 20260408 - Imported/Theoremized Crosswalk (Top-60)

Lean-native row coverage crosswalk extension from Top-56 to Top-60.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk60

open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk28
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk32
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk36
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk40
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk44
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk48
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk52
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk56

def rows : List RowCoverage :=
  Crosswalk56.rows ++
  [ CATEPT 57 "Batch20260408_57_0281_entropic_adm_total_proper_time_variant" "Batch20260408_57_EntropicADMTotalProperTimeVariant0281"
  , CATEPT 58 "Batch20260408_58_0002_entropy_braid_action" "Batch20260408_58_EntropyBraidAction0002"
  , CATEPT 59 "Batch20260408_59_0003_entropy_braid_action_latex" "Batch20260408_59_EntropyBraidActionLatex0003"
  , CATEPT 60 "Batch20260408_60_0004_entropy_braid_action_embedded" "Batch20260408_60_EntropyBraidActionEmbedded0004"
  ]

theorem rows_length_is_60 : rows.length = 60 := by
  simp [rows, Crosswalk56.rows_length_is_56]

def importedCount : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus60.totalModuleCount

def theoremizedCount : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top60.totalModuleCount

theorem crosswalk_consistent_with_imported_count : rows.length = importedCount := by
  rw [rows_length_is_60]
  simpa [importedCount] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus60.totalModuleCount_is_60

theorem crosswalk_consistent_with_theoremized_count : rows.length = theoremizedCount := by
  rw [rows_length_is_60]
  simpa [theoremizedCount] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top60.totalModuleCount_is_60

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk60

