import CATEPTMain.Integration.QuantumTemporalOrderEnergyCAT
import CATEPTMain.Integration.NonHermitianQuantumCAT
import CATEPTMain.CATEPT.CATEPT.NHQMCATEPTBridge
import CATEPTMain.Integration.GRQMPathIntegralUnifyBridge
import CATEPTMain.CATEPT.CATEPT.BohmianBornRuleCoreAbstractions
import CATEPTMain.Integration.NSSpaceQIFConsistencyBridge

import CATEPTMain.CATEPT.CATEPT.DiracMatrixAlgebra
import CATEPTMain.CATEPT.CATEPT.PauliNoGoEntropicTimeBridge
import CATEPTMain.CATEPT.CATEPT.QIFCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.QTMCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.SpinorPathIntegralBridge
import CATEPTMain.Domains.Adapters.BohmianEM
import CATEPTMain.Domains.Adapters.QMLive
import CATEPTMain.Integration.ModularFlowDiscreteEventBridge
import CATEPTMain.Integration.PhyslibQuantumMechanicsBridge
import CATEPTMain.Integration.QFTCurvedTemporalSpine
import CATEPTMain.Integration.SpectralGapKMSBetaConsistencyBridge
import CATEPTMain.Integration.StringEffectiveQFTSpineBridge
import CATEPTMain.QuantumOps.Imported.Batch20260408_11_0004_6_framework_testing
import CATEPTMain.QuantumOps.Imported.Batch20260408_12_0026_reply_55_integration_of_next_10_of_d
import CATEPTMain.QuantumOps.Imported.Batch20260408_13_0055_expanded_reply_79_integration_of_nex
import CATEPTMain.QuantumOps.Imported.Batch20260408_14_0024_reply_53_integration_of_next_10_of_d
import CATEPTMain.QuantumOps.IsabelleMarresDirac.Basics
import CATEPTMain.QuantumOps.IsabelleMarresDirac.Deutsch
import CATEPTMain.QuantumOps.IsabelleMarresDirac.Quantum
import CATEPTMain.QuantumOps.PartialTrace.FinDimPartialTrace
import CATEPTMain.QuantumOps.QuantumFourierTransform.QFTDefs
import CATEPTMain.QuantumOps.QuantumFourierTransform.QFTSubset01
import CATEPTMain.QuantumOps.QuantumFourierTransform.QFTSubset02
import CATEPTMain.QuantumOps.Theoremized.Batch20260408_11_FrameworkTesting
import CATEPTMain.QuantumOps.Theoremized.Batch20260408_12_GameTheoryIntegration
import CATEPTMain.QuantumOps.Theoremized.Batch20260408_14_DSFResonanceIntegration
import CATEPTMain.QuantumOps.Theoremized.Batch20260408_Theoremized
/-!
# QMOrphanBundle — Option B spine-recovery bundle for QM pillar extensions

Wires substantive previously-orphan QM / quantum-extensions modules onto
the root-reachable spine.

## Modules wired (6)

* `QuantumTemporalOrderEnergyCAT` — temporal-order / energy CAT (12 thm, 4 struct).
* `NonHermitianQuantumCAT` — non-Hermitian quantum CAT (8 thm, 4 struct).
* `NHQMCATEPTBridge` — non-Hermitian QM ↔ CAT/EPT bridge (12 thm, 2 struct).
* `GRQMPathIntegralUnifyBridge` — GR ↔ QM path-integral unification (10 thm, 2 struct).
* `BohmianBornRuleCoreAbstractions` — Bohmian / Born-rule core (15 thm, 4 struct).
* `NSSpaceQIFConsistencyBridge` — NS-space QIF consistency (10 thm, 3 struct).

Tracked by worklog task `catept_spine_orphan_triage_audit_20260503`.
-/
namespace CATEPTMain.Integration.QMOrphanBundle
end CATEPTMain.Integration.QMOrphanBundle
