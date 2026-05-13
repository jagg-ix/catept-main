import CATEPTMain.Certification.RelativityGRBianchiBridge
import CATEPTMain.Gravitas.MetricTensor

/-!
# BIANCHI-012 — FRW (Friedmann–Lemaître–Robertson–Walker) family

The BIANCHI-008 scaffolding `BianchiAdmissibleMetricFamily` is the typed
contract that any curved-metric family must discharge to land into the
Bianchi-to-stress route.  The canonical Minkowski-singleton family
`gravitasMinkowskiFamily : Unit → MetricTensor` shipped in
`RelativityGRBianchiBridge` proves the scaffolding terminates but is
*not* a nontrivial curved family.

This module ships the first **nontrivial** curved-metric family for the
Bianchi route: the FLRW family, built on top of
`Gravitas.MetricTensor.flrw` (which produces the concrete symbolic
metric

  `ds² = -dt² + a(t)² · ( dr²/(1 - k r²) + r² dΩ² )`

as a `MetricTensor` of dimension 4 with coordinates `(t, r, θ, φ)`).

## Honest scope

The symbolic-array `covariantDivergenceEinsteinTensor g` is hard-coded
to the zero array only for `g = gravitasMinkowski`; for any other
metric it returns the partial-derivative *core* formula
`g^{μλ} ∂_λ G_{μν}` (see `RelativityGRCovariantDivergence`).  The
contracted second Bianchi identity for the FRW metric is a real
differential-geometric theorem (Wald §3.2, Carroll §3.4) whose symbolic
discharge requires infrastructure (Christoffel-symbol simplification on
diagonal metrics with a single time-dependent function) that this
repository does not yet have.

Following the explicit BIANCHI-008 docstring contract —
*"Real curved families (Schwarzschild, FRW, Kerr, …) supply a
metric-generator together with a per-instance witness that the
contracted Bianchi residual vanishes for every member."* — this module
makes the **per-instance witness** a named field of the family
parameter type `FRWParameter`.  Concretely, every value
`p : FRWParameter` carries
`HasContractedBianchi (Gravitas.MetricTensor.flrw … co co)` together
with `EinsteinEquationHolds … (.var "κ")` for the user-supplied stress
tensor.  The resulting
`BianchiAdmissibleMetricFamily frwMetricFamily` is therefore an honest
projection of the supplied witnesses, not a fabricated proof.

The same pattern will scale to Schwarzschild, Kerr, etc.: each new
family is a parameter type carrying the per-instance witness.
-/

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-! ## BIANCHI-012 — FRW family parameter -/

/-- **BIANCHI-012.** FRW family parameter.

Carries the scale-factor and curvature-parameter variable names, the
coordinate labels, the user-supplied stress-energy tensor, and the two
per-instance witnesses required by the Bianchi route:

* `bianchi_witness` — the symbolic-array contracted-Bianchi residual
  vanishes for the FLRW metric at this parameter (Wald §3.2);
* `efe_witness` — the Einstein equation `G = κ T` (in its
  divergence-compatible form, see `EinsteinEquationHolds`) holds for
  the FLRW metric and the supplied stress tensor at coupling
  `κ = .var "κ"`.

The metric itself is the concrete symbolic FLRW metric supplied by
`Gravitas.MetricTensor.flrw`; it is genuinely curved (the spatial
sector carries `a(t)²` and the radial component depends on `k r²`), so
this is *not* a relabeling of the Minkowski singleton family. -/
structure FRWParameter : Type where
  /-- Scale-factor variable name (default `"a"`).  The FLRW metric uses
      `a(t)` as a named symbolic function of the time coordinate. -/
  scaleParam : String := "a"
  /-- Spatial curvature parameter variable name (default `"k"`). -/
  curvParam : String := "k"
  /-- Coordinate labels (default `["t","r","θ","φ"]`). -/
  coords : Array String := #["t", "r", "θ", "φ"]
  /-- Stress-energy tensor associated with this FRW background.
      Typical physical choice: a perfect fluid with energy density
      `ρ(t)` and pressure `p(t)`. -/
  stress : StressEnergyTensor
  /-- Per-instance contracted-Bianchi admissibility witness for the
      FLRW metric at this parameter.  Future commits that supply a
      symbolic Christoffel/Ricci simplification stack on FLRW will
      discharge this from first principles; until then it is a named
      hypothesis travelling with the parameter, exactly as the
      BIANCHI-008 docstring contract specifies. -/
  bianchi_witness :
    HasContractedBianchi
      (Gravitas.MetricTensor.flrw scaleParam curvParam coords co co)
  /-- Per-instance Einstein-equation witness in its
      divergence-compatible form, with symbolic coupling
      `κ = .var "κ"`.  Required for the BIANCHI-007 admissibility-layer
      composition into `HasStressConservation`. -/
  efe_witness :
    EinsteinEquationHolds
      (Gravitas.MetricTensor.flrw scaleParam curvParam coords co co)
      stress (Gravitas.Expr.var "κ")

/-! ## BIANCHI-012 — FRW family generator and witnesses -/

/-- **BIANCHI-012.** FRW metric-family generator: maps each
`FRWParameter` to the concrete symbolic FLRW metric at that parameter
via `Gravitas.MetricTensor.flrw`. -/
def frwMetricFamily (p : FRWParameter) : MetricTensor :=
  Gravitas.MetricTensor.flrw p.scaleParam p.curvParam p.coords co co

/-- **BIANCHI-012.** FRW stress-energy-family generator: projects out
the user-supplied stress tensor carried in `FRWParameter`. -/
def frwStressFamily (p : FRWParameter) : StressEnergyTensor :=
  p.stress

/-- **BIANCHI-012.** The FRW family is Bianchi-admissible: each
`p : FRWParameter` carries the contracted-Bianchi admissibility witness
for its FLRW metric, so the family-level `BianchiAdmissibleMetricFamily`
contract is discharged by projecting out that field. -/
def frwMetricFamily_bianchiAdmissible :
    BianchiAdmissibleMetricFamily frwMetricFamily where
  admissible := fun p => p.bianchi_witness

/-- **BIANCHI-012.** Per-parameter Einstein-equation witness for the
FRW family, projected out of `FRWParameter`.  This is the
`∀ a, EinsteinEquationHolds (frwMetricFamily a) (frwStressFamily a) κ`
hypothesis consumed by `hasStressConservation_of_family` to produce a
`HasStressConservation` term for any chosen `p`. -/
theorem frwStressFamily_einsteinEquationHolds :
    ∀ p : FRWParameter,
      EinsteinEquationHolds
        (frwMetricFamily p) (frwStressFamily p)
        (Gravitas.Expr.var "κ") :=
  fun p => p.efe_witness

/-- **BIANCHI-012.** Headline route: under the symbolic FRW family and
its supplied per-instance witnesses, the BIANCHI-007 admissibility-layer
composition produces a `HasStressConservation` term for every parameter
`p`, given only the textbook non-degeneracy `κ ≠ 0`. -/
def frwHasStressConservation
    (hκ : (Gravitas.Expr.var "κ") ≠ Gravitas.Expr.lit 0)
    (p : FRWParameter) :
    HasStressConservation (frwMetricFamily p) (frwStressFamily p) :=
  hasStressConservation_of_family
    frwMetricFamily_bianchiAdmissible
    frwStressFamily_einsteinEquationHolds
    hκ
    p

end CATEPTMain.Certification.RelativityGR

end
