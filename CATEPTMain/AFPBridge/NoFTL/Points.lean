import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Points

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNorm2Decomposition#1
Theorem name: lemNorm2Decomposition
Lean tactic class: arithmetic_norm_num
-/

theorem lemNorm2Decomposition (u : NoFTLObj) : norm2 u = sqr (tval u) + sNorm2 (sComponent u) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemPointDecomposition#1
Theorem name: lemPointDecomposition
Lean tactic class: arithmetic_norm_num
-/

theorem lemPointDecomposition (p : NoFTLObj) (tval : NoFTLObj → NoFTLObj) (tUnit : NoFTLObj) (xval : NoFTLObj → NoFTLObj) (xUnit : NoFTLObj) (yval : NoFTLObj → NoFTLObj) (yUnit : NoFTLObj) (zval : NoFTLObj → NoFTLObj) (zUnit : NoFTLObj) : p = (((tval p) * tUnit) + (((xval p) * xUnit) + (((yval p) * yUnit) + ((zval p) * zUnit)))) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleLeftSumDistrib#1
Theorem name: lemScaleLeftSumDistrib
Lean tactic class: arithmetic_norm_num
-/

theorem lemScaleLeftSumDistrib (a : NoFTLObj) (b : NoFTLObj) (p : NoFTLObj) : ((a + b) * p) = ((a * p) + (b * p)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleLeftDiffDistrib#1
Theorem name: lemScaleLeftDiffDistrib
Lean tactic class: arithmetic_norm_num
-/

theorem lemScaleLeftDiffDistrib (a : NoFTLObj) (b : NoFTLObj) (p : NoFTLObj) : ((a - b) * p) = ((a * p) - (b * p)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleAssoc#1
Theorem name: lemScaleAssoc
Lean tactic class: arithmetic_norm_num
-/

theorem lemScaleAssoc (p : NoFTLObj) : (α * (β * p)) = ((α * β) * p) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleCommute#1
Theorem name: lemScaleCommute
Lean tactic class: arithmetic_norm_num
-/

theorem lemScaleCommute (p : NoFTLObj) : (α * (β * p)) = (β * (α * p)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleDistribSum#1
Theorem name: lemScaleDistribSum
Lean tactic class: arithmetic_norm_num
-/

theorem lemScaleDistribSum (p : NoFTLObj) (q : NoFTLObj) : (α * (p + q)) = ((α*p) + (α*q)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleDistribDiff#1
Theorem name: lemScaleDistribDiff
Lean tactic class: arithmetic_norm_num
-/

theorem lemScaleDistribDiff (p : NoFTLObj) (q : NoFTLObj) : (α * (p - q)) = ((α*p) - (α*q)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleOrigin#1
Theorem name: lemScaleOrigin
Lean tactic class: arithmetic_norm_num
-/

theorem lemScaleOrigin (origin : NoFTLObj) : (α * origin) = origin := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemMNorm2OfScaled#1
Theorem name: lemMNorm2OfScaled
Lean tactic class: arithmetic_norm_num
-/

theorem lemMNorm2OfScaled (scaleBy : NoFTLObj) (p : NoFTLObj) : mNorm2 (scaleBy α p) = (sqr α) * mNorm2 p := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSNorm2OfScaled#1
Theorem name: lemSNorm2OfScaled
Lean tactic class: arithmetic_norm_num
-/

theorem lemSNorm2OfScaled (sScaleBy : NoFTLObj) (p : NoFTLObj) : sNorm2 (sScaleBy α p) = (sqr α) * sNorm2 p := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNorm2OfScaled#1
Theorem name: lemNorm2OfScaled
Lean tactic class: arithmetic_norm_num
-/

theorem lemNorm2OfScaled (p : NoFTLObj) : norm2 (α * p) = (sqr α) * norm2 p := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleSep2#1
Theorem name: lemScaleSep2
Lean tactic class: arithmetic_norm_num
-/

theorem lemScaleSep2 (a : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) : (sqr a) * (sep2 p q) = sep2 (a * p) (a * q) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSScaleAssoc#1
Theorem name: lemSScaleAssoc
Lean tactic class: arithmetic_norm_num
-/

theorem lemSScaleAssoc (s : NoFTLObj → NoFTLObj) (p : NoFTLObj) : (α *s (β *s p)) = ((α * β) *s p) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleBall#1
Theorem name: lemScaleBall
Lean tactic class: arithmetic_norm_num
-/

theorem lemScaleBall (a : NoFTLObj) (x : NoFTLObj) (e : NoFTLObj) (y : NoFTLObj) (h1 : x within e of y) (h2 : a ≠ 0) : withinOf (a * x) (a * e) (a * y) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleBallAndBoundary#1
Theorem name: lemScaleBallAndBoundary
Lean tactic class: arithmetic_norm_num
-/

theorem lemScaleBallAndBoundary (a : NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) (e : NoFTLObj) (h1 : sep2 x y ≤ sqr e) (h2 : a ≠ 0) : sep2 (a * x) (a * y) ≤ sqr (a * e) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemTimeAxisIsLine#1
Theorem name: lemTimeAxisIsLine
Lean tactic class: needs_human
-/

theorem lemTimeAxisIsLine (timeAxis : NoFTLSet) : isLine timeAxis := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSameLine#1
Theorem name: lemSameLine
Lean tactic class: arithmetic_norm_num
-/

theorem lemSameLine (sameLine : NoFTLObj → NoFTLObj → Prop) (line : NoFTLObj) (b : NoFTLObj) (d : NoFTLObj) (p : NoFTLObj) (h1 : p ∈ line b d) : sameLine (line b d) (line p d) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSSep2Symmetry#1
Theorem name: lemSSep2Symmetry
Lean tactic class: arithmetic_norm_num
-/

theorem lemSSep2Symmetry (p : NoFTLObj) (q : NoFTLObj) : sSep2 p q = sSep2 q p := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSep2Symmetry#1
Theorem name: lemSep2Symmetry
Lean tactic class: arithmetic_norm_num
-/

theorem lemSep2Symmetry (p : NoFTLObj) (q : NoFTLObj) : sep2 p q = sep2 q p := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSpatialNullImpliesSpatialOrigin#1
Theorem name: lemSpatialNullImpliesSpatialOrigin
Lean tactic class: arithmetic_norm_num
-/

theorem lemSpatialNullImpliesSpatialOrigin (s : NoFTLObj) (sOrigin : NoFTLObj) (h1 : sNorm2 s = 0) : s = sOrigin := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNorm2NonNeg#1
Theorem name: lemNorm2NonNeg
Lean tactic class: needs_human
-/

theorem lemNorm2NonNeg (p : NoFTLObj) : norm2 p ≥ 0 := by
  first | omega | norm_num | linarith | nlinarith | simp_all | decide | trivial | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNullImpliesOrigin#1
Theorem name: lemNullImpliesOrigin
Lean tactic class: arithmetic_norm_num
-/

theorem lemNullImpliesOrigin (p : NoFTLObj) (origin : NoFTLObj) (h1 : norm2 p = 0) : p = origin := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNotOriginImpliesPosNorm2#1
Theorem name: lemNotOriginImpliesPosNorm2
Lean tactic class: arithmetic_norm_num
-/

theorem lemNotOriginImpliesPosNorm2 (p : NoFTLObj) (h1 : p ≠ origin) : norm2 p > 0 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNotEqualImpliesSep2Pos#1
Theorem name: lemNotEqualImpliesSep2Pos
Lean tactic class: arithmetic_norm_num
-/

theorem lemNotEqualImpliesSep2Pos (y : NoFTLObj) (x : NoFTLObj) (h1 : y ≠ x) : sep2 y x > 0 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemBallContainsCentre#1
Theorem name: lemBallContainsCentre
Lean tactic class: arithmetic_norm_num
-/

theorem lemBallContainsCentre (x : NoFTLObj) (h1 : ε > 0) : withinOf x ε x := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemPointLimit#1
Theorem name: lemPointLimit
Lean tactic class: arithmetic_norm_num
-/

theorem lemPointLimit (v : NoFTLObj) (u : NoFTLObj) (h1 : ∀ ε > 0, (v within ε of u)) : v = u := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemBallPopulated#1
Theorem name: lemBallPopulated
Lean tactic class: arithmetic_norm_num
-/

theorem lemBallPopulated (e : NoFTLObj) (x : NoFTLObj) (h1 : e > 0) : ∃ y, (y within e of x) ∧ (y ≠ x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemBallInBall#1
Theorem name: lemBallInBall
Lean tactic class: arithmetic_norm_num
-/

theorem lemBallInBall (p : NoFTLObj) (y : NoFTLObj) (q : NoFTLObj) (h1 : p within x of q) (h2 : 0 < x ∧ x ≤ y) : withinOf p y q := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSmallPoints#1
Theorem name: lemSmallPoints
Lean tactic class: arithmetic_norm_num
-/

theorem lemSmallPoints (p : NoFTLObj) (e : NoFTLObj) (h1 : e > 0) : ∃ a, a > 0 ∧  norm2 (a * p) < sqr e := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemLineJoiningContainsEndPoints#1
Theorem name: lemLineJoiningContainsEndPoints
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineJoiningContainsEndPoints (x : NoFTLObj) (l : NoFTLSet) (p : NoFTLObj) (h1 : l = lineJoining x p) : onLine x l ∧ onLine p l := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemLineAndPoints#1
Theorem name: lemLineAndPoints
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineAndPoints (p : NoFTLObj) (l : NoFTLSet) (q : NoFTLObj) (h1 : p ≠ q) : (onLine p l ∧ onLine q l) ↔ (l = lineJoining p q) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemLineDefinedByPair#1
Theorem name: lemLineDefinedByPair
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineDefinedByPair (l1 : NoFTLSet) (h1 : x ≠ p) (h2 : (onLine p l1) ∧ (onLine x l1)) (h3 : (onLine p l2) ∧ (onLine x l2)) : l1 = l2 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemDrtn#1
Theorem name: lemDrtn
Lean tactic class: arithmetic_norm_num
-/

theorem lemDrtn (d2 : NoFTLObj) (d1 : NoFTLObj) (h1 : { d1, d2 } ⊆ drtn l) : ∃ α ≠ 0, d2 = (α * d1) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemLineDeterminedByPointAndDrtn#1
Theorem name: lemLineDeterminedByPointAndDrtn
Lean tactic class: arithmetic_norm_num
-/

theorem lemLineDeterminedByPointAndDrtn (l1 : NoFTLSet) (h1 : (x ≠ p) ∧ (p ∈ l1) ∧ (onLine x l1) ∧ (onLine x l2)) (h2 : drtn l1 = drtn l2) : l1 = l2 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Points
