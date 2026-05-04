import Mathlib.Data.Real.Basic
import CATEPTMain.CATEPT.ClassicalCore
import CATEPTMain.CATEPT.CATEPT.CAT_EPT_ETH_CanonicalBridge
import CATEPTMain.CATEPT.CATEPT.MicrocanonicalETHInterface

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

/-- Instantiates the Canonical ETH parameters for an OscillatorJet state space. -/
def oscillatorETHParams (hbar' beta_I' : ℝ) (h_pos : 0 < hbar')
    (info_density : OscillatorJet → ℝ)
    (action_im : OscillatorJet → ℝ)
    (h_bridge : ∀ J, action_im J = beta_I' * info_density J) :
    CanonicalETHBridgeParams OscillatorJet where
  beta_I := beta_I'
  hbar := hbar'
  hbar_pos := h_pos
  I := info_density
  actionDensity_im := action_im
  action_eq_info := h_bridge

/-- Constructs a specific Microcanonical Shell over the classical damped oscillator 
    based on its purely mechanical energy. -/
def oscillatorMicrocanonicalShell (p : DampedOscillatorParams) (targetE deltaE' : ℝ)
    (delta_pos : 0 < deltaE') : MicrocanonicalShell OscillatorJet where
  energy := fun J => mechanicalEnergy p J.x J.v
  E := targetE
  deltaE := deltaE'
  deltaE_pos := delta_pos

/-- Binds the thermal expectation of the mechanical dissipation observable
    to the microcanonical ensemble average over the energy shell.

    The microcanonical average is supplied as a parameter (`avg : ℝ`)
    rather than computed; consumers provide whatever value is dictated
    by their application (e.g. a closed-form integral in a worked
    example, or a hypothesis from upstream physics). -/
def oscillatorETHInterface (p : DampedOscillatorParams) (targetE deltaE' : ℝ) (delta_pos : 0 < deltaE')
    (base_thermal_dissipation avg : ℝ)
    (h_avg : base_thermal_dissipation = avg) :
    MicrocanonicalETHInterface OscillatorJet OscillatorJet where
  shell := oscillatorMicrocanonicalShell p targetE deltaE' delta_pos
  observable := mechanicalEnergyDerivAtJet p
  average := avg
  O_thermal_base := base_thermal_dissipation
  O_thermal_eq_average := h_avg

/-- The full canonical ETH diagonal matrix structure explicitly evaluated 
    for the damped oscillator's dissipation, demonstrating how high information
    exponentially suppresses fluctuations away from the pure microcanonical average. -/
theorem oscillator_dissipation_ETH_value (p : DampedOscillatorParams)
    (targetE deltaE' : ℝ) (delta_pos : 0 < deltaE')
    (base_thermal_dissipation avg : ℝ)
    (h_avg : base_thermal_dissipation = avg)
    (hbar' beta_I' : ℝ) (h_pos : 0 < hbar')
    (info_density action_im : OscillatorJet → ℝ)
    (h_bridge : ∀ J, action_im J = beta_I' * info_density J)
    (varepsilon : OscillatorJet → ℝ) (J : OscillatorJet) :
    canonicalDiagonalETHValue (oscillatorETHParams hbar' beta_I' h_pos info_density action_im h_bridge)
      (fun _ => base_thermal_dissipation)
      varepsilon
      J =
    avg +
    Real.exp (-((beta_I' * info_density J) / hbar')) * varepsilon J := by
  unfold canonicalDiagonalETHValue canonicalSuppressionFactor canonicalTauDiag oscillatorETHParams
  simp only
  rw [← h_avg]

end CATEPTMain.CATEPT.CATEPT
