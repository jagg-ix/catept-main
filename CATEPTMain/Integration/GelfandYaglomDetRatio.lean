import CATEPTMain.Integration.GelfandYaglomJacobi
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Gel'fand–Yaglom Determinant Ratio (T-FF Phase 3)

Phase-3 honest content: package the Phase-1/Phase-2 Jacobi-field
machinery into the **Gel'fand–Yaglom determinant-ratio identity**

  `det'(−∂²_t + ω²) / det'(−∂²_t)  =  ψ_ω(T) / T  =  sinh(ω T) / (ω T)`

at the level of the algebraic Jacobi quotient.  Concretely we expose
`gyDetRatio ω T := gyJacobi ω T / T` and prove the closed-form
identification, free-particle limit, and parity symmetry.

The point of Phase-3 is that on the algebraic side, the determinant
ratio is now a single function `(ω, T) ↦ gyDetRatio ω T` whose value
at `ω = 0` is `1` (free-particle baseline) and whose value at any
other `ω` is exactly the celebrated `sinh(ω T)/(ω T)`.  This is the
ratio identity Coleman–Callan and Gel'fand–Yaglom both invoke.

## Stages NOT discharged here (Phase-4+)

* Asymptotic regimes of the ratio (small `ω`, large `T`) — covered
  in companion module `GelfandYaglomAsymptotics`.
* Spectral-zeta side: the equality of `gyDetRatio` to the actual
  `exp(−ζ'_{−∂²+ω²}(0) + ζ'_{−∂²}(0))` — needs spectral zeta theory.
* Generalisation to a `T·V` smooth potential and the dependence on
  `V` via the Jacobi ODE flow — needs ODE existence/uniqueness.

## Phase status

Phase-3 — honest determinant-ratio identity at the Jacobi-quotient
level, machine-checked, kernel-only `[propext, Classical.choice,
Quot.sound]` axioms.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GelfandYaglomDetRatio

open CATEPTMain.Integration.GelfandYaglomJacobi

noncomputable section

/-- **Gel'fand–Yaglom determinant ratio** at the Jacobi-quotient level:
    `gyDetRatio ω T := ψ_ω(T) / T`, the value playing the role of
    `det'(−∂² + ω²) / det'(−∂²)` once the spectral-zeta identification
    is in place. -/
def gyDetRatio (ω T : ℝ) : ℝ := gyJacobi ω T / T

/-- **Free-particle baseline**: at `ω = 0` the determinant ratio is
    identically `1` for every `T ≠ 0`, since `ψ_0(T) = T`. -/
theorem gyDetRatio_omega_zero (T : ℝ) (hT : T ≠ 0) :
    gyDetRatio 0 T = 1 := by
  unfold gyDetRatio
  rw [gyJacobi_omega_zero]
  exact div_self hT

/-- **Closed-form Gel'fand–Yaglom identity**: for `ω ≠ 0` and `T ≠ 0`,
    the determinant ratio equals the celebrated `sinh(ω T) / (ω T)`. -/
theorem gyDetRatio_eq_sinh_form (ω T : ℝ) (hω : ω ≠ 0) (hT : T ≠ 0) :
    gyDetRatio ω T = Real.sinh (ω * T) / (ω * T) := by
  unfold gyDetRatio gyJacobi
  rw [if_neg hω]
  field_simp

/-- **Parity symmetry** `ω ↦ −ω`: the determinant ratio depends only
    on `|ω|`, since the spectrum of `−∂² + ω²` does. -/
theorem gyDetRatio_neg_omega (ω T : ℝ) :
    gyDetRatio (-ω) T = gyDetRatio ω T := by
  unfold gyDetRatio
  rw [gyJacobi_neg_omega]

/-- **Source-endpoint degeneracy**: at `T = 0` the ratio
    `ψ_ω(0)/0 = 0/0` is set to `0` by Lean's division convention, a
    harmless degeneracy outside the physical regime `T > 0`. -/
theorem gyDetRatio_T_zero (ω : ℝ) :
    gyDetRatio ω 0 = 0 := by
  unfold gyDetRatio
  rw [gyJacobi_T_zero]
  simp

end

end CATEPTMain.Integration.GelfandYaglomDetRatio
