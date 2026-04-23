import NavierStokesClean.Galerkin.VSNuPSpatialBridge

/-!
# VS≤νP Legacy Compatibility (Clean Spatial Carrier)

This file ports the core symbol surface of legacy
`NSVSNuPKernel.lean` / `NSVSNuPResolutionBridge.lean` to the clean repo,
using the spatialized bridge theorem stack already present in
`VSNuPSpatialBridge.lean`.

No new axioms, no `sorry`.
-/

set_option autoImplicit false

namespace NavierStokesClean.Galerkin

open NavierStokesClean

noncomputable section

/-! ## 1. Ratio guard surface (legacy name preservation) -/

/-- Legacy-style stretching ratio `VS/Ω` on the spatial carrier. -/
def stretchingRatioAt
    (traj : NSSpaceTrajectory) (t : ℝ)
    (_hE : 0 < spatialEnstrophy (traj t)) : ℝ :=
  vorticityStretching (traj t) / spatialEnstrophy (traj t)

/-- Legacy-style spectral ratio `P/Ω` on the spatial carrier. -/
def spectralRatioAt
    (traj : NSSpaceTrajectory) (t : ℝ)
    (_hE : 0 < spatialEnstrophy (traj t)) : ℝ :=
  palinstrophySpatial (traj t) / spatialEnstrophy (traj t)

/-- Legacy algebraic guard, adapted to spatial operators:
`VS ≤ νP` iff `VS/Ω ≤ ν(P/Ω)` when `Ω > 0`. -/
theorem vs_le_nuP_iff_ratio_guard
    (traj : NSSpaceTrajectory) (ν t : ℝ)
    (hE : 0 < spatialEnstrophy (traj t)) :
    vorticityStretching (traj t) ≤ ν * palinstrophySpatial (traj t) ↔
      stretchingRatioAt traj t hE ≤ ν * spectralRatioAt traj t hE := by
  have hE0 : spatialEnstrophy (traj t) ≠ 0 := ne_of_gt hE
  constructor
  · intro hVS
    have hdiv :
        vorticityStretching (traj t) / spatialEnstrophy (traj t) ≤
          (ν * palinstrophySpatial (traj t)) / spatialEnstrophy (traj t) :=
      div_le_div_of_nonneg_right hVS (le_of_lt hE)
    simpa [stretchingRatioAt, spectralRatioAt, mul_div_assoc] using hdiv
  · intro hRatio
    have hdiv :
        vorticityStretching (traj t) / spatialEnstrophy (traj t) ≤
          (ν * palinstrophySpatial (traj t)) / spatialEnstrophy (traj t) := by
      simpa [stretchingRatioAt, spectralRatioAt, mul_div_assoc] using hRatio
    field_simp [hE0] at hdiv
    exact hdiv

/-! ## 2. Kernel/resolution compatibility predicates -/

/-- Legacy-style universal `VS ≤ νP` predicate, adapted to the clean spatial bridge.

The explicit `hH1_t` hypothesis matches the current clean theoremized route
(`vsnup_spatial_small_data`). -/
def VSLeNuPAllTrajProp (ν : ℝ) : Prop :=
  ∀ (traj : NSSpaceTrajectory) (t : ℝ),
    0 < ν →
    SatisfiesSpatialNSPDE ν traj →
    (∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2) →
    vorticityStretching (traj t) ≤ ν * palinstrophySpatial (traj t)

/-- Legacy kernel proposition in coefficient form.

Compared to the legacy equality form `VS = θP`, we keep a monotone form
`VS ≤ θP` so the proposition is realizable on the current spatial route
without adding auxiliary equalities. -/
def SliceProjectionCouplingBoundProp (ν : ℝ) : Prop :=
  ∀ (traj : NSSpaceTrajectory) (t : ℝ),
    0 < ν →
    SatisfiesSpatialNSPDE ν traj →
    (∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2) →
    ∃ θ : ℝ, 0 ≤ θ ∧ θ ≤ ν ∧
      vorticityStretching (traj t) ≤ θ * palinstrophySpatial (traj t)

/-! ## 3. Kernel reduction theorems (legacy name preservation) -/

/-- Legacy reducer: kernel proposition implies universal `VS ≤ νP`. -/
theorem slice_projection_kernel_implies_vs_le_nu_p_all
    (ν : ℝ)
    (hKernel : SliceProjectionCouplingBoundProp ν) :
    VSLeNuPAllTrajProp ν := by
  intro traj t hν hNS hH1_t
  rcases hKernel traj t hν hNS hH1_t with ⟨θ, _hθnn, hθν, hVSθ⟩
  have hθP : θ * palinstrophySpatial (traj t) ≤ ν * palinstrophySpatial (traj t) :=
    mul_le_mul_of_nonneg_right hθν (palinstrophySpatial_nonneg (traj t))
  exact le_trans hVSθ hθP

/-- Constructive kernel witness from the existing clean spatial bridge theorem. -/
theorem slice_projection_kernel_from_vsnup_spatial_small_data
    (ν : ℝ) :
    SliceProjectionCouplingBoundProp ν := by
  intro traj t hν hNS hH1_t
  refine ⟨ν, le_of_lt hν, le_rfl, ?_⟩
  simpa using vsnup_spatial_small_data traj ν hν hNS t hH1_t

/-- Legacy universal form derived from the clean spatial bridge route. -/
theorem vs_le_nu_p_all_from_spatial_bridge
    (ν : ℝ) :
    VSLeNuPAllTrajProp ν :=
  slice_projection_kernel_implies_vs_le_nu_p_all ν
    (slice_projection_kernel_from_vsnup_spatial_small_data ν)

/-- Legacy ratio corollary from the universal spatial bridge form. -/
theorem ratio_guard_from_spatial_bridge
    (ν : ℝ)
    (hAll : VSLeNuPAllTrajProp ν)
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hν : 0 < ν)
    (hNS : SatisfiesSpatialNSPDE ν traj)
    (hH1_t : ∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2)
    (hE : 0 < spatialEnstrophy (traj t)) :
    stretchingRatioAt traj t hE ≤ ν * spectralRatioAt traj t hE := by
  exact (vs_le_nuP_iff_ratio_guard traj ν t hE).1 (hAll traj t hν hNS hH1_t)

end
end NavierStokesClean.Galerkin
