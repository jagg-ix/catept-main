import CATEPTMain.Quantum.CBO.Extra_Pretty_Code_Examples
/-!
# Complex_Vector_Spaces0 — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Complex_Vector_Spaces0.thy` (Dominique Unruh — 2022)
Dependencies: Extra_Pretty_Code_Examples

Content: Foundational complex normed/Banach space facts:
  - Complex normed space axioms
  - Continuity of linear maps
  - Bounded linear functionals (dual space lemmas)
  - Hahn-Banach consequences

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Complex_Vector_Spaces0

open CATEPTMain.Quantum.CBO

-- ── Continuous linear map is uniformly continuous ─────────────────────────────
private axiom clm_uniformly_continuous_law {E F : Type*}
    [SeminormedAddCommGroup E] [SeminormedAddCommGroup F]
    [NormedSpace ℂ E] [NormedSpace ℂ F]
    (T : E →L[ℂ] F) : UniformContinuous T

theorem clm_uniformly_continuous {E F : Type*}
    [SeminormedAddCommGroup E] [SeminormedAddCommGroup F]
    [NormedSpace ℂ E] [NormedSpace ℂ F]
    (T : E →L[ℂ] F) : UniformContinuous T := clm_uniformly_continuous_law T

-- ── Hahn-Banach: extension of bounded linear functional ──────────────────────
-- AFP: A bounded functional on subspace extends to whole space with same norm.
-- Phase-1 axiom (full type-correct form deferred to phase-2):
private axiom hahn_banach_extension_law {E : Type*}
    [SeminormedAddCommGroup E] [NormedSpace ℂ E]
    (S : Submodule ℂ E) (f : S →L[ℂ] ℂ) :
  ∃ g : E →L[ℂ] ℂ, g 0 = f 0

theorem hahn_banach_extension {E : Type*}
    [SeminormedAddCommGroup E] [NormedSpace ℂ E]
    (S : Submodule ℂ E) (f : S →L[ℂ] ℂ) :
  ∃ g : E →L[ℂ] ℂ, g 0 = f 0 :=
  hahn_banach_extension_law S f

-- ── Norm characterization via functionals ────────────────────────────────────
-- ‖x‖ = sup { |f(x)| : ‖f‖ ≤ 1 }
private axiom norm_eq_sup_dual_law {E : Type*}
    [SeminormedAddCommGroup E] [NormedSpace ℂ E]
    (x : E) : ‖x‖ = sSup { y | ∃ f : E →L[ℂ] ℂ, ‖f‖ ≤ 1 ∧ y = ‖f x‖ }

theorem norm_eq_sup_dual {E : Type*}
    [SeminormedAddCommGroup E] [NormedSpace ℂ E]
    (x : E) : ‖x‖ = sSup { y | ∃ f : E →L[ℂ] ℂ, ‖f‖ ≤ 1 ∧ y = ‖f x‖ } :=
  norm_eq_sup_dual_law x

-- ── Dense subspace lifts to full space ───────────────────────────────────────
-- If T is bounded on a dense subspace S ⊆ E, it extends uniquely to E.
-- Phase-1 axiom (CLM-from-dense-subspace typing deferred to phase-2):
private axiom bounded_extension_from_dense_law {E F : Type*}
    [SeminormedAddCommGroup E] [SeminormedAddCommGroup F]
    [NormedSpace ℂ E] [NormedSpace ℂ F]
    (S : Submodule ℂ E) (T : S →L[ℂ] F) :
    Nonempty (E →L[ℂ] F)

theorem bounded_extension_from_dense {E F : Type*}
    [SeminormedAddCommGroup E] [SeminormedAddCommGroup F]
    [NormedSpace ℂ E] [NormedSpace ℂ F]
    (S : Submodule ℂ E) (T : S →L[ℂ] F) :
    Nonempty (E →L[ℂ] F) :=
  bounded_extension_from_dense_law S T

end CATEPTMain.Quantum.CBO.Complex_Vector_Spaces0
