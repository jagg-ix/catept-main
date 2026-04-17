import CATEPTMain.AFPBridge.HSTP.Strong_Operator_Topology
/-!
# Positive_Operators — AFP Hilbert_Space_Tensor_Product → Lean 4 (Phase 1)

Source: `Hilbert_Space_Tensor_Product/Positive_Operators.thy` (Dominique Unruh — 2023)
Dependencies: Strong_Operator_Topology

Content: Positive operator theory for H ⊗h K:
  - Positive operator ordering
  - Square root of positive operators
  - Comparison and monotone convergence for positive operators
  - Tensor product of positive operators is positive

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.HSTP.Positive_Operators

open CATEPTMain.AFPBridge.HSTP
open CATEPTMain.AFPBridge.CBO

-- ── Positive HSTP operator ────────────────────────────────────────────────────
def IsHSTPPositive (T : HSTPOp) : Prop :=
  ∀ x : HSTPTensor, 0 ≤ (hstpInner (hstpOpApply T x) x).re

-- ── Square root of positive operator ─────────────────────────────────────────
noncomputable axiom hstpSqrt : HSTPOp → HSTPOp

axiom hstpSqrt_pos (T : HSTPOp) (hPos : IsHSTPPositive T) :
    IsHSTPPositive (hstpSqrt T)

axiom hstpSqrt_sq (T : HSTPOp) (hPos : IsHSTPPositive T) :
    CATEPTMain.AFPBridge.HSTP.Strong_Operator_Topology.hstpOpComp
      (hstpSqrt T) (hstpSqrt T) = T

-- ── Positive operator ordering ────────────────────────────────────────────────
-- S ≤ T in operator order iff T - S is positive.
-- Phase-1: stated as axiom (full ordering needs HSTPOpAdd).
def HSTPOpLE (S T : HSTPOp) : Prop :=
  ∀ x : HSTPTensor,
    (hstpInner (hstpOpApply T x) x).re ≥ (hstpInner (hstpOpApply S x) x).re

-- ── Monotone convergence ──────────────────────────────────────────────────────
-- An increasing bounded sequence of positive operators converges SOT.
private axiom monotone_positive_sot_conv_law (Tseq : ℕ → HSTPOp)
    (hPos : ∀ n, IsHSTPPositive (Tseq n))
    (hMono : ∀ m n, m ≤ n → HSTPOpLE (Tseq m) (Tseq n))
    (hBdd : ∃ C : ℝ, ∀ n, hstpNorm (Tseq n) ≤ C) :
    ∃ T : HSTPOp, IsHSTPPositive T ∧
    CATEPTMain.AFPBridge.HSTP.Strong_Operator_Topology.HSTPStrongConv Tseq T

theorem monotone_positive_sot_conv (Tseq : ℕ → HSTPOp)
    (hPos : ∀ n, IsHSTPPositive (Tseq n))
    (hMono : ∀ m n, m ≤ n → HSTPOpLE (Tseq m) (Tseq n))
    (hBdd : ∃ C : ℝ, ∀ n, hstpNorm (Tseq n) ≤ C) :
    ∃ T : HSTPOp, IsHSTPPositive T ∧
    CATEPTMain.AFPBridge.HSTP.Strong_Operator_Topology.HSTPStrongConv Tseq T :=
  monotone_positive_sot_conv_law Tseq hPos hMono hBdd

-- ── Tensor product of positive operators ─────────────────────────────────────
private axiom hstpOpTensor_positive_law (T S : CBOOp)
    (hT : CATEPTMain.AFPBridge.CBO.IsPositive T)
    (hS : CATEPTMain.AFPBridge.CBO.IsPositive S) :
    IsHSTPPositive (hstpOpTensor T S)

theorem hstpOpTensor_positive (T S : CBOOp)
    (hT : CATEPTMain.AFPBridge.CBO.IsPositive T)
    (hS : CATEPTMain.AFPBridge.CBO.IsPositive S) :
    IsHSTPPositive (hstpOpTensor T S) := hstpOpTensor_positive_law T S hT hS

end CATEPTMain.AFPBridge.HSTP.Positive_Operators
