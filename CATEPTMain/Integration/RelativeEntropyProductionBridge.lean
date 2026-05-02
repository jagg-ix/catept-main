import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Relative-Entropy Production Bridge (Tier-2 PR #3)

Tier-2 PR #3 of four queued in `equation-spine-review-20260430.md`.

Relative entropy `S_rel[P | P_s]` is the natural object that turns
information exchange into an arrow of time.  The advisor analyses
emphasise it as the bridge between Onsager–Machlup / Fokker–Planck
dynamics and the entropic-arrow content.

This module ships the **structural carrier** for relative-entropy
production with the standard sign-convention bookkeeping.  The
load-bearing equations are:

  `S_rel[P(t) | P_s] = ∫ P(t) log (P(t) / P_s)`         (KL form)
  `S_info[P | P_s]   = −k_B · S_rel[P | P_s]`          (info form)
  `d/dt S_rel ≤ 0`     monotone decrease toward equilibrium
  `d/dt S_info ≥ 0`    equivalent statement in information form

## Honest scope (CRUCIAL)

The actual probability-measure relative-entropy formalisation needs
Mathlib's Radon-Nikodym + density-function infrastructure (a
multi-PR follow-on).  This module is the **scalar / abstract carrier
layer**:

* Carrier struct with `S_rel : ℝ → ℝ`, `prod : ℝ → ℝ`, monotonicity,
  positivity.
* Sign-convention bridge `S_info ↔ −k_B · S_rel`.
* Bridge contract for downstream consumers to supply concrete
  measure-theoretic definitions when the Mathlib infrastructure
  lands.

## What is honestly proven

* `RelativeEntropyProduction` (carrier struct):
  - `S_rel : ℝ → ℝ`  (relative entropy as function of time)
  - `prod : ℝ → ℝ`   (production rate)
  - `prod_nonneg`    (`0 ≤ prod σ`)
  - `S_rel_monotone_decreasing` (`t₁ ≤ t₂ → S_rel t₂ ≤ S_rel t₁`)

* `info_form`: definition `S_info := −k_B · S_rel` for `k_B > 0`.

* `info_form_monotone_increasing`: under the carrier hypotheses,
  `t₁ ≤ t₂ → S_info t₁ ≤ S_info t₂` (the dual sign convention).

* `RelativeEntropyProduction.exists_trivial`: structural existence —
  the trivial constant carrier `S_rel ≡ 0, prod ≡ 0` satisfies all
  carrier conditions.

## Architectural fit

```text
abstract carrier (this module)
    ↓ Phase-2: Radon-Nikodym + density theory
concrete relative entropy: S_rel[P | P_s] = ∫ P log(P/P_s) dμ
    ↓
Onsager-Machlup / Fokker-Planck production identities
    ↓
arrow-of-time content for CAT/EPT
```
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.RelativeEntropyProductionBridge

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- Carrier struct
-- ═══════════════════════════════════════════════════════════════════════

/-- **Relative-entropy production carrier.**  Abstract scalar shape
of a relative-entropy time evolution `S_rel : ℝ → ℝ` with a
non-negative production rate `prod : ℝ → ℝ` and monotone-decreasing
`S_rel`.

This is intentionally generic: consumers supply their own concrete
`S_rel`/`prod` from a Radon-Nikodym derivative when Mathlib
infrastructure is available; the carrier only enforces the sign /
monotonicity properties the downstream chain needs. -/
structure RelativeEntropyProduction where
  /-- Relative entropy as a function of time. -/
  S_rel : ℝ → ℝ
  /-- Production rate at each time. -/
  prod : ℝ → ℝ
  /-- The production rate is non-negative pointwise. -/
  prod_nonneg : ∀ σ, 0 ≤ prod σ
  /-- Relative entropy is monotone-decreasing in time
      (the standard arrow-of-time direction for `S_rel` toward
      equilibrium). -/
  S_rel_monotone_decreasing : ∀ t₁ t₂ : ℝ, t₁ ≤ t₂ → S_rel t₂ ≤ S_rel t₁

namespace RelativeEntropyProduction

/-- **Trivial witness.**  The carrier is non-empty: take
`S_rel ≡ 0` and `prod ≡ 0`. -/
theorem exists_trivial : ∃ R : RelativeEntropyProduction, True :=
  ⟨{ S_rel := fun _ => 0
   , prod := fun _ => 0
   , prod_nonneg := fun _ => le_refl 0
   , S_rel_monotone_decreasing := fun _ _ _ => le_refl 0 }, trivial⟩

-- ═══════════════════════════════════════════════════════════════════════
-- Information-form (sign-flipped) bookkeeping
-- ═══════════════════════════════════════════════════════════════════════

/-- **Information form.**  Given a relative-entropy carrier and a
positive Boltzmann constant, the information-form quantity is

  `S_info(t) := −k_B · S_rel(t)`,

which is monotone *increasing* in time (the dual statement of
`S_rel_monotone_decreasing`). -/
def info_form (R : RelativeEntropyProduction) (k_B : ℝ) : ℝ → ℝ :=
  fun t => -(k_B) * R.S_rel t

/-- **Information-form monotonicity.**  For positive `k_B`, the
information-form `S_info := −k_B · S_rel` is monotone increasing in
time (`t₁ ≤ t₂ → S_info t₁ ≤ S_info t₂`). -/
theorem info_form_monotone_increasing
    (R : RelativeEntropyProduction) (k_B : ℝ) (hkB : 0 < k_B)
    (t₁ t₂ : ℝ) (h₁₂ : t₁ ≤ t₂) :
    R.info_form k_B t₁ ≤ R.info_form k_B t₂ := by
  unfold info_form
  have hRel : R.S_rel t₂ ≤ R.S_rel t₁ :=
    R.S_rel_monotone_decreasing t₁ t₂ h₁₂
  -- Want: -k_B * S_rel t₁ ≤ -k_B * S_rel t₂
  -- i.e.  k_B * S_rel t₂ ≤ k_B * S_rel t₁
  -- which follows from S_rel t₂ ≤ S_rel t₁ and k_B > 0.
  nlinarith [hRel, hkB]

/-- **Production rate is non-negative** (re-export at the
`info_form`-friendly level). -/
theorem prod_nonneg_at (R : RelativeEntropyProduction) (σ : ℝ) :
    0 ≤ R.prod σ :=
  R.prod_nonneg σ

end RelativeEntropyProduction

end

end CATEPTMain.Integration.RelativeEntropyProductionBridge
