import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Affine

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemTranslationPartIsUnique#1
Theorem name: lemTranslationPartIsUnique
Lean tactic class: arithmetic_norm_num
-/

theorem lemTranslationPartIsUnique (T1 : NoFTLObj) (h1 : isTranslationPart A T1) (h2 : isTranslationPart A T2) : T1 = T2 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemLinearPartIsUnique#1
Theorem name: lemLinearPartIsUnique
Lean tactic class: arithmetic_norm_num
-/

theorem lemLinearPartIsUnique (L1 : NoFTLObj) (h1 : isLinearPart A L1) (h2 : isLinearPart A L2) : L1 = L2 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemLinearImpliesAffine#1
Theorem name: lemLinearImpliesAffine
Lean tactic class: arithmetic_norm_num
-/

theorem lemLinearImpliesAffine (L : NoFTLObj) (h1 : linear L) : affine L := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemTranslationImpliesAffine#1
Theorem name: lemTranslationImpliesAffine
Lean tactic class: arithmetic_norm_num
-/

theorem lemTranslationImpliesAffine (T : NoFTLObj) (h1 : translation T) : affine T := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineDiff#1
Theorem name: lemAffineDiff
Lean tactic class: arithmetic_norm_num
-/

theorem lemAffineDiff (A : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) (L : NoFTLObj) (h1 : linear L) (h2 : ∃ T, ((translation T) ∧ (A = composeRel T L))) : ((A p) - (A q)) = L (p - q) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineImpliesTotalFunction#1
Theorem name: lemAffineImpliesTotalFunction
Lean tactic class: arithmetic_norm_num
-/

theorem lemAffineImpliesTotalFunction (A : NoFTLObj) (h1 : affine A) : isTotalFunction A := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineEqualAtBase#1
Theorem name: lemAffineEqualAtBase
Lean tactic class: arithmetic_norm_num
-/

theorem lemAffineEqualAtBase (f : NoFTLObj → NoFTLObj) (x : NoFTLObj) (A : NoFTLObj) (h1 : affineApprox A f x) : ∀ y, (f x = y) ↔ (y = A x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineOfPointOnLine#1
Theorem name: lemAffineOfPointOnLine
Lean tactic class: arithmetic_norm_num
-/

theorem lemAffineOfPointOnLine (A : NoFTLObj) (x : NoFTLObj) (b : NoFTLObj) (a : NoFTLObj) (L : NoFTLObj) (d : NoFTLObj) (h1 : (linear L) ∧ (translation T) ∧ (A = composeRel T L)) (h2 : x = b + a * d) : A x = ((A b) + (a * (L d))) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineOfLineIsLine#1
Theorem name: lemAffineOfLineIsLine
Lean tactic class: arithmetic_norm_num
-/

theorem lemAffineOfLineIsLine (A : NoFTLObj) (l : NoFTLSet) (l' : NoFTLSet) (h1 : isLine l) : (applyAffineToLine A l l') ↔ (affine A ∧ l' = applyToSet (asFunc A) l) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemOnLineUnderAffine#1
Theorem name: lemOnLineUnderAffine
Lean tactic class: arithmetic_norm_num
-/

theorem lemOnLineUnderAffine (A : NoFTLObj) (p : NoFTLObj) (l : NoFTLSet) (h1 : (affine A) ∧ (onLine p l)) : onLine (A p) (applyToSet (asFunc A) l) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemLineJoiningUnderAffine#1
Theorem name: lemLineJoiningUnderAffine
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineJoiningUnderAffine (A : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) (h1 : affine A) : applyToSet (asFunc A) (lineJoining p q) = lineJoining (A p) (A q) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineIsCts#1
Theorem name: lemAffineIsCts
Lean tactic class: arithmetic_norm_num
-/

theorem lemAffineIsCts (A : NoFTLObj) (x : NoFTLObj) (h1 : affine A) : cts A x := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineContinuity#1
Theorem name: lemAffineContinuity
Lean tactic class: arithmetic_norm_num
-/

theorem lemAffineContinuity (A : NoFTLObj) (h1 : affine A) : ∀ x, ∀ ε, ε > 0 →  ∃ δ, δ > 0 ∧  ∀ p, (p within δ of x) → ((A p) within ε of (A x)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffOfAffIsAff#1
Theorem name: lemAffOfAffIsAff
Lean tactic class: arithmetic_norm_num
-/

theorem lemAffOfAffIsAff (B : NoFTLObj) (A : NoFTLObj) (h1 : (affine A) ∧ (affine B)) : affine (composeRel B A) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemInverseAffine#1
Theorem name: lemInverseAffine
Lean tactic class: arithmetic_norm_num
-/

theorem lemInverseAffine (A : NoFTLObj) (h1 : affInvertible A) : ∃ A', (affine A') ∧ (∀ p q, A p = q ↔ A' q = p) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineApproxDomainTranslation#1
Theorem name: lemAffineApproxDomainTranslation
Lean tactic class: arithmetic_norm_num
-/

theorem lemAffineApproxDomainTranslation (A : NoFTLObj) (T : NoFTLObj) (f : NoFTLObj) (T' : NoFTLObj) (x : NoFTLObj) (h1 : translation T) (h2 : affineApprox A f x) (h3 : ∀ p q, T p = q ↔ T' q = p) : affineApprox (composeRel A T) (composeRel f T) (T' x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineApproxRangeTranslation#1
Theorem name: lemAffineApproxRangeTranslation
Lean tactic class: arithmetic_norm_num
-/

theorem lemAffineApproxRangeTranslation (T : NoFTLObj) (A : NoFTLObj) (f : NoFTLObj) (x : NoFTLObj) (h1 : translation T) (h2 : affineApprox A f x) : affineApprox (composeRel T A) (composeRel T f) x := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineIdentity#1
Theorem name: lemAffineIdentity
Lean tactic class: arithmetic_norm_num
-/

theorem lemAffineIdentity (A : NoFTLObj) (id : NoFTLObj) (h1 : affine A) (h2 : e > 0) (h3 : ∀ y, (y within e of x) → (A y = y)) : A = id := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Affine
