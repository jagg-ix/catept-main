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
import CATEPTMain.Certification.UniversalCertificate

/-!
# Certification — Kernel-Axiom Audit

Standalone reproducible audit for every load-bearing declaration in the
`CATEPTMain/Certification/` namespace.

## Expected output

Every `#print axioms` directive below **must** report exactly:
```
'<decl>' depends on axioms: [propext, Classical.choice, Quot.sound]
```
No `sorryAx` is permitted.

## How to run

```
lake build CATEPTMain.Certification.Audit
```

or open this file in VS Code with the Lean 4 extension active.
-/

-- ── SR sector ─────────────────────────────────────────────────────────────────
#print axioms CATEPTMain.Certification.RelativitySR.canonical_sr
#print axioms CATEPTMain.Certification.RelativitySR.canonical_sr_spinor
#print axioms CATEPTMain.Certification.RelativitySR.sr_properTime_pos

-- ── QM sector ─────────────────────────────────────────────────────────────────
#print axioms CATEPTMain.Certification.Quantum.canonical_quantum
#print axioms CATEPTMain.Certification.Quantum.qm_gr_share_entropic_clock

-- ── Bell / QI sector ──────────────────────────────────────────────────────────
#print axioms CATEPTMain.Certification.Bell.canonical_bell
#print axioms CATEPTMain.Certification.Bell.bell_classical_bound
#print axioms CATEPTMain.Certification.Bell.bell_tsirelson
#print axioms CATEPTMain.Certification.Bell.bell_quantum_violation
#print axioms CATEPTMain.Certification.Bell.singlet_is_entangled
#print axioms CATEPTMain.Certification.Bell.canonical_bell_entropic

-- ── Path-integral sector ──────────────────────────────────────────────────────
#print axioms CATEPTMain.Certification.PathIntegral.canonical_pi_exists
#print axioms CATEPTMain.Certification.PathIntegral.gr_qm_shared_damping
#print axioms CATEPTMain.Certification.PathIntegral.wick_is_consistent

-- ── Modular-thermal sector ────────────────────────────────────────────────────
#print axioms CATEPTMain.Certification.ModularThermal.canonical_thermal_bundle
#print axioms CATEPTMain.Certification.ModularThermal.thermal_imaginary_action_eq
#print axioms CATEPTMain.Certification.ModularThermal.thermal_tauEnt_neg_log_Z
#print axioms CATEPTMain.Certification.ModularThermal.canonical_qm_matsubara_eq

-- ── Classical mechanics — Herglotz/contact damped oscillator certificate ──────
#print axioms CATEPTMain.Certification.ClassicalMechanics.canonical_classical
#print axioms CATEPTMain.Certification.ClassicalMechanics.classical_slot_consistent
#print axioms CATEPTMain.Certification.ClassicalMechanics.classical_clock_eq_tauEnt
#print axioms CATEPTMain.Certification.ClassicalMechanics.classical_dissipation_nonpos
#print axioms CATEPTMain.Certification.ClassicalMechanics.classical_decayRate_eq
#print axioms CATEPTMain.Certification.ClassicalMechanics.classical_zero_entropy_reduces

-- ── GR flat (Minkowski) certificate ──────────────────────────────────────────
#print axioms CATEPTMain.Certification.RelativityGR.canonical_gr_flat
#print axioms CATEPTMain.Certification.RelativityGR.gr_flat_slot_consistent
#print axioms CATEPTMain.Certification.RelativityGR.gr_flat_tolman_trivial

-- ── GR tensor certificate (CERT-UP-005 Stage A) ───────────────────────────────
#print axioms CATEPTMain.Certification.RelativityGR.canonical_gr_tensor
#print axioms CATEPTMain.Certification.RelativityGR.gr_tensor_faraday_defined
#print axioms CATEPTMain.Certification.RelativityGR.gr_tensor_stress_energy_defined

-- ── Universal certificate (CERT-UP-007 — 11-sector upgrade) ──────────────────
#print axioms CATEPTMain.Certification.universalConsistencyCertificate
#print axioms CATEPTMain.Certification.universal_curved_maxwell_bridge_certified
#print axioms CATEPTMain.Certification.universal_vml_maxwell_equilibrium_certified
#print axioms CATEPTMain.Certification.universal_sr_properTime_pos
#print axioms CATEPTMain.Certification.universal_qm_gr_shared_clock
#print axioms CATEPTMain.Certification.canonicalCommonClock
#print axioms CATEPTMain.Certification.CertificationScopeBoundary
#print axioms CATEPTMain.Certification.certificationScopeBoundary
#print axioms CATEPTMain.Certification.certificationScopeBoundary_claim
-- ── GR Einstein certificate (CERT-UP-005 Stage B — structural, kernel-only) ───
#print axioms CATEPTMain.Certification.RelativityGR.canonical_gr_einstein

-- ── GR Hodge dual involution (kernel-transparent bivector layer) ─────────────
#print axioms CATEPTMain.Certification.RelativityGR.gravitasFaraday_hodgeStar_involutive

-- ── GR full-tensor Hodge-star API (ElectromagneticTensor layer) ─────────────
#print axioms CATEPTMain.Certification.RelativityGR.hodgeStarEM_involutive
#print axioms CATEPTMain.Certification.RelativityGR.hodgeStarEM_involutive_for_minkowski_family
#print axioms CATEPTMain.Certification.RelativityGR.hodgeStarEM_double_components_fixedAntisymmetric4D
#print axioms CATEPTMain.Certification.RelativityGR.hodgeStarEM_involutive_of_fixedAntisymmetric4D
#print axioms CATEPTMain.Certification.RelativityGR.hodgeStarEM_fixedAntisymmetric4D_closure_profile
#print axioms CATEPTMain.Certification.RelativityGR.gravitasFaradayMinkowski_fixedAntisymmetric4D
#print axioms CATEPTMain.Certification.RelativityGR.gravitasFaraday_hodgeStarEM_involutive

-- ── GR real covariant divergence (StressEnergyTensor layer) ─────────────────
#print axioms CATEPTMain.Certification.RelativityGR.gravitasCanonicalStress_covariantDivergence_zero

-- ── GR stress conservation (kernel-transparent constant model) ───────────────
#print axioms CATEPTMain.Certification.RelativityGR.canonical_radiation_stress_conserved
#print axioms CATEPTMain.Certification.RelativityGR.canonical_radiation_stress_nonzero_and_conserved
#print axioms CATEPTMain.Certification.RelativityGR.flat_constant_stress_conserved_for_all_constant_T
#print axioms CATEPTMain.Certification.RelativityGR.maxwell_implies_stress_conservation_of_contract
#print axioms CATEPTMain.Certification.RelativityGR.maxwell_implies_stress_conservation_derived
#print axioms CATEPTMain.Certification.RelativityGR.maxwell_implies_stress_conservation_minkowski
#print axioms CATEPTMain.Certification.RelativityGR.canonical_maxwell_implies_stress_conservation_derived
#print axioms CATEPTMain.Certification.RelativityGR.canonicalNamedFaradayComponents
#print axioms CATEPTMain.Certification.RelativityGR.canonical_electrovacuum_stress_bridge_of_faraday_components
#print axioms CATEPTMain.Certification.RelativityGR.canonical_maxwell_implies_stress_conservation_of_faraday_components
#print axioms CATEPTMain.Certification.RelativityGR.canonicalMinkowskiFaradayStressFamily
#print axioms CATEPTMain.Certification.RelativityGR.canonical_minkowski_faraday_family_implies_stress_conservation

-- ── GR curved-Maxwell bridge certificate (reused NSCATEPT core surface) ─────
#print axioms CATEPTMain.Certification.RelativityGR.canonical_gr_curved_maxwell
#print axioms CATEPTMain.Certification.RelativityGR.gr_curved_maxwell_flat_wave_eq

-- ── GR VML-Maxwell equilibrium certificate (plugin-vml-landau bridge) ───────
#print axioms CATEPTMain.Certification.RelativityGR.vml_steady_state_rigidity_certified
#print axioms CATEPTMain.Certification.RelativityGR.vml_landau_content_available_certified
#print axioms CATEPTMain.Certification.RelativityGR.canonical_vml_maxwell_equilibrium
#print axioms CATEPTMain.Certification.RelativityGR.vml_equilibrium_implies_E_zero
#print axioms CATEPTMain.Certification.RelativityGR.vml_equilibrium_implies_B_constant
#print axioms CATEPTMain.Certification.RelativityGR.vml_equilibrium_implies_global_maxwellian
#print axioms CATEPTMain.Certification.RelativityGR.vml_equilibrium_projection_bundle

-- ── GR Maxwell-CurveSpace/pphi2 bridge certificate ───────────────────────────
#print axioms CATEPTMain.Certification.RelativityGR.mk_maxwell_pphi2_certificate
#print axioms CATEPTMain.Certification.RelativityGR.mk_maxwell_pphi2_certificate_contract_holds
#print axioms CATEPTMain.Certification.RelativityGR.canonical_maxwell_pphi2_certificate
#print axioms CATEPTMain.Certification.RelativityGR.canonical_maxwell_pphi2_bridge_contract_available

-- ── GR full direct curved-claim certificate surface ─────────────────────────
#print axioms CATEPTMain.Certification.RelativityGR.CurvedGRDirectCertificate
#print axioms CATEPTMain.Certification.RelativityGR.mk_curved_gr_direct_certificate
#print axioms CATEPTMain.Certification.RelativityGR.mk_curved_gr_direct_certificate_of_fixedAntisymmetric4D
#print axioms CATEPTMain.Certification.RelativityGR.curved_gr_direct_full_claim
#print axioms CATEPTMain.Certification.RelativityGR.mk_curved_gr_direct_certificate_claim
#print axioms CATEPTMain.Certification.RelativityGR.mk_curved_gr_direct_certificate_of_fixedAntisymmetric4D_claim
#print axioms CATEPTMain.Certification.RelativityGR.FaradayMinkowskiFixedWitness
#print axioms CATEPTMain.Certification.RelativityGR.gravitasFaradayMinkowski_fixedAntisymmetric4D_of_witness
#print axioms CATEPTMain.Certification.RelativityGR.canonical_curved_gr_direct_certificate_of_fixedAntisymmetric4D
#print axioms CATEPTMain.Certification.RelativityGR.canonical_curved_gr_direct_certificate_of_fixedAntisymmetric4D_claim
#print axioms CATEPTMain.Certification.RelativityGR.canonical_faraday_minkowski_fixed_witness
#print axioms CATEPTMain.Certification.RelativityGR.canonical_faraday_minkowski_fixed_witness_claim
#print axioms CATEPTMain.Certification.RelativityGR.canonical_curved_gr_direct_certificate_witness_free
#print axioms CATEPTMain.Certification.RelativityGR.canonical_curved_gr_direct_certificate_witness_free_claim
#print axioms CATEPTMain.Certification.RelativityGR.FaradayOfMetricFixedWitness
#print axioms CATEPTMain.Certification.RelativityGR.faraday_ofMetric_is_fixedAntisymmetric4D
#print axioms CATEPTMain.Certification.RelativityGR.canonical_faraday_ofMetric_witness_minkowski
#print axioms CATEPTMain.Certification.RelativityGR.IsCertifiedCurvedGRData
#print axioms CATEPTMain.Certification.RelativityGR.curved_gr_direct_certificate_of_certified_data
#print axioms CATEPTMain.Certification.RelativityGR.certified_curved_gr_data_implies_full_direct_claim
#print axioms CATEPTMain.Certification.RelativityGR.isCertifiedCurvedGRData_of_fixedAntisymmetric4D
#print axioms CATEPTMain.Certification.RelativityGR.canonical_certified_curved_gr_data
#print axioms CATEPTMain.Certification.RelativityGR.canonical_curved_gr_direct_certificate_of_certified_data
#print axioms CATEPTMain.Certification.RelativityGR.canonical_certified_curved_gr_data_full_claim
#print axioms CATEPTMain.Certification.RelativityGR.IsEinsteinElectrovacuumSolution
#print axioms CATEPTMain.Certification.RelativityGR.einsteinElectrovacuumStress
#print axioms CATEPTMain.Certification.RelativityGR.einstein_certificate_for_solution
#print axioms CATEPTMain.Certification.RelativityGR.einstein_electrovacuum_solution_full_claim
#print axioms CATEPTMain.Certification.RelativityGR.canonical_minkowski_is_einstein_electrovacuum_solution
#print axioms CATEPTMain.Certification.RelativityGR.canonical_einstein_certificate_of_electrovacuum_solution
#print axioms CATEPTMain.Certification.RelativityGR.canonical_einstein_electrovacuum_solution_full_claim
#print axioms CATEPTMain.Certification.RelativityGR.IsCertifiedADMData
#print axioms CATEPTMain.Certification.RelativityGR.adm_certificate_for_data
#print axioms CATEPTMain.Certification.RelativityGR.adm_data_full_claim
#print axioms CATEPTMain.Certification.RelativityGR.canonical_minkowski_is_certified_adm_data
#print axioms CATEPTMain.Certification.RelativityGR.canonical_adm_certificate_of_data
#print axioms CATEPTMain.Certification.RelativityGR.canonical_adm_data_full_claim
#print axioms CATEPTMain.Certification.RelativityGR.IsVMLElectrovacuumEquilibrium
#print axioms CATEPTMain.Certification.RelativityGR.isVMLElectrovacuumEquilibrium_of_maxwellian
#print axioms CATEPTMain.Certification.RelativityGR.vml_electrovacuum_equilibrium_full_claim
#print axioms CATEPTMain.Certification.RelativityGR.canonical_trivial_vml_electrovacuum_equilibrium
#print axioms CATEPTMain.Certification.RelativityGR.vml_equilibrium_supports_flat_electrovacuum_family
#print axioms CATEPTMain.Certification.RelativityGR.vml_electrovacuum_equilibrium_content_available
-- ── GR witness-free stress-identification (WF-GR-StressId-001) ──────────────
#print axioms CATEPTMain.Certification.RelativityGR.namedCanonicalElectrovacuumStress
#print axioms CATEPTMain.Certification.RelativityGR.namedCanonicalElectrovacuumStress_eq_gravitasEMStressEnergy
#print axioms CATEPTMain.Certification.RelativityGR.namedCanonical_maxwell_to_stress_conservation_witness_free
#print axioms CATEPTMain.Certification.RelativityGR.vml_equilibrium_supports_named_canonical_electrovacuum_family_witness_free
#print axioms CATEPTMain.Certification.RelativityGR.curved_gr_direct_to_adm_certificate_for
#print axioms CATEPTMain.Certification.RelativityGR.curved_gr_direct_to_adm_certificate_for_holds
#print axioms CATEPTMain.Certification.RelativityGR.curved_gr_direct_to_einstein_certificate_for_source
#print axioms CATEPTMain.Certification.RelativityGR.curved_gr_direct_to_einstein_certificate_for_source_holds
#print axioms CATEPTMain.Certification.RelativityGR.curved_gr_direct_to_einstein_certificate_for
#print axioms CATEPTMain.Certification.RelativityGR.curved_gr_direct_to_einstein_certificate_for_holds

-- ── GR unsafe-claims closure certificate (canonical residual-identity layer) ─
#print axioms CATEPTMain.Certification.RelativityGR.canonical_gr_unsafe_claims_closed
#print axioms CATEPTMain.Certification.RelativityGR.gravitasFaraday_double_hodge_bivector
#print axioms CATEPTMain.Certification.RelativityGR.gravitasCanonicalStress_conserved_constant_model
#print axioms CATEPTMain.Certification.RelativityGR.gravitasEinstein_residual_exact
#print axioms CATEPTMain.Certification.RelativityGR.einstein_residual_zero_for_vacuum_family
#print axioms CATEPTMain.Certification.RelativityGR.gravitasCanonicalVacuumADM_hamiltonian_residual_exact

-- ── Typed GR residual objects (first-class certified payloads) ───────────────
#print axioms CATEPTMain.Certification.RelativityGR.canonical_einstein_residual
#print axioms CATEPTMain.Certification.RelativityGR.canonical_adm_residual

-- ── Typed Einstein-equation certificate (Target 4) ───────────────────────────
#print axioms CATEPTMain.Certification.RelativityGR.mk_einstein_equation_certificate
#print axioms CATEPTMain.Certification.RelativityGR.mk_einstein_equation_certificate_holds
#print axioms CATEPTMain.Certification.RelativityGR.mk_einstein_equation_certificate_for
#print axioms CATEPTMain.Certification.RelativityGR.mk_einstein_equation_certificate_for_holds
#print axioms CATEPTMain.Certification.RelativityGR.mk_einstein_equation_certificate_for_source
#print axioms CATEPTMain.Certification.RelativityGR.mk_einstein_equation_certificate_for_source_holds
#print axioms CATEPTMain.Certification.RelativityGR.canonical_electrovac_einstein_certificate
#print axioms CATEPTMain.Certification.RelativityGR.canonical_electrovac_einstein_equation_holds
#print axioms CATEPTMain.Certification.RelativityGR.canonical_electrovac_einstein_certificate_for
#print axioms CATEPTMain.Certification.RelativityGR.canonical_electrovac_einstein_equation_holds_for
#print axioms CATEPTMain.Certification.RelativityGR.canonical_electrovac_einstein_certificate_for_source
#print axioms CATEPTMain.Certification.RelativityGR.canonical_electrovac_einstein_equation_holds_for_source
#print axioms CATEPTMain.Certification.RelativityGR.canonical_electrovac_einstein_certificate_for_family
#print axioms CATEPTMain.Certification.RelativityGR.canonical_electrovac_einstein_equation_holds_for_family
#print axioms CATEPTMain.Certification.RelativityGR.canonical_electrovac_einstein_certificate_for_source_family
#print axioms CATEPTMain.Certification.RelativityGR.canonical_electrovac_einstein_equation_holds_for_source_family

-- ── Typed ADM-constraint certificate (Target 5) ──────────────────────────────
#print axioms CATEPTMain.Certification.RelativityGR.mk_adm_constraint_certificate
#print axioms CATEPTMain.Certification.RelativityGR.mk_adm_constraint_certificate_holds
#print axioms CATEPTMain.Certification.RelativityGR.mk_adm_constraint_certificate_for
#print axioms CATEPTMain.Certification.RelativityGR.mk_adm_constraint_certificate_for_holds
#print axioms CATEPTMain.Certification.RelativityGR.canonical_vacuum_adm_certificate
#print axioms CATEPTMain.Certification.RelativityGR.canonical_vacuum_adm_hamiltonian_constraint_holds
#print axioms CATEPTMain.Certification.RelativityGR.canonical_vacuum_adm_momentum_constraint_holds
#print axioms CATEPTMain.Certification.RelativityGR.canonical_vacuum_adm_certificate_for
#print axioms CATEPTMain.Certification.RelativityGR.canonical_vacuum_adm_certificate_for_family
#print axioms CATEPTMain.Certification.RelativityGR.canonical_vacuum_adm_certificate_for_family_holds
#print axioms CATEPTMain.Certification.RelativityGR.minkowski_vacuum_adm_constraints_for_family
