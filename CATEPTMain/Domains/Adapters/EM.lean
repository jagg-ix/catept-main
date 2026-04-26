import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.GR.Domain

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

end CATEPTMain.Temporal.Adapter
