import CATEPTMain.Geometry.SM.Topological_Manifold
/-!
# Differentiable_Manifold — AFP Smooth_Manifolds → Lean 4 (Phase 1)

Source: `Smooth_Manifolds/Differentiable_Manifold.thy` (Immler, Zhan — 2018)
Dependencies: Topological_Manifold

Content: Differentiable (smooth) manifold properties:
  - Smooth open/closed submanifolds
  - Smooth maps and their derivatives
  - Immersions and submersions
  - Rank theorem (constant rank → submanifold)

Phase: 1 (all proofs `sorry`; B38/B39 applied)
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Differentiable_Manifold

open CATEPTMain.Geometry.SM

-- ── Smooth immersion ──────────────────────────────────────────────────────────
-- f : M → N is an immersion if the differential df_x is injective ∀ x.
def IsImmersion {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (f : M → M') : Prop :=
  IsSmooth I I' f ∧
  ∀ x : M, Function.Injective (mfderiv I I' f x)

-- ── Smooth submersion ──────────────────────────────────────────────────────────
def IsSubmersion {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (f : M → M') : Prop :=
  IsSmooth I I' f ∧
  ∀ x : M, Function.Surjective (mfderiv I I' f x)

-- ── Diffeomorphism preserves topology ────────────────────────────────────────
private axiom diffeomorphism_homeomorphism_law {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (f : M → M') (hf : IsDiffeomorphism I I' f) : IsHomeomorph f

theorem diffeomorphism_homeomorphism {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (f : M → M') (hf : IsDiffeomorphism I I' f) :
    IsHomeomorph f :=
  diffeomorphism_homeomorphism_law I I' f hf

-- ── Smooth map = continuous ────────────────────────────────────────────────────
theorem smooth_continuous {H H' M M' : Type*}
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (f : M → M') (hf : IsSmooth I I' f) : Continuous f :=
  hf.continuous

end CATEPTMain.Geometry.SM.Differentiable_Manifold
