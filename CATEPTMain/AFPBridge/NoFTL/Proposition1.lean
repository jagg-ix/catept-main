import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Proposition1

/-!
Auto-generated theorem-indexed pilot file.
Theory: Proposition1
Theorem id: No_FTL_observers_Gen_Rel.Proposition1.lemProposition1#1
Theorem name: lemProposition1
Lean tactic class: arithmetic_norm_num
-/

theorem lemProposition1 (cone : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj) (m : NoFTLObj) (x : NoFTLObj) (p : NoFTLObj) (regularCone : NoFTLObj → NoFTLObj → NoFTLObj) (h1 : x ∈ wline m m) : cone m x p = regularCone x p := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Proposition1
