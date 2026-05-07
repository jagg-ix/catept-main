import CATEPTMain.Integration.LatticeActionDerivation
import CATEPTMain.Integration.ParametricLatticeAction

/-!
# Higher-Degree Polynomial Lattice Action (T-FF Phase 26)

Generalizes `ParametricLatticeAction` (P25) from the
quadratic family `S_a(k) = a · k²` to a two-parameter
family of homogeneous polynomial lattice actions

  `S_{a,d}(k) = a · k^d`,    `a > 0`,   `d ∈ ℕ`,  `1 ≤ d`,

and proves the **high-mode shift coercivity**

  `S_{a,d}(k + N) ≥ S_{a,d}(k) + a · N^d`     ∀ k, N ∈ ℕ,

for every natural exponent `d ≥ 1`. The d = 2 specialization
recovers the P25 datum, and the (a = 1, d = 2) further
specialization recovers the unit P23 datum.

## Mathematical content

The non-trivial inequality is

  `(x + y)^d ≥ x^d + y^d`            x, y ≥ 0,  d ≥ 1.

This is the elementary super-additivity of `t ↦ t^d` on
`[0,∞)` for natural exponent `d ≥ 1`; it follows from a
direct induction:

* `d = 1`:  `(x + y)^1 = x + y = x^1 + y^1`.
* `d ⇒ d + 1` (with `d ≥ 1`):
    `(x+y)^{d+1} = (x+y)·(x+y)^d ≥ (x+y)·(x^d + y^d)`
                `= x·x^d + x·y^d + y·x^d + y·y^d`
                `= x^{d+1} + y^{d+1} + (x·y^d + y·x^d)`
                `≥ x^{d+1} + y^{d+1}`,
  using `x, y ≥ 0` and the IH.

Multiplying by `a > 0` yields the shift-coercivity
inequality with leading constant `a · N^d`.

## Output

* `HigherDegreeAction` — bundle of `(a, a_pos, d, d_pos)`.
* `higherAction` — the action profile `S_{a,d} : ℕ → ℝ`.
* `add_pow_ge_pow_add_pow` — the auxiliary inequality
  `(x + y)^d ≥ x^d + y^d` for `x, y ≥ 0` and `1 ≤ d`.
* `higherAction_shift_coercivity` — the lattice statement
  `S_{a,d}(k+N) ≥ S_{a,d}(k) + a · N^d`.
* `higherLatticeAction` — packaging into the abstract
  `LatticeAction` of P23 with `actionDegree = d`,
  `coercivityConstant = a`.
* Specialization theorems showing
  - `d = 2` reproduces `paramLatticeAction P` of P25,
  - `(a = 1, d = 2)` reproduces `realLatticeAction1D` of P23.
* Audit theorems with kernel-only axioms.

## Honest scope

* This is a structural / wiring extension of P25. It
  exposes both the leading constant `a` and the homogeneity
  degree `d` as continuous / discrete parameters, so
  downstream consumers can vary either one while keeping
  the abstract `PhysicalEntropicModel` shape stable.
* The shift-coercivity lemma `higherAction_shift_coercivity`
  reduces to the elementary super-additivity of `t ↦ t^d`
  on `[0,∞)`; no appeal to summability, analytic estimates,
  or first-principles derivation of `(C, α)` from CAT/EPT
  primitive variables.
* The actual P22 / P24 cube-tail bound is still tied to
  the quadratic case `d = 2`. Higher exponents `d ≥ 3`
  would only flow through to a downstream `T3TailBound`
  variant if one separately replaces the `exp(-k²)` series
  with `exp(-k^d)`. That extension is not undertaken here.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.HigherDegreeLatticeAction

open CATEPTMain.Integration.LatticeActionDerivation
open CATEPTMain.Integration.ParametricLatticeAction

noncomputable section

/-! ## Higher-degree polynomial action. -/

/-- A two-parameter family of homogeneous polynomial lattice
actions `S_{a,d}(k) = a · k^d`, with positive coefficient
`a` and exponent `d ≥ 1`. -/
structure HigherDegreeAction where
  /-- The leading coefficient `a`. -/
  a : ℝ
  /-- Positivity of `a`. -/
  a_pos : 0 < a
  /-- The homogeneity exponent `d`. -/
  d : ℕ
  /-- Lower bound `d ≥ 1` (excludes the trivial constant
  action `d = 0`). -/
  d_pos : 1 ≤ d

/-- The action profile `S_{a,d}(k) = a · k^d` as a function
`ℕ → ℝ`. -/
def higherAction (P : HigherDegreeAction) (k : ℕ) : ℝ :=
  P.a * ((k : ℝ))^(P.d)

/-! ## Auxiliary super-additivity inequality. -/

/-- **Super-additivity of `t ↦ t^d` on `[0,∞)`** for
natural exponent `d ≥ 1`:

  `x^d + y^d ≤ (x + y)^d`        x, y ≥ 0,  1 ≤ d.

Proved by induction on `d`. -/
theorem add_pow_ge_pow_add_pow
    {x y : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y)
    {d : ℕ} (hd : 1 ≤ d) :
    x^d + y^d ≤ (x + y)^d := by
  induction d with
  | zero => omega
  | succ n ih =>
    by_cases hn : n = 0
    · subst hn; simp
    · have hn1 : 1 ≤ n := Nat.one_le_iff_ne_zero.mpr hn
      have ih' := ih hn1
      have hxy : 0 ≤ x + y := add_nonneg hx hy
      have hx_pow_nonneg : 0 ≤ x^n := pow_nonneg hx n
      have hy_pow_nonneg : 0 ≤ y^n := pow_nonneg hy n
      have h_cross_nonneg : 0 ≤ x * y^n + y * x^n := by positivity
      calc x^(n+1) + y^(n+1)
          = x * x^n + y * y^n := by ring
        _ ≤ x * x^n + y * y^n + (x * y^n + y * x^n) := by
            linarith
        _ = (x + y) * (x^n + y^n) := by ring
        _ ≤ (x + y) * (x + y)^n := by
            exact mul_le_mul_of_nonneg_left ih' hxy
        _ = (x + y)^(n+1) := by ring

/-! ## Shift-coercivity of the higher-degree action. -/

/-- **Shift coercivity** of the higher-degree action: for any
base index `k` and shift `N`,

  `S_{a,d}(k + N) ≥ S_{a,d}(k) + a · N^d`.

Reduces to `(k+N)^d ≥ k^d + N^d` rescaled by the positive
coefficient `a`, via `add_pow_ge_pow_add_pow`. -/
theorem higherAction_shift_coercivity
    (P : HigherDegreeAction) (k N : ℕ) :
    higherAction P (k + N)
      ≥ higherAction P k + P.a * ((N : ℝ))^(P.d) := by
  unfold higherAction
  have hcast : ((k + N : ℕ) : ℝ) = (k : ℝ) + (N : ℝ) := by
    push_cast; ring
  rw [hcast]
  have hk_nonneg : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have hN_nonneg : (0 : ℝ) ≤ (N : ℝ) := Nat.cast_nonneg N
  have h_super :
      ((k : ℝ))^(P.d) + ((N : ℝ))^(P.d)
        ≤ ((k : ℝ) + (N : ℝ))^(P.d) :=
    add_pow_ge_pow_add_pow hk_nonneg hN_nonneg P.d_pos
  have h_a_nonneg : 0 ≤ P.a := P.a_pos.le
  nlinarith [h_super, P.a_pos]

/-! ## Packaging into `LatticeAction`. -/

/-- Package a higher-degree polynomial action `S_{a,d}` into
the abstract `LatticeAction` record of P23 with
`actionDegree = d` and `coercivityConstant = a`. -/
def higherLatticeAction (P : HigherDegreeAction) :
    LatticeAction where
  action := higherAction P
  actionDegree := P.d
  coercivityConstant := P.a
  actionDegree_pos := P.d_pos
  coercivityConstant_pos := P.a_pos

/-! ## Specialization to `d = 2`. -/

/-- Build a `HigherDegreeAction` of degree `2` from a
`ParametricQuadraticAction` of P25. -/
def ofParametric (P : ParametricQuadraticAction) :
    HigherDegreeAction where
  a := P.a
  a_pos := P.a_pos
  d := 2
  d_pos := by norm_num

/-- For `d = 2` the higher-degree action profile collapses to
the parametric quadratic action `S_a(k) = a · k²` of P25. -/
theorem higherAction_ofParametric_eq
    (P : ParametricQuadraticAction) (k : ℕ) :
    higherAction (ofParametric P) k = paramAction P k := by
  unfold higherAction ofParametric paramAction
  simp

/-- For `d = 2` the packaged higher-degree record has the
same `actionDegree` as the P25 parametric record. -/
theorem higherLatticeAction_ofParametric_degree
    (P : ParametricQuadraticAction) :
    (higherLatticeAction (ofParametric P)).actionDegree
      = (paramLatticeAction P).actionDegree := rfl

/-- For `d = 2` the packaged higher-degree record has the
same `coercivityConstant` as the P25 parametric record. -/
theorem higherLatticeAction_ofParametric_coercivity
    (P : ParametricQuadraticAction) :
    (higherLatticeAction (ofParametric P)).coercivityConstant
      = (paramLatticeAction P).coercivityConstant := rfl

/-! ## Specialization to `(a = 1, d = 2)`. -/

/-- The `(a = 1, d = 2)` instance of the higher-degree
family. -/
def unitQuadratic : HigherDegreeAction where
  a := 1
  a_pos := one_pos
  d := 2
  d_pos := by norm_num

/-- For `(a = 1, d = 2)` the higher-degree action profile
collapses to `k²`, the action of P23. -/
theorem higherAction_unit_eq (k : ℕ) :
    higherAction unitQuadratic k = ((k : ℝ))^2 := by
  unfold higherAction unitQuadratic
  simp

/-- For `(a = 1, d = 2)` the higher-degree action profile
equals `realLatticeAction1D.action` of P23. -/
theorem higherAction_unit_eq_realLatticeAction1D (k : ℕ) :
    higherAction unitQuadratic k = realLatticeAction1D.action k := by
  rw [higherAction_unit_eq]
  rfl

/-- For `(a = 1, d = 2)` the packaged record has the same
degree as `realLatticeAction1D` of P23. -/
theorem higherLatticeAction_unit_degree :
    (higherLatticeAction unitQuadratic).actionDegree
      = realLatticeAction1D.actionDegree := rfl

/-- For `(a = 1, d = 2)` the packaged record has the same
coercivity constant as `realLatticeAction1D` of P23. -/
theorem higherLatticeAction_unit_coercivity :
    (higherLatticeAction unitQuadratic).coercivityConstant
      = realLatticeAction1D.coercivityConstant := rfl

/-! ## Audit theorems. -/

/-- The packaged higher-degree record has degree `P.d`. -/
theorem higherLatticeAction_degree_eq
    (P : HigherDegreeAction) :
    (higherLatticeAction P).actionDegree = P.d := rfl

/-- The packaged higher-degree record has coercivity
constant `P.a`. -/
theorem higherLatticeAction_coercivity_eq_a
    (P : HigherDegreeAction) :
    (higherLatticeAction P).coercivityConstant = P.a := rfl

/-- The packaged action profile is `higherAction P`. -/
theorem higherLatticeAction_action_eq
    (P : HigherDegreeAction) (k : ℕ) :
    (higherLatticeAction P).action k = higherAction P k := rfl

/-- The shift-coercivity inequality, restated through the
packaged record. -/
theorem higherLatticeAction_shift_coercivity
    (P : HigherDegreeAction) (k N : ℕ) :
    (higherLatticeAction P).action (k + N)
      ≥ (higherLatticeAction P).action k
        + (higherLatticeAction P).coercivityConstant
          * ((N : ℝ))^((higherLatticeAction P).actionDegree) :=
  higherAction_shift_coercivity P k N

/-- Specialization audit: the `(a = 1, d = 2)` packaged
degree is `2`. -/
theorem higherLatticeAction_unit_degree_eq_two :
    (higherLatticeAction unitQuadratic).actionDegree = 2 := rfl

/-- Specialization audit: the `(a = 1, d = 2)` packaged
coercivity is `1`. -/
theorem higherLatticeAction_unit_coercivity_eq_one :
    (higherLatticeAction unitQuadratic).coercivityConstant = 1 := rfl

end

end CATEPTMain.Integration.HigherDegreeLatticeAction
