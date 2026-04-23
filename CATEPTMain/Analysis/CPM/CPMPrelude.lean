import CATEPTMain.Core.Framework.AFPBridgeFramework
import Mathlib.MeasureTheory.Measure.MeasureSpace
import Mathlib.MeasureTheory.Measure.Typeclasses.Finite
import Mathlib.MeasureTheory.Measure.Typeclasses.SFinite
/-!
# CPM Prelude — Coproduct_Measure (AFP) → Lean 4

Phase-1 opaque scaffold for `Coproduct_Measure` (Michikazu Hirata — 2024).
https://www.isa-afp.org/entries/Coproduct_Measure.html

AFP dependencies bridged here:
  S_Finite_Measure_Monad → IsSFinite axiom predicate

Module-specific content: coproduct measure ∐ᵢ μᵢ on disjoint union Σ i, α i,
  coproduct sigma-algebra, injection measurability, measure properties.

CRITICAL TYPE DISTINCTION (E35/E36):
  - Domain of coproduct: `Σ i : I, α i`  (Lean 4 dependent sum / Sigma type)
    NOT `Sum α β` (binary coproduct type) — injections are `Sigma.mk i`, NOT Sum.inl/Sum.inr
  - coprodMeasure is indexed family: `(∀ i, Measure (α i)) → Measure (Σ i, α i)`
    NOT a binary `Measure → Measure → Measure`

BINDER RULES:
  B26: indexed family measure `(μ : ∀ i : I, Measure (α i))` never collapsed to single Measure
  B27: disjoint union domain always `Σ i : I, α i`, never `Sum α β` for indexed families
  B28: injection `Sigma.mk i : α i → Σ j : I, α j` (not `Sum.inl`/`Sum.inr`)

Phase-2 upgrade path:
  Replace coprodMeasure axiom with MeasureTheory.Measure.sum family construction.
  IsSFinite → MeasureTheory.SFinite typeclass if available in pinned Mathlib.

See: CATEPTMain/AFPBridge/CPM/CPM_WORKLOG.lean
-/

set_option autoImplicit false

open CATEPTMain.Core.Framework.TacticStubs

namespace CATEPTMain.Analysis.CPM

-- ── s-finite measure predicate ─────────────────────────────────────────────────
-- AFP S_Finite_Measure_Monad: `s_finite_measure μ`
-- Phase-1: axiom. Phase-2: MeasureTheory.SFinite typeclass (if in Mathlib 4.29).
axiom IsSFinite {α : Type*} [MeasurableSpace α] (μ : MeasureTheory.Measure α) : Prop

-- s-finite closed under countable sums:
axiom isSFinite_sum {α : Type*} [MeasurableSpace α] (μ : ℕ → MeasureTheory.Measure α)
    (h : ∀ n, MeasureTheory.IsFiniteMeasure (μ n)) :
    IsSFinite (MeasureTheory.Measure.sum μ)

-- Finite measures are s-finite:
axiom isFinite_isSFinite {α : Type*} [MeasurableSpace α] (μ : MeasureTheory.Measure α)
    [MeasureTheory.IsFiniteMeasure μ] : IsSFinite μ

-- ── Coproduct measure ──────────────────────────────────────────────────────────
-- AFP: `coproduct_measure {μᵢ}` on `∐ᵢ Mᵢ = Σ i : I, α i`
-- BINDER RULE B26: μ is indexed family, never collapsed.
-- Domain type: Σ i : I, α i  (Lean 4 Sigma type — dependent sum)

noncomputable axiom coprodMeasure {I : Type*} {α : I → Type*} [∀ i, MeasurableSpace (α i)]
    (μ : ∀ i : I, MeasureTheory.Measure (α i)) :
    MeasureTheory.Measure (Σ i : I, α i)

-- ── Key property: injection measurability ──────────────────────────────────────
-- AFP: The injection (λx. (i, x)) is measurable w.r.t. coproduct σ-algebra.
-- In Lean 4: Sigma.mk i : α i → Σ j : I, α j
-- BINDER RULE B28: use Sigma.mk, NOT Sum.inl or Sum.inr.

axiom coprodMeasure_injection_measurable {I : Type*} {α : I → Type*}
    [∀ i, MeasurableSpace (α i)]
    (μ : ∀ i : I, MeasureTheory.Measure (α i)) (i : I) :
    Measurable (Sigma.mk i : α i → Σ j : I, α j)

-- ── Injection measure property ─────────────────────────────────────────────────
-- AFP core: (∐μ)(injection_i A) = μᵢ(A) for measurable A
axiom coprodMeasure_injection_eq {I : Type*} {α : I → Type*}
    [∀ i, MeasurableSpace (α i)]
    (μ : ∀ i : I, MeasureTheory.Measure (α i)) (i : I)
    (A : Set (α i)) (hA : MeasurableSet A) :
    coprodMeasure μ (Sigma.mk i '' A) = μ i A

-- ── s-finiteness of coproduct ─────────────────────────────────────────────────
axiom coprodMeasure_sfin {I : Type*} {α : I → Type*}
    [∀ i, MeasurableSpace (α i)]
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (h : ∀ i : I, IsSFinite (μ i)) :
    IsSFinite (coprodMeasure μ)

-- ── Measurability via coproduct (universal property) ─────────────────────────
-- AFP: f : Σ i, α i → N measurable ↔ ∀ i, Measurable (f ∘ Sigma.mk i)
axiom coprodMeasure_measurable_iff {I : Type*} {α : I → Type*} {N : Type*}
    [∀ i, MeasurableSpace (α i)] [MeasurableSpace N]
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (f : (Σ i : I, α i) → N) :
    Measurable f ↔ ∀ i : I, Measurable (fun x => f ⟨i, x⟩)

end CATEPTMain.Analysis.CPM
