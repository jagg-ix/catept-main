import NavierStokesClean.CATEPT.Imported.Batch20260418_01_chat_artifact_query_19_scaffold
import NavierStokesClean.CATEPT.Imported.Batch20260418_02_chat_artifact_query_19_obligations

/-!
# CATEPT Imported Batch 20260418

Stable import anchor for the deduped and obligation-scoped ingestion of
`~/Downloads/chat_artifact_query (19).csv`.
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260418

def moduleCount : Nat := 2

def modules : List String := [
  "Batch20260418_01_chat_artifact_query_19_scaffold",
  "Batch20260418_02_chat_artifact_query_19_obligations"
]

theorem moduleCount_matches : modules.length = moduleCount := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260418

