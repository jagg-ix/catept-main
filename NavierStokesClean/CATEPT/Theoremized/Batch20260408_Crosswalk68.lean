import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Crosswalk64
import NavierStokesClean.CATEPT.Imported.Batch20260408_AllPlus68
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_Top68

/-!
# Batch 20260408 - Imported/Theoremized Crosswalk (Top-68)

Lean-native row coverage crosswalk extension from Top-64 to Top-68.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk68

open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk28
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk32
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk36
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk40
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk44
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk48
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk52
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk56
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk60
open NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk64

def rows : List RowCoverage :=
  Crosswalk64.rows ++
  [ CATEPT 65 "Batch20260408_65_0285_complex_einstein_equations_eq3_variant" "Batch20260408_65_ComplexEinsteinEquationEq3Variant0285"
  , CATEPT 66 "Batch20260408_66_0065_discrete_energy_measurement_grid" "Batch20260408_66_DiscreteEnergyMeasurementGrid0065"
  , CATEPT 67 "Batch20260408_67_0066_discrete_energy_measurement_grid_variant" "Batch20260408_67_DiscreteEnergyMeasurementGridVariant0066"
  , CATEPT 68 "Batch20260408_68_0224_l_layer_dimensional_consistency" "Batch20260408_68_LLayerDimensionalConsistency0224"
  ]

theorem rows_length_is_68 : rows.length = 68 := by
  simp [rows, Crosswalk64.rows_length_is_64]

def importedCount : Nat :=
  NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus68.totalModuleCount

def theoremizedCount : Nat :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top68.totalModuleCount

theorem crosswalk_consistent_with_imported_count : rows.length = importedCount := by
  rw [rows_length_is_68]
  simpa [importedCount] using
    NavierStokesClean.CATEPT.Imported.Batch20260408.AllPlus68.totalModuleCount_is_68

theorem crosswalk_consistent_with_theoremized_count : rows.length = theoremizedCount := by
  rw [rows_length_is_68]
  simpa [theoremizedCount] using
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.Top68.totalModuleCount_is_68

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.Crosswalk68
