import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Classification

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemDrtnLineJoining#1
Theorem name: lemDrtnLineJoining
Lean tactic class: arithmetic_norm_num
-/

theorem lemDrtnLineJoining (p : NoFTLObj) (x : NoFTLObj) (drtn : NoFTLSet → NoFTLSet) (l : NoFTLSet) (h1 : l = lineJoining x p) (h2 : x ≠ p) : (p - x) ∈ drtn l := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemVelocityLineJoining#1
Theorem name: lemVelocityLineJoining
Lean tactic class: arithmetic_norm_num
-/

theorem lemVelocityLineJoining (v : NoFTLObj) (lineVelocity : NoFTLSet → NoFTLSet) (l : NoFTLSet) (h1 : l = lineJoining x p) (h2 : v = velocityJoining origin (p x)) (h3 : x ≠ p) : v ∈ lineVelocity l := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemSlopeLineJoining#1
Theorem name: lemSlopeLineJoining
Lean tactic class: arithmetic_norm_num
-/

theorem lemSlopeLineJoining (lineSlopeFinite : NoFTLSet → Prop) (l : NoFTLSet) (slopeFinite : NoFTLObj → NoFTLObj → Prop) (p : NoFTLObj) (q : NoFTLObj) (h1 : l = lineJoining p q) (h2 : p ≠ q) : lineSlopeFinite l ↔ slopeFinite p q := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemVelocityJoiningUsingPoints#1
Theorem name: lemVelocityJoiningUsingPoints
Lean tactic class: arithmetic_norm_num
-/

theorem lemVelocityJoiningUsingPoints (velocityJoining : NoFTLObj → NoFTLObj → NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) (origin : NoFTLObj) (h1 : p ≠ q) : velocityJoining p q = velocityJoining origin (q-p) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineVelocityNonZeroImpliesFinite#1
Theorem name: lemLineVelocityNonZeroImpliesFinite
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineVelocityNonZeroImpliesFinite (lineSlopeFinite : NoFTLObj → Prop) (l : NoFTLObj) (h1 : u ∈ lineVelocity l) (h2 : sNorm2 u ≠ 0) : lineSlopeFinite l := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineVelocityUsingPoints#1
Theorem name: lemLineVelocityUsingPoints
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineVelocityUsingPoints (lineVelocity : NoFTLSet → NoFTLSet) (l : NoFTLSet) (velocityJoining : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) (h1 : slopeFinite p q) (h2 : onLine p l ∧ onLine q l) : lineVelocity l = { velocityJoining p q } := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemSNorm2VelocityJoining#1
Theorem name: lemSNorm2VelocityJoining
Lean tactic class: arithmetic_norm_num
-/

theorem lemSNorm2VelocityJoining (tval : NoFTLObj) (p : NoFTLObj) (x : NoFTLObj) (v : NoFTLObj) (sComponent : NoFTLObj → NoFTLObj) (h1 : slopeFinite x p) (h2 : v = velocityJoining x p) : sqr (tval p - tval x) * sNorm2 v = sNorm2 (sComponent (p-x)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemOrthogalSpaceVectorExists#1
Theorem name: lemOrthogalSpaceVectorExists
Lean tactic class: arithmetic_norm_num
-/

theorem lemOrthogalSpaceVectorExists (sOrigin : NoFTLObj) (s : NoFTLObj → NoFTLObj) (v : NoFTLObj) : ∃ w, (w ≠ sOrigin) ∧ (w *s v) = 0 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemNonParallelVectorsExist#1
Theorem name: lemNonParallelVectorsExist
Lean tactic class: arithmetic_norm_num
-/

theorem lemNonParallelVectorsExist (origin : NoFTLObj) (tval : NoFTLObj → NoFTLObj) (v : NoFTLObj) : ∃ w, ((w ≠ origin) ∧ (tval v = tval w)) ∧ (¬ (∃ α, (α ≠ 0) ∧ v = (α * w))) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConeContainsVertex#1
Theorem name: lemConeContainsVertex
Lean tactic class: needs_human
-/

theorem lemConeContainsVertex (regularCone : NoFTLObj → NoFTLObj → Prop) (x : NoFTLObj) : regularCone x x := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConesExist#1
Theorem name: lemConesExist
Lean tactic class: needs_human
-/

theorem lemConesExist (x : NoFTLObj) : regularConeSet x ≠ {} := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemRegularCone#1
Theorem name: lemRegularCone
Lean tactic class: arithmetic_norm_num
-/


def wolframStatementPlaceholder (_theoremId : String) (_sourceStatement : String) : Prop := True
theorem lemRegularCone (x : NoFTLObj) (p : NoFTLObj) (onRegularCone : NoFTLObj → NoFTLObj) (regularCone : NoFTLObj) : wolframStatementPlaceholder "No_FTL_observers_Gen_Rel.Classification.lemRegularCone#1" "shows \"((x = p) \\<or> onRegularCone x p) \\<longleftrightarrow> regularCone x p\"" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemSlopeInfiniteImpliesOutside#1
Theorem name: lemSlopeInfiniteImpliesOutside
Lean tactic class: arithmetic_norm_num
-/

theorem lemSlopeInfiniteImpliesOutside (p : NoFTLObj) (x : NoFTLObj) (h1 : x ≠ p) (h2 : slopeInfinite x p) : ∃ l p', (p' ≠ p) ∧ onLine p' l ∧ onLine p l ∧ (l ∩ regularConeSet x = {}) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemClassification#1
Theorem name: lemClassification
Lean tactic class: needs_human
-/


def wolframStatementPlaceholder (_theoremId : String) (_sourceStatement : String) : Prop := True
theorem lemClassification (x : NoFTLObj) (p : NoFTLObj) (vertex : NoFTLObj → NoFTLObj) (outsideRegularCone : NoFTLObj → NoFTLObj) (onRegularCone : NoFTLObj → NoFTLObj → Prop) : wolframStatementPlaceholder "No_FTL_observers_Gen_Rel.Classification.lemClassification#1" "shows \"(insideRegularCone x p) \\<or> (vertex x p \\<or> outsideRegularCone x p \\<or> onRegularCone x p)\"" := by
  sorry  -- compile-safe placeholder preserving theorem/source identity




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemQuadCoordinates#1
Theorem name: lemQuadCoordinates
Lean tactic class: arithmetic_norm_num
-/

theorem lemQuadCoordinates (tval : NoFTLObj → NoFTLObj) (p : NoFTLObj) (x : NoFTLObj) (sComponent : NoFTLObj → NoFTLObj) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (h1 : p = (B ( D))) (h2 : a = mNorm^2 D) (h3 : b = 2*(tval (Bx))*(tval D) - 2*((sComponent D) s (sComponent (Bx)))) (h4 : c = mNorm^2 (Bx)) : sqr (tval (p-x)) - sNorm2 (sComponent (p-x)) = a*(sqr α) + b*α + c := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates#1
Theorem name: lemConeCoordinates
Lean tactic class: arithmetic_norm_num
-/


def wolframStatementPlaceholder (_theoremId : String) (_sourceStatement : String) : Prop := True
theorem lemConeCoordinates (onRegularCone : NoFTLObj → NoFTLObj) (x : NoFTLObj) (p : NoFTLObj) (tval : NoFTLObj) (sComponent : NoFTLObj → NoFTLObj) (outsideRegularCone : NoFTLObj → NoFTLObj) : wolframStatementPlaceholder "No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates#1" "shows \"(onRegularCone x p \\<longleftrightarrow> sqr (tval p - tval x) = sNorm2 (sComponent (p\\<ominus>x))) \\<and> (insideRegularCone x p \\<longleftrightarrow> sqr (tval p - tval x) > sNorm2 (sComponent (p\\<ominus>x))) \\<and> (outsideRegu..." := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates1#1
Theorem name: lemConeCoordinates1
Lean tactic class: arithmetic_norm_num
-/

theorem lemConeCoordinates1 (p : NoFTLObj) (x : NoFTLObj) (tval : NoFTLObj) : p ∈ regularConeSet x ↔ norm2 (p-x) = 2 * sqr (tval p - tval x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemWhereLineMeetsCone#1
Theorem name: lemWhereLineMeetsCone
Lean tactic class: arithmetic_norm_num
-/

theorem lemWhereLineMeetsCone (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (regularCone : NoFTLObj → NoFTLObj → Prop) (x : NoFTLObj) (B : NoFTLObj) (D : NoFTLObj) (h1 : a = mNorm^2 D) (h2 : b = 2*(tval (Bx))*(tval D) - 2*((sComponent D) s (sComponent (Bx)))) (h3 : c = mNorm^2 (Bx)) : qroot a b c α ↔ regularCone x (B + (α*D)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone1#1
Theorem name: lemLineMeetsCone1
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineMeetsCone1 (qcase1 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (S : NoFTLSet) (B : NoFTLObj) (h1 : ¬ (x ∈ l)) (h2 : isLine l) (h3 : S = l ∩ regularConeSet x) (l : l = line B D) (X : X = (B x)) (a : a = mNorm^2 D) (b : b = 2*(tval X)*(tval D) - 2*((sComponent D) s (sComponent X))) (c : c = mNorm^2 X) : (qcase1 a b c → S = setOf' (fun q => q = B)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone2#1
Theorem name: lemLineMeetsCone2
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineMeetsCone2 (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (S : NoFTLSet) (h1 : ¬ (x ∈ l)) (h2 : isLine l) (h3 : S = l ∩ regularConeSet x) (l : l = line B D) (X : X = (B x)) (h4 : a = mNorm^2 D) (h5 : b = 2*(tval (Bx))*(tval D) - 2*((sComponent D) s (sComponent (Bx)))) (h6 : c = mNorm^2 (Bx)) : qcase^2 a b c → S = {} := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone3#1
Theorem name: lemLineMeetsCone3
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineMeetsCone3 (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (S : NoFTLSet) (h1 : ¬ (x ∈ l)) (h2 : isLine l) (h3 : S = l ∩ regularConeSet x) (l : l = line B D) (X : X = (B x)) (a : a = mNorm^2 D) (b : b = 2*(tval X)*(tval D) - 2*((sComponent D) s (sComponent X))) (c : c = sqr (tval X) - sNorm2 (sComponent X)) (y3 : y^3 = (B ((-c/b)D))) : qcase^3 a b c → S = setOf' (fun q => q = y^3) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone4#1
Theorem name: lemLineMeetsCone4
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineMeetsCone4 (qcase4 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (S : NoFTLSet) (h1 : ¬ (x ∈ l)) (h2 : isLine l) (h3 : S = l ∩ regularConeSet x) (l : l = line B D) (X : X = (B x)) (a : a = mNorm^2 D) (b : b = 2*(tval X)*(tval D) - 2*((sComponent D) s (sComponent X))) (c : c = sqr (tval X) - sNorm2 (sComponent X)) : (qcase4 a b c → S = {}) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone5#1
Theorem name: lemLineMeetsCone5
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineMeetsCone5 (qcase5 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (S : NoFTLSet) (y5 : NoFTLObj) (h1 : ¬ (x ∈ l)) (h2 : isLine l) (h3 : S = l ∩ regularConeSet x) (l : l = line B D) (X : X = (B x)) (a : a = mNorm^2 D) (b : b = 2*(tval X)*(tval D) - 2*((sComponent D) s (sComponent X))) (c : c = sqr (tval X) - sNorm2 (sComponent X)) (y5 : y5 = (B ((-b/(2*a))D))) : (qcase5 a b c → S = setOf' (fun q => q = y5)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone6#1
Theorem name: lemLineMeetsCone6
Lean tactic class: arithmetic_norm_num
-/


def wolframStatementPlaceholder (_theoremId : String) (_sourceStatement : String) : Prop := True
theorem lemLineMeetsCone6 (qcase6 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (ym : NoFTLObj) (yp : NoFTLObj) (S : NoFTLSet) (h1 : ¬ (x ∈ l)) (h2 : isLine l) (h3 : S = l ∩ regularConeSet x) (l : l = line B D) (X : X = (B x)) (a : a = mNorm^2 D) (b : b = 2*(tval X)*(tval D) - 2*((sComponent D) s (sComponent X))) (c : c = sqr (tval X) - sNorm2 (sComponent X)) (ym : ym = (B (((-b - (sqrt (discriminant a b c))) / (2*a)) D))) (yp : yp = (B (((-b + (sqrt (discriminant a b c))) / (2*a)) D))) : wolframStatementPlaceholder "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone6#1" "assumes \"\\<not> (x \\<in> l)\" and \"isLine l\" and \"S = l \\<inter> regularConeSet x\" and l: \"l = line B D\" and X: \"X = (B \\<ominus> x)\" and a: \"a = mNorm2 D\" and b: \"b = 2*(tval X)*(tval D) - 2*((sComponent D) \\<odot>s (sComponent X))\" and ..." := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConeLemma1#1
Theorem name: lemConeLemma1
Lean tactic class: arithmetic_norm_num
-/

theorem lemConeLemma1 (S : NoFTLSet) (h1 : ¬ (x ∈ l)) (h2 : isLine l) (h3 : S = l ∩ regularConeSet x) : finite S ∧ card S ≤ 2 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConeLemma2#1
Theorem name: lemConeLemma2
Lean tactic class: arithmetic_norm_num
-/

theorem lemConeLemma2 (w : NoFTLObj) (x : NoFTLObj) (h1 : ¬ (regularCone x w)) : ∃ l, (onLine w l) ∧ (¬ (x ∈ l)) ∧ (card (l ∩ (regularConeSet x)) = 2) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineInsideRegularConeHasFiniteSlope#1
Theorem name: lemLineInsideRegularConeHasFiniteSlope
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineInsideRegularConeHasFiniteSlope (lineSlopeFinite : NoFTLSet → Prop) (l : NoFTLSet) (h1 : insideRegularCone x p) (h2 : l = lineJoining x p) : lineSlopeFinite l := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemInvertibleOnMeet#1
Theorem name: lemInvertibleOnMeet
Lean tactic class: arithmetic_norm_num
-/

theorem lemInvertibleOnMeet (f : NoFTLObj) (S : NoFTLSet) (A : NoFTLSet) (B : NoFTLSet) (h1 : invertible f) (h2 : S = A ∩ B) : applyToSet (asFunc f) S = (applyToSet (asFunc f) A) ∩ (applyToSet (asFunc f) B) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemInsideCone#1
Theorem name: lemInsideCone
Lean tactic class: needs_human
-/


def wolframStatementPlaceholder (_theoremId : String) (_sourceStatement : String) : Prop := True
theorem lemInsideCone (x : NoFTLObj) (p : NoFTLObj) (vertex : NoFTLObj → NoFTLObj) (outsideRegularCone : NoFTLObj → NoFTLObj) (onRegularCone : NoFTLObj → NoFTLObj → Prop) : wolframStatementPlaceholder "No_FTL_observers_Gen_Rel.Classification.lemInsideCone#1" "shows \"insideRegularCone x p \\<longleftrightarrow> \\<not>(vertex x p \\<or> outsideRegularCone x p \\<or> onRegularCone x p)\"" := by
  sorry  -- compile-safe placeholder preserving theorem/source identity




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemOnRegularConeIff#1
Theorem name: lemOnRegularConeIff
Lean tactic class: arithmetic_norm_num
-/

theorem lemOnRegularConeIff (onRegularCone : NoFTLObj → NoFTLObj) (x : NoFTLObj) (p : NoFTLObj) (l : NoFTLSet) (h1 : l = lineJoining x p) : (onRegularCone x = p)↔ (l ∩ regularConeSet x = l) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemOutsideRegularConeImplies#1
Theorem name: lemOutsideRegularConeImplies
Lean tactic class: arithmetic_norm_num
-/

theorem lemOutsideRegularConeImplies (outsideRegularCone : NoFTLObj → NoFTLObj) (x : NoFTLObj) (p : NoFTLObj) : (outsideRegularCone x = p)→ (∃ l p', (p' ≠ p) ∧ onLine p' l ∧ onLine p l ∧ (l ∩ regularConeSet x = {})) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemTimelikeInsideCone#1
Theorem name: lemTimelikeInsideCone
Lean tactic class: arithmetic_norm_num
-/

theorem lemTimelikeInsideCone (timelike : NoFTLObj → Prop) (p : NoFTLObj) (x : NoFTLObj) (h1 : insideRegularCone x p) : timelike (p - x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Classification
