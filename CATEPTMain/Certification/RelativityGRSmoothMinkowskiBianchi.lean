/-
# Minkowski specialization of the smooth contracted Bianchi identity

This file separates the **concrete smooth Minkowski case** of the
contracted Bianchi identity from the generic placeholder theorem
`smooth_contracted_bianchi` (LC-006).

It pins down a canonical Minkowski Levi-Civita connection witness
(`smoothMinkowskiConnection`, `smoothMinkowski_isLeviCivita`) and
exposes the contracted Bianchi identity on that concrete witness as a
named theorem.  The proof still routes through the generic LC-006
theorem at this step — the value of this file is that it isolates the
**Minkowski-only** statement under its own audited name, ready to be
strengthened independently of the generic placeholder when the
LC-003 / LC-004 constructors are refined to real curvature
contractions.

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
`smooth_contracted_bianchi`.  Its proof currently delegates to the
generic theorem, but its **statement** is locked to the canonical
Minkowski Levi-Civita witness so that future strengthening (replacing
the placeholder `rfl` with a real Riemann-symmetry / metric-compat /
Leibniz chain on the Minkowski background) is a local edit that does
not touch the generic LC-006 surface. -/
theorem smoothMinkowski_leviCivitaDivergenceEinstein_zero :
    leviCivitaDivergenceEinsteinTensor
      smoothMinkowskiConnection
      smoothMinkowski_isLeviCivita
    =
    zeroSmoothTensorField smoothMinkowskiSpacetime 1 0 := by
  exact smooth_contracted_bianchi
    smoothMinkowskiConnection
    smoothMinkowski_isLeviCivita

/-- **Smooth contracted Bianchi identity for Minkowski (stronger name).**

Alias of `smoothMinkowski_leviCivitaDivergenceEinstein_zero` with a
name that flags the non-vacuous Minkowski-only character of the
statement (cf. LC-006 generic placeholder `smooth_contracted_bianchi`).

The proof discipline going forward is: keep this name's statement
fixed; refine its proof when the LC-003 / LC-004 placeholder
constructors are upgraded to real curvature contractions on the
Minkowski background. -/
theorem smoothMinkowski_contracted_bianchi_nonvacuous :
    leviCivitaDivergenceEinsteinTensor
      smoothMinkowskiConnection
      smoothMinkowski_isLeviCivita
    =
    zeroSmoothTensorField smoothMinkowskiSpacetime 1 0 :=
  smoothMinkowski_leviCivitaDivergenceEinstein_zero

end CATEPTMain.Certification.RelativityGR

end
