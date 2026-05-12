import CATEPTMain.Certification.RelativityGRADM
import CATEPTMain.Certification.RelativityGRUnsafeFixes

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-!
# Witness-free ADM-constraint family
(WF-GR-007 / WF-GR-008)

This module exposes a typed admissibility predicate
`IsCertifiedADMData` parameterized by an ADM decomposition together with its
stress decomposition and source term. The predicate bundles the two
obligations characterising an ADM-constraint solution:

* the Hamiltonian-constraint residual identity (vacuum vs. sourced),
* the momentum-constraint residual identity (vacuum vs. sourced).

A constructor `adm_certificate_for_data` lifts any admissible bundle into the
indexed certificate surface `ADMConstraintCertificateFor`. The canonical
Minkowski vacuum instance is discharged from the existing
`gravitasCanonicalVacuumADM_*_residual_exact` theorems.
-/

/-- Umbrella admissibility predicate bundling the two ADM-constraint
obligations needed to recognise `(adm, admStress, sourceTerm)` as a valid
ADM-constraint solution input. -/
structure IsCertifiedADMData
    (adm : ADMDecomposition)
    (admStress : ADMStressEnergyDecomposition)
    (sourceTerm : Expr) : Prop where
  hamiltonian_residual :
    (solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint
  momentum_residual :
    (solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm admStress sourceTerm).momentumConstraints

/-- Assemble an indexed ADM-constraint certificate from any admissible
ADM data bundle. This is the leverage-map `adm_certificate_for_data`
constructor. -/
def adm_certificate_for_data
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Expr}
    (h : IsCertifiedADMData adm admStress sourceTerm) :
    ADMConstraintCertificateFor adm where
  stressDecomposition := admStress
  sourceTerm := sourceTerm
  hamiltonian_constraint := h.hamiltonian_residual
  momentum_constraint := h.momentum_residual

/-- Full-claim projection: any admissible ADM data bundle yields the
two-conjunction direct claim (Hamiltonian residual identity, momentum residual
identity). -/
theorem adm_data_full_claim
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Expr}
    (h : IsCertifiedADMData adm admStress sourceTerm) :
    ((solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint) ∧
    ((solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm admStress sourceTerm).momentumConstraints) :=
  ⟨h.hamiltonian_residual, h.momentum_residual⟩

/-- Canonical Minkowski vacuum ADM data instance, discharged from the
existing `gravitasCanonicalVacuumADM_*_residual_exact` theorems. -/
theorem canonical_minkowski_is_certified_adm_data :
    IsCertifiedADMData
      gravitasCanonicalVacuumADM
      gravitasCanonicalVacuumADMStressDecomposition
      (.lit 0) where
  hamiltonian_residual := gravitasCanonicalVacuumADM_hamiltonian_residual_exact
  momentum_residual := gravitasCanonicalVacuumADM_momentum_residual_exact

/-- Canonical indexed ADM-constraint certificate assembled from the canonical
Minkowski vacuum ADM data bundle. -/
def canonical_adm_certificate_of_data :
    ADMConstraintCertificateFor gravitasCanonicalVacuumADM :=
  adm_certificate_for_data canonical_minkowski_is_certified_adm_data

/-- Concrete canonical full-claim specialization. -/
theorem canonical_adm_data_full_claim :
    ((solveVacuumADMEquations gravitasCanonicalVacuumADM).hamiltonianConstraint =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).hamiltonianConstraint) ∧
    ((solveVacuumADMEquations gravitasCanonicalVacuumADM).momentumConstraints =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).momentumConstraints) :=
  adm_data_full_claim canonical_minkowski_is_certified_adm_data

end CATEPTMain.Certification.RelativityGR

end
