/-
# Canonical CurvedDirect certificate from the smooth Levi-Civita route

This file routes the smooth-side Minkowski Bianchi/stress witness
(PR4/PR5) into the canonical certified curved-GR data umbrella,
replacing the Maxwell-route stress closure of
`canonical_certified_curved_gr_data` with the smooth-route closure
`gravitasMinkowski_hasStressConservation_from_smooth`.

The remaining three sector closures (Hodge, Einstein, ADM) are reused
verbatim from the canonical witness.  The resulting umbrella is then
fed into `curved_gr_direct_certificate_of_certified_data` to produce
a full `CurvedGRDirectCertificate` through the smooth route.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothMinkowskiCurvedDirect`
  passes;
* `#check gravitasMinkowski_certifiedCurvedGRData_from_smooth`
  elaborates;
* `#check gravitasMinkowski_curvedGRDirectCertificate_from_smooth`
  elaborates;
* `#print axioms` reports only standard kernel axioms.
-/

import CATEPTMain.Certification.RelativityGRSmoothMinkowskiStress
import CATEPTMain.Certification.RelativityGRWitnessFreeCurvedDirect
import CATEPTMain.Certification.RelativityGREinsteinEquation

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open CATEPTMain.Integration.GravitasBridge

/-- **Canonical `IsCertifiedCurvedGRData` produced by the smooth route.**

Reuses the Hodge / Einstein / ADM sector closures from
`canonical_certified_curved_gr_data`, but replaces the Maxwell-route
stress closure with `gravitasMinkowski_hasStressConservation_from_smooth`
(PR5).  This demonstrates that the smooth Levi-Civita ladder is
sufficient to discharge the stress-closure obligation of the umbrella. -/
def gravitasMinkowski_certifiedCurvedGRData_from_smooth :
    IsCertifiedCurvedGRData
      gravitasMinkowski
      gravitasFaradayMinkowski
      gravitasEMStressEnergy
      gravitasCanonicalVacuumADM
      gravitasCanonicalVacuumADMStressDecomposition
      (.lit 0) :=
  certifiedCurvedGRData_of_bianchi_stress
    canonical_certified_curved_gr_data.hodgeClosure
    gravitasMinkowski_hasStressConservation_from_smooth
    canonical_certified_curved_gr_data.einsteinClosure
    canonical_certified_curved_gr_data.admClosure

/-- **Canonical `CurvedGRDirectCertificate` produced by the smooth route.**

Assembled by piping `gravitasMinkowski_certifiedCurvedGRData_from_smooth`
through `curved_gr_direct_certificate_of_certified_data` at the canonical
electrovac coupling.  Provides a smooth-route inhabitant of the same
`CurvedGRDirectCertificate` surface that the Maxwell-route assembly
`canonical_curved_gr_direct_certificate_of_certified_data` also
inhabits. -/
def gravitasMinkowski_curvedGRDirectCertificate_from_smooth :
    CurvedGRDirectCertificate :=
  curved_gr_direct_certificate_of_certified_data
    canonical_electrovac_einstein_certificate.kappa
    gravitasMinkowski_certifiedCurvedGRData_from_smooth

end CATEPTMain.Certification.RelativityGR

end
