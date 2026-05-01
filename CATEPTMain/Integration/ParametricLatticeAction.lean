import CATEPTMain.Integration.LatticeActionDerivation

/-!
# Parametric Quadratic Lattice Action (T-FF Phase 25)

Generalizes `LatticeActionDerivation` (P23) from the unit
quadratic action `S(k) = k²` to a one-parameter family of
homogeneous quadratic actions

  `S_a(k) = a · k²`,    `a > 0`,

and proves the **high-mode coercivity inequality**

  `S_a(k + N) ≥ S_a(k) + a · N²`     ∀ k, N ∈ ℕ,

which is the lattice-level statement underlying the choice
`coercivityConstant = a` in `LatticeAction`. Specializing to
`a = 1` recovers the P23 datum `(α, C) = (2, 1)`.

## Mathematical content

For any `a > 0` and any `k, N ∈ ℕ`,

  `S_a(k+N) − S_a(k) = a · ((k+N)² − k²)
                     = a · (2 k N + N²)
                     ≥ a · N²`,

since `2 k N ≥ 0`. Hence the **shift-coercivity** statement

  `S_a(k+N) ≥ S_a(k) + a · N²`

with leading constant `a`. This is the elementary fact behind
the index-shift estimate of P20 (1-D) and P22/P24 (3-D).

## Output

* `ParametricQuadraticAction` — bundle of `(a, a_pos)`.
* `paramAction` — the action profile `S_a : ℕ → ℝ`.
* `paramAction_shift_coercivity` — the inequality
  `S_a(k+N) ≥ S_a(k) + a · N²`.
* `paramLatticeAction` — packaging into the P23 record
  `LatticeAction` with `actionDegree = 2`,
  `coercivityConstant = a`.
* Specialization theorems showing that the `a = 1`
  instance reproduces the data of `realLatticeAction1D`.
* Six kernel-only audit theorems.

## Honest scope

* This is still a structural / wiring lemma, not a derivation
  of `(C, α)` from CAT/EPT primitive variables. The novelty
  over P23 is exposing `C = a` as a continuous parameter, so
  downstream consumers can vary the coercivity strength while
  keeping the abstract `PhysicalEntropicModel` shape stable.
* The shift-coercivity lemma `paramAction_shift_coercivity`
  is the elementary `(k+N)² ≥ k² + N²` rescaled by `a`; no
  appeal to summability or analytic estimates.
* Higher-degree polynomial actions `S(k) = a · k^d` for
  `d ≥ 3` would require a separate file — they are not
  covered here, since the cube tail of P22 / index shift of
  P24 are tied to the quadratic case.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.ParametricLatticeAction

open CATEPTMain.Integration.LatticeActionDerivation

noncomputable section

/-! ## Parametric quadratic action. -/

/-- A one-parameter family of homogeneous quadratic lattice
actions `S_a(k) = a · k²`, parameterized by a positive real
`a`. -/
structure ParametricQuadraticAction where
  /-- The leading coefficient `a`. -/
  a : ℝ
  /-- Positivity of `a`. -/
  a_pos : 0 < a

/-- The action profile `S_a(k) = a · k²` as a function `ℕ → ℝ`. -/
def paramAction (P : ParametricQuadraticAction) (k : ℕ) : ℝ :=
  P.a * ((k : ℝ))^2

/-! ## Shift-coercivity. -/

/-- **Shift coercivity** of the parametric quadratic action:
for any base index `k` and shift `N`,

  `S_a(k + N) ≥ S_a(k) + a · N²`.

This is the elementary fact `(k+N)² − k² = 2kN + N² ≥ N²`
rescaled by the positive coefficient `a`. -/
theorem paramAction_shift_coercivity
    (P : ParametricQuadraticAction) (k N : ℕ) :
    paramAction P (k + N)
      ≥ paramAction P k + P.a * ((N : ℝ))^2 := by
  unfold paramAction
  have hcast : ((k + N : ℕ) : ℝ) = (k : ℝ) + (N : ℝ) := by
    push_cast; ring
  rw [hcast]
  have hk_nonneg : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
  have hN_nonneg : (0 : ℝ) ≤ (N : ℝ) := Nat.cast_nonneg N
  have h_cross : (0 : ℝ) ≤ 2 * (k : ℝ) * (N : ℝ) := by positivity
  have h_expand :
      ((k : ℝ) + (N : ℝ))^2
        = ((k : ℝ))^2 + 2 * (k : ℝ) * (N : ℝ) + ((N : ℝ))^2 := by
    ring
  have h_pa_nonneg : 0 ≤ P.a := P.a_pos.le
  nlinarith [P.a_pos, h_cross, h_expand]

/-! ## Packaging into `LatticeAction`. -/

/-- Package a parametric quadratic action `S_a` into the
abstract `LatticeAction` record of P23 with degree `2` and
coercivity constant `a`. -/
def paramLatticeAction (P : ParametricQuadraticAction) :
    LatticeAction where
  action := paramAction P
  actionDegree := 2
  coercivityConstant := P.a
  actionDegree_pos := by norm_num
  coercivityConstant_pos := P.a_pos

/-! ## Specialization to `a = 1`. -/

/-- The `a = 1` instance of the parametric family. -/
def unitParam : ParametricQuadraticAction where
  a := 1
  a_pos := one_pos

/-- For `a = 1` the parametric action profile collapses to
`k²`, the action of P23. -/
theorem paramAction_unit_eq (k : ℕ) :
    paramAction unitParam k = ((k : ℝ))^2 := by
  unfold paramAction unitParam
  simp

/-- For `a = 1` the parametric action profile equals
`realLatticeAction1D.action`. -/
theorem paramAction_unit_eq_realLatticeAction1D (k : ℕ) :
    paramAction unitParam k = realLatticeAction1D.action k := by
  rw [paramAction_unit_eq]
  rfl

/-- For `a = 1` the packaged record has the same degree as
`realLatticeAction1D`. -/
theorem paramLatticeAction_unit_degree :
    (paramLatticeAction unitParam).actionDegree
      = realLatticeAction1D.actionDegree := rfl

/-- For `a = 1` the packaged record has the same coercivity
constant as `realLatticeAction1D`. -/
theorem paramLatticeAction_unit_coercivity :
    (paramLatticeAction unitParam).coercivityConstant
      = realLatticeAction1D.coercivityConstant := rfl

/-! ## Audit theorems. -/

/-- The packaged parametric record has degree `2`. -/
theorem paramLatticeAction_degree_eq_two
    (P : ParametricQuadraticAction) :
    (paramLatticeAction P).actionDegree = 2 := rfl

/-- The packaged parametric record has coercivity constant
`P.a`. -/
theorem paramLatticeAction_coercivity_eq_a
    (P : ParametricQuadraticAction) :
    (paramLatticeAction P).coercivityConstant = P.a := rfl

/-- The packaged action profile is `paramAction P`. -/
theorem paramLatticeAction_action_eq
    (P : ParametricQuadraticAction) (k : ℕ) :
    (paramLatticeAction P).action k = paramAction P k := rfl

/-- The shift-coercivity inequality, restated through the
packaged record. -/
theorem paramLatticeAction_shift_coercivity
    (P : ParametricQuadraticAction) (k N : ℕ) :
    (paramLatticeAction P).action (k + N)
      ≥ (paramLatticeAction P).action k
        + (paramLatticeAction P).coercivityConstant
          * ((N : ℝ))^2 :=
  paramAction_shift_coercivity P k N

/-- Specialization audit: the `a = 1` packaged degree is `2`. -/
theorem paramLatticeAction_unit_degree_eq_two :
    (paramLatticeAction unitParam).actionDegree = 2 := rfl

/-- Specialization audit: the `a = 1` packaged coercivity is `1`. -/
theorem paramLatticeAction_unit_coercivity_eq_one :
    (paramLatticeAction unitParam).coercivityConstant = 1 := rfl

end

end CATEPTMain.Integration.ParametricLatticeAction
