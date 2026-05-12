import CATEPTMain.Certification.RelativityGRCurvedDirect

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.CurvedDirectExamples

open CATEPTMain.Certification.RelativityGR

#check CurvedGRDirectCertificate
#check curved_gr_direct_full_claim
#check mk_curved_gr_direct_certificate_claim
#check mk_curved_gr_direct_certificate_of_fixedAntisymmetric4D_claim
#check canonical_curved_gr_direct_certificate_of_fixedAntisymmetric4D_claim

example (cert : CurvedGRDirectCertificate) :
    hodgeStarEM cert.metric (hodgeStarEM cert.metric cert.faraday) = cert.faraday :=
  (curved_gr_direct_full_claim cert).1

end CATEPTMain.Certification.Tests.CurvedDirectExamples
