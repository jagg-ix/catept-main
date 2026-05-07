import CATEPTMain.Domains.CoherenceSpine
import CATEPTMain.Domains.UnifiedValidator
import CATEPTMain.Domains.Adapters.HarmonicOscillator
import CATEPTMain.Domains.Adapters.Kinetic
import CATEPTMain.Domains.Adapters.Higgs
import CATEPTMain.Domains.Adapters.Herglotz
import CATEPTMain.Domains.Adapters.QM
import CATEPTMain.Domains.Adapters.QMLive
import CATEPTMain.Domains.Adapters.BohmianEM
import CATEPTMain.Domains.Adapters.SR
import CATEPTMain.Bridges.CrossDomainCompat
import CATEPTMain.Domains.SubstrateProjections
import CATEPTMain.Domains.JointAdapter
import CATEPTMain.Domains.UnifiedConstraints
import CATEPTMain.Domains.UnifiedConstraintsSubstrate
import CATEPTMain.Integration.SubstrateBellBridge
import CATEPTMain.Integration.ConstructorInformationSubstrate
import CATEPTMain.Integration.ConcreteSubstrateExample
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
import CATEPTMain.Integration.AbstractWitnessContracts.BTCompat
import CATEPTMain.Integration.EntropicProperTimeCoreBridge
import CATEPTMain.Integration.PathIntegralBenchmarksBridge
import CATEPTMain.Integration.GeneratingFunctionalCalculus
import CATEPTMain.Integration.OscillatorKernel
import CATEPTMain.Integration.RenormalizationGroup
import CATEPTMain.Integration.InstantonTunneling
import CATEPTMain.Integration.FeynmanDiagrams
import CATEPTMain.Integration.ConnesKreimerLadder
import CATEPTMain.Integration.ConnesKreimerAntipode
import CATEPTMain.Integration.OneLoopBPHZOnShell
import CATEPTMain.Integration.OneLoopBPHZCubic
import CATEPTMain.Integration.GelfandYaglomJacobi
import CATEPTMain.Integration.GelfandYaglomDeriv
import CATEPTMain.Integration.GelfandYaglomDetRatio
import CATEPTMain.Integration.GelfandYaglomAsymptotics
import CATEPTMain.Integration.GelfandYaglomPartition
import CATEPTMain.Integration.GelfandYaglomPartitionPos
import CATEPTMain.Integration.GelfandYaglomInversionAPI
import CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge
import CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge
import CATEPTMain.Integration.SimplexPathIntegralNoRenormBridgeMulti
import CATEPTMain.Integration.EntropicCoercivityToUVCertificate
import CATEPTMain.Integration.ComplexWeightNormEntropicDamping
import CATEPTMain.Integration.RigorousComplexFeynmanKac
import CATEPTMain.Integration.CountertermFreeAbsoluteConvergence
import CATEPTMain.Integration.EntropicActionPositivity
import CATEPTMain.Integration.EntropicCoercivityFromViscousDissipation
import CATEPTMain.Integration.EntropicCoercivityFromFisherInformation
import CATEPTMain.Integration.EntropicCoercivityFromPalinstrophy
import CATEPTMain.Integration.EntropicCoercivityFromEntropyProduction
import CATEPTMain.Integration.EntropicCoercivityFromModularHamiltonian
import CATEPTMain.Geometry.FiniteMinkowski
import CATEPTMain.Geometry.EntropicLapse
import CATEPTMain.Integration.QFTCurvedTemporalSpine
import CATEPTMain.Integration.CATEPTSTAdapter
import CATEPTMain.Integration.MISNoFTLBridge
import CATEPTMain.Integration.SpacetimeHarvestCatalog
import CATEPTMain.Integration.PhysicalUVConvergenceCertificate
import CATEPTMain.Integration.CanonicalEntropicModel
import CATEPTMain.Integration.StokesEntropicModel
import CATEPTMain.Integration.UVCertificateFailureModes
import CATEPTMain.Integration.SpectralSumPartition
import CATEPTMain.Integration.RealSpectralEntropicModel
import CATEPTMain.Integration.T3SpectralPartition
import CATEPTMain.Integration.T3TailBound
import CATEPTMain.Integration.LatticeActionDerivation
import CATEPTMain.Integration.T3PhysicalEntropicModel
import CATEPTMain.Integration.ParametricLatticeAction
import CATEPTMain.Integration.HigherDegreeLatticeAction
import CATEPTMain.Integration.HigherDegreeT3Tail
import CATEPTMain.Integration.HigherDegreeT3TailSharp
import CATEPTMain.Integration.EntropicGreenFunctionBridge
-- LaplaceTransformBridge import removed (Category-A axiom sweep retired
-- the AFP-port-stub module; this showcase no longer depends on it).
import CATEPTMain.Integration.EntropicGreenFromHeatSemigroup
import CATEPTMain.Integration.GreenDampingUVChain
import CATEPTMain.Integration.GreenDampingUVChainMultimode
import CATEPTMain.Integration.SpectralTermHeatModeBridge
import CATEPTMain.Integration.EntropicTimeIntegralStateDependent
import CATEPTMain.Integration.FisherLawvereEventCostBridge
import CATEPTMain.Integration.ImaginaryActionDissipationDictionary
import CATEPTMain.Integration.TolmanDissipationRedshiftBridge
import CATEPTMain.Integration.KMSModularParameterBridge
import CATEPTMain.Integration.RelativeEntropyProductionBridge
import CATEPTMain.Integration.GKSLInformationExchangeBridge
import CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge
import CATEPTMain.Integration.MixedBracketCompatibilityPhase2
import CATEPTMain.Integration.FujikawaCATEPTBridge
import CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge
import CATEPTMain.Integration.CATEPTSheafGluingPhase2
import CATEPTMain.Integration.YamasakiInternalClockBridge
import CATEPTMain.Integration.RelativeEntropyModularBridge
import CATEPTMain.Integration.WDWRQMRelationalTimeContracts
import CATEPTMain.Integration.WDWRQMPhaseMutualInfoContracts
import CATEPTMain.Integration.WDWRQMNoetherContracts
import CATEPTMain.Integration.WDWRQMUncertaintyContracts
import CATEPTMain.Integration.NonHermitianQuantumCAT
import CATEPTMain.Integration.QuantumTemporalOrderEnergyCAT
import CATEPTMain.Integration.ContactDynamicsCAT
import CATEPTMain.Integration.StochasticEntropyIntegrationBridge
import CATEPTMain.Integration.CATEPTMeasureTheorem
import CATEPTMain.Integration.EtaSpectralDensityCarrier
import CATEPTMain.Integration.EtaSpectralDensityCarrierPhase2
import CATEPTMain.Integration.TensorNetworkPathIntegralCarrier
import CATEPTMain.Integration.ComplexTimePathIntegralCarrier
import CATEPTMain.Integration.GRQMPathIntegralUnifyBridge
import CATEPTMain.Integration.QEDRepresentationStability
import CATEPTMain.Integration.OpenSystemMasterEquationCarrier
import CATEPTMain.Integration.PerturbativeApproximationCarrier
import CATEPTMain.Integration.NSSpaceQIFConsistencyBridge
import CATEPTMain.Integration.MaxwellWaveCATEPTSpaceTimeBridge
import CATEPTMain.Integration.VMLEntropicEquilibriumBridge
import CATEPTMain.Integration.GoalsABPhase3Closures
import CATEPTMain.Integration.MaxwellCurveSpaceDampingPhase3
import CATEPTMain.Integration.ReducedModularChannelCarrier
import CATEPTMain.Integration.PowerHierarchyCarrier
import CATEPTMain.Integration.FivePaperUnifiedHierarchy
import CATEPTMain.Integration.ContinuousEntropicUncertaintyCarrier
import CATEPTMain.Integration.StringWorldsheetTemporalBridge
import CATEPTMain.Integration.StringEffectiveQFTSpineBridge
import CATEPTMain.Integration.BounceStationarity
import CATEPTMain.Integration.TopologicalChargeIntegrality
import CATEPTMain.Integration.CutkoskyDiscontinuity
import CATEPTMain.Integration.BPHZForestLadder
import CATEPTMain.Integration.ColemanCallanDiluteGas
import CATEPTMain.Integration.TopologicalChargeCohomology
import CATEPTMain.Integration.CutkoskyBranchCut
import CATEPTMain.Integration.CKBirkhoffLadder
import CATEPTMain.Integration.GaussianCompletion
import CATEPTMain.Integration.FreeParticleAction
import CATEPTMain.Integration.FreeParticleSaddle
import CATEPTMain.Integration.FreeParticlePropagator
import CATEPTMain.Integration.FreeParticlePropagatorNFold
import CATEPTMain.Integration.SchwingerSourceShift
import CATEPTMain.Integration.MultiModeGaussianCompletion
import CATEPTMain.Integration.ShiftedGaussianIntegral
import CATEPTMain.Integration.SourcedGaussianIntegral
import CATEPTMain.Integration.MultiModeSourcedGaussian
import CATEPTMain.Integration.ZJRatio
import CATEPTMain.Integration.LogZJRatio
import CATEPTMain.Integration.PropagatorScalar
import CATEPTMain.Integration.PropagatorMultimode
import CATEPTMain.Integration.PropagatorEntropicTime
import CATEPTMain.Integration.HeatSemigroupEntropicTime
import CATEPTMain.Integration.HeatIntegralEntropicTime
import CATEPTMain.Integration.HeatSemigroupLaw
import CATEPTMain.Integration.SourcedHeatIntegral
import CATEPTMain.Integration.ShiftedHeatIntegral
import CATEPTMain.Domains.UnifiedConstraintsGaugeGeometry
import CATEPTMain.Domains.UnifiedConstraintsEMDuality
import CATEPTMain.Domains.UnifiedConstraintsCoupling
import CATEPTMain.Domains.SuperiorMethodAssumptionTags
import CATEPTMain.Integration.FoundationsAssumptionTags
import CATEPTMain.Integration.FisherRaoLawvereAssumptionTags
import CATEPTMain.Integration.SpectralPhysicsAssumptionTags
-- T101 unblocked T100: PhysicalConstants now lives in
-- PhysicalConstantsCommon (single canonical definition); importing
-- NoetherEPTAssumptionTags no longer collides.
import CATEPTMain.Integration.NoetherEPTAssumptionTags

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

-- Non-vacuum QuantumCorrespondence for EM and Higgs (T91 — Group A1+A2).
--   Same algebraic shape as T68 HarmonicOscillator: curvature =
--   expectationValue = clock, G = 1/(8π) so 8πG = 1.
#print axioms CATEPTMain.Temporal.Adapter.em_quantum_correspondence
#print axioms CATEPTMain.Temporal.Adapter.higgs_quantum_correspondence

-- Non-vacuum QuantumCorrespondence sweep continued (T94 — same pattern).
--   Brings non-vacuum QC count from 3 to 6 of 11 adapters.
#print axioms CATEPTMain.Temporal.Adapter.kinetic_quantum_correspondence
#print axioms CATEPTMain.Temporal.Adapter.herglotz_quantum_correspondence
#print axioms CATEPTMain.Temporal.Adapter.bohmianEM_quantum_correspondence

-- Final non-vacuum QC sweep — 10/11 adapters covered (T95).
--   Only Minkowski remains intentionally vacuum-tier.
#print axioms CATEPTMain.Temporal.Adapter.vml_quantum_correspondence
#print axioms CATEPTMain.Temporal.Adapter.qm_quantum_correspondence
#print axioms CATEPTMain.Temporal.Adapter.sr_quantum_correspondence
#print axioms CATEPTMain.Temporal.Adapter.maxwellCurveSpace_quantum_correspondence

-- Joint QC composition (T96 — Group A3, all-but-Minkowski now have non-vacuum QC).
--   Generic `joint_quantum_correspondence` composes any two QCs with
--   matching `G`; specialised to maxwellGRQM (3-way) and
--   maxwellGRQMcurved (4-way) with G = 1/(8π) throughout.
#print axioms CATEPTMain.Temporal.Adapter.joint_quantum_correspondence
#print axioms CATEPTMain.Temporal.Adapter.minkowski_quantum_correspondence_unitPrefactor
#print axioms CATEPTMain.Temporal.Adapter.maxwellGRQM_quantum_correspondence
#print axioms CATEPTMain.Temporal.Adapter.maxwellGRQMcurved_quantum_correspondence

-- Joint composition of Conservation/Reduction/Symmetry (T97 — generic).
#print axioms CATEPTMain.Temporal.Adapter.joint_conservation
#print axioms CATEPTMain.Temporal.Adapter.joint_reduction
#print axioms CATEPTMain.Temporal.Adapter.joint_symmetry

-- ★ HEADLINE: full UnifiedValidator on the joint TFs (T97).
--   Each claims spine + all 4 invariants in one theorem.
--   maxwellGRQM   = Mink ⊕ EM ⊕ QM (3-way)
--   maxwellGRQMcurved = MaxwellCurveSpace ⊕ Mink ⊕ EM ⊕ QM (4-way)
#print axioms CATEPTMain.Temporal.Adapter.maxwellGRQM_validates
#print axioms CATEPTMain.Temporal.Adapter.maxwellGRQMcurved_validates

-- SR + MaxwellCurveSpace live tiers (T92 — Group A4 + A5).
--   Caller-supplied live-witness pattern (Higgs/Herglotz precedent).
#print axioms CATEPTMain.Temporal.Adapter.srLive
#print axioms CATEPTMain.Temporal.Adapter.sr_dynamics_nontrivial
#print axioms CATEPTMain.Temporal.Adapter.maxwellCurveSpaceLive
#print axioms CATEPTMain.Temporal.Adapter.maxwellCurveSpace_dynamics_nontrivial

-- Group B retrofit (T93 — registry sweep continued).
--   complexActionStructure id (was dead) now retrofitted via the
--   Superior-Method slot's actionFn_nonneg field.
#print axioms CATEPTMain.Domains.SuperiorMethodAssumptionTags.complexActionStructure_tag

-- Cross-library Foundations retrofits (T98 — Group B continued).
--   Wraps CATEPT/CATEPT/Foundations.lean's eq012_thermal_response and
--   eq013_entropic_rate_formula with the registry's hawkingTemperatureFormula
--   and modularRateIdentification ids (both previously dead).
#print axioms CATEPTMain.Integration.FoundationsAssumptionTags.hawking_temperature_formula_tag
#print axioms CATEPTMain.Integration.FoundationsAssumptionTags.modular_rate_identification_tag

-- Fisher-Rao / Lawvere doc retrofits (T99 — Group B continued, GR-side).
--   Source: (private intake doc) (1).md §9, §10, §14.
--   Retrofits bianchiImpliesConservation + jacobsonEinsteinFromThermo
--   (both previously dead; Phase-1 placeholder Props pending Mathlib
--   smooth-section infra for Phase-2 tensor calculus).
#print axioms CATEPTMain.Integration.FisherRaoLawvereAssumptionTags.bianchi_implies_conservation_tag
#print axioms CATEPTMain.Integration.FisherRaoLawvereAssumptionTags.jacobson_einstein_from_thermo_tag
#print axioms CATEPTMain.Integration.FisherRaoLawvereAssumptionTags.fisher_rao_lawvere_GR_retrofits_discharged
-- Fisher-Rao / Lawvere assumption tags upgraded from := True placeholders
-- to non-vacuous structural Props (Bianchi linearity-of-divergence shape;
-- Jacobson/Einstein linear-superposition shape).  Same vacuous-content
-- sweep pattern as PR #27 (substrate tags).
#print axioms CATEPTMain.Integration.FisherRaoLawvereAssumptionTags.bianchiCompatibilityClaim_holds
#print axioms CATEPTMain.Integration.FisherRaoLawvereAssumptionTags.jacobsonEinsteinClaim_holds

-- T104 — Spectral-physics retrofit.  Three new substantive
-- AssumptionIds (spectralGapPositive, laplacianSelfAdjoint,
-- laplacianPositiveSemidefinite) wrap the corresponding theorems
-- from catept-plugin-spectral-physics (proved_spectral_gap_pos,
-- proved_laplacian_self_adjoint, proved_laplacian_pos_semidef).
-- Path B: add new ids matching plugin content rather than stretch
-- weylLaw / agmonEstimate (which target distinct claims).
#print axioms CATEPTMain.Integration.SpectralPhysicsAssumptionTags.spectralGapPositive_holds
#print axioms CATEPTMain.Integration.SpectralPhysicsAssumptionTags.laplacianSelfAdjoint_holds
#print axioms CATEPTMain.Integration.SpectralPhysicsAssumptionTags.laplacianPositiveSemidefinite_holds
#print axioms CATEPTMain.Integration.SpectralPhysicsAssumptionTags.spectral_physics_T104_retrofits_discharged

-- Physics-Noether retrofit audit lines (T100, unblocked by T101 PhysicalConstants dedup):
#print axioms CATEPTMain.Integration.NoetherEPTAssumptionTags.cat_noether_invariant_tag
#print axioms CATEPTMain.Integration.NoetherEPTAssumptionTags.ept_noether_invariant_tag
#print axioms CATEPTMain.Integration.NoetherEPTAssumptionTags.noether_invariants_under_ept_discharged
-- Substantive Noether-invariant theorems (NoetherEPT.lean) now in audit surface:
#print axioms CATEPTMain.CATEPT.CATEPT.cat_decay_implies_invariant_constant
#print axioms CATEPTMain.CATEPT.CATEPT.ept_decay_implies_invariant_constant
#print axioms CATEPTMain.CATEPT.CATEPT.dampedEquation_implies_mechanicalEnergyBalance

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
-- T70 Phase-2 contract: QMLiveWitnessCarrier carrier provides the
-- live-tier route via Phase-2 vonNeumannEntropy without adding new
-- axioms.  Note theorem documents that under Phase-1 placeholder
-- (vonNeumannEntropy ≡ 0), no carrier instance can exist.
#print axioms CATEPTMain.Temporal.Adapter.QMLiveWitnessCarrier.qmLive_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.qmLive_unobtainable_when_entropy_zero

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

-- Constructor-theoretic information layer over RelationalInformationSubstrate.
--   Thin CTI contract layer: SubstrateAttribute, SubstrateVariable,
--   SubstrateTask, ReversibleTask, CopyingTask, MeasurementTask,
--   InformationMedium, SuperinformationMedium.  Anti-vacuity guard
--   HasNontrivialNotifications blocks Notification := Empty from
--   discharging load-bearing CTI claims for free.
#print axioms CATEPTMain.Integration.ConstructorInformationSubstrate.SubstrateTask.evidence_empty_of_impossible
#print axioms CATEPTMain.Integration.ConstructorInformationSubstrate.SubstrateTask.possible_of_hasTaskEvidence
#print axioms CATEPTMain.Integration.ConstructorInformationSubstrate.informationMedium_requires_evidence
#print axioms CATEPTMain.Integration.ConstructorInformationSubstrate.superinformationMedium_requires_information
#print axioms CATEPTMain.Integration.ConstructorInformationSubstrate.taskImpossible_iff_no_evidence

-- T103 partial witness: concrete two-entity Alice/Bob substrate
-- demonstrates the upgraded SubstrateAssumptionTags Props (PR #27)
-- are non-vacuous in a concrete instance.  Each of the three Props
-- (IsMinkowskiSubstrate, SubstratePhaseIsQuantumPhaseClaim,
-- SubstrateNotificationIsQuantumChannelClaim) is proved for
-- aliceBobSubstrate, plus the bundle theorem combining all four
-- claims (the three plus HasNontrivialNotifications).
#print axioms CATEPTMain.Integration.ConcreteSubstrateExample.aliceBobSubstrate_hasNontrivialNotifications
#print axioms CATEPTMain.Integration.ConcreteSubstrateExample.aliceBobSubstrate_isMinkowskiSubstrate
#print axioms CATEPTMain.Integration.ConcreteSubstrateExample.aliceBobSubstrate_phaseIsQuantumPhase
#print axioms CATEPTMain.Integration.ConcreteSubstrateExample.aliceBobSubstrate_notificationIsQuantumChannel
#print axioms CATEPTMain.Integration.ConcreteSubstrateExample.aliceBobSubstrate_satisfies_T103_witness_bundle

-- Joint adapter (T79 — QM ⊕ GR ⊕ Maxwell unification).
--   The CATEPT spine is closed under arbitrary finite joins:
--   any combination of TemporalFramework adapters is itself a
--   TemporalFramework with the spine identification holding for free.
--   The maxwellGRQM TF demonstrates the headline composition.
#print axioms CATEPTMain.Temporal.Adapter.joint_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.maxwellGRQM_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.maxwellGRQM_clock_decomposition

-- Unified-Theory Constraints (T80 — discharges 7 of 11 Copilot-doc invariants).
--   Source: (private intake doc)
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
#print axioms CATEPTMain.Integration.SubstrateBell.SubstrateBellSource.alice_frame_owner
#print axioms CATEPTMain.Integration.SubstrateBell.SubstrateBellSource.bob_frame_owner

-- CTI-vocabulary upgrade for Bell bridge: non-vacuous local measurement
-- consuming MeasurementTask + InformationMedium guards.  Earlier drafts
-- shipped a placeholder substrate_local_frame_measurement that
-- discharged via rfl; it has been removed in favour of the theorems below.
#print axioms CATEPTMain.Integration.SubstrateBell.SubstrateBellSource.substrate_alice_nonperturbing_measurement
#print axioms CATEPTMain.Integration.SubstrateBell.SubstrateBellSource.substrate_bob_nonperturbing_measurement

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

-- T-BB / T-E Phase 2 (Wilson–Polchinski exact RG flow ODE). Genuine
-- `HasDerivAt` statement: the closed-form one-loop running coupling
-- `g(t) = g₀/(1 + b·g₀·t)` satisfies the exact RG flow ODE
--   `dg/dt = β(g) = -b·g(t)²`
-- pointwise along its trajectory (away from the Landau pole). This
-- closes the Phase-2 stage queued in the T-E header and discharges
-- the "Wilson–Polchinski exact RG flow" critical target on the
-- 11-target list. One honest theorem:
--   * oneLoopRunning_hasDerivAt
#print axioms CATEPTMain.Integration.RenormalizationGroup.oneLoopRunning_hasDerivAt

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

-- T-CC / T-D Phase 2 (Coleman-Callan φ⁴ bounce + topological-charge
-- integrality on S⁴; closes two Tier-4 critical-target lines at the
-- algebraic level). Six honest theorems on closed forms
-- S_b(λ) = 8π²/(3λ) and Q(n) = 8π²·n:
--   * bounceActionPhi4_pos                   φ⁴ bounce is positive
--   * bounceActionPhi4_coupling_rescale      S_b(k·λ) = (1/k)·S_b(λ)
--   * bounceActionPhi4_eq_BPST_third_at_match  3λ-vs-g² ratio identity
--   * topologicalCharge_zero                 Q(0) = 0
--   * topologicalCharge_add                  Q(n+m) = Q(n)+Q(m)
--   * instantonBPSTAction_mul_g_sq_eq_unit_charge  S_inst·g² = Q(1)
-- Gel'fand-Yaglom det' / Coleman-Callan one-loop prefactor /
-- 4-form integration of tr(F∧F) deferred to Phase 3.
#print axioms CATEPTMain.Integration.InstantonTunneling.bounceActionPhi4_pos
#print axioms CATEPTMain.Integration.InstantonTunneling.bounceActionPhi4_coupling_rescale
#print axioms CATEPTMain.Integration.InstantonTunneling.bounceActionPhi4_eq_BPST_third_at_match
#print axioms CATEPTMain.Integration.InstantonTunneling.topologicalCharge_zero
#print axioms CATEPTMain.Integration.InstantonTunneling.topologicalCharge_add
#print axioms CATEPTMain.Integration.InstantonTunneling.instantonBPSTAction_mul_g_sq_eq_unit_charge

-- T-C Phase 1 (Feynman-diagram algebra, final rung of the path-integral
-- leverage ladder). Honest algebraic identities on the tree-level s-channel
-- exchange amplitude  M(g, s, m) = g² / (s - m²):
--   * closed-form factorisation  M = g² · Δ(s, m),
--   * pole-residue normalisation  (s - m²) · M = g²  (unitarity weight),
--   * coupling-rescaling  M(k·g) = k² · M(g)        (universal tree weight).
-- One-loop vacuum polarisation, Cutkosky rules, BPHZ subtraction, and
-- on-shell renormalisation deferred to Phase 2.
#print axioms CATEPTMain.Integration.FeynmanDiagrams.treeAmplitude_closed_form
#print axioms CATEPTMain.Integration.FeynmanDiagrams.treeAmplitude_residue_at_pole
#print axioms CATEPTMain.Integration.FeynmanDiagrams.treeAmplitude_coupling_rescale

-- T-DD / Tier-4 (Connes–Kreimer Hopf algebra of Feynman graphs,
-- ladder sector Phase 1). The ladder sub-Hopf-algebra of H_FG is
-- isomorphic to the polynomial Hopf algebra ℝ[x] with primitive
-- coproduct Δ(x) = x⊗1 + 1⊗x; the (k, n−k)-component of Δ(xⁿ) is
-- the binomial coefficient C(n,k). Four honest theorems:
--   * ckLadderCoeff_zero_zero        counit on unit
--   * ckLadderCoeff_left_unit        left projection of counit
--   * ckLadderCoeff_primitive        Δ(x) = x⊗1 + 1⊗x
--   * ckLadderCoeff_coassociativity  Pascal's rule = coassociativity
-- Full graph-valued H_FG, antipode S, Birkhoff decomposition and
-- BPHZ characters deferred to Phase 2; rooted-tree H_R + B+ grafting
-- to Phase 3.
#print axioms CATEPTMain.Integration.ConnesKreimerLadder.ckLadderCoeff_zero_zero
#print axioms CATEPTMain.Integration.ConnesKreimerLadder.ckLadderCoeff_left_unit
#print axioms CATEPTMain.Integration.ConnesKreimerLadder.ckLadderCoeff_primitive
#print axioms CATEPTMain.Integration.ConnesKreimerLadder.ckLadderCoeff_coassociativity

-- T-EE / Tier-4 (One-loop vacuum polarisation, BPHZ on-shell
-- subtraction Phase 1). Two Taylor subtractions of a quadratic
-- self-energy Σ(p) = c₀ + c₁·p + c₂·p² at the on-shell point p₀
-- collapse to the on-shell remainder c₂·(p − p₀)², realising the
-- two on-shell renormalisation conditions Σ_R(p₀) = 0 and
-- Σ_R'(p₀) = 0. Four honest theorems:
--   * bphzOnShellRemainder_at_subtraction      mass renorm condition
--   * bphzOnShellRemainder_hasDerivAt_zero      wave-function renorm condition
--   * quadSelfEnergy_bphz_eq_onShellRemainder   closed form of BPHZ-2
--   * bphzOnShellRemainder_coupling_rescale     universal scaling
-- Full one-loop integral with dim-reg, Cutkosky discontinuities,
-- and forest formula for overlapping divergences deferred to
-- Phase 2 (built on T-DD H_FG Phase 2).
#print axioms CATEPTMain.Integration.OneLoopBPHZOnShell.bphzOnShellRemainder_at_subtraction
#print axioms CATEPTMain.Integration.OneLoopBPHZOnShell.bphzOnShellRemainder_hasDerivAt_zero
#print axioms CATEPTMain.Integration.OneLoopBPHZOnShell.quadSelfEnergy_bphz_eq_onShellRemainder
#print axioms CATEPTMain.Integration.OneLoopBPHZOnShell.bphzOnShellRemainder_coupling_rescale

-- T-FF / Tier-4 (Gel'fand–Yaglom functional determinant, Jacobi-field
-- Phase 1). For the harmonic oscillator on [0,T] with Dirichlet BCs,
-- the determinant ratio det'(−∂² + ω²)/det'(−∂²) = sinh(ωT)/(ωT)
-- is captured by the Jacobi-field solution gyJacobi ω T defined
-- piecewise to absorb the removable singularity at ω = 0. Four
-- honest theorems:
--   * gyJacobi_T_zero            Dirichlet ψ(0) = 0
--   * gyJacobi_omega_zero        free-particle limit gyJacobi 0 T = T
--   * gyJacobi_neg_omega         parity ω ↦ −ω (sinh odd)
--   * omega_mul_gyJacobi_eq_sinh multiplicative GY bridge
-- Zeta-regularised det' definition, Weierstrass-product representation,
-- and ODE-flow generalisation to smooth V deferred to Phase 2.
#print axioms CATEPTMain.Integration.GelfandYaglomJacobi.gyJacobi_T_zero
#print axioms CATEPTMain.Integration.GelfandYaglomJacobi.gyJacobi_omega_zero
#print axioms CATEPTMain.Integration.GelfandYaglomJacobi.gyJacobi_neg_omega
#print axioms CATEPTMain.Integration.GelfandYaglomJacobi.omega_mul_gyJacobi_eq_sinh

-- T-DD Phase 2 (Connes–Kreimer ladder antipode). The antipode
-- S(xⁿ) = (−1)ⁿ·xⁿ satisfies the antipode axiom
--   m ∘ (S ⊗ id) ∘ Δ = η ∘ ε
-- which collapses on xⁿ to the Möbius / alternating-sum identity
--   Σ_k (−1)ᵏ·C(n,k) = δ_{n,0}.
-- Honest theorems:
--   * ckLadderAntipodeSign_zero       S(1) = 1
--   * ckLadderAntipodeSign_add         S(xᵐ⁺ⁿ) = S(xᵐ)·S(xⁿ)
--   * ckLadder_antipode_axiom          full Möbius/antipode identity
--   * ckLadder_antipode_axiom_pos      vanishing in positive degree
#print axioms CATEPTMain.Integration.ConnesKreimerAntipode.ckLadderAntipodeSign_zero
#print axioms CATEPTMain.Integration.ConnesKreimerAntipode.ckLadderAntipodeSign_add
#print axioms CATEPTMain.Integration.ConnesKreimerAntipode.ckLadder_antipode_axiom
#print axioms CATEPTMain.Integration.ConnesKreimerAntipode.ckLadder_antipode_axiom_pos

-- T-EE Phase 2 (BPHZ-3 on-shell, cubic self-energy). Three Taylor
-- subtractions of Σ₃(p) = c₀ + c₁p + c₂p² + c₃p³ at p₀ collapse to the
-- closed cubic remainder c₃·(p − p₀)³, lifting the BPHZ prescription
-- of Phase 1 to higher-order Taylor remainders. Honest theorems:
--   * bphz3OnShellRemainder_at_subtraction       Σ_R(p₀) = 0
--   * bphz3OnShellRemainder_hasDerivAt_zero       Σ_R'(p₀) = 0
--   * cubicSelfEnergy_bphz_eq_onShellRemainder    closed-form BPHZ-3
#print axioms CATEPTMain.Integration.OneLoopBPHZCubic.bphz3OnShellRemainder_at_subtraction
#print axioms CATEPTMain.Integration.OneLoopBPHZCubic.bphz3OnShellRemainder_hasDerivAt_zero
#print axioms CATEPTMain.Integration.OneLoopBPHZCubic.cubicSelfEnergy_bphz_eq_onShellRemainder

-- T-FF Phase 2 (Gel'fand–Yaglom Jacobi field, initial-velocity
-- condition ψ'(0) = 1). Honest HasDerivAt boundary conditions for
-- both branches of the GY Jacobi field:
--   * gyJacobi_free_hasDerivAt_one              free particle ω = 0
--   * sinh_div_omega_hasDerivAt_one_at_zero     oscillator ω ≠ 0
--   * sinh_div_omega_at_zero                    ψ(0) = 0 (consistency)
#print axioms CATEPTMain.Integration.GelfandYaglomDeriv.gyJacobi_free_hasDerivAt_one
#print axioms CATEPTMain.Integration.GelfandYaglomDeriv.sinh_div_omega_hasDerivAt_one_at_zero
#print axioms CATEPTMain.Integration.GelfandYaglomDeriv.sinh_div_omega_at_zero

-- T-CC Phase 3 (Coleman–Callan bounce stationarity & WKB suppression).
-- Lifts Phase-1/2 from the closed form S_b(λ) = 8π²/(3λ) to the
-- scale-invariant content of the Fubini bounce solution:
--   * bounceActionPhi4_lambda_action_invariant     λ · S_b(λ) = 8π²/3
--   * bounceActionPhi4_action_ratio_scale_invariant joint rescaling fixes ratio
--   * tunnelAmplitude_at_bounce                    closed-form WKB factor
--   * tunnelAmplitude_at_bounce_lt_one              strict suppression < 1
#print axioms CATEPTMain.Integration.BounceStationarity.bounceActionPhi4_lambda_action_invariant
#print axioms CATEPTMain.Integration.BounceStationarity.bounceActionPhi4_action_ratio_scale_invariant
#print axioms CATEPTMain.Integration.BounceStationarity.tunnelAmplitude_at_bounce
#print axioms CATEPTMain.Integration.BounceStationarity.tunnelAmplitude_at_bounce_lt_one

-- T-CC Phase 3 (Topological-charge integrality on S⁴, Atiyah–Singer
-- algebraic core). Q(n)/(8π²) = (n : ℝ) for any integer n,
-- with explicit unit-charge BPST and anti-instanton witnesses:
--   * topologicalCharge_div_eight_pi_sq        Q(n)/(8π²) = n  (integrality)
--   * topologicalCharge_integer_witness         existential converse
--   * topologicalCharge_unit_charge             Q(1) = 8π²
--   * topologicalCharge_anti_unit               Q(-1) = -8π²
#print axioms CATEPTMain.Integration.TopologicalChargeIntegrality.topologicalCharge_div_eight_pi_sq
#print axioms CATEPTMain.Integration.TopologicalChargeIntegrality.topologicalCharge_integer_witness
#print axioms CATEPTMain.Integration.TopologicalChargeIntegrality.topologicalCharge_unit_charge
#print axioms CATEPTMain.Integration.TopologicalChargeIntegrality.topologicalCharge_anti_unit

-- T-EE Phase 3 (Cutkosky discontinuity = 2·i·Im, complex-analytic
-- core of the cutting rules / unitarity). Lifted from Mathlib's
-- Complex.sub_conj at the algebraic level:
--   * cutkoskyDisc_eq_two_I_im     Disc(z) = 2·i·Im(z)
--   * cutkoskyDisc_real_zero       no branch cut on ℝ
--   * cutkoskyDisc_re_zero          discontinuity is purely imaginary
--   * cutkoskyDisc_im              optical-theorem normalisation
#print axioms CATEPTMain.Integration.CutkoskyDiscontinuity.cutkoskyDisc_eq_two_I_im
#print axioms CATEPTMain.Integration.CutkoskyDiscontinuity.cutkoskyDisc_real_zero
#print axioms CATEPTMain.Integration.CutkoskyDiscontinuity.cutkoskyDisc_re_zero
#print axioms CATEPTMain.Integration.CutkoskyDiscontinuity.cutkoskyDisc_im

-- T-DD/T-EE Phase 3 (BPHZ forest formula on Connes–Kreimer ladder).
-- The renormalised ladder amplitude Z_R(xⁿ) = ∑ (-1)ᵏ·C(n,k) collapses
-- to δ_{n,0} via the antipode / Möbius identity — the algebraic core of
-- BPHZ cancellation of nested ladder divergences:
--   * renormalisedLadder_eq_alternating_sum   forest-formula expansion
--   * renormalisedLadder_eq_kronecker          Z_R(xⁿ) = δ_{n,0}
--   * renormalisedLadder_pos_eq_zero           full BPHZ cancellation in n>0
--   * renormalisedLadder_zero                  unit sector returns 1
#print axioms CATEPTMain.Integration.BPHZForestLadder.renormalisedLadder_eq_alternating_sum
#print axioms CATEPTMain.Integration.BPHZForestLadder.renormalisedLadder_eq_kronecker
#print axioms CATEPTMain.Integration.BPHZForestLadder.renormalisedLadder_pos_eq_zero
#print axioms CATEPTMain.Integration.BPHZForestLadder.renormalisedLadder_zero

-- T-CC Phase 4 (Coleman–Callan dilute-instanton-gas exponentiation).
-- Multi-instanton resummation Z(V,κ,S) = exp(V·κ·exp(−S)), with
-- vacuum-energy density E/V = −κ·exp(−S) extracted via log Z = −V·E/V:
--   * diluteGasZ_at_zero_action         trivial-action limit Z = exp(V·κ)
--   * diluteGasZ_disjoint_volumes        Z(V₁+V₂) = Z(V₁)·Z(V₂)
--   * log_diluteGasZ_eq_minus_E_times_V  vacuum-energy extraction
--   * vacuumEnergyDensity_neg            strict false-vacuum instability
#print axioms CATEPTMain.Integration.ColemanCallanDiluteGas.diluteGasZ_at_zero_action
#print axioms CATEPTMain.Integration.ColemanCallanDiluteGas.diluteGasZ_disjoint_volumes
#print axioms CATEPTMain.Integration.ColemanCallanDiluteGas.log_diluteGasZ_eq_minus_E_times_V
#print axioms CATEPTMain.Integration.ColemanCallanDiluteGas.vacuumEnergyDensity_neg

-- T-CC Phase 4 (Topological-charge cohomological non-degeneracy).
-- Q : ℤ → ℝ is a genuine injection — distinct instanton sectors
-- give distinct charges, no level-crossings or vacuum identifications:
--   * topologicalCharge_neg              orientation reversal Q(−n)=−Q(n)
--   * topologicalCharge_sub               relative-instanton-number linearity
--   * topologicalCharge_eq_zero_iff       vanishing iff trivial sector
--   * topologicalCharge_injective         cohomological non-degeneracy ℤ ↪ ℝ
#print axioms CATEPTMain.Integration.TopologicalChargeCohomology.topologicalCharge_neg
#print axioms CATEPTMain.Integration.TopologicalChargeCohomology.topologicalCharge_sub
#print axioms CATEPTMain.Integration.TopologicalChargeCohomology.topologicalCharge_eq_zero_iff
#print axioms CATEPTMain.Integration.TopologicalChargeCohomology.topologicalCharge_injective

-- T-EE Phase 4 (Branch-cut log discontinuity). Cutkosky cut of the
-- principal-branch logarithm at −1: log(−1)=π·I, Disc=2π·I, the algebraic
-- shadow of the one-loop bubble cut log(m²−s−i0⁺):
--   * branchValueLogNegOne                log(−1) = π·I
--   * branchImag_log_neg_one              Im(log(−1)) = π
--   * cutkoskyDisc_log_neg_one             Disc(log(−1)) = 2π·I
--   * cutkoskyDisc_log_neg_one_ne_zero     genuine branch-cut detection
#print axioms CATEPTMain.Integration.CutkoskyBranchCut.branchValueLogNegOne
#print axioms CATEPTMain.Integration.CutkoskyBranchCut.branchImag_log_neg_one
#print axioms CATEPTMain.Integration.CutkoskyBranchCut.cutkoskyDisc_log_neg_one
#print axioms CATEPTMain.Integration.CutkoskyBranchCut.cutkoskyDisc_log_neg_one_ne_zero

-- T-DD Phase 4 (Connes–Kreimer convolution algebra & Birkhoff inversion).
-- Convolution φ∗ψ on ladder characters has the antipode S as the convolution
-- inverse of id: S∗id = ε (Birkhoff antipode axiom in convolution algebra):
--   * ckLadderConv_one_left          ε∗φ = φ, left convolution unit
--   * ckLadderConv_S_id              S∗id = ε, antipode = convolution inverse
--   * ckLadderConv_id_S_at_zero      unit-sector right-side normalisation
#print axioms CATEPTMain.Integration.CKBirkhoffLadder.ckLadderConv_one_left
#print axioms CATEPTMain.Integration.CKBirkhoffLadder.ckLadderConv_S_id
#print axioms CATEPTMain.Integration.CKBirkhoffLadder.ckLadderConv_id_S_at_zero

-- T-F Phase 1 (Gaussian completion-of-the-square, algebraic engine of
-- every Gaussian path integral). Honest algebraic identities:
--   * gaussianCompletion                    a·x² - b·x = a·(x - b/(2a))² - b²/(4a)
--   * gaussianCompletion_zero_source         b = 0 reduction
--   * gaussianCompletion_shift_eliminates_linear  shift law x ↦ y + b/(2a)
-- Closed-form Gaussian integral √(π/a)·exp(b²/(4a)) and matrix-version
-- ½·Jᵀ·A⁻¹·J + ½·log det(2π A⁻¹) deferred to Phase 2.
#print axioms CATEPTMain.Integration.GaussianCompletion.gaussianCompletion
#print axioms CATEPTMain.Integration.GaussianCompletion.gaussianCompletion_zero_source
#print axioms CATEPTMain.Integration.GaussianCompletion.gaussianCompletion_shift_eliminates_linear

-- T-G Phase 1 (Free-particle classical action, exponent of the Feynman
-- free propagator K ∝ exp(i·S_cl/ℏ) where S_cl = m·(xb-xa)²/(2T)).
-- Four honest algebraic identities:
--   * freeClassicalAction_zero_displacement   xb=xa ⇒ 0
--   * freeClassicalAction_endpoint_symm       invariant under xa ↔ xb
--   * freeClassicalAction_endpoint_rescale    quadratic in displacement
--   * freeClassicalAction_mass_linear         linear in mass
-- Time-additivity along a slicing, harmonic-oscillator extension, and
-- the full propagator Gaussian-integral identity deferred to Phase 2.
#print axioms CATEPTMain.Integration.FreeParticleAction.freeClassicalAction_zero_displacement
#print axioms CATEPTMain.Integration.FreeParticleAction.freeClassicalAction_endpoint_symm
#print axioms CATEPTMain.Integration.FreeParticleAction.freeClassicalAction_endpoint_rescale
#print axioms CATEPTMain.Integration.FreeParticleAction.freeClassicalAction_mass_linear

-- T-H Phase 1 (Free-particle action time-additivity at the saddle
-- xm* = (T₂·xa + T₁·xb)/(T₁+T₂); algebraic Chapman–Kolmogorov of the
-- Feynman slicing construction). Two honest algebraic identities:
--   * freeSaddle_displacement_split        segment displacements
--   * freeClassicalAction_additive_at_saddle  S(xa,xm*,T₁)+S(xm*,xb,T₂)=S(xa,xb,T₁+T₂)
-- Variational characterisation of xm* and n-fold Trotter slicing
-- deferred to Phase 2.
#print axioms CATEPTMain.Integration.FreeParticleSaddle.freeSaddle_displacement_split
#print axioms CATEPTMain.Integration.FreeParticleSaddle.freeClassicalAction_additive_at_saddle

-- T-Y / T-H Phase 2 (Saddle variational characterisation —
-- ∂_{xₘ}[S_cl(xa,xm,T₁) + S_cl(xm,xb,T₂)] = 0 at xm = xm*).
-- Genuine `HasDerivAt` statement: the broken-path action, viewed as a
-- function of the midpoint `u`, has derivative 0 at the saddle
-- xm* = (T₂·xa + T₁·xb)/(T₁+T₂). Closes Tier-1 #3 of the original
-- 11-target critical-path list. One honest theorem:
--   * freeClassicalAction_sum_hasDerivAt_saddle
#print axioms CATEPTMain.Integration.FreeParticleSaddle.freeClassicalAction_sum_hasDerivAt_saddle

-- T-Z / Tier-2 #4 Phase 1 (Trotter slicing → free-particle propagator
-- phase). Defines the WKB phase Φ(xa,xb,T) = m·(xb-xa)²/(2·ℏ·T)
-- (the exponent of the Feynman free propagator
-- K = √(m/(2π·iℏ·T))·exp(i·S_cl/ℏ)) and proves it is closed under
-- saddle-point Trotter slicing. Three honest theorems:
--   * freePropagatorPhase_eq_action_div_hbar           Φ = S_cl / ℏ
--   * freePropagatorPhase_split_at_saddle              2-fold slicing
--   * freePropagatorPhase_three_split_at_successive_saddles
--                                                      3-fold (iterable)
-- Full complex-valued propagator with √(m/(2πiℏT)) prefactor and
-- Gaussian-convolution semigroup law deferred to Phase 2.
#print axioms CATEPTMain.Integration.FreeParticlePropagator.freePropagatorPhase_eq_action_div_hbar
#print axioms CATEPTMain.Integration.FreeParticlePropagator.freePropagatorPhase_split_at_saddle
#print axioms CATEPTMain.Integration.FreeParticlePropagator.freePropagatorPhase_three_split_at_successive_saddles

-- T-AA / Tier-2 #4 Phase 1.5 (uniform n-fold Trotter splitting of the
-- free-particle propagator phase). Lifts the 2-fold and 3-fold algebraic
-- saddle-splittings of T-Z to an arbitrary uniform partition of `[0, T]`
-- into `n` equal slices. On the closed-form uniform grid
-- `x_i = xa + (i/n)(xb − xa)` with `δ = T/n`, each slice carries
-- exactly `1/n`-th of the total WKB phase, and summing `n` copies
-- recovers `Φ(xa, xb, T)`. Four honest theorems:
--   * uniformGridPoint_zero                          x_0 = xa
--   * uniformGridPoint_self                          x_n = xb (n ≠ 0)
--   * freePropagatorPhase_uniformGrid_summand        Φ_i = Φ_total / n
--   * freePropagatorPhase_uniform_n_fold_split       ∑Φ_i = Φ_total
-- Non-uniform partitions via list-based saddle paths and the full
-- complex propagator with Gaussian convolution deferred to Phase 2.
#print axioms CATEPTMain.Integration.FreeParticlePropagatorNFold.uniformGridPoint_zero
#print axioms CATEPTMain.Integration.FreeParticlePropagatorNFold.uniformGridPoint_self
#print axioms CATEPTMain.Integration.FreeParticlePropagatorNFold.freePropagatorPhase_uniformGrid_summand
#print axioms CATEPTMain.Integration.FreeParticlePropagatorNFold.freePropagatorPhase_uniform_n_fold_split

-- T-I Phase 1 (Schwinger source-shift bridge — leverages FEYNCALC's
-- scalar Schwinger / Laplace identity from catept-domain-gauge to lift
-- the algebraic completion-of-the-square engine of T-F Phase 1 into a
-- proper-time integral representation of the source-shifted free-mode
-- propagator). Three honest kernel-only theorems:
--   * shiftedQuadratic_eq_completed     a·(x − b/(2a))² = a·x² − b·x + b²/(4a)
--   * shiftedQuadratic_pos              positivity away from the saddle
--   * schwinger_for_shiftedQuadratic    1/(a·(x−b/(2a))²) = ∫₀^∞ e^{−α t} dt
-- N-dim matrix Schwinger trick + sourced Z[J]/Z[0] deferred to Phase 2.
#print axioms CATEPTMain.Integration.SchwingerSourceShift.shiftedQuadratic_eq_completed
#print axioms CATEPTMain.Integration.SchwingerSourceShift.shiftedQuadratic_pos
#print axioms CATEPTMain.Integration.SchwingerSourceShift.schwinger_for_shiftedQuadratic

-- T-J Phase 1 (Diagonal multivariate Gaussian completion — vector lift
-- of T-F's scalar completion-of-square via Finset.sum, plus a FEYNCALC
-- bridge showing the trivial-coefficient diagonal sum coincides with
-- the catept-domain-gauge euclideanDenominator k 0). Three honest
-- kernel-only theorems:
--   * gaussianCompletion_diag                          ∑ (aᵢ xᵢ² − bᵢ xᵢ) lift
--   * gaussianCompletion_diag_zero_source              b ≡ 0 reduction
--   * gaussianCompletion_diag_recovers_euclideanDenominator   FEYNCALC bridge
-- Non-diagonal matrix completion + sourced n-dim Z[J]/Z[0] deferred to Phase 2.
#print axioms CATEPTMain.Integration.MultiModeGaussianCompletion.gaussianCompletion_diag
#print axioms CATEPTMain.Integration.MultiModeGaussianCompletion.gaussianCompletion_diag_zero_source
#print axioms CATEPTMain.Integration.MultiModeGaussianCompletion.gaussianCompletion_diag_recovers_euclideanDenominator

-- T-K Phase 1 (Shifted Gaussian integral — first analytic evaluation
-- on the path-integral ladder). Combines Mathlib's `integral_gaussian`
-- with translation-invariance of Lebesgue measure (`integral_sub_right_eq_self`)
-- to evaluate `∫ exp(-a·(x - c)²) dx = √(π/a)` for any real shift `c`,
-- then specialises to T-F Phase 1's saddle shift `c = b/(2a)`.
--   * integral_gaussian_shifted               translation invariance + Mathlib eval
--   * integral_gaussian_at_completionShift    bridge to T-F Phase 1 saddle
-- Phase 2 deferred: extracting the `exp(b²/(4a))` constant via integral_const_mul.
#print axioms CATEPTMain.Integration.ShiftedGaussianIntegral.integral_gaussian_shifted
#print axioms CATEPTMain.Integration.ShiftedGaussianIntegral.integral_gaussian_at_completionShift

-- T-L Phase 1 (FULL SOURCED Gaussian integral evaluation — capstone
-- of T-F + T-K). Composes algebraic completion-of-the-square (T-F) with
-- the shifted Gaussian integral (T-K Phase 1) and Mathlib's
-- `integral_const_mul` linearity to derive
--      ∫ℝ  exp(-(a·x² - b·x)) dx  =  √(π/a) · exp(b²/(4a)).
-- This is the foundational Z[J]/Z[0] = exp(b²/(4a)) identity in
-- 1D scalar QFT — the source-coupling generating-functional trick.
--   * integral_sourced_gaussian               full identity (a ≠ 0)
--   * integral_sourced_gaussian_zero_source   b = 0 reduction
#print axioms CATEPTMain.Integration.SourcedGaussianIntegral.integral_sourced_gaussian
#print axioms CATEPTMain.Integration.SourcedGaussianIntegral.integral_sourced_gaussian_zero_source

-- T-M Phase 1 (DIAGONAL MULTIMODE sourced Gaussian Z[J] in 1D-per-mode
-- form). Lifts T-L Phase 1 from a single mode to a `Finset.prod` over
-- an arbitrary finite index type `ι`, composing `Real.exp_sum`,
-- Mathlib's `integral_fintype_prod_volume_eq_prod` (Fubini on product
-- measure), and per-mode T-L sourced-Gaussian evaluation:
--      ∫_{ℝ^ι} exp(-(∑ᵢ aᵢxᵢ² - bᵢxᵢ)) dx
--           = ∏ᵢ exp(bᵢ²/(4aᵢ)) · √(π/aᵢ).
-- This is the diagonal multivariate generating functional Z[J] of an
-- n-mode free scalar theory whose kinetic operator has been
-- diagonalised — directly composing T-J's algebraic substrate and
-- T-L's analytic per-mode evaluation.
--   * integral_sourced_gaussian_multimode             full multimode identity
--   * integral_sourced_gaussian_multimode_zero_source b ≡ 0 reduction
#print axioms CATEPTMain.Integration.MultiModeSourcedGaussian.integral_sourced_gaussian_multimode
#print axioms CATEPTMain.Integration.MultiModeSourcedGaussian.integral_sourced_gaussian_multimode_zero_source

-- T-N Phase 1 (Z[J]/Z[0] RATIO IDENTITY — the source-coupling factor
-- isolated from the kinetic determinant). Capstone-conceptual rung
-- that takes the ratio of T-L (resp. T-M) full Z[J] over its own
-- zero-source Z[0]; the kinetic determinant √(π/a) (resp. ∏ √(π/aᵢ))
-- cancels, leaving the bare exponential source-coupling factor:
--      Z[J] / Z[0]  =  exp(b²/(4a))               (scalar 1D)
--      Z[J] / Z[0]  =  ∏ᵢ exp(bᵢ²/(4 aᵢ))         (diagonal multimode)
-- This is the form in which Z[J]/Z[0] is read off generating-functional
-- relations in QFT (e.g. as the source for connected n-point functions).
--   * Z_ratio_scalar      scalar 1D ratio (a > 0)
--   * Z_ratio_multimode   diagonal multimode ratio (∀ i, 0 < aᵢ)
#print axioms CATEPTMain.Integration.ZJRatio.Z_ratio_scalar
#print axioms CATEPTMain.Integration.ZJRatio.Z_ratio_multimode

-- T-O Phase 1 (FREE-ENERGY / LOG-RATIO READING). Composes T-N with
-- Real.log_exp (and Real.exp_sum for the multimode case) to obtain
-- the QFT "connected free-energy" form
--      log( Z[J] / Z[0] )  =  b² / (4a)               (scalar 1D)
--      log( Z[J] / Z[0] )  =  ∑ᵢ  bᵢ² / (4 aᵢ)         (diagonal multimode)
-- This is the value of the connected generating functional W[J]
-- = log Z[J] (relative to the b = 0 baseline) on the Gaussian sector.
--   * log_Z_ratio_scalar      scalar 1D log-ratio (a > 0)
--   * log_Z_ratio_multimode   diagonal multimode log-ratio (∀ i, 0 < aᵢ)
#print axioms CATEPTMain.Integration.LogZJRatio.log_Z_ratio_scalar
#print axioms CATEPTMain.Integration.LogZJRatio.log_Z_ratio_multimode

-- T-P Phase 1 (TWO-POINT CONNECTED PROPAGATOR — second-derivative
-- reading of T-O's connected free-energy W[J] = log Z[J]/Z[0] = b²/(4a)).
-- Standard QFT generating-functional identities derived by elementary
-- Mathlib calculus (`HasDerivAt` on b ↦ b²/(4a) and b ↦ b/(2a)):
--   one-point function:    ∂_b W[J] |_{b=0}    =  0
--   connected propagator:  ∂²_b W[J] |_{b=0}   =  1/(2a)
-- The two-point function vanishes at b=0 (action is even); its second
-- derivative recovers the inverse kinetic operator G = (2a)⁻¹ — the
-- canonical "propagator from the source-coupling generator" reading.
--   * one_point_scalar       ∂_b W |_{b=0} = 0
--   * propagator_scalar      ∂²_b W |_{b=0} = 1/(2a)
#print axioms CATEPTMain.Integration.PropagatorScalar.one_point_scalar
#print axioms CATEPTMain.Integration.PropagatorScalar.propagator_scalar

-- T-Q Phase 1 (DIAGONAL MULTIMODE PROPAGATOR — lift T-P scalar to
-- per-mode + quadratic-form readings of T-O multimode W[b]).
--   * propagator_diagonal           per-slot ∂²_b W |_{b=0} = 1/(2 a_i)
--   * W_eq_propagator_quadratic_form  2·W[b] = ∑ᵢ bᵢ·(G·b)ᵢ with
--                                    Gᵢⱼ = δᵢⱼ/(2 aᵢ)
-- Exposes the diagonal propagator as the matrix kernel of the connected
-- 2-point function in the diagonal sector. Off-diagonal vanishes
-- definitionally; non-diagonal n-dim deferred (Cholesky / spectral).
#print axioms CATEPTMain.Integration.PropagatorMultimode.propagator_diagonal
#print axioms CATEPTMain.Integration.PropagatorMultimode.W_eq_propagator_quadratic_form

-- T-R Phase 1 (OFF-DIAGONAL VANISHING + ENTROPIC-PROPER-TIME READING
-- of the connected two-point function).
--   * propagator_eq_entropicProperTime         per-mode propagator = τ(a) := 1/(2a)
--   * propagator_off_diagonal                  cross-mode ∂∂ W |₀ = 0 (separable action)
--   * propagatorKernel_eq_entropicProperTime   multimode kernel = δ_ij · τ(a_i)
-- Identifies the connected propagator with the entropic-proper-time
-- scale of each Gaussian mode; off-diagonal vanishing says independent
-- modes have decoupled entropic clocks (no cross-time mixing).
#print axioms CATEPTMain.Integration.PropagatorEntropicTime.propagator_eq_entropicProperTime
#print axioms CATEPTMain.Integration.PropagatorEntropicTime.propagator_off_diagonal
#print axioms CATEPTMain.Integration.PropagatorEntropicTime.propagatorKernel_eq_entropicProperTime

-- T-S Phase 1 (HEAT-SEMIGROUP ↔ ENTROPIC-PROPER-TIME identification).
--   * heatMode_zero          heatMode a 0 = 1 (initial-value normalisation)
--   * heatMode_decay_rate    ∂_t heatMode a |_{t=0} = - 1 / τ(a)
-- Couples the static-side propagator G = τ(a) (T-P/T-Q/T-R) with the
-- dynamic-side heat-semigroup `e^{-2 a t}` whose initial decay rate is
-- `1/τ(a)`. The entropic proper time is the inverse heat-semigroup
-- decay rate at t=0; this is the t→0 localisation of the Gaussian mode.
#print axioms CATEPTMain.Integration.HeatSemigroupEntropicTime.heatMode_zero
#print axioms CATEPTMain.Integration.HeatSemigroupEntropicTime.heatMode_decay_rate

-- T-T Phase 1 (TIME-INTEGRATED HEAT-SEMIGROUP = ENTROPIC PROPER TIME).
--   * heatMode_integral_eq_entropicProperTime
--       ∫ t in Ioi 0, heatMode a t = τ(a), for a > 0.
-- Complementary L¹/Laplace-transform reading of τ: time-integral of the
-- heat semigroup against a unit source equals the static propagator.
-- Combined with T-S, the two semigroup readings of τ(a) = 1/(2a) are:
--   τ = inverse decay rate at t=0 (T-S), τ = ∫₀^∞ e^{-2 a t} dt (T-T).
#print axioms CATEPTMain.Integration.HeatIntegralEntropicTime.heatMode_integral_eq_entropicProperTime

-- T-U Phase 1 (HEAT-SEMIGROUP COMPOSITION LAW).
--   * heatMode_semigroup
--       heatMode a (s + t) = heatMode a s * heatMode a t.
-- Together with heatMode_zero (T-S), gives the one-parameter abelian
-- semigroup structure on the diagonal heat-mode `S_t = e^{-(2 a) t}`.
-- Closes out the elementary semigroup readings of τ(a): rate at 0 (T-S),
-- L¹-norm (T-T), composition law (T-U).
#print axioms CATEPTMain.Integration.HeatSemigroupLaw.heatMode_semigroup

-- T-V Phase 1 (SOURCED HEAT-INTEGRAL IDENTITY).
--   * heatMode_pos
--       0 < heatMode a t  (positivity-free in `a`).
--   * heatMode_integral_smul_source
--       ∫ Ioi 0, J · heatMode a t  =  J · τ(a)  (for a > 0).
-- Linear-in-source reading of T-T: the sourced time integral of the
-- diagonal heat mode equals the source times the entropic proper time.
-- Connects the heat-semigroup track to the W[J] / sourced-Gaussian track.
#print axioms CATEPTMain.Integration.SourcedHeatIntegral.heatMode_pos
#print axioms CATEPTMain.Integration.SourcedHeatIntegral.heatMode_integral_smul_source

-- T-W Phase 1 (SHIFTED HEAT-INTEGRAL IDENTITY).
--   * heatMode_shifted_integral
--       a > 0  ==>  ∫ Ioi 0, heatMode a (s + t) dt  =  heatMode a s · τ(a).
-- Composition of T-U and T-T: starting the heat semigroup at phase s
-- and integrating forward gives τ(a) discounted by the semigroup factor
-- heatMode a s. The Markov / time-shift identity for the diagonal
-- OU heat mode; bridges T-T (s=0 case) with the delayed-source W[J].
#print axioms CATEPTMain.Integration.ShiftedHeatIntegral.heatMode_shifted_integral

-- T-X Phase 2 (MEHLER HALF-ANGLE DECOMPOSITION). Phase-2 bridge of T-A
-- toward both deferred analytic limits of the Mehler kernel:
--   * mehler_bracket_half_angle
--       (x²+y²)·cosh(2u) − 2xy = cosh²(u)·(x−y)² + sinh²(u)·(x+y)².
--   * mehlerExponent_half_angle
--       S(x,y;t) = −m·ω·[cosh²(ωt/2)(x−y)² + sinh²(ωt/2)(x+y)²]
--                  / (2·sinh(ωt)).
-- The (x−y)² coefficient drives the t→0 free-particle delta limit
-- (heat-kernel exponent −m(x−y)²/(2t)); the (x+y)² coefficient with
-- tanh(ωt/2) is the generating-function form for the Hermite spectral
-- expansion ∑ Hₙ(x)Hₙ(y)·e^(−(n+½)ωt). Full distributional / spectral
-- convergence deferred (Phase 3+).
#print axioms CATEPTMain.Integration.OscillatorKernel.mehler_bracket_half_angle
#print axioms CATEPTMain.Integration.OscillatorKernel.mehlerExponent_half_angle

-- T-FF Phase 3 (Gel'fand–Yaglom determinant ratio at the Jacobi-quotient
-- level). Packages the closed-form GY identity
--   det'(−∂² + ω²) / det'(−∂²)  =  ψ_ω(T) / T  =  sinh(ω T) / (ω T)
-- as a single function `gyDetRatio ω T := gyJacobi ω T / T`. Four honest
-- theorems:
--   * gyDetRatio_omega_zero       free-particle baseline = 1
--   * gyDetRatio_eq_sinh_form      closed-form sinh(ω T)/(ω T)
--   * gyDetRatio_neg_omega         parity ω ↦ −ω invariance
--   * gyDetRatio_T_zero             source-endpoint degeneracy (T = 0)
#print axioms CATEPTMain.Integration.GelfandYaglomDetRatio.gyDetRatio_omega_zero
#print axioms CATEPTMain.Integration.GelfandYaglomDetRatio.gyDetRatio_eq_sinh_form
#print axioms CATEPTMain.Integration.GelfandYaglomDetRatio.gyDetRatio_neg_omega
#print axioms CATEPTMain.Integration.GelfandYaglomDetRatio.gyDetRatio_T_zero

-- T-FF Phase 4 (Gel'fand–Yaglom determinant-ratio asymptotics).
-- Strict positivity of ψ_ω(T) and the determinant ratio on the physical
-- regime T > 0, plus strict T-monotonicity for ω > 0 (the qualitative
-- form of the GY exponential blow-up `e^{ωT}/(2ωT)` at large T).
-- Brings T-FF to Phase-4 parity with T-CC / T-DD / T-EE. Four honest
-- theorems:
--   * gyJacobi_pos                            ψ_ω(T) > 0 for T > 0, any ω
--   * gyDetRatio_pos                           ratio > 0 for T > 0, any ω
--   * gyDetRatio_baseline_omega_zero           ratio = 1 at ω = 0, T > 0
--   * gyJacobi_strictMono_T_of_omega_pos       T-monotonicity for ω > 0
#print axioms CATEPTMain.Integration.GelfandYaglomAsymptotics.gyJacobi_pos
#print axioms CATEPTMain.Integration.GelfandYaglomAsymptotics.gyDetRatio_pos
#print axioms CATEPTMain.Integration.GelfandYaglomAsymptotics.gyDetRatio_baseline_omega_zero
#print axioms CATEPTMain.Integration.GelfandYaglomAsymptotics.gyJacobi_strictMono_T_of_omega_pos

-- T-FF Phase 5 (Gel'fand–Yaglom partition-function ratio).
-- Inverse of the Phase-3 det'-ratio: Z_HO/Z_free = T/ψ_ω(T) = ωT/sinh(ωT),
-- and the cancellation identity gyDetRatio · gyPartRatio = 1 on T > 0.
-- Five honest theorems:
--   * gyPartRatio_omega_zero                 free baseline = 1 at ω = 0
--   * gyPartRatio_eq_inv_sinh_form           closed form (ωT)/sinh(ωT)
--   * gyPartRatio_neg_omega                  parity ω ↦ −ω
--   * gyPartRatio_T_zero                     T = 0 degeneracy
--   * gyDetRatio_mul_partRatio_eq_one        cancellation on T > 0
#print axioms CATEPTMain.Integration.GelfandYaglomPartition.gyPartRatio_omega_zero
#print axioms CATEPTMain.Integration.GelfandYaglomPartition.gyPartRatio_eq_inv_sinh_form
#print axioms CATEPTMain.Integration.GelfandYaglomPartition.gyPartRatio_neg_omega
#print axioms CATEPTMain.Integration.GelfandYaglomPartition.gyPartRatio_T_zero
#print axioms CATEPTMain.Integration.GelfandYaglomPartition.gyDetRatio_mul_partRatio_eq_one

-- T-FF Phase 6 (Gel'fand–Yaglom partition-ratio positivity & inversion).
-- Phase-4 parity for the partition side: strict positivity on T > 0,
-- free baseline at ω = 0, and explicit inversion bridge
-- gyPartRatio = (gyDetRatio)⁻¹. Three honest theorems:
--   * gyPartRatio_pos                       0 < ratio for T > 0
--   * gyPartRatio_baseline_omega_zero       ratio = 1 at ω = 0, T > 0
--   * gyPartRatio_eq_inv_gyDetRatio         inversion bridge on T > 0
#print axioms CATEPTMain.Integration.GelfandYaglomPartitionPos.gyPartRatio_pos
#print axioms CATEPTMain.Integration.GelfandYaglomPartitionPos.gyPartRatio_baseline_omega_zero
#print axioms CATEPTMain.Integration.GelfandYaglomPartitionPos.gyPartRatio_eq_inv_gyDetRatio

-- T-FF Phase 7 (Gel'fand–Yaglom inversion API).
-- Symmetric inversion bridge between det-ratio and partition-ratio
-- on T > 0, plus non-vanishing of the partition ratio. Three
-- kernel-only corollaries:
--   * gyPartRatio_mul_gyDetRatio_eq_one   commuted cancellation
--   * gyDetRatio_eq_inv_gyPartRatio       reverse bridge
--   * gyPartRatio_ne_zero                  non-vanishing on T > 0
#print axioms CATEPTMain.Integration.GelfandYaglomInversionAPI.gyPartRatio_mul_gyDetRatio_eq_one
#print axioms CATEPTMain.Integration.GelfandYaglomInversionAPI.gyDetRatio_eq_inv_gyPartRatio
#print axioms CATEPTMain.Integration.GelfandYaglomInversionAPI.gyPartRatio_ne_zero

-- T-FF Phase 8 (Simplex / FK-like path-integral no-renormalization bridge).
-- Counterterm-free criterion for the entropically damped complex FK-like
-- path integral: an exponential UV-tail bound on the cutoff partition
-- family forces convergence in ℂ to the continuum partition with the
-- counterterm pinned to 0. Three kernel-only corollaries:
--   * tendsto_cutoff_to_continuum                       UV → continuum
--   * counterterm_eq_zero                                no counterterm needed
--   * exponential_uv_tail_implies_no_counterterm_needed  conjunction bridge
#print axioms CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge.CountertermFreeUVLimit.tendsto_cutoff_to_continuum
#print axioms CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge.CountertermFreeUVLimit.counterterm_eq_zero
#print axioms CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge.exponential_uv_tail_implies_no_counterterm_needed

-- T-FF Phase 9 (UV-certificate compatibility bridge).
-- Canonical lift from the pre-existing real-valued
-- `UVConvergenceCertificate` (Modular-flow / Kuchar lane) to the
-- complex Phase-8 `CountertermFreeUVLimit`. Three kernel-only
-- corollaries:
--   * ofUVConvergenceCertificate_continuumPartition_eq_ofReal
--   * ofUVConvergenceCertificate_counterterm_eq_zero
--   * ofUVConvergenceCertificate_no_counterterm_needed
#print axioms CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge.ofUVConvergenceCertificate_continuumPartition_eq_ofReal
#print axioms CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge.ofUVConvergenceCertificate_counterterm_eq_zero
#print axioms CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge.ofUVConvergenceCertificate_no_counterterm_needed

-- T-FF Phase 10 (multimode counterterm-free UV limit).
-- Finite-family extension of Phase 8: a uniform exponential
-- UV-tail bound across an indexed family `ι → (cutoff, continuum)`
-- with shared positive UV scale yields per-index ℂ-convergence
-- and per-index zero counterterm. Three kernel-only corollaries:
--   * MultimodeCountertermFreeUVLimit.tendsto_pointwise
--   * MultimodeCountertermFreeUVLimit.counterterm_zero_pointwise
--   * multimode_exponential_uv_tail_implies_no_counterterm_needed
#print axioms CATEPTMain.Integration.SimplexPathIntegralNoRenormBridgeMulti.MultimodeCountertermFreeUVLimit.tendsto_pointwise
#print axioms CATEPTMain.Integration.SimplexPathIntegralNoRenormBridgeMulti.MultimodeCountertermFreeUVLimit.counterterm_zero_pointwise
#print axioms CATEPTMain.Integration.SimplexPathIntegralNoRenormBridgeMulti.multimode_exponential_uv_tail_implies_no_counterterm_needed

-- T-FF Phase 11 — Entropic-coercivity → UV certificate bridge.
-- Abstract bridge separating physics obligation (coercivity
-- S_I[Φ] ≥ C · ‖Φ‖²_UV) from analysis machinery (spectral tail
-- bound). Three kernel-only corollaries:
--   * coercive_entropic_action_yields_uv_certificate_tail
--   * coercive_entropic_action_yields_uv_certificate_tendsto
--   * coercive_entropic_action_yields_no_counterterm_needed
#print axioms CATEPTMain.Integration.EntropicCoercivityToUVCertificate.coercive_entropic_action_yields_uv_certificate_tail
#print axioms CATEPTMain.Integration.EntropicCoercivityToUVCertificate.coercive_entropic_action_yields_uv_certificate_tendsto
#print axioms CATEPTMain.Integration.EntropicCoercivityToUVCertificate.coercive_entropic_action_yields_no_counterterm_needed

-- T-FF Phase 12 — Complex weight norm = entropic damping.
-- Honest realization of the path-integral phase-norm identity
-- ‖exp(i S_R/ℏ − S_I/ℏ)‖ = exp(−S_I/ℏ): the real action only
-- contributes a phase, so UV size is controlled entirely by
-- the imaginary action. Three kernel-only corollaries:
--   * norm_phase_imaginary_weight
--   * norm_complex_path_weight_eq_real_damping
--   * complex_weight_norm_eq_entropic_damping
#print axioms CATEPTMain.Integration.ComplexWeightNormEntropicDamping.norm_phase_imaginary_weight
#print axioms CATEPTMain.Integration.ComplexWeightNormEntropicDamping.norm_complex_path_weight_eq_real_damping
#print axioms CATEPTMain.Integration.ComplexWeightNormEntropicDamping.complex_weight_norm_eq_entropic_damping

-- Rigorous Complex Feynman-Kac for entropically-damped oscillatory measures.
--   Replaces the long-standing complex_FK_bridge := True / axiom : True
--   placeholders for the catept-physics class.  Rigorous theorems:
--   integrability of the FK integrand under bounded-observable + L¹-damping;
--   norm bound ‖⟨obs⟩‖ ≤ C · partitionFunction;
--   headline complex_FK_rigorous packaging both.
--   Honest scope: rigorous for the entropically-damped class (CAT/EPT
--   physics), NOT the open Glimm-Jaffe oscillatory-measure problem.
#print axioms CATEPTMain.Integration.RigorousComplexFeynmanKac.complexFKExpectation_integrable
#print axioms CATEPTMain.Integration.RigorousComplexFeynmanKac.complexFKExpectation_norm_le
#print axioms CATEPTMain.Integration.RigorousComplexFeynmanKac.complexFKExpectation_bound
#print axioms CATEPTMain.Integration.RigorousComplexFeynmanKac.complex_FK_rigorous

-- T-FF Phase 13 — Counterterm-free absolute convergence.
-- For any Phase-8 CountertermFreeUVLimit, the geometric UV
-- tail dominates the cutoff-to-continuum distances, giving
-- absolute summability — i.e. convergence is achieved by
-- entropic damping, not by counterterm subtraction. Three
-- kernel-only corollaries:
--   * geometric_uv_tail_summable
--   * cutoffPartition_absolutely_convergent
--   * counterterm_free_because_absolute_convergence
#print axioms CATEPTMain.Integration.CountertermFreeAbsoluteConvergence.geometric_uv_tail_summable
#print axioms CATEPTMain.Integration.CountertermFreeAbsoluteConvergence.cutoffPartition_absolutely_convergent
#print axioms CATEPTMain.Integration.CountertermFreeAbsoluteConvergence.counterterm_free_because_absolute_convergence

-- T-FF Phase 14 — Entropic action positivity.
-- Small structural ship recording the physics-side hypothesis
-- S_I[Φ] ≥ 0 with the five canonical sources tagged
-- (viscous / palinstrophy / Fisher / entropy production /
-- modular). Coercivity (Phase 11) strictly refines
-- positivity; positivity alone is insufficient for UV
-- suppression (failure-mode anchor for Phase 15). Five
-- kernel-only corollaries:
--   * entropic_action_nonneg
--   * entropic_action_zero_is_extremal
--   * coercivity_implies_positivity
--   * positivity_alone_insufficient_without_coercivity
#print axioms CATEPTMain.Integration.EntropicActionPositivity.entropic_action_nonneg
#print axioms CATEPTMain.Integration.EntropicActionPositivity.entropic_action_zero_is_extremal
#print axioms CATEPTMain.Integration.EntropicActionPositivity.coercivity_implies_positivity
#print axioms CATEPTMain.Integration.EntropicActionPositivity.positivity_alone_insufficient_without_coercivity

-- Failure-mode broadening (10-target plan target #10 — 4 new anchors,
-- bringing the total to all 5 named failure modes from the plan):
--   * no_spectral_gap_breaks_uv_certificate                      (witness 1/(k+1))
--   * mode_density_beats_damping_breaks_uv_certificate           (witness const 1)
--   * oscillatory_phase_does_not_replace_absolute_convergence    (governing identity)
--   * oscillatory_phase_without_absolute_convergence_witness     (witness form)
--   * non_monotone_or_non_exhaustive_cutoff_breaks_certificate   (witness const 0 ↛ 1)
--   * all_five_failure_modes_anchored                            (capstone tag)
#print axioms CATEPTMain.Integration.EntropicActionPositivity.no_spectral_gap_breaks_uv_certificate
#print axioms CATEPTMain.Integration.EntropicActionPositivity.mode_density_beats_damping_breaks_uv_certificate
#print axioms CATEPTMain.Integration.EntropicActionPositivity.oscillatory_phase_does_not_replace_absolute_convergence
#print axioms CATEPTMain.Integration.EntropicActionPositivity.oscillatory_phase_without_absolute_convergence_witness
#print axioms CATEPTMain.Integration.EntropicActionPositivity.non_monotone_or_non_exhaustive_cutoff_breaks_certificate
#print axioms CATEPTMain.Integration.EntropicActionPositivity.all_five_failure_modes_anchored

-- T-FF P27a — viscous dissipation → EntropicActionCoercive (first sub-task
-- of the P27 umbrella, physics-to-structure derivation).  Retires the
-- axiomatic-carrier status of EntropicActionCoercive for the
-- viscous-dissipation source: a Poincaré-style spectral-gap hypothesis on
-- the UV subspace plus a viscosity ν > 0 produces the coercivity
-- certificate with explicit constant C = ν · k_UV².  Five kernel-only
-- corollaries:
--   * gradNormSq_nonneg — gradient norm-squared ≥ 0 from spectral gap
--   * viscous_action_coercivity — the coercivity inequality itself
--   * viscous_action_im_nonneg — Phase-14 positivity recovered as a
--                                consequence of P27a (no separate carrier)
--   * viscous_dissipation_C_eq — produced certificate's constant = ν · k_UV²
--   * viscous_C_via_constantin_iyer — Constantin-Iyer specialisation
--                                     (ν = ℏ/2 ⟹ C = (ℏ/2)·k_UV²)
#print axioms CATEPTMain.Integration.EntropicCoercivityFromViscousDissipation.ViscousDissipationData.gradNormSq_nonneg
#print axioms CATEPTMain.Integration.EntropicCoercivityFromViscousDissipation.ViscousDissipationData.viscous_action_coercivity
#print axioms CATEPTMain.Integration.EntropicCoercivityFromViscousDissipation.ViscousDissipationData.viscous_action_im_nonneg
#print axioms CATEPTMain.Integration.EntropicCoercivityFromViscousDissipation.viscous_dissipation_C_eq
#print axioms CATEPTMain.Integration.EntropicCoercivityFromViscousDissipation.viscous_C_via_constantin_iyer

-- T-FF P27c — Fisher information → EntropicActionCoercive (third sub-task
-- of the P27 umbrella; quantum-information / log-density incarnation of
-- P27a's viscous coercivity).  Same Poincaré bound applied in log-density
-- coordinates Φ = log p, with the density floor p_min playing the role
-- viscosity ν played in P27a.  Derived constant: C = p_min · k_UV².
-- Five kernel-only corollaries:
--   * gradNormSq_nonneg               (gradient ≥ 0 from spectral gap)
--   * fisher_info_nonneg              (Phase-14 positivity recovered)
--   * fisher_info_coercivity          (the inequality itself)
--   * fisher_C_eq                     (C = p_min · k_UV² definitionally)
--   * fisher_C_via_log_sobolev        (Gross/LSI specialisation, p_min ≥ exp(-Λ))
#print axioms CATEPTMain.Integration.EntropicCoercivityFromFisherInformation.FisherInformationData.gradNormSq_nonneg
#print axioms CATEPTMain.Integration.EntropicCoercivityFromFisherInformation.FisherInformationData.fisher_info_nonneg
#print axioms CATEPTMain.Integration.EntropicCoercivityFromFisherInformation.FisherInformationData.fisher_info_coercivity
#print axioms CATEPTMain.Integration.EntropicCoercivityFromFisherInformation.fisher_C_eq
#print axioms CATEPTMain.Integration.EntropicCoercivityFromFisherInformation.fisher_C_via_log_sobolev

-- T-FF P27b — palinstrophy → EntropicActionCoercive (second sub-task of
-- the P27 umbrella; *higher-degree* sibling of P27a).  Uses the
-- second-order Laplacian ∫|ΔΦ|² (controlling the H² Sobolev seminorm)
-- instead of P27a's first-order gradient.  Spectral floor jumps from
-- k_UV² (P27a) to k_UV⁴ (P27b), giving the stronger UV suppression
-- exp(-ν·k_UV⁴·N²) consistent with NS Stage 73-83 enstrophy Lyapunov
-- chain.  Five kernel-only corollaries:
--   * laplacianNormSq_nonneg            (Laplacian-norm ≥ 0)
--   * palinstrophy_action_coercivity    (the inequality itself)
--   * palinstrophy_action_im_nonneg     (Phase-14 positivity recovered)
--   * palinstrophy_C_eq                 (C = ν · k_UV⁴ definitionally)
--   * palinstrophy_C_via_constantin_iyer (ν = ℏ/2 ⟹ C = (ℏ/2)·k_UV⁴)
#print axioms CATEPTMain.Integration.EntropicCoercivityFromPalinstrophy.PalinstrophyData.laplacianNormSq_nonneg
#print axioms CATEPTMain.Integration.EntropicCoercivityFromPalinstrophy.PalinstrophyData.palinstrophy_action_coercivity
#print axioms CATEPTMain.Integration.EntropicCoercivityFromPalinstrophy.PalinstrophyData.palinstrophy_action_im_nonneg
#print axioms CATEPTMain.Integration.EntropicCoercivityFromPalinstrophy.palinstrophy_C_eq
#print axioms CATEPTMain.Integration.EntropicCoercivityFromPalinstrophy.palinstrophy_C_via_constantin_iyer

-- T-FF P27d — entropy production → EntropicActionCoercive (fourth
-- sub-task of the P27 umbrella; thermodynamic / second-law incarnation
-- of P27a's viscous coercivity).  Onsager quadratic-form structure with
-- positive-definite kinetic matrix L: smallest eigenvalue L_min > 0
-- plays the role viscosity ν played in P27a; same Poincaré bound on the
-- thermodynamic forces (= spatial gradients).  Derived constant:
-- C = L_min · k_UV².  Five kernel-only corollaries:
--   * forceNormSq_nonneg            (force-norm ≥ 0 from spectral gap)
--   * entropy_prod_nonneg           (second law + Phase-14 positivity recovered)
--   * entropy_prod_coercivity       (the inequality itself)
--   * entropy_C_eq                  (C = L_min · k_UV² definitionally)
--   * entropy_C_via_noether_decay   (T100 specialisation: L_min ≥ γ ⟹
--                                    C ≥ γ·k_UV², bridging noether-EPT)
#print axioms CATEPTMain.Integration.EntropicCoercivityFromEntropyProduction.EntropyProductionData.forceNormSq_nonneg
#print axioms CATEPTMain.Integration.EntropicCoercivityFromEntropyProduction.EntropyProductionData.entropy_prod_nonneg
#print axioms CATEPTMain.Integration.EntropicCoercivityFromEntropyProduction.EntropyProductionData.entropy_prod_coercivity
#print axioms CATEPTMain.Integration.EntropicCoercivityFromEntropyProduction.entropy_C_eq
#print axioms CATEPTMain.Integration.EntropicCoercivityFromEntropyProduction.entropy_C_via_noether_decay

-- T-FF P27e — modular Hamiltonian / KMS positivity → EntropicActionCoercive
-- (FIFTH and FINAL sub-task of the P27 umbrella; quantum-field /
-- modular-flow incarnation of the same coercivity story).  Uses
-- Tomita-Takesaki modular Hamiltonian K = -log ρ and its spectral gap
-- K_min > 0 above the ground state.  Derived constant: C = K_min · k_UV².
-- When this lands the EntropicActionCoercive axiomatic-carrier status
-- is RETIRED across all 5 canonical physics sources (viscous /
-- palinstrophy / Fisher / entropy-production / modular).  Five
-- kernel-only corollaries:
--   * thermalDistSq_nonneg          (thermal-distance ≥ 0 from spectral gap)
--   * modular_action_nonneg         (K ≥ 0 + Phase-14 positivity recovered)
--   * modular_action_coercivity     (the inequality itself)
--   * modular_C_eq                  (C = K_min · k_UV² definitionally)
--   * modular_C_via_kms_temperature (KMS specialisation:
--                                    K_min ≥ β·E_min ⟹ C ≥ β·E_min·k_UV²)
#print axioms CATEPTMain.Integration.EntropicCoercivityFromModularHamiltonian.ModularHamiltonianData.thermalDistSq_nonneg
#print axioms CATEPTMain.Integration.EntropicCoercivityFromModularHamiltonian.ModularHamiltonianData.modular_action_nonneg
#print axioms CATEPTMain.Integration.EntropicCoercivityFromModularHamiltonian.ModularHamiltonianData.modular_action_coercivity
#print axioms CATEPTMain.Integration.EntropicCoercivityFromModularHamiltonian.modular_C_eq
#print axioms CATEPTMain.Integration.EntropicCoercivityFromModularHamiltonian.modular_C_via_kms_temperature

-- Geometry/FiniteMinkowski — pure-geometric harvest of Minkowski-on-(Fin 4 → ℝ)
-- primitives from NavierStokesClean/CATEPT/CATEPTSpaceTime.lean.  Mathlib-only,
-- NS-independent.  Provides reusable spacetime carriers, causal-structure
-- predicates, and the no-FTL bound; does NOT include NS-specific velocity
-- fields, GRTensorKernel-bound metric types, or entropic-lapse content
-- (the latter slated for a sibling EntropicLapse.lean).  Five kernel-only
-- corollaries:
--   * causal_trichotomy            (every displacement is timelike/lightlike/spacelike/zero)
--   * timelike_time_dominates      (timelike ⟹ time² > spatial²)
--   * spatialNorm2_nonneg          (sum of squares ≥ 0)
--   * spacelike_of_time_zero       (non-zero with Δx 0 = 0 ⟹ spacelike)
--   * noFTLBound_mono              (NoFTLBound is monotone in the velocity field)
#print axioms CATEPTMain.Geometry.FiniteMinkowski.causal_trichotomy
#print axioms CATEPTMain.Geometry.FiniteMinkowski.timelike_time_dominates
#print axioms CATEPTMain.Geometry.FiniteMinkowski.spatialNorm2_nonneg
#print axioms CATEPTMain.Geometry.FiniteMinkowski.spacelike_of_time_zero
#print axioms CATEPTMain.Geometry.FiniteMinkowski.noFTLBound_mono

-- Geometry/EntropicLapse — §3c harvest: ADM-style lapse-weighted
-- Minkowski geometry.  Lapse N : CATEPTST → ℝ converts coordinate-time
-- intervals to entropic-time intervals via dτ = N dt (canonical
-- N_ent = Ω/(2ν) under Constantin-Iyer ℏ = 2ν).  Builds on
-- FiniteMinkowski; geometric carrier for the path-integral phase-1
-- chain (T-S/T/U/V/W series — heat-semigroup ↔ τ_ent identification)
-- and for the next P28 task (higher-degree T³ tail).  Five kernel-only
-- corollaries:
--   * entropicNorm2_unitLapse              (N=1 reduces to Minkowski)
--   * entropicTimelike_unitLapse_iff       (unit-lapse causal class = standard)
--   * entropicSpacelike_unitLapse_iff      (unit-lapse spacelike = standard)
--   * entropicTimelike_mono                (higher lapse widens timelike cone)
--   * entropicTimelike_velocity_bound      (|v|² < N(x)²: entropic local c)
#print axioms CATEPTMain.Geometry.EntropicLapse.entropicNorm2_unitLapse
#print axioms CATEPTMain.Geometry.EntropicLapse.entropicTimelike_unitLapse_iff
#print axioms CATEPTMain.Geometry.EntropicLapse.entropicSpacelike_unitLapse_iff
#print axioms CATEPTMain.Geometry.EntropicLapse.entropicTimelike_mono
#print axioms CATEPTMain.Geometry.EntropicLapse.entropicTimelike_velocity_bound

-- Integration/QFTCurvedTemporalSpine — first-class spine adapter for
-- QFT-in-curved-space.  Lifts NavierStokesClean's CurvedMeasurePathIntegralModel
-- into the canonical CATEPTMain.Temporal.TemporalFramework, so the universal
-- coherence_spine theorem discharges the CAT/EPT identity actionIm/ℏ = eptClock
-- for free.  Headline: the four-way joint
--   harmonic ⊕ physlib-SR ⊕ qm ⊕ qft-curved
-- composes via JointAdapter and satisfies the same spine.  Five kernel-only
-- corollaries:
--   * curvedMTPI_clock_eq_actionImScaled         (clock = actionIm / ℏ)
--   * curvedMTPI_clock_nonneg                    (named lemma)
--   * curvedMTPI_satisfies_spine                 (the headline)
--   * qm_classical_sr_qft_curved_joint_satisfies_spine
--                                                (4-way joint compose)
#print axioms CATEPTMain.Integration.curvedMTPI_clock_eq_actionImScaled
#print axioms CATEPTMain.Integration.curvedMTPI_clock_nonneg
#print axioms CATEPTMain.Integration.curvedMTPI_satisfies_spine
#print axioms CATEPTMain.Integration.qm_classical_sr_qft_curved_joint_satisfies_spine

-- Integration/CATEPTSTAdapter — spacetime-harvest step 3.  Bridges
-- CATEPTMain.Geometry.FiniteMinkowski.CATEPTST into the canonical
-- CATEPTMain.Integration.CATEPTSpacetimeModel via a vacuum-tier instance
-- (lorentzMetric := minkowskiNorm2 (y-x), ept ≡ 0).  After this the
-- harvested geometry is end-to-end usable: pure-geometry → adapter →
-- canonical-spine theorems.  Three kernel-only corollaries:
--   * finiteMinkowski_lorentzMetric_eq_minkowskiNorm2  (definitional)
--   * finiteMinkowski_ept_eq_zero                       (vacuum tier)
--   * finiteMinkowski_satisfies_ept_axioms              (HEADLINE)
#print axioms CATEPTMain.Integration.CATEPTSTAdapter.finiteMinkowski_lorentzMetric_eq_minkowskiNorm2
#print axioms CATEPTMain.Integration.CATEPTSTAdapter.finiteMinkowski_ept_eq_zero
#print axioms CATEPTMain.Integration.CATEPTSTAdapter.finiteMinkowski_satisfies_ept_axioms

-- Integration/MISNoFTLBridge — spacetime-harvest step 4.  NS-specific
-- bridge composing EntropicLapse (PR #18) + palinstrophy coercivity
-- (P27b, PR #14) + no-FTL bound (FiniteMinkowski PR #17) into a
-- single MISNoFTLData carrier with coercivity constant C = ν · k_UV⁴
-- (inherited from palinstrophy).  Bridges the geometry harvest chain
-- to the path-integral coercivity chain at the structural level; the
-- supplies_P28_d4_rate theorem records the rate that will enter the
-- open P28 task (higher-degree T³ tail at d = 4).  Five kernel-only
-- corollaries:
--   * coercivityConstant_pos                  (positivity inherited)
--   * MIS_C_eq_palinstrophy_C                 (C = palinstrophy.C)
--   * noFTL_and_coercivity_compatible         (joint structural anchor)
--   * supplies_P28_d4_rate                    (P28 hookup)
#print axioms CATEPTMain.Integration.MISNoFTLBridge.MISNoFTLData.coercivityConstant_pos
#print axioms CATEPTMain.Integration.MISNoFTLBridge.MISNoFTLData.MIS_C_eq_palinstrophy_C
#print axioms CATEPTMain.Integration.MISNoFTLBridge.MISNoFTLData.noFTL_and_coercivity_compatible
#print axioms CATEPTMain.Integration.MISNoFTLBridge.MISNoFTLData.supplies_P28_d4_rate

-- Integration/SpacetimeHarvestCatalog — spacetime-harvest step 5
-- (provenance index).  Kernel-only catalog of all 5 steps with
-- HarvestEntry data + catalog_complete + catalog_in_step_order
-- audit anchors.  Greppable provenance trail for future helpers.
#print axioms CATEPTMain.Integration.SpacetimeHarvestCatalog.catalog_complete
#print axioms CATEPTMain.Integration.SpacetimeHarvestCatalog.catalog_in_step_order

-- T-FF Phase 15: PhysicalUVConvergenceCertificate — physical instantiation of
--   the abstract Phase-7 UVConvergenceCertificate by packaging the four named
--   physics inputs (#1 cutoff family, #4 coercivity, #5 Stokes spectrum,
--   #6 exponential tail) into a PhysicalEntropicModel and discharging via the
--   P11 bridge. Closes the dependency graph at the structural level.
--   * physical_uv_certificate_tail
--   * physical_uv_certificate_tendsto
--   * physical_uv_certificate_strength_eq_coercivity
--   * physical_uv_certificate_high_mode_tail_eq
--   * physical_uv_certificate_no_counterterm_needed
#print axioms CATEPTMain.Integration.PhysicalUVConvergenceCertificate.physical_uv_certificate_tail
#print axioms CATEPTMain.Integration.PhysicalUVConvergenceCertificate.physical_uv_certificate_tendsto
#print axioms CATEPTMain.Integration.PhysicalUVConvergenceCertificate.physical_uv_certificate_strength_eq_coercivity
#print axioms CATEPTMain.Integration.PhysicalUVConvergenceCertificate.physical_uv_certificate_high_mode_tail_eq
#print axioms CATEPTMain.Integration.PhysicalUVConvergenceCertificate.physical_uv_certificate_no_counterterm_needed

-- T-FF Phase 16: CanonicalEntropicModel — concrete term-level witness that
--   PhysicalEntropicModel is non-vacuous. Canonical numerical choices:
--   C := 1, α := 2 (Stokes Laplacian), Z_∞ := 0, Z_N := exp(-N).
--   Locks each numerical choice to its field name and produces a concrete
--   UVConvergenceCertificate witness with the no-counterterm conjunction.
--   * canonicalModel_C_eq_one
--   * canonicalModel_alpha_eq_two
--   * canonicalModel_Z_inf_eq_zero
--   * canonicalModel_Z_N_eq
--   * canonicalCertificate_strength_eq_one
--   * canonicalCertificate_no_counterterm_needed
#print axioms CATEPTMain.Integration.CanonicalEntropicModel.canonicalModel_C_eq_one
#print axioms CATEPTMain.Integration.CanonicalEntropicModel.canonicalModel_alpha_eq_two
#print axioms CATEPTMain.Integration.CanonicalEntropicModel.canonicalModel_Z_inf_eq_zero
#print axioms CATEPTMain.Integration.CanonicalEntropicModel.canonicalModel_Z_N_eq
#print axioms CATEPTMain.Integration.CanonicalEntropicModel.canonicalCertificate_strength_eq_one
#print axioms CATEPTMain.Integration.CanonicalEntropicModel.canonicalCertificate_no_counterterm_needed

-- T-FF Phase 17: StokesEntropicModel — Stokes-spectral concrete witness
--   refining canonicalModel by promoting α=2 from passive tag to active
--   quadratic law in the cutoff: Z_N := exp(-N^2). Tail bound holds with
--   C=1 since (N:ℝ)^2 ≥ (N:ℝ) for all N : ℕ.
--   * stokesModel_C_eq_one
--   * stokesModel_alpha_eq_two
--   * stokesModel_Z_inf_eq_zero
--   * stokesModel_Z_N_eq
--   * stokesCertificate_strength_eq_one
--   * stokesCertificate_no_counterterm_needed
#print axioms CATEPTMain.Integration.StokesEntropicModel.stokesModel_C_eq_one
#print axioms CATEPTMain.Integration.StokesEntropicModel.stokesModel_alpha_eq_two
#print axioms CATEPTMain.Integration.StokesEntropicModel.stokesModel_Z_inf_eq_zero
#print axioms CATEPTMain.Integration.StokesEntropicModel.stokesModel_Z_N_eq
#print axioms CATEPTMain.Integration.StokesEntropicModel.stokesCertificate_strength_eq_one
#print axioms CATEPTMain.Integration.StokesEntropicModel.stokesCertificate_no_counterterm_needed

-- T-FF Phase 18: UVCertificateFailureModes — structural failure-mode audit
--   closing the T-FF plan. Enumerates the five canonical failure modes for
--   the four named physics inputs of PhysicalEntropicModel and pins each to
--   the structural field it would invalidate via a total lookup function
--   `affectedField`. Five rfl-level lookup theorems plus length witness.
--   * affectedField_actionMerelyNonneg_eq_coercivity
--   * affectedField_noSpectralGap_eq_spectral
--   * affectedField_highModeDensityBeatsDamping_eq_exponentialTailBound
--   * affectedField_oscillatoryPhaseNonAbsolute_eq_cutoff
--   * affectedField_cutoffFamilyNonExhaustive_eq_tendsToContinuum
--   * failureModes_length
#print axioms CATEPTMain.Integration.UVCertificateFailureModes.affectedField_actionMerelyNonneg_eq_coercivity
#print axioms CATEPTMain.Integration.UVCertificateFailureModes.affectedField_noSpectralGap_eq_spectral
#print axioms CATEPTMain.Integration.UVCertificateFailureModes.affectedField_highModeDensityBeatsDamping_eq_exponentialTailBound
#print axioms CATEPTMain.Integration.UVCertificateFailureModes.affectedField_oscillatoryPhaseNonAbsolute_eq_cutoff
#print axioms CATEPTMain.Integration.UVCertificateFailureModes.affectedField_cutoffFamilyNonExhaustive_eq_tendsToContinuum
#print axioms CATEPTMain.Integration.UVCertificateFailureModes.failureModes_length

-- T-FF Phase 19: SpectralSumPartition — first concrete spectral-sum partition.
--   Z_N := ∑_{k<N} exp(-k²), Z_∞ := ∑' k, exp(-k²) on the 1D integer lattice.
--   Replaces the toy P16/P17 scalar cutoffs with a real summable spectral series
--   (proven summable via comparison with geometric (exp(-1))^k).
--   * summable_spectralTerm — proven Summable
--   * tendsto_Z_N_atTop_Z_inf — genuine continuum convergence via HasSum.tendsto_sum_nat
--   * Z_N_le_Z_inf — partial-sum monotonicity
--   * Z_inf_pos — strict positivity (Z_∞ ≥ spectralTerm 0 = 1)
--   * Z_inf_sub_Z_N_eq_tsum_shift — residual identity for the high-mode tail
--   * spectralTerm_zero_eq_one — normalization
#print axioms CATEPTMain.Integration.SpectralSumPartition.summable_spectralTerm
#print axioms CATEPTMain.Integration.SpectralSumPartition.tendsto_Z_N_atTop_Z_inf
#print axioms CATEPTMain.Integration.SpectralSumPartition.Z_N_le_Z_inf
#print axioms CATEPTMain.Integration.SpectralSumPartition.Z_inf_pos
#print axioms CATEPTMain.Integration.SpectralSumPartition.Z_inf_sub_Z_N_eq_tsum_shift
#print axioms CATEPTMain.Integration.SpectralSumPartition.spectralTerm_zero_eq_one

-- T-FF Phase 20: RealSpectralEntropicModel — first non-toy PhysicalEntropicModel.
--   Built from the P19 1-D Stokes-spectral series ∑' k, exp(-k²). Tail bound
--   |Z_∞ - Z_N| ≤ exp(-N) · Z_∞ via (k+N)² ≥ k²+N² and N² ≥ N. Normalized to
--   Z_∞^norm = 1 to fit the abstract record's `exp(-C·N)` shape with C := 1.
--   * realSpectralModel — the PhysicalEntropicModel record
--   * realSpectralCertificate — the resulting UVConvergenceCertificate
--   * realSpectralModel_C_eq_one, realSpectralModel_alpha_eq_two
--   * realSpectralModel_Z_inf_eq_one (= 1, not 0 as in P16/P17)
--   * realSpectralModel_Z_N_eq (= Z_N / Z_∞)
--   * realSpectralCertificate_strength_eq_one,
--     realSpectralCertificate_no_counterterm_needed
#print axioms CATEPTMain.Integration.RealSpectralEntropicModel.realSpectralModel_C_eq_one
#print axioms CATEPTMain.Integration.RealSpectralEntropicModel.realSpectralModel_alpha_eq_two
#print axioms CATEPTMain.Integration.RealSpectralEntropicModel.realSpectralModel_Z_inf_eq_one
#print axioms CATEPTMain.Integration.RealSpectralEntropicModel.realSpectralModel_Z_N_eq
#print axioms CATEPTMain.Integration.RealSpectralEntropicModel.realSpectralCertificate_strength_eq_one
#print axioms CATEPTMain.Integration.RealSpectralEntropicModel.realSpectralCertificate_no_counterterm_needed

-- T-FF Phase 21: T3SpectralPartition — 3-D extension of the spectral sum.
--   Positive Fourier cone of T³, λ_k = k₁²+k₂²+k₃². The cube cutoff factorizes
--   as the third power of the 1-D cutoff: Z_N^{T³} = (Z_N)³, Z_∞^{T³} = (Z_∞)³.
--   * spectralTerm3D_factor — triple product factorization
--   * summable_spectralTerm3D — 3-D summability via Summable.mul_of_nonneg ×2
--   * Z_N_3D_eq_Z_N_pow — cube cutoff = (Z_N)³
--   * Z_inf_3D_eq_Z_inf_pow — continuum value = Z_∞³
--   * tendsto_Z_N_3D_atTop_Z_inf_3D — continuum convergence
--   * Z_inf_3D_pos
#print axioms CATEPTMain.Integration.T3SpectralPartition.spectralTerm3D_factor
#print axioms CATEPTMain.Integration.T3SpectralPartition.summable_spectralTerm3D
#print axioms CATEPTMain.Integration.T3SpectralPartition.Z_N_3D_eq_Z_N_pow
#print axioms CATEPTMain.Integration.T3SpectralPartition.Z_inf_3D_eq_Z_inf_pow
#print axioms CATEPTMain.Integration.T3SpectralPartition.tendsto_Z_N_3D_atTop_Z_inf_3D
#print axioms CATEPTMain.Integration.T3SpectralPartition.Z_inf_3D_pos

-- T-FF Phase 22: T3TailBound — explicit multiplicative tail bound on T³.
--   |Z_∞^{T³} - Z_N^{T³}| ≤ 3 · Z_∞^{T³} · exp(-N), via the algebraic identity
--   a³ - b³ = (a - b)(a² + ab + b²) and the P20 1-D bound. Packaged as a
--   `MultiplicativeUVTail` record with M = 3·Z_∞^{T³}, C = 1.
--   * cube_residual_factorization
--   * Z_inf_pow_three_sub_Z_N_pow_three_le — the elementary 3-D bound
--   * abs_Z_N_3D_sub_Z_inf_3D_le — absolute form
--   * t3_tail_C_eq_one, t3_tail_M_eq
--   * t3_tail_bound_holds, t3_tail_tendsto
#print axioms CATEPTMain.Integration.T3TailBound.cube_residual_factorization
#print axioms CATEPTMain.Integration.T3TailBound.Z_inf_pow_three_sub_Z_N_pow_three_le
#print axioms CATEPTMain.Integration.T3TailBound.abs_Z_N_3D_sub_Z_inf_3D_le
#print axioms CATEPTMain.Integration.T3TailBound.t3_tail_C_eq_one
#print axioms CATEPTMain.Integration.T3TailBound.t3_tail_M_eq
#print axioms CATEPTMain.Integration.T3TailBound.t3_tail_bound_holds
#print axioms CATEPTMain.Integration.T3TailBound.t3_tail_tendsto

-- T-FF Phase 23: LatticeActionDerivation — structural connection of
--   (α, C) = (2, 1) to a quadratic lattice action S(k) = k² (1-D) and
--   S(k₁,k₂,k₃) = k₁²+k₂²+k₃² (3-D). LatticeAction record packaging
--   (actionDegree, coercivityConstant). Audit theorems show that the
--   realized lattice actions agree with realSpectralGrowth /
--   realCoercivity (P20) and t3_multiplicative_tail (P22).
#print axioms CATEPTMain.Integration.LatticeActionDerivation.realLatticeAction1D_degree_eq_spectralGrowth
#print axioms CATEPTMain.Integration.LatticeActionDerivation.realLatticeAction1D_coercivity_eq_C
#print axioms CATEPTMain.Integration.LatticeActionDerivation.realLatticeAction1D_coercivity_eq_t3_tail_C
#print axioms CATEPTMain.Integration.LatticeActionDerivation.realLatticeAction3D_degree_eq_1D
#print axioms CATEPTMain.Integration.LatticeActionDerivation.realLatticeAction3D_coercivity_eq_1D
#print axioms CATEPTMain.Integration.LatticeActionDerivation.realLatticeAction3D_coercivity_eq_t3_tail_C
#print axioms CATEPTMain.Integration.LatticeActionDerivation.realLatticeAction1D_degree_eq_two
#print axioms CATEPTMain.Integration.LatticeActionDerivation.realLatticeAction1D_coercivity_eq_one
#print axioms CATEPTMain.Integration.LatticeActionDerivation.realLatticeAction3D_degree_eq_two
#print axioms CATEPTMain.Integration.LatticeActionDerivation.realLatticeAction3D_coercivity_eq_one

-- T-FF Phase 24: T3PhysicalEntropicModel — closes the deferred P22
--   PhysicalEntropicModel instantiation via index shift N ↦ N+2,
--   yielding a constant-free tail bound and (α,C) = (2,1).
#print axioms CATEPTMain.Integration.T3PhysicalEntropicModel.three_mul_exp_neg_two_le_one
#print axioms CATEPTMain.Integration.T3PhysicalEntropicModel.abs_shifted_sub_one_le
#print axioms CATEPTMain.Integration.T3PhysicalEntropicModel.tendsto_shiftedZ_N_atTop_one
#print axioms CATEPTMain.Integration.T3PhysicalEntropicModel.t3PhysicalModel_tendsto
#print axioms CATEPTMain.Integration.T3PhysicalEntropicModel.t3PhysicalModel_C_eq_one
#print axioms CATEPTMain.Integration.T3PhysicalEntropicModel.t3PhysicalModel_alpha_eq_two

-- T-FF Phase 25: ParametricLatticeAction — one-parameter family
--   S_a(k) = a · k² with shift-coercivity S_a(k+N) ≥ S_a(k) + a·N²;
--   generalizes P23 from the unit (a=1) action to arbitrary a > 0.
#print axioms CATEPTMain.Integration.ParametricLatticeAction.paramAction_shift_coercivity
#print axioms CATEPTMain.Integration.ParametricLatticeAction.paramAction_unit_eq_realLatticeAction1D
#print axioms CATEPTMain.Integration.ParametricLatticeAction.paramLatticeAction_unit_degree
#print axioms CATEPTMain.Integration.ParametricLatticeAction.paramLatticeAction_unit_coercivity
#print axioms CATEPTMain.Integration.ParametricLatticeAction.paramLatticeAction_degree_eq_two
#print axioms CATEPTMain.Integration.ParametricLatticeAction.paramLatticeAction_coercivity_eq_a
#print axioms CATEPTMain.Integration.ParametricLatticeAction.paramLatticeAction_shift_coercivity
#print axioms CATEPTMain.Integration.ParametricLatticeAction.paramLatticeAction_unit_degree_eq_two
#print axioms CATEPTMain.Integration.ParametricLatticeAction.paramLatticeAction_unit_coercivity_eq_one

-- T-FF Phase 26: HigherDegreeLatticeAction — two-parameter family
--   S_{a,d}(k) = a · k^d (a > 0, d ≥ 1) with shift-coercivity
--   S_{a,d}(k+N) ≥ S_{a,d}(k) + a·N^d. Uses super-additivity
--   (x+y)^d ≥ x^d + y^d on [0,∞) for d ≥ 1. Specializes:
--   d=2 ↦ P25, (a=1,d=2) ↦ P23.
#print axioms CATEPTMain.Integration.HigherDegreeLatticeAction.add_pow_ge_pow_add_pow
#print axioms CATEPTMain.Integration.HigherDegreeLatticeAction.higherAction_shift_coercivity
#print axioms CATEPTMain.Integration.HigherDegreeLatticeAction.higherAction_ofParametric_eq
#print axioms CATEPTMain.Integration.HigherDegreeLatticeAction.higherLatticeAction_ofParametric_degree
#print axioms CATEPTMain.Integration.HigherDegreeLatticeAction.higherLatticeAction_ofParametric_coercivity
#print axioms CATEPTMain.Integration.HigherDegreeLatticeAction.higherAction_unit_eq_realLatticeAction1D
#print axioms CATEPTMain.Integration.HigherDegreeLatticeAction.higherLatticeAction_unit_degree
#print axioms CATEPTMain.Integration.HigherDegreeLatticeAction.higherLatticeAction_unit_coercivity
#print axioms CATEPTMain.Integration.HigherDegreeLatticeAction.higherLatticeAction_shift_coercivity
#print axioms CATEPTMain.Integration.HigherDegreeLatticeAction.higherLatticeAction_unit_degree_eq_two
#print axioms CATEPTMain.Integration.HigherDegreeLatticeAction.higherLatticeAction_unit_coercivity_eq_one

-- T-FF Phase 28: HigherDegreeT3Tail — analysis-side companion to P26's
--   action-side parametric S_{a,d}(k) = a · k^d.  Linear-majorant first
--   cut: exp(-(a · k^d)) ≤ exp(-(a · k)) for k : ℕ, d ≥ 1, a ≥ 0.
--   This lets P22's cube-factorization carry through to the higher-
--   degree spectral action with rate `a` in place of `1`, at the cost
--   of weakening the decay from `exp(-a·N^d)` to `exp(-a·N)`.
--   The MISNoFTLBridge.MISNoFTLData.supplies_P28_d4_rate anchor records
--   the rate `ν · k_UV⁴` that this module's tail bound consumes at d=4.
--   Sharper `exp(-a·N^d)` decay rate at d ≥ 2 remains queued as future work.
#print axioms CATEPTMain.Integration.HigherDegreeT3Tail.Nat.le_pow_self_of_one_le_exp
#print axioms CATEPTMain.Integration.HigherDegreeT3Tail.Real.natCast_le_pow_self_of_one_le_exp
#print axioms CATEPTMain.Integration.HigherDegreeT3Tail.exp_neg_pow_le_exp_neg_of_one_le_exp
#print axioms CATEPTMain.Integration.HigherDegreeT3Tail.exp_neg_pow_le_exp_neg_d2
#print axioms CATEPTMain.Integration.HigherDegreeT3Tail.exp_neg_pow_le_exp_neg_d4
#print axioms CATEPTMain.Integration.HigherDegreeT3Tail.HigherDegreeT3LinearMajorantTailExists

-- T-FF Phase 28b: HigherDegreeT3TailSharp — sharper exp(-a·N^d) decay
--   rate via the convexity / mean-value inequality m^d - N^d ≥
--   d · N^(d-1) · (m - N).  Upgrades P28's linear-majorant first cut
--   to the optimal decay rate at higher d.
--   Foundational lemmas: pow_succ_sub_pow_succ_ge_mul, pow_sub_pow_ge_mul.
--   Headline: exp_neg_pow_le_exp_neg_pow_at_N_of_one_le_exp.
--   Structural carrier: HigherDegreeT3SharpTailExists.
#print axioms CATEPTMain.Integration.HigherDegreeT3TailSharp.pow_succ_sub_pow_succ_ge_mul
#print axioms CATEPTMain.Integration.HigherDegreeT3TailSharp.pow_sub_pow_ge_mul
#print axioms CATEPTMain.Integration.HigherDegreeT3TailSharp.exp_neg_pow_le_exp_neg_pow_at_N_of_one_le_exp
#print axioms CATEPTMain.Integration.HigherDegreeT3TailSharp.HigherDegreeT3SharpTailExists
#print axioms CATEPTMain.Integration.HigherDegreeT3TailSharp.exp_neg_pow_le_exp_neg_pow_at_N_d1

-- EntropicGreenFunctionBridge (Phase 1) — operator-theoretic companion
--   to the no-renormalization chain.  Re-reads Laplace-transform /
--   Green-function machinery through the entropic clock dτ = λ dt.
--   Constant-rate algebraic identity at the heart of the resolvent-
--   scaling formula R_τ(s) = lam · R_t(lam · s).
#print axioms CATEPTMain.Integration.EntropicGreenFunctionBridge.entropicTimeOfGeometric_eq_dtau
#print axioms CATEPTMain.Integration.EntropicGreenFunctionBridge.entropic_laplace_weight_const_rate
#print axioms CATEPTMain.Integration.EntropicGreenFunctionBridge.entropic_complex_laplace_weight_const_rate
#print axioms CATEPTMain.Integration.EntropicGreenFunctionBridge.entropicResolventScaling_exists
#print axioms CATEPTMain.Integration.EntropicGreenFunctionBridge.EntropicResolventScaling.laplace_weight_const_rate
#print axioms CATEPTMain.Integration.EntropicGreenFunctionBridge.entropicResolventScaling_zero_operator

-- LaplaceTransformBridge: AFP Laplace_Transform → Lean4 surface (Stokes
-- resolvent etc).  Audit line included so future Mathlib API drift is
-- caught at showcase build time (this file was previously not imported
-- by the showcase, allowing Complex.abs / HasDerivAt drift to slip
-- under the radar — fixed in PR #36).
-- The `CATEPTMain.Transforms.LaplaceTransformBridge` module that previously
-- provided `HasLaplace`, `ExponentialOrder`, `ns_stokes_resolvent_anchor`,
-- and `stokes_constant_seed_laplace_clock_invariance` was retired in the
-- Category-A axiom sweep (it was an AFP port stub holding 7 axioms with
-- no live downstream consumers).  The corresponding `#print axioms`
-- entries are removed from this showcase.

-- Step 4: Heat-semigroup → Green-function bridge.
--   For a Gaussian mode of action coefficient a > 0:
--     ∫₀^∞ heatMode a t dt = 1/(2 a) = entropicProperTime a.
--   Closes step 4 of the user's Green-function-bridge ladder
--   (Green = integrated entropic heat semigroup at the single-mode level).
#print axioms CATEPTMain.Integration.EntropicGreenFromHeatSemigroup.heatMode_integral_Ioi_eq_inv_two_mul
#print axioms CATEPTMain.Integration.EntropicGreenFromHeatSemigroup.green_function_eq_entropicProperTime

-- Step 5: Green damping → UV / no-renormalization chain.
--   At the Gaussian-mode level, exposes the sequential identification
--     Green ↔ ∫heat ↔ τ(a) ↔ exp(−τ(a)) ↔ damping ∈ (0,1]
--   in one theorem boundary.  Closes step 5 of the user's ladder.
#print axioms CATEPTMain.Integration.GreenDampingUVChain.green_to_uv_damping_chain
#print axioms CATEPTMain.Integration.GreenDampingUVChain.green_damping_weight_bounded

-- Step 5b: Multimode lift of the Green-damping chain.
--   Lifts the per-mode damping shape (0, 1] to a finite product of
--   Gaussian modes (the spectral side of T3SpectralPartition's
--   cube cutoff).  Closes the multimode finite-cutoff level of the
--   user's Green-function-bridge ladder.
#print axioms CATEPTMain.Integration.GreenDampingUVChainMultimode.multimode_green_damping_pos
#print axioms CATEPTMain.Integration.GreenDampingUVChainMultimode.multimode_green_damping_le_one
#print axioms CATEPTMain.Integration.GreenDampingUVChainMultimode.multimode_green_damping_bounded

-- Spectral-term ↔ heat-mode bridge.  Pure parametrization identity
-- linking T3SpectralPartition (Stokes-spectral side) to
-- HeatSemigroupEntropicTime (heat-semigroup / Green-function side).
-- Closes the loop between the two infrastructure layers that use the
-- same Gaussian factor under different parametrizations.
#print axioms CATEPTMain.Integration.SpectralTermHeatModeBridge.spectralTerm_eq_heatMode_at_unit_action
#print axioms CATEPTMain.Integration.SpectralTermHeatModeBridge.spectralTerm3D_eq_heatMode_sum_of_squares
#print axioms CATEPTMain.Integration.SpectralTermHeatModeBridge.Z_N_eq_heatMode_partial_sum
#print axioms CATEPTMain.Integration.SpectralTermHeatModeBridge.Z_inf_eq_heatMode_tsum
#print axioms CATEPTMain.Integration.SpectralTermHeatModeBridge.Z_N_3D_eq_heatMode_partial_sum_cube
#print axioms CATEPTMain.Integration.SpectralTermHeatModeBridge.Z_inf_3D_eq_heatMode_tsum_cube
#print axioms CATEPTMain.Integration.SpectralTermHeatModeBridge.heatMode_at_unit_action_pos
#print axioms CATEPTMain.Integration.SpectralTermHeatModeBridge.heatMode_at_unit_action_le_one
#print axioms CATEPTMain.Integration.SpectralTermHeatModeBridge.stokes_spectral_cube_chain

-- Step 6 (first sub-step): state-dependent entropic-time integral.
--   τ(t) := ∫₀^t rate(σ) dσ, with the constant-rate case recovering
--   CFLClock.dtauFromDt.  Smallest defensible scaffold for non-autonomous
--   entropic propagators; remaining state-dependent operator-side
--   infrastructure (time-ordered exponential) is Phase 2.
#print axioms CATEPTMain.Integration.EntropicTimeIntegralStateDependent.entropicTimeIntegral_zero
#print axioms CATEPTMain.Integration.EntropicTimeIntegralStateDependent.entropicTimeIntegral_constant
#print axioms CATEPTMain.Integration.EntropicTimeIntegralStateDependent.entropicTimeIntegral_constant_eq_dtauFromDt
#print axioms CATEPTMain.Integration.EntropicTimeIntegralStateDependent.entropicTimeIntegral_nonneg_of_nonneg_rate
#print axioms CATEPTMain.Integration.EntropicTimeIntegralStateDependent.entropicTimeIntegral_nonneg_of_pos_rate
#print axioms CATEPTMain.Integration.EntropicTimeIntegralStateDependent.entropicTimeIntegral_mono_of_nonneg_rate
#print axioms CATEPTMain.Integration.EntropicTimeIntegralStateDependent.entropicTimeIntegral_add
#print axioms CATEPTMain.Integration.EntropicTimeIntegralStateDependent.entropicTimeIntegral_const_mul

-- Fisher–Lawvere event-cost bridge.  Adapter layer wiring three pieces
-- from external advisor analyses into the session-30 chain:
-- LawvereCost (with triangle inequality + damping shape (0,1]),
-- FisherRateCarrier (plugs into entropicTimeIntegral and inherits
-- non-negativity / monotonicity automatically), and KLLocalQuadraticExpansion
-- (Phase-1 contract for D_KL ≈ ½·g_F(dθ,dθ) + O(|dθ|³)).
#print axioms CATEPTMain.Integration.FisherLawvereEventCostBridge.LawvereCost.damping_bounded
#print axioms CATEPTMain.Integration.FisherLawvereEventCostBridge.LawvereCost.damping_submultiplicative
#print axioms CATEPTMain.Integration.FisherLawvereEventCostBridge.FisherRateCarrier.entropicTimeIntegral_nonneg
#print axioms CATEPTMain.Integration.FisherLawvereEventCostBridge.FisherRateCarrier.entropicTimeIntegral_mono
#print axioms CATEPTMain.Integration.FisherLawvereEventCostBridge.KLLocalQuadraticExpansion.klDivergence_zero_le_zero

-- Imaginary-action / dissipation-rate dictionary.  Tier-1 PR #3 from
-- the Fisher-Rao / Lawvere advisor inspection.  Carefully respects
-- the user's "no information time" correction by keeping THREE
-- distinct named layers: imaginary-action accumulation (S_I/ℏ),
-- entropic proper time (catept τ_ent), and KMS modular-flow parameter
-- (Δs_KMS = 1/γ_I).  Identification across layers is an explicit
-- bridge contract (IdentifyEntropicProperTimeWithImaginaryAction),
-- not a free-standing equation.
#print axioms CATEPTMain.Integration.ImaginaryActionDissipationDictionary.dissipation_energy_eq_hbar_mul_rate
#print axioms CATEPTMain.Integration.ImaginaryActionDissipationDictionary.imaginaryActionAccumulation_initial
#print axioms CATEPTMain.Integration.ImaginaryActionDissipationDictionary.imaginaryActionAccumulation_nonneg_of_pos_rate
#print axioms CATEPTMain.Integration.ImaginaryActionDissipationDictionary.kmsStripWidth_pos
#print axioms CATEPTMain.Integration.ImaginaryActionDissipationDictionary.kmsStripWidth_eq_hbar_div_dissipation_energy
#print axioms CATEPTMain.Integration.ImaginaryActionDissipationDictionary.IdentifyEntropicProperTimeWithImaginaryAction.tauEnt_zero

-- Tier-2 PR #1 from review-equations.md: Tolman dissipation-rate redshift.
-- Algebraic identity γ_I^∞(x) = N(x) · γ_I^loc(x) (and same for β̃_I);
-- standard Tolman temperature redshift T_loc = T_∞ / N(x).
-- Honest scope: algebraic only; no new physics derivations.
#print axioms CATEPTMain.Integration.TolmanDissipationRedshiftBridge.gammaI_redshift_pos
#print axioms CATEPTMain.Integration.TolmanDissipationRedshiftBridge.betaTildeI_redshift_eq_hbar_mul_gammaI_redshift
#print axioms CATEPTMain.Integration.TolmanDissipationRedshiftBridge.Tloc_redshift_pos

-- Tier-2 PR #2: KMS / modular-flow parameter bridge.  The strip
-- width Δs_KMS = 1/γ_I is a SEPARATE layer from entropic proper time;
-- identification requires the explicit IdentifyKMSStripWithEntropicProperTime
-- carrier.  Includes a note theorem documenting that without the
-- carrier, the two layers do not coincide.
#print axioms CATEPTMain.Integration.KMSModularParameterBridge.kmsStripWidth_eq
#print axioms CATEPTMain.Integration.KMSModularParameterBridge.kmsStripWidth_pos
#print axioms CATEPTMain.Integration.KMSModularParameterBridge.kms_strip_separate_from_entropicProperTime
#print axioms CATEPTMain.Integration.KMSModularParameterBridge.IdentifyKMSStripWithEntropicProperTime.tauEnt_eq_inv_rate
#print axioms CATEPTMain.Integration.KMSModularParameterBridge.IdentifyKMSStripWithEntropicProperTime.tauEnt_pos_of_pos_rate

-- Tier-2 PR #3: Relative-entropy production bridge.  Carrier struct
-- with S_rel monotone-decreasing + production rate non-negative; sign-
-- flipped info-form bookkeeping (S_info = −k_B · S_rel monotone-increasing).
-- Honest scope: scalar/abstract carrier; Radon-Nikodym + density-function
-- formalisation deferred (multi-PR, needs Mathlib infrastructure).
#print axioms CATEPTMain.Integration.RelativeEntropyProductionBridge.RelativeEntropyProduction.exists_trivial
#print axioms CATEPTMain.Integration.RelativeEntropyProductionBridge.RelativeEntropyProduction.info_form_monotone_increasing
#print axioms CATEPTMain.Integration.RelativeEntropyProductionBridge.RelativeEntropyProduction.prod_nonneg_at

-- Tier-2 PR #4: GKSL information-exchange bridge.  Scalar carrier for
-- the Lindblad/GKSL operational form: H_eff = H_R - i·ℏ·γ_I·V (effective
-- non-Hermitian Hamiltonian) and L_V = √(2·γ_I·V) (jump-operator
-- intensity).  Honest scope: scalar/abstract carrier; operator-valued
-- GKSL semigroups need MarkovSemigroups wiring (Tier-3).
#print axioms CATEPTMain.Integration.GKSLInformationExchangeBridge.H_eff_imag_eq_neg_betaTildeI_mul_V
#print axioms CATEPTMain.Integration.GKSLInformationExchangeBridge.jumpOpIntensity_nonneg
#print axioms CATEPTMain.Integration.GKSLInformationExchangeBridge.jumpOpIntensity_squared
#print axioms CATEPTMain.Integration.GKSLInformationExchangeBridge.GKSLChannel.jumpOpIntensity_nonneg

-- Local Fisher entropic-generator bridge.  Three-component decomposition
-- H_I = ℏ λ_KMS + ℏ c_α ∂₀ I_α + η I_F^σ[ρ;x] consolidating PRs #51, #60-#63
-- per docs/intake/fisher-rao-lawvere-3-coverage-map.md.  Carriers:
-- ThreeComponentImaginaryGenerator, ThreeComponentRate, LocalFisherRate,
-- CenteredImaginaryGenerator (norm-preserving), QRFClassification (λ_QRF
-- equilibrium criterion), MixedBracketCompatibility (open theorem target).
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.ThreeComponentImaginaryGenerator.total_nonneg
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.ThreeComponentRate.total_nonneg
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.LocalFisherRate.value_nonneg
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.QRFClassification.equilibrium_iff
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.QRFClassification.nonequilibrium_iff
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.cameron_damping_preserved
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.IdentifyKMSWithModularRate.lambda_kms_eq_h_kms_div_hbar
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.IdentifyFisherWithLocalDensity.h_fisher_nonneg_from_components
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.mixedBracketCompatibilityClaim_holds
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.mixedBracket_kappa_rescaling
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.mixedBracketAntisymmetryClaim_holds
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.mixedBracketBilinearityClaim_holds
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.mixedBracketJacobiClaim_holds
#print axioms CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge.mixedBracket_phase2_stage0_bundle

-- Phase-2 stages 2 + 3: functional-derivative + distributional-delta
-- abstract carriers + structural shapes (provable by ring).  Stage 4
-- (full continuum proof) remains the explicit deferred target.
#print axioms CATEPTMain.Integration.MixedBracketCompatibilityPhase2.FunctionalDerivativeCarrier.linearity_shape_holds
#print axioms CATEPTMain.Integration.MixedBracketCompatibilityPhase2.FunctionalDerivativeCarrier.product_rule_shape_holds
#print axioms CATEPTMain.Integration.MixedBracketCompatibilityPhase2.FunctionalDerivativeCarrier.chain_rule_shape_holds
#print axioms CATEPTMain.Integration.MixedBracketCompatibilityPhase2.DistributionalDeltaCarrier.sifting_shape_holds
#print axioms CATEPTMain.Integration.MixedBracketCompatibilityPhase2.DistributionalDeltaCarrier.antisymmetric_derivative_shape_holds
#print axioms CATEPTMain.Integration.MixedBracketCompatibilityPhase2.DistributionalDeltaCarrier.derivative_pairing_shape_holds
#print axioms CATEPTMain.Integration.MixedBracketCompatibilityPhase2.MixedBracketEquationContract.holds
#print axioms CATEPTMain.Integration.MixedBracketCompatibilityPhase2.MixedBracketEquationContract.rescaling_preserved
#print axioms CATEPTMain.Integration.MixedBracketCompatibilityPhase2.stage4_contract_implies_stage0_shape
#print axioms CATEPTMain.Integration.MixedBracketCompatibilityPhase2.mixedBracket_phase2_stages_2_and_3_bundle

-- Fujikawa ↔ CAT/EPT bridge: Joglekar measure-ambiguity contract,
-- Option-A modular alignment X = K = -ln ρ = S_I/ℏ, Fisher-preferred-
-- not-unique framing.  Provides a principled selection rule for the
-- otherwise-arbitrary Fujikawa basis choice; mixed covariance remains
-- Phase-2 Stage 4 deferred.
#print axioms CATEPTMain.Integration.FujikawaCATEPTBridge.measureAmbiguityShape_holds
#print axioms CATEPTMain.Integration.FujikawaCATEPTBridge.FujikawaMeasureAmbiguityContract.regulatorScale_pos
#print axioms CATEPTMain.Integration.FujikawaCATEPTBridge.FujikawaModularAlignment.fisher_refinement_nonneg
#print axioms CATEPTMain.Integration.FujikawaCATEPTBridge.FujikawaModularAlignment.fisherIsPreferredNotUnique_holds
#print axioms CATEPTMain.Integration.FujikawaCATEPTBridge.alignment_implies_stage0_shape
#print axioms CATEPTMain.Integration.FujikawaCATEPTBridge.alignment_fisher_preserves_total_nonneg
#print axioms CATEPTMain.Integration.FujikawaCATEPTBridge.fujikawa_catept_bridge_bundle
#print axioms CATEPTMain.Integration.FujikawaCATEPTBridge.fujikawaCATEPTOpenObligation_at_stage0_shape

-- CAT/EPT sheaves over a coarse-graining site: assignment-to-contexts
-- shape with the operational second law (entropic-time monotonicity
-- under coarse-graining: τ_ent(c₂) ≥ τ_ent(c₁) for f : c₁ → c₂).
-- Full sheaf gluing/descent axioms remain Phase-2 deferred.
#print axioms CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge.CATEPTSheaf.SI_eq_hbar_mul_τent
#print axioms CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge.CATEPTSheafMonotonicity.constZero_satisfies
#print axioms CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge.CATEPTSheafMonotonicity.increment_nonneg
#print axioms CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge.CATEPTSheafMonotonicity.SI_nondecreasing
#print axioms CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge.CATEPTSheafMonotonicity.increment_compose
#print axioms CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge.entropicTimeIncrementShape_holds
#print axioms CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge.cumulativeMonotonicityShape_holds
#print axioms CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge.catept_sheaf_coarse_graining_bundle

-- CAT/EPT sheaf gluing — Phase 2 completion of PR #80's deferred sheaf
-- condition.  RestrictionMap (presheaf functoriality on a preorder),
-- Cover (indexed family of refinements), CompatibleFamily, GluingAxiom,
-- IsCATEPTSheaf.  Proves singleton-cover gluing for any sheaf with the
-- identity restriction.  Mathlib CategoryTheory.Sheaf reduction is
-- consumer-supplied via IdentifyMathlibSheaf carrier.
#print axioms CATEPTMain.Integration.CATEPTSheafGluingPhase2.RestrictionMap.exists_restrictionMap
#print axioms CATEPTMain.Integration.CATEPTSheafGluingPhase2.Cover.exists_cover
#print axioms CATEPTMain.Integration.CATEPTSheafGluingPhase2.CompatibleFamily.zero_compatible_identity
#print axioms CATEPTMain.Integration.CATEPTSheafGluingPhase2.CompatibleFamily.const_compatible_identity
#print axioms CATEPTMain.Integration.CATEPTSheafGluingPhase2.singleton_cover_gluing
#print axioms CATEPTMain.Integration.CATEPTSheafGluingPhase2.constZero_singleton_gluing
#print axioms CATEPTMain.Integration.CATEPTSheafGluingPhase2.catept_sheaf_gluing_phase2_bundle

-- Yamasaki internal-clock bridge — Frenkel-Kramers / zitterbewegung as
-- CAT/EPT internal clock with positive/negative-energy interference.
-- Y1: t'_yamasaki ≠ τ_ent layer separation (pattern: PR #68)
-- Y2: Ψ = Ψ_+ + Ψ_- decomposition shape
-- Y3: cross-sector interference observable + visibility-decay shape
-- Leverages Mathlib.Algebra.Lie.OfAssociative for canonical
-- Heisenberg commutator structure.  Hooks into existing
-- SpinorPathIntegralBridge.coherenceSectorSuppression.
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.yamasaki_kinematic_separate_from_entropic_proper_time
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.IdentifyYamasakiKinematicWithEntropicProperTime.tauEnt_eq_tauKinematic_funext
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.posNegEnergyDecompositionShape_holds
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.visibility_decay_attenuates
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.commutator_antisym
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.commutator_add_left
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.yamasaki_internal_clock_bundle

-- Yamasaki extension Y4-Y8 (CAT-EPT-20260415-27/28):
-- Y4 two-Hamiltonian split (H_I, H_II); Y5 two kinematic proper times
-- (τ_I, τ_II); Y6 operator decomposition Q = Q_regular + Q_zbw;
-- Y7 coherent oscillator Re(C_Q · e^{2imτ'}); Y8 full CAT/EPT formula
-- ⟨Q⟩(τ', τ_ent) = ⟨Q⟩_diag + e^{-τ_ent} · Re(C_Q · e^{2imτ'}).
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.TwoHamiltonianSplit.total_nonneg
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.tau_I_separate_from_tau_II
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.OperatorDecomposition.pure_regular
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.OperatorDecomposition.pure_zbw
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.CoherentOscillator.oscillation_at_zero
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.cateptExpectationValue_at_zero_τent
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.catept_attenuates_coherent_oscillator
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.cateptExpectationValue_le_unattenuated
#print axioms CATEPTMain.Integration.YamasakiInternalClockBridge.yamasaki_extension_bundle

-- Relative entropy ↔ modular ↔ entropic-time identities (R1, R2 from
-- CAT-EPT-20260129-00123).  R1: D(ρ‖σ) = Δ⟨K_σ⟩ − ΔS.  R2: D = Δτ_ent
-- − ΔS.  Bridge: Δ⟨K_σ⟩ = Δτ_ent (consumer-supplied).  Continuum
-- Hilbert-space proof remains Phase-2 deferred.
#print axioms CATEPTMain.Integration.RelativeEntropyModularBridge.RelativeEntropyModularIdentity.delta_K_eq_D_plus_delta_S
#print axioms CATEPTMain.Integration.RelativeEntropyModularBridge.RelativeEntropyEntropicTimeIdentity.delta_tau_ent_eq_D_plus_delta_S
#print axioms CATEPTMain.Integration.RelativeEntropyModularBridge.IdentifyDeltaKWithDeltaTauEnt.delta_K_eq_delta_tau_ent
#print axioms CATEPTMain.Integration.RelativeEntropyModularBridge.R1_plus_bridge_implies_R2
#print axioms CATEPTMain.Integration.RelativeEntropyModularBridge.relativeEntropyIdentityShape_holds
#print axioms CATEPTMain.Integration.RelativeEntropyModularBridge.R2_aligns_with_stage0_shape
#print axioms CATEPTMain.Integration.RelativeEntropyModularBridge.relative_entropy_modular_bridge_bundle

-- String/CAT-EPT spine — interface-level scaffold (per
-- docs/architecture/string-catept-spine.md).  Two modules:
--   StringWorldsheetTemporalBridge — separates worldsheet τ from
--     entropic proper time τ_ent (counterexample + Identify carrier).
--   StringEffectiveQFTSpineBridge — interface-only capstone with
--     7-field witness (worldsheet action, complex split, S_I ≥ 0,
--     Weyl/beta, beta-to-EOM, CFT modular, couples-to-TF) plus the
--     string_effective_qft_on_catept_spine bundle theorem.
#print axioms CATEPTMain.Integration.StringWorldsheetTemporalBridge.worldsheet_tau_separate_from_entropic_proper_time
#print axioms CATEPTMain.Integration.StringWorldsheetTemporalBridge.IdentifyWorldsheetTauWithEntropicProperTime.tauEnt_eq_tauWs_funext
#print axioms CATEPTMain.Integration.StringEffectiveQFTSpineBridge.StringEffectiveQFTCATEPTWitness.string_effective_qft_on_catept_spine

-- WDW/RQM artifact spine (intake at docs/intake/wdw-rqm-*).  Four
-- structural-carrier landing pads:
--   WDWRQMRelationalTimeContracts — per-actor event preorders +
--     happens-before relation for relational time.
--   WDWRQMPhaseMutualInfoContracts — discrete mutual-info phase
--     accumulation + cluster-coherence predicate.
--   WDWRQMNoetherContracts — continuous symmetry, discrete conserved
--     current, and bridge identification.
--   WDWRQMUncertaintyContracts — computational ℏ_comp, observable
--     dispersion pair, ΔG·ΔΦ ≥ ℏ_comp/2 inequality, load/phase pair.
#print axioms CATEPTMain.Integration.WDWRQMRelationalTimeContracts.RelationalTimeModel.happensBefore_refl
#print axioms CATEPTMain.Integration.WDWRQMRelationalTimeContracts.RelationalTimeModel.happensBefore_trans_of_same_actor
#print axioms CATEPTMain.Integration.WDWRQMPhaseMutualInfoContracts.phaseAt_succ_ge
#print axioms CATEPTMain.Integration.WDWRQMNoetherContracts.ContinuousSymmetry.conservation
#print axioms CATEPTMain.Integration.WDWRQMNoetherContracts.ContinuousSymmetry.conserved_current_const
#print axioms CATEPTMain.Integration.WDWRQMNoetherContracts.DiscreteConservedCurrent.value_eq_initial
#print axioms CATEPTMain.Integration.WDWRQMNoetherContracts.DiscreteConservedCurrent.value_step_invariant
#print axioms CATEPTMain.Integration.WDWRQMNoetherContracts.IdentifyContinuousWithDiscreteConservation.all_equal_to_action_zero
#print axioms CATEPTMain.Integration.WDWRQMNoetherContracts.noether_conservation_bundle
#print axioms CATEPTMain.Integration.WDWRQMUncertaintyContracts.ComputationalHbar.half_nonneg
#print axioms CATEPTMain.Integration.WDWRQMUncertaintyContracts.ObservablePair.product_nonneg
#print axioms CATEPTMain.Integration.WDWRQMUncertaintyContracts.LoadPhaseCanonicalPair.product_lower_bound
#print axioms CATEPTMain.Integration.WDWRQMUncertaintyContracts.IdentifyGenericWithLoadPhase.product_agrees
#print axioms CATEPTMain.Integration.WDWRQMUncertaintyContracts.uncertainty_principle_bundle

-- CAT/EPT non-Hermitian quantum bridge.  Carriers for the artifact's
-- classical-contact ↔ quantum-non-Hermitian ↔ GKLS pipeline:
--   classical L_I = ρ·s, quantum ⟨H_I⟩ ≥ 0 with norm-decay
--   ‖ψ(t₂)‖² ≤ ‖ψ(t₁)‖² (t₁ ≤ t₂), bridge L_I = ℏ·⟨H_I⟩,
--   GKLS jump decomposition ⟨H_I⟩ = (ℏ/2) Σⱼ γⱼ.
#print axioms CATEPTMain.Integration.NonHermitianQuantumCAT.NonHermitianGenerator.normSq_le_initial
#print axioms CATEPTMain.Integration.NonHermitianQuantumCAT.ClassicalContactDissipation.L_I_nonneg
#print axioms CATEPTMain.Integration.NonHermitianQuantumCAT.IdentifyClassicalContactWithQuantumDissipation.product_form_agrees
#print axioms CATEPTMain.Integration.NonHermitianQuantumCAT.GKLSJumpDecomposition.sum_rates_nonneg
#print axioms CATEPTMain.Integration.NonHermitianQuantumCAT.non_hermitian_quantum_cat_bundle

-- Quantum temporal-order energy CAT/EPT bridge.  Carriers for the
-- artifact's Yamasaki internal-clock + Zych temporal-order
-- superposition + CAT/EPT damping pipeline:
--   ⟨Q⟩_{CAT/EPT}(τ', τ_ent) = ⟨Q⟩_{diag}
--                            + e^{-τ_ent} · |C_Q| · cos(2 m τ' + arg C_Q),
-- with recovery at τ_ent = 0, unitary limit when |C_Q| = 0, and a
-- bridge to the Yamasaki τ'-fixed cross scalar.
#print axioms CATEPTMain.Integration.QuantumTemporalOrderEnergyCAT.TemporalOrderBranches.ampPlus_sq_le_one
#print axioms CATEPTMain.Integration.QuantumTemporalOrderEnergyCAT.TemporalOrderBranches.ampMinus_sq_le_one
#print axioms CATEPTMain.Integration.QuantumTemporalOrderEnergyCAT.CATEPTTemporalOrderObservable.expValCATEPT_at_zero_τent
#print axioms CATEPTMain.Integration.QuantumTemporalOrderEnergyCAT.CATEPTTemporalOrderObservable.unitary_limit
#print axioms CATEPTMain.Integration.QuantumTemporalOrderEnergyCAT.CATEPTTemporalOrderObservable.expValBare_unitary
#print axioms CATEPTMain.Integration.QuantumTemporalOrderEnergyCAT.IdentifyTemporalOrderWithYamasakiCross.expValBare_at_τ'_fix
#print axioms CATEPTMain.Integration.QuantumTemporalOrderEnergyCAT.IdentifyTemporalOrderWithYamasakiCross.expValCATEPT_at_τ'_fix
#print axioms CATEPTMain.Integration.QuantumTemporalOrderEnergyCAT.IdentifyTemporalOrderWithYamasakiCross.damped_deviation_le_bare
#print axioms CATEPTMain.Integration.QuantumTemporalOrderEnergyCAT.quantum_temporal_order_energy_cat_bundle

-- CAT/EPT contact-dynamics bridge.  Algebraic pipeline carriers:
--   complex Lagrangian L = L_R + iL_I  →  Herglotz contact slice
--     L_eff(t) = L_R(t) - ρ(t)·s(t),
-- with damped-oscillator instantiation (ρ = γ/m constant).
#print axioms CATEPTMain.Integration.ContactDynamicsCAT.HerglotzContactSlice.L_R_sub_L_eff_eq_ρs
#print axioms CATEPTMain.Integration.ContactDynamicsCAT.HerglotzContactSlice.L_R_sub_L_eff_nonneg
#print axioms CATEPTMain.Integration.ContactDynamicsCAT.IdentifyComplexLagrangianWithHerglotz.L_eff_eq_L_R_sub_L_I
#print axioms CATEPTMain.Integration.ContactDynamicsCAT.DampedOscillatorContactInstance.γ_div_m_nonneg
#print axioms CATEPTMain.Integration.ContactDynamicsCAT.contact_dynamics_cat_bundle

-- Stochastic entropy-integration bridge.  Discrete CAT/EPT trinity
-- (X, τ_ent, λ, A) carriers with deterministic accumulation
-- τ_ent (n+1) = τ_ent n + λ n, damping envelope Λ = exp(-τ_ent), and
-- the free-propagation limit (λ ≡ 0).
#print axioms CATEPTMain.Integration.StochasticEntropyIntegrationBridge.DiscreteCATEPTTrinity.τ_ent_nonneg
#print axioms CATEPTMain.Integration.StochasticEntropyIntegrationBridge.DiscreteCATEPTTrinity.damping_envelope_le_one
#print axioms CATEPTMain.Integration.StochasticEntropyIntegrationBridge.DiscreteCATEPTTrinity.damping_envelope_pos
#print axioms CATEPTMain.Integration.StochasticEntropyIntegrationBridge.DiscreteCATEPTTrinity.tau_ent_monotone
#print axioms CATEPTMain.Integration.StochasticEntropyIntegrationBridge.DiscreteCATEPTTrinity.damping_envelope_monotone
#print axioms CATEPTMain.Integration.StochasticEntropyIntegrationBridge.IdentifyTrinityWithUnattenuatedFreePropagation.tau_ent_const
#print axioms CATEPTMain.Integration.StochasticEntropyIntegrationBridge.IdentifyTrinityWithUnattenuatedFreePropagation.damping_envelope_const
#print axioms CATEPTMain.Integration.StochasticEntropyIntegrationBridge.stochastic_entropy_integration_bundle

-- CAT/EPT measure-theorem landing pad.  Carriers for the complex
-- path-integral measure existence:
--   |g(ω)| = exp(-S_I(ω)/ℏ) ≤ 1, integrability witness Z_0 > 0,
-- Cameron-Martin shift density exp(⟨h,ω⟩ - ½‖h‖²).
#print axioms CATEPTMain.Integration.CATEPTMeasureTheorem.CATEPTActionData.density_modulus_pos
#print axioms CATEPTMain.Integration.CATEPTMeasureTheorem.CATEPTActionData.density_modulus_le_one
#print axioms CATEPTMain.Integration.CATEPTMeasureTheorem.IntegrabilityWitness.inv_Z_0_pos
#print axioms CATEPTMain.Integration.CATEPTMeasureTheorem.CameronMartinShift.cm_density_pos
#print axioms CATEPTMain.Integration.CATEPTMeasureTheorem.CameronMartinShift.cm_density_at_zero
#print axioms CATEPTMain.Integration.CATEPTMeasureTheorem.IdentifyDensityModulusWithImaginaryActionDecay.modulus_pos
#print axioms CATEPTMain.Integration.CATEPTMeasureTheorem.IdentifyDensityModulusWithImaginaryActionDecay.modulus_le_one
#print axioms CATEPTMain.Integration.CATEPTMeasureTheorem.catept_measure_theorem_bundle

-- Tier-1 QuantumDynamics.jl path-integral content as CAT/EPT carriers.
-- Consolidates EtaCoefficients.jl, QuAPI.jl, Blip.jl, SpectralDensities.jl,
-- and pathintegral.jl into structural-carrier landing pads:
--   spectral density J ≥ 0, η-kernel (Re η ≥ 0, Im η free), influence-
--   functional weight with damping magnitude exp(-Δs² · Re η) ≤ 1,
--   blip suppression (monotone in Δs²), η ↔ CAT/EPT (S_R, S_I) bridge,
--   and the spectral-density → η carrier with abstract origin witness.
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.InfluenceFunctionalWeight.dampingMagnitude_pos
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.InfluenceFunctionalWeight.dampingMagnitude_le_one
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.InfluenceFunctionalWeight.dampingMagnitude_monotone_in_Δs_sq
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.InfluenceFunctionalWeight.dampingMagnitude_at_zero_Δs
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.IdentifyEtaWithComplexAction.S_I_nonneg
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.IdentifyEtaWithComplexAction.catept_damping_eq_eta_damping
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.eta_spectral_density_carrier_bundle

-- Tier-1 Phase 2: concrete Ohmic + Drude-Lorentz spectral-density instances
-- with non-negativity discharged from {xi >= 0, omega_c > 0, lambda >= 0,
-- gamma > 0, Delta_s /= 0} as appropriate; multi-slice eta kernel matching
-- EtaCoeffs (eta00, etamm, eta0m[k], etamn[k], eta0e[k]) with kmax lags;
-- multi-slice damping product bound in (0, 1].
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.Phase2.ohmicJ_nonneg
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.Phase2.drudeLorentzJ_nonneg
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.Phase2.MultiSliceEtaKernel.totalDampingProduct_pos
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.Phase2.MultiSliceEtaKernel.totalDampingProduct_le_one
#print axioms CATEPTMain.Integration.EtaSpectralDensityCarrier.Phase2.eta_spectral_density_phase2_bundle

-- Tier-2 QuantumDynamics.jl tensor-network path-integral content as
-- CAT/EPT carriers.  Consolidates TEMPO.jl, MSTNPI.jl, PCTNPI.jl, and
-- Propagators.jl into structural-carrier landing pads:
--   TensorNetworkArgs (maxdim >= 1, cutoff >= 0),
--   CompressedInfluenceFunctional with truncation error >= 0 and
--   compressedWeight in [0, 1],
--   ForwardBackwardPropagator with semigroup composition hypothesis,
--   MultiSiteSystem with per-site eta-kernels,
--   IdentifyTNPIWithQuAPI bridge: at zero truncation error the
--   compressed weight equals the un-compressed dampingMagnitude.
#print axioms CATEPTMain.Integration.TensorNetworkPathIntegralCarrier.CompressedInfluenceFunctional.compressedWeight_in_unit_interval
#print axioms CATEPTMain.Integration.TensorNetworkPathIntegralCarrier.CompressedInfluenceFunctional.compressed_dampingMagnitude_le_uncompressed
#print axioms CATEPTMain.Integration.TensorNetworkPathIntegralCarrier.ForwardBackwardPropagator.composition_at_zero
#print axioms CATEPTMain.Integration.TensorNetworkPathIntegralCarrier.MultiSiteSystem.perSiteKernel_reEta_nonneg
#print axioms CATEPTMain.Integration.TensorNetworkPathIntegralCarrier.IdentifyTNPIWithQuAPI.compressedWeight_le_one_at_exact
#print axioms CATEPTMain.Integration.TensorNetworkPathIntegralCarrier.tensor_network_path_integral_bundle

-- Tier-4 QuantumDynamics.jl complex-time / Wick-rotation path-integral
-- content as CAT/EPT carriers.  Consolidates ComplexPISetup.jl,
-- BMatrix.jl, ComplexQuAPI.jl, ComplexTNPI.jl, correlationfunction.jl,
-- and QCPI.jl into structural-carrier landing pads:
--   ComplexTimePoint, ComplexTimeContour with Keldysh endpoint
--   conditions (origin and -i*beta); BMatrixKernel symmetric in (k, k');
--   WickRotationCarrier bridging Tier-1 EtaKernel to Tier-4 BMatrix at
--   slice [0, 0]; QuasiClassicalCarrier (QCPI) with zeta-kernel;
--   IdentifyComplexQuAPIWithRealQuAPI bridge in the zero-temperature
--   (real-time restriction) limit.
#print axioms CATEPTMain.Integration.ComplexTimePathIntegralCarrier.ComplexTimeContour.halfThermal_pos
#print axioms CATEPTMain.Integration.ComplexTimePathIntegralCarrier.WickRotationCarrier.reB_at_zero_nonneg
#print axioms CATEPTMain.Integration.ComplexTimePathIntegralCarrier.IdentifyComplexQuAPIWithRealQuAPI.realWeight_dampingMagnitude_le_one
#print axioms CATEPTMain.Integration.ComplexTimePathIntegralCarrier.complex_time_path_integral_bundle

-- Goal (c) — GR vs QM path-integral unification via the Wick-rotation
-- contour from Tier 4.  Both Lorentzian (real-time, oscillatory) and
-- Euclidean (imaginary-time, damping) sides share a single underlying
-- EtaKernel; identifications `gr_uses_eta`, `qm_uses_eta`,
-- `wick_uses_eta` discharge the Wick-rotation tie at the carrier
-- level.  Tier-1 dampingMagnitude_le_one + S_I_nonneg propagate
-- through the bridge to both sides simultaneously.
#print axioms CATEPTMain.Integration.GRQMPathIntegralUnifyBridge.PathIntegralSide.dampingMagnitude_le_one
#print axioms CATEPTMain.Integration.GRQMPathIntegralUnifyBridge.PathIntegralSide.S_I_nonneg
#print axioms CATEPTMain.Integration.GRQMPathIntegralUnifyBridge.IdentifyGRWithQMPathIntegral.dampingMagnitudes_both_le_one
#print axioms CATEPTMain.Integration.GRQMPathIntegralUnifyBridge.IdentifyGRWithQMPathIntegral.S_I_both_nonneg
#print axioms CATEPTMain.Integration.GRQMPathIntegralUnifyBridge.IdentifyGRWithQMPathIntegral.gr_qm_dampingMagnitudes_eq
#print axioms CATEPTMain.Integration.GRQMPathIntegralUnifyBridge.IdentifyGRWithQMPathIntegral.wick_pivot_consistency
#print axioms CATEPTMain.Integration.GRQMPathIntegralUnifyBridge.IdentifyGRWithQMPathIntegral.shared_η_reEta_nonneg
#print axioms CATEPTMain.Integration.GRQMPathIntegralUnifyBridge.gr_qm_path_integral_unify_bundle

-- QED representation-stability bridge (ported from
-- entropic-time/lean4_formal_verification commit ff2f597).
-- Encodes the rule: only attach S_I and tau_ent to *physical
-- observables*; preserve QED causality via retarded time t - r/c.
-- A QEDChart selects physical observables and assigns chart-local
-- S_I; RepresentationStableEntropy asserts two charts (e.g.
-- minimal vs multipolar / PZW) agree on physical-observable S_I,
-- which gives tau_ent invariance as a corollary.
#print axioms CATEPTMain.Integration.QEDRepresentationStability.cateptRetardedDamping_pos
#print axioms CATEPTMain.Integration.QEDRepresentationStability.cateptRetardedDamping_le_one
#print axioms CATEPTMain.Integration.QEDRepresentationStability.tauEnt_representation_stable
#print axioms CATEPTMain.Integration.QEDRepresentationStability.tauEnt_nonneg_on_physical
#print axioms CATEPTMain.Integration.QEDRepresentationStability.qed_representation_stability_bundle

-- Tier-3 QuantumDynamics.jl HEOM/GQME/TTM open-system master-equation
-- content as CAT/EPT carriers.  Consolidates HEOM/standard_scaled.jl,
-- HEOM/FP-HEOM_MPS.jl, DynamicMap_MasterEquation/{dynamicmap,GQME,TTM}.jl
-- into structural-carrier landing pads:
--   HEOMHierarchy with (numBaths, numModes, Lmax, hierarchySize >= 1);
--   AuxiliaryDensityLevel with magnitude in [0, 1] and decay >= 0;
--   MemoryKernel with K[r] >= 0 and bounded total sum;
--   TransferTensor with T[r] in [0, 1] and bounded product;
--   IdentifyHEOMWithGKLSJumpDecomposition tying HEOM hierarchy to
--     NonHermitianQuantumCAT.GKLSJumpDecomposition;
--   IdentifyTTMWithEtaKernel tying TTM transfer tensors to Tier-1
--     EtaKernel.
#print axioms CATEPTMain.Integration.OpenSystemMasterEquationCarrier.MemoryKernel.K_sum_nonneg
#print axioms CATEPTMain.Integration.OpenSystemMasterEquationCarrier.TransferTensor.T_prod_le_one
#print axioms CATEPTMain.Integration.OpenSystemMasterEquationCarrier.IdentifyHEOMWithGKLSJumpDecomposition.decay_nonneg_from_GKLS
#print axioms CATEPTMain.Integration.OpenSystemMasterEquationCarrier.IdentifyTTMWithEtaKernel.T_prod_le_one_from_eta
#print axioms CATEPTMain.Integration.OpenSystemMasterEquationCarrier.open_system_master_equation_bundle

-- Tier-5 QuantumDynamics.jl perturbative + semiclassical approximation
-- methods as CAT/EPT carriers.  Consolidates Approximate/Bare.jl,
-- Approximate/BlochRedfield.jl, Approximate/Forster.jl, and the four
-- Approximate/Semiclassical/{PLDM,LSC,SpinPLDM,SpinLSC}.jl methods
-- into structural-carrier landing pads expressing each as a
-- constrained regime of the exact (Tier 1) or master-equation (Tier 3)
-- framework:
--   BareDynamicsRegime — expH_I = 0 (no bath).
--   BlochRedfieldRegime — Markov: memory kernel rmax = 1.
--   ForsterRateRegime — line-shape g(t) >= 0 with g(0) = 0.
--   SemiclassicalIVRRegime — nSamples >= 1 with non-negative weights.
--   IdentifyApproximationsAsRegimes — bridge bundling all four.
#print axioms CATEPTMain.Integration.PerturbativeApproximationCarrier.BareDynamicsRegime.expH_I_at_zero
#print axioms CATEPTMain.Integration.PerturbativeApproximationCarrier.BlochRedfieldRegime.rmax_eq_one
#print axioms CATEPTMain.Integration.PerturbativeApproximationCarrier.ForsterRateRegime.lineShape_at_zero_nonneg
#print axioms CATEPTMain.Integration.PerturbativeApproximationCarrier.SemiclassicalIVRRegime.sampleWeight_sum_nonneg
#print axioms CATEPTMain.Integration.PerturbativeApproximationCarrier.IdentifyApproximationsAsRegimes.all_positivities_hold
#print axioms CATEPTMain.Integration.PerturbativeApproximationCarrier.perturbative_approximation_bundle

-- Goal (d) — NSSpace + Quantum Inertial Frames consistency.
-- Defines QuantumInertialFrame for the first time across the
-- catept-main / catept-core / domain / plugin ecosystem
-- (pre-existing inventory confirmed QIF was a genuine gap).
-- NSSpaceCarrier exposes velocityField + spectralGap > 0
-- (Lichnerowicz CD(κ) ⟹ λ ≥ κ regime); QuantumInertialFrame
-- exposes operator-valued energyMomentum >= 0 + stressTensorMin > 0.
-- IdentifyNSSpaceWithQIF ties NS spectral gap to QIF stress-tensor
-- minimum at the magnitude level, giving a bidirectional consistency
-- equivalence as the canonical theorem.
#print axioms CATEPTMain.Integration.NSSpaceQIFConsistencyBridge.NSSpaceCarrier.spectralGap_nonneg
#print axioms CATEPTMain.Integration.NSSpaceQIFConsistencyBridge.QuantumInertialFrame.stressTensorMin_nonneg
#print axioms CATEPTMain.Integration.NSSpaceQIFConsistencyBridge.IdentifyNSSpaceWithQIF.NSSpace_implies_QIF_positivity
#print axioms CATEPTMain.Integration.NSSpaceQIFConsistencyBridge.IdentifyNSSpaceWithQIF.QIF_implies_NSSpace_spectralGap
#print axioms CATEPTMain.Integration.NSSpaceQIFConsistencyBridge.IdentifyNSSpaceWithQIF.NSSpace_QIF_positivity_equivalent
#print axioms CATEPTMain.Integration.NSSpaceQIFConsistencyBridge.nsspace_qif_consistency_bundle

-- Goal (a) — MaxwellWave + CATEPTSpaceTime + tau_ent.  Magnitude-level
-- carriers identifying MaxwellWave field configurations with
-- CATEPTSpacetimeModel-driven amplitudes under tau_ent damping.
-- Composes the existing MaxwellWaveEntropicTimeBridge (commit 74f548d4)
-- with catept-plugin-maxwell-curvespace-pphi2's
-- catEpt_maxwell_curveSpace_pphi2_bridge (term-proved 0 sorry).
#print axioms CATEPTMain.Integration.MaxwellWaveCATEPTSpaceTimeBridge.MaxwellWaveAbstractData.total_mag_nonneg
#print axioms CATEPTMain.Integration.MaxwellWaveCATEPTSpaceTimeBridge.CATEPTSpaceTimeAbstract.tauEnt_ge_initial
#print axioms CATEPTMain.Integration.MaxwellWaveCATEPTSpaceTimeBridge.IdentifyMaxwellWaveWithCATEPTSpaceTime.MaxwellWave_admits_CATEPT_damping
#print axioms CATEPTMain.Integration.MaxwellWaveCATEPTSpaceTimeBridge.maxwellWave_catept_spacetime_bundle

-- Goal (b) — VML + CATEPTSpaceTime + tau_ent.  Identifies the
-- catept-plugin-vml-landau term-proved Theorem 4.2 rigidity output
-- (Maxwellian + E = 0 + B = const) with tau_ent saturation at the
-- carrier level.  Boltzmann-H-theorem-style identification of
-- Maxwellian with entropy-maximum is a consumer-supplied hypothesis.
#print axioms CATEPTMain.Integration.VMLEntropicEquilibriumBridge.VMLSteadyStateAbstract.f_density_nonneg
#print axioms CATEPTMain.Integration.VMLEntropicEquilibriumBridge.MaxwellianEquilibrium.E_at_zero
#print axioms CATEPTMain.Integration.VMLEntropicEquilibriumBridge.EntropicEquilibriumState.tauEnt_constant
#print axioms CATEPTMain.Integration.VMLEntropicEquilibriumBridge.IdentifyVMLSteadyStateWithEntropicEquilibrium.VML_steady_implies_tau_ent_saturated
#print axioms CATEPTMain.Integration.VMLEntropicEquilibriumBridge.IdentifyVMLSteadyStateWithEntropicEquilibrium.maxwellian_temperature_ge_one
#print axioms CATEPTMain.Integration.VMLEntropicEquilibriumBridge.vml_entropic_equilibrium_bundle

-- Goals (a) + (b) Phase-3 closures.  Concrete instantiations of the
-- carriers from PR #106 with non-trivial parameters
-- (T = 2 Maxwellian, exp(-t) field decay, max(t, 0) tau_ent), plus a
-- name-level wiring confirmation that the upstream
-- catept-plugin-vml-landau Theorem 4.2 (proved_vml_steady_state_rigidity)
-- is reachable from this module.  Phase-3 work that's blocked on
-- Mathlib infrastructure (full integral discharge of QuAPI eta,
-- complex analytic continuation, Galilei/Poincare rep theory) is
-- explicitly deferred.
#print axioms CATEPTMain.Integration.GoalsABPhase3Closures.vml_landau_content_witness_typechecks
#print axioms CATEPTMain.Integration.GoalsABPhase3Closures.concreteVMLIdentification_temperature_ge_one
#print axioms CATEPTMain.Integration.GoalsABPhase3Closures.concreteVMLIdentification_tauEntMax_nonneg
#print axioms CATEPTMain.Integration.GoalsABPhase3Closures.concreteMaxwellIdentification_damping_at_one
#print axioms CATEPTMain.Integration.GoalsABPhase3Closures.goals_a_b_phase3_closure_bundle

-- Goal (a) deeper Phase-3.  Discharges damping_consistency from the
-- upstream catEpt_maxwell_curveSpace_pphi2_bridge directly: extracts
-- the mass gap from the term-proved bridge contract, derives both
-- E_mag(t) = exp(-m_gap*max(t, 0)) and tau_ent(t) = m_gap*max(t, 0)
-- from the *same* mass gap, and discharges the carrier inequality
-- via mass-gap-driven exponential damping rather than generic
-- Real.exp_le_exp monotonicity.
#print axioms CATEPTMain.Integration.MaxwellCurveSpaceDampingPhase3.concreteIntegrationContract
#print axioms CATEPTMain.Integration.MaxwellCurveSpaceDampingPhase3.concreteMaxGap_pos
#print axioms CATEPTMain.Integration.MaxwellCurveSpaceDampingPhase3.damping_consistency_from_bridge_mass_gap
#print axioms CATEPTMain.Integration.MaxwellCurveSpaceDampingPhase3.damping_at_one_from_bridge_mass_gap
#print axioms CATEPTMain.Integration.MaxwellCurveSpaceDampingPhase3.goal_a_deeper_phase3_bundle

-- Five-paper unification hierarchy chain (REPLYID CAT-EPT-20260415-38).
-- Three new structural carriers ship the central unification primitive
--   O_obs^loc = O_stable^loc + Phi_mod(O_sensitive)
-- across the five-paper chain (Yamasaki + Power II/III/IV + AQFT
-- modular).  Yamasaki and AQFT-modular sides are already in the spine
-- (PRs #82, #83, #84, #87); these modules add the Power-stage carriers
-- + reduced-modular-channel + master-equation primitive.
#print axioms CATEPTMain.Integration.ReducedModularChannelCarrier.ReducedModularChannel.magnitude_le_one
#print axioms CATEPTMain.Integration.ReducedModularChannelCarrier.ReducedModularChannel.magnitude_at_zero
#print axioms CATEPTMain.Integration.ReducedModularChannelCarrier.StableSensitiveObservableSplit.master_equation_le_unattenuated
#print axioms CATEPTMain.Integration.ReducedModularChannelCarrier.StableSensitiveObservableSplit.obsObserved_at_no_damping
#print axioms CATEPTMain.Integration.ReducedModularChannelCarrier.reduced_modular_channel_bundle
#print axioms CATEPTMain.Integration.PowerHierarchyCarrier.LocalFieldHierarchy.stableMag_nonneg
#print axioms CATEPTMain.Integration.PowerHierarchyCarrier.RetardedExchange.power_field_zero_below_lightcone
#print axioms CATEPTMain.Integration.PowerHierarchyCarrier.QuadraticObservable.quadratic_decomposition_le_total
#print axioms CATEPTMain.Integration.PowerHierarchyCarrier.power_hierarchy_bundle
#print axioms CATEPTMain.Integration.FivePaperUnifiedHierarchy.FivePaperHierarchy.unified_master_equation
#print axioms CATEPTMain.Integration.FivePaperUnifiedHierarchy.FivePaperHierarchy.master_equation_holds_at_zero
#print axioms CATEPTMain.Integration.FivePaperUnifiedHierarchy.five_paper_unified_hierarchy_bundle

-- Continuous entropic uncertainty principle (REPLYID CAT-EPT-20260415-40).
-- Continuous Parseval-frame entropies S_A, S_B and overlap bound
-- c = sup |B_beta . A_alpha^*| compose into the master inequality
--   S_A + S_B >= -2 log c
-- carried as a Prop-level field.  The modular-physical bridge ties
-- S_A to a ReducedModularChannel's tau_ent(0), giving the CAT/EPT
-- reading: modular-frame entropy bounded below by tau_ent.
#print axioms CATEPTMain.Integration.ContinuousEntropicUncertaintyCarrier.FrameOverlapBound.c_nonneg
#print axioms CATEPTMain.Integration.ContinuousEntropicUncertaintyCarrier.ContinuousEntropicUncertainty.entropy_bound_holds
#print axioms CATEPTMain.Integration.ContinuousEntropicUncertaintyCarrier.ContinuousEntropicUncertainty.entropy_bound_at_unit_overlap
#print axioms CATEPTMain.Integration.ContinuousEntropicUncertaintyCarrier.ModularPhysicalFrameBridge.modular_entropy_nonneg
#print axioms CATEPTMain.Integration.ContinuousEntropicUncertaintyCarrier.continuous_entropic_uncertainty_bundle
