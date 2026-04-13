import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.TangentLines

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLines
Theorem id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineTranslation#1
Theorem name: lemTangentLineTranslation
Lean tactic class: arithmetic_norm_num
-/

theorem lemTangentLineTranslation (tangentLine : NoFTLSet → NoFTLSet → NoFTLObj → Prop) (T : NoFTLObj) (l : NoFTLSet) (s : NoFTLSet) (x : NoFTLObj) (h1 : translation T) (h2 : tangentLine l s x) : tangentLine (applyToSet (asFunc T) l) (applyToSet (asFunc T) s) (T x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLines
Theorem id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineA#1
Theorem name: lemTangentLineA
Lean tactic class: arithmetic_norm_num
-/

theorem lemTangentLineA (tangentLineA : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (l : NoFTLObj) (s : NoFTLObj) (x : NoFTLObj) (h1 : tangentLine l s x) : tangentLineA l s x := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLines
Theorem id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineE#1
Theorem name: lemTangentLineE
Lean tactic class: arithmetic_norm_num
-/

theorem lemTangentLineE (tangentLine : NoFTLSet → NoFTLObj → NoFTLObj → Prop) (l : NoFTLSet) (s : NoFTLObj) (x : NoFTLObj) (h1 : tangentLineA l s x) (h2 : ∃ p ≠ x, onLine p l) : tangentLine l s x := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.TangentLines
