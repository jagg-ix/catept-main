import CATEPTMain.Bridges.PhyslibRelativityBridge.MinkowskiBridge
import Physlib.Relativity.Special.ProperTime

/-!
# Bridge: CATEPT Proper-Time Interval ↔ Physlib `properTime`

This module proves two theorems connecting CATEPT's interval formula to
Physlib's `SpaceTime.properTime`:

1. **`catept_sqrt_interval_eq_physlib_properTime`** — a pure metric-compatibility
   identity, valid for *all* pairs `(q, p)` (no timelike hypothesis needed):

       √(−minkowskiNorm2 (p − q)) = SpaceTime.properTime (E q) (E p)

   where `E = cateptEquivPhyslib`.  Proof: unfold `properTime` to `√⟪…⟫ₘ`,
   rewrite via `cateptEquivPhyslib.map_sub`, then use `minkowskiNorm2_eq_neg_physlib`.

2. **`catept_properTime_pos_of_timelike`** — the value is strictly positive
   for timelike-separated events, delegating to Physlib's own
   `properTime_pos_ofTimeLike` plus the causality bridge.

## Design note

The timelike hypothesis is deliberately separated from the equality theorem.
`properTime` is defined for *all* pairs in Physlib; it returns a real
(possibly zero or undefined-looking value) for non-timelike separations.
The equality holds universally; positivity requires timelike-ness.
-/

open CATEPTMain.Geometry.FiniteMinkowski
open Lorentz Vector SpaceTime

namespace CATEPTMain.Bridges.PhyslibRelativityBridge

/-- **Metric compatibility**: The CATEPT proper-time interval formula
`√(−minkowskiNorm2 (p − q))` equals Physlib's geometric `properTime` for
*every* pair of events, regardless of causal character.

The proof is a pure algebraic rewrite: no timelike hypothesis is needed because
`properTime` is defined unconditionally as `√⟪p−q, p−q⟫ₘ`. -/
theorem catept_sqrt_interval_eq_physlib_properTime (q p : CATEPTST) :
    Real.sqrt (-(minkowskiNorm2 (p - q))) =
    properTime (cateptEquivPhyslib q) (cateptEquivPhyslib p) := by
  rw [properTime, minkowskiProduct_apply]
  rw [show cateptEquivPhyslib p - cateptEquivPhyslib q = cateptEquivPhyslib (p - q) from
        (cateptEquivPhyslib.map_sub p q).symm]
  congr 1
  linarith [minkowskiNorm2_eq_neg_physlib (p - q)]

/-- **Positivity**: For timelike-separated events, the CATEPT interval is
strictly positive.  Delegates to Physlib's `properTime_pos_ofTimeLike`. -/
theorem catept_properTime_pos_of_timelike
    (q p : CATEPTST) (h : CausalTimelike (p - q)) :
    0 < Real.sqrt (-(minkowskiNorm2 (p - q))) := by
  rw [catept_sqrt_interval_eq_physlib_properTime q p]
  apply properTime_pos_ofTimeLike
  -- Rewrite the Physlib displacement in terms of the CATEPT bridge
  rw [show cateptEquivPhyslib p - cateptEquivPhyslib q = cateptEquivPhyslib (p - q) from
        (cateptEquivPhyslib.map_sub p q).symm]
  exact (causalTimelike_iff_physlib_timeLike (p - q)).mp h

end CATEPTMain.Bridges.PhyslibRelativityBridge
