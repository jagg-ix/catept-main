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

/-! ## BIANCHI-013 — FRW family end-to-end into `IsCertifiedCurvedGRData`

`certifiedCurvedGRData_of_bianchi_stress` (BIANCHI-006) consumes four
sector closures (`HasHodgeClosure`, `HasStressConservation`,
`HasEinsteinClosure`, `HasADMClosure`) and produces the umbrella
admissibility predicate `IsCertifiedCurvedGRData`, which by
`curved_gr_direct_certificate_of_certified_data` assembles a full
`CurvedGRDirectCertificate`.

This section discharges that end-to-end route for a **non-Minkowski**
family: the FRW family of BIANCHI-012.  The stress-conservation closure
is supplied by the Bianchi route
(`frwHasStressConservation`); the three remaining sector closures
(Hodge `★★`, Einstein-residual identity, ADM-residual identities) are
carried as named per-instance witnesses on a dedicated parameter type
`FRWCertifiedParameter`, exactly mirroring the BIANCHI-008 docstring
contract for curved families.

Together with the `(Gravitas.Expr.var "κ") ≠ Gravitas.Expr.lit 0`
non-degeneracy hypothesis (also carried as a parameter field), each
member of the FRW certified-parameter family produces a fully-assembled
`CurvedGRDirectCertificate`. -/

/-- **BIANCHI-013.** FRW certified-data parameter.

Extends `FRWParameter` (BIANCHI-012) with the Maxwell/ADM payload and
the per-instance witnesses for the three remaining curved-GR sector
closures.  The stress-conservation closure is *not* a field here: it is
derived through the Bianchi route from the base `FRWParameter`. -/
structure FRWCertifiedParameter : Type where
  /-- Underlying FRW family parameter (carries the metric generator
      data, the stress tensor, and the Bianchi/EFE witnesses). -/
  base : FRWParameter
  /-- Electromagnetic tensor on this FRW background.  Carried as a
      family field so that downstream consumers can choose physically
      meaningful electromagnetic configurations (e.g. vacuum). -/
  faraday : ElectromagneticTensor
  /-- ADM decomposition of the FRW background. -/
  adm : ADMDecomposition
  /-- ADM stress-energy decomposition matching the FRW stress tensor. -/
  admStress : ADMStressEnergyDecomposition
  /-- Einstein-equation source term (typically `.lit 0` for vacuum, the
      symbolic cosmological constant for ΛCDM, etc.). -/
  sourceTerm : Gravitas.Expr
  /-- Real-valued coupling `κ` consumed by
      `curved_gr_direct_certificate_of_certified_data`.  Independent of
      the symbolic `Expr` coupling that the Bianchi route uses. -/
  kappa : ℝ
  /-- Non-degeneracy of the symbolic Bianchi-route coupling.  Required
      by `frwHasStressConservation` to produce the
      `HasStressConservation` closure for this family member. -/
  bianchi_kappa_nonzero :
    (Gravitas.Expr.var "κ") ≠ Gravitas.Expr.lit 0
  /-- Hodge `★★`-involution closure on the chosen Faraday tensor
      relative to the FRW metric. -/
  hodge_witness :
    HasHodgeClosure
      (Gravitas.MetricTensor.flrw
        base.scaleParam base.curvParam base.coords co co)
      faraday
  /-- Einstein-residual closure at the solver output for the FRW
      metric, the chosen stress tensor, and the chosen source term. -/
  einstein_witness :
    HasEinsteinClosure
      (Gravitas.MetricTensor.flrw
        base.scaleParam base.curvParam base.coords co co)
      base.stress sourceTerm
  /-- ADM Hamiltonian/momentum residual closure at the solver outputs. -/
  adm_witness :
    HasADMClosure adm admStress sourceTerm

/-- **BIANCHI-013.** FRW Faraday-family generator: projects out the
chosen electromagnetic tensor on each certified FRW parameter. -/
def frwFaradayFamily (p : FRWCertifiedParameter) : ElectromagneticTensor :=
  p.faraday

/-- **BIANCHI-013.** FRW ADM-decomposition family generator. -/
def frwADMFamily (p : FRWCertifiedParameter) : ADMDecomposition :=
  p.adm

/-- **BIANCHI-013.** FRW ADM stress-energy-decomposition family generator. -/
def frwADMStressFamily (p : FRWCertifiedParameter) :
    ADMStressEnergyDecomposition :=
  p.admStress

/-- **BIANCHI-013.** FRW source-term family generator. -/
def frwSourceTerm (p : FRWCertifiedParameter) : Gravitas.Expr :=
  p.sourceTerm

/-- **BIANCHI-013.** Per-parameter projection: Hodge `★★`-involution
closure for each certified FRW parameter. -/
def frwHodgeClosure (p : FRWCertifiedParameter) :
    HasHodgeClosure (frwMetricFamily p.base) (frwFaradayFamily p) :=
  p.hodge_witness

/-- **BIANCHI-013.** Per-parameter projection: Einstein-residual
closure for each certified FRW parameter. -/
def frwEinsteinClosure (p : FRWCertifiedParameter) :
    HasEinsteinClosure
      (frwMetricFamily p.base) (frwStressFamily p.base) (frwSourceTerm p) :=
  p.einstein_witness

/-- **BIANCHI-013.** Per-parameter projection: ADM-residual closure
for each certified FRW parameter. -/
def frwADMClosure (p : FRWCertifiedParameter) :
    HasADMClosure (frwADMFamily p) (frwADMStressFamily p) (frwSourceTerm p) :=
  p.adm_witness

/-- **BIANCHI-013.** End-to-end `IsCertifiedCurvedGRData` discharge for
the FRW family.

Composes:
* the Bianchi route to `HasStressConservation` via
  `frwHasStressConservation`, taking `p.bianchi_kappa_nonzero`;
* the three remaining sector closures projected out of
  `FRWCertifiedParameter`;

through `certifiedCurvedGRData_of_bianchi_stress` (BIANCHI-006). -/
def frwCertifiedCurvedGRData (p : FRWCertifiedParameter) :
    IsCertifiedCurvedGRData
      (frwMetricFamily p.base)
      (frwFaradayFamily p)
      (frwStressFamily p.base)
      (frwADMFamily p)
      (frwADMStressFamily p)
      (frwSourceTerm p) :=
  certifiedCurvedGRData_of_bianchi_stress
    (frwHodgeClosure p)
    (frwHasStressConservation p.bianchi_kappa_nonzero p.base)
    (frwEinsteinClosure p)
    (frwADMClosure p)

/-- **BIANCHI-013.** End-to-end `CurvedGRDirectCertificate` for the
FRW family: the first non-Minkowski family that produces the full
direct curved-GR certificate via the Bianchi route. -/
def frwCurvedGRDirectCertificate (p : FRWCertifiedParameter) :
    CurvedGRDirectCertificate :=
  curved_gr_direct_certificate_of_certified_data
    p.kappa
    (frwCertifiedCurvedGRData p)

end CATEPTMain.Certification.RelativityGR

end
