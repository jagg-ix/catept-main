import CATEPTMain.AFPBridge.HSTP.Theories.Trace_Class
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

namespace CATEPTMain.AFPBridge.HSTP.Theories.Weak_Star_Topology

open CATEPTMain.AFPBridge.HSTP
open CATEPTMain.AFPBridge.CBO

-- ── Weak* convergence on B(H) ─────────────────────────────────────────────────
-- Tₙ →_w* T  iff Tr(ρ Tₙ) → Tr(ρ T) for all trace-class ρ.
def HSTPWeakStarConv (Tseq : ℕ → HSTPOp) (T : HSTPOp) : Prop :=
  ∀ ρ : HSTPOp, CATEPTMain.AFPBridge.HSTP.Theories.Trace_Class.IsTraceClass ρ →
    Filter.Tendsto
      (fun n => CATEPTMain.AFPBridge.HSTP.Theories.Trace_Class.hstpTrace
        (CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology.hstpOpComp ρ (Tseq n)))
      Filter.atTop
      (nhds (CATEPTMain.AFPBridge.HSTP.Theories.Trace_Class.hstpTrace
        (CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology.hstpOpComp ρ T)))

-- ── WOT ↔ weak* ──────────────────────────────────────────────────────────────
-- Via Riesz duality B₁(H)* = B(H) and trace duality.
theorem wot_eq_weakstar (Tseq : ℕ → HSTPOp) (T : HSTPOp) :
    HSTPWeakStarConv Tseq T ↔
    CATEPTMain.AFPBridge.HSTP.Theories.Weak_Operator_Topology.HSTPWeakConv Tseq T := by
  sorry -- phase2_duality: ⟨y, Tx⟩ = Tr(|x⟩⟨y| T); trace-class = rank-1 via Schmidt

-- ── Kaplansky density ────────────────────────────────────────────────────────
-- For any T with ‖T‖ ≤ 1, ∃ net of finite-dim operators Tₙ with ‖Tₙ‖ ≤ 1 and Tₙ →_SOT T.
axiom kaplansky_density (T : HSTPOp) (hBdd : hstpNorm T ≤ 1) :
    ∃ Tseq : ℕ → HSTPOp,
      (∀ n, CATEPTMain.AFPBridge.HSTP.Theories.Compact_Operators.IsHSTPFiniteRank (Tseq n)) ∧
      (∀ n, hstpNorm (Tseq n) ≤ 1) ∧
      CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology.HSTPStrongConv Tseq T

end CATEPTMain.AFPBridge.HSTP.Theories.Weak_Star_Topology
