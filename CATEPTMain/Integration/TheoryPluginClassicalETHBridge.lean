import Mathlib.Data.Real.Basic
import CATEPT.ClassicalCore
import CATEPT.ClassicalETHIntegration
import CATEPTMain.Integration.TheoryPluginArchitecture

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Integration

/-- Construct the Canonical CATEPT Plugin Slot natively for the ETH Damped Oscillator. -/
def classicalETHSiteSlot (p : CATEPT.DampedOscillatorParams)
    (hbar' beta_I' : ℝ) (h_pos : 0 < hbar')
    (info_density action_im : CATEPT.OscillatorJet → ℝ)
    (action_im_nonneg : ∀ J, 0 ≤ action_im J)
  (_h_bridge : ∀ J, action_im J = beta_I' * info_density J) :
    CATEPTPluginSlot where
  ConfigSpaceTy := CATEPT.OscillatorJet
  actionRe := fun J => CATEPT.mechanicalEnergy p J.x J.v
  actionIm := action_im
  actionIm_nonneg := action_im_nonneg
  hbar := hbar'
  hbar_pos := h_pos
  eptClock := fun J => action_im J / hbar'
  eptClock_nonneg := fun J => div_nonneg (action_im_nonneg J) (le_of_lt h_pos)
  -- `eptClock J` is defined as `action_im J / hbar'`, which is exactly the
  -- spine identity goal `actionIm J / hbar = eptClock J` after unfolding.
  consistent := fun _ => rfl

/-- Extract the ETH canonical clock from the Plugin Slot explicitly -/
theorem classicalETHSite_clock_matches_canonicalTauDiag
    (p : CATEPT.DampedOscillatorParams)
    (hbar' beta_I' : ℝ) (h_pos : 0 < hbar')
    (info_density action_im : CATEPT.OscillatorJet → ℝ)
    (action_im_nonneg : ∀ J, 0 ≤ action_im J)
    (h_bridge : ∀ J, action_im J = beta_I' * info_density J) :
    ∀ J : CATEPT.OscillatorJet,
      (classicalETHSiteSlot p hbar' beta_I' h_pos info_density action_im action_im_nonneg h_bridge).eptClock J =
      CATEPT.canonicalTauDiag
        (CATEPT.oscillatorETHParams hbar' beta_I' h_pos info_density action_im h_bridge) J := by
  intro J
  dsimp [classicalETHSiteSlot, CATEPT.canonicalTauDiag, CATEPT.oscillatorETHParams]
  rw [h_bridge J]

/-- The classical ETH damping natively satisfies the framework's universal CATEPT consistency constraint -/
theorem classicalETHPluginSlot_is_consistent
    (p : CATEPT.DampedOscillatorParams)
    (hbar' beta_I' : ℝ) (h_pos : 0 < hbar')
    (info_density action_im : CATEPT.OscillatorJet → ℝ)
    (action_im_nonneg : ∀ J, 0 ≤ action_im J)
    (h_bridge : ∀ J, action_im J = beta_I' * info_density J) :
    cateptConsistencyConstraint (classicalETHSiteSlot p hbar' beta_I' h_pos info_density action_im action_im_nonneg h_bridge) := by
  intro J
  rfl

end CATEPTMain.Integration
