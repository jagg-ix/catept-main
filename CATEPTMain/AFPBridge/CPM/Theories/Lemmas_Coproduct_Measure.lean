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

theorem sigma_injections_disjoint {I : Type} {α : I → Type} (i j : I) (h : i ≠ j) :
    Disjoint (Set.range (Sigma.mk i : α i → Σ k : I, α k))
             (Set.range (Sigma.mk j : α j → Σ k : I, α k)) := by
  sorry -- phase2_exact: Set.disjoint_range_sigma of distinct indices

-- ── Sigma-finite implies s-finite ─────────────────────────────────────────────
theorem sigmaFinite_isSFinite {α : Type} (μ : MeasureTheory.Measure α)
    [MeasureTheory.SigmaFinite μ] : IsSFinite μ := by
  sorry -- phase2_exact: SigmaFinite → countable sum of finite measures

-- ── Measurability of indicator on Sigma type ─────────────────────────────────
-- For i : I and measurable A ⊆ α i, the indicator of (Sigma.mk i '' A) is measurable.
theorem indicator_sigma_measurable {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (i : I) (A : Set (α i)) (hA : @MeasureTheory.MeasurableSet (α i) (m i) A) :
    @MeasureTheory.MeasurableSet (Σ j : I, α j) inferInstance (Sigma.mk i '' A) := by
  sorry -- phase2_exact: MeasurableSet.image of measurable injection

-- ── s-finite measure sum characterization ────────────────────────────────────
-- AFP: μ is s-finite iff there exist finite measures μₙ with μ = ∑ₙ μₙ.
theorem isSFinite_iff {α : Type} (μ : MeasureTheory.Measure α) :
    IsSFinite μ ↔
    ∃ (μs : ℕ → MeasureTheory.Measure α),
    (∀ n, MeasureTheory.IsFiniteMeasure (μs n)) ∧
    μ = MeasureTheory.Measure.sum μs := by
  sorry -- phase2_exact: by definition of IsSFinite

-- ── Coproduct σ-algebra is the least making injections measurable ─────────────
-- AFP: The sigma-algebra on Σ i : I, α i is the smallest making all Sigma.mk i measurable.
-- In Lean 4, the MeasurableSpace instance on Σ is defined this way.
theorem coprod_sigma_algebra_minimal {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (m' : MeasureTheory.MeasurableSpace (Σ i : I, α i))
    (hm' : ∀ i : I, @MeasureTheory.Measurable (α i) _ (m i) m' (Sigma.mk i)) :
    ∀ A : Set (Σ i : I, α i),
    @MeasureTheory.MeasurableSet _ inferInstance A →
    @MeasureTheory.MeasurableSet _ m' A := by
  sorry -- phase2_exact: universal property of generated sigma-algebra

-- ── Measurable section: preimage under injection ──────────────────────────────
-- For measurable B ⊆ Σ i : I, α i, the section {x | Sigma.mk i x ∈ B} is measurable.
theorem sigma_section_measurable {I : Type} {α : I → Type}
    (m : ∀ i : I, MeasureTheory.MeasurableSpace (α i))
    (i : I) (B : Set (Σ j : I, α j))
    (hB : @MeasureTheory.MeasurableSet _ inferInstance B) :
    @MeasureTheory.MeasurableSet (α i) (m i) {x | (⟨i, x⟩ : Σ j : I, α j) ∈ B} := by
  sorry -- phase2_exact: MeasurableSet.preimage of injection

end CATEPTMain.AFPBridge.CPM.Theories.Lemmas_Coproduct_Measure
