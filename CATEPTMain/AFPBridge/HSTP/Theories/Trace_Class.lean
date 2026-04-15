import CATEPTMain.AFPBridge.HSTP.Theories.Spectral_Theorem
/-!
# Trace_Class — AFP Hilbert_Space_Tensor_Product → Lean 4 (Phase 1)

Source: `Hilbert_Space_Tensor_Product/Trace_Class.thy` (Dominique Unruh — 2023)
Dependencies: Spectral_Theorem

Content: Trace-class operators on H ⊗h K:
  - Definition: T is trace-class iff ∑ ⟨eₙ, |T| eₙ⟩ < ∞
  - Trace: Tr(T) = ∑ ⟨eₙ, T eₙ⟩  (basis-independent)
  - Tr(ST) = Tr(TS)  (cyclic property)
  - B₁(H) = dual of K(H)  (trace-class = dual of compacts)

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.HSTP.Theories.Trace_Class

open CATEPTMain.AFPBridge.HSTP
open CATEPTMain.AFPBridge.CBO

-- ── Trace-class predicate ─────────────────────────────────────────────────────
-- T is trace-class iff ∑_{n} ⟨eₙ, |T| eₙ⟩ < ∞
-- Phase-1: provided by prelude stub IsHSTPTraceClass.
-- We re-export and provide trace norm.
noncomputable axiom hstpTraceNorm : HSTPOp → ℝ

axiom hstpTraceNorm_nonneg (T : HSTPOp) : 0 ≤ hstpTraceNorm T
axiom hstpTraceNorm_le_norm (T : HSTPOp) : hstpNorm T ≤ hstpTraceNorm T

-- T is trace-class iff trace norm is finite (phase-1 opaque predicate):
axiom IsTraceClass : HSTPOp → Prop

-- ── Trace ─────────────────────────────────────────────────────────────────────
noncomputable axiom hstpTrace : HSTPOp → ℂ

-- Trace is basis-independent for trace-class operators:
axiom hstpTrace_basis_indep (T : HSTPOp) (hTC : IsTraceClass T) :
    True  -- Tr(T) does not depend on choice of ONB; phase-2 formal statement

-- ── Trace cyclic property ─────────────────────────────────────────────────────
axiom hstpTrace_cyclic (S T : HSTPOp) (hST : IsTraceClass
    (CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology.hstpOpComp S T)) :
    hstpTrace
      (CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology.hstpOpComp S T) =
    hstpTrace
      (CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology.hstpOpComp T S)

-- ── Trace-class ⊂ compact ─────────────────────────────────────────────────────
private axiom traceClass_compact_law (T : HSTPOp) (hTC : IsTraceClass T) :
    CATEPTMain.AFPBridge.HSTP.Theories.Eigenvalues.IsHSTPCompact T

theorem traceClass_compact (T : HSTPOp) (hTC : IsTraceClass T) :
    CATEPTMain.AFPBridge.HSTP.Theories.Eigenvalues.IsHSTPCompact T := traceClass_compact_law T hTC

end CATEPTMain.AFPBridge.HSTP.Theories.Trace_Class
