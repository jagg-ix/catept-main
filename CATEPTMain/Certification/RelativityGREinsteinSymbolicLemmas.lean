import CATEPTMain.Certification.RelativityGREinsteinEquation
import CATEPTMain.Certification.RelativityGRWitnessFreeFaraday

noncomputable section

set_option autoImplicit false
-- Kernel reduction of the canonical Maxwell residual exercises the full
-- `Gravitas.simplifyN`/`symDiffN` engine (now total `def`s post-upstream
-- totalization), which needs a higher rec-depth budget than the default.
set_option maxRecDepth 8192

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

Both obligations are now established by kernel `rfl` and therefore carry
**only** the standard Lean axiom trio `[propext, Classical.choice, Quot.sound]`:

* `canonical_einstein_field_equations_reduce`: the LHS `solveEinsteinEquations
  …` reduces definitionally to `EinsteinTensor.fieldEquations …`.
* `canonical_maxwell_residual_array_zero`: the LHS reduces under kernel
  computation thanks to the upstream totalization of `Gravitas.simplify` and
  `Gravitas.symDiff` (`CATEPTGravitasPort/Basic.lean`).  Both are now total
  `def`s built atop kernel-reducible fuel-bounded engines
  `simplifyN` / `symDiffN`, replacing the previous `partial def`s that
  forced `native_decide`.  This file sets `maxRecDepth 8192` to accommodate
  the increased kernel reduction depth.

  A spec-named alias `canonical_maxwell_residual_array_zero_symbolic` plus
  per-component projections `maxwellResidual_component_{0,1,2,3}_zero` are
  exported for symbolic transparency at the call site.
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

Following the upstream totalization of `Gravitas.simplify` and
`Gravitas.symDiff` (originally `partial def` at `CATEPTGravitasPort/Basic.lean:71`
and `:157`; now total `def`s built atop kernel-reducible fuel-bounded
engines `simplifyN` / `symDiffN`), this identity is established directly
by kernel `rfl` — no `native_decide`, no `Lean.ofReduceBool` axiom.  The
file-level `set_option maxRecDepth 8192` (above) accommodates the deeper
reduction depth required when both `simplify` and `symDiff` unfold fully
in the kernel.

The axiom dependency reduces to the standard Lean trio
`[propext, Classical.choice, Quot.sound]`. -/
theorem canonical_maxwell_residual_array_zero :
    (solveElectrovacuumEinsteinEquations gravitasMinkowski #[]
        (.var "μ₀") (.lit 0)).maxwellEquations =
      Array.replicate gravitasMinkowski.dim (.lit 0) := by
  rfl

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
