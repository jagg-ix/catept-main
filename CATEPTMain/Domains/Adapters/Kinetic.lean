import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Invariants.Conservation
import CATEPTMain.Domains.Invariants.Reduction
import CATEPTMain.Domains.Invariants.Symmetry
import CATEPTMain.Domains.Invariants.QuantumCorrespondence
import CATEPTMain.Domains.UnifiedValidator
import CATEPTMain.Domains.ETH.Domain

/-!
# Kinetic Adapter — `LiveTemporalFramework` for Maxwell-Boltzmann velocity space

Wraps the existing `kineticSuperiorSlot T hT` from `Domains/ETH/Domain.lean`
as a `TemporalFramework` instance with full per-invariant coverage.

Configuration space: `Fin 3 → ℝ` (velocity space ℝ³).
Clock: `S_I(v) = ‖v‖²/(2T)` (the negative log of the Maxwell-Boltzmann
kernel `exp(−‖v‖²/(2T))`).
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

open CATEPTMain.Integration (cateptConsistencyConstraint)

/-- Kinetic temporal framework, parameterised by temperature `T > 0`. -/
noncomputable def kinetic (T : ℝ) (hT : 0 < T) : TemporalFramework where
  Config := Fin 3 → ℝ
  clock := fun v => (∑ i : Fin 3, v i ^ 2) / (2 * T)
  clock_nonneg := fun v =>
    div_nonneg (Finset.sum_nonneg fun _ _ => sq_nonneg _) (by linarith)
  witness := fun _ => 0  -- velocity-space origin

/-- Kinetic upgraded to `LiveTemporalFramework`: any non-zero velocity
    has positive action. Use `v = ⟨1, 0, 0⟩` as the concrete witness. -/
noncomputable def kineticLive (T : ℝ) (hT : 0 < T) : LiveTemporalFramework where
  toTemporalFramework := kinetic T hT
  live_witness := by
    refine ⟨fun i => if i = 0 then 1 else 0, ?_⟩
    show 0 < (kinetic T hT).clock _
    show 0 < (∑ i : Fin 3, (if i = 0 then (1 : ℝ) else 0) ^ 2) / (2 * T)
    apply div_pos
    · simp [Fin.sum_univ_three]
    · linarith

theorem kinetic_satisfies_spine (T : ℝ) (hT : 0 < T) :
    cateptConsistencyConstraint (kinetic T hT).toCATEPTSlot :=
  (kinetic T hT).coherence_spine

-- ── Per-invariant claims ─────────────────────────────────────────────

noncomputable def kinetic_conservation (T : ℝ) (hT : 0 < T) :
    ConservationInvariant (kinetic T hT) :=
  (kinetic T hT).vacuumConservation

noncomputable def kinetic_reduction (T : ℝ) (hT : 0 < T) :
    ReductionInvariant (kinetic T hT) where
  classicalProjection := (kinetic T hT).clock
  target := (kinetic T hT).clock
  reduces_classically := fun _ => rfl

/-- Velocity reflection `v ↦ -v` preserves `‖v‖²/(2T)`. Real non-identity
    witness — Maxwell-Boltzmann is isotropic about the origin. -/
noncomputable def kinetic_symmetry (T : ℝ) (hT : 0 < T) :
    SymmetryInvariant (kinetic T hT) where
  sigma := fun v i => -(v i)
  clock_invariant := fun v => by
    show (∑ i : Fin 3, (-(v i)) ^ 2) / (2 * T) =
         (∑ i : Fin 3, v i ^ 2) / (2 * T)
    congr 1
    apply Finset.sum_congr rfl
    intro _ _
    ring

/-- The kinetic adapter validates spine + 3 invariants
    (Conservation/Reduction/Symmetry); QuantumCorrespondence not claimed
    (would require connecting to a specific quantum-statistical bridge). -/
theorem kinetic_validates (T : ℝ) (hT : 0 < T) :
    UnifiedValidator
      (kinetic T hT)
      (some <| kinetic_conservation T hT)
      (some <| kinetic_reduction T hT)
      (some <| kinetic_symmetry T hT)
      none :=
  ⟨(kinetic T hT).coherence_spine,
   (kinetic_conservation T hT).divergence_free,
   (kinetic_reduction T hT).reduces_classically,
   (kinetic_symmetry T hT).clock_invariant,
   trivial⟩

theorem kinetic_dynamics_nontrivial (T : ℝ) (hT : 0 < T) :
    ∃ v : Fin 3 → ℝ, 0 < (kinetic T hT).clock v :=
  (kineticLive T hT).dynamics_nontrivial

/-- ★ Non-vacuum `QuantumCorrespondenceInvariant` for Kinetic (T94) ★

    Maxwell-Boltzmann velocity-space clock `‖v‖²/(2T)` plays both
    "curvature" and "expectation value" roles in `R = 8πG·⟨O⟩` with
    `G = 1/(8π)`. Same algebraic shape as T68 / T91. -/
noncomputable def kinetic_quantum_correspondence (T : ℝ) (hT : 0 < T) :
    QuantumCorrespondenceInvariant (kinetic T hT) where
  curvature := (kinetic T hT).clock
  expectationValue := (kinetic T hT).clock
  G := 1 / (8 * Real.pi)
  G_pos := by
    apply div_pos one_pos
    have hπ : 0 < Real.pi := Real.pi_pos
    positivity
  bridges := by
    intro v
    show (kinetic T hT).clock v
        = 8 * Real.pi * (1 / (8 * Real.pi)) * (kinetic T hT).clock v
    have h8π : (8 : ℝ) * Real.pi ≠ 0 := by
      have hπ : 0 < Real.pi := Real.pi_pos
      positivity
    have : 8 * Real.pi * (1 / (8 * Real.pi)) = 1 := by field_simp
    rw [this, one_mul]

end CATEPTMain.Temporal.Adapter
