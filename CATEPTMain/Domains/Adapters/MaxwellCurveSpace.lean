import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Invariants.Conservation
import CATEPTMain.Domains.Invariants.Reduction
import CATEPTMain.Domains.Invariants.Symmetry
import CATEPTMain.Domains.Invariants.QuantumCorrespondence
import CATEPTMain.Domains.UnifiedValidator
import CATEPTMain.Integration.MaxwellCurveSpacePphi2Bridge

/-!
# Maxwell-CurveSpace Adapter (T88) — first curved-spacetime adapter

Wraps the `catept-plugin-maxwell-curvespace-pphi2` plugin's
`CatEptMaxwellCurveSpaceModel` as a `TemporalFramework`. The clock
combines curvature energy, Maxwell action, and their coupling — all
three non-negative, hence the sum is.

This is the **first curved-spacetime adapter** in the spine surface.
The existing T66 EM adapter handles flat-space `‖A‖²/(2μ₀)`; this one
handles curved-space Maxwell with explicit gravity coupling via the
plugin's `couplingEnergy : CurveSpace → MaxwellState → ℝ`.

## Composition with the joint operator (T79)

Given a populated `CatEptMaxwellCurveSpaceModel m` with non-negativity
proofs and an inhabitant of its config type, the adapter composes
into the existing `maxwellGRQM` joint via T79's `joint`:

  `maxwellGRQMcurved := joint maxwellCurveSpace (joint minkowski (joint em qm))`

extending the structural QM ⊕ GR ⊕ Maxwell-flat unification to also
include Maxwell-in-curved-spacetime with an OS-reconstruction interface.

## Adapter coverage

  Tier:  kernel (live tier deferred — caller may upgrade by supplying
         a config witness with strictly positive clock).
  Cons:  vacuum default (Phase-2: refine using stress-energy from the
         coupled Maxwell-Einstein system).
  Red:   identity reduction (clock reduces to itself).
  Sym:   identity symmetry (Phase-2: lift the EM gauge-symmetry and
         GR diffeomorphism-symmetry to the joint product).
  QC:    not claimed at this tier (Phase-2: tie to the QFT
         expectation-value bridge).
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

open CATEPTMain.Integration (CatEptMaxwellCurveSpaceModel cateptConsistencyConstraint)

/-- Joint configuration for Maxwell-in-curved-spacetime: a
    `CurveSpace` event paired with a `MaxwellState`. -/
abbrev MaxwellCurveSpaceConfig (m : CatEptMaxwellCurveSpaceModel) :=
  m.CurveSpace × m.MaxwellState

/-- Combined non-negative clock:
    `clock(x, a) = curvatureEnergy(x) + maxwellAction(a) + couplingEnergy(x, a)`. -/
noncomputable def maxwellCurveSpaceClock
    (m : CatEptMaxwellCurveSpaceModel) :
    MaxwellCurveSpaceConfig m → ℝ :=
  fun p => m.curvatureEnergy p.1 + m.maxwellAction p.2 + m.couplingEnergy p.1 p.2

theorem maxwellCurveSpaceClock_nonneg
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a) :
    ∀ p : MaxwellCurveSpaceConfig m, 0 ≤ maxwellCurveSpaceClock m p := by
  intro p
  unfold maxwellCurveSpaceClock
  have h1 := hCE p.1
  have h2 := hMA p.2
  have h3 := hCo p.1 p.2
  linarith

/-- The Maxwell-curved-spacetime `TemporalFramework`. Caller supplies
    a populated model `m`, three non-negativity proofs, and a witness
    config inhabitant. -/
noncomputable def maxwellCurveSpace
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (witness₀ : MaxwellCurveSpaceConfig m) : TemporalFramework where
  Config := MaxwellCurveSpaceConfig m
  clock := maxwellCurveSpaceClock m
  clock_nonneg := maxwellCurveSpaceClock_nonneg m hCE hMA hCo
  witness := witness₀

theorem maxwellCurveSpace_satisfies_spine
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (w : MaxwellCurveSpaceConfig m) :
    cateptConsistencyConstraint
      (maxwellCurveSpace m hCE hMA hCo w).toCATEPTSlot :=
  (maxwellCurveSpace m hCE hMA hCo w).coherence_spine

-- ── Per-invariant claims (3/4 — QC deferred) ─────────────────────────

noncomputable def maxwellCurveSpace_conservation
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (w : MaxwellCurveSpaceConfig m) :
    ConservationInvariant (maxwellCurveSpace m hCE hMA hCo w) :=
  (maxwellCurveSpace m hCE hMA hCo w).vacuumConservation

noncomputable def maxwellCurveSpace_reduction
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (w : MaxwellCurveSpaceConfig m) :
    ReductionInvariant (maxwellCurveSpace m hCE hMA hCo w) where
  classicalProjection := (maxwellCurveSpace m hCE hMA hCo w).clock
  target := (maxwellCurveSpace m hCE hMA hCo w).clock
  reduces_classically := fun _ => rfl

noncomputable def maxwellCurveSpace_symmetry
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (w : MaxwellCurveSpaceConfig m) :
    SymmetryInvariant (maxwellCurveSpace m hCE hMA hCo w) :=
  (maxwellCurveSpace m hCE hMA hCo w).identitySymmetry

theorem maxwellCurveSpace_validates
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (w : MaxwellCurveSpaceConfig m) :
    UnifiedValidator (maxwellCurveSpace m hCE hMA hCo w)
      (some <| maxwellCurveSpace_conservation m hCE hMA hCo w)
      (some <| maxwellCurveSpace_reduction m hCE hMA hCo w)
      (some <| maxwellCurveSpace_symmetry m hCE hMA hCo w)
      none :=
  ⟨(maxwellCurveSpace m hCE hMA hCo w).coherence_spine,
   (maxwellCurveSpace_conservation m hCE hMA hCo w).divergence_free,
   (maxwellCurveSpace_reduction m hCE hMA hCo w).reduces_classically,
   (maxwellCurveSpace_symmetry m hCE hMA hCo w).clock_invariant,
   trivial⟩

/-- **MaxwellCurveSpace live tier** (T92, Group A5). Caller-supplied
    live-witness pattern: any pair `(x, a)` for which at least one of
    `m.curvatureEnergy x`, `m.maxwellAction a`, `m.couplingEnergy x a`
    is strictly positive yields a live-tier witness, since the joint
    clock is the sum of three non-negatives. -/
noncomputable def maxwellCurveSpaceLive
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (witness₀ : MaxwellCurveSpaceConfig m)
    (live : MaxwellCurveSpaceConfig m)
    (hPos : 0 < m.curvatureEnergy live.1
            + m.maxwellAction live.2
            + m.couplingEnergy live.1 live.2) :
    LiveTemporalFramework where
  toTemporalFramework := maxwellCurveSpace m hCE hMA hCo witness₀
  live_witness := by
    refine ⟨live, ?_⟩
    show 0 < maxwellCurveSpaceClock m live
    unfold maxwellCurveSpaceClock
    exact hPos

theorem maxwellCurveSpace_dynamics_nontrivial
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (witness₀ : MaxwellCurveSpaceConfig m)
    (live : MaxwellCurveSpaceConfig m)
    (hPos : 0 < m.curvatureEnergy live.1
            + m.maxwellAction live.2
            + m.couplingEnergy live.1 live.2) :
    ∃ x : (maxwellCurveSpace m hCE hMA hCo witness₀).Config,
      0 < (maxwellCurveSpace m hCE hMA hCo witness₀).clock x :=
  (maxwellCurveSpaceLive m hCE hMA hCo witness₀ live hPos).dynamics_nontrivial

end CATEPTMain.Temporal.Adapter
