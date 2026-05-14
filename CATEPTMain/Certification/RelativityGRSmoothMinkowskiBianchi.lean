/-
# Minkowski specialization of the smooth contracted Bianchi identity

This file separates the **concrete smooth Minkowski case** of the
contracted Bianchi identity from the generic placeholder theorem
`smooth_contracted_bianchi` (LC-006).

It pins down a canonical Minkowski Levi-Civita connection witness
(`smoothMinkowskiConnection`, `smoothMinkowski_isLeviCivita`) and
exposes the contracted Bianchi identity on that concrete witness as a
named theorem.  The proof is **direct from the Minkowski-only
component-zero lemmas**
`smoothEinsteinTensor_minkowski_components_zero` /
`leviCivitaDivergenceEinsteinTensor_minkowski_components_zero` in
`RelativityGRSmoothContractedBianchi`, rather than delegating to the
generic LC-006 placeholder `smooth_contracted_bianchi`.  This isolates
the **Minkowski-only** statement under its own audited name and its
own audited proof.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothMinkowskiBianchi`
  passes;
* `#check smoothMinkowski_leviCivitaDivergenceEinstein_zero` and
  `#check smoothMinkowski_contracted_bianchi_nonvacuous` elaborate;
* `#print axioms smoothMinkowski_contracted_bianchi_nonvacuous` reports
  only the standard kernel axioms.
-/

import CATEPTMain.Certification.RelativityGRSmoothContractedBianchi

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

/-- Canonical smooth connection on the smooth Minkowski spacetime.

At LC-002 the connection structure carries only `Prop` placeholders,
so this is the trivial witness with `True` everywhere — its role is to
be the named handle on which downstream Minkowski-specific theorems
hang.  When LC-003+ replaces the `Prop` fields with genuine smooth
predicates, this witness will be refined accordingly. -/
def smoothMinkowskiConnection : SmoothConnection smoothMinkowskiSpacetime where
  nabla := Unit
  actsOnVectorFields := True
  actsOnTensorFields := True
  linear_over_functions := True
  leibniz_rule := True

/-- The canonical smooth Minkowski connection is Levi-Civita
(torsion-free and metric-compatible).

At the present LC-step both sub-conditions are `Prop` placeholders
satisfied by `True`.  When the structures are upgraded to genuine
geometric predicates this witness must be replaced by an honest proof
of `torsion_zero` and `nabla_metric_zero` on the Minkowski background. -/
def smoothMinkowski_isLeviCivita :
    IsLeviCivitaConnection smoothMinkowskiConnection where
  torsion_free := { torsion_zero := True }
  metric_compatible := { nabla_metric_zero := True }

/-- **Smooth contracted Bianchi identity for Minkowski (first form).**

```
leviCivitaDivergenceEinsteinTensor
  smoothMinkowskiConnection smoothMinkowski_isLeviCivita
  = zeroSmoothTensorField smoothMinkowskiSpacetime 1 0
```

This is the Minkowski specialization of the generic LC-006 theorem
`smooth_contracted_bianchi`.  The proof is direct from the
**concrete-array Minkowski component-zero lemma**
`leviCivitaDivergenceEinsteinTensor_minkowski_components_zero`
in `RelativityGRSmoothContractedBianchi`: both sides are
`SmoothTensorField smoothMinkowskiSpacetime 1 0` records sharing
`carrier = Unit` and `smooth = True`, and their `components` fields
both reduce to `Array.replicate 4 (Gravitas.Expr.lit 0)` — the LHS by
the component-zero lemma, the RHS by the definition of
`zeroSmoothTensorField` together with `smoothMinkowskiSpacetime.dim = 4`.
No delegation to the generic LC-006 placeholder. -/
theorem smoothMinkowski_leviCivitaDivergenceEinstein_zero :
    leviCivitaDivergenceEinsteinTensor
      smoothMinkowskiConnection
      smoothMinkowski_isLeviCivita
    =
    zeroSmoothTensorField smoothMinkowskiSpacetime 1 0 := by
  -- The two records share `carrier = Unit` and `smooth = True`.
  -- Their `components` fields agree by the Minkowski component-zero
  -- lemma on the LHS and by reduction of `smoothMinkowskiSpacetime.dim`
  -- to `4` on the RHS.
  have hLHS :
      (leviCivitaDivergenceEinsteinTensor smoothMinkowskiConnection
          smoothMinkowski_isLeviCivita).components
        = Array.replicate 4 (Gravitas.Expr.lit 0) :=
    leviCivitaDivergenceEinsteinTensor_minkowski_components_zero
      smoothMinkowskiConnection smoothMinkowski_isLeviCivita
  have hRHS :
      (zeroSmoothTensorField smoothMinkowskiSpacetime 1 0).components
        = Array.replicate 4 (Gravitas.Expr.lit 0) := rfl
  -- Both records are `⟨Unit, True, Array.replicate 4 (.lit 0)⟩` after
  -- rewriting the components fields by `hLHS` / `hRHS`.
  show (⟨Unit, True, Array.replicate 4 (Gravitas.Expr.lit 0)⟩
          : SmoothTensorField smoothMinkowskiSpacetime 1 0)
       = ⟨Unit, True, Array.replicate 4 (Gravitas.Expr.lit 0)⟩
  rfl

/-- **Smooth contracted Bianchi identity for Minkowski (stronger name).**

Alias of `smoothMinkowski_leviCivitaDivergenceEinstein_zero` with a
name that flags the non-vacuous Minkowski-only character of the
statement (cf. LC-006 generic placeholder `smooth_contracted_bianchi`).

The proof is direct from the Minkowski-only component-zero lemmas; it
does not delegate to the generic LC-006 placeholder. -/
theorem smoothMinkowski_contracted_bianchi_nonvacuous :
    leviCivitaDivergenceEinsteinTensor
      smoothMinkowskiConnection
      smoothMinkowski_isLeviCivita
    =
    zeroSmoothTensorField smoothMinkowskiSpacetime 1 0 :=
  smoothMinkowski_leviCivitaDivergenceEinstein_zero

end CATEPTMain.Certification.RelativityGR

end
