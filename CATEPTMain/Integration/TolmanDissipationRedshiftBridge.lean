import CATEPTMain.Geometry.EntropicLapse
import CATEPTMain.Integration.ImaginaryActionDissipationDictionary

/-!
# Tolman Dissipation Redshift Bridge (Tier-2 PR #1)

Tier-2 PR #1 of four queued in `equation-spine-review-20260430.md`.

Algebraic Tolman-redshift identity for the dissipation rate `γ_I`
and the dissipation energy scale `β̃_I = ℏ · γ_I` under the entropic
lapse function `N(x) = √(−g₀₀(x))`:

  `γ_I^∞(x)    = N(x) · γ_I^loc(x)`,
  `β̃_I^∞(x)   = N(x) · β̃_I^loc(x)`,
  `T_loc(x)    = T_∞ / N(x)`.

The first two are the gravity → local-rate redshift (a local clock
running slower under stronger lapse produces a redshifted dissipation
rate). The third is the standard Tolman temperature redshift.

## Honest scope

This module ships **algebraic identities** only:

* No new physics derivations.  The lapse function is taken from
  `EntropicLapse.lapse` (PR #18 entropic-lapse harvest); the
  redshift is a definition, not a derivation.
* No claim that the catept lapse `N := Ω / (2 ν)` is *the* GR lapse
  in the strong sense.  The redshift identity is structural; concrete
  identification with GR's `√(−g₀₀)` requires a separate adapter.
* No "information time" terminology.  Per the user's correction,
  imaginary-action accumulation, entropic proper time, and KMS
  modular flow remain three separate layers.

## What is honestly proven

* `gammaI_redshift` (def): `γ_I^∞(x) := N(x) · γ_I^loc(x)`.
* `betaTildeI_redshift` (def): `β̃_I^∞(x) := N(x) · β̃_I^loc(x)`
  (using PR #53's `dissipationEnergyFromRate`).
* `gammaI_redshift_pos`: `0 < γ_I^∞(x)` if `γ_I^loc(x) > 0`.
* `betaTildeI_redshift_eq_hbar_mul_gammaI_redshift`: dimensional
  dictionary `β̃_I^∞ = ℏ · γ_I^∞`.
* `Tloc_redshift` (def): `T_loc(x) := T_∞ / N(x)`.
* `Tloc_redshift_pos`: positivity of `T_loc(x)` when `T_∞ > 0`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.TolmanDissipationRedshiftBridge

open CATEPTMain.Geometry.EntropicLapse (EntropicLapse)
open CATEPTMain.Geometry.FiniteMinkowski (CATEPTST)

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- Tolman redshift of the dissipation rate γ_I
-- ═══════════════════════════════════════════════════════════════════════

/-- **Redshifted dissipation rate.**  For an entropic lapse `N` and a
local rate field `γ_I^loc : CATEPTST → ℝ`, the global-frame rate is

  `γ_I^∞(x) := N(x) · γ_I^loc(x)`.

A local clock running slower under stronger lapse produces a
redshifted dissipation rate. -/
def gammaI_redshift
    (N : EntropicLapse) (gammaI_loc : CATEPTST → ℝ) :
    CATEPTST → ℝ :=
  fun x => N.lapse x * gammaI_loc x

/-- **Positivity of the redshifted rate.**  Strictly positive lapse
times strictly positive local rate yields strictly positive global
rate. -/
theorem gammaI_redshift_pos
    (N : EntropicLapse) (gammaI_loc : CATEPTST → ℝ)
    (h : ∀ x, 0 < gammaI_loc x) (x : CATEPTST) :
    0 < gammaI_redshift N gammaI_loc x :=
  mul_pos (N.lapse_pos x) (h x)

-- ═══════════════════════════════════════════════════════════════════════
-- Tolman redshift of the dissipation energy scale β̃_I
-- ═══════════════════════════════════════════════════════════════════════

/-- **Redshifted dissipation energy scale.**  For an entropic lapse
`N`, Planck's constant `ℏ`, and a local rate field `γ_I^loc`, the
global-frame energy scale is

  `β̃_I^∞(x) := N(x) · β̃_I^loc(x) = N(x) · (ℏ · γ_I^loc(x))`.

The factor of `N(x)` reflects the same gravitational-clock-rate
redshift as for `γ_I` itself, since `β̃_I = ℏ · γ_I` is a
dimensional dictionary (`ImaginaryActionDissipationDictionary`,
PR #53). -/
def betaTildeI_redshift
    (N : EntropicLapse) (hbar : ℝ) (gammaI_loc : CATEPTST → ℝ) :
    CATEPTST → ℝ :=
  fun x => N.lapse x * (hbar * gammaI_loc x)

/-- **Dimensional dictionary at the redshifted level.**  `β̃_I^∞ =
ℏ · γ_I^∞` pointwise — the dictionary `β̃_I = ℏ · γ_I` is preserved
by the redshift. -/
theorem betaTildeI_redshift_eq_hbar_mul_gammaI_redshift
    (N : EntropicLapse) (hbar : ℝ) (gammaI_loc : CATEPTST → ℝ)
    (x : CATEPTST) :
    betaTildeI_redshift N hbar gammaI_loc x =
      hbar * gammaI_redshift N gammaI_loc x := by
  unfold betaTildeI_redshift gammaI_redshift
  ring

-- ═══════════════════════════════════════════════════════════════════════
-- Tolman temperature redshift  T_loc(x) = T_∞ / N(x)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Tolman temperature redshift.**  For an entropic lapse `N` and
a global-frame temperature `T_∞`, the local temperature at spacetime
event `x` is

  `T_loc(x) := T_∞ / N(x)`.

Standard Tolman result: stronger gravity (larger `N`) yields lower
local temperature. -/
def Tloc_redshift (N : EntropicLapse) (T_inf : ℝ) : CATEPTST → ℝ :=
  fun x => T_inf / N.lapse x

/-- **Positivity of `T_loc`.**  `T_∞ > 0` and lapse positivity yield
`0 < T_loc(x)`. -/
theorem Tloc_redshift_pos
    (N : EntropicLapse) (T_inf : ℝ) (hT : 0 < T_inf) (x : CATEPTST) :
    0 < Tloc_redshift N T_inf x :=
  div_pos hT (N.lapse_pos x)

end

end CATEPTMain.Integration.TolmanDissipationRedshiftBridge
