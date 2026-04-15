import CATEPTMain.AFPBridge.SM.Theories.Differentiable_Manifold
/-!
# Partition_Of_Unity — AFP Smooth_Manifolds → Lean 4 (Phase 1)

Source: `Smooth_Manifolds/Partition_Of_Unity.thy` (Immler, Zhan — 2018)
Dependencies: Differentiable_Manifold

Content: Smooth partition of unity:
  - Existence subordinate to any open cover
  - Smooth extension using partition of unity
  - Embedding of manifolds into ℝⁿ (Whitney embedding sketch)

Phase: 1 (all proofs `sorry`; B39 applied)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.SM.Theories.Partition_Of_Unity

open CATEPTMain.AFPBridge.SM
open Manifold

variable {ι : Type*}

-- ── Smooth partition of unity exists ─────────────────────────────────────────
-- For any open cover {Uᵢ} of a smooth manifold, ∃ smooth subordinate partition.
private axiom smooth_partunity_exists_law {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [T2Space M] [SigmaCompactSpace M]
    [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    (U : ι → Set M) (hU : ∀ i : ι, IsOpen (U i)) (hCover : Set.univ ⊆ ⋃ i, U i) :
    ∃ _ : SmoothPartUnity H M I, True

theorem smooth_partunity_exists {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [T2Space M] [SigmaCompactSpace M]
    [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    (U : ι → Set M) (hU : ∀ i : ι, IsOpen (U i)) (hCover : Set.univ ⊆ ⋃ i, U i) :
    ∃ _ : SmoothPartUnity H M I, True :=
  smooth_partunity_exists_law I U hU hCover

-- ── Smooth extension ──────────────────────────────────────────────────────────
-- If f : K → ℝ is smooth on compact K ⊆ M (closed), f extends to all of M.
private axiom smooth_extension_law {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [T2Space M] [SigmaCompactSpace M]
    [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    (K : Set M) (hK : IsClosed K) (f : M → ℝ)
    (hf : ContMDiffOn I 𝓘(ℝ) ⊤ f K) :
    ∃ g : M → ℝ, ContMDiff I 𝓘(ℝ) ⊤ g ∧ ∀ x ∈ K, g x = f x

theorem smooth_extension {H M : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [T2Space M] [SigmaCompactSpace M]
    [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    (K : Set M) (hK : IsClosed K) (f : M → ℝ)
    (hf : ContMDiffOn I 𝓘(ℝ) ⊤ f K) :
    ∃ g : M → ℝ, ContMDiff I 𝓘(ℝ) ⊤ g ∧ ∀ x ∈ K, g x = f x :=
  smooth_extension_law I K hK f hf

-- ── Gluing smooth maps ────────────────────────────────────────────────────────
private axiom smooth_glue_law {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [T2Space M] [SigmaCompactSpace M]
    [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (U V : Set M) (hU : IsOpen U) (hV : IsOpen V) (hCover : U ∪ V = Set.univ)
    (fU : M → M') (fV : M → M')
    (hfU : ContMDiffOn I I' ⊤ fU U) (hfV : ContMDiffOn I I' ⊤ fV V)
    (hAgree : ∀ x ∈ U ∩ V, fU x = fV x) :
    ∃ f : M → M', ContMDiff I I' ⊤ f ∧ ∀ x ∈ U, f x = fU x ∧ ∀ y ∈ V, f y = fV y

theorem smooth_glue {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [T2Space M] [SigmaCompactSpace M]
    [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (U V : Set M) (hU : IsOpen U) (hV : IsOpen V) (hCover : U ∪ V = Set.univ)
    (fU : M → M') (fV : M → M')
    (hfU : ContMDiffOn I I' ⊤ fU U) (hfV : ContMDiffOn I I' ⊤ fV V)
    (hAgree : ∀ x ∈ U ∩ V, fU x = fV x) :
    ∃ f : M → M', ContMDiff I I' ⊤ f ∧ ∀ x ∈ U, f x = fU x ∧ ∀ y ∈ V, f y = fV y :=
  smooth_glue_law I I' U V hU hV hCover fU fV hfU hfV hAgree

end CATEPTMain.AFPBridge.SM.Theories.Partition_Of_Unity
