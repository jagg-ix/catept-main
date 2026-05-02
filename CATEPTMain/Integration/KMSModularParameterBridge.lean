import CATEPTMain.Integration.ImaginaryActionDissipationDictionary

/-!
# KMS / Modular-Flow Parameter Bridge (Tier-2 PR #2)

Tier-2 PR #2 of four queued in `equation-spine-review-20260430.md`.

The KMS / modular-flow parameter has strip width

  `Δs_KMS(t) = ℏ / β̃_I(t) = 1 / γ_I(t)`,

where `γ_I` is the dissipation rate and `β̃_I = ℏ · γ_I` is the
dissipation energy scale (`ImaginaryActionDissipationDictionary`,
PR #53).

The strip width is **not the same object** as catept's entropic
proper time `τ_ent`.  This module:

1. Re-exports the strip-width definition from PR #53 for use in a
   thermal/modular-flow context.

2. Provides an explicit `IdentifyKMSStripWithEntropicProperTime`
   bridge carrier that downstream consumers must supply if they want
   the identification.

3. Records the structural separation: two distinct named layers,
   distinct functional roles, identification only under the bridge.

## Honest scope (CRUCIAL — read before assuming identification)

* The KMS strip width is a **thermal/modular-flow** layer; it
  characterises the periodicity of the modular flow under KMS state.
* The entropic proper time is a **CAT/EPT clock** variable; it
  parametrises observable evolution.
* They have the **same units** ([time]) and similar formal shape
  but are **not** automatically equal.  Phase-2 work that wants
  identification must produce a bridge instance.

This is the same separation principle that
`ImaginaryActionDissipationDictionary` (PR #53) imposed on
`(S_I/ℏ)` vs `τ_ent`.  Following the user's "no information time"
correction, all three layers (imaginary-action accumulation, entropic
proper time, KMS modular flow parameter) remain distinct named
objects with explicit bridge contracts.

## What is honestly proven

* `kmsStripWidth_recall`: alias for PR #53's `kmsStripWidth`.

* `IdentifyKMSStripWithEntropicProperTime` (carrier): the explicit
  bridge contract — carries `gammaI`, `tauEnt`, and the equality
  `tauEnt(t) = kmsStripWidth gammaI t`.

* `kms_strip_separate_from_entropicProperTime` (note theorem): a
  small structural lemma documenting that without the carrier,
  `kmsStripWidth` and an arbitrary `tauEnt` are not equal.  Concrete
  counter-example shape: `gammaI ≡ 1` gives `kmsStripWidth = 1`, but
  `tauEnt` could be any function `ℝ → ℝ`.

* `IdentifyKMSStripWithEntropicProperTime.tauEnt_eq_inv_rate`:
  under the carrier, `tauEnt(t) = 1 / gammaI(t)`.

* `IdentifyKMSStripWithEntropicProperTime.tauEnt_pos_of_pos_rate`:
  under the carrier with positive rate, `tauEnt(t) > 0`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.KMSModularParameterBridge

open CATEPTMain.Integration.ImaginaryActionDissipationDictionary

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- Re-export of the strip-width definition (for clarity in this module)
-- ═══════════════════════════════════════════════════════════════════════

/-- Alias for `ImaginaryActionDissipationDictionary.kmsStripWidth`.
The KMS / modular-flow strip width at time `t` is `1 / γ_I(t)`.

This alias re-exports the definition under the explicitly-modular
namespace so consumers reading `KMSModularParameterBridge` see the
strip-width name without having to dot through the rate-form
dictionary. -/
def kmsStripWidth (gammaI : ℝ → ℝ) (t : ℝ) : ℝ :=
  ImaginaryActionDissipationDictionary.kmsStripWidth gammaI t

theorem kmsStripWidth_eq (gammaI : ℝ → ℝ) (t : ℝ) :
    kmsStripWidth gammaI t = 1 / gammaI t :=
  rfl

theorem kmsStripWidth_pos
    (gammaI : ℝ → ℝ) (hpos : ∀ σ, 0 < gammaI σ) (t : ℝ) :
    0 < kmsStripWidth gammaI t :=
  ImaginaryActionDissipationDictionary.kmsStripWidth_pos gammaI hpos t

-- ═══════════════════════════════════════════════════════════════════════
-- Bridge contract: KMS strip width vs entropic proper time
-- ═══════════════════════════════════════════════════════════════════════

/-- **Bridge contract: KMS strip width vs entropic proper time.**
The two layers are distinct by default.  Consumers who want to
identify them must exhibit this carrier with an explicit
`tauEnt_eq_kmsStripWidth` field, supplying both functions and the
proof of equality.

Phase-2 work can refine to a model-theoretic bridge once the catept
KMS-state contract is fully formalised at the operator level. -/
structure IdentifyKMSStripWithEntropicProperTime where
  /-- The dissipation rate the bridge is built on. -/
  gammaI : ℝ → ℝ
  /-- The catept-model entropic proper time function. -/
  tauEnt : ℝ → ℝ
  /-- The bridge identification: entropic proper time equals the
      KMS / modular-flow strip width pointwise.  This is the
      load-bearing equation. -/
  tauEnt_eq_kmsStripWidth :
    ∀ t : ℝ, tauEnt t = kmsStripWidth gammaI t

namespace IdentifyKMSStripWithEntropicProperTime

/-- Under the bridge contract, `tauEnt(t) = 1 / gammaI(t)` (since
strip width is `1 / γ_I`). -/
theorem tauEnt_eq_inv_rate
    (B : IdentifyKMSStripWithEntropicProperTime) (t : ℝ) :
    B.tauEnt t = 1 / B.gammaI t := by
  rw [B.tauEnt_eq_kmsStripWidth, kmsStripWidth_eq]

/-- Under the bridge contract with strictly positive rate, the
identified entropic proper time is strictly positive. -/
theorem tauEnt_pos_of_pos_rate
    (B : IdentifyKMSStripWithEntropicProperTime)
    (hpos : ∀ σ, 0 < B.gammaI σ) (t : ℝ) :
    0 < B.tauEnt t := by
  rw [B.tauEnt_eq_kmsStripWidth]
  exact kmsStripWidth_pos B.gammaI hpos t

end IdentifyKMSStripWithEntropicProperTime

-- ═══════════════════════════════════════════════════════════════════════
-- Note theorem: layers are separate by default
-- ═══════════════════════════════════════════════════════════════════════

/-- **Note theorem documenting the layer separation.**

Without the `IdentifyKMSStripWithEntropicProperTime` bridge, the
KMS strip width and an arbitrary `tauEnt` need not coincide.

Concrete counter-example: take `gammaI ≡ 1` (so `kmsStripWidth ≡ 1`)
and `tauEnt := fun t => t`.  Then `tauEnt 2 = 2 ≠ 1 = kmsStripWidth
(fun _ => 1) 2`.

This lemma exists to make the separation explicit in the audit
trail; future helpers should not assume the two layers coincide
without exhibiting a bridge carrier. -/
theorem kms_strip_separate_from_entropicProperTime :
    ∃ (gammaI tauEnt : ℝ → ℝ) (t : ℝ),
      tauEnt t ≠ kmsStripWidth gammaI t := by
  refine ⟨fun _ => (1 : ℝ), fun t => t, 2, ?_⟩
  unfold kmsStripWidth ImaginaryActionDissipationDictionary.kmsStripWidth
  norm_num

end

end CATEPTMain.Integration.KMSModularParameterBridge
