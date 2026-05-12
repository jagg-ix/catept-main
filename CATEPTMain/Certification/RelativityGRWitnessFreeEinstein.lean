import CATEPTMain.Certification.RelativityGREinsteinEquation
import CATEPTMain.Certification.RelativityGRWitnessFreeFaraday

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-!
# Witness-free Einstein-equation family for electrovacuum solutions
(WF-GR-005 / WF-GR-006)

This module exposes a typed admissibility predicate
`IsEinsteinElectrovacuumSolution` parameterized by `(g, A, μ₀, Λ, sourceTerm)`
that bundles two obligations characterizing an electrovacuum Einstein solution:

* the Einstein residual identity at the electromagnetic stress-energy derived
  from `solveElectrovacuumEinsteinEquations g A μ₀ Λ`,
* the Maxwell residual array vanishing.

A constructor `einstein_certificate_for_electrovacuum_solution` lifts any such
admissible bundle into the existing `EinsteinEquationCertificate` surface.

The canonical Minkowski instance (default potential, μ₀ symbolic, Λ = 0,
sourceTerm = 0) is discharged via `native_decide` against concrete Gravitas
data, reusing the `deriving DecidableEq` instances from the witness-free
Faraday module.
-/

/-- Umbrella admissibility predicate bundling the two obligations needed to
recognise `(g, A, μ₀, Λ, sourceTerm)` as a valid Einstein-electrovacuum
solution input. -/
structure IsEinsteinElectrovacuumSolution
    (g : MetricTensor)
    (A : Array Expr)
    (μ₀ : Expr)
    (Λ : Expr)
    (sourceTerm : Expr) : Prop where
  einstein_residual :
    (solveEinsteinEquations
        (StressEnergyTensor.electromagneticField g
          (solveElectrovacuumEinsteinEquations g A μ₀ Λ).faradayTensor.components μ₀)
        sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations g
        (StressEnergyTensor.electromagneticField g
          (solveElectrovacuumEinsteinEquations g A μ₀ Λ).faradayTensor.components
          μ₀).components
        sourceTerm (.var "G_N")
  maxwell_residual_zero :
    (solveElectrovacuumEinsteinEquations g A μ₀ Λ).maxwellEquations =
      Array.replicate g.dim (.lit 0)

/-- The EM stress-energy tensor associated to an Einstein-electrovacuum
solution input. -/
def einsteinElectrovacuumStress
    (g : MetricTensor) (A : Array Expr) (μ₀ : Expr) (Λ : Expr) :
    StressEnergyTensor :=
  StressEnergyTensor.electromagneticField g
    (solveElectrovacuumEinsteinEquations g A μ₀ Λ).faradayTensor.components μ₀

/-- Assemble a source-aware Einstein-equation certificate from any admissible
Einstein-electrovacuum solution input. This is the leverage-map
`einstein_certificate_for_solution` constructor. -/
def einstein_certificate_for_solution
    {g : MetricTensor} {A : Array Expr} {μ₀ Λ sourceTerm : Expr}
    (kappa : ℝ)
    (h : IsEinsteinElectrovacuumSolution g A μ₀ Λ sourceTerm) :
    EinsteinEquationCertificateForSource g (einsteinElectrovacuumStress g A μ₀ Λ) where
  kappa := kappa
  sourceTerm := sourceTerm
  equation_holds := h.einstein_residual

/-- Full-claim projection: any admissible Einstein-electrovacuum solution input
yields the two-conjunction direct claim (Einstein residual identity at the EM
stress, Maxwell residual zero). -/
theorem einstein_electrovacuum_solution_full_claim
    {g : MetricTensor} {A : Array Expr} {μ₀ Λ sourceTerm : Expr}
    (h : IsEinsteinElectrovacuumSolution g A μ₀ Λ sourceTerm) :
    (solveEinsteinEquations (einsteinElectrovacuumStress g A μ₀ Λ) sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations g
        (einsteinElectrovacuumStress g A μ₀ Λ).components sourceTerm (.var "G_N") ∧
    (solveElectrovacuumEinsteinEquations g A μ₀ Λ).maxwellEquations =
      Array.replicate g.dim (.lit 0) := by
  refine ⟨?_, h.maxwell_residual_zero⟩
  exact h.einstein_residual

/-- Canonical Minkowski Einstein-electrovacuum solution instance, discharged
from concrete Gravitas data via `native_decide`. -/
theorem canonical_minkowski_is_einstein_electrovacuum_solution :
    IsEinsteinElectrovacuumSolution
      gravitasMinkowski #[] (.var "μ₀") (.lit 0) (.lit 0) where
  einstein_residual := by native_decide
  maxwell_residual_zero := by native_decide

/-- Canonical source-aware Einstein-equation certificate assembled from the
canonical Minkowski Einstein-electrovacuum solution. -/
def canonical_einstein_certificate_of_electrovacuum_solution :
    EinsteinEquationCertificateForSource
      gravitasMinkowski
      (einsteinElectrovacuumStress gravitasMinkowski #[] (.var "μ₀") (.lit 0)) :=
  einstein_certificate_for_solution
    (8 * Real.pi)
    canonical_minkowski_is_einstein_electrovacuum_solution

/-- Concrete canonical full-claim specialization. -/
theorem canonical_einstein_electrovacuum_solution_full_claim :
    (solveEinsteinEquations
        (einsteinElectrovacuumStress gravitasMinkowski #[] (.var "μ₀") (.lit 0))
        (.lit 0)).fieldEquations =
      EinsteinTensor.fieldEquations gravitasMinkowski
        (einsteinElectrovacuumStress gravitasMinkowski #[] (.var "μ₀") (.lit 0)).components
        (.lit 0) (.var "G_N") ∧
    (solveElectrovacuumEinsteinEquations gravitasMinkowski #[] (.var "μ₀") (.lit 0)).maxwellEquations =
      Array.replicate gravitasMinkowski.dim (.lit 0) :=
  einstein_electrovacuum_solution_full_claim
    canonical_minkowski_is_einstein_electrovacuum_solution

end CATEPTMain.Certification.RelativityGR

end
