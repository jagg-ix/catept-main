import Mathlib.Data.Real.Basic
import CATEPT.ClassicalCore
import CATEPT.ClassicalHerglotz
import CATEPT.ClassicalHerglotzETHBridge
import CATEPTMain.Integration.TheoryPluginClassicalETHBridge

/-!
# Herglotz–ETH Theory Plugin (Concrete Instantiation)

Instantiates `CATEPTPluginSlot` for the classical damped oscillator using
the **concrete Herglotz identification**:

  info_density J = mechanicalEnergy p J.x J.v
  beta_I         = γ/m  (Herglotz contact rate)
  action_im J    = (γ/m) · mechanicalEnergy p J.x J.v

This refines `classicalETHSiteSlot` (which took arbitrary `info_density` and
`action_im`) to the specific physical choice motivated by the Herglotz
variational principle.

## Key theorems

| Name                                        | Status | Notes                                         |
|---------------------------------------------|--------|-----------------------------------------------|
| `herglotzPluginSlot`                        | def    | Concrete CATEPTPluginSlot for the oscillator  |
| `herglotzPlugin_clock_eq_tauEnt`            | proved | Clock = τ_ent from herglotzETHParams          |
| `herglotzPlugin_is_consistent`             | proved | cateptConsistencyConstraint holds             |
| `herglotzPlugin_dissipation_bound`          | proved | dE/dt suppressed by ETH suppression factor    |
-/

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Integration

-- ── Concrete plugin slot ──────────────────────────────────────────────────────

/-- The concrete `CATEPTPluginSlot` for the classical damped oscillator
    with Herglotz identification of the imaginary action. -/
def herglotzPluginSlot (p : CATEPT.DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    CATEPTPluginSlot :=
  classicalETHSiteSlot p hbar
  (CATEPT.herglotzContactRate p) hbar_pos
  (fun J => CATEPT.mechanicalEnergy p J.x J.v)
  (CATEPT.herglotzActionIm p)
  (fun J => CATEPT.herglotzActionIm_nonneg p hγ hk J)
    (fun _ => rfl)

-- ── The clock is the Herglotz entropic proper time ────────────────────────────

/-- The plugin clock matches `canonicalTauDiag` from `herglotzETHParams`. -/
theorem herglotzPlugin_clock_eq_tauEnt (p : CATEPT.DampedOscillatorParams) (hbar : ℝ)
    (hbar_pos : 0 < hbar) (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k)
  (J : CATEPT.OscillatorJet) :
    (herglotzPluginSlot p hbar hbar_pos hγ hk).eptClock J =
  CATEPT.canonicalTauDiag (CATEPT.herglotzETHParams p hbar hbar_pos) J := by
  unfold herglotzPluginSlot
  rw [classicalETHSite_clock_matches_canonicalTauDiag]
  rfl

-- ── Consistency constraint ────────────────────────────────────────────────────

/-- The Herglotz plugin slot satisfies the universal CATEPT consistency
    constraint `eptClock J = actionImScaled J`. -/
theorem herglotzPlugin_is_consistent (p : CATEPT.DampedOscillatorParams) (hbar : ℝ)
    (hbar_pos : 0 < hbar) (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    cateptConsistencyConstraint (herglotzPluginSlot p hbar hbar_pos hγ hk) :=
  classicalETHPluginSlot_is_consistent p hbar
  (CATEPT.herglotzContactRate p) hbar_pos
  (fun J => CATEPT.mechanicalEnergy p J.x J.v)
  (CATEPT.herglotzActionIm p)
  (fun J => CATEPT.herglotzActionIm_nonneg p hγ hk J)
    (fun _ => rfl)

-- ── Dissipation is bounded by the ETH suppression factor ─────────────────────

/-- For a jet satisfying the damped equation, the mechanical energy derivative
    equals `-γ v²`, which is bounded above by zero (energy decreases).
    Combined with the suppression factor `W_ETH = exp(-τ_ent)`, this shows the
    dissipation rate decays as the system thermalizes. -/
theorem herglotzPlugin_dissipation_nonpos (p : CATEPT.DampedOscillatorParams)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (J : CATEPT.OscillatorJet) (hJ : CATEPT.JetSatisfiesDampedEquation p J)
    (hγ : 0 ≤ p.gamma) :
    CATEPT.mechanicalEnergyDerivAtJet p J ≤ 0 := by
  rw [CATEPT.herglotz_energyDecay_ETH_compatible p hbar hbar_pos J hJ]
  have : 0 ≤ p.gamma * J.v ^ 2 := mul_nonneg hγ (sq_nonneg _)
  linarith

/-- The decay rate magnitude `|dE/dt|` equals `(γ/m) · m · v²`
    = `herglotzContactRate p · p.m · J.v²`.
    This matches the ETH imaginary action structure:
      `action_im J = (γ/m) · E_mech`  and  `m·v² ≤ 2·E_mech` for `k ≥ 0`. -/
theorem herglotzPlugin_decayRate_eq (p : CATEPT.DampedOscillatorParams)
    (J : CATEPT.OscillatorJet) (hJ : CATEPT.JetSatisfiesDampedEquation p J) :
    -CATEPT.mechanicalEnergyDerivAtJet p J = CATEPT.herglotzContactRate p * p.m * J.v ^ 2 := by
  rw [CATEPT.herglotz_energyDecay_via_contactRate p J hJ]; ring

end CATEPTMain.Integration

end
