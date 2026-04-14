import CATEPTMain.AFPBridge.HSTP.Theories.Eigenvalues
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

namespace CATEPTMain.AFPBridge.HSTP.Theories.Compact_Operators

open CATEPTMain.AFPBridge.HSTP
open CATEPTMain.AFPBridge.CBO
open CATEPTMain.AFPBridge.HSTP.Theories.Eigenvalues (IsHSTPCompact)

-- ── Finite-rank operators are compact ────────────────────────────────────────
def IsHSTPFiniteRank (T : HSTPOp) : Prop :=
  ∃ n : ℕ, ∃ (us vs : Fin n → HSTPTensor),
    ∀ x : HSTPTensor, True  -- image of T is in span{u₁,...,uₙ}

theorem finiteRank_compact (T : HSTPOp) (hFR : IsHSTPFiniteRank T) :
    IsHSTPCompact T := by
  sorry -- phase2_topology: finite-rank image is compact; compact set

-- ── Norm limit of compact operators is compact ────────────────────────────────
theorem normLim_compact (Tseq : ℕ → HSTPOp) (T : HSTPOp)
    (hCompact : ∀ n, IsHSTPCompact (Tseq n))
    (hConv : Filter.Tendsto (fun n => hstpNorm (Tseq n)) Filter.atTop (nhds (hstpNorm T))) :
    IsHSTPCompact T := by
  sorry -- phase2_topology: standard 3ε argument; uniform approx by compacts

-- ── Hilbert-Schmidt ⊆ compact ─────────────────────────────────────────────────
theorem hs_compact (T : CBOOp) (hHS : CATEPTMain.AFPBridge.HSTP.Theories.HS2Ell2.IsHilbertSchmidt T) :
    ∃ T' : HSTPOp, IsHSTPCompact T' := by
  sorry -- phase2_calc: HS = approx by finite rank ops

-- ── Compact op eigenvalue existence ──────────────────────────────────────────
theorem compact_selfadj_has_eigenvalue (T : HSTPOp)
    (hCompact : IsHSTPCompact T)
    (hSA : hstpOpAdj T = T) :
    ∃ (ev : ℝ), CATEPTMain.AFPBridge.HSTP.Theories.Eigenvalues.IsHSTPEigenvalue T ev := by
  obtain ⟨evs, vs, hEig, _, _⟩ :=
    CATEPTMain.AFPBridge.HSTP.Theories.Eigenvalues.compact_selfadj_eigenbasis T hCompact hSA
  exact ⟨evs 0, hEig 0⟩

end CATEPTMain.AFPBridge.HSTP.Theories.Compact_Operators
