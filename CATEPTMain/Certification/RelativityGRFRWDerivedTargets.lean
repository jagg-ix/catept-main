/-
# FRW derived-witness target shell

The existing `FRWParameter` (see `RelativityGRBianchiFRW`) carries the
`bianchi_witness` and `efe_witness` fields *per instance*: every caller
must hand-supply the contracted-Bianchi residual identity and the
divergence-compatible Einstein equation for the FLRW metric at that
parameter.  That is honest but **not derived** — the witnesses are
inputs, not theorems.

This module isolates the witness-carrying surface into a separate
"target" shell, *without* touching the existing `FRWParameter` API.
The shape is:

* `FRWRawParameter` — the **witness-free** part of `FRWParameter`
  (`scaleParam`, `curvParam`, `coords`, `stress` only).
* `frwRawMetricFamily` — the same `Gravitas.MetricTensor.flrw` lift
  used by `frwMetricFamily`, but on a raw parameter.
* `FRWDerivedBianchiTarget` and `FRWDerivedEFETarget` — `Prop`-valued
  target shells.  Each carries a single field that *names* the
  theorem to derive (contracted-Bianchi, divergence-compatible EFE).
  Today these are inhabited only when callers supply the witness;
  tomorrow they will be discharged by a symbolic FLRW
  Christoffel/Ricci/divergence simplification stack.
* `frwParameter_of_derived_targets` — the **bridge**: given a raw
  parameter plus the two target witnesses, produces the existing
  `FRWParameter` with the witnesses installed into the legacy
  `bianchi_witness` / `efe_witness` slots.

This shell gives a clear migration path: once the two
`FRWDerivedBianchiTarget` / `FRWDerivedEFETarget` shells are proved
generically from FLRW symbolic data, every existing
`FRWParameter`-constructing call site can be rewritten to call
`frwParameter_of_derived_targets`, after which the per-instance
witness fields can be removed from `FRWParameter` itself without
breaking any downstream code (the legacy fields would then be
synthesized inside the bridge).

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRFRWDerivedTargets`
  passes;
* `#check FRWRawParameter`, `#check FRWDerivedBianchiTarget`,
  `#check frwParameter_of_derived_targets` all elaborate;
* `#print axioms` reports only standard kernel axioms.

This module **adds no axioms and changes no existing API**.
-/

import CATEPTMain.Certification.RelativityGRBianchiFRW

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas

/-- **Witness-free** raw FRW parameter shell.

Strictly the non-witness payload of `FRWParameter`: scale-factor and
curvature variable names, coordinate labels, and the associated
stress-energy tensor.  No contracted-Bianchi or Einstein-equation
hypothesis travels with this structure — those obligations are split
out into `FRWDerivedBianchiTarget` and `FRWDerivedEFETarget` below. -/
structure FRWRawParameter : Type where
  /-- Scale-factor variable name (default `"a"`). -/
  scaleParam : String := "a"
  /-- Spatial curvature parameter variable name (default `"k"`). -/
  curvParam : String := "k"
  /-- Coordinate labels (default `["t","r","θ","φ"]`). -/
  coords : Array String := #["t", "r", "θ", "φ"]
  /-- Stress-energy tensor associated with this FRW background. -/
  stress : StressEnergyTensor

/-- FLRW metric-family generator on the **raw** (witness-free) shell.

Produces the same concrete symbolic FLRW metric as `frwMetricFamily`,
but accepts a witness-free `FRWRawParameter`. -/
def frwRawMetricFamily (p : FRWRawParameter) : MetricTensor :=
  Gravitas.MetricTensor.flrw p.scaleParam p.curvParam p.coords co co

/-- **Target shell** for the FRW contracted-Bianchi obligation.

`Prop`-valued container naming the theorem that needs to be derived:
the FLRW metric at parameter `p` satisfies the contracted-Bianchi
admissibility contract.  Today this is supplied by the caller; a
future symbolic FLRW Christoffel/Ricci/divergence stack will discharge
it generically. -/
structure FRWDerivedBianchiTarget (p : FRWRawParameter) : Prop where
  /-- The contracted-Bianchi admissibility for the FLRW metric at `p`. -/
  derived :
    HasContractedBianchi (frwRawMetricFamily p)

/-- **Target shell** for the FRW divergence-compatible Einstein-equation
obligation.

`Prop`-valued container naming the theorem that needs to be derived:
the divergence-compatible Einstein equation
`EinsteinEquationHolds … (.var "κ")` for the FLRW metric and supplied
stress tensor at parameter `p`. -/
structure FRWDerivedEFETarget (p : FRWRawParameter) : Prop where
  /-- The divergence-compatible Einstein equation for the FLRW metric
      at `p` with stress tensor `p.stress` and symbolic coupling
      `κ = .var "κ"`. -/
  derived :
    EinsteinEquationHolds
      (frwRawMetricFamily p)
      p.stress
      (Gravitas.Expr.var "κ")

/-- **Bridge** from the witness-free raw shell plus the two target
witnesses to the existing witness-carrying `FRWParameter`.

Lets callers carry only `FRWRawParameter` plus separate `Prop`-valued
target hypotheses; the bridge installs them into the legacy
`bianchi_witness` / `efe_witness` fields.  Once the two targets are
discharged generically, the bridge body is the only site that needs to
change to drop the per-instance witness fields from `FRWParameter`. -/
def frwParameter_of_derived_targets
    (p : FRWRawParameter)
    (hB : FRWDerivedBianchiTarget p)
    (hE : FRWDerivedEFETarget p) :
    FRWParameter :=
  { scaleParam := p.scaleParam
    curvParam := p.curvParam
    coords := p.coords
    stress := p.stress
    bianchi_witness := hB.derived
    efe_witness := hE.derived }

end CATEPTMain.Certification.RelativityGR

end
