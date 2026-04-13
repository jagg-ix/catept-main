import NavierStokesClean.Sobolev.PeriodicSobolev
import NavierStokesClean.Galerkin.VSNuPSpatialBridge

/-!
Legacy-compat leverage surface for `NST3SobolevSupplement.lean`.
Connects periodic Sobolev contracts with the clean VS<=nuP route.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NST3SobolevSupplement

open NavierStokesClean
open NavierStokesClean.Galerkin

lemma t3PoincareContract_holds (u : NSVelocityField) :
    spatialEnstrophy u ≤ palinstrophySpatial u :=
  NavierStokesClean.Sobolev.sa_g1b_poincare_t3_from_sub u

lemma agmon_h2_linfty_periodic_holds (u : NSVelocityField) (hSmooth : ContDiff ℝ 2 u) :
    (vorticityLinfNorm u).toReal ^ 2 ≤ palinstrophySpatial u * spatialEnstrophy u :=
  NavierStokesClean.Sobolev.agmon_h2_linfty_periodic u hSmooth

lemma vs_le_nup_from_subcritical
    (traj : NSSpaceTrajectory) (ν : ℝ)
    (hν : 0 < ν)
    (hNS : SatisfiesSpatialNSPDE ν traj)
    (t : ℝ)
    (hH1_t : ∫ x : Space, ‖fderiv ℝ (traj t) x‖ ^ 2 ≤ ν ^ 2) :
    vorticityStretching (traj t) ≤ ν * palinstrophySpatial (traj t) :=
  vsnup_spatial_small_data traj ν hν hNS t hH1_t

end NavierStokesClean.LegacyCompat.NST3SobolevSupplement
