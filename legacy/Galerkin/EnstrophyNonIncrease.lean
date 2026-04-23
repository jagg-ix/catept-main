import NavierStokesClean.Galerkin.VSNuPSpatialBridge
import Mathlib.Analysis.Calculus.Deriv.MeanValue

/-!
# m04: Enstrophy Non-Increase (VS≤νP + Enstrophy Equation)

## Summary

This file derives the **enstrophy non-increase theorem** by connecting two results
already proved in the spatial bridge lane:

1. **Enstrophy equation** (`SatisfiesSpatialNSPDEFull.hEnstrophyEq`):
     d/dt Ω(t) = −2ν · P(t) + 2 · VS(t)
   where Ω = spatialEnstrophy, P = palinstrophySpatial, VS = vorticityStretching.

2. **VS ≤ νP** (`vsnup_spatial_small_data`, conditional on SA-G1 + SA-G1b):
     VS(t) ≤ ν · P(t)   when ∫‖∇u(t)‖² ≤ ν²

Together they give:
   d/dt Ω(t) = −2ν·P(t) + 2·VS(t) ≤ −2ν·P(t) + 2ν·P(t) = 0

so enstrophy is non-increasing on any interval where the small-data H¹ control holds.

## Theorems

| Theorem | Content | Axioms |
|---------|---------|--------|
| `enstrophy_deriv_le_zero` | RHS of enstrophy eq ≤ 0 at each t | SA-G1, SA-G1b, `vorticityStretching_zero_of_const` |
| `enstrophy_hasDerivAt_nonpos` | HasDerivAt with ≤ 0 derivative at each t | same |
| `enstrophy_antitoneOn_small_data` | spatialEnstrophy is antitone on [t₁,t₂] | same + explicit `hCont` |

## Semantic gap note (m04)

`hCont : ContinuousOn (fun s => spatialEnstrophy (traj s)) (Set.Icc t₁ t₂)` is an explicit
hypothesis in `enstrophy_antitoneOn_small_data`. The derivation of continuity from
`SatisfiesSpatialNSPDEFull` requires parameter continuity of the spatial integral
`∫ x, ‖vorticity (traj t) x‖²` in t — a dominated-convergence argument that needs
the concrete T³ Sobolev framework (NSC-P33 discharge target).

Until NSC-P33: `SatisfiesSpatialNSPDEFull` carries `hEnstrophyEq` (the derivative
equation) but not integral continuity. The explicit `hCont` makes the gap transparent
rather than hiding it behind an axiom.

## Zero sorry, zero warnings.
-/

set_option autoImplicit false

namespace NavierStokesClean.Galerkin

open NavierStokesClean MeasureTheory Set

/-! ## §1. Enstrophy equation RHS is ≤ 0 (small-data) -/

/-- **Enstrophy derivative ≤ 0** (m04 core).

    Given that VS(t) ≤ ν · P(t) (from `vsnup_spatial_small_data`, conditional on SA-G1 + SA-G1b),
    the RHS of the enstrophy equation satisfies:
      −2ν · P(t) + 2 · VS(t) ≤ −2ν · P(t) + 2ν · P(t) = 0

    **Axioms consumed**: SA-G1, SA-G1b (via `vsnup_spatial_small_data`); no new axioms. -/
theorem enstrophy_deriv_le_zero
    (traj : NSSpaceTrajectory) (ν : ℝ)
    (hν : 0 < ν)
    (hFull : SatisfiesSpatialNSPDEFull ν traj)
    (t : ℝ)
    (hH1_t : ∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2) :
    -2 * ν * palinstrophySpatial (traj t) + 2 * vorticityStretching (traj t) ≤ 0 := by
  have hVS := vsnup_spatial_small_data traj ν hν hFull.toSatisfiesSpatialNSPDE t hH1_t
  nlinarith [palinstrophySpatial_nonneg (traj t)]

/-! ## §2. HasDerivAt with nonpositive value -/

/-- **HasDerivAt with ≤ 0 value** (m04).

    Combines `SatisfiesSpatialNSPDEFull.hEnstrophyEq` with `enstrophy_deriv_le_zero`
    to give: the spatial enstrophy has a HasDerivAt at each t, and that derivative ≤ 0.

    This is the pointwise statement of enstrophy decrease — no continuity required. -/
theorem enstrophy_hasDerivAt_nonpos
    (traj : NSSpaceTrajectory) (ν : ℝ)
    (hν : 0 < ν)
    (hFull : SatisfiesSpatialNSPDEFull ν traj)
    (t : ℝ)
    (hH1_t : ∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2) :
    ∃ d : ℝ, d ≤ 0 ∧
      HasDerivAt (fun s => spatialEnstrophy (traj s)) d t :=
  ⟨_, enstrophy_deriv_le_zero traj ν hν hFull t hH1_t, hFull.hEnstrophyEq t⟩

/-! ## §3. Enstrophy is antitone on [t₁, t₂] -/

/-- **Enstrophy is antitone** (non-increasing) on [t₁, t₂] in the small-data regime.

    **Proof chain**:
    1. `enstrophy_deriv_le_zero`: at each t ∈ interior [t₁,t₂], d/dt Ω(t) ≤ 0
    2. `hFull.hEnstrophyEq t`: provides `HasDerivAt`, hence `DifferentiableAt`
    3. `antitoneOn_of_deriv_nonpos` (Mathlib): ContinuousOn + DifferentiableOn + deriv ≤ 0 → AntitoneOn

    **Semantic gap** (`hCont`): Continuity of `t ↦ spatialEnstrophy (traj t)` is stated as an
    explicit hypothesis because it requires parameter continuity of the spatial integral,
    which depends on the concrete T³ measure structure (NSC-P33 discharge target).

    **Axioms consumed**: SA-G1, SA-G1b (via `vsnup_spatial_small_data`); no new axioms. -/
theorem enstrophy_antitoneOn_small_data
    (traj : NSSpaceTrajectory) (ν : ℝ) (t₁ t₂ : ℝ)
    (ht : t₁ ≤ t₂)
    (hν : 0 < ν)
    (hFull : SatisfiesSpatialNSPDEFull ν traj)
    (hH1 : ∀ t ∈ Icc t₁ t₂, ∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2)
    (hCont : ContinuousOn (fun s => spatialEnstrophy (traj s)) (Icc t₁ t₂)) :
    spatialEnstrophy (traj t₂) ≤ spatialEnstrophy (traj t₁) := by
  -- DifferentiableOn from HasDerivAt at each point
  have hDiff : DifferentiableOn ℝ (fun s => spatialEnstrophy (traj s))
      (interior (Icc t₁ t₂)) :=
    fun t _ => (hFull.hEnstrophyEq t).differentiableAt.differentiableWithinAt
  -- antitoneOn_of_deriv_nonpos from Mathlib
  have hAnt : AntitoneOn (fun s => spatialEnstrophy (traj s)) (Icc t₁ t₂) := by
    apply antitoneOn_of_deriv_nonpos (convex_Icc t₁ t₂) hCont hDiff
    intro t ht_int
    rw [(hFull.hEnstrophyEq t).deriv]
    exact enstrophy_deriv_le_zero traj ν hν hFull t (hH1 t (interior_subset ht_int))
  exact hAnt (left_mem_Icc.mpr ht) (right_mem_Icc.mpr ht) ht

/-! ## §4. Corollary: enstrophy does not blow up under small-data control -/

/-- **Enstrophy bound in small-data regime**.

    If the H¹ control `∫‖∇u(t)‖² ≤ ν²` holds uniformly on [0,T],
    then `spatialEnstrophy (traj T) ≤ spatialEnstrophy (traj 0)`.

    This is the enstrophy cascade blocking argument from Temam 1984 §III:
    VS ≤ νP prevents enstrophy amplification, ruling out blowup in the small-data regime. -/
theorem enstrophy_bounded_by_initial_small_data
    (traj : NSSpaceTrajectory) (ν T : ℝ)
    (hT : 0 ≤ T)
    (hν : 0 < ν)
    (hFull : SatisfiesSpatialNSPDEFull ν traj)
    (hH1 : ∀ t ∈ Icc 0 T, ∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2)
    (hCont : ContinuousOn (fun s => spatialEnstrophy (traj s)) (Icc 0 T)) :
    spatialEnstrophy (traj T) ≤ spatialEnstrophy (traj 0) :=
  enstrophy_antitoneOn_small_data traj ν 0 T hT hν hFull hH1 hCont

end NavierStokesClean.Galerkin
