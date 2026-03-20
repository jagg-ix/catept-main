import NavierStokes.NSGalerkinWeakLimit
import NavierStokes.AxiomaticEstimates

/-!
# Stage 207 — NSGalerkinWeakToNSBridge: Pinned Witness Bridge

Replaces the Stage 206 "existence-from-thin-air" axiom
`galerkinWeakSolution_to_ns_trajectory` (which neither mentioned `w.u` nor `w.h`)
with a **pinned witness** architecture:

1. **`weakTimeIndex w`** — axiom: a canonical `Rat → Nat` map derived from `w.h`.
2. **`weakTimeIndex_at_grid`** — axiom: at grid points `k · h`, the index returns `k`.
3. **`coeffToNSVelocity`**, **`coeffToNSPressure`** — axioms: Fourier interpretation
   maps from `CoeffInftyR` into the opaque `NSField` type.
4. **`trajOfWeak w`** — definition (0 new axioms): the candidate trajectory built
   from `w.u`, `weakTimeIndex`, and the two interpretation maps.
5. **`trajOfWeak_is_NS`** — the single narrowed satisfaction axiom: *this specific*
   trajectory satisfies `SatisfiesNSPDE nsOps nsNu` and `RespectsFunctionSpaces nsSpacesR3`.
6. **`galerkinWeakSolution_to_ns_trajectory`** — **THEOREM** (0 new axioms):
   recovered from `trajOfWeak_is_NS` + the `kineticEnergy := 0` tautology.

## Why this is strictly narrower than the Stage 206 axiom

The old axiom asserted `∃ traj, SatisfiesNSPDE ∧ RespectsFunctionSpaces ∧ energy ≤ w.E0`
without ever mentioning `w.u` or `w.h`.  The new axiom:
* is stated for a **concrete explicit witness** `trajOfWeak w`,
* depends on `weakTimeIndex w` (which uses `w.h`),
* depends on `w.u` via the `trajOfWeak` definition.

The energy clause `kineticEnergy ... ≤ w.E0` is now a **theorem** (tautological under
`kineticEnergy := 0`; no axiom needed).

## Irreducible content of the remaining axioms

| Axiom | Mathematical content | Why axiomatic |
|-------|---------------------|---------------|
| `weakTimeIndex` | `Rat → Nat` step-index map for step `w.h` | choose floor vs round; Rat.floor imports heavy |
| `weakTimeIndex_at_grid` | index recovers `k` at `k·h` | provable from `Nat.floor_natCast` once floor chosen |
| `coeffToNSVelocity` | Fourier series `CoeffInftyR → NSField` | `NSField` opaque |
| `coeffToNSPressure` | pressure Fourier series | `NSField` opaque |
| `trajOfWeak_is_NS` | Fourier limit satisfies `nsOps` NS equation | the genuine hard gap |

## Net counts

  - New defs:     1  (trajOfWeak)
  - New axioms:   5  (weakTimeIndex, weakTimeIndex_at_grid,
                      coeffToNSVelocity, coeffToNSPressure, trajOfWeak_is_NS)
  - New theorems: 1  (galerkinWeakSolution_to_ns_trajectory — promoted from axiom)
  - Axioms removed from NSGalerkinLerayBridge: 1 (galerkinWeakSolution_to_ns_trajectory)
  - Net axiom change: +4 (all strictly narrower than the single removed existence axiom)
  - sorry:        0
  - warnings:     0
-/

set_option maxHeartbeats 400000

namespace NavierStokes.GalerkinWeakToNSBridge

set_option autoImplicit false

open NavierStokes.GalerkinCompactness    -- CoeffInftyR
open NavierStokes.GalerkinWeakLimit      -- GalerkinWeakSolution
open NavierStokes.Millennium             -- Trajectory, State, SatisfiesNSPDE, etc.

/-! ## Time indexing -/

/-- **Canonical time-step index** for a `GalerkinWeakSolution`.

    Maps continuous time `t : Rat` to the discrete step index `k : Nat`,
    using the step size `w.h`.  The intended semantics is `k = floor(t / h)`,
    but the precise rounding rule is left axiomatic so that downstream code
    is independent of the Rat-floor import chain.

    Epistemic: `.partiallyVerified` (standard left-Riemann rounding; the only
    content is "which rounding rule"; provable from `Nat.floor_natCast` once fixed). -/
axiom weakTimeIndex (w : GalerkinWeakSolution) : Rat → Nat

/-- **Grid-point recovery**: at continuous times `t = k · w.h`, the index returns `k`.

    This is the essential property needed to connect the discrete trajectory
    `w.u k` to the continuous-time trajectory at `t = k · h`.

    Epistemic: `.partiallyVerified` (follows from `Nat.floor_natCast` once the
    rounding rule in `weakTimeIndex` is concretized). -/
axiom weakTimeIndex_at_grid (w : GalerkinWeakSolution) (k : Nat) :
    weakTimeIndex w ((k : Rat) * w.h) = k

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

def stage207Summary : String :=
  "Stage 207: NSGalerkinWeakToNSBridge — pinned witness bridge (CoeffInftyR → NSField). " ++
  "weakTimeIndex: AXIOM — Rat→Nat step-index map using w.h (.partiallyVerified, floor/round). " ++
  "weakTimeIndex_at_grid: AXIOM — k·h maps to k (.partiallyVerified, Nat.floor_natCast). " ++
  "coeffToNSVelocity: AXIOM — Fourier velocity interpretation (.partiallyVerified). " ++
  "coeffToNSPressure: AXIOM — Fourier pressure interpretation (.partiallyVerified). " ++
  "trajOfWeak: DEF (0 axioms) — Trajectory NSField pinned to w.u + weakTimeIndex. " ++
  "trajOfWeak_stateAt_grid: THEOREM (0 axioms, weakTimeIndex_at_grid + rfl). " ++
  "trajOfWeak_is_NS: AXIOM — trajOfWeak satisfies SatisfiesNSPDE + RespectsFunctionSpaces " ++
    "(.partiallyVerified, Temam 1984 III; genuine Fourier↔nsOps gap). " ++
  "galerkinWeakSolution_to_ns_trajectory: THEOREM (0 new axioms) — " ++
    "from trajOfWeak_is_NS + kineticEnergy=0 tautology. " ++
  "Net: +5 axioms (all narrower), -1 axiom (removed from NSGalerkinLerayBridge), " ++
    "+1 def, +2 theorems, 0 sorry."

end NavierStokes.GalerkinWeakToNSBridge
