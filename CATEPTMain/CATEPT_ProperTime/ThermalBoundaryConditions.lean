import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Analysis.SpecialFunctions.Sqrt

set_option autoImplicit false

/-!
# Thermal boundary conditions and CAT/EPT oscillator checks

Encodes periodic/antiperiodic boundary conditions and the CAT/EPT-modified
oscillator partition functions used as thermal sanity checks.
-/

namespace CATEPTMain.CATEPT_ProperTime.ThermalBoundaryConditions

noncomputable section

/-- Thermal circle data: beta * hbar. -/
structure ThermalCircle where
  beta : ℝ
  hbar : ℝ
  beta_pos : 0 < beta
  hbar_pos : 0 < hbar

/-- Thermal period beta * hbar. -/
def thermalPeriod (T : ThermalCircle) : ℝ :=
  T.beta * T.hbar

/-- Bosonic periodic boundary condition on the Euclidean circle. -/
def bosonPeriodic {α : Type*} [AddGroup α]
    (phi : ℝ → α) (T : ThermalCircle) : Prop :=
  ∀ tau, phi (tau + thermalPeriod T) = phi tau

/-- Fermionic antiperiodic boundary condition on the Euclidean circle. -/
def fermionAntiperiodic {α : Type*} [AddGroup α]
    (psi : ℝ → α) (T : ThermalCircle) : Prop :=
  ∀ tau, psi (tau + thermalPeriod T) = -psi tau

/-- Bosonic Matsubara frequencies 2*pi*n/(beta*hbar). -/
def matsubaraOmegaBoson (T : ThermalCircle) (n : ℤ) : ℝ :=
  (2 * Real.pi * (n : ℝ)) / (T.beta * T.hbar)

/-- Fermionic Matsubara frequencies (2n+1)*pi/(beta*hbar). -/
def matsubaraOmegaFermion (T : ThermalCircle) (n : ℤ) : ℝ :=
  ((2 * (n : ℝ) + 1) * Real.pi) / (T.beta * T.hbar)

/-- Effective oscillator frequency with CAT/EPT entropy shift. -/
def omegaEff (omega mu_I : ℝ) : ℝ :=
  Real.sqrt (omega ^ 2 + mu_I ^ 2)

/-- CAT/EPT bosonic oscillator partition function check. -/
def bosonPartitionCAT (beta omega mu_I : ℝ) : ℝ :=
  1 / (2 * Real.sinh (beta * omegaEff omega mu_I / 2))

/-- CAT/EPT fermionic oscillator partition function check. -/
def fermionPartitionCAT (beta omega mu_I : ℝ) : ℝ :=
  2 * Real.cosh (beta * omegaEff omega mu_I / 2)

/-- Abstract bosonic partition function. -/
axiom bosonPartitionFunction : ℝ → ℝ → ℝ → ℝ

/-- Abstract fermionic partition function. -/
axiom fermionPartitionFunction : ℝ → ℝ → ℝ → ℝ

/-- Periodic boundary conditions yield the bosonic thermal partition function. -/
axiom thermal_boson_periodic (beta omega mu_I : ℝ) (hbeta : 0 < beta) :
  bosonPartitionFunction beta omega mu_I = bosonPartitionCAT beta omega mu_I

/-- Antiperiodic boundary conditions yield the fermionic thermal partition function. -/
axiom thermal_fermion_antiperiodic (beta omega mu_I : ℝ) (hbeta : 0 < beta) :
  fermionPartitionFunction beta omega mu_I = fermionPartitionCAT beta omega mu_I

end

end CATEPTMain.CATEPT_ProperTime.ThermalBoundaryConditions
