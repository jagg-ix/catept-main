import CATEPTMain.Bridges.PhyslibRelativityBridge.MinkowskiBridge
import CATEPTMain.Bridges.PhyslibRelativityBridge.ProperTimeBridge
import CATEPTMain.Bridges.PhyslibRelativityBridge.SpinorBridge
import CATEPTMain.Bridges.PhyslibRelativityBridge.SRBridgeCertificate
import CATEPTMain.Bridges.PhyslibRelativityBridge.SpinorBridgeCertificate

/-!
# Axiom Audit: Physlib SR Bridge

This file audits the axioms used by the five modules of the Physlib SR bridge.
Running `lake build CATEPTMain.Bridges.PhyslibRelativityBridge.Audit` prints
the axiom dependencies of each key theorem and the two canonical certificate
instances.

## Expected result

No `sorryAx` must appear in any output line.  Kernel axioms allowed are:
- `propext`
- `Classical.choice`
- `Quot.sound`

`funext` is a theorem (not a kernel axiom) and should **not** appear in
the axiom list.  Any axiom printed by Physlib beyond the three above must be
copied into this comment with a reason and a source theorem before this audit
is considered passing.

Actual output observed (2026-05-08): `propext`, `Classical.choice`,
`Quot.sound` only — all 13 entries.  No `sorryAx`.

## Usage

```
lake build CATEPTMain.Bridges.PhyslibRelativityBridge.Audit 2>&1 | grep -E "axioms|sorry"
```
-/

open CATEPTMain.Bridges.PhyslibRelativityBridge
open CATEPTMain.Geometry.FiniteMinkowski

section MinkowskiBridgeAudit
-- Core bridge theorems
#print axioms cateptEquivPhyslib
#print axioms minkowskiNorm2_eq_neg_physlib
#print axioms causalTimelike_iff_physlib_timeLike
#print axioms insideLightcone_iff_physlib_timeLike
end MinkowskiBridgeAudit

section ProperTimeBridgeAudit
#print axioms catept_sqrt_interval_eq_physlib_properTime
#print axioms catept_properTime_pos_of_timelike
end ProperTimeBridgeAudit

section SpinorBridgeAudit
#print axioms cateptToSelfAdjoint
#print axioms cateptToSelfAdjoint_det
#print axioms cateptToSelfAdjoint_intertwines_sl2c
end SpinorBridgeAudit

section SRCertificateAudit
#print axioms cateptPhyslibSRBridge
#print axioms certificate_properTime_pos
end SRCertificateAudit

section SpinorCertificateAudit
#print axioms cateptPhyslibSRSpinorBridge
end SpinorCertificateAudit
