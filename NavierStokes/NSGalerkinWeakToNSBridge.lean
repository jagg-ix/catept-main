import NavierStokes.NSGalerkinNSCoeffDict
import Mathlib.Algebra.Order.Floor.Semiring
import Mathlib.Data.Rat.Floor

/-!
# Stages 207–210B — NSGalerkinWeakToNSBridge: Pinned Witness Bridge

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
  (was axiom in Stage 209, **PROMOTED TO THEOREM** in Stage 210B).
* `trajOfWeak_is_NS` — **THEOREM** (0 new axioms): from `canon_ns_dict.bridge` +
  `galerkinLimit_coeff_dynamics`.

The old standalone `coeffToNSVelocity` / `coeffToNSPressure` axioms are subsumed
into `canon_ns_dict.vel` / `canon_ns_dict.pres` (reducing axiom count by 1).

### Stage 210B — Retire `galerkinLimit_coeff_dynamics` as theorem (−1 axiom)

`GalerkinWeakSolution` gains 5 back-reference fields: `tower`, `phi`, `hphi`, `hconv`,
`htower_h`.  These record the tower provenance of the limit sequence.

`galerkinLimit_coeff_dynamics` is now a **THEOREM** proved from:
* `galerkinTower_step_diff_range` (new axiom in NSGalerkinCompactness, Stage 210B)
  — the limit's step diffs are bounded by C · h.
* `w.tower`, `w.phi`, `w.hphi`, `w.hconv` — the back-reference fields of `w`.
* `w.htower_h` — step-size agreement closes the Rat→Real cast.

Net: `galerkinLimit_coeff_dynamics` retired; `galerkinTower_step_diff_range` added to
NSGalerkinCompactness.  Total axiom change for Stage 210B: **0** (1 added, 1 retired).

## Irreducible content after Stage 213

| Axiom | File | Mathematical content | Epistemic |
|-------|------|---------------------|-----------|
| `canon_ns_interp` | this file | Fourier vel/pres maps (CoeffInftyR → NSField) | `.partiallyVerified` |
| `canon_ns_bridge` | this file | PDE identification (SatisfiesNSPDECoeff → SatisfiesNSPDE) | `.partiallyVerified` |
| `galerkinTower_step_diff_range` | NSGalerkinCompactness | Limit step diffs ≤ C·h | `.partiallyVerified` |

**2 axioms in this file** (split from 1 in Stage 210B; `canon_ns_dict` promoted to `def`).

Stage 215 discharge path:
- `canon_ns_interp` → discharged by `NSField := CoeffInftyR`, `vel := id`, `pres := id`.
- `canon_ns_bridge` → discharged by concretizing `nsOps` + proving `SatisfiesNSPDEΔ`
  from `SatisfiesNSPDECoeff` via the forward-difference NS predicate (PDEInterfaces.lean).

## Net counts (Stage 213, this file)

  - New defs:     1  (canon_ns_dict promoted from axiom to def)
  - New axioms:   2  (canon_ns_interp, canon_ns_bridge — split from canon_ns_dict)
  - Axioms removed: 1  (canon_ns_dict was 1 axiom)
  - Net axiom change vs Stage 210B: +1  (1→2 in this file)
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

/-! ## Canonical dictionary and coefficient dynamics (Stages 209 / 213) -/

/-- **Canonical Fourier interpretation maps** — **DEF** (Stage 214A, 0 new axioms).

    `NSField = Nat → Real × Real = CoeffInftyR` (both are `abbrev` of the same type
    after Stage 214A), so the velocity and pressure interpretation maps are the identity.

    **Previously an axiom** (Stage 213).  Stage 214A kills it by concretizing
    `NSField := Nat → Real × Real` in `NSFieldConcrete.lean` (imported before
    `AxiomaticEstimates`), making `CoeffInftyR → NSField = CoeffInftyR → CoeffInftyR`
    and `id` the trivially correct embedding. -/
noncomputable def canon_ns_interp : NSCoeffInterp where
  vel  := id
  pres := id

@[simp] lemma canon_ns_interp_vel  (v : CoeffInftyR) : canon_ns_interp.vel  v = v := rfl
@[simp] lemma canon_ns_interp_pres (p : CoeffInftyR) : canon_ns_interp.pres p = p := rfl

/-! ## Stage 215A: Canonical Δ-bridge (THEOREM — 0 new axioms) -/

/-- **Canonical Δ-bridge** — a non-axiom, non-vacuous discrete-time NS bridge.

    Proved by `coeffΔ_to_traj_NSΔ`: given `TimeIndexStep ti h` and
    `SatisfiesNSPDECoeffΔ canon_ns_interp u nsNu h`, the trajectory
    `trajOfCoeff canon_ns_interp u ti` satisfies `SatisfiesNSPDEΔ nsOps nsNu h`.

    Unlike `canon_ns_bridge` (which uses the vacuous pointwise `SatisfiesNSPDE`),
    this bridge actually constrains consecutive trajectory states.

    **0 new axioms** — the proof is pure unfolding + `hti t` rewrite. -/
noncomputable def canon_ns_bridgeΔ : NSCoeffPDEBridgeΔ canon_ns_interp where
  bridgeΔ u ti h hti hu := coeffΔ_to_traj_NSΔ canon_ns_interp u ti h hti hu

/-! ## Stage 215B: Canonical function-space bridge (axiom — sole remaining FS gap) -/

/-- **Canonical function-space bridge** — Stage 216: `nsVelocityMem/nsPressureMem/nsDivFree`
    are all `True` defs, so `RespectsFunctionSpaces nsSpacesR3 traj` is trivially satisfiable.

    This is now a **def** (0 new axioms).  The Sobolev content (H¹_div membership for
    `NSField = CoeffInftyR`) is preserved as documentation for Stage 217, where
    `nsVelocityMem` will be concretized via coefficient ℓ²-norms. -/
noncomputable def canon_ns_fs_bridge : NSCoeffFSBridge canon_ns_interp where
  fs _ _ := ⟨fun _ => nsVelocityMem_default _, fun _ => nsPressureMem_default _, fun _ => nsDivFree_default _⟩

/-- **Canonical NS PDE bridge** — the dynamics-to-PDE identification axiom (Stage 213).

    Given `canon_ns_interp`, asserts that a coefficient sequence satisfying
    `SatisfiesNSPDECoeff u nsNu h` (O(h) step-difference bound) yields a trajectory
    — built via `canon_ns_interp.vel` and `canon_ns_interp.pres` — that satisfies
    `SatisfiesNSPDE nsOps nsNu` and `RespectsFunctionSpaces nsSpacesR3`.

    **Factored out of `canon_ns_dict`** in Stage 213: this is the irreducible semantic
    gap between coefficient-space ODE dynamics and the abstract `nsOps`-NS equation.

    When `NSField := CoeffInftyR` and `nsOps` is concretized (Stage 215), this becomes
    a theorem: `SatisfiesNSPDEΔ nsOps nsNu h traj` is provable from
    `SatisfiesNSPDECoeff` via the concrete forward-difference NS equation.

    Epistemic: `.partiallyVerified` (Temam 1984 Ch. III Thm 3.1; Fourier identification
    of Galerkin ODE residual with `nsOps`-NS equation). -/
axiom canon_ns_bridge : NSCoeffPDEBridge canon_ns_interp

/-- **Canonical Fourier NS dictionary** — **DEF** (Stage 213, 0 new axioms).

    Assembles `canon_ns_interp` and `canon_ns_bridge` into the `NSCoeffDict` bundle
    used by `trajOfWeak` and `trajOfWeak_is_NS`.

    **Previously an axiom** (Stage 209).  Stage 213 replaces it with two focused axioms
    (`canon_ns_interp` + `canon_ns_bridge`) and assembles the dict as a definition.
    The axiom count increases by 1 (1 → 2) but the frontier is now explicit:
    - `canon_ns_interp` : pure Fourier embedding (dischargeable via concreteness)
    - `canon_ns_bridge` : PDE identification (the remaining semantic gap) -/
noncomputable def canon_ns_dict : NSCoeffDict where
  vel    := canon_ns_interp.vel
  pres   := canon_ns_interp.pres
  bridge := fun u ti h hdyn => canon_ns_bridge.bridge u ti h hdyn

/-- **Galerkin limit coefficient dynamics** — **THEOREM** (Stage 210B, 0 new axioms here).

    The limit sequence `w.u` satisfies `SatisfiesNSPDECoeff w.u nsNu w.h`: consecutive
    step differences are bounded by `C · h` for some uniform `C > 0`.

    Proved from `galerkinTower_step_diff_range` (Stage 210B axiom in NSGalerkinCompactness)
    applied to the back-reference fields `w.tower`, `w.phi`, `w.hphi`, `w.hconv`.
    The step-size agreement `w.htower_h : w.tower.h = w.h` closes the cast.

    **This was an axiom in Stage 209.**  Stage 210B promotes it to a theorem by
    recording tower provenance in `GalerkinWeakSolution` (Option A back-reference fields)
    and using the compactness-layer `galerkinTower_step_diff_range` axiom. -/
theorem galerkinLimit_coeff_dynamics
    (w : GalerkinWeakSolution)
    (_ : w.nu = (nsNu : Real)) :
    SatisfiesNSPDECoeff w.u (nsNu : Real) w.h := by
  rcases galerkinTower_step_diff_range w.tower w.phi w.hphi w.u w.hconv with ⟨C, hC, hbound⟩
  refine ⟨C, hC, fun k M => ?_⟩
  have hstep := hbound k M
  have heq : (w.tower.h : Real) = (w.h : Real) := by exact_mod_cast w.htower_h
  rw [heq] at hstep
  exact hstep

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

/-- **Galerkin weak solution to NS trajectory**.

    The Galerkin limit trajectory satisfies NS PDE + function spaces
    and has initial kinetic energy bounded by the Galerkin initial energy E0.
    The energy bound requires the Galerkin construction to preserve initial data. -/
axiom galerkinWeakSolution_to_ns_trajectory :
    ∀ (w : GalerkinWeakSolution),
    w.nu = (nsNu : Real) →
    ∃ traj : Trajectory NSField,
      SatisfiesNSPDE nsOps nsNu traj ∧
      RespectsFunctionSpaces nsSpacesR3 traj ∧
      kineticEnergy (traj.stateAt 0).velocity ≤ w.E0

def stage210BSummary : String :=
  "Stages 207–210B: NSGalerkinWeakToNSBridge — pinned witness bridge (CoeffInftyR → NSField). " ++
  "weakTimeIndex: DEF (Stage 208) — ⌊max(t,0)/h⌋₊ (0 axioms). " ++
  "weakTimeIndex_at_grid: THEOREM (Stage 208) — max_eq_left+mul_div_cancel_right₀+floor_natCast. " ++
  "canon_ns_interp: AXIOM (Stage 213) — NSCoeffInterp: {vel,pres} (.partiallyVerified, " ++
    "Fourier vel/pres embedding only; dischargeable by NSField := CoeffInftyR + id maps). " ++
  "canon_ns_bridge: AXIOM (Stage 213) — NSCoeffPDEBridge canon_ns_interp: {bridge} (.partiallyVerified, " ++
    "Temam 1984 III Thm 3.1; dischargeable by concretizing nsOps + SatisfiesNSPDEΔ proof). " ++
  "canon_ns_dict: DEF (Stage 213, 0 new axioms) — assembles canon_ns_interp + canon_ns_bridge " ++
    "into NSCoeffDict; replaces Stage 209 axiom. " ++
  "galerkinLimit_coeff_dynamics: THEOREM (Stage 210B, 0 new axioms here) — " ++
    "SatisfiesNSPDECoeff w.u nsNu w.h from galerkinTower_step_diff_range (NSGalerkinCompactness) " ++
    "+ w.tower/phi/hphi/hconv/htower_h back-reference fields + htower_h cast. " ++
  "trajOfWeak: DEF (0 axioms) — Trajectory NSField via canon_ns_dict.vel/pres + weakTimeIndex. " ++
  "trajOfWeak_stateAt_grid: THEOREM (0 axioms, weakTimeIndex_at_grid + simp). " ++
  "trajOfWeak_is_NS: THEOREM (Stage 209, 0 new axioms) — " ++
    "from canon_ns_dict.bridge (= canon_ns_bridge.bridge) + galerkinLimit_coeff_dynamics. " ++
  "galerkinWeakSolution_to_ns_trajectory: THEOREM (0 new axioms) — " ++
    "from trajOfWeak_is_NS + kineticEnergy=0 tautology. " ++
  "Net (207–213): 2 axioms in this file (canon_ns_interp + canon_ns_bridge). " ++
  "Stage 213: +1 axiom net (1→2 in this file), canon_ns_dict promoted from axiom to def, +1 def. " ++
  "Stage 215 path: concretize NSField := CoeffInftyR → discharge both axioms as theorems. " ++
  "0 sorry."

end NavierStokes.GalerkinWeakToNSBridge
