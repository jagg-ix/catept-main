import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Data.Fin.Tuple.Basic
import Mathlib.LinearAlgebra.Matrix.Notation
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic
/-!
# Euclidean Clifford Algebra — Concrete Chiral Representation

Concrete 4×4 complex gamma matrices satisfying `{γ^μ, γ^ν} = 2δ^{μν}·1₄`
with Euclidean signature (+,+,+,+), i.e. Cl(4,0).

These are the **Euclidean chiral representation** matrices used in lattice QCD,
matching the convention in LatticeDiracOperators.jl (Akio Tomiya et al.):

              (       -i )              (       -1 )
    GAMMA1 =  (     -i   )     GAMMA2 = (     +1   )
              (   +i     )              (   +1     )
              ( +i       )              ( -1       )

              (     -i   )              (     -1   )
    GAMMA3 =  (       +i )     GAMMA4 = (       -1 )
              ( +i       )              ( -1       )
              (   -i     )              (   -1     )

              ( -1       )
    GAMMA5 =  (   -1     )  =  γ₁γ₂γ₃γ₄
              (     +1   )
              (       +1 )

Clifford relation: {γ^μ, γ^ν} = 2δ_{μν}·1₄  for μ,ν ∈ {1,2,3,4}.

Source: LatticeDiracOperators.jl `mk_gamma()`, WilsonFermion.jl lines 318–477.
Reference: Geometric-Algebra/CliffordBasic.m (Cl(p,q) framework with p=4, q=0).

## Proof strategy

Same as `CliffordMinkowski.lean`:
1. `euclidGamma_sq_eq`: (γ^μ)² = 1₄  (all 4 cases, Euclidean: every square = +1)
2. `euclidGamma_anticomm_neq`: γ^μγ^ν + γ^νγ^μ = 0 for μ≠ν  (12 off-diagonal cases)
3. Combined in `euclidGamma_anticommute` via `by_cases h : μ = ν`.
-/

set_option autoImplicit false
open Complex

namespace CATEPTMain.FEYNCALC

-- ── Concrete gamma matrices (Euclidean chiral representation) ────────────────

/-- γ₁ (Euclidean chiral). Off-diagonal blocks with ±i entries. -/
def euclidGamma1 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 0, -I; 0, 0, -I, 0; 0, I, 0, 0; I, 0, 0, 0]

/-- γ₂ (Euclidean chiral). Off-diagonal blocks with ±1 entries. -/
def euclidGamma2 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, 0, -1; 0, 0, 1, 0; 0, 1, 0, 0; -1, 0, 0, 0]

/-- γ₃ (Euclidean chiral). Off-diagonal blocks with ±i entries. -/
def euclidGamma3 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, -I, 0; 0, 0, 0, I; I, 0, 0, 0; 0, -I, 0, 0]

/-- γ₄ (Euclidean chiral). Off-diagonal blocks with ±1 entries. -/
def euclidGamma4 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![0, 0, -1, 0; 0, 0, 0, -1; -1, 0, 0, 0; 0, -1, 0, 0]

/-- Indexed Euclidean gamma matrix function: `euclidGamma μ` for μ ∈ {0,1,2,3}.
    Note: we use 0-based indexing (Fin 4), mapping 0→γ₁, 1→γ₂, 2→γ₃, 3→γ₄. -/
def euclidGamma : Fin 4 → Matrix (Fin 4) (Fin 4) ℂ :=
  ![euclidGamma1, euclidGamma2, euclidGamma3, euclidGamma4]

/-- γ₅ (Euclidean chiral) = γ₁γ₂γ₃γ₄ = diag(-1,-1,+1,+1). -/
def euclidGamma5 : Matrix (Fin 4) (Fin 4) ℂ :=
  !![-1, 0, 0, 0; 0, -1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1]

-- ── Euclidean metric (Kronecker delta) ───────────────────────────────────────

/-- Euclidean metric δ_{μν}: 1 if μ=ν, 0 otherwise. -/
def euclidDelta (μ ν : Fin 4) : ℝ :=
  if μ = ν then 1 else 0

-- ── Diagonal products (γ^μ)² = 1₄ ──────────────────────────────────────────

/-- Each Euclidean γ^μ squares to the identity: (γ^μ)² = 1₄.
    This is the Euclidean signature property — all squares are +1. -/
private lemma euclidGamma_sq_eq (μ : Fin 4) :
    euclidGamma μ * euclidGamma μ = (euclidDelta μ μ : ℂ) • 1 := by
  fin_cases μ <;>
    ext i j <;> fin_cases i <;> fin_cases j <;>
    simp [euclidGamma, euclidDelta, euclidGamma1, euclidGamma2, euclidGamma3, euclidGamma4,
          Matrix.mul_apply, Fin.sum_univ_four, Matrix.smul_apply, Matrix.one_apply,
          Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const,
          I_sq] <;>
    ring

-- ── Off-diagonal anticommutation: γ^μγ^ν + γ^νγ^μ = 0 for μ ≠ ν ────────────

/-- Helper: every element of Fin 4 is one of 0, 1, 2, 3. -/
private lemma fin4_cases_eq (i : Fin 4) :
    i = ⟨0, by omega⟩ ∨ i = ⟨1, by omega⟩ ∨ i = ⟨2, by omega⟩ ∨ i = ⟨3, by omega⟩ := by
  rcases i with ⟨k, hk⟩; interval_cases k <;> simp

set_option maxHeartbeats 800000 in
/-- For μ ≠ ν, the anticommutator vanishes: γ^μγ^ν + γ^νγ^μ = 0.
    12 off-diagonal cases, each verified by entry-wise computation. -/
private lemma euclidGamma_anticomm_neq (μ ν : Fin 4) (h : μ ≠ ν) :
    euclidGamma μ * euclidGamma ν + euclidGamma ν * euclidGamma μ = 0 := by
  rcases fin4_cases_eq μ with rfl | rfl | rfl | rfl <;>
  rcases fin4_cases_eq ν with rfl | rfl | rfl | rfl <;>
    first
    | exact absurd rfl h
    | (ext i j
       rcases fin4_cases_eq i with rfl | rfl | rfl | rfl <;>
       rcases fin4_cases_eq j with rfl | rfl | rfl | rfl <;>
       simp [euclidGamma, euclidGamma1, euclidGamma2, euclidGamma3, euclidGamma4,
             Matrix.mul_apply, Matrix.add_apply, Fin.sum_univ_four, Matrix.zero_apply,
             Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const,
             I_sq] <;>
       ring)

-- ── Main theorem: Euclidean Clifford anticommutation relation ────────────────

/-- **Euclidean Clifford anticommutation** for the chiral gamma matrices:
    `γ^μ γ^ν + γ^ν γ^μ = 2δ_{μν} · 1₄`  (signature +,+,+,+).
    This is the defining relation of Cl(4,0). -/
theorem euclidGamma_anticommute (μ ν : Fin 4) :
    euclidGamma μ * euclidGamma ν + euclidGamma ν * euclidGamma μ =
    (2 * (euclidDelta μ ν : ℂ)) • (1 : Matrix (Fin 4) (Fin 4) ℂ) := by
  by_cases h : μ = ν
  · subst h
    rw [euclidGamma_sq_eq, ← add_smul]
    congr 1
    push_cast
    ring
  · rw [euclidGamma_anticomm_neq μ ν h]
    simp [euclidDelta, if_neg h]

-- ── γ₅ properties ────────────────────────────────────────────────────────────

/-- `(γ₅)² = 1₄` — γ₅ is an involution. -/
theorem euclidGamma5_sq : euclidGamma5 * euclidGamma5 = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [euclidGamma5, Matrix.mul_apply, Fin.sum_univ_four, Matrix.one_apply]

/-- γ₅ anticommutes with each γ^μ: `γ₅γ^μ + γ^μγ₅ = 0`. -/
theorem euclidGamma5_anticommute (μ : Fin 4) :
    euclidGamma5 * euclidGamma μ + euclidGamma μ * euclidGamma5 = 0 := by
  fin_cases μ <;>
    ext i j <;> fin_cases i <;> fin_cases j <;>
    simp [euclidGamma, euclidGamma1, euclidGamma2, euclidGamma3, euclidGamma4,
          euclidGamma5, Matrix.mul_apply, Matrix.add_apply, Fin.sum_univ_four,
          Matrix.zero_apply, Matrix.cons_val_zero, Matrix.cons_val_one,
          Matrix.head_cons, Matrix.head_fin_const, I_sq] <;>
    ring

-- ── γ₅ = γ₁γ₂γ₃γ₄ ──────────────────────────────────────────────────────────

set_option maxHeartbeats 400000 in
/-- γ₅ equals the product γ₁γ₂γ₃γ₄ (pseudoscalar of Cl(4,0)). -/
theorem euclidGamma5_eq_product :
    euclidGamma5 = euclidGamma1 * euclidGamma2 * euclidGamma3 * euclidGamma4 := by
  ext i j
  rcases fin4_cases_eq i with rfl | rfl | rfl | rfl <;>
  rcases fin4_cases_eq j with rfl | rfl | rfl | rfl <;>
    simp [euclidGamma5, euclidGamma1, euclidGamma2, euclidGamma3, euclidGamma4,
          Matrix.mul_apply, Fin.sum_univ_four,
          Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
          Matrix.head_fin_const, I_sq] <;>
    ring

-- ── Hermiticity ──────────────────────────────────────────────────────────────

/-- γ₅ is Hermitian: γ₅† = γ₅. -/
theorem euclidGamma5_hermitian :
    euclidGamma5.conjTranspose = euclidGamma5 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [euclidGamma5, Matrix.conjTranspose_apply, Matrix.cons_val_zero,
          Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const,
          starRingEnd_apply, Complex.conj_ofReal]

-- ── Chiral projectors (lattice QCD convention) ──────────────────────────────

/-- Right chiral projector P₊ = (1 + γ₅)/2. -/
noncomputable def euclidChiralPlus : Matrix (Fin 4) (Fin 4) ℂ :=
  (1/2 : ℂ) • (1 + euclidGamma5)

/-- Left chiral projector P₋ = (1 - γ₅)/2. -/
noncomputable def euclidChiralMinus : Matrix (Fin 4) (Fin 4) ℂ :=
  (1/2 : ℂ) • (1 - euclidGamma5)

/-- Chiral projectors sum to identity: P₊ + P₋ = 1₄. -/
theorem euclidChiral_sum :
    euclidChiralPlus + euclidChiralMinus = 1 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [euclidChiralPlus, euclidChiralMinus, euclidGamma5,
          Matrix.smul_apply, Matrix.add_apply, Matrix.sub_apply,
          Matrix.one_apply, Matrix.cons_val_zero, Matrix.cons_val_one,
          Matrix.head_cons] <;>
    norm_num

/-- P₊ is idempotent: P₊² = P₊. -/
theorem euclidChiralPlus_sq :
    euclidChiralPlus * euclidChiralPlus = euclidChiralPlus := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [euclidChiralPlus, euclidGamma5,
          Matrix.mul_apply, Fin.sum_univ_four, Matrix.smul_apply,
          Matrix.add_apply, Matrix.one_apply,
          Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons] <;>
    norm_num

/-- P₋ is idempotent: P₋² = P₋. -/
theorem euclidChiralMinus_sq :
    euclidChiralMinus * euclidChiralMinus = euclidChiralMinus := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [euclidChiralMinus, euclidGamma5,
          Matrix.mul_apply, Fin.sum_univ_four, Matrix.smul_apply,
          Matrix.sub_apply, Matrix.one_apply,
          Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons] <;>
    norm_num

/-- Chiral projectors are orthogonal: P₊·P₋ = 0. -/
theorem euclidChiral_orthogonal :
    euclidChiralPlus * euclidChiralMinus = 0 := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [euclidChiralPlus, euclidChiralMinus, euclidGamma5,
          Matrix.mul_apply, Fin.sum_univ_four, Matrix.smul_apply,
          Matrix.add_apply, Matrix.sub_apply, Matrix.one_apply,
          Matrix.zero_apply, Matrix.cons_val_zero, Matrix.cons_val_one,
          Matrix.head_cons] <;>
    norm_num

-- ── Trace properties ─────────────────────────────────────────────────────────

/-- Tr(γ^μ) = 0 for each Euclidean gamma matrix. -/
theorem euclidGamma_trace_zero (μ : Fin 4) :
    Matrix.trace (euclidGamma μ) = 0 := by
  fin_cases μ <;>
    simp [euclidGamma, euclidGamma1, euclidGamma2, euclidGamma3, euclidGamma4,
          Matrix.trace, Fin.sum_univ_four, Matrix.diag,
          Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
          Matrix.head_fin_const]

/-- Tr(γ₅) = 0. -/
theorem euclidGamma5_trace_zero :
    Matrix.trace euclidGamma5 = 0 := by
  simp [euclidGamma5, Matrix.trace, Fin.sum_univ_four, Matrix.diag,
        Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons]

/-- Tr(1₄) = 4 (spinor dimension). -/
theorem euclidTrace_one :
    Matrix.trace (1 : Matrix (Fin 4) (Fin 4) ℂ) = 4 := by
  simp [Matrix.trace, Fin.sum_univ_four, Matrix.diag, Matrix.one_apply]

end CATEPTMain.FEYNCALC
