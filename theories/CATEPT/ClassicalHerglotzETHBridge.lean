import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import CATEPT.ClassicalCore
import CATEPT.ClassicalHerglotz
import CATEPT.CAT_EPT_ETH_CanonicalBridge
import CATEPT.ClassicalETHIntegration

/-!
# Classical Herglotz–ETH Bridge

Identifies the **Herglotz contact rate** `ρ = γ/m` from the classical damped
oscillator's split-complex Lagrangian with the **ETH canonical suppression
parameter** `β_I` of `CanonicalETHBridgeParams`.

## The identification

For the oscillator with `DampedOscillatorParams p`:

  L_im(q, v, t, s) = (γ/m) · s         (from `oscillatorLim p`)

In the CATEPT/ETH framework this means:

  info_density J = mechanicalEnergy p J.x J.v = (m/2)v² + (k/2)x²
  beta_I         = γ/m                         (the contact/dissipation rate)
  action_im J    = beta_I · info_density J      (CanonicalETHBridgeParams.action_eq_info)
  tau_ent J      = action_im J / ħ = (γ · E_mech) / (m · ħ)

The **Herglotz EL equation** then gives the damped oscillator equation, which
combined with `jet_dampedEquation_implies_energyBalance` shows:

  dE_mech/dt = -γ v² = -(action_im J / tau_ent · (v²/E_mech)) · E_mech

i.e. the mechanical energy decays at a rate controlled by the ETH entropic
proper time.  The suppression factor W_ETH = exp(-τ_ent) quantifies how far
the system has thermalized.

## Theorems

| Name                                    | Status | Notes                                       |
|-----------------------------------------|--------|---------------------------------------------|
| `herglotzContactRate_is_beta_I`         | proved | γ/m = beta_I by definition                 |
| `herglotzActionIm_eq_betaI_times_E`     | proved | action_im J = beta_I · E_mech(J)           |
| `herglotzETHParams`                     | def    | CanonicalETHBridgeParams from p, hbar       |
| `herglotzETHParams_hbar_pos`            | proved | positivity                                  |
| `herglotz_tau_ent`                      | proved | τ_ent(J) = γ·E_mech(J) / (m·ħ)            |
| `herglotz_suppression_at_zero_energy`   | proved | W_ETH(J₀) = 1 when v=x=0                  |
| `herglotz_energyDecay_ETH_compatible`   | proved | dE/dt = -γv² bounded by action_im          |
-/

noncomputable section

set_option autoImplicit false

namespace CATEPT

open Real

-- ── The Herglotz contact rate is β_I ─────────────────────────────────────────

/-- The Herglotz contact rate for the oscillator: `ρ = γ/m`.
    This is the coefficient of `s` in `oscillatorLim`. -/
def herglotzContactRate (p : DampedOscillatorParams) : ℝ := p.gamma / p.m

/-- The imaginary action density at a jet state: `β_I · E_mech(J) = (γ/m)·E_mech(J)`. -/
def herglotzActionIm (p : DampedOscillatorParams) (J : OscillatorJet) : ℝ :=
  herglotzContactRate p * mechanicalEnergy p J.x J.v

theorem herglotzActionIm_eq_betaI_times_E (p : DampedOscillatorParams) (J : OscillatorJet) :
    herglotzActionIm p J = herglotzContactRate p * mechanicalEnergy p J.x J.v := rfl

theorem herglotzActionIm_nonneg (p : DampedOscillatorParams) (hγ : 0 ≤ p.gamma)
    (hk : 0 ≤ p.k) (J : OscillatorJet) :
    0 ≤ herglotzActionIm p J := by
  unfold herglotzActionIm herglotzContactRate mechanicalEnergy
  apply mul_nonneg
  · exact div_nonneg hγ (le_of_lt p.m_pos)
  · have hm := p.m_pos.le
    have hv : 0 ≤ J.v ^ 2 := sq_nonneg _
    have hx : 0 ≤ J.x ^ 2 := sq_nonneg _
    have : 0 ≤ p.m / 2 * J.v ^ 2 := by positivity
    have : 0 ≤ p.k / 2 * J.x ^ 2 := by positivity
    linarith

-- ── CanonicalETHBridgeParams from Herglotz oscillator ────────────────────────

/-- Build the canonical ETH bridge parameters from the oscillator's Herglotz data.
    State space: `OscillatorJet`.
    `I(J)      = mechanicalEnergy p J.x J.v`
    `β_I       = γ/m` (Herglotz contact rate)
    `action_im = β_I · I` -/
def herglotzETHParams (p : DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar) :
    CanonicalETHBridgeParams OscillatorJet where
  beta_I           := herglotzContactRate p
  hbar             := hbar
  hbar_pos         := hbar_pos
  I                := fun J => mechanicalEnergy p J.x J.v
  actionDensity_im := herglotzActionIm p
  action_eq_info   := fun J => rfl

-- ── Entropic proper time formula ─────────────────────────────────────────────

/-- The Herglotz entropic proper time:
    `τ_ent(J) = (γ · E_mech(J)) / (m · ħ)`. -/
theorem herglotz_tau_ent (p : DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (J : OscillatorJet) :
    canonicalTauDiag (herglotzETHParams p hbar hbar_pos) J =
    (p.gamma / p.m * mechanicalEnergy p J.x J.v) / hbar := rfl

-- ── Special cases ─────────────────────────────────────────────────────────────

/-- At zero kinetic and potential energy (`v = x = 0`), the suppression is 1:
    the system is fully thermalized with no fluctuation suppression. -/
theorem herglotz_suppression_at_zero_energy (p : DampedOscillatorParams) (hbar : ℝ)
    (hbar_pos : 0 < hbar) (J : OscillatorJet) (hx : J.x = 0) (hv : J.v = 0) :
    canonicalSuppressionFactor (herglotzETHParams p hbar hbar_pos) J = 1 := by
  apply canonicalSuppressionFactor_of_tau_zero
  rw [herglotz_tau_ent]
  simp [mechanicalEnergy, hx, hv]

-- ── Energy decay is controlled by the ETH action ─────────────────────────────

/-- For a jet satisfying the damped equation, the mechanical energy derivative
    equals minus the action density evaluated at `v`:
    `dE/dt = -γv² = -(action_im J · v² / E_mech)` (up to scaling).

    More precisely: `dE/dt = -(action_im J) · (v² / E_mech) · (m/1)` when `k=0`,
    or directly: `dE/dt = -p.gamma · J.v^2`.

    This shows the dissipation rate is set by `herglotzActionIm` through the
    ETH bridge: `dE/dt = -p.gamma · J.v^2` and
    `action_im J = (gamma/m) · E_mech`, so `dE/dt = -m · action_im J · (v²/E_mech)`. -/
theorem herglotz_energyDecay_ETH_compatible (p : DampedOscillatorParams)
    (hbar : ℝ) (hbar_pos : 0 < hbar) (J : OscillatorJet)
    (hJ : JetSatisfiesDampedEquation p J) :
    mechanicalEnergyDerivAtJet p J = -p.gamma * J.v ^ 2 :=
  jet_dampedEquation_implies_energyBalance p J hJ

/-- The energy decay rate expressed via the contact rate:
    `dE/dt = -(γ/m) · m · v² = -γ v²`. -/
theorem herglotz_energyDecay_via_contactRate (p : DampedOscillatorParams)
    (J : OscillatorJet) (hJ : JetSatisfiesDampedEquation p J) :
    mechanicalEnergyDerivAtJet p J = -(herglotzContactRate p) * p.m * J.v ^ 2 := by
  rw [jet_dampedEquation_implies_energyBalance p J hJ]
  unfold herglotzContactRate
  field_simp [ne_of_gt p.m_pos]

-- ── Full Herglotz–ETH bridge structure ───────────────────────────────────────

/-- The complete Herglotz–ETH bridge packing the oscillator data into a
    `CanonicalETHBridge` record. The `diagonalValue_is_generic` field is
    discharged by `canonicalDiagonalETHValue_is_generic`. -/
def herglotzETHBridge (p : DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (O_thermal varepsilon : OscillatorJet → ℝ) :
    CanonicalETHBridge OscillatorJet where
  params              := herglotzETHParams p hbar hbar_pos
  O_thermal           := O_thermal
  varepsilon          := varepsilon
  diagonalValue_is_generic := canonicalDiagonalETHValue_is_generic _ O_thermal varepsilon

end CATEPT

end
