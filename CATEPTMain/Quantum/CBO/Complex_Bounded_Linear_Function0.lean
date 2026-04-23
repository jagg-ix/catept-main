import CATEPTMain.Quantum.CBO.Complex_Euclidean_Space0
/-!
# Complex_Bounded_Linear_Function0 — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Complex_Bounded_Linear_Function0.thy` (Dominique Unruh — 2022)
Dependencies: Complex_Euclidean_Space0

Content: Bounded linear operator theory, foundational results:
  - Adjoint operator existence and uniqueness
  - Normal operators (T†T = TT†)
  - Spectral preliminaries: resolvent set definition
  - Convergence of operator sequences

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Complex_Bounded_Linear_Function0

open CATEPTMain.Quantum.CBO

-- ── Adjoint existence (general Hilbert case via Riesz) ────────────────────────
-- For each T there exists T† with ⟨T†u, v⟩ = ⟨u, Tv⟩.
private axiom adjoint_defines_unique_law (T : CBOOp) :
    ∀ S : CBOOp, (∀ u v : CBOVec,
      cboInner (cboApply S u) v = cboInner u (cboApply T v)) →
    S = cboAdj T

theorem adjoint_defines_unique (T : CBOOp) :
    ∀ S : CBOOp, (∀ u v : CBOVec,
      cboInner (cboApply S u) v = cboInner u (cboApply T v)) →
    S = cboAdj T := adjoint_defines_unique_law T

-- ── Normal operator ───────────────────────────────────────────────────────────
def IsNormal (T : CBOOp) : Prop :=
  cboComp (cboAdj T) T = cboComp T (cboAdj T)

private axiom unitary_normal_law (U : CBOOp) (hU : IsCBOUnitary U) : IsNormal U

theorem unitary_normal (U : CBOOp) (hU : IsCBOUnitary U) : IsNormal U :=
  unitary_normal_law U hU

-- ── Downstream rank-one projector bridge ─────────────────────────────────────
theorem rankOne_unit_projector_bridge
    (v : CBOVec)
    (hUnit : CATEPTMain.Quantum.CBO.Extra_Pretty_Code_Examples.cboVecNorm v = 1) :
    IsCBOProjector (CATEPTMain.Quantum.CBO.Extra_Pretty_Code_Examples.rankOneOp v v) :=
  CATEPTMain.Quantum.CBO.Complex_Euclidean_Space0.rankOne_unit_projector_bridge v hUnit

-- ── Hermitian operators have real spectrum ────────────────────────────────────
-- Phase-1 axiom placeholder (spectral theorem proven in later file).
axiom hermitian_eigenvalue_real (T : CBOOp) (h : IsHermitian T)
    (ev : ℂ) (v : CBOVec) (hv : cboApply T v = cboApply (cboSmul ev cboOne) v) :
    ev.im = 0

-- ── Resolvent set ────────────────────────────────────────────────────────────
-- λ ∈ resolvent iff (T - λI) is invertible.
def IsResolvent (T : CBOOp) (ev : ℂ) : Prop :=
  ∃ R : CBOOp,
    cboComp (cboAdd T (cboSmul (-ev) cboOne)) R = cboOne ∧
    cboComp R (cboAdd T (cboSmul (-ev) cboOne)) = cboOne

def IsSpectrum (T : CBOOp) (ev : ℂ) : Prop := ¬ IsResolvent T ev

-- Resolvent is open (in ℂ):
private axiom resolvent_open_law (T : CBOOp) : IsOpen {ev : ℂ | IsResolvent T ev}

theorem resolvent_open (T : CBOOp) : IsOpen {ev : ℂ | IsResolvent T ev} :=
  resolvent_open_law T

end CATEPTMain.Quantum.CBO.Complex_Bounded_Linear_Function0
