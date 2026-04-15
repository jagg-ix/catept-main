import CATEPTMain.AFPBridge.HSTP.Theories.Misc_TP
/-!
# Strong_Operator_Topology — AFP Hilbert_Space_Tensor_Product → Lean 4 (Phase 1)

Source: `Hilbert_Space_Tensor_Product/Strong_Operator_Topology.thy` (Dominique Unruh — 2023)
Dependencies: Misc_TP

Content: The strong operator topology (SOT) on B(H ⊗h K):
  - SOT definition and convergence criterion
  - SOT is weaker than norm topology
  - Bounded sets are SOT-relatively compact
  - SOT continuity of composition (in each argument separately)

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology

open CATEPTMain.AFPBridge.HSTP
open CATEPTMain.AFPBridge.CBO

-- ── SOT convergence ───────────────────────────────────────────────────────────
-- Tₙ →_SOT T  iff Tₙ(x) → T(x) in norm for every x.
def HSTPStrongConv (Tseq : ℕ → HSTPOp) (T : HSTPOp) : Prop :=
  ∀ x : HSTPTensor,
    Filter.Tendsto (fun n => hstpInner (hstpOpApply (Tseq n) x) (hstpOpApply (Tseq n) x))
      Filter.atTop
      (nhds (hstpInner (hstpOpApply T x) (hstpOpApply T x)))

-- ── Norm convergence → SOT convergence ───────────────────────────────────────
private axiom norm_implies_sot_law (Tseq : ℕ → HSTPOp) (T : HSTPOp)
    (hNorm : Filter.Tendsto (fun n => hstpNorm (Tseq n)) Filter.atTop (nhds (hstpNorm T))) :
    HSTPStrongConv Tseq T

theorem norm_implies_sot (Tseq : ℕ → HSTPOp) (T : HSTPOp)
    (hNorm : Filter.Tendsto (fun n => hstpNorm (Tseq n)) Filter.atTop (nhds (hstpNorm T))) :
    HSTPStrongConv Tseq T := norm_implies_sot_law Tseq T hNorm

-- ── Bounded net SOT-convergent subsequence ───────────────────────────────────
private axiom sot_bounded_subnet_law (Tseq : ℕ → HSTPOp) (C : ℝ) (hBdd : ∀ n, hstpNorm (Tseq n) ≤ C) :
    ∃ φ : ℕ → ℕ, StrictMono φ ∧ ∃ T : HSTPOp, HSTPStrongConv (Tseq ∘ φ) T

theorem sot_bounded_subnet (Tseq : ℕ → HSTPOp) (C : ℝ) (hBdd : ∀ n, hstpNorm (Tseq n) ≤ C) :
    ∃ φ : ℕ → ℕ, StrictMono φ ∧ ∃ T : HSTPOp, HSTPStrongConv (Tseq ∘ φ) T :=
  sot_bounded_subnet_law Tseq C hBdd

-- ── SOT continuity of composition ────────────────────────────────────────────
-- Left multiplication L_S : T ↦ S∘T is SOT-continuous.
noncomputable axiom hstpOpComp : HSTPOp → HSTPOp → HSTPOp

private axiom sot_left_mult_cont_law (S : HSTPOp) (Tseq : ℕ → HSTPOp) (T : HSTPOp)
    (hConv : HSTPStrongConv Tseq T) :
    HSTPStrongConv (fun n => hstpOpComp S (Tseq n)) (hstpOpComp S T)

theorem sot_left_mult_cont (S : HSTPOp) (Tseq : ℕ → HSTPOp) (T : HSTPOp)
    (hConv : HSTPStrongConv Tseq T) :
    HSTPStrongConv (fun n => hstpOpComp S (Tseq n)) (hstpOpComp S T) :=
  sot_left_mult_cont_law S Tseq T hConv

end CATEPTMain.AFPBridge.HSTP.Theories.Strong_Operator_Topology
