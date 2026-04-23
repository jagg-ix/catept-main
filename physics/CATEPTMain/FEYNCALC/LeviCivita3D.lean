import Mathlib
/-!
# Levi-Civita Tensor in 3D — Complete Lean 4 Formalization

Formalizes the Levi-Civita tensor ε_{ijk} over `Fin 3`, the Kronecker delta,
standard vector operations (dot, cross, curl), and the full suite of algebraic
identities from classical tensor analysis.

This file is intentionally Euclidean 3D. For the 4D Lorentz-index Levi-Civita
tensor ε^{μνρσ} used in FEYNCALC, see
`CATEPTMain.FEYNCALC.LeviCivita4D` and
`CATEPTMain.FEYNCALC.LorentzAlgebra`.

## Proof strategy (pragmatic)

All combinatorial and contraction lemmas use:
  `fin_cases` to enumerate all concrete index values, then
  `simp [epsilon, delta, Fin.sum_univ_three]` to fully reduce (full simp set
  evaluates `Fin` equality via `DecidableEq`), then `ring` to close arithmetic.

Key lessons:
  - `simp [epsilon]` (full simp, not `simp only`) correctly evaluates Fin 3
    concrete equalities (e.g. `(0:Fin 3) = (1:Fin 3)` → False).
  - `simp only [epsilon]` does NOT suffice — needs the full simp set.
  - After `fin_cases` exhausts all indices, `simp [epsilon]` closes structural
    lemmas entirely (via `neg_neg`, `rfl`); no trailing `norm_num` needed.
  - `epsilon_contract_general` (3^6 = 729 goals) requires raised heartbeats.

## Contents

| Lemma                      | Statement                                           | Status  |
|----------------------------|-----------------------------------------------------|---------|
| epsilon_antisym            | ε_{ijk} = −ε_{jik}                                 | proved  |
| epsilon_antisym_23         | ε_{ijk} = −ε_{ikj}                                 | proved  |
| epsilon_cyclic             | ε_{ijk} = ε_{jki}                                  | proved  |
| epsilon_test_pos/neg       | ε_{012}² = 1 ; ε_{012}·ε_{210} = −1                | proved  |
| epsilon_contract_single    | ∑_k ε_{ijk} ε_{klm} = δ_{il}δ_{jm} − δ_{im}δ_{jl} | proved  |
| epsilon_contract_double    | ∑_{jk} ε_{ijk} ε_{ljk} = 2 δ_{il}                 | proved  |
| epsilon_norm               | ∑_{ijk} ε_{ijk}² = 6                               | proved  |
| epsilon_contract_general   | ε_{ijk} ε_{lmn} = det(δ) expansion                 | proved  |
| cross_comp0/1/2            | (u×v)_i = explicit component formula               | proved  |
| curl_comp0/1/2             | (∇×v)_i = explicit component formula               | proved  |
| cross_self                 | u × u = 0                                          | proved  |
| cross_anticomm             | u × v = −(v × u)                                   | proved  |
| cross_add_left/right       | bilinearity of cross product                        | proved  |
| dot_cross_left             | u · (u × v) = 0                                    | proved  |
| dot_cross_right            | u · (v × v) = 0                                    | proved  |
| bac_cab                    | u×(v×w) = (u·w)v − (u·v)w                          | proved  |
| triple_product             | u·(v×w) = w·(u×v) = v·(w×u)                        | proved  |
-/

set_option autoImplicit false

open BigOperators

namespace LeviCivita

-- ── Core definitions ──────────────────────────────────────────────────────────

/-- Kronecker delta: 1 if i = j, else 0. -/
def delta (i j : Fin 3) : ℝ := if i = j then 1 else 0

/-- Levi-Civita tensor ε_{ijk} over Fin 3 (values in ℝ).
    Even permutations of (0,1,2) → +1; odd permutations → −1; all others → 0. -/
def epsilon (i j k : Fin 3) : ℝ :=
  if      i = 0 ∧ j = 1 ∧ k = 2 then  1
  else if i = 1 ∧ j = 2 ∧ k = 0 then  1
  else if i = 2 ∧ j = 0 ∧ k = 1 then  1
  else if i = 0 ∧ j = 2 ∧ k = 1 then -1
  else if i = 2 ∧ j = 1 ∧ k = 0 then -1
  else if i = 1 ∧ j = 0 ∧ k = 2 then -1
  else 0

-- ── Structural properties ─────────────────────────────────────────────────────
-- All proved by: fin_cases (all 3 indices) → simp [epsilon] (full simp set
-- evaluates Fin concrete comparisons via DecidableEq) → closed by neg_neg/rfl.

/-- ε is antisymmetric under exchange of first two indices: ε_{ijk} = −ε_{jik}. -/
lemma epsilon_antisym (i j k : Fin 3) :
    epsilon i j k = -epsilon j i k := by
  fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [epsilon]

/-- ε is antisymmetric under exchange of last two indices: ε_{ijk} = −ε_{ikj}. -/
lemma epsilon_antisym_23 (i j k : Fin 3) :
    epsilon i j k = -epsilon i k j := by
  fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [epsilon]

/-- Cyclic symmetry: ε_{ijk} = ε_{jki}. -/
lemma epsilon_cyclic (i j k : Fin 3) :
    epsilon i j k = epsilon j k i := by
  fin_cases i <;> fin_cases j <;> fin_cases k <;> simp [epsilon]

/-- ε vanishes when any two indices coincide (follows from antisymmetry). -/
lemma epsilon_self_12 (i k : Fin 3) : epsilon i i k = 0 := by
  have h := epsilon_antisym i i k; linarith

lemma epsilon_self_23 (i j : Fin 3) : epsilon i j j = 0 := by
  have h := epsilon_antisym_23 i j j; linarith

lemma epsilon_self_13 (j k : Fin 3) : epsilon j j k = 0 := epsilon_self_12 j k

-- ── Explicit test cases ───────────────────────────────────────────────────────

lemma epsilon_test_pos : epsilon 0 1 2 * epsilon 0 1 2 = 1 := by
  simp [epsilon]

lemma epsilon_test_neg : epsilon 0 1 2 * epsilon 2 1 0 = -1 := by
  simp [epsilon]

-- ── Contraction identities ────────────────────────────────────────────────────

/-- **Single contraction**: ∑_k ε_{ijk} ε_{klm} = δ_{il} δ_{jm} − δ_{im} δ_{jl}.
    (k is the last index of the first tensor and first of the second.) -/
lemma epsilon_contract_single (i j l m : Fin 3) :
    ∑ k : Fin 3, epsilon i j k * epsilon k l m =
    delta i l * delta j m - delta i m * delta j l := by
  fin_cases i <;> fin_cases j <;> fin_cases l <;> fin_cases m <;>
    simp [epsilon, delta]

/-- **Double contraction**: ∑_{jk} ε_{ijk} ε_{ljk} = 2 δ_{il}. -/
lemma epsilon_contract_double (i l : Fin 3) :
    ∑ j : Fin 3, ∑ k : Fin 3, epsilon i j k * epsilon l j k =
    2 * delta i l := by
  fin_cases i <;> fin_cases l <;>
    simp [epsilon, delta, Fin.sum_univ_three] <;> ring

/-- **Normalization**: ∑_{ijk} ε_{ijk}² = 6. -/
lemma epsilon_norm :
    ∑ i : Fin 3, ∑ j : Fin 3, ∑ k : Fin 3, epsilon i j k * epsilon i j k = 6 := by
  simp [epsilon, Fin.sum_univ_three]
  norm_num

set_option maxHeartbeats 4000000 in
/-- **General contraction identity**: ε_{ijk} ε_{lmn} = 3×3 determinant of Kronecker deltas. -/
lemma epsilon_contract_general (i j k l m n : Fin 3) :
    epsilon i j k * epsilon l m n =
    delta i l * delta j m * delta k n +
    delta i m * delta j n * delta k l +
    delta i n * delta j l * delta k m -
    delta i l * delta j n * delta k m -
    delta i n * delta j m * delta k l -
    delta i m * delta j l * delta k n := by
  fin_cases i <;> fin_cases j <;> fin_cases k <;>
    fin_cases l <;> fin_cases m <;> fin_cases n <;>
    simp [epsilon, delta]

-- ── Vector operations ─────────────────────────────────────────────────────────

/-- Dot product: u · v = ∑_i u_i v_i. -/
def dot (u v : Fin 3 → ℝ) : ℝ := ∑ i, u i * v i

/-- Cross product: (u × v)_i = ∑_{jk} ε_{ijk} u_j v_k. -/
def cross (u v : Fin 3 → ℝ) : Fin 3 → ℝ :=
  fun i => ∑ j : Fin 3, ∑ k : Fin 3, epsilon i j k * u j * v k

/-- Curl: (∇ × f)_i = ∑_{jk} ε_{ijk} d_{jk}
    where `d j k` represents ∂_j f_k (abstracted derivative operator). -/
def curl (d : Fin 3 → Fin 3 → ℝ) : Fin 3 → ℝ :=
  fun i => ∑ j : Fin 3, ∑ k : Fin 3, epsilon i j k * d j k

-- ── Component expansions: cross product ──────────────────────────────────────
-- These are the building blocks for all higher vector identity proofs.

/-- (u × v)_0 = u_1 v_2 − u_2 v_1. -/
lemma cross_comp0 (u v : Fin 3 → ℝ) :
    cross u v 0 = u 1 * v 2 - u 2 * v 1 := by
  simp [cross, Fin.sum_univ_three, epsilon]; ring

/-- (u × v)_1 = u_2 v_0 − u_0 v_2. -/
lemma cross_comp1 (u v : Fin 3 → ℝ) :
    cross u v 1 = u 2 * v 0 - u 0 * v 2 := by
  simp [cross, Fin.sum_univ_three, epsilon]; ring

/-- (u × v)_2 = u_0 v_1 − u_1 v_0. -/
lemma cross_comp2 (u v : Fin 3 → ℝ) :
    cross u v 2 = u 0 * v 1 - u 1 * v 0 := by
  simp [cross, Fin.sum_univ_three, epsilon]; ring

-- ── Component expansions: curl ────────────────────────────────────────────────

/-- (∇ × f)_0 = d_{12} − d_{21}  (i.e. ∂_1 f_2 − ∂_2 f_1). -/
lemma curl_comp0 (d : Fin 3 → Fin 3 → ℝ) :
    curl d 0 = d 1 2 - d 2 1 := by
  simp [curl, Fin.sum_univ_three, epsilon]; ring

/-- (∇ × f)_1 = d_{20} − d_{02}. -/
lemma curl_comp1 (d : Fin 3 → Fin 3 → ℝ) :
    curl d 1 = d 2 0 - d 0 2 := by
  simp [curl, Fin.sum_univ_three, epsilon]; ring

/-- (∇ × f)_2 = d_{01} − d_{10}. -/
lemma curl_comp2 (d : Fin 3 → Fin 3 → ℝ) :
    curl d 2 = d 0 1 - d 1 0 := by
  simp [curl, Fin.sum_univ_three, epsilon]; ring

-- ── Vector identities ─────────────────────────────────────────────────────────
-- All proved by rewriting via cross_comp0/1/2 (which give fully-evaluated
-- component formulas) and then closing with `ring`.

/-- Helper: expand dot product to three explicit terms. -/
private lemma dot_expand (u v : Fin 3 → ℝ) :
    dot u v = u 0 * v 0 + u 1 * v 1 + u 2 * v 2 := by
  simp [dot, Fin.sum_univ_three]

/-- **Cross product of a vector with itself vanishes**: u × u = 0. -/
lemma cross_self (u : Fin 3 → ℝ) : cross u u = fun _ => 0 := by
  funext i; fin_cases i
  · show cross u u 0 = 0; rw [cross_comp0]; ring
  · show cross u u 1 = 0; rw [cross_comp1]; ring
  · show cross u u 2 = 0; rw [cross_comp2]; ring

/-- **Cross product is anticommutative**: u × v = −(v × u). -/
lemma cross_anticomm (u v : Fin 3 → ℝ) :
    cross u v = fun i => -(cross v u i) := by
  funext i; fin_cases i
  · show cross u v 0 = -(cross v u 0); rw [cross_comp0 u v, cross_comp0 v u]; ring
  · show cross u v 1 = -(cross v u 1); rw [cross_comp1 u v, cross_comp1 v u]; ring
  · show cross u v 2 = -(cross v u 2); rw [cross_comp2 u v, cross_comp2 v u]; ring

/-- **Cross product is bilinear in the left argument**. -/
lemma cross_add_left (u₁ u₂ v : Fin 3 → ℝ) :
    cross (fun i => u₁ i + u₂ i) v = fun i => cross u₁ v i + cross u₂ v i := by
  funext i; fin_cases i
  · show cross (fun i => u₁ i + u₂ i) v 0 = cross u₁ v 0 + cross u₂ v 0
    simp only [cross_comp0]; ring
  · show cross (fun i => u₁ i + u₂ i) v 1 = cross u₁ v 1 + cross u₂ v 1
    simp only [cross_comp1]; ring
  · show cross (fun i => u₁ i + u₂ i) v 2 = cross u₁ v 2 + cross u₂ v 2
    simp only [cross_comp2]; ring

/-- **Cross product is bilinear in the right argument**. -/
lemma cross_add_right (u v₁ v₂ : Fin 3 → ℝ) :
    cross u (fun i => v₁ i + v₂ i) = fun i => cross u v₁ i + cross u v₂ i := by
  funext i; fin_cases i
  · show cross u (fun i => v₁ i + v₂ i) 0 = cross u v₁ 0 + cross u v₂ 0
    simp only [cross_comp0]; ring
  · show cross u (fun i => v₁ i + v₂ i) 1 = cross u v₁ 1 + cross u v₂ 1
    simp only [cross_comp1]; ring
  · show cross u (fun i => v₁ i + v₂ i) 2 = cross u v₁ 2 + cross u v₂ 2
    simp only [cross_comp2]; ring

/-- **The cross product is orthogonal to its left factor**: u · (u × v) = 0. -/
lemma dot_cross_left (u v : Fin 3 → ℝ) :
    dot u (cross u v) = 0 := by
  rw [dot_expand, cross_comp0 u v, cross_comp1 u v, cross_comp2 u v]; ring

/-- **u · (v × v) = 0**: cross product with itself vanishes under dot. -/
lemma dot_cross_right (u v : Fin 3 → ℝ) :
    dot u (cross v v) = 0 := by
  rw [dot_expand, cross_comp0 v v, cross_comp1 v v, cross_comp2 v v]; ring

/-- **BAC–CAB rule**: u × (v × w) = (u · w) v − (u · v) w.
    Proof: `show` normalises the `fin_cases` beta-wrapper, then rewrite via
    cross_comp and dot_expand, close with ring. -/
lemma bac_cab (u v w : Fin 3 → ℝ) :
    cross u (cross v w) = fun i => dot u w * v i - dot u v * w i := by
  funext i; fin_cases i
  · show cross u (cross v w) 0 = dot u w * v 0 - dot u v * w 0
    rw [cross_comp0 u (cross v w), cross_comp1 v w, cross_comp2 v w,
        dot_expand u w, dot_expand u v]; ring
  · show cross u (cross v w) 1 = dot u w * v 1 - dot u v * w 1
    rw [cross_comp1 u (cross v w), cross_comp0 v w, cross_comp2 v w,
        dot_expand u w, dot_expand u v]; ring
  · show cross u (cross v w) 2 = dot u w * v 2 - dot u v * w 2
    rw [cross_comp2 u (cross v w), cross_comp0 v w, cross_comp1 v w,
        dot_expand u w, dot_expand u v]; ring

/-- **Triple product cyclic symmetry**:
      u · (v × w) = w · (u × v)  and  v · (w × u) = u · (v × w).
    Proof: expand all cross products to component formulas; ring. -/
lemma triple_product (u v w : Fin 3 → ℝ) :
    dot u (cross v w) = dot w (cross u v) ∧
    dot v (cross w u) = dot u (cross v w) := by
  simp only [dot_expand, cross_comp0, cross_comp1, cross_comp2]
  constructor <;> ring

end LeviCivita
