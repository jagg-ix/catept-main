import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.AffineConeLemma

/-!
Auto-generated theorem-indexed pilot file.
Theory: AffineConeLemma
Theorem id: No_FTL_observers_Gen_Rel.AffineConeLemma.lemInverseOfAffInvertibleIsAffInvertible#1
Theorem name: lemInverseOfAffInvertibleIsAffInvertible
Lean tactic class: arithmetic_norm_num
-/

theorem lemInverseOfAffInvertibleIsAffInvertible (A' : NoFTLObj) (h1 : affInvertible A) (h2 : ∀ x y, A x = y ↔ A' y = x) : affInvertible A' := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: AffineConeLemma
Theorem id: No_FTL_observers_Gen_Rel.AffineConeLemma.lemInsideRegularConeUnderAffInvertible#1
Theorem name: lemInsideRegularConeUnderAffInvertible
Lean tactic class: arithmetic_norm_num
-/

theorem lemInsideRegularConeUnderAffInvertible (A : NoFTLObj) (x : NoFTLObj) (p : NoFTLObj) (h1 : affInvertible A) (h2 : insideRegularCone x p) (h3 : regularConeSet (A x) = applyToSet (asFunc A) (regularConeSet x)) : insideRegularCone (A x) (A p) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.AffineConeLemma
