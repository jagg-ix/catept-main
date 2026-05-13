import CATEPTMain.Certification.RelativityGRBianchiBridge

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRBianchiCurvatureIdentity

open CATEPTMain.Certification.RelativityGR
open CATEPTMain.Integration.GravitasBridge
open Gravitas

/-! # BIANCHI-009 — second Bianchi identity ⇒ contracted Bianchi certificate

Test surface for the named hypothesis `SecondBianchiIdentity` and the
constructor `contractedBianchiCertificate_of_secondBianchi`, the
headline implication `ContractedBianchiFromSecondBianchi`, the
admissibility-layer upgrade `hasContractedBianchi_of_secondBianchi`,
and the canonical Minkowski witness
`gravitasMinkowski_secondBianchiIdentity`. -/

#check SecondBianchiIdentity
#check ContractedBianchiFromSecondBianchi
#check contractedBianchiCertificate_of_secondBianchi
#check contractedBianchiFromSecondBianchi
#check hasContractedBianchi_of_secondBianchi
#check gravitasMinkowski_secondBianchiIdentity

/-- Constructor route: second Bianchi ⇒ contracted Bianchi certificate. -/
example
    {g : MetricTensor}
    (h : SecondBianchiIdentity g) :
    ContractedBianchiCertificate g :=
  contractedBianchiCertificate_of_secondBianchi h

/-- Headline-implication route. -/
example
    {g : MetricTensor}
    (h : SecondBianchiIdentity g) :
    ContractedBianchiCertificate g :=
  contractedBianchiFromSecondBianchi h

/-- Admissibility-layer route: second Bianchi ⇒ `HasContractedBianchi g`. -/
example
    {g : MetricTensor}
    (h : SecondBianchiIdentity g) :
    HasContractedBianchi g :=
  hasContractedBianchi_of_secondBianchi h

/-- Canonical Minkowski: the second Bianchi witness holds. -/
example : SecondBianchiIdentity gravitasMinkowski :=
  gravitasMinkowski_secondBianchiIdentity

/-- Canonical Minkowski: from the second Bianchi witness recover the
contracted Bianchi certificate. -/
example : ContractedBianchiCertificate gravitasMinkowski :=
  contractedBianchiCertificate_of_secondBianchi
    gravitasMinkowski_secondBianchiIdentity

end CATEPTMain.Certification.Tests.GRBianchiCurvatureIdentity

end
