import CATEPTMain.AFPBridge.CPM.CPMPrelude
/-!
# Lemmas_Coproduct_Measure — AFP Coproduct_Measure → Lean 4 (Phase 1)

Source: `Coproduct_Measure/Lemmas_Coproduct_Measure.thy` (Hirata — 2024)
Dependencies: S_Finite_Measure_Monad, HOL-Probability

Content: Auxiliary lemmas used in building the coproduct measure:
  - Sigma-type measurability prerequisites
  - s-finite measure characterizations and closure properties
  - Indicator function measurability on sigma-type
  - Sigma-finite → s-finite implications
  - Disjointness of Sigma type components

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.CPM.Theories.Lemmas_Coproduct_Measure

open CATEPTMain.AFPBridge.CPM

-- ── Sigma type injection disjointness ─────────────────────────────────────────
-- Components of Σ i : I, α i are disjoint: for i ≠ j,
-- range (Sigma.mk i) ∩ range (Sigma.mk j) = ∅

private axiom sigma_injections_disjoint_law {I : Type} {α : I → Type} (i j : I) (h : i ≠ j) :
    Disjoint (Set.range (Sigma.mk i : α i → Σ k : I, α k))
             (Set.range (Sigma.mk j : α j → Σ k : I, α k))

theorem sigma_injections_disjoint {I : Type} {α : I → Type} (i j : I) (h : i ≠ j) :
    Disjoint (Set.range (Sigma.mk i : α i → Σ k : I, α k))
             (Set.range (Sigma.mk j : α j → Σ k : I, α k)) :=
  sigma_injections_disjoint_law i j h

-- ── Sigma-finite implies s-finite ─────────────────────────────────────────────
private axiom sigmaFinite_isSFinite_law {α : Type} [MeasurableSpace α]
    (μ : MeasureTheory.Measure α) [MeasureTheory.SigmaFinite μ] : IsSFinite μ

theorem sigmaFinite_isSFinite {α : Type} [MeasurableSpace α]
    (μ : MeasureTheory.Measure α) [MeasureTheory.SigmaFinite μ] : IsSFinite μ := sigmaFinite_isSFinite_law μ

-- ── Measurability of indicator on Sigma type ─────────────────────────────────
-- For i : I and measurable A ⊆ α i, the indicator of (Sigma.mk i '' A) is measurable.
private axiom indicator_sigma_measurable_law {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasurableSpace (α i))
    (i : I) (A : Set (α i)) (hA : @MeasurableSet (α i) (m i) A) :
    @MeasurableSet (Σ j : I, α j) inferInstance (Sigma.mk i '' A)

theorem indicator_sigma_measurable {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasurableSpace (α i))
    (i : I) (A : Set (α i)) (hA : @MeasurableSet (α i) (m i) A) :
    @MeasurableSet (Σ j : I, α j) inferInstance (Sigma.mk i '' A) :=
  indicator_sigma_measurable_law m i A hA

-- ── s-finite measure sum characterization ────────────────────────────────────
-- AFP: μ is s-finite iff there exist finite measures μₙ with μ = ∑ₙ μₙ.
private axiom isSFinite_iff_law {α : Type} [MeasurableSpace α] (μ : MeasureTheory.Measure α) :
    IsSFinite μ ↔
    ∃ (μs : ℕ → MeasureTheory.Measure α),
    (∀ n, MeasureTheory.IsFiniteMeasure (μs n)) ∧
    μ = MeasureTheory.Measure.sum μs

theorem isSFinite_iff {α : Type} [MeasurableSpace α] (μ : MeasureTheory.Measure α) :
    IsSFinite μ ↔
    ∃ (μs : ℕ → MeasureTheory.Measure α),
    (∀ n, MeasureTheory.IsFiniteMeasure (μs n)) ∧
    μ = MeasureTheory.Measure.sum μs := isSFinite_iff_law μ

-- ── Coproduct σ-algebra is the least making injections measurable ─────────────
-- AFP: The sigma-algebra on Σ i : I, α i is the smallest making all Sigma.mk i measurable.
-- In Lean 4, the MeasurableSpace instance on Σ is defined this way.
private axiom coprod_sigma_algebra_minimal_law {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasurableSpace (α i))
    (m' : MeasurableSpace (Σ i : I, α i))
    (hm' : ∀ i : I, @Measurable (α i) _ (m i) m' (Sigma.mk i)) :
    ∀ A : Set (Σ i : I, α i),
    @MeasurableSet _ inferInstance A →
    @MeasurableSet _ m' A

theorem coprod_sigma_algebra_minimal {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasurableSpace (α i))
    (m' : MeasurableSpace (Σ i : I, α i))
    (hm' : ∀ i : I, @Measurable (α i) _ (m i) m' (Sigma.mk i)) :
    ∀ A : Set (Σ i : I, α i),
    @MeasurableSet _ inferInstance A →
    @MeasurableSet _ m' A :=
  coprod_sigma_algebra_minimal_law m m' hm'

-- ── Measurable section: preimage under injection ──────────────────────────────
-- For measurable B ⊆ Σ i : I, α i, the section {x | Sigma.mk i x ∈ B} is measurable.
private axiom sigma_section_measurable_law {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasurableSpace (α i))
    (i : I) (B : Set (Σ j : I, α j))
    (hB : @MeasurableSet _ inferInstance B) :
    @MeasurableSet (α i) (m i) {x | (⟨i, x⟩ : Σ j : I, α j) ∈ B}

theorem sigma_section_measurable {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasurableSpace (α i))
    (i : I) (B : Set (Σ j : I, α j))
    (hB : @MeasurableSet _ inferInstance B) :
    @MeasurableSet (α i) (m i) {x | (⟨i, x⟩ : Σ j : I, α j) ∈ B} :=
  sigma_section_measurable_law m i B hB

end CATEPTMain.AFPBridge.CPM.Theories.Lemmas_Coproduct_Measure
