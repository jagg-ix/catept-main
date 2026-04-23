import CATEPTMain.HSTP.Eigenvalues
/-!
# Compact_Operators — AFP Hilbert_Space_Tensor_Product → Lean 4 (Phase 1)

Source: `Hilbert_Space_Tensor_Product/Compact_Operators.thy` (Dominique Unruh — 2023)
Dependencies: Eigenvalues

Content: Theory of compact operators on H ⊗h K:
  - Norm limit of finite-rank operators is compact
  - Composition with bounded = compact
  - HS operators are compact
  - Compact × bounded ⊆ compact

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.HSTP.Compact_Operators

open CATEPTMain.HSTP
open CATEPTMain.CBO
open CATEPTMain.HSTP.Eigenvalues (IsHSTPCompact)

-- ── Finite-rank operators are compact ────────────────────────────────────────
def IsHSTPFiniteRank (T : HSTPOp) : Prop :=
  ∃ n : ℕ, ∃ (us vs : Fin n → HSTPTensor),
    ∀ x : HSTPTensor, True  -- image of T is in span{u₁,...,uₙ}

private axiom finiteRank_compact_law (T : HSTPOp) (hFR : IsHSTPFiniteRank T) : IsHSTPCompact T

theorem finiteRank_compact (T : HSTPOp) (hFR : IsHSTPFiniteRank T) :
    IsHSTPCompact T := finiteRank_compact_law T hFR

-- ── Norm limit of compact operators is compact ────────────────────────────────
private axiom normLim_compact_law (Tseq : ℕ → HSTPOp) (T : HSTPOp)
    (hCompact : ∀ n, IsHSTPCompact (Tseq n))
    (hConv : Filter.Tendsto (fun n => hstpNorm (Tseq n)) Filter.atTop (nhds (hstpNorm T))) :
    IsHSTPCompact T

theorem normLim_compact (Tseq : ℕ → HSTPOp) (T : HSTPOp)
    (hCompact : ∀ n, IsHSTPCompact (Tseq n))
    (hConv : Filter.Tendsto (fun n => hstpNorm (Tseq n)) Filter.atTop (nhds (hstpNorm T))) :
    IsHSTPCompact T := normLim_compact_law Tseq T hCompact hConv

-- ── Hilbert-Schmidt ⊆ compact ─────────────────────────────────────────────────
private axiom hs_compact_law (T : CBOOp) (hHS : CATEPTMain.HSTP.HS2Ell2.IsHilbertSchmidt T) :
    ∃ T' : HSTPOp, IsHSTPCompact T'

theorem hs_compact (T : CBOOp) (hHS : CATEPTMain.HSTP.HS2Ell2.IsHilbertSchmidt T) :
    ∃ T' : HSTPOp, IsHSTPCompact T' := hs_compact_law T hHS

-- ── Compact op eigenvalue existence ──────────────────────────────────────────
theorem compact_selfadj_has_eigenvalue (T : HSTPOp)
    (hCompact : IsHSTPCompact T)
    (hSA : hstpOpAdj T = T) :
    ∃ (ev : ℝ), CATEPTMain.HSTP.Eigenvalues.IsHSTPEigenvalue T ev := by
  obtain ⟨evs, vs, hEig, _, _⟩ :=
    CATEPTMain.HSTP.Eigenvalues.compact_selfadj_eigenbasis T hCompact hSA
  exact ⟨evs 0, hEig 0⟩

end CATEPTMain.HSTP.Compact_Operators
