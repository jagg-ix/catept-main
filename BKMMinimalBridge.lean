import NavierStokesClean.Core.EnergyFunctionals
import NavierStokesClean.Millennium.BKMContinuationPipeline

/-!
Legacy-compat leverage surface for `BKMMinimalBridge.lean`.
Bridges minimal BKM endpoint names to the clean continuation pipeline.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.BKMMinimalBridge

open NavierStokesClean
open NavierStokesClean.Millennium

lemma bkmVorticityIntegral_nonneg (traj : Trajectory) (T : ℝ) (hT : 0 ≤ T) :
    (0 : ℝ) ≤ bkmVorticityIntegral traj T :=
  bkm_nonneg traj T hT

lemma bkm_bounded_implies_converges :
    NavierStokesClean.Millennium.PreciseGapStatement →
      MillenniumNS_BoundedDomain.FeffermanB :=
  ns_bkm_global_existence_from_pgs

lemma bkm_proxy_implies_continuation :
    MillenniumNS_BoundedDomain.FeffermanB :=
  leray_fk_bkm_from_physical_mode0

lemma minimal_bridge_to_globalRegularity :
    MillenniumNavierStokes.NavierStokesMillenniumProblem :=
  millennium_C_global_regularity_via_pipeline

end NavierStokesClean.LegacyCompat.BKMMinimalBridge
