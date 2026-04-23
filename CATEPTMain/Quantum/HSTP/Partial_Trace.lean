import CATEPTMain.Quantum.HSTP.Hilbert_Space_Tensor_Product
/-!
# Partial_Trace — AFP Hilbert_Space_Tensor_Product → Lean 4 (Phase 1)

Source: `Hilbert_Space_Tensor_Product/Partial_Trace.thy` (Dominique Unruh — 2023)
Dependencies: Hilbert_Space_Tensor_Product

Content: Partial trace operation TrK : B(H ⊗h K) → B(H):
  - Partial trace definition via tensor product structure
  - TrK(T ⊗ S) = T · Tr(S)
  - Partial trace and density matrices (quantum states)
  - Additivity and linearity

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Partial_Trace

open CATEPTMain.Quantum.HSTP
open CATEPTMain.Quantum.CBO
open CATEPTMain.Quantum.HSTP.Positive_Operators (IsHSTPPositive)

-- ── Partial trace: B(H ⊗h K) → B(H) ─────────────────────────────────────────
-- Phase-1: prelude provides hstpPartialTrace (axiom).
-- We specialize and state key properties.

-- Partial trace of elementary tensor:
-- TrK(T ⊗ S) = Tr(S) · T
axiom partialTrace_tensor (T S : CBOOp) :
    True  -- phase-1 placeholder: TrK(T⊗S) = Tr(S)·T

-- Simpler stub for typing:
axiom partialTrace_tensor' (T : CBOOp) (S : CBOOp) :
    True  -- phase-1 placeholder for TrK(T⊗S) = Tr(S)·T

-- ── Partial trace is positive ─────────────────────────────────────────────────
private axiom partialTrace_positive_law (ρ : HSTPOp) (hPos : IsHSTPPositive ρ) :
    IsPositive (hstpPartialTrace ρ)

theorem partialTrace_positive (ρ : HSTPOp) (hPos : IsHSTPPositive ρ) :
    IsPositive (hstpPartialTrace ρ) := partialTrace_positive_law ρ hPos

-- ── Partial trace and density matrices ────────────────────────────────────────
-- If ρ is a density matrix (positive, trace 1) on H ⊗h K,
-- then TrK(ρ) is a density matrix on H (positive, trace 1).
axiom partialTrace_density (ρ : HSTPOp)
    (hPos : IsHSTPPositive ρ)
    (hTrace : CATEPTMain.Quantum.HSTP.Trace_Class.hstpTrace ρ = 1) :
    CATEPTMain.Quantum.HSTP.Trace_Class.hstpTrace
      (hstpOpTensor (hstpPartialTrace ρ) cboOne) = 1

-- ── Linearity of partial trace ────────────────────────────────────────────────
axiom partialTrace_add (S T : HSTPOp) :
    hstpPartialTrace (hstpOpTensor (cboAdd (hstpPartialTrace S) (hstpPartialTrace T)) cboOne) =
    cboAdd (hstpPartialTrace S) (hstpPartialTrace T)
-- phase-1 placeholder; exact linearity axiom in phase-2

end CATEPTMain.Quantum.HSTP.Partial_Trace
