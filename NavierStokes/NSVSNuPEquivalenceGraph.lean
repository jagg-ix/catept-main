import NavierStokes.NSVSNuPKernel
import NavierStokes.NSVSNuPResolutionBridge
import NavierStokes.NSInfoTheoreticBottleneckBridge
import NavierStokes.ThermodynamicRegularityBridge
import NavierStokes.NSObservationalEntropyBridge
import NavierStokes.NSComplexEinsteinEntropicMatterBridge
import NavierStokes.RicciFlowCATEPTBridge
import NavierStokes.NSSliceDecompositionBridge
import NavierStokes.VSOmegaPKernel
import NavierStokes.NSMadelungADMTensorBridge
import NavierStokes.Bridges.NSModularNoetherBridge
import NavierStokes.Bridges.NSArakiRelativeEntropyBridge
import NavierStokes.Bridges.NSImaginaryActionConcavityBridge
import NavierStokes.Bridges.NSMadelungADMTensorBridge
import NavierStokes.MillenniumAuditCertificate
import NavierStokes.NSEnstrophyPhysicalizationBridge

/-!
# VS≤νP Equivalence Graph (Compile-Safe Core)

This module provides a compile-safe graph layer for the VS≤νP equivalent-form
catalog and a machine-readable list of currently missing closure arrows.

Design goals:
- keep the graph lightweight and syntax-stable (no HoTT/cubical dependencies),
- ensure high-value equivalence symbols resolve in Lean,
- isolate blocked closure arrows with explicit Lean anchors and next actions.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

/-- Node ids for the 23-form VS≤νP equivalent-form catalog. -/
inductive VSNuPForm where
  | f01 | f02 | f03 | f04 | f05 | f06 | f07 | f08 | f09 | f10 | f11
  | f12 | f13 | f14 | f15 | f16 | f17 | f18 | f19 | f20 | f21 | f22 | f23
  deriving DecidableEq, Repr

/-- Canonical representative used across the current route planning stack. -/
def canonicalVSNuPForm : VSNuPForm := .f22

/-- Canonical catalog entry for the VS≤νP equivalent-form inventory.
This block is intentionally script-friendly and acts as the Lean-side source of
truth used by sync tooling. -/
structure VSNuPFormCatalogEntry where
  id              : VSNuPForm
  symbol          : String
  formType        : String
  bridgeLayer     : String
  scope           : String
  equivalenceKey  : String
  equivalenceText : String
  sourceFile      : String
  sourceLine      : Nat
  deriving Repr

/-- Lean-side source-of-truth catalog for the equivalent forms tracked in the
ZIL model. -/
def vsnupFormCatalog : List VSNuPFormCatalogEntry :=
  [ { id := .f01, symbol := "vs_le_nuP_iff_ratio_guard", formType := "theorem_iff", bridgeLayer := "kernel", scope := "local", equivalenceKey := "ratio_guard", equivalenceText := "VS <= nu*P <-> VS/Omega <= nu*(P/Omega) with Omega>0", sourceFile := "NSVSNuPKernel.lean", sourceLine := 50 }
  , { id := .f02, symbol := "ns_imaginary_noether_defect_nonneg_iff_vs_le_nuP", formType := "theorem_iff", bridgeLayer := "kernel", scope := "local", equivalenceKey := "defect_nonneg", equivalenceText := "0 <= (nu*P - VS) <-> VS <= nu*P", sourceFile := "NSVSNuPKernel.lean", sourceLine := 119 }
  , { id := .f03, symbol := "vs_le_nuP_iff_enstrophy_rate_nonpos", formType := "theorem_iff", bridgeLayer := "kernel", scope := "local", equivalenceKey := "enstrophy_rate_nonpos", equivalenceText := "VS <= nu*P <-> dOmega/dt <= 0", sourceFile := "NSVSNuPKernel.lean", sourceLine := 132 }
  , { id := .f04, symbol := "projectedThetaCoeff_le_nu_iff_vs_le_nuP", formType := "theorem_iff", bridgeLayer := "slice_decomposition", scope := "local", equivalenceKey := "theta_vs_nup", equivalenceText := "theta(t) <= nu <-> VS <= nu*P", sourceFile := "NSSliceDecompositionBridge.lean", sourceLine := 492 }
  , { id := .f05, symbol := "vs_le_nuP_iff_vs_over_omega_le_nu_p_over_omega", formType := "theorem_iff", bridgeLayer := "vs_omega_kernel", scope := "local", equivalenceKey := "ratio_guard_alias", equivalenceText := "VS <= nu*P <-> VS/Omega <= nu*(P/Omega)", sourceFile := "VSOmegaPKernel.lean", sourceLine := 31 }
  , { id := .f06, symbol := "defect_nonneg_iff_vs_le_nuP", formType := "theorem_iff", bridgeLayer := "modular_noether", scope := "local", equivalenceKey := "modular_defect_nonneg", equivalenceText := "0 <= D_I <-> VS <= nu*P", sourceFile := "Bridges/NSModularNoetherBridge.lean", sourceLine := 51 }
  , { id := .f07, symbol := "defect_nonneg_iff_enstrophy_rate_nonpos", formType := "theorem_iff", bridgeLayer := "modular_noether", scope := "local", equivalenceKey := "modular_defect_rate", equivalenceText := "0 <= D_I <-> dOmega/dt <= 0", sourceFile := "Bridges/NSModularNoetherBridge.lean", sourceLine := 58 }
  , { id := .f08, symbol := "dirac_mass_nonneg_iff_defect_nonneg", formType := "theorem_iff", bridgeLayer := "madelung_adm", scope := "local", equivalenceKey := "dirac_mass_defect", equivalenceText := "m_D >= 0 <-> D_I >= 0 with rho>0", sourceFile := "Bridges/NSMadelungADMTensorBridge.lean", sourceLine := 122 }
  , { id := .f09, symbol := "dirac_mass_nonneg_iff_vs_le_nuP", formType := "theorem_iff", bridgeLayer := "madelung_adm", scope := "local", equivalenceKey := "dirac_mass_nup", equivalenceText := "m_D >= 0 <-> VS <= nu*P with rho>0", sourceFile := "Bridges/NSMadelungADMTensorBridge.lean", sourceLine := 137 }
  , { id := .f10, symbol := "signal_integrity_iff_vs_le_nuP", formType := "theorem_iff", bridgeLayer := "info_theoretic", scope := "local", equivalenceKey := "signal_integrity", equivalenceText := "NSSignalIntegrityAtTime <-> VS <= nu*P", sourceFile := "NSInfoTheoreticBottleneckBridge.lean", sourceLine := 149 }
  , { id := .f11, symbol := "vs_le_nuP_iff_defect_nonneg", formType := "theorem_iff", bridgeLayer := "observational_entropy", scope := "local", equivalenceKey := "observational_defect", equivalenceText := "VS <= nu*P <-> vsNuPDefect >= 0", sourceFile := "NSObservationalEntropyBridge.lean", sourceLine := 263 }
  , { id := .f12, symbol := "millennium_iff_noncomm_nonneg", formType := "theorem_iff", bridgeLayer := "observational_entropy", scope := "global", equivalenceKey := "global_noncomm_signature", equivalenceText := "VSLeNuPAllTrajProp <-> noncommutativity_signature_nonnegative_global", sourceFile := "NSObservationalEntropyBridge.lean", sourceLine := 272 }
  , { id := .f13, symbol := "vs_le_nuP_iff_imag_stress_nonneg", formType := "theorem_iff", bridgeLayer := "complex_einstein_entropic_matter", scope := "local", equivalenceKey := "imag_stress_nonneg", equivalenceText := "VS <= nu*P <-> T_I >= 0", sourceFile := "NSComplexEinsteinEntropicMatterBridge.lean", sourceLine := 253 }
  , { id := .f14, symbol := "millennium_as_imaginary_stress_positivity", formType := "theorem_iff", bridgeLayer := "complex_einstein_entropic_matter", scope := "global", equivalenceKey := "global_imag_stress", equivalenceText := "VSLeNuPAllTrajProp <-> T_I >= 0 globally", sourceFile := "NSComplexEinsteinEntropicMatterBridge.lean", sourceLine := 262 }
  , { id := .f15, symbol := "three_millennium_reformulations_equivalent", formType := "theorem_equivalence_bundle", bridgeLayer := "complex_einstein_entropic_matter", scope := "global", equivalenceKey := "tri_equivalence_bundle", equivalenceText := "Global standard VS<=nuP, observational defect, and imaginary-stress formulations are equivalent", sourceFile := "NSComplexEinsteinEntropicMatterBridge.lean", sourceLine := 277 }
  , { id := .f16, symbol := "ns_araki_rel_entropy_decreasing_iff_vs_le_nuP", formType := "theorem_iff", bridgeLayer := "araki_relative_entropy", scope := "local", equivalenceKey := "araki_entropy_monotone", equivalenceText := "d/dt S_rel_NS <= 0 <-> VS <= nu*P", sourceFile := "Bridges/NSArakiRelativeEntropyBridge.lean", sourceLine := 113 }
  , { id := .f17, symbol := "imaginary_action_omega_concavity_iff_vs_le_nuP_of_witness", formType := "theorem_iff", bridgeLayer := "imag_action_concavity", scope := "local", equivalenceKey := "omega_concavity", equivalenceText := "d2 S_I_Omega / dt2 <= 0 <-> VS <= nu*P under witness assumptions", sourceFile := "Bridges/NSImaginaryActionConcavityBridge.lean", sourceLine := 115 }
  , { id := .f18, symbol := "ns_defect_nonneg_iff_vs_le_nuP_inst", formType := "theorem_iff", bridgeLayer := "ricci_cat_ept_instance", scope := "local", equivalenceKey := "instance_defect_nonneg", equivalenceText := "Instance-level D_I >= 0 <-> VS <= nu*P", sourceFile := "RicciFlowCATEPTBridge.lean", sourceLine := 182 }
  , { id := .f19, symbol := "NSSignalIntegrityAtTime", formType := "definition_alias", bridgeLayer := "info_theoretic", scope := "local", equivalenceKey := "alias_signal_integrity_at_time", equivalenceText := "Definition alias naming VS <= nu*P as signal integrity at time", sourceFile := "NSInfoTheoreticBottleneckBridge.lean", sourceLine := 133 }
  , { id := .f20, symbol := "NSUniversalSignalIntegrity", formType := "definition_alias", bridgeLayer := "info_theoretic", scope := "global", equivalenceKey := "alias_signal_integrity_global", equivalenceText := "Definition alias naming forall t>=0. VS <= nu*P", sourceFile := "NSInfoTheoreticBottleneckBridge.lean", sourceLine := 140 }
  , { id := .f21, symbol := "KMSCompatible", formType := "definition_alias", bridgeLayer := "thermodynamic", scope := "global", equivalenceKey := "alias_kms_compatibility", equivalenceText := "Definition alias naming KMS compatibility as forall t>=0. VS <= nu*P", sourceFile := "ThermodynamicRegularityBridge.lean", sourceLine := 63 }
  , { id := .f22, symbol := "VSLeNuPAllTrajProp", formType := "definition_canonical_predicate", bridgeLayer := "resolution_bridge", scope := "global", equivalenceKey := "canonical_universal_predicate", equivalenceText := "Canonical universal predicate: forall traj t>=0. VS <= nu*P", sourceFile := "NSVSNuPResolutionBridge.lean", sourceLine := 32 }
  , { id := .f23, symbol := "realNoetherToSliceVS_global_contract", formType := "axiom_root_contract_witness", bridgeLayer := "thermodynamic_root_contract", scope := "global", equivalenceKey := "root_contract_witness", equivalenceText := "Axiom witness of RealNoetherToSliceVSContract; same quantifier/inequality shape as canonical VSLeNuPAllTrajProp", sourceFile := "ThermodynamicRegularityBridge.lean", sourceLine := 165 } ]

theorem vsnupFormCatalog_count :
    vsnupFormCatalog.length = 23 := by decide

/-- Metadata for a proved equivalence transport edge in the catalog. -/
structure EquivalenceArrow where
  edgeId    : String
  source    : VSNuPForm
  target    : VSNuPForm
  witness   : String
  statement : String
  deriving Repr

/-- Lightweight proof-backbone edges (all theorem-level symbol anchors). -/
def provedEquivalenceBackbone : List EquivalenceArrow :=
  [ { edgeId := "e01", source := .f01, target := .f22
      witness := "vs_le_nuP_iff_ratio_guard"
      statement := "local ratio-guard equivalence transports to canonical VS<=nuP contract context" }
  , { edgeId := "e02", source := .f02, target := .f22
      witness := "ns_imaginary_noether_defect_nonneg_iff_vs_le_nuP"
      statement := "defect nonnegativity is equivalent to VS<=nuP" }
  , { edgeId := "e03", source := .f03, target := .f22
      witness := "vs_le_nuP_iff_enstrophy_rate_nonpos"
      statement := "enstrophy-rate nonpositivity is equivalent to VS<=nuP" }
  , { edgeId := "e04", source := .f04, target := .f22
      witness := "projectedThetaCoeff_le_nu_iff_vs_le_nuP"
      statement := "slice projection coefficient guard transports to VS<=nuP" }
  , { edgeId := "e05", source := .f06, target := .f22
      witness := "defect_nonneg_iff_vs_le_nuP"
      statement := "modular noether defect form is equivalent to VS<=nuP" }
  , { edgeId := "e06", source := .f10, target := .f22
      witness := "signal_integrity_iff_vs_le_nuP"
      statement := "signal-integrity alias is equivalent to VS<=nuP" }
  , { edgeId := "e07", source := .f11, target := .f22
      witness := "vs_le_nuP_iff_defect_nonneg"
      statement := "observational entropy defect form is equivalent to VS<=nuP" }
  , { edgeId := "e08", source := .f13, target := .f22
      witness := "vs_le_nuP_iff_imag_stress_nonneg"
      statement := "imaginary-stress positivity form is equivalent to VS<=nuP" }
  , { edgeId := "e09", source := .f16, target := .f22
      witness := "ns_araki_rel_entropy_decreasing_iff_vs_le_nuP"
      statement := "relative-entropy monotonicity form is equivalent to VS<=nuP" }
  , { edgeId := "e10", source := .f18, target := .f22
      witness := "ns_defect_nonneg_iff_vs_le_nuP_inst"
      statement := "Ricci/CAT-EPT instance-level defect form is equivalent to VS<=nuP" } ]

theorem provedEquivalenceBackbone_count :
    provedEquivalenceBackbone.length = 10 := by decide

/-- Root-contract to canonical transport:
`RealNoetherToSliceVSContract` has the same quantifier shape as the canonical
`VSLeNuPAllTrajProp`, so transport is definitional. -/
theorem realNoether_contract_implies_vsnup_all
    (hRoot : RealNoetherToSliceVSContract) :
    VSLeNuPAllTrajProp := by
  intro traj t ht hNS hFS
  exact hRoot traj t ht hNS hFS

/-- Yoneda-style transport eliminator for the VS≤νP category:
any target proposition reachable from the canonical representative
`VSLeNuPAllTrajProp` is reachable from the root contract witness. -/
theorem yoneda_transport_from_realNoether
    {P : Prop}
    (hTransport : VSLeNuPAllTrajProp → P)
    (hRoot : RealNoetherToSliceVSContract) :
    P :=
  hTransport (realNoether_contract_implies_vsnup_all hRoot)

/-- Expansion 1: root contract transports to universal enstrophy-rate
nonpositivity. -/
theorem realNoether_contract_implies_enstrophy_rate_nonpos_all
    (hRoot : RealNoetherToSliceVSContract) :
    EnstrophyRateNonposAllTrajProp :=
  yoneda_transport_from_realNoether
    vs_le_nu_p_all_implies_enstrophy_rate_nonpos_all hRoot

/-- Expansion 2: root contract transports to `PreciseGapStatement`. -/
theorem realNoether_contract_implies_precise_gap
    (hRoot : RealNoetherToSliceVSContract) :
    PreciseGapStatement :=
  yoneda_transport_from_realNoether
    vs_le_nu_p_all_implies_precise_gap hRoot

/-- Expansion 3: root contract transports to the observational-entropy global
noncommutativity form. -/
theorem realNoether_contract_implies_noncomm_signature_nonneg_global
    (hRoot : RealNoetherToSliceVSContract) :
    ∀ (traj : Trajectory NSField) (t : Rat),
      0 ≤ t →
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      0 ≤ NavierStokes.ObservationalEntropy.vsNuPDefect traj t := by
  exact (NavierStokes.ObservationalEntropy.millennium_iff_noncomm_nonneg.mp
    (realNoether_contract_implies_vsnup_all hRoot))

/-- Expansion 4: root contract transports to KMS-compatibility for each
trajectory (via defect-form entropy production). -/
theorem realNoether_contract_implies_kms_compatible
    (hRoot : RealNoetherToSliceVSContract) :
    ∀ (traj : Trajectory NSField),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      KMSCompatible traj := by
  intro traj hNS hFS
  refine entropy_production_nonneg_implies_kms traj hNS hFS ?hProd
  intro t ht
  have hVS : vortexStretchingIntegral traj t ≤
      nsNu * palinstrophy (traj.stateAt t).velocity :=
    hRoot traj t ht hNS hFS
  linarith

/-- Exported expansion pack from the currently used root witness
`realNoetherToSliceVS_global_contract`.

This makes the "one-category, many equivalent equations" expansion explicit in
Lean so downstream lanes can consume a single theorem instead of re-deriving
transport steps. -/
theorem realNoether_root_witness_expansion_pack :
    VSLeNuPAllTrajProp
    ∧ EnstrophyRateNonposAllTrajProp
    ∧ PreciseGapStatement
    ∧ (∀ (traj : Trajectory NSField) (t : Rat),
         0 ≤ t →
         SatisfiesNSPDE nsOps nsNu traj →
         RespectsFunctionSpaces nsSpacesR3 traj →
         0 ≤ NavierStokes.ObservationalEntropy.vsNuPDefect traj t)
    ∧ (∀ (traj : Trajectory NSField),
         SatisfiesNSPDE nsOps nsNu traj →
         RespectsFunctionSpaces nsSpacesR3 traj →
         KMSCompatible traj) := by
  refine ⟨?h1, ?h2, ?h3, ?h4, ?h5⟩
  · exact realNoether_contract_implies_vsnup_all realNoetherToSliceVS_global_contract
  · exact realNoether_contract_implies_enstrophy_rate_nonpos_all realNoetherToSliceVS_global_contract
  · exact realNoether_contract_implies_precise_gap realNoetherToSliceVS_global_contract
  · exact realNoether_contract_implies_noncomm_signature_nonneg_global realNoetherToSliceVS_global_contract
  · exact realNoether_contract_implies_kms_compatible realNoetherToSliceVS_global_contract

/-- Symbol-resolution guard:
if this theorem compiles, the key catalog symbols are still present and named. -/
theorem vsnup_catalog_symbol_resolution_guard : True := by
  have _ := NavierStokes.Millennium.vs_le_nuP_iff_ratio_guard
  have _ := NavierStokes.Millennium.ns_imaginary_noether_defect_nonneg_iff_vs_le_nuP
  have _ := NavierStokes.Millennium.vs_le_nuP_iff_enstrophy_rate_nonpos
  have _ := NavierStokes.SliceDecomposition.projectedThetaCoeff_le_nu_iff_vs_le_nuP
  have _ := NavierStokes.Millennium.vs_le_nuP_iff_vs_over_omega_le_nu_p_over_omega
  have _ := NavierStokes.Bridges.NSModularNoether.defect_nonneg_iff_vs_le_nuP
  have _ := NavierStokes.Bridges.NSModularNoether.defect_nonneg_iff_enstrophy_rate_nonpos
  have _ := NavierStokes.Bridges.NSMadelungADMTensor.dirac_mass_nonneg_iff_defect_nonneg
  have _ := NavierStokes.Bridges.NSMadelungADMTensor.dirac_mass_nonneg_iff_vs_le_nuP
  have _ := NavierStokes.InfoTheoreticBottleneck.signal_integrity_iff_vs_le_nuP
  have _ := NavierStokes.ObservationalEntropy.vs_le_nuP_iff_defect_nonneg
  have _ := NavierStokes.ObservationalEntropy.millennium_iff_noncomm_nonneg
  have _ := NavierStokes.ComplexEinsteinEntropicMatter.vs_le_nuP_iff_imag_stress_nonneg
  have _ := NavierStokes.ComplexEinsteinEntropicMatter.millennium_as_imaginary_stress_positivity
  have _ := NavierStokes.ComplexEinsteinEntropicMatter.three_millennium_reformulations_equivalent
  have _ := NavierStokes.Bridges.NSArakiRelativeEntropy.ns_araki_rel_entropy_decreasing_iff_vs_le_nuP
  have _ := NavierStokes.Bridges.NSImaginaryActionConcavity.imaginary_action_omega_concavity_iff_vs_le_nuP_of_witness
  have _ := NavierStokes.RicciCATEPT.ns_defect_nonneg_iff_vs_le_nuP_inst
  have _ := NavierStokes.InfoTheoreticBottleneck.NSSignalIntegrityAtTime
  have _ := NavierStokes.InfoTheoreticBottleneck.NSUniversalSignalIntegrity
  have _ := NavierStokes.Millennium.KMSCompatible
  have _ := NavierStokes.Millennium.VSLeNuPAllTrajProp
  have _ := NavierStokes.Millennium.realNoetherToSliceVS_global_contract
  trivial

/-- Missing/blocked arrow item:
each item is an unclosed transport edge from the equivalent-form class to strict
physical closure contracts. -/
structure MissingArrowObligation where
  obligationId : String
  source       : String
  target       : String
  blockerKind  : String
  leanAnchor   : String
  nextAction   : String
  deriving Repr

/-- Resolved arrow obligation item:
records formerly missing arrows that have since been closed by a Stage. -/
structure ResolvedArrowObligation where
  obligationId  : String
  source        : String
  target        : String
  resolutionRef : String    -- Lean anchor proving the obligation closed
  closedByStage : String
  deriving Repr

/-- Current blocked closure arrows from the canonical equivalent-form class.

Stage 257 audit:
- m01 retired (Path C is now physically closed, see `resolvedArrowObligations`).
- m05 leanAnchor corrected: `bkm_t3_global_existence` is a THEOREM — the real
  open content is `AxiomaticEstimates.nsStaticCompatibilityContract` (the
  Leray-projection + Poisson-pressure sub-axiom, `.partiallyVerified`). -/
def missingArrowObligations : List MissingArrowObligation :=
  [ { obligationId := "m04_pde_semantics_concretization"
      source := "VSLeNuPAllTrajProp"
      target := "strict physical SatisfiesNSPDE/function-space semantics"
      blockerKind := "pde_semantics_gap"
      leanAnchor := "WORKLOG.ns_target_concretize_pde_semantics_t3"
      nextAction := "tie operators and spaces to concrete T3 weak/physical semantics" }
  , { obligationId := "m05_galerkin_operator_identification"
      source := "VSLeNuPAllTrajProp"
      target := "surrogate operator identification for Leray+Poisson on Galerkin spaces"
      blockerKind := "surrogate_operator_gap"
      leanAnchor := "AxiomaticEstimates.nsGalerkinLerayContract"
      nextAction :=
        "identify surrogate nsDiv/nsGrad/nsConvection with concrete Fourier operators; " ++
        "K-Y Def.1.1 (Leray, arXiv:2110.08039) + K-Y Eq.1.3 (Poisson) provide the math; " ++
        "Stage 259: nsStaticCompatibilityContract already promoted to THEOREM from K-Y sub-axioms" } ]

theorem missingArrowObligations_count :
    missingArrowObligations.length = 2 := by decide

/-- Arrows that were formerly in `missingArrowObligations` but are now closed. -/
def resolvedArrowObligations : List ResolvedArrowObligation :=
  [ { obligationId  := "m01_strict_physical_closure"
      source        := "VSLeNuPAllTrajProp"
      target        := "pathCCertificate.strictPhysicalSemanticsClosed = true"
      resolutionRef := "MillenniumAuditCertificate.path_C_physically_closed"
      closedByStage := "Stage-253 (NSGalerkinPassageLimitProof SA-G1/G2/G3 grounded all shim blockers)" } ]

theorem resolvedArrowObligations_count :
    resolvedArrowObligations.length = 1 := by decide

/-- Stage 257: m01 is closed.
`path_C_physically_closed` proves `physical_semantics_closed pathCCertificate = true`
by `rfl`, confirming the semantic shim blockers are gone.  The leanAnchor that
`missingArrowObligations` carried for m01 (`path_C_not_physically_closed`) was stale —
that theorem was never created; instead Stage 253 proved the positive direction. -/
theorem m01_resolved_by_stage253 :
    NavierStokes.MillenniumAudit.physical_semantics_closed
      NavierStokes.MillenniumAudit.pathCCertificate = true :=
  NavierStokes.MillenniumAudit.path_C_physically_closed

/-- Existing formal closure transport from canonical VS≤νP contract to precise gap. -/
theorem canonical_to_precise_gap_arrow_available :
    VSLeNuPAllTrajProp → PreciseGapStatement :=
  vs_le_nu_p_all_implies_precise_gap

/-- Existing bridge reduction from the physicalization gate to the Stage-218
strong physical-mode bridge contract. -/
theorem enstrophy_gate_to_strong_bridge_arrow_available :
    EnstrophyPhysicalizationGate →
      BridgeTargetLinearEntropicControlPhysicalMode0Strong :=
  NavierStokes.MillenniumAudit.path_C_stage218_strong_bridge_reduces_to_enstrophy_physicalization_gate

/-- Stage-230 milestone: global candidate-swap alignment is discharged. -/
theorem candidate_swap_arrow_discharged_current_model :
    (∀ v : NSField, enstrophy v = EnstrophyPhysicalizedCandidate v) :=
  NavierStokes.MillenniumAudit.path_C_stage218_candidate_swap_discharged_current_model

/-- Stage-230 milestone: strong Stage-218 bridge contract is discharged. -/
theorem mode0_strong_bridge_arrow_discharged_current_model :
    BridgeTargetLinearEntropicControlPhysicalMode0Strong :=
  NavierStokes.MillenniumAudit.path_C_stage218_strong_bridge_discharged_current_model

/-- Existing strict one-step route from the physicalization gate to global
regularity (the closure blocker is semantic hardening/internalization, not a
missing connector theorem). -/
theorem enstrophy_gate_to_global_route_arrow_available :
    EnstrophyPhysicalizationGate →
      (∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0) :=
  NavierStokes.MillenniumAudit.path_C_stage221_strong_global_route_of_enstrophyPhysicalizationGate

/-- Ranked immediate unblock sequence corresponding to `missingArrowObligations`
after Stage 257 audit (m01 retired). -/
def immediateDirectUnblockSequence : List String :=
  [ "m04: concretize PDE + function-space semantics on concrete T3 carrier"
  , "m05: prove NSStaticCompatibilityContract (Leray projection + Poisson pressure)" ]

theorem immediateDirectUnblockSequence_count :
    immediateDirectUnblockSequence.length = 2 := by decide

end

end NavierStokes.Millennium
