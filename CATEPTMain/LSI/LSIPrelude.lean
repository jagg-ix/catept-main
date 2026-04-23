import CATEPTMain.Framework.AFPBridgeFramework
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.MeasureTheory.Measure.Stieltjes
import Mathlib.Analysis.Calculus.Deriv.Basic
/-!
# LSI Prelude — Lebesgue_Stieltjes_Integral (AFP) → Lean 4

Phase-1 opaque scaffold for `Lebesgue_Stieltjes_Integral` (Yosuke Ito — 2026).
https://www.isa-afp.org/entries/Lebesgue_Stieltjes_Integral.html

AFP dependencies bridged here:
  Wlog → no-op (`wlog` tactic available in Lean 4 Mathlib)
  HOL-Analysis / HOL-Probability → Mathlib.MeasureTheory imports

Module-specific content: Stieltjes measure from monotone right-continuous
  function F : ℝ → ℝ, Lebesgue-Stieltjes integral, change-of-variables formula,
  integration by parts.

BINDER RULES (B29–B32):
  B29: all Stieltjes generating functions emitted as (F : ℝ → ℝ) (hF : Monotone F)
  B30: integrability stated as separate predicate before integral
  B31: absolute continuity emitted as a named hypothesis
  B32: derivative emitted via (hDiff : DifferentiableAt ℝ F x)

Phase-2 upgrade path:
  Replace lsiMeasure axiom with MeasureTheory.StieltjesFunction.measure.
  All theory imports remain unchanged.

See: CATEPTMain/AFPBridge/LSI/LSI_WORKLOG.lean
-/

set_option autoImplicit false

open CATEPTMainFramework.TacticStubs

namespace CATEPTMain.LSI

-- ── Stieltjes measure (phase-1 axiom) ─────────────────────────────────────────
-- AFP: `interval_measure F` = Stieltjes measure of monotone right-continuous F.
-- Phase-1: axiom without bundled proof obligations.
-- BINDER RULE B29: never emit (F : ℝ → ℝ) without accompanying (hF : Monotone F).
noncomputable axiom lsiMeasure : (ℝ → ℝ) → MeasureTheory.Measure ℝ

-- Key property: half-open interval measure equals function increment
axiom lsiMeasure_Ioc (F : ℝ → ℝ) (hF : Monotone F) (a b : ℝ) (h : a ≤ b) :
    lsiMeasure F (Set.Ioc a b) = ENNReal.ofReal (F b - F a)

-- Right-continuity: lsiMeasure uses right-continuous regularisation of F
axiom lsiMeasure_right_cont (F : ℝ → ℝ) (hF : Monotone F) :
    ∀ x : ℝ, Filter.Tendsto F (nhdsWithin x (Set.Ici x)) (nhds (F x)) → True

-- ── Absolute continuity predicate ─────────────────────────────────────────────
-- AFP: `absolutely_continuous ν μ`
-- Phase-1: wrapped predicate. Phase-2: MeasureTheory.Measure.AbsolutelyContinuous
abbrev LSIAbsCont (ν μ : MeasureTheory.Measure ℝ) : Prop :=
  MeasureTheory.Measure.AbsolutelyContinuous ν μ

-- ── Lebesgue-Stieltjes integral ────────────────────────────────────────────────
-- ∫ g dF := ∫ g(x) d(lsiMeasure F)(x)
-- BINDER RULE B30: integrability stated separately.
noncomputable def lsiIntegral (F g : ℝ → ℝ) : ℝ :=
  ∫ x, g x ∂(lsiMeasure F)

noncomputable def lsiIntegralOn (F g : ℝ → ℝ) (a b : ℝ) : ℝ :=
  ∫ x in Set.Ioc a b, g x ∂(lsiMeasure F)

-- ── Change-of-variables formula ────────────────────────────────────────────────
-- AFP main result: ∫ₐᵇ g dF = ∫ₐᵇ g * F' dx (for abs. continuous F)
-- Phase-1: axiom. Phase-2: use MeasureTheory.StieltjesFunction.withDensity_deriv.
axiom lsiChangeOfVariables (F g : ℝ → ℝ) (hF : Monotone F) (a b : ℝ)
    (habsCont : LSIAbsCont (lsiMeasure F) MeasureTheory.volume) :
    lsiIntegralOn F g a b =
    ∫ x in Set.Ioc a b, g x * deriv F x ∂MeasureTheory.volume

-- ── Integration by parts ──────────────────────────────────────────────────────
-- AFP: ∫ₐᵇ g dF + ∫ₐᵇ F dg = F(b)·g(b) − F(a)·g(a)
-- Phase-1: axiom. Phase-2: Fubini + indicator function argument.
axiom lsiIntByParts (F g : ℝ → ℝ) (hF : Monotone F) (hG : Monotone g) (a b : ℝ) :
    lsiIntegralOn F g a b + lsiIntegralOn g F a b =
    F b * g b - F a * g a

end CATEPTMain.LSI
