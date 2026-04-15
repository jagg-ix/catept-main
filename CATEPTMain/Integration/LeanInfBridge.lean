import LeanInf.Basic
import LeanInf.LeviCivitaNum
/-!
# LeanInf Integration Bridge

Integrates [lean-inf](https://github.com/allofphysicsgraph/lean-inf) into CATEPT.

## What lean-inf provides

- `LeanInf.Basic`: Array comprehension notation, HashMap extensions, OrderedFloat wrapper,
  `Option.unwrapOr`, Lean.Rat / ℚ hashing utilities.
- `LeanInf.LeviCivitaNum`: Levi-Civita number field for non-standard analysis.
  A `LeviCivitaNum` is a formal power series in a formal infinitesimal `ε` with rational
  coefficients and rational exponents — capturing infinitesimals and infinite quantities
  algebraically.
- `LeanInf.Parser`: Expression parser for Levi-Civita calculator inputs.
- `LeanInf.SafeFloat`: IEEE 754 `OrderedFloat` wrapper ensuring total ordering.

## Integration status

- Phase: `direct_4_29` — lean-inf toolchain updated to v4.29.0, directly importable.
- lean-inf `ArrayFunctor.lean` is excluded from `LeanInf.lean` barrel (LeanCopilot dependency
  has been stripped; file retained as dead code for later port when needed).

## CATEPT usage hooks

The primary CATEPT use-case for lean-inf is Levi-Civita arithmetic in non-standard analysis
bridges — specifically for modelling infinitesimal perturbations in entropy-dissipation
estimates and for formalizing non-standard limit arguments in the VML bridge.
-/

namespace CATEPTMain.Integration.LeanInf

/-- Re-export: the Levi-Civita number type (formal power series in ε and H). -/
abbrev LCNum := LeviCivitaNum

/-- Re-export: the standard infinitesimal ε as a Levi-Civita number.
    `ε` has `infinitesimal = p[-ε]` (i.e., exp −1, coeff 1). -/
abbrev lcEpsilon : LCNum := LeviCivitaNum.ε

/-- Non-standard analysis: a number is purely infinitesimal iff its standard and
    infinite parts are both zero (only the infinitesimal part is non-zero). -/
def isInfinitesimal (x : LCNum) : Bool :=
  x.std == 0 && x.infinite == 0

end CATEPTMain.Integration.LeanInf
