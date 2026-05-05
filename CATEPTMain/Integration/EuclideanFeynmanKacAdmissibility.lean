import CATEPTMain.CATEPT.CATEPT.FeynmanKacBridge
import CATEPTMain.Integration.EntropicTimeIntegralStateDependent
import CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.Tactic.Linarith

set_option autoImplicit false

/-!
# Euclidean Feynman–Kac layer with admissible CAT/EPT rates

Records the Euclidean CAT/EPT weight as a Feynman–Kac damping factor
and exposes basic admissibility conditions (non-negativity and
integrability shape) for the entropic rate.
-/

namespace CATEPTMain.Integration.EuclideanFeynmanKacAdmissibility

noncomputable section

open CATEPTMain.CATEPT.CATEPT
open CATEPTMain.Integration.EntropicTimeIntegralStateDependent
open CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge
open MeasureTheory

/-- Euclidean CAT/EPT killing functional along a path. -/
def euclideanKillingIntegral
    (hbar : ℝ) (V : ℝ → ℝ) (lambda : ℝ → ℝ)
    (x : ℝ → ℝ) (t : ℝ) : ℝ :=
  fkPathPotential V x t / hbar + entropicTimeIntegral lambda t

/-- Euclidean CAT/EPT weight along a path. -/
def euclideanWeight
    (hbar : ℝ) (V : ℝ → ℝ) (lambda : ℝ → ℝ)
    (x : ℝ → ℝ) (t : ℝ) : ℝ :=
  Real.exp (-(euclideanKillingIntegral hbar V lambda x t))

/-- The Euclidean weight factorizes into FK potential and CAT/EPT damping. -/
theorem euclideanWeight_factorizes
    (hbar : ℝ) (V : ℝ → ℝ) (lambda : ℝ → ℝ)
    (x : ℝ → ℝ) (t : ℝ) :
    euclideanWeight hbar V lambda x t =
      Real.exp (-(fkPathPotential V x t / hbar)) *
      Real.exp (-(entropicTimeIntegral lambda t)) := by
  unfold euclideanWeight euclideanKillingIntegral
  rw [neg_add, Real.exp_add]

/-- Admissibility carrier for Euclidean rates (non-negative and integrable). -/
structure EuclideanAdmissibleRate where
  rate : ℝ → ℝ
  rate_nonneg : ∀ t, 0 ≤ rate t
  rate_integrable : ∀ a b : ℝ,
    IntervalIntegrable rate MeasureTheory.volume a b

/-- If V >= 0 and lambda >= 0, the Euclidean CAT/EPT weight is <= 1. -/
theorem euclideanWeight_le_one
    (hbar : ℝ) (V : ℝ → ℝ) (lambda : ℝ → ℝ)
    (x : ℝ → ℝ) (t : ℝ)
    (hh : 0 < hbar) (ht : 0 ≤ t)
    (hV : ∀ y, 0 ≤ V y)
    (hlam : ∀ s, 0 ≤ lambda s) :
    euclideanWeight hbar V lambda x t ≤ 1 := by
  unfold euclideanWeight euclideanKillingIntegral
  have hVint : 0 ≤ fkPathPotential V x t := by
    unfold fkPathPotential
    exact intervalIntegral.integral_nonneg ht (fun τ _ => hV (x τ))
  have hL : 0 ≤ entropicTimeIntegral lambda t :=
    entropicTimeIntegral_nonneg_of_nonneg_rate lambda hlam t ht
  have hsum : 0 ≤ fkPathPotential V x t / hbar + entropicTimeIntegral lambda t := by
    exact add_nonneg (div_nonneg hVint (le_of_lt hh)) hL
  have hneg : -(fkPathPotential V x t / hbar + entropicTimeIntegral lambda t) ≤ 0 := by
    linarith
  exact (Real.exp_le_one_iff).mpr hneg

/-- Total rate from the three-component decomposition (constant in time). -/
def lambdaTotal_from_three_component_rate (R : ThreeComponentRate) : ℝ → ℝ :=
  fun _ => R.total

/-- The total rate is non-negative if each component is non-negative. -/
theorem lambdaTotal_from_three_component_rate_nonneg
    (R : ThreeComponentRate) (t : ℝ) :
    0 ≤ lambdaTotal_from_three_component_rate R t := by
  simpa [lambdaTotal_from_three_component_rate] using R.total_nonneg

/-- Fisher admissibility: lambda_F >= 0 when eta >= 0 and I_F >= 0. -/
theorem fisher_rate_nonneg
    (L : LocalFisherRate) :
    0 ≤ L.value :=
  LocalFisherRate.value_nonneg L

/-- GTD equilibrium limit: exp(-tau_ent) reduces to exp(-DeltaS/kB). -/
theorem gtd_equilibrium_damping
    (tauEnt deltaS kB : ℝ)
    (h : tauEnt = deltaS / kB) :
    Real.exp (-tauEnt) = Real.exp (-(deltaS / kB)) := by
  simp [h]

end

end CATEPTMain.Integration.EuclideanFeynmanKacAdmissibility
