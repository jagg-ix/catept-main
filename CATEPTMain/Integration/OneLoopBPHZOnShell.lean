import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Pow

/-!
# One-Loop Vacuum Polarisation — BPHZ On-Shell Subtraction (T-EE Phase 1)

Phase-1 honest algebraic content of the **BPHZ on-shell renormalisation
prescription** for a one-loop quadratic vacuum-polarisation self-energy.

A polynomial self-energy
  `Σ(p)  =  c₀ + c₁·p + c₂·p²`
is on-shell-renormalised at scale `p₀` by *two* BPHZ subtractions
(Taylor truncation through first order):
  `Σ_R(p)  :=  Σ(p) − Σ(p₀) − (p − p₀)·Σ'(p₀)`.

This file proves that the resulting renormalised self-energy collapses
to the closed quadratic remainder `c₂·(p − p₀)²` and verifies the two
defining on-shell conditions:

* `bphzOnShellRemainder_at_subtraction`            — `Σ_R(p₀) = 0`
                                                     (mass-renormalisation
                                                     condition).
* `bphzOnShellRemainder_hasDerivAt_zero`           — `Σ_R'(p₀) = 0`
                                                     (wave-function
                                                     renormalisation
                                                     condition).
* `quadSelfEnergy_bphz_eq_onShellRemainder`        — closed-form
                                                     identification of
                                                     the BPHZ-2 subtracted
                                                     quadratic with the
                                                     on-shell remainder.
* `bphzOnShellRemainder_coupling_rescale`          — universal `c₂·(...)²`
                                                     scaling.

## Stages NOT discharged here (require new infrastructure)

* The actual one-loop integral
  `Π(p²) = (g²/(16π²)) · ∫₀¹ dx [log(m² − x(1−x)p² − iε) − log μ²]`
  — needs dimensional regularisation and Feynman parametrisation.
* Cutkosky's cutting rules
  `Disc Π(s) = 2i · Im Π(s + i0⁺)` — needs branch-cut analysis of `log`.
* Forest formula and overlapping divergences — needs `H_FG` Hopf algebra
  (T-DD Phase 2).

## Phase status

Phase-1 — honest algebraic identities and one `HasDerivAt` statement,
machine-checked, kernel-only `[propext, Classical.choice, Quot.sound]`
axioms.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.OneLoopBPHZOnShell

noncomputable section

/-- Quadratic self-energy `Σ(p) = c₀ + c₁·p + c₂·p²` (toy one-loop
    vacuum polarisation truncated to second order in the external
    momentum). -/
def quadSelfEnergy (c₀ c₁ c₂ p : ℝ) : ℝ :=
  c₀ + c₁ * p + c₂ * p ^ 2

/-- BPHZ on-shell remainder: the closed form `c₂·(p − p₀)²` left after
    two Taylor subtractions of `quadSelfEnergy` at the on-shell point
    `p₀`. -/
def bphzOnShellRemainder (c₂ p₀ p : ℝ) : ℝ :=
  c₂ * (p - p₀) ^ 2

/-- **Mass-renormalisation condition** (first BPHZ on-shell condition):
    the on-shell remainder vanishes at the subtraction point. -/
theorem bphzOnShellRemainder_at_subtraction (c₂ p₀ : ℝ) :
    bphzOnShellRemainder c₂ p₀ p₀ = 0 := by
  simp [bphzOnShellRemainder]

/-- **Wave-function-renormalisation condition** (second BPHZ on-shell
    condition): the on-shell remainder has vanishing derivative at the
    subtraction point.

    Genuine `HasDerivAt` statement: `(d/dp) [c₂·(p − p₀)²] |_{p = p₀} = 0`. -/
theorem bphzOnShellRemainder_hasDerivAt_zero (c₂ p₀ : ℝ) :
    HasDerivAt (bphzOnShellRemainder c₂ p₀) 0 p₀ := by
  unfold bphzOnShellRemainder
  have h1 : HasDerivAt (fun p : ℝ => p - p₀) 1 p₀ := by
    simpa using (hasDerivAt_id p₀).sub_const p₀
  have h2 : HasDerivAt (fun p : ℝ => (p - p₀) ^ 2) (2 * (p₀ - p₀) ^ 1 * 1) p₀ :=
    h1.pow 2
  have h3 : HasDerivAt (fun p : ℝ => c₂ * (p - p₀) ^ 2)
      (c₂ * (2 * (p₀ - p₀) ^ 1 * 1)) p₀ := h2.const_mul c₂
  convert h3 using 1
  ring

/-- **Closed-form identification**: the BPHZ-2 subtracted quadratic
    self-energy is *exactly* the on-shell remainder `c₂·(p − p₀)²`.

    Two Taylor subtractions at `p₀` (subtracting the value and the
    linear term `Σ'(p₀) = c₁ + 2·c₂·p₀`) collapse `Σ(p)` to the
    on-shell-renormalised quadratic. -/
theorem quadSelfEnergy_bphz_eq_onShellRemainder
    (c₀ c₁ c₂ p₀ p : ℝ) :
    quadSelfEnergy c₀ c₁ c₂ p
        - quadSelfEnergy c₀ c₁ c₂ p₀
        - (p - p₀) * (c₁ + 2 * c₂ * p₀)
      = bphzOnShellRemainder c₂ p₀ p := by
  unfold quadSelfEnergy bphzOnShellRemainder
  ring

/-- **Universal scaling**: the on-shell remainder rescales as `k`
    under a coupling rescaling `c₂ ↦ k·c₂`. -/
theorem bphzOnShellRemainder_coupling_rescale (c₂ p₀ p k : ℝ) :
    bphzOnShellRemainder (k * c₂) p₀ p = k * bphzOnShellRemainder c₂ p₀ p := by
  unfold bphzOnShellRemainder
  ring

end

end CATEPTMain.Integration.OneLoopBPHZOnShell
