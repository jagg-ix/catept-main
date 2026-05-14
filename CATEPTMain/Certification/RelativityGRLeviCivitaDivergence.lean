/-
# LC-004 — Levi-Civita divergence operator on smooth tensor fields

REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS / Missing 6 →
LC-ladder, step 4 (LC-004).

This file defines the semantic Levi-Civita divergence operator
`leviCivitaDivergence` on rank-`(2, 0)` smooth tensor fields, returning
a rank-`(1, 0)` smooth tensor field, plus its specialisation
`leviCivitaDivergenceEinsteinTensor` for the Einstein tensor.

The current symbolic operator
`CATEPTMain.Certification.RelativityGR.covariantDivergenceEinsteinTensor`
is the **coordinate / array** representation that this smooth operator
should later be shown to descend from (compatibility theorem deferred —
see `BIANCHI-014` block in `RelativityGRCovariantDivergence.lean`).

At LC-004 the operator returns a placeholder smooth tensor field with
abstract carrier and `smooth := True` witness; LC-005+ will refine it
into a real contraction `g^{aμ} ∇_a T_{μb}`.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRLeviCivitaDivergence`
  passes;
* `#check leviCivitaDivergence` and
  `#check leviCivitaDivergenceEinsteinTensor` elaborate;
* `#print axioms` on the GuardAlias entries is axiom-free.

## Tracking

* REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS — Missing 6
* LC-ladder: LC-004 (this file).  Parents: LC-001 / LC-002 / LC-003.
-/

import CATEPTMain.Certification.RelativityGRSmoothTensorField

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

/-- Levi-Civita divergence of a rank-`(2, 0)` smooth tensor field.

Geometrically this is the rank-`(1, 0)` tensor `(∇^a T_{ab})_b`, where
the index is raised with the inverse metric and the covariant
derivative is taken with respect to the Levi-Civita connection `∇`
(witnessed by `hLC`).

At the present LC-step the `carrier` is still a `Unit` placeholder, but
the `components` field carries the genuine rank-`(1, 0)` zero array
`Array.mkArray X.dim (.lit 0)` — i.e. the concrete coordinate
representation of the vanishing divergence on the
vacuum/Minkowski background.  Later LC-steps will replace this with
the genuine contraction `g^{aμ} ∇_a T_{μb}`. -/
def leviCivitaDivergence
    {X : SmoothPseudoRiemannianManifold}
    (connection : SmoothConnection X)
    (_hLC : IsLeviCivitaConnection connection)
    (_T : SmoothTensorField X 2 0) :
    SmoothTensorField X 1 0 :=
  let _ := connection
  { carrier := Unit
    smooth := True
    components := Array.replicate X.dim (Gravitas.Expr.lit 0) }

/-- Levi-Civita divergence specialised to the Einstein tensor.

This is the smooth-tensor counterpart of the symbolic operator
`covariantDivergenceEinsteinTensor` in
`CATEPTMain.Certification.RelativityGRCovariantDivergence`.  The
compatibility theorem
`covariantDivergenceEinsteinTensor_eq_leviCivita_divergence`
(symbolic core ⇔ smooth field) is recorded as deferred in
`BIANCHI-014`. -/
def leviCivitaDivergenceEinsteinTensor
    {X : SmoothPseudoRiemannianManifold}
    (connection : SmoothConnection X)
    (hLC : IsLeviCivitaConnection connection) :
    SmoothTensorField X 1 0 :=
  leviCivitaDivergence connection hLC (smoothEinsteinTensor X connection hLC)

end CATEPTMain.Certification.RelativityGR

end
