import CATEPTMain.Certification.RelativityGRUnsafeFixes

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- Flatten an expression matrix row-wise to a single residual vector. -/
def flattenResidualMatrix (m : Mat) : Array Gravitas.Expr :=
  m.foldl (fun acc row => acc ++ row) #[]

/-- First-class Einstein residual witness for a metric/stress pair. -/
structure EinsteinResidual where
  metric : MetricTensor
  stress : StressEnergyTensor
  residual : Array Gravitas.Expr
  deriving Repr

/-- First-class ADM residual witness for a slicing. -/
structure ADMResidual where
  hamiltonian : Gravitas.Expr
  momentum : Array Gravitas.Expr
  deriving Repr

/-- Canonical Einstein residual object on Minkowski electrovacuum data. -/
def canonical_einstein_residual : EinsteinResidual where
  metric := gravitasMinkowski
  stress := gravitasEMStressEnergy
  residual := flattenResidualMatrix
    (solveEinsteinEquations gravitasEMStressEnergy (.lit 0)).fieldEquations

/-- Canonical ADM residual object on the vacuum Minkowski slicing. -/
def canonical_adm_residual : ADMResidual where
  hamiltonian := (solveVacuumADMEquations gravitasCanonicalVacuumADM).hamiltonianConstraint
  momentum := (solveVacuumADMEquations gravitasCanonicalVacuumADM).momentumConstraints

/-- The canonical Einstein residual object stores the explicit residual payload. -/
theorem canonical_einstein_residual_explicit :
    canonical_einstein_residual.residual =
      flattenResidualMatrix
        (solveEinsteinEquations gravitasEMStressEnergy (.lit 0)).fieldEquations := by
  rfl

/-- The canonical ADM residual object stores explicit Hamiltonian/momentum data. -/
theorem canonical_adm_residual_explicit :
    canonical_adm_residual.hamiltonian =
      (solveVacuumADMEquations gravitasCanonicalVacuumADM).hamiltonianConstraint ∧
    canonical_adm_residual.momentum =
      (solveVacuumADMEquations gravitasCanonicalVacuumADM).momentumConstraints := by
  exact ⟨rfl, rfl⟩

end CATEPTMain.Certification.RelativityGR

end
