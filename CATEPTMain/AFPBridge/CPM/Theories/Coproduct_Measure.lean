import CATEPTMain.AFPBridge.CPM.Theories.Lemmas_Coproduct_Measure
/-!
# Coproduct_Measure — AFP → Lean 4 (Phase 1)

Source: `Coproduct_Measure/Coproduct_Measure.thy` (Hirata — 2024)
Dependencies: Lemmas_Coproduct_Measure

Content: Main coproduct measure construction and properties:
  - Coproduct measure definition (via injection images)
  - Total measure formula: (∐μ)(∐M) = ∑ᵢ μᵢ(Mᵢ)
  - Universal property: measurability via coproduct ↔ componentwise measurability
  - s-finiteness of coproduct measure

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.CPM.Theories.Coproduct_Measure

open CATEPTMain.AFPBridge.CPM

-- ── Coproduct measure basic properties ────────────────────────────────────────

-- ∅ has measure 0:
theorem coprodMeasure_empty {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i)) :
    coprodMeasure m μ ∅ = 0 := by
  sorry -- phase2_exact: MeasureTheory.Measure.empty

-- Monotonicity: A ⊆ B → (∐μ)(A) ≤ (∐μ)(B)
theorem coprodMeasure_mono {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (A B : Set (Σ i : I, α i)) (hAB : A ⊆ B) :
    coprodMeasure m μ A ≤ coprodMeasure m μ B := by
  sorry -- phase2_exact: MeasureTheory.Measure.mono

-- ── Total mass (index-2 case) ─────────────────────────────────────────────────
-- AFP: (∐μ)(Σ i, α i) = ∑ᵢ μᵢ(Set.univ)
-- Phase-1: stated for a finite index I with Fintype instance.

theorem coprodMeasure_total {α : Fin 2 → Type}
    (m : ∀ i : Fin 2, MeasureTheory.MeasurableSpace (α i))
    (μ : ∀ i : Fin 2, MeasureTheory.Measure (α i)) :
    coprodMeasure m μ Set.univ =
    μ 0 Set.univ + μ 1 Set.univ := by
  sorry -- phase2_calc: disjoint union + coprodMeasure_injection_eq

-- General tsum form (countably indexed):
theorem coprodMeasure_total_tsum {I : Type} [Countable I] {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i)) :
    coprodMeasure m μ Set.univ = ∑' i : I, μ i Set.univ := by
  sorry -- phase2_calc: application of coprodMeasure_injection_eq + tsum

-- ── Universal property (main structural theorem) ─────────────────────────────
-- Re-export from prelude:
theorem coproduct_measurable_iff {I : Type} {α : I → Type} {N : Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    [MN : MeasureTheory.MeasurableSpace N]
    (f : (Σ i : I, α i) → N) :
    @MeasureTheory.Measurable (Σ i : I, α i) N inferInstance MN f ↔
    ∀ i : I, @MeasureTheory.Measurable (α i) N (m i) MN (fun x => f ⟨i, x⟩) :=
  coprodMeasure_measurable_iff m f

-- ── Integration over coproduct ─────────────────────────────────────────────────
-- AFP (Additional): ∫ (∐μ) f = ∑ᵢ ∫ μᵢ (f ∘ injᵢ)
-- Phase-1: axiom here; proved in Coproduct_Measure_Additional.
axiom coprodMeasure_integral {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (f : (Σ i : I, α i) → ℝ)
    (hf : MeasureTheory.Integrable f (coprodMeasure m μ)) :
    ∫ x, f x ∂(coprodMeasure m μ) =
    ∑' i : I, ∫ x, f ⟨i, x⟩ ∂(μ i)

-- ── s-finiteness: restate ─────────────────────────────────────────────────────
theorem coprodMeasure_s_finite {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (h : ∀ i : I, IsSFinite (μ i)) :
    IsSFinite (coprodMeasure m μ) :=
  coprodMeasure_sfin m μ h

end CATEPTMain.AFPBridge.CPM.Theories.Coproduct_Measure
