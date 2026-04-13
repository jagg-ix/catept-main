import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
-- ════════════════════════════════════════════════════════════════-- AFP Module     : Card_Multisets-- Link style     : concat-- Source files   : 1-- Total theorems : 9-- Signature src  : ctir-- Generated      : 2026-04-12T21:11:14.267607+00:00-- ════════════════════════════════════════════════════════════════import NavierStokesClean.AFPIsabellePilot.AFPDomainShim


-- ════════════════════════════════════════════════════════════════
-- AFP Isabelle Source : Card_Multisets.thy
-- AFP Module         : Card_Multisets
-- Lean4 Namespace    : AFPIsabellePilot.Card_Multisets.Card_Multisets
-- Theorems           : 9 (0 missing objects)
-- Signature source   : ctir
-- Emission modes     : retry=compile_safe  needs_human=compile_safe
-- Generated          : 2026-04-12T21:11:14.263924+00:00
-- ════════════════════════════════════════════════════════════════

namespace AFPIsabellePilot.Card_Multisets.Card_Multisets


/-!
Auto-generated theorem-indexed pilot file.
Theory: Card_Multisets
Theorem id: Card_Multisets.Card_Multisets.mset_set_set_mset_subseteq#1
Theorem name: mset_set_set_mset_subseteq
Lean tactic class: needs_human
-/


variable (M : NoFTLObj)
theorem mset_set_set_mset_subseteq (M : NoFTLObj) : mset (set M) ≤ M := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry


/-!
Auto-generated theorem-indexed pilot file.
Theory: Card_Multisets
Theorem id: Card_Multisets.Card_Multisets.size_mset_set_eq_card#1
Theorem name: size_mset_set_eq_card
Lean tactic class: induction
-/


variable (A : NoFTLObj)
theorem size_mset_set_eq_card (size : NoFTLObj → NoFTLObj) (mset_set : NoFTLObj) (A : NoFTLSet) (h1 : finite A) : size (mset_set A) = card A := by
  first | simp [*] | simp_all | tauto | decide | sorry


/-!
Auto-generated theorem-indexed pilot file.
Theory: Card_Multisets
Theorem id: Card_Multisets.Card_Multisets.card_set_mset_leq#1
Theorem name: card_set_mset_leq
Lean tactic class: needs_human
-/


variable (M : NoFTLObj)
theorem card_set_mset_leq (set_mset : NoFTLObj → NoFTLSet) (M : NoFTLObj) (size : NoFTLObj → NoFTLObj) : card (set_mset M) ≤ size M := by
  first | omega | norm_num | linarith | nlinarith | simp_all | decide | trivial | sorry


/-!
Auto-generated theorem-indexed pilot file.
Theory: Card_Multisets
Theorem id: Card_Multisets.Card_Multisets.set_of_multisets_eq#1
Theorem name: set_of_multisets_eq
Lean tactic class: arithmetic_norm_num
-/


def wolframStatementPlaceholder (_theoremId : String) (_sourceStatement : String) : Prop := True
theorem set_of_multisets_eq : wolframStatementPlaceholder "Card_Multisets.Card_Multisets.set_of_multisets_eq#1" "assumes \"x \\<notin> A\" shows \"{M. set_mset M \\<subseteq> insert x A \\<and> size M = Suc k} = {M. set_mset M \\<subseteq> A \\<and> size M = Suc k} \\<union> (\\<lambda>M. M + {#x#}) ` {M. set_mset M \\<subseteq> insert x A \\<and> size M = k}\"" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Card_Multisets
Theorem id: Card_Multisets.Card_Multisets.finite_set_and_nat_induct#1
Theorem name: finite_set_and_nat_induct
Lean tactic class: needs_human
-/


variable (A : NoFTLObj) (P : NoFTLObj)
theorem finite_set_and_nat_induct (P : NoFTLObj) (A : NoFTLObj) (k : NoFTLObj) (h1 : finite A) (h2 : ∀ A, finite A → P A 0) (h3 : ∀ k, P {} k) (h4 : ∀ A k x, finite A → x ∉ A → P A (Suc k) → P (insert x A) k → P (insert x A) (Suc k)) : P A k := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry


/-!
Auto-generated theorem-indexed pilot file.
Theory: Card_Multisets
Theorem id: Card_Multisets.Card_Multisets.finite_multisets#1
Theorem name: finite_multisets
Lean tactic class: needs_human
-/


variable (A : NoFTLSet) (M : NoFTLSet)
theorem finite_multisets (M : NoFTLSet) (set_mset : NoFTLObj) (A : NoFTLSet) (size : NoFTLSet → NoFTLObj) (k : NoFTLObj) (h1 : finite A) : finite setOf' (fun M => set_mset M ⊆ A ∧ size M = k) := by
  first | simp_all [Set.mem_setOf_eq, Set.subset_def] | tauto | omega | decide | sorry


/-!
Auto-generated theorem-indexed pilot file.
Theory: Card_Multisets
Theorem id: Card_Multisets.Card_Multisets.card_multisets#1
Theorem name: card_multisets
Lean tactic class: arithmetic_norm_num
-/


variable (A : NoFTLSet) (M : NoFTLSet)
theorem card_multisets (M : NoFTLSet) (set_mset : NoFTLObj) (A : NoFTLSet) (size : NoFTLObj) (k : NoFTLObj) (choose : NoFTLObj → NoFTLObj) (h1 : finite A) : card setOf' (fun M => set_mset M ⊆ A ∧ size M = k) = (card A + k - 1) choose k := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry


/-!
Auto-generated theorem-indexed pilot file.
Theory: Card_Multisets
Theorem id: Card_Multisets.Card_Multisets.card_too_small_multisets_covering_set#1
Theorem name: card_too_small_multisets_covering_set
Lean tactic class: needs_human
-/


variable (A : NoFTLObj) (M : NoFTLObj)
theorem card_too_small_multisets_covering_set (M : NoFTLObj) (set_mset : NoFTLObj) (A : NoFTLSet) (size : NoFTLObj) (k : NoFTLObj) (h1 : finite A) (h2 : k < card A) : card setOf' (fun M => set_mset M = A ∧ size M = k) = 0 := by
  first | omega | norm_num | linarith | nlinarith | simp_all | decide | trivial | sorry


/-!
Auto-generated theorem-indexed pilot file.
Theory: Card_Multisets
Theorem id: Card_Multisets.Card_Multisets.card_multisets_covering_set#1
Theorem name: card_multisets_covering_set
Lean tactic class: arithmetic_norm_num
-/


variable (A : NoFTLObj) (M : NoFTLObj)
theorem card_multisets_covering_set (M : NoFTLObj) (set_mset : NoFTLObj) (A : NoFTLSet) (size : NoFTLObj) (k : NoFTLObj) (choose : NoFTLObj → NoFTLObj) (h1 : finite A) (h2 : card A ≤ k) : card setOf' (fun M => set_mset M = A ∧ size M = k) = (k - 1) choose (k - card A) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Card_Multisets.Card_Multisets

