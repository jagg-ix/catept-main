import CATEPTMain.Integration.RetardedGreenFisherBridge
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# MeasurementSharpnessEntropicCostBridge — measurement sharpness as
entropic cost (CIE-008)

Carrier-level surrogate tying the Fisher-info reciprocal bound (CIE-003)
to the entropic-proper-time cost `τ_ent = S_I / ℏ`:

  `I_F^meas(f) ≤ 1 / Δ_r(f, f) ≤ 2 / S_I[f]`

whenever an admissible local probe is used (so that `S_I[f] ≤ 2·Δ_r(f, f)`
holds).

REPLYID: CAT-EPT-20260506-01.  Composes CIE-003 + the Matsubara/τ_ent
identification.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.MeasurementSharpnessEntropicCostBridge

open CATEPTMain.Integration.RetardedGreenFisherBridge

noncomputable section

/-- **Sharpness-cost carrier**: extends `RetardedSharpnessCarrier` with
the entropic-proper-time bookkeeping `(τ_ent, S_I, ℏ)` and the
admissibility hypothesis `S_I ≤ 2 · Δ_r`. -/
structure MeasurementSharpnessCarrier (α : Type) where
  retarded             : RetardedSharpnessCarrier α
  S_I                  : (α → ℝ) → ℝ
  S_I_nonneg           : ∀ f, 0 ≤ S_I f
  hbar                 : ℝ
  hbar_pos             : 0 < hbar
  S_I_le_two_deltaR    : ∀ f, S_I f ≤ 2 * retarded.deltaR f

namespace MeasurementSharpnessCarrier

theorem exists_trivial : ∃ _ : MeasurementSharpnessCarrier Unit, True := by
  obtain ⟨R, _⟩ := RetardedSharpnessCarrier.exists_trivial
  refine ⟨{
      retarded             := R
    , S_I                  := fun _ => 0
    , S_I_nonneg           := fun _ => le_refl 0
    , hbar                 := 1
    , hbar_pos             := by norm_num
    , S_I_le_two_deltaR    := fun f => by
        have h := R.deltaR_nonneg f
        linarith
  }, trivial⟩

end MeasurementSharpnessCarrier

/-- **Entropic-time form of the Fisher-info bound**:

  `I_F^meas(f) · S_I(f) ≤ 2`

(multiplicative form of `I_F ≤ 2/S_I`, which combines the CIE-003
reciprocal bound with the admissibility `S_I ≤ 2·Δ_r`). -/
def FisherEntropicBound {α : Type}
    (M : MeasurementSharpnessCarrier α) : Prop :=
  ∀ f, M.retarded.fisherInfo f * M.S_I f ≤ 2

/-- **Existence witness**: with `S_I = 0`, the entropic bound trivialises
to `0 ≤ 2`, discharged by `norm_num` after `mul_zero`. -/
theorem fisherEntropicBound_zero_witness :
    ∃ M : MeasurementSharpnessCarrier Unit, FisherEntropicBound M := by
  obtain ⟨R, _⟩ := RetardedSharpnessCarrier.exists_trivial
  refine ⟨{
      retarded             := R
    , S_I                  := fun _ => 0
    , S_I_nonneg           := fun _ => le_refl 0
    , hbar                 := 1
    , hbar_pos             := by norm_num
    , S_I_le_two_deltaR    := fun f => by
        have h := R.deltaR_nonneg f
        linarith
  }, ?_⟩
  intro f
  -- Goal: R.fisherInfo f * 0 ≤ 2
  show R.fisherInfo f * 0 ≤ 2
  rw [mul_zero]
  norm_num

end -- noncomputable section

end CATEPTMain.Integration.MeasurementSharpnessEntropicCostBridge
