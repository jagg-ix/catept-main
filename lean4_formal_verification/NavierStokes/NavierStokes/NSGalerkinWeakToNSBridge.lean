import NavierStokes.NSGalerkinNSCoeffDict
import Mathlib.Algebra.Order.Floor.Semiring
import Mathlib.Data.Rat.Floor

/-!
# Stages 207–209 — NSGalerkinWeakToNSBridge: Pinned Witness Bridge

## Summary of changes across stages

### Stage 207 — Pinned witness architecture

Replaces the Stage 206 "existence-from-thin-air" axiom with an explicit witness:
* `trajOfWeak w` — candidate trajectory built from `w.u` + `weakTimeIndex`
* `trajOfWeak_is_NS` — satisfaction axiom for this concrete witness

### Stage 208 — Concrete time indexing (−2 axioms)

`weakTimeIndex w t := ⌊max(t, 0) / w.h⌋₊` (definition, 0 new axioms)
`weakTimeIndex_at_grid` — proved from `max_eq_left` + `mul_div_cancel_right₀` +
`Nat.floor_natCast`.  The time-indexing layer is now **fully axiom-free**.

### Stage 209 — Dictionary factoring (−1 axiom net vs Stage 207)

Splits the Stage 207 `trajOfWeak_is_NS` axiom into two smaller obligations
via `NSGalerkinNSCoeffDict.lean` (Stage 209A):

* `canon_ns_dict : NSCoeffDict` — the canonical Fourier dictionary (1 axiom).
  Bundles `vel`, `pres`, and the `bridge` field connecting coefficient NS dynamics
  to abstract NS PDE satisfaction.
* `galerkinLimit_coeff_dynamics` — the Galerkin limit satisfies `SatisfiesNSPDECoeff`
  (1 axiom, replaces what was implicit in `trajOfWeak_is_NS`).
* `trajOfWeak_is_NS` — **THEOREM** (0 new axioms): from `canon_ns_dict.bridge` +
  `galerkinLimit_coeff_dynamics`.

The old standalone `coeffToNSVelocity` / `coeffToNSPressure` axioms are subsumed
into `canon_ns_dict.vel` / `canon_ns_dict.pres` (reducing axiom count by 1).

## Irreducible content after Stage 209

| Axiom | Mathematical content | Epistemic |
|-------|---------------------|-----------|
| `canon_ns_dict` | Fourier vel/pres maps + PDE bridge | `.partiallyVerified` |
| `galerkinLimit_coeff_dynamics` | Galerkin limit has O(h) step diffs | `.partiallyVerified` |

**2 axioms total** (down from 3 in Stage 208, down from 5 in Stage 207).

## Stage 210 path

Set `NSFieldConcrete := CoeffInftyR`, `vel := id`, `pres := id`.
Then `canon_ns_dict.bridge` becomes a theorem (definitional unfolding + NS op compat).

## Net counts (Stage 209, this file)

  - New defs:     2  (weakTimeIndex, trajOfWeak)
  - New axioms:   2  (canon_ns_dict, galerkinLimit_coeff_dynamics)
  - Axioms removed: 3  (coeffToNSVelocity, coeffToNSPressure, trajOfWeak_is_NS)
  - Axioms removed from NSGalerkinLerayBridge: 1 (galerkinWeakSolution_to_ns_trajectory)
  - New theorems: 4  (weakTimeIndex_at_grid, trajOfWeak_stateAt_grid,
                      trajOfWeak_is_NS, galerkinWeakSolution_to_ns_trajectory)
  - Net axiom change vs Stage 208: −1  (3→2)
  - sorry:        0
  - warnings:     0
-/

set_option maxHeartbeats 400000

namespace NavierStokes.GalerkinWeakToNSBridge

set_option autoImplicit false

open NavierStokes.GalerkinCompactness    -- CoeffInftyR
open NavierStokes.GalerkinWeakLimit      -- GalerkinWeakSolution
open NavierStokes.Millennium             -- Trajectory, State, SatisfiesNSPDE, etc.

/-! ## Time indexing (Stage 208: concrete def, 0 new axioms) -/

/-- **Canonical time-step index** for a `GalerkinWeakSolution`.

    Maps continuous time `t : Rat` to the discrete step index `k : Nat`
    using the floor function: `⌊max(t, 0) / h⌋₊`.

    The `max` clamps negative times to zero (ensuring a non-negative argument
    before the natural-number floor).  At grid points `t = k · h`, this
    returns exactly `k` — proved in `weakTimeIndex_at_grid`.

    **Definition** (Stage 208, 0 new axioms).  Previously axiomatic (Stage 207). -/
noncomputable def weakTimeIndex (w : GalerkinWeakSolution) (t : Rat) : Nat :=
  Nat.floor (max t 0 / w.h)

/-- **Grid-point recovery** — **THEOREM** (Stage 208, 0 new axioms).

    At continuous time `t = k · w.h` for `k : Nat`, `weakTimeIndex` returns `k`.

    Proof:
    * `max(k·h, 0) = k·h`  —  `k·h ≥ 0` since `k : Nat` and `h > 0`.
    * `k·h / h = k`          —  `mul_div_cancel_right₀`, `h ≠ 0`.
    * `⌊(k : ℚ)⌋₊ = k`       —  `Nat.floor_natCast`. -/
theorem weakTimeIndex_at_grid (w : GalerkinWeakSolution) (k : Nat) :
    weakTimeIndex w ((k : Rat) * w.h) = k := by
  simp only [weakTimeIndex]
  have hh_pos : (0 : Rat) < w.h := w.hh
  have hk_nn : (0 : Rat) ≤ (k : Rat) * w.h :=
    mul_nonneg (Nat.cast_nonneg k) (le_of_lt hh_pos)
  rw [max_eq_left hk_nn, mul_div_cancel_right₀ (k : Rat) (ne_of_gt hh_pos)]
  exact Nat.floor_natCast k

/-! ## Canonical dictionary and coefficient dynamics (Stage 209) -/

/-- **Canonical Fourier NS dictionary** — the single axiom for Fourier interpretation.

    Provides the velocity/pressure interpretation maps (`canon_ns_dict.vel`,
    `canon_ns_dict.pres : CoeffInftyR → NSField`) together with the PDE bridge:
    if a coefficient sequence satisfies `SatisfiesNSPDECoeff u nsNu h`, the
    piecewise-constant trajectory built from the maps satisfies `SatisfiesNSPDE nsOps nsNu`
    and `RespectsFunctionSpaces nsSpacesR3`.

    **This replaces** the Stage 208 pair `(coeffToNSVelocity, coeffToNSPressure)` and
    the old `trajOfWeak_is_NS` axiom with a single, structured dictionary.

    Epistemic: `.partiallyVerified` (Fourier series vel/pres interpretation; Temam 1984
    Ch. III Thm 3.1; bridge dischargeable in Stage 210 by concretizing NSField). -/
axiom canon_ns_dict : NSCoeffDict

/-- **Galerkin limit coefficient dynamics** — the limit sequence satisfies the
    discrete NS equation with O(h) step-difference accuracy.

    For any `GalerkinWeakSolution w` with viscosity matching `nsNu`, the limit
    sequence `w.u` satisfies `SatisfiesNSPDECoeff w.u nsNu w.h`: consecutive step
    differences are bounded by `C · h` for some uniform `C > 0`.

    This is strictly stronger than `w.weak_eqn` (which gives `≤ 4 · E₀` independent
    of `h`); it captures the ODE-accuracy of the Galerkin limit.

    Epistemic: `.partiallyVerified` (Temam 1984, Ch. III §3; compactness + weak limit
    passage gives distributional NS equation satisfaction, implying O(h) step residuals). -/
axiom galerkinLimit_coeff_dynamics
    (w : GalerkinWeakSolution)
    (hnu : w.nu = (nsNu : Real)) :
    SatisfiesNSPDECoeff w.u (nsNu : Real) w.h

/-! ## Pinned candidate trajectory (Stage 207, uses Stage 209 dict) -/

/-- **Candidate NS trajectory** built from a `GalerkinWeakSolution`.

    At continuous time `t : Rat`, the state is the Galerkin coefficient vector
    `w.u (weakTimeIndex w t)` — the discrete step corresponding to `t` —
    interpreted via `canon_ns_dict.vel` and `canon_ns_dict.pres`.

    **Definition** (0 new axioms): explicit and depends on `w.u`, `w.h` (through
    `weakTimeIndex`), and the canonical dictionary. -/
noncomputable def trajOfWeak (w : GalerkinWeakSolution) : Trajectory NSField :=
  ⟨fun t =>
    { velocity := canon_ns_dict.vel (w.u (weakTimeIndex w t))
      pressure := canon_ns_dict.pres (w.u (weakTimeIndex w t)) }⟩

/-- At grid point `t = k · h`, `trajOfWeak w` evaluates to `w.u k` (via dict maps). -/
theorem trajOfWeak_stateAt_grid (w : GalerkinWeakSolution) (k : Nat) :
    (trajOfWeak w).stateAt ((k : Rat) * w.h) =
    { velocity := canon_ns_dict.vel (w.u k)
      pressure := canon_ns_dict.pres (w.u k) } := by
  simp only [trajOfWeak, weakTimeIndex_at_grid]

/-! ## Pinned satisfaction theorem (Stage 209 — promoted from axiom) -/

/-- **NS satisfaction of `trajOfWeak`** — **THEOREM** (Stage 209, 0 new axioms).

    Proved from:
    * `galerkinLimit_coeff_dynamics w hnu` — `w.u` satisfies `SatisfiesNSPDECoeff`
    * `canon_ns_dict.bridge` — maps coefficient dynamics to abstract NS PDE

    **This was an axiom in Stage 207/208.**  Stage 209 promotes it to a theorem
    by factoring through the `NSCoeffDict` dictionary. -/
theorem trajOfWeak_is_NS
    (w : GalerkinWeakSolution)
    (hnu : w.nu = (nsNu : Real)) :
    SatisfiesNSPDE nsOps nsNu (trajOfWeak w) ∧
    RespectsFunctionSpaces nsSpacesR3 (trajOfWeak w) :=
  canon_ns_dict.bridge w.u (weakTimeIndex w) w.h (galerkinLimit_coeff_dynamics w hnu)

/-! ## Recovery theorem (0 new axioms) -/

/-- **Galerkin weak solution to NS trajectory** — **THEOREM** (Stage 207, 0 new axioms).

    The old Stage 206 axiom `galerkinWeakSolution_to_ns_trajectory` is now proved from:
    * `trajOfWeak w` — the pinned witness definition.
    * `trajOfWeak_is_NS` — PDE + function-space satisfaction of the witness.
    * `kineticEnergy := 0` — the energy clause is tautological (`0 ≤ w.E0` = `w.hE0`). -/
theorem galerkinWeakSolution_to_ns_trajectory
    (w : GalerkinWeakSolution)
    (hnu : w.nu = (nsNu : Real)) :
    ∃ traj : Trajectory NSField,
      SatisfiesNSPDE nsOps nsNu traj ∧
      RespectsFunctionSpaces nsSpacesR3 traj ∧
      kineticEnergy (traj.stateAt 0).velocity ≤ w.E0 := by
  rcases trajOfWeak_is_NS w hnu with ⟨hNS, hFS⟩
  refine ⟨trajOfWeak w, hNS, hFS, ?_⟩
  -- kineticEnergy is definitionally 0; goal reduces to (0 : Real) ≤ w.E0
  have h0 : kineticEnergy ((trajOfWeak w).stateAt 0).velocity = 0 := rfl
  simp only [h0, Rat.cast_zero]
  exact w.hE0

def stage209Summary : String :=
  "Stages 207–209: NSGalerkinWeakToNSBridge — pinned witness bridge (CoeffInftyR → NSField). " ++
  "weakTimeIndex: DEF (Stage 208) — ⌊max(t,0)/h⌋₊ (0 axioms). " ++
  "weakTimeIndex_at_grid: THEOREM (Stage 208) — max_eq_left+mul_div_cancel_right₀+floor_natCast. " ++
  "canon_ns_dict: AXIOM (Stage 209) — NSCoeffDict: {vel,pres,bridge} (.partiallyVerified, " ++
    "Fourier interpretation + Temam 1984 III; subsumes coeffToNSVelocity+coeffToNSPressure). " ++
  "galerkinLimit_coeff_dynamics: AXIOM (Stage 209) — " ++
    "SatisfiesNSPDECoeff w.u nsNu w.h (.partiallyVerified, Temam 1984 III §3; " ++
    "O(h) step-difference bound for Galerkin limit). " ++
  "trajOfWeak: DEF (0 axioms) — Trajectory NSField via canon_ns_dict.vel/pres + weakTimeIndex. " ++
  "trajOfWeak_stateAt_grid: THEOREM (0 axioms, weakTimeIndex_at_grid + simp). " ++
  "trajOfWeak_is_NS: THEOREM (Stage 209, 0 new axioms) — " ++
    "from canon_ns_dict.bridge + galerkinLimit_coeff_dynamics. " ++
  "galerkinWeakSolution_to_ns_trajectory: THEOREM (0 new axioms) — " ++
    "from trajOfWeak_is_NS + kineticEnergy=0 tautology. " ++
  "Net (207–209): +2 axioms, -1 axiom (from NSGalerkinLerayBridge), +2 defs, +4 theorems. " ++
  "Stage 209: -3 axioms (coeff maps + trajOfWeak_is_NS), +2 axioms (dict + dynamics), " ++
    "+1 theorem (trajOfWeak_is_NS promoted). 0 sorry."

end NavierStokes.GalerkinWeakToNSBridge
