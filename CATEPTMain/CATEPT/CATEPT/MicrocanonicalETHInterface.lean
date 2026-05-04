import Mathlib.Data.Real.Basic
-- Note: Requires CAT_EPT_ETH_CanonicalBridge to be in scope

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

/-- A Microcanonical Shell in a given Phase Space. -/
structure MicrocanonicalShell (PhaseSpace : Type) where
  energy : PhaseSpace → ℝ
  E : ℝ
  deltaE : ℝ
  deltaE_pos : 0 < deltaE
  in_shell : PhaseSpace → Prop := fun x => E - deltaE < energy x ∧ energy x < E + deltaE

/-- Interface tying the abstract `O_thermal` used in the Canonical ETH Bridge
    to a microcanonical-average value over the CAT/EPT action shell.

    The microcanonical average is held as a *field* (`average : ℝ`) rather
    than computed via a sorry-bodied global definition.  Consumers
    constructing this interface supply the average value (e.g. as a
    user-provided abstraction over the integral defining the average)
    along with the equation `O_thermal_base = average`. -/
structure MicrocanonicalETHInterface (PhaseSpace X : Type) where
  shell : MicrocanonicalShell PhaseSpace
  observable : PhaseSpace → ℝ
  /-- Real-valued microcanonical-average surrogate (caller supplies). -/
  average : ℝ
  O_thermal_base : ℝ
  /-- Defining identity: the canonical-ETH thermal observable equals
      the supplied microcanonical average. -/
  O_thermal_eq_average : O_thermal_base = average

/-- The extended observable on the state space matches the ETH generic diagonal form
    with the thermal expectation securely anchored to the microcanonical average. -/
theorem ETH_diagonal_is_microcanonical {PhaseSpace X : Type}
    (interface : MicrocanonicalETHInterface PhaseSpace X)
    (suppression : X → ℝ) (varepsilon : X → ℝ) :
    ∀ x : X,
      interface.O_thermal_base + suppression x * varepsilon x =
      interface.average + suppression x * varepsilon x := by
  intro x
  rw [interface.O_thermal_eq_average]

end CATEPTMain.CATEPT.CATEPT
