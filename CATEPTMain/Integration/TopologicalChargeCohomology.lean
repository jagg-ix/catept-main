import Mathlib.Data.Real.Basic
import Mathlib.Data.Int.Cast.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity
import CATEPTMain.Integration.InstantonTunneling
import CATEPTMain.Integration.TopologicalChargeIntegrality

/-!
# Topological-Charge Cohomological Non-Degeneracy (T-CC Phase 4)

Phase 4 of the topological-charge integrality target. Phase 3 pinned
that the normalised charge `Q(n)/(8π²) = (n : ℝ)` lives in `ℤ ⊂ ℝ`.
Phase 4 establishes the **cohomological non-degeneracy** of the
Pontryagin pairing: the assignment `n ↦ Q(n) = 8π²·n` is a genuine
**injection** `ℤ ↪ ℝ` and an additive group homomorphism, so distinct
instanton sectors give distinct charges (no level-crossings, no
non-trivial vacuum identifications).

This is the algebraic heart of the statement that the second Chern
class `c₂` distinguishes principal SU(2)-bundles over `S⁴`
([∫ c₂] = n is a complete invariant up to isomorphism).

* `topologicalCharge_injective`            — `Q : ℤ → ℝ` injective.
* `topologicalCharge_eq_zero_iff`          — `Q(n) = 0 ↔ n = 0`.
* `topologicalCharge_neg`                  — `Q(-n) = -Q(n)`,
                                             orientation reversal.
* `topologicalCharge_sub`                  — relative-instanton-number
                                             linearity.

## Phase status

Phase-4 — kernel-only `[propext, Classical.choice, Quot.sound]`.
Genuine 4-form integration of `tr(F ∧ F)` over `S⁴` and the full
classification of principal SU(2)-bundles by π₃(SU(2)) = ℤ remain
deferred to a later phase.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.TopologicalChargeCohomology

open CATEPTMain.Integration.InstantonTunneling
open CATEPTMain.Integration.TopologicalChargeIntegrality

noncomputable section

/-- **Orientation reversal**: the topological charge of the
    orientation-reversed bundle equals minus the charge,
    `Q(-n) = -Q(n)`. -/
theorem topologicalCharge_neg (n : ℤ) :
    topologicalCharge (-n) = -topologicalCharge n := by
  unfold topologicalCharge
  push_cast
  ring

/-- **Subtraction linearity**: relative instanton numbers compose
    linearly, `Q(n - m) = Q(n) - Q(m)`. -/
theorem topologicalCharge_sub (n m : ℤ) :
    topologicalCharge (n - m) = topologicalCharge n - topologicalCharge m := by
  unfold topologicalCharge
  push_cast
  ring

/-- **Vanishing iff trivial sector**: `Q(n) = 0 ↔ n = 0`. The
    Pontryagin charge detects the trivial bundle exactly. -/
theorem topologicalCharge_eq_zero_iff (n : ℤ) :
    topologicalCharge n = 0 ↔ n = 0 := by
  unfold topologicalCharge
  have h8pi : (8 * Real.pi ^ 2 : ℝ) ≠ 0 := by positivity
  constructor
  · intro h
    have : (n : ℝ) = 0 := by
      have := (mul_eq_zero.mp h).resolve_left h8pi
      exact this
    exact_mod_cast this
  · intro h; subst h; simp

/-- **Cohomological non-degeneracy**: the topological-charge map
    `Q : ℤ → ℝ` is an injection. Distinct instanton sectors give
    distinct real-valued charges — no false vacuum identifications. -/
theorem topologicalCharge_injective :
    Function.Injective topologicalCharge := by
  intro n m h
  have hsub : topologicalCharge (n - m) = 0 := by
    rw [topologicalCharge_sub, h, sub_self]
  have : n - m = 0 := (topologicalCharge_eq_zero_iff (n - m)).mp hsub
  linarith

end

end CATEPTMain.Integration.TopologicalChargeCohomology
