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
import CATEPTMain.Certification.RelativityGRWitnessFreeFaraday
import CATEPTMain.Certification.RelativityGRWitnessFreeFaradayFamily
import CATEPTMain.Certification.RelativityGRWitnessFreeCurvedDirect
import CATEPTMain.Certification.RelativityGRWitnessFreeEinstein
import CATEPTMain.Certification.RelativityGRWitnessFreeADM
import CATEPTMain.Certification.RelativityGRVMLFamily
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
| `RelativityGRWitnessFreeFaraday` | Witness-free canonical Faraday derivation from Gravitas data (`canonical_faraday_minkowski_fixed_witness`) and witness-free direct curved-GR canonical certificate (`canonical_curved_gr_direct_certificate_witness_free`) |
| `RelativityGRWitnessFreeFaradayFamily` | Family-level fixed-antisymmetric theorem for arbitrary `ElectromagneticTensor.ofMetric g A μ₀` (`faraday_ofMetric_is_fixedAntisymmetric4D`, `FaradayOfMetricFixedWitness`), with canonical Minkowski instance (`canonical_faraday_ofMetric_witness_minkowski`) discharged via `native_decide` |
| `RelativityGRWitnessFreeCurvedDirect` | Umbrella admissibility predicate `IsCertifiedCurvedGRData` bundling the five direct curved-GR obligations, with `curved_gr_direct_certificate_of_certified_data`, `certified_curved_gr_data_implies_full_direct_claim`, and the canonical Minkowski instance `canonical_certified_curved_gr_data` |
| `RelativityGRWitnessFreeEinstein` | Witness-free Einstein-electrovacuum family (WF-GR-005/6): `IsEinsteinElectrovacuumSolution`, `einstein_certificate_for_solution`, `einstein_electrovacuum_solution_full_claim`, with canonical Minkowski instance `canonical_minkowski_is_einstein_electrovacuum_solution` discharged via `native_decide` |
| `RelativityGRWitnessFreeADM` | Witness-free ADM-constraint family (WF-GR-007/8): `IsCertifiedADMData`, `adm_certificate_for_data`, `adm_data_full_claim`, with canonical Minkowski vacuum instance `canonical_minkowski_is_certified_adm_data` reusing `gravitasCanonicalVacuumADM_*_residual_exact` |
| `RelativityGRVMLFamily` | Witness-free VML-Landau flat equilibrium family: `IsVMLElectrovacuumEquilibrium` bundles the rigidity outputs of `proved_vml_steady_state_rigidity` (= `VML.CoulombConcreteTheorem42`); `vml_equilibrium_supports_flat_electrovacuum_family` lifts equilibria into the existing flat Maxwell→stress-conservation route |
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
