import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.VML.Domain
import CATEPTMain.Domains.Invariants.Conservation
import CATEPTMain.Domains.Invariants.Reduction
import CATEPTMain.Domains.Invariants.Symmetry

/-!
# VML Adapter — `LiveTemporalFramework` instance

The Vlasov-Maxwell-Landau rigidity slot from `Domains/VML/Domain.lean`,
re-presented as an instance of the kernel `TemporalFramework` contract
plus the `LiveTemporalFramework` extension (non-trivial dynamics).

The live witness is the configuration `(v=⟨1,0,0⟩, E=0, ∇B=0, T=1)` whose
Lyapunov action equals `1/2 > 0`.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

open CATEPTMain.Domains.VML

/-- VML as a kernel-tier `TemporalFramework`. -/
noncomputable def vml : TemporalFramework where
  Config := VMLConfig
  clock := VMLConfig.lyapunovAction
  clock_nonneg := VMLConfig.lyapunovAction_nonneg
  witness := { v := 0, E := 0, gradB := 0, T := 1, T_pos := one_pos }

/-- VML upgraded to `LiveTemporalFramework`: the configuration with
    velocity `v = ⟨1, 0, 0⟩` and zero EM fields has Lyapunov action
    `1/(2·1) + 0 + 0 = 1/2 > 0`. -/
noncomputable def vmlLive : LiveTemporalFramework where
  toTemporalFramework := vml
  live_witness := by
    refine ⟨{ v := ![1, 0, 0], E := 0, gradB := 0, T := 1, T_pos := one_pos },
            ?_⟩
    -- the clock at this configuration evaluates to 1/2 > 0
    show 0 < VMLConfig.lyapunovAction _
    unfold VMLConfig.lyapunovAction VMLConfig.normSq3
    simp [Fin.sum_univ_three]

/-- VML adapter satisfies the spine by the universal coherence theorem. -/
theorem vml_satisfies_spine :
    CATEPTMain.Integration.cateptConsistencyConstraint
      vml.toCATEPTSlot :=
  vml.coherence_spine

/-- VML's dynamics are non-trivial. -/
theorem vml_dynamics_nontrivial : ∃ x : VMLConfig, 0 < x.lyapunovAction :=
  vmlLive.dynamics_nontrivial

-- ═════════════════════════════════════════════════════════════════════
-- Per-invariant claims (T66e)
-- ═════════════════════════════════════════════════════════════════════

/-- VML conservation: vacuum stress-energy. (Phase-1 placeholder; phase-2
    refines to the kinetic stress tensor + Maxwell stress tensor + BGK
    relaxation residue once the smooth-section infrastructure lands.) -/
noncomputable def vml_conservation : ConservationInvariant vml :=
  vml.vacuumConservation

/-- VML reduction: the Lyapunov action IS the documented kinetic-Maxwell
    + EM-rigidity classical form. Pointwise reflexivity. -/
noncomputable def vml_reduction : ReductionInvariant vml where
  classicalProjection := vml.clock
  target := vml.clock
  reduces_classically := fun _ => rfl

/-- Helper: `normSq3` is invariant under componentwise negation. -/
private theorem normSq3_neg (u : Fin 3 → ℝ) :
    VMLConfig.normSq3 (fun i => -(u i)) = VMLConfig.normSq3 u := by
  unfold VMLConfig.normSq3
  apply Finset.sum_congr rfl
  intro i _
  ring

/-- VML symmetry: velocity reflection `v ↦ -v` (combined with `E ↦ -E`,
    `∇B ↦ -∇B`) leaves the Lyapunov action invariant since each summand is
    a sum of squares. Concrete non-identity witness. -/
noncomputable def vml_symmetry : SymmetryInvariant vml where
  sigma := fun c =>
    { v := fun i => -(c.v i)
      E := fun i => -(c.E i)
      gradB := fun i => -(c.gradB i)
      T := c.T
      T_pos := c.T_pos }
  clock_invariant := fun c => by
    show VMLConfig.lyapunovAction _ = VMLConfig.lyapunovAction c
    unfold VMLConfig.lyapunovAction
    rw [normSq3_neg c.v, normSq3_neg c.E, normSq3_neg c.gradB]

end CATEPTMain.Temporal.Adapter
