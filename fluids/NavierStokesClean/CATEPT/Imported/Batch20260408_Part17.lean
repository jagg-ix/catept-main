import NavierStokesClean.CATEPT.Imported.Batch20260408_69_0241_l_layer_dimensional_consistency_variant
import NavierStokesClean.CATEPT.Imported.Batch20260408_70_0092_classical_papastavridis
import NavierStokesClean.CATEPT.Imported.Batch20260408_71_0067_discrete_energy_time_evolution
import NavierStokesClean.CATEPT.Imported.Batch20260408_72_0304_phase_generator_installation

/-!
# CATEPT Imported Batch 20260408 Part 17

Compilable ingestion surface for next-tranche batch items `#69` through `#72`,
seeded from `phase6_curated_port_queue_by_domain.csv` catept ranks 69-72.
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.Part17

def moduleCount : Nat := 4

def modules : List String :=
  [ "Batch20260408_69_0241_l_layer_dimensional_consistency_variant"
  , "Batch20260408_70_0092_classical_papastavridis"
  , "Batch20260408_71_0067_discrete_energy_time_evolution"
  , "Batch20260408_72_0304_phase_generator_installation"
  ]

theorem moduleCount_matches : modules.length = moduleCount := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.Part17
