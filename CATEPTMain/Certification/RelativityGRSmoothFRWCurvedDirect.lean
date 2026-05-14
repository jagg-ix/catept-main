/-
# Full FRW `CurvedGRDirectCertificate` from the smooth Levi-Civita route

This file is the **FRW analog** of
`RelativityGRSmoothMinkowskiCurvedDirect`.  It composes:

* `frw_hasStressConservation_from_smooth_of_raw` — stress-conservation
  closure for the FRW raw shell, derived from the smooth Levi-Civita
  ladder (PR #152);
* caller-supplied Hodge / Einstein / ADM sector closures (the three
  obligations not yet covered by the smooth ladder);

through `certifiedCurvedGRData_of_bianchi_stress` to produce an
`IsCertifiedCurvedGRData` umbrella, and then pipes that through
`curved_gr_direct_certificate_of_certified_data` to obtain a full
`CurvedGRDirectCertificate` for the FRW raw shell.

This is the first non-Minkowski family that closes the full direct
curved-GR certificate via the smooth Levi-Civita route, **without**
requiring the legacy witness-carrying `FRWCertifiedParameter`.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothFRWCurvedDirect`
  passes;
* `#check @frwCertifiedCurvedGRData_from_smooth_of_raw` and
  `#check @frwCurvedGRDirectCertificate_from_smooth_of_raw` elaborate;
* `#print axioms` reports only standard kernel axioms.
-/

import CATEPTMain.Certification.RelativityGRSmoothFRWDerivedStress
import CATEPTMain.Certification.RelativityGRWitnessFreeCurvedDirect

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas

/-- **FRW `IsCertifiedCurvedGRData` from the smooth Levi-Civita route.**

Stress closure is produced by `frw_hasStressConservation_from_smooth_of_raw`
(PR #152) from `hRep : SmoothFRWRepresentsGravitasFRW p` and
`hEFE : EinsteinEquationHolds (frwRawMetricFamily p) p.stress (.var "κ")`.
The three remaining sector closures (Hodge `★★`-involution,
Einstein-residual, ADM-residual) are caller-supplied — exactly as in
the Minkowski analog `gravitasMinkowski_certifiedCurvedGRData_from_smooth`,
which reuses the canonical Minkowski sector closures rather than
deriving them. -/
def frwCertifiedCurvedGRData_from_smooth_of_raw
    (p : FRWRawParameter)
    {faraday : ElectromagneticTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (hRep : SmoothFRWRepresentsGravitasFRW p)
    (hEFE :
      EinsteinEquationHolds
        (frwRawMetricFamily p) p.stress (Gravitas.Expr.var "κ"))
    (hHodge : HasHodgeClosure (frwRawMetricFamily p) faraday)
    (hEinstein :
      HasEinsteinClosure (frwRawMetricFamily p) p.stress sourceTerm)
    (hADM : HasADMClosure adm admStress sourceTerm) :
    IsCertifiedCurvedGRData
      (frwRawMetricFamily p) faraday p.stress adm admStress sourceTerm :=
  certifiedCurvedGRData_of_bianchi_stress
    hHodge
    (frw_hasStressConservation_from_smooth_of_raw p hRep hEFE)
    hEinstein
    hADM

/-- **Full FRW `CurvedGRDirectCertificate` from the smooth Levi-Civita
route.**

Composes `frwCertifiedCurvedGRData_from_smooth_of_raw` with
`curved_gr_direct_certificate_of_certified_data` at a caller-supplied
real coupling `κ : ℝ`.

This is the FRW analog of
`gravitasMinkowski_curvedGRDirectCertificate_from_smooth`; it is the
first non-Minkowski family that produces a full
`CurvedGRDirectCertificate` via the smooth Levi-Civita route and the
witness-free raw FRW shell. -/
def frwCurvedGRDirectCertificate_from_smooth_of_raw
    (p : FRWRawParameter)
    {faraday : ElectromagneticTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (kappa : ℝ)
    (hRep : SmoothFRWRepresentsGravitasFRW p)
    (hEFE :
      EinsteinEquationHolds
        (frwRawMetricFamily p) p.stress (Gravitas.Expr.var "κ"))
    (hHodge : HasHodgeClosure (frwRawMetricFamily p) faraday)
    (hEinstein :
      HasEinsteinClosure (frwRawMetricFamily p) p.stress sourceTerm)
    (hADM : HasADMClosure adm admStress sourceTerm) :
    CurvedGRDirectCertificate :=
  curved_gr_direct_certificate_of_certified_data
    kappa
    (frwCertifiedCurvedGRData_from_smooth_of_raw
      p hRep hEFE hHodge hEinstein hADM)

end CATEPTMain.Certification.RelativityGR

end
