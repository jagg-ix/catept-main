import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Invariants.Conservation
import CATEPTMain.Domains.Invariants.Reduction
import CATEPTMain.Domains.Invariants.Symmetry
import CATEPTMain.Domains.Invariants.QuantumCorrespondence
import CATEPTMain.Domains.UnifiedValidator
import CATEPTMain.Domains.SR.Domain

/-!
# SR Adapter — Physlib-backed Proper Time

Wraps `srSuperiorSlot d` (in `Domains/SR/Domain.lean`, which itself
exposes Physlib's `SpaceTime.properTime`) as a `TemporalFramework`.

This is the **first Physlib-backed adapter** in the spine. The clock is
the relativistic proper time τ = √⟪p−q, p−q⟫ₘ; the kernel-tier
non-negativity is `Real.sqrt_nonneg`.

## Tier

Kernel-tier with the origin-pair witness `(0, 0)` (a degenerate
worldline at the origin). Live tier requires constructing a SpaceTime
pair with time-like separation — the Physlib lemma
`properTime_pos_ofTimeLike` is available, but synthesising a concrete
time-like vector goes through `Lorentz.Vector` API not exercised here.
Same kernel-only treatment as the QM adapter (T70).

## Distribution-lane note

This file is **not** imported by the root `CATEPTMain.lean` umbrella;
it appears only in the `CoherenceShowcase` audit graph. See the note
at the top of `Domains/SR/Domain.lean` for the full conflict path.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

open CATEPTMain.Integration (cateptConsistencyConstraint)
open CATEPTMain.Domains.SR (srSuperiorSlot SREvent)

/-- SR temporal framework: clock = proper time on `SpaceTime d × SpaceTime d`. -/
noncomputable def sr (d : ℕ) : TemporalFramework where
  Config := SREvent d
  clock := fun w => SpaceTime.properTime w.1 w.2
  clock_nonneg := fun _ => Real.sqrt_nonneg _
  witness := (0, 0)

theorem sr_satisfies_spine (d : ℕ) :
    cateptConsistencyConstraint (sr d).toCATEPTSlot :=
  (sr d).coherence_spine

-- ── Per-invariant claims (3/4 — QC deferred) ─────────────────────────

noncomputable def sr_conservation (d : ℕ) : ConservationInvariant (sr d) :=
  (sr d).vacuumConservation

noncomputable def sr_reduction (d : ℕ) : ReductionInvariant (sr d) where
  classicalProjection := (sr d).clock
  target := (sr d).clock
  reduces_classically := fun _ => rfl

/-- Trivial (identity) symmetry. The natural SR symmetry is worldline
    time-reversal `(q, p) ↦ (p, q)`, which is invariant because the
    Minkowski inner product satisfies `⟪p−q, p−q⟫ₘ = ⟪q−p, q−p⟫ₘ`.
    Proving this requires unfolding Physlib's `MinkowskiProduct` API —
    deferred to a phase-2 follow-up; ship identity for kernel-tier. -/
noncomputable def sr_symmetry (d : ℕ) : SymmetryInvariant (sr d) :=
  (sr d).identitySymmetry

theorem sr_validates (d : ℕ) :
    UnifiedValidator (sr d)
      (some <| sr_conservation d)
      (some <| sr_reduction d)
      (some <| sr_symmetry d)
      none :=
  ⟨(sr d).coherence_spine,
   (sr_conservation d).divergence_free,
   (sr_reduction d).reduces_classically,
   (sr_symmetry d).clock_invariant,
   trivial⟩

/-- **SR live tier** (T92, Group A4). Caller-supplied witness pattern:
    given a SpaceTime pair `(q, p)` with time-like separation, the
    SR adapter upgrades to `LiveTemporalFramework` with positive clock.

    The live witness uses Physlib's `properTime_pos_ofTimeLike`
    (re-exposed in T77 as `srSuperiorSlot_clock_pos_of_timeLike`) —
    no construction of concrete time-like vectors via the
    Lorentz.Vector API needed; the existence of such a pair is what
    the caller asserts. Same caller-supplied-witness pattern as
    Higgs (T69) and Herglotz (T70 herglotzLive). -/
noncomputable def srLive (d : ℕ) (q p : SpaceTime d)
    (hTL : Lorentz.Vector.causalCharacter (p - q) = .timeLike) :
    LiveTemporalFramework where
  toTemporalFramework := sr d
  live_witness := by
    refine ⟨(q, p), ?_⟩
    show 0 < SpaceTime.properTime q p
    exact SpaceTime.properTime_pos_ofTimeLike q p hTL

theorem sr_dynamics_nontrivial (d : ℕ) (q p : SpaceTime d)
    (hTL : Lorentz.Vector.causalCharacter (p - q) = .timeLike) :
    ∃ x : (sr d).Config, 0 < (sr d).clock x :=
  (srLive d q p hTL).dynamics_nontrivial

end CATEPTMain.Temporal.Adapter
