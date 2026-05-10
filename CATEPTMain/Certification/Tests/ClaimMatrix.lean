import CATEPTMain.Certification

/-!
# Claim Matrix

A claim may appear under "Implemented" only if there is a real declaration
checked below.

Future targets stay in the doc block until the corresponding declaration
exists and builds.
-/

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.ClaimMatrix

/-! ## Implemented claims -/

#check CATEPTMain.Certification.universalConsistencyCertificate

-- GR implemented surfaces
#check CATEPTMain.Certification.RelativityGR.canonical_gr_tensor
#check CATEPTMain.Certification.RelativityGR.canonical_gr_curved_maxwell
#check CATEPTMain.Certification.RelativityGR.canonical_gr_unsafe_claims_closed
#check CATEPTMain.Certification.RelativityGR.gravitasFaraday_hodgeStar_involutive
#check CATEPTMain.Certification.RelativityGR.canonical_radiation_stress_conserved
#check CATEPTMain.Certification.RelativityGR.canonical_vml_maxwell_equilibrium

/-!
## Future targets, not yet implemented as full general theorems

Do not move these into the implemented section until the named Lean declarations
exist and are audited:

* full `ElectromagneticTensor`-level `hodgeStarEM` involution;
* general curved `covariantDivergenceStressEnergy g T = 0`;
* general Einstein equation certificate `EinsteinTensor.ofMetric g = κT`;
* general ADM constraint certificate;
* Maxwell curve-space / pphi2 reconstruction certificate.
-/

end CATEPTMain.Certification.Tests.ClaimMatrix
