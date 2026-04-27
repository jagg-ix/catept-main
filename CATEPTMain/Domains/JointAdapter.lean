import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Adapters.Minkowski
import CATEPTMain.Domains.Adapters.EM
import CATEPTMain.Domains.Adapters.QM
import CATEPTMain.Domains.QM.Domain
import CATEPTMain.Domains.Adapters.MaxwellCurveSpace
import CATEPTMain.Domains.Invariants.QuantumCorrespondence

/-!
# Joint TemporalFramework — QM ⊕ GR ⊕ Maxwell unification

The CATEPT spine identification `actionIm/ℏ = eptClock` is *additive*:
if `T₁` and `T₂` are TemporalFrameworks, then the configuration space
`T₁.Config × T₂.Config` with clock `(x₁, x₂) ↦ T₁.clock x₁ + T₂.clock x₂`
is itself a TemporalFramework, and the spine theorem
`coherence_spine` discharges by `div_one` exactly as for individual
adapters.

That single structural theorem is the substrate-level reason CATEPT
unifies QM + GR + Maxwell in curved spacetime: the three adapters'
Configs combine into one joint Config, and the spine identification
holds *for free*.

This file makes the joint adapter explicit and demonstrates the
headline composition:

  GR (Minkowski) ⊕ Maxwell (EM) ⊕ QM (density matrix)
  =
  `maxwellGRQM μ₀ hμ₀ n ρ₀ : TemporalFramework`

with `maxwellGRQM_satisfies_spine` proven by `coherence_spine`.

## What this proves

- The CATEPT spine is closed under arbitrary finite joins.
- Any combination of physical theories that fit the SuperiorMethodSlot
  / TemporalFramework shape can be plugged into a single CAT/EPT
  framework without re-deriving the spine constraint.

## What this does *not* prove

- Specific theorems about Maxwell-QFT-in-curved-spacetime (e.g.
  Reeh-Schlieder, Hadamard property, Wightman positivity). Those are
  domain-specific and live in their own bridge files.
- The 11 universal invariants (wave-particle, gauge-geometry, etc.)
  for the joint framework. Those are tracked separately in
  `UnifiedConstraints.lean` and discharge case-by-case.

The joint construction is the *structural backbone* — it shows the
spine survives composition. The physical content lives in the per-
adapter and per-invariant files.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

open CATEPTMain.Integration (cateptConsistencyConstraint CatEptMaxwellCurveSpaceModel)
open CATEPTMain.Quantum.QUANTUM (DensityMatrix)

-- ─── Binary join ─────────────────────────────────────────────────────

/-- Joint configuration: ordered pair of two adapter configs. -/
abbrev JointConfig (T₁ T₂ : TemporalFramework) := T₁.Config × T₂.Config

/-- Joint clock: sum of component clocks (each non-negative, hence the
    sum is non-negative). -/
noncomputable def jointClock (T₁ T₂ : TemporalFramework) :
    JointConfig T₁ T₂ → ℝ :=
  fun x => T₁.clock x.1 + T₂.clock x.2

theorem jointClock_nonneg (T₁ T₂ : TemporalFramework) :
    ∀ x : JointConfig T₁ T₂, 0 ≤ jointClock T₁ T₂ x := by
  intro x
  exact add_nonneg (T₁.clock_nonneg x.1) (T₂.clock_nonneg x.2)

/-- The binary join of two TemporalFrameworks. The spine identification
    `actionIm/ℏ = eptClock` is automatic via `coherence_spine`. -/
noncomputable def joint (T₁ T₂ : TemporalFramework) : TemporalFramework where
  Config := JointConfig T₁ T₂
  clock := jointClock T₁ T₂
  clock_nonneg := jointClock_nonneg T₁ T₂
  witness := (T₁.witness, T₂.witness)

/-- The joint TemporalFramework satisfies the CATEPT spine, by
    `div_one` — the same proof as every individual adapter. -/
theorem joint_satisfies_spine (T₁ T₂ : TemporalFramework) :
    cateptConsistencyConstraint (joint T₁ T₂).toCATEPTSlot :=
  (joint T₁ T₂).coherence_spine

-- ─── Headline: QM ⊕ GR ⊕ Maxwell ─────────────────────────────────────

/-- **Unified Maxwell-GR-QM TemporalFramework.**
    The composition `minkowski ⊕ (em μ₀) ⊕ (qm n ρ₀)` exhibits Maxwell
    electrodynamics + Minkowski geometry + quantum density-matrix
    observables in a single CAT/EPT framework. The spine identification
    `actionIm/ℏ = eptClock` holds on this joint framework by the
    universal `coherence_spine` theorem. -/
noncomputable def maxwellGRQM (μ₀ : ℝ) (hμ₀ : 0 < μ₀)
    (n : ℕ) (ρ₀ : DensityMatrix n) :
    TemporalFramework :=
  joint minkowski (joint (em μ₀ hμ₀) (qm n ρ₀))

/-- The unified Maxwell-GR-QM framework satisfies the CATEPT spine.
    Headline corollary of `joint_satisfies_spine` applied twice. -/
theorem maxwellGRQM_satisfies_spine (μ₀ : ℝ) (hμ₀ : 0 < μ₀)
    (n : ℕ) (ρ₀ : DensityMatrix n) :
    cateptConsistencyConstraint
      (maxwellGRQM μ₀ hμ₀ n ρ₀).toCATEPTSlot :=
  (maxwellGRQM μ₀ hμ₀ n ρ₀).coherence_spine

/-- The unified Maxwell-GR-QM framework's clock is the sum of the
    component clocks. Pointwise unfolding gives a transparent reading
    of the joint entropic-time observable. -/
theorem maxwellGRQM_clock_decomposition (μ₀ : ℝ) (hμ₀ : 0 < μ₀)
    (n : ℕ) (ρ₀ : DensityMatrix n)
    (gx : (Fin 4 → ℝ)) (Ax : (Fin 4 → ℝ))
    (ρ : DensityMatrix n) :
    (maxwellGRQM μ₀ hμ₀ n ρ₀).clock (gx, Ax, ρ) =
      minkowski.clock gx + (em μ₀ hμ₀).clock Ax + (qm n ρ₀).clock ρ := by
  -- jointClock unfolds to component sums by definition
  unfold maxwellGRQM joint jointClock
  ring

-- ─── 4-way join: QM ⊕ GR ⊕ Maxwell-flat ⊕ Maxwell-curved (T89) ──────

/-- **Unified Maxwell-CurveSpace + GR + Maxwell-flat + QM `TemporalFramework`.**

    Adds the T88 curved-spacetime Maxwell layer on top of T79's
    `maxwellGRQM`. Configuration:

      `MaxwellCurveSpaceConfig m × (Fin 4 → ℝ) × (Fin 4 → ℝ) × DensityMatrix n`

    The joint clock decomposes pointwise into a 4-way sum (see
    `maxwellGRQMcurved_clock_decomposition`). The spine identification
    `actionIm/ℏ = eptClock` holds on the joint framework via two
    applications of `coherence_spine` — no new theorem needed beyond
    the structural one in T79.

    Caller supplies the plugin model `m` plus its three non-negativity
    proofs and a witness config inhabitant; the GR/EM/QM layers carry
    their existing parameters. -/
noncomputable def maxwellGRQMcurved
    (μ₀ : ℝ) (hμ₀ : 0 < μ₀) (n : ℕ) (ρ₀ : DensityMatrix n)
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (witness₀ : MaxwellCurveSpaceConfig m) :
    TemporalFramework :=
  joint (maxwellCurveSpace m hCE hMA hCo witness₀) (maxwellGRQM μ₀ hμ₀ n ρ₀)

/-- The 4-way unified framework satisfies the CATEPT spine. Headline
    corollary of `joint_satisfies_spine` applied three times — and
    proved here in one line via the universal `coherence_spine`. -/
theorem maxwellGRQMcurved_satisfies_spine
    (μ₀ : ℝ) (hμ₀ : 0 < μ₀) (n : ℕ) (ρ₀ : DensityMatrix n)
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (witness₀ : MaxwellCurveSpaceConfig m) :
    cateptConsistencyConstraint
      (maxwellGRQMcurved μ₀ hμ₀ n ρ₀ m hCE hMA hCo witness₀).toCATEPTSlot :=
  (maxwellGRQMcurved μ₀ hμ₀ n ρ₀ m hCE hMA hCo witness₀).coherence_spine

/-- The 4-way joint clock decomposes pointwise into the sum of its four
    component clocks. Pointwise unfolding gives a transparent reading
    of the unified entropic-time observable as

      `τ_curved + τ_minkowski + τ_em + τ_qm` -/
theorem maxwellGRQMcurved_clock_decomposition
    (μ₀ : ℝ) (hμ₀ : 0 < μ₀) (n : ℕ) (ρ₀ : DensityMatrix n)
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (witness₀ : MaxwellCurveSpaceConfig m)
    (cs : MaxwellCurveSpaceConfig m)
    (gx : (Fin 4 → ℝ)) (Ax : (Fin 4 → ℝ))
    (ρ : DensityMatrix n) :
    (maxwellGRQMcurved μ₀ hμ₀ n ρ₀ m hCE hMA hCo witness₀).clock
        (cs, gx, Ax, ρ) =
      (maxwellCurveSpace m hCE hMA hCo witness₀).clock cs
      + minkowski.clock gx
      + (em μ₀ hμ₀).clock Ax
      + (qm n ρ₀).clock ρ := by
  unfold maxwellGRQMcurved maxwellGRQM joint jointClock
  ring

-- ─── Composing QuantumCorrespondence across joints (T96) ─────────────

/-- **Generic joint QC composition.** Given two `TemporalFramework`s
    `T₁` and `T₂` each with a `QuantumCorrespondenceInvariant` whose
    `G` values agree, the joint `joint T₁ T₂` inherits a
    `QuantumCorrespondenceInvariant` with the same `G`, where:

      curvature        = qc₁.curvature x.1 + qc₂.curvature x.2
      expectationValue = qc₁.expectationValue x.1 + qc₂.expectationValue x.2
      bridges          = linear combination of qc₁.bridges and qc₂.bridges

    The shared-`G` constraint is needed because the joint bridge is
    `R = 8πG·⟨O⟩` with one common `G`. With T68/T91/T94/T95 all
    using `G = 1/(8π)`, this composition lifts cleanly to all 10
    non-vacuum-QC-claiming spine adapters. -/
noncomputable def joint_quantum_correspondence
    {T₁ T₂ : TemporalFramework}
    (qc₁ : QuantumCorrespondenceInvariant T₁)
    (qc₂ : QuantumCorrespondenceInvariant T₂)
    (hG : qc₁.G = qc₂.G) :
    QuantumCorrespondenceInvariant (joint T₁ T₂) where
  curvature := fun x => qc₁.curvature x.1 + qc₂.curvature x.2
  expectationValue := fun x => qc₁.expectationValue x.1 + qc₂.expectationValue x.2
  G := qc₁.G
  G_pos := qc₁.G_pos
  bridges := by
    intro x
    show qc₁.curvature x.1 + qc₂.curvature x.2
        = 8 * Real.pi * qc₁.G
            * (qc₁.expectationValue x.1 + qc₂.expectationValue x.2)
    have h1 := qc₁.bridges x.1
    have h2 := qc₂.bridges x.2
    rw [h1, h2, hG]
    ring

/-- **Minkowski non-vacuum-shape QC at G = 1/(8π).** Same vacuum data
    (curvature = expectationValue ≡ 0) but uses the same `G` value as
    the rest of the spine adapters (T68/T91/T94/T95 all use
    `1/(8π)`), so it composes via `joint_quantum_correspondence`
    without G-mismatch. The vacuum-default
    `minkowski_quantum_correspondence` (T66) uses `G = 1` — kept as-is
    for back-compat; this is the composition-friendly variant. -/
noncomputable def minkowski_quantum_correspondence_unitPrefactor :
    QuantumCorrespondenceInvariant minkowski where
  curvature := fun _ => 0
  expectationValue := fun _ => 0
  G := 1 / (8 * Real.pi)
  G_pos := by
    apply div_pos one_pos
    have hπ : 0 < Real.pi := Real.pi_pos
    positivity
  bridges := by intro _; ring

/-- **`maxwellGRQM` non-vacuum QC.** All three components share
    `G = 1/(8π)`: minkowski uses the unit-prefactor variant above;
    T91 EM and T95 QM both fix `G = 1/(8π)`. The joint inherits via
    two applications of `joint_quantum_correspondence`. -/
noncomputable def maxwellGRQM_quantum_correspondence
    (μ₀ : ℝ) (hμ₀ : 0 < μ₀) (n : ℕ) (ρ₀ : DensityMatrix n) :
    QuantumCorrespondenceInvariant (maxwellGRQM μ₀ hμ₀ n ρ₀) :=
  joint_quantum_correspondence
    minkowski_quantum_correspondence_unitPrefactor
    (joint_quantum_correspondence
      (em_quantum_correspondence μ₀ hμ₀)
      (qm_quantum_correspondence n ρ₀)
      rfl)
    rfl

/-- **`maxwellGRQMcurved` non-vacuum QC.** Four-way composition adding
    the T88 curved-spacetime layer on top. All four components share
    `G = 1/(8π)`. -/
noncomputable def maxwellGRQMcurved_quantum_correspondence
    (μ₀ : ℝ) (hμ₀ : 0 < μ₀) (n : ℕ) (ρ₀ : DensityMatrix n)
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (witness₀ : MaxwellCurveSpaceConfig m) :
    QuantumCorrespondenceInvariant
      (maxwellGRQMcurved μ₀ hμ₀ n ρ₀ m hCE hMA hCo witness₀) :=
  joint_quantum_correspondence
    (maxwellCurveSpace_quantum_correspondence m hCE hMA hCo witness₀)
    (maxwellGRQM_quantum_correspondence μ₀ hμ₀ n ρ₀)
    rfl

end CATEPTMain.Temporal.Adapter
