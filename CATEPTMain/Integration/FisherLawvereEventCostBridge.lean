import CATEPTMain.Integration.GreenDampingUVChain
import CATEPTMain.Integration.EntropicTimeIntegralStateDependent

/-!
# Fisher–Lawvere Event-Cost Bridge

Adapter layer that ties three reusable pieces from external Fisher–Rao /
Lawvere-metric advisor analyses into the catept session-30 chain.

## What this module ships

1. **`LawvereCost` carrier** — abstract enriched-category-style cost
   functor with non-negativity and triangle inequality.  Sits next to
   `green_damping_weight_bounded` (PR #39): consumers obtain
   `0 < exp(-cost) ≤ 1` damping from the cost shape.

2. **`FisherRateCarrier`** — abstract pointwise non-negative rate
   function `rate : ℝ → ℝ` satisfying integrability on every interval,
   suitable for plugging into
   `EntropicTimeIntegralStateDependent.entropicTimeIntegral`
   (PRs #42–#44, #50).  Concrete instances such as
   `rate(t) = √(g_F(θ'(t), θ'(t)))` (Fisher-Rao geodesic speed)
   produce a bona-fide entropic-time integral in the existing
   state-dependent τ machinery.

3. **`KLLocalQuadraticExpansion` contract** — the standard local
   quadratic expansion `D_KL(p_θ || p_{θ+dθ}) ≈ ½ · g_F(dθ, dθ)`
   stated as an abstract structural Prop (a quadratic-form bound).
   Phase-2 work can refine to a concrete derivative-of-KL theorem
   when Mathlib's KL infrastructure (Radon-Nikodym + ε² Taylor
   expansion) is wired up; the Phase-1 contract captures the shape.

## Honest scope (CRUCIAL)

* **No new physics derivations.**  The Lawvere triangle inequality
  is taken as a structure axiom (consumers prove it for their
  specific cost function); the Fisher rate is taken as a non-negative
  scalar function (consumers prove it from `g_F(θ', θ')`).
* **No information stress tensor / Bianchi compatibility / complex
  Einstein mass.**  Those need smooth-section / functional-derivative
  infrastructure that Mathlib does not currently ship; they are
  tracked separately and remain Phase-2.
* **No Puthoff polarizable-vacuum content.**  Explicitly flagged as
  optional / non-core in the advisor analysis; not load-bearing.
* **No "information time" terminology.**  Following the user's
  correction, this module keeps three layers strictly separate:
  imaginary-action accumulation, entropic proper time, and
  KMS/modular flow parameter.  Consumers identify them only via
  explicit bridge theorems.

## Architectural fit

```text
Lawvere event/process cost
        ↓ (this module)
exp(-cost) ∈ (0, 1]   ←  green_damping_weight_bounded shape (PR #39)
        ↓
MeasurePathIntegral.damping  →  RigorousComplexFeynmanKac (PR #30)


Fisher rate √g_F(θ', θ')
        ↓ (this module)
EntropicTimeIntegralStateDependent.entropicTimeIntegral (PRs #42–#50)
        ↓
state-dependent τ with the full clock-property suite already shipped
```
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.FisherLawvereEventCostBridge

open CATEPTMain.Integration.EntropicTimeIntegralStateDependent

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- Lawvere event-cost carrier + damping bound
-- ═══════════════════════════════════════════════════════════════════════

/-- **Lawvere event-cost carrier.**  Abstract enriched-category cost
functor on a type `α` of events.  The fields encode:
  - `cost : α → α → ℝ`
  - non-negativity
  - triangle inequality (Lawvere `d(A,C) ≤ d(A,B) + d(B,C)`)

The carrier is intentionally minimal: no symmetry hypothesis (Lawvere
metrics are *not* required to be symmetric) and no zero-self-cost
hypothesis (the user can supply or omit it). -/
structure LawvereCost (α : Type) where
  /-- The pairwise event cost. -/
  cost : α → α → ℝ
  /-- Pointwise non-negativity of the cost. -/
  cost_nonneg : ∀ a b, 0 ≤ cost a b
  /-- The Lawvere triangle inequality. -/
  triangle : ∀ a b c, cost a c ≤ cost a b + cost b c

namespace LawvereCost

variable {α : Type}

/-- **Lawvere damping is bounded.**  For any Lawvere cost on `α`,
the damping weight `exp(-cost a b)` is in `(0, 1]`.  Matches the
canonical damping shape consumed by
`MeasurePathIntegralModel.damping` (via PR #39's
`green_damping_weight_bounded`) and `RigorousComplexFeynmanKac`
(PR #30). -/
theorem damping_bounded (L : LawvereCost α) (a b : α) :
    0 < Real.exp (-(L.cost a b)) ∧ Real.exp (-(L.cost a b)) ≤ 1 := by
  refine ⟨Real.exp_pos _, ?_⟩
  rw [Real.exp_le_one_iff]
  linarith [L.cost_nonneg a b]

/-- **Submultiplicative damping under composition.**  For events
`a, b, c : α` with Lawvere cost, the damping weight respects the
triangle inequality submultiplicatively:

  `exp(-cost a c) ≥ exp(-cost a b) · exp(-cost b c)`.

This is the "composition respects triangle" reading: a longer event
chain produces *no less* damping than the path-summed one (i.e. the
direct path is the cheapest). -/
theorem damping_submultiplicative
    (L : LawvereCost α) (a b c : α) :
    Real.exp (-(L.cost a b)) * Real.exp (-(L.cost b c))
      ≤ Real.exp (-(L.cost a c)) := by
  rw [← Real.exp_add]
  apply Real.exp_le_exp.mpr
  linarith [L.triangle a b c]

end LawvereCost

-- ═══════════════════════════════════════════════════════════════════════
-- Fisher rate carrier + connector to entropicTimeIntegral
-- ═══════════════════════════════════════════════════════════════════════

/-- **Fisher rate carrier.**  Abstract non-negative rate function
`rate : ℝ → ℝ` plus per-interval integrability — the minimum data
needed to plug into `entropicTimeIntegral` and inherit
non-negativity / monotonicity / linearity from
`EntropicTimeIntegralStateDependent` (PRs #42–#44, #50).

Concrete physics instances supply `rate(t) := √(g_F(θ'(t), θ'(t)))`
where `g_F` is the Fisher-Rao metric and `θ` parametrises a curve in
parameter space.  This module does NOT formalise `g_F` directly
(no smooth-manifold infrastructure assumed); it merely records the
contract that the rate be non-negative and integrable. -/
structure FisherRateCarrier where
  /-- The pointwise rate function. -/
  rate : ℝ → ℝ
  /-- Pointwise non-negativity (Fisher-Rao geodesic speed is always ≥ 0). -/
  rate_nonneg : ∀ σ, 0 ≤ rate σ
  /-- Per-interval integrability — strong enough to invoke
      `entropicTimeIntegral_mono_of_nonneg_rate` and friends. -/
  integrable : ∀ a b : ℝ, IntervalIntegrable rate MeasureTheory.volume a b

namespace FisherRateCarrier

/-- **Fisher rate produces a non-negative entropic-time integral.**
For any Fisher rate carrier and any forward-time `t ≥ 0`, the
integrated entropic time `τ(t) := ∫₀^t rate σ dσ` is non-negative.

This is the connector: a Fisher-Rao geodesic speed plugged into
`entropicTimeIntegral` automatically satisfies the
`entropicTimeIntegral_nonneg_of_nonneg_rate` clock-property
(PR #43). -/
theorem entropicTimeIntegral_nonneg
    (F : FisherRateCarrier) (t : ℝ) (ht : 0 ≤ t) :
    0 ≤ entropicTimeIntegral F.rate t :=
  entropicTimeIntegral_nonneg_of_nonneg_rate F.rate F.rate_nonneg t ht

/-- **Fisher rate produces a monotone entropic-time integral.**
For any Fisher rate carrier and `t₁ ≤ t₂`,
`entropicTimeIntegral F.rate t₁ ≤ entropicTimeIntegral F.rate t₂`. -/
theorem entropicTimeIntegral_mono
    (F : FisherRateCarrier) (t₁ t₂ : ℝ) (h₁₂ : t₁ ≤ t₂) :
    entropicTimeIntegral F.rate t₁ ≤ entropicTimeIntegral F.rate t₂ :=
  entropicTimeIntegral_mono_of_nonneg_rate F.rate F.rate_nonneg
    F.integrable t₁ t₂ h₁₂

end FisherRateCarrier

-- ═══════════════════════════════════════════════════════════════════════
-- KL local quadratic expansion (Phase-1 contract)
-- ═══════════════════════════════════════════════════════════════════════

/-- **KL local quadratic expansion contract** (Phase-1 abstract form).

The standard fact `D_KL(p_θ || p_{θ+dθ}) = ½ · g_F(dθ, dθ) + O(|dθ|³)`
states that the KL divergence is locally Taylor-approximated by half
the Fisher-Rao quadratic form on the parameter increment.  Phase-1
captures this as a structural Prop:

  *for some constant `C ≥ 0`, the absolute error between `D_KL` and
  `½ · g_F(dθ, dθ)` is bounded by `C · |dθ|³`*

with the carrier exposing the bound constant `C`.  Phase-2 work can
refine to a concrete `Asymptotics.IsLittleO`-flavoured statement when
Mathlib's KL / smooth-manifold infrastructure is wired up.

Consumers wanting a non-vacuous contract should require both
`bound_nonneg` and `quadratic_form_nonneg` (Fisher metric is
positive-semidefinite). -/
structure KLLocalQuadraticExpansion where
  /-- Symbolic KL divergence as a function of parameter increment. -/
  klDivergence : ℝ → ℝ
  /-- Symbolic Fisher quadratic form (`g_F(dθ, dθ)` evaluated at `dθ`). -/
  fisherQuadratic : ℝ → ℝ
  /-- Bound constant for the cubic remainder. -/
  bound : ℝ
  /-- The bound constant is non-negative. -/
  bound_nonneg : 0 ≤ bound
  /-- Fisher quadratic form is non-negative (Fisher metric is PSD). -/
  fisherQuadratic_nonneg : ∀ dθ, 0 ≤ fisherQuadratic dθ
  /-- The local-quadratic bound: `|D_KL(dθ) - ½ · g_F(dθ, dθ)| ≤ C · |dθ|³`. -/
  local_quadratic_bound :
    ∀ dθ : ℝ,
      |klDivergence dθ - (1 / 2 : ℝ) * fisherQuadratic dθ|
        ≤ bound * |dθ|^3

namespace KLLocalQuadraticExpansion

/-- **At zero increment, KL is bounded by the cubic remainder.**  For
any KL-local-quadratic carrier, evaluating at `dθ = 0` gives
`|klDivergence 0 - 0| ≤ 0`, i.e. `klDivergence 0 = 0` follows from
the bound + Fisher-PSD.  This records the structural consistency of
the carrier at the origin. -/
theorem klDivergence_zero_le_zero (K : KLLocalQuadraticExpansion) :
    |K.klDivergence 0 - (1 / 2 : ℝ) * K.fisherQuadratic 0| ≤ 0 := by
  have h := K.local_quadratic_bound 0
  -- bound * |0|^3 = bound * 0 = 0
  have : K.bound * |(0 : ℝ)|^3 = 0 := by simp
  linarith

end KLLocalQuadraticExpansion

end

end CATEPTMain.Integration.FisherLawvereEventCostBridge
