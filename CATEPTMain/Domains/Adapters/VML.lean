import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.VML.Domain

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

end CATEPTMain.Temporal.Adapter
