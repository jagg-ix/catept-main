import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.LinearMaps

/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearProps#1
Theorem name: lemLinearProps
Lean tactic class: arithmetic_norm_num
-/

theorem lemLinearProps (L : NoFTLObj) (origin : NoFTLObj) (a : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) (h1 : linear L) : (L origin = origin) ∧ (L (a * p) = (a * (L p))) ∧ (L (p + q) = ((L p) + (L q))) ∧ (L (p - q) = ((L p) - (L q))) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemMatrixApplicationIsLinear#1
Theorem name: lemMatrixApplicationIsLinear
Lean tactic class: needs_human
-/

theorem lemMatrixApplicationIsLinear (applyMatrix : NoFTLObj) (m : NoFTLObj) : linear (applyMatrix m) := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsMatrixApplication#1
Theorem name: lemLinearIsMatrixApplication
Lean tactic class: arithmetic_norm_num
-/

theorem lemLinearIsMatrixApplication (L : NoFTLObj) (applyMatrix : NoFTLObj) (h1 : linear L) : ∃ m, L = (applyMatrix m) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIffMatrix#1
Theorem name: lemLinearIffMatrix
Lean tactic class: arithmetic_norm_num
-/

theorem lemLinearIffMatrix (L : NoFTLObj) (applyMatrix : NoFTLObj → NoFTLObj) : linear L ↔ (∃ M, L = applyMatrix M) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemIdIsLinear#1
Theorem name: lemIdIsLinear
Lean tactic class: needs_human
-/

theorem lemIdIsLinear (id : NoFTLObj) : linear id := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsBounded#1
Theorem name: lemLinearIsBounded
Lean tactic class: arithmetic_norm_num
-/

theorem lemLinearIsBounded (bounded : NoFTLObj → Prop) (L : NoFTLObj) (h1 : linear L) : bounded L := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsCts#1
Theorem name: lemLinearIsCts
Lean tactic class: arithmetic_norm_num
-/

theorem lemLinearIsCts (L : NoFTLObj) (x : NoFTLObj) (h1 : linear L) : cts L x := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinOfLinIsLin#1
Theorem name: lemLinOfLinIsLin
Lean tactic class: arithmetic_norm_num
-/

theorem lemLinOfLinIsLin (B : NoFTLObj) (A : NoFTLObj) (h1 : (linear A) ∧ (linear B)) : linear (composeRel B A) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemInverseLinear#1
Theorem name: lemInverseLinear
Lean tactic class: arithmetic_norm_num
-/

theorem lemInverseLinear (A : NoFTLObj) (h1 : linear A) (h2 : invertible A) : ∃ A', (linear A') ∧ (∀ p q, A p = q ↔ A' q = p) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.LinearMaps
