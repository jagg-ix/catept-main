import NavierStokesClean.CATEPT.Imported.Batch20260408_61_0074_discrete_measurement_extension
import NavierStokesClean.CATEPT.Imported.Batch20260408_62_0277_kms_condition_spectral_proof
import NavierStokesClean.CATEPT.Imported.Batch20260408_63_0277_kms_condition_spectral_proof_variant
import NavierStokesClean.CATEPT.Imported.Batch20260408_64_0285_complex_einstein_equations_eq3

/-!
# CATEPT Imported Batch 20260408 Part 15

Compilable ingestion surface for next-tranche batch items `#61` through `#64`,
seeded from `phase6_curated_port_queue_by_domain.csv` catept ranks 61-64.
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.Part15

def moduleCount : Nat := 4

def modules : List String :=
  [ "Batch20260408_61_0074_discrete_measurement_extension"
  , "Batch20260408_62_0277_kms_condition_spectral_proof"
  , "Batch20260408_63_0277_kms_condition_spectral_proof_variant"
  , "Batch20260408_64_0285_complex_einstein_equations_eq3"
  ]

theorem moduleCount_matches : modules.length = moduleCount := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.Part15

