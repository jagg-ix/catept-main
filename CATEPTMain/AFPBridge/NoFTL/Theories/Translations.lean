import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Translations

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemMkTrans#1
Theorem name: lemMkTrans
Lean tactic class: needs_human
-/

theorem lemMkTrans : ∀ t, translation (mkTranslation t) := by
  first | intro _ | simp_all | tauto | omega | decide | trivial | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemInverseTranslation#1
Theorem name: lemInverseTranslation
Lean tactic class: arithmetic_norm_num
-/

theorem lemInverseTranslation (T' : NoFTLObj) (T : NoFTLObj) (id : NoFTLObj) (h1 : (T = mkTranslation t) ∧ (T' = mkTranslation (origin - t))) : (composeRel T' T = id) ∧ (composeRel T T' = id) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSum#1
Theorem name: lemTranslationSum
Lean tactic class: arithmetic_norm_num
-/

theorem lemTranslationSum (T : NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) (h1 : translation T) : T (u + v) = ((T u) + v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemIdIsTranslation#1
Theorem name: lemIdIsTranslation
Lean tactic class: needs_human
-/

theorem lemIdIsTranslation (id : NoFTLObj) : translation id := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationCancel#1
Theorem name: lemTranslationCancel
Lean tactic class: arithmetic_norm_num
-/

theorem lemTranslationCancel (T : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) (h1 : translation T) : ((T p) - (T q)) = (p - q) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSwap#1
Theorem name: lemTranslationSwap
Lean tactic class: arithmetic_norm_num
-/

theorem lemTranslationSwap (p : NoFTLObj) (T : NoFTLObj) (q : NoFTLObj) (h1 : translation T) : (p + (T q)) = ((T p) + q) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationPreservesSep2#1
Theorem name: lemTranslationPreservesSep2
Lean tactic class: arithmetic_norm_num
-/

theorem lemTranslationPreservesSep2 (p : NoFTLObj → NoFTLObj) (q : NoFTLObj) (T : NoFTLObj) (h1 : translation T) : sep2 p q = sep2 (T p) (T q) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationInjective#1
Theorem name: lemTranslationInjective
Lean tactic class: arithmetic_norm_num
-/

theorem lemTranslationInjective (T : NoFTLObj) (h1 : translation T) : injective T := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSurjective#1
Theorem name: lemTranslationSurjective
Lean tactic class: arithmetic_norm_num
-/

theorem lemTranslationSurjective (surjective : (NoFTLObj → NoFTLObj) → Prop) (T : NoFTLObj) (h1 : translation T) : surjective (asFunc T) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationTotalFunction#1
Theorem name: lemTranslationTotalFunction
Lean tactic class: arithmetic_norm_num
-/

theorem lemTranslationTotalFunction (T : NoFTLObj) (h1 : translation T) : isTotalFunction T := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationOfLine#1
Theorem name: lemTranslationOfLine
Lean tactic class: arithmetic_norm_num
-/

theorem lemTranslationOfLine (T : NoFTLObj) (line : NoFTLObj → NoFTLObj → NoFTLSet) (B : NoFTLObj) (D : NoFTLObj) (h1 : translation T) : (applyToSet (asFunc T) (line B D)) = line (T B) D := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemOnLineTranslation#1
Theorem name: lemOnLineTranslation
Lean tactic class: arithmetic_norm_num
-/

theorem lemOnLineTranslation (T : NoFTLObj) (p : NoFTLObj) (l : NoFTLSet) (h1 : (translation T) ∧ (onLine p l)) : onLine (T p) (applyToSet (asFunc T) l) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemLineJoiningTranslation#1
Theorem name: lemLineJoiningTranslation
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineJoiningTranslation (T : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) (h1 : translation T) : applyToSet (asFunc T) (lineJoining p q) = lineJoining (T p) (T q) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemBallTranslation#1
Theorem name: lemBallTranslation
Lean tactic class: arithmetic_norm_num
-/

theorem lemBallTranslation (T : NoFTLObj) (x : NoFTLObj) (e : NoFTLObj) (y : NoFTLObj) (h1 : translation T) (h2 : x within e of y) : withinOf (T x) e (T y) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemBallTranslationWithBoundary#1
Theorem name: lemBallTranslationWithBoundary
Lean tactic class: arithmetic_norm_num
-/

theorem lemBallTranslationWithBoundary (T : NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) (e : NoFTLObj) (h1 : translation T) (h2 : sep2 x y ≤ sqr e) : sep2 (T x) (T y) ≤ sqr e := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationIsCts#1
Theorem name: lemTranslationIsCts
Lean tactic class: arithmetic_norm_num
-/

theorem lemTranslationIsCts (T : NoFTLObj) (x : NoFTLObj) (h1 : translation T) : cts T x := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemAccPointTranslation#1
Theorem name: lemAccPointTranslation
Lean tactic class: arithmetic_norm_num
-/

theorem lemAccPointTranslation (accPoint : NoFTLObj → NoFTLSet → Prop) (T : NoFTLObj) (x : NoFTLObj) (s : NoFTLSet) (h1 : translation T) (h2 : accPoint x s) : accPoint (T x) (applyToSet (asFunc T) s) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemInverseOfTransIsTrans#1
Theorem name: lemInverseOfTransIsTrans
Lean tactic class: arithmetic_norm_num
-/

theorem lemInverseOfTransIsTrans (toFunc : NoFTLObj) (T' : NoFTLObj) (h1 : translation T) (h2 : T' = invFunc (asFunc T)) : translation (toFunc T') := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemInverseTrans#1
Theorem name: lemInverseTrans
Lean tactic class: arithmetic_norm_num
-/

theorem lemInverseTrans (T : NoFTLObj) (h1 : translation T) : ∃ T', (translation T') ∧ (∀ p q, T p = q ↔ T' q = p) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Translations
