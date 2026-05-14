/-
# LC-011 — Smooth Levi-Civita ⇒ CurvedGRDirectCertificate

REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS / Missing 6 →
LC-ladder, step 11 (LC-011).

End-to-end result composing LC-009 (smooth Levi-Civita ⇒
`HasStressConservation`) with `certifiedCurvedGRData_of_bianchi_stress`
(BIANCHI-006) and `curved_gr_direct_certificate_of_certified_data`
(`RelativityGRWitnessFreeCurvedDirect`).

Given:
* a smooth Levi-Civita connection on `X` (LC-001/LC-002),
* a `SymbolicEinsteinDivergenceRepresentsSmooth` representation
  witness (LC-007),
* the divergence-compatible Einstein equation
  `EinsteinEquationHolds gSym T κ` and `κ ≠ 0` (BIANCHI-003),
* the three remaining sector closures (`HasHodgeClosure`,
  `HasEinsteinClosure`, `HasADMClosure`),
* a real coupling `kappa : ℝ`,

we produce a full `IsCertifiedCurvedGRData` bundle and the
final `CurvedGRDirectCertificate`.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothCurvedDirect`
  passes;
* `#check certifiedCurvedGRData_of_smooth_leviCivita` and
  `#check curvedGRDirectCertificate_of_smooth_leviCivita` elaborate;
* `#print axioms` on the GuardAlias entries is the standard audit-pure
  set `[propext, Classical.choice, Quot.sound]`, inherited from the
  symbolic chain.

## Tracking

* REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS — Missing 6
* LC-ladder: LC-011 (this file).  Parents: LC-009,
  BIANCHI-006, `RelativityGRWitnessFreeCurvedDirect`.
-/

import CATEPTMain.Certification.RelativityGRSmoothStressConservation
import CATEPTMain.Certification.RelativityGRWitnessFreeCurvedDirect

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- **LC-011.** Produce the `IsCertifiedCurvedGRData` umbrella bundle
from a smooth Levi-Civita connection plus the three remaining sector
closures.  The stress-conservation closure is supplied by LC-009. -/
def certifiedCurvedGRData_of_smooth_leviCivita
    {X : SmoothPseudoRiemannianManifold}
    {gSym : MetricTensor}
    {faraday : ElectromagneticTensor}
    {T : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    {κ : Gravitas.Expr}
    (connection : SmoothConnection X)
    (hLC : IsLeviCivitaConnection connection)
    (hRep : SymbolicEinsteinDivergenceRepresentsSmooth connection hLC gSym)
    (hEFE : EinsteinEquationHolds gSym T κ)
    (hκ : κ ≠ Gravitas.Expr.lit 0)
    (hHodge : HasHodgeClosure gSym faraday)
    (hEinstein : HasEinsteinClosure gSym T sourceTerm)
    (hADM : HasADMClosure adm admStress sourceTerm) :
    IsCertifiedCurvedGRData gSym faraday T adm admStress sourceTerm :=
  certifiedCurvedGRData_of_bianchi_stress
    hHodge
    (hasStressConservation_of_smooth_leviCivita_einstein
      connection hLC hRep hEFE hκ)
    hEinstein
    hADM

/-- **LC-011.** End-to-end: assemble the full
`CurvedGRDirectCertificate` from a smooth Levi-Civita connection and
the four sector closures plus the real coupling `kappa`. -/
def curvedGRDirectCertificate_of_smooth_leviCivita
    {X : SmoothPseudoRiemannianManifold}
    {gSym : MetricTensor}
    {faraday : ElectromagneticTensor}
    {T : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    {κ : Gravitas.Expr}
    (connection : SmoothConnection X)
    (hLC : IsLeviCivitaConnection connection)
    (hRep : SymbolicEinsteinDivergenceRepresentsSmooth connection hLC gSym)
    (hEFE : EinsteinEquationHolds gSym T κ)
    (hκ : κ ≠ Gravitas.Expr.lit 0)
    (hHodge : HasHodgeClosure gSym faraday)
    (hEinstein : HasEinsteinClosure gSym T sourceTerm)
    (hADM : HasADMClosure adm admStress sourceTerm)
    (kappa : ℝ) :
    CurvedGRDirectCertificate :=
  curved_gr_direct_certificate_of_certified_data
    kappa
    (certifiedCurvedGRData_of_smooth_leviCivita
      connection hLC hRep hEFE hκ hHodge hEinstein hADM)

end CATEPTMain.Certification.RelativityGR

end
