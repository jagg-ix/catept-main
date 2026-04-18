import Mathlib.MeasureTheory.Measure.MeasureSpace
import Mathlib.MeasureTheory.Kernel.Basic

namespace MarkovSemigroups

open MeasureTheory

/-- A Markov kernel on a measurable space X. -/
structure MarkovKernel (X : Type*) [MeasurableSpace X] where
  kernel : X → Set X → ENNReal
  -- Add basic requirements of a Markov kernel if needed, but for a stub we keep it simple

/-- Doeblin's condition for a Markov kernel K and a reference measure μ. -/
structure DoeblinCondition {X : Type*} [MeasurableSpace X] (K : MarkovKernel X) (μ : Measure X) where
  ε : ℝ
  ε_pos : 0 < ε
  ε_le_one : ε ≤ 1
  minorization : ∀ (x : X) (A : Set X), MeasurableSet A →
    ε * (μ A).toReal ≤ (K.kernel x A).toReal

end MarkovSemigroups
