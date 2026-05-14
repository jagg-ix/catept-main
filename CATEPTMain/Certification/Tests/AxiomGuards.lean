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
import CATEPTMain.Certification.RelativityGRSmoothContractedBianchi
import CATEPTMain.Certification.RelativityGRSmoothGravitasBridge
import CATEPTMain.Certification.RelativityGRSmoothContractedBianchiCertificate
import CATEPTMain.Certification.RelativityGRSmoothStressConservation
import CATEPTMain.Certification.RelativityGRSmoothFRW
import CATEPTMain.Certification.RelativityGRSmoothCurvedDirect
import CATEPTMain.Certification.RelativityGRSmoothLeviCivitaBridge
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiBianchi
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiCoordinateBridge
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiContractedCertificate
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiStress
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiCurvedDirect
import CATEPTMain.Certification.RelativityGRFRWDerivedTargets
import CATEPTMain.Certification.RelativityGRSmoothFRWDerivedBianchi
import CATEPTMain.Certification.RelativityGRSmoothFRWDerivedStress
import CATEPTMain.Certification.RelativityGRFRWMatterModel
import CATEPTMain.Certification.RelativityGRSmoothFRWCurvedDirect
import CATEPTMain.Certification.RelativityGRFRWChartSymbolicContract
import CATEPTMain.Certification.RelativityGREinsteinDivergenceLinearity

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
abbrev lc006zeroSmoothTensorField := @zeroSmoothTensorField
abbrev lc006smooth_contracted_bianchi := @smooth_contracted_bianchi
abbrev lc006smoothEinsteinTensor_minkowski_components_zero := @smoothEinsteinTensor_minkowski_components_zero
abbrev lc006leviCivitaDivergenceEinsteinTensor_minkowski_components_zero := @leviCivitaDivergenceEinsteinTensor_minkowski_components_zero
abbrev lc006MinkowskismoothMinkowskiConnection := smoothMinkowskiConnection
abbrev lc006MinkowskismoothMinkowski_isLeviCivita := smoothMinkowski_isLeviCivita
abbrev lc006MinkowskileviCivitaDivergenceEinstein_zero := smoothMinkowski_leviCivitaDivergenceEinstein_zero
abbrev lc006Minkowskicontracted_bianchi_nonvacuous := smoothMinkowski_contracted_bianchi_nonvacuous
abbrev lc007coordinateArrayOfSmoothTensor := @coordinateArrayOfSmoothTensor
abbrev lc007GravitasRepresentsSmoothMetric := @GravitasRepresentsSmoothMetric
abbrev lc007SymbolicEinsteinDivergenceRepresentsSmooth := @SymbolicEinsteinDivergenceRepresentsSmooth
abbrev lc007gravitasMinkowski_represents_smoothMinkowski := gravitasMinkowski_represents_smoothMinkowski
abbrev lc007symbolic_contracted_bianchi_of_smooth := @symbolic_contracted_bianchi_of_smooth
abbrev lc007MinkowskicoordinateArray_zero := coordinateArrayOfSmoothMinkowskiEinsteinDivergence_zero
abbrev lc007Minkowskisymbolic_divergence_matches_smooth := gravitasMinkowski_symbolic_divergence_matches_smooth
abbrev lc007MinkowskisymbolicEinsteinDivergenceRepresentsSmooth := gravitasMinkowski_symbolicEinsteinDivergenceRepresentsSmooth
abbrev lc008contractedBianchiCertificate_of_smooth_leviCivita := @contractedBianchiCertificate_of_smooth_leviCivita
abbrev lc008MinkowskisymbolicRepresents_smooth := gravitasMinkowski_symbolicRepresents_smooth
abbrev lc008Minkowskicertificate_from_smooth := gravitasMinkowski_contractedBianchiCertificate_from_smooth
abbrev lc009hasStressConservation_of_smooth_leviCivita_einstein := @hasStressConservation_of_smooth_leviCivita_einstein
abbrev lc009kappa_var_ne_zero_lit := kappa_var_ne_zero_lit
abbrev lc009Minkowskistress_from_smooth := gravitasMinkowski_hasStressConservation_from_smooth
abbrev lc011MinkowskicertifiedCurvedGRData_from_smooth := gravitasMinkowski_certifiedCurvedGRData_from_smooth
abbrev lc011MinkowskicurvedGRDirectCertificate_from_smooth := gravitasMinkowski_curvedGRDirectCertificate_from_smooth
abbrev frwDerivedFRWRawParameter := @FRWRawParameter
abbrev frwDerivedfrwRawMetricFamily := @frwRawMetricFamily
abbrev frwDerivedBianchiTarget := @FRWDerivedBianchiTarget
abbrev frwDerivedEFETarget := @FRWDerivedEFETarget
abbrev frwDerivedParameter_of_targets := @frwParameter_of_derived_targets
abbrev frwSmoothDerivedBianchiRepr := @SmoothFRWRepresentsGravitasFRW
abbrev frwSmoothDerivedBianchi := @frw_hasContractedBianchi_from_smooth
abbrev frwSmoothDerivedBianchiTarget := @frwDerivedBianchiTarget_from_smooth
abbrev frwSmoothRepresentsOfRaw := @smoothFRW_represents_gravitasFRW_of_raw
abbrev frwSmoothDerivedStress := @frw_hasStressConservation_from_smooth_of_raw
abbrev frwSmoothDerivedEFETarget := @frwDerivedEFETarget_from_smooth_of_raw
abbrev frwMatterModel := @FRWMatterModel
abbrev frwEFEFromRaw := @frw_einsteinEquationHolds_from_raw
abbrev frwDerivedEFETargetFromMatter := @frwDerivedEFETarget_from_matter
abbrev frwSmoothCurvedDataOfRaw := @frwCertifiedCurvedGRData_from_smooth_of_raw
abbrev frwSmoothCurvedDirectOfRaw := @frwCurvedGRDirectCertificate_from_smooth_of_raw
abbrev frwChartCompatible := @FRWChartCompatible
abbrev frwSymbolicDivergenceSimplifies := @FRWSymbolicDivergenceSimplifies
abbrev frwSmoothRepresentsOfRawNamed := @smoothFRW_represents_gravitasFRW_of_raw_named
abbrev edlLiteralTensorEquation := @LiteralEinsteinTensorEquation
abbrev edlCovariantDivergenceLinear := @CovariantDivergenceLinear
abbrev edlCouplingCovariantlyConstant := @CouplingCovariantlyConstant
abbrev edlDivergenceCompatOfLiteral := @divergence_compat_of_literal_tensor_equation
abbrev lc010smoothFRWFamily := @smoothFRWFamily
abbrev lc010frwLeviCivitaConnection := @frwLeviCivitaConnection
abbrev lc010frwConnection_isLeviCivita := @frwConnection_isLeviCivita
abbrev lc010frw_bianchiAdmissible := frw_bianchiAdmissible
abbrev lc011certifiedCurvedGRData_of_smooth_leviCivita := @certifiedCurvedGRData_of_smooth_leviCivita
abbrev lc011curvedGRDirectCertificate_of_smooth_leviCivita := @curvedGRDirectCertificate_of_smooth_leviCivita
abbrev lcBridgeCertifiedSmoothContractedBianchi := @certified_smooth_contracted_bianchi

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

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc003smoothEinsteinTensor' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc003smoothEinsteinTensor

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc004LeviCivitaDivergence' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc004LeviCivitaDivergence

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc004LeviCivitaDivergenceEinsteinTensor' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc004LeviCivitaDivergenceEinsteinTensor

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc005SmoothSecondBianchiIdentity' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc005SmoothSecondBianchiIdentity

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc005smooth_second_bianchi_of_leviCivita' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc005smooth_second_bianchi_of_leviCivita

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc006zeroSmoothTensorField' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc006zeroSmoothTensorField

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc006smooth_contracted_bianchi' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc006smooth_contracted_bianchi

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc006smoothEinsteinTensor_minkowski_components_zero' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc006smoothEinsteinTensor_minkowski_components_zero

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc006leviCivitaDivergenceEinsteinTensor_minkowski_components_zero' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc006leviCivitaDivergenceEinsteinTensor_minkowski_components_zero

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc006MinkowskismoothMinkowskiConnection' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc006MinkowskismoothMinkowskiConnection

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc006MinkowskismoothMinkowski_isLeviCivita' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc006MinkowskismoothMinkowski_isLeviCivita

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc006MinkowskileviCivitaDivergenceEinstein_zero' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc006MinkowskileviCivitaDivergenceEinstein_zero

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc006Minkowskicontracted_bianchi_nonvacuous' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc006Minkowskicontracted_bianchi_nonvacuous

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc007coordinateArrayOfSmoothTensor' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc007coordinateArrayOfSmoothTensor

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc007GravitasRepresentsSmoothMetric' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.lc007GravitasRepresentsSmoothMetric

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc007SymbolicEinsteinDivergenceRepresentsSmooth' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc007SymbolicEinsteinDivergenceRepresentsSmooth

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc007gravitasMinkowski_represents_smoothMinkowski' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc007gravitasMinkowski_represents_smoothMinkowski

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc007symbolic_contracted_bianchi_of_smooth' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc007symbolic_contracted_bianchi_of_smooth

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc007MinkowskicoordinateArray_zero' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc007MinkowskicoordinateArray_zero

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc007Minkowskisymbolic_divergence_matches_smooth' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc007Minkowskisymbolic_divergence_matches_smooth

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc007MinkowskisymbolicEinsteinDivergenceRepresentsSmooth' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc007MinkowskisymbolicEinsteinDivergenceRepresentsSmooth

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc008contractedBianchiCertificate_of_smooth_leviCivita' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc008contractedBianchiCertificate_of_smooth_leviCivita

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc008MinkowskisymbolicRepresents_smooth' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc008MinkowskisymbolicRepresents_smooth

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc008Minkowskicertificate_from_smooth' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc008Minkowskicertificate_from_smooth

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc009hasStressConservation_of_smooth_leviCivita_einstein' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc009hasStressConservation_of_smooth_leviCivita_einstein

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc009kappa_var_ne_zero_lit' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc009kappa_var_ne_zero_lit

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc009Minkowskistress_from_smooth' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc009Minkowskistress_from_smooth

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc011MinkowskicertifiedCurvedGRData_from_smooth' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc011MinkowskicertifiedCurvedGRData_from_smooth

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc011MinkowskicurvedGRDirectCertificate_from_smooth' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc011MinkowskicurvedGRDirectCertificate_from_smooth

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwDerivedFRWRawParameter' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.frwDerivedFRWRawParameter

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwDerivedfrwRawMetricFamily' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwDerivedfrwRawMetricFamily

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwDerivedBianchiTarget' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwDerivedBianchiTarget

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwDerivedEFETarget' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwDerivedEFETarget

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwDerivedParameter_of_targets' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwDerivedParameter_of_targets

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwSmoothDerivedBianchiRepr' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwSmoothDerivedBianchiRepr

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwSmoothDerivedBianchi' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwSmoothDerivedBianchi

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwSmoothDerivedBianchiTarget' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwSmoothDerivedBianchiTarget

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwSmoothDerivedStress' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwSmoothDerivedStress

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwSmoothDerivedEFETarget' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwSmoothDerivedEFETarget

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwMatterModel' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwMatterModel

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwEFEFromRaw' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwEFEFromRaw

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwDerivedEFETargetFromMatter' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwDerivedEFETargetFromMatter

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwSmoothCurvedDataOfRaw' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwSmoothCurvedDataOfRaw

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwSmoothCurvedDirectOfRaw' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwSmoothCurvedDirectOfRaw

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwChartCompatible' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwChartCompatible

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwSymbolicDivergenceSimplifies' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwSymbolicDivergenceSimplifies

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.frwSmoothRepresentsOfRawNamed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.frwSmoothRepresentsOfRawNamed

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.edlLiteralTensorEquation' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.edlLiteralTensorEquation

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.edlCovariantDivergenceLinear' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.edlCovariantDivergenceLinear

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.edlCouplingCovariantlyConstant' does not depend on any axioms -/
#guard_msgs in
#print axioms GuardAlias.edlCouplingCovariantlyConstant

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.edlDivergenceCompatOfLiteral' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.edlDivergenceCompatOfLiteral

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc010smoothFRWFamily' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc010smoothFRWFamily

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc010frwLeviCivitaConnection' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc010frwLeviCivitaConnection

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc010frwConnection_isLeviCivita' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc010frwConnection_isLeviCivita

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc010frw_bianchiAdmissible' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc010frw_bianchiAdmissible

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc011certifiedCurvedGRData_of_smooth_leviCivita' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc011certifiedCurvedGRData_of_smooth_leviCivita

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lc011curvedGRDirectCertificate_of_smooth_leviCivita' depends on axioms: [propext,
 Classical.choice,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lc011curvedGRDirectCertificate_of_smooth_leviCivita

/-- info: 'CATEPTMain.Certification.Tests.AxiomGuards.GuardAlias.lcBridgeCertifiedSmoothContractedBianchi' depends on axioms: [propext,
 Quot.sound] -/
#guard_msgs in
#print axioms GuardAlias.lcBridgeCertifiedSmoothContractedBianchi

end

end CATEPTMain.Certification.Tests.AxiomGuards
