import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
-- ════════════════════════════════════════════════════════════════-- AFP Module     : Bondy-- Link style     : concat-- Source files   : 1-- Total theorems : 2-- Signature src  : ctir-- Generated      : 2026-04-12T21:11:14.156801+00:00-- ════════════════════════════════════════════════════════════════import NavierStokesClean.AFPIsabellePilot.AFPDomainShim


-- ════════════════════════════════════════════════════════════════
-- AFP Isabelle Source : Bondy.thy
-- AFP Module         : Bondy
-- Lean4 Namespace    : AFPIsabellePilot.Bondy.Bondy
-- Theorems           : 2 (0 missing objects)
-- Signature source   : ctir
-- Emission modes     : retry=compile_safe  needs_human=compile_safe
-- Generated          : 2026-04-12T21:11:14.155018+00:00
-- ════════════════════════════════════════════════════════════════

namespace AFPIsabellePilot.Bondy.Bondy


/-!
Auto-generated theorem-indexed pilot file.
Theory: Bondy
Theorem id: Bondy.Bondy.card_less_if_surj_not_inj#1
Theorem name: card_less_if_surj_not_inj
Lean tactic class: needs_human
-/


def wolframStatementPlaceholder (_theoremId : String) (_sourceStatement : String) : Prop := True
theorem card_less_if_surj_not_inj : wolframStatementPlaceholder "Bondy.Bondy.card_less_if_surj_not_inj#1" "\"\\<lbrakk> finite A; f ` A = B; \\<not> inj_on f A \\<rbrakk> \\<Longrightarrow> card B < card A\"" := by
  sorry  -- compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Bondy
Theorem id: Bondy.Bondy.Bondy#1
Theorem name: Bondy
Lean tactic class: needs_human
-/


theorem Bondy : wolframStatementPlaceholder "Bondy.Bondy.Bondy#1" "assumes \"\\<forall>A \\<in> F. A \\<subseteq> X\" and \"card X \\<ge> 1\" and \"card F = card X\" shows \"\\<exists>D. D \\<subseteq> X & card D < card X & card (inter D ` F) = card F\"" := by
  sorry  -- compile-safe placeholder preserving theorem/source identity

end AFPIsabellePilot.Bondy.Bondy

