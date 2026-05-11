import CATEPTMain.Certification.RelativityGRUnsafeFixes

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- Typed certificate for ADM Hamiltonian and momentum constraints. -/
structure ADMConstraintCertificate where
  adm : ADMDecomposition
  stressDecomposition : ADMStressEnergyDecomposition
  sourceTerm : Gravitas.Expr
  hamiltonian_constraint :
    (solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm stressDecomposition sourceTerm).hamiltonianConstraint
  momentum_constraint :
    (solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm stressDecomposition sourceTerm).momentumConstraints

/-- Constructor for an arbitrary ADM-constraint certificate with explicit
proof payloads for Hamiltonian and momentum residual identities. -/
def mk_adm_constraint_certificate
    (adm : ADMDecomposition)
    (stressDecomposition : ADMStressEnergyDecomposition)
    (sourceTerm : Gravitas.Expr)
    (hHamiltonian :
      (solveVacuumADMEquations adm).hamiltonianConstraint =
        (solveADMEquations adm stressDecomposition sourceTerm).hamiltonianConstraint)
    (hMomentum :
      (solveVacuumADMEquations adm).momentumConstraints =
        (solveADMEquations adm stressDecomposition sourceTerm).momentumConstraints) :
    ADMConstraintCertificate where
  adm := adm
  stressDecomposition := stressDecomposition
  sourceTerm := sourceTerm
  hamiltonian_constraint := hHamiltonian
  momentum_constraint := hMomentum

/-- Any certificate built via `mk_adm_constraint_certificate` stores the
provided Hamiltonian and momentum proofs verbatim. -/
theorem mk_adm_constraint_certificate_holds
    (adm : ADMDecomposition)
    (stressDecomposition : ADMStressEnergyDecomposition)
    (sourceTerm : Gravitas.Expr)
    (hHamiltonian :
      (solveVacuumADMEquations adm).hamiltonianConstraint =
        (solveADMEquations adm stressDecomposition sourceTerm).hamiltonianConstraint)
    (hMomentum :
      (solveVacuumADMEquations adm).momentumConstraints =
        (solveADMEquations adm stressDecomposition sourceTerm).momentumConstraints) :
    ((solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm stressDecomposition sourceTerm).hamiltonianConstraint) ∧
    ((solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm stressDecomposition sourceTerm).momentumConstraints) := by
  exact ⟨
    (mk_adm_constraint_certificate adm stressDecomposition sourceTerm
      hHamiltonian hMomentum).hamiltonian_constraint,
    (mk_adm_constraint_certificate adm stressDecomposition sourceTerm
      hHamiltonian hMomentum).momentum_constraint
  ⟩

/-- Canonical vacuum ADM constraint certificate on the Minkowski slicing. -/
def canonical_vacuum_adm_certificate : ADMConstraintCertificate where
  adm := gravitasCanonicalVacuumADM
  stressDecomposition := gravitasCanonicalVacuumADMStressDecomposition
  sourceTerm := .lit 0
  hamiltonian_constraint := by
    simpa using gravitasCanonicalVacuumADM_hamiltonian_residual_exact
  momentum_constraint := by
    simpa using gravitasCanonicalVacuumADM_momentum_residual_exact

/-- The canonical certificate satisfies its Hamiltonian constraint field. -/
theorem canonical_vacuum_adm_hamiltonian_constraint_holds :
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).hamiltonianConstraint =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).hamiltonianConstraint :=
  canonical_vacuum_adm_certificate.hamiltonian_constraint

/-- The canonical certificate satisfies its momentum-constraint field. -/
theorem canonical_vacuum_adm_momentum_constraint_holds :
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).momentumConstraints =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).momentumConstraints :=
  canonical_vacuum_adm_certificate.momentum_constraint

end CATEPTMain.Certification.RelativityGR

end
