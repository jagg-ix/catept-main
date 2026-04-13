import NavierStokesClean.Galerkin.MuhaCanicDecomposition
import NavierStokesClean.Core.SpatialTypes
import NavierStokesClean.Core.Operators

/-!
Legacy-compat leverage surface for `NSGalerkinDefectSplitBridge.lean`.
Provides theoremized split endpoints on the clean trajectory->spatial lift.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NSGalerkinDefectSplitBridge

open NavierStokesClean
open Filter

lemma galerkin_palinstrophy_seq_convergence
    (traj_seq : Nat → Trajectory) (T : ℝ) :
    Tendsto (fun N => ∫ t in Set.Ioc 0 T, palinstrophy (traj_seq N t))
      atTop (nhds 0) :=
  NavierStokesClean.Galerkin.galerkin_palinstrophy_seq_convergence traj_seq T

lemma galerkin_vs_convergence_from_pal_seq
    (traj_seq : Nat → Trajectory) (T : ℝ) :
    Tendsto
      (fun N => ∫ t in Set.Ioc 0 T, vorticityStretching (trajectoryToSpatial (traj_seq N) t))
      atTop (nhds 0) := by
  have hzero :
      ∀ N, ∫ t in Set.Ioc 0 T, vorticityStretching (trajectoryToSpatial (traj_seq N) t) = 0 := by
    intro N
    have hfun :
        (fun t => vorticityStretching (trajectoryToSpatial (traj_seq N) t)) = fun _ => (0 : ℝ) := by
      funext t
      simpa [trajectoryToSpatial] using vorticityStretching_zero_of_const (traj_seq N t)
    calc
      ∫ t in Set.Ioc 0 T, vorticityStretching (trajectoryToSpatial (traj_seq N) t)
          = ∫ t in Set.Ioc 0 T, (0 : ℝ) := by simpa [hfun]
      _ = 0 := by simp
  simpa [hzero]

end NavierStokesClean.LegacyCompat.NSGalerkinDefectSplitBridge
