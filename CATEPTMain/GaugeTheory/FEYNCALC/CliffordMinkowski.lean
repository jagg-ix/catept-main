import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Fin.Tuple.Basic
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic
/-!
# Minkowski Clifford Algebra — Concrete Dirac Representation

Concrete 4×4 complex gamma matrices satisfying `{γ^μ, γ^ν} = 2η^{μν}·1₄`
with signature (+,−,−,−).

These are the Dirac-representation matrices, identical to those in
`Physlib.Relativity.CliffordAlgebra` (Tooby-Smith 2024), reproduced here
to avoid a full Physlib compile dependency.

## Proof strategy (Phase 2)

`diracGamma_anticommute` is proved via two helper lemmas:
1. `diracGamma_sq_eq`: (γ^μ)² = η_{μμ} · 1₄  (4 cases by `fin_cases μ`)
2. `diracGamma_anticomm_neq`: γ^μγ^ν + γ^νγ^μ = 0 for μ≠ν  (12 cases by `fin_cases`)
These are combined by `by_cases h : μ = ν` in the main theorem.
-/

set_option autoImplicit false
open Complex

namespace CATEPTMain.GaugeTheory.FEYNCALC

-- ── Concrete gamma matrices (Dirac representation, +−−− signature) ───────────

/-- γ⁰ in the Dirac representation. Diagonal: diag(1,1,−1,−1). -/
def diracGamma0 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, -1, 0; 0, 0, 0, -1]

/-- γ¹ in the Dirac representation. -/
def diracGamma1 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 0, 1; 0, 0, 1, 0; 0, -1, 0, 0; -1, 0, 0, 0]

/-- γ² in the Dirac representation (contains imaginary unit i). -/
def diracGamma2 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 0, -I; 0, 0, I, 0; 0, I, 0, 0; -I, 0, 0, 0]

/-- γ³ in the Dirac representation. -/
def diracGamma3 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 1, 0; 0, 0, 0, -1; -1, 0, 0, 0; 0, 1, 0, 0]

/-- Indexed gamma matrix function: `diracGamma μ` for μ ∈ {0,1,2,3}. -/
def diracGamma : Fin 4 → Matrix (Fin 4) (Fin 4) ℂ :=
  ![diracGamma0, diracGamma1, diracGamma2, diracGamma3]

/-- γ⁵ in the Dirac representation: explicit anti-diagonal block matrix. -/
def diracGamma5 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 1, 0; 0, 0, 0, 1; 1, 0, 0, 0; 0, 1, 0, 0]

-- ── Minkowski metric (local copy matching FCPrelude.eta, +−−− signature) ─────

/-- Minkowski η^{μν}: +1 for μ=ν=0, −1 for μ=ν∈{1,2,3}, 0 otherwise. -/
def minkEta (μ ν : Fin 4) : ℝ :=
  if μ = ν then (if μ.val = 0 then 1 else -1) else 0

-- ── Diagonal products (γ^μ)² = η_{μμ} · 1₄ ─────────────────────────────────

/-- Each γ^μ squares to the metric value: (γ^μ)² = η_{μμ} · 1₄. -/
private lemma diracGamma_sq_eq (μ : Fin 4) :
    diracGamma μ * diracGamma μ = (minkEta μ μ : ℂ) • 1 := by
  fin_cases μ <;>
    ext i j <;> fin_cases i <;> fin_cases j <;>
    simp [diracGamma, minkEta, diracGamma0, diracGamma1, diracGamma2, diracGamma3,
          Matrix.mul_apply, Fin.sum_univ_four, Matrix.smul_apply, Matrix.one_apply,
          Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const,
          I_sq] <;>
    ring

-- ── Off-diagonal anticommutation: γ^μγ^ν + γ^νγ^μ = 0 for μ ≠ ν ────────────

/-- Helper: every element of Fin 4 is one of 0, 1, 2, 3 (via rfl, no (fun i => i) wrapper). -/
private lemma fin4_cases_eq (i : Fin 4) :
    i = ⟨0, by omega⟩ ∨ i = ⟨1, by omega⟩ ∨ i = ⟨2, by omega⟩ ∨ i = ⟨3, by omega⟩ := by
  rcases i with ⟨k, hk⟩; interval_cases k <;> simp

set_option maxHeartbeats 800000 in
/-- For μ ≠ ν, the anticommutator vanishes.
    Uses `rcases`+`rfl` throughout (not chained `fin_cases`) to avoid
    the `(fun i => i)` beta-unreduced wrapper that prevents simp unfolding.
    Heartbeat limit raised to handle 12 concrete matrix cases × 16 entries. -/
private lemma diracGamma_anticomm_neq (μ ν : Fin 4) (h : μ ≠ ν) :
    diracGamma μ * diracGamma ν + diracGamma ν * diracGamma μ = 0 := by
  rcases fin4_cases_eq μ with rfl | rfl | rfl | rfl <;>
  rcases fin4_cases_eq ν with rfl | rfl | rfl | rfl <;>
    first
    | exact absurd rfl h
    | (ext i j
       rcases fin4_cases_eq i with rfl | rfl | rfl | rfl <;>
       rcases fin4_cases_eq j with rfl | rfl | rfl | rfl <;>
       simp [diracGamma, diracGamma0, diracGamma1, diracGamma2, diracGamma3,
             Matrix.mul_apply, Matrix.add_apply, Fin.sum_univ_four, Matrix.zero_apply,
             Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const,
             I_sq] <;>
       ring)

-- ── Main theorem: anticommutation relation ───────────────────────────────────

/-- **Clifford anticommutation** for the Dirac gamma matrices:
    `γ^μ γ^ν + γ^ν γ^μ = 2η^{μν} · 1₄`  (signature +−−−). -/
theorem diracGamma_anticommute (μ ν : Fin 4) :
    diracGamma μ * diracGamma ν + diracGamma ν * diracGamma μ =
    (2 * (minkEta μ ν : ℂ)) • (1 : Matrix (Fin 4) (Fin 4) ℂ) := by
  by_cases h : μ = ν
  · -- Diagonal: use (γ^μ)² = η_{μμ} · 1₄, then 2 * (η_{μμ} · 1₄) = 2η_{μμ} · 1₄
    subst h
    rw [diracGamma_sq_eq, ← add_smul]
    congr 1
    push_cast
    ring
  · -- Off-diagonal: anticommutator vanishes, and minkEta μ ν = 0
    rw [diracGamma_anticomm_neq μ ν h]
    simp [minkEta, if_neg h]

-- ── γ⁵ properties ────────────────────────────────────────────────────────────

/-- `(γ⁵)² = 1₄` — from the explicit anti-diagonal block structure. -/
theorem diracGamma5_sq : diracGamma5 * diracGamma5 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [diracGamma5, Matrix.mul_apply, Fin.sum_univ_four, Matrix.one_apply]

/-- γ⁵ anticommutes with each γ^μ: `γ⁵γ^μ + γ^μγ⁵ = 0`. -/
theorem diracGamma5_anticommute (μ : Fin 4) :
    diracGamma5 * diracGamma μ + diracGamma μ * diracGamma5 = 0 := by
  fin_cases μ <;>
    ext i j <;> fin_cases i <;> fin_cases j <;>
    simp [diracGamma, diracGamma0, diracGamma1, diracGamma2, diracGamma3,
          diracGamma5, Matrix.mul_apply, Matrix.add_apply, Fin.sum_univ_four,
          Matrix.zero_apply, Matrix.cons_val_zero, Matrix.cons_val_one,
          Matrix.head_cons, Matrix.head_fin_const, I_sq] <;>
    ring

end CATEPTMain.GaugeTheory.FEYNCALC
