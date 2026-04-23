import CATEPTMain.Core.CATEPTAbstract
import Mathlib.Tactic.Ring

/-!
# CAT/EPT Abstract Core — witness instances for QM and GR compatibility

Two concrete inhabitants of `CATEPTMain.Core.Abstract.CATEPTCore` that
together demonstrate schematic compatibility with quantum mechanics and
general relativity. Both are minimal toy instances: their role is to show
the signature admits inhabitants with QM-shaped data (scalar observables on
a state) and GR-shaped data (scalar fields on a parameter axis) without any
new axioms.

* `qmToy` — QM-shaped: `Observable = Flow = ℝ`, expectation pairing, action
  and entropic time quadratic in the state.
* `grToy` — GR-shaped: `Observable = Flow = ℝ → ℝ` (scalar fields on a 1-D
  parameter), pointwise evaluation at the origin.

The physically substantive instances (finite-dim density-matrix / von Neumann
algebra for QM; Lorentzian manifold with timelike Killing vector for GR)
are staged downstream under `CATEPTMain.Quantum.HSTP` and
`CATEPTMain.Geometry`; they will follow the same axiom-free pattern.
-/

set_option autoImplicit false

namespace CATEPTMain.Core.Abstract

open CATEPTCore

/-- Quantum-shaped toy instance: scalar observables and flows on a one-level
"system" with `hbar = 1`. Every CAT/EPT law holds by `simp`/`nlinarith`. -/
noncomputable def qmToy : CATEPTCore where
  Observable := ℝ
  Flow := ℝ
  eval O φ := O * φ
  actionIm φ := φ * φ
  tauEnt φ := φ * φ
  modRate _ := 1
  dt O := O
  dtau O := O
  hbar := 1
  action_is_hbar_tauEnt _ := by ring
  modular_chain_rule _ _ := by ring
  hbar_pos := by norm_num
  tauEnt_nonneg _ := mul_self_nonneg _
  modRate_nonneg _ := by norm_num

/-- GR-shaped toy instance: scalar fields on ℝ with pointwise pairing at the
origin; `hbar = 1`. Every CAT/EPT law holds by `simp`/`sq_nonneg`. -/
noncomputable def grToy : CATEPTCore where
  Observable := ℝ → ℝ
  Flow := ℝ → ℝ
  eval O φ := O 0 * φ 0
  actionIm φ := (φ 0) ^ 2
  tauEnt φ := (φ 0) ^ 2
  modRate _ := 1
  dt O := O
  dtau O := O
  hbar := 1
  action_is_hbar_tauEnt _ := by ring
  modular_chain_rule _ _ := by ring
  hbar_pos := by norm_num
  tauEnt_nonneg _ := sq_nonneg _
  modRate_nonneg _ := by norm_num

/-- Sanity theorems: the abstract lemmas specialise to the toy instances
without recourse to any new axioms. -/
theorem qmToy_action_nonneg (φ : qmToy.Flow) : 0 ≤ qmToy.actionIm φ :=
  action_nonneg qmToy φ

theorem grToy_action_nonneg (φ : grToy.Flow) : 0 ≤ grToy.actionIm φ :=
  action_nonneg grToy φ

theorem qmToy_tauEnt_from_action (φ : qmToy.Flow) :
    qmToy.tauEnt φ = qmToy.actionIm φ / qmToy.hbar :=
  tauEnt_from_action qmToy φ

theorem grToy_tauEnt_from_action (φ : grToy.Flow) :
    grToy.tauEnt φ = grToy.actionIm φ / grToy.hbar :=
  tauEnt_from_action grToy φ

end CATEPTMain.Core.Abstract
