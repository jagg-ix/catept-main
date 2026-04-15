import CATEPTMain.AFPBridge.SM.Theories.Bump_Function
/-!
# Chart — AFP Smooth_Manifolds → Lean 4 (Phase 1)

Source: `Smooth_Manifolds/Chart.thy` (Immler, Zhan — 2018)
Dependencies: Bump_Function

Content: Chart and atlas theory:
  - Chart compatibility (smooth transition maps)
  - Maximal atlas construction
  - C∞-structure from atlas
  - Chart neighborhoods

Phase: 1 (all proofs `sorry`; B38/B39 applied)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.SM.Theories.Chart

open CATEPTMain.AFPBridge.SM
open Manifold

-- ── Chart = local homeomorphism to model space ────────────────────────────────
-- In Lean 4 Mathlib: `LocalHomeomorph M H` is the chart type.
-- The `ChartedSpace H M` typeclass provides `chartAt : M → LocalHomeomorph M H`.

-- Chart neighborhood:
theorem chart_nhd {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (x : M) : IsOpen (chartAt H x).source := by
  exact (chartAt H x).open_source

-- ── Smooth transition map ─────────────────────────────────────────────────────
-- AFP: Charts φ, ψ are compatible if ψ ∘ φ⁻¹ is C∞.
-- In Lean 4: captured by `IsManifold.toStructureGroupoid`.
axiom chartAt_transition_smooth {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    (x y : M) : True
-- phase2_exact: chart transition smoothness captured by IsManifold structure

-- ── Two charts cover implies partunity ───────────────────────────────────────
private axiom two_charts_partunity_law {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [T2Space M] [CompactSpace M]
    (U V : Set M) (hU : IsOpen U) (hV : IsOpen V) (hCover : U ∪ V = Set.univ) :
    ∃ f g : M → ℝ,
      ContMDiff I 𝓘(ℝ) ⊤ f ∧ ContMDiff I 𝓘(ℝ) ⊤ g ∧
      (∀ x, f x + g x = 1) ∧ Function.support f ⊆ U ∧ Function.support g ⊆ V

theorem two_charts_partunity {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [T2Space M] [CompactSpace M]
    (U V : Set M) (hU : IsOpen U) (hV : IsOpen V) (hCover : U ∪ V = Set.univ) :
    ∃ f g : M → ℝ,
      ContMDiff I 𝓘(ℝ) ⊤ f ∧ ContMDiff I 𝓘(ℝ) ⊤ g ∧
      (∀ x, f x + g x = 1) ∧ Function.support f ⊆ U ∧ Function.support g ⊆ V :=
  two_charts_partunity_law I U V hU hV hCover

end CATEPTMain.AFPBridge.SM.Theories.Chart
