/-
# Named contracts for the FRW smooth-representation derivation

The constrained derivation
`smoothFRW_represents_gravitasFRW_of_raw` in
`RelativityGRSmoothFRWDerivedBianchi` packages a
`SmoothFRWRepresentsGravitasFRW p` witness from two raw hypotheses:

* `hDim : (smoothFRWFamilyRaw p).dim = (frwRawMetricFamily p).dim`
* `hDiv : covariantDivergenceEinsteinTensor (frwRawMetricFamily p) = ...`

This module wraps the two raw hypotheses as two named `Prop`-valued
contracts and re-derives the witness through the named theorem
`smoothFRW_represents_gravitasFRW_of_raw_named`.  The contracts
correspond to the two pieces of work an FLRW chart/symbolic stack
would discharge automatically once it lands:

* `FRWChartCompatible p` — the dimension equation between the
  raw-shell smooth FRW carrier and the symbolic FLRW metric at `p`
  (closed by a chart/atlas compatibility lemma);
* `FRWSymbolicDivergenceSimplifies p` — the symbolic-side
  Einstein-divergence-zero equation for the symbolic FLRW metric at
  `p` (closed by an FLRW Christoffel / Ricci / divergence
  simplifier).

The theorem is a thin repackaging — we do **not** attempt to discharge
either contract here.  Doing so unconditionally would require the
FLRW symbolic stack, which has not yet landed.  The point of this
module is to give callers a single, named physics-level entry point
for the smooth-route derivation, so the remaining gap is the two
named contracts rather than two anonymous hypotheses.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRFRWChartSymbolicContract`
  passes;
* `#check @FRWChartCompatible`,
  `#check @FRWSymbolicDivergenceSimplifies`, and
  `#check @smoothFRW_represents_gravitasFRW_of_raw_named` elaborate;
* `#print axioms` reports only standard kernel axioms.
-/

import CATEPTMain.Certification.RelativityGRSmoothFRWDerivedBianchi

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas

/-- **Chart-compatibility contract** for FRW at raw parameter `p`.

Names the dimension equation between the raw-shell smooth FRW carrier
`smoothFRWFamilyRaw p` and the symbolic FLRW metric
`frwRawMetricFamily p`.  Closed by a chart/atlas compatibility lemma
once the FLRW chart stack lands. -/
structure FRWChartCompatible (p : FRWRawParameter) : Prop where
  /-- The raw-shell smooth FRW carrier and the symbolic FLRW metric
      agree on dimension. -/
  dim_match : (smoothFRWFamilyRaw p).dim = (frwRawMetricFamily p).dim

/-- **Symbolic-side Einstein-divergence simplification** for FRW at
raw parameter `p`.

Names the symbolic-side Einstein-divergence-zero equation for the
symbolic FLRW metric at `p`.  Closed by an FLRW Christoffel / Ricci /
divergence simplifier once the FLRW symbolic stack lands. -/
structure FRWSymbolicDivergenceSimplifies (p : FRWRawParameter) : Prop where
  /-- Symbolic covariant divergence of the Einstein tensor for the
      FLRW metric at `p` is the zero array. -/
  divergence_zero :
    covariantDivergenceEinsteinTensor (frwRawMetricFamily p) =
      Array.replicate (smoothFRWFamilyRaw p).dim
        (Gravitas.Expr.lit 0)

/-- **Named-contract derivation of `SmoothFRWRepresentsGravitasFRW p`.**

Repackages `smoothFRW_represents_gravitasFRW_of_raw` so callers can
supply two **named physics-level contracts** instead of two anonymous
hypotheses:

* `hChart : FRWChartCompatible p`
* `hSymbolic : FRWSymbolicDivergenceSimplifies p`

Until the FLRW chart stack and symbolic-divergence simplifier land,
this theorem is the recommended entry point for the smooth-route
derivation of the FRW contracted-Bianchi / stress-conservation
witnesses (PRs #146, #152).  Callers are expected to discharge
`hChart` and `hSymbolic` from upstream FLRW analysis.

Note: because `SmoothFRWRepresentsGravitasFRW` is a `structure`
rather than a `Prop`, this is a `def` (not a `theorem`) — the
nomenclature follows the existing
`smoothFRW_represents_gravitasFRW_of_raw` def. -/
def smoothFRW_represents_gravitasFRW_of_raw_named
    (p : FRWRawParameter)
    (hChart : FRWChartCompatible p)
    (hSymbolic : FRWSymbolicDivergenceSimplifies p) :
    SmoothFRWRepresentsGravitasFRW p :=
  smoothFRW_represents_gravitasFRW_of_raw p
    hSymbolic.divergence_zero hChart.dim_match

end CATEPTMain.Certification.RelativityGR

end
