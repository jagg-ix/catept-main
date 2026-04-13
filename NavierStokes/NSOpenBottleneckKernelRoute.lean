import NavierStokes.NSVSNuPResolutionBridge
import NavierStokes.NSSliceRotationalAssemblyBridge
import NavierStokes.NSBKMContinuationPipeline

/-!
# NS Open Bottleneck Kernel Route

This module provides a theorem-level routing interface from the constructive
Stage 69 obligations to `PreciseGapStatement` through the unweighted
`VS/Ω/P` kernel chain.

It does not modify the Stage 64 bottleneck axioms in
`NSOpenBottleneckPrecise.lean`; it adds an explicit constructive route in a
downstream module to avoid import cycles.
-/

namespace NavierStokes.OpenBottleneck

set_option autoImplicit false

open NavierStokes.Millennium

noncomputable section

/-- Kernel-routed closure:
Stage 69 constructive obligations imply `PreciseGapStatement` via the
unweighted `VS/Ω/P` chain in `NSVSNuPResolutionBridge`. -/
theorem stage69_constructive_obligations_imply_precise_gap_via_kernel
    (hPDE : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEProp)
    (hSDE : NavierStokes.BohmBianchiConstructive.BohmOsmoticHolonomyConstructiveSDEPDEProp) :
    PreciseGapStatement :=
  NavierStokes.Millennium.stage69_constructive_obligations_imply_precise_gap hPDE hSDE

/-- Component-obligation kernel route:
explicit slice-PDE component obligations imply the kernel proposition directly. -/
theorem slice_projection_components_imply_slice_projection_kernel_via_kernel
    (hComp : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEComponentsProp) :
    NavierStokes.Millennium.SliceProjectionCouplingBoundProp :=
  NavierStokes.Millennium.slice_projection_components_imply_slice_projection_kernel hComp

/-- Component-obligation kernel route:
explicit slice-PDE component obligations imply universal trajectory-level
`VS ≤ νP` on `t ≥ 0`. -/
theorem slice_projection_components_imply_vs_le_nu_p_all_via_kernel
    (hComp : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEComponentsProp) :
    NavierStokes.Millennium.VSLeNuPAllTrajProp :=
  NavierStokes.Millennium.slice_projection_components_imply_vs_le_nu_p_all hComp

/-- Component-obligation kernel route:
explicit slice-PDE component obligations imply universal enstrophy monotonicity
`dΩ/dt ≤ 0` on `t ≥ 0`. -/
theorem slice_projection_components_imply_enstrophy_rate_nonpos_all_via_kernel
    (hComp : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEComponentsProp) :
    NavierStokes.Millennium.EnstrophyRateNonposAllTrajProp :=
  NavierStokes.Millennium.slice_projection_components_imply_enstrophy_rate_nonpos_all hComp

/-- Component-obligation kernel route:
explicit slice-PDE component obligations imply `PreciseGapStatement` through the
unweighted `VS/Ω/P` chain. -/
theorem slice_projection_components_imply_precise_gap_via_kernel
    (hComp : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEComponentsProp) :
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_components_imply_precise_gap hComp

/-- Current constructive target symbol routed through the unweighted kernel chain. -/
theorem slice_projection_constructive_target_implies_precise_gap_via_kernel :
    NavierStokes.BohmBianchi.SliceProjectionPrimitiveDerivationProp →
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_constructive_target_implies_precise_gap

/-- Direct core bottleneck route through the unweighted kernel chain. -/
theorem slice_projection_direct_vs_le_nuP_implies_precise_gap_via_kernel :
    NavierStokes.SliceDecomposition.SliceProjectedVSLeNuPPrimitiveProp →
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_direct_vs_le_nuP_implies_precise_gap

/-- Factorized core bottleneck route:
if the final enstrophy-target theorem is discharged, direct pointwise
slice primitive `VS≤νP` yields `PreciseGapStatement` without invoking the
Stage-64 boundary wrapper. -/
theorem slice_projection_direct_vs_le_nuP_implies_precise_gap_via_enstrophy_target
    (hTarget : NavierStokes.Millennium.EnstrophyMonotoneToPreciseGapTargetProp)
    (hVS : NavierStokes.SliceDecomposition.SliceProjectedVSLeNuPPrimitiveProp) :
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_kernel_implies_precise_gap_of_enstrophy_target
    hTarget
    (NavierStokes.Millennium.slice_projection_coupling_bound_from_direct_vs_le_nuP hVS)

/-- Explicit conditional closure route through subcritical slice regime. -/
theorem slice_projection_subcritical_enstrophy_implies_precise_gap_via_kernel :
    NavierStokes.SliceDecomposition.SliceProjectedSubcriticalEnstrophyProp →
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_subcritical_enstrophy_implies_precise_gap

/-- Constructive cap-witness route through the unweighted kernel chain. -/
theorem slice_projection_subcritical_cap_witness_implies_precise_gap_via_kernel :
    NavierStokes.SliceDecomposition.SliceProjectedSubcriticalCapWitnessProp →
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_subcritical_cap_witness_implies_precise_gap

/-- Cap-threshold compatibility primitive route through the unweighted kernel chain. -/
theorem slice_projection_cap_threshold_compatibility_implies_precise_gap_via_kernel :
    NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp →
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_cap_threshold_compatibility_implies_precise_gap

/-- Factorized cap-threshold route:
if the final enstrophy-target theorem is discharged, cap-threshold
compatibility yields `PreciseGapStatement` without invoking the Stage-64
boundary wrapper. -/
theorem slice_projection_cap_threshold_compatibility_implies_precise_gap_via_enstrophy_target
    (hTarget : NavierStokes.Millennium.EnstrophyMonotoneToPreciseGapTargetProp)
    (hCompat : NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_cap_threshold_compatibility_implies_precise_gap_of_enstrophy_target
    hTarget hCompat

/-- Oriented-slice rotational assembly route through the unweighted kernel chain.
This exposes the "2D slices + 3D residual absorption" strategy as a direct
path to `PreciseGapStatement`. -/
theorem oriented_slice_residual_absorption_implies_precise_gap_via_kernel
    (w : NavierStokes.SliceRotationalAssembly.OrientedSliceAssemblyWitness)
    (hAbsorb : NavierStokes.SliceRotationalAssembly.OrientedSliceResidualAbsorptionProp w) :
    PreciseGapStatement :=
  NavierStokes.SliceRotationalAssembly.oriented_slice_residual_absorption_implies_precise_gap
    w hAbsorb

/-- Triadic residual candidate route:
single cap-threshold inequality target on the triadic witness implies
`PreciseGapStatement` through the oriented-slice kernel chain. -/
theorem triadic_cap_threshold_target_implies_precise_gap_via_kernel
    (w : NavierStokes.SliceRotationalAssembly.TriadicOrientedSliceAssemblyWitness)
    (hTarget : NavierStokes.SliceRotationalAssembly.TriadicResidualCapThresholdInequalityTargetProp w) :
    PreciseGapStatement :=
  NavierStokes.SliceRotationalAssembly.triadic_cap_threshold_target_implies_precise_gap
    w hTarget

/-- Constructive triadic route:
concrete 3D slice-PDE estimates discharge the triadic cap-threshold target,
yielding `PreciseGapStatement` via the unweighted kernel chain. -/
theorem triadic_precise_gap_from_concrete_3d_slice_pde_estimates_via_kernel
    (w : NavierStokes.SliceRotationalAssembly.TriadicOrientedSliceAssemblyWitness)
    (hCompat : NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    PreciseGapStatement :=
  NavierStokes.SliceRotationalAssembly.triadic_precise_gap_from_concrete_3d_slice_pde_estimates
    w hCompat

/-- Closed kernel-routed target:
uses the discharged slice primitive derivation witness route directly. -/
theorem slice_projection_constructive_target_closed_implies_precise_gap_via_kernel :
    NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp →
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_constructive_target_closed_implies_precise_gap

/-- Legacy closed kernel-routed target (witness-parameterized):
retained as adapter for compatibility with earlier route signatures. -/
theorem slice_projection_constructive_target_closed_implies_precise_gap_via_kernel_legacy :
    NavierStokes.SliceDecomposition.SliceProjectedUniformEntropicRateSourceWitness →
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_constructive_target_closed_implies_precise_gap_legacy

/-- Closed kernel-routed target (cap-threshold branch):
explicit cap-threshold compatibility primitive data yield `PreciseGapStatement`
without a separate source-witness parameter. -/
theorem slice_projection_constructive_target_closed_from_cap_threshold_compatibility_implies_precise_gap_via_kernel
    (hCompat : NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_constructive_target_closed_from_cap_threshold_compatibility_implies_precise_gap
    hCompat

/-- Explicit causality-adapter route through the unweighted kernel chain. -/
theorem slice_projection_causality_adapter_implies_precise_gap_via_kernel
    (cb : NavierStokes.Millennium.CausalityBoundedLambda)
    (hTimeDomain : NavierStokes.Millennium.SliceTimeDomainNonnegativeProp)
    (hCompat : ((NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu) * cb.lambdaMax) *
      ((NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu) * cb.lambdaMax) ≤
      NavierStokes.Millennium.subcriticalEnstrophySquaredThreshold) :
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_causality_adapter_implies_precise_gap cb hTimeDomain hCompat

/-- No-global-time-domain adapter route through the unweighted kernel chain. -/
theorem slice_projection_causality_interval_implies_precise_gap_via_kernel
    (cb : NavierStokes.Millennium.CausalityBoundedLambda)
    (hCompat : ((NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu) * cb.lambdaMax) *
      ((NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu) * cb.lambdaMax) ≤
      NavierStokes.Millennium.subcriticalEnstrophySquaredThreshold) :
    PreciseGapStatement :=
  NavierStokes.Millennium.slice_projection_causality_interval_implies_precise_gap cb hCompat

/-! ## Kernel Route -> Global Regularity (Stage-221 continuation) -/

/-- Any kernel-routed `PreciseGapStatement` can be pushed through the
    Stage-221 BKM continuation pipeline to `GlobalRegularSolution` on T³. -/
theorem precise_gap_implies_global_regularity_via_bkm_pipeline
    (hPGS : PreciseGapStatement) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 := by
  intro st0
  have hAdmR3 : AdmissibleInitialData nsSpacesR3 st0 := admissible_any_state_r3 st0
  obtain ⟨traj, h0, hNS, hFSR3⟩ := ns_bkm_global_existence_from_pgs hPGS st0 hAdmR3
  exact ⟨admissible_any_state_t3 st0, traj, h0, hNS, respects_r3_to_t3 traj hFSR3⟩

/-- Full constructive Stage-69 route to global regularity:
    Stage-69 constructive obligations -> kernel precise gap -> Stage-221 continuation. -/
theorem stage69_constructive_obligations_imply_global_regularity_via_kernel
    (hPDE : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEProp)
    (hSDE : NavierStokes.BohmBianchiConstructive.BohmOsmoticHolonomyConstructiveSDEPDEProp) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 :=
  precise_gap_implies_global_regularity_via_bkm_pipeline
    (stage69_constructive_obligations_imply_precise_gap_via_kernel hPDE hSDE)

/-- Component-obligation route to global regularity via kernel + Stage-221 pipeline. -/
theorem slice_projection_components_imply_global_regularity_via_kernel
    (hComp : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEComponentsProp) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 :=
  precise_gap_implies_global_regularity_via_bkm_pipeline
    (slice_projection_components_imply_precise_gap_via_kernel hComp)

/-- Direct slice primitive route to global regularity via kernel + Stage-221 pipeline. -/
theorem slice_projection_direct_vs_le_nuP_imply_global_regularity_via_kernel
    (hVS : NavierStokes.SliceDecomposition.SliceProjectedVSLeNuPPrimitiveProp) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 :=
  precise_gap_implies_global_regularity_via_bkm_pipeline
    (slice_projection_direct_vs_le_nuP_implies_precise_gap_via_kernel hVS)

/-- Closed constructive-target route to global regularity via kernel + Stage-221 pipeline. -/
theorem slice_projection_constructive_target_closed_imply_global_regularity_via_kernel
    (hCompat : NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 :=
  precise_gap_implies_global_regularity_via_bkm_pipeline
    (slice_projection_constructive_target_closed_from_cap_threshold_compatibility_implies_precise_gap_via_kernel hCompat)

/-- Causality-adapter route to global regularity via kernel + Stage-221 pipeline. -/
theorem slice_projection_causality_adapter_imply_global_regularity_via_kernel
    (cb : NavierStokes.Millennium.CausalityBoundedLambda)
    (hTimeDomain : NavierStokes.Millennium.SliceTimeDomainNonnegativeProp)
    (hCompat : ((NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu) * cb.lambdaMax) *
      ((NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu) * cb.lambdaMax) ≤
      NavierStokes.Millennium.subcriticalEnstrophySquaredThreshold) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 :=
  precise_gap_implies_global_regularity_via_bkm_pipeline
    (slice_projection_causality_adapter_implies_precise_gap_via_kernel cb hTimeDomain hCompat)

/-- Causality-interval route to global regularity via kernel + Stage-221 pipeline. -/
theorem slice_projection_causality_interval_imply_global_regularity_via_kernel
    (cb : NavierStokes.Millennium.CausalityBoundedLambda)
    (hCompat : ((NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu) * cb.lambdaMax) *
      ((NavierStokes.Millennium.hbar / NavierStokes.Millennium.nsNu) * cb.lambdaMax) ≤
      NavierStokes.Millennium.subcriticalEnstrophySquaredThreshold) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 :=
  precise_gap_implies_global_regularity_via_bkm_pipeline
    (slice_projection_causality_interval_implies_precise_gap_via_kernel cb hCompat)

def openBottleneckKernelRouteClaims : List LabeledClaim :=
  [ ⟨"stage69_constructive_obligations_imply_precise_gap_via_kernel", .partiallyVerified,
      "THEOREM: Stage 69 constructive obligations imply PreciseGapStatement through NSVSNuPKernel/Resolution chain (modulo open bridges)"⟩
  , ⟨"slice_projection_components_imply_slice_projection_kernel_via_kernel", .partiallyVerified,
      "THEOREM: explicit slice-PDE component obligations imply NSVSNuPKernel proposition through kernel route reducer"⟩
  , ⟨"slice_projection_components_imply_vs_le_nu_p_all_via_kernel", .partiallyVerified,
      "THEOREM: explicit slice-PDE component obligations imply universal trajectory-level VS≤νP on t≥0 through kernel route reducer"⟩
  , ⟨"slice_projection_components_imply_enstrophy_rate_nonpos_all_via_kernel", .partiallyVerified,
      "THEOREM: explicit slice-PDE component obligations imply universal enstrophy monotonicity dΩ/dt≤0 on t≥0 through kernel route reducer"⟩
  , ⟨"slice_projection_components_imply_precise_gap_via_kernel", .partiallyVerified,
      "THEOREM: explicit slice-PDE component obligations imply PreciseGapStatement through the unweighted VS/Ω/P kernel route"⟩
  , ⟨"slice_projection_constructive_target_implies_precise_gap_via_kernel", .partiallyVerified,
      "COROLLARY: current slice-projection constructive target (parameterized by slice witness) yields PreciseGapStatement through unweighted VS/Ω/P kernel chain"⟩
  , ⟨"slice_projection_direct_vs_le_nuP_implies_precise_gap_via_kernel", .partiallyVerified,
      "COROLLARY: direct pointwise slice primitive VS≤νP yields PreciseGapStatement through unweighted VS/Ω/P kernel chain"⟩
  , ⟨"slice_projection_direct_vs_le_nuP_implies_precise_gap_via_enstrophy_target", .partiallyVerified,
      "COROLLARY: factorized route — direct pointwise slice primitive VS≤νP yields PreciseGapStatement once the final enstrophy-target theorem is discharged"⟩
  , ⟨"slice_projection_subcritical_enstrophy_implies_precise_gap_via_kernel", .partiallyVerified,
      "COROLLARY: explicit subcritical slice condition Ω²≤ν⁴λ₁/C⁴ yields PreciseGapStatement through unweighted VS/Ω/P kernel chain"⟩
  , ⟨"slice_projection_subcritical_cap_witness_implies_precise_gap_via_kernel", .partiallyVerified,
      "COROLLARY: constructive cap-witness route (Ω≤Ω_max and Ω_max²≤ν⁴λ₁/C⁴) yields PreciseGapStatement through unweighted VS/Ω/P kernel chain"⟩
  , ⟨"slice_projection_cap_threshold_compatibility_implies_precise_gap_via_kernel", .partiallyVerified,
      "COROLLARY: cap-threshold compatibility primitive route yields PreciseGapStatement through unweighted VS/Ω/P kernel chain"⟩
  , ⟨"slice_projection_cap_threshold_compatibility_implies_precise_gap_via_enstrophy_target", .partiallyVerified,
      "COROLLARY: factorized route — cap-threshold compatibility yields PreciseGapStatement once the final enstrophy-target theorem is discharged"⟩
  , ⟨"oriented_slice_residual_absorption_implies_precise_gap_via_kernel", .partiallyVerified,
      "COROLLARY: oriented-slice rotational assembly with absorbed 3D residual implies PreciseGapStatement through unweighted VS/Ω/P kernel chain"⟩
  , ⟨"triadic_cap_threshold_target_implies_precise_gap_via_kernel", .partiallyVerified,
      "COROLLARY: concrete triadic cross-orientation residual route closes from one cap-threshold inequality target through unweighted VS/Ω/P kernel chain"⟩
  , ⟨"triadic_precise_gap_from_concrete_3d_slice_pde_estimates_via_kernel", .partiallyVerified,
      "COROLLARY: concrete 3D slice-PDE estimate producers imply PreciseGapStatement through triadic cap-threshold route in unweighted VS/Ω/P kernel chain (cap-threshold canonical input)"⟩
  , ⟨"slice_projection_constructive_target_closed_implies_precise_gap_via_kernel", .partiallyVerified,
      "COROLLARY: slice-projection constructive target route through unweighted VS/Ω/P kernel chain from cap-threshold compatibility primitive data (remaining open content is upstream Stage-64)"⟩
  , ⟨"slice_projection_constructive_target_closed_implies_precise_gap_via_kernel_legacy", .partiallyVerified,
      "COROLLARY (legacy): witness-parameterized closed route retained as adapter; superseded by cap-threshold canonical route"⟩
  , ⟨"slice_projection_constructive_target_closed_from_cap_threshold_compatibility_implies_precise_gap_via_kernel", .partiallyVerified,
      "COROLLARY: slice-projection constructive target route through unweighted VS/Ω/P kernel chain from explicit cap-threshold compatibility primitive data"⟩
  , ⟨"slice_projection_causality_adapter_implies_precise_gap_via_kernel", .partiallyVerified,
      "COROLLARY: explicit CausalityBoundedLambda adapter route through unweighted VS/Ω/P kernel chain to PreciseGapStatement (remaining open content is upstream Stage-64)"⟩
  , ⟨"slice_projection_causality_interval_implies_precise_gap_via_kernel", .partiallyVerified,
      "COROLLARY: no-global-time-domain causality adapter route through unweighted VS/Ω/P kernel chain to PreciseGapStatement"⟩
  , ⟨"precise_gap_implies_global_regularity_via_bkm_pipeline", .partiallyVerified,
      "THEOREM: any kernel-routed PreciseGapStatement lifts to GlobalRegularSolution on T³ via Stage-221 continuation pipeline"⟩
  , ⟨"stage69_constructive_obligations_imply_global_regularity_via_kernel", .partiallyVerified,
      "THEOREM: Stage-69 constructive obligations yield GlobalRegularSolution via kernel precise-gap route and Stage-221 continuation"⟩
  , ⟨"slice_projection_components_imply_global_regularity_via_kernel", .partiallyVerified,
      "COROLLARY: explicit slice-PDE component obligations imply GlobalRegularSolution via kernel precise-gap route and Stage-221 continuation"⟩
  , ⟨"slice_projection_direct_vs_le_nuP_imply_global_regularity_via_kernel", .partiallyVerified,
      "COROLLARY: direct slice primitive VS<=nuP implies GlobalRegularSolution via kernel precise-gap route and Stage-221 continuation"⟩
  , ⟨"slice_projection_constructive_target_closed_imply_global_regularity_via_kernel", .partiallyVerified,
      "COROLLARY: closed constructive target (cap-threshold compatibility primitive) implies GlobalRegularSolution via kernel precise-gap route and Stage-221 continuation"⟩
  , ⟨"slice_projection_causality_adapter_imply_global_regularity_via_kernel", .partiallyVerified,
      "COROLLARY: explicit causality adapter route implies GlobalRegularSolution via kernel precise-gap route and Stage-221 continuation"⟩
  , ⟨"slice_projection_causality_interval_imply_global_regularity_via_kernel", .partiallyVerified,
      "COROLLARY: no-global-time-domain causality interval route implies GlobalRegularSolution via kernel precise-gap route and Stage-221 continuation"⟩
  ]

end
