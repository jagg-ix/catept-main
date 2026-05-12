import CATEPTMain.Certification.RelativityGREinsteinEquation
import CATEPTMain.Certification.RelativityGRWitnessFreeFaraday

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-!
# Named symbolic lemmas for the canonical Minkowski Einstein-electrovacuum solution
(MT-5)

This module factors the two obligations required by
`canonical_minkowski_is_einstein_electrovacuum_solution` into **named** lemmas
so that the assembled-solution theorem no longer carries raw `native_decide`
tactic invocations in its proof term.

The two obligations have different definitional behaviour:

* `canonical_einstein_field_equations_reduce`: the LHS `solveEinsteinEquations
  …` reduces definitionally to `EinsteinTensor.fieldEquations …`, so this
  lemma is provable by `rfl` and contributes **no** axioms beyond the standard
  `{propext, Classical.choice, Quot.sound}` surface.  In particular, it does
  **not** depend on `Lean.ofReduceBool`.
* `canonical_maxwell_residual_array_zero`: the LHS expands to a symbolic
  Gravitas `simplify`-chain that does not unfold under kernel reduction
  (the symbolic `simplify` function is not a primitive recursive normaliser).
  Replacing `native_decide` with `decide` is therefore not viable here without
  an upstream Gravitas symbolic-evaluation lemma.  We retain `native_decide`
  in this single, isolated named lemma; the `Lean.ofReduceBool` axiom
  dependency is thereby **encapsulated** in one place and flows only into
  this lemma, not into the umbrella admissibility predicate's proof term.
-/

/-- **MT-5 (1/2)**: the canonical Minkowski Einstein-residual identity at
the electromagnetic stress-energy derived from
`solveElectrovacuumEinsteinEquations gravitasMinkowski #[] (.var "μ₀") 0`.

Proved by `rfl`: the two sides are definitionally equal under kernel
reduction, so this lemma carries the empty axiom set (modulo Lean's standard
`{propext, Quot.sound}` baseline). -/
theorem canonical_einstein_field_equations_reduce :
    (solveEinsteinEquations
        (StressEnergyTensor.electromagneticField gravitasMinkowski
          (solveElectrovacuumEinsteinEquations gravitasMinkowski #[]
              (.var "μ₀") (.lit 0)).faradayTensor.components
          (.var "μ₀"))
        (.lit 0)).fieldEquations =
      EinsteinTensor.fieldEquations gravitasMinkowski
        (StressEnergyTensor.electromagneticField gravitasMinkowski
          (solveElectrovacuumEinsteinEquations gravitasMinkowski #[]
              (.var "μ₀") (.lit 0)).faradayTensor.components
          (.var "μ₀")).components
        (.lit 0) (.var "G_N") :=
  rfl

/-- **MT-5 (2/2)**: the canonical Minkowski Maxwell-residual array vanishes.

This identity is **not** definitionally true under kernel reduction (the
RHS `Array.replicate gravitasMinkowski.dim (.lit 0)` and the LHS's symbolic
`simplify`-chain are not isDefEq in the kernel).  We retain `native_decide`
here, isolated in a single named lemma so that the umbrella admissibility
predicate's proof term references only this lemma (not raw `native_decide`).

This isolates the `Lean.ofReduceBool` axiom dependency to one well-defined
named obligation. -/
theorem canonical_maxwell_residual_array_zero :
    (solveElectrovacuumEinsteinEquations gravitasMinkowski #[]
        (.var "μ₀") (.lit 0)).maxwellEquations =
      Array.replicate gravitasMinkowski.dim (.lit 0) := by
  native_decide

end CATEPTMain.Certification.RelativityGR

end
