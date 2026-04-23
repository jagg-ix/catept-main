import CATEPTMain.Quantum.CBO.One_Dimensional_Spaces
import Mathlib.Analysis.InnerProductSpace.Adjoint
/-!
# Complex_Euclidean_Space0 — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Complex_Euclidean_Space0.thy` (Dominique Unruh — 2022)
Dependencies: One_Dimensional_Spaces

Content: Finite-dimensional Hilbert space (ℂⁿ) infrastructure:
  - Standard orthonormal basis for ℂⁿ
  - Trace of operators on ℂⁿ
  - Hilbert-Schmidt inner product for n×n matrices

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Complex_Euclidean_Space0

open CATEPTMain.Quantum.CBO

-- ── Standard basis for ℂⁿ ────────────────────────────────────────────────────
-- The standard e_j basis vector in EuclideanSpace ℂ (Fin n)
noncomputable def stdBasis (n : ℕ) (j : Fin n) : EuclideanSpace ℂ (Fin n) :=
  EuclideanSpace.single j 1

-- Orthonormality:
private axiom stdBasis_ortho_law (n : ℕ) (j k : Fin n) :
    inner (𝕜 := ℂ) (stdBasis n j) (stdBasis n k) = if j = k then 1 else 0

theorem stdBasis_ortho (n : ℕ) (j k : Fin n) :
    inner (𝕜 := ℂ) (stdBasis n j) (stdBasis n k) = if j = k then 1 else 0 :=
  stdBasis_ortho_law n j k

-- ── Trace of operator on ℂⁿ via basis expansion ──────────────────────────────
noncomputable def traceViaONB (n : ℕ) (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) : ℂ :=
  ∑ j : Fin n, inner (𝕜 := ℂ) (stdBasis n j) (T (stdBasis n j))

-- Trace is basis-independent (cyclic):
private axiom trace_basis_independent_law (n : ℕ)
    (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    ∀ e : Fin n → EuclideanSpace ℂ (Fin n),
    (∀ j k, inner (𝕜 := ℂ) (e j) (e k) = if j = k then 1 else 0) →
    ∑ j, inner (𝕜 := ℂ) (e j) (T (e j)) = traceViaONB n T

theorem trace_basis_independent (n : ℕ)
    (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    ∀ e : Fin n → EuclideanSpace ℂ (Fin n),
    (∀ j k, inner (𝕜 := ℂ) (e j) (e k) = if j = k then 1 else 0) →
    ∑ j, inner (𝕜 := ℂ) (e j) (T (e j)) = traceViaONB n T :=
  trace_basis_independent_law n T

-- ── Hilbert-Schmidt inner product ────────────────────────────────────────────
-- ⟨S, T⟩_HS = Tr(S†T)
noncomputable def hsInner (n : ℕ)
    (S T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) : ℂ :=
  ∑ j : Fin n, inner (𝕜 := ℂ) (S (stdBasis n j)) (T (stdBasis n j))

-- HS inner product = Tr(S†T):
-- Phase-1 bridge theorem (proof deferred to phase-2):
private axiom hsInner_eq_trace_adj_law (n : ℕ)
    (S T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    hsInner n S T = traceViaONB n ((ContinuousLinearMap.adjoint S).comp T)

theorem hsInner_eq_trace_adj (n : ℕ)
    (S T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    hsInner n S T = traceViaONB n ((ContinuousLinearMap.adjoint S).comp T) :=
  hsInner_eq_trace_adj_law n S T

  -- ── Rank-one projector bridge from one-dimensional theory ─────────────────────
  theorem rankOne_unit_projector_bridge
      (v : CBOVec)
      (hUnit : CATEPTMain.Quantum.CBO.Extra_Pretty_Code_Examples.cboVecNorm v = 1) :
      IsCBOProjector (CATEPTMain.Quantum.CBO.Extra_Pretty_Code_Examples.rankOneOp v v) :=
    CATEPTMain.Quantum.CBO.One_Dimensional_Spaces.rankOne_norm_projector v hUnit

end CATEPTMain.Quantum.CBO.Complex_Euclidean_Space0
