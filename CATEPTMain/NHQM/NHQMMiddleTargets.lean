import Mathlib.Data.Complex.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset
import CATEPTMain.NHQM.NHQMPrelude

set_option autoImplicit false

/-!
# NHQM middle-target carriers

Structural carriers and aliases for the REPLYID CAT-EPT-20260505-02
NHQM middle targets.
-/

namespace CATEPTMain.NHQM.MiddleTargets

noncomputable section

open scoped BigOperators

/-- Complex spectral map: epsilon_n = E_n - i * Gamma_n / 2. -/
def epsilonComplex (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (n : Fin N) : ℂ :=
  (complexEigenvalueRe N H φ n) - Complex.I * (complexEigenvalueIm N H φ n) / 2

/-- Entropic time along a spectral branch. -/
def tauEntSpectral (N : ℕ) (H : NHHamiltonian N) (φ : ℝ)
    (n : Fin N) (t hbar : ℝ) : ℝ :=
  complexEigenvalueIm N H φ n * t / (2 * hbar)

/-- Carrier claim linking H_I to Gamma_n. -/
def gammaFromHIClaim (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (n : Fin N) : Prop :=
  complexEigenvalueIm N H φ n = H.decayDiag n

/-- The H_I -> Gamma_n claim holds by definition. -/
theorem gammaFromHIClaim_holds (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (n : Fin N) :
    gammaFromHIClaim N H φ n :=
  rfl

/-- Effective NH Fermi-Dirac carrier. -/
def fEff (β ε γ μ : ℝ) : ℝ := nhFermiDirac β ε γ μ

/-- The occupation rule is the effective NH Fermi-Dirac carrier. -/
theorem nhStateOccupation_eq_fEff
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) (n : Fin N) :
    nhStateOccupation N H β μ n =
      (fun φ => fEff β (complexEigenvalueRe N H φ n) (complexEigenvalueIm N H φ n) μ) := by
  funext φ
  simp [nhStateOccupation, nhEnergyBranch, nhDecayBranch, fEff]

/-- Response template carrier for persistent-current derivations. -/
structure ResponseTemplate where
  freeEnergy : ℝ → ℝ
  current : ℝ → ℝ
  responseLaw : Prop

/-- Phase-1 response template from spectral data. -/
def responseTemplateFromSpec
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) : ResponseTemplate :=
  { freeEnergy := fun φ =>
      Finset.sum Finset.univ (fun n : Fin N =>
        fEff β (complexEigenvalueRe N H φ n) (complexEigenvalueIm N H φ n) μ)
    current := fun φ => persistentCurrentFromSpec N H β μ φ
    responseLaw := True }

/-- EP regularity carrier with proof-carrying continuity. -/
structure EPRegularityCarrier (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) where
  φ_EP : ℝ
  m : Fin N
  n : Fin N
  hEP : exceptionalPointAt N H φ_EP m n
  currentContinuousAt : ContinuousAt (persistentCurrentFromSpec N H β μ) φ_EP

/-- EP regularity carrier instantiated with the phase-1 continuity theorem. -/
def epRegularityCarrier
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ)
    (m n : Fin N) (φ_EP : ℝ) (hEP : exceptionalPointAt N H φ_EP m n) :
    EPRegularityCarrier N H β μ :=
  { φ_EP := φ_EP
    m := m
    n := n
    hEP := hEP
    currentContinuousAt := nhFermiDirac_continuousAtEP N H β μ m n φ_EP hEP }

/-- Proper-time determinant linkage carrier. -/
structure ProperTimeDeterminantCarrier where
  traceLog : ℝ
  properTimeIntegral : ℝ
  linkClaim : traceLog = properTimeIntegral

/-- Build a structural proper-time determinant carrier. -/
def mkProperTimeDeterminantCarrier (x : ℝ) : ProperTimeDeterminantCarrier :=
  { traceLog := x
    properTimeIntegral := x
    linkClaim := rfl }

/-- Gauge/holonomy response carrier anchored to a response template. -/
structure GaugeHolonomyResponseCarrier where
  template : ResponseTemplate

/-- Gauge/holonomy response from the spectral response template. -/
def gaugeHolonomyResponseCarrierFromSpec
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) : GaugeHolonomyResponseCarrier :=
  { template := responseTemplateFromSpec N H β μ }

/-- Curved-spacetime response carrier. -/
structure CurvedSpacetimeResponseCarrier where
  stressEnergy : ℝ → ℝ
  conservation : Prop

/-- Structural curved-spacetime response carrier. -/
def curvedSpacetimeResponseCarrier (stressEnergy : ℝ → ℝ) (conservation : Prop) :
    CurvedSpacetimeResponseCarrier :=
  { stressEnergy := stressEnergy
    conservation := conservation }

end

end CATEPTMain.NHQM.MiddleTargets
