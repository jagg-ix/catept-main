import NavierStokes.Core.NSObservableInterface
import NavierStokes.Core.NST3SobolevSupplement

/-!
# NSObservableTailControlBridge

Bridges the finite-mode T³ Sobolev tail inequalities into the observable interface
used by physical-route NS theorems.

This makes the S1 supplement (`NST3SobolevSupplement`) directly consumable in
trajectory-level statements:
- pointwise high-frequency enstrophy tail control by palinstrophy,
- integrated tail control over time via the discrete integral kernel.
-/

namespace NavierStokes.ObservableTailControl

set_option autoImplicit false

open NavierStokes.ObservableInterface
open NavierStokes.FourierModel
open NavierStokes.T3SobolevSupplement
open NavierStokes.DiscreteKernel

noncomputable section

open NavierStokes.Millennium

/-- Pointwise physical-route bridge:
high-frequency enstrophy tail is controlled by physical enstrophy. -/
theorem physical_enstrophyTail_le_enstrophy
    (v : NSField) (K : Nat) :
    frequencyTailSeminorm (ObservableInterface.interpretAsFourier v) 1 K ≤
      physicalNSObservables.enstrophy v := by
  have hTail :
      frequencyTailSeminorm (ObservableInterface.interpretAsFourier v) 1 K ≤
        weightedModeSeminorm (ObservableInterface.interpretAsFourier v) 1 :=
    frequencyTailSeminorm_le_weightedModeSeminorm (ObservableInterface.interpretAsFourier v) 1 K
  simpa [physicalNSObservables, fourierNSObsInstance, weightedModeSeminorm_one] using hTail

/-- Pointwise physical-route bridge:
high-frequency enstrophy tail is controlled by physical palinstrophy. -/
theorem physical_enstrophyTail_le_palinstrophy
    (v : NSField) (K : Nat) :
    frequencyTailSeminorm (ObservableInterface.interpretAsFourier v) 1 K ≤
      physicalNSObservables.palinstrophy v := by
  simpa [physicalNSObservables, fourierNSObsInstance] using
    (enstrophyTail_le_palinstrophy (ObservableInterface.interpretAsFourier v) K)

/-- Time-integrated tail control:
the integrated enstrophy tail is bounded by physical palinstrophy integral. -/
theorem physical_enstrophyTailIntegral_le_palinstrophyIntegral
    (traj : Trajectory NSField) (T : Rat) (K : Nat) :
    discreteIntegral
      (fun t => frequencyTailSeminorm (ObservableInterface.interpretAsFourier (traj.stateAt t).velocity) 1 K) T ≤
      palinstrophyIntegralObs physicalNSObservables traj T := by
  unfold palinstrophyIntegralObs
  apply discreteIntegral_le_of_pointwise
  intro t
  exact physical_enstrophyTail_le_palinstrophy ((traj.stateAt t).velocity) K

/-- Contract form for pointwise tail-to-palinstrophy control on physical observables. -/
def PhysicalObservableTailControlContract : Prop :=
  ∀ (v : NSField) (K : Nat),
    frequencyTailSeminorm (ObservableInterface.interpretAsFourier v) 1 K ≤
      physicalNSObservables.palinstrophy v

theorem physicalObservableTailControlContract_holds :
    PhysicalObservableTailControlContract := by
  intro v K
  exact physical_enstrophyTail_le_palinstrophy v K

/-- Contract form for integrated tail control over trajectories. -/
def PhysicalObservableTailIntegralContract : Prop :=
  ∀ (traj : Trajectory NSField) (T : Rat) (K : Nat),
    discreteIntegral
      (fun t => frequencyTailSeminorm (ObservableInterface.interpretAsFourier (traj.stateAt t).velocity) 1 K) T ≤
      palinstrophyIntegralObs physicalNSObservables traj T

theorem physicalObservableTailIntegralContract_holds :
    PhysicalObservableTailIntegralContract := by
  intro traj T K
  exact physical_enstrophyTailIntegral_le_palinstrophyIntegral traj T K

def stageS2Summary : String :=
  "S2: Bridged Sobolev tail controls into observable semantics. " ++
  "Adds pointwise and time-integrated enstrophy-tail <= palinstrophy inequalities " ++
  "for physicalNSObservables, with explicit contract witnesses."

end

end NavierStokes.ObservableTailControl
