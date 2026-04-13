import NavierStokesClean.Audit.NSSemanticFidelityGapAudit

/-!
Legacy-compat wrapper for `NSSemanticFidelityGapAudit.lean`.
Canonical implementation lives in `NavierStokesClean/Audit/NSSemanticFidelityGapAudit.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NSSemanticFidelityGapAudit

open NavierStokesClean

lemma gap1_NSField_is_point_vector :
    NSField = EuclideanSpace ℝ (Fin 3) :=
  SemanticFidelity.gap1_NSField_is_point_vector

lemma gap2_palinstrophy_is_placeholder :
    palinstrophy = (fun _ : NSField => (0 : ℝ)) :=
  SemanticFidelity.gap2_palinstrophy_is_placeholder

lemma gap3_vorticity_zero_for_lifted (traj : Trajectory) :
    ∀ t : ℝ, vorticity (trajectoryToSpatial traj t) = (fun _ => 0) :=
  SemanticFidelity.gap3_vorticity_zero_for_lifted traj

end NavierStokesClean.LegacyCompat.NSSemanticFidelityGapAudit
