import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

/-!
# Oscillator-Kernel Bridge — Mehler Kernel (T-A Phase 1)

Phase 1 of the path-integral infrastructure ladder Target T-A —
oscillator kernels. The harmonic-oscillator Euclidean propagator is the
**Mehler kernel**

  `K(x,y;t)  =  N(m,ω,t) · exp ( S(m,ω,t,x,y) )`

with prefactor and exponent

  `N(m,ω,t)        =  √( m·ω / (2π · sinh(ωt)) )`
  `S(m,ω,t,x,y)   =  − m·ω / (2 sinh(ωt)) · ((x²+y²)·cosh(ωt) − 2xy)`.

This file pins three honest algebraic identities about the **exponent**
`S` and the **prefactor squared** `N²`, all proved with `ring` /
`field_simp` from the underlying `Real.sinh` / `Real.cosh` API. No
measure-theoretic, integration, or limiting-process content — that is
deferred (Phase 2: t→0 delta-function limit; Phase 3: Trotter
composition `K(t₁+t₂) = ∫ K(t₁) K(t₂)`).

## Identities discharged here

* `mehlerExponent_symm`            — S(x,y;t) = S(y,x;t).
* `mehlerExponent_at_diagonal`     — closed form of S at x=y.
* `mehlerPrefactorSq_pos`          — N² > 0 for m,ω,t > 0
                                    (PD prefactor on the Euclidean side).

## Phase status

Phase-1 — honest algebraic identities, machine-checked, kernel-only
`[propext, Classical.choice, Quot.sound]` axioms.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.OscillatorKernel

noncomputable section

/-- Mehler-kernel exponent (Euclidean harmonic-oscillator propagator),
    parametrised by mass `m`, frequency `ω`, Euclidean time `t`, and
    endpoints `x`, `y`:

      `S = − m·ω / (2 sinh(ωt)) · ((x²+y²)·cosh(ωt) − 2 x y)`. -/
def mehlerExponent (m ω t x y : ℝ) : ℝ :=
  - m * ω / (2 * Real.sinh (ω * t))
    * ((x^2 + y^2) * Real.cosh (ω * t) - 2 * x * y)

/-- Mehler-kernel prefactor *squared*:

      `N²  =  m·ω / (2π · sinh(ωt))`.

    Working with `N²` avoids square-root / nonneg side-conditions at the
    Phase-1 level; the actual prefactor is `Real.sqrt N²`. -/
def mehlerPrefactorSq (m ω t : ℝ) : ℝ :=
  m * ω / (2 * Real.pi * Real.sinh (ω * t))

/-- **Symmetry** of the Mehler exponent in the spatial endpoints. This
    is the algebraic reflection symmetry that makes the Euclidean
    propagator `K(x,y;t) = K(y,x;t)` — a necessary condition for
    self-adjointness of the oscillator semigroup. -/
theorem mehlerExponent_symm (m ω t x y : ℝ) :
    mehlerExponent m ω t x y = mehlerExponent m ω t y x := by
  unfold mehlerExponent
  ring

/-- **Closed form at the spatial diagonal** `x = y`. Substituting `y = x`
    collapses `(x² + y²)·cosh − 2xy` to `2x²·(cosh(ωt) − 1)`, giving

      `S(x,x;t)  =  − m·ω · x² · (cosh(ωt) − 1) / sinh(ωt)`.

    This is the form that shows up in the diagonal trace
    `Tr K(t) = ∫ K(x,x;t) dx` once the Gaussian integral is performed
    (deferred). -/
theorem mehlerExponent_at_diagonal (m ω t x : ℝ) :
    mehlerExponent m ω t x x
      = - m * ω * x^2 * (Real.cosh (ω * t) - 1) / Real.sinh (ω * t) := by
  unfold mehlerExponent
  field_simp
  ring

/-- **Prefactor positivity** on the Euclidean side: for positive mass,
    frequency, and Euclidean time, the squared prefactor `N²` is strictly
    positive. Uses `Real.sinh_pos` for `0 < ωt`. -/
theorem mehlerPrefactorSq_pos
    {m ω t : ℝ} (hm : 0 < m) (hω : 0 < ω) (ht : 0 < t) :
    0 < mehlerPrefactorSq m ω t := by
  unfold mehlerPrefactorSq
  have hωt : 0 < ω * t := mul_pos hω ht
  have hsinh : 0 < Real.sinh (ω * t) := Real.sinh_pos_iff.mpr hωt
  have hpi : 0 < Real.pi := Real.pi_pos
  have hden : 0 < 2 * Real.pi * Real.sinh (ω * t) := by positivity
  have hnum : 0 < m * ω := mul_pos hm hω
  exact div_pos hnum hden

end

end CATEPTMain.Integration.OscillatorKernel
