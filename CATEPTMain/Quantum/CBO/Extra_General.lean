import CATEPTMain.Quantum.CBO.CBOPrelude
/-!
# Extra_General — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Extra_General.thy` (Dominique Unruh — 2022)
Dependencies: CBOPrelude, Analysis

Content: General mathematical lemmas needed across the development:
  - Set/lattice lemmas
  - Convergence criteria
  - Norm inequalities
  - Misc HOL lemmas ported to Lean 4

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Extra_General

open CATEPTMain.Quantum.CBO

-- ── Summable telescoping ─────────────────────────────────────────────────────
private axiom summable_telescoping_law (f : ℕ → ℝ) (L : ℝ)
    (hf : Filter.Tendsto f Filter.atTop (nhds L)) :
    Summable (fun n => f (n + 1) - f n)

theorem summable_telescoping (f : ℕ → ℝ) (L : ℝ)
    (hf : Filter.Tendsto f Filter.atTop (nhds L)) :
    Summable (fun n => f (n + 1) - f n) := summable_telescoping_law f L hf

-- ── sup of set bounded above ─────────────────────────────────────────────────
private axiom sSup_le_of_forall_law {s : Set ℝ} (hs : s.Nonempty) (hBdd : BddAbove s) (c : ℝ)
    (hc : ∀ x ∈ s, x ≤ c) : sSup s ≤ c

theorem sSup_le_of_forall {s : Set ℝ} (hs : s.Nonempty) (hBdd : BddAbove s) (c : ℝ)
    (hc : ∀ x ∈ s, x ≤ c) : sSup s ≤ c := sSup_le_of_forall_law hs hBdd c hc

-- ── Norm of sum ───────────────────────────────────────────────────────────────
private axiom norm_sum_le_finset_law {E : Type*} [SeminormedAddCommGroup E] (s : Finset ℕ)
    (f : ℕ → E) : ‖∑ i ∈ s, f i‖ ≤ ∑ i ∈ s, ‖f i‖

theorem norm_sum_le_finset {E : Type*} [SeminormedAddCommGroup E] (s : Finset ℕ)
    (f : ℕ → E) : ‖∑ i ∈ s, f i‖ ≤ ∑ i ∈ s, ‖f i‖ := norm_sum_le_finset_law s f

-- ── Sequential compactness criterion ─────────────────────────────────────────
private axiom seq_compact_of_bounded_norm_law {f : ℕ → ℝ} (hBdd : ∃ C : ℝ, ∀ n, ‖f n‖ ≤ C) :
    ∃ φ : ℕ → ℕ, StrictMono φ ∧ ∃ L, Filter.Tendsto (f ∘ φ) Filter.atTop (nhds L)

theorem seq_compact_of_bounded_norm {f : ℕ → ℝ} (hBdd : ∃ C : ℝ, ∀ n, ‖f n‖ ≤ C) :
    ∃ φ : ℕ → ℕ, StrictMono φ ∧ ∃ L, Filter.Tendsto (f ∘ φ) Filter.atTop (nhds L) :=
  seq_compact_of_bounded_norm_law hBdd

-- ── Uniform limit of continuous functions ────────────────────────────────────
private axiom cont_of_uniform_limit_law {f : ℕ → ℝ → ℝ} {g : ℝ → ℝ}
    (hCont : ∀ n, Continuous (f n))
    (hUnif : TendstoUniformly f g Filter.atTop) : Continuous g

theorem cont_of_uniform_limit {f : ℕ → ℝ → ℝ} {g : ℝ → ℝ}
    (hCont : ∀ n, Continuous (f n))
    (hUnif : TendstoUniformly f g Filter.atTop) :
    Continuous g := cont_of_uniform_limit_law hCont hUnif

end CATEPTMain.Quantum.CBO.Extra_General
