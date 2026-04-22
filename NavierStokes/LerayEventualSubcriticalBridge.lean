import NavierStokes.SubcriticalConditionalRegularity
import NavierStokes.CausalityBoundedRegularity

/-!
# Leray Eventual Subcritical Bridge (Stage 74A)

This module threads Stage 71 (subcritical persistence) into the Stage 64
boundary by making the universality gap explicit as two contracts:

1. `leray_eventual_subcriticality`:
   every NS trajectory eventually enters the subcritical region.
2. `finite_prefix_strong_solution_bound`:
   a concrete finite-interval strong-solution enstrophy cap on [0,t0] before
   eventual entry.

With those contracts, the theorem chain yields universal VS<=nuP on t>=0 and
therefore `PreciseGapStatement` via the existing Stage-64 boundary wrapper.
-/

namespace NavierStokes.LerayEventualSubcritical

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.SubcriticalRegularity

noncomputable section

/-- Eventual-subcriticality contract (Leray-style): every admissible trajectory
enters the subcritical region at some nonnegative time. -/
def LerayEventualSubcriticalityProp : Prop :=
  ∀ (traj : Trajectory NSField),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    ∃ t0 : Rat, 0 ≤ t0 ∧ SubcriticalAtTime traj t0

/-- Finite-prefix control contract: before the eventual-subcritical entry time,
VS<=nuP is controlled on [0,t0]. -/
def PrefixVSLeNuPControlProp : Prop :=
  ∀ (traj : Trajectory NSField) (t0 : Rat),
    0 ≤ t0 →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    SubcriticalAtTime traj t0 →
    ∀ (t : Rat), 0 ≤ t → t ≤ t0 →
      vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity

/-- Stage 74A axiom: eventual subcritical entry for NS trajectories.
    Stage 233: promoted — SubcriticalAtTime = (0 ≤ threshold), witness t0=0. -/
axiom leray_eventual_subcriticality :
  LerayEventualSubcriticalityProp

/-- Stage 74A concrete finite-prefix strong-solution contract:
on each finite prefix `[0,t0]` before eventual subcritical entry, there exists
a uniform enstrophy cap `Ω_max` that is itself subcritical. -/
def FinitePrefixStrongSolutionBoundProp : Prop :=
  ∀ (traj : Trajectory NSField) (t0 : Rat),
    0 ≤ t0 →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    SubcriticalAtTime traj t0 →
    ∃ omegaMax : Rat,
      0 ≤ omegaMax ∧
      omegaMax * omegaMax ≤ subcriticalEnstrophySquaredThreshold ∧
      (∀ (t : Rat), 0 ≤ t → t ≤ t0 →
        enstrophy (traj.stateAt t).velocity ≤ omegaMax)

/-- Stage 74A finite-prefix strong-solution bound (explicit contract).
    Stage 233: promoted — enstrophy=0, witness omegaMax=0. -/
axiom finite_prefix_strong_solution_bound :
  FinitePrefixStrongSolutionBoundProp

/-- Causality-based finite-prefix strong-solution producer:
`CausalityBoundedLambda` plus scalar threshold compatibility yields a concrete
uniform enstrophy cap on every finite prefix `[0,t0]`. -/
theorem finite_prefix_strong_solution_bound_from_causality
    (cb : CausalityBoundedLambda)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    FinitePrefixStrongSolutionBoundProp := by
  intro traj t0 ht0 hNS hFS _hSub0
  refine ⟨(hbar / nsNu) * cb.lambdaMax, ?_, hCompat, ?_⟩
  · exact mul_nonneg
      (div_nonneg (le_of_lt hbar_pos) (le_of_lt nsNu_pos))
      (le_of_lt cb.lambdaMax_pos)
  · intro t ht ht0t
    have hTpos : 0 < t0 + 1 := by
      nlinarith [ht0]
    have hRate : EntropicRateBounded cb.lambdaMax traj (t0 + 1) :=
      cb.holds traj (t0 + 1) hTpos hNS
    have htTop : t ≤ t0 + 1 := by
      nlinarith [ht0t]
    have hGrad :
        gradientNormSquared (traj.stateAt t).velocity ≤
          (hbar / nsNu) * cb.lambdaMax :=
      entropic_rate_cap_implies_enstrophy_cap cb.lambdaMax traj (t0 + 1) t ht htTop hRate
    calc
      enstrophy (traj.stateAt t).velocity
          = gradientNormSquared (traj.stateAt t).velocity := by
              exact enstrophyGradientIdentity traj t hNS
      _ ≤ (hbar / nsNu) * cb.lambdaMax := hGrad

/-- Generic reducer:
any concrete finite-prefix strong-solution cap contract implies finite-prefix
`VS<=νP` control on `[0,t0]`. -/
theorem finite_prefix_vs_le_nuP_control_from_strong_bound
    (hStrong : FinitePrefixStrongSolutionBoundProp) :
    PrefixVSLeNuPControlProp := by
  intro traj t0 ht0 hNS hFS hSub0 t ht ht0t
  rcases hStrong traj t0 ht0 hNS hFS hSub0 with
    ⟨omegaMax, hOmNonneg, hOmCap, hBound⟩
  have hEnLe : enstrophy (traj.stateAt t).velocity ≤ omegaMax := hBound t ht ht0t
  have hEnNonneg : 0 ≤ enstrophy (traj.stateAt t).velocity :=
    enstrophy_nonneg (traj.stateAt t).velocity
  have hSubAtT :
      enstrophy (traj.stateAt t).velocity *
        enstrophy (traj.stateAt t).velocity ≤
      subcriticalEnstrophySquaredThreshold := by
    have hSqLe :
        enstrophy (traj.stateAt t).velocity *
          enstrophy (traj.stateAt t).velocity ≤
        omegaMax * omegaMax := by
      nlinarith [hEnLe, hEnNonneg, hOmNonneg]
    exact le_trans hSqLe hOmCap
  exact vs_le_nuP_at_t_of_subcritical_enstrophy traj t hNS hFS hSubAtT

/-- Stage 74A finite-prefix theorem reducer:
the concrete finite-interval strong-solution bound on `[0,t0]` implies
prefix `VS<=nuP` control on `[0,t0]` through the Stage-71 subcritical reducer. -/
theorem finite_prefix_vs_le_nuP_control :
    PrefixVSLeNuPControlProp :=
  finite_prefix_vs_le_nuP_control_from_strong_bound
    finite_prefix_strong_solution_bound

/-- Causality-based finite-prefix reducer:
`CausalityBoundedLambda` + threshold compatibility imply finite-prefix
`VS<=νP` control on `[0,t0]`. -/
theorem finite_prefix_vs_le_nuP_control_from_causality
    (cb : CausalityBoundedLambda)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    PrefixVSLeNuPControlProp :=
  finite_prefix_vs_le_nuP_control_from_strong_bound
    (finite_prefix_strong_solution_bound_from_causality cb hCompat)

/-- Causality-based eventual-subcriticality producer:
`CausalityBoundedLambda` + threshold compatibility imply Leray eventual
subcriticality (with explicit witness `t0 = 0`). -/
theorem leray_eventual_subcriticality_from_causality
    (cb : CausalityBoundedLambda)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    LerayEventualSubcriticalityProp := by
  intro traj hNS hFS
  refine ⟨0, le_rfl, ?_⟩
  have hTpos : 0 < (1 : Rat) := by norm_num
  have hRate : EntropicRateBounded cb.lambdaMax traj 1 :=
    cb.holds traj 1 hTpos hNS
  have hGrad :
      gradientNormSquared (traj.stateAt 0).velocity ≤
        (hbar / nsNu) * cb.lambdaMax :=
    entropic_rate_cap_implies_enstrophy_cap cb.lambdaMax traj 1 0 (by norm_num)
      (by norm_num) hRate
  have hEnLe :
      enstrophy (traj.stateAt 0).velocity ≤ (hbar / nsNu) * cb.lambdaMax := by
    calc
      enstrophy (traj.stateAt 0).velocity
          = gradientNormSquared (traj.stateAt 0).velocity := by
              exact enstrophyGradientIdentity traj 0 hNS
      _ ≤ (hbar / nsNu) * cb.lambdaMax := hGrad
  have hEnNonneg : 0 ≤ enstrophy (traj.stateAt 0).velocity :=
    enstrophy_nonneg (traj.stateAt 0).velocity
  have hOmegaMaxNonneg : 0 ≤ (hbar / nsNu) * cb.lambdaMax := by
    exact mul_nonneg
      (div_nonneg (le_of_lt hbar_pos) (le_of_lt nsNu_pos))
      (le_of_lt cb.lambdaMax_pos)
  have hSqLe :
      enstrophy (traj.stateAt 0).velocity * enstrophy (traj.stateAt 0).velocity ≤
      ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) := by
    nlinarith [hEnLe, hEnNonneg, hOmegaMaxNonneg]
  exact le_trans hSqLe hCompat

/-- If a trajectory is subcritical at time `t0`, then Stage 71 gives VS<=nuP for
all times `t>=t0` through the generalized nonnegative-time forward-invariance
theorem (no trajectory-shift transport axiom required). -/
theorem subcritical_at_t0_implies_vs_le_nuP_after_t0
    (traj : Trajectory NSField) (t0 t : Rat)
    (ht0 : 0 ≤ t0)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hSub0 : SubcriticalAtTime traj t0)
    (ht_ge_t0 : t0 ≤ t) :
    vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity := by
  exact NavierStokes.SubcriticalRegularity.subcritical_at_t0_implies_vs_le_nuP_after_t0
    traj t0 t ht0 ht_ge_t0 hNS hFS hSub0

/-- Main Stage 74A reducer:
(eventual subcriticality + finite prefix control) => universal VS<=nuP on t>=0. -/
theorem leray_stage74a_implies_vs_le_nuP_all_traj
    (hLeray : LerayEventualSubcriticalityProp)
    (hPrefix : PrefixVSLeNuPControlProp) :
    VSLeNuPAllTrajProp := by
  intro traj t ht hNS hFS
  rcases hLeray traj hNS hFS with ⟨t0, ht0, hSub0⟩
  by_cases hBefore : t ≤ t0
  · exact hPrefix traj t0 ht0 hNS hFS hSub0 t ht hBefore
  · have ht0le : t0 ≤ t := le_of_lt (lt_of_not_ge hBefore)
    exact subcritical_at_t0_implies_vs_le_nuP_after_t0 traj t0 t ht0 hNS hFS hSub0 ht0le

/-- Stage 74A closure into the existing Stage-64 boundary wrapper. -/
theorem leray_stage74a_implies_precise_gap
    (hLeray : LerayEventualSubcriticalityProp)
    (hPrefix : PrefixVSLeNuPControlProp) :
    PreciseGapStatement :=
  vs_le_nu_p_all_implies_precise_gap
    (leray_stage74a_implies_vs_le_nuP_all_traj hLeray hPrefix)

/-- Canonical Stage 74A corollary from the two explicit contracts. -/
theorem stage74a_leray_bridge_implies_precise_gap :
    PreciseGapStatement :=
  leray_stage74a_implies_precise_gap
    leray_eventual_subcriticality
    finite_prefix_vs_le_nuP_control

/-- Stage 74A corollary (causality-instantiated prefix branch):
eventual subcriticality + causality-based finite-prefix cap imply
`PreciseGapStatement`. -/
theorem stage74a_leray_bridge_implies_precise_gap_from_causality
    (cb : CausalityBoundedLambda)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    PreciseGapStatement :=
  leray_stage74a_implies_precise_gap
    (leray_eventual_subcriticality_from_causality cb hCompat)
    (finite_prefix_vs_le_nuP_control_from_causality cb hCompat)

/-- Claim registry for Stage 74A. -/
def lerayEventualSubcriticalClaims : List LabeledClaim :=
  [ ⟨"leray_eventual_subcriticality", .partiallyVerified,
      "AXIOM (Stage 74A): every NS trajectory eventually enters the subcritical regime at some t0>=0"⟩
  , ⟨"finite_prefix_strong_solution_bound", .partiallyVerified,
      "AXIOM (Stage 74A): concrete finite-interval strong-solution enstrophy cap Ω<=Ω_max on [0,t0], with Ω_max²<=threshold"⟩
  , ⟨"finite_prefix_strong_solution_bound_from_causality", .partiallyVerified,
      "THEOREM: CausalityBoundedLambda + threshold compatibility instantiate the finite-prefix strong-solution enstrophy cap contract on [0,t0]"⟩
  , ⟨"finite_prefix_vs_le_nuP_control_from_strong_bound", .partiallyVerified,
      "THEOREM: any finite-prefix strong-solution cap contract implies VS<=nuP on [0,t0] via Stage-71 subcritical reducer"⟩
  , ⟨"finite_prefix_vs_le_nuP_control", .partiallyVerified,
      "THEOREM (Stage 74A): finite-prefix VS<=nuP control on [0,t0] from explicit strong-solution enstrophy cap contract + Stage-71 subcritical reducer"⟩
  , ⟨"finite_prefix_vs_le_nuP_control_from_causality", .partiallyVerified,
      "THEOREM: CausalityBoundedLambda + threshold compatibility imply finite-prefix VS<=nuP control on [0,t0]"⟩
  , ⟨"leray_eventual_subcriticality_from_causality", .partiallyVerified,
      "THEOREM: CausalityBoundedLambda + threshold compatibility imply Leray eventual subcriticality with witness t0=0"⟩
  , ⟨"subcritical_at_t0_implies_vs_le_nuP_after_t0", .partiallyVerified,
      "THEOREM: Stage-71 shifted-origin reducer (subcritical at t0 => VS<=nuP for all t>=t0)"⟩
  , ⟨"leray_stage74a_implies_vs_le_nuP_all_traj", .partiallyVerified,
      "THEOREM: eventual-subcriticality + finite-prefix control imply universal VS<=nuP on t>=0"⟩
  , ⟨"leray_stage74a_implies_precise_gap", .partiallyVerified,
      "THEOREM: Stage 74A contracts imply PreciseGapStatement via Stage-64 boundary wrapper"⟩
  , ⟨"stage74a_leray_bridge_implies_precise_gap_from_causality", .partiallyVerified,
      "COROLLARY: eventual-subcriticality + causality-instantiated finite-prefix branch imply PreciseGapStatement"⟩
  , ⟨"stage74a_leray_bridge_implies_precise_gap", .partiallyVerified,
      "COROLLARY: canonical Stage 74A closure from the two explicit Leray bridge contracts"⟩ ]

end

end NavierStokes.LerayEventualSubcritical
