import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.NoFTLGR

/-!
Auto-generated theorem-indexed pilot file.
Theory: NoFTLGR
Theorem id: No_FTL_observers_Gen_Rel.NoFTLGR.lemNoFTLGR#1
Theorem name: lemNoFTLGR
Lean tactic class: arithmetic_norm_num
-/

theorem lemNoFTLGR (lineSlopeFinite : NoFTLObj → Prop) (l : NoFTLObj) (v : NoFTLObj) (ass1 : x ∈ wline m m ∩ wline m k) (ass2 : tl l m k x) (ass3 : v ∈ lineVelocity l) (ass4 : ∃ p, (p ≠ x) ∧ (p ∈ l)) : (lineSlopeFinite l) ∧ (sNorm2 v < 1) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.NoFTLGR
