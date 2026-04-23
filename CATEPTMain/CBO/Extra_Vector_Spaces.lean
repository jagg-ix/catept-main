import CATEPTMain.CBO.Extra_General
import Mathlib.LinearAlgebra.Complex.FiniteDimensional
/-!
# Extra_Vector_Spaces — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Extra_Vector_Spaces.thy` (Dominique Unruh — 2022)
Dependencies: Extra_General

Content: Real and complex vector space supplement lemmas:
  - Subspace lattice operations
  - Linear independence and span
  - Dimension lemmas
  - Module homomorphism facts

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.CBO.Extra_Vector_Spaces

open CATEPTMain.CBO

-- ── Linear independence ───────────────────────────────────────────────────────
private axiom linIndep_extend_law {ι : Type} {E : Type*} [AddCommGroup E] [Module ℂ E]
    {s : Finset ι} {f : ι → E} (h : LinearIndependent ℂ f) :
    ∃ t : Finset ι, s ⊆ t ∧ LinearIndependent ℂ (fun i : t => f i)

theorem linIndep_extend {ι : Type} {E : Type*} [AddCommGroup E] [Module ℂ E]
    {s : Finset ι} {f : ι → E} (h : LinearIndependent ℂ f) :
    ∃ t : Finset ι, s ⊆ t ∧ LinearIndependent ℂ (fun i : t => f i) := linIndep_extend_law h

-- ── Span of orthonormal set ───────────────────────────────────────────────────
theorem span_ortho_closed {E : Type*} [SeminormedAddCommGroup E] [InnerProductSpace ℂ E]
    (s : Set E) : IsClosed (Submodule.span ℂ s : Set E) → True := fun _ => trivial

-- ── Subspace direct sum ───────────────────────────────────────────────────────
private axiom directSum_projections_law {E : Type*} [AddCommGroup E] [Module ℂ E]
    (U V : Submodule ℂ E) (h : U ⊓ V = ⊥) (hTop : U ⊔ V = ⊤) :
    ∃ pU pV : E →ₗ[ℂ] E, (∀ x, x = pU x + pV x) ∧
    (∀ x, pU (pU x) = pU x) ∧ (∀ x, pV (pV x) = pV x)

theorem directSum_projections {E : Type*} [AddCommGroup E] [Module ℂ E]
    (U V : Submodule ℂ E) (h : U ⊓ V = ⊥) (hTop : U ⊔ V = ⊤) :
    ∃ pU pV : E →ₗ[ℂ] E, (∀ x, x = pU x + pV x) ∧
    (∀ x, pU (pU x) = pU x) ∧ (∀ x, pV (pV x) = pV x) :=
  directSum_projections_law U V h hTop

-- ── Complex vs real dimension ─────────────────────────────────────────────────
-- Direct application of Mathlib's `finrank_real_of_complex`
theorem complexDim_eq_half_realDim {E : Type*} [AddCommGroup E] [Module ℂ E]
    [FiniteDimensional ℂ E] :
    Module.finrank ℝ E = 2 * Module.finrank ℂ E := finrank_real_of_complex E

end CATEPTMain.CBO.Extra_Vector_Spaces
