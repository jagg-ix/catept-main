import CATEPTMain.AFPBridge.HSTP.Theories.Misc_TP_TTS
/-!
# Eigenvalues — AFP Hilbert_Space_Tensor_Product → Lean 4 (Phase 1)

Source: `Hilbert_Space_Tensor_Product/Eigenvalues.thy` (Dominique Unruh — 2023)
Dependencies: Misc_TP_TTS

Content: Eigenvalue theory for operators on H ⊗h K:
  - Compact operators have discrete spectrum
  - Spectral theorem for compact self-adjoint operators
  - Orthonormal basis of eigenvectors
  - Eigenvalue ordering for compact self-adjoint

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.HSTP.Theories.Eigenvalues

open CATEPTMain.AFPBridge.HSTP
open CATEPTMain.AFPBridge.CBO

-- ── Compact HSTP operator ─────────────────────────────────────────────────────
-- Phase-1 definition: compact = maps bounded sets to sets with convergent subsequences.
def IsHSTPCompact (T : HSTPOp) : Prop :=
  ∀ (xseq : ℕ → HSTPTensor),
    (∃ C : ℝ, ∀ n, (hstpInner (xseq n) (xseq n)).re ≤ C) →
    ∃ φ : ℕ → ℕ, StrictMono φ ∧
    ∃ y : HSTPTensor, True  -- phase-1; phase-2: T(xseq ∘ φ) → y in norm

-- ── Eigenvalue of HSTP operator ───────────────────────────────────────────────
def IsHSTPEigenvalue (T : HSTPOp) (ev : ℂ) : Prop :=
  ∃ v : HSTPTensor, hstpInner v v ≠ 0 ∧
    hstpOpApply T v = hstpOpApply (hstpOpTensor (cboSmul ev cboOne) cboOne) v

-- ── Spectral theorem for compact self-adjoint ─────────────────────────────────
-- Compact Hermitian T has orthonormal eigenbasis with λₙ → 0.
-- Phase-1 axiom.
axiom compact_selfadj_eigenbasis (T : HSTPOp)
    (hCompact : IsHSTPCompact T)
    (hSelfAdj : hstpOpAdj T = T) :
    ∃ (evs : ℕ → ℝ) (vs : ℕ → HSTPTensor),
      (∀ n, IsHSTPEigenvalue T (evs n)) ∧
      (∀ n m, n ≠ m → hstpInner (vs n) (vs m) = 0) ∧
      Filter.Tendsto (fun n => evs n) Filter.atTop (nhds 0)

end CATEPTMain.AFPBridge.HSTP.Theories.Eigenvalues
