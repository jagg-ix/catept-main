import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Adapters.HarmonicOscillator
import CATEPTMain.Domains.Adapters.QM
import CATEPTMain.Domains.Adapters.SR
import CATEPTMain.Domains.JointAdapter

/-!
# Physlib ↔ CAT/EPT Spacetime Adapter

Bridges Physlib's `SpaceTime d` / `properTime` API into CAT/EPT's
`TemporalFramework` contract via a thin neutral abstraction layer
(`LorentzianSpaceTime`), then proves the proposal-targeted

  **QM ⊕ classical mechanics ⊕ Physlib SR**

joint framework satisfies the CAT/EPT spine identification.

## Why this file exists in catept-main, not in Physlib

The dependency direction must be `catept-main → Physlib` (via lakefile pin),
not the reverse — Physlib stays domain-neutral physical mathematics; CAT/EPT
is a framework-interpretation layer on top.  Inverting the arrow would
create a Lake cycle (`catept-main → Physlib → catept-main`) and would
contaminate Physlib with framework-specific concepts.

## What gets exported

- `LorentzianSpaceTime` (typeclass) — the minimum spacetime interface
  needed to extract a `TemporalFramework`: a `properTime` clock with
  kernel-tier non-negativity, plus a `causal` predicate that upgrades
  the lift to a `LiveTemporalFramework`.

- `physlibLorentzianSpaceTime` (instance) — `Physlib.SpaceTime d` satisfies
  `LorentzianSpaceTime` with `properTime := SpaceTime.properTime` and
  `causal := Lorentz.Vector.causalCharacter (p − q) = .timeLike`.

- `LorentzianSpaceTime.toTemporalFramework` — generic lift; any
  `LorentzianSpaceTime` instance becomes a `TemporalFramework`.

- `physlibSRTemporalFramework` — named alias for the lift applied to
  Physlib SR.  This is the proof object the user's recommendation
  proposes: *"Any Physlib spacetime instance can be lifted into CAT/EPT,
  and once lifted, it satisfies the same temporal coherence theorem as
  QM, classical mechanics, and GR."*

- `physlibSRLive` — the live-tier upgrade for any timelike Physlib pair.

- `harmonicSRQM` — the joint
  `harmonic ⊕ physlib-SR ⊕ qm` framework.  Its spine identification
  follows from the universal `TemporalFramework.coherence_spine` exactly
  as every other joint adapter (T79 maxwellGRQM, T89 maxwellGRQMcurved).

## Distribution-lane note (inherited from `Adapters/SR`)

This file is **not** imported by `CATEPTMain.lean` (the root umbrella).
Importing `Adapters.SR` transitively brings in
`Physlib.Mathematics.Distribution.*` which collides with the umbrella's
own distribution lane (same conflict shape as `PhyslibQuantumMechanicsBridge`).
The `#print axioms` audit lines for the new theorems live in
`CATEPTMain.Domains.TemporalCoherenceShowcase` (which is itself outside
the root umbrella graph).

## Architectural fit

| Layer | What it gives | Where |
|---|---|---|
| `TemporalFramework.coherence_spine` | universal `actionIm/ℏ = eptClock` | `Domains/TemporalFramework.lean` |
| `JointAdapter.joint` | compositional clock for product systems | `Domains/JointAdapter.lean` |
| `SharedClockWitness` | two frameworks pin the same numerical τ | `Domains/TemporalSynchronization.lean` |
| **`LorentzianSpaceTime`** (this file) | abstract spacetime → `TemporalFramework` lift | `Integration/PhyslibCATEPTSpaceTimeAdapter.lean` |
-/

set_option autoImplicit false

namespace CATEPTMain.Integration

open CATEPTMain.Temporal (TemporalFramework LiveTemporalFramework)

-- ═══════════════════════════════════════════════════════════════════════
-- Abstraction layer
-- ═══════════════════════════════════════════════════════════════════════

/-- Minimum Lorentzian-spacetime contract for CAT/EPT lifting.

    Captures the four facts the spine actually needs:
    - a `properTime` clock function on pairs of points,
    - non-negativity of that clock (kernel tier),
    - a `causal` predicate identifying timelike pairs,
    - strict positivity of `properTime` on timelike pairs (live tier).

    Physlib's `SpaceTime d` is the canonical instance.  Future GR or
    de-Sitter spacetimes can also instantiate this without touching
    upstream Physlib. -/
class LorentzianSpaceTime (M : Type) where
  /-- Proper-time clock between two events. -/
  properTime : M → M → ℝ
  /-- Kernel-tier positivity: clock is non-negative everywhere
      (spacelike pairs default to zero by convention). -/
  properTime_nonneg : ∀ x y, 0 ≤ properTime x y
  /-- Timelike-character predicate. -/
  causal : M → M → Prop
  /-- Live-tier nontriviality: timelike pairs have strictly positive clock. -/
  properTime_pos_of_causal_timelike :
    ∀ x y, causal x y → 0 < properTime x y

namespace LorentzianSpaceTime

/-- Generic lift: any `LorentzianSpaceTime` instance becomes a
    `TemporalFramework` whose configuration space is pairs of events
    and whose clock is `properTime`.

    The `origin` parameter pins the kernel-tier inhabited witness at
    `(origin, origin)` — a degenerate worldline.  Live tier requires
    a separate timelike pair (see `liveOfTimelike`). -/
noncomputable def toTemporalFramework
    (M : Type) [LorentzianSpaceTime M] (origin : M) :
    TemporalFramework where
  Config := M × M
  clock := fun w => properTime w.1 w.2
  clock_nonneg := fun w => properTime_nonneg w.1 w.2
  witness := (origin, origin)

/-- Universal lift: any lifted `LorentzianSpaceTime` satisfies the CAT/EPT
    spine identification `actionIm/ℏ = eptClock`.  Proof: one application
    of `TemporalFramework.coherence_spine`, no per-spacetime work. -/
theorem coherence_spine_of_lift
    (M : Type) [LorentzianSpaceTime M] (origin : M) :
    cateptConsistencyConstraint
      (toTemporalFramework M origin).toCATEPTSlot :=
  (toTemporalFramework M origin).coherence_spine

/-- Live-tier upgrade: when a `LorentzianSpaceTime` admits a timelike pair,
    its lift becomes a `LiveTemporalFramework`. -/
noncomputable def liveOfTimelike
    (M : Type) [inst : LorentzianSpaceTime M] (origin : M)
    (q p : M) (hC : inst.causal q p) :
    LiveTemporalFramework where
  toTemporalFramework := toTemporalFramework M origin
  live_witness := ⟨(q, p), properTime_pos_of_causal_timelike q p hC⟩

end LorentzianSpaceTime

-- ═══════════════════════════════════════════════════════════════════════
-- Physlib SR instance + named lift
-- ═══════════════════════════════════════════════════════════════════════

/-- Physlib `SpaceTime d` is a `LorentzianSpaceTime` via `properTime`. -/
noncomputable instance physlibLorentzianSpaceTime (d : ℕ) :
    LorentzianSpaceTime (SpaceTime d) where
  properTime q p := SpaceTime.properTime q p
  properTime_nonneg _ _ := Real.sqrt_nonneg _
  causal q p := Lorentz.Vector.causalCharacter (p - q) = .timeLike
  properTime_pos_of_causal_timelike q p h :=
    SpaceTime.properTime_pos_ofTimeLike q p h

/-- Named alias: Physlib SR proper time, lifted to CAT/EPT via the
    `LorentzianSpaceTime` abstraction.  Origin pinned at `0` (the
    degenerate worldline at the spacetime origin). -/
noncomputable def physlibSRTemporalFramework (d : ℕ) : TemporalFramework :=
  LorentzianSpaceTime.toTemporalFramework (SpaceTime d) 0

/-- ★ HEADLINE ★ The Physlib SR lift satisfies the CAT/EPT spine
    identification `actionIm/ℏ = eptClock`.

    This is the proof object the architecture audit asked for: Physlib's
    SR `properTime` plugs into CAT/EPT's universal temporal-coherence
    theorem WITHOUT requiring Physlib to depend on catept-main. -/
theorem physlibSRTemporalFramework_coherent (d : ℕ) :
    cateptConsistencyConstraint
      (physlibSRTemporalFramework d).toCATEPTSlot :=
  (physlibSRTemporalFramework d).coherence_spine

/-- Live-tier upgrade: any timelike Physlib pair `(q, p)` produces a
    `LiveTemporalFramework` over the Physlib SR lift. -/
noncomputable def physlibSRLive (d : ℕ) (q p : SpaceTime d)
    (hTL : Lorentz.Vector.causalCharacter (p - q) = .timeLike) :
    LiveTemporalFramework :=
  LorentzianSpaceTime.liveOfTimelike (SpaceTime d) 0 q p hTL

-- ═══════════════════════════════════════════════════════════════════════
-- Joint QM ⊕ Classical (Harmonic) ⊕ SR (Physlib) demo
-- ═══════════════════════════════════════════════════════════════════════

open CATEPTMain.Temporal.Adapter (joint jointClock harmonic qm)
open CATEPTMain.Quantum.QUANTUM (DensityMatrix)

/-- Joint `TemporalFramework` spanning **quantum mechanics, classical
    mechanics, and Physlib special relativity** in one CAT/EPT framework.

    Configuration:
      `HOConfig × ((SpaceTime d × SpaceTime d) × DensityMatrix n)`

    Joint clock (additive over components):
      `harmonic.clock x_HO + physlibSR.clock (q, p) + qm.clock ρ`. -/
noncomputable def harmonicSRQM (d n : ℕ) (ρ₀ : DensityMatrix n) :
    TemporalFramework :=
  joint harmonic (joint (physlibSRTemporalFramework d) (qm n ρ₀))

/-- ★ HEADLINE ★ The joint **QM ⊕ classical ⊕ Physlib-SR** framework
    satisfies the CAT/EPT spine identification.

    Same one-line proof as every other joint adapter — the universal
    `coherence_spine` carries through composition. -/
theorem harmonicSRQM_satisfies_spine
    (d n : ℕ) (ρ₀ : DensityMatrix n) :
    cateptConsistencyConstraint
      (harmonicSRQM d n ρ₀).toCATEPTSlot :=
  (harmonicSRQM d n ρ₀).coherence_spine

/-- Pointwise clock decomposition: the joint clock IS the sum of the three
    component clocks.  Useful when reading the joint entropic time on
    concrete states. -/
theorem harmonicSRQM_clock_decomposition
    (d n : ℕ) (ρ₀ : DensityMatrix n)
    (xHO : (Fin 2 → ℝ)) (q p : SpaceTime d) (ρ : DensityMatrix n) :
    (harmonicSRQM d n ρ₀).clock (xHO, (q, p), ρ) =
      harmonic.clock xHO
      + (physlibSRTemporalFramework d).clock (q, p)
      + (qm n ρ₀).clock ρ := by
  unfold harmonicSRQM joint jointClock
  ring

end CATEPTMain.Integration
