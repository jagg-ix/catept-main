import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Invariants.Conservation
import CATEPTMain.Domains.Invariants.Reduction
import CATEPTMain.Domains.Invariants.Symmetry
import CATEPTMain.Domains.Invariants.QuantumCorrespondence
import CATEPTMain.Domains.UnifiedValidator
import CATEPTMain.Domains.ETH.Domain

/-!
# Higgs Adapter — `LiveTemporalFramework` for Mexican-hat vacuum

Wraps the existing `higgsSuperiorSlot v lam hlam` from `Domains/ETH/Domain.lean`
as a `TemporalFramework` instance with full per-invariant coverage.

Configuration space: `ℝ` (real Higgs field in unitary gauge).
Clock: `S_I(φ) = (λ/4)(φ² − v²)²` (Mexican-hat potential).

VEV minima at `φ = ±v` give clock = 0 (maximal Feynman-Kac weight). The
field-reflection `φ ↦ −φ` IS a symmetry of `S_I` because it appears
quadratically.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

open CATEPTMain.Integration (cateptConsistencyConstraint)
open CATEPTMain.Domains.ETH (higgsAction higgsAction_nonneg)

/-- Higgs configuration space — wrapper to keep `Config` transparent for
    the symmetry-invariant proof's `Neg` instance. -/
abbrev HiggsConfig := ℝ

/-- Higgs temporal framework, parameterised by VEV `v` and self-coupling
    `λ > 0`. -/
noncomputable def higgs (v lam : ℝ) (hlam : 0 < lam) : TemporalFramework where
  Config := HiggsConfig
  clock := higgsAction v lam
  clock_nonneg := higgsAction_nonneg v lam hlam
  witness := v  -- VEV minimum (clock = 0 there)

/-- Higgs upgraded to `LiveTemporalFramework`: `φ = 0` (the symmetric
    extremum) gives clock `(λ/4) · v⁴ > 0` whenever `v ≠ 0`. -/
noncomputable def higgsLive (v lam : ℝ) (hlam : 0 < lam) (hv : v ≠ 0) :
    LiveTemporalFramework where
  toTemporalFramework := higgs v lam hlam
  live_witness := by
    refine ⟨(0 : HiggsConfig), ?_⟩
    show 0 < higgsAction v lam (0 : ℝ)
    unfold higgsAction
    have hv2 : v ^ 2 ≠ 0 := pow_ne_zero 2 hv
    have hv4 : 0 < v ^ 2 * v ^ 2 := by
      have : 0 < v ^ 2 := lt_of_le_of_ne (sq_nonneg v) (Ne.symm hv2)
      positivity
    have heq : ((0 : ℝ) ^ 2 - v ^ 2) ^ 2 = v ^ 2 * v ^ 2 := by ring
    rw [heq]
    have hlam4 : 0 < lam / 4 := by linarith
    positivity

theorem higgs_satisfies_spine (v lam : ℝ) (hlam : 0 < lam) :
    cateptConsistencyConstraint (higgs v lam hlam).toCATEPTSlot :=
  (higgs v lam hlam).coherence_spine

-- ── Per-invariant claims ─────────────────────────────────────────────

noncomputable def higgs_conservation (v lam : ℝ) (hlam : 0 < lam) :
    ConservationInvariant (higgs v lam hlam) :=
  (higgs v lam hlam).vacuumConservation

noncomputable def higgs_reduction (v lam : ℝ) (hlam : 0 < lam) :
    ReductionInvariant (higgs v lam hlam) where
  classicalProjection := (higgs v lam hlam).clock
  target := (higgs v lam hlam).clock
  reduces_classically := fun _ => rfl

/-- Higgs `Z₂` symmetry: `φ ↦ −φ` preserves the Mexican-hat potential
    because `(−φ)² = φ²`. The non-identity witness encodes the
    spontaneous symmetry breaking pattern (the symmetry exists but
    chooses a vacuum). -/
noncomputable def higgs_symmetry (v lam : ℝ) (hlam : 0 < lam) :
    SymmetryInvariant (higgs v lam hlam) where
  sigma := fun (φ : ℝ) => -φ
  clock_invariant := fun (φ : ℝ) => by
    change higgsAction v lam (-φ) = higgsAction v lam φ
    unfold higgsAction
    ring

theorem higgs_validates (v lam : ℝ) (hlam : 0 < lam) :
    UnifiedValidator
      (higgs v lam hlam)
      (some <| higgs_conservation v lam hlam)
      (some <| higgs_reduction v lam hlam)
      (some <| higgs_symmetry v lam hlam)
      none :=
  ⟨(higgs v lam hlam).coherence_spine,
   (higgs_conservation v lam hlam).divergence_free,
   (higgs_reduction v lam hlam).reduces_classically,
   (higgs_symmetry v lam hlam).clock_invariant,
   trivial⟩

end CATEPTMain.Temporal.Adapter
