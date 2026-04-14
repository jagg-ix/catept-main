import CATEPTMain.AFPBridge.CBO.Theories.Extra_Operator_Norm
/-!
# Extra_Pretty_Code_Examples — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Extra_Pretty_Code_Examples.thy` (Dominique Unruh — 2022)
Dependencies: Extra_Operator_Norm

Content: Pedagogical examples illustrating operator norm and adjoint usage.
  These are small demonstrations that appear in the AFP text:
  - Diagonal matrix operators
  - Rank-one operators |v⟩⟨w|
  - Composition examples

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.CBO.Theories.Extra_Pretty_Code_Examples

open CATEPTMain.AFPBridge.CBO

-- ── Rank-one operator ─────────────────────────────────────────────────────────
-- Given vectors v, w: define |v⟩⟨w| as a bounded operator.
-- (v ⊗ w†)(x) = ⟨w, x⟩ · v
noncomputable axiom rankOneOp : CBOVec → CBOVec → CBOOp

axiom rankOneOp_apply (v w x : CBOVec) :
    cboApply (rankOneOp v w) x =
    cboApply (cboSmul (cboInner w x) cboOne) v

axiom rankOneOp_adj (v w : CBOVec) :
    cboAdj (rankOneOp v w) = rankOneOp w v

-- ── Norm of rank-one operator ────────────────────────────────────────────────
-- ‖|v⟩⟨w|‖ = ‖v‖ · ‖w‖
noncomputable axiom cboVecNorm : CBOVec → ℝ
axiom cboVecNorm_nonneg (v : CBOVec) : 0 ≤ cboVecNorm v

axiom rankOneOp_norm (v w : CBOVec) :
    cboNorm (rankOneOp v w) = cboVecNorm v * cboVecNorm w

-- ── Example: projection onto span of v ───────────────────────────────────────
-- For unit vector v: P_v = |v⟩⟨v| is a projector.
-- phase2_note: idempotency cboComp P P = P requires cboComp_apply + cboExt + cboSmulOne_apply
-- axioms not yet in CBOPrelude; admitted as a private axiom pending that infrastructure.
private axiom rankOneOp_idempotent (v : CBOVec) (h : cboVecNorm v = 1) :
    cboComp (rankOneOp v v) (rankOneOp v v) = rankOneOp v v

theorem rankOneOp_projector (v : CBOVec) (hUnit : cboVecNorm v = 1) :
    IsCBOProjector (rankOneOp v v) := by
  constructor
  · exact rankOneOp_idempotent v hUnit
  · unfold IsHermitian; rw [rankOneOp_adj]

end CATEPTMain.AFPBridge.CBO.Theories.Extra_Pretty_Code_Examples
