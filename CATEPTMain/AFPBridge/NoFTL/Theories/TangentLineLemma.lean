import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.TangentLineLemma

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTImpliesFunction#1
Theorem name: lemWVTImpliesFunction
Lean tactic class: needs_human
-/

theorem lemWVTImpliesFunction (k : NoFTLObj) (h : NoFTLObj) : isFunction (toFunc (wvt k h)) := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTCts#1
Theorem name: lemWVTCts
Lean tactic class: arithmetic_norm_num
-/

theorem lemWVTCts (h : NoFTLObj) (k : NoFTLObj) (p : NoFTLObj) (h1 : definedAt (toFunc (wvt h k)) p) : cts (toFunc (wvt h k)) p := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverse#1
Theorem name: lemWVTInverse
Lean tactic class: arithmetic_norm_num
-/

theorem lemWVTInverse (k : NoFTLObj) (h : NoFTLObj) : invFunc (toFunc (wvt k h)) = toFunc (wvt h k) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverseCts#1
Theorem name: lemWVTInverseCts
Lean tactic class: arithmetic_norm_num
-/

theorem lemWVTInverseCts (h : NoFTLObj) (k : NoFTLObj) (q : NoFTLObj) (h1 : wvtFunc k h p q) : cts (toFunc (wvt h k)) q := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInjective#1
Theorem name: lemWVTInjective
Lean tactic class: needs_human
-/

theorem lemWVTInjective (k : NoFTLObj) (h : NoFTLObj) : injective (toFunc (wvt k h)) := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemPresentation#1
Theorem name: lemPresentation
Lean tactic class: arithmetic_norm_num
-/

theorem lemPresentation (tangentLine : NoFTLSet → NoFTLObj → NoFTLObj → Prop) (l' : NoFTLSet) (k : NoFTLObj) (b : NoFTLObj) (y : NoFTLObj) (h1 : x ∈ wline m b) (h2 : tangentLine l (wline m b) x) (h3 : affineApprox A (toFunc (wvt m k)) x) (h4 : wvtFunc m k x y) (h5 : applyAffineToLine A l l') : tangentLine l' (wline k b) y := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLines#1
Theorem name: lemTangentLines
Lean tactic class: arithmetic_norm_num
-/

theorem lemTangentLines (tl : NoFTLSet → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (l' : NoFTLSet) (k : NoFTLObj) (b : NoFTLObj) (y : NoFTLObj) (h1 : affineApprox A (toFunc (wvt m k)) x) (h2 : tl l m b x) (h3 : applyAffineToLine A l l') (h4 : wvtFunc m k x y) : tl l' k b y := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemSelfTangentIsTimeAxis#1
Theorem name: lemSelfTangentIsTimeAxis
Lean tactic class: arithmetic_norm_num
-/

theorem lemSelfTangentIsTimeAxis (l : NoFTLSet) (timeAxis : NoFTLSet) (h1 : tangentLine l (wline k k) x) : l = timeAxis := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLineUnique#1
Theorem name: lemTangentLineUnique
Lean tactic class: arithmetic_norm_num
-/

theorem lemTangentLineUnique (l1 : NoFTLSet) (h1 : tl l1 m k x) (h2 : tl l2 m k x) (h3 : affineApprox A (toFunc (wvt m k)) x) (h4 : wvtFunc m k x y) (h5 : x ∈ wline m k) : l1 = l2 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.TangentLineLemma
