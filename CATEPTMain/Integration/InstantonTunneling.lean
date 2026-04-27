import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# Instanton / Tunneling Amplitude Algebra (T-D Phase 1)

Phase 1 of Target T-D (instanton / det' machinery). Honest algebraic
content of the **dilute instanton gas** at the level of the
exponential suppression factor — the place where instanton physics
first becomes sharp.

The classical **BPST instanton action** for an SU(2) Yang–Mills
self-dual configuration of unit topological charge is

  `S_inst(g)  =  8 · π² / g²`,

and the leading-order tunneling amplitude is the WKB-like
exponential

  `A(S)  =  exp(-S)`.

In the dilute-gas approximation, n-instanton configurations are
non-interacting, so their amplitudes multiply.  This file pins
three honest algebraic identities on these closed forms — all
proved by `simp` / `Real.exp_add` from underlying arithmetic, no
path-integral machinery:

* `tunnelAmplitude_at_zero`          — `A(0) = 1`  (trivial sector).
* `tunnelAmplitude_compose`          — `A(S₁+S₂) = A(S₁)·A(S₂)`
  (n-instanton dilute-gas product law).
* `instantonBPSTAction_pos`          — strict positivity of the
  BPST action for `g ≠ 0`.

## Stages NOT discharged here (require new infrastructure)

* The Gel'fand–Yaglom functional determinant ratio
  `det'(-∂² + V''(φ_cl)) / det(-∂² + ω²)` — needs spectral theory of
  Schrödinger operators on `ℝ` and quotient out of zero modes.
* The bounce theorem (Coleman–Callan): tunneling decay rate
  `Γ/V = (S_inst/2π)^{n/2} · |det'|^{-1/2} · exp(-S_inst) · (1+O(ℏ))`.
* Topological-charge integrality `(1/8π²)∫ tr F∧F ∈ ℤ` (requires a
  4-form integration framework).

## Phase status

Phase-1 — honest algebraic identities, machine-checked, kernel-only
`[propext, Classical.choice, Quot.sound]` axioms.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.InstantonTunneling

noncomputable section

/-- BPST instanton action: `S_inst(g) = 8 · π² / g²` for the unit-charge
    self-dual SU(2) Yang–Mills configuration. -/
def instantonBPSTAction (g : ℝ) : ℝ :=
  8 * Real.pi ^ 2 / g ^ 2

/-- Leading-order tunneling amplitude: `A(S) = exp(-S)`. -/
def tunnelAmplitude (S : ℝ) : ℝ :=
  Real.exp (-S)

/-- **Trivial sector**: vanishing instanton action gives no
    suppression, `A(0) = 1`. -/
theorem tunnelAmplitude_at_zero :
    tunnelAmplitude 0 = 1 := by
  simp [tunnelAmplitude]

/-- **Dilute-gas composition law** (n-instanton product rule).

    Two non-interacting instanton sectors of actions `S₁` and `S₂`
    give a combined tunneling amplitude that *factorises*:

      `A(S₁ + S₂)  =  A(S₁) · A(S₂)`.

    This is the algebraic core of the dilute-instanton-gas
    approximation; physically it expresses that widely-separated
    instantons contribute independently to the partition sum. -/
theorem tunnelAmplitude_compose (S₁ S₂ : ℝ) :
    tunnelAmplitude (S₁ + S₂) = tunnelAmplitude S₁ * tunnelAmplitude S₂ := by
  unfold tunnelAmplitude
  rw [show -(S₁ + S₂) = (-S₁) + (-S₂) by ring, Real.exp_add]

/-- **Positivity**: for any non-zero gauge coupling the BPST action
    is strictly positive, so the tunneling amplitude is strictly
    less than one (genuine exponential suppression). -/
theorem instantonBPSTAction_pos {g : ℝ} (hg : g ≠ 0) :
    0 < instantonBPSTAction g := by
  unfold instantonBPSTAction
  have hg2 : 0 < g ^ 2 := by positivity
  have hpi2 : 0 < Real.pi ^ 2 := by positivity
  positivity

end

end CATEPTMain.Integration.InstantonTunneling
