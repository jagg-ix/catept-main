import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import CATEPTMain.Integration.EntropicTimeIntegralStateDependent

set_option autoImplicit false

/-!
# Matsubara Euclidean CAT/EPT bridge (Reply 18)

Encodes the finite-temperature (KMS) Euclidean-time compactification and
Matsubara frequencies as the thermal upgrade of the Euclidean CAT/EPT
layer.  CAT/EPT entropy production is modeled as an **extra** functional
(`lambda_extra`), not as a duplicate KMS term.
-/

namespace CATEPTMain.Integration.MatsubaraEuclideanCATEPTBridge

noncomputable section

/-- Compact Euclidean time data: period `beta * hbar`. -/
structure MatsubaraCompactTime where
  beta : ℝ
  hbar : ℝ
  beta_pos : 0 < beta
  hbar_pos : 0 < hbar

/-- Thermal Euclidean period `beta * hbar`. -/
def thermalPeriod (M : MatsubaraCompactTime) : ℝ :=
  M.beta * M.hbar

/-- Bosonic periodicity on the Euclidean circle. -/
def bosonPeriodic {α : Type*} [AddGroup α]
    (phi : ℝ → α) (M : MatsubaraCompactTime) : Prop :=
  ∀ tau, phi (tau + thermalPeriod M) = phi tau

/-- Fermionic anti-periodicity on the Euclidean circle. -/
def fermionAntiperiodic {α : Type*} [AddGroup α]
    (psi : ℝ → α) (M : MatsubaraCompactTime) : Prop :=
  ∀ tau, psi (tau + thermalPeriod M) = -psi tau

/-- Bosonic Matsubara frequencies `2 pi n / (beta hbar)`. -/
def matsubaraOmegaBoson (M : MatsubaraCompactTime) (n : ℤ) : ℝ :=
  (2 * Real.pi * (n : ℝ)) / (M.beta * M.hbar)

/-- Fermionic Matsubara frequencies `(2n+1) pi / (beta hbar)`. -/
def matsubaraOmegaFermion (M : MatsubaraCompactTime) (n : ℤ) : ℝ :=
  ((2 * (n : ℝ) + 1) * Real.pi) / (M.beta * M.hbar)

/-- Mode expansion carrier (scalar field or spinor components). -/
structure MatsubaraModeExpansion (α : Type*) where
  coeff : ℤ → α
  expansion : Prop

/-- Extra entropy rate: avoid double-counting KMS in Matsubara. -/
def lambdaExtra {α : Type*} (lambda_petz_pos lambda_fisher : α → ℝ) : α → ℝ :=
  fun x => lambda_petz_pos x + lambda_fisher x

/-- Extra entropy accumulation over one thermal period. -/
def matsubaraEntropyExtra
    (M : MatsubaraCompactTime) (lambda_extra : ℝ → ℝ) : ℝ :=
  CATEPTMain.Integration.EntropicTimeIntegralStateDependent.entropicTimeIntegral
    lambda_extra (thermalPeriod M)

/-- Euclidean weight with extra entropy functional. -/
def matsubaraEuclideanWeight (hbar : ℝ) (S_E S_ent_extra : ℝ) : ℝ :=
  Real.exp (-(S_E / hbar) - S_ent_extra)

/-- Euclidean inverse propagator with an entropy kernel correction. -/
def euclideanInversePropagator (omega k m : ℝ) (gamma : ℝ) : ℝ :=
  omega ^ 2 + k ^ 2 + m ^ 2 + gamma

/-- Retarded continuation `omega -> omega + i epsilon`. -/
def retardedContinuation (omega epsilon : ℝ) : ℂ :=
  (omega : ℂ) + Complex.I * epsilon

/-- Carrier for Matsubara-to-retarded continuation of the entropy kernel. -/
structure MatsubaraToRetarded where
  gamma_E : ℤ → ℝ → ℝ
  sigma_R : ℝ → ℝ → ℂ
  continuation : Prop

end

end CATEPTMain.Integration.MatsubaraEuclideanCATEPTBridge
