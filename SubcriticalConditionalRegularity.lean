import NavierStokesClean.Galerkin.VSNuPSpatialBridge
import NavierStokesClean.Galerkin.EnstrophyNonIncrease

/-!
Legacy-compat leverage surface for `SubcriticalConditionalRegularity.lean`.
Reuses the clean small-data VS<=nuP and enstrophy monotonicity chain.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.SubcriticalConditionalRegularity

open NavierStokesClean
open NavierStokesClean.Galerkin

lemma vs_le_nuP_at_t_of_subcritical_enstrophy
    (traj : NSSpaceTrajectory) (ν : ℝ)
    (hν : 0 < ν)
    (hNS : SatisfiesSpatialNSPDE ν traj)
    (t : ℝ)
    (hH1_t : ∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2) :
    vorticityStretching (traj t) ≤ ν * palinstrophySpatial (traj t) :=
  vsnup_spatial_small_data traj ν hν hNS t hH1_t

lemma subcritical_rate_to_monotonicity
    (traj : NSSpaceTrajectory) (ν : ℝ)
    (hν : 0 < ν)
    (hFull : SatisfiesSpatialNSPDEFull ν traj)
    (t : ℝ)
    (hH1_t : ∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2) :
    -2 * ν * palinstrophySpatial (traj t) + 2 * vorticityStretching (traj t) ≤ 0 :=
  enstrophy_deriv_le_zero traj ν hν hFull t hH1_t

end NavierStokesClean.LegacyCompat.SubcriticalConditionalRegularity
