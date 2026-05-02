import NavierStokesClean.CATEPT.CFLClockEntropicBridge
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic

/-!
# State-Dependent Entropic-Time Integral (Step 6 — first sub-step)

Smallest defensible first sub-step of step 6 of the Green-function-
bridge ladder ("state-dependent entropic Green functions"): the
**time-integral** of a state-dependent rate, recovering `dtauFromDt`
as the constant case.

The CFL clock layer (`CFLClockEntropicBridge`) already gives us the
constant-rate identity

  `dτ = lam · dt`,  `dtauFromDt t lam = lam · t`

for a fixed rate `lam`.  In the physical CAT/EPT setting, the rate
typically depends on **state** (enstrophy, modular flow, palinstrophy,
…), e.g. via `ModularNoetherCompatibility.catEptRateNS`.  When the
rate is parametrised by **geometric time** `t` (with the state-
dependence already substituted), the integrated entropic time is

  `τ(t) = ∫₀^t rate(σ) dσ`.

This module ships that integral and proves the constant-rate
specialisation, so future Phase-2 work on non-autonomous propagators
has a clean object to plug into.

## What is honestly proven

* `entropicTimeIntegral` (def): `τ(t) := ∫₀^t rate(σ) dσ`.

* `entropicTimeIntegral_zero`: `τ(0) = 0` (no entropic time has elapsed
  at the initial geometric time).

* `entropicTimeIntegral_constant`: for constant rate `lam`,
  `τ(t) = lam · t`.

* `entropicTimeIntegral_constant_eq_dtauFromDt`: connects the
  constant-rate specialisation to `CFLClock.dtauFromDt`, recording
  that the existing constant-rate clock layer is a special case of
  this state-dependent integral.

## Honest scope (CRUCIAL)

This is **strictly the time-integral piece** of state-dependent
entropic time.  Specifically:

* ✅ Time-integral of a rate function `rate : ℝ → ℝ`.
* ✅ Constant-rate ↔ `dtauFromDt` reduction.
* ❌ Non-autonomous propagator (time-ordered exponential
  `T-exp ∫₀^t A/rate(σ) dσ`) — Mathlib does not provide this; Phase 2.
* ❌ Concrete physics rates (`catEptRateNS`, modular rate, etc.) plugged
  in — those connect via existing modules (`ModularNoetherCompatibility`)
  separately; this module is generic.

## Architectural fit

```text
CFLClockEntropicBridge.dtauFromDt (constant rate)
        ↓ generalise rate from constant to function
THIS MODULE: entropicTimeIntegral
        ↓ Phase 2: lift to operator-valued non-autonomous propagator
        ↓ (time-ordered exponential, deferred)
EntropicGreenFunctionBridge (state-dependent variant, Phase 2)
        ↓
no-renormalization chain at the state-dependent level (Phase 2)
```
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.EntropicTimeIntegralStateDependent

open NavierStokesClean.CATEPT.CFLClock (dtauFromDt)
open MeasureTheory

noncomputable section

/-- **State-dependent entropic-time integral.**  For a rate function
`rate : ℝ → ℝ` and a geometric time `t : ℝ`, the cumulative entropic
time is the interval integral

  `τ(t) := ∫₀^t rate(σ) dσ`.

In the constant-rate case `rate ≡ lam` this collapses to
`lam · t = dtauFromDt t lam` (see
`entropicTimeIntegral_constant_eq_dtauFromDt`). -/
def entropicTimeIntegral (rate : ℝ → ℝ) (t : ℝ) : ℝ :=
  ∫ σ in (0 : ℝ)..t, rate σ

/-- **Initial value.**  `τ(0) = 0`: no entropic time has elapsed at
the initial geometric time. -/
theorem entropicTimeIntegral_zero (rate : ℝ → ℝ) :
    entropicTimeIntegral rate 0 = 0 := by
  unfold entropicTimeIntegral
  exact intervalIntegral.integral_same

/-- **Constant-rate specialisation.**  When `rate ≡ lam`,
`τ(t) = lam · t`. -/
theorem entropicTimeIntegral_constant (lam t : ℝ) :
    entropicTimeIntegral (fun _ => lam) t = lam * t := by
  unfold entropicTimeIntegral
  rw [intervalIntegral.integral_const, sub_zero, smul_eq_mul, mul_comm]

/-- **Bridge to the existing CFL clock layer.**  The constant-rate
specialisation of `entropicTimeIntegral` is exactly
`NavierStokesClean.CATEPT.CFLClock.dtauFromDt`.  This records that the
existing constant-rate clock infrastructure is a special case of the
state-dependent integral shipped here. -/
theorem entropicTimeIntegral_constant_eq_dtauFromDt (lam t : ℝ) :
    entropicTimeIntegral (fun _ => lam) t = dtauFromDt t lam := by
  rw [entropicTimeIntegral_constant]
  unfold NavierStokesClean.CATEPT.CFLClock.dtauFromDt
  ring

-- ═══════════════════════════════════════════════════════════════════════
-- Structural properties (non-negativity, monotonicity)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Non-negativity for non-negative rates.**  When `rate σ ≥ 0`
pointwise and `t ≥ 0`, the entropic time `τ(t)` is non-negative.

Physically: a non-negative entropic-clock rate produces a non-negative
elapsed entropic time, exactly as the constant-rate CFL clock does. -/
theorem entropicTimeIntegral_nonneg_of_nonneg_rate
    (rate : ℝ → ℝ) (hrate : ∀ σ, 0 ≤ rate σ) (t : ℝ) (ht : 0 ≤ t) :
    0 ≤ entropicTimeIntegral rate t := by
  unfold entropicTimeIntegral
  exact intervalIntegral.integral_nonneg_of_forall ht hrate

/-- **Special case: catEpt-style rates produce non-negative τ.**
Records the typical CAT/EPT constraint shape — a positive rate
function (modular flow, palinstrophy, …) yields a non-negative τ
on any forward-time window. -/
theorem entropicTimeIntegral_nonneg_of_pos_rate
    (rate : ℝ → ℝ) (hrate : ∀ σ, 0 < rate σ) (t : ℝ) (ht : 0 ≤ t) :
    0 ≤ entropicTimeIntegral rate t :=
  entropicTimeIntegral_nonneg_of_nonneg_rate rate
    (fun σ => (hrate σ).le) t ht

-- ═══════════════════════════════════════════════════════════════════════
-- Linearity in the rate function
-- ═══════════════════════════════════════════════════════════════════════

/-- **Linearity in the rate (additivity).**  For two integrable rate
functions, the entropic time of the sum is the sum of entropic times:

  `τ_{rate₁ + rate₂}(t) = τ_{rate₁}(t) + τ_{rate₂}(t)`. -/
theorem entropicTimeIntegral_add
    (rate₁ rate₂ : ℝ → ℝ) (t : ℝ)
    (h₁ : IntervalIntegrable rate₁ MeasureTheory.volume 0 t)
    (h₂ : IntervalIntegrable rate₂ MeasureTheory.volume 0 t) :
    entropicTimeIntegral (fun σ => rate₁ σ + rate₂ σ) t =
      entropicTimeIntegral rate₁ t + entropicTimeIntegral rate₂ t := by
  unfold entropicTimeIntegral
  exact intervalIntegral.integral_add h₁ h₂

/-- **Linearity in the rate (scalar multiplication).**  For any
real scalar `c`,

  `τ_{c · rate}(t) = c · τ_{rate}(t)`. -/
theorem entropicTimeIntegral_const_mul
    (c : ℝ) (rate : ℝ → ℝ) (t : ℝ) :
    entropicTimeIntegral (fun σ => c * rate σ) t =
      c * entropicTimeIntegral rate t := by
  unfold entropicTimeIntegral
  exact intervalIntegral.integral_const_mul c rate

/-- **Monotonicity in `t`.**  For a non-negative rate (with the
mild integrability hypothesis on every adjacent interval) and
`t₁ ≤ t₂`, the entropic-time integral is non-decreasing:
`τ(t₁) ≤ τ(t₂)`.

Physically: under a non-negative entropic-clock rate, *more*
geometric time produces *no less* elapsed entropic time.  This is
the state-dependent generalisation of `lam · t₁ ≤ lam · t₂` for
the constant-rate CFL clock.

Proof sketch: by the adjacent-intervals identity, `τ(t₂) − τ(t₁)
= ∫_{t₁}^{t₂} rate σ dσ ≥ 0` (the second factor is non-negative
since `rate σ ≥ 0` pointwise and `t₁ ≤ t₂`). -/
theorem entropicTimeIntegral_mono_of_nonneg_rate
    (rate : ℝ → ℝ) (hrate : ∀ σ, 0 ≤ rate σ)
    (hinteg : ∀ a b : ℝ, IntervalIntegrable rate MeasureTheory.volume a b)
    (t₁ t₂ : ℝ) (h₁₂ : t₁ ≤ t₂) :
    entropicTimeIntegral rate t₁ ≤ entropicTimeIntegral rate t₂ := by
  unfold entropicTimeIntegral
  -- ∫(0..t₂) - ∫(0..t₁) = ∫(t₁..t₂) ≥ 0.
  have h_split :
      (∫ σ in (0 : ℝ)..t₁, rate σ) + (∫ σ in t₁..t₂, rate σ)
        = ∫ σ in (0 : ℝ)..t₂, rate σ :=
    intervalIntegral.integral_add_adjacent_intervals
      (hinteg 0 t₁) (hinteg t₁ t₂)
  have h_nonneg :
      0 ≤ ∫ σ in t₁..t₂, rate σ :=
    intervalIntegral.integral_nonneg_of_forall h₁₂ hrate
  linarith

end

end CATEPTMain.Integration.EntropicTimeIntegralStateDependent
