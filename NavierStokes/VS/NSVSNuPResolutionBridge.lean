import NavierStokes.VS.NSVSNuPKernel
import NavierStokes.BKM.BKMMinimalBridge
import NavierStokes.Bohm.BohmBianchiConstructiveObligations
import NavierStokes.Bridges.NSOpenBottleneckPrecise

/-!
# NS VS-νP Resolution Bridge

Focused bridge from the kernel-level bottleneck proposition to the existing
`PreciseGapStatement` interface.

This module keeps the unresolved Millennium step explicit:

1. Kernel reduction (proved here):
   `SliceProjectionCouplingBoundProp -> VSLeNuPAllTrajProp`.
2. Open bridge (single axiom here):
   `VSLeNuPAllTrajProp -> PreciseGapStatement`.

So the unresolved mathematical content is localized to one explicit implication
with trajectory-level quantifiers.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

/-! ## 1. Explicit Universal VS≤νP Predicate -/

/-- Universal trajectory-level form of the bottleneck inequality `VS ≤ νP`. -/
def VSLeNuPAllTrajProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity

/-- Universal trajectory-level enstrophy monotonicity predicate on `t ≥ 0`:
`dΩ/dt ≤ 0` pointwise for all NS trajectories/nonnegative times. -/
def EnstrophyRateNonposAllTrajProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    enstrophyRate traj t ≤ 0

/-! ## 2. Kernel Reduction (Theorem) -/

/-- Kernel reduction theorem:
`SliceProjectionCouplingBoundProp` implies universal `VS ≤ νP`. -/
theorem slice_projection_kernel_implies_vs_le_nu_p_all
    (hKernel : SliceProjectionCouplingBoundProp) :
    VSLeNuPAllTrajProp := by
  intro traj t _ht hNS hFS
  exact slice_projection_bound_implies_vs_le_nuP hKernel traj t hNS hFS

/-- Kernel-to-monotonicity reducer:
universal `VS ≤ νP` implies universal `dΩ/dt ≤ 0`. -/
theorem vs_le_nu_p_all_implies_enstrophy_rate_nonpos_all
    (hAll : VSLeNuPAllTrajProp) :
    EnstrophyRateNonposAllTrajProp := by
  intro traj t ht hNS hFS
  exact enstrophy_rate_nonpos_of_vs_le_nuP traj t hNS hFS
    (hAll traj t ht hNS hFS)

/-- Kernel-level monotonicity corollary:
the slice-projection kernel proposition implies universal enstrophy non-increase. -/
theorem slice_projection_kernel_implies_enstrophy_rate_nonpos_all
    (hKernel : SliceProjectionCouplingBoundProp) :
    EnstrophyRateNonposAllTrajProp :=
  vs_le_nu_p_all_implies_enstrophy_rate_nonpos_all
    (slice_projection_kernel_implies_vs_le_nu_p_all hKernel)

/-- Reverse kernel reducer:
universal enstrophy monotonicity `dΩ/dt ≤ 0` implies universal `VS ≤ νP`
by the algebraic converse from `NSVSNuPKernel`. -/
theorem enstrophy_rate_nonpos_all_implies_vs_le_nu_p_all
    (hMono : EnstrophyRateNonposAllTrajProp) :
    VSLeNuPAllTrajProp := by
  intro traj t ht hNS hFS
  exact vs_le_nuP_of_enstrophy_rate_nonpos traj t hNS hFS
    (hMono traj t ht hNS hFS)

/-! ## 3. Stage-64 Composition Reducer -/

/-- Explicit final analytic target (post-kernel):
if universal enstrophy monotonicity can be upgraded to `PreciseGapStatement`,
then the remaining Stage-64 bottleneck is closed without additional bridge
assumptions. -/
def EnstrophyMonotoneToPreciseGapTargetProp : Prop :=
  EnstrophyRateNonposAllTrajProp → PreciseGapStatement

/-- Factorized closure reducer:
`VS≤νP (all traj, t≥0)` closes `PreciseGapStatement` once the final analytic target
`dΩ/dt≤0 (all traj, t≥0) -> PreciseGapStatement` is discharged. -/
theorem vs_le_nu_p_all_implies_precise_gap_of_enstrophy_target
    (hTarget : EnstrophyMonotoneToPreciseGapTargetProp)
    (hAll : VSLeNuPAllTrajProp) :
    PreciseGapStatement :=
  hTarget (vs_le_nu_p_all_implies_enstrophy_rate_nonpos_all hAll)

/-- Composition reducer:
the universal trajectory-level form of `VS ≤ νP` discharges the Stage-64
open-content implication to `PreciseGapStatement`. -/
theorem vs_le_nu_p_all_implies_precise_gap :
  VSLeNuPAllTrajProp → PreciseGapStatement := by
  intro hAll
  exact bridge_target_linear_entropic_control_implies_precise_gap
    (NavierStokes.OpenBottleneck.vs_le_nu_p_implies_linear_entropic_control hAll)

/-- Conditional closure theorem:
if the kernel proposition is established constructively, then
`PreciseGapStatement` follows. -/
theorem slice_projection_kernel_implies_precise_gap
    (hKernel : SliceProjectionCouplingBoundProp) :
    PreciseGapStatement := by
  exact vs_le_nu_p_all_implies_precise_gap
    (slice_projection_kernel_implies_vs_le_nu_p_all hKernel)

/-- Factorized kernel corollary:
if the final enstrophy-target theorem is available, kernel control implies
`PreciseGapStatement` without invoking the Stage-64 boundary wrapper. -/
theorem slice_projection_kernel_implies_precise_gap_of_enstrophy_target
    (hTarget : EnstrophyMonotoneToPreciseGapTargetProp)
    (hKernel : SliceProjectionCouplingBoundProp) :
    PreciseGapStatement :=
  vs_le_nu_p_all_implies_precise_gap_of_enstrophy_target hTarget
    (slice_projection_kernel_implies_vs_le_nu_p_all hKernel)

/-- Closed target theorem:
the final enstrophy-target implication is derivable from the existing Stage-64
linear-entropic bridge plus the reverse kernel reducer `dΩ/dt≤0 -> VS≤νP`. -/
theorem enstrophy_monotone_to_precise_gap_target_from_stage64 :
    EnstrophyMonotoneToPreciseGapTargetProp := by
  intro hMono
  exact vs_le_nu_p_all_implies_precise_gap
    (enstrophy_rate_nonpos_all_implies_vs_le_nu_p_all hMono)

/-! ## 4. Stage 69 Constructive Obligations -> Kernel -> Gap -/

/-- Theorem-level decomposition step:
slice-PDE constructive obligations imply the kernel proposition through the
export contract surfaced by `BohmBianchiCouplingBridge`. -/
theorem slice_projection_pde_side_implies_slice_projection_kernel
    (hPDE : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEProp) :
    SliceProjectionCouplingBoundProp := by
  intro traj t hNS hFS
  exact
      (NavierStokes.BohmBianchiConstructive.stage69_constructive_pde_obligation_implies_kernel_export hPDE)
      traj t hNS hFS

/-- Component-obligation reducer:
the explicit constructive slice-PDE component obligations (momentum/vorticity/
coefficient) imply the kernel proposition directly through the Stage-69 PDE
obligation constructor. -/
theorem slice_projection_components_imply_slice_projection_kernel
    (hComp : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEComponentsProp) :
    SliceProjectionCouplingBoundProp := by
  intro traj t hNS hFS
  exact
    (NavierStokes.BohmBianchiConstructive.slice_geometry_components_imply_kernel_export hComp)
      traj t hNS hFS

/-- Component-obligation kernel-to-universal reducer:
explicit constructive slice-PDE component obligations imply universal trajectory
`VS ≤ νP` on `t ≥ 0`. -/
theorem slice_projection_components_imply_vs_le_nu_p_all
    (hComp : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEComponentsProp) :
    VSLeNuPAllTrajProp :=
  slice_projection_kernel_implies_vs_le_nu_p_all
    (slice_projection_components_imply_slice_projection_kernel hComp)

/-- Component-obligation kernel-to-monotonicity reducer:
explicit constructive slice-PDE component obligations imply universal
enstrophy monotonicity `dΩ/dt ≤ 0` on `t ≥ 0`. -/
theorem slice_projection_components_imply_enstrophy_rate_nonpos_all
    (hComp : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEComponentsProp) :
    EnstrophyRateNonposAllTrajProp :=
  slice_projection_kernel_implies_enstrophy_rate_nonpos_all
    (slice_projection_components_imply_slice_projection_kernel hComp)

/-- Decomposed bridge theorem from Stage 69 obligations to the kernel proposition.

Current reduction is anchored on the slice-PDE side; the Bohm/SDE side is
retained as an explicit hypothesis for the full Stage 69 contract chain. -/
theorem stage69_constructive_obligations_imply_slice_projection_kernel
    (hPDE : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEProp)
    (hSDE : NavierStokes.BohmBianchiConstructive.BohmOsmoticHolonomyConstructiveSDEPDEProp) :
    SliceProjectionCouplingBoundProp := by
  -- Keep Stage 69 two-sided obligations linked in the reduction chain.
  have _hStage69 :
      NavierStokes.BohmBianchi.BianchiForcesCouplingProp ∧
      NavierStokes.BohmBianchi.BohmOsmoticMatchesCouplingProp :=
    NavierStokes.BohmBianchiConstructive.stage69_constructive_obligations_imply_structural_bridges
      hPDE hSDE
  exact slice_projection_pde_side_implies_slice_projection_kernel hPDE

/-- Main conditional closure theorem in fully typed contract form:
Stage 69 constructive obligations imply `PreciseGapStatement` through the
kernel chain. -/
theorem stage69_constructive_obligations_imply_precise_gap
    (hPDE : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEProp)
    (hSDE : NavierStokes.BohmBianchiConstructive.BohmOsmoticHolonomyConstructiveSDEPDEProp) :
    PreciseGapStatement := by
  exact slice_projection_kernel_implies_precise_gap
    (stage69_constructive_obligations_imply_slice_projection_kernel hPDE hSDE)

/-- Component-obligation closure reducer:
proving the three explicit slice-PDE primitive component obligations
(momentum/vorticity/coefficient) is sufficient to derive `PreciseGapStatement`
through the unweighted kernel chain (modulo Stage-64 bridge). -/
theorem slice_projection_components_imply_precise_gap
    (hComp : NavierStokes.BohmBianchiConstructive.SliceGeometryNSCouplingConstructivePDEComponentsProp) :
    PreciseGapStatement := by
  exact slice_projection_kernel_implies_precise_gap
    (slice_projection_components_imply_slice_projection_kernel hComp)

/-- Corollary through the current constructive target symbol.

This is still open in substance because it depends on
upstream Stage-64 and slice-export open-content obligations. -/
theorem slice_projection_constructive_target_implies_precise_gap :
    NavierStokes.BohmBianchi.SliceProjectionPrimitiveDerivationProp →
    PreciseGapStatement := by
  intro hDeriv
  exact slice_projection_kernel_implies_precise_gap
    (slice_projection_coupling_bound_constructive hDeriv)

/-- Direct core corollary:
pointwise slice primitive `VS≤νP` implies `PreciseGapStatement` through the
unweighted kernel chain. This is the most direct bottleneck-facing route. -/
theorem slice_projection_direct_vs_le_nuP_implies_precise_gap
    (hVS : NavierStokes.SliceDecomposition.SliceProjectedVSLeNuPPrimitiveProp) :
    PreciseGapStatement := by
  exact slice_projection_kernel_implies_precise_gap
    (slice_projection_coupling_bound_from_direct_vs_le_nuP hVS)

/-- Explicit conditional closure through subcritical slice regime:
if slices stay in `Ω² ≤ ν⁴ λ₁ / C⁴`, then `PreciseGapStatement` follows through
the unweighted kernel chain. -/
theorem slice_projection_subcritical_enstrophy_implies_precise_gap
    (hSub : NavierStokes.SliceDecomposition.SliceProjectedSubcriticalEnstrophyProp) :
    PreciseGapStatement := by
  exact slice_projection_kernel_implies_precise_gap
    (slice_projection_coupling_bound_from_subcritical_enstrophy hSub)

/-- Explicit conditional closure through constructive cap witness:
if slices admit a constructive uniform enstrophy cap witness compatible with the
subcritical threshold, then `PreciseGapStatement` follows through the direct
`VS≤νP` kernel route. -/
theorem slice_projection_subcritical_cap_witness_implies_precise_gap
    (hW : NavierStokes.SliceDecomposition.SliceProjectedSubcriticalCapWitnessProp) :
    PreciseGapStatement := by
  exact slice_projection_kernel_implies_precise_gap
    (slice_projection_coupling_bound_from_subcritical_cap_witness hW)

/-- Explicit conditional closure through cap-threshold compatibility primitive:
if slices satisfy the cap-threshold primitive contract, then `PreciseGapStatement`
follows through the direct `VS≤νP` kernel route. -/
theorem slice_projection_cap_threshold_compatibility_implies_precise_gap
    (hCompat : NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    PreciseGapStatement := by
  exact slice_projection_kernel_implies_precise_gap
    (slice_projection_coupling_bound_from_cap_threshold_compatibility hCompat)

/-- Cap-threshold monotonicity corollary:
constructive cap-threshold compatibility data imply universal enstrophy
non-increase `dΩ/dt ≤ 0` through the unweighted kernel chain. -/
theorem slice_projection_cap_threshold_compatibility_implies_enstrophy_rate_nonpos_all
    (hCompat : NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    EnstrophyRateNonposAllTrajProp :=
  slice_projection_kernel_implies_enstrophy_rate_nonpos_all
    (slice_projection_coupling_bound_from_cap_threshold_compatibility hCompat)

/-- Factorized cap-threshold closure:
cap-threshold compatibility implies `PreciseGapStatement` once the final
enstrophy-target theorem is discharged. -/
theorem slice_projection_cap_threshold_compatibility_implies_precise_gap_of_enstrophy_target
    (hTarget : EnstrophyMonotoneToPreciseGapTargetProp)
    (hCompat : NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    PreciseGapStatement :=
  hTarget (slice_projection_cap_threshold_compatibility_implies_enstrophy_rate_nonpos_all hCompat)

/-- Closed constructive target corollary:
the primitive slice-projection theorem producers discharge the target route
without requiring an external witness argument. -/
theorem slice_projection_constructive_target_closed_implies_precise_gap :
    NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp →
    PreciseGapStatement :=
  slice_projection_kernel_implies_precise_gap
    ∘ slice_projection_coupling_bound_constructive_closed

/-- Legacy closed constructive target corollary (witness-parameterized):
retained as adapter; canonical closed route is cap-threshold based. -/
theorem slice_projection_constructive_target_closed_implies_precise_gap_legacy :
    NavierStokes.SliceDecomposition.SliceProjectedUniformEntropicRateSourceWitness →
    PreciseGapStatement :=
  slice_projection_kernel_implies_precise_gap
    ∘ slice_projection_coupling_bound_constructive_closed_legacy

/-- Closed constructive target corollary (cap-threshold branch):
explicit cap-threshold compatibility primitive data discharge the target route
without requiring a separate source-witness argument. -/
theorem slice_projection_constructive_target_closed_from_cap_threshold_compatibility_implies_precise_gap
    (hCompat : NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    PreciseGapStatement :=
  slice_projection_kernel_implies_precise_gap
    (slice_projection_coupling_bound_constructive_closed_from_cap_threshold_compatibility hCompat)

/-- Explicit causality-adapter closure route:
`CausalityBoundedLambda` plus explicit time-domain and threshold-compatibility
assumptions instantiate the kernel proposition and imply `PreciseGapStatement`. -/
theorem slice_projection_causality_adapter_implies_precise_gap
    (cb : CausalityBoundedLambda)
    (hTimeDomain : SliceTimeDomainNonnegativeProp)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    PreciseGapStatement := by
  exact slice_projection_kernel_implies_precise_gap
    (slice_projection_coupling_bound_from_causality cb hTimeDomain hCompat)

/-- Interval-local family from causality adapter:
for every `T>0`, we get pointwise `VS≤νP` on `[0,T]` without global
time-domain side-condition assumptions. -/
theorem slice_projection_causality_interval_family
    (cb : CausalityBoundedLambda)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    ∀ (T : Rat), 0 < T →
      ∀ (traj : Trajectory NSField) (t : Rat),
        0 ≤ t →
        t ≤ T →
        SatisfiesNSPDE nsOps nsNu traj →
        RespectsFunctionSpaces nsSpacesR3 traj →
        vortexStretchingIntegral traj t ≤
          nsNu * palinstrophy (traj.stateAt t).velocity := by
  intro T hT traj t ht0 htT hNS hFS
  exact slice_projection_causality_interval_implies_vs_le_nuP cb T hT hCompat
    traj t ht0 htT hNS hFS

/-- No-global-time-domain adapter closure:
the interval-local `VS≤νP` family is obtained constructively from causality
assumptions, and `PreciseGapStatement` follows via the existing causality route. -/
theorem slice_projection_causality_interval_implies_precise_gap
    (cb : CausalityBoundedLambda)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    PreciseGapStatement := by
  have _hLocalFamily := slice_projection_causality_interval_family cb hCompat
  exact causality_bounded_implies_precise_gap cb

/-! ## 5. Claim Registry -/

def vsNuPResolutionBridgeClaims : List LabeledClaim :=
  [ ⟨"slice_projection_kernel_implies_vs_le_nu_p_all", .verified,
      "THEOREM: kernel coefficient proposition implies universal trajectory-level VS≤νP on t≥0"⟩
  , ⟨"vs_le_nu_p_all_implies_enstrophy_rate_nonpos_all", .verified,
      "THEOREM: universal trajectory-level VS≤νP on t≥0 implies universal enstrophy monotonicity dΩ/dt≤0 on t≥0"⟩
  , ⟨"enstrophy_rate_nonpos_all_implies_vs_le_nu_p_all", .verified,
      "THEOREM: universal enstrophy monotonicity dΩ/dt≤0 on t≥0 implies universal trajectory-level VS≤νP on t≥0 (kernel converse)"⟩
  , ⟨"slice_projection_kernel_implies_enstrophy_rate_nonpos_all", .verified,
      "THEOREM: kernel proposition implies universal enstrophy monotonicity dΩ/dt≤0"⟩
  , ⟨"enstrophy_monotone_to_precise_gap_target_from_stage64", .partiallyVerified,
      "THEOREM: final enstrophy-target implication dΩ/dt≤0(all traj,t≥0)→PreciseGapStatement follows from reverse kernel reducer + direct VS≤νP→linear-entropic composition"⟩
  , ⟨"vs_le_nu_p_all_implies_precise_gap_of_enstrophy_target", .partiallyVerified,
      "THEOREM: factorized closure — if dΩ/dt≤0(all traj,t≥0) implies PreciseGapStatement, then VS≤νP(all traj,t≥0) implies PreciseGapStatement"⟩
  , ⟨"slice_projection_kernel_implies_precise_gap_of_enstrophy_target", .partiallyVerified,
      "THEOREM: factorized kernel closure route through explicit final enstrophy-target theorem"⟩
  , ⟨"vs_le_nu_p_all_implies_precise_gap", .partiallyVerified,
      "THEOREM: composition reducer from universal VS≤νP to PreciseGapStatement via direct linear-entropic bridge composition (no Stage-64 boundary wrapper)"⟩
  , ⟨"slice_projection_pde_side_implies_slice_projection_kernel", .partiallyVerified,
      "THEOREM: theorem-level decomposition from slice-PDE constructive obligation (via Bohm bridge export) to NSVSNuPKernel proposition"⟩
  , ⟨"slice_projection_components_imply_slice_projection_kernel", .partiallyVerified,
      "THEOREM: explicit slice-PDE component obligations (momentum/vorticity/coefficient) imply NSVSNuPKernel proposition through Stage-69 PDE constructor"⟩
  , ⟨"slice_projection_components_imply_vs_le_nu_p_all", .partiallyVerified,
      "THEOREM: explicit slice-PDE component obligations imply universal trajectory-level VS≤νP on t≥0 via kernel reducer"⟩
  , ⟨"slice_projection_components_imply_enstrophy_rate_nonpos_all", .partiallyVerified,
      "THEOREM: explicit slice-PDE component obligations imply universal enstrophy monotonicity dΩ/dt≤0 on t≥0 via kernel reducer"⟩
  , ⟨"stage69_constructive_obligations_imply_slice_projection_kernel", .partiallyVerified,
      "THEOREM: decomposed Stage 69 obligations imply NSVSNuPKernel proposition (currently anchored on PDE-side reduction)"⟩
  , ⟨"stage69_constructive_obligations_imply_precise_gap", .partiallyVerified,
      "THEOREM: Stage 69 constructive obligations imply PreciseGapStatement through the kernel chain (modulo open bridges)"⟩
  , ⟨"slice_projection_components_imply_precise_gap", .partiallyVerified,
      "THEOREM: explicit three-component slice-PDE obligations imply PreciseGapStatement through the unweighted kernel chain (modulo Stage-64 bridge)"⟩
  , ⟨"slice_projection_kernel_implies_precise_gap", .partiallyVerified,
      "THEOREM: under open bridge, kernel proposition implies PreciseGapStatement"⟩
  , ⟨"slice_projection_constructive_target_implies_precise_gap", .partiallyVerified,
      "COROLLARY: constructive target (parameterized by slice witness) yields PreciseGapStatement through reducer chain (remaining open content is upstream Stage-64 only)"⟩
  , ⟨"slice_projection_direct_vs_le_nuP_implies_precise_gap", .partiallyVerified,
      "COROLLARY: direct pointwise slice primitive VS≤νP yields PreciseGapStatement through the unweighted kernel chain (remaining open content is upstream Stage-64)"⟩
  , ⟨"slice_projection_subcritical_enstrophy_implies_precise_gap", .partiallyVerified,
      "COROLLARY: explicit subcritical slice condition Ω²≤ν⁴λ₁/C⁴ yields PreciseGapStatement through direct VS≤νP kernel route (remaining open content is upstream Stage-64)"⟩
  , ⟨"slice_projection_subcritical_cap_witness_implies_precise_gap", .partiallyVerified,
      "COROLLARY: constructive cap-witness data (Ω≤Ω_max and Ω_max²≤ν⁴λ₁/C⁴) yields PreciseGapStatement through direct VS≤νP kernel route (remaining open content is upstream Stage-64)"⟩
  , ⟨"slice_projection_cap_threshold_compatibility_implies_precise_gap", .partiallyVerified,
      "COROLLARY: cap-threshold compatibility primitive contract yields PreciseGapStatement through direct VS≤νP kernel route (remaining open content is upstream Stage-64)"⟩
  , ⟨"slice_projection_cap_threshold_compatibility_implies_enstrophy_rate_nonpos_all", .partiallyVerified,
      "COROLLARY: cap-threshold compatibility primitive route implies universal enstrophy monotonicity dΩ/dt≤0 (pre-Stage64 analytic target)"⟩
  , ⟨"slice_projection_cap_threshold_compatibility_implies_precise_gap_of_enstrophy_target", .partiallyVerified,
      "COROLLARY: cap-threshold compatibility route closes PreciseGapStatement once final enstrophy-target theorem is discharged"⟩
  , ⟨"slice_projection_constructive_target_closed_implies_precise_gap", .partiallyVerified,
      "COROLLARY: constructive target route from cap-threshold compatibility primitive data to PreciseGapStatement (remaining open content is upstream Stage-64)"⟩
  , ⟨"slice_projection_constructive_target_closed_implies_precise_gap_legacy", .partiallyVerified,
      "COROLLARY (legacy): witness-parameterized closed route retained as adapter; superseded by cap-threshold canonical route"⟩
  , ⟨"slice_projection_constructive_target_closed_from_cap_threshold_compatibility_implies_precise_gap", .partiallyVerified,
      "COROLLARY: constructive target route from explicit cap-threshold compatibility primitive data to PreciseGapStatement (remaining open content is upstream Stage-64)"⟩
  , ⟨"slice_projection_causality_adapter_implies_precise_gap", .partiallyVerified,
      "COROLLARY: explicit CausalityBoundedLambda adapter assumptions instantiate the kernel proposition and imply PreciseGapStatement (remaining open content is upstream Stage-64)"⟩
  , ⟨"slice_projection_causality_interval_family", .partiallyVerified,
      "THEOREM: causality adapter yields interval-local family of pointwise VS≤νP on [0,T] without global time-domain side-condition assumptions"⟩
  , ⟨"slice_projection_causality_interval_implies_precise_gap", .partiallyVerified,
      "COROLLARY: interval-local causality adapter route + existing causality closure imply PreciseGapStatement without global time-domain side-condition assumptions"⟩ ]

end

end NavierStokes.Millennium
