import CATEPTMain.Domains.CoherenceSpine
import CATEPTMain.Domains.UnifiedValidator
import CATEPTMain.Domains.Adapters.HarmonicOscillator
import CATEPTMain.Domains.Adapters.Kinetic
import CATEPTMain.Domains.Adapters.Higgs
import CATEPTMain.Domains.Adapters.Herglotz
import CATEPTMain.Domains.Adapters.QM
import CATEPTMain.Domains.Adapters.BohmianEM
import CATEPTMain.Domains.Adapters.SR
import CATEPTMain.Bridges.CrossDomainCompat
import CATEPTMain.Domains.SubstrateProjections
import CATEPTMain.Domains.JointAdapter
import CATEPTMain.Domains.UnifiedConstraints
import CATEPTMain.Domains.UnifiedConstraintsSubstrate
import CATEPTMain.Integration.SubstrateBellBridge
import CATEPTMain.Integration.SubstrateBackedSpacetimeAxioms
import CATEPTMain.Integration.SubstrateAssumptionTags
import CATEPTMain.Integration.MaxwellCurveSpacePphi2Bridge
import CATEPTMain.Domains.Adapters.MaxwellCurveSpace
import CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags
-- T90 plugin batch (13 sibling plugins, audit-gate inclusion):
import CATEPTMain.Integration.QuantumInfoBridge
import CATEPTMain.Integration.SpectralPhysicsBridge
import CATEPTMain.Integration.BochnerMinlosBridge
import CATEPTMain.Integration.GibbsMeasureBridge
import CATEPTMain.Integration.HopfLeanBridge
import CATEPTMain.Integration.KolmogorovComplexityBridge
import CATEPTMain.Integration.CarlesonBridge
import CATEPTMain.Integration.CslibBridge
import CATEPTMain.Integration.GaussianFieldLogSobolevBridge
import CATEPTMain.Integration.DeGiorgiBridge
import CATEPTMain.Integration.ThermodynamicsLeanBridge
import CATEPTMain.Integration.VMLLandauBridge
import CATEPTPluginBTCompat.IntegrationBridge
import CATEPTMain.Integration.EntropicProperTimeCoreBridge
import CATEPTMain.Integration.PathIntegralBenchmarksBridge
import CATEPTMain.Integration.GeneratingFunctionalCalculus
import CATEPTMain.Integration.OscillatorKernel
import CATEPTMain.Integration.RenormalizationGroup
import CATEPTMain.Integration.InstantonTunneling
import CATEPTMain.Domains.UnifiedConstraintsGaugeGeometry
import CATEPTMain.Domains.UnifiedConstraintsEMDuality
import CATEPTMain.Domains.UnifiedConstraintsCoupling

/-!
# Coherence Spine + UnifiedValidator — Kernel-Axiom Showcase

Inline `#print axioms` audit for the three adapters, the coherence-spine
theorem, AND the per-adapter unified-validator instances (T66).

Expected (every line on `[propext, Classical.choice, Quot.sound]`):

  Spine theorems (T65):
    minkowski_satisfies_spine
    em_satisfies_spine
    vml_satisfies_spine
    coherence_spine_GR_EM_VML
    live_dynamics_EM_VML

  Per-invariant adapter claims (T66e):
    minkowski_conservation / _reduction / _symmetry / _quantum_correspondence
    em_conservation / em_reduction / em_symmetry  (μ₀=1, hμ₀=one_pos applied below)
    vml_conservation / vml_reduction / vml_symmetry

  Unified validators (T66f):
    minkowski_validates  — spine + 4 invariants (vacuum tier)
    em_validates         — spine + 3 invariants (no quantum-correspondence)
    vml_validates        — spine + 3 invariants (no quantum-correspondence)

Any axiom outside `[propext, Classical.choice, Quot.sound]` is a regression.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal

open Adapter

-- ── Concrete UnifiedValidator instances (one per adapter) ────────────

/-- Minkowski validates against ALL four invariants (vacuum tier). -/
theorem minkowski_validates :
    UnifiedValidator
      minkowski
      (some minkowski_conservation)
      (some minkowski_reduction)
      (some minkowski_symmetry)
      (some minkowski_quantum_correspondence) :=
  UnifiedValidator.full
    minkowski
    minkowski_conservation
    minkowski_reduction
    minkowski_symmetry
    minkowski_quantum_correspondence

/-- EM validates against three invariants (Conservation/Reduction/
    Symmetry); QuantumCorrespondence not claimed. -/
theorem em_validates (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    UnifiedValidator
      (em μ₀ hμ₀)
      (some <| em_conservation μ₀ hμ₀)
      (some <| em_reduction μ₀ hμ₀)
      (some <| em_symmetry μ₀ hμ₀)
      none :=
  ⟨(em μ₀ hμ₀).coherence_spine,
   (em_conservation μ₀ hμ₀).divergence_free,
   (em_reduction μ₀ hμ₀).reduces_classically,
   (em_symmetry μ₀ hμ₀).clock_invariant,
   trivial⟩

/-- VML validates against three invariants; QuantumCorrespondence not
    claimed (the bridge requires QM machinery beyond the current scope). -/
theorem vml_validates :
    UnifiedValidator
      vml
      (some vml_conservation)
      (some vml_reduction)
      (some vml_symmetry)
      none :=
  ⟨vml.coherence_spine,
   vml_conservation.divergence_free,
   vml_reduction.reduces_classically,
   vml_symmetry.clock_invariant,
   trivial⟩

end CATEPTMain.Temporal

-- ═══════════════════════════════════════════════════════════════════════
-- KERNEL-AXIOM AUDIT
-- ═══════════════════════════════════════════════════════════════════════

-- Spine theorems (T65, retained):
#print axioms CATEPTMain.Temporal.Adapter.minkowski_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.em_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.vml_satisfies_spine
#print axioms CATEPTMain.Temporal.coherence_spine_GR_EM_VML
#print axioms CATEPTMain.Temporal.live_dynamics_EM_VML

-- Per-invariant adapter claims (T66e):
#print axioms CATEPTMain.Temporal.Adapter.minkowski_conservation
#print axioms CATEPTMain.Temporal.Adapter.minkowski_reduction
#print axioms CATEPTMain.Temporal.Adapter.minkowski_symmetry
#print axioms CATEPTMain.Temporal.Adapter.minkowski_quantum_correspondence
#print axioms CATEPTMain.Temporal.Adapter.em_conservation
#print axioms CATEPTMain.Temporal.Adapter.em_reduction
#print axioms CATEPTMain.Temporal.Adapter.em_symmetry
#print axioms CATEPTMain.Temporal.Adapter.vml_conservation
#print axioms CATEPTMain.Temporal.Adapter.vml_reduction
#print axioms CATEPTMain.Temporal.Adapter.vml_symmetry

-- UnifiedValidator instances (T66f):
#print axioms CATEPTMain.Temporal.minkowski_validates
#print axioms CATEPTMain.Temporal.em_validates
#print axioms CATEPTMain.Temporal.vml_validates

-- HarmonicOscillator adapter (T68 — full-stack live demo):
--   FIRST adapter to claim a non-vacuum QuantumCorrespondence
--   (curvature = expectationValue = H, G = 1/(8π) so 8πG = 1).
#print axioms CATEPTMain.Temporal.Adapter.harmonic_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.harmonic_conservation
#print axioms CATEPTMain.Temporal.Adapter.harmonic_reduction
#print axioms CATEPTMain.Temporal.Adapter.harmonic_symmetry
#print axioms CATEPTMain.Temporal.Adapter.harmonic_quantum_correspondence
#print axioms CATEPTMain.Temporal.Adapter.harmonic_validates
#print axioms CATEPTMain.Temporal.Adapter.harmonic_dynamics_nontrivial

-- Kinetic adapter (T69 — Maxwell-Boltzmann velocity space):
#print axioms CATEPTMain.Temporal.Adapter.kinetic_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.kinetic_validates
#print axioms CATEPTMain.Temporal.Adapter.kinetic_dynamics_nontrivial

-- Higgs adapter (T69 — Mexican-hat vacuum, Z₂ symmetry, live tier):
#print axioms CATEPTMain.Temporal.Adapter.higgs_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.higgs_validates

-- Herglotz adapter (T69 kernel + T70 live tier — damped classical oscillator):
#print axioms CATEPTMain.Temporal.Adapter.herglotz_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.herglotz_validates
#print axioms CATEPTMain.Temporal.Adapter.herglotzLive

-- BohmianEM adapter (T73 — minimally-coupled Bohmian, displaced Gaussian).
--   First reflection-through-a-point symmetry witness `σ : v ↦ 2·A_bg − v`.
#print axioms CATEPTMain.Temporal.Adapter.bohmianEM_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.bohmianEM_validates
#print axioms CATEPTMain.Temporal.Adapter.bohmianEM_dynamics_nontrivial

-- QM density-matrix adapter (T70 — von Neumann entropy clock, kernel tier):
--   Wraps `qmSuperiorSlot n` (catept-domain-quantum sibling) as a
--   `TemporalFramework`. Phase-1 entropy returns 0 so live tier deferred.
#print axioms CATEPTMain.Temporal.Adapter.qm_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.qm_validates

-- SR adapter (T77 — first Physlib-backed slot, kernel tier).
--   Clock = SpaceTime.properTime q p  (Physlib.Relativity.Special.ProperTime).
--   Non-negativity by Real.sqrt_nonneg.
#print axioms CATEPTMain.Temporal.Adapter.sr_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.sr_validates
#print axioms CATEPTMain.Domains.SR.srSuperiorSlot_clock_pos_of_timeLike

-- Cross-domain Logos-style "compiler-is-the-comparator" bridges
-- (T71 — rework proposal step 2, the highest-payoff piece).
-- Every theorem here proved by `rfl` on both sides — no domain-specific
-- tactic, no unfolding, no `simp`. The bridge cost is the cost of `rfl`.
#print axioms CATEPTMain.Bridges.CrossDomain.superiorSlot_actionIm_eq_eptClock
#print axioms CATEPTMain.Bridges.CrossDomain.qm_herglotz_clock_compat
#print axioms CATEPTMain.Bridges.CrossDomain.qm_higgs_clock_compat
#print axioms CATEPTMain.Bridges.CrossDomain.kinetic_higgs_clock_compat
#print axioms CATEPTMain.Bridges.CrossDomain.any_finite_collection_of_slots_compatible

-- Relational-Information Substrate (T78 — ontological floor).
--   Cherry-picked substrate kernel + leverage demo: every existing
--   TemporalFramework adapter is a substrate projection.
#print axioms CATEPTMain.Integration.RelationalInformationSubstrate.toTemporalFramework_coherence
#print axioms CATEPTMain.Integration.RelationalInformationSubstrate.toLiveTemporalFramework_coherence
#print axioms CATEPTMain.Integration.RelationalInformationSubstrate.tauEnt_nonneg
#print axioms CATEPTMain.Domains.SubstrateProjections.harmonic_is_substrate_projection
#print axioms CATEPTMain.Domains.SubstrateProjections.harmonicSubstrate_satisfies_spine

-- Joint adapter (T79 — QM ⊕ GR ⊕ Maxwell unification).
--   The CATEPT spine is closed under arbitrary finite joins:
--   any combination of TemporalFramework adapters is itself a
--   TemporalFramework with the spine identification holding for free.
--   The maxwellGRQM TF demonstrates the headline composition.
#print axioms CATEPTMain.Temporal.Adapter.joint_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.maxwellGRQM_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.maxwellGRQM_clock_decomposition

-- Unified-Theory Constraints (T80 — discharges 7 of 11 Copilot-doc invariants).
--   Source: /Users/macbookpro/Downloads/copilot-md-docs/Copilot-Copilot_Chat_TwyFkfsi.md
--   Headline: catept_discharges_seven_of_eleven (CT, MG, R, C, S, QC + structural).
#print axioms CATEPTMain.Domains.UnifiedConstraints.classicalQuantum_discharged
#print axioms CATEPTMain.Domains.UnifiedConstraints.matterGeometry_discharged_of_qc
#print axioms CATEPTMain.Domains.UnifiedConstraints.reduction_discharged_of_R
#print axioms CATEPTMain.Domains.UnifiedConstraints.conservation_discharged_of_C
#print axioms CATEPTMain.Domains.UnifiedConstraints.symmetry_discharged_of_S
#print axioms CATEPTMain.Domains.UnifiedConstraints.qc_discharged_of_Q
#print axioms CATEPTMain.Domains.UnifiedConstraints.catept_discharges_seven_of_eleven

-- Substrate-backed discharges (T81 — lifts T80 placeholders 1, 3 to honest theorems).
#print axioms CATEPTMain.Domains.UnifiedConstraints.waveParticleDualityAtSubstrate_holds
#print axioms CATEPTMain.Domains.UnifiedConstraints.localGlobalDualityAtSubstrate_holds
#print axioms CATEPTMain.Domains.UnifiedConstraints.catept_substrate_discharges_two_more

-- Extended substrate projections (T82-mine — generic constructor + 9 named witnesses).
--   Single ofTemporalFramework_projects_to_self proves all per-adapter cases via div_one.
#print axioms CATEPTMain.Domains.SubstrateProjections.ofTemporalFramework_projects_to_self
#print axioms CATEPTMain.Domains.SubstrateProjections.minkowski_is_substrate_projection
#print axioms CATEPTMain.Domains.SubstrateProjections.em_is_substrate_projection
#print axioms CATEPTMain.Domains.SubstrateProjections.vml_is_substrate_projection
#print axioms CATEPTMain.Domains.SubstrateProjections.kinetic_is_substrate_projection
#print axioms CATEPTMain.Domains.SubstrateProjections.higgs_is_substrate_projection
#print axioms CATEPTMain.Domains.SubstrateProjections.herglotz_is_substrate_projection
#print axioms CATEPTMain.Domains.SubstrateProjections.bohmianEM_is_substrate_projection
#print axioms CATEPTMain.Domains.SubstrateProjections.qm_is_substrate_projection
#print axioms CATEPTMain.Domains.SubstrateProjections.sr_is_substrate_projection

-- Substrate-to-Bell adapter (T83-mine — architecture note Target C).
--   Substrate-side no-signaling discharge; Bell math stays in NoFTLBellBridge.
#print axioms CATEPTMain.Integration.SubstrateBell.SubstrateBellSource.substrate_alice_bob_no_signaling
#print axioms CATEPTMain.Integration.SubstrateBell.SubstrateBellSource.substrate_pair_delay_bounded
#print axioms CATEPTMain.Integration.SubstrateBell.SubstrateBellSource.substrate_local_frame_measurement
#print axioms CATEPTMain.Integration.SubstrateBell.SubstrateBellSource.alice_frame_owner
#print axioms CATEPTMain.Integration.SubstrateBell.SubstrateBellSource.bob_frame_owner

-- Final 3 Copilot-doc invariants (T82-T84 from parallel helper b1d9296d8).
--   Substrate-backed discharges of T80 placeholders #2, #5, #10.
--   Author: GitHub Copilot (Claude Opus 4.7) <copilot-claude@anthropic.local>.
--   Cherry-picked into integrated history; original branch
--   feat/copilot-claude/t82-t84-invariants on origin until cleanup.
#print axioms CATEPTMain.Domains.UnifiedConstraints.gaugeGeometryDualityAtJoint_holds
#print axioms CATEPTMain.Domains.UnifiedConstraints.gaugeGeometryDuality_factor_decomposition
#print axioms CATEPTMain.Domains.UnifiedConstraints.electricMagneticDualityAtEM_holds
#print axioms CATEPTMain.Domains.UnifiedConstraints.emDualityInvolution_nontrivial
#print axioms CATEPTMain.Domains.UnifiedConstraints.emDualityInvolution_involutive
#print axioms CATEPTMain.Domains.UnifiedConstraints.couplingConstraintAtBohmianEM_holds

-- Substrate-backed spacetime axioms (T85 — architecture note Target B).
--   Replaces CATEPTSpacetimeModel's `True` placeholders with substantive
--   substrate-derived ∀-statements. Original placeholders preserved for
--   backward compat; this is the principled upgrade path.
#print axioms CATEPTMain.Integration.SubstrateBackedSpacetimeAxioms.fromSubstrate
#print axioms CATEPTMain.Integration.SubstrateBackedSpacetimeAxioms.noFTL_propagation_bound_pos
#print axioms CATEPTMain.Integration.SubstrateBackedSpacetimeAxioms.ept_causal_arrow_strict_at_pair
#print axioms CATEPTMain.Integration.CATEPTSpaceTime.SubstrateSpacetimeProjection.substrateBackedAxioms
#print axioms CATEPTMain.Integration.CATEPTSpaceTime.SubstrateSpacetimeProjection.substrateBackedAxioms_noFTL_pos

-- Substrate-facing assumption tags (T86 — architecture note Target E).
--   Three new substrate.* AssumptionIds + retrofit of entropicTimeDefinition.
#print axioms CATEPTMain.Integration.SubstrateAssumptionTags.substrate_tauEnt_def
#print axioms CATEPTMain.Integration.SubstrateAssumptionTags.substrateCausalIsMinkowskiFuture_tag
#print axioms CATEPTMain.Integration.SubstrateAssumptionTags.substratePhaseIsQuantumPhase_tag
#print axioms CATEPTMain.Integration.SubstrateAssumptionTags.substrateNotificationIsQuantumChannel_tag
#print axioms CATEPTMain.Integration.SubstrateAssumptionTags.substrate_assumption_tags_discharge

-- Substrate-backed entropic-time / spacetime compatibility (T87 — Target D).
--   Discharges the Phase-2 comment on
--   `entropicProperTimeCore_spacetime_compatible : True` with substantive
--   content packaged from T78 (`tauEnt_nonneg`) + T85
--   (`SubstrateBackedSpacetimeAxioms`). Original trivial theorem
--   preserved unchanged for back-compat.
#print axioms CATEPTMain.Integration.EntropicProperTimeCore.entropicProperTimeCore_model_compatible_strong
#print axioms CATEPTMain.Integration.EntropicProperTimeCore.entropicProperTimeCore_spacetime_compatible_substrate

-- Maxwell-CurveSpace-Pphi2 plugin (T88 — first curved-spacetime adapter).
--   Source: catept-plugin-maxwell-curvespace-pphi2 sibling repo.
--   Provides Osterwalder-Schrader reconstruction interface for
--   curved-space Maxwell QFT — the QFT hook in the spine surface.
#print axioms CATEPTMain.Integration.catEpt_maxwell_curveSpace_pphi2_bridge

-- Maxwell-CurveSpace TemporalFramework adapter (T88 — 11th adapter).
--   First curved-spacetime adapter; clock = curvature + maxwell + coupling.
#print axioms CATEPTMain.Temporal.Adapter.maxwellCurveSpace_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.maxwellCurveSpace_validates

-- AssumptionId retrofits via the plugin's Pphi2IntegrationWitness fields
-- (T88 — moves 3 dead OS-reconstruction ids to referenced).
#print axioms CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags.os0_analyticity_tag
#print axioms CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags.reflection_positivity_tag
#print axioms CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags.has_reconstruction_tag

-- 4-way joint TemporalFramework (T89 — QM ⊕ GR ⊕ Maxwell-flat ⊕ Maxwell-curved).
--   Builds on T79 maxwellGRQM by adding the T88 curved-spacetime layer.
--   Spine identification holds free via coherence_spine; clock decomposes
--   pointwise into a 4-way sum.
#print axioms CATEPTMain.Temporal.Adapter.maxwellGRQMcurved_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.maxwellGRQMcurved_clock_decomposition

-- Path-integral benchmark ladder (T88-jag — Stages 1+3 and Stage 4 of
-- REPLYID:20260427-PI-NORM-RENORM-01, author Jorge A. Garcia). Honest
-- algebraic identities for the FK-damping composition law (free-
-- particle / oscillator composition at the weight level) and the
-- Euclidean harmonic-oscillator partition closed form
-- Z(β) = 1/(2 sinh(βℏω/2)) via finite geometric sum + sinh identity.
-- Stages 2/5/6/7/8 deferred (require new infrastructure).
#print axioms CATEPTMain.Integration.PathIntegralBenchmarks.fk_damping_composition
#print axioms CATEPTMain.Integration.PathIntegralBenchmarks.fk_damping_at_zero
#print axioms CATEPTMain.Integration.PathIntegralBenchmarks.fk_damping_semigroup
#print axioms CATEPTMain.Integration.PathIntegralBenchmarks.harmonicOscillator_partition_sinh_form
#print axioms CATEPTMain.Integration.PathIntegralBenchmarks.harmonicOscillator_partition_finite
#print axioms CATEPTMain.Integration.PathIntegralBenchmarks.harmonicOscillator_partition_matches_sinh_finite

-- ═══════════════════════════════════════════════════════════════════════
-- T90 plugin batch — audit-gate inclusion for 13 sibling plugins
-- ═══════════════════════════════════════════════════════════════════════
-- Methodology equivalent to T88-claude (Maxwell-CurveSpace-Pphi2): bring
-- each plugin's representative theorem(s) under CI protection.
-- AFP-framework intentionally skipped (its content is axiom-style
-- opaque-symbol infrastructure, not theorems with kernel proofs).

-- catept-plugin-quantum-info — quantum-information integration contract.
#print axioms CATEPTPluginQuantumInfo.quantumInfo_integration_contract

-- catept-plugin-spectral-physics — spectral gap, Laplacian self-adjoint, PSD.
#print axioms CATEPTPluginSpectralPhysics.proved_spectral_gap_pos
#print axioms CATEPTPluginSpectralPhysics.proved_laplacian_self_adjoint
#print axioms CATEPTPluginSpectralPhysics.proved_laplacian_pos_semidef

-- catept-plugin-bochner-minlos — Bochner-Minlos cylindrical-measure bridge.
#print axioms CATEPTPluginBochnerMinlos.bochnerMinlos_integration_contract

-- catept-plugin-gibbs-measure — Gibbs ensemble integration contract.
#print axioms CATEPTPluginGibbsMeasure.gibbsMeasure_integration_contract

-- catept-plugin-hopf-lean — Hopf-algebra/Lean integration contract.
#print axioms CATEPTPluginHopfLean.hopfLean_integration_contract

-- catept-plugin-kolmogorov-complexity — algorithmic-information bridge.
#print axioms CATEPTPluginKolmogorovComplexity.kolmogorovComplexity_integration_contract

-- catept-plugin-carleson — abstract Carleson + concrete witness contracts.
#print axioms CATEPTPluginCarleson.carleson_integration_contract
#print axioms CATEPTPluginCarleson.concrete_witness_contract

-- catept-plugin-cslib — Cslib (concurrency / shared logic) integration.
#print axioms CATEPTPluginCslib.cslib_integration_contract

-- catept-plugin-gaussian-field-lsi — log-Sobolev / Poincaré inequalities.
#print axioms CATEPTPluginGaussianFieldLSI.proved_gross_log_sobolev
#print axioms CATEPTPluginGaussianFieldLSI.proved_log_sobolev_1d
#print axioms CATEPTPluginGaussianFieldLSI.discrete_poincare_from_spectral_gap

-- catept-plugin-degiorgi — De Giorgi nascent smoothness + approximation.
#print axioms CATEPTPluginDeGiorgi.proved_gns_smooth
#print axioms CATEPTPluginDeGiorgi.proved_gns_approx
#print axioms CATEPTPluginDeGiorgi.proved_poincare_unitBall

-- catept-plugin-thermodynamics-lean — thermodynamic identities bridge.
#print axioms CATEPTPluginThermodynamicsLean.thermodynamicsLean_integration_contract

-- catept-plugin-bt-compat — relativistic Brillet–Tisserand kinematics
-- (no shim file in catept-main; imported directly from the plugin namespace).
#print axioms CATEPTPluginBTCompat.btInvariantEnergySq_at_rest
#print axioms CATEPTPluginBTCompat.btDopplerFactor_at_rest
#print axioms CATEPTPluginBTCompat.btObservedFrequency_at_rest

-- catept-plugin-vml-landau — VML Landau collision content marker.
#print axioms CATEPTPluginVMLLandau.vml_landau_content_available

-- Generating-functional / source-term calculus (T-B Phase 1 / Stage 5 of
-- REPLYID:20260427-PI-NORM-RENORM-01). Honest algebraic identities on the
-- closed-form Gaussian charFun Z[J] = exp(iJμ - J²σ²/2): normalization
-- Z[0]=1, centered form Z[J] = exp(-½J²σ²), and the independence
-- semigroup Z₁[J]·Z₂[J] = Z₁₊₂[J] (W[J] = log Z[J] additivity for
-- independent Gaussian contributions to the connected generating
-- functional). Multi-point correlators (Wick / δⁿZ/δJⁿ) and the Minlos
-- extension to nuclear-space white-noise field measures deferred.
#print axioms CATEPTMain.Integration.GeneratingFunctionalCalculus.gaussianCharFun_at_zero
#print axioms CATEPTMain.Integration.GeneratingFunctionalCalculus.gaussianCharFun_centered
#print axioms CATEPTMain.Integration.GeneratingFunctionalCalculus.gaussianCharFun_independence_semigroup

-- Oscillator kernels / Mehler propagator (T-A Phase 1 / path-integral
-- ladder). Honest algebraic identities on the Euclidean Mehler-kernel
-- exponent S(x,y;t) and squared prefactor N²:
--   * exponent symmetry  S(x,y;t) = S(y,x;t),
--   * closed form at the spatial diagonal x = y,
--   * prefactor positivity  N² > 0 for m,ω,t > 0.
-- t→0 delta limit and Trotter composition K(t₁+t₂) = ∫ K(t₁) K(t₂)
-- deferred (require Gaussian-integral infrastructure).
#print axioms CATEPTMain.Integration.OscillatorKernel.mehlerExponent_symm
#print axioms CATEPTMain.Integration.OscillatorKernel.mehlerExponent_at_diagonal
#print axioms CATEPTMain.Integration.OscillatorKernel.mehlerPrefactorSq_pos

-- T-E Phase 1 (renormalization-group apparatus, fifth rung of the path-integral
-- leverage ladder). Honest algebraic identities on the one-loop running
-- coupling g(t) = g₀ / (1 + b·g₀·t):
--   * initial condition  g(0) = g₀,
--   * RG-invariant linear law  1/g(t) = 1/g₀ + b·t,
--   * RG semigroup  g_t ∘ g_s = g_{s+t}  (Wilson-flow composition).
-- Underlying ODE  dg/dt = -b·g²  and multi-coupling matrix RGEs
-- deferred (require ODE-uniqueness / matrix-flow infrastructure).
#print axioms CATEPTMain.Integration.RenormalizationGroup.oneLoopRunning_at_zero
#print axioms CATEPTMain.Integration.RenormalizationGroup.oneLoopRunning_inverse_linear
#print axioms CATEPTMain.Integration.RenormalizationGroup.oneLoopRunning_semigroup

-- T-D Phase 1 (instanton / tunneling amplitude algebra, sixth rung of the
-- path-integral leverage ladder). Honest algebraic identities on the BPST
-- instanton action S_inst(g) = 8·π²/g² and tunneling amplitude A(S) = exp(-S):
--   * trivial sector  A(0) = 1,
--   * dilute-gas composition  A(S₁+S₂) = A(S₁)·A(S₂)  (n-instanton product),
--   * BPST-action positivity  S_inst(g) > 0  for g ≠ 0.
-- Gel'fand-Yaglom det' / Coleman-Callan bounce / topological-charge
-- integrality deferred (require spectral theory and 4-form integration).
#print axioms CATEPTMain.Integration.InstantonTunneling.tunnelAmplitude_at_zero
#print axioms CATEPTMain.Integration.InstantonTunneling.tunnelAmplitude_compose
#print axioms CATEPTMain.Integration.InstantonTunneling.instantonBPSTAction_pos
