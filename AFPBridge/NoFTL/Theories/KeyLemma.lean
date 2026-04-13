import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.KeyLemma

/-!
Auto-generated theorem-indexed pilot file.
Theory: KeyLemma
Theorem id: No_FTL_observers_Gen_Rel.KeyLemma.lemInsideRegularConeImplies#1
Theorem name: lemInsideRegularConeImplies
Lean tactic class: arithmetic_norm_num
-/

theorem lemInsideRegularConeImplies (l : NoFTLSet) (x : NoFTLObj) (h1 : insideRegularCone x p) (h2 : D ≠ origin) (h3 : l = line p D) : (0 < card (l ∩ regularConeSet x)) ∧ (card (l ∩ regularConeSet x) ≤ 2) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.KeyLemma
