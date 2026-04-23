import NavierStokesClean.CATEPT.Imported.Batch20260408_25_0100_uqg_equationsofmotion
import NavierStokesClean.CATEPT.Imported.Batch20260408_26_0112_uqg_covariantactionprinciple
import NavierStokesClean.CATEPT.Imported.Batch20260408_27_0062_uqg_covariantactionprinciple
import NavierStokesClean.CATEPT.Imported.Batch20260408_28_0010_reply_3_quantummeasurement_implement

/-!
# CATEPT Imported Batch 20260408 Part 6

Compilable ingestion surface for next-tranche batch items `#25` through `#28`,
seeded from `phase6_curated_port_queue_by_domain.csv` catept ranks 11-14.
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408.Part6

def moduleCount : Nat := 4

def modules : List String :=
  [ "Batch20260408_25_0100_uqg_equationsofmotion"
  , "Batch20260408_26_0112_uqg_covariantactionprinciple"
  , "Batch20260408_27_0062_uqg_covariantactionprinciple"
  , "Batch20260408_28_0010_reply_3_quantummeasurement_implement"
  ]

theorem moduleCount_matches : modules.length = moduleCount := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408.Part6
