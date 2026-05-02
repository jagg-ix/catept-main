import CATEPTMain.Integration.ImaginaryActionDissipationDictionary

/-!
# GKSL Information-Exchange Bridge (Tier-2 PR #4)

Tier-2 PR #4 of four queued in `equation-spine-review-20260430.md`.

The advisor analyses identify the GKSL / Lindblad picture as the
operational form of the imaginary-action / dissipation-rate content:

  `H_eff = H_R − i · β̃_I · V`
        `= H_R − i · ℏ · γ_I · V`

  `L_V = √(2 · γ_I · V)`
       `= √(2 · β̃_I · V / ℏ)`

The first equation is an effective non-Hermitian Hamiltonian with
imaginary part proportional to the dissipation energy scale times a
"channel operator" `V`.  The second is the corresponding Lindblad
jump-operator intensity (square-root of twice the dissipation rate
times the channel).

## Honest scope (CRUCIAL)

This module ships the **scalar / abstract carrier** for the GKSL
content:

* `H_eff_real`, `H_eff_imag` as numerical / scalar fields.
* `jumpOpIntensity` as a numerical scalar.
* Algebraic identities relating the rate-form and energy-form
  expressions via the `β̃_I = ℏ · γ_I` dictionary
  (`ImaginaryActionDissipationDictionary`, PR #53).

What this module does **NOT** do:

* No operator-valued GKSL semigroup construction.  That requires
  `MarkovSemigroups` package wiring + bounded-operator infrastructure;
  it is a separate Tier-3 task.
* No claim that any specific physical system implements this
  GKSL picture.  Concrete instances supply their own
  `gammaI`, `V`, `H_R`.
* No "information time" terminology — imaginary-action accumulation,
  entropic proper time, KMS modular flow remain three separate
  layers per the user's correction.

## What is honestly proven

* `H_eff_imag (def)`: `H_eff_imag = −ℏ · γ_I · V` (the imaginary
  part of the effective Hamiltonian, in units of `[energy]`).

* `jumpOpIntensity (def)`: `√(2 · γ_I · V)` (the Lindblad jump-
  operator intensity squared, in units of `[1/time]^(1/2)`).

* `H_eff_imag_eq_neg_betaTildeI_mul_V`: dimensional dictionary —
  `H_eff_imag = −β̃_I · V` (rate-form ↔ energy-form).

* `jumpOpIntensity_squared`: `(jumpOpIntensity γ V)² = 2 · γ · V`
  for non-negative `γ V`.

* `jumpOpIntensity_nonneg`: `0 ≤ jumpOpIntensity γ V` for
  `0 ≤ γ V`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GKSLInformationExchangeBridge

open CATEPTMain.Integration.ImaginaryActionDissipationDictionary

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- Effective non-Hermitian Hamiltonian: imaginary part
-- ═══════════════════════════════════════════════════════════════════════

/-- **Imaginary part of the effective non-Hermitian Hamiltonian.**

  `H_eff_imag (ℏ, γ_I, V) := −ℏ · γ_I · V`.

This is the imaginary part of `H_eff = H_R − i · ℏ · γ_I · V`,
where `H_R` is the real (Hermitian) Hamiltonian, `γ_I` is the
dissipation rate, and `V` is a "channel operator" representing
the system-environment coupling.  At the scalar / numerical level
this is simply `−ℏ · γ_I · V`. -/
def H_eff_imag (hbar gammaI V : ℝ) : ℝ := -(hbar * gammaI * V)

/-- **Rate-form ↔ energy-form dictionary at the H_eff level.**
Using `β̃_I = ℏ · γ_I` from `ImaginaryActionDissipationDictionary`,

  `H_eff_imag (ℏ, γ_I, V)  =  −β̃_I · V`.

The factor of `ℏ` rebalances between the rate form (with `γ_I`) and
the energy form (with `β̃_I`). -/
theorem H_eff_imag_eq_neg_betaTildeI_mul_V
    (hbar gammaI V : ℝ) :
    H_eff_imag hbar gammaI V =
      -(dissipationEnergyFromRate hbar (fun _ => gammaI) 0 * V) := by
  unfold H_eff_imag dissipationEnergyFromRate
  ring

-- ═══════════════════════════════════════════════════════════════════════
-- Lindblad jump-operator intensity
-- ═══════════════════════════════════════════════════════════════════════

/-- **Lindblad jump-operator intensity.**  At the scalar level,

  `jumpOpIntensity (γ_I, V) := √(2 · γ_I · V)`.

The actual operator-valued Lindblad jump operator `L_V` would be
the unique square root of `2 · γ_I · V` in the relevant operator
algebra; at the scalar level this is just the real square root. -/
def jumpOpIntensity (gammaI V : ℝ) : ℝ := Real.sqrt (2 * gammaI * V)

/-- **Non-negativity.**  `jumpOpIntensity γ V ≥ 0` always (real
square root). -/
theorem jumpOpIntensity_nonneg (gammaI V : ℝ) :
    0 ≤ jumpOpIntensity gammaI V :=
  Real.sqrt_nonneg _

/-- **Squared identity.**  For `0 ≤ 2 · γ_I · V`,
`(jumpOpIntensity γ V)² = 2 · γ · V`.

Reflects the standard Lindblad "intensity squared = 2 · rate ·
channel" relation. -/
theorem jumpOpIntensity_squared
    (gammaI V : ℝ) (h : 0 ≤ 2 * gammaI * V) :
    (jumpOpIntensity gammaI V)^2 = 2 * gammaI * V := by
  unfold jumpOpIntensity
  exact Real.sq_sqrt h

-- ═══════════════════════════════════════════════════════════════════════
-- Carrier struct (optional bundling)
-- ═══════════════════════════════════════════════════════════════════════

/-- **GKSL information-exchange carrier.**  Bundles the four scalar
fields (`H_R`, `gammaI`, `V`, `hbar`) plus the derived imaginary
Hamiltonian and jump-operator intensity. -/
structure GKSLChannel where
  /-- The real (Hermitian) Hamiltonian (scalar). -/
  H_R : ℝ
  /-- The dissipation rate `γ_I`. -/
  gammaI : ℝ
  /-- The channel-operator scalar `V`. -/
  V : ℝ
  /-- Planck's constant. -/
  hbar : ℝ

namespace GKSLChannel

/-- The imaginary part of `H_eff` for the carrier. -/
def H_eff_imag (G : GKSLChannel) : ℝ :=
  GKSLInformationExchangeBridge.H_eff_imag G.hbar G.gammaI G.V

/-- The jump-operator intensity for the carrier. -/
def jumpOpIntensity (G : GKSLChannel) : ℝ :=
  GKSLInformationExchangeBridge.jumpOpIntensity G.gammaI G.V

/-- **Non-negativity of the carrier's jump-operator intensity.** -/
theorem jumpOpIntensity_nonneg (G : GKSLChannel) :
    0 ≤ G.jumpOpIntensity :=
  GKSLInformationExchangeBridge.jumpOpIntensity_nonneg G.gammaI G.V

end GKSLChannel

end

end CATEPTMain.Integration.GKSLInformationExchangeBridge
