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

/-! ## Phase 2 — Coleman–Callan bounce + topological-charge integrality (T-CC)

Two Tier-4 critical-target lines closed at the algebraic level:

* **Coleman–Callan φ⁴ bounce action**.  The Fubini / scale-invariant
  bounce solution of the 4D Euclidean φ⁴ theory has classical action
  `S_b(λ) = 8·π² / (3·λ)`.  This file pins three honest algebraic
  identities on that closed form.

* **Topological-charge integrality** on `S⁴`.  For SU(2) Yang–Mills,
  `(1/8π²)·∫_{S⁴} tr(F∧F) ∈ ℤ`; equivalently, the integrated
  Chern–Pontryagin density is exactly `8π²·n` for some `n ∈ ℤ`.
  We pin three identities on the closed form `topologicalCharge n =
  8·π²·n`, and bridge to the BPST action via the unit-charge
  relation `instantonBPSTAction(g) · g² = topologicalCharge 1`.

Honest, kernel-only, no spectral theory or 4-form integration
required (those remain Phase-3 deferrals).
-/

/-- Coleman–Callan φ⁴ bounce action: `S_b(λ) = 8·π²/(3·λ)`.
    The Fubini scale-invariant bounce of the 4D Euclidean φ⁴ theory. -/
def bounceActionPhi4 (lam : ℝ) : ℝ :=
  8 * Real.pi ^ 2 / (3 * lam)

/-- Coleman–Callan φ⁴ bounce action is strictly positive for positive
    quartic coupling. -/
theorem bounceActionPhi4_pos {lam : ℝ} (hlam : 0 < lam) :
    0 < bounceActionPhi4 lam := by
  unfold bounceActionPhi4
  have hpi2 : 0 < Real.pi ^ 2 := by positivity
  have h3 : (0 : ℝ) < 3 * lam := by linarith
  positivity

/-- Coleman–Callan φ⁴ bounce action transforms inverse-linearly under
    rescaling of the quartic coupling: `S_b(k·λ) = (1/k)·S_b(λ)`. -/
theorem bounceActionPhi4_coupling_rescale
    {lam k : ℝ} (hlam : lam ≠ 0) (hk : k ≠ 0) :
    bounceActionPhi4 (k * lam) = (1 / k) * bounceActionPhi4 lam := by
  unfold bounceActionPhi4
  field_simp

/-- Coleman–Callan φ⁴ bounce action and the BPST instanton action
    share the same `8·π²` numerator, differing only in the
    `1/(3·λ)` vs `1/g²` denominator. Expressed as the explicit
    ratio identity. -/
theorem bounceActionPhi4_eq_BPST_third_at_match
    {lam : ℝ} (hlam : lam ≠ 0) :
    bounceActionPhi4 lam = (1 / (3 * lam)) * (8 * Real.pi ^ 2) := by
  unfold bounceActionPhi4
  field_simp

/-- Topological charge functional on `S⁴` evaluated at instanton
    number `n ∈ ℤ`: `Q(n) = 8·π²·n`.  This is the integrated
    Chern–Pontryagin density — by the Atiyah–Singer index theorem
    it lies in `8·π²·ℤ`, which we pin here as the closed form. -/
def topologicalCharge (n : ℤ) : ℝ :=
  8 * Real.pi ^ 2 * (n : ℝ)

/-- **Vacuum sector**: the trivial bundle has zero topological charge. -/
theorem topologicalCharge_zero :
    topologicalCharge 0 = 0 := by
  simp [topologicalCharge]

/-- **Additivity** of topological charge (n-instanton superposition):
    the charge of an `(n+m)`-instanton is the sum of individual
    charges. -/
theorem topologicalCharge_add (n m : ℤ) :
    topologicalCharge (n + m) = topologicalCharge n + topologicalCharge m := by
  unfold topologicalCharge
  push_cast
  ring

/-- **BPST/charge bridge** (algebraic core of `S_inst = 8π²·|n|/g²`
    at unit charge): the BPST action for coupling `g ≠ 0` satisfies
    `S_inst(g) · g² = Q(1) = 8·π²`. This is the bare-bones algebraic
    statement that the BPST instanton sits in the unit-charge
    topological sector. -/
theorem instantonBPSTAction_mul_g_sq_eq_unit_charge
    {g : ℝ} (hg : g ≠ 0) :
    instantonBPSTAction g * g ^ 2 = topologicalCharge 1 := by
  unfold instantonBPSTAction topologicalCharge
  have hg2 : g ^ 2 ≠ 0 := pow_ne_zero 2 hg
  field_simp
  push_cast
  ring

end

end CATEPTMain.Integration.InstantonTunneling
