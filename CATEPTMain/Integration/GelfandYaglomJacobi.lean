import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Complex.Trigonometric
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# Gel'fand–Yaglom Functional Determinant — Jacobi-Field Phase 1 (T-FF)

Phase-1 honest algebraic core of the **Gel'fand–Yaglom theorem** for the
one-dimensional harmonic oscillator with Dirichlet boundary data on
`[0, T]`.

The Gel'fand–Yaglom theorem states that the ratio of functional
determinants of `−∂²_t + V(t)` to that of `−∂²_t` over `[0, T]` (with
Dirichlet boundary conditions at both endpoints) equals the value at
`t = T` of the Jacobi-field solution `ψ_V` of
  `ψ'' + V(t)·ψ = 0`,    `ψ(0) = 0`, `ψ'(0) = 1`,
divided by the corresponding Jacobi field of the free problem (which
is just `t`):
  `det'(−∂²_t + V) / det'(−∂²_t)  =  ψ_V(T) / T`.

For the harmonic oscillator `V ≡ ω²` this gives the celebrated closed
form
  `det'(−∂²_t + ω²) / det'(−∂²_t)  =  sinh(ωT) / (ωT)`.

This file ships the algebraic Jacobi-field core: `gyJacobi ω T`,
defined piecewise so that `gyJacobi 0 T = T` (free particle, removable
singularity at `ω = 0`) and `gyJacobi ω T = sinh(ωT)/ω` otherwise.
The honest theorems verify

* the Dirichlet boundary condition at the source endpoint,
* the free-particle limit,
* the parity `ω ↦ −ω` symmetry (sinh is odd),
* the multiplicative bridge `ω·ψ_ω(T) = sinh(ωT)`.

## Stages NOT discharged here (require new infrastructure)

* The actual zeta-regularised functional determinant
  `det'(−∂²_t + V) := exp(−ζ'_{−∂²+V}(0))` and the equality to `ψ_V(T)/T`
  — needs spectral zeta theory and `MeasureTheory` zeta-regularisation.
* The finite-mode product representation
  `det'(−∂²_t + ω²) = ∏_{n≥1}(1 + ω²T²/(n²π²))`  — needs absolutely
  convergent Weierstrass-product analysis.
* Generalisation to a `T·V` smooth potential and the dependence of
  `ψ_V(T)` on `V` via the Jacobi ODE flow — needs ODE existence and
  uniqueness machinery.

## Phase status

Phase-1 — honest algebraic identities, machine-checked, kernel-only
`[propext, Classical.choice, Quot.sound]` axioms.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GelfandYaglomJacobi

noncomputable section

open Real

/-- Jacobi-field solution of `ψ'' + ω²·ψ = 0` with `ψ(0) = 0` and
    `ψ'(0) = 1`.  Defined piecewise so that the free-particle limit
    `ω → 0` is captured exactly:
      `gyJacobi 0 T = T`,
      `gyJacobi ω T = sinh(ω·T) / ω`        for `ω ≠ 0`. -/
def gyJacobi (ω T : ℝ) : ℝ :=
  if ω = 0 then T else Real.sinh (ω * T) / ω

/-- **Dirichlet boundary condition at the source endpoint**:
    the Jacobi field vanishes at `T = 0` (initial value `ψ(0) = 0`). -/
theorem gyJacobi_T_zero (ω : ℝ) :
    gyJacobi ω 0 = 0 := by
  unfold gyJacobi
  by_cases hω : ω = 0
  · simp [hω]
  · simp [hω]

/-- **Free-particle limit**: at `ω = 0` the Jacobi field is the
    identity in `T`, recovering the free-particle determinant ratio
    `det'(−∂²_t)/det'(−∂²_t) = T/T = 1`. -/
theorem gyJacobi_omega_zero (T : ℝ) :
    gyJacobi 0 T = T := by
  unfold gyJacobi
  simp

/-- **Parity symmetry** (sinh is odd): the Jacobi field is invariant
    under `ω ↦ −ω`, reflecting that the spectrum of `−∂² + ω²` depends
    only on `|ω|`. -/
theorem gyJacobi_neg_omega (ω T : ℝ) :
    gyJacobi (-ω) T = gyJacobi ω T := by
  unfold gyJacobi
  by_cases hω : ω = 0
  · simp [hω]
  · have hneg : -ω ≠ 0 := neg_ne_zero.mpr hω
    simp [hω, hneg, Real.sinh_neg, neg_mul, neg_div_neg_eq]

/-- **Multiplicative Gel'fand–Yaglom bridge**: for `ω ≠ 0`, the product
    `ω · ψ_ω(T)` recovers `sinh(ωT)`.  Combined with the free-particle
    Jacobi field `T`, this is the closed form behind the determinant
    ratio
      `det'(−∂² + ω²) / det'(−∂²)  =  ψ_ω(T) / T  =  sinh(ωT) / (ωT)`. -/
theorem omega_mul_gyJacobi_eq_sinh (ω T : ℝ) (hω : ω ≠ 0) :
    ω * gyJacobi ω T = Real.sinh (ω * T) := by
  unfold gyJacobi
  rw [if_neg hω]
  field_simp

end

end CATEPTMain.Integration.GelfandYaglomJacobi
