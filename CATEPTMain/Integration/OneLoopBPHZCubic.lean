import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Pow

/-!
# One-Loop Vacuum Polarisation — Cubic BPHZ-3 On-Shell Subtraction (T-EE Phase 2)

Phase-2 honest content for **higher-order BPHZ subtraction**: a cubic
self-energy
  `Σ₃(p)  =  c₀ + c₁·p + c₂·p² + c₃·p³`
is on-shell-renormalised at scale `p₀` by *three* BPHZ subtractions
(Taylor truncation through second order):
  `Σ₃_R(p)  :=  Σ₃(p) − Σ₃(p₀) − (p − p₀)·Σ₃'(p₀)
                            − ½(p − p₀)²·Σ₃''(p₀)`.

This module proves that the resulting renormalised cubic self-energy
collapses to the closed cubic remainder `c₃·(p − p₀)³` and verifies
the three defining BPHZ on-shell conditions
  `Σ₃_R(p₀)  =  0`,
  `Σ₃_R'(p₀) =  0`,
and (implicitly via the closed form) `Σ₃_R''(p₀) = 0`.

Phase-1 (`OneLoopBPHZOnShell.lean`) handled the quadratic self-energy
with two subtractions; this Phase-2 module shows that the BPHZ
prescription extends to higher orders by Taylor remainder, the algebraic
ingredient of the Bogoliubov R-operation.

## Stages NOT discharged here (require new infrastructure)

* The forest formula for overlapping divergences (multi-loop graphs)
  — needs the H_FG antipode (T-DD Phase 3 graph-valued lift).
* The renormalisation scheme for general dimension `D` — needs
  dimensional regularisation infrastructure.

## Phase status

Phase-2 — honest algebraic identities and one `HasDerivAt`,
machine-checked, kernel-only `[propext, Classical.choice, Quot.sound]`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.OneLoopBPHZCubic

noncomputable section

/-- Cubic self-energy `Σ₃(p) = c₀ + c₁·p + c₂·p² + c₃·p³`. -/
def cubicSelfEnergy (c₀ c₁ c₂ c₃ p : ℝ) : ℝ :=
  c₀ + c₁ * p + c₂ * p ^ 2 + c₃ * p ^ 3

/-- BPHZ-3 on-shell remainder: the closed cubic `c₃·(p − p₀)³` left
    after three Taylor subtractions of `cubicSelfEnergy` at `p₀`. -/
def bphz3OnShellRemainder (c₃ p₀ p : ℝ) : ℝ :=
  c₃ * (p - p₀) ^ 3

/-- **Mass-renormalisation (BPHZ-3)**: the cubic on-shell remainder
    vanishes at the subtraction point. -/
theorem bphz3OnShellRemainder_at_subtraction (c₃ p₀ : ℝ) :
    bphz3OnShellRemainder c₃ p₀ p₀ = 0 := by
  simp [bphz3OnShellRemainder]

/-- **Wave-function-renormalisation (BPHZ-3)**: the cubic on-shell
    remainder has vanishing derivative at the subtraction point.
    Genuine `HasDerivAt` statement: `(d/dp) [c₃·(p − p₀)³]|_{p = p₀} = 0`. -/
theorem bphz3OnShellRemainder_hasDerivAt_zero (c₃ p₀ : ℝ) :
    HasDerivAt (bphz3OnShellRemainder c₃ p₀) 0 p₀ := by
  unfold bphz3OnShellRemainder
  have h1 : HasDerivAt (fun p : ℝ => p - p₀) 1 p₀ := by
    simpa using (hasDerivAt_id p₀).sub_const p₀
  have h2 : HasDerivAt (fun p : ℝ => (p - p₀) ^ 3)
      (3 * (p₀ - p₀) ^ 2 * 1) p₀ := h1.pow 3
  have h3 : HasDerivAt (fun p : ℝ => c₃ * (p - p₀) ^ 3)
      (c₃ * (3 * (p₀ - p₀) ^ 2 * 1)) p₀ := h2.const_mul c₃
  convert h3 using 1
  ring

/-- **Closed-form identification** (BPHZ-3): three Taylor subtractions
    at `p₀` (subtracting value, first derivative `c₁ + 2 c₂ p₀ + 3 c₃ p₀²`,
    and one-half second derivative `c₂ + 3 c₃ p₀`) collapse the cubic
    self-energy to the on-shell remainder `c₃·(p − p₀)³`. -/
theorem cubicSelfEnergy_bphz_eq_onShellRemainder
    (c₀ c₁ c₂ c₃ p₀ p : ℝ) :
    cubicSelfEnergy c₀ c₁ c₂ c₃ p
        - cubicSelfEnergy c₀ c₁ c₂ c₃ p₀
        - (p - p₀) * (c₁ + 2 * c₂ * p₀ + 3 * c₃ * p₀ ^ 2)
        - (p - p₀) ^ 2 * (c₂ + 3 * c₃ * p₀)
      = bphz3OnShellRemainder c₃ p₀ p := by
  unfold cubicSelfEnergy bphz3OnShellRemainder
  ring

end

end CATEPTMain.Integration.OneLoopBPHZCubic
