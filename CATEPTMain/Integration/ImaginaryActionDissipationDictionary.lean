import CATEPTMain.Integration.EntropicTimeIntegralStateDependent
import Mathlib.Analysis.SpecialFunctions.Exp

/-!
# Imaginary-Action / Dissipation-Rate Dictionary

Tier-1 PR #3 from the Fisher-Rao / Lawvere advisor inspection.  The
strongest reusable piece from the *gravity / clock-rates* advisor
analysis was the cleanly separated dimensional dictionary

  `β̃_I = ℏ · γ_I`,        `S_I / ℏ = ∫₀^t γ_I(σ) dσ`,

where:

  * `γ_I : ℝ → ℝ`  is a **dissipation rate**           [1/time]
  * `β̃_I : ℝ → ℝ` is a **dissipation energy scale**   [energy]
  * `S_I / ℏ`      is the **imaginary-action accumulation** [dimensionless]

This module ships the dictionary as small kernel-only theorems +
structural separation from the **modular flow parameter** and from
**entropic proper time**.

## Naming and the user's "no information time" correction

Following the user's terminology correction, this module keeps **three
distinct named layers**:

  1. *Imaginary-action accumulation* — the dimensionless functional
     `S_I / ℏ`, computed as `∫₀^t γ_I(σ) dσ` once a rate function is
     supplied.  This is the object lived-in by `MeasurePathIntegralModel`
     (its `actionImScaled` field).

  2. *Entropic proper time* — the CAT/EPT clock variable `τ_ent`.
     Identification with `S_I / ℏ` is a **bridge obligation** under
     the catept model contract, NOT an automatic equation.

  3. *KMS / modular-flow parameter* — the modular thermal-flow
     parameter with strip width `Δs_KMS = ℏ / β̃_I = 1 / γ_I`.  This
     is **separate** from entropic proper time; identification under
     `Δs_KMS = τ_ent` requires a specific KMS-state contract.

The names "information time" and "informational temperature" are
deliberately AVOIDED.  Each layer has its own name and its own
explicit bridge theorems.

## What this module ships

* `dissipation_energy_eq_hbar_mul_rate`: dimensional dictionary
  `β̃_I = ℏ · γ_I` as a definitional identity on chosen carriers.

* `imaginaryActionAccumulation`:
  `S_I_over_hbar (γ_I) (t) := entropicTimeIntegral γ_I t`.

* `imaginaryActionAccumulation_initial`: at `t = 0`, the
  imaginary-action accumulation is `0`.

* `imaginaryActionAccumulation_nonneg_of_pos_rate`: for `γ_I > 0`
  pointwise and `t ≥ 0`, the imaginary-action accumulation is `0 ≤`.

* `kmsStripWidth`: `Δs_KMS γ_I (t) := 1 / γ_I t` — definitional.

* `kmsStripWidth_pos`: for `γ_I > 0` pointwise, `0 < Δs_KMS γ_I t`.

* `kmsStripWidth_eq_hbar_div_dissipation_energy`: connector between
  the rate-form and energy-form definitions of `Δs_KMS`.

* `IdentifyEntropicProperTimeWithImaginaryAction` (carrier): an
  **explicit bridge contract** the consumer must supply to identify
  entropic proper time with the imaginary-action accumulation.  The
  carrier exists to keep the two layers distinct unless the bridge
  is supplied.

## Honest scope

* **No new physics derivations.**  The dictionary `β̃_I = ℏ γ_I` is a
  dimensional identity; the KMS strip width is a definitional
  reciprocal of the rate.
* **No `entropic proper time = imaginary-action accumulation`
  identification by default.**  That equation is the user's
  catept-model bridge obligation, not a free-standing fact.  The
  carrier `IdentifyEntropicProperTimeWithImaginaryAction` makes the
  obligation explicit.
* **No "information time".**  Per the user's correction, that
  terminology is deliberately avoided in favour of the three
  separated layers above.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.ImaginaryActionDissipationDictionary

open CATEPTMain.Integration.EntropicTimeIntegralStateDependent

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- Dimensional dictionary: β̃_I = ℏ · γ_I
-- ═══════════════════════════════════════════════════════════════════════

/-- **Dissipation energy from rate.**  Given a dissipation rate
`γ_I : ℝ → ℝ` [1/time] and Planck's constant `ℏ : ℝ` [energy · time],
the dissipation energy scale is `β̃_I (t) = ℏ · γ_I (t)` [energy].

This is a *definition*, not a theorem; the dictionary identity holds
by construction. -/
def dissipationEnergyFromRate (hbar : ℝ) (gammaI : ℝ → ℝ) : ℝ → ℝ :=
  fun t => hbar * gammaI t

/-- **Dictionary identity.**  At each `t : ℝ`,
`β̃_I (t) = ℏ · γ_I (t)`. -/
theorem dissipation_energy_eq_hbar_mul_rate
    (hbar : ℝ) (gammaI : ℝ → ℝ) (t : ℝ) :
    dissipationEnergyFromRate hbar gammaI t = hbar * gammaI t := rfl

-- ═══════════════════════════════════════════════════════════════════════
-- Imaginary-action accumulation S_I / ℏ
-- ═══════════════════════════════════════════════════════════════════════

/-- **Imaginary-action accumulation.**  The dimensionless functional

  `S_I (t) / ℏ = ∫₀^t γ_I(σ) dσ`,

which the catept model's `MeasurePathIntegralModel.actionImScaled`
field tracks at the per-state level.  This is **not** automatically
identified with entropic proper time; that bridge is the consumer's
obligation (see `IdentifyEntropicProperTimeWithImaginaryAction`). -/
def imaginaryActionAccumulation (gammaI : ℝ → ℝ) (t : ℝ) : ℝ :=
  entropicTimeIntegral gammaI t

/-- **Initial value.**  At `t = 0`, no imaginary action has accumulated:
`(S_I / ℏ)(0) = 0`. -/
theorem imaginaryActionAccumulation_initial (gammaI : ℝ → ℝ) :
    imaginaryActionAccumulation gammaI 0 = 0 :=
  entropicTimeIntegral_zero gammaI

/-- **Non-negativity for positive rates.**  For `γ_I (σ) > 0` pointwise
and `t ≥ 0`, the imaginary-action accumulation `(S_I / ℏ)(t)` is
non-negative — matching the standard physics shape
`exp(− S_I / ℏ) ∈ (0, 1]` of the entropic damping factor. -/
theorem imaginaryActionAccumulation_nonneg_of_pos_rate
    (gammaI : ℝ → ℝ) (hpos : ∀ σ, 0 < gammaI σ) (t : ℝ) (ht : 0 ≤ t) :
    0 ≤ imaginaryActionAccumulation gammaI t :=
  entropicTimeIntegral_nonneg_of_pos_rate gammaI hpos t ht

-- ═══════════════════════════════════════════════════════════════════════
-- KMS / modular-flow strip width  (separate layer)
-- ═══════════════════════════════════════════════════════════════════════

/-- **KMS strip width from dissipation rate.**  For a positive rate
`γ_I (t) > 0`, the KMS / modular-flow strip width at time `t` is

  `Δs_KMS (t) = 1 / γ_I (t)`.

This is the *thermal/modular* layer, distinct from entropic proper
time.  Identification `Δs_KMS = τ_ent` requires a specific KMS-state
bridge contract; the catept model does NOT impose this by default. -/
def kmsStripWidth (gammaI : ℝ → ℝ) (t : ℝ) : ℝ := 1 / gammaI t

/-- **Strip-width positivity.**  For `γ_I (t) > 0`, the KMS strip
width is strictly positive. -/
theorem kmsStripWidth_pos
    (gammaI : ℝ → ℝ) (hpos : ∀ σ, 0 < gammaI σ) (t : ℝ) :
    0 < kmsStripWidth gammaI t := by
  unfold kmsStripWidth
  exact one_div_pos.mpr (hpos t)

/-- **Strip width via the energy-form dictionary.**  For positive
`ℏ` and rate `γ_I (t)`, the KMS strip width can equivalently be
expressed as `ℏ / β̃_I (t) = ℏ / (ℏ · γ_I) = 1 / γ_I`. -/
theorem kmsStripWidth_eq_hbar_div_dissipation_energy
    (hbar : ℝ) (gammaI : ℝ → ℝ) (t : ℝ)
    (h_hbar : hbar ≠ 0) (h_rate : gammaI t ≠ 0) :
    kmsStripWidth gammaI t = hbar / dissipationEnergyFromRate hbar gammaI t := by
  unfold kmsStripWidth dissipationEnergyFromRate
  field_simp

-- ═══════════════════════════════════════════════════════════════════════
-- Bridge contract: entropic proper time = imaginary-action accumulation
-- ═══════════════════════════════════════════════════════════════════════

/-- **Bridge contract: entropic proper time vs imaginary-action
accumulation.**  Records the user's explicit catept-model identification

  `τ_ent (t)  =  (S_I / ℏ) (t)  =  ∫₀^t γ_I(σ) dσ`

as a structural carrier, NOT as a free-standing equation.  The two
layers (entropic proper time and imaginary-action accumulation) are
**by default distinct**; consumers wanting to identify them must
exhibit this carrier with an explicit `tau_ent_eq_imaginary_action`
field, supplying both the entropic proper time function and the
proof of equality.

Phase-2 work can refine to a model-theoretic bridge once the catept
model contract is fully formalised at the operator level. -/
structure IdentifyEntropicProperTimeWithImaginaryAction where
  /-- The dissipation rate the bridge is built on. -/
  gammaI : ℝ → ℝ
  /-- The catept-model entropic proper time function. -/
  tauEnt : ℝ → ℝ
  /-- The bridge identification: entropic proper time equals the
      imaginary-action accumulation pointwise.  This is the
      load-bearing equation. -/
  tau_ent_eq_imaginary_action :
    ∀ t : ℝ, tauEnt t = imaginaryActionAccumulation gammaI t

namespace IdentifyEntropicProperTimeWithImaginaryAction

/-- Under the bridge contract, `tauEnt(0) = 0`. -/
theorem tauEnt_zero (B : IdentifyEntropicProperTimeWithImaginaryAction) :
    B.tauEnt 0 = 0 := by
  rw [B.tau_ent_eq_imaginary_action 0]
  exact imaginaryActionAccumulation_initial B.gammaI

end IdentifyEntropicProperTimeWithImaginaryAction

end

end CATEPTMain.Integration.ImaginaryActionDissipationDictionary
