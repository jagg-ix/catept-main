/-
# Minkowski specialization of the smooth↔symbolic coordinate-array bridge

This file makes the LC-007 coordinate-array bridge non-trivial on the
canonical Minkowski background by recording two named theorems:

* `coordinateArrayOfSmoothMinkowskiEinsteinDivergence_zero` —
  the coordinate array extracted from the smooth Levi-Civita
  divergence of the Einstein tensor on Minkowski is the genuine
  `Array Gravitas.Expr` zero array of length
  `smoothMinkowskiSpacetime.dim`;
* `gravitasMinkowski_symbolic_divergence_matches_smooth` —
  the symbolic Gravitas `covariantDivergenceEinsteinTensor
  gravitasMinkowski` agrees with that same coordinate array.

Together they discharge the `representation` field of
`SymbolicEinsteinDivergenceRepresentsSmooth` for Minkowski without
extra manual witnesses, so a downstream instance can be built from
these two theorems plus the LC-007 `dim_match : X.dim = gSym.dim`.

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothMinkowskiCoordinateBridge`
  passes;
* `#check coordinateArrayOfSmoothMinkowskiEinsteinDivergence_zero` and
  `#check gravitasMinkowski_symbolic_divergence_matches_smooth`
  elaborate;
* `#print axioms` on both theorems reports only standard kernel axioms.
-/

import CATEPTMain.Certification.RelativityGRSmoothMinkowskiBianchi
import CATEPTMain.Certification.RelativityGRSmoothGravitasBridge

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open CATEPTMain.Integration.GravitasBridge

/-- **Coordinate-array witness for the smooth Minkowski Einstein
divergence.**

```
coordinateArrayOfSmoothTensor
  (leviCivitaDivergenceEinsteinTensor
    smoothMinkowskiConnection smoothMinkowski_isLeviCivita)
  = Array.mkArray smoothMinkowskiSpacetime.dim (.lit 0)
```

The equality is by `rfl`: `coordinateArrayOfSmoothTensor` projects the
`components` field of the smooth tensor, which on Minkowski is the
genuine `Array.replicate smoothMinkowskiSpacetime.dim (Gravitas.Expr.lit 0)`
populated by LC-004 / LC-006.  `Array.mkArray` is the project-local
alias for `Array.replicate`. -/
theorem coordinateArrayOfSmoothMinkowskiEinsteinDivergence_zero :
    coordinateArrayOfSmoothTensor
      (leviCivitaDivergenceEinsteinTensor
        smoothMinkowskiConnection
        smoothMinkowski_isLeviCivita)
    =
    Array.mkArray smoothMinkowskiSpacetime.dim (.lit 0) := by
  rfl

/-- **Symbolic↔smooth divergence match on Minkowski.**

```
covariantDivergenceEinsteinTensor gravitasMinkowski
  = coordinateArrayOfSmoothTensor
      (leviCivitaDivergenceEinsteinTensor
        smoothMinkowskiConnection smoothMinkowski_isLeviCivita)
```

This is the named equation required by the `representation` field of
`SymbolicEinsteinDivergenceRepresentsSmooth`.  Proof: rewrite the LHS
via `gravitasMinkowski_einstein_covariantDivergence_zero` and the RHS
via `coordinateArrayOfSmoothMinkowskiEinsteinDivergence_zero`; both
reduce to `Array.mkArray 4 (.lit 0)`. -/
theorem gravitasMinkowski_symbolic_divergence_matches_smooth :
    covariantDivergenceEinsteinTensor gravitasMinkowski =
      coordinateArrayOfSmoothTensor
        (leviCivitaDivergenceEinsteinTensor
          smoothMinkowskiConnection
          smoothMinkowski_isLeviCivita) := by
  rw [gravitasMinkowski_einstein_covariantDivergence_zero,
      coordinateArrayOfSmoothMinkowskiEinsteinDivergence_zero]
  rfl

/-- Minkowski instance of the LC-007 symbolic↔smooth divergence
representation predicate.

Built directly from the two theorems above plus the rfl-level
dimension match `smoothMinkowskiSpacetime.dim = gravitasMinkowski.dim`
(both are `4`).  Demonstrates that
`SymbolicEinsteinDivergenceRepresentsSmooth` can be discharged for
Minkowski with **no extra manual witnesses**. -/
def gravitasMinkowski_symbolicEinsteinDivergenceRepresentsSmooth :
    SymbolicEinsteinDivergenceRepresentsSmooth
      smoothMinkowskiConnection
      smoothMinkowski_isLeviCivita
      gravitasMinkowski where
  representation := gravitasMinkowski_symbolic_divergence_matches_smooth
  dim_match := rfl

end CATEPTMain.Certification.RelativityGR

end
