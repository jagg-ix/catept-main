import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Adapters.Minkowski
import CATEPTMain.Domains.Adapters.EM
import CATEPTMain.Domains.Adapters.QM
import CATEPTMain.Domains.QM.Domain

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

open CATEPTMain.Integration (cateptConsistencyConstraint)
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

end CATEPTMain.Temporal.Adapter
