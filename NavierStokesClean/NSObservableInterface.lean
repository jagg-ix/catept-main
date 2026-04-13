import NavierStokesClean.Core.EnergyFunctionals
import NavierStokesClean.Millennium.PhysicalObservablesPreciseGapBridge

/-!
Legacy-compat leverage surface for `NSObservableInterface.lean`.
Binds observable-route names to the theoremized physical-mode0 bridge.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NSObservableInterface

open NavierStokesClean
open NavierStokesClean.Millennium

lemma bkmVorticityIntegralObs_nonneg (traj : Trajectory) (T : ℝ) (hT : 0 ≤ T) :
    (0 : ℝ) ≤ bkmVorticityIntegral traj T :=
  bkm_nonneg traj T hT

lemma pgs_obs_zero_trivial : PreciseGapStatementPhysicalMode0 :=
  bridge_target_linear_entropic_control_physicalMode0_witness

lemma bkm_obs_route_implies_millennium
    (hRoute : BridgeTargetLinearEntropicControlPhysicalMode0) :
    MillenniumNavierStokes.NavierStokesMillenniumProblem :=
  bridge_target_linear_entropic_control_physicalMode0_implies_millennium_problem hRoute

end NavierStokesClean.LegacyCompat.NSObservableInterface
