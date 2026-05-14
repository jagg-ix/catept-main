/-
# LC-009 — Smooth Levi-Civita ⇒ `HasStressConservation`

REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS / Missing 6 →
LC-ladder, step 9 (LC-009).

This file feeds the smooth-geometry theorem of LC-008
(`contractedBianchiCertificate_of_smooth_leviCivita`) into the existing
Bianchi route `hasStressConservation_of_bianchi_einstein`
(BIANCHI-004), producing a `HasStressConservation gSym T` term from
*actual* smooth Levi-Civita geometry plus the divergence-compatible
Einstein equation.

The construction is a one-liner composition; no axiom-level surface is
added beyond what LC-006…LC-008 and the existing Bianchi bridge
already supply.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothStressConservation`
  passes;
* `#check hasStressConservation_of_smooth_leviCivita_einstein` elaborates;
* `#print axioms` on the GuardAlias entry is audit-pure
  (`[propext, Classical.choice, Quot.sound]`, inherited).

## Tracking

* REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS — Missing 6
* LC-ladder: LC-009 (this file).  Parents: LC-007, LC-008,
  BIANCHI-003, BIANCHI-004.
-/

import CATEPTMain.Certification.RelativityGRSmoothContractedBianchiCertificate

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- **LC-009.** Produce `HasStressConservation gSym T` from a smooth
Levi-Civita connection on `X`, a `SymbolicEinsteinDivergenceRepresentsSmooth`
representation witness (LC-007), the divergence-compatible Einstein
equation `EinsteinEquationHolds gSym T κ` (BIANCHI-003), and the
non-degeneracy `κ ≠ .lit 0`. -/
def hasStressConservation_of_smooth_leviCivita_einstein
    {X : SmoothPseudoRiemannianManifold}
    {gSym : Gravitas.MetricTensor}
    {T : StressEnergyTensor}
    {κ : Gravitas.Expr}
    (connection : SmoothConnection X)
    (hLC : IsLeviCivitaConnection connection)
    (hRep : SymbolicEinsteinDivergenceRepresentsSmooth connection hLC gSym)
    (hEFE : EinsteinEquationHolds gSym T κ)
    (hκ : κ ≠ Gravitas.Expr.lit 0) :
    HasStressConservation gSym T :=
  hasStressConservation_of_bianchi_einstein
    (contractedBianchiCertificate_of_smooth_leviCivita connection hLC hRep)
    hEFE
    hκ

end CATEPTMain.Certification.RelativityGR

end
