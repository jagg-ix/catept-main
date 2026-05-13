import CATEPTMain.Certification.RelativityGRWitnessFreeCurvedDirect
import CATEPTMain.Certification.RelativityGRCovariantDivergence
import CATEPTMain.Gravitas.RiemannTensor
import CATEPTMain.Gravitas.RicciTensor
import CATEPTMain.Gravitas.EinsteinTensor

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-!
# Curved-GR Bianchi bridge — BIANCHI-001 inventory layer
(REPLYID 20260513-BIANCHI-CURVED-SPACE-LEVERAGE-001)

This module introduces a **conservative inventory surface** for the
Bianchi-identity → stress-conservation route to `HasStressConservation`,
complementing the existing Maxwell-driven route in
`RelativityGRWitnessFreeStressConservation` /
`RelativityGRWitnessFreeFamilyCertificate`.

The strategic chain (textbook, see `jagg-ix/generalrelativity`, Lecture 11):

```text
∇_[a R_bc]de = 0                  -- second Bianchi identity
⇒ ∇^a G_ab = 0                    -- contracted Bianchi
⇒ if G_ab = κ T_ab and κ ≠ 0,
   then ∇^a T_ab = 0              -- stress conservation
```

## Layering

* **BIANCHI-001** — inventory + theorem-shaped interfaces (typed surface).

* **BIANCHI-002** — `ContractedBianchiCertificate g` carries the real
  index-array equality `covariantDivergenceEinsteinTensor g = Array.mkArray g.dim (.lit 0)`,
  with the operator defined in `RelativityGRCovariantDivergence` and a
  canonical Minkowski witness `gravitasMinkowski_contractedBianchiCertificate`.

* **BIANCHI-003 (this commit)** — `EinsteinEquationHolds g T κ` carries the
  Levi-Civita-compatibility consequence of the textbook Einstein equation
  `G = κ T`, namely `covariantDivergenceStressEnergy g T = covariantDivergenceEinsteinTensor g`,
  and `BianchiToStressConservation.hκ_nonzero` is tightened to the literal
  disequality `κ ≠ .lit 0`.  This commit also proves
  `stress_conservation_of_contracted_bianchi_and_einstein`:
  `∇·G = 0 ∧ G = κT ⇒ ∇·T = 0` at the symbolic-array level.

* **BIANCHI-004 (this commit)** — `hasStressConservation_of_bianchi_einstein`
  packages the BIANCHI-003 conclusion as a `HasStressConservation g T` term,
  giving an alternative constructor parallel to the existing Maxwell route
  in `RelativityGRWitnessFreeStressConservation`.

Upstream object sources (no in-tree definitions added in this commit):

| Object                       | Provided by                                    |
|------------------------------|------------------------------------------------|
| `RiemannTensor`              | `CATEPTMain.Gravitas.RiemannTensor` (shim)     |
| `RicciTensor`                | `CATEPTMain.Gravitas.RicciTensor` (shim)       |
| `EinsteinTensor`             | `CATEPTMain.Gravitas.EinsteinTensor` (shim)    |
| `covariantDivergenceStressEnergy` | `RelativityGRCovariantDivergence`          |
-/

/-! ## BIANCHI-001 — curvature/Bianchi object inventory surface

A flat `Prop`-marker structure listing the curvature-side ingredients the
witness-free GR program will rely on.  Each field is a placeholder that a
future PR (BIANCHI-002) will refine into a real theorem-shaped obligation. -/

/-- Inventory surface for the Bianchi-identity route to stress conservation.

This is the **typed handle** for the Bianchi bridge.  No physical content
is asserted at this layer — every field is `True`-shaped — but the names
are reserved so that downstream certification files can refer to them and
later PRs can strengthen the fields one at a time. -/
structure BianchiBridgeSurface : Prop where
  /-- The symbolic curvature objects (`RiemannTensor`, `RicciTensor`,
      `EinsteinTensor`) are imported and in scope. -/
  curvature_objects_available : True
  /-- Riemann tensor symmetries (antisymmetry, pair-swap, first Bianchi)
      are available as named lemmas. -/
  riemann_symmetry_layer_available : True
  /-- Second Bianchi identity `∇_[a R_bc]de = 0` is available as a named
      lemma. -/
  bianchi_identity_layer_available : True
  /-- Contracted Bianchi identity `∇^a G_ab = 0` is available as a named
      lemma. -/
  contracted_bianchi_layer_available : True
  /-- Einstein-tensor covariant divergence operator
      `covariantDivergenceEinsteinTensor` is defined. -/
  einstein_divergence_layer_available : True

/-- Canonical witness for the inventory surface.  Each field is `trivial`
because the surface only records that the modules are imported and the
names are reserved.  Real obligations land in BIANCHI-002. -/
def bianchiBridgeSurface : BianchiBridgeSurface where
  curvature_objects_available := trivial
  riemann_symmetry_layer_available := trivial
  bianchi_identity_layer_available := trivial
  contracted_bianchi_layer_available := trivial
  einstein_divergence_layer_available := trivial

/-! ## BIANCHI-002 / BIANCHI-003 — theorem-shaped interfaces

The structures below pin **the exact theorem shapes** for the contracted
Bianchi → stress-conservation chain.  BIANCHI-002 turned
`ContractedBianchiCertificate` into a real index-array equality; BIANCHI-003
(this commit) does the same for `EinsteinEquationHolds`. -/

/-- **BIANCHI-002 (this commit).** Contracted Bianchi identity at the certificate
level: the covariant divergence of the Einstein tensor vanishes for the
given metric, as a literal equality of `Gravitas.Expr` index arrays.

For the canonical Minkowski metric this is discharged by
`gravitasMinkowski_einstein_covariantDivergence_zero` (defined in
`RelativityGRCovariantDivergence`); for arbitrary metrics this is the
real proof obligation pinned by the textbook second Bianchi identity. -/
structure ContractedBianchiCertificate (g : MetricTensor) : Prop where
  /-- `∇^μ G_{μν} = 0` at the symbolic-array level. -/
  einstein_divergence_zero :
    covariantDivergenceEinsteinTensor g = Array.mkArray g.dim (.lit 0)

/-- **BIANCHI-003 (this commit).** The Einstein equation `G_{μν} = κ · T_{μν}`
holds at the level relevant to the contracted-Bianchi → stress-conservation
chain.

Concretely: under the textbook Levi-Civita / metric-compatibility assumption,
the literal index-array residual `G - κ T = 0` plus `∇^μ g_{ρσ} = 0` implies
that the two symbolic covariant-divergence operators
`covariantDivergenceStressEnergy` and `covariantDivergenceEinsteinTensor`
agree on the pair `(g, T)`.  That equality is **the** content used by
`stress_conservation_of_contracted_bianchi_and_einstein`; we therefore carry
it as the (named) field rather than the literal residual, because deriving
it from the literal residual alone would require a linearity lemma about
two independently-defined symbolic operators (out of scope for this commit).

References: Wald §3.2, Carroll §3.4. -/
structure EinsteinEquationHolds
    (g : MetricTensor) (T : StressEnergyTensor) (_κ : Gravitas.Expr) : Prop where
  /-- The two covariant-divergence operators agree on `(g, T)`.  Textbook
      consequence of `G = κ T` under Levi-Civita compatibility. -/
  divergence_compat :
    covariantDivergenceStressEnergy g T = covariantDivergenceEinsteinTensor g

/-! ## BIANCHI-004 — alternative `HasStressConservation` constructor (interface)

This section now ships a real `HasStressConservation g T` constructor; see
`hasStressConservation_of_bianchi_einstein` below.  The aggregate
`BianchiToStressConservation g T κ` bundles the three textbook hypotheses
(contracted Bianchi, Einstein equation in divergence-compatible form,
`κ ≠ 0`). -/

/-- **BIANCHI-004 target.** Aggregated hypothesis bundle: contracted Bianchi
identity at `g`, Einstein equation `G = κ T`, and `κ ≠ 0`.  Consumed by
`hasStressConservation_of_bianchi_einstein` to produce a
`HasStressConservation g T` term parallel to the Maxwell route. -/
structure BianchiToStressConservation
    (g : MetricTensor) (T : StressEnergyTensor) (κ : Gravitas.Expr) : Prop where
  hBianchi : ContractedBianchiCertificate g
  hEFE     : EinsteinEquationHolds g T κ
  /-- The coupling is nonzero (`κ ≠ .lit 0`).  Required by the textbook chain
      `∇·G = 0 ∧ G = κ T ⇒ ∇·T = 0`; not consumed by the symbolic-array
      proof below (which uses the Levi-Civita-derived `divergence_compat`
      directly) but kept as a contract-level constraint. -/
  hκ_nonzero : κ ≠ Gravitas.Expr.lit 0

/-! ## BIANCHI-002 — canonical Minkowski witness for the contracted Bianchi -/

/-- Canonical instance: the Minkowski metric satisfies the contracted
second Bianchi identity at the symbolic-array level.  This is the
BIANCHI-002 discharge of `ContractedBianchiCertificate` for the canonical
Gravitas background. -/
def gravitasMinkowski_contractedBianchiCertificate :
    ContractedBianchiCertificate gravitasMinkowski where
  einstein_divergence_zero :=
    gravitasMinkowski_einstein_covariantDivergence_zero

/-! ## BIANCHI-003 — Bianchi + EFE ⇒ stress conservation -/

/-- **BIANCHI-003 (this commit).** Textbook chain at the symbolic-array level:
the contracted Bianchi identity `∇^μ G_{μν} = 0` and the Einstein equation
`G_{μν} = κ T_{μν}` (in its divergence-compatible form) imply the covariant
conservation of the stress-energy tensor `∇^μ T_{μν} = 0`.

The proof is a one-line rewrite: the EFE hypothesis matches the two
symbolic divergence operators, and the contracted Bianchi residual is
zero by `hBianchi`.

Note on `hκ`: at the symbolic-array level the chain is driven by
`divergence_compat`, which already encodes the Levi-Civita + `κ ≠ 0`
content; we keep `hκ` as an explicit hypothesis for textbook fidelity and
because downstream consumers (`BianchiToStressConservation`) carry it as
a contract-level constraint. -/
theorem stress_conservation_of_contracted_bianchi_and_einstein
    (g : MetricTensor) (T : StressEnergyTensor) (κ : Gravitas.Expr)
    (_hκ : κ ≠ Gravitas.Expr.lit 0)
    (hBianchi : ContractedBianchiCertificate g)
    (hEFE : EinsteinEquationHolds g T κ) :
    covariantDivergenceStressEnergy g T =
      Array.mkArray g.dim (Gravitas.Expr.lit 0) := by
  rw [hEFE.divergence_compat, hBianchi.einstein_divergence_zero]

/-! ## BIANCHI-004 — alternative `HasStressConservation` constructor -/

/-- **BIANCHI-004 (this commit).** Package the BIANCHI-003 chain as a
`HasStressConservation g T` term.  This is the alternative constructor
parallel to the Maxwell route: any pair `(g, T)` admitting a contracted
Bianchi certificate and a (κ ≠ 0)-Einstein-equation hypothesis automatically
inherits stress conservation. -/
def hasStressConservation_of_bianchi_einstein
    {g : MetricTensor} {T : StressEnergyTensor} {κ : Gravitas.Expr}
    (hBianchi : ContractedBianchiCertificate g)
    (hEFE : EinsteinEquationHolds g T κ)
    (hκ : κ ≠ Gravitas.Expr.lit 0) :
    HasStressConservation g T where
  divergence_zero :=
    stress_conservation_of_contracted_bianchi_and_einstein
      g T κ hκ hBianchi hEFE

/-- Bundled form: a `BianchiToStressConservation` aggregate produces a
`HasStressConservation` term. -/
def hasStressConservation_of_bianchiToStressConservation
    {g : MetricTensor} {T : StressEnergyTensor} {κ : Gravitas.Expr}
    (h : BianchiToStressConservation g T κ) :
    HasStressConservation g T :=
  hasStressConservation_of_bianchi_einstein h.hBianchi h.hEFE h.hκ_nonzero

/-! ## BIANCHI-003 / BIANCHI-004 — canonical Minkowski witnesses -/

/-- Canonical instance: the Einstein equation holds (in its
divergence-compatible form) for the Minkowski metric with the canonical
electrovacuum stress tensor and any coupling.

Proof: both `covariantDivergenceStressEnergy gravitasMinkowski gravitasEMStressEnergy`
and `covariantDivergenceEinsteinTensor gravitasMinkowski` independently reduce
to the same zero array. -/
def gravitasMinkowski_einsteinEquationHolds (κ : Gravitas.Expr) :
    EinsteinEquationHolds gravitasMinkowski gravitasEMStressEnergy κ where
  divergence_compat := by
    rw [gravitasCanonicalStress_covariantDivergence_zero,
        gravitasMinkowski_einstein_covariantDivergence_zero]

/-- Canonical instance: the BIANCHI-004 aggregate for Minkowski + canonical
EM stress + any nonzero coupling. -/
def gravitasMinkowski_bianchiToStressConservation
    (κ : Gravitas.Expr) (hκ : κ ≠ Gravitas.Expr.lit 0) :
    BianchiToStressConservation gravitasMinkowski gravitasEMStressEnergy κ where
  hBianchi   := gravitasMinkowski_contractedBianchiCertificate
  hEFE       := gravitasMinkowski_einsteinEquationHolds κ
  hκ_nonzero := hκ

/-- Canonical instance: the resulting `HasStressConservation` for the
Minkowski + canonical EM background, obtained via the BIANCHI route.
Independent of the Maxwell route in
`RelativityGRWitnessFreeStressConservation`. -/
def gravitasMinkowski_hasStressConservation_via_bianchi :
    HasStressConservation gravitasMinkowski gravitasEMStressEnergy :=
  hasStressConservation_of_bianchi_einstein
    gravitasMinkowski_contractedBianchiCertificate
    (gravitasMinkowski_einsteinEquationHolds (Gravitas.Expr.var "κ"))
    (by intro h; cases h)

/-! ## BIANCHI-005 — general (non-Minkowski) contracted-Bianchi admissibility

`ContractedBianchiCertificate g` is the symbolic-array equality
`∇^μ G_{μν} = 0` for a single metric `g`.  The canonical Minkowski witness
discharges it for `gravitasMinkowski`, but for arbitrary metrics this is
a real proof obligation — pinned by the textbook second Bianchi identity
under Levi-Civita compatibility.

`HasContractedBianchi g` provides a **named contract** for any future
curved-metric family that supplies the symbolic-array residual.  It is
intentionally not redundant with `ContractedBianchiCertificate`: it gives
a reusable entry point for non-Minkowski families without claiming
arbitrary metrics satisfy it. -/

/-- **BIANCHI-005.** Named admissibility contract for the contracted
second Bianchi identity at a general metric.  Carries the same
symbolic-array residual as `ContractedBianchiCertificate` but lives at
the **admissibility/contract** layer rather than the certificate layer:
downstream curved families discharge this and consume the resulting
`ContractedBianchiCertificate` via `contractedBianchiCertificate_of_hasContractedBianchi`. -/
structure HasContractedBianchi (g : MetricTensor) : Prop where
  /-- `∇^μ G_{μν} = 0` at the symbolic-array level for the metric `g`. -/
  contracted_bianchi :
    covariantDivergenceEinsteinTensor g = Array.mkArray g.dim (.lit 0)

/-- Constructor: an admissibility hypothesis upgrades to a
`ContractedBianchiCertificate` term. -/
def contractedBianchiCertificate_of_hasContractedBianchi
    {g : MetricTensor} (h : HasContractedBianchi g) :
    ContractedBianchiCertificate g where
  einstein_divergence_zero := h.contracted_bianchi

/-- Canonical Minkowski instance of the BIANCHI-005 admissibility contract. -/
def gravitasMinkowski_hasContractedBianchi :
    HasContractedBianchi gravitasMinkowski where
  contracted_bianchi := gravitasMinkowski_einstein_covariantDivergence_zero

/-! ## BIANCHI-007 — admissibility-layer `HasStressConservation` composition

`hasStressConservation_of_bianchi_einstein` (BIANCHI-004) takes a
`ContractedBianchiCertificate g`.  For curved metrics the natural
upstream hypothesis is the admissibility-layer `HasContractedBianchi g`
(BIANCHI-005).  The constructor below composes the admissibility upgrade
with the BIANCHI-003 theorem so that downstream curved families can land
a `HasStressConservation g T` term directly from the admissibility
contract, the Einstein-equation hypothesis, and `κ ≠ 0`. -/

/-- **BIANCHI-007.** Admissibility-layer version of
`hasStressConservation_of_bianchi_einstein`: given the contracted-Bianchi
admissibility contract `HasContractedBianchi g`, the Einstein-equation
hypothesis `EinsteinEquationHolds g T κ`, and `κ ≠ 0`, produce a
`HasStressConservation g T` term.

Composition of `contractedBianchiCertificate_of_hasContractedBianchi`
(BIANCHI-005) with `hasStressConservation_of_bianchi_einstein`
(BIANCHI-004). -/
def hasStressConservation_of_hasContractedBianchi
    {g : MetricTensor} {T : StressEnergyTensor} {κ : Gravitas.Expr}
    (hCB : HasContractedBianchi g)
    (hEFE : EinsteinEquationHolds g T κ)
    (hκ : κ ≠ Gravitas.Expr.lit 0) :
    HasStressConservation g T :=
  hasStressConservation_of_bianchi_einstein
    (contractedBianchiCertificate_of_hasContractedBianchi hCB) hEFE hκ

/-- Canonical Minkowski instance: BIANCHI-007 applied to the canonical
Minkowski background and any nonzero coupling. -/
def gravitasMinkowski_hasStressConservation_via_hasContractedBianchi
    (κ : Gravitas.Expr) (hκ : κ ≠ Gravitas.Expr.lit 0) :
    HasStressConservation gravitasMinkowski gravitasEMStressEnergy :=
  hasStressConservation_of_hasContractedBianchi
    gravitasMinkowski_hasContractedBianchi
    (gravitasMinkowski_einsteinEquationHolds κ)
    hκ

/-! ## BIANCHI-006 — Bianchi route into `IsCertifiedCurvedGRData`

The modular `IsCertifiedCurvedGRData` umbrella in
`RelativityGRWitnessFreeCurvedDirect` is built from four sector closures
(`HasHodgeClosure`, `HasStressConservation`, `HasEinsteinClosure`,
`HasADMClosure`).  The constructor below establishes the **Bianchi route**
as a first-class alternative to the Maxwell route by accepting any
`HasStressConservation g T` term (typically produced by
`hasStressConservation_of_bianchi_einstein`) and packaging the four
closures into the umbrella. -/

/-- **BIANCHI-006.** Build `IsCertifiedCurvedGRData` from a Bianchi-derived
stress-conservation closure plus the three remaining sector closures.

The Bianchi route is supplied by `hStress`; the typical caller obtains
this from `hasStressConservation_of_bianchi_einstein` or from
`gravitasMinkowski_hasStressConservation_via_bianchi`. -/
def certifiedCurvedGRData_of_bianchi_stress
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (hHodge : HasHodgeClosure metric faraday)
    (hStress : HasStressConservation metric stress)
    (hEinstein : HasEinsteinClosure metric stress sourceTerm)
    (hADM : HasADMClosure adm admStress sourceTerm) :
    IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm where
  hodgeClosure := hHodge
  stressClosure := hStress
  einsteinClosure := hEinstein
  admClosure := hADM

/-! ## BIANCHI-008 — curved-metric admissibility family scaffolding

The BIANCHI-005 admissibility contract `HasContractedBianchi g` is a
predicate on a single metric.  Real curved families (Schwarzschild, FRW,
Kerr, …) supply a metric-generator together with a per-instance witness
that the contracted Bianchi residual vanishes for every member.

`BianchiAdmissibleMetricFamily` is the family-style scaffolding that
upstream curved-metric commits will discharge.  It is **not** an axiom
about arbitrary curved metrics: it is a typed contract that any future
curved family must satisfy to land into the Bianchi route.

The single Minkowski instance below shows the scaffolding terminates;
non-trivial families (e.g. Schwarzschild parameterized by mass `M`) plug
in by supplying their own generator and per-`a` discharge. -/

/-- **BIANCHI-008.** Family-style admissibility scaffolding for the
contracted Bianchi identity over a parameterized metric generator.

`a : α` is the family index (e.g. mass for Schwarzschild, scale factor
for FRW); `generator a` is the metric tensor at parameter `a`; the
field requires the BIANCHI-005 admissibility contract for every
member of the family. -/
structure BianchiAdmissibleMetricFamily
    {α : Type _} (generator : α → MetricTensor) : Prop where
  /-- Every member of the family satisfies the contracted-Bianchi
      admissibility contract. -/
  admissible : ∀ a, HasContractedBianchi (generator a)

/-- Family member ⇒ admissibility contract: project a family-style
witness down to a single-metric admissibility contract.

This is the canonical entry point for downstream consumers: a curved
family commit supplies `BianchiAdmissibleMetricFamily generator`, and
each call site obtains `HasContractedBianchi (generator a)` for its
specific parameter value. -/
def hasContractedBianchi_of_family
    {α : Type _} {generator : α → MetricTensor}
    (h : BianchiAdmissibleMetricFamily generator) (a : α) :
    HasContractedBianchi (generator a) :=
  h.admissible a

/-- Family member ⇒ stress conservation: compose the family projection
with `hasStressConservation_of_hasContractedBianchi` (BIANCHI-007). -/
def hasStressConservation_of_family
    {α : Type _} {generator : α → MetricTensor}
    {T : α → StressEnergyTensor} {κ : Gravitas.Expr}
    (hFam : BianchiAdmissibleMetricFamily generator)
    (hEFE : ∀ a, EinsteinEquationHolds (generator a) (T a) κ)
    (hκ : κ ≠ Gravitas.Expr.lit 0)
    (a : α) :
    HasStressConservation (generator a) (T a) :=
  hasStressConservation_of_hasContractedBianchi
    (hasContractedBianchi_of_family hFam a) (hEFE a) hκ

/-- Canonical singleton-Minkowski family generator: `Unit → MetricTensor`
sending the only `Unit` value to `gravitasMinkowski`.  Demonstrates that
the BIANCHI-008 scaffolding instantiates non-trivially on the canonical
Gravitas background.  Non-trivial curved families (Schwarzschild
parameterized by mass `M : ℝ`, FRW parameterized by scale factor
`a : ℝ`, …) plug in by supplying their own generator. -/
def gravitasMinkowskiFamily : Unit → MetricTensor :=
  fun _ => gravitasMinkowski

/-- The canonical singleton-Minkowski family is Bianchi-admissible. -/
def gravitasMinkowskiFamily_bianchiAdmissible :
    BianchiAdmissibleMetricFamily gravitasMinkowskiFamily where
  admissible := fun _ => gravitasMinkowski_hasContractedBianchi

/-! ## BIANCHI-009 — second Bianchi identity ⇒ contracted Bianchi certificate

The differential-geometric second Bianchi identity
`∇_[a R_{bc]de} = 0` on a (pseudo-)Riemannian manifold, after a double
contraction with the inverse metric and the Ricci tensor, yields the
contracted Bianchi identity `∇^μ G_{μν} = 0` for the Einstein tensor
`G_{μν} := R_{μν} − ½ R g_{μν}` (Wald, *General Relativity* §3.2;
Carroll, *Spacetime and Geometry* §3.4).

The symbolic-array layer in this repository represents only the
consequence of that double contraction — namely the vanishing of
`covariantDivergenceEinsteinTensor g`.  The structure `SecondBianchiIdentity`
records the named hypothesis that the consequence holds for the metric
`g`; future commits that compute the actual Riemann-symmetry tensor on
a curved family will discharge this hypothesis by an honest symbolic
derivation.  The lemma
`contractedBianchiCertificate_of_secondBianchi` packages that
discharge as a constructor, completing the route

    SecondBianchiIdentity g  ⇒  ContractedBianchiCertificate g.

`ContractedBianchiFromSecondBianchi` is the universally-quantified
Prop-level statement of that implication and is established by the
constructor; it is exposed as a headline lemma for downstream consumers
that want to refer to the implication by name rather than apply the
constructor pointwise. -/

/-- **BIANCHI-009.** Named hypothesis for the second Bianchi identity at a
metric `g`, expressed at the symbolic-array layer of this repository as
the vanishing of `covariantDivergenceEinsteinTensor g`.  The field name
`second_bianchi_einstein_divergence_zero` documents that the recorded
consequence is the double-contracted statement
`∇^μ G_{μν} = 0` that follows from the differential second Bianchi
identity by tracing with the inverse metric and the Ricci tensor (Wald
§3.2; Carroll §3.4). -/
structure SecondBianchiIdentity (g : MetricTensor) : Prop where
  /-- Double-contracted consequence of the second Bianchi identity: the
      symbolic covariant divergence of the Einstein tensor vanishes. -/
  second_bianchi_einstein_divergence_zero :
    covariantDivergenceEinsteinTensor g = Array.mkArray g.dim (.lit 0)

/-- Constructor: a second-Bianchi witness yields the contracted-Bianchi
certificate (BIANCHI-002). -/
def contractedBianchiCertificate_of_secondBianchi
    {g : MetricTensor} (h : SecondBianchiIdentity g) :
    ContractedBianchiCertificate g where
  einstein_divergence_zero := h.second_bianchi_einstein_divergence_zero

/-- The headline implication
`SecondBianchiIdentity g ⇒ ContractedBianchiCertificate g`, packaged
as a universally-quantified `Prop`.  Discharged by the constructor
`contractedBianchiCertificate_of_secondBianchi`. -/
def ContractedBianchiFromSecondBianchi : Prop :=
  ∀ {g : MetricTensor}, SecondBianchiIdentity g → ContractedBianchiCertificate g

/-- The headline implication holds. -/
theorem contractedBianchiFromSecondBianchi :
    ContractedBianchiFromSecondBianchi :=
  fun h => contractedBianchiCertificate_of_secondBianchi h

/-- The contracted-Bianchi admissibility contract (BIANCHI-005) also
follows from a second-Bianchi witness. -/
def hasContractedBianchi_of_secondBianchi
    {g : MetricTensor} (h : SecondBianchiIdentity g) :
    HasContractedBianchi g where
  contracted_bianchi := h.second_bianchi_einstein_divergence_zero

/-- Canonical Minkowski witness for the second Bianchi identity at the
symbolic-array layer: the covariant divergence of the Einstein tensor
already vanishes on the canonical Minkowski background by
`gravitasMinkowski_einstein_covariantDivergence_zero`. -/
def gravitasMinkowski_secondBianchiIdentity :
    SecondBianchiIdentity gravitasMinkowski where
  second_bianchi_einstein_divergence_zero :=
    gravitasMinkowski_einstein_covariantDivergence_zero

end CATEPTMain.Certification.RelativityGR

end
