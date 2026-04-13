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
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
import NavierStokesClean.AFPIsabellePilot.AFPDomainShim
-- ════════════════════════════════════════════════════════════════-- AFP Module     : Abel_Limit_Theorem-- Link style     : concat-- Source files   : 2-- Total theorems : 15-- Signature src  : ctir-- Generated      : 2026-04-12T21:11:14.047284+00:00-- ════════════════════════════════════════════════════════════════import NavierStokesClean.AFPIsabellePilot.AFPDomainShim


-- ════════════════════════════════════════════════════════════════
-- AFP Isabelle Source : Abel_Limit_Theorem.thy
-- AFP Module         : Abel_Limit_Theorem
-- Lean4 Namespace    : AFPIsabellePilot.Abel_Limit_Theorem.Abel_Limit_Theorem
-- Theorems           : 3 (0 missing objects)
-- Signature source   : ctir
-- Emission modes     : retry=compile_safe  needs_human=compile_safe
-- Generated          : 2026-04-12T21:11:14.041519+00:00
-- ════════════════════════════════════════════════════════════════

namespace AFPIsabellePilot.Abel_Limit_Theorem.Abel_Limit_Theorem


/-!
Auto-generated theorem-indexed pilot file.
Theory: Abel_Limit_Theorem
Theorem id: Abel_Limit_Theorem.Abel_Limit_Theorem.Abel_limit_theorem#1
Theorem name: Abel_limit_theorem
Lean tactic class: arithmetic_norm_num
-/

theorem Abel_limit_theorem (f : NoFTLObj) (a : ℕ → ℝ) (summable_a : summable a) (conv_radius_1 : conv_radius a = 1) : (f (Σn. a n)) (at_left 1) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry


/-!
Auto-generated theorem-indexed pilot file.
Theory: Abel_Limit_Theorem
Theorem id: Abel_Limit_Theorem.Abel_Limit_Theorem.filterlim_at_right_at_left_eq#1
Theorem name: filterlim_at_right_at_left_eq
Lean tactic class: needs_human
-/


def wolframStatementPlaceholder (_theoremId : String) (_sourceStatement : String) : Prop := True
theorem filterlim_at_right_at_left_eq : wolframStatementPlaceholder "Abel_Limit_Theorem.Abel_Limit_Theorem.filterlim_at_right_at_left_eq#1" "shows \"((\\<lambda>x. f (-x)) \\<longlongrightarrow> l) (at_right (-1)) \\<longleftrightarrow> ((\\<lambda>x. f (x)) \\<longlongrightarrow> l) (at_left (1::real))\" apply (rule iffI) apply (simp add: at_left_minus) apply (simp add: filterlim_f..." := by
  sorry  -- compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Abel_Limit_Theorem
Theorem id: Abel_Limit_Theorem.Abel_Limit_Theorem.Abel_limit_theorem'#1
Theorem name: Abel_limit_theorem'
Lean tactic class: arithmetic_norm_num
-/

theorem Abel_limit_theorem' (x : ℝ) (f : NoFTLObj → NoFTLObj) (a : NoFTLObj → NoFTLObj) (summable_a : summable a) (conv_radius_1 : conv_radius a = 1) : ((fun x => f (-x)) (Σn. a n)) (at_right (-1)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Abel_Limit_Theorem.Abel_Limit_Theorem


-- ════════════════════════════════════════════════════════════════
-- AFP Isabelle Source : Binomial_Sqrt_Series_Boundary.thy
-- AFP Module         : Abel_Limit_Theorem
-- Lean4 Namespace    : AFPIsabellePilot.Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary
-- Theorems           : 12 (0 missing objects)
-- Signature source   : ctir
-- Emission modes     : retry=compile_safe  needs_human=compile_safe
-- Generated          : 2026-04-12T21:11:14.041519+00:00
-- ════════════════════════════════════════════════════════════════

namespace AFPIsabellePilot.Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.binomial_sqrt_series#1
Theorem name: binomial_sqrt_series
Lean tactic class: arithmetic_norm_num
-/

theorem binomial_sqrt_series (suminf : NoFTLObj → NoFTLObj) (n : NoFTLObj) (gchoose : NoFTLObj → NoFTLObj) (x : NoFTLObj) (h1 : x < 1) : suminf (fun n => ((1/2) gchoose n) * x ^ n) = sqrt (1 + x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_1_2_catalan#1
Theorem name: gbinomial_1_2_catalan
Lean tactic class: arithmetic_norm_num
-/


def wolframStatementPlaceholder (_theoremId : String) (_sourceStatement : String) : Prop := True
theorem gbinomial_1_2_catalan : wolframStatementPlaceholder "Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_1_2_catalan#1" "\"((1/2) gchoose (Suc n)) = ((-1)^(n)/(2^(2*n+1))) * real (catalan n)\"" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_1_2_catalan'#1
Theorem name: gbinomial_1_2_catalan'
Lean tactic class: arithmetic_norm_num
-/


theorem gbinomial_1_2_catalan' : wolframStatementPlaceholder "Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_1_2_catalan'#1" "\"((1/2) gchoose (Suc n)) = ((-1)^n/2) * (1/4^n) * real (catalan n)\"" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_1_2_simp#1
Theorem name: gbinomial_1_2_simp
Lean tactic class: arithmetic_norm_num
-/


theorem gbinomial_1_2_simp : wolframStatementPlaceholder "Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_1_2_simp#1" "\"((1/2) gchoose (Suc n)) = ((-1)^n / real (2^(2*n+1) * (Suc n))) * ((2*n) choose n)\"" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.summable_real_powr_iff'#1
Theorem name: summable_real_powr_iff'
Lean tactic class: arithmetic_norm_num
-/


theorem summable_real_powr_iff' : wolframStatementPlaceholder "Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.summable_real_powr_iff'#1" "\"summable (\\<lambda>n. 1 / of_nat n powr s :: real) \\<longleftrightarrow> s > 1\"" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.summable_1_2_gchoose#1
Theorem name: summable_1_2_gchoose
Lean tactic class: needs_human
-/


theorem summable_1_2_gchoose : wolframStatementPlaceholder "Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.summable_1_2_gchoose#1" "\"summable (\\<lambda>n. ((1::real)/2) gchoose n)\"" := by
  sorry  -- compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_1_2_gchoose_sum_sqrt_2#1
Theorem name: gbinomial_1_2_gchoose_sum_sqrt_2
Lean tactic class: arithmetic_norm_num
-/


theorem gbinomial_1_2_gchoose_sum_sqrt_2 : wolframStatementPlaceholder "Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_1_2_gchoose_sum_sqrt_2#1" "shows \"(\\<Sum>n. (((1::real) / (2::real) gchoose n))) = sqrt 2\" (is \"(\\<Sum>n. ?f_1 n) = _\")" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_ratio_limit'#1
Theorem name: gbinomial_ratio_limit'
Lean tactic class: arithmetic_norm_num
-/


theorem gbinomial_ratio_limit' : wolframStatementPlaceholder "Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_ratio_limit'#1" "fixes a :: \"'a :: real_normed_field\" assumes \"a \\<notin> \\<nat>\" shows \"(\\<lambda>n. ((a gchoose n) * (-1) ^ n) / ((a gchoose Suc n) * (-1) ^ (Suc n))) \\<longlonglongrightarrow> 1\"" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.conv_radius_gchoose_alternating#1
Theorem name: conv_radius_gchoose_alternating
Lean tactic class: arithmetic_norm_num
-/


theorem conv_radius_gchoose_alternating : wolframStatementPlaceholder "Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.conv_radius_gchoose_alternating#1" "fixes a :: \"'a :: {real_normed_field,banach}\" assumes \"a \\<notin> \\<nat>\" shows \"conv_radius (\\<lambda>n::nat. (a gchoose n) * (-1) ^ n) = (1::ereal)\"" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.summable_1_2_gchoose_alternating#1
Theorem name: summable_1_2_gchoose_alternating
Lean tactic class: arithmetic_norm_num
-/


theorem summable_1_2_gchoose_alternating : wolframStatementPlaceholder "Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.summable_1_2_gchoose_alternating#1" "\"summable (\\<lambda>n::nat. (1 / 2 gchoose n) * (-1) ^ n :: real)\" (is \"summable ?f\")" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_1_2_gchoose_alternating_sum_0#1
Theorem name: gbinomial_1_2_gchoose_alternating_sum_0
Lean tactic class: arithmetic_norm_num
-/


theorem gbinomial_1_2_gchoose_alternating_sum_0 : wolframStatementPlaceholder "Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.gbinomial_1_2_gchoose_alternating_sum_0#1" "shows \"(\\<Sum>n. ((1/2 gchoose n) * (- (1::real)) ^ n)) = 0\" (is \"(\\<Sum>n. ?f_1 n) = 0\")" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity


/-!
Auto-generated theorem-indexed pilot file.
Theory: Binomial_Sqrt_Series_Boundary
Theorem id: Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary.binomial_sqrt_series'#1
Theorem name: binomial_sqrt_series'
Lean tactic class: arithmetic_norm_num
-/

theorem binomial_sqrt_series' (suminf : NoFTLObj → NoFTLObj) (n : NoFTLObj) (gchoose : NoFTLObj → NoFTLObj) (x : NoFTLObj) (h1 : x ≤ (1 : ℝ)) : suminf (fun n => ((1/2) gchoose n) * x ^ n) = sqrt (1 + x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Abel_Limit_Theorem.Binomial_Sqrt_Series_Boundary

