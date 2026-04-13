import NavierStokes.EnstrophyEvolutionBalance
import NavierStokes.BohmBianchiCouplingBridge
import NavierStokes.CausalityBoundedRegularity
import Mathlib.Tactic.FieldSimp

/-!
# NS VS-νP Kernel

Focused kernel for the irreducible Navier-Stokes bottleneck:

`VS ≤ νP` on actual 3D NS trajectories.

This module avoids surrogate records and works directly with trajectory-level
quantities already present in the formalization:
- `vortexStretchingIntegral` (VS)
- `enstrophy` (Ω)
- `palinstrophy` (P)
- `enstrophyRate` (`dΩ/dt`)

It introduces:
1. Ratio guards `VS/Ω` and `P/Ω`.
2. Direct equivalence between `VS ≤ νP` and the ratio inequality.
3. A primitive slice-projection coupling proposition over NS trajectories.
4. Theorem consequences from that proposition (`VS ≤ νP`, `dΩ/dt ≤ 0`).
5. A theorem-level reducer from the upstream slice-export contract.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

/-! ## 1. Direct Ratio Guards -/

/-- Stretching-to-enstrophy ratio `VS/Ω` at time `t`. -/
def stretchingRatioAt
    (traj : Trajectory NSField) (t : Rat)
    (_hE : 0 < enstrophy (traj.stateAt t).velocity) : Rat :=
  vortexStretchingIntegral traj t / enstrophy (traj.stateAt t).velocity

/-- Spectral ratio `P/Ω` at time `t`. -/
def spectralRatioAt
    (traj : Trajectory NSField) (t : Rat)
    (_hE : 0 < enstrophy (traj.stateAt t).velocity) : Rat :=
  palinstrophy (traj.stateAt t).velocity / enstrophy (traj.stateAt t).velocity

/-- Direct algebraic guard:
`VS ≤ νP` iff `VS/Ω ≤ ν(P/Ω)` when `Ω > 0`. -/
theorem vs_le_nuP_iff_ratio_guard
    (traj : Trajectory NSField) (t : Rat)
    (hE : 0 < enstrophy (traj.stateAt t).velocity) :
    vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity ↔
      stretchingRatioAt traj t hE ≤ nsNu * spectralRatioAt traj t hE := by
  unfold stretchingRatioAt spectralRatioAt
  have hE0 : enstrophy (traj.stateAt t).velocity ≠ 0 := ne_of_gt hE
  constructor
  · intro hVS
    have hRatio :
        vortexStretchingIntegral traj t / enstrophy (traj.stateAt t).velocity ≤
          nsNu * (palinstrophy (traj.stateAt t).velocity /
            enstrophy (traj.stateAt t).velocity) := by
      field_simp [hE0]
      exact hVS
    exact hRatio
  · intro hRatio
    have hVS : vortexStretchingIntegral traj t ≤
        nsNu * palinstrophy (traj.stateAt t).velocity := by
      field_simp [hE0] at hRatio
      exact hRatio
    exact hVS

/-! ## 2. Direct Consequences of `VS ≤ νP` -/

/-- If `VS ≤ νP`, then `2VS ≤ 2νP`. -/
theorem two_vs_le_two_nuP_of_vs_le_nuP
    (traj : Trajectory NSField) (t : Rat)
    (hVS : vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity) :
    2 * vortexStretchingIntegral traj t ≤
      2 * nsNu * palinstrophy (traj.stateAt t).velocity := by
  simpa [mul_assoc] using
    mul_le_mul_of_nonneg_left hVS (by norm_num : (0 : Rat) ≤ 2)

/-- If `VS ≤ νP`, then enstrophy is non-increasing at that instant. -/
theorem enstrophy_rate_nonpos_of_vs_le_nuP
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hVS : vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity) :
    enstrophyRate traj t ≤ 0 := by
  exact enstrophy_rate_nonpos_when_dissipation_dominates traj t hNS hFS
    (two_vs_le_two_nuP_of_vs_le_nuP traj t hVS)

/-- Converse kernel consequence:
if enstrophy is non-increasing at that instant (`dΩ/dt ≤ 0`), then `VS ≤ νP`.

This is the direct algebraic converse of
`enstrophy_rate_nonpos_of_vs_le_nuP` under the exact enstrophy evolution
identity `dΩ/dt = -2νP + 2VS`. -/
theorem vs_le_nuP_of_enstrophy_rate_nonpos
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hRate : enstrophyRate traj t ≤ 0) :
    vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity := by
  rw [enstrophy_evolution_identity traj t hNS hFS] at hRate
  nlinarith

/-! ## 3. Complex Noether ↔ NS Bottleneck Identification -/

/-- Imaginary-sector defect at time `t`:
`νP - VS`. Nonnegativity of this defect is the direct NS bottleneck condition. -/
def nsImaginaryNoetherDefect
    (traj : Trajectory NSField) (t : Rat) : Rat :=
  nsNu * palinstrophy (traj.stateAt t).velocity - vortexStretchingIntegral traj t

/-- Direct algebraic identification:
`νP - VS ≥ 0` iff `VS ≤ νP`. -/
theorem ns_imaginary_noether_defect_nonneg_iff_vs_le_nuP
    (traj : Trajectory NSField) (t : Rat) :
    0 ≤ nsImaginaryNoetherDefect traj t ↔
      vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity := by
  unfold nsImaginaryNoetherDefect
  constructor
  · intro hDefect
    nlinarith
  · intro hVS
    nlinarith

/-- Kernel equivalence at a fixed time:
`VS ≤ νP` iff `dΩ/dt ≤ 0` under the exact enstrophy evolution identity. -/
theorem vs_le_nuP_iff_enstrophy_rate_nonpos
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity ↔
      enstrophyRate traj t ≤ 0 := by
  constructor
  · intro hVS
    exact enstrophy_rate_nonpos_of_vs_le_nuP traj t hNS hFS hVS
  · intro hRate
    exact vs_le_nuP_of_enstrophy_rate_nonpos traj t hNS hFS hRate

/-- Exact Lean-side proposition for the CAT/EPT complex-Noether identification
at the NS bottleneck:
- defect nonnegativity (`νP - VS ≥ 0`)
- direct bottleneck inequality (`VS ≤ νP`)
- enstrophy monotonicity certificate (`dΩ/dt ≤ 0`)
are equivalent at each trajectory-time point. -/
def ComplexNoetherNSBottleneckIdentificationProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    (0 ≤ nsImaginaryNoetherDefect traj t ↔
      vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity) ∧
    (0 ≤ nsImaginaryNoetherDefect traj t ↔
      enstrophyRate traj t ≤ 0)

/-- The complex-Noether bottleneck identification holds at kernel level. -/
theorem complex_noether_ns_bottleneck_identification :
    ComplexNoetherNSBottleneckIdentificationProp := by
  intro traj t hNS hFS
  constructor
  · exact ns_imaginary_noether_defect_nonneg_iff_vs_le_nuP traj t
  · exact (ns_imaginary_noether_defect_nonneg_iff_vs_le_nuP traj t).trans
      (vs_le_nuP_iff_enstrophy_rate_nonpos traj t hNS hFS)

/-! ## 4. Primitive Slice-Projection Kernel Proposition -/

/-- Primitive kernel proposition over NS trajectories:
the vertical slice-projection coupling produces a coefficient `θ(t)` with
`0 ≤ θ ≤ ν` such that `VS = θ P`. -/
def SliceProjectionCouplingBoundProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    ∃ θ : Rat, 0 ≤ θ ∧ θ ≤ nsNu ∧
      vortexStretchingIntegral traj t =
        θ * palinstrophy (traj.stateAt t).velocity

/-- Interval-local kernel proposition over NS trajectories on `[0,T]`.
This variant matches `EntropicRateBounded` semantics directly. -/
def SliceProjectionCouplingBoundOnIntervalProp (T : Rat) : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    t ≤ T →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    ∃ θ : Rat, 0 ≤ θ ∧ θ ≤ nsNu ∧
      vortexStretchingIntegral traj t =
        θ * palinstrophy (traj.stateAt t).velocity

/-- Kernel consequence: the slice-projection proposition implies `VS ≤ νP`. -/
theorem slice_projection_bound_implies_vs_le_nuP
    (hKernel : SliceProjectionCouplingBoundProp)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity := by
  rcases hKernel traj t hNS hFS with ⟨θ, _hθnn, hθν, hEq⟩
  rw [hEq]
  exact mul_le_mul_of_nonneg_right hθν (palinstrophy_nonneg _)

/-- Interval-local kernel consequence: on `[0,T]`, the kernel proposition
implies pointwise `VS ≤ νP`. -/
theorem slice_projection_bound_on_interval_implies_vs_le_nuP
    (T : Rat)
    (hKernel : SliceProjectionCouplingBoundOnIntervalProp T)
    (traj : Trajectory NSField) (t : Rat)
    (ht0 : 0 ≤ t) (htT : t ≤ T)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity := by
  rcases hKernel traj t ht0 htT hNS hFS with ⟨θ, _hθnn, hθν, hEq⟩
  rw [hEq]
  exact mul_le_mul_of_nonneg_right hθν (palinstrophy_nonneg _)

/-- Kernel consequence: the slice-projection proposition implies enstrophy decay
at each instant (`dΩ/dt ≤ 0`). -/
theorem slice_projection_bound_implies_enstrophy_nonpos
    (hKernel : SliceProjectionCouplingBoundProp)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    enstrophyRate traj t ≤ 0 := by
  exact enstrophy_rate_nonpos_of_vs_le_nuP traj t hNS hFS
    (slice_projection_bound_implies_vs_le_nuP hKernel traj t hNS hFS)

/-- Ratio-form corollary from the kernel proposition. -/
theorem slice_projection_bound_implies_ratio_guard
    (hKernel : SliceProjectionCouplingBoundProp)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hE : 0 < enstrophy (traj.stateAt t).velocity) :
    stretchingRatioAt traj t hE ≤ nsNu * spectralRatioAt traj t hE :=
  (vs_le_nuP_iff_ratio_guard traj t hE).1
    (slice_projection_bound_implies_vs_le_nuP hKernel traj t hNS hFS)

/-! ## 5. Kernel Reducer from Slice Export -/

/-- Direct kernel reducer from the core pointwise primitive:
if slice primitives supply pointwise `VS ≤ νP`, then the kernel proposition
follows immediately via the explicit normalized coefficient witness. -/
theorem slice_projection_coupling_bound_from_direct_vs_le_nuP
    (hVS : NavierStokes.SliceDecomposition.SliceProjectedVSLeNuPPrimitiveProp) :
    SliceProjectionCouplingBoundProp := by
  intro traj t hNS hFS
  refine ⟨NavierStokes.SliceDecomposition.projectedThetaCoeff traj t,
    NavierStokes.SliceDecomposition.projectedThetaCoeff_nonneg traj t,
    ?_, NavierStokes.SliceDecomposition.projectedThetaCoeff_equation traj t hNS hFS⟩
  exact (NavierStokes.SliceDecomposition.projectedThetaCoeff_le_nu_iff_vs_le_nuP traj t hNS hFS).2
    (hVS traj t hNS hFS)

/-- Kernel reducer through explicit subcritical slice condition:
`Ω² ≤ ν⁴ λ₁ / C⁴` on slices implies the kernel proposition via the direct
bottleneck reducer. -/
theorem slice_projection_coupling_bound_from_subcritical_enstrophy
    (hSub : NavierStokes.SliceDecomposition.SliceProjectedSubcriticalEnstrophyProp) :
    SliceProjectionCouplingBoundProp :=
  slice_projection_coupling_bound_from_direct_vs_le_nuP
    (NavierStokes.SliceDecomposition.slice_projected_vs_le_nuP_from_subcritical_enstrophy hSub)

/-- Kernel reducer through constructive cap witness:
subcritical cap witness data (`Ω≤Ω_max`, `Ω_max²≤ν⁴λ₁/C⁴`) implies the kernel
proposition through the direct pointwise primitive `VS≤νP`. -/
theorem slice_projection_coupling_bound_from_subcritical_cap_witness
    (hW : NavierStokes.SliceDecomposition.SliceProjectedSubcriticalCapWitnessProp) :
    SliceProjectionCouplingBoundProp :=
  slice_projection_coupling_bound_from_direct_vs_le_nuP
    (NavierStokes.SliceDecomposition.slice_projected_vs_le_nuP_from_subcritical_cap_witness hW)

/-- Kernel reducer through cap-threshold compatibility primitive:
the cap-threshold compatibility primitive contract implies the kernel
proposition through the direct pointwise primitive `VS≤νP`. -/
theorem slice_projection_coupling_bound_from_cap_threshold_compatibility
    (hCompat : NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    SliceProjectionCouplingBoundProp :=
  slice_projection_coupling_bound_from_direct_vs_le_nuP
    (NavierStokes.SliceDecomposition.slice_projected_vs_le_nuP_from_cap_threshold_compatibility hCompat)

/-- Kernel constructive target reducer:
the slice-export contract in `BohmBianchiCouplingBridge` implies the kernel
proposition directly. This removes duplication of open obligations in this file. -/
theorem slice_projection_coupling_bound_constructive :
  NavierStokes.BohmBianchi.SliceProjectionPrimitiveDerivationProp →
  SliceProjectionCouplingBoundProp := by
  intro hDeriv
  exact slice_projection_coupling_bound_from_direct_vs_le_nuP
    (NavierStokes.BohmBianchi.slice_projection_witness_existence_implies_direct_vs_le_nuP hDeriv)

/-- Normalized kernel reducer (V2):
the normalized slice-projection witness contract is definitionally identical to
the kernel proposition. -/
theorem slice_projection_coupling_bound_from_normalized_witness
    (hW : NavierStokes.SliceDecomposition.SliceProjectedThetaWitnessProp) :
    SliceProjectionCouplingBoundProp := hW

/-- Closed kernel constructive target:
the slice-projection coefficient bound proposition follows directly from
NS slice-projection primitive theorem producers. -/
theorem slice_projection_coupling_bound_constructive_closed :
    NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp →
    SliceProjectionCouplingBoundProp :=
  slice_projection_coupling_bound_from_direct_vs_le_nuP
    ∘ NavierStokes.SliceDecomposition.slice_projected_vs_le_nuP_from_cap_threshold_compatibility

/-- Legacy closed constructive target (witness-parameterized):
kept as adapter for backward compatibility; the canonical closed route is now
`slice_projection_coupling_bound_constructive_closed` via cap-threshold compatibility. -/
theorem slice_projection_coupling_bound_constructive_closed_legacy :
    NavierStokes.SliceDecomposition.SliceProjectedUniformEntropicRateSourceWitness →
    SliceProjectionCouplingBoundProp :=
  slice_projection_coupling_bound_from_direct_vs_le_nuP
    ∘ NavierStokes.SliceDecomposition.slice_projected_vs_le_nuP_constructive_producer

/-- Closed kernel constructive target (cap-threshold branch):
the slice-projection coefficient bound proposition follows directly from
explicit cap-threshold compatibility primitive data. -/
theorem slice_projection_coupling_bound_constructive_closed_from_cap_threshold_compatibility
    (hCompat : NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    SliceProjectionCouplingBoundProp :=
  slice_projection_coupling_bound_from_direct_vs_le_nuP
    (NavierStokes.SliceDecomposition.slice_projected_vs_le_nuP_from_cap_threshold_compatibility hCompat)

/-! ## 6. Explicit Causality Adapter (Witness Instantiation) -/

/-- Explicit side-condition: trajectories on this route are time-domain nonnegative.
This keeps `EntropicRateBounded` interval semantics (`0 ≤ t ≤ T`) compatible
with the witness used by the slice-projection kernel path. -/
abbrev SliceTimeDomainNonnegativeProp : Prop :=
  NavierStokes.SliceDecomposition.SliceProjectedTimeDomainNonnegativeProp

/-- Adapter theorem:
instantiate the remaining slice-rate source witness from `CausalityBoundedLambda`
plus explicit time-domain and threshold-compatibility assumptions. -/
theorem slice_rate_source_witness_from_causality
    (cb : CausalityBoundedLambda)
    (hTimeDomain : SliceTimeDomainNonnegativeProp)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    NavierStokes.SliceDecomposition.SliceProjectedUniformEntropicRateSourceWitness :=
  NavierStokes.SliceDecomposition.slice_projected_rate_source_witness_from_causality
    cb hTimeDomain hCompat

/-- Kernel corollary:
with the explicit causality adapter assumptions, the slice-projection kernel
proposition follows without introducing a hidden global export. -/
theorem slice_projection_coupling_bound_from_causality
    (cb : CausalityBoundedLambda)
    (hTimeDomain : SliceTimeDomainNonnegativeProp)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    SliceProjectionCouplingBoundProp :=
  slice_projection_coupling_bound_from_direct_vs_le_nuP
    (NavierStokes.SliceDecomposition.slice_projected_vs_le_nuP_from_causality
      cb hTimeDomain hCompat)

/-- Interval-local causality adapter:
derive the kernel proposition on `[0,T]` directly from `CausalityBoundedLambda`
and scalar threshold compatibility, without any global time-domain side-condition. -/
theorem slice_projection_coupling_bound_on_interval_from_causality
    (cb : CausalityBoundedLambda)
    (T : Rat) (hT : 0 < T)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    SliceProjectionCouplingBoundOnIntervalProp T := by
  intro traj t ht0 htT hNS hFS
  have hRateBounded : EntropicRateBounded cb.lambdaMax traj T :=
    cb.holds traj T hT hNS
  have hGradCap :
      gradientNormSquared (traj.stateAt t).velocity ≤ (hbar / nsNu) * cb.lambdaMax :=
    entropic_rate_cap_implies_enstrophy_cap cb.lambdaMax traj T t ht0 htT hRateBounded
  have hOmegaLe :
      enstrophy (traj.stateAt t).velocity ≤ (hbar / nsNu) * cb.lambdaMax := by
    calc
      enstrophy (traj.stateAt t).velocity =
          gradientNormSquared (traj.stateAt t).velocity :=
        enstrophyGradientIdentity traj t hNS
      _ ≤ (hbar / nsNu) * cb.lambdaMax := hGradCap
  have hOmegaNN : 0 ≤ enstrophy (traj.stateAt t).velocity :=
    enstrophy_nonneg (traj.stateAt t).velocity
  have hSub :
      enstrophy (traj.stateAt t).velocity * enstrophy (traj.stateAt t).velocity ≤
        subcriticalEnstrophySquaredThreshold := by
    nlinarith [hOmegaLe, hOmegaNN, hCompat]
  have h2 : 2 * vortexStretchingIntegral traj t ≤
      2 * nsNu * palinstrophy (traj.stateAt t).velocity :=
    subcritical_enstrophy_implies_stretching_dominated traj t hNS hFS hSub
  have hVS : vortexStretchingIntegral traj t ≤
      nsNu * palinstrophy (traj.stateAt t).velocity := by
    nlinarith
  refine ⟨NavierStokes.SliceDecomposition.projectedThetaCoeff traj t,
    NavierStokes.SliceDecomposition.projectedThetaCoeff_nonneg traj t,
    NavierStokes.SliceDecomposition.projectedThetaCoeff_le_nu_of_vs_le_nuP traj t hVS,
    NavierStokes.SliceDecomposition.projectedThetaCoeff_equation traj t hNS hFS⟩

/-- Interval-local bottleneck consequence from the causality adapter:
on `[0,T]`, one gets direct pointwise `VS ≤ νP` without global time-domain
side-condition assumptions. -/
theorem slice_projection_causality_interval_implies_vs_le_nuP
    (cb : CausalityBoundedLambda)
    (T : Rat) (hT : 0 < T)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    ∀ (traj : Trajectory NSField) (t : Rat),
      0 ≤ t →
      t ≤ T →
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      vortexStretchingIntegral traj t ≤
        nsNu * palinstrophy (traj.stateAt t).velocity := by
  intro traj t ht0 htT hNS hFS
  exact slice_projection_bound_on_interval_implies_vs_le_nuP T
    (slice_projection_coupling_bound_on_interval_from_causality cb T hT hCompat)
    traj t ht0 htT hNS hFS

/-! ## 7. Claim Registry -/

def vsNuPKernelClaims : List LabeledClaim :=
  [ ⟨"vs_le_nuP_iff_ratio_guard", .verified,
      "THEOREM: VS≤νP iff VS/Ω ≤ ν(P/Ω) for Ω>0 (direct algebraic kernel guard)"⟩
  , ⟨"ns_imaginary_noether_defect_nonneg_iff_vs_le_nuP", .verified,
      "THEOREM: complex-Noether defect νP−VS is nonnegative iff VS≤νP (exact algebraic identification)"⟩
  , ⟨"vs_le_nuP_iff_enstrophy_rate_nonpos", .verified,
      "THEOREM: VS≤νP iff dΩ/dt≤0 under exact enstrophy evolution identity"⟩
  , ⟨"complex_noether_ns_bottleneck_identification", .verified,
      "THEOREM: exact kernel proposition linking CAT/EPT complex-Noether defect nonnegativity, VS≤νP, and enstrophy-rate monotonicity"⟩
  , ⟨"enstrophy_rate_nonpos_of_vs_le_nuP", .verified,
      "THEOREM: VS≤νP implies dΩ/dt≤0 (direct enstrophy kernel consequence)"⟩
  , ⟨"vs_le_nuP_of_enstrophy_rate_nonpos", .verified,
      "THEOREM: dΩ/dt≤0 implies VS≤νP (direct algebraic converse under enstrophy evolution identity)"⟩
  , ⟨"slice_projection_bound_implies_vs_le_nuP", .verified,
      "THEOREM: primitive slice-projection coefficient bound implies VS≤νP"⟩
  , ⟨"slice_projection_bound_implies_enstrophy_nonpos", .verified,
      "THEOREM: primitive slice-projection coefficient bound implies dΩ/dt≤0"⟩
  , ⟨"slice_projection_bound_implies_ratio_guard", .verified,
      "THEOREM: primitive slice-projection coefficient bound implies ratio guard VS/Ω ≤ ν(P/Ω)"⟩
  , ⟨"slice_projection_coupling_bound_from_direct_vs_le_nuP", .partiallyVerified,
      "THEOREM: direct core reducer from pointwise slice primitive VS≤νP to kernel proposition via explicit normalized coefficient witness"⟩
  , ⟨"slice_projection_coupling_bound_from_subcritical_enstrophy", .partiallyVerified,
      "THEOREM: explicit subcritical slice condition Ω²≤ν⁴λ₁/C⁴ implies kernel proposition through direct VS≤νP reducer"⟩
  , ⟨"slice_projection_coupling_bound_from_subcritical_cap_witness", .partiallyVerified,
      "THEOREM: constructive cap witness (Ω≤Ω_max and Ω_max²≤ν⁴λ₁/C⁴) implies kernel proposition through direct VS≤νP reducer"⟩
  , ⟨"slice_projection_coupling_bound_from_cap_threshold_compatibility", .partiallyVerified,
      "THEOREM: cap-threshold compatibility primitive contract implies kernel proposition through direct VS≤νP reducer"⟩
  , ⟨"slice_projection_coupling_bound_constructive", .partiallyVerified,
      "THEOREM: reducer from BohmBianchi witness-parameterized slice-export contract to NSVSNuPKernel proposition"⟩
  , ⟨"slice_projection_coupling_bound_from_normalized_witness", .partiallyVerified,
      "THEOREM: normalized slice witness contract directly yields the NSVSNuPKernel proposition"⟩
  , ⟨"slice_projection_coupling_bound_constructive_closed", .partiallyVerified,
      "THEOREM: NSVSNuPKernel proposition from cap-threshold compatibility primitive data through direct VS≤νP reducer (canonical closed route)"⟩
  , ⟨"slice_projection_coupling_bound_constructive_closed_legacy", .partiallyVerified,
      "THEOREM (legacy): witness-parameterized closed route retained as adapter; superseded by cap-threshold canonical closed route"⟩
  , ⟨"slice_projection_coupling_bound_constructive_closed_from_cap_threshold_compatibility", .partiallyVerified,
      "THEOREM: NSVSNuPKernel proposition from explicit cap-threshold compatibility primitive data through direct VS≤νP reducer"⟩
  , ⟨"slice_rate_source_witness_from_causality", .partiallyVerified,
      "THEOREM: explicit adapter from CausalityBoundedLambda + time-domain nonnegativity + threshold compatibility to slice-rate source witness"⟩
  , ⟨"slice_projection_coupling_bound_from_causality", .partiallyVerified,
      "COROLLARY: explicit causality adapter assumptions instantiate the slice-projection kernel proposition without hidden global export"⟩
  , ⟨"slice_projection_coupling_bound_on_interval_from_causality", .partiallyVerified,
      "THEOREM: interval-local causality adapter gives pointwise kernel witness on [0,T] directly from EntropicRateBounded + threshold compatibility, without global time-domain side-condition"⟩
  , ⟨"slice_projection_causality_interval_implies_vs_le_nuP", .partiallyVerified,
      "THEOREM: interval-local causality adapter yields direct pointwise VS≤νP on [0,T] with no global time-domain side-condition"⟩ ]

end

end NavierStokes.Millennium
