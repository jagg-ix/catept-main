/-
# FRW `CurvedGRDirectCertificate` from the four named FLRW contracts

Builds the strongest FRW `CurvedGRDirectCertificate` constructor
currently available, with the witness burden reduced to:

* four FLRW physics-level Prop contracts:
  * `FRWChartCompatible p` (chart/dim compatibility, PR #160)
  * `FRWSymbolicDivergenceSimplifies p` (symbolic Bianchi, PR #160)
  * `FRWPerfectFluidStress p` (matter continuity, PR #162)
  * `FRWContinuityEquation p` (geometric Bianchi, PR #162)
* three sector-closure hypotheses (Hodge / Einstein / ADM), exactly
  as in the existing smooth-route constructor
  `frwCurvedGRDirectCertificate_from_smooth_of_raw` (PR #156); these
  are not yet expressible as FLRW-specific Prop contracts because the
  Hodge / Einstein / ADM closures depend on caller-supplied
  electromagnetic and ADM data (`faraday`, `adm`, `admStress`,
  `sourceTerm`).

Under the hood this delegates to the smooth-route stack:

1. `smoothFRW_represents_gravitasFRW_of_raw_named p hChart hSymbolic`
   yields `SmoothFRWRepresentsGravitasFRW p`;
2. `frwMatterModel_of_perfectFluidContinuity p hPF hContinuity`
   yields `FRWMatterModel p`, and
   `frw_einsteinEquationHolds_from_raw p _` yields
   `EinsteinEquationHolds (frwRawMetricFamily p) p.stress (.var "κ")`;
3. `frwCurvedGRDirectCertificate_from_smooth_of_raw p kappa _ _ hHodge
   hEinstein hADM` produces the final `CurvedGRDirectCertificate`.

This is the next reduction in witness burden after PR #156: callers
who previously supplied `hRep`, `hEFE` directly now supply the four
named FLRW Prop contracts instead, which is the physics-natural
statement of the FRW assumptions and is the form that an FLRW
symbolic stack would discharge.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRFRWCurvedDirectFromModels`
  passes;
* `#check @frwCertifiedCurvedGRData_from_models`,
  `#check @frwCurvedGRDirectCertificate_from_models` elaborate;
* `#print axioms` reports only standard kernel axioms.
-/

import CATEPTMain.Certification.RelativityGRFRWChartSymbolicContract
import CATEPTMain.Certification.RelativityGRFRWPerfectFluidContinuity
import CATEPTMain.Certification.RelativityGRSmoothFRWCurvedDirect

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas

/-- **FRW `IsCertifiedCurvedGRData` from the four named FLRW
contracts.**

Reduces the witness burden of
`frwCertifiedCurvedGRData_from_smooth_of_raw` (PR #156) by replacing
its two raw inputs

* `hRep : SmoothFRWRepresentsGravitasFRW p`
* `hEFE : EinsteinEquationHolds (frwRawMetricFamily p) p.stress (.var "κ")`

with the four FLRW physics-level Prop contracts

* `hChart : FRWChartCompatible p`
* `hSymbolic : FRWSymbolicDivergenceSimplifies p`
* `hPF : FRWPerfectFluidStress p`
* `hContinuity : FRWContinuityEquation p`.

The three sector closures (`hHodge`, `hEinstein`, `hADM`) remain
caller-supplied as in PR #156. -/
def frwCertifiedCurvedGRData_from_models
    (p : FRWRawParameter)
    {faraday : ElectromagneticTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (hChart : FRWChartCompatible p)
    (hSymbolic : FRWSymbolicDivergenceSimplifies p)
    (hPF : FRWPerfectFluidStress p)
    (hContinuity : FRWContinuityEquation p)
    (hHodge : HasHodgeClosure (frwRawMetricFamily p) faraday)
    (hEinstein :
      HasEinsteinClosure (frwRawMetricFamily p) p.stress sourceTerm)
    (hADM : HasADMClosure adm admStress sourceTerm) :
    IsCertifiedCurvedGRData
      (frwRawMetricFamily p) faraday p.stress adm admStress sourceTerm :=
  frwCertifiedCurvedGRData_from_smooth_of_raw p
    (smoothFRW_represents_gravitasFRW_of_raw_named p hChart hSymbolic)
    (frw_einsteinEquationHolds_from_raw p
      (frwMatterModel_of_perfectFluidContinuity p hPF hContinuity))
    hHodge hEinstein hADM

/-- **FRW `CurvedGRDirectCertificate` from the four named FLRW
contracts.**

The Step-4 entry point: combines `frwCertifiedCurvedGRData_from_models`
with `curved_gr_direct_certificate_of_certified_data` at a
caller-supplied real coupling `κ : ℝ`.

This is the strongest currently-available FRW `CurvedGRDirectCertificate`
constructor: it requires only four FLRW Prop contracts plus the three
sector closures and `kappa`.  All FLRW physics inputs are surfaced as
named Prop contracts, ready for an FLRW symbolic stack to discharge. -/
def frwCurvedGRDirectCertificate_from_models
    (p : FRWRawParameter)
    {faraday : ElectromagneticTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (kappa : ℝ)
    (hChart : FRWChartCompatible p)
    (hSymbolic : FRWSymbolicDivergenceSimplifies p)
    (hPF : FRWPerfectFluidStress p)
    (hContinuity : FRWContinuityEquation p)
    (hHodge : HasHodgeClosure (frwRawMetricFamily p) faraday)
    (hEinstein :
      HasEinsteinClosure (frwRawMetricFamily p) p.stress sourceTerm)
    (hADM : HasADMClosure adm admStress sourceTerm) :
    CurvedGRDirectCertificate :=
  frwCurvedGRDirectCertificate_from_smooth_of_raw p kappa
    (smoothFRW_represents_gravitasFRW_of_raw_named p hChart hSymbolic)
    (frw_einsteinEquationHolds_from_raw p
      (frwMatterModel_of_perfectFluidContinuity p hPF hContinuity))
    hHodge hEinstein hADM

end CATEPTMain.Certification.RelativityGR

end
