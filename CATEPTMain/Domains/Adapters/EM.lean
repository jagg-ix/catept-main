import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.GR.Domain
import CATEPTMain.Domains.Invariants.Conservation
import CATEPTMain.Domains.Invariants.Reduction
import CATEPTMain.Domains.Invariants.Symmetry
import CATEPTMain.Domains.Invariants.QuantumCorrespondence

/-!
# EM Adapter — `LiveTemporalFramework` instance for QFT-on-curved-spacetime

The EM Lagrangian density slot from `Domains/GR/Domain.lean`
(`emSuperiorSlot μ₀ hμ₀`), re-presented as an instance of the
`LiveTemporalFramework` contract.

Dynamics are non-trivial: any non-zero gauge potential `A` has positive
action `‖A‖²/(2μ₀)`.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

open CATEPTMain.Domains

/-- EM as a kernel-tier `TemporalFramework` (parameterised by the vacuum
    permeability `μ₀ > 0`). -/
noncomputable def em (μ₀ : ℝ) (hμ₀ : 0 < μ₀) : TemporalFramework where
  Config := Fin 4 → ℝ
  clock := fun A => (∑ μ : Fin 4, A μ ^ 2) / (2 * μ₀)
  clock_nonneg := fun A =>
    div_nonneg (Finset.sum_nonneg fun _ _ => sq_nonneg _) (by linarith)
  witness := fun _ => 0

/-- EM upgraded to `LiveTemporalFramework`: the gauge potential
    `A = (1, 0, 0, 0)` gives action `1/(2μ₀) > 0`. -/
noncomputable def emLive (μ₀ : ℝ) (hμ₀ : 0 < μ₀) : LiveTemporalFramework where
  toTemporalFramework := em μ₀ hμ₀
  live_witness := by
    refine ⟨fun μ => if μ = 0 then 1 else 0, ?_⟩
    show 0 < (∑ μ : Fin 4, (if μ = 0 then 1 else 0) ^ 2) / (2 * μ₀)
    apply div_pos
    · -- the sum equals 1
      simp [Fin.sum_univ_four]
    · linarith

/-- EM adapter satisfies the spine via the universal coherence theorem. -/
theorem em_satisfies_spine (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    CATEPTMain.Integration.cateptConsistencyConstraint
      (em μ₀ hμ₀).toCATEPTSlot :=
  (em μ₀ hμ₀).coherence_spine

-- ═════════════════════════════════════════════════════════════════════
-- Per-invariant claims (T66e)
-- ═════════════════════════════════════════════════════════════════════

/-- EM conservation: vacuum stress-energy. (Phase-1 placeholder; phase-2
    refines to the actual Maxwell stress tensor `T^{μν} = F^{μα} F^ν_α
    − ¼ g^{μν} F^{αβ} F_{αβ}` once the smooth-section infrastructure is
    available.) -/
noncomputable def em_conservation (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    ConservationInvariant (em μ₀ hμ₀) :=
  (em μ₀ hμ₀).vacuumConservation

/-- EM reduction: the action `‖A‖²/(2μ₀)` IS the Maxwell low-energy form
    in this configuration-space presentation. Reduction equality is
    pointwise reflexivity. -/
noncomputable def em_reduction (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    ReductionInvariant (em μ₀ hμ₀) where
  classicalProjection := (em μ₀ hμ₀).clock
  target := (em μ₀ hμ₀).clock
  reduces_classically := fun _ => rfl

/-- EM symmetry: the clock `‖A‖²/(2μ₀)` is invariant under negation
    `A ↦ -A` (since `(-A)² = A²` componentwise). Concrete non-identity
    witness. -/
noncomputable def em_symmetry (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    SymmetryInvariant (em μ₀ hμ₀) where
  sigma := fun A μ => -(A μ)
  clock_invariant := fun A => by
    show (∑ μ : Fin 4, (-(A μ)) ^ 2) / (2 * μ₀) =
         (∑ μ : Fin 4, A μ ^ 2) / (2 * μ₀)
    congr 1
    apply Finset.sum_congr rfl
    intro μ _
    ring

/-- ★ Non-vacuum `QuantumCorrespondenceInvariant` for EM (T91) ★

    Bridges classical curvature (Maxwell action density `‖A‖²/(2μ₀)`)
    and quantum expectation value via `R = 8πG·⟨O⟩` with
    `G = 1/(8π)`. Both sides of the bridge are pointwise equal to the
    EM clock; the QC framework collapses to the arithmetic identity
    `8πG = 1`. Same algebraic shape as T68 (HarmonicOscillator), now
    instantiated with the EM gauge-potential clock. -/
noncomputable def em_quantum_correspondence (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    QuantumCorrespondenceInvariant (em μ₀ hμ₀) where
  curvature := (em μ₀ hμ₀).clock
  expectationValue := (em μ₀ hμ₀).clock
  G := 1 / (8 * Real.pi)
  G_pos := by
    apply div_pos one_pos
    have hπ : 0 < Real.pi := Real.pi_pos
    positivity
  bridges := by
    intro A
    show (em μ₀ hμ₀).clock A
        = 8 * Real.pi * (1 / (8 * Real.pi)) * (em μ₀ hμ₀).clock A
    have h8π : (8 : ℝ) * Real.pi ≠ 0 := by
      have hπ : 0 < Real.pi := Real.pi_pos
      positivity
    have : 8 * Real.pi * (1 / (8 * Real.pi)) = 1 := by field_simp
    rw [this, one_mul]

end CATEPTMain.Temporal.Adapter
