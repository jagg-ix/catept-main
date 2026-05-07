import CATEPTMain.CATEPT.CATEPT.QEDCoreAbstractions
import CATEPTMain.Integration.QEDRepresentationStability
import CATEPTMain.Integration.MaxwellCurveSpaceDampingPhase3
import CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags

import CATEPTMain.CATEPT.CATEPT.QCDCoreAbstractions
import CATEPTMain.Domains.UnifiedConstraintsGaugeGeometry
/-!
# EMOrphanBundle — Option B spine-recovery bundle for EM pillar

Wires substantive previously-orphan EM modules onto the root-reachable
spine.  Each imported module ships proven content; build buildability
verified individually before wiring.

## Modules wired (4)

* `QEDCoreAbstractions` — QED Mandelstam / Compton / Ward (4 thm, 1 struct).
* `QEDRepresentationStability` — QED rep-theoretic stability (6 thm, 2 struct).
* `MaxwellCurveSpaceDampingPhase3` — Maxwell on curved space, damping (6 thm).
* `MaxwellCurveSpaceAssumptionTags` — assumption-tag layer (3 thm).

Tracked by worklog task `catept_spine_orphan_triage_em_20260503`.
-/
namespace CATEPTMain.Integration.EMOrphanBundle
end CATEPTMain.Integration.EMOrphanBundle
