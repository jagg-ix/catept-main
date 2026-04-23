import NavierStokes.VS.NSVSNuPKernel

/-!
# VS/Ω/P Kernel (Canonical Unweighted Interface)

This module exposes the bottleneck kernel in explicit `VS/Ω/P` language while
reusing the already-proved unweighted trajectory theorems from
`NSVSNuPKernel.lean`.

Scope:
- no Cameron/Weber weighting
- no stochastic closure assumptions
- direct trajectory-level inequalities in terms of `VS`, `Ω`, `P`

The only constructive open target remains the slice-projection coefficient
witness proposition.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

/-- Canonical kernel proposition over NS trajectories:
`VS = θP` with `0 ≤ θ ≤ ν` at each time. -/
abbrev VSOmegaPKernelProp : Prop := SliceProjectionCouplingBoundProp

/-- Canonical ratio guard theorem:
`VS ≤ νP ↔ VS/Ω ≤ ν(P/Ω)` (for `Ω > 0`). -/
theorem vs_le_nuP_iff_vs_over_omega_le_nu_p_over_omega
    (traj : Trajectory NSField) (t : Rat)
    (hE : 0 < enstrophy (traj.stateAt t).velocity) :
    vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity ↔
      stretchingRatioAt traj t hE ≤ nsNu * spectralRatioAt traj t hE :=
  vs_le_nuP_iff_ratio_guard traj t hE

/-- Kernel-to-bottleneck theorem:
`VSOmegaPKernelProp` implies `VS ≤ νP`. -/
theorem vs_omega_p_kernel_implies_vs_le_nuP
    (hKernel : VSOmegaPKernelProp)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity :=
  slice_projection_bound_implies_vs_le_nuP hKernel traj t hNS hFS

/-- Kernel consequence in enstrophy form:
`VSOmegaPKernelProp` implies `dΩ/dt ≤ 0`. -/
theorem vs_omega_p_kernel_implies_enstrophy_rate_nonpos
    (hKernel : VSOmegaPKernelProp)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    enstrophyRate traj t ≤ 0 :=
  slice_projection_bound_implies_enstrophy_nonpos hKernel traj t hNS hFS

/-- Canonical open target for constructive closure (slice PDE side). -/
theorem vs_omega_p_kernel_constructive_target
    (hDeriv : NavierStokes.BohmBianchi.SliceProjectionPrimitiveDerivationProp) :
    VSOmegaPKernelProp :=
  slice_projection_coupling_bound_constructive hDeriv

/-- Closed canonical constructive target:
the unweighted `VS/Ω/P` kernel proposition follows directly from NS
slice-projection primitive theorem producers. -/
theorem vs_omega_p_kernel_constructive_target_closed :
    NavierStokes.SliceDecomposition.SliceProjectedCapThresholdCompatibilityPrimitiveProp →
    VSOmegaPKernelProp :=
  slice_projection_coupling_bound_constructive_closed

/-- Legacy closed canonical constructive target (witness-parameterized):
retained as adapter; canonical closed target is cap-threshold based. -/
theorem vs_omega_p_kernel_constructive_target_closed_legacy :
    NavierStokes.SliceDecomposition.SliceProjectedUniformEntropicRateSourceWitness →
    VSOmegaPKernelProp :=
  slice_projection_coupling_bound_constructive_closed_legacy

def vsOmegaPKernelClaims : List LabeledClaim :=
  [ ⟨"vs_le_nuP_iff_vs_over_omega_le_nu_p_over_omega", .verified,
      "THEOREM: unweighted ratio guard VS≤νP ↔ VS/Ω≤ν(P/Ω) for Ω>0"⟩
  , ⟨"vs_omega_p_kernel_implies_vs_le_nuP", .verified,
      "THEOREM: unweighted VS/Ω/P kernel witness implies VS≤νP"⟩
  , ⟨"vs_omega_p_kernel_implies_enstrophy_rate_nonpos", .verified,
      "THEOREM: unweighted VS/Ω/P kernel witness implies dΩ/dt≤0"⟩
  , ⟨"vs_omega_p_kernel_constructive_target", .partiallyVerified,
      "THEOREM: witness-parameterized route from slice primitive derivation to unweighted VS/Ω/P kernel proposition"⟩
  , ⟨"vs_omega_p_kernel_constructive_target_closed", .partiallyVerified,
      "THEOREM: route from cap-threshold compatibility primitive data to unweighted VS/Ω/P kernel proposition (canonical closed route)"⟩
  , ⟨"vs_omega_p_kernel_constructive_target_closed_legacy", .partiallyVerified,
      "THEOREM (legacy): witness-parameterized closed route retained as adapter; superseded by cap-threshold canonical route"⟩ ]

end

end NavierStokes.Millennium
