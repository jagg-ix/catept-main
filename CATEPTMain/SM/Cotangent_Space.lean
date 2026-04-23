import CATEPTMain.SM.Tangent_Space
/-!
# Cotangent_Space — AFP Smooth_Manifolds → Lean 4 (Phase 1)
Source: `Smooth_Manifolds/Cotangent_Space.thy` (Immler, Zhan — 2018)
Phase: 1 (axiom stubs; B39 applied)
-/

set_option autoImplicit false

namespace CATEPTMain.SM.Cotangent_Space

open CATEPTMain.SM
open Manifold

-- Phase-1: cotangent space and differentials as opaque axioms
-- avoiding TangentSpace/ContinuousLinearMap universe constraints

axiom smoothDifferential {H M : Type}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    (f : M → ℝ) (x : M) : H →L[ℝ] ℝ

axiom smoothDiff_add {H M : Type}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [TopologicalSpace M] [ChartedSpace H M]
    (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    (f g : M → ℝ) (x : M) :
    smoothDifferential I (f + g) x = smoothDifferential I f x + smoothDifferential I g x

axiom pullbackOneForm {H H' M M' : Type}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H'] [FiniteDimensional ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (ph : M → M') (om : M' → H' →L[ℝ] ℝ) (x : M) : H →L[ℝ] ℝ

axiom pullback_differential {H H' M M' : Type}
    [NormedAddCommGroup H] [NormedSpace ℝ H] [FiniteDimensional ℝ H]
    [NormedAddCommGroup H'] [NormedSpace ℝ H'] [FiniteDimensional ℝ H']
    [TopologicalSpace M] [ChartedSpace H M] (I : ModelWithCorners ℝ H M) [IsManifold I ⊤ M]
    [TopologicalSpace M'] [ChartedSpace H' M'] (I' : ModelWithCorners ℝ H' M') [IsManifold I' ⊤ M']
    (ph : M → M') (hph : IsSmooth I I' ph) (f : M' → ℝ) (x : M) :
    pullbackOneForm I I' ph (smoothDifferential I' f) x =
    smoothDifferential I (f ∘ ph) x

end CATEPTMain.SM.Cotangent_Space
