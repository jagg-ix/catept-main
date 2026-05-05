import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import CATEPTMain.CATEPT.CATEPT.LorentzianPathIntegralBridge
import CATEPTMain.CATEPT.EPT.EPTPrelude

set_option autoImplicit false

/-!
# Proper-time path-integral bridge

Carrier-level encoding of the Schwinger/Fock proper-time representation of the
scalar propagator. We keep the normalization prefactor abstract to avoid
committing to dimension-specific constants.
-/

namespace CATEPTMain.Integration.ProperTimePathIntegralBridge

noncomputable section

open CATEPTMain.CATEPT.CATEPT
/-- Damping factor for the proper-time regulator epsilon > 0. -/
def properTimeRegulator (epsilon tau : ℝ) : ℝ :=
  Real.exp (-(epsilon * tau))

/-- Phase term for the free scalar proper-time kernel, with sigma = (x-x')^2. -/
def properTimePhase (sigma m tau : ℝ) : ℂ :=
  Complex.exp ((-(sigma / (4 * tau) + m ^ 2 * tau) : ℂ) * Complex.I)

/-- Proper-time kernel with an abstract normalization prefactor. -/
def properTimeKernel (prefactor : ℝ → ℂ) (sigma m epsilon tau : ℝ) : ℂ :=
  prefactor tau * properTimePhase sigma m tau * (properTimeRegulator epsilon tau : ℂ)

/-- Same kernel written as a CAT/EPT Lorentzian weight with hbar = 1. -/
def properTimeKernelViaLorentzian (prefactor : ℝ → ℂ)
    (sigma m epsilon tau : ℝ) : ℂ :=
  prefactor tau *
    lorentzianKernel (-(sigma / (4 * tau) + m ^ 2 * tau)) (epsilon * tau) 1

theorem properTimeKernel_via_lorentzian
    (prefactor : ℝ → ℂ) (sigma m epsilon tau : ℝ) :
    properTimeKernel prefactor sigma m epsilon tau =
      properTimeKernelViaLorentzian prefactor sigma m epsilon tau := by
  unfold properTimeKernel properTimeKernelViaLorentzian properTimePhase properTimeRegulator
  simp [lorentzianKernel_factorizes, mul_assoc]

/-- Abstract proper-time integral (carrier-level placeholder). -/
axiom properTimeIntegral : (ℝ → ℂ) → ℂ

/-- Proper-time representation of a propagator. -/
def properTimeRepresentation (kernel : ℝ → ℂ) (propagator : ℂ) : Prop :=
  propagator = (-Complex.I) * properTimeIntegral kernel

/-- Carrier for a proper-time propagator. -/
structure ProperTimePropagatorCarrier where
  kernel : ℝ → ℂ
  propagator : ℂ
  representation : properTimeRepresentation kernel propagator

/-- Bridge: identify proper time parameter with entropic proper time. -/
structure IdentifyProperTimeWithEntropicTime where
  tau : ℝ
  hbar : ℝ
  S_I : ℝ
  relation : tau = CATEPTMain.CATEPT.EPT.entropicTime hbar S_I

end

end CATEPTMain.Integration.ProperTimePathIntegralBridge
