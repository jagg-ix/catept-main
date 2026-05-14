/-
# LC-002 — Smooth connection & Levi-Civita predicate (semantic naming layer)

REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS / Missing 6 →
LC-ladder, step 2 (LC-002).

This file separates **a connection** from **the Levi-Civita connection**
at the semantic naming layer built in
`CATEPTMain.Certification.RelativityGRSmoothPseudoRiemannian` (LC-001).

The Levi-Civita connection is, by definition, the unique connection that
is

* **torsion-free**          (`IsTorsionFree`)
* **metric-compatible**     (`IsMetricCompatible`).

We name both conditions and the conjunction (`IsLeviCivitaConnection`)
as `Prop`-valued structures.  Curvature, Bianchi identities, and the
uniqueness theorem are deliberately **not** introduced at LC-002 — they
belong to later LC-steps (LC-003+ will introduce smooth tensor fields,
LC-004 the curvature tensor, LC-005 the second Bianchi identity, etc.).

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothConnection`
  passes;
* the following `#check`s elaborate:
  `SmoothConnection`, `IsLeviCivitaConnection`, `IsTorsionFree`,
  `IsMetricCompatible`;
* `#print axioms` on the Guard aliases below is axiom-free
  (the structures are pure data, no proofs invoked).

## Tracking

* REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS — Missing 6
* LC-ladder: LC-002 (this file).  Parent: LC-001
  (`RelativityGRSmoothPseudoRiemannian.lean`).
-/

import CATEPTMain.Certification.RelativityGRSmoothPseudoRiemannian

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

/-- A smooth connection on `X`.

`nabla` is the underlying operator carrier (Type placeholder; a later
LC-step will refine to a smooth bilinear map
`Γ(TM) × Γ(TM) → Γ(TM)`).  The four `Prop` fields name the abstract
axioms a connection must satisfy:

* `actsOnVectorFields`   — `∇ : Γ(TM) × Γ(TM) → Γ(TM)`;
* `actsOnTensorFields`   — `∇` extends to all tensor bundles;
* `linear_over_functions`— `∇_{fX} Y = f · ∇_X Y` for any smooth `f`;
* `leibniz_rule`         — `∇_X (f · Y) = (X · f) · Y + f · ∇_X Y`.

At LC-002 these are abstract conditions; LC-003+ will substitute real
predicates once smooth tensor fields are in scope. -/
structure SmoothConnection (X : SmoothPseudoRiemannianManifold) where
  /-- Carrier of the connection operator. -/
  nabla : Type
  /-- `∇` acts on smooth vector fields. -/
  actsOnVectorFields : Prop
  /-- `∇` extends to general tensor fields. -/
  actsOnTensorFields : Prop
  /-- `∇_{f X} Y = f · ∇_X Y` (`C^∞(M)`-linearity in the lower slot). -/
  linear_over_functions : Prop
  /-- `∇_X (f Y) = (X · f) Y + f · ∇_X Y` (Leibniz / product rule). -/
  leibniz_rule : Prop

/-- Torsion-free condition: `∇_X Y − ∇_Y X = [X, Y]`. -/
structure IsTorsionFree
    {X : SmoothPseudoRiemannianManifold}
    (connection : SmoothConnection X) where
  /-- `T(X, Y) = ∇_X Y − ∇_Y X − [X, Y] = 0`. -/
  torsion_zero : Prop

/-- Metric-compatibility condition: `∇ g = 0`. -/
structure IsMetricCompatible
    {X : SmoothPseudoRiemannianManifold}
    (connection : SmoothConnection X) where
  /-- `∇ g = 0` (the connection preserves the metric). -/
  nabla_metric_zero : Prop

/-- Levi-Civita connection: torsion-free **and** metric-compatible.

The fundamental theorem of pseudo-Riemannian geometry asserts that
there is exactly one such connection on `(M, g)`; uniqueness is a
separate target (deferred — see worklog note below). -/
structure IsLeviCivitaConnection
    {X : SmoothPseudoRiemannianManifold}
    (connection : SmoothConnection X) where
  /-- Torsion vanishes. -/
  torsion_free : IsTorsionFree connection
  /-- Metric compatibility. -/
  metric_compatible : IsMetricCompatible connection

/-! ## LC-002 worklog notes

The following targets are intentionally **deferred** to later LC-steps:

* `theorem leviCivita_unique` — uniqueness of the Levi-Civita
  connection.  Requires the Koszul formula, which in turn requires
  `linear_over_functions` and `leibniz_rule` to be real predicates
  over smooth tensor fields (LC-003 prerequisite).
* `def leviCivitaOf (X : SmoothPseudoRiemannianManifold) :
    SmoothConnection X` together with the existence proof
  `theorem leviCivitaOf_isLeviCivita : IsLeviCivitaConnection
   (leviCivitaOf X)`.
* The downstream consumer
  `theorem contracted_bianchi_leviCivita
    (g : MetricTensor) (hLC : IsLeviCivitaConnection …) :
    covariantDivergenceEinsteinTensor g = Array.mkArray g.dim (.lit 0)`
  recorded as deferred in
  `CATEPTMain.Certification.RelativityGRCovariantDivergence`
  (`BIANCHI-014` block).

Acceptance criteria for closing each deferred target: real theorems
(no axioms, no `sorry`), audit-pure under
`[propext, Classical.choice, Quot.sound]`, with at least one
non-Minkowski instance discharging `IsLeviCivitaConnection`. -/

end CATEPTMain.Certification.RelativityGR

end
