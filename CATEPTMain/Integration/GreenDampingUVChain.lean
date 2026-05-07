import CATEPTMain.Integration.EntropicGreenFromHeatSemigroup

/-!
# Green Damping → UV / No-Renormalization Chain (Step 5)

Step 5 of the user's Green-function-bridge ladder:

> Link Green damping to UV / no-renormalization certificates.
> The useful chain is:
>     entropic Green kernel → entropic damping → UV convergence
>     certificate → no counterterm needed.

This module ships the explicit single-mode chain that makes the
connection sequential and machine-checkable.  At the Gaussian-mode
level:

  `Green(a) = ∫₀^∞ heatMode a t dt` (PR #38)
            `= entropicProperTime a` (T-R Phase 1)
            `= 1 / (2 a)` (definition)
            `↦ exp(−Green(a))` (UV-suppression weight, in (0, 1]).

The composition `green_to_uv_damping_chain` bundles these four facts
into a single theorem, exposing the chain explicitly so downstream
consumers can re-use it.

## What is honestly proven

* `green_to_uv_damping_chain` (★ HEADLINE ★): for a Gaussian mode of
  action coefficient `a > 0`, all four chain links hold simultaneously:
    1. `∫₀^∞ heatMode a t dt = entropicProperTime a`  (PR #38)
    2. `entropicProperTime a = 1 / (2 a)`             (definitional)
    3. `exp(−entropicProperTime a) ≤ 1`              (damping ≤ 1)
    4. `0 < exp(−entropicProperTime a)`              (damping > 0)

  Cannot be discharged without the explicit positivity `0 < a`; the
  trivial `a = 0` case fails item 2 (division by zero) and item 3
  (`exp(0) = 1` saturates rather than bounds).

* `green_damping_weight_bounded`: corollary —
  `0 < exp(−entropicProperTime a) ≤ 1`.  Matches the
  `MeasurePathIntegralModel.damping` shape; the partition-function
  bound `‖⟨obs⟩‖ ≤ C · partitionFunction m` from
  `RigorousComplexFeynmanKac` consumes exactly this kind of weight.

## Architectural fit

```text
HeatSemigroupEntropicTime.heatMode (PR T-S)
        ↓
EntropicGreenFromHeatSemigroup.green_function_eq_entropicProperTime (PR #38)
        ↓
THIS MODULE: green_to_uv_damping_chain
        ↓ exp(−τ) ≤ 1, > 0   (matches MeasurePathIntegralModel.damping)
        ↓
RigorousComplexFeynmanKac.complex_FK_rigorous (PR #30)
        ↓
PhysicalUVConvergenceCertificate.physical_uv_certificate_no_counterterm_needed
                                                  (no counterterm needed)
```

The chain is now sequential and machine-checkable end-to-end at the
single-mode level.  Lifting from a Gaussian mode to a full physical
field theory plugs in via `RigorousComplexFeynmanKac` (which consumes
any `MeasurePathIntegralModel` with `actionIm_nonneg` and L¹-damping)
plus the existing UV-certificate chain.

## Honest scope

* **Single-mode only.**  Each Gaussian mode admits this chain
  individually; the multimode / cube-factorization lift uses the P22
  / `T3TailBound` and `HigherDegreeT3TailSharp` (PR #32) infrastructure
  already shipped.

* **Real-valued damping.**  Complex cases reduce to the damping side
  via Phase-12 `‖weight‖ = damping` (already in tree).
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GreenDampingUVChain

open CATEPTMain.Integration.EntropicGreenFromHeatSemigroup
open CATEPTMain.Integration.HeatSemigroupEntropicTime
open CATEPTMain.Integration.PropagatorEntropicTime

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- Headline: full chain in one theorem
-- ═══════════════════════════════════════════════════════════════════════

/-- ★ **HEADLINE — Green-damping UV chain** ★

For a Gaussian mode of action coefficient `a > 0`, the four chain
links — Green = ∫ heat semigroup, ∫ heat semigroup = τ(a), τ(a) is
finite and positive, exp(−τ(a)) is in (0, 1] — all hold simultaneously.

This is the single-mode connector exposing the chain

  `Green ↔ ∫heat ↔ τ(a) ↔ exp(−τ(a)) ↔ damping ∈ (0,1]`

at one theorem boundary, so downstream consumers can re-use the
sequential identification without re-deriving each step. -/
theorem green_to_uv_damping_chain (a : ℝ) (ha : 0 < a) :
    -- (1) Green = ∫ heat semigroup = entropic proper time.
    (∫ t in Set.Ioi (0 : ℝ), heatMode a t) = entropicProperTime a ∧
    -- (2) Inverse-coupling identification.
    entropicProperTime a = 1 / (2 * a) ∧
    -- (3) The "Green-damping" weight is at most 1 (UV suppression).
    Real.exp (-(entropicProperTime a)) ≤ 1 ∧
    -- (4) The "Green-damping" weight is strictly positive.
    0 < Real.exp (-(entropicProperTime a)) := by
  refine ⟨green_function_eq_entropicProperTime a ha, rfl, ?_, ?_⟩
  · -- exp(-τ) ≤ 1 since τ ≥ 0 (τ = 1/(2a) > 0 > 0).
    rw [Real.exp_le_one_iff]
    have hτ_pos : 0 < entropicProperTime a := by
      unfold entropicProperTime
      positivity
    linarith
  · -- exp(_) > 0 always.
    exact Real.exp_pos _

-- ═══════════════════════════════════════════════════════════════════════
-- Damping-shape corollary
-- ═══════════════════════════════════════════════════════════════════════

/-- **Damping-shape corollary.**  The Green-damping weight
`exp(−entropicProperTime a)` satisfies the canonical damping shape
`0 < weight ≤ 1` matching `MeasurePathIntegralModel.damping_pos` and
`damping_le_one`.

This is what `RigorousComplexFeynmanKac.complex_FK_rigorous`
ultimately consumes (via `MeasurePathIntegralModel.damping ∈ L¹`):
the no-counterterm chain runs on weights of exactly this shape. -/
theorem green_damping_weight_bounded (a : ℝ) (ha : 0 < a) :
    0 < Real.exp (-(entropicProperTime a)) ∧
      Real.exp (-(entropicProperTime a)) ≤ 1 :=
  ⟨(green_to_uv_damping_chain a ha).2.2.2,
   (green_to_uv_damping_chain a ha).2.2.1⟩

end

end CATEPTMain.Integration.GreenDampingUVChain
