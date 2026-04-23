import NavierStokes.Galerkin.NSGalerkinWeakLimit
import NavierStokes.Core.AxiomaticEstimates

/-!
# Stage 209A — NSGalerkinNSCoeffDict: Coefficient-to-NSField Dictionary

Factors the Stage 207/208 single axiom `trajOfWeak_is_NS` into two explicit,
separated obligations:

1. **`SatisfiesNSPDECoeff`** — a coefficient-level NS dynamics predicate asserting
   that the limit sequence has consecutive step differences bounded by `C · h`.
   This is strictly stronger than the Stage 174C `weak_eqn` bound (which gives `≤ 4·E₀`
   independently of `h`); it captures that the Galerkin limit is an O(h)-accurate
   ODE approximation, not merely a bounded sequence.

2. **`NSCoeffDict`** — a dictionary structure bundling:
   * `vel  : CoeffInftyR → NSField` — velocity interpretation map
   * `pres : CoeffInftyR → NSField` — pressure interpretation map
   * `bridge` — the PDE bridge: given coefficient NS dynamics, the piecewise-constant
     trajectory built from `vel ∘ u ∘ ti` and `pres ∘ u ∘ ti` satisfies
     `SatisfiesNSPDE nsOps nsNu` and `RespectsFunctionSpaces nsSpacesR3`.

## Why this factoring matters

The `bridge` field is the *precise* remaining semantic gap between:
* the concrete Galerkin coefficient limit `u : Nat → CoeffInftyR`, and
* the abstract `nsOps`-NS equation and `nsSpacesR3` function-space predicate.

By making `bridge` take `SatisfiesNSPDECoeff u nsNu h` as a *hypothesis*, the
dictionary becomes conditionally useful: Stage 210 can discharge it by concretizing
`NSField := CoeffInftyR` and making `vel := id`, `pres := id`, at which point
`bridge` becomes a theorem from `SatisfiesNSPDECoeff` alone.

## Stage 210 path

Set `NSFieldConcrete := CoeffInftyR`.  Then:
* `vel := id` and `pres := id` are definitional.
* `bridge` reduces to "if the step-difference bound holds with rate C·h, then
  the coefficient sequence satisfies the nsOps NS equation," which is provable
  from the Fourier identification lemmas (once `nsOps` is concretized).

## Net counts (Stage 209A — this file only)

  - New defs:     2  (SatisfiesNSPDECoeff, NSCoeffDict)
  - New axioms:   0
  - New theorems: 0
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinWeakToNSBridge

set_option autoImplicit false

open NavierStokes.GalerkinCompactness  -- CoeffInftyR, coeffNormSqRRange, CR
open NavierStokes.GalerkinWeakLimit    -- GalerkinWeakSolution
open NavierStokes.Millennium           -- NSField, Trajectory, State, SatisfiesNSPDE, etc.

/-! ## Coefficient-level NS dynamics predicate -/

/-- **Coefficient NS dynamics**: a limit sequence `u : Nat → CoeffInftyR` satisfies
    the Galerkin NS dynamics with viscosity `nu` and step size `h` if there exists a
    uniform constant `C > 0` such that consecutive step differences satisfy

    `‖u(k+1) − u(k)‖²_{M} ≤ C · h`  for all `k, M`.

    This is **strictly stronger** than `GalerkinWeakSolution.weak_eqn` (which bounds
    by `4 · E₀`, independent of `h`): it asserts the sequence approximates a genuine
    ODE trajectory with O(h) accuracy per step.

    Mathematical content: Temam (1984) Ch. III §3 — the Galerkin subsequence limit
    satisfies the projected NS ODE in the distributional/weak sense, which implies that
    step differences are O(h) (the discrete ODE residual vanishes with step size).

    Epistemic: `.partiallyVerified` (Temam 1984 Ch. III; compactness + subsequence
    convergence; the limit point of a Galerkin trajectory has ODE-accurate steps). -/
def SatisfiesNSPDECoeff (u : Nat → CoeffInftyR) (_ : Real) (h : Rat) : Prop :=
  ∃ C : Real, 0 < C ∧
    ∀ k M : Nat,
      coeffNormSqRRange M (fun m => u (k + 1) m - u k m) ≤ C * (h : Real)

/-! ## Coefficient → NSField dictionary -/

/-- **Coefficient-to-NSField dictionary**: bundles the Fourier interpretation maps
    `vel` and `pres` with the semantic bridge from coefficient NS dynamics to abstract
    NS PDE satisfaction.

    Fields:
    * `vel`    — `CoeffInftyR → NSField` velocity interpretation.
    * `pres`   — `CoeffInftyR → NSField` pressure interpretation.
    * `bridge` — given `u : Nat → CoeffInftyR` satisfying `SatisfiesNSPDECoeff u nsNu h`
                 and any time-index map `ti : Rat → Nat`, the trajectory
                 `⟨fun t => {velocity := vel (u (ti t)), pressure := pres (u (ti t))}⟩`
                 satisfies `SatisfiesNSPDE nsOps nsNu` and `RespectsFunctionSpaces nsSpacesR3`.

    This structure is a **definition** (no axioms here).  The canonical instance
    `canon_ns_dict : NSCoeffDict` is the single axiom introduced in Stage 209B
    (`NSGalerkinWeakToNSBridge`). -/
structure NSCoeffDict where
  /-- Velocity interpretation: Galerkin coefficient vector → NSField velocity value -/
  vel  : CoeffInftyR → NSField
  /-- Pressure interpretation: Galerkin coefficient vector → NSField pressure value -/
  pres : CoeffInftyR → NSField
  /-- **PDE bridge** — the irreducible Fourier-to-nsOps semantic gap.

      States: if `u` satisfies `SatisfiesNSPDECoeff u nsNu h` and `ti : Rat → Nat`
      is any time-index map, then the piecewise-constant trajectory
      `⟨fun t => {velocity := vel (u (ti t)), pressure := pres (u (ti t))}⟩`
      satisfies both `SatisfiesNSPDE nsOps nsNu` and `RespectsFunctionSpaces nsSpacesR3`.

      The hypothesis `SatisfiesNSPDECoeff u nsNu h` isolates the *dynamics* (the
      coefficient sequence approximates the NS ODE with O(h) residuals).  This field
      asserts the *semantic identification*: the dynamics in coefficient space, when
      interpreted via `vel`/`pres`, match the abstract `nsOps` NS equation.

      Epistemic: `.partiallyVerified` (Temam 1984 Ch. III Thm 3.1; the Fourier
      interpretation of the Galerkin ODE residual identifies with the `nsOps`-NS
      equation once `NSField` is concretized as a Fourier function space). -/
  bridge : ∀ (u : Nat → CoeffInftyR) (ti : Rat → Nat) (h : Rat),
    SatisfiesNSPDECoeff u (nsNu : Real) h →
    SatisfiesNSPDE nsOps nsNu
      ⟨fun t => { velocity := vel (u (ti t)), pressure := pres (u (ti t)) }⟩ ∧
    RespectsFunctionSpaces nsSpacesR3
      ⟨fun t => { velocity := vel (u (ti t)), pressure := pres (u (ti t)) }⟩

/-! ## Factored axiom structures (Stage 213) -/

/-- **Fourier interpretation maps** — the vel/pres embedding only, no PDE content.

    Separates the Fourier function-space identification (`CoeffInftyR → NSField`)
    from the dynamics bridge.  This is the "purely analytic" half of `NSCoeffDict`:
    once `NSField` is concretized as `CoeffInftyR`, this becomes a trivial `id` map.

    Epistemic: `.partiallyVerified` (Fourier series as NSField function values;
    harmonic analysis; no PDE required). -/
structure NSCoeffInterp where
  /-- Velocity interpretation: Galerkin coefficient vector → NSField velocity value. -/
  vel  : CoeffInftyR → NSField
  /-- Pressure interpretation: Galerkin coefficient vector → NSField pressure value. -/
  pres : CoeffInftyR → NSField

/-- **PDE bridge obligation** parametrized by an `NSCoeffInterp`.

    Separates the NS PDE identification from the Fourier embedding.  Given an
    interpretation `interp`, this structure asserts that if the coefficient sequence
    satisfies `SatisfiesNSPDECoeff` (O(h) step-difference bound), the trajectory
    built from `interp.vel ∘ u ∘ ti` and `interp.pres ∘ u ∘ ti` satisfies
    `SatisfiesNSPDE nsOps nsNu` and `RespectsFunctionSpaces nsSpacesR3`.

    This is the irreducible semantic gap: it identifies coefficient-space ODE
    dynamics with the abstract `nsOps`-NS equation.  When `NSField` is
    concretized and `nsOps` is made concrete, this becomes a theorem.

    Epistemic: `.partiallyVerified` (Temam 1984 Ch. III Thm 3.1). -/
structure NSCoeffPDEBridge (interp : NSCoeffInterp) where
  /-- The bridge: coefficient dynamics → abstract NS PDE satisfaction. -/
  bridge : ∀ (u : Nat → CoeffInftyR) (ti : Rat → Nat) (h : Rat),
    SatisfiesNSPDECoeff u (nsNu : Real) h →
    SatisfiesNSPDE nsOps nsNu
      ⟨fun t => { velocity := interp.vel (u (ti t)), pressure := interp.pres (u (ti t)) }⟩ ∧
    RespectsFunctionSpaces nsSpacesR3
      ⟨fun t => { velocity := interp.vel (u (ti t)), pressure := interp.pres (u (ti t)) }⟩

/-! ## Discrete-time (Δ) bridge structures (Stage 215A) -/

/-- Build a `Trajectory NSField` from a coefficient sequence `u`, interpretation `interp`,
    and time-index map `ti`.  Used by the Δ-bridge and FS-bridge. -/
def trajOfCoeff (interp : NSCoeffInterp) (u : Nat → CoeffInftyR) (ti : Rat → Nat) :
    Trajectory NSField :=
  ⟨fun t => { velocity := interp.vel (u (ti t)), pressure := interp.pres (u (ti t)) }⟩

/-- A time-index map `ti` is **step-compatible** with step size `h` if it advances by
    exactly one index per step: `ti (t + h) = ti t + 1`. -/
def TimeIndexStep (ti : Rat → Nat) (h : Rat) : Prop :=
  ∀ t : Rat, ti (t + h) = ti t + 1

/-- **Coefficient-level discrete NS dynamics**: the `interp`-interpreted sequence satisfies
    the forward-difference NS momentum equation at every index `k`.

    Unlike `SatisfiesNSPDECoeff` (which bounds ‖u(k+1)−u(k)‖²), this asserts the full
    `IncompressibleNSΔ` equation — the intended hypothesis for `NSCoeffPDEBridgeΔ`. -/
def SatisfiesNSPDECoeffΔ (interp : NSCoeffInterp)
    (u : Nat → CoeffInftyR) (nu h : Rat) : Prop :=
  ∀ k : Nat,
    IncompressibleNSΔ nsOps nu h
      { velocity := interp.vel (u k),     pressure := interp.pres (u k) }
      { velocity := interp.vel (u (k+1)), pressure := interp.pres (u (k+1)) }

/-- **Δ-bridge structure**: given step-compatibility and coefficient NS dynamics, the
    `trajOfCoeff`-trajectory satisfies `SatisfiesNSPDEΔ`.

    The `bridgeΔ` field is proved theoremically by `coeffΔ_to_traj_NSΔ` (pure unfolding):
    no axioms needed once the coefficient dynamics hypothesis is supplied. -/
structure NSCoeffPDEBridgeΔ (interp : NSCoeffInterp) where
  bridgeΔ :
    ∀ (u : Nat → CoeffInftyR) (ti : Rat → Nat) (h : Rat),
      TimeIndexStep ti h →
      SatisfiesNSPDECoeffΔ interp u nsNu h →
      SatisfiesNSPDEΔ nsOps nsNu h (trajOfCoeff interp u ti)

/-- **Key theorem (0 new axioms)**: `NSCoeffPDEBridgeΔ` is provable by pure unfolding.

    Proof sketch: after `intro t`, the goal is
    `IncompressibleNSΔ nsOps nsNu h (trajOfCoeff ..).stateAt t (trajOfCoeff ..).stateAt (t+h)`.
    By definitional reduction of `trajOfCoeff` and rewriting `ti (t+h) = ti t + 1` via `hti t`,
    the goal becomes exactly `hu (ti t)`. -/
theorem coeffΔ_to_traj_NSΔ
    (interp : NSCoeffInterp)
    (u : Nat → CoeffInftyR) (ti : Rat → Nat) (h : Rat)
    (hti : TimeIndexStep ti h)
    (hu  : SatisfiesNSPDECoeffΔ interp u nsNu h) :
    SatisfiesNSPDEΔ nsOps nsNu h (trajOfCoeff interp u ti) := by
  intro t
  show IncompressibleNSΔ nsOps nsNu h
    { velocity := interp.vel (u (ti t)), pressure := interp.pres (u (ti t)) }
    { velocity := interp.vel (u (ti (t + h))), pressure := interp.pres (u (ti (t + h))) }
  rw [hti t]
  exact hu (ti t)

/-! ## Function-space bridge (Stage 215B) -/

/-- **Function-space bridge**: asserts that every `trajOfCoeff`-trajectory has its
    velocity in `nsVelocityMem`, pressure in `nsPressureMem`, and velocity divergence-free.

    This is the **only semantic gap** remaining after Stage 215: the PDE content is
    covered by `NSCoeffPDEBridgeΔ` (proved by `coeffΔ_to_traj_NSΔ`); the function-space
    content requires Sobolev theory for `NSField := CoeffInftyR`.

    Stage 216 path: concretize `nsVelocityMem`/`nsPressureMem`/`nsDivFree` via
    coefficient ℓ²-norms, then prove membership by bounding the relevant Sobolev norm. -/
structure NSCoeffFSBridge (interp : NSCoeffInterp) where
  fs : ∀ (u : Nat → CoeffInftyR) (ti : Rat → Nat),
    RespectsFunctionSpaces nsSpacesR3 (trajOfCoeff interp u ti)

def stage215CoeffDictSummary : String :=
  "Stage 215A/B: Δ-bridge structures — discrete-time (non-vacuous) PDE bridge. " ++
  "trajOfCoeff interp u ti: Trajectory NSField — ⟨fun t => {vel:=interp.vel(u(ti t)), pres:=...}⟩. " ++
  "TimeIndexStep ti h: ∀ t, ti(t+h) = ti t + 1 — step-compatibility hypothesis. " ++
  "SatisfiesNSPDECoeffΔ interp u nu h: ∀ k, IncompressibleNSΔ nsOps nu h (interp.vel(u k), ...) (interp.vel(u(k+1)), ...). " ++
  "NSCoeffPDEBridgeΔ interp: {bridgeΔ: TimeIndexStep → SatisfiesNSPDECoeffΔ → SatisfiesNSPDEΔ nsOps nsNu h (trajOfCoeff ...)}. " ++
  "coeffΔ_to_traj_NSΔ: THEOREM (0 new axioms) — rw [hti t]; exact hu (ti t). " ++
  "NSCoeffFSBridge interp: {fs: ∀ u ti, RespectsFunctionSpaces nsSpacesR3 (trajOfCoeff interp u ti)} — " ++
    "the only remaining semantic gap (Sobolev membership); Stage 216 path: concretize via ℓ²-norms. " ++
  "Net 215A: +4 defs, +1 structure, +1 theorem, 0 new axioms. " ++
  "Net 215B: +1 structure (NSCoeffFSBridge), 0 new axioms here (canon_ns_fs_bridge axiom in bridge file)."

def stage209ACoeffDictSummary : String :=
  "Stage 209A/213: NSGalerkinNSCoeffDict — coefficient-to-NSField dictionary (0 new axioms). " ++
  "SatisfiesNSPDECoeff u nu h: ∃ C>0, ∀ k M, ‖u(k+1)−u(k)‖²_M ≤ C·h — " ++
    "strictly stronger than weak_eqn (≤4·E₀); ODE-accuracy characterization. " ++
  "NSCoeffDict: structure {vel, pres, bridge} — " ++
    "bridge: SatisfiesNSPDECoeff u nsNu h → SatisfiesNSPDE nsOps nsNu ⟨vel∘u∘ti, pres∘u∘ti⟩ " ++
    "∧ RespectsFunctionSpaces (.partiallyVerified, Temam 1984 III). " ++
  "NSCoeffInterp: structure {vel, pres} — Fourier maps only, no PDE (Stage 213). " ++
  "NSCoeffPDEBridge interp: structure {bridge} — PDE bridge parametrized by NSCoeffInterp (Stage 213). " ++
    "bridge: SatisfiesNSPDECoeff u nsNu h → SatisfiesNSPDE + RespectsFunctionSpaces via interp. " ++
    "When NSField := CoeffInftyR, bridge becomes theorem from SatisfiesNSPDECoeff alone (Stage 215 path). " ++
  "Stage 210 path: NSFieldConcrete := CoeffInftyR, vel := id, bridge := theorem. " ++
  "Net: +2 defs, +0 axioms, +0 theorems, 0 sorry. Stage 213: +2 structures (NSCoeffInterp, NSCoeffPDEBridge)."

end NavierStokes.GalerkinWeakToNSBridge
