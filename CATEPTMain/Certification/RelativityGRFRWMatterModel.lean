/-
# Constrained derivation of the FRW divergence-compatible EFE

`FRWDerivedEFETarget p` (in `RelativityGRFRWDerivedTargets`) names the
divergence-compatible Einstein equation
`EinsteinEquationHolds (frwRawMetricFamily p) p.stress (.var "κ")` as
the obligation that needs to be derived for an FRW raw parameter `p`.

Today the witness is supplied by the caller; downstream of the smooth
ladder the obligation factors through the LC-009 generic theorem
(`hasStressConservation_of_smooth_leviCivita_einstein`) and ultimately
through a symbolic FLRW perfect-fluid stress-energy / continuity-equation
simplification stack that has not yet landed.

Until that stack lands, this module names the **remaining algebraic
gap** explicitly:

* `FRWMatterModel p` — a `Prop`-valued container with a single named
  field, `divergence_compat`, that asserts the two covariant-divergence
  operators agree on `(frwRawMetricFamily p, p.stress)`.  This is
  precisely the textbook statement of the FRW continuity equation
  `∇_μ T^{μν} = 0` paired with the contracted Bianchi identity
  `∇_μ G^{μν} = 0`, written at the symbolic-array layer of this
  repository.
* `frw_einsteinEquationHolds_from_raw` — packages an `FRWMatterModel p`
  hypothesis into the `EinsteinEquationHolds` structure consumed by the
  Bianchi-to-stress chain (BIANCHI-003).
* `frwDerivedEFETarget_from_matter` — packages the same hypothesis as
  an `FRWDerivedEFETarget p`, ready to feed
  `frwParameter_of_derived_targets`.

This is the FRW EFE analog of the constrained derivation of
`SmoothFRWRepresentsGravitasFRW p` provided by
`smoothFRW_represents_gravitasFRW_of_raw` in
`RelativityGRSmoothFRWDerivedBianchi`: it makes the remaining gap an
**explicit named hypothesis** rather than a per-instance witness on
`FRWParameter`, so callers can route their FRW matter assumption
through a single, named contract.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRFRWMatterModel`
  passes;
* `#check @FRWMatterModel` and
  `#check @frw_einsteinEquationHolds_from_raw` elaborate;
* `#print axioms` reports only standard kernel axioms.
-/

import CATEPTMain.Certification.RelativityGRFRWDerivedTargets

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas

/-- **FRW matter-model contract.**

Names the textbook FRW matter assumption that the stress-energy tensor
`p.stress` is divergence-free under the FLRW Levi-Civita connection —
equivalently, that its symbolic covariant divergence matches the
symbolic covariant divergence of the Einstein tensor for the FLRW
metric at `p`.  Wald §3.2, Carroll §3.4: the perfect-fluid continuity
equation paired with `∇_μ G^{μν} = 0` (contracted Bianchi). -/
structure FRWMatterModel (p : FRWRawParameter) : Prop where
  /-- The two covariant-divergence operators agree on
      `(frwRawMetricFamily p, p.stress)`.  Discharged in the symbolic
      layer once an FLRW perfect-fluid simplification stack lands. -/
  divergence_compat :
    covariantDivergenceStressEnergy (frwRawMetricFamily p) p.stress =
      covariantDivergenceEinsteinTensor (frwRawMetricFamily p)

/-- **Constrained derivation of `EinsteinEquationHolds` for the FRW raw
shell.**

Packages an `FRWMatterModel p` hypothesis into the
divergence-compatible Einstein equation
`EinsteinEquationHolds (frwRawMetricFamily p) p.stress (.var "κ")`
consumed by the Bianchi-to-stress chain (BIANCHI-003).

This is the FRW EFE analog of `smoothFRW_represents_gravitasFRW_of_raw`
in `RelativityGRSmoothFRWDerivedBianchi`: until a generic FLRW
perfect-fluid simplification stack lands, the
matter-divergence-compatibility hypothesis names the remaining gap
explicitly and lets callers supply a single, named matter contract
rather than a per-instance witness on `FRWParameter`. -/
theorem frw_einsteinEquationHolds_from_raw
    (p : FRWRawParameter) (hMatter : FRWMatterModel p) :
    EinsteinEquationHolds
      (frwRawMetricFamily p) p.stress (Gravitas.Expr.var "κ") where
  divergence_compat := hMatter.divergence_compat

/-- Convenience: package the derived EFE as an `FRWDerivedEFETarget p`,
ready to feed `frwParameter_of_derived_targets`. -/
def frwDerivedEFETarget_from_matter
    (p : FRWRawParameter) (hMatter : FRWMatterModel p) :
    FRWDerivedEFETarget p where
  derived := frw_einsteinEquationHolds_from_raw p hMatter

end CATEPTMain.Certification.RelativityGR

end
