import CATEPTMain.Certification.RelativitySR
import CATEPTMain.Certification.Quantum
import CATEPTMain.Certification.Bell
import CATEPTMain.Certification.PathIntegral
import CATEPTMain.Certification.ModularThermal
import CATEPTMain.Certification.UniversalCertificate
import CATEPTMain.Certification.ClassicalMechanics
import CATEPTMain.Certification.RelativityGR
import CATEPTMain.Certification.RelativityGRHodgeDual
import CATEPTMain.Certification.RelativityGRHodgeTensor
import CATEPTMain.Certification.RelativityGRCovariantDivergence
import CATEPTMain.Certification.RelativityGRStressConservation
import CATEPTMain.Certification.RelativityGRCurvedMaxwell
import CATEPTMain.Certification.RelativityGRVMLMaxwell
import CATEPTMain.Certification.RelativityGRMaxwellPphi2
import CATEPTMain.Certification.RelativityGRCurvedDirect
import CATEPTMain.Certification.RelativityGRUnsafeFixes
import CATEPTMain.Certification.RelativityGRResiduals
import CATEPTMain.Certification.RelativityGREinsteinEquation
import CATEPTMain.Certification.RelativityGRADM
import CATEPTMain.Certification.Status
-- Note: Certification/Audit.lean is NOT imported here to avoid import cycles
-- (it imports UniversalCertificate which already imports the certification sectors).
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
| `RelativityGRHodgeTensor` | Full `ElectromagneticTensor`-layer Hodge-star API with explicit component action, metadata-level involution, fixed-antisymmetric-4D component closure, and fixed-antisymmetric full-tensor involution theorem |
| `RelativityGRCovariantDivergence` | Named real covariant-divergence operator on `StressEnergyTensor` with canonical Minkowski/electrovacuum zero-divergence certificate |
| `RelativityGRCurvedMaxwell` | Curved-Maxwell bridge certificate surface (`canonical_gr_curved_maxwell`) used by the production universal certificate |
| `RelativityGRVMLMaxwell` | VML Maxwell-equilibrium certificate surface (`VMLMaxwellEquilibriumCertificate`, `canonical_vml_maxwell_equilibrium`) |
| `RelativityGRMaxwellPphi2` | Maxwell-CurveSpace/pphi2 bridge certificate surface (`MaxwellPphi2Certificate`, `canonical_maxwell_pphi2_certificate`) |
| `RelativityGRCurvedDirect` | Full direct curved-GR claim surface (`CurvedGRDirectCertificate`) with explicit-payload and fixed-antisymmetric-derived constructors, plus canonical derived assembly theorem |
| `RelativityGRUnsafeFixes` | Canonical closure certificate for GR unsafe-claim surfaces (double-Hodge bivector closure, Einstein/ADM residual identities, conservation model closure) |
| `RelativityGRResiduals` | Typed Einstein/ADM residual objects (`canonical_einstein_residual`, `canonical_adm_residual`) |
| `RelativityGREinsteinEquation` | Typed Einstein equation certificate (`EinsteinEquationCertificate`, `canonical_electrovac_einstein_certificate`) |
| `RelativityGRADM` | Typed ADM constraint certificate (`ADMConstraintCertificate`, `canonical_vacuum_adm_certificate`) |
| `UniversalCertificate` | `CATEPTUniversalConsistencyCertificate`, `universalConsistencyCertificate` (includes `curvedMaxwell`) |
| `Status` | Baseline v1 sentinel record |

## Kernel-axiom status

All declarations in this namespace depend only on
`{propext, Classical.choice, Quot.sound}`.
See `CATEPTMain.Certification.Audit` for the full `#print axioms` audit.
-/
