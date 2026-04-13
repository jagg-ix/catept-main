import NavierStokesClean.NSGalerkinDefectSplitBridge

/-!
Legacy-compat leverage surface for `NSGalerkinDefectConvergenceClosure.lean`.
Closes the convergence endpoint through the split bridge adapters.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NSGalerkinDefectConvergenceClosure

open NavierStokesClean
open Filter

lemma galerkinDefect_componentwise_seq_convergence
    (traj_seq : Nat → Trajectory) (T : ℝ) :
    Tendsto
      (fun N => ∫ t in Set.Ioc 0 T, vorticityStretching (trajectoryToSpatial (traj_seq N) t))
      atTop (nhds 0) :=
  LegacyCompat.NSGalerkinDefectSplitBridge.galerkin_vs_convergence_from_pal_seq traj_seq T

lemma ns_defect_transport_from_galerkin_lsc
    (traj_seq : Nat → Trajectory) (T : ℝ) :
    Tendsto
      (fun N => ∫ t in Set.Ioc 0 T, vorticityStretching (trajectoryToSpatial (traj_seq N) t))
      atTop (nhds 0) :=
  galerkinDefect_componentwise_seq_convergence traj_seq T

end NavierStokesClean.LegacyCompat.NSGalerkinDefectConvergenceClosure
