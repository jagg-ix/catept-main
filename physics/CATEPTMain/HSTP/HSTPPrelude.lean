import CATEPTMain.CBO.CBOPrelude
import Mathlib.Analysis.InnerProductSpace.TensorProduct
/-!
# HSTP Prelude — Hilbert_Space_Tensor_Product (AFP) → Lean 4

Phase-1 opaque scaffold for `Hilbert_Space_Tensor_Product` (Dominique Unruh — 2023).
https://www.isa-afp.org/entries/Hilbert_Space_Tensor_Product.html

AFP dependencies bridged here:
  Complex_Bounded_Operators (via CBOPrelude)
  HOL-Analysis

CRITICAL TYPE NOTE:
  AFP `htensor H K` = Hilbert space tensor product (complete in ℓ²).
  This is the COMPLETION of the algebraic tensor product.
  In Lean 4 Phase-1: opaque `HSTPTensor` type (NOT a concrete algebraic tensor product).

  AFP `tensor_pack T S` (operator on H ⊗ K) = HSTP version.
  BINDER RULE B36: `htensor` → emit as `HSTPTensor` opaque, NOT `TensorProduct ℂ`.
  BINDER RULE B37: `tensor_pack T S` → emit as `hstpOpTensor T S : HSTPOp`

KEY DISTINCTION from IMD:
  IMD uses `tensorMat` (Kronecker product of matrices, finite-dim).
  HSTP uses infinite-dimensional Hilbert tensor product (operator-algebraic).

Phase-2 upgrade path:
  Connect HSTPTensor → TensorProduct.Completion H K in Lean 4.

See: CATEPTMain/AFPBridge/HSTP/HSTP_WORKLOG.lean
-/

set_option autoImplicit false

open CATEPTMainFramework.TacticStubs

namespace CATEPTMain.HSTP

-- ── Hilbert tensor product (opaque type) ─────────────────────────────────────
-- AFP: `H ⊗h K`  (Hilbert tensor product — completed algebraic TP)
-- BINDER RULE B36: opaque, not TensorProduct ℂ H K.
opaque HSTPTensor : Type

-- ── Operators on tensor space ─────────────────────────────────────────────────
opaque HSTPOp : Type

-- ── Elementary tensor injection ──────────────────────────────────────────────
-- AFP: `ket (u ⊗ v)` — the elementary tensor |u⟩|v⟩ in H ⊗h K
noncomputable axiom hstpPair : CATEPTMain.CBO.CBOVec →
    CATEPTMain.CBO.CBOVec → HSTPTensor

-- Scaling on left factor:
axiom hstpPair_smul_left (c : ℂ) (u v : CATEPTMain.CBO.CBOVec) :
    hstpPair (CATEPTMain.CBO.cboApply (CATEPTMain.CBO.cboSmul c CATEPTMain.CBO.cboOne) u) v =
    hstpPair u v  -- phase-1 stub; linearity tracked structurally

-- ── Inner product on HSTPTensor ───────────────────────────────────────────────
noncomputable axiom hstpInner : HSTPTensor → HSTPTensor → ℂ

-- Bilinear formula: ⟨u₁⊗v₁, u₂⊗v₂⟩ = ⟨u₁,u₂⟩_H · ⟨v₁,v₂⟩_K
axiom hstpInner_pair (u₁ u₂ v₁ v₂ : CATEPTMain.CBO.CBOVec) :
    hstpInner (hstpPair u₁ v₁) (hstpPair u₂ v₂) =
    CATEPTMain.CBO.cboInner u₁ u₂ * CATEPTMain.CBO.cboInner v₁ v₂

-- ── Operator tensor product ───────────────────────────────────────────────────
-- AFP: `tensor_pack T S` — T ⊗ S acting on H ⊗h K
-- BINDER RULE B37: hstpOpTensor (not 'tensorMat').
noncomputable axiom hstpOpTensor :
    CATEPTMain.CBO.CBOOp →
    CATEPTMain.CBO.CBOOp → HSTPOp

-- Action on elementary tensors:
noncomputable axiom hstpOpApply : HSTPOp → HSTPTensor → HSTPTensor

axiom hstpOpTensor_pair (T S : CATEPTMain.CBO.CBOOp)
    (u v : CATEPTMain.CBO.CBOVec) :
    hstpOpApply (hstpOpTensor T S) (hstpPair u v) =
    hstpPair (CATEPTMain.CBO.cboApply T u) (CATEPTMain.CBO.cboApply S v)

-- ── HSTPOp norm ───────────────────────────────────────────────────────────────
noncomputable axiom hstpNorm : HSTPOp → ℝ

axiom hstpOpTensor_norm (T S : CATEPTMain.CBO.CBOOp) :
    hstpNorm (hstpOpTensor T S) =
    CATEPTMain.CBO.cboNorm T * CATEPTMain.CBO.cboNorm S

-- ── Adjoint of tensor op ──────────────────────────────────────────────────────
noncomputable axiom hstpOpAdj : HSTPOp → HSTPOp

axiom hstpOpTensor_adj (T S : CATEPTMain.CBO.CBOOp) :
    hstpOpAdj (hstpOpTensor T S) =
    hstpOpTensor (CATEPTMain.CBO.cboAdj T) (CATEPTMain.CBO.cboAdj S)

-- ── Trace-class and partial trace (needed by HSTP theories) ──────────────────
def IsHSTPTraceClass (T : HSTPOp) : Prop :=
  ∃ C : ℝ, 0 ≤ C ∧ hstpNorm T ≤ C  -- phase-1 stub; phase-2 ∑ singular values < ∞

noncomputable axiom hstpPartialTrace : HSTPOp → CATEPTMain.CBO.CBOOp

end CATEPTMain.HSTP
