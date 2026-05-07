import CATEPTMain.Integration.CausalImplementabilitySMatrixBridge
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

set_option autoImplicit false

/-!
# Schwinger–Keldysh / Influence-Functional Bridge for CAT/EPT

Records the doubled-history influence-functional layer for open-system
CAT/EPT, with a non-negative imaginary influence action that supplies
entropic damping of off-diagonal histories.

## Module history

The original file (PR #112) used the Lean 3 `constant` keyword to declare
opaque `FieldHistory : Type` and `RealAction : FieldHistory → ℝ` symbols.
Lean 4 dropped that keyword (the closest replacements `opaque`/`axiom`
both either require a body or are forbidden by the project's no-`axiom`
rule).  The 2026-05-06 fix replaces those declarations with a
`(α : Type)` type parameter on `InfluenceAction` (and a `RealAction : α
→ ℝ` field), matching the carrier-level pattern used throughout the
CAT-EPT-20260506-01 causality bridges (`LocalSmatrix α`,
`CauchySplit α`, `RetardedSharpnessCarrier α`, etc.).  No prior consumer
of these symbols existed at the time of the fix.

## CIE-006 in-place landing (REPLYID CAT-EPT-20260506-01)

The carrier `IFCauchyAdditive`, the Hammerstein-weakened analogue
`IFHammersteinCorrection`, and the trivial-existence witness
`ifCauchyAdditive_zero_witness` land directly in this module, replacing
the temporary standalone bridge `IFInfluenceFunctionalCauchyAdditiveBridge`.
See `CAUSAL_IMPLEMENTABILITY_WORKLOG.lean` record CIE-006.
-/

namespace CATEPTMain.Integration.SchwingerKeldyshInfluenceFunctionalBridge

open CATEPTMain.Integration.CausalImplementabilitySMatrixBridge

noncomputable section

/-- **Schwinger–Keldysh influence action** parameterised over the
field/history type `α` (carrier-level surrogate for the closed-time-path
field configuration space).

* `RealAction` — Hermitian real action on a single history.
* `SIF_R` — real part of the influence action (doubled history).
* `SIF_I` — imaginary part of the influence action; non-negative.
-/
structure InfluenceAction (α : Type) where
  RealAction      : α → ℝ
  SIF_R           : α → α → ℝ
  SIF_I           : α → α → ℝ
  nonnegative_I   : ∀ φp φm, 0 ≤ SIF_I φp φm

namespace InfluenceAction

/-- Trivial existence: zero influence action on `Unit` histories. -/
theorem exists_trivial : ∃ _ : InfluenceAction Unit, True :=
  ⟨{ RealAction      := fun _ => 0
   , SIF_R           := fun _ _ => 0
   , SIF_I           := fun _ _ => 0
   , nonnegative_I   := fun _ _ => le_refl 0 }, trivial⟩

end InfluenceAction

/-- Entropic proper time on doubled histories. -/
def tauEntSK {α : Type} (IF : InfluenceAction α) (hbar : ℝ) (φp φm : α) : ℝ :=
  IF.SIF_I φp φm / hbar

/-- Schwinger–Keldysh real-phase exponent (without `i`). -/
def skRealPhase {α : Type} (IF : InfluenceAction α) (hbar : ℝ)
    (φp φm : α) : ℝ :=
  (IF.RealAction φp - IF.RealAction φm + IF.SIF_R φp φm) / hbar

/-- Entropic damping factor for doubled histories. -/
def skDamping {α : Type} (IF : InfluenceAction α) (hbar : ℝ)
    (φp φm : α) : ℝ :=
  Real.exp (-(tauEntSK IF hbar φp φm))

/-- Damping is contractive for positive imaginary influence action. -/
theorem skDamping_le_one {α : Type}
    (IF : InfluenceAction α) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (φp φm : α) :
    skDamping IF hbar φp φm ≤ 1 := by
  unfold skDamping tauEntSK
  have hnonneg : 0 ≤ IF.SIF_I φp φm / hbar :=
    div_nonneg (IF.nonnegative_I φp φm) (le_of_lt hbar_pos)
  have hneg : -(IF.SIF_I φp φm / hbar) ≤ 0 := by linarith
  exact (Real.exp_le_one_iff).mpr hneg

/-- Diagonal histories have zero imaginary influence (structural hypothesis). -/
structure DiagonalInfluenceVanishing {α : Type} (IF : InfluenceAction α) : Prop where
  diag_zero : ∀ φ, IF.SIF_I φ φ = 0

/-- Off-diagonal suppression: if `SIF_I ≥ 0` and the diagonal vanishes,
    damping is `1` on diagonal histories. -/
theorem skDamping_diag_eq_one {α : Type}
    (IF : InfluenceAction α) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (H : DiagonalInfluenceVanishing IF) (φ : α) :
    skDamping IF hbar φ φ = 1 := by
  unfold skDamping tauEntSK
  rw [H.diag_zero φ]
  simp [hbar_pos.ne']

-- ============================================================================
-- CIE-006 in-place landing — IF Cauchy-additivity factorisation
-- ============================================================================

/-! ## CIE-006 — IF Cauchy-additivity factorisation

Carrier-level surrogate for the relativistic admissibility constraint
on the SK influence functional:

  `S_IF^I[f_+ + f_-] = S_IF^I[f_+] + S_IF^I[f_-]`

on every spacelike Cauchy split, plus a channel-level Hammerstein
analogue (additive correction).

REPLYID: CAT-EPT-20260506-01.  See
[`CAUSAL_IMPLEMENTABILITY_WORKLOG.lean`](./CAUSAL_IMPLEMENTABILITY_WORKLOG.lean)
record CIE-006 for the broader plan and leverage map.

This block lands directly in `SchwingerKeldyshInfluenceFunctionalBridge`,
fulfilling the original CIE-006 plan ("extend
SchwingerKeldyshInfluenceFunctionalBridge with `IFCauchyAdditive` and a
witness type linking to `LocalSmatrix`").  The temporary standalone
bridge `CATEPTMain/Integration/IFInfluenceFunctionalCauchyAdditiveBridge.lean`
provided coverage while this upstream module's pre-existing build error
was being resolved.

The `α : Type` parameter is the smearing index used by `LocalSmatrix`
and `CauchySplit`; consumers connect their influence functional to a
local S-matrix at the same `α`. -/

/-- **Influence functional** at carrier level: `S_IF^I` as a real-valued
functional of a smearing test function. -/
structure InfluenceFunctional (α : Type) where
  SI : (α → ℝ) → ℝ

namespace InfluenceFunctional

theorem exists_trivial : ∃ _ : InfluenceFunctional Unit, True :=
  ⟨{ SI := fun _ => 0 }, trivial⟩

end InfluenceFunctional

/-- **IF Cauchy-additivity** predicate: across every spacelike Cauchy
split, the imaginary action splits additively.  External `def`, not a
field of `InfluenceFunctional`, so consumers must derive the additive
identity from their concrete `SI`. -/
def IFCauchyAdditive {α : Type}
    (IF : InfluenceFunctional α) : Prop :=
  ∀ (split : CauchySplit α),
    split.futureSupport → split.pastSupport →
      IF.SI split.f = IF.SI split.f_plus + IF.SI split.f_minus

/-- **Hammerstein channel correction** — weakened additivity. -/
structure IFHammersteinCorrection {α : Type}
    (IF : InfluenceFunctional α) where
  delta                    : CauchySplit α → ℝ
  additive_with_correction :
    ∀ (split : CauchySplit α),
      split.futureSupport → split.pastSupport →
        IF.SI split.f = IF.SI split.f_plus + IF.SI split.f_minus + delta split

/-- **Existence witness**: the zero influence functional is
Cauchy-additive.  Proof body discharges the additive identity via
`ring`. -/
theorem ifCauchyAdditive_zero_witness :
    ∃ IF : InfluenceFunctional Unit, IFCauchyAdditive IF := by
  refine ⟨{ SI := fun _ => 0 }, ?_⟩
  intro split _ _
  show (0 : ℝ) = 0 + 0
  ring

end -- noncomputable section

end CATEPTMain.Integration.SchwingerKeldyshInfluenceFunctionalBridge
