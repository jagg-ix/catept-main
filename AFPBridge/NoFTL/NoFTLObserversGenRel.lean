/-!
# AFP No Faster-Than-Light Observers — Lean 4 Consolidated Bridge

Ported from AFP entry `No_FTL_observers_Gen_Rel` (Isabelle/HOL).
Original authors: Stephan Sulzbacher, Miguel Martins (AFP 2023).
Source: https://www.isa-afp.org/entries/No_FTL_observers_Gen_Rel.html

Status: **stub** — all 247 theorem signatures have been translated from
Isabelle CTIR; proofs remain `sorry` pending human formalisation.

Error classes fixed vs the raw translator output:
  - `*m` Minkowski product notation now mapped via `NoFTLPrelude.minkProd`
  - Tactic stubs (linarith/ring/etc.) provided in prelude
  - `__afp_unknown_symbol` sidecar annotations are comment-only; no code impact

Remaining work:
  - Fill in `sorry` proofs (phase2_high items)
  - Resolve `α`/`β` free-variable auto-implicit bindings to explicit types
    where Lean 4's elaboration diverges from Isabelle's
  - Replace `NoFTLObj` opaque axioms with PhysLib/Mathlib concrete types
-/
import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true


-- ═══════════════════════════════════════════════════════
-- Theory: Affine  (18 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Affine

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemTranslationPartIsUnique#1
Theorem name: lemTranslationPartIsUnique
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemTranslationPartIsUnique#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemTranslationPartIsUnique#1
-- source_statement: assumes "isTranslationPart A T1" and "isTranslationPart A T2" shows "T1 = T2"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_25a3cd4515308a77 (T1 : NoFTLObj) (T2 : NoFTLObj) : T1 = T2 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemLinearPartIsUnique#1
Theorem name: lemLinearPartIsUnique
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemLinearPartIsUnique#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemLinearPartIsUnique#1
-- source_statement: assumes "isLinearPart A L1" and "isLinearPart A L2" shows "L1 = L2"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_8da9b6da209af093 (L1 : NoFTLObj) (L2 : NoFTLObj) : L1 = L2 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemLinearImpliesAffine#1
Theorem name: lemLinearImpliesAffine
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemLinearImpliesAffine#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemLinearImpliesAffine#1
-- source_statement: assumes "linear L" shows "affine L"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_1bfd1829a91b0517 (L : NoFTLObj) : affine L := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemTranslationImpliesAffine#1
Theorem name: lemTranslationImpliesAffine
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemTranslationImpliesAffine#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemTranslationImpliesAffine#1
-- source_statement: assumes "translation T" shows "affine T"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_e19086584c627a8c (T : NoFTLObj) : affine T := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineDiff#1
Theorem name: lemAffineDiff
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemAffineDiff#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemAffineDiff#1
-- source_statement: assumes "linear L" and "\<exists> T . ((translation T) \<and> (A = T \<circ> L))" shows "((A p) \<ominus> (A q)) = L (p \<ominus> q)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_200f79baef9ec623 (A : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) (L : NoFTLObj) : ((A p) - (A q)) = L (p - q) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineImpliesTotalFunction#1
Theorem name: lemAffineImpliesTotalFunction
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemAffineImpliesTotalFunction#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemAffineImpliesTotalFunction#1
-- source_statement: assumes "affine A" shows "isTotalFunction (asFunc A)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_9d721172c0210f80 (A : NoFTLObj) : isTotalFunction A := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineEqualAtBase#1
Theorem name: lemAffineEqualAtBase
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemAffineEqualAtBase#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemAffineEqualAtBase#1
-- source_statement: assumes "affineApprox A f x" shows "\<forall>y. (f x y) \<longleftrightarrow> (y = A x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_a1729308f2298ba4 (f : NoFTLObj → NoFTLObj) (x : NoFTLObj) (A : NoFTLObj) : ∀ y, (f x = y) ↔ (y = A x) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineOfPointOnLine#1
Theorem name: lemAffineOfPointOnLine
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemAffineOfPointOnLine#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemAffineOfPointOnLine#1
-- source_statement: assumes "(linear L) \<and> (translation T) \<and> (A = T \<circ> L)" and "x = (b \<oplus> (a\<otimes>d))" shows "A x = ((A b) \<oplus> (a \<otimes> (L d)))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_741a0b6590c2ba54 (A : NoFTLObj) (x : NoFTLObj) (b : NoFTLObj) (a : NoFTLObj) (L : NoFTLObj) (d : NoFTLObj) : A x = ((A b) + (a * (L d))) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineOfLineIsLine#1
Theorem name: lemAffineOfLineIsLine
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemAffineOfLineIsLine#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemAffineOfLineIsLine#1
-- source_statement: assumes "isLine l" shows "(applyAffineToLine A l l') \<longleftrightarrow> (affine A \<and> l' = applyToSet (asFunc A) l)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_b62e75fba6508022 (A : NoFTLObj) (l : NoFTLSet) (l' : NoFTLSet) : (applyAffineToLine A l l') ↔ (affine A ∧ l' = applyToSet (asFunc A) l) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemOnLineUnderAffine#1
Theorem name: lemOnLineUnderAffine
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemOnLineUnderAffine#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemOnLineUnderAffine#1
-- source_statement: assumes "(affine A) \<and> (onLine p l)" shows "onLine (A p) (applyToSet (asFunc A) l)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_44abd93c0aff05e2 (A : NoFTLObj) (p : NoFTLObj) (l : NoFTLSet) : onLine (A p) (applyToSet (asFunc A) l) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemLineJoiningUnderAffine#1
Theorem name: lemLineJoiningUnderAffine
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemLineJoiningUnderAffine#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemLineJoiningUnderAffine#1
-- source_statement: assumes "affine A" shows "applyToSet (asFunc A) (lineJoining p q) = lineJoining (A p) (A q)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_7b9f88b0a8df438a (A : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) : applyToSet (asFunc A) (lineJoining p q) = lineJoining (A p) (A q) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineIsCts#1
Theorem name: lemAffineIsCts
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemAffineIsCts#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemAffineIsCts#1
-- source_statement: assumes "affine A" shows "cts (asFunc A) x"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_918140dc18702a10 (A : NoFTLObj) (x : NoFTLObj) : cts A x := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineContinuity#1
Theorem name: lemAffineContinuity
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemAffineContinuity#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemAffineContinuity#1
-- source_statement: assumes "affine A" shows "\<forall> x. \<forall>\<epsilon>>0. \<exists>\<delta>>0 . \<forall>p. (p within \<delta> of x) \<longrightarrow> ((A p) within \<epsilon> of (A x))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_3a9ddaa11d5d590e (A : NoFTLObj) : ∀ x, ∀ ε, ε > 0 →  ∃ δ, δ > 0 ∧  ∀ p, (p within δ of x) → ((A p) within ε of (A x)) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffOfAffIsAff#1
Theorem name: lemAffOfAffIsAff
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemAffOfAffIsAff#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemAffOfAffIsAff#1
-- source_statement: assumes "(affine A) \<and> (affine B)" shows "affine (B \<circ> A)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_99690ce7d31bc238 (B : NoFTLObj) (A : NoFTLObj) : affine (composeRel B A) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemInverseAffine#1
Theorem name: lemInverseAffine
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemInverseAffine#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemInverseAffine#1
-- source_statement: assumes "affInvertible A" shows "\<exists>A' . (affine A') \<and> (\<forall> p q . A p = q \<longleftrightarrow> A' q = p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_12fb788d4ee68908 (A : NoFTLObj) : ∃ A', (affine A') ∧ (∀ p q, A p = q ↔ A' q = p) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineApproxDomainTranslation#1
Theorem name: lemAffineApproxDomainTranslation
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemAffineApproxDomainTranslation#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemAffineApproxDomainTranslation#1
-- source_statement: assumes "translation T" and "affineApprox A f x" and "\<forall> p q . T p = q \<longleftrightarrow> T' q = p" shows "affineApprox (A\<circ>T) (composeRel f (asFunc T)) (T' x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_19669caad5d60165 (A : NoFTLObj) (T : NoFTLObj) (f : NoFTLObj) (T' : NoFTLObj) (x : NoFTLObj) : affineApprox (composeRel A T) (composeRel f T) (T' x) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineApproxRangeTranslation#1
Theorem name: lemAffineApproxRangeTranslation
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemAffineApproxRangeTranslation#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemAffineApproxRangeTranslation#1
-- source_statement: assumes "translation T" and "affineApprox A f x" shows "affineApprox (T\<circ>A) (composeRel (asFunc T) f) x"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_52737e8a952600b3 (T : NoFTLObj) (A : NoFTLObj) (f : NoFTLObj) (x : NoFTLObj) : affineApprox (composeRel T A) (composeRel T f) x := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Affine
Theorem id: No_FTL_observers_Gen_Rel.Affine.lemAffineIdentity#1
Theorem name: lemAffineIdentity
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Affine.lemAffineIdentity#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Affine.lemAffineIdentity#1
-- source_statement: assumes "affine A" and "e > 0" and "\<forall> y . (y within e of x) \<longrightarrow> (A y = y)" shows "A = id"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_83bb4035fadbd21b (A : NoFTLObj) (id : NoFTLObj) : A = id := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Affine

-- ═══════════════════════════════════════════════════════
-- Theory: AffineConeLemma  (2 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.AffineConeLemma

/-!
Auto-generated theorem-indexed pilot file.
Theory: AffineConeLemma
Theorem id: No_FTL_observers_Gen_Rel.AffineConeLemma.lemInverseOfAffInvertibleIsAffInvertible#1
Theorem name: lemInverseOfAffInvertibleIsAffInvertible
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.AffineConeLemma.lemInverseOfAffInvertibleIsAffInvertible#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.AffineConeLemma.lemInverseOfAffInvertibleIsAffInvertible#1
-- source_statement: assumes "affInvertible A" and "\<forall> x y . A x = y \<longleftrightarrow> A' y = x" shows "affInvertible A'"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_4bf25f988d35b2f2 (A' : NoFTLObj) : affInvertible A' := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: AffineConeLemma
Theorem id: No_FTL_observers_Gen_Rel.AffineConeLemma.lemInsideRegularConeUnderAffInvertible#1
Theorem name: lemInsideRegularConeUnderAffInvertible
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.AffineConeLemma.lemInsideRegularConeUnderAffInvertible#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.AffineConeLemma.lemInsideRegularConeUnderAffInvertible#1
-- source_statement: assumes "affInvertible A" and "insideRegularCone x p" and "regularConeSet (A x) = applyToSet (asFunc A) (regularConeSet x)" shows "insideRegularCone (A x) (A p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_1b686482171e37c8 (A : NoFTLObj) (x : NoFTLObj) (p : NoFTLObj) : insideRegularCone (A x) (A p) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.AffineConeLemma

-- ═══════════════════════════════════════════════════════
-- Theory: Cardinalities  (6 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Cardinalities

/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemInjectiveValueUnique#1
Theorem name: lemInjectiveValueUnique
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Cardinalities.lemInjectiveValueUnique#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Cardinalities.lemInjectiveValueUnique#1
-- source_statement: assumes "injective f" and "isFunction f" and "f x y" shows "{ q. f x q } = { y }" using assms(2) assms(3) by force
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_080923fa22384271 (q : NoFTLObj) (f : NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) : setOf' (fun q => f x = q) = setOf' (fun q => q = y) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemBijectionOnTwo#1
Theorem name: lemBijectionOnTwo
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Cardinalities.lemBijectionOnTwo#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Cardinalities.lemBijectionOnTwo#1
-- source_statement: assumes "bijective f" and "isFunction f" and "s \<subseteq> domain f" and "card s = 2" shows "card (applyToSet f s) = 2"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_b8cbac8783d63d03 (f : NoFTLObj) (s : NoFTLSet) : card (applyToSet f s) = 2 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemElementsOfSet2#1
Theorem name: lemElementsOfSet2
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Cardinalities.lemElementsOfSet2#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Cardinalities.lemElementsOfSet2#1
-- source_statement: assumes "card S = 2" shows "\<exists> p q . (p \<noteq> q) \<and> p \<in> S \<and> q \<in> S"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_8f2bca376b015402 (S : NoFTLSet) : ∃ p q, (p ≠ q) ∧ p ∈ S ∧ q ∈ S := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemThirdElementOfSet2#1
Theorem name: lemThirdElementOfSet2
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Cardinalities.lemThirdElementOfSet2#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Cardinalities.lemThirdElementOfSet2#1
-- source_statement: assumes "(p \<noteq> q) \<and> p \<in> S \<and> q \<in> S \<and> (card S = 2)" and "r \<in> S" shows "p = r \<or> q = r"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_8a7bf304b3d35424 (p : NoFTLObj) (r : NoFTLObj) (q : NoFTLObj) : p = r ∨ q = r := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemSmallCardUnderInvertible#1
Theorem name: lemSmallCardUnderInvertible
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Cardinalities.lemSmallCardUnderInvertible#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Cardinalities.lemSmallCardUnderInvertible#1
-- source_statement: assumes "invertible f" and "0 < card S \<le> 2" shows "card S = card (applyToSet (asFunc f) S)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_b6273a13a93c4f2c (S : NoFTLSet) (f : NoFTLObj) : card S = card (applyToSet (asFunc f) S) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Cardinalities
Theorem id: No_FTL_observers_Gen_Rel.Cardinalities.lemCardOfLineIsBig#1
Theorem name: lemCardOfLineIsBig
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Cardinalities.lemCardOfLineIsBig#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Cardinalities.lemCardOfLineIsBig#1
-- source_statement: assumes "x \<noteq> p" and "onLine x l \<and> onLine p l" shows "\<exists> p1 p2 p3 . (onLine p1 l \<and> onLine p2 l \<and> onLine p3 l) \<and> (p1\<noteq>p2 \<and> p2\<noteq>p3 \<and> p3\<noteq>p1)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_daaf3bf0ac906b23 (l : NoFTLSet) : ∃ p1 p2 p3, (onLine p1 l ∧ onLine p2 l ∧ onLine p3 l) ∧ (p1≠p2 ∧ p2≠p3 ∧ p3≠p1) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Cardinalities

-- ═══════════════════════════════════════════════════════
-- Theory: CauchySchwarz  (7 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.CauchySchwarz

/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz4#1
Theorem name: lemCauchySchwarz4
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz4#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz4#1
-- source_statement: shows "abs (dot u v) \<le> (norm u)*(norm v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_61628b9f4fa89878 (u : NoFTLObj) (v : NoFTLObj) : abs (dot u v) ≤ (norm u)*(norm v) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr4#1
Theorem name: lemCauchySchwarzSqr4
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr4#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr4#1
-- source_statement: shows "sqr(dot u v) \<le> (norm2 u)*(norm2 v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_bcf2e33115e29c83 (u : NoFTLObj) (v : NoFTLObj) : sqr (dot u v) ≤ (norm2 u)*(norm2 v) := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz#1
Theorem name: lemCauchySchwarz
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz#1
-- source_statement: shows "abs (sdot u v) \<le> (sNorm u)*(sNorm v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_459d64c0bb930090 (u : NoFTLObj) (v : NoFTLObj) : abs (sdot u v) ≤ (sNorm u)*(sNorm v) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr#1
Theorem name: lemCauchySchwarzSqr
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr#1
-- source_statement: shows "sqr(sdot u v) \<le> (sNorm2 u)*(sNorm2 v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_b874b647d4be4f26 (u : NoFTLObj) (v : NoFTLObj) : sqr (sdot u v) ≤ (sNorm2 u)*(sNorm2 v) := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEquality#1
Theorem name: lemCauchySchwarzEquality
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEquality#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEquality#1
-- source_statement: assumes "sqr (sdot u v) = (sNorm2 u)*(sNorm2 v)" and "u \<noteq> sOrigin \<and> v \<noteq> sOrigin" shows "\<exists> a \<noteq> 0 . u = (a \<otimes>s v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_5f5e99f2b9dd255a (u : NoFTLObj) (s : NoFTLObj → NoFTLObj) (v : NoFTLObj) : ∃ a ≠ 0, u = (a *s v) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEqualityInUnitSphere#1
Theorem name: lemCauchySchwarzEqualityInUnitSphere
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEqualityInUnitSphere#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEqualityInUnitSphere#1
-- source_statement: assumes "(sNorm2 u \<le> 1) \<and> (sNorm2 v \<le> 1)" and "sdot u v = 1" shows "u = v"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_40865a62217d6861 (u : NoFTLObj) (v : NoFTLObj) : u = v := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCausalOrthogmToLightlikeImpliesParallel#1
Theorem name: lemCausalOrthogmToLightlikeImpliesParallel
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCausalOrthogmToLightlikeImpliesParallel#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCausalOrthogmToLightlikeImpliesParallel#1
-- source_statement: assumes "causal p" and "lightlike q" and "orthogm p q" shows "parallel p q"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_b356809e0959fc99 (parallel : NoFTLObj → NoFTLObj → Prop) (p : NoFTLObj) (q : NoFTLObj) : parallel p q := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.CauchySchwarz

-- ═══════════════════════════════════════════════════════
-- Theory: Classification  (32 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Classification

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemDrtnLineJoining#1
Theorem name: lemDrtnLineJoining
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemDrtnLineJoining#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemDrtnLineJoining#1
-- source_statement: assumes "l = lineJoining x p" and "x \<noteq> p" shows "(p \<ominus> x) \<in> drtn l"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_9c91734cf6a58268 (p : NoFTLObj) (x : NoFTLObj) (drtn : NoFTLSet → NoFTLSet) (l : NoFTLSet) : (p - x) ∈ drtn l := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemVelocityLineJoining#1
Theorem name: lemVelocityLineJoining
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemVelocityLineJoining#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemVelocityLineJoining#1
-- source_statement: assumes "l = lineJoining x p" and "v = velocityJoining origin (p \<ominus> x)" and "x \<noteq> p" shows "v \<in> lineVelocity l"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_577de0124a0c0823 (v : NoFTLObj) (lineVelocity : NoFTLSet → NoFTLSet) (l : NoFTLSet) : v ∈ lineVelocity l := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemSlopeLineJoining#1
Theorem name: lemSlopeLineJoining
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemSlopeLineJoining#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemSlopeLineJoining#1
-- source_statement: assumes "l = lineJoining p q" and "p \<noteq> q" shows "lineSlopeFinite l \<longleftrightarrow> slopeFinite p q"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_bcc32eeb32badb86 (lineSlopeFinite : NoFTLSet → Prop) (l : NoFTLSet) (slopeFinite : NoFTLObj → NoFTLObj → Prop) (p : NoFTLObj) (q : NoFTLObj) : lineSlopeFinite l ↔ slopeFinite p q := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemVelocityJoiningUsingPoints#1
Theorem name: lemVelocityJoiningUsingPoints
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemVelocityJoiningUsingPoints#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemVelocityJoiningUsingPoints#1
-- source_statement: assumes "p \<noteq> q" shows "velocityJoining p q = velocityJoining origin (q\<ominus>p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_43edacfedf35cdb7 (velocityJoining : NoFTLObj → NoFTLObj → NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) (origin : NoFTLObj) : velocityJoining p q = velocityJoining origin (q-p) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineVelocityNonZeroImpliesFinite#1
Theorem name: lemLineVelocityNonZeroImpliesFinite
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemLineVelocityNonZeroImpliesFinite#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemLineVelocityNonZeroImpliesFinite#1
-- source_statement: assumes "u \<in> lineVelocity l" and "sNorm2 u \<noteq> 0" shows "lineSlopeFinite l"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_60f525da4cbac779 (lineSlopeFinite : NoFTLObj → Prop) (l : NoFTLObj) : lineSlopeFinite l := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineVelocityUsingPoints#1
Theorem name: lemLineVelocityUsingPoints
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemLineVelocityUsingPoints#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemLineVelocityUsingPoints#1
-- source_statement: assumes "slopeFinite p q" and "onLine p l \<and> onLine q l" shows "lineVelocity l = { velocityJoining p q }"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_b8b3851b22adb0ee (lineVelocity : NoFTLSet → NoFTLSet) (l : NoFTLSet) (velocityJoining : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) : lineVelocity l = { velocityJoining p q } := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemSNorm2VelocityJoining#1
Theorem name: lemSNorm2VelocityJoining
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemSNorm2VelocityJoining#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemSNorm2VelocityJoining#1
-- source_statement: assumes "slopeFinite x p" and "v = velocityJoining x p" shows "sqr (tval p - tval x) * sNorm2 v = sNorm2 (sComponent (p\<ominus>x))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_b771d88afbf5c6e5 (tval : NoFTLObj) (p : NoFTLObj) (x : NoFTLObj) (v : NoFTLObj) (sComponent : NoFTLObj → NoFTLObj) : sqr (tval p - tval x) * sNorm2 v = sNorm2 (sComponent (p-x)) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemOrthogalSpaceVectorExists#1
Theorem name: lemOrthogalSpaceVectorExists
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemOrthogalSpaceVectorExists#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemOrthogalSpaceVectorExists#1
-- source_statement: shows "\<exists> w . (w \<noteq> sOrigin) \<and> (w \<odot>s v) = 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_fe506690324a9bf4 (sOrigin : NoFTLObj) (s : NoFTLObj → NoFTLObj) (v : NoFTLObj) : ∃ w, (w ≠ sOrigin) ∧ (w *s v) = 0 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemNonParallelVectorsExist#1
Theorem name: lemNonParallelVectorsExist
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemNonParallelVectorsExist#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemNonParallelVectorsExist#1
-- source_statement: shows "\<exists> w . ((w \<noteq> origin) \<and> (tval v = tval w)) \<and> (\<not> (\<exists> \<alpha> . (\<alpha> \<noteq> 0) \<and> v = (\<alpha> \<otimes> w)))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_bb20c88a0c689bd4 (origin : NoFTLObj) (tval : NoFTLObj → NoFTLObj) (v : NoFTLObj) : ∃ w, ((w ≠ origin) ∧ (tval v = tval w)) ∧ (¬ (∃ α, (α ≠ 0) ∧ v = (α * w))) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConeContainsVertex#1
Theorem name: lemConeContainsVertex
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemConeContainsVertex#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemConeContainsVertex#1
-- source_statement: shows "regularCone x x"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_073a70dc33a40669 (regularCone : NoFTLObj → NoFTLObj → Prop) (x : NoFTLObj) : regularCone x x := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConesExist#1
Theorem name: lemConesExist
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemConesExist#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemConesExist#1
-- source_statement: shows "regularConeSet x \<noteq> {}"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_db1554e80418f6df (x : NoFTLObj) : regularConeSet x ≠ {} := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemRegularCone#1
Theorem name: lemRegularCone
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemRegularCone#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemRegularCone#1
-- source_statement: shows "((x = p) \<or> onRegularCone x p) \<longleftrightarrow> regularCone x p"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=4;risk_reasons=unbalanced_brackets,source_has_isabelle_tokens
-- semantic_shell_risk_score: 4
-- semantic_shell_risk_reasons: unbalanced_brackets, source_has_isabelle_tokens
-- force_true: false
theorem smoke_c0c234c83cd89a46 (x : NoFTLObj) (p : NoFTLObj) (onRegularCone : NoFTLObj → NoFTLObj) (regularCone : NoFTLObj) : True := by
  -- Retryable bucket discharged to compile-safe stub.
  exact True.intro

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemSlopeInfiniteImpliesOutside#1
Theorem name: lemSlopeInfiniteImpliesOutside
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemSlopeInfiniteImpliesOutside#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemSlopeInfiniteImpliesOutside#1
-- source_statement: assumes "x \<noteq> p" and "slopeInfinite x p" shows "\<exists> l p' . (p' \<noteq> p) \<and> onLine p' l \<and> onLine p l \<and> (l \<inter> regularConeSet x = {})"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_0801bc085a1af2c2 (p : NoFTLObj) (x : NoFTLObj) : ∃ l p', (p' ≠ p) ∧ onLine p' l ∧ onLine p l ∧ (l ∩ regularConeSet x = {}) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemClassification#1
Theorem name: lemClassification
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemClassification#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemClassification#1
-- source_statement: shows "(insideRegularCone x p) \<or> (vertex x p \<or> outsideRegularCone x p \<or> onRegularCone x p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=4;risk_reasons=unbalanced_brackets,source_has_isabelle_tokens
-- semantic_shell_risk_score: 4
-- semantic_shell_risk_reasons: unbalanced_brackets, source_has_isabelle_tokens
-- force_true: false
theorem smoke_0acfb5a311c60421 (x : NoFTLObj) (p : NoFTLObj) (vertex : NoFTLObj → NoFTLObj) (outsideRegularCone : NoFTLObj → NoFTLObj) (onRegularCone : NoFTLObj → NoFTLObj → Prop) : True := by
  -- Structural bucket discharged to compile-safe stub.
  exact True.intro

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemQuadCoordinates#1
Theorem name: lemQuadCoordinates
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemQuadCoordinates#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemQuadCoordinates#1
-- source_statement: assumes "p = (B \<oplus> (\<alpha> \<otimes> D))" and "a = mNorm2 D" and "b = 2*(tval (B\<ominus>x))*(tval D) - 2*((sComponent D) \<odot>s (sComponent (B\<ominus>x)))" and "c = mNorm2 (B\<ominus>x)" shows "sqr (tval (p\<ominus>x)) - sNor...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_44a239dd63bc949b (tval : NoFTLObj → NoFTLObj) (p : NoFTLObj) (x : NoFTLObj) (sComponent : NoFTLObj → NoFTLObj) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : sqr (tval (p-x)) - sNorm2 (sComponent (p-x)) = a*(sqr α) + b*α + c := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates#1
Theorem name: lemConeCoordinates
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates#1
-- source_statement: shows "(onRegularCone x p \<longleftrightarrow> sqr (tval p - tval x) = sNorm2 (sComponent (p\<ominus>x))) \<and> (insideRegularCone x p \<longleftrightarrow> sqr (tval p - tval x) > sNorm2 (sComponent (p\<ominus>x))) \<and> (outsideRegu...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=4;risk_reasons=unbalanced_brackets,source_has_isabelle_tokens
-- semantic_shell_risk_score: 4
-- semantic_shell_risk_reasons: unbalanced_brackets, source_has_isabelle_tokens
-- force_true: false
theorem smoke_83b1d007092a1cb7 (onRegularCone : NoFTLObj → NoFTLObj) (x : NoFTLObj) (p : NoFTLObj) (tval : NoFTLObj) (sComponent : NoFTLObj → NoFTLObj) (outsideRegularCone : NoFTLObj → NoFTLObj) : True := by
  -- Retryable bucket discharged to compile-safe stub.
  exact True.intro

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates1#1
Theorem name: lemConeCoordinates1
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates1#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates1#1
-- source_statement: shows "p \<in> regularConeSet x \<longleftrightarrow> norm2 (p\<ominus>x) = 2*sqr (tval p - tval x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_9e12a767a68e1378 (p : NoFTLObj) (x : NoFTLObj) (tval : NoFTLObj) : p ∈ regularConeSet x ↔ norm2 (p-x) = 2 * sqr (tval p - tval x) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemWhereLineMeetsCone#1
Theorem name: lemWhereLineMeetsCone
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemWhereLineMeetsCone#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemWhereLineMeetsCone#1
-- source_statement: assumes "a = mNorm2 D" and "b = 2*(tval (B\<ominus>x))*(tval D) - 2*((sComponent D) \<odot>s (sComponent (B\<ominus>x)))" and "c = mNorm2 (B\<ominus>x)" shows "qroot a b c \<alpha> \<longleftrightarrow> regularCone x (B \<oplus> (\<alpha...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_36aaeb5a811d5b1e (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (regularCone : NoFTLObj → NoFTLObj → Prop) (x : NoFTLObj) (B : NoFTLObj) (D : NoFTLObj) : qroot a b c α ↔ regularCone x (B + (α*D)) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone1#1
Theorem name: lemLineMeetsCone1
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone1#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone1#1
-- source_statement: assumes "\<not> (x \<in> l)" and "isLine l" and "S = l \<inter> regularConeSet x" and l: "l = line B D" and X: "X = (B \<ominus> x)" and a: "a = mNorm2 D" and b: "b = 2*(tval X)*(tval D) - 2*((sComponent D) \<odot>s (sComponent X))" and ...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_8b5f2b440065cdec (qcase1 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (S : NoFTLSet) (B : NoFTLObj) : (qcase1 a b c → S = setOf' (fun q => q = B)) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone2#1
Theorem name: lemLineMeetsCone2
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone2#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone2#1
-- source_statement: assumes "\<not> (x \<in> l)" and "isLine l" and "S = l \<inter> regularConeSet x" and l: "l = line B D" and X: "X = (B \<ominus> x)" and "a = mNorm2 D" and "b = 2*(tval (B\<ominus>x))*(tval D) - 2*((sComponent D) \<odot>s (sComponent (B\...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_917e070b520d5eeb (qcase2 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (S : NoFTLSet) : qcase2 a b c → S = {} := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone3#1
Theorem name: lemLineMeetsCone3
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone3#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone3#1
-- source_statement: assumes "\<not> (x \<in> l)" and "isLine l" and "S = l \<inter> regularConeSet x" and l: "l = line B D" and X: "X = (B \<ominus> x)" and a: "a = mNorm2 D" and b: "b = 2*(tval X)*(tval D) - 2*((sComponent D) \<odot>s (sComponent X))" and ...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_dd358f4ea628bd5d (qcase3 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (S : NoFTLSet) (y3 : NoFTLObj) : qcase3 a b c → S = setOf' (fun q => q = y3) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone4#1
Theorem name: lemLineMeetsCone4
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone4#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone4#1
-- source_statement: assumes "\<not> (x \<in> l)" and "isLine l" and "S = l \<inter> regularConeSet x" and l: "l = line B D" and X: "X = (B \<ominus> x)" and a: "a = mNorm2 D" and b: "b = 2*(tval X)*(tval D) - 2*((sComponent D) \<odot>s (sComponent X))" and ...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_6814f58738a1377d (qcase4 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (S : NoFTLSet) : (qcase4 a b c → S = {}) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone5#1
Theorem name: lemLineMeetsCone5
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone5#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone5#1
-- source_statement: assumes "\<not> (x \<in> l)" and "isLine l" and "S = l \<inter> regularConeSet x" and l: "l = line B D" and X: "X = (B \<ominus> x)" and a: "a = mNorm2 D" and b: "b = 2*(tval X)*(tval D) - 2*((sComponent D) \<odot>s (sComponent X))" and ...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_29a908e3757dcc99 (qcase5 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (S : NoFTLSet) (y5 : NoFTLObj) : (qcase5 a b c → S = setOf' (fun q => q = y5)) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone6#1
Theorem name: lemLineMeetsCone6
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone6#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone6#1
-- source_statement: assumes "\<not> (x \<in> l)" and "isLine l" and "S = l \<inter> regularConeSet x" and l: "l = line B D" and X: "X = (B \<ominus> x)" and a: "a = mNorm2 D" and b: "b = 2*(tval X)*(tval D) - 2*((sComponent D) \<odot>s (sComponent X))" and ...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_72e7a4b4e6b0a15c (qcase6 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (ym : NoFTLObj) (yp : NoFTLObj) (S : NoFTLSet) : (qcase6 a b c → (ym ≠ yp) ∧ S = {ym, yp}) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConeLemma1#1
Theorem name: lemConeLemma1
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemConeLemma1#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemConeLemma1#1
-- source_statement: assumes "\<not> (x \<in> l)" and "isLine l" and "S = l \<inter> regularConeSet x" shows "finite S \<and> card S \<le> 2"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_87ff8ec16b84b640 (finite : NoFTLSet → Prop) (S : NoFTLSet) : finite S ∧ card S ≤ 2 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemConeLemma2#1
Theorem name: lemConeLemma2
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemConeLemma2#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemConeLemma2#1
-- source_statement: assumes "\<not> (regularCone x w)" shows "\<exists> l . (onLine w l) \<and> (\<not> (x \<in> l)) \<and> (card (l \<inter> (regularConeSet x)) = 2)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_816db8572134a851 (w : NoFTLObj) (x : NoFTLObj) : ∃ l, (onLine w l) ∧ (¬ (x ∈ l)) ∧ (card (l ∩ (regularConeSet x)) = 2) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemLineInsideRegularConeHasFiniteSlope#1
Theorem name: lemLineInsideRegularConeHasFiniteSlope
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemLineInsideRegularConeHasFiniteSlope#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemLineInsideRegularConeHasFiniteSlope#1
-- source_statement: assumes "insideRegularCone x p" and "l = lineJoining x p" shows "lineSlopeFinite l"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_b2fd5a1b42bb9fee (lineSlopeFinite : NoFTLSet → Prop) (l : NoFTLSet) : lineSlopeFinite l := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemInvertibleOnMeet#1
Theorem name: lemInvertibleOnMeet
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemInvertibleOnMeet#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemInvertibleOnMeet#1
-- source_statement: assumes "invertible f" and "S = A \<inter> B" shows "applyToSet (asFunc f) S = (applyToSet (asFunc f) A) \<inter> (applyToSet (asFunc f) B)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_de1dc240b0268a3c (f : NoFTLObj) (S : NoFTLSet) (A : NoFTLSet) (B : NoFTLSet) : applyToSet (asFunc f) S = (applyToSet (asFunc f) A) ∩ (applyToSet (asFunc f) B) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemInsideCone#1
Theorem name: lemInsideCone
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemInsideCone#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemInsideCone#1
-- source_statement: shows "insideRegularCone x p \<longleftrightarrow> \<not>(vertex x p \<or> outsideRegularCone x p \<or> onRegularCone x p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=4;risk_reasons=unbalanced_brackets,source_has_isabelle_tokens
-- semantic_shell_risk_score: 4
-- semantic_shell_risk_reasons: unbalanced_brackets, source_has_isabelle_tokens
-- force_true: false
theorem smoke_17afa4001a802d67 (x : NoFTLObj) (p : NoFTLObj) (vertex : NoFTLObj → NoFTLObj) (outsideRegularCone : NoFTLObj → NoFTLObj) (onRegularCone : NoFTLObj → NoFTLObj → Prop) : True := by
  -- Structural bucket discharged to compile-safe stub.
  exact True.intro

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemOnRegularConeIff#1
Theorem name: lemOnRegularConeIff
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemOnRegularConeIff#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemOnRegularConeIff#1
-- source_statement: assumes "l = lineJoining x p" shows "onRegularCone x p \<longleftrightarrow> (l \<inter> regularConeSet x = l)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_c3103bc0f4ad78d8 (onRegularCone : NoFTLObj → NoFTLObj) (x : NoFTLObj) (p : NoFTLObj) (l : NoFTLSet) : (onRegularCone x = p)↔ (l ∩ regularConeSet x = l) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemOutsideRegularConeImplies#1
Theorem name: lemOutsideRegularConeImplies
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemOutsideRegularConeImplies#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemOutsideRegularConeImplies#1
-- source_statement: shows "outsideRegularCone x p \<longrightarrow> (\<exists> l p' . (p' \<noteq> p) \<and> onLine p' l \<and> onLine p l \<and> (l \<inter> regularConeSet x = {}))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_366915b7e8353926 (outsideRegularCone : NoFTLObj → NoFTLObj) (x : NoFTLObj) (p : NoFTLObj) : (outsideRegularCone x = p)→ (∃ l p', (p' ≠ p) ∧ onLine p' l ∧ onLine p l ∧ (l ∩ regularConeSet x = {})) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Classification
Theorem id: No_FTL_observers_Gen_Rel.Classification.lemTimelikeInsideCone#1
Theorem name: lemTimelikeInsideCone
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Classification.lemTimelikeInsideCone#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Classification.lemTimelikeInsideCone#1
-- source_statement: assumes "insideRegularCone x p" shows "timelike (p \<ominus> x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_59985ae4cb288ab9 (timelike : NoFTLObj → Prop) (p : NoFTLObj) (x : NoFTLObj) : timelike (p - x) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Classification

-- ═══════════════════════════════════════════════════════
-- Theory: Functions  (7 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Functions

/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemBijInv#1
Theorem name: lemBijInv
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Functions.lemBijInv#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Functions.lemBijInv#1
-- source_statement: "bijective (asFunc f) \<longleftrightarrow> invertible f"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_3287e4bb9244910e (bijective : (NoFTLObj → NoFTLObj) → Prop) (f : NoFTLObj) : bijective (asFunc f) ↔ invertible f := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemApproxEqualAtBase#1
Theorem name: lemApproxEqualAtBase
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Functions.lemApproxEqualAtBase#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Functions.lemApproxEqualAtBase#1
-- source_statement: assumes "diffApprox g f x" shows "(f x y \<and> g x z) \<longrightarrow> (y = z)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_5200d0c8c687d15a (f : NoFTLObj → NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) (g : NoFTLObj → NoFTLObj) (z : NoFTLObj) : (f x = y)∧(g x = z) → (y = z) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemCtsOfCtsIsCts#1
Theorem name: lemCtsOfCtsIsCts
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Functions.lemCtsOfCtsIsCts#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Functions.lemCtsOfCtsIsCts#1
-- source_statement: assumes "cts f x" and "\<forall>y . (f x y) \<longrightarrow> (cts g y)" shows "cts (composeRel g f) x"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_35ecbbc6e902115d (g : NoFTLObj) (f : NoFTLObj) (x : NoFTLObj) : cts (composeRel g f) x := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemInjOfInjIsInj#1
Theorem name: lemInjOfInjIsInj
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Functions.lemInjOfInjIsInj#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Functions.lemInjOfInjIsInj#1
-- source_statement: assumes "injective f" and "injective g" shows "injective (composeRel g f)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_bb984c7386dbd07b (g : NoFTLObj) (f : NoFTLObj) : injective (composeRel g f) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemInverseComposition#1
Theorem name: lemInverseComposition
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Functions.lemInverseComposition#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Functions.lemInverseComposition#1
-- source_statement: assumes "h = composeRel g f" shows "(invFunc h) = composeRel (invFunc f) (invFunc g)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_f28f45360de370fa (invFunc : NoFTLObj → NoFTLObj) (h : NoFTLObj) (f : NoFTLObj) (g : NoFTLObj) : (invFunc h) = composeRel (invFunc f) (invFunc g) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemToFuncAsFunc#1
Theorem name: lemToFuncAsFunc
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Functions.lemToFuncAsFunc#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Functions.lemToFuncAsFunc#1
-- source_statement: assumes "isFunction f" and "total f" shows "asFunc (toFunc f) = f"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_550529541c71da91 (toFunc : NoFTLObj) (f : NoFTLObj) : asFunc (toFunc f) = f := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Functions
Theorem id: No_FTL_observers_Gen_Rel.Functions.lemAsFuncToFunc#1
Theorem name: lemAsFuncToFunc
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Functions.lemAsFuncToFunc#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Functions.lemAsFuncToFunc#1
-- source_statement: "toFunc (asFunc f) = f"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_0429945053053cdf (toFunc : (NoFTLObj → NoFTLObj) → NoFTLObj) (f : NoFTLObj) : toFunc (asFunc f) = f := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Functions

-- ═══════════════════════════════════════════════════════
-- Theory: KeyLemma  (1 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.KeyLemma

/-!
Auto-generated theorem-indexed pilot file.
Theory: KeyLemma
Theorem id: No_FTL_observers_Gen_Rel.KeyLemma.lemInsideRegularConeImplies#1
Theorem name: lemInsideRegularConeImplies
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.KeyLemma.lemInsideRegularConeImplies#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.KeyLemma.lemInsideRegularConeImplies#1
-- source_statement: assumes "insideRegularCone x p" and "D \<noteq> origin" and "l = line p D" shows "0 < card (l \<inter> regularConeSet x) \<le> 2"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_bf90207e0c6dd670 (l : NoFTLSet) (x : NoFTLObj) : (0 < card (l ∩ regularConeSet x)) ∧ (card (l ∩ regularConeSet x) ≤ 2) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.KeyLemma

-- ═══════════════════════════════════════════════════════
-- Theory: LinearMaps  (9 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.LinearMaps

/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearProps#1
Theorem name: lemLinearProps
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearProps#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearProps#1
-- source_statement: assumes "linear L" shows "(L origin = origin) \<and> (L (a \<otimes> p) = (a \<otimes> (L p))) \<and> (L (p \<oplus> q) = ((L p) \<oplus> (L q))) \<and> (L (p \<ominus> q) = ((L p) \<ominus> (L q)))" using assms by simp
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_b3f45c3136a964b2 (L : NoFTLObj) (origin : NoFTLObj) (a : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) : (L origin = origin) ∧ (L (a * p) = (a * (L p))) ∧ (L (p + q) = ((L p) + (L q))) ∧ (L (p - q) = ((L p) - (L q))) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemMatrixApplicationIsLinear#1
Theorem name: lemMatrixApplicationIsLinear
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.LinearMaps.lemMatrixApplicationIsLinear#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.LinearMaps.lemMatrixApplicationIsLinear#1
-- source_statement: "linear (applyMatrix m)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_77fc562fecd972f0 (applyMatrix : NoFTLObj) (m : NoFTLObj) : linear (applyMatrix m) := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsMatrixApplication#1
Theorem name: lemLinearIsMatrixApplication
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsMatrixApplication#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsMatrixApplication#1
-- source_statement: assumes "linear L" shows "\<exists> m . L = (applyMatrix m)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_6ef08c2d45abcdd5 (L : NoFTLObj) (applyMatrix : NoFTLObj) : ∃ m, L = (applyMatrix m) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIffMatrix#1
Theorem name: lemLinearIffMatrix
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIffMatrix#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIffMatrix#1
-- source_statement: "linear L \<longleftrightarrow> (\<exists> M. L = applyMatrix M)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_56dd0fbbe2db331d (L : NoFTLObj) (applyMatrix : NoFTLObj → NoFTLObj) : linear L ↔ (∃ M, L = applyMatrix M) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemIdIsLinear#1
Theorem name: lemIdIsLinear
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.LinearMaps.lemIdIsLinear#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.LinearMaps.lemIdIsLinear#1
-- source_statement: "linear id"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_cfed4e87370e053b (id : NoFTLObj) : linear id := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsBounded#1
Theorem name: lemLinearIsBounded
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsBounded#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsBounded#1
-- source_statement: assumes "linear L" shows "bounded L"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_d1adf970b5edc0d2 (bounded : NoFTLObj → Prop) (L : NoFTLObj) : bounded L := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsCts#1
Theorem name: lemLinearIsCts
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsCts#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsCts#1
-- source_statement: assumes "linear L" shows "cts (asFunc L) x"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_2fbba05529869206 (L : NoFTLObj) (x : NoFTLObj) : cts L x := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinOfLinIsLin#1
Theorem name: lemLinOfLinIsLin
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinOfLinIsLin#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.LinearMaps.lemLinOfLinIsLin#1
-- source_statement: assumes "(linear A) \<and> (linear B)" shows "linear (B \<circ> A)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_bf8824dffb3ded63 (B : NoFTLObj) (A : NoFTLObj) : linear (composeRel B A) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: LinearMaps
Theorem id: No_FTL_observers_Gen_Rel.LinearMaps.lemInverseLinear#1
Theorem name: lemInverseLinear
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.LinearMaps.lemInverseLinear#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.LinearMaps.lemInverseLinear#1
-- source_statement: assumes "linear A" and "invertible A" shows "\<exists>A' . (linear A') \<and> (\<forall> p q. A p = q \<longleftrightarrow> A' q = p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_02e17ca8d687bde2 (A : NoFTLObj) : ∃ A', (linear A') ∧ (∀ p q, A p = q ↔ A' q = p) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.LinearMaps

-- ═══════════════════════════════════════════════════════
-- Theory: MainLemma  (3 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.MainLemma

/-!
Auto-generated theorem-indexed pilot file.
Theory: MainLemma
Theorem id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaBasic#1
Theorem name: lemMainLemmaBasic
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaBasic#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaBasic#1
-- source_statement: assumes tgt: "tangentLine l wl origin" and injf: "injective f" and affapp: "affineApprox A f origin" and f00: "f origin origin" and ctsf'0: "cts (invFunc f) origin" and affline: "applyAffineToLine A l l'" shows "tangentLine l' (applyToSe...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_fcbbe93437f33a27 (tangentLine : NoFTLSet → NoFTLSet → NoFTLObj → Prop) (l' : NoFTLSet) (f : NoFTLObj) (wl : NoFTLSet) (origin : NoFTLObj) : tangentLine l' (applyToSet f wl) origin := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: MainLemma
Theorem id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaOrigin#1
Theorem name: lemMainLemmaOrigin
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaOrigin#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaOrigin#1
-- source_statement: assumes tgtx: "tangentLine l wl x" and injf: "injective f" and affappx: "affineApprox A f x" and fx0: "f x origin" and ctsf'0: "cts (invFunc f) origin" and affline: "applyAffineToLine A l l'" shows "tangentLine l' (applyToSet f wl) origin"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_b77b9af900dbfc92 (tangentLine : NoFTLSet → NoFTLSet → NoFTLObj → Prop) (l' : NoFTLSet) (f : NoFTLObj) (wl : NoFTLSet) (origin : NoFTLObj) : tangentLine l' (applyToSet f wl) origin := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: MainLemma
Theorem id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemma#1
Theorem name: lemMainLemma
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemma#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.MainLemma.lemMainLemma#1
-- source_statement: assumes tgtx: "tangentLine l wl x" and injf: "injective f" and affappx: "affineApprox A f x" and fxy: "f x y" and ctsf'y: "cts (invFunc f) y" and affline: "applyAffineToLine A l l'" shows "tangentLine l' (applyToSet f wl) y"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_fd85b44b4ee644d8 (tangentLine : NoFTLSet → NoFTLSet → NoFTLObj → Prop) (l' : NoFTLSet) (f : NoFTLObj) (wl : NoFTLSet) (y : NoFTLObj) : tangentLine l' (applyToSet f wl) y := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.MainLemma

-- ═══════════════════════════════════════════════════════
-- Theory: NoFTLGR  (1 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.NoFTLGR

/-!
Auto-generated theorem-indexed pilot file.
Theory: NoFTLGR
Theorem id: No_FTL_observers_Gen_Rel.NoFTLGR.lemNoFTLGR#1
Theorem name: lemNoFTLGR
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.NoFTLGR.lemNoFTLGR#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.NoFTLGR.lemNoFTLGR#1
-- source_statement: assumes ass1: "x \<in> wline m m \<inter> wline m k" and ass2: "tl l m k x" and ass3: "v \<in> lineVelocity l" and ass4: "\<exists> p . (p \<noteq> x) \<and> (p \<in> l)" shows "(lineSlopeFinite l) \<and> (sNorm2 v < 1)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_4ca9ccd6fb9097d7 (lineSlopeFinite : NoFTLObj → Prop) (l : NoFTLObj) (v : NoFTLObj) : (lineSlopeFinite l) ∧ (sNorm2 v < 1) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.NoFTLGR

-- ═══════════════════════════════════════════════════════
-- Theory: Norms  (8 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Norms

/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemNormSqrIsNorm2#1
Theorem name: lemNormSqrIsNorm2
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Norms.lemNormSqrIsNorm2#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Norms.lemNormSqrIsNorm2#1
-- source_statement: "norm2 p = sqr (norm p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_bf3bb597c6c22a8c (p : NoFTLObj) : norm2 p = sqr (norm p) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemZeroNorm#1
Theorem name: lemZeroNorm
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Norms.lemZeroNorm#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Norms.lemZeroNorm#1
-- source_statement: shows "(p = origin) \<longleftrightarrow> (norm p = 0)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_082e352af8f1f1c5 (p : NoFTLObj) (origin : NoFTLObj) : (p = origin) ↔ (norm p = 0) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemNormNonNegative#1
Theorem name: lemNormNonNegative
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Norms.lemNormNonNegative#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Norms.lemNormNonNegative#1
-- source_statement: "norm p \<ge> 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_4813450cfb9ce114 (p : NoFTLObj) : norm p ≥ 0 := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemNotOriginImpliesPositiveNorm#1
Theorem name: lemNotOriginImpliesPositiveNorm
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Norms.lemNotOriginImpliesPositiveNorm#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Norms.lemNotOriginImpliesPositiveNorm#1
-- source_statement: assumes "p \<noteq> origin" shows "(norm p > 0)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_ac202df6b3faa3cb (p : NoFTLObj) : (norm p > 0) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemNormSymmetry#1
Theorem name: lemNormSymmetry
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Norms.lemNormSymmetry#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Norms.lemNormSymmetry#1
-- source_statement: "norm (p\<ominus>q) = norm (q\<ominus>p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_bbc95c65408af32d (p : NoFTLObj) (q : NoFTLObj) : norm (p-q) = norm (q-p) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemNormOfScaled#1
Theorem name: lemNormOfScaled
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Norms.lemNormOfScaled#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Norms.lemNormOfScaled#1
-- source_statement: "norm (\<alpha>\<otimes>p) = (abs \<alpha>) * (norm p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_dd84773128f2c52a (p : NoFTLObj) : norm (α*p) = (abs α) * (norm p) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemDistancesAdd#1
Theorem name: lemDistancesAdd
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Norms.lemDistancesAdd#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Norms.lemDistancesAdd#1
-- source_statement: assumes triangle: "axTriangleInequality (q\<ominus>p) (r\<ominus>q)" and distances: "(x > 0) \<and> (y > 0) \<and> (sep2 p q < sqr x) \<and> (sep2 r q < sqr y)" shows "r within (x+y) of p"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_da1f06b080308e34 (r : NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) (p : NoFTLObj) : withinOf r (x+y) p := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemDistancesAddStrictR#1
Theorem name: lemDistancesAddStrictR
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Norms.lemDistancesAddStrictR#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Norms.lemDistancesAddStrictR#1
-- source_statement: assumes triangle: "axTriangleInequality (q\<ominus>p) (r\<ominus>q)" and distances: "(x > 0) \<and> (y > 0) \<and> (sep2 p q \<le> sqr x) \<and> (sep2 r q < sqr y)" shows "r within (x+y) of p"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_2845fa4f912e80d1 (r : NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) (p : NoFTLObj) : withinOf r (x+y) p := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Norms

-- ═══════════════════════════════════════════════════════
-- Theory: ObserverConeLemma  (1 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.ObserverConeLemma

/-!
Auto-generated theorem-indexed pilot file.
Theory: ObserverConeLemma
Theorem id: No_FTL_observers_Gen_Rel.ObserverConeLemma.lemConeOfObserved#1
Theorem name: lemConeOfObserved
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.ObserverConeLemma.lemConeOfObserved#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.ObserverConeLemma.lemConeOfObserved#1
-- source_statement: assumes "affineApprox A (wvtFunc m k) x" and "m sees k at x" shows "coneSet k (A x) = regularConeSet (A x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_fe90cdf2ddb18ed1 (coneSet : NoFTLObj → NoFTLObj → NoFTLSet) (k : NoFTLObj) (A : NoFTLObj) (x : NoFTLObj) : coneSet k (A x) = regularConeSet (A x) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.ObserverConeLemma

-- ═══════════════════════════════════════════════════════
-- Theory: Points  (35 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Points

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNorm2Decomposition#1
Theorem name: lemNorm2Decomposition
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemNorm2Decomposition#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemNorm2Decomposition#1
-- source_statement: shows "norm2 u = sqr (tval u) + sNorm2 (sComponent u)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_8272daf7cc3ebe4e (u : NoFTLObj) (tval : NoFTLObj) (sComponent : NoFTLObj) : norm2 u = sqr (tval u) + sNorm2 (sComponent u) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemPointDecomposition#1
Theorem name: lemPointDecomposition
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemPointDecomposition#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemPointDecomposition#1
-- source_statement: shows "p = (((tval p)\<otimes>tUnit) \<oplus> (((xval p)\<otimes>xUnit) \<oplus> (((yval p)\<otimes>yUnit) \<oplus> ((zval p)\<otimes>zUnit))))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_19dc79c8be477c18 (p : NoFTLObj) (tval : NoFTLObj → NoFTLObj) (tUnit : NoFTLObj) (xval : NoFTLObj → NoFTLObj) (xUnit : NoFTLObj) (yval : NoFTLObj → NoFTLObj) (yUnit : NoFTLObj) (zval : NoFTLObj → NoFTLObj) (zUnit : NoFTLObj) : p = (((tval p) * tUnit) + (((xval p) * xUnit) + (((yval p) * yUnit) + ((zval p) * zUnit)))) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleLeftSumDistrib#1
Theorem name: lemScaleLeftSumDistrib
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemScaleLeftSumDistrib#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemScaleLeftSumDistrib#1
-- source_statement: "((a + b) \<otimes> p) = ((a\<otimes>p) \<oplus> (b\<otimes>p))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_5807c569c0c03c09 (a : NoFTLObj) (b : NoFTLObj) (p : NoFTLObj) : ((a + b) * p) = ((a * p) + (b * p)) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleLeftDiffDistrib#1
Theorem name: lemScaleLeftDiffDistrib
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemScaleLeftDiffDistrib#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemScaleLeftDiffDistrib#1
-- source_statement: "((a - b) \<otimes> p) = ((a\<otimes>p) \<ominus> (b\<otimes>p))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_84d8b278b19f368d (a : NoFTLObj) (b : NoFTLObj) (p : NoFTLObj) : ((a - b) * p) = ((a * p) - (b * p)) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleAssoc#1
Theorem name: lemScaleAssoc
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemScaleAssoc#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemScaleAssoc#1
-- source_statement: "(\<alpha> \<otimes> (\<beta> \<otimes> p)) = ((\<alpha> * \<beta>) \<otimes> p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_01a436c14de168d0 (p : NoFTLObj) : (α * (β * p)) = ((α * β) * p) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleCommute#1
Theorem name: lemScaleCommute
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemScaleCommute#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemScaleCommute#1
-- source_statement: "(\<alpha> \<otimes> (\<beta> \<otimes> p)) = (\<beta> \<otimes> (\<alpha> \<otimes> p))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_7164073afc4ebd45 (p : NoFTLObj) : (α * (β * p)) = (β * (α * p)) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleDistribSum#1
Theorem name: lemScaleDistribSum
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemScaleDistribSum#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemScaleDistribSum#1
-- source_statement: "(\<alpha> \<otimes> (p \<oplus> q)) = ((\<alpha>\<otimes>p) \<oplus> (\<alpha>\<otimes>q))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_50eb9e23b993ea2f (p : NoFTLObj) (q : NoFTLObj) : (α * (p + q)) = ((α*p) + (α*q)) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleDistribDiff#1
Theorem name: lemScaleDistribDiff
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemScaleDistribDiff#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemScaleDistribDiff#1
-- source_statement: "(\<alpha> \<otimes> (p \<ominus> q)) = ((\<alpha>\<otimes>p) \<ominus> (\<alpha>\<otimes>q))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_65f3d428937936c5 (p : NoFTLObj) (q : NoFTLObj) : (α * (p - q)) = ((α*p) - (α*q)) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleOrigin#1
Theorem name: lemScaleOrigin
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemScaleOrigin#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemScaleOrigin#1
-- source_statement: "(\<alpha> \<otimes> origin) = origin"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_838dd310bd0c6a42 (origin : NoFTLObj) : (α * origin) = origin := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemMNorm2OfScaled#1
Theorem name: lemMNorm2OfScaled
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemMNorm2OfScaled#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemMNorm2OfScaled#1
-- source_statement: "mNorm2 (scaleBy \<alpha> p) = (sqr \<alpha>) * mNorm2 p"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_2a420bafd3dbfd30 (mNorm2 : NoFTLObj → NoFTLObj) (scaleBy : NoFTLObj) (p : NoFTLObj) : mNorm2 (scaleBy α p) = (sqr α) * mNorm2 p := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSNorm2OfScaled#1
Theorem name: lemSNorm2OfScaled
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemSNorm2OfScaled#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemSNorm2OfScaled#1
-- source_statement: "sNorm2 (sScaleBy \<alpha> p) = (sqr \<alpha>) * sNorm2 p"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_953f98097bd0099f (sScaleBy : NoFTLObj) (p : NoFTLObj) : sNorm2 (sScaleBy α p) = (sqr α) * sNorm2 p := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNorm2OfScaled#1
Theorem name: lemNorm2OfScaled
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemNorm2OfScaled#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemNorm2OfScaled#1
-- source_statement: "norm2 (\<alpha> \<otimes> p) = (sqr \<alpha>) * norm2 p"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_f4af596e25dd294f (p : NoFTLObj) : norm2 (α * p) = (sqr α) * norm2 p := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleSep2#1
Theorem name: lemScaleSep2
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemScaleSep2#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemScaleSep2#1
-- source_statement: "(sqr a) * (sep2 p q) = sep2 (a\<otimes>p) (a\<otimes>q)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_b45f2648898e1b23 (a : NoFTLObj) (sep2 : NoFTLObj → NoFTLObj → NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) : (sqr a) * (sep2 p q) = sep2 (a * p) (a * q) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSScaleAssoc#1
Theorem name: lemSScaleAssoc
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemSScaleAssoc#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemSScaleAssoc#1
-- source_statement: "(\<alpha> \<otimes>s (\<beta> \<otimes>s p)) = ((\<alpha> * \<beta>) \<otimes>s p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_d39db2b8ff07e22e (s : NoFTLObj → NoFTLObj) (p : NoFTLObj) : (α *s (β *s p)) = ((α * β) *s p) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleBall#1
Theorem name: lemScaleBall
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemScaleBall#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemScaleBall#1
-- source_statement: assumes "x within e of y" and "a \<noteq> 0" shows "(a\<otimes>x) within (a*e) of (a\<otimes>y)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_6b6530b59b3907a6 (a : NoFTLObj) (x : NoFTLObj) (e : NoFTLObj) (y : NoFTLObj) : withinOf (a * x) (a * e) (a * y) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemScaleBallAndBoundary#1
Theorem name: lemScaleBallAndBoundary
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemScaleBallAndBoundary#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemScaleBallAndBoundary#1
-- source_statement: assumes "sep2 x y \<le> sqr e" and "a \<noteq> 0" shows "sep2 (a\<otimes>x) (a\<otimes>y) \<le> sqr (a*e)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_2fc362c443da51b5 (sep2 : NoFTLObj → NoFTLObj → NoFTLObj) (a : NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) (e : NoFTLObj) : sep2 (a * x) (a * y) ≤ sqr (a * e) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemTimeAxisIsLine#1
Theorem name: lemTimeAxisIsLine
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemTimeAxisIsLine#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemTimeAxisIsLine#1
-- source_statement: "isLine timeAxis"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_af823a7e18013d36 (timeAxis : NoFTLSet) : isLine timeAxis := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSameLine#1
Theorem name: lemSameLine
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemSameLine#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemSameLine#1
-- source_statement: assumes "p \<in> line b d" shows "sameLine (line b d) (line p d)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_fdbf4fdb457f3746 (sameLine : NoFTLObj → NoFTLObj → Prop) (line : NoFTLObj) (b : NoFTLObj) (d : NoFTLObj) (p : NoFTLObj) : sameLine (line b d) (line p d) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSSep2Symmetry#1
Theorem name: lemSSep2Symmetry
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemSSep2Symmetry#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemSSep2Symmetry#1
-- source_statement: "sSep2 p q = sSep2 q p"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_d14fac3e46114a3d (sSep2 : NoFTLObj → NoFTLObj → NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) : sSep2 p q = sSep2 q p := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSep2Symmetry#1
Theorem name: lemSep2Symmetry
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemSep2Symmetry#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemSep2Symmetry#1
-- source_statement: "sep2 p q = sep2 q p"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_5617e674812cd8f9 (sep2 : NoFTLObj → NoFTLObj → NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) : sep2 p q = sep2 q p := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSpatialNullImpliesSpatialOrigin#1
Theorem name: lemSpatialNullImpliesSpatialOrigin
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemSpatialNullImpliesSpatialOrigin#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemSpatialNullImpliesSpatialOrigin#1
-- source_statement: assumes "sNorm2 s = 0" shows "s = sOrigin" using assms local.add_nonneg_eq_0_iff by auto
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_6097ca92aaff01e1 (s : NoFTLObj) (sOrigin : NoFTLObj) : s = sOrigin := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNorm2NonNeg#1
Theorem name: lemNorm2NonNeg
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemNorm2NonNeg#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemNorm2NonNeg#1
-- source_statement: "norm2 p \<ge> 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_0c98c045aae435da (p : NoFTLObj) : norm2 p ≥ 0 := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNullImpliesOrigin#1
Theorem name: lemNullImpliesOrigin
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemNullImpliesOrigin#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemNullImpliesOrigin#1
-- source_statement: assumes "norm2 p = 0" shows "p = origin"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_d909ba5c402fba1f (p : NoFTLObj) (origin : NoFTLObj) : p = origin := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNotOriginImpliesPosNorm2#1
Theorem name: lemNotOriginImpliesPosNorm2
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemNotOriginImpliesPosNorm2#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemNotOriginImpliesPosNorm2#1
-- source_statement: assumes "p \<noteq> origin" shows "norm2 p > 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_c3de69d56276ad74 (p : NoFTLObj) : norm2 p > 0 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemNotEqualImpliesSep2Pos#1
Theorem name: lemNotEqualImpliesSep2Pos
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemNotEqualImpliesSep2Pos#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemNotEqualImpliesSep2Pos#1
-- source_statement: assumes "y \<noteq> x" shows "sep2 y x > 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_e880341a530552e3 (sep2 : NoFTLObj → NoFTLObj → NoFTLObj) (y : NoFTLObj) (x : NoFTLObj) : sep2 y x > 0 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemBallContainsCentre#1
Theorem name: lemBallContainsCentre
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemBallContainsCentre#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemBallContainsCentre#1
-- source_statement: assumes "\<epsilon> > 0" shows "x within \<epsilon> of x"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_1c7020c5ec8d2adb (x : NoFTLObj) : withinOf x ε x := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemPointLimit#1
Theorem name: lemPointLimit
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemPointLimit#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemPointLimit#1
-- source_statement: assumes "\<forall> \<epsilon> > 0 . (v within \<epsilon> of u)" shows "v = u"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_ca7906388c6d656b (v : NoFTLObj) (u : NoFTLObj) : v = u := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemBallPopulated#1
Theorem name: lemBallPopulated
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemBallPopulated#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemBallPopulated#1
-- source_statement: assumes "e > 0" shows "\<exists> y . (y within e of x) \<and> (y \<noteq> x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_c32fa3dd2c68c34b (e : NoFTLObj) (x : NoFTLObj) : ∃ y, (y within e of x) ∧ (y ≠ x) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemBallInBall#1
Theorem name: lemBallInBall
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemBallInBall#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemBallInBall#1
-- source_statement: assumes "p within x of q" and "0 < x \<le> y" shows "p within y of q"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_0d4e46ff16ba6212 (p : NoFTLObj) (y : NoFTLObj) (q : NoFTLObj) : withinOf p y q := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemSmallPoints#1
Theorem name: lemSmallPoints
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemSmallPoints#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemSmallPoints#1
-- source_statement: assumes "e > 0" shows "\<exists> a > 0 . norm2 (a\<otimes>p) < sqr e"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_625e89e32a52c070 (p : NoFTLObj) (e : NoFTLObj) : ∃ a, a > 0 ∧  norm2 (a * p) < sqr e := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemLineJoiningContainsEndPoints#1
Theorem name: lemLineJoiningContainsEndPoints
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemLineJoiningContainsEndPoints#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemLineJoiningContainsEndPoints#1
-- source_statement: assumes "l = lineJoining x p" shows "onLine x l \<and> onLine p l"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_bd55b9bdad68dadb (x : NoFTLObj) (l : NoFTLSet) (p : NoFTLObj) : onLine x l ∧ onLine p l := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemLineAndPoints#1
Theorem name: lemLineAndPoints
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemLineAndPoints#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemLineAndPoints#1
-- source_statement: assumes "p \<noteq> q" shows "(onLine p l \<and> onLine q l) \<longleftrightarrow> (l = lineJoining p q)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_ec81db04e6dfea02 (p : NoFTLObj) (l : NoFTLSet) (q : NoFTLObj) : (onLine p l ∧ onLine q l) ↔ (l = lineJoining p q) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemLineDefinedByPair#1
Theorem name: lemLineDefinedByPair
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemLineDefinedByPair#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemLineDefinedByPair#1
-- source_statement: assumes "x \<noteq> p" and "(onLine p l1) \<and> (onLine x l1)" and "(onLine p l2) \<and> (onLine x l2)" shows "l1 = l2"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_578fc1de9fcaa7f6 (l1 : NoFTLSet) (l2 : NoFTLSet) : l1 = l2 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemDrtn#1
Theorem name: lemDrtn
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemDrtn#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemDrtn#1
-- source_statement: assumes "{ d1, d2 } \<subseteq> drtn l" shows "\<exists> \<alpha> \<noteq> 0 . d2 = (\<alpha> \<otimes> d1)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_63d25535fe98da7a (d2 : NoFTLObj) (d1 : NoFTLObj) : ∃ α ≠ 0, d2 = (α * d1) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Points
Theorem id: No_FTL_observers_Gen_Rel.Points.lemLineDeterminedByPointAndDrtn#1
Theorem name: lemLineDeterminedByPointAndDrtn
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Points.lemLineDeterminedByPointAndDrtn#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Points.lemLineDeterminedByPointAndDrtn#1
-- source_statement: assumes "(x \<noteq> p) \<and> (p \<in> l1) \<and> (onLine x l1) \<and> (onLine x l2)" and "drtn l1 = drtn l2" shows "l1 = l2"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_3ec4f58cf5ac96e7 (l1 : NoFTLSet) (l2 : NoFTLSet) : l1 = l2 := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Points

-- ═══════════════════════════════════════════════════════
-- Theory: Proposition1  (1 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Proposition1

/-!
Auto-generated theorem-indexed pilot file.
Theory: Proposition1
Theorem id: No_FTL_observers_Gen_Rel.Proposition1.lemProposition1#1
Theorem name: lemProposition1
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Proposition1.lemProposition1#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Proposition1.lemProposition1#1
-- source_statement: assumes "x \<in> wline m m" shows "cone m x p = regularCone x p"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_230854e335b6643c (cone : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj) (m : NoFTLObj) (x : NoFTLObj) (p : NoFTLObj) (regularCone : NoFTLObj → NoFTLObj → NoFTLObj) : cone m x p = regularCone x p := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Proposition1

-- ═══════════════════════════════════════════════════════
-- Theory: Proposition2  (1 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Proposition2

/-!
Auto-generated theorem-indexed pilot file.
Theory: Proposition2
Theorem id: No_FTL_observers_Gen_Rel.Proposition2.lemProposition2#1
Theorem name: lemProposition2
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Proposition2.lemProposition2#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Proposition2.lemProposition2#1
-- source_statement: assumes "affineApprox A (wvtFunc m k) x" shows "applyToSet (asFunc A) (coneSet m x) \<subseteq> coneSet k (A x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_542a36a2e11ee88b (A : NoFTLObj) (coneSet : NoFTLObj → NoFTLObj → NoFTLSet) (m : NoFTLObj) (x : NoFTLObj) (k : NoFTLObj) : applyToSet (asFunc A) (coneSet m x) ⊆ coneSet k (A x) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Proposition2

-- ═══════════════════════════════════════════════════════
-- Theory: Proposition3  (1 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Proposition3

/-!
Auto-generated theorem-indexed pilot file.
Theory: Proposition3
Theorem id: No_FTL_observers_Gen_Rel.Proposition3.lemProposition3#1
Theorem name: lemProposition3
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Proposition3.lemProposition3#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Proposition3.lemProposition3#1
-- source_statement: assumes "m sees k at x" shows "\<exists> A y . (wvtFunc m k x y) \<and> (affineApprox A (wvtFunc m k) x) \<and> (applyToSet (asFunc A) (coneSet m x) \<subseteq> coneSet k y) \<and> (coneSet k y = regularConeSet y)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=4;risk_reasons=unbalanced_brackets,source_has_isabelle_tokens
-- semantic_shell_risk_score: 4
-- semantic_shell_risk_reasons: unbalanced_brackets, source_has_isabelle_tokens
-- force_true: false
theorem smoke_35d52a598169631f (wvtFunc : NoFTLObj) (m : NoFTLObj) (k : NoFTLObj) (x : NoFTLObj) (coneSet : NoFTLObj → NoFTLSet → NoFTLSet) : True := by
  -- Retryable bucket discharged to compile-safe stub.
  exact True.intro

end AFPIsabellePilot.Proposition3

-- ═══════════════════════════════════════════════════════
-- Theory: Quadratics  (9 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Quadratics

/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadRootCondition#1
Theorem name: lemQuadRootCondition
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadRootCondition#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadRootCondition#1
-- source_statement: assumes "a \<noteq> 0" shows "(sqr (2*a*r + b) = discriminant a b c) \<longleftrightarrow> qroot a b c r"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_b563f12be8ce2455 (a : NoFTLObj) (r : NoFTLObj) (b : NoFTLObj) (discriminant : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj) (c : NoFTLObj) (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) : (sqr (2 * a * r + b) = discriminant a b c) ↔ qroot a b c r := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticCasesComplete#1
Theorem name: lemQuadraticCasesComplete
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticCasesComplete#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticCasesComplete#1
-- source_statement: shows "qcase1 a b c \<or> qcase2 a b c \<or> qcase3 a b c \<or> qcase4 a b c \<or> qcase5 a b c \<or> qcase6 a b c" using not_less_iff_gr_or_eq by blast
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_83c08af6b6491d05 (qcase1 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (qcase2 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (qcase3 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (qcase4 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (qcase5 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (qcase6 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) : qcase1 a b c ∨ qcase2 a b c ∨ qcase3 a b c ∨ qcase4 a b c ∨ qcase5 a b c ∨ qcase6 a b c := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase1#1
Theorem name: lemQCase1
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase1#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase1#1
-- source_statement: assumes "qcase1 a b c" shows "\<forall> r . qroot a b c r" using assms by simp
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_6f72a28f0419be0f (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : ∀ r, qroot a b c r := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase2#1
Theorem name: lemQCase2
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase2#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase2#1
-- source_statement: assumes "qcase2 a b c" shows "\<not> (\<exists> r . qroot a b c r)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_1e6d71e0968c97a8 (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : ¬ (∃ r, qroot a b c r) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase3#1
Theorem name: lemQCase3
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase3#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase3#1
-- source_statement: assumes "qcase3 a b c" shows "qroot a b c r \<longleftrightarrow> r = -c/b"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_ad210a42d18c367d (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (r : NoFTLObj) : qroot a b c r ↔ r = -c/b := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase4#1
Theorem name: lemQCase4
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase4#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase4#1
-- source_statement: assumes "qcase4 a b c" shows "\<not> (\<exists> r . qroot a b c r)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_31fb1338456848ef (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : ¬ (∃ r, qroot a b c r) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase5#1
Theorem name: lemQCase5
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase5#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase5#1
-- source_statement: assumes "qcase5 a b c" shows "qroot a b c r \<longleftrightarrow> r = -b/(2*a)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_381f38e92139b05a (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (r : NoFTLObj) : qroot a b c r ↔ r = -b/(2 * a) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase6#1
Theorem name: lemQCase6
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase6#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase6#1
-- source_statement: assumes "qcase6 a b c" and "rd = sqrt (discriminant a b c)" and "rp = ((-b) + rd) / (2*a)" and "rm = ((-b) - rd) / (2*a)" shows "(rp \<noteq> rm) \<and> qroots a b c = { rp, rm }"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_a3cab0d1c0407d83 (rp : NoFTLObj) (rm : NoFTLObj) (qroots : NoFTLObj → NoFTLObj → NoFTLSet → NoFTLSet) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLSet) : (rp ≠ rm) ∧ qroots a b c = { rp, rm } := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticRootCount#1
Theorem name: lemQuadraticRootCount
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticRootCount#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticRootCount#1
-- source_statement: assumes "\<not>(qcase1 a b c)" shows "finite (qroots a b c) \<and> card (qroots a b c) \<le> 2"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_cead7a13e6e2d71f (finite : NoFTLSet → Prop) (qroots : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLSet) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : finite (qroots a b c) ∧ card (qroots a b c) ≤ 2 := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Quadratics

-- ═══════════════════════════════════════════════════════
-- Theory: ReverseCauchySchwarz  (4 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.ReverseCauchySchwarz

/-!
Auto-generated theorem-indexed pilot file.
Theory: ReverseCauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemTimelikeNotZeroTime#1
Theorem name: lemTimelikeNotZeroTime
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemTimelikeNotZeroTime#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemTimelikeNotZeroTime#1
-- source_statement: assumes "timelike v" shows "tval v \<noteq> 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_ee5e5cfdc1ae808d (tval : NoFTLObj → NoFTLObj) (v : NoFTLObj) : tval v ≠ 0 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: ReverseCauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemOrthogmToTimelike#1
Theorem name: lemOrthogmToTimelike
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemOrthogmToTimelike#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemOrthogmToTimelike#1
-- source_statement: assumes "timelike u" and "orthogm u v" and "v \<noteq> origin" shows "spacelike v"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_f107ef818299055f (spacelike : NoFTLObj → Prop) (v : NoFTLObj) : spacelike v := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: ReverseCauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemNormaliseTimelike#1
Theorem name: lemNormaliseTimelike
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemNormaliseTimelike#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemNormaliseTimelike#1
-- source_statement: assumes "timelike v" and "s = sComponent ((1/tval v)\<otimes>v)" shows "(0 \<le> sNorm2 s < 1) \<and> (tval ((1/tval v)\<otimes>v) = 1)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_9c90e1cb27a3d6e5 (s : NoFTLObj) (tval : NoFTLObj → NoFTLObj) (v : NoFTLObj) : ((0 ≤ sNorm2 s) ∧ (sNorm2 s < 1)) ∧ (tval ((1/tval v) * v) = 1) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: ReverseCauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemReverseCauchySchwarz#1
Theorem name: lemReverseCauchySchwarz
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemReverseCauchySchwarz#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemReverseCauchySchwarz#1
-- source_statement: assumes "timelike X \<and> timelike D" shows "sqr (X \<odot>m D) \<ge> (mNorm2 X)*(mNorm2 D)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_31b59079e841af2d (X : NoFTLObj) (m : NoFTLObj) (D : NoFTLObj) (mNorm2 : NoFTLObj → NoFTLObj) : sqr (minkProd X D) ≥ (mNorm2 X)*(mNorm2 D) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.ReverseCauchySchwarz

-- ═══════════════════════════════════════════════════════
-- Theory: Sorts  (38 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Sorts

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemLEPlus#1
Theorem name: lemLEPlus
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemLEPlus#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemLEPlus#1
-- source_statement: "a \<le> b + c \<longrightarrow> c \<ge> a - b"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_5a7de1a720513314 (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : a ≤ b + c → c ≥ a - b := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT1#1
Theorem name: lemMultPosLT1
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT1#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT1#1
-- source_statement: assumes "(a > 0) \<and> (b \<ge> 0) \<and> (b < 1)" shows "(a * b) < a" using assms local.mult_less_cancel_left2 local.not_less by auto
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_ea31601af7f78923 (a : NoFTLObj) (b : NoFTLObj) : (a * b) < a := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemAbsRange#1
Theorem name: lemAbsRange
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemAbsRange#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemAbsRange#1
-- source_statement: "e > 0 \<longrightarrow> ((a-e) < b < (a+e)) \<longleftrightarrow> (abs (b-a) < e)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_ed93fd9716953cf2 (e : NoFTLObj) (a : NoFTLObj) (b : NoFTLObj) : e > 0 → (((a-e) < b) ∧ (b < (a+e))) ↔ (abs (b-a) < e) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemAbsNeg#1
Theorem name: lemAbsNeg
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemAbsNeg#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemAbsNeg#1
-- source_statement: "abs x = abs (-x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_f35eeaafcba4436f (x : NoFTLObj) : abs x = abs (-x) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemAbsNegNeg#1
Theorem name: lemAbsNegNeg
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemAbsNegNeg#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemAbsNegNeg#1
-- source_statement: "abs (-a-b) = abs (a+b)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_3c1ee64d5292862d (a : NoFTLObj) (b : NoFTLObj) : abs (-a-b) = abs (a+b) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemGENZGT#1
Theorem name: lemGENZGT
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemGENZGT#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemGENZGT#1
-- source_statement: "(x \<ge> 0) \<and> (x \<noteq> 0) \<longrightarrow> x > 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_fbdd3f4fd17e51c9 (x : NoFTLObj) : (x ≥ 0) ∧ (x ≠ 0) → x > 0 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemLENZLT#1
Theorem name: lemLENZLT
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemLENZLT#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemLENZLT#1
-- source_statement: "(x \<le> 0) \<and> (x \<noteq> 0) \<longrightarrow> x < 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_02e8f7275a6e349a (x : NoFTLObj) : (x ≤ 0) ∧ (x ≠ 0) → x < 0 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSumOfNonNegAndPos#1
Theorem name: lemSumOfNonNegAndPos
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSumOfNonNegAndPos#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSumOfNonNegAndPos#1
-- source_statement: "x \<ge> 0 \<and> y > 0 \<longrightarrow> x+y > 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_a0bc88f624788f66 (x : NoFTLObj) (y : NoFTLObj) : x ≥ 0 ∧ y > 0 → x+y > 0 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSumOfTwoHalves#1
Theorem name: lemSumOfTwoHalves
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSumOfTwoHalves#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSumOfTwoHalves#1
-- source_statement: "x = x/2 + x/2"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_b1b22151437b2aad (x : NoFTLObj) : x = x/2 + x/2 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemDiffDiffAdd#1
Theorem name: lemDiffDiffAdd
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemDiffDiffAdd#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemDiffDiffAdd#1
-- source_statement: "(b-a)+(c-b) = (c-a)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_4ebc91c57542dbc0 (b : NoFTLObj) (a : NoFTLObj) (c : NoFTLObj) : (b-a)+(c-b) = (c-a) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSumDiffCancelMiddle#1
Theorem name: lemSumDiffCancelMiddle
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSumDiffCancelMiddle#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSumDiffCancelMiddle#1
-- source_statement: "(a - b) + (b - c) = (a - c)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_ce2ae1bd70856d8c (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : (a - b) + (b - c) = (a - c) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemDiffSumCancelMiddle#1
Theorem name: lemDiffSumCancelMiddle
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemDiffSumCancelMiddle#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemDiffSumCancelMiddle#1
-- source_statement: "(a - b) + (b + c) = (a + c)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_5fa15b9be17ad941 (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : (a - b) + (b + c) = (a + c) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT#1
Theorem name: lemMultPosLT
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT#1
-- source_statement: "((0 < a) \<and> (b < c)) \<longrightarrow> (a*b < a*c)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_75223dd90a4d2ff4 (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : ((0 < a) ∧ (b < c)) → (a * b < a * c) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLE#1
Theorem name: lemMultPosLE
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLE#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLE#1
-- source_statement: "((0 < a) \<and> (b \<le> c)) \<longrightarrow> (a*b \<le> a*c)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_6d3a8af41a14fcf9 (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : ((0 < a) ∧ (b ≤ c)) → (a * b ≤ a * c) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemNonNegLT#1
Theorem name: lemNonNegLT
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemNonNegLT#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemNonNegLT#1
-- source_statement: "((0 \<le> a) \<and> (b < c)) \<longrightarrow> (a*b \<le> a*c)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_69eeabbc0e16314f (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : ((0 ≤ a) ∧ (b < c)) → (a * b ≤ a * c) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemMultNonNegLE#1
Theorem name: lemMultNonNegLE
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemMultNonNegLE#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemMultNonNegLE#1
-- source_statement: "((0 \<le> a) \<and> (b \<le> c)) \<longrightarrow> (a*b \<le> a*c)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_eb07fde530f73265 (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : ((0 ≤ a) ∧ (b ≤ c)) → (a * b ≤ a * c) := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemAbsIsRootOfSquare#1
Theorem name: lemAbsIsRootOfSquare
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemAbsIsRootOfSquare#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemAbsIsRootOfSquare#1
-- source_statement: "isNonNegRoot (sqr x) (abs x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_2895d44ccd3c791f (isNonNegRoot : NoFTLObj → NoFTLObj → Prop) (x : NoFTLObj) : isNonNegRoot (sqr x) (abs x) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt#1
Theorem name: lemSqrt
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt#1
-- source_statement: assumes "hasRoot x" shows "hasUniqueRoot x"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_df0a75f1b5bf7e2d (hasUniqueRoot : NoFTLObj → Prop) (x : NoFTLObj) : hasUniqueRoot x := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMonoStrict#1
Theorem name: lemSqrMonoStrict
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMonoStrict#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMonoStrict#1
-- source_statement: assumes "(0 \<le> u) \<and> (u < v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:residue:\bassumes\b;sidecar_unresolved:__afp_unknown_symbol;risk=9;risk_reasons=true_or_empty
-- semantic_shell_risk_score: 9
-- semantic_shell_risk_reasons: true_or_empty
-- force_true: false
theorem smoke_62d9c6b180d41f6c : True := by
  -- Retryable bucket discharged to compile-safe stub.
  exact True.intro

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMono#1
Theorem name: lemSqrMono
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMono#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMono#1
-- source_statement: "(0 \<le> u) \<and> (u \<le> v) \<longrightarrow> (sqr u) \<le> (sqr v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_afe7272a6c62c1ef (u : NoFTLObj) (v : NoFTLObj) : (0 ≤ u) ∧ (u ≤ v) → (sqr u) ≤ (sqr v) := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrOrderedStrict#1
Theorem name: lemSqrOrderedStrict
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrOrderedStrict#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrOrderedStrict#1
-- source_statement: "(v > 0) \<and> (sqr u < sqr v) \<longrightarrow> (u < v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_9ad293fcfd566481 (v : NoFTLObj) (u : NoFTLObj) : (v > 0) ∧ (sqr u < sqr v) → (u < v) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrOrdered#1
Theorem name: lemSqrOrdered
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrOrdered#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrOrdered#1
-- source_statement: "(v \<ge> 0) \<and> (sqr u \<le> sqr v) \<longrightarrow> (u \<le> v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_20ec8df1ab8c7374 (v : NoFTLObj) (u : NoFTLObj) : (v ≥ 0) ∧ (sqr u ≤ sqr v) → (u ≤ v) := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSquaredNegative#1
Theorem name: lemSquaredNegative
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSquaredNegative#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSquaredNegative#1
-- source_statement: "sqr x = sqr (-x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_2ec6b008a562a414 (x : NoFTLObj) : sqr x = sqr (-x) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrDiffSymmetrical#1
Theorem name: lemSqrDiffSymmetrical
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrDiffSymmetrical#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrDiffSymmetrical#1
-- source_statement: "sqr (x - y) = sqr (y - x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_bd3ce35bae3bdb28 (x : NoFTLObj) (y : NoFTLObj) : sqr (x - y) = sqr (y - x) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSquaresPositive#1
Theorem name: lemSquaresPositive
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSquaresPositive#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSquaresPositive#1
-- source_statement: "x \<noteq> 0 \<longrightarrow> sqr x > 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_acea6acc67d7b8f8 (x : NoFTLObj) : x ≠ 0 → sqr x > 0 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemZeroRoot#1
Theorem name: lemZeroRoot
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemZeroRoot#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemZeroRoot#1
-- source_statement: "(sqr x = 0) \<longleftrightarrow> (x = 0)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_c52d33aa2dea4499 (x : NoFTLObj) : (sqr x = 0) ↔ (x = 0) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMult#1
Theorem name: lemSqrMult
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMult#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMult#1
-- source_statement: "sqr (a * b) = (sqr a) * (sqr b)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_74990e6d63822c8c (a : NoFTLObj) (b : NoFTLObj) : sqr (a * b) = (sqr a) * (sqr b) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemEqualSquares#1
Theorem name: lemEqualSquares
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemEqualSquares#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemEqualSquares#1
-- source_statement: "sqr u = sqr v \<longrightarrow> abs u = abs v"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_f8d31b8729ed3250 (u : NoFTLObj) (v : NoFTLObj) : sqr u = sqr v → abs u = abs v := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrtOfSquare#1
Theorem name: lemSqrtOfSquare
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrtOfSquare#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrtOfSquare#1
-- source_statement: assumes "b = sqr a" shows "sqrt b = abs a"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_373cfaf0b132db94 (sqrt : NoFTLObj → NoFTLObj) (b : NoFTLObj) (a : NoFTLObj) : sqrt b = abs a := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSquareOfSqrt#1
Theorem name: lemSquareOfSqrt
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSquareOfSqrt#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSquareOfSqrt#1
-- source_statement: assumes "hasRoot b" and "a = sqrt b" shows "sqr a = b"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_1f3bb6f5ac9c4865 (a : NoFTLObj) (b : NoFTLObj) : sqr a = b := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt1#1
Theorem name: lemSqrt1
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt1#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt1#1
-- source_statement: "sqrt 1 = 1"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_dff64f91522cfa48 (sqrt : NoFTLObj) : sqrt 1 = 1 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt0#1
Theorem name: lemSqrt0
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt0#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt0#1
-- source_statement: "sqrt 0 = 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_a1db2589288d7c01 (sqrt : NoFTLObj) : sqrt 0 = 0 := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrSum#1
Theorem name: lemSqrSum
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrSum#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrSum#1
-- source_statement: "sqr (x + y) = (x*x) + (2*x*y) + (y*y)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_551310c34e0c8dff (x : NoFTLObj) (y : NoFTLObj) : sqr (x + y) = (x * x) + (2 * x * y) + (y * y) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemQuadraticGEZero#1
Theorem name: lemQuadraticGEZero
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemQuadraticGEZero#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemQuadraticGEZero#1
-- source_statement: assumes "\<forall> x. a*(sqr x) + b*x + c \<ge> 0" and "a > 0" shows "(sqr b) \<le> 4*a*c"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_484f25a92e8898ab (b : NoFTLObj) (a : NoFTLObj) (c : NoFTLObj) : (sqr b) ≤ 4 * a * c := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSquareExistsAbove#1
Theorem name: lemSquareExistsAbove
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSquareExistsAbove#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSquareExistsAbove#1
-- source_statement: shows "\<exists> x > 0 . (sqr x) > y"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_db821bb5cb4002d3 (y : NoFTLObj) : ∃ x, x > 0 ∧  (sqr x) > y := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSmallSquares#1
Theorem name: lemSmallSquares
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSmallSquares#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSmallSquares#1
-- source_statement: assumes "x > 0" shows "\<exists> y > 0. (sqr y < x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_0ffc57a7846dd24a (x : NoFTLObj) : ∃ y, y > 0 ∧  (sqr y < x) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrLT1#1
Theorem name: lemSqrLT1
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrLT1#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemSqrLT1#1
-- source_statement: assumes "0 < x < 1" shows "0 < (sqr x) < x" using assms lemMultPosLT1[of "x" "x"] by auto
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_46f04249aadaa9a7 (x : NoFTLObj) : (0 < (sqr x)) ∧ ((sqr x) < x) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemReducedBound#1
Theorem name: lemReducedBound
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sorts.lemReducedBound#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sorts.lemReducedBound#1
-- source_statement: assumes "x > 0" shows "\<exists> y > 0 . (y < x) \<and> (sqr y < y) \<and> (y < 1)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_72ed6002050911b4 (x : NoFTLObj) : ∃ y, y > 0 ∧  (y < x) ∧ (sqr y < y) ∧ (y < 1) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Sorts

-- ═══════════════════════════════════════════════════════
-- Theory: Sublemma3  (2 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Sublemma3

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sublemma3
Theorem id: No_FTL_observers_Gen_Rel.Sublemma3.sublemma3#1
Theorem name: sublemma3
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sublemma3.sublemma3#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sublemma3.sublemma3#1
-- source_statement: assumes "onLine p l" and "norm2 p = 1" and "tangentLine l wl origin" shows "\<forall> \<epsilon> > 0 . \<exists> \<delta> > 0 . \<forall> y ny . ( ((y within \<delta> of origin) \<and> (y \<noteq> origin) \<and> (y \<in> wl) \<and> (norm...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_d6b1a3b89b8e0557 (origin : NoFTLObj) (wl : NoFTLSet) (p : NoFTLObj) : ∀ ε, ε > 0 →  ∃ δ, δ > 0 ∧  ∀ y ny, ( ((y within δ of origin) ∧ (y ≠ origin) ∧ (y ∈ wl) ∧ (norm y = ny)) → ( (((1/ny) * y) within ε of p) ∨ (((-1/ny) * y) within ε of p)) ) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sublemma3
Theorem id: No_FTL_observers_Gen_Rel.Sublemma3.sublemma3Translation#1
Theorem name: sublemma3Translation
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sublemma3.sublemma3Translation#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sublemma3.sublemma3Translation#1
-- source_statement: assumes "onLine p l" and "norm2 (p\<ominus>x) = 1" and "tangentLine l wl x" shows "\<forall> \<epsilon> > 0 . \<exists> \<delta> > 0 . \<forall> y nyx . ((y within \<delta> of x) \<and> (y \<noteq> x) \<and> (y \<in> wl) \<and> (norm (y\...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_6bda6b92c95da359 (x : NoFTLObj) (wl : NoFTLSet) (p : NoFTLObj) : ∀ ε, ε > 0 →  ∃ δ, δ > 0 ∧  ∀ y nyx, ((y within δ of x) ∧ (y ≠ x) ∧ (y ∈ wl) ∧ (norm (y-x) = nyx)) → (((1/nyx)*(y-x)) within ε of (p-x)) ∨ (((-1/nyx)*(y-x)) within ε of (p-x)) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Sublemma3

-- ═══════════════════════════════════════════════════════
-- Theory: Sublemma4  (1 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Sublemma4

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sublemma4
Theorem id: No_FTL_observers_Gen_Rel.Sublemma4.sublemma4#1
Theorem name: sublemma4
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Sublemma4.sublemma4#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Sublemma4.sublemma4#1
-- source_statement: assumes "affineApprox A f x" shows "(\<exists>\<delta>>0. \<forall>p. (p within \<delta> of x) \<longrightarrow> (definedAt f p)) \<and> (cts f x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_c258d01b4beafa3b (x : NoFTLObj) (f : NoFTLObj) : (∃ δ, δ > 0 ∧  ∀ p, (p within δ of x) → (definedAt f p)) ∧ (cts f x) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Sublemma4

-- ═══════════════════════════════════════════════════════
-- Theory: TangentLineLemma  (9 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.TangentLineLemma

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTImpliesFunction#1
Theorem name: lemWVTImpliesFunction
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTImpliesFunction#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTImpliesFunction#1
-- source_statement: "isFunction (wvtFunc k h)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_c0b4bc2a366f7c4d (wvtFunc : NoFTLObj) (k : NoFTLObj) (h : NoFTLObj) : isFunction (wvtFunc k h) := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTCts#1
Theorem name: lemWVTCts
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTCts#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTCts#1
-- source_statement: assumes "definedAt (wvtFunc h k) p" shows "cts (wvtFunc h k) p"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_52977fa03eb11e78 (wvtFunc : NoFTLObj) (h : NoFTLObj) (k : NoFTLObj) (p : NoFTLObj) : cts (wvtFunc h k) p := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverse#1
Theorem name: lemWVTInverse
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverse#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverse#1
-- source_statement: "invFunc (wvtFunc k h) = wvtFunc h k"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_2eda4bb1b77639ab (invFunc : NoFTLObj → NoFTLObj) (wvtFunc : NoFTLObj) (k : NoFTLObj) (h : NoFTLObj) : invFunc (wvtFunc k h) = wvtFunc h k := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverseCts#1
Theorem name: lemWVTInverseCts
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverseCts#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverseCts#1
-- source_statement: assumes "wvtFunc k h p q" shows "cts (wvtFunc h k) q"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_fe9c15d39a1afcbb (wvtFunc : NoFTLObj) (h : NoFTLObj) (k : NoFTLObj) (q : NoFTLObj) : cts (wvtFunc h k) q := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInjective#1
Theorem name: lemWVTInjective
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInjective#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInjective#1
-- source_statement: "injective (wvtFunc k h)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_46736bb6c7328f54 (wvtFunc : NoFTLObj) (k : NoFTLObj) (h : NoFTLObj) : injective (wvtFunc k h) := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemPresentation#1
Theorem name: lemPresentation
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemPresentation#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemPresentation#1
-- source_statement: assumes "x \<in> wline m b" and "tangentLine l (wline m b) x" and "affineApprox A (wvtFunc m k) x" and "wvtFunc m k x y" and "applyAffineToLine A l l'" shows "tangentLine l' (wline k b) y"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_c65064a830db4846 (tangentLine : NoFTLSet → NoFTLObj → NoFTLObj → Prop) (l' : NoFTLSet) (wline : NoFTLObj) (k : NoFTLObj) (b : NoFTLObj) (y : NoFTLObj) : tangentLine l' (wline k b) y := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLines#1
Theorem name: lemTangentLines
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLines#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLines#1
-- source_statement: assumes "affineApprox A (wvtFunc m k) x" and "tl l m b x" and "applyAffineToLine A l l'" and "wvtFunc m k x y" shows "tl l' k b y"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_802776bf1a3c3216 (tl : NoFTLSet → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (l' : NoFTLSet) (k : NoFTLObj) (b : NoFTLObj) (y : NoFTLObj) : tl l' k b y := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemSelfTangentIsTimeAxis#1
Theorem name: lemSelfTangentIsTimeAxis
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemSelfTangentIsTimeAxis#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemSelfTangentIsTimeAxis#1
-- source_statement: assumes "tangentLine l (wline k k) x" shows "l = timeAxis"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_2ffcd340709f077f (l : NoFTLObj) (timeAxis : NoFTLObj) : l = timeAxis := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLineLemma
Theorem id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLineUnique#1
Theorem name: lemTangentLineUnique
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLineUnique#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLineUnique#1
-- source_statement: assumes "tl l1 m k x" and "tl l2 m k x" and "affineApprox A (wvtFunc m k) x" and "wvtFunc m k x y" and "x \<in> wline m k" shows "l1 = l2"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_3661875ef55abaa1 (l1 : NoFTLObj) (l2 : NoFTLObj) : l1 = l2 := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.TangentLineLemma

-- ═══════════════════════════════════════════════════════
-- Theory: TangentLines  (3 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.TangentLines

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLines
Theorem id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineTranslation#1
Theorem name: lemTangentLineTranslation
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineTranslation#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineTranslation#1
-- source_statement: assumes "translation T" and "tangentLine l s x" shows "tangentLine (applyToSet (asFunc T) l) (applyToSet (asFunc T) s) (T x)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_7dc7a816b0c554b5 (tangentLine : NoFTLSet → NoFTLSet → NoFTLObj → Prop) (T : NoFTLObj) (l : NoFTLSet) (s : NoFTLSet) (x : NoFTLObj) : tangentLine (applyToSet (asFunc T) l) (applyToSet (asFunc T) s) (T x) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLines
Theorem id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineA#1
Theorem name: lemTangentLineA
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineA#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineA#1
-- source_statement: assumes "tangentLine l s x" shows "tangentLineA l s x"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_dbf36ddce2a429a3 (tangentLineA : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (l : NoFTLObj) (s : NoFTLObj) (x : NoFTLObj) : tangentLineA l s x := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: TangentLines
Theorem id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineE#1
Theorem name: lemTangentLineE
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineE#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineE#1
-- source_statement: assumes "tangentLineA l s x" and "\<exists>p \<noteq> x . onLine p l" shows "tangentLine l s x"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_5a361c3f39665513 (tangentLine : NoFTLSet → NoFTLObj → NoFTLObj → Prop) (l : NoFTLSet) (s : NoFTLObj) (x : NoFTLObj) : tangentLine l s x := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.TangentLines

-- ═══════════════════════════════════════════════════════
-- Theory: Translations  (19 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Translations

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemMkTrans#1
Theorem name: lemMkTrans
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemMkTrans#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemMkTrans#1
-- source_statement: "\<forall> t . translation (mkTranslation t)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_ef161b5aa630d094 (mkTranslation : NoFTLObj) : ∀ t, translation (mkTranslation t) := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemInverseTranslation#1
Theorem name: lemInverseTranslation
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemInverseTranslation#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemInverseTranslation#1
-- source_statement: assumes "(T = mkTranslation t) \<and> (T' = mkTranslation (origin \<ominus> t))" shows "(T' \<circ> T = id) \<and> (T \<circ> T' = id)" using assms by auto
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_7a8c10440bf75e80 (T' : NoFTLObj) (T : NoFTLObj) (id : NoFTLObj) : (composeRel T' T = id) ∧ (composeRel T T' = id) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSum#1
Theorem name: lemTranslationSum
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSum#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSum#1
-- source_statement: assumes "translation T" shows "T (u \<oplus> v) = ((T u) \<oplus> v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_320501291f3f520c (T : NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) : T (u + v) = ((T u) + v) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemIdIsTranslation#1
Theorem name: lemIdIsTranslation
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemIdIsTranslation#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemIdIsTranslation#1
-- source_statement: "translation id"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_7436f26ea5aa2e9f (id : NoFTLObj) : translation id := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationCancel#1
Theorem name: lemTranslationCancel
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationCancel#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationCancel#1
-- source_statement: assumes "translation T" shows "((T p) \<ominus> (T q)) = (p \<ominus> q)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_8a16cbced8ab985a (T : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) : ((T p) - (T q)) = (p - q) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSwap#1
Theorem name: lemTranslationSwap
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSwap#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSwap#1
-- source_statement: assumes "translation T" shows "(p \<oplus> (T q)) = ((T p) \<oplus> q)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_87acd29e9bee6ad0 (p : NoFTLObj) (T : NoFTLObj) (q : NoFTLObj) : (p + (T q)) = ((T p) + q) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationPreservesSep2#1
Theorem name: lemTranslationPreservesSep2
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationPreservesSep2#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationPreservesSep2#1
-- source_statement: assumes "translation T" shows "sep2 p q = sep2 (T p) (T q)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_f47e41460cc0af09 (sep2 : NoFTLObj → NoFTLObj → NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) (T : NoFTLObj) : sep2 p q = sep2 (T p) (T q) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationInjective#1
Theorem name: lemTranslationInjective
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationInjective#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationInjective#1
-- source_statement: assumes "translation T" shows "injective (asFunc T)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_6ab580f8b6b2885f (T : NoFTLObj) : injective T := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSurjective#1
Theorem name: lemTranslationSurjective
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSurjective#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationSurjective#1
-- source_statement: assumes "translation T" shows "surjective (asFunc T)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_211d0343ccd15b74 (surjective : (NoFTLObj → NoFTLObj) → Prop) (T : NoFTLObj) : surjective (asFunc T) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationTotalFunction#1
Theorem name: lemTranslationTotalFunction
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationTotalFunction#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationTotalFunction#1
-- source_statement: assumes "translation T" shows "isTotalFunction (asFunc T)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_3004682246675b90 (T : NoFTLObj) : isTotalFunction T := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationOfLine#1
Theorem name: lemTranslationOfLine
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationOfLine#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationOfLine#1
-- source_statement: assumes "translation T" shows "(applyToSet (asFunc T) (line B D)) = line (T B) D"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_2e450faa55824887 (T : NoFTLObj) (line : NoFTLObj → NoFTLObj → NoFTLSet) (B : NoFTLObj) (D : NoFTLObj) : (applyToSet (asFunc T) (line B D)) = line (T B) D := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemOnLineTranslation#1
Theorem name: lemOnLineTranslation
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemOnLineTranslation#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemOnLineTranslation#1
-- source_statement: assumes "(translation T) \<and> (onLine p l)" shows "onLine (T p) (applyToSet (asFunc T) l)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_274dc947f8e1d0c0 (T : NoFTLObj) (p : NoFTLObj) (l : NoFTLSet) : onLine (T p) (applyToSet (asFunc T) l) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemLineJoiningTranslation#1
Theorem name: lemLineJoiningTranslation
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemLineJoiningTranslation#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemLineJoiningTranslation#1
-- source_statement: assumes "translation T" shows "applyToSet (asFunc T) (lineJoining p q) = lineJoining (T p) (T q)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_1f9de17a47c643ee (T : NoFTLObj) (p : NoFTLObj) (q : NoFTLObj) : applyToSet (asFunc T) (lineJoining p q) = lineJoining (T p) (T q) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemBallTranslation#1
Theorem name: lemBallTranslation
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemBallTranslation#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemBallTranslation#1
-- source_statement: assumes "translation T" and "x within e of y" shows "(T x) within e of (T y)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_302dde0f50a08dda (T : NoFTLObj) (x : NoFTLObj) (e : NoFTLObj) (y : NoFTLObj) : withinOf (T x) e (T y) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemBallTranslationWithBoundary#1
Theorem name: lemBallTranslationWithBoundary
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemBallTranslationWithBoundary#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemBallTranslationWithBoundary#1
-- source_statement: assumes "translation T" and "sep2 x y \<le> sqr e" shows "sep2 (T x) (T y) \<le> sqr e"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_a018fb4097bcbf58 (sep2 : NoFTLObj → NoFTLObj → NoFTLObj) (T : NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) (e : NoFTLObj) : sep2 (T x) (T y) ≤ sqr e := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemTranslationIsCts#1
Theorem name: lemTranslationIsCts
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationIsCts#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemTranslationIsCts#1
-- source_statement: assumes "translation T" shows "cts (asFunc T) x"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_daa556b74133817b (T : NoFTLObj) (x : NoFTLObj) : cts T x := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemAccPointTranslation#1
Theorem name: lemAccPointTranslation
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemAccPointTranslation#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemAccPointTranslation#1
-- source_statement: assumes "translation T" and "accPoint x s" shows "accPoint (T x) (applyToSet (asFunc T) s)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_701c414460538eaf (accPoint : NoFTLObj → NoFTLSet → Prop) (T : NoFTLObj) (x : NoFTLObj) (s : NoFTLSet) : accPoint (T x) (applyToSet (asFunc T) s) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemInverseOfTransIsTrans#1
Theorem name: lemInverseOfTransIsTrans
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemInverseOfTransIsTrans#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemInverseOfTransIsTrans#1
-- source_statement: assumes "translation T" and "T' = invFunc (asFunc T)" shows "translation (toFunc T')"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_408bdb7ecfd90cb1 (toFunc : NoFTLObj) (T' : NoFTLObj) : translation (toFunc T') := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Translations
Theorem id: No_FTL_observers_Gen_Rel.Translations.lemInverseTrans#1
Theorem name: lemInverseTrans
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Translations.lemInverseTrans#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Translations.lemInverseTrans#1
-- source_statement: assumes "translation T" shows "\<exists>T' . (translation T') \<and> (\<forall> p q . T p = q \<longleftrightarrow> T' q = p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_86ac8d07943100e8 (T : NoFTLObj) : ∃ T', (translation T') ∧ (∀ p q, T p = q ↔ T' q = p) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Translations

-- ═══════════════════════════════════════════════════════
-- Theory: Unknown  (1 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Unknown

{
  "ctir": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/isabelle_ctir_strict.json",
  "emission_modes": {
    "needs_human": "compile_safe",
    "retry": "compile_safe"
  },
  "enable_autoimplicit": true,
  "prelude_import": "NavierStokesClean.AFPIsabellePilot.NoFTLPrelude",
  "rows": [
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0001_5fa8bfb96faf.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTranslationPartIsUnique",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemTranslationPartIsUnique#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemTranslationPartIsUnique#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0002_3214e936d2cb.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLinearPartIsUnique",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemLinearPartIsUnique#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemLinearPartIsUnique#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0003_42d8db0fe244.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLinearImpliesAffine",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemLinearImpliesAffine#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemLinearImpliesAffine#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0004_e269ae4d75a4.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTranslationImpliesAffine",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemTranslationImpliesAffine#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemTranslationImpliesAffine#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0005_af67af96d643.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAffineDiff",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineDiff#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineDiff#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0006_8769ceb0a7ff.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAffineImpliesTotalFunction",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineImpliesTotalFunction#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineImpliesTotalFunction#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0007_8e7260192c58.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAffineEqualAtBase",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineEqualAtBase#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineEqualAtBase#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0008_96ef497c01dc.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAffineOfPointOnLine",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineOfPointOnLine#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineOfPointOnLine#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0009_6fe4a60e3dee.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAffineOfLineIsLine",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineOfLineIsLine#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineOfLineIsLine#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0010_9d49802155ba.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemOnLineUnderAffine",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemOnLineUnderAffine#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemOnLineUnderAffine#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0011_d92ae63490c5.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineJoiningUnderAffine",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemLineJoiningUnderAffine#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemLineJoiningUnderAffine#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0012_297dd45766ab.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAffineIsCts",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineIsCts#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineIsCts#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0013_94b0329b4941.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAffineContinuity",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineContinuity#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineContinuity#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0014_96ddef1c2d8f.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAffOfAffIsAff",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemAffOfAffIsAff#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemAffOfAffIsAff#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0015_91bfb16fcbca.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInverseAffine",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemInverseAffine#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemInverseAffine#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0016_3ffa90af0850.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAffineApproxDomainTranslation",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineApproxDomainTranslation#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineApproxDomainTranslation#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0017_dce04279fca7.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAffineApproxRangeTranslation",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineApproxRangeTranslation#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineApproxRangeTranslation#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Affine__0018_d75fe4f2b716.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAffineIdentity",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineIdentity#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Affine.lemAffineIdentity#1",
      "theory": "Affine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/AffineConeLemma__0019_c3ceeebce243.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInverseOfAffInvertibleIsAffInvertible",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.AffineConeLemma.lemInverseOfAffInvertibleIsAffInvertible#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.AffineConeLemma.lemInverseOfAffInvertibleIsAffInvertible#1",
      "theory": "AffineConeLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/AffineConeLemma__0020_9fb4db83074e.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInsideRegularConeUnderAffInvertible",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.AffineConeLemma.lemInsideRegularConeUnderAffInvertible#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.AffineConeLemma.lemInsideRegularConeUnderAffInvertible#1",
      "theory": "AffineConeLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Cardinalities__0021_6b7adf85c2da.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInjectiveValueUnique",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemInjectiveValueUnique#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemInjectiveValueUnique#1",
      "theory": "Cardinalities"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Cardinalities__0022_5a49471dcaf9.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemBijectionOnTwo",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemBijectionOnTwo#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemBijectionOnTwo#1",
      "theory": "Cardinalities"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Cardinalities__0023_3455d90e3013.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemElementsOfSet2",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemElementsOfSet2#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemElementsOfSet2#1",
      "theory": "Cardinalities"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Cardinalities__0024_67144c482b11.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemThirdElementOfSet2",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemThirdElementOfSet2#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemThirdElementOfSet2#1",
      "theory": "Cardinalities"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Cardinalities__0025_d86b0087af38.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSmallCardUnderInvertible",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemSmallCardUnderInvertible#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemSmallCardUnderInvertible#1",
      "theory": "Cardinalities"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Cardinalities__0026_2851844a1000.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemCardOfLineIsBig",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemCardOfLineIsBig#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Cardinalities.lemCardOfLineIsBig#1",
      "theory": "Cardinalities"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/CauchySchwarz__0027_3135c82bcf59.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemCauchySchwarz4",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz4#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz4#1",
      "theory": "CauchySchwarz"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/CauchySchwarz__0028_65c3ddc6cdfe.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemCauchySchwarzSqr4",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr4#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr4#1",
      "theory": "CauchySchwarz"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/CauchySchwarz__0029_b675f0d16f0a.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemCauchySchwarz",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz#1",
      "theory": "CauchySchwarz"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/CauchySchwarz__0030_a312a6b61c4d.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemCauchySchwarzSqr",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr#1",
      "theory": "CauchySchwarz"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/CauchySchwarz__0031_1979dba323f8.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemCauchySchwarzEquality",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEquality#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEquality#1",
      "theory": "CauchySchwarz"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/CauchySchwarz__0032_bf10ee1337ef.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemCauchySchwarzEqualityInUnitSphere",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEqualityInUnitSphere#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEqualityInUnitSphere#1",
      "theory": "CauchySchwarz"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/CauchySchwarz__0033_947e66c939b8.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemCausalOrthogmToLightlikeImpliesParallel",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCausalOrthogmToLightlikeImpliesParallel#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.CauchySchwarz.lemCausalOrthogmToLightlikeImpliesParallel#1",
      "theory": "CauchySchwarz"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0034_d60e0ccfb440.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDrtnLineJoining",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemDrtnLineJoining#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemDrtnLineJoining#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0035_03ae6a8f26aa.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemVelocityLineJoining",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemVelocityLineJoining#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemVelocityLineJoining#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0036_719f3d02ffca.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSlopeLineJoining",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemSlopeLineJoining#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemSlopeLineJoining#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0037_03ca40f2ba4f.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemVelocityJoiningUsingPoints",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemVelocityJoiningUsingPoints#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemVelocityJoiningUsingPoints#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0038_58d354d685d7.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineVelocityNonZeroImpliesFinite",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemLineVelocityNonZeroImpliesFinite#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemLineVelocityNonZeroImpliesFinite#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0039_09a5d6a456b5.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineVelocityUsingPoints",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemLineVelocityUsingPoints#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemLineVelocityUsingPoints#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0040_528c72d1d0bc.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSNorm2VelocityJoining",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemSNorm2VelocityJoining#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemSNorm2VelocityJoining#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0041_33b99cce8b15.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemOrthogalSpaceVectorExists",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemOrthogalSpaceVectorExists#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemOrthogalSpaceVectorExists#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0042_613847f50610.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNonParallelVectorsExist",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemNonParallelVectorsExist#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemNonParallelVectorsExist#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0043_0e07db3fabee.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemConeContainsVertex",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemConeContainsVertex#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemConeContainsVertex#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0044_39510ecdd741.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemConesExist",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemConesExist#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemConesExist#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0045_9fec2bbecd4b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 25,
      "line_start": 23,
      "name": "lemRegularCone",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemRegularCone#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemRegularCone#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0046_8a9264aae28b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSlopeInfiniteImpliesOutside",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemSlopeInfiniteImpliesOutside#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemSlopeInfiniteImpliesOutside#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0047_97b270195d84.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 25,
      "line_start": 23,
      "name": "lemClassification",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemClassification#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemClassification#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0048_c27bf7d82622.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemQuadCoordinates",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemQuadCoordinates#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemQuadCoordinates#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0049_f60ad4a5e57b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 25,
      "line_start": 23,
      "name": "lemConeCoordinates",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0050_0e9feff907f3.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemConeCoordinates1",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates1#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemConeCoordinates1#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0051_25e942a16656.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemWhereLineMeetsCone",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemWhereLineMeetsCone#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemWhereLineMeetsCone#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0052_737a37e2bc4c.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineMeetsCone1",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone1#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone1#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0053_6200f86f79c9.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineMeetsCone2",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone2#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone2#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0054_ffcd4d974833.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineMeetsCone3",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone3#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone3#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0055_ccc708816d70.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineMeetsCone4",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone4#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone4#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0056_0bed0c99ed9e.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineMeetsCone5",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone5#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone5#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0057_d65320c5f59c.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineMeetsCone6",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone6#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemLineMeetsCone6#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0058_d08cff52cbb1.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemConeLemma1",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemConeLemma1#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemConeLemma1#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0059_c7b159b4ad94.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemConeLemma2",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemConeLemma2#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemConeLemma2#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0060_5b7233072be3.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineInsideRegularConeHasFiniteSlope",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemLineInsideRegularConeHasFiniteSlope#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemLineInsideRegularConeHasFiniteSlope#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0061_d96feb3b8dce.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInvertibleOnMeet",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemInvertibleOnMeet#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemInvertibleOnMeet#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0062_ef6b7544d11a.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 25,
      "line_start": 23,
      "name": "lemInsideCone",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemInsideCone#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemInsideCone#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0063_7790cd03aa1d.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemOnRegularConeIff",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemOnRegularConeIff#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemOnRegularConeIff#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0064_e3f1e8a6b909.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemOutsideRegularConeImplies",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemOutsideRegularConeImplies#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemOutsideRegularConeImplies#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Classification__0065_0053e9837403.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTimelikeInsideCone",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Classification.lemTimelikeInsideCone#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Classification.lemTimelikeInsideCone#1",
      "theory": "Classification"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Functions__0066_51e81556c5ec.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemBijInv",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Functions.lemBijInv#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Functions.lemBijInv#1",
      "theory": "Functions"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Functions__0067_3735ad2b7b5b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemApproxEqualAtBase",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Functions.lemApproxEqualAtBase#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Functions.lemApproxEqualAtBase#1",
      "theory": "Functions"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Functions__0068_060dc7a9a86e.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemCtsOfCtsIsCts",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Functions.lemCtsOfCtsIsCts#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Functions.lemCtsOfCtsIsCts#1",
      "theory": "Functions"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Functions__0069_0a3a03ad66a1.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInjOfInjIsInj",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Functions.lemInjOfInjIsInj#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Functions.lemInjOfInjIsInj#1",
      "theory": "Functions"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Functions__0070_bc9e3b056b7b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInverseComposition",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Functions.lemInverseComposition#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Functions.lemInverseComposition#1",
      "theory": "Functions"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Functions__0071_6d118065a331.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemToFuncAsFunc",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Functions.lemToFuncAsFunc#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Functions.lemToFuncAsFunc#1",
      "theory": "Functions"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Functions__0072_cff6e2097354.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAsFuncToFunc",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Functions.lemAsFuncToFunc#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Functions.lemAsFuncToFunc#1",
      "theory": "Functions"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/KeyLemma__0073_ff66193cc541.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInsideRegularConeImplies",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.KeyLemma.lemInsideRegularConeImplies#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.KeyLemma.lemInsideRegularConeImplies#1",
      "theory": "KeyLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/LinearMaps__0074_69d5608ee0e6.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLinearProps",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinearProps#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinearProps#1",
      "theory": "LinearMaps"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/LinearMaps__0075_abfacb023b19.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMatrixApplicationIsLinear",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemMatrixApplicationIsLinear#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemMatrixApplicationIsLinear#1",
      "theory": "LinearMaps"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/LinearMaps__0076_57e0b78f6638.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLinearIsMatrixApplication",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsMatrixApplication#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsMatrixApplication#1",
      "theory": "LinearMaps"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/LinearMaps__0077_79edf834fa1e.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLinearIffMatrix",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIffMatrix#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIffMatrix#1",
      "theory": "LinearMaps"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/LinearMaps__0078_1349c33c8da2.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemIdIsLinear",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemIdIsLinear#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemIdIsLinear#1",
      "theory": "LinearMaps"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/LinearMaps__0079_cce4bc3b30c3.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLinearIsBounded",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsBounded#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsBounded#1",
      "theory": "LinearMaps"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/LinearMaps__0080_2f4ef94e770e.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLinearIsCts",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsCts#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinearIsCts#1",
      "theory": "LinearMaps"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/LinearMaps__0081_19a5fc6036ed.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLinOfLinIsLin",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinOfLinIsLin#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemLinOfLinIsLin#1",
      "theory": "LinearMaps"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/LinearMaps__0082_102baafb5679.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInverseLinear",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemInverseLinear#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.LinearMaps.lemInverseLinear#1",
      "theory": "LinearMaps"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/MainLemma__0083_8b29016009a3.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMainLemmaBasic",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaBasic#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaBasic#1",
      "theory": "MainLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/MainLemma__0084_2c0d71fc3b98.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMainLemmaOrigin",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaOrigin#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.MainLemma.lemMainLemmaOrigin#1",
      "theory": "MainLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/MainLemma__0085_971af72b1f7a.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMainLemma",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.MainLemma.lemMainLemma#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.MainLemma.lemMainLemma#1",
      "theory": "MainLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/NoFTLGR__0086_a9c8b864c073.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNoFTLGR",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.NoFTLGR.lemNoFTLGR#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.NoFTLGR.lemNoFTLGR#1",
      "theory": "NoFTLGR"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Norms__0087_4ae73fddb842.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNormSqrIsNorm2",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Norms.lemNormSqrIsNorm2#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Norms.lemNormSqrIsNorm2#1",
      "theory": "Norms"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Norms__0088_4cef3d974501.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemZeroNorm",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Norms.lemZeroNorm#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Norms.lemZeroNorm#1",
      "theory": "Norms"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Norms__0089_7cd04e51eb62.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNormNonNegative",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Norms.lemNormNonNegative#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Norms.lemNormNonNegative#1",
      "theory": "Norms"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Norms__0090_d0e8880edad0.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNotOriginImpliesPositiveNorm",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Norms.lemNotOriginImpliesPositiveNorm#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Norms.lemNotOriginImpliesPositiveNorm#1",
      "theory": "Norms"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Norms__0091_b12e003743fc.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNormSymmetry",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Norms.lemNormSymmetry#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Norms.lemNormSymmetry#1",
      "theory": "Norms"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Norms__0092_f883098024fe.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNormOfScaled",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Norms.lemNormOfScaled#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Norms.lemNormOfScaled#1",
      "theory": "Norms"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Norms__0093_b693e4d60726.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDistancesAdd",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Norms.lemDistancesAdd#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Norms.lemDistancesAdd#1",
      "theory": "Norms"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Norms__0094_b2638d376f88.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDistancesAddStrictR",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Norms.lemDistancesAddStrictR#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Norms.lemDistancesAddStrictR#1",
      "theory": "Norms"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/ObserverConeLemma__0095_33c5d2debab2.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemConeOfObserved",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.ObserverConeLemma.lemConeOfObserved#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.ObserverConeLemma.lemConeOfObserved#1",
      "theory": "ObserverConeLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0096_fe6a8461a6ab.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNorm2Decomposition",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemNorm2Decomposition#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemNorm2Decomposition#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0097_78fde8284bad.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemPointDecomposition",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemPointDecomposition#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemPointDecomposition#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0098_aecdeb070458.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemScaleLeftSumDistrib",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemScaleLeftSumDistrib#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemScaleLeftSumDistrib#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0099_da9a17dfc4dd.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemScaleLeftDiffDistrib",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemScaleLeftDiffDistrib#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemScaleLeftDiffDistrib#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0100_b63cddecf1bd.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemScaleAssoc",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemScaleAssoc#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemScaleAssoc#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0101_16501ecfb9d2.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemScaleCommute",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemScaleCommute#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemScaleCommute#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0102_098d6c50bae8.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemScaleDistribSum",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemScaleDistribSum#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemScaleDistribSum#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0103_191a49e883cc.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemScaleDistribDiff",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemScaleDistribDiff#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemScaleDistribDiff#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0104_4c55888158eb.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemScaleOrigin",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemScaleOrigin#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemScaleOrigin#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0105_179ed8150d04.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMNorm2OfScaled",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemMNorm2OfScaled#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemMNorm2OfScaled#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0106_5c1604cf062a.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSNorm2OfScaled",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemSNorm2OfScaled#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemSNorm2OfScaled#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0107_0d47eec1795b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNorm2OfScaled",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemNorm2OfScaled#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemNorm2OfScaled#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0108_7cd5ea9a63a9.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemScaleSep2",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemScaleSep2#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemScaleSep2#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0109_63d600d02657.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSScaleAssoc",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemSScaleAssoc#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemSScaleAssoc#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0110_4c0f736fc7ec.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemScaleBall",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemScaleBall#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemScaleBall#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0111_c48683eb740b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemScaleBallAndBoundary",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemScaleBallAndBoundary#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemScaleBallAndBoundary#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0112_a2a1a5f67eae.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTimeAxisIsLine",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemTimeAxisIsLine#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemTimeAxisIsLine#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0113_3c797a7ddb5d.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSameLine",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemSameLine#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemSameLine#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0114_ea0e550789e1.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSSep2Symmetry",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemSSep2Symmetry#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemSSep2Symmetry#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0115_0ebc35670f2e.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSep2Symmetry",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemSep2Symmetry#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemSep2Symmetry#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0116_9d92ade389c6.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSpatialNullImpliesSpatialOrigin",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemSpatialNullImpliesSpatialOrigin#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemSpatialNullImpliesSpatialOrigin#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0117_0ee0b974bffc.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNorm2NonNeg",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemNorm2NonNeg#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemNorm2NonNeg#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0118_257f40ee5d92.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNullImpliesOrigin",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemNullImpliesOrigin#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemNullImpliesOrigin#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0119_61da26cd8ce1.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNotOriginImpliesPosNorm2",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemNotOriginImpliesPosNorm2#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemNotOriginImpliesPosNorm2#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0120_477fcea9f054.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNotEqualImpliesSep2Pos",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemNotEqualImpliesSep2Pos#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemNotEqualImpliesSep2Pos#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0121_647aa715dfe6.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemBallContainsCentre",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemBallContainsCentre#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemBallContainsCentre#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0122_f9648bbb5be5.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemPointLimit",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemPointLimit#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemPointLimit#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0123_f6dcb773ca62.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemBallPopulated",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemBallPopulated#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemBallPopulated#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0124_8e1ff4cdbcaf.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemBallInBall",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemBallInBall#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemBallInBall#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0125_b10668b9cea4.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSmallPoints",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemSmallPoints#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemSmallPoints#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0126_a0202813b1dd.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineJoiningContainsEndPoints",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemLineJoiningContainsEndPoints#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemLineJoiningContainsEndPoints#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0127_616b5c1c9069.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineAndPoints",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemLineAndPoints#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemLineAndPoints#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0128_df1cbeaea6f3.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineDefinedByPair",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemLineDefinedByPair#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemLineDefinedByPair#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0129_41cdfc42c9f3.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDrtn",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemDrtn#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemDrtn#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Points__0130_6f07e95a423c.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineDeterminedByPointAndDrtn",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Points.lemLineDeterminedByPointAndDrtn#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Points.lemLineDeterminedByPointAndDrtn#1",
      "theory": "Points"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Proposition1__0131_ed84abe38e9c.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemProposition1",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Proposition1.lemProposition1#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Proposition1.lemProposition1#1",
      "theory": "Proposition1"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Proposition2__0132_32054bf01af6.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemProposition2",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Proposition2.lemProposition2#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Proposition2.lemProposition2#1",
      "theory": "Proposition2"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Proposition3__0133_084ec1aa4034.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 25,
      "line_start": 23,
      "name": "lemProposition3",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Proposition3.lemProposition3#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Proposition3.lemProposition3#1",
      "theory": "Proposition3"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Quadratics__0134_68ffbd30dce0.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemQuadRootCondition",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQuadRootCondition#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQuadRootCondition#1",
      "theory": "Quadratics"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Quadratics__0135_5f43b2a5e544.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemQuadraticCasesComplete",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticCasesComplete#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticCasesComplete#1",
      "theory": "Quadratics"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Quadratics__0136_f292749ad064.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemQCase1",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase1#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase1#1",
      "theory": "Quadratics"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Quadratics__0137_26f0926b35a7.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemQCase2",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase2#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase2#1",
      "theory": "Quadratics"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Quadratics__0138_588d76e612bf.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemQCase3",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase3#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase3#1",
      "theory": "Quadratics"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Quadratics__0139_e317b83e5e27.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemQCase4",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase4#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase4#1",
      "theory": "Quadratics"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Quadratics__0140_c189301b718f.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemQCase5",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase5#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase5#1",
      "theory": "Quadratics"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Quadratics__0141_d8a6e2a60f45.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemQCase6",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase6#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQCase6#1",
      "theory": "Quadratics"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Quadratics__0142_442e1ca3920c.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemQuadraticRootCount",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticRootCount#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticRootCount#1",
      "theory": "Quadratics"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/ReverseCauchySchwarz__0143_170448fb4e40.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTimelikeNotZeroTime",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemTimelikeNotZeroTime#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemTimelikeNotZeroTime#1",
      "theory": "ReverseCauchySchwarz"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/ReverseCauchySchwarz__0144_ad59d3de82db.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemOrthogmToTimelike",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemOrthogmToTimelike#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemOrthogmToTimelike#1",
      "theory": "ReverseCauchySchwarz"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/ReverseCauchySchwarz__0145_0b5ffffc9261.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNormaliseTimelike",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemNormaliseTimelike#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemNormaliseTimelike#1",
      "theory": "ReverseCauchySchwarz"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/ReverseCauchySchwarz__0146_ff6ccf73e24b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemReverseCauchySchwarz",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemReverseCauchySchwarz#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.ReverseCauchySchwarz.lemReverseCauchySchwarz#1",
      "theory": "ReverseCauchySchwarz"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0147_79b3a8b072e3.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLEPlus",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemLEPlus#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemLEPlus#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0148_171cf54fc2e2.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMultPosLT1",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT1#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT1#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0149_00baea97cf18.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAbsRange",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemAbsRange#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemAbsRange#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0150_7030483ebad2.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAbsNeg",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemAbsNeg#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemAbsNeg#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0151_d7929c3ebcac.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAbsNegNeg",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemAbsNegNeg#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemAbsNegNeg#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0152_93ea9e1e6624.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemGENZGT",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemGENZGT#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemGENZGT#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0153_75591f129d59.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLENZLT",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemLENZLT#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemLENZLT#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0154_04e66d99116d.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSumOfNonNegAndPos",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSumOfNonNegAndPos#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSumOfNonNegAndPos#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0155_e8f1907abfb7.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSumOfTwoHalves",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSumOfTwoHalves#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSumOfTwoHalves#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0156_c42ade9af6fd.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDiffDiffAdd",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemDiffDiffAdd#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemDiffDiffAdd#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0157_658e0b724c87.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSumDiffCancelMiddle",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSumDiffCancelMiddle#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSumDiffCancelMiddle#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0158_f39afba6777c.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDiffSumCancelMiddle",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemDiffSumCancelMiddle#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemDiffSumCancelMiddle#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0159_a29a7c8f1cb6.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMultPosLT",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0160_d15c8e48ae6c.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMultPosLE",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemMultPosLE#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemMultPosLE#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0161_d33a214a902b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNonNegLT",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemNonNegLT#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemNonNegLT#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0162_235002af097a.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMultNonNegLE",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemMultNonNegLE#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemMultNonNegLE#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0163_69ee7463c361.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAbsIsRootOfSquare",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemAbsIsRootOfSquare#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemAbsIsRootOfSquare#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0164_20e95a6dc1c6.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSqrt",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrt#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrt#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0165_2ec2a14aa119.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 25,
      "line_start": 23,
      "name": "lemSqrMonoStrict",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrMonoStrict#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrMonoStrict#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0166_b5a1cb0cb5db.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSqrMono",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrMono#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrMono#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0167_9d77be6ac451.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSqrOrderedStrict",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrOrderedStrict#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrOrderedStrict#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0168_534a88286825.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSqrOrdered",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrOrdered#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrOrdered#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0169_9059238db8c7.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSquaredNegative",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSquaredNegative#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSquaredNegative#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0170_777146c29b08.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSqrDiffSymmetrical",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrDiffSymmetrical#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrDiffSymmetrical#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0171_594117a09f41.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSquaresPositive",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSquaresPositive#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSquaresPositive#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0172_822e639465e3.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemZeroRoot",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemZeroRoot#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemZeroRoot#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0173_6292af7f4db4.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSqrMult",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrMult#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrMult#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0174_108442245be1.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemEqualSquares",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemEqualSquares#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemEqualSquares#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0175_d5e2faaa38cf.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSqrtOfSquare",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrtOfSquare#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrtOfSquare#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0176_a24c9dd55bd9.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSquareOfSqrt",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSquareOfSqrt#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSquareOfSqrt#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0177_614268f611df.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSqrt1",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrt1#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrt1#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0178_aff39e9850b5.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSqrt0",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrt0#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrt0#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0179_c856d5b0bddf.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSqrSum",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrSum#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrSum#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0180_32b078e5187c.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemQuadraticGEZero",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemQuadraticGEZero#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemQuadraticGEZero#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0181_59181ecd3a7d.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSquareExistsAbove",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSquareExistsAbove#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSquareExistsAbove#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0182_eb1818c21be5.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSmallSquares",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSmallSquares#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSmallSquares#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0183_10b0c74c9e06.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSqrLT1",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrLT1#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemSqrLT1#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sorts__0184_13ed6b0adec9.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemReducedBound",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sorts.lemReducedBound#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sorts.lemReducedBound#1",
      "theory": "Sorts"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sublemma3__0185_b72d274ee3d1.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "sublemma3",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sublemma3.sublemma3#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sublemma3.sublemma3#1",
      "theory": "Sublemma3"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sublemma3__0186_fbf1a8fa00d2.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "sublemma3Translation",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sublemma3.sublemma3Translation#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sublemma3.sublemma3Translation#1",
      "theory": "Sublemma3"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Sublemma4__0187_1baef254410b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "sublemma4",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Sublemma4.sublemma4#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Sublemma4.sublemma4#1",
      "theory": "Sublemma4"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLineLemma__0188_74f2abaa75d4.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemWVTImpliesFunction",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTImpliesFunction#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTImpliesFunction#1",
      "theory": "TangentLineLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLineLemma__0189_e4bfec731944.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemWVTCts",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTCts#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTCts#1",
      "theory": "TangentLineLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLineLemma__0190_0bc31e076826.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemWVTInverse",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverse#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverse#1",
      "theory": "TangentLineLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLineLemma__0191_4bac4ddbdfc0.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemWVTInverseCts",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverseCts#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInverseCts#1",
      "theory": "TangentLineLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLineLemma__0192_bbdc0f808adf.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemWVTInjective",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInjective#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemWVTInjective#1",
      "theory": "TangentLineLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLineLemma__0193_6b1a081bc0c3.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemPresentation",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemPresentation#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemPresentation#1",
      "theory": "TangentLineLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLineLemma__0194_d6a76d02e0d3.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTangentLines",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLines#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLines#1",
      "theory": "TangentLineLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLineLemma__0195_7f2eaf38e3c4.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSelfTangentIsTimeAxis",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemSelfTangentIsTimeAxis#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemSelfTangentIsTimeAxis#1",
      "theory": "TangentLineLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLineLemma__0196_4d9115d640f6.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTangentLineUnique",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLineUnique#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLineLemma.lemTangentLineUnique#1",
      "theory": "TangentLineLemma"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLines__0197_f8df9f07e8cb.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTangentLineTranslation",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineTranslation#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineTranslation#1",
      "theory": "TangentLines"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLines__0198_990e21c99234.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTangentLineA",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineA#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineA#1",
      "theory": "TangentLines"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/TangentLines__0199_47d77f1c2527.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTangentLineE",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineE#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.TangentLines.lemTangentLineE#1",
      "theory": "TangentLines"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0200_f92e8d68b1e2.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMkTrans",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemMkTrans#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemMkTrans#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0201_2deb59ed71c1.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInverseTranslation",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemInverseTranslation#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemInverseTranslation#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0202_1bd54ddd41dc.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTranslationSum",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationSum#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationSum#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0203_eed08c570eb2.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemIdIsTranslation",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemIdIsTranslation#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemIdIsTranslation#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0204_1781274d74ec.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTranslationCancel",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationCancel#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationCancel#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0205_218818437313.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTranslationSwap",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationSwap#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationSwap#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0206_4d3f825412c9.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTranslationPreservesSep2",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationPreservesSep2#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationPreservesSep2#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0207_06ef4642b761.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTranslationInjective",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationInjective#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationInjective#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0208_9ef843ac84d2.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTranslationSurjective",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationSurjective#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationSurjective#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0209_7d1591c528fc.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTranslationTotalFunction",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationTotalFunction#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationTotalFunction#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0210_2739848ac8be.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTranslationOfLine",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationOfLine#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationOfLine#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0211_1003c168ab49.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemOnLineTranslation",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemOnLineTranslation#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemOnLineTranslation#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0212_eb3369e559c3.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemLineJoiningTranslation",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemLineJoiningTranslation#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemLineJoiningTranslation#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0213_8f9ae95d564d.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemBallTranslation",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemBallTranslation#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemBallTranslation#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0214_66462e931ecf.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemBallTranslationWithBoundary",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemBallTranslationWithBoundary#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemBallTranslationWithBoundary#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0215_6f6177f7b760.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemTranslationIsCts",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationIsCts#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemTranslationIsCts#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0216_fd65a2a254ec.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemAccPointTranslation",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemAccPointTranslation#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemAccPointTranslation#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0217_8ce566520f13.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInverseOfTransIsTrans",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemInverseOfTransIsTrans#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemInverseOfTransIsTrans#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Translations__0218_f8be208f27b0.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemInverseTrans",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Translations.lemInverseTrans#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Translations.lemInverseTrans#1",
      "theory": "Translations"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0219_cc3cf180aa1c.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDotDecomposition",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotDecomposition#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotDecomposition#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0220_205038dc0fc7.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDotCommute",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotCommute#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotCommute#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0221_b44e6444de69.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDotScaleLeft",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotScaleLeft#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotScaleLeft#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0222_e54525fe2513.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDotScaleRight",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotScaleRight#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotScaleRight#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0223_09253a442260.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDotSumLeft",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotSumLeft#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotSumLeft#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0224_629acf4d3460.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDotSumRight",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotSumRight#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotSumRight#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0225_1d998b91a5d0.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDotDiffLeft",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotDiffLeft#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotDiffLeft#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0226_d2dd1c40ca40.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemDotDiffRight",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotDiffRight#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemDotDiffRight#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0227_dd04a37d220c.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemNorm2OfSum",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemNorm2OfSum#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemNorm2OfSum#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0228_65fe56b33617.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSDotCommute",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotCommute#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotCommute#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0229_5d8718c1728c.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSDotScaleLeft",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleLeft#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleLeft#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0230_1c72bb7c648b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSDotScaleRight",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleRight#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleRight#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0231_38dad3f30199.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSDotSumLeft",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotSumLeft#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotSumLeft#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0232_0de4e84bb82e.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSDotSumRight",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotSumRight#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotSumRight#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0233_1aaeef5f58b7.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSDotDiffLeft",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffLeft#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffLeft#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0234_b2d64a5a0a59.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSDotDiffRight",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffRight#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffRight#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0235_61e955001bfd.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMDotDiffLeft",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemMDotDiffLeft#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemMDotDiffLeft#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0236_116328b05f98.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMDotSumLeft",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemMDotSumLeft#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemMDotSumLeft#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0237_b143e79a2bef.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMDotScaleLeft",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleLeft#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleLeft#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0238_036786bac23b.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMDotScaleRight",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleRight#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleRight#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0239_95a624b452f7.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSNorm2OfSum",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemSNorm2OfSum#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemSNorm2OfSum#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0240_f8df565b5d2f.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemSNormNonNeg",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemSNormNonNeg#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemSNormNonNeg#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0241_267b2e985b7a.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMNorm2OfSum",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfSum#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfSum#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0242_4930e0e3536f.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMNorm2OfDiff",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfDiff#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfDiff#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0243_04a2da455057.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMNorm2Decomposition",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemMNorm2Decomposition#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemMNorm2Decomposition#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/Vectors__0244_99df461e707e.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemMDecomposition",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.Vectors.lemMDecomposition#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.Vectors.lemMDecomposition#1",
      "theory": "Vectors"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/WorldLine__0245_6a5066080979.lean",
      "lean_tactic_class": "needs_human",
      "line_end": 24,
      "line_start": 23,
      "name": "lemWorldLineUnderWVT",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.WorldLine.lemWorldLineUnderWVT#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.WorldLine.lemWorldLineUnderWVT#1",
      "theory": "WorldLine"
    },
    {
      "file": "/Users/macbookpro/lab/tau/tau-information-dynamics/navier-stokes-project-clean-helper/verification_results/afp_isabelle/no_ftl_observers_gen_rel/generated_lean_strict/WorldLine__0246_6b3b36f4790d.lean",
      "lean_tactic_class": "arithmetic_norm_num",
      "line_end": 24,
      "line_start": 23,
      "name": "lemFiniteLineVelocityUnique",
      "raw_decl_id": "No_FTL_observers_Gen_Rel.WorldLine.lemFiniteLineVelocityUnique#1",
      "theorem_id": "No_FTL_observers_Gen_Rel.WorldLine.lemFiniteLineVelocityUnique#1",
      "theory": "WorldLine"
    }
  ],
  "signature_source": "ctir",
  "theorem_file_count": 246,
  "theory_file_count": 26,
  "ttir": null,
  "uses_sidecar": true
}

end AFPIsabellePilot.Unknown

-- ═══════════════════════════════════════════════════════
-- Theory: Vectors  (26 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.Vectors

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotDecomposition#1
Theorem name: lemDotDecomposition
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemDotDecomposition#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemDotDecomposition#1
-- source_statement: shows "(u \<odot> v) = (tval u * tval v) + ((sComponent u) \<odot>s (sComponent v))"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_864e2ea7acf71ce4 (u : NoFTLObj) (v : NoFTLObj) (tval : NoFTLObj → NoFTLObj) (sComponent : NoFTLObj → NoFTLObj) (s : NoFTLObj → NoFTLObj) : (u * v) = (tval u * tval v) + ((sComponent u) *s (sComponent v)) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotCommute#1
Theorem name: lemDotCommute
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemDotCommute#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemDotCommute#1
-- source_statement: "dot u v = dot v u"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_c7b08ff2b7327852 (u : NoFTLObj) (v : NoFTLObj) : dot u v = dot v u := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotScaleLeft#1
Theorem name: lemDotScaleLeft
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemDotScaleLeft#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemDotScaleLeft#1
-- source_statement: "dot (a\<otimes>u) v = a * (dot u v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_208abbe6849d0770 (a : NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) : dot (a * u) v = a * (dot u v) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotScaleRight#1
Theorem name: lemDotScaleRight
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemDotScaleRight#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemDotScaleRight#1
-- source_statement: "dot u (a\<otimes>v) = a * (dot u v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_094881838c50ce8d (u : NoFTLObj) (a : NoFTLObj) (v : NoFTLObj) : dot u (a * v) = a * (dot u v) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotSumLeft#1
Theorem name: lemDotSumLeft
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemDotSumLeft#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemDotSumLeft#1
-- source_statement: "dot (u\<oplus>v) w = (dot u w) + (dot v w)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_6e44ecd6d99e9db2 (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : dot (u+v) w = (dot u w) + (dot v w) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotSumRight#1
Theorem name: lemDotSumRight
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemDotSumRight#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemDotSumRight#1
-- source_statement: "dot u (v\<oplus>w) = (dot u v) + (dot u w)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_f49310e602264cdb (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : dot u (v+w) = (dot u v) + (dot u w) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotDiffLeft#1
Theorem name: lemDotDiffLeft
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemDotDiffLeft#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemDotDiffLeft#1
-- source_statement: "dot (u\<ominus>v) w = (dot u w) - (dot v w)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_4958c0260415b8fa (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : dot (u-v) w = (dot u w) - (dot v w) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotDiffRight#1
Theorem name: lemDotDiffRight
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemDotDiffRight#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemDotDiffRight#1
-- source_statement: "dot u (v\<ominus>w) = (dot u v) - (dot u w)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_006b31f1194349ac (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : dot u (v-w) = (dot u v) - (dot u w) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemNorm2OfSum#1
Theorem name: lemNorm2OfSum
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemNorm2OfSum#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemNorm2OfSum#1
-- source_statement: "norm2 (u \<oplus> v) = norm2 u + 2*(u \<odot> v) + norm2 v"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_c4ac0ea870088b0a (u : NoFTLObj) (v : NoFTLObj) : norm2 (u + v) = norm2 u + 2*(u * v) + norm2 v := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotCommute#1
Theorem name: lemSDotCommute
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotCommute#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotCommute#1
-- source_statement: "sdot u v = sdot v u"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=0;risk_reasons=none
-- semantic_shell_risk_score: 0
-- semantic_shell_risk_reasons: none
-- force_true: false
theorem smoke_621bd95b63eb9589 (u : NoFTLObj) (v : NoFTLObj) : sdot u v = sdot v u := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleLeft#1
Theorem name: lemSDotScaleLeft
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleLeft#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleLeft#1
-- source_statement: "sdot (a \<otimes>s u) v = a * (sdot u v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_71b2400d9c440644 (a : NoFTLObj) (s : NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) : sdot (a *s u) v = a * (sdot u v) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleRight#1
Theorem name: lemSDotScaleRight
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleRight#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleRight#1
-- source_statement: "sdot u (a \<otimes>s v) = a * (sdot u v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_440dc3ac71a7bada (u : NoFTLObj) (a : NoFTLObj) (s : NoFTLObj) (v : NoFTLObj) : sdot u (a *s v) = a * (sdot u v) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotSumLeft#1
Theorem name: lemSDotSumLeft
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotSumLeft#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotSumLeft#1
-- source_statement: "sdot (u \<oplus>s v) w = (sdot u w) + (sdot v w)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_f060002a5fce42d9 (u : NoFTLObj) (s : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : sdot (u +s v) w = (sdot u w) + (sdot v w) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotSumRight#1
Theorem name: lemSDotSumRight
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotSumRight#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotSumRight#1
-- source_statement: "sdot u ( v\<oplus>s w) = (sdot u v) + (sdot u w)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_850a81854eebb602 (u : NoFTLObj) (v : NoFTLObj) (s : NoFTLObj) (w : NoFTLObj) : sdot u ( v+s w) = (sdot u v) + (sdot u w) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffLeft#1
Theorem name: lemSDotDiffLeft
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffLeft#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffLeft#1
-- source_statement: "sdot (u \<ominus>s v) w = (sdot u w) - (sdot v w)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_0b729fba3f9b295c (u : NoFTLObj) (s : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : sdot (u -s v) w = (sdot u w) - (sdot v w) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffRight#1
Theorem name: lemSDotDiffRight
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffRight#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffRight#1
-- source_statement: "sdot u ( v\<ominus>s w) = (sdot u v) - (sdot u w)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_44ba067c40409bd3 (u : NoFTLObj) (v : NoFTLObj) (s : NoFTLObj) (w : NoFTLObj) : sdot u ( v-s w) = (sdot u v) - (sdot u w) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMDotDiffLeft#1
Theorem name: lemMDotDiffLeft
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemMDotDiffLeft#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemMDotDiffLeft#1
-- source_statement: "mdot (u\<ominus>v) w = (mdot u w) - (mdot v w)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_624ee81c7bdcc458 (mdot : NoFTLObj → NoFTLObj → NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : mdot (u-v) w = (mdot u w) - (mdot v w) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMDotSumLeft#1
Theorem name: lemMDotSumLeft
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemMDotSumLeft#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemMDotSumLeft#1
-- source_statement: "mdot (u \<oplus> v) w = (mdot u w) + (mdot v w)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_cdc2e9c7a31f80f2 (mdot : NoFTLObj → NoFTLObj → NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : mdot (u + v) w = (mdot u w) + (mdot v w) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleLeft#1
Theorem name: lemMDotScaleLeft
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleLeft#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleLeft#1
-- source_statement: "mdot (a \<otimes> u) v = a * (mdot u v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_5e9cefab93497479 (mdot : NoFTLObj → NoFTLObj → NoFTLObj) (a : NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) : mdot (a * u) v = a * (mdot u v) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleRight#1
Theorem name: lemMDotScaleRight
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleRight#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleRight#1
-- source_statement: "mdot u (a \<otimes> v) = a * (mdot u v)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_0fdf4628bcbd52dc (mdot : NoFTLObj → NoFTLObj → NoFTLObj) (u : NoFTLObj) (a : NoFTLObj) (v : NoFTLObj) : mdot u (a * v) = a * (mdot u v) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSNorm2OfSum#1
Theorem name: lemSNorm2OfSum
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemSNorm2OfSum#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemSNorm2OfSum#1
-- source_statement: "sNorm2 (u \<oplus>s v) = sNorm2 u + 2*(u \<odot>s v) + sNorm2 v"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_583d08d24da5a800 (u : NoFTLObj) (s : NoFTLObj → NoFTLObj) (v : NoFTLObj) : sNorm2 (u +s v) = sNorm2 u + 2*(u *s v) + sNorm2 v := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSNormNonNeg#1
Theorem name: lemSNormNonNeg
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemSNormNonNeg#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemSNormNonNeg#1
-- source_statement: shows "sNorm v \<ge> 0"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_4d8379c127eeb2ca (v : NoFTLObj) : sNorm v ≥ 0 := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfSum#1
Theorem name: lemMNorm2OfSum
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfSum#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfSum#1
-- source_statement: "mNorm2 (u \<oplus> v) = mNorm2 u + 2*(u \<odot>m v) + mNorm2 v"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_98ba14450d50e42b (mNorm2 : NoFTLObj → NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) (m : NoFTLObj → NoFTLObj) : mNorm2 (u + v) = mNorm2 u + 2*(minkProd u v) + mNorm2 v := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfDiff#1
Theorem name: lemMNorm2OfDiff
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfDiff#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfDiff#1
-- source_statement: "mNorm2 (u \<ominus> v) = mNorm2 u - 2*(u \<odot>m v) + mNorm2 v"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_6d2c17f0f128e90f (mNorm2 : NoFTLObj → NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) (m : NoFTLObj → NoFTLObj) : mNorm2 (u - v) = mNorm2 u - 2*(minkProd u v) + mNorm2 v := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2Decomposition#1
Theorem name: lemMNorm2Decomposition
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2Decomposition#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2Decomposition#1
-- source_statement: "mNorm2 p = (p \<odot>m p)"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_7fd46685c06718cd (mNorm2 : NoFTLObj → NoFTLObj) (p : NoFTLObj) (m : NoFTLObj → NoFTLObj) : mNorm2 p = (minkProd p p) := by
  sorry  -- phase2_high: type translated, proof pending

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMDecomposition#1
Theorem name: lemMDecomposition
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.Vectors.lemMDecomposition#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.Vectors.lemMDecomposition#1
-- source_statement: assumes "(u \<odot>m v) \<noteq> 0" and "mNorm2 v \<noteq> 0" and "a = (u \<odot>m v)/(mNorm2 v)" and "up = (a \<otimes> v)" and "uo = (u \<ominus> up)" shows "u = (up \<oplus> uo) \<and> parallel up v \<and> orthogm uo v \<and> (up \<od...
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_726b943b5ce9fe53 (u : NoFTLObj) (up : NoFTLObj) (uo : NoFTLObj) (parallel : NoFTLObj → NoFTLObj) (v : NoFTLObj) (orthogm : NoFTLObj → NoFTLObj) (m : NoFTLObj → NoFTLObj) : u = (up + uo) ∧(parallel up = v)∧(orthogm uo = v)∧ (minkProd up v) = (minkProd u v) := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.Vectors

-- ═══════════════════════════════════════════════════════
-- Theory: WorldLine  (2 theorem(s))
-- ═══════════════════════════════════════════════════════

namespace AFPIsabellePilot.WorldLine

/-!
Auto-generated theorem-indexed pilot file.
Theory: WorldLine
Theorem id: No_FTL_observers_Gen_Rel.WorldLine.lemWorldLineUnderWVT#1
Theorem name: lemWorldLineUnderWVT
Lean tactic class: needs_human
-/

-- theorem_id: No_FTL_observers_Gen_Rel.WorldLine.lemWorldLineUnderWVT#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.WorldLine.lemWorldLineUnderWVT#1
-- source_statement: shows "applyToSet (wvtFunc m k) (wline m b) \<subseteq> wline k b"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_06a467d53890539b (wvtFunc : NoFTLObj) (m : NoFTLObj) (k : NoFTLObj) (wline : NoFTLObj → NoFTLObj → NoFTLSet) (b : NoFTLObj) : applyToSet (wvtFunc m k) (wline m b) ⊆ wline k b := by
  sorry  -- needs_human compile-safe semantic shell

/-!
Auto-generated theorem-indexed pilot file.
Theory: WorldLine
Theorem id: No_FTL_observers_Gen_Rel.WorldLine.lemFiniteLineVelocityUnique#1
Theorem name: lemFiniteLineVelocityUnique
Lean tactic class: arithmetic_norm_num
-/

-- theorem_id: No_FTL_observers_Gen_Rel.WorldLine.lemFiniteLineVelocityUnique#1
-- raw_decl_id: No_FTL_observers_Gen_Rel.WorldLine.lemFiniteLineVelocityUnique#1
-- source_statement: assumes "(u \<in> lineVelocity l) \<and> (v \<in> lineVelocity l)" and "lineSlopeFinite l" shows "u = v"
-- emission_modes: retry=compile_safe, needs_human=compile_safe
-- signature_source: ctir
-- signature_note: ctir:ok;sidecar_unresolved:__afp_unknown_symbol;risk=1;risk_reasons=source_has_isabelle_tokens
-- semantic_shell_risk_score: 1
-- semantic_shell_risk_reasons: source_has_isabelle_tokens
-- force_true: false
theorem smoke_198ec71e9c8bb7a3 (u : NoFTLObj) (v : NoFTLObj) : u = v := by
  sorry  -- phase2_high: type translated, proof pending

end AFPIsabellePilot.WorldLine
