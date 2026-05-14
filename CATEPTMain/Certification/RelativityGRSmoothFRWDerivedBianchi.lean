/-
# FRW contracted-Bianchi derived from the smooth route

REPLYID continuation of the FRW derived-targets shell
(`RelativityGRFRWDerivedTargets`) and the LC-008 / LC-010 chain
(`RelativityGRSmoothContractedBianchiCertificate`,
`RelativityGRSmoothFRW`).

The witness-free `FRWRawParameter` shell separated the FLRW
generator data from the per-instance contracted-Bianchi
witness.  This module lifts that separation through the smooth side:
given a raw FRW parameter `p : FRWRawParameter` together with a
`SmoothFRWRepresentsGravitasFRW p` representation witness, the
symbolic `HasContractedBianchi (frwRawMetricFamily p)` admissibility
contract is **derived** from the LC-008 smooth-route certificate
constructor, rather than carried by the caller.

Because the LC-010 smooth FRW carriers (`smoothFRWFamily`,
`frwLeviCivitaConnection`, `frwConnection_isLeviCivita`) are indexed
by the witness-carrying `FRWParameter` but their bodies do **not**
depend on the witness fields (LC-010 placeholders are `Unit / True`),
we expose three raw-shell wrappers below — `smoothFRWFamilyRaw`,
`frwLeviCivitaConnectionRaw`, `frwConnectionRaw_isLeviCivita` —
indexed by the witness-free `FRWRawParameter`.  This avoids the
chicken-and-egg of having to manufacture a `bianchi_witness` in order
to talk about the smooth connection that *derives* it.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothFRWDerivedBianchi`
  passes;
* `#check SmoothFRWRepresentsGravitasFRW` and
  `#check frw_hasContractedBianchi_from_smooth` elaborate;
* `#print axioms` reports only standard kernel axioms.

This module **adds no axioms and changes no existing API**.
-/

import CATEPTMain.Certification.RelativityGRFRWDerivedTargets
import CATEPTMain.Certification.RelativityGRSmoothFRW
import CATEPTMain.Certification.RelativityGRSmoothContractedBianchiCertificate
import CATEPTMain.Certification.RelativityGRSmoothGravitasBridge

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- **Raw-shell smooth FRW carrier.** Same Unit/True placeholder body
as `smoothFRWFamily`, but indexed by the witness-free
`FRWRawParameter`.  Used so that the smooth-route derivation of the
contracted-Bianchi witness does not need to fabricate a
`bianchi_witness` just to name the carrier. -/
def smoothFRWFamilyRaw (_p : FRWRawParameter) : SmoothPseudoRiemannianManifold where
  M := Unit
  dim := 4
  chartAtlas := Unit
  tangentBundle := Unit
  cotangentBundle := Unit
  metric := Unit
  metric_symmetric := True
  metric_nonDegenerate := True
  metric_smooth := True
  signature_lorentzian := True

/-- **Raw-shell smooth Levi-Civita connection** on `smoothFRWFamilyRaw p`.
Mirrors `frwLeviCivitaConnection` but indexed by `FRWRawParameter`. -/
def frwLeviCivitaConnectionRaw (p : FRWRawParameter) :
    SmoothConnection (smoothFRWFamilyRaw p) where
  nabla := Unit
  actsOnVectorFields := True
  actsOnTensorFields := True
  linear_over_functions := True
  leibniz_rule := True

/-- **Raw-shell Levi-Civita witness** for `frwLeviCivitaConnectionRaw p`.
Mirrors `frwConnection_isLeviCivita` but indexed by
`FRWRawParameter`. -/
def frwConnectionRaw_isLeviCivita (p : FRWRawParameter) :
    IsLeviCivitaConnection (frwLeviCivitaConnectionRaw p) where
  torsion_free := { torsion_zero := True }
  metric_compatible := { nabla_metric_zero := True }

/-- Component type: smooth FRW carrier represents the symbolic FLRW
metric at raw parameter `p`. -/
abbrev SmoothFRWMetricMatches (p : FRWRawParameter) :=
  GravitasRepresentsSmoothMetric (smoothFRWFamilyRaw p) (frwRawMetricFamily p)

/-- Component type: symbolic Einstein-divergence array is the
coordinate representation of the smooth Levi-Civita divergence on the
raw-shell FRW carrier at parameter `p`. -/
abbrev SmoothFRWDivergenceMatches (p : FRWRawParameter) :=
  SymbolicEinsteinDivergenceRepresentsSmooth
    (frwLeviCivitaConnectionRaw p)
    (frwConnectionRaw_isLeviCivita p)
    (frwRawMetricFamily p)

set_option maxHeartbeats 4000000 in
/-- **Smooth-side representation witness** for the FRW family at a
raw parameter `p`.

Two named obligations:

* `smooth_family_matches_symbolic` — the LC-007 chart/component
  representation of the symbolic FLRW metric on the raw-shell smooth
  carrier;
* `divergence_represents` — the LC-007 representation equation linking
  the symbolic `covariantDivergenceEinsteinTensor` array to the
  coordinate representation of the smooth Levi-Civita divergence.

The second field is exactly what `contractedBianchiCertificate_of_smooth_leviCivita`
consumes to derive a `ContractedBianchiCertificate`. -/
structure SmoothFRWRepresentsGravitasFRW (p : FRWRawParameter) where
  /-- Smooth FRW carrier represents the symbolic FLRW metric at `p`. -/
  smooth_family_matches_symbolic : SmoothFRWMetricMatches p
  /-- Symbolic Einstein-divergence array is the coordinate
  representation of the smooth Levi-Civita divergence. -/
  divergence_represents : SmoothFRWDivergenceMatches p

/-- **Derived** contracted-Bianchi admissibility for the FLRW metric at
a raw parameter `p`, obtained from a smooth representation witness.

Concretely, the LC-008 constructor
`contractedBianchiCertificate_of_smooth_leviCivita` produces a
`ContractedBianchiCertificate (frwRawMetricFamily p)` whose
`einstein_divergence_zero` field is exactly the
`HasContractedBianchi.contracted_bianchi` obligation.

This is the first construction in the FRW derived-targets shell that
**derives** a target witness from the smooth route, rather than
carrying it as caller input. -/
def frw_hasContractedBianchi_from_smooth
    (p : FRWRawParameter)
    (hRep : SmoothFRWRepresentsGravitasFRW p) :
    HasContractedBianchi (frwRawMetricFamily p) where
  contracted_bianchi :=
    (contractedBianchiCertificate_of_smooth_leviCivita
        (frwLeviCivitaConnectionRaw p)
        (frwConnectionRaw_isLeviCivita p)
        hRep.divergence_represents).einstein_divergence_zero

/-- Convenience: the derived contracted-Bianchi witness packaged as an
`FRWDerivedBianchiTarget`, ready to feed
`frwParameter_of_derived_targets`. -/
def frwDerivedBianchiTarget_from_smooth
    (p : FRWRawParameter)
    (hRep : SmoothFRWRepresentsGravitasFRW p) :
    FRWDerivedBianchiTarget p where
  derived := frw_hasContractedBianchi_from_smooth p hRep

end CATEPTMain.Certification.RelativityGR

end
