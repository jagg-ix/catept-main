import CATEPTMain.CATEPT.CATEPT.LorentzianPathIntegralBridge
import CATEPTMain.Integration.ImaginaryActionDissipationDictionary
import CATEPTMain.Integration.EntropicTimeIntegralStateDependent
import CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge

set_option autoImplicit false

/-!
# Lorentzian CAT/EPT kernel with explicit rate decomposition

Provides a rate-level Lorentzian kernel that injects the three-component
rate decomposition into the imaginary action used by the Lorentzian
path integral.
-/

namespace CATEPTMain.Integration.LorentzianRateKernelBridge

noncomputable section

open CATEPTMain.CATEPT.CATEPT
open CATEPTMain.Integration.ImaginaryActionDissipationDictionary
open CATEPTMain.Integration.EntropicTimeIntegralStateDependent
open CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge

/-- Total rate from three component rate functions. -/
def lambdaTotal
    (lambda_kms lambda_petz lambda_fisher : ℝ → ℝ) : ℝ → ℝ :=
  fun t => lambda_kms t + lambda_petz t + lambda_fisher t

/-- Constant-in-time total rate from a `ThreeComponentRate`. -/
def lambdaTotal_from_three_component_rate (R : ThreeComponentRate) : ℝ → ℝ :=
  fun _ => R.total

/-- Imaginary action from a rate: S_I(t) = hbar * ∫_0^t lambda_total. -/
def entropicActionFromRate (hbar : ℝ) (lambda_total : ℝ → ℝ) (t : ℝ) : ℝ :=
  hbar * imaginaryActionAccumulation lambda_total t

/-- Pointwise generator from a rate: H_I(t) = hbar * lambda_total(t). -/
def generatorFromRate (hbar : ℝ) (lambda_total : ℝ → ℝ) (t : ℝ) : ℝ :=
  hbar * lambda_total t

/-- Lorentzian kernel with explicit rate decomposition. -/
def lorentzianKernel_from_rate
    (S_R hbar : ℝ) (lambda_total : ℝ → ℝ) (t : ℝ) : ℂ :=
  lorentzianKernel S_R (entropicActionFromRate hbar lambda_total t) hbar

/-- Lorentzian kernel expressed directly with the rate integral.

The `hh : hbar ≠ 0` hypothesis is required: without it the identity
`ℏ · (S_I/ℏ) = S_I` collapses to `0 = S_I` when `ℏ = 0`. -/
theorem lorentzianKernel_from_rate_exp
    (S_R hbar : ℝ) (lambda_total : ℝ → ℝ) (t : ℝ) (hh : hbar ≠ 0) :
    lorentzianKernel_from_rate S_R hbar lambda_total t =
      Complex.exp ((S_R / hbar : ℂ) * Complex.I -
        (imaginaryActionAccumulation lambda_total t : ℂ)) := by
  unfold lorentzianKernel_from_rate entropicActionFromRate
  unfold lorentzianKernel
  have hC : (hbar : ℂ) ≠ 0 := by exact_mod_cast hh
  congr 1
  push_cast
  field_simp

/-- If the total rate is non-negative, the Lorentzian kernel is bounded. -/
theorem lorentzianKernel_from_rate_norm_le_one
    (S_R hbar : ℝ) (lambda_total : ℝ → ℝ) (t : ℝ)
    (ht : 0 ≤ t)
    (hh : 0 < hbar)
    (hpos : ∀ s, 0 ≤ lambda_total s) :
    ‖lorentzianKernel_from_rate S_R hbar lambda_total t‖ ≤ 1 := by
  unfold lorentzianKernel_from_rate entropicActionFromRate
  have hSI : 0 ≤ imaginaryActionAccumulation lambda_total t := by
    unfold imaginaryActionAccumulation
    exact entropicTimeIntegral_nonneg_of_nonneg_rate lambda_total hpos t ht
  have hnorm : ‖lorentzianKernel S_R (hbar * imaginaryActionAccumulation lambda_total t) hbar‖
      = Real.exp (-(imaginaryActionAccumulation lambda_total t)) := by
    have hh' : hbar ≠ 0 := ne_of_gt hh
    have hcancel : hbar * imaginaryActionAccumulation lambda_total t / hbar
        = imaginaryActionAccumulation lambda_total t := by
      field_simp
    rw [lorentzianKernel_norm_is_damping (S_R := S_R)
        (S_I := hbar * imaginaryActionAccumulation lambda_total t) (hbar := hbar), hcancel]
  rw [hnorm]
  rw [Real.exp_le_one_iff]
  linarith

end

end CATEPTMain.Integration.LorentzianRateKernelBridge
