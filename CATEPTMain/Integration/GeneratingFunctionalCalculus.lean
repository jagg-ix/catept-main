import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Complex.Log
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

/-!
# Generating-Functional / Source-Term Calculus Bridge (Phase 1, T-B)

Phase 1 of the path-integral infrastructure ladder Stage 5 — the
algebraic content of the Gaussian generating functional `Z[J]`.

This file does not construct the path measure (Minlos extension to a
nuclear space is deferred — `kolmogorov_extension4` is not pinned in
catept-main). It instead pins the *closed-form algebraic identity* that
Mathlib already proves for any Gaussian random variable
(`HasGaussianLaw.charFun_map_real`):

    Z[J]  =  E[exp (i·J·X)]  =  exp (i·J·μ − ½·J²·σ²)

and discharges three honest kernel-only-axiom identities about this
closed form:

* `gaussianCharFun_at_zero`             — Z[0] = 1 normalization.
* `gaussianCharFun_centered`            — μ = 0 ⇒ Z[J] = exp(−½ J² σ²).
* `gaussianCharFun_independence_semigroup`
    — Z₁[J]·Z₂[J] = Z₁₊₂[J] for independent Gaussians (W[J] = log Z[J]
      additivity at the algebraic level).

## Stages NOT discharged here (require new infrastructure)

* The Mathlib bridge `gaussianCharFun = HasGaussianLaw.charFun_map_real`
  is omitted to keep this file self-contained at the algebraic level.
  Promoting one of the theorems below to use the random-variable side
  is mechanical (a `rw` against the Mathlib lemma) and is queued as a
  Phase-1.5 follow-up.
* Multi-point correlator enumeration (`δⁿZ/δJⁿ`, Wick contractions for
  n ≥ 3) needs Feynman-diagram combinatorics (T-C, deferred).
* Minlos extension to nuclear-space white-noise field measures needs
  `kolmogorov_extension4` pinned + a sibling plugin (Phase 2).

## Phase status

Phase-1 — honest algebraic identities, machine-checked, kernel-only
`[propext, Classical.choice, Quot.sound]` axioms.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GeneratingFunctionalCalculus

noncomputable section

open Complex

/-- Closed form of the Gaussian generating functional with mean `μ`,
    variance `σ²`, evaluated at source `J`:
      `Z[J]  =  exp (i·J·μ  −  ½·J²·σ²)`.
    Matches the Mathlib lemma
    `ProbabilityTheory.HasGaussianLaw.charFun_map_real` for any real
    Gaussian random variable `X` with `μ = E[X]`, `σ² = Var[X]`. -/
def gaussianCharFun (μ σSq J : ℝ) : ℂ :=
  Complex.exp ((J * μ : ℝ) * Complex.I - ((J^2 * σSq) / 2 : ℝ))

/-- `Z[0] = 1` — normalization of the generating functional at zero source. -/
theorem gaussianCharFun_at_zero (μ σSq : ℝ) :
    gaussianCharFun μ σSq 0 = 1 := by
  simp [gaussianCharFun]

/-- Centered Gaussian (mean zero) generating functional has the canonical
    quadratic form `Z[J] = exp(−½ J² σ²)`. -/
theorem gaussianCharFun_centered (σSq J : ℝ) :
    gaussianCharFun 0 σSq J = Complex.exp (-((J^2 * σSq) / 2 : ℝ)) := by
  simp [gaussianCharFun]

/-- **Independence semigroup law** for Gaussian generating functionals.

    For two independent Gaussian random variables
    `X ~ N(μ₁, σ₁²)` and `Y ~ N(μ₂, σ₂²)`, the sum is
    `X + Y ~ N(μ₁ + μ₂, σ₁² + σ₂²)`, so

      `Z[X][J] · Z[Y][J]  =  Z[X+Y][J]`.

    Equivalently `W[J] = log Z[J]` is additive over independent
    contributions — the algebraic content of the connected generating
    functional. This identity holds at the level of the closed form
    `gaussianCharFun` and does not invoke any measure-theoretic
    independence argument. -/
theorem gaussianCharFun_independence_semigroup
    (μ₁ σSq₁ μ₂ σSq₂ J : ℝ) :
    gaussianCharFun μ₁ σSq₁ J * gaussianCharFun μ₂ σSq₂ J
      = gaussianCharFun (μ₁ + μ₂) (σSq₁ + σSq₂) J := by
  unfold gaussianCharFun
  rw [← Complex.exp_add]
  congr 1
  push_cast
  ring

end

end CATEPTMain.Integration.GeneratingFunctionalCalculus
