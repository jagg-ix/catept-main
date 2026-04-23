import NavierStokesClean.CATEPT.Imported.Batch20260419_01_aqft1_provenance
import NavierStokesClean.CATEPT.Imported.Batch20260419_02_aqft1_entropic_lapse_identities
import NavierStokesClean.CATEPT.Imported.Batch20260419_03_aqft1_modular_identities

/-!
# CATEPT Imported Batch 20260419

Stable import anchor for AQFT-1 ingestion (`aqft-1.txt`) with:
- deduped provenance module
- low-risk entropic-lapse theoremization
-/

namespace NavierStokesClean.CATEPT.Imported.Batch20260419

def moduleCount : Nat := 3

def modules : List String := [
  "Batch20260419_01_aqft1_provenance",
  "Batch20260419_02_aqft1_entropic_lapse_identities",
  "Batch20260419_03_aqft1_modular_identities"
]

theorem moduleCount_matches : modules.length = moduleCount := by
  decide

end NavierStokesClean.CATEPT.Imported.Batch20260419
