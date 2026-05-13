/-
# LC-005 — Smooth second Bianchi identity (semantic statement)

REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS / Missing 6 →
LC-ladder, step 5 (LC-005).

This file states the second Bianchi identity at the **smooth**
(non-symbolic) layer, plus a constructor
`smooth_second_bianchi_of_leviCivita` that produces it from a
Levi-Civita witness.

At LC-005 the `second_bianchi` field is a named `Prop` placeholder.
Later LC-steps will replace it by the actual antisymmetrised covariant
derivative equation `∇_{[a} R_{bc]de} = 0`, contracted to
`∇^μ G_{μν} = 0`.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothBianchi`
  passes;
* `#check SmoothSecondBianchiIdentity` and
  `#check smooth_second_bianchi_of_leviCivita` elaborate;
* `#print axioms` on the GuardAlias entries is axiom-free.

## Tracking

* REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS — Missing 6
* LC-ladder: LC-005 (this file).  Parents: LC-001 / LC-002 (+ LC-003
  for tensor-field shape, LC-004 for the divergence operator the
  contracted form feeds into).
-/

import CATEPTMain.Certification.RelativityGRLeviCivitaDivergence

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

/-- Smooth second Bianchi identity on `(X, ∇)` with Levi-Civita
witness `hLC`.

`second_bianchi` names the antisymmetrised covariant-derivative
equation `∇_{[a} R_{bc]de} = 0`.  At LC-005 it is a `Prop` placeholder;
LC-006+ will replace it by the genuine equation on `SmoothTensorField`
and feed the contracted form into `leviCivitaDivergenceEinsteinTensor`. -/
structure SmoothSecondBianchiIdentity
    {X : SmoothPseudoRiemannianManifold}
    (connection : SmoothConnection X)
    (hLC : IsLeviCivitaConnection connection) where
  /-- The antisymmetrised covariant derivative of the Riemann tensor
  vanishes: `∇_{[a} R_{bc]de} = 0`. -/
  second_bianchi : Prop

/-- The second Bianchi identity holds for the Levi-Civita connection of
any smooth pseudo-Riemannian manifold.

At LC-005 the conclusion uses a `Prop` placeholder (`True`); LC-006+
will replace it by the genuine smooth-tensor equation and prove it from
torsion-freeness of `∇`. -/
def smooth_second_bianchi_of_leviCivita
    {X : SmoothPseudoRiemannianManifold}
    (connection : SmoothConnection X)
    (hLC : IsLeviCivitaConnection connection) :
    SmoothSecondBianchiIdentity connection hLC :=
  let _ := hLC
  { second_bianchi := True }

end CATEPTMain.Certification.RelativityGR

end
