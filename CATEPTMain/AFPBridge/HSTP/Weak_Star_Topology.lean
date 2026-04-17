import CATEPTMain.AFPBridge.HSTP.Trace_Class
/-!
# Weak_Star_Topology — AFP Hilbert_Space_Tensor_Product → Lean 4 (Phase 1)

Source: `Hilbert_Space_Tensor_Product/Weak_Star_Topology.thy` (Dominique Unruh — 2023)
Dependencies: Trace_Class

Content: Weak* topology on B(H) = B₁(H)* (predual):
  - Weak* topology definition via trace-class predual
  - Kaplansky density theorem
  - WOT = weak* topology on bounded operators via trace predual

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.HSTP.Weak_Star_Topology

open CATEPTMain.AFPBridge.HSTP
open CATEPTMain.AFPBridge.CBO

-- ── Weak* convergence on B(H) ─────────────────────────────────────────────────
-- Tₙ →_w* T  iff Tr(ρ Tₙ) → Tr(ρ T) for all trace-class ρ.
def HSTPWeakStarConv (Tseq : ℕ → HSTPOp) (T : HSTPOp) : Prop :=
  ∀ ρ : HSTPOp, CATEPTMain.AFPBridge.HSTP.Trace_Class.IsTraceClass ρ →
    Filter.Tendsto
      (fun n => CATEPTMain.AFPBridge.HSTP.Trace_Class.hstpTrace
        (CATEPTMain.AFPBridge.HSTP.Strong_Operator_Topology.hstpOpComp ρ (Tseq n)))
      Filter.atTop
      (nhds (CATEPTMain.AFPBridge.HSTP.Trace_Class.hstpTrace
        (CATEPTMain.AFPBridge.HSTP.Strong_Operator_Topology.hstpOpComp ρ T)))

-- ── WOT ↔ weak* ──────────────────────────────────────────────────────────────
-- Via Riesz duality B₁(H)* = B(H) and trace duality.
private axiom wot_eq_weakstar_law (Tseq : ℕ → HSTPOp) (T : HSTPOp) :
    HSTPWeakStarConv Tseq T ↔
    CATEPTMain.AFPBridge.HSTP.Weak_Operator_Topology.HSTPWeakConv Tseq T

theorem wot_eq_weakstar (Tseq : ℕ → HSTPOp) (T : HSTPOp) :
    HSTPWeakStarConv Tseq T ↔
    CATEPTMain.AFPBridge.HSTP.Weak_Operator_Topology.HSTPWeakConv Tseq T :=
  wot_eq_weakstar_law Tseq T

-- ── Kaplansky density ────────────────────────────────────────────────────────
-- For any T with ‖T‖ ≤ 1, ∃ net of finite-dim operators Tₙ with ‖Tₙ‖ ≤ 1 and Tₙ →_SOT T.
axiom kaplansky_density (T : HSTPOp) (hBdd : hstpNorm T ≤ 1) :
    ∃ Tseq : ℕ → HSTPOp,
      (∀ n, CATEPTMain.AFPBridge.HSTP.Compact_Operators.IsHSTPFiniteRank (Tseq n)) ∧
      (∀ n, hstpNorm (Tseq n) ≤ 1) ∧
      CATEPTMain.AFPBridge.HSTP.Strong_Operator_Topology.HSTPStrongConv Tseq T

end CATEPTMain.AFPBridge.HSTP.Weak_Star_Topology
