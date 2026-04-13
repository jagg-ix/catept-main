import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 106

Unified Lean4 model skeleton for the physics of time-arrow emergence.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G106

structure rowG106ArrowState where
  entropyRate : ℝ
  informationFlux : ℝ
  coupling : ℝ
  baseline : ℝ

/-- Arrow intensity from entropy-information coupling. -/
def rowG106ArrowIntensity (s : rowG106ArrowState) : ℝ :=
  s.baseline + s.coupling * s.entropyRate * s.informationFlux

/-- Monotone in entropy rate for nonnegative coupling and information flux. -/
theorem rowG106_mono_entropy
    (b c i e1 e2 : ℝ)
    (hc : 0 ≤ c)
    (hi : 0 ≤ i)
    (he : e1 ≤ e2) :
    rowG106ArrowIntensity
      { baseline := b, coupling := c, entropyRate := e1, informationFlux := i } ≤
    rowG106ArrowIntensity
      { baseline := b, coupling := c, entropyRate := e2, informationFlux := i } := by
  have hci : 0 ≤ c * i := mul_nonneg hc hi
  have hmul' : (c * i) * e1 ≤ (c * i) * e2 :=
    mul_le_mul_of_nonneg_left he hci
  have hmul : c * e1 * i ≤ c * e2 * i := by
    simpa [mul_assoc, mul_left_comm, mul_comm] using hmul'
  unfold rowG106ArrowIntensity
  nlinarith [hmul]

/-- Nonnegative components imply nonnegative arrow intensity. -/
theorem rowG106_nonneg
    (s : rowG106ArrowState)
    (hb : 0 ≤ s.baseline)
    (hc : 0 ≤ s.coupling)
    (he : 0 ≤ s.entropyRate)
    (hi : 0 ≤ s.informationFlux) :
    0 ≤ rowG106ArrowIntensity s := by
  have hprod : 0 ≤ s.coupling * s.entropyRate * s.informationFlux :=
    mul_nonneg (mul_nonneg hc he) hi
  unfold rowG106ArrowIntensity
  nlinarith [hb, hprod]

/-- Bundle theorem for row-106 unified arrow model. -/
theorem rowG106_bundle
    (b c i e1 e2 : ℝ)
    (hb : 0 ≤ b)
    (hc : 0 ≤ c)
    (hi : 0 ≤ i)
    (he1 : 0 ≤ e1)
    (he : e1 ≤ e2) :
    rowG106ArrowIntensity
      { baseline := b, coupling := c, entropyRate := e1, informationFlux := i } ≤
    rowG106ArrowIntensity
      { baseline := b, coupling := c, entropyRate := e2, informationFlux := i } ∧
    0 ≤ rowG106ArrowIntensity
      { baseline := b, coupling := c, entropyRate := e1, informationFlux := i } := by
  exact ⟨
    rowG106_mono_entropy b c i e1 e2 hc hi he,
    rowG106_nonneg
      { baseline := b, coupling := c, entropyRate := e1, informationFlux := i }
      hb hc he1 hi
  ⟩

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G106
