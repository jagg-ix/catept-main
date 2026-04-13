import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.ReverseCauchySchwarz

/-!
Auto-generated theorem-indexed pilot file.
Theory: ReverseCauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemTimelikeNotZeroTime#1
Theorem name: lemTimelikeNotZeroTime
Lean tactic class: arithmetic_norm_num
-/

theorem lemTimelikeNotZeroTime (tval : NoFTLObj → NoFTLObj) (v : NoFTLObj) (h1 : timelike v) : tval v ≠ 0 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: ReverseCauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemOrthogmToTimelike#1
Theorem name: lemOrthogmToTimelike
Lean tactic class: arithmetic_norm_num
-/

theorem lemOrthogmToTimelike (spacelike : NoFTLObj → Prop) (v : NoFTLObj) (h1 : timelike u) (h2 : orthogm u v) (h3 : v ≠ origin) : spacelike v := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: ReverseCauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemNormaliseTimelike#1
Theorem name: lemNormaliseTimelike
Lean tactic class: arithmetic_norm_num
-/

theorem lemNormaliseTimelike (s : NoFTLObj) (tval : NoFTLObj → NoFTLObj) (v : NoFTLObj) (h1 : timelike v) (h2 : s = sComponent ((1/tval v)v)) : ((0 ≤ sNorm2 s) ∧ (sNorm2 s < 1)) ∧ (tval ((1/tval v) * v) = 1) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: ReverseCauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemReverseCauchySchwarz#1
Theorem name: lemReverseCauchySchwarz
Lean tactic class: arithmetic_norm_num
-/

theorem lemReverseCauchySchwarz (X : NoFTLObj) (m : NoFTLObj) (D : NoFTLObj) (h1 : timelike X ∧ timelike D) : sqr (X *m D) ≥ (mNorm^2 X)*(mNorm^2 D) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.ReverseCauchySchwarz
