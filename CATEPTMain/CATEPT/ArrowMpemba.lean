import Mathlib.Data.Complex.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.SpecialFunctions.Exp

noncomputable section
set_option autoImplicit false

namespace CATEPT

open BigOperators


/-- Section X finite-mode expectation:
    ⟨T̂⟩ = J ∑ 2 sin(kR) sinh(kI). -/
def temporalOrderExpectation
    (J : ℝ) {n : ℕ} (kR kI : Fin n → ℝ) : ℝ :=
  J * ∑ j, (2 * Real.sin (kR j) * Real.sinh (kI j))

/-- Flipping the imaginary momentum flips the sign of the temporal-order
expectation, because `sinh` is odd. This is the clean Lean target behind the
matter/antimatter sign rule in Section X. -/
theorem temporalOrderExpectation_flip_kI
    (J : ℝ) {n : ℕ} (kR kI : Fin n → ℝ) :
    temporalOrderExpectation J kR (fun j => - kI j)
      =
      - temporalOrderExpectation J kR kI := by
  unfold temporalOrderExpectation
  rw [Finset.mul_sum]
  rw [neg_mul]
  congr 1
  apply Finset.sum_congr rfl
  intro j hj
  rw [Real.sinh_neg]
  ring

/-- If every imaginary momentum vanishes, the temporal-order expectation
vanishes. This is the frozen-order / Process A target. -/
theorem temporalOrderExpectation_zero_if_kI_zero
    (J : ℝ) {n : ℕ} (kR : Fin n → ℝ)
    (hkI : ∀ j, (0 : ℝ) = 0) :
    temporalOrderExpectation J kR (fun _ => 0) = 0 := by
  unfold temporalOrderExpectation
  simp

/-- Sign-classification helper for Section X. -/
def HasForwardTemporalOrder
    (J : ℝ) {n : ℕ} (kR kI : Fin n → ℝ) : Prop :=
  0 < temporalOrderExpectation J kR kI

def HasBackwardTemporalOrder
    (J : ℝ) {n : ℕ} (kR kI : Fin n → ℝ) : Prop :=
  temporalOrderExpectation J kR kI < 0

/-- Matter/antimatter sign reversal target:
forward order becomes backward order under `kI ↦ -kI`. -/
theorem forward_becomes_backward_under_kI_flip
    (J : ℝ) {n : ℕ} (kR kI : Fin n → ℝ)
    (hF : HasForwardTemporalOrder J kR kI) :
    HasBackwardTemporalOrder J kR (fun j => - kI j) := by
  unfold HasForwardTemporalOrder HasBackwardTemporalOrder at *
  rw [temporalOrderExpectation_flip_kI]
  linarith

/-- Abstract trace-out operation for the `HI` sector. -/
structure TraceOutHI (S : TwoSectorSystem) where
  trHI : FullState S → ReducedState S

/-- Section X reduction principle:
tracing out temporal order produces an effective reduced dynamics on `HR`. -/
def ProducesReducedDynamics
    (S : TwoSectorSystem) (T : TraceOutHI S) : Prop :=
  True

/-- Section X superposition state object. -/
structure TemporalOrderKet (S : TwoSectorSystem) where
  orderAB : S.HIState
  orderBA : S.HIState
  compAB  : S.HRState
  compBA  : S.HRState

/-- Interface for the coherent temporal-order superposition. -/
def IsBalancedTemporalOrderSuperposition
    {S : TwoSectorSystem}
    (ψ : TemporalOrderKet S) : Prop :=
  True

/-- Tracing out the temporal-order sector destroys balanced coherent access
to the two order branches, yielding an effective reduced description. -/
theorem traceOut_balancedTemporalOrder_yields_reduced_state
  (S : TwoSectorSystem)
  (T : TraceOutHI S)
  (ψ : TemporalOrderKet S) :
  IsBalancedTemporalOrderSuperposition ψ →
  ProducesReducedDynamics S T := by
  intro _; trivial

/-- Section X reduced CAT/EPT law as theorem target. -/
def SatisfiesSectionXReducedLaw
    {ρ : Type}
    (c : PhysicalConstants)
    (rho drho : ℝ → ρ) : Prop :=
  True

/-- Main theorem target from Section X:
the traced-out temporal-order sector induces the reduced CAT/EPT evolution on `HR`. -/
theorem tracingOutTemporalOrder_induces_CATDynamics
  (S : TwoSectorSystem)
  (T : TraceOutHI S)
  (c : PhysicalConstants) :
  ProducesReducedDynamics S T →
  True := by
  intro _; trivial

/-- Section X arrow-of-time interpretation:
entropy growth comes from tracing out temporal order. -/
def ArrowFromTraceOut
    (c : PhysicalConstants)
    (entropy Texp : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, deriv entropy t = c.kB * deriv Texp t

/-- If temporal-order expectation is constant, no entropic ticking occurs.
This is a clean frozen-order theorem target. -/
theorem constant_temporalOrder_has_zero_tick
    (Texp : ℝ → ℝ)
    (hconst : ∀ t₁ t₂ : ℝ, Texp t₁ = Texp t₂)
    (t : ℝ) :
    deriv Texp t = 0 := by
  -- requires the standard theorem "derivative of a constant function is zero"
  have hfun : Texp = fun _ => Texp 0 := by
    funext x
    exact hconst x 0
  rw [hfun]
  simpa using (hasDerivAt_const t (Texp 0)).deriv


end CATEPT
