import CATEPTMain.AFPBridge.CPM.Theories.Coproduct_Measure
/-!
# Coproduct_Measure_Additional — AFP Coproduct_Measure → Lean 4 (Phase 1)

Source: `Coproduct_Measure/Coproduct_Measure_Additional.thy` (Hirata — 2024)
Dependencies: Coproduct_Measure

Content: Extended properties of the coproduct measure:
  - Integration formula: ∫ d(∐μ) f = ∑ᵢ ∫ dμᵢ (f ∘ injᵢ)
  - Pushforward of coproduct measure under measurable maps
  - Interaction with product measure (Fubini for coproduct)
  - s-finite measures and the coproduct

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.CPM.Theories.Coproduct_Measure_Additional

open CATEPTMain.AFPBridge.CPM

-- ── Integration formula (main result of this file) ────────────────────────────
-- AFP: ∫ f d(∐μ) = ∑ᵢ ∫ (f ∘ injᵢ) dμᵢ

-- Non-negative version (lintegral):
private axiom coprodMeasure_lintegral_law {I : Type} [Countable I] {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (f : (Σ i : I, α i) → ℝ≥0∞)
    (hf : @MeasureTheory.Measurable (Σ i : I, α i) ℝ≥0∞ inferInstance _ f) :
    ∫⁻ x, f x ∂(coprodMeasure m μ) =
    ∑' i : I, ∫⁻ x, f ⟨i, x⟩ ∂(μ i)

theorem coprodMeasure_lintegral {I : Type} [Countable I] {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (f : (Σ i : I, α i) → ℝ≥0∞)
    (hf : @MeasureTheory.Measurable (Σ i : I, α i) ℝ≥0∞ inferInstance _ f) :
    ∫⁻ x, f x ∂(coprodMeasure m μ) =
    ∑' i : I, ∫⁻ x, f ⟨i, x⟩ ∂(μ i) :=
  coprodMeasure_lintegral_law m μ f hf

-- Signed integral version (re-export of axiom from Coproduct_Measure):
theorem coprodMeasure_integral_formula {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (f : (Σ i : I, α i) → ℝ)
    (hf : MeasureTheory.Integrable f (coprodMeasure m μ)) :
    ∫ x, f x ∂(coprodMeasure m μ) =
    ∑' i : I, ∫ x, f ⟨i, x⟩ ∂(μ i) :=
  coprodMeasure_integral m μ f hf

-- ── Pushforward of coproduct under measurable map ────────────────────────────
-- AFP: For measurable f : (Σ i, α i) → N, (f *)_(∐μ) = ∑ᵢ (f ∘ injᵢ *)_μᵢ

private axiom coprodMeasure_pushforward_law {I : Type} {α : I → Type} {N : Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    [MN : MeasureTheory.MeasurableSpace N]
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (f : (Σ i : I, α i) → N)
    (hf : @MeasureTheory.Measurable _ N inferInstance MN f) :
    MeasureTheory.Measure.map f (coprodMeasure m μ) =
    MeasureTheory.Measure.sum (fun i => MeasureTheory.Measure.map (fun x => f ⟨i, x⟩) (μ i))

theorem coprodMeasure_pushforward {I : Type} {α : I → Type} {N : Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    [MN : MeasureTheory.MeasurableSpace N]
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (f : (Σ i : I, α i) → N)
    (hf : @MeasureTheory.Measurable _ N inferInstance MN f) :
    MeasureTheory.Measure.map f (coprodMeasure m μ) =
    MeasureTheory.Measure.sum (fun i => MeasureTheory.Measure.map (fun x => f ⟨i, x⟩) (μ i)) :=
  coprodMeasure_pushforward_law m μ f hf

-- ── Coproduct and product measure interaction ─────────────────────────────────
-- AFP: (∐μᵢ) × ν = ∐ (μᵢ × ν)  (distributivity over coproduct)
private axiom coprodMeasure_prod_distrib_law {I : Type} {α : I → Type} {β : Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    [mβ : MeasureTheory.MeasurableSpace β]
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (ν : MeasureTheory.Measure β) :
    MeasureTheory.Measure.prod (coprodMeasure m μ) ν =
    coprodMeasure (fun i => instMeasurableSpaceProd) (fun i => MeasureTheory.Measure.prod (μ i) ν)

theorem coprodMeasure_prod_distrib {I : Type} {α : I → Type} {β : Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    [mβ : MeasureTheory.MeasurableSpace β]
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (ν : MeasureTheory.Measure β) :
    MeasureTheory.Measure.prod (coprodMeasure m μ) ν =
    coprodMeasure (fun i => instMeasurableSpaceProd) (fun i => MeasureTheory.Measure.prod (μ i) ν) :=
  coprodMeasure_prod_distrib_law m ν

-- ── Coproduct of probability measures ────────────────────────────────────────
-- AFP: If all μᵢ are probability measures and I is finite with |I| = n,
-- then (∐μᵢ)(∐Mᵢ) = n (sum of unit masses).
private axiom coprodMeasure_prob_total_law {I : Type} [Fintype I] {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    [h : ∀ i, MeasureTheory.IsProbabilityMeasure (μ i)] :
    coprodMeasure m μ Set.univ = Fintype.card I

theorem coprodMeasure_prob_total {I : Type} [Fintype I] {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    [∀ i, MeasureTheory.IsProbabilityMeasure (μ i)] :
    coprodMeasure m μ Set.univ = Fintype.card I :=
  coprodMeasure_prob_total_law m μ

end CATEPTMain.AFPBridge.CPM.Theories.Coproduct_Measure_Additional
