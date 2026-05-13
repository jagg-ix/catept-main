import CATEPTMain.Certification.UniversalCertificate
import CATEPTMain.Certification.RelativityGRStressConservation
import CATEPTMain.Certification.RelativityGRVMLMaxwell
import CATEPTMain.Certification.RelativityGRCurvedDirect
import CATEPTMain.Certification.RelativityGRBianchiBridge
import CATEPTMain.Certification.RelativityGRBianchiFRW

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.AxiomGuards

open CATEPTMain.Certification
open CATEPTMain.Certification.RelativityGR

noncomputable section

namespace GuardAlias

abbrev ucc := universalConsistencyCertificate
abbrev vml := canonical_vml_maxwell_equilibrium
abbrev curvedClaim := canonical_curved_gr_direct_certificate_of_fixedAntisymmetric4D_claim
abbrev maxwellToStress := maxwell_implies_stress_conservation_of_contract
abbrev scopeBoundary := certificationScopeBoundary

-- BIANCHI guard aliases
abbrev bianchiMinkContracted := gravitasMinkowski_contractedBianchiCertificate
abbrev bianchiMinkEinsteinDivZero := gravitasMinkowski_einstein_covariantDivergence_zero
abbrev bianchiMinkEFE := gravitasMinkowski_einsteinEquationHolds
abbrev bianchiStressTheorem := stress_conservation_of_contracted_bianchi_and_einstein
abbrev bianchiHasStressConsCtor := @hasStressConservation_of_bianchi_einstein
abbrev bianchiMinkHasStressCons := gravitasMinkowski_hasStressConservation_via_bianchi
abbrev bianchiCertOfHas := @contractedBianchiCertificate_of_hasContractedBianchi
abbrev bianchiCurvedGRDataCtor := @certifiedCurvedGRData_of_bianchi_stress
abbrev bianchiHasCBToStress := @hasStressConservation_of_hasContractedBianchi
abbrev bianchiMinkHasCBToStress := gravitasMinkowski_hasStressConservation_via_hasContractedBianchi
abbrev bianchiFamilyAdmissible := @gravitasMinkowskiFamily_bianchiAdmissible
abbrev bianchiFamilyProject := @hasContractedBianchi_of_family
abbrev bianchiFamilyStress := @hasStressConservation_of_family
abbrev bianchiSecondCertCtor := @contractedBianchiCertificate_of_secondBianchi
abbrev bianchiSecondImplication := @contractedBianchiFromSecondBianchi
abbrev bianchiSecondHasCB := @hasContractedBianchi_of_secondBianchi
abbrev bianchiMinkSecond := gravitasMinkowski_secondBianchiIdentity
abbrev bianchiLiteralEFE := @LiteralEinsteinEquationHolds
abbrev bianchiLiteralEFEDemote := @divergence_compat_of_literal_einstein_equation
abbrev bianchiFRWMetricFamily := @frwMetricFamily
abbrev bianchiFRWStressFamily := @frwStressFamily
abbrev bianchiFRWAdmissible := @frwMetricFamily_bianchiAdmissible
abbrev bianchiFRWEFE := @frwStressFamily_einsteinEquationHolds
abbrev bianchiFRWStressCons := @frwHasStressConservation

end GuardAlias

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.ucc' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.ucc

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.vml' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.vml

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.curvedClaim' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.curvedClaim

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.maxwellToStress' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.maxwellToStress

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.scopeBoundary' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.scopeBoundary

/-! ### BIANCHI bridge axiom guards -/

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiMinkContracted' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiMinkContracted

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiMinkEinsteinDivZero' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiMinkEinsteinDivZero

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiMinkEFE' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiMinkEFE

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiStressTheorem' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiStressTheorem

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiHasStressConsCtor' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiHasStressConsCtor

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiMinkHasStressCons' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiMinkHasStressCons

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiCertOfHas' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiCertOfHas

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiCurvedGRDataCtor' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiCurvedGRDataCtor

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiHasCBToStress' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiHasCBToStress

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiMinkHasCBToStress' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiMinkHasCBToStress

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiFamilyAdmissible' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiFamilyAdmissible

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiFamilyProject' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiFamilyProject

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiFamilyStress' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiFamilyStress

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiSecondCertCtor' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiSecondCertCtor

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiSecondImplication' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiSecondImplication

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiSecondHasCB' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiSecondHasCB

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiMinkSecond' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiMinkSecond

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiLiteralEFE' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiLiteralEFE

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiLiteralEFEDemote' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiLiteralEFEDemote

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiFRWMetricFamily' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiFRWMetricFamily

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiFRWStressFamily' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiFRWStressFamily

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiFRWAdmissible' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiFRWAdmissible

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiFRWEFE' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiFRWEFE

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiFRWStressCons' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiFRWStressCons

end

end CATEPTMain.Certification.Tests.AxiomGuards
