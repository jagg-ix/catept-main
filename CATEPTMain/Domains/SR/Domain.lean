import CATEPTMain.Domains.SuperiorMethod
import Physlib.Relativity.Special.ProperTime

/-!
# SR Superior-Method Domain — Physlib-backed Proper Time

The first Physlib-backed Superior-Method slot. Configuration is a pair
of `SpaceTime d` events `(q, p)`; the imaginary action is the Physlib
`SpaceTime.properTime q p = √⟪p − q, p − q⟫ₘ`.

Physlib's `properTime` defaults to `0` for space-like and light-like
separations (via `Real.sqrt` of a non-positive `⟪·,·⟫ₘ`); for time-like
separations it reduces to the relativistic interval. Either way
`0 ≤ properTime q p` because `Real.sqrt_nonneg` is universal — that is
the only fact we need for the slot.

## Distribution-lane note

This file is **not** imported by `CATEPTMain.lean` (the root umbrella).
The transitive Physlib import path
  `Special.ProperTime → SpaceTime.Basic → Space.Integrals.Basic
   → Space.Module → Mathlib.Analysis.Distribution.TemperateGrowth`
collides with the umbrella's `Physlib.Mathematics.Distribution.*` lane —
same conflict shape as `PhyslibQuantumMechanicsBridge.lean`. The slot
ships in the showcase audit graph (which doesn't import the root
umbrella), preserving root-umbrella build cleanliness.
-/

set_option autoImplicit false

namespace CATEPTMain.Domains.SR

/-- Configuration: ordered pair `(q, p) ∈ SpaceTime d × SpaceTime d`. -/
abbrev SREvent (d : ℕ) := SpaceTime d × SpaceTime d

/-- The SR Superior-Method slot for `d+1`-dimensional Minkowski spacetime.

    Configuration: `SREvent d`.
    Action: `SpaceTime.properTime q p`.
    Non-negativity: trivial via `Real.sqrt_nonneg`.

    With ħ = 1 (canonical), `eptClock = actionIm = properTime q p`.
    The CATEPT consistency proof reduces to `div_one`. -/
noncomputable def srSuperiorSlot (d : ℕ) : SuperiorMethodSlot where
  ConfigSpaceTy   := SREvent d
  actionRe        := fun _ => 0
  actionFn        := fun w => SpaceTime.properTime w.1 w.2
  actionFn_nonneg := fun _ => Real.sqrt_nonneg _

/-- The SR slot satisfies the CATEPT consistency constraint by `div_one`.
    No slot unfolding required. -/
theorem srSuperiorSlot_consistent (d : ℕ) :
    CATEPTMain.Integration.cateptConsistencyConstraint
      (srSuperiorSlot d).toCATEPTSlot :=
  (srSuperiorSlot d).consistent

/-- Time-like separation upgrades the slot's clock to a strictly positive
    value. Physlib's `properTime_pos_ofTimeLike` gives the underlying
    inequality; this re-exports it in the slot's terms. -/
theorem srSuperiorSlot_clock_pos_of_timeLike (d : ℕ) (q p : SpaceTime d)
    (h : Lorentz.Vector.causalCharacter (p - q) = .timeLike) :
    0 < (srSuperiorSlot d).actionFn (q, p) :=
  SpaceTime.properTime_pos_ofTimeLike q p h

end CATEPTMain.Domains.SR
