import CATEPTMain.Certification.UniversalCertificate

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.UniversalFields

open CATEPTMain.Certification

#check universalConsistencyCertificate.curvedMaxwell
#check universalConsistencyCertificate.vmlMaxwell

example :
    universalConsistencyCertificate.curvedMaxwell =
      RelativityGR.canonical_gr_curved_maxwell :=
  universal_curved_maxwell_bridge_certified

example :
    universalConsistencyCertificate.vmlMaxwell =
      RelativityGR.canonical_vml_maxwell_equilibrium :=
  universal_vml_maxwell_equilibrium_certified

end CATEPTMain.Certification.Tests.UniversalFields
