import CATEPTMain.Certification.RelativityGRHodgeTensor
import CATEPTMain.Certification.RelativityGRCovariantDivergence
import CATEPTMain.Certification.RelativityGRResiduals
import CATEPTMain.Certification.RelativityGREinsteinEquation
import CATEPTMain.Certification.RelativityGRADM
import CATEPTMain.Certification.RelativityGRVMLMaxwell
import CATEPTMain.Certification.RelativityGRMaxwellPphi2
import CATEPTMain.Certification.RelativityGRCurvedDirect
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiContractedCertificate
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiStress
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiCurvedDirect
import CATEPTMain.Certification.RelativityGRFRWDerivedTargets
import CATEPTMain.Certification.RelativityGRSmoothFRWDerivedBianchi
import CATEPTMain.Certification.RelativityGRSmoothFRWDerivedStress
import CATEPTMain.Certification.RelativityGRFRWMatterModel
import CATEPTMain.Certification.RelativityGRSmoothFRWCurvedDirect
import CATEPTMain.Certification.RelativityGREinsteinDivergenceLinearity
import CATEPTMain.Certification.UniversalCertificate

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
#check CATEPTMain.Certification.RelativityGR.hodgeStarEM_involutive_of_fixedAntisymmetric4D
#check CATEPTMain.Certification.RelativityGR.gravitasFaradayMinkowski_fixedAntisymmetric4D
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
#check CATEPTMain.Certification.RelativityGR.mk_curved_gr_direct_certificate_of_fixedAntisymmetric4D
#check CATEPTMain.Certification.RelativityGR.mk_curved_gr_direct_certificate_of_fixedAntisymmetric4D_claim
#check CATEPTMain.Certification.RelativityGR.canonical_curved_gr_direct_certificate_of_fixedAntisymmetric4D
#check CATEPTMain.Certification.RelativityGR.canonical_curved_gr_direct_certificate_of_fixedAntisymmetric4D_claim
#check CATEPTMain.Certification.RelativityGR.curved_gr_direct_full_claim

/-! ## Implemented smooth Minkowski / FRW / Einstein-divergence claims -/

#check CATEPTMain.Certification.RelativityGR.gravitasMinkowski_contractedBianchiCertificate_from_smooth
#check CATEPTMain.Certification.RelativityGR.gravitasMinkowski_hasStressConservation_from_smooth
#check CATEPTMain.Certification.RelativityGR.gravitasMinkowski_curvedGRDirectCertificate_from_smooth
#check CATEPTMain.Certification.RelativityGR.FRWRawParameter
#check CATEPTMain.Certification.RelativityGR.frw_hasContractedBianchi_from_smooth
#check CATEPTMain.Certification.RelativityGR.frw_hasStressConservation_from_smooth_of_raw
#check CATEPTMain.Certification.RelativityGR.frwDerivedEFETarget_from_smooth_of_raw
#check CATEPTMain.Certification.RelativityGR.FRWMatterModel
#check CATEPTMain.Certification.RelativityGR.frw_einsteinEquationHolds_from_raw
#check CATEPTMain.Certification.RelativityGR.frwDerivedEFETarget_from_matter
#check CATEPTMain.Certification.RelativityGR.frwCertifiedCurvedGRData_from_smooth_of_raw
#check CATEPTMain.Certification.RelativityGR.frwCurvedGRDirectCertificate_from_smooth_of_raw
#check CATEPTMain.Certification.RelativityGR.LiteralEinsteinTensorEquation
#check CATEPTMain.Certification.RelativityGR.divergence_compat_of_literal_tensor_equation

/-! ## Implemented universal fields -/

#check CATEPTMain.Certification.universalConsistencyCertificate
#check CATEPTMain.Certification.universal_curved_maxwell_bridge_certified
#check CATEPTMain.Certification.universal_vml_maxwell_equilibrium_certified

/-!
## Pending

Do not move these into the implemented section until the named Lean declarations
exist and are audited:

* derive `SmoothFRWRepresentsGravitasFRW p` automatically from
  `FRWRawParameter` data, removing the explicit representation-witness
  hypothesis in `frw_hasContractedBianchi_from_smooth` and
  `frw_hasStressConservation_from_smooth_of_raw`;
* derive `FRWMatterModel p` from perfect-fluid continuity equations,
  removing the explicit divergence-compat hypothesis in
  `frw_einsteinEquationHolds_from_raw`;
* derive FRW Hodge / Einstein / ADM closures automatically, removing the
  explicit `hHodge`, `hEinstein`, `hADM` hypotheses in
  `frwCertifiedCurvedGRData_from_smooth_of_raw` and
  `frwCurvedGRDirectCertificate_from_smooth_of_raw`;
* remove `divergence_compat_witness` from `LiteralEinsteinTensorEquation`
  (the bridge field is gone from the structure; only stale doc-comment
  mentions remain to be scrubbed);
* prove full second-Bianchi ⇒ contracted-Bianchi from Riemann symmetries
  for arbitrary metrics (canonical Minkowski is done as a named surface
  via `smoothMinkowski_contracted_bianchi_nonvacuous` but still routes
  through generic LC-006).
-/

end CATEPTMain.Certification.Tests.ClaimMatrix
