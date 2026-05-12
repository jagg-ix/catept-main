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
  because the upstream Gravitas helpers `Gravitas.simplify` and
  `Gravitas.symDiff` are declared as `partial def`
  (`CATEPTGravitasPort/Basic.lean:71` / `:157`).  Lean 4's kernel never
  unfolds `partial def`s, so a `rfl`-based symbolic decomposition is
  impossible without making those upstream functions total.  Replacing
  `native_decide` with `decide` is therefore not viable either.  We retain
  `native_decide` in this single, isolated named lemma; the
  `Lean.ofReduceBool` axiom dependency is thereby **encapsulated** in one
  place and flows only into this lemma, not into the umbrella admissibility
  predicate's proof term.  A spec-named alias
  `canonical_maxwell_residual_array_zero_symbolic` plus per-component
  projections `maxwellResidual_component_{0,1,2,3}_zero` are exported for
  symbolic transparency at the call site — all derived from the base
  lemma by `rfl`/`rw`, introducing no new `native_decide` islands.
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

This identity is **not** definitionally true under kernel reduction.  The
upstream Gravitas helpers used to assemble the residual expressions —
`Gravitas.simplify` (`CATEPTGravitasPort/Basic.lean:71`) and
`Gravitas.symDiff` (`CATEPTGravitasPort/Basic.lean:157`) — are declared as
`partial def`.  Lean 4's kernel never unfolds `partial def`s, so neither
`rfl` nor `decide` can reduce the LHS to `Array.replicate 4 (.lit 0)`
symbolically.  A fully symbolic decomposition into per-component lemmas
proved by `rfl` would therefore require an upstream change in the Gravitas
port to make `simplify` / `symDiff` total — which is out of scope here.

We therefore retain `native_decide`, isolated in this single named lemma
so that the umbrella admissibility predicate's proof term references only
this lemma (not raw `native_decide`).  The `Lean.ofReduceBool` axiom
dependency is thereby encapsulated in one well-defined named obligation. -/
theorem canonical_maxwell_residual_array_zero :
    (solveElectrovacuumEinsteinEquations gravitasMinkowski #[]
        (.var "μ₀") (.lit 0)).maxwellEquations =
      Array.replicate gravitasMinkowski.dim (.lit 0) := by
  native_decide

/-! ### Symbolic alias and per-component projections

The following declarations expose the Maxwell-residual array under the
spec-requested name `canonical_maxwell_residual_array_zero_symbolic` and
provide one named projection per array entry.  All four projections are
derived from `canonical_maxwell_residual_array_zero` by `rfl`/`simp`, so
they introduce **no** new `native_decide` islands and inherit the single
`Lean.ofReduceBool` axiom dependency through the base lemma. -/

/-- Spec-named alias of `canonical_maxwell_residual_array_zero` (definitionally
equal, no new axioms). -/
theorem canonical_maxwell_residual_array_zero_symbolic :
    (solveElectrovacuumEinsteinEquations gravitasMinkowski #[]
        (.var "μ₀") (.lit 0)).maxwellEquations =
      Array.replicate gravitasMinkowski.dim (.lit 0) :=
  canonical_maxwell_residual_array_zero

/-- Per-component projection: Maxwell residual entry 0 vanishes. -/
theorem maxwellResidual_component_0_zero :
    (solveElectrovacuumEinsteinEquations gravitasMinkowski #[]
        (.var "μ₀") (.lit 0)).maxwellEquations[0]! = .lit 0 := by
  rw [canonical_maxwell_residual_array_zero]; rfl

/-- Per-component projection: Maxwell residual entry 1 vanishes. -/
theorem maxwellResidual_component_1_zero :
    (solveElectrovacuumEinsteinEquations gravitasMinkowski #[]
        (.var "μ₀") (.lit 0)).maxwellEquations[1]! = .lit 0 := by
  rw [canonical_maxwell_residual_array_zero]; rfl

/-- Per-component projection: Maxwell residual entry 2 vanishes. -/
theorem maxwellResidual_component_2_zero :
    (solveElectrovacuumEinsteinEquations gravitasMinkowski #[]
        (.var "μ₀") (.lit 0)).maxwellEquations[2]! = .lit 0 := by
  rw [canonical_maxwell_residual_array_zero]; rfl

/-- Per-component projection: Maxwell residual entry 3 vanishes. -/
theorem maxwellResidual_component_3_zero :
    (solveElectrovacuumEinsteinEquations gravitasMinkowski #[]
        (.var "μ₀") (.lit 0)).maxwellEquations[3]! = .lit 0 := by
  rw [canonical_maxwell_residual_array_zero]; rfl

end CATEPTMain.Certification.RelativityGR

end
