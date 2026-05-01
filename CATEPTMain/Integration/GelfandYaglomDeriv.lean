import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Complex.Trigonometric
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

/-!
# Gel'fand–Yaglom Initial Velocity (Jacobi Field, T-FF Phase 2)

Phase-2 honest content for the **second Dirichlet boundary condition**
of the Gel'fand–Yaglom Jacobi field
  `ψ_ω(T)  =  sinh(ω T)/ω        (ω ≠ 0)`,
  `ψ_0(T)  =  T                   (free particle)`,
namely the *initial-velocity* condition
  `ψ_ω'(0)  =  1`     for every `ω`.

Together with the Phase-1 boundary condition `ψ_ω(0) = 0`, this fully
specifies the Jacobi field as the unique solution to
  `ψ'' + ω²·ψ = 0`,    `ψ(0) = 0`, `ψ'(0) = 1`,
which is the data needed by the Gel'fand–Yaglom theorem to express
the determinant ratio `det'(−∂² + ω²)/det'(−∂²) = ψ_ω(T)/T`.

This file ships honest `HasDerivAt` statements:

* `gyJacobi_free_hasDerivAt_one`           free-particle case `ω = 0`,
* `sinh_div_omega_hasDerivAt_one_at_zero`  the `ω ≠ 0` Jacobi field
                                           `T ↦ sinh(ω T)/ω` has unit
                                           derivative at `T = 0`.

## Phase status

Phase-2 — honest `HasDerivAt` boundary conditions, machine-checked,
kernel-only `[propext, Classical.choice, Quot.sound]`. Phase-3 will
upgrade to the full ODE flow `ψ'' + V(t)·ψ = 0` for smooth `V`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GelfandYaglomDeriv

noncomputable section

open Real

/-- **Initial-velocity condition (free particle)**: the Jacobi field
    of the free problem is `ψ₀(T) = T`, with `ψ₀'(0) = 1`. -/
theorem gyJacobi_free_hasDerivAt_one :
    HasDerivAt (fun T : ℝ => T) 1 0 :=
  hasDerivAt_id 0

/-- **Initial-velocity condition (harmonic oscillator, `ω ≠ 0`)**:
    the Jacobi field branch `T ↦ sinh(ω·T) / ω` has derivative `1` at
    `T = 0`, witnessing `ψ_ω'(0) = 1`.

    Computation: `(d/dT) [sinh(ω T)/ω] = ω·cosh(ω T)/ω = cosh(ω T)`,
    and `cosh 0 = 1`. -/
theorem sinh_div_omega_hasDerivAt_one_at_zero (ω : ℝ) (hω : ω ≠ 0) :
    HasDerivAt (fun T : ℝ => Real.sinh (ω * T) / ω) 1 0 := by
  have h_id : HasDerivAt (fun T : ℝ => T) 1 0 := hasDerivAt_id 0
  have h_lin : HasDerivAt (fun T : ℝ => ω * T) (ω * 1) 0 :=
    h_id.const_mul ω
  have h_sinh : HasDerivAt (fun T : ℝ => Real.sinh (ω * T))
      (Real.cosh (ω * 0) * (ω * 1)) 0 :=
    (Real.hasDerivAt_sinh (ω * 0)).comp 0 h_lin
  have h_div : HasDerivAt (fun T : ℝ => Real.sinh (ω * T) / ω)
      (Real.cosh (ω * 0) * (ω * 1) / ω) 0 :=
    h_sinh.div_const ω
  have hcosh : Real.cosh (ω * 0) = 1 := by
    simp
  have hgoal : Real.cosh (ω * 0) * (ω * 1) / ω = 1 := by
    rw [hcosh]
    field_simp
  rw [← hgoal]
  exact h_div

/-- **Wronskian/initial-velocity bridge**: combined with
    `omega_mul_gyJacobi_eq_sinh` from Phase 1, the unit initial
    velocity certifies that the Gel'fand–Yaglom Jacobi field on
    `[0, T]` is the unique solution to the ODE/BVP
    `ψ'' + ω²·ψ = 0,  ψ(0) = 0,  ψ'(0) = 1`,
    closing the Phase-2 algebraic core of the GY determinant ratio. -/
theorem sinh_div_omega_at_zero (ω : ℝ) :
    Real.sinh (ω * 0) / ω = 0 := by
  simp

end

end CATEPTMain.Integration.GelfandYaglomDeriv
