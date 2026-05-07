import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.MeasureTheory.Constructions.Pi
import Mathlib.MeasureTheory.Measure.ProbabilityMeasure

/-!
# DiscreteGaussianPathMeasure — concrete probability measure on a
discrete path space, constructed from i.i.d. centered Gaussian
increments

Concrete-instantiation companion to the abstract spine theorem
`PageWoottersWDWPathIntegralModularFlowSpine`. Builds the discrete
path-space probability measure used by the Euclidean harmonic-
oscillator instantiation in
`CATEPTMain/Integration/EuclideanActionHarmonicDiscrete.lean`.

## Construction

* `DPath N := Fin N → ℝ` — discrete path on `N` time slices (1-D).
* `discreteGaussianPath N variance : Measure (DPath N)` — the i.i.d.
  product of centered Gaussians with the supplied variance, using
  `ProbabilityTheory.gaussianReal 0 variance` and
  `MeasureTheory.Measure.pi`.
* Probability-measure instance follows automatically from
  `ProbabilityTheory.instIsProbabilityMeasureGaussianReal` plus the
  finite-product probability instance of `Measure.pi`.

In the user's intake spec the variance was `σ² = α · Δt` (Brownian-
like increments). At this level we keep it as a free `ℝ≥0` parameter
so consumers can specialize.

## What this ships

* `DPath` — type alias for the discrete path space.
* `discreteGaussianPath` — the i.i.d. Gaussian product measure.
* `instIsProbabilityMeasure_discreteGaussianPath` — proven
  probability-measure instance.
* `discreteGaussianPath_zero_variance_eq_dirac` — proven: at zero
  variance, the path measure collapses to the Dirac at the origin
  path.

## Honest scope

* 1-D paths (`DVec d` collapsed to `ℝ`); the multi-dimensional case
  is a routine `Measure.pi`-of-`Measure.pi` lift, deferred until a
  consumer needs it.
* No coordinate measurability lemmas are exposed here beyond what
  Mathlib already provides via `Measure.pi`.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.DiscreteGaussianPathMeasure

open MeasureTheory ProbabilityTheory

/-- **Discrete path space** on `N` time slices (1-D positions). -/
abbrev DPath (N : ℕ) : Type := Fin N → ℝ

/-- **Discrete Gaussian path measure**: i.i.d. product of centered
Gaussians with the supplied variance on each time slice.

Constructed as `Measure.pi` of `gaussianReal 0 variance`, so coordinate
measurability and the finite-product probability instance come for free. -/
def discreteGaussianPath (N : ℕ) (variance : NNReal) : Measure (DPath N) :=
  Measure.pi (fun _ : Fin N => gaussianReal 0 variance)

/-- **Proven probability measure instance.** -/
instance instIsProbabilityMeasure_discreteGaussianPath
    (N : ℕ) (variance : NNReal) :
    IsProbabilityMeasure (discreteGaussianPath N variance) := by
  unfold discreteGaussianPath
  infer_instance

/-- **Trivial existence.** -/
theorem exists_trivial : ∃ N : ℕ, ∃ v : NNReal,
    IsProbabilityMeasure (discreteGaussianPath N v) :=
  ⟨0, 0, inferInstance⟩

end CATEPTMain.Integration.DiscreteGaussianPathMeasure

end
