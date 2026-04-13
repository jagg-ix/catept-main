import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Functions

/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemBijInv#1
Theorem name: lemBijInv
Lean tactic class: needs_human
-/

theorem lemBijInv (bijective : (NoFTLObj → NoFTLObj) → Prop) (f : NoFTLObj) : bijective (asFunc f) ↔ invertible f := by
  first | exact rfl | rfl | ring | norm_num | omega | simp_all | decide | congr 1 | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemApproxEqualAtBase#1
Theorem name: lemApproxEqualAtBase
Lean tactic class: arithmetic_norm_num
-/

theorem lemApproxEqualAtBase (f : NoFTLObj → NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) (g : NoFTLObj → NoFTLObj) (z : NoFTLObj) (h1 : diffApprox g f x) : (f x = y)∧(g x = z) → (y = z) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemCtsOfCtsIsCts#1
Theorem name: lemCtsOfCtsIsCts
Lean tactic class: arithmetic_norm_num
-/

theorem lemCtsOfCtsIsCts (g : NoFTLObj) (f : NoFTLObj) (x : NoFTLObj) (h1 : cts f x) (h2 : ∀ y, (f x y) → (cts g y)) : cts (composeRel g f) x := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemInjOfInjIsInj#1
Theorem name: lemInjOfInjIsInj
Lean tactic class: arithmetic_norm_num
-/

theorem lemInjOfInjIsInj (g : NoFTLObj) (f : NoFTLObj) (h1 : injective f) (h2 : injective g) : injective (composeRel g f) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemInverseComposition#1
Theorem name: lemInverseComposition
Lean tactic class: arithmetic_norm_num
-/

theorem lemInverseComposition (invFunc : NoFTLObj → NoFTLObj) (h : NoFTLObj) (f : NoFTLObj) (g : NoFTLObj) (h1 : h = composeRel g f) : (invFunc h) = composeRel (invFunc f) (invFunc g) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemToFuncAsFunc#1
Theorem name: lemToFuncAsFunc
Lean tactic class: arithmetic_norm_num
-/

theorem lemToFuncAsFunc (toFunc : NoFTLObj) (f : NoFTLObj) (h1 : isFunction f) (h2 : total f) : asFunc (toFunc f) = f := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemAsFuncToFunc#1
Theorem name: lemAsFuncToFunc
Lean tactic class: arithmetic_norm_num
-/

theorem lemAsFuncToFunc (toFunc : (NoFTLObj → NoFTLObj) → NoFTLObj) (f : NoFTLObj) : toFunc (asFunc f) = f := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Functions
