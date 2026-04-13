import NavierStokesClean.CATEPT.Imported.Batch20260408_01_0002_key_theorems
import NavierStokesClean.CATEPT.Imported.Batch20260408_02_0233_response
import NavierStokesClean.CATEPT.Imported.Batch20260408_03_0078_prompt
import NavierStokesClean.CATEPT.Imported.Batch20260408_04_0260_quantumcomplexaction_maxent
import NavierStokesClean.CATEPT.Imported.Batch20260408_05_0105_uqg_complexvariational_er_epr_fd_lea

/-!
# CATEPT Imported Batch 20260408

Compilable ingestion surface for the first import batch selected from
`chat_artifact_extractions`. This module provides a stable import anchor while the
underlying extracted equations are being theoremized into core CATEPT modules.
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260408

def moduleCount : Nat := 5

def modules : List String := [
  "Batch20260408_01_0002_key_theorems",
  "Batch20260408_02_0233_response",
  "Batch20260408_03_0078_prompt",
  "Batch20260408_04_0260_quantumcomplexaction_maxent",
  "Batch20260408_05_0105_uqg_complexvariational_er_epr_fd_lea"
]

theorem moduleCount_matches : modules.length = moduleCount := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260408

