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

/-- Indexed ADM-constraint certificate family with the ADM decomposition fixed
in the type. -/
structure ADMConstraintCertificateFor (adm : ADMDecomposition) where
  stressDecomposition : ADMStressEnergyDecomposition
  sourceTerm : Gravitas.Expr
  hamiltonian_constraint :
    (solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm stressDecomposition sourceTerm).hamiltonianConstraint
  momentum_constraint :
    (solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm stressDecomposition sourceTerm).momentumConstraints

/-- Constructor for the indexed ADM-constraint certificate family. -/
def mk_adm_constraint_certificate_for
    (adm : ADMDecomposition)
    (stressDecomposition : ADMStressEnergyDecomposition)
    (sourceTerm : Gravitas.Expr)
    (hHamiltonian :
      (solveVacuumADMEquations adm).hamiltonianConstraint =
        (solveADMEquations adm stressDecomposition sourceTerm).hamiltonianConstraint)
    (hMomentum :
      (solveVacuumADMEquations adm).momentumConstraints =
        (solveADMEquations adm stressDecomposition sourceTerm).momentumConstraints) :
    ADMConstraintCertificateFor adm where
  stressDecomposition := stressDecomposition
  sourceTerm := sourceTerm
  hamiltonian_constraint := hHamiltonian
  momentum_constraint := hMomentum

/-- Any indexed certificate built via `mk_adm_constraint_certificate_for`
stores the Hamiltonian and momentum proof payloads unchanged. -/
theorem mk_adm_constraint_certificate_for_holds
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
    (mk_adm_constraint_certificate_for adm stressDecomposition sourceTerm
      hHamiltonian hMomentum).hamiltonian_constraint,
    (mk_adm_constraint_certificate_for adm stressDecomposition sourceTerm
      hHamiltonian hMomentum).momentum_constraint
  ⟩

/-- Family predicate for ADM decompositions identified with the canonical
Minkowski vacuum slicing. -/
structure IsMinkowskiVacuumADM (adm : ADMDecomposition) : Prop where
  eq_canonical : adm = gravitasCanonicalVacuumADM

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

/-- Canonical indexed vacuum ADM certificate. -/
def canonical_vacuum_adm_certificate_for :
    ADMConstraintCertificateFor gravitasCanonicalVacuumADM where
  stressDecomposition := gravitasCanonicalVacuumADMStressDecomposition
  sourceTerm := .lit 0
  hamiltonian_constraint := by
    simpa using gravitasCanonicalVacuumADM_hamiltonian_residual_exact
  momentum_constraint := by
    simpa using gravitasCanonicalVacuumADM_momentum_residual_exact

/-- Family-lifted canonical indexed ADM certificate:
any ADM decomposition identified with the canonical Minkowski vacuum slicing
inherits the canonical indexed certificate payload. -/
def canonical_vacuum_adm_certificate_for_family
    (adm : ADMDecomposition)
    (hAdm : IsMinkowskiVacuumADM adm) :
    ADMConstraintCertificateFor adm := by
  rcases hAdm with ⟨hEq⟩
  subst hEq
  exact canonical_vacuum_adm_certificate_for

/-- Projection theorem for the family-lifted canonical indexed ADM certificate. -/
theorem canonical_vacuum_adm_certificate_for_family_holds
    (adm : ADMDecomposition)
    (hAdm : IsMinkowskiVacuumADM adm) :
    ((solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm gravitasCanonicalVacuumADMStressDecomposition
        (.lit 0)).hamiltonianConstraint) ∧
    ((solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm gravitasCanonicalVacuumADMStressDecomposition
        (.lit 0)).momentumConstraints) := by
  rcases hAdm with ⟨hEq⟩
  subst hEq
  exact ⟨
    canonical_vacuum_adm_certificate_for.hamiltonian_constraint,
    canonical_vacuum_adm_certificate_for.momentum_constraint
  ⟩

/-- Any ADM decomposition identified with the canonical Minkowski vacuum
slicing inherits the canonical vacuum ADM residual identities. -/
theorem minkowski_vacuum_adm_constraints_for_family
    (adm : ADMDecomposition)
    (hAdm : IsMinkowskiVacuumADM adm) :
    (solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm gravitasCanonicalVacuumADMStressDecomposition
        (.lit 0)).hamiltonianConstraint ∧
    (solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm gravitasCanonicalVacuumADMStressDecomposition
        (.lit 0)).momentumConstraints := by
  rcases hAdm with ⟨hEq⟩
  subst hEq
  exact ⟨
    canonical_vacuum_adm_certificate_for.hamiltonian_constraint,
    canonical_vacuum_adm_certificate_for.momentum_constraint
  ⟩

end CATEPTMain.Certification.RelativityGR

end
