import CATEPTMain.Certification.RelativitySR
import CATEPTMain.Certification.Quantum
import CATEPTMain.Certification.Bell
import CATEPTMain.Certification.PathIntegral
import CATEPTMain.Certification.ModularThermal
import CATEPTMain.Certification.UniversalCertificate
import CATEPTMain.Certification.ClassicalMechanics
import CATEPTMain.Certification.RelativityGR
import CATEPTMain.Certification.RelativityGRHodgeDual
import CATEPTMain.Certification.RelativityGRStressConservation
import CATEPTMain.Certification.RelativityGRCurvedMaxwell
import CATEPTMain.Certification.RelativityGRUnsafeFixes
import CATEPTMain.Certification.Status
-- Note: Certification/Audit.lean is NOT imported here to avoid import cycles
-- (it imports UniversalCertificate which already imports all five sectors).
-- Run `lake build CATEPTMain.Certification.Audit` as a standalone target.

/-!
# CATEPTMain.Certification — Production Barrel

Exports the certification sectors and universal consistency certificate:

| Module | Content |
|---|---|
| `RelativitySR` | `SRBridgeCertificate`, `SRSpinorBridgeCertificate`, `canonical_sr`, `canonical_sr_spinor` |
| `Quantum` | `QuantumCATEPTCertificate`, `canonical_quantum` |
| `Bell` | `canonical_bell`, CHSH bound, Tsirelson, quantum violation, singlet entanglement, `canonical_bell_entropic` |
| `PathIntegral` | `WickIdentification`, `canonical_pi_exists`, shared damping |
| `ModularThermal` | `MLWCarrier`, `canonical_thermal_bundle`, `S_I = ℏ·τ_ent` |
| `ClassicalMechanics` | Herglotz/contact classical mechanics certificate (CERT-UP-002/003) |
| `RelativityGR` | Flat GR, tensor-identification (Stage A), and Stage-B structural Hodge/divergence certificate |
| `RelativityGRUnsafeFixes` | Canonical closure certificate for GR unsafe-claim surfaces (double-Hodge bivector closure, Einstein/ADM residual identities, conservation model closure) |
| `UniversalCertificate` | `CATEPTUniversalConsistencyCertificate`, `universalConsistencyCertificate` (9 sectors) |
| `Status` | Baseline v1 sentinel record |

## Kernel-axiom status

All declarations in this namespace depend only on
`{propext, Classical.choice, Quot.sound}`.
See `CATEPTMain.Certification.Audit` for the full `#print axioms` audit (35 directives).
-/
