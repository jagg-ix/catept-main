import CATEPTMain.Certification.UniversalCertificate
import CATEPTMain.Certification.RelativityGRStressConservation
import CATEPTMain.Certification.RelativityGRVMLMaxwell
import CATEPTMain.Certification.RelativityGRCurvedDirect

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

end

end CATEPTMain.Certification.Tests.AxiomGuards
