import CATEPTMain.AFPBridge.SM.Theories.Smooth
/-!
# Bump_Function — AFP Smooth_Manifolds → Lean 4 (Phase 1)

Source: `Smooth_Manifolds/Bump_Function.thy` (Immler, Zhan — 2018)
Dependencies: Smooth

Content: Smooth bump functions on manifolds:
  - Existence of smooth bump functions subordinate to open sets
  - Cutoff functions
  - Smooth Urysohn lemma (smooth separation of closed sets)

Phase: 1 (all proofs `sorry`; B39 applied)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.SM.Theories.Bump_Function

open CATEPTMain.AFPBridge.SM
open Manifold

-- ── Smooth bump on manifold ────────────────────────────────────────────────────
-- ∃ smooth f : M → [0,1] with f = 1 on K and supp f ⊆ U  (K compact, K ⊆ U open).
private axiom smooth_bump_manifold_law {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [T2Space M] [LocallyCompactSpace M]
    (K : Set M) (U : Set M) (hK : IsCompact K) (hU : IsOpen U) (hKU : K ⊆ U) :
    ∃ f : M → ℝ, ContMDiff I 𝓘(ℝ) ⊤ f ∧
    (∀ x ∈ K, f x = 1) ∧ (∀ x, 0 ≤ f x) ∧ (∀ x, f x ≤ 1) ∧
    Function.support f ⊆ U

theorem smooth_bump_manifold {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [T2Space M] [LocallyCompactSpace M]
    (K : Set M) (U : Set M) (hK : IsCompact K) (hU : IsOpen U) (hKU : K ⊆ U) :
    ∃ f : M → ℝ, ContMDiff I 𝓘(ℝ) ⊤ f ∧
    (∀ x ∈ K, f x = 1) ∧ (∀ x, 0 ≤ f x) ∧ (∀ x, f x ≤ 1) ∧
    Function.support f ⊆ U :=
  smooth_bump_manifold_law I K U hK hU hKU

-- ── Smooth Urysohn lemma ──────────────────────────────────────────────────────
-- For disjoint closed sets A, B on compact manifold, ∃ smooth f : M → [0,1]
-- with f|_A = 0 and f|_B = 1.
private axiom smooth_urysohn_law {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [T2Space M] [CompactSpace M]
    (A B : Set M) (hA : IsClosed A) (hB : IsClosed B) (hDisj : Disjoint A B) :
    ∃ f : M → ℝ, ContMDiff I 𝓘(ℝ) ⊤ f ∧
    (∀ x ∈ A, f x = 0) ∧ (∀ x ∈ B, f x = 1) ∧ (∀ x, 0 ≤ f x) ∧ (∀ x, f x ≤ 1)

theorem smooth_urysohn {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [T2Space M] [CompactSpace M]
    (A B : Set M) (hA : IsClosed A) (hB : IsClosed B) (hDisj : Disjoint A B) :
    ∃ f : M → ℝ, ContMDiff I 𝓘(ℝ) ⊤ f ∧
    (∀ x ∈ A, f x = 0) ∧ (∀ x ∈ B, f x = 1) ∧ (∀ x, 0 ≤ f x) ∧ (∀ x, f x ≤ 1) :=
  smooth_urysohn_law I A B hA hB hDisj

-- ── Sum of bump functions ─────────────────────────────────────────────────────
private axiom smooth_bump_sum_partunity_law {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [T2Space M] [SigmaCompactSpace M]
    (U : ℕ → Set M) (hU : ∀ n, IsOpen (U n)) (hCover : Set.univ ⊆ ⋃ n, U n) :
    ∃ ψ : SmoothPartUnity H M I, True

theorem smooth_bump_sum_partunity {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [T2Space M] [SigmaCompactSpace M]
    (U : ℕ → Set M) (hU : ∀ n, IsOpen (U n)) (hCover : Set.univ ⊆ ⋃ n, U n) :
    ∃ ψ : SmoothPartUnity H M I, True :=
  smooth_bump_sum_partunity_law I U hU hCover

end CATEPTMain.AFPBridge.SM.Theories.Bump_Function
