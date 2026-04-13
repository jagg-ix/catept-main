import NavierStokesClean.Galerkin.MuhaCanicDecomposition

/-!
Legacy-compat leverage surface for `NSGalerkinPalFourierBridge.lean`.
Re-exports theoremized palinstrophy convergence endpoints.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NSGalerkinPalFourierBridge

open NavierStokesClean
open Filter

lemma galerkin_palinstrophy_seq_convergence_proved
    (traj_seq : Nat → Trajectory) (T : ℝ) :
    Tendsto (fun N => ∫ t in Set.Ioc 0 T, palinstrophy (traj_seq N t))
      atTop (nhds 0) :=
  NavierStokesClean.Galerkin.galerkin_palinstrophy_seq_convergence traj_seq T

lemma galerkin_palinstrophySpatial_seq_convergence_of_lifted_proved
    (traj_seq : Nat → Trajectory) (T : ℝ) :
    Tendsto
      (fun N => ∫ t in Set.Ioc 0 T, palinstrophySpatial (trajectoryToSpatial (traj_seq N) t))
      atTop (nhds 0) :=
  NavierStokesClean.Galerkin.galerkin_palinstrophySpatial_seq_convergence_of_lifted traj_seq T

end NavierStokesClean.LegacyCompat.NSGalerkinPalFourierBridge
