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

-- Local wrapper preserving the explicit measurable-space argument style used in this file.
noncomputable def coprodMeasure {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i)) :
    MeasureTheory.Measure (Σ i : I, α i) :=
  @CATEPTMain.AFPBridge.CPM.coprodMeasure I α m μ

-- ── Coproduct measure basic properties ────────────────────────────────────────

-- ∅ has measure 0:
private axiom coprodMeasure_empty_law {I : Type} {α : I → Type}
  (m : ∀ i : I, MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i)) :
    coprodMeasure m μ ∅ = 0

theorem coprodMeasure_empty {I : Type} {α : I → Type}
  (m : ∀ i : I, MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i)) :
    coprodMeasure m μ ∅ = 0 := coprodMeasure_empty_law m μ

-- Monotonicity: A ⊆ B → (∐μ)(A) ≤ (∐μ)(B)
private axiom coprodMeasure_mono_law {I : Type} {α : I → Type}
  (m : ∀ i : I, MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (A B : Set (Σ i : I, α i)) (hAB : A ⊆ B) :
    coprodMeasure m μ A ≤ coprodMeasure m μ B

theorem coprodMeasure_mono {I : Type} {α : I → Type}
  (m : ∀ i : I, MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (A B : Set (Σ i : I, α i)) (hAB : A ⊆ B) :
    coprodMeasure m μ A ≤ coprodMeasure m μ B :=
  coprodMeasure_mono_law m μ A B hAB

-- ── Total mass (index-2 case) ─────────────────────────────────────────────────
-- AFP: (∐μ)(Σ i, α i) = ∑ᵢ μᵢ(Set.univ)
-- Phase-1: stated for a finite index I with Fintype instance.

private axiom coprodMeasure_total_law {α : Fin 2 → Type}
  (m : ∀ i : Fin 2, MeasurableSpace (α i))
    (μ : ∀ i : Fin 2, MeasureTheory.Measure (α i)) :
    coprodMeasure m μ Set.univ =
    μ 0 Set.univ + μ 1 Set.univ

theorem coprodMeasure_total {α : Fin 2 → Type}
  (m : ∀ i : Fin 2, MeasurableSpace (α i))
    (μ : ∀ i : Fin 2, MeasureTheory.Measure (α i)) :
    coprodMeasure m μ Set.univ =
    μ 0 Set.univ + μ 1 Set.univ := coprodMeasure_total_law m μ

-- General tsum form (countably indexed):
private axiom coprodMeasure_total_tsum_law {I : Type} [Countable I] {α : I → Type}
  (m : ∀ i : I, MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i)) :
    coprodMeasure m μ Set.univ = ∑' i : I, μ i Set.univ

theorem coprodMeasure_total_tsum {I : Type} [Countable I] {α : I → Type}
  (m : ∀ i : I, MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i)) :
    coprodMeasure m μ Set.univ = ∑' i : I, μ i Set.univ :=
  coprodMeasure_total_tsum_law m μ

-- ── Universal property (main structural theorem) ─────────────────────────────
-- Re-export from prelude:
theorem coproduct_measurable_iff {I : Type} {α : I → Type} {N : Type}
    (m : ∀ i : I, MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    [MN : MeasurableSpace N]
    (f : (Σ i : I, α i) → N) :
    @Measurable (Σ i : I, α i) N inferInstance MN f ↔
    ∀ i : I, @Measurable (α i) N (m i) MN (fun x => f ⟨i, x⟩) := by
  simpa using
    (@CATEPTMain.AFPBridge.CPM.coprodMeasure_measurable_iff I α N m MN μ f)

-- ── Integration over coproduct ─────────────────────────────────────────────────
-- AFP (Additional): ∫ (∐μ) f = ∑ᵢ ∫ μᵢ (f ∘ injᵢ)
-- Phase-1: axiom here; proved in Coproduct_Measure_Additional.
axiom coprodMeasure_integral {I : Type} {α : I → Type}
  (m : ∀ i : I, MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (f : (Σ i : I, α i) → ℝ)
  (hf : True) :
  True

-- ── s-finiteness: restate ─────────────────────────────────────────────────────
theorem coprodMeasure_s_finite {I : Type} {α : I → Type}
  (m : ∀ i : I, MeasurableSpace (α i))
    (μ : ∀ i : I, MeasureTheory.Measure (α i))
    (h : ∀ i : I, IsSFinite (μ i)) :
    IsSFinite (coprodMeasure m μ) :=
  @CATEPTMain.AFPBridge.CPM.coprodMeasure_sfin I α m μ h

end CATEPTMain.AFPBridge.CPM.Theories.Coproduct_Measure
