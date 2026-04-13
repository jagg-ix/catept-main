import NavierStokesClean.CATEPT.ModularNoetherCompatibility
import NavierStokesClean.CATEPT.ArakiRelativeEntropyBridge

/-!
Legacy-compat leverage surface for `NSDualSphereFiberDecomposition.lean`.
The clean carrier exposes the key defect decomposition and monotonicity identities.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NSDualSphereFiberDecomposition

open NavierStokesClean
open NavierStokesClean.CATEPT

noncomputable section

abbrev dualSphereDefect := spatialImaginaryNoetherDefect

lemma dualSphereDefect_nonneg_iff_vsnup (traj : NSSpaceTrajectory) (t : ℝ) :
    0 ≤ dualSphereDefect traj t ↔
      vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t) :=
  defect_nonneg_iff_vs_le_nuP traj t

lemma modular_entropy_controls_defect_integral
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hFull : NavierStokesClean.Galerkin.SatisfiesSpatialNSPDEFull nsNu traj) :
    deriv (fun s => nsArakiRelativeEntropySpatial traj s) t ≤ 0 ↔ 0 ≤ dualSphereDefect traj t :=
  ns_araki_rel_entropy_spatial_decreasing_iff_defect_nonneg traj t hFull

end
end NavierStokesClean.LegacyCompat.NSDualSphereFiberDecomposition
