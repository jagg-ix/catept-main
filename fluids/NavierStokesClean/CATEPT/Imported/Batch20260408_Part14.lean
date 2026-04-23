import NavierStokesClean.CATEPT.Imported.Batch20260408_57_0281_entropic_adm_total_proper_time_variant
import NavierStokesClean.CATEPT.Imported.Batch20260408_58_0002_entropy_braid_action
import NavierStokesClean.CATEPT.Imported.Batch20260408_59_0003_entropy_braid_action_latex
import NavierStokesClean.CATEPT.Imported.Batch20260408_60_0004_entropy_braid_action_embedded

/-!
# CATEPT Imported Batch 20260408 Part 14

Compilable ingestion surface for next-tranche batch items `#57` through `#60`,
seeded from `phase6_curated_port_queue_by_domain.csv` catept ranks 57-60.
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.Part14

def moduleCount : Nat := 4

def modules : List String :=
  [ "Batch20260408_57_0281_entropic_adm_total_proper_time_variant"
  , "Batch20260408_58_0002_entropy_braid_action"
  , "Batch20260408_59_0003_entropy_braid_action_latex"
  , "Batch20260408_60_0004_entropy_braid_action_embedded"
  ]

theorem moduleCount_matches : modules.length = moduleCount := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.Part14

