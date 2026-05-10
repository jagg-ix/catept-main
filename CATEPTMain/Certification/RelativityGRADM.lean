import CATEPTMain.Certification.RelativityGRUnsafeFixes

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- Typed certificate for ADM Hamiltonian and momentum constraints. -/
structure ADMConstraintCertificate where
  hamiltonian_constraint : Prop
  momentum_constraint : Prop

/-- Canonical vacuum ADM constraint certificate on the Minkowski slicing. -/
def canonical_vacuum_adm_certificate : ADMConstraintCertificate where
  hamiltonian_constraint :=
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).hamiltonianConstraint =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).hamiltonianConstraint
  momentum_constraint :=
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).momentumConstraints =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).momentumConstraints

/-- The canonical certificate satisfies its Hamiltonian constraint field. -/
theorem canonical_vacuum_adm_hamiltonian_constraint_holds :
    canonical_vacuum_adm_certificate.hamiltonian_constraint := by
  simpa [canonical_vacuum_adm_certificate] using
    gravitasCanonicalVacuumADM_hamiltonian_residual_exact

/-- The canonical certificate satisfies its momentum-constraint field. -/
theorem canonical_vacuum_adm_momentum_constraint_holds :
    canonical_vacuum_adm_certificate.momentum_constraint := by
  simpa [canonical_vacuum_adm_certificate] using
    gravitasCanonicalVacuumADM_momentum_residual_exact

end CATEPTMain.Certification.RelativityGR

end