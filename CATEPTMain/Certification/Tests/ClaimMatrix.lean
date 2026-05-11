import CATEPTMain.Certification
import CATEPTMain.Certification.RelativityGRCurvedDirect

/-!
# Claim Matrix

A claim may appear under "Implemented" only if there is a real declaration
checked below.

Future targets stay in the doc block until the corresponding declaration
exists and builds.
-/

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.ClaimMatrix

/-! ## Implemented canonical / typed claims -/

#check CATEPTMain.Certification.RelativityGR.hodgeStarEM_involutive
#check CATEPTMain.Certification.RelativityGR.hodgeStarEM_double_components_fixedAntisymmetric4D
#check CATEPTMain.Certification.RelativityGR.gravitasCanonicalStress_covariantDivergence_zero
#check CATEPTMain.Certification.RelativityGR.canonical_einstein_residual
#check CATEPTMain.Certification.RelativityGR.canonical_adm_residual
#check CATEPTMain.Certification.RelativityGR.canonical_electrovac_einstein_certificate
#check CATEPTMain.Certification.RelativityGR.canonical_vacuum_adm_certificate
#check CATEPTMain.Certification.RelativityGR.canonical_vml_maxwell_equilibrium
#check CATEPTMain.Certification.RelativityGR.canonical_maxwell_pphi2_certificate
#check CATEPTMain.Certification.RelativityGR.mk_einstein_equation_certificate
#check CATEPTMain.Certification.RelativityGR.mk_adm_constraint_certificate
#check CATEPTMain.Certification.RelativityGR.mk_maxwell_pphi2_certificate
#check CATEPTMain.Certification.RelativityGR.CurvedGRDirectCertificate
#check CATEPTMain.Certification.RelativityGR.mk_curved_gr_direct_certificate
#check CATEPTMain.Certification.RelativityGR.curved_gr_direct_full_claim

/-! ## Implemented universal fields -/

#check CATEPTMain.Certification.universalConsistencyCertificate
#check CATEPTMain.Certification.universal_curved_maxwell_bridge_certified
#check CATEPTMain.Certification.universal_vml_maxwell_equilibrium_certified

/-!
## Future general theorems

Do not move these into the implemented section until the named Lean declarations
exist and are audited:

Constructor-level assumption-indexed generalization is implemented; the items
below remain the outstanding witness-free derivation goals.

* witness-free full tensor equality `hodgeStarEM g (hodgeStarEM g F) = F`;
* witness-free curved `covariantDivergenceStressEnergy g T = 0`;
* witness-free Einstein equation derivation `EinsteinTensor.ofMetric g = κT`;
* witness-free ADM constraints derivation;
* full Maxwell curve-space / pphi2 reconstruction theorem (beyond the current interface-level certificate).
-/

end CATEPTMain.Certification.Tests.ClaimMatrix
