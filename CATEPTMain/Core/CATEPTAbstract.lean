import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

/-!
# CAT/EPT Abstract Core — axiom-free spine compatible with QM and GR

This module carries the CAT/EPT primitives (imaginary action `S_I`, entropic
proper time `τ_ent`, modular rate `λ`, physical/entropic-time derivatives) as
the fields of a `structure`, with the framework's core identities as
`Prop`-valued hypotheses.

**No `axiom` declarations are introduced in this file.** Every result is a
`theorem` whose proof term, under `#print axioms`, reduces to the
Mathlib-standard three: `propext`, `Classical.choice`, `Quot.sound`.

**Compatibility**:

* **Quantum-mechanics instance** (downstream, under
  `CATEPTMain.Quantum.HSTP`): take `Observable` = self-adjoint operators on a
  Hilbert space, `Flow` = density matrices, `eval O φ := Tr(ρ_φ · O)`, `dt` via
  Heisenberg commutator `-i[H, ·]/ℏ`, `dtau` via Tomita–Takesaki modular flow.
* **General-relativity instance** (downstream, under `CATEPTMain.Geometry`):
  take `Observable` = smooth scalar fields on spacetime, `Flow` = causal
  paths in configuration space, `eval` via pointwise evaluation, `dt` along
  the Killing flow of a global time, `dtau` along the entropic-time
  reparametrisation.

Neither instance introduces new axioms: it supplies data satisfying the
structure's fields, which Lean treats as ordinary hypotheses.

Identifier note: `λ` (modular rate) is spelled `modRate` throughout because
Lean 4's parser reads `λ` as the lambda keyword even mid-identifier.
-/

set_option autoImplicit false

namespace CATEPTMain.Core.Abstract

/-- The CAT/EPT abstract core: carrier types, primitives, and their identities.

A `CATEPTCore` value packages

* an `Observable` carrier (operators in QM, tensor fields in GR),
* a `Flow` carrier (states/paths),
* a pairing `eval : Observable → Flow → ℝ`,
* the core functionals `actionIm`, `tauEnt`, `modRate`,
* both time derivatives `dt`, `dtau`,
* Planck's scale `hbar`,

together with the minimal set of identities the framework requires — all as
ordinary structure fields, not axioms. -/
structure CATEPTCore where
  /-- Observable carrier. -/
  Observable : Type
  /-- Flow carrier. -/
  Flow : Type
  /-- Pairing: observable applied to a flow yields a real number. -/
  eval : Observable → Flow → ℝ
  /-- Imaginary part of the complex action, as a functional on flows. -/
  actionIm : Flow → ℝ
  /-- Entropic proper time, as a functional on flows. -/
  tauEnt : Flow → ℝ
  /-- Modular rate `λ(φ) = dt/dτ_ent`, nonnegative and flow-indexed. -/
  modRate : Flow → ℝ
  /-- Physical-time derivative on observables. -/
  dt : Observable → Observable
  /-- Entropic-time derivative on observables. -/
  dtau : Observable → Observable
  /-- Planck's scale. -/
  hbar : ℝ
  /-- CAT identification: `S_I = ℏ · τ_ent`. -/
  action_is_hbar_tauEnt : ∀ φ, actionIm φ = hbar * tauEnt φ
  /-- Modular chain rule: `λ · ⟨dτ O, φ⟩ = ⟨dt O, φ⟩`. -/
  modular_chain_rule :
      ∀ (O : Observable) (φ : Flow), modRate φ * eval (dtau O) φ = eval (dt O) φ
  /-- `ℏ > 0`. -/
  hbar_pos : 0 < hbar
  /-- Entropic proper time is nonnegative. -/
  tauEnt_nonneg : ∀ φ, 0 ≤ tauEnt φ
  /-- Modular rate is nonnegative. -/
  modRate_nonneg : ∀ φ, 0 ≤ modRate φ

namespace CATEPTCore

variable (C : CATEPTCore)

/-- **Theorem 1 — action nonnegativity.** The imaginary action is nonnegative;
this follows from `ℏ > 0` and `τ_ent ≥ 0` via the CAT identification. -/
theorem action_nonneg (φ : C.Flow) : 0 ≤ C.actionIm φ := by
  rw [C.action_is_hbar_tauEnt]
  exact mul_nonneg (le_of_lt C.hbar_pos) (C.tauEnt_nonneg φ)

/-- **Theorem 2 — entropic time from action.** Entropic proper time equals the
imaginary action divided by `ℏ`. -/
theorem tauEnt_from_action (φ : C.Flow) : C.tauEnt φ = C.actionIm φ / C.hbar := by
  have h : C.hbar ≠ 0 := ne_of_gt C.hbar_pos
  rw [eq_div_iff h, C.action_is_hbar_tauEnt, mul_comm]

/-- **Theorem 3 — physical-time from modular and entropic.** Physical-time
derivative equals modular rate times entropic-time derivative (pairing-level). -/
theorem dt_via_modular_and_dtau (O : C.Observable) (φ : C.Flow) :
    C.eval (C.dt O) φ = C.modRate φ * C.eval (C.dtau O) φ :=
  (C.modular_chain_rule O φ).symm

/-- **Theorem 4 — entropic from physical (positive-rate regime).** When the
modular rate is strictly positive, the entropic-time derivative is recoverable
from the physical-time derivative by division. -/
theorem dtau_from_dt {φ : C.Flow} (O : C.Observable) (h : 0 < C.modRate φ) :
    C.eval (C.dtau O) φ = C.eval (C.dt O) φ / C.modRate φ := by
  have hne : C.modRate φ ≠ 0 := ne_of_gt h
  rw [eq_div_iff hne, mul_comm]
  exact C.modular_chain_rule O φ

/-- **Theorem 5 — action monotonicity in entropic time.** Since `ℏ ≥ 0`,
ordering of entropic proper time pulls back to ordering of imaginary action. -/
theorem action_mono_of_tauEnt {φ ψ : C.Flow} (h : C.tauEnt φ ≤ C.tauEnt ψ) :
    C.actionIm φ ≤ C.actionIm ψ := by
  rw [C.action_is_hbar_tauEnt, C.action_is_hbar_tauEnt]
  exact mul_le_mul_of_nonneg_left h (le_of_lt C.hbar_pos)

/-- **Theorem 6 — vanishing equivalence.** Entropic proper time vanishes iff
the imaginary action does (given `ℏ > 0`). -/
theorem tauEnt_eq_zero_iff (φ : C.Flow) :
    C.tauEnt φ = 0 ↔ C.actionIm φ = 0 := by
  rw [C.action_is_hbar_tauEnt]
  refine ⟨fun h => by rw [h, mul_zero], fun h => ?_⟩
  rcases mul_eq_zero.mp h with hhbar | htau
  · exact absurd hhbar (ne_of_gt C.hbar_pos)
  · exact htau

end CATEPTCore

end CATEPTMain.Core.Abstract

/-!
## Axiom audit

After build, verify zero framework-specific axioms:

```
#print axioms CATEPTMain.Core.Abstract.CATEPTCore.action_nonneg
#print axioms CATEPTMain.Core.Abstract.CATEPTCore.tauEnt_from_action
#print axioms CATEPTMain.Core.Abstract.CATEPTCore.dt_via_modular_and_dtau
#print axioms CATEPTMain.Core.Abstract.CATEPTCore.dtau_from_dt
#print axioms CATEPTMain.Core.Abstract.CATEPTCore.action_mono_of_tauEnt
#print axioms CATEPTMain.Core.Abstract.CATEPTCore.tauEnt_eq_zero_iff
```

Each should list only `propext`, `Classical.choice`, `Quot.sound`.
-/
