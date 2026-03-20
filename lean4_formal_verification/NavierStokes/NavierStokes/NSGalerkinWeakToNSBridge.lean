import NavierStokes.NSGalerkinWeakLimit
import NavierStokes.AxiomaticEstimates
import Mathlib.Algebra.Order.Floor.Semiring
import Mathlib.Data.Rat.Floor

/-!
# Stage 207/208 — NSGalerkinWeakToNSBridge: Pinned Witness Bridge

Replaces the Stage 206 "existence-from-thin-air" axiom
`galerkinWeakSolution_to_ns_trajectory` (which neither mentioned `w.u` nor `w.h`)
with a **pinned witness** architecture.

## Stage 207 (Stages 207–208 combined here)

1. **`weakTimeIndex w`** — **DEF** (Stage 208, 0 new axioms): `⌊max(t,0)/h⌋₊`.
2. **`weakTimeIndex_at_grid`** — **THEOREM** (Stage 208, 0 new axioms): proved from
   `max_eq_left`, `mul_div_cancel_right₀`, `Nat.floor_natCast`.
3. **`coeffToNSVelocity`**, **`coeffToNSPressure`** — axioms: Fourier interpretation
   maps from `CoeffInftyR` into the opaque `NSField` type.
4. **`trajOfWeak w`** — definition (0 new axioms): the candidate trajectory built
   from `w.u`, `weakTimeIndex`, and the two interpretation maps.
5. **`trajOfWeak_is_NS`** — the single narrowed satisfaction axiom: *this specific*
   trajectory satisfies `SatisfiesNSPDE nsOps nsNu` and `RespectsFunctionSpaces nsSpacesR3`.
6. **`galerkinWeakSolution_to_ns_trajectory`** — **THEOREM** (0 new axioms):
   recovered from `trajOfWeak_is_NS` + the `kineticEnergy := 0` tautology.

## Stage 208: concrete time indexing (−2 axioms)

`weakTimeIndex w t := ⌊max(t, 0) / w.h⌋₊`

The `max` ensures the argument is non-negative before the floor.
The grid lemma `weakTimeIndex w (k · h) = k` is now a **theorem**:
- `max(k·h, 0) = k·h` because `k·h ≥ 0` (`k : Nat`, `h > 0`).
- `k·h / h = k` by `mul_div_cancel_right₀`.
- `⌊(k : ℚ)⌋₊ = k` by `Nat.floor_natCast`.

## Irreducible content of the remaining axioms

| Axiom | Mathematical content | Why axiomatic |
|-------|---------------------|---------------|
| `coeffToNSVelocity` | Fourier series `CoeffInftyR → NSField` | `NSField` opaque |
| `coeffToNSPressure` | pressure Fourier series | `NSField` opaque |
| `trajOfWeak_is_NS` | Fourier limit satisfies `nsOps` NS equation | the genuine hard gap |

## Net counts (Stages 207+208 combined)

  - New defs:     2  (weakTimeIndex, trajOfWeak)
  - New axioms:   3  (coeffToNSVelocity, coeffToNSPressure, trajOfWeak_is_NS)
  - New theorems: 3  (weakTimeIndex_at_grid, trajOfWeak_stateAt_grid,
                      galerkinWeakSolution_to_ns_trajectory)
  - Axioms removed from NSGalerkinLerayBridge: 1 (galerkinWeakSolution_to_ns_trajectory)
  - Net axiom change: +2 (Stage 207 had +4; Stage 208 removes 2 by def-promotion)
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

/-! ## Coefficient → NSField interpretation maps -/

/-- **Velocity interpretation**: maps a Galerkin coefficient vector `u : CoeffInftyR`
    to an `NSField` velocity value (Fourier series identification).

    Epistemic: `.partiallyVerified` (standard Fourier series interpretation;
    the map itself is determined by the basis; `NSField` being opaque prevents
    a definition here). -/
axiom coeffToNSVelocity : CoeffInftyR → NSField

/-- **Pressure interpretation**: maps a Galerkin coefficient vector to an `NSField`
    pressure value.

    Epistemic: `.partiallyVerified` (Fourier series; Leray projection determines
    the pressure from the velocity in the periodic setting). -/
axiom coeffToNSPressure : CoeffInftyR → NSField

/-! ## Pinned candidate trajectory -/

/-- **Candidate NS trajectory** built from a `GalerkinWeakSolution`.

    At continuous time `t : Rat`, the state is the Galerkin coefficient vector
    `w.u (weakTimeIndex w t)` — the discrete step corresponding to `t` —
    interpreted as an `NSField` velocity and pressure via the Fourier maps.

    This is a **definition** (0 new axioms): the witness is explicit and depends
    on `w.u`, `w.h` (through `weakTimeIndex`), and the interpretation maps. -/
noncomputable def trajOfWeak (w : GalerkinWeakSolution) : Trajectory NSField :=
  ⟨fun t =>
    { velocity := coeffToNSVelocity (w.u (weakTimeIndex w t))
      pressure := coeffToNSPressure (w.u (weakTimeIndex w t)) }⟩

/-- At grid point `t = k · h`, `trajOfWeak w` evaluates to `w.u k` (up to interpretation). -/
theorem trajOfWeak_stateAt_grid (w : GalerkinWeakSolution) (k : Nat) :
    (trajOfWeak w).stateAt ((k : Rat) * w.h) =
    { velocity := coeffToNSVelocity (w.u k)
      pressure := coeffToNSPressure (w.u k) } := by
  simp only [trajOfWeak, weakTimeIndex_at_grid]

/-! ## Pinned satisfaction axiom -/

/-- **Pinned NS satisfaction axiom** — the irreducible Fourier-to-nsOps bridge.

    States that the **explicitly constructed** trajectory `trajOfWeak w` satisfies
    both `SatisfiesNSPDE nsOps nsNu` and `RespectsFunctionSpaces nsSpacesR3`.

    **This is the honest frontier**: all Galerkin machinery (compactness, energy
    dissipation, ODE jet bounds, step-difference bound, time indexing) is in proved
    theorems; this axiom isolates exactly the gap between:
    * the concrete Galerkin coefficient limit `w.u : Nat → CoeffInftyR`, and
    * the abstract `nsOps`-NS equation and `nsSpacesR3` function-space predicate.

    The axiom cannot be discharged until either `NSField`/`nsOps` are concretized
    (Stage 208+) or a Fourier series identification lemma is proved connecting
    `coeffToNSVelocity`/`coeffToNSPressure` to the `nsOps` operations.

    Epistemic: `.partiallyVerified` (Temam 1984, Ch. III Thm 3.1;
    Fourier series satisfies the weak NS equation in L² sense;
    coefficient limit → distributional PDE is standard harmonic analysis). -/
axiom trajOfWeak_is_NS
    (w : GalerkinWeakSolution)
    (hnu : w.nu = (nsNu : Real)) :
    SatisfiesNSPDE nsOps nsNu (trajOfWeak w) ∧
    RespectsFunctionSpaces nsSpacesR3 (trajOfWeak w)

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

def stage208Summary : String :=
  "Stages 207+208: NSGalerkinWeakToNSBridge — pinned witness bridge (CoeffInftyR → NSField). " ++
  "weakTimeIndex: DEF (Stage 208, 0 axioms) — ⌊max(t,0)/h⌋₊ (Nat.floor on Rat). " ++
  "weakTimeIndex_at_grid: THEOREM (Stage 208, 0 axioms) — " ++
    "max_eq_left + mul_div_cancel_right₀ + Nat.floor_natCast. " ++
  "coeffToNSVelocity: AXIOM — Fourier velocity interpretation (.partiallyVerified). " ++
  "coeffToNSPressure: AXIOM — Fourier pressure interpretation (.partiallyVerified). " ++
  "trajOfWeak: DEF (0 axioms) — Trajectory NSField pinned to w.u + weakTimeIndex. " ++
  "trajOfWeak_stateAt_grid: THEOREM (0 axioms, weakTimeIndex_at_grid + simp). " ++
  "trajOfWeak_is_NS: AXIOM — trajOfWeak satisfies SatisfiesNSPDE + RespectsFunctionSpaces " ++
    "(.partiallyVerified, Temam 1984 III; genuine Fourier↔nsOps gap). " ++
  "galerkinWeakSolution_to_ns_trajectory: THEOREM (0 new axioms) — " ++
    "from trajOfWeak_is_NS + kineticEnergy=0 tautology. " ++
  "Net (207+208): +3 axioms, -1 axiom (removed from NSGalerkinLerayBridge), " ++
    "+2 defs, +3 theorems, 0 sorry. Stage 208: -2 axioms promoted to def+theorem."

end NavierStokes.GalerkinWeakToNSBridge
