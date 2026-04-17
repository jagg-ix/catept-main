import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Cardinalities

/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemInjectiveValueUnique#1
Theorem name: lemInjectiveValueUnique
Lean tactic class: arithmetic_norm_num
-/

theorem lemInjectiveValueUnique (q : NoFTLObj) (f : NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) (h1 : injective f) (h2 : isFunction f) (h3 : f x = y) : setOf' (fun q => f x = q) = setOf' (fun q => q = y) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemBijectionOnTwo#1
Theorem name: lemBijectionOnTwo
Lean tactic class: arithmetic_norm_num
-/

theorem lemBijectionOnTwo (f : NoFTLObj) (s : NoFTLSet) (h1 : bijective f) (h2 : isFunction f) (h3 : s ⊆ domain f) (h4 : card s = 2) : card (applyToSet f s) = 2 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemElementsOfSet2#1
Theorem name: lemElementsOfSet2
Lean tactic class: arithmetic_norm_num
-/

theorem lemElementsOfSet2 (S : NoFTLSet) (h1 : card S = 2) : ∃ p q, (p ≠ q) ∧ p ∈ S ∧ q ∈ S := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemThirdElementOfSet2#1
Theorem name: lemThirdElementOfSet2
Lean tactic class: arithmetic_norm_num
-/

theorem lemThirdElementOfSet2 (p : NoFTLObj) (r : NoFTLObj) (q : NoFTLObj) (h1 : (p ≠ q) ∧ p ∈ S ∧ q ∈ S ∧ (card S = 2)) (h2 : r ∈ S) : p = r ∨ q = r := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemSmallCardUnderInvertible#1
Theorem name: lemSmallCardUnderInvertible
Lean tactic class: arithmetic_norm_num
-/

theorem lemSmallCardUnderInvertible (S : NoFTLSet) (f : NoFTLObj) (h1 : invertible f) (h2 : 0 < card S ∧ card S ≤ 2) : card S = card (applyToSet (asFunc f) S) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemCardOfLineIsBig#1
Theorem name: lemCardOfLineIsBig
Lean tactic class: arithmetic_norm_num
-/

theorem lemCardOfLineIsBig (l : NoFTLSet) (h1 : x ≠ p) (h2 : onLine x l ∧ onLine p l) : ∃ p1 p2 p3, (onLine p1 l ∧ onLine p2 l ∧ onLine p3 l) ∧ (p1≠p2 ∧ p2≠p3 ∧ p3≠p1) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Cardinalities
