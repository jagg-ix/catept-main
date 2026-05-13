import CATEPTMain.Certification.UniversalCertificate
import CATEPTMain.Certification.RelativityGRStressConservation
import CATEPTMain.Certification.RelativityGRVMLMaxwell
import CATEPTMain.Certification.RelativityGRCurvedDirect
import CATEPTMain.Certification.RelativityGRBianchiBridge
import CATEPTMain.Certification.RelativityGRBianchiFRW
import CATEPTMain.Certification.RelativityGRSmoothPseudoRiemannian
import CATEPTMain.Certification.RelativityGRSmoothConnection
import CATEPTMain.Certification.RelativityGRSmoothTensorField
import CATEPTMain.Certification.RelativityGRLeviCivitaDivergence
import CATEPTMain.Certification.RelativityGRSmoothBianchi

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
abbrev bianchiFRWCertifiedParameter := @FRWCertifiedParameter
abbrev bianchiFRWCertifiedData := @frwCertifiedCurvedGRData
abbrev bianchiFRWCurvedDirect := @frwCurvedGRDirectCertificate
abbrev lc001SmoothPRManifold := @SmoothPseudoRiemannianManifold
abbrev lc001SmoothMinkowski := smoothMinkowskiSpacetime
abbrev lc002SmoothConnection := @SmoothConnection
abbrev lc002IsTorsionFree := @IsTorsionFree
abbrev lc002IsMetricCompatible := @IsMetricCompatible
abbrev lc002IsLeviCivitaConnection := @IsLeviCivitaConnection
abbrev lc003SmoothTensorField := @SmoothTensorField
abbrev lc003SmoothEinsteinTensor := @SmoothEinsteinTensor
abbrev lc003smoothEinsteinTensor := @smoothEinsteinTensor
abbrev lc004LeviCivitaDivergence := @leviCivitaDivergence
abbrev lc004LeviCivitaDivergenceEinsteinTensor := @leviCivitaDivergenceEinsteinTensor
abbrev lc005SmoothSecondBianchiIdentity := @SmoothSecondBianchiIdentity
abbrev lc005smooth_second_bianchi_of_leviCivita := @smooth_second_bianchi_of_leviCivita

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

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiFRWCertifiedParameter' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiFRWCertifiedParameter

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiFRWCertifiedData' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiFRWCertifiedData

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.bianchiFRWCurvedDirect' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.bianchiFRWCurvedDirect

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc001SmoothPRManifold' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc001SmoothPRManifold

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc001SmoothMinkowski' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc001SmoothMinkowski

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc002SmoothConnection' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc002SmoothConnection

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc002IsTorsionFree' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc002IsTorsionFree

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc002IsMetricCompatible' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc002IsMetricCompatible

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc002IsLeviCivitaConnection' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc002IsLeviCivitaConnection

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc003SmoothTensorField' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc003SmoothTensorField

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc003SmoothEinsteinTensor' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc003SmoothEinsteinTensor

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc003smoothEinsteinTensor' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc003smoothEinsteinTensor

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc004LeviCivitaDivergence' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc004LeviCivitaDivergence

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc004LeviCivitaDivergenceEinsteinTensor' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc004LeviCivitaDivergenceEinsteinTensor

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc005SmoothSecondBianchiIdentity' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc005SmoothSecondBianchiIdentity

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc005smooth_second_bianchi_of_leviCivita' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc005smooth_second_bianchi_of_leviCivita

end

end CATEPTMain.Certification.Tests.AxiomGuards
