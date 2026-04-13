import NavierStokesClean.NSGalerkinDefectSplitBridge
import NavierStokesClean.CATEPT.ArakiRelativeEntropyBridge

/-!
Legacy-compat leverage surface for `NSGalerkinVSDefectBridge.lean`.
Re-exports VS-sequence convergence on the clean lifted trajectory carrier.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NSGalerkinVSDefectBridge

open NavierStokesClean
open NavierStokesClean.CATEPT
open Filter

lemma galerkin_defect_limit_eq (traj : Trajectory) (t : ℝ) :
    spatialImaginaryNoetherDefect (trajectoryToSpatial traj) t = 0 := by
  unfold spatialImaginaryNoetherDefect
  have hVS : vorticityStretching (trajectoryToSpatial traj t) = 0 := by
    simpa [trajectoryToSpatial] using vorticityStretching_zero_of_const (traj t)
  have hPal : palinstrophySpatial (trajectoryToSpatial traj t) = 0 := by
    simpa [trajectoryToSpatial] using palinstrophySpatial_zero_of_const (traj t)
  simp [hVS, hPal]

lemma galerkin_vs_convergence_from_pal_seq_proved
    (traj_seq : Nat → Trajectory) (T : ℝ) :
    Tendsto
      (fun N => ∫ t in Set.Ioc 0 T, vorticityStretching (trajectoryToSpatial (traj_seq N) t))
      atTop (nhds 0) :=
  LegacyCompat.NSGalerkinDefectSplitBridge.galerkin_vs_convergence_from_pal_seq traj_seq T

end NavierStokesClean.LegacyCompat.NSGalerkinVSDefectBridge
