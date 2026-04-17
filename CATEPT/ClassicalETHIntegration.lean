import CATEPT.ClassicalCore
import CATEPT.CAT_EPT_ETH_CanonicalBridge
import CATEPT.MicrocanonicalETHInterface

noncomputable section

set_option autoImplicit false

namespace CATEPT

-- 1. Emulate Information metric from Classical dissipation (gamma * v^2)
def oscillatorInfo (p : DampedOscillatorParams) (J : OscillatorJet) : ℝ :=
  p.gamma * J.v^2

-- 2. Emulate Imaginary action density
def oscillatorActionIm (p : DampedOscillatorParams) (beta_I : ℝ) (J : OscillatorJet) : ℝ :=
  beta_I * oscillatorInfo p J

-- 3. Bind the ETH Params Interface seamlessly
def oscillatorETHParams (p : DampedOscillatorParams) (beta_I hbar : ℝ) (hbar_pos : 0 < hbar) :
    CanonicalETHBridgeParams OscillatorJet where
  beta_I := beta_I
  hbar := hbar
  hbar_pos := hbar_pos
  I := oscillatorInfo p
  actionDensity_im := oscillatorActionIm p beta_I
  action_eq_info := by
    intro J
    rfl

-- 4. Define the Energy Shell for the microcanonical average over Phase Space
def oscillatorMicrocanonicalShell (p : DampedOscillatorParams) (E deltaE : ℝ) (deltaE_pos : 0 < deltaE) :
    MicrocanonicalShell OscillatorJet where
  energy := fun J => mechanicalEnergy p J.x J.v
  E := E
  deltaE := deltaE
  deltaE_pos := deltaE_pos

-- 5. Construct the Microcanonical ETH Interface
-- Anchors the abstract "thermal" expectation to the concrete mechanicalEnergyDerivAtJet
def oscillatorETHInterface (p : DampedOscillatorParams) (beta_I hbar E deltaE : ℝ)
    (hbar_pos : 0 < hbar) (deltaE_pos : 0 < deltaE) (O_thermal : ℝ)
    (h_avg : O_thermal = microcanonicalAverage (oscillatorMicrocanonicalShell p E deltaE deltaE_pos) (mechanicalEnergyDerivAtJet p)) :
    MicrocanonicalETHInterface OscillatorJet OscillatorJet where
  shell := oscillatorMicrocanonicalShell p E deltaE deltaE_pos
  observable := mechanicalEnergyDerivAtJet p
  O_thermal_base := O_thermal
  O_thermal_eq_average := h_avg

end CATEPT
