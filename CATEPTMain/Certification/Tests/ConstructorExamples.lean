import CATEPTMain.Certification.RelativityGREinsteinEquation
import CATEPTMain.Certification.RelativityGRADM
import CATEPTMain.Certification.RelativityGRMaxwellPphi2
import CATEPTMain.Certification.RelativityGRCurvedDirect
import CATEPTMain.Integration.GravitasBridge

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.ConstructorExamples

open CATEPTMain.Certification.RelativityGR
open CATEPTMain.Integration.GravitasBridge
open Gravitas

example : EinsteinEquationCertificateFor gravitasMinkowski gravitasEMStressEnergy :=
  mk_einstein_equation_certificate_for
    gravitasMinkowski
    gravitasEMStressEnergy
    canonical_electrovac_einstein_certificate.kappa
    (.lit 0)
    canonical_electrovac_einstein_equation_holds

example : EinsteinEquationCertificateFor gravitasMinkowski gravitasEMStressEnergy :=
  canonical_electrovac_einstein_certificate_for_family
    gravitasMinkowski
    gravitasEMStressEnergy
    rfl
    rfl

example : EinsteinEquationCertificateForSource gravitasMinkowski gravitasEMStressEnergy :=
  canonical_electrovac_einstein_certificate_for_source_family
    gravitasMinkowski
    gravitasEMStressEnergy
    rfl
    rfl

example : ADMConstraintCertificateFor gravitasCanonicalVacuumADM :=
  mk_adm_constraint_certificate_for
    gravitasCanonicalVacuumADM
    gravitasCanonicalVacuumADMStressDecomposition
    (.lit 0)
    canonical_vacuum_adm_hamiltonian_constraint_holds
    canonical_vacuum_adm_momentum_constraint_holds

example : ADMConstraintCertificateFor gravitasCanonicalVacuumADM :=
  canonical_vacuum_adm_certificate_for_family
    gravitasCanonicalVacuumADM
    ⟨rfl⟩

example : MaxwellPphi2Certificate :=
  mk_maxwell_pphi2_certificate
    canonical_maxwell_pphi2_model
    canonical_maxwell_pphi2_witness
    (by intro x; cases x; simp [canonical_maxwell_pphi2_model])
    (by intro a; cases a; simp [canonical_maxwell_pphi2_model])
    (by intro x a; cases x; cases a; simp [canonical_maxwell_pphi2_model])
    trivial trivial trivial trivial trivial trivial

example
    (hHodge :
      hodgeStarEM gravitasMinkowski
        (hodgeStarEM gravitasMinkowski gravitasFaradayMinkowski) =
        gravitasFaradayMinkowski) :
    CurvedGRDirectCertificate :=
  mk_curved_gr_direct_certificate
    gravitasMinkowski
    gravitasFaradayMinkowski
    gravitasEMStressEnergy
    gravitasCanonicalVacuumADM
    gravitasCanonicalVacuumADMStressDecomposition
    (.lit 0)
    canonical_electrovac_einstein_certificate.kappa
    hHodge
    gravitasCanonicalStress_covariantDivergence_zero
    canonical_electrovac_einstein_equation_holds
    canonical_vacuum_adm_hamiltonian_constraint_holds
    canonical_vacuum_adm_momentum_constraint_holds

example
    (hFixed : FixedAntisymmetric4D gravitasFaradayMinkowski)
    (hHodgeFixed :
      hodgeStarEM gravitasMinkowski
        (hodgeStarEM gravitasMinkowski gravitasFaradayMinkowski) =
        gravitasFaradayMinkowski) :
    CurvedGRDirectCertificate :=
  mk_curved_gr_direct_certificate_of_fixedAntisymmetric4D
    gravitasMinkowski
    gravitasFaradayMinkowski
    gravitasEMStressEnergy
    gravitasCanonicalVacuumADM
    gravitasCanonicalVacuumADMStressDecomposition
    (.lit 0)
    canonical_electrovac_einstein_certificate.kappa
    hFixed
    hHodgeFixed
    gravitasCanonicalStress_covariantDivergence_zero
    canonical_electrovac_einstein_equation_holds
    canonical_vacuum_adm_hamiltonian_constraint_holds
    canonical_vacuum_adm_momentum_constraint_holds

example
    (cert : CurvedGRDirectCertificate) :
    ADMConstraintCertificateFor cert.adm :=
  curved_gr_direct_to_adm_certificate_for cert

example
    (cert : CurvedGRDirectCertificate) :
    EinsteinEquationCertificateForSource cert.metric cert.stress :=
  curved_gr_direct_to_einstein_certificate_for_source cert

example
    (cert : CurvedGRDirectCertificate)
    (hSourceZero : cert.sourceTerm = .lit 0) :
    EinsteinEquationCertificateFor cert.metric cert.stress :=
  curved_gr_direct_to_einstein_certificate_for cert hSourceZero

end CATEPTMain.Certification.Tests.ConstructorExamples
