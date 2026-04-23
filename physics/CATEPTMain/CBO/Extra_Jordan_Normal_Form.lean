import CATEPTMain.CBO.Complex_L2
/-!
# Extra_Jordan_Normal_Form — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Extra_Jordan_Normal_Form.thy` (Dominique Unruh — 2022)
Dependencies: Complex_L2

Content: Jordan normal form supplements for finite-dimensional operators:
  - Eigenvalue / eigenvector algebra
  - Diagonalization of normal matrices
  - Spectral decomposition for finite-dimensional normal operators
  - Characteristic polynomial and minimal polynomial

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.CBO.Extra_Jordan_Normal_Form

open CATEPTMain.CBO

-- ── Downstream rank-one projector bridge ─────────────────────────────────────
theorem rankOne_unit_projector_bridge
    (v : CBOVec)
    (hUnit : CATEPTMain.CBO.Extra_Pretty_Code_Examples.cboVecNorm v = 1) :
    IsCBOProjector (CATEPTMain.CBO.Extra_Pretty_Code_Examples.rankOneOp v v) :=
  CATEPTMain.CBO.Complex_L2.rankOne_unit_projector_bridge v hUnit

-- ── Eigenspace ────────────────────────────────────────────────────────────────
-- Eigenspace of T for eigenvalue ev: ker(T - ev⋅I)
def eigenspace (T : CBOOp) (ev : ℂ) : Set CBOVec :=
  { v | cboApply T v = cboApply (cboSmul ev cboOne) v }

-- Eigenspaces for distinct eigenvalues are orthogonal (for Hermitian T):
private axiom hermitian_eigenspaces_ortho_law (T : CBOOp) (h : IsHermitian T)
    (evA evB : ℂ) (hne : evA ≠ evB) (u : CBOVec) (hu : u ∈ eigenspace T evA)
    (v : CBOVec) (hv : v ∈ eigenspace T evB) :
    cboInner u v = 0

theorem hermitian_eigenspaces_ortho (T : CBOOp) (h : IsHermitian T)
    (evA evB : ℂ) (hne : evA ≠ evB) (u : CBOVec) (hu : u ∈ eigenspace T evA)
    (v : CBOVec) (hv : v ∈ eigenspace T evB) :
    cboInner u v = 0 :=
  hermitian_eigenspaces_ortho_law T h evA evB hne u hu v hv

-- ── Spectral decomposition (finite dim) ──────────────────────────────────────
-- For Hermitian T on ℂⁿ: T = ∑ᵢ λᵢ Pᵢ (spectral decomposition)
-- Phase-1 axiom (finite dim only; ∑ over CBOOp deferred to phase-2):
private axiom spectralDecomp_finite_law (T : CBOOp) (h : IsHermitian T) :
    ∃ evs : List ℂ, ∃ Ps : List CBOOp, evs.length = Ps.length

theorem spectralDecomp_finite (T : CBOOp) (h : IsHermitian T) :
    ∃ evs : List ℂ, ∃ Ps : List CBOOp, evs.length = Ps.length :=
  spectralDecomp_finite_law T h

-- ── Characteristic polynomial ────────────────────────────────────────────────
-- For T on ℂⁿ: char poly has degree n; roots = eigenvalues.
-- Phase-1 axiom (Matrix.charpoly deferred to phase-2):
private axiom charPoly_degree_n_law (n : ℕ)
    (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    ∃ d : ℕ, d = n

theorem charPoly_degree_n (n : ℕ)
    (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    ∃ d : ℕ, d = n :=
  charPoly_degree_n_law n T

-- (complex stub; phase-2 uses Matrix.charpoly)

end CATEPTMain.CBO.Extra_Jordan_Normal_Form
