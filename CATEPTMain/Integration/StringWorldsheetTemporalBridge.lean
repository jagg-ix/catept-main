import CATEPTMain.Integration.KMSModularParameterBridge

/-!
# String Worldsheet ↔ CAT/EPT Temporal Layer Separation

Records the structural separation between **worldsheet `τ`** (a
gauge / local coordinate on the string worldsheet) and the
**entropic proper time `τ_ent = S_I / ℏ`** (the CAT/EPT clock
variable).

## Why a separate module?

Worldsheet `τ_ws` is varied by reparameterizations and is *not* a
physical clock; identifying it with `τ_ent` by definition would
break the layer-naming convention recorded in
[`docs/architecture/string-catept-spine.md`](../../docs/architecture/string-catept-spine.md).
This module enforces the separation explicitly, mirroring the
pattern of [`KMSModularParameterBridge`](./KMSModularParameterBridge.lean)
(PR #61) for the modular-flow vs entropic-proper-time separation.

## What is honestly proven

* `IdentifyWorldsheetTauWithEntropicProperTime` (carrier struct):
  the explicit bridge contract — carries
  `tau_ws` (worldsheet coordinate function),
  `tauEnt` (entropic proper time function), and the equality
  hypothesis `∀ s, tauEnt s = tau_ws s`.

* `worldsheet_tau_separate_from_entropic_proper_time` (note theorem):
  documents that without the carrier, an arbitrary worldsheet `τ_ws`
  and an arbitrary `tauEnt` need not coincide.  Concrete counter-
  example: `tau_ws := fun _ => 0` (a constant gauge), `tauEnt :=
  fun s => s` (linear accumulation).  Then `tauEnt 1 = 1 ≠ 0 =
  tau_ws 1`.

## Honest scope

* **No claim that worldsheet `τ` is unphysical** in any absolute
  sense; it is simply not the catept clock.  Different physics
  applications use different identifications, but each must be
  recorded as a `Identify…` carrier.
* **No string-side derivation.**  The module records the layer
  separation only; concrete worldsheet content lives in upstream
  string-theory packages.
* **No "information time" terminology.**  Per the established
  catept convention.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.StringWorldsheetTemporalBridge

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- Bridge contract: worldsheet τ vs entropic proper time
-- ═══════════════════════════════════════════════════════════════════════

/-- **Bridge contract: worldsheet `τ` vs entropic proper time.**
The two layers are distinct by default.  Consumers who want to
identify them must exhibit this carrier with an explicit
`tauEnt_eq_tauWs` field.

Phase-2 string-theory work that wants the identification (e.g.
specific gauge choices in conformal frame) supplies the carrier.

Following the pattern of `IdentifyKMSStripWithEntropicProperTime`
(PR #61) and `IdentifyEntropicProperTimeWithImaginaryAction`
(PR #53). -/
structure IdentifyWorldsheetTauWithEntropicProperTime where
  /-- The worldsheet coordinate function.  Domain is the
      worldsheet parameter type (here scalarised to ℝ at this
      structural carrier level). -/
  tau_ws : ℝ → ℝ
  /-- The catept-model entropic proper time function. -/
  tauEnt : ℝ → ℝ
  /-- The bridge identification: entropic proper time equals the
      worldsheet `τ` pointwise.  This is the load-bearing equation. -/
  tauEnt_eq_tauWs : ∀ s : ℝ, tauEnt s = tau_ws s

namespace IdentifyWorldsheetTauWithEntropicProperTime

/-- Under the bridge contract, the entropic proper time at any
worldsheet parameter equals the worldsheet coordinate. -/
theorem tauEnt_eq_tauWs_at
    (B : IdentifyWorldsheetTauWithEntropicProperTime) (s : ℝ) :
    B.tauEnt s = B.tau_ws s :=
  B.tauEnt_eq_tauWs s

/-- Under the bridge contract, the entropic-proper-time function and
worldsheet coordinate function agree as functions. -/
theorem tauEnt_eq_tauWs_funext
    (B : IdentifyWorldsheetTauWithEntropicProperTime) :
    B.tauEnt = B.tau_ws := by
  funext s
  exact B.tauEnt_eq_tauWs s

end IdentifyWorldsheetTauWithEntropicProperTime

-- ═══════════════════════════════════════════════════════════════════════
-- Note theorem: layers are separate by default
-- ═══════════════════════════════════════════════════════════════════════

/-- **Note theorem documenting the layer separation.**

Without the `IdentifyWorldsheetTauWithEntropicProperTime` bridge,
the worldsheet coordinate `τ_ws` and an arbitrary `tauEnt` need not
coincide.

Concrete counter-example: take `tau_ws := fun _ => 0` (a constant
gauge) and `tauEnt := fun s => s` (linear accumulation).  Then
`tauEnt 1 = 1 ≠ 0 = tau_ws 1`.

This lemma exists to make the separation explicit in the audit
trail; future helpers should not assume the two layers coincide
without exhibiting a bridge carrier. -/
theorem worldsheet_tau_separate_from_entropic_proper_time :
    ∃ (tau_ws tauEnt : ℝ → ℝ) (s : ℝ),
      tauEnt s ≠ tau_ws s := by
  refine ⟨fun _ => (0 : ℝ), fun s => s, 1, ?_⟩
  norm_num

end

end CATEPTMain.Integration.StringWorldsheetTemporalBridge
