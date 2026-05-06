import CATEPTMain.Integration.CausalImplementabilitySMatrixBridge
import Mathlib.Tactic.Ring

/-!
# IFInfluenceFunctionalCauchyAdditiveBridge — SK influence functional
factorisation across spacelike Cauchy cuts (CIE-006)

Carrier-level surrogate for the Schwinger–Keldysh influence-functional
analogue of `ContinuousAdditive`:

  `S_IF^I[f_+ + f_-] = S_IF^I[f_+] + S_IF^I[f_-]`

on every spacelike Cauchy split, plus a channel-level Hammerstein
analogue (additive correction).

This module is structured as a **standalone bridge** rather than as an
extension of `CATEPTMain/Integration/SchwingerKeldyshInfluenceFunctionalBridge.lean`
because the latter currently has a self-contained build issue
(`Unknown identifier FieldHistory`) on this branch. The carrier here
exposes the same shape (`SI` magnitude functional + Cauchy-split
predicate) so a downstream consumer can wire either bridge into
`LocalSmatrix` once the upstream module builds.

REPLYID: CAT-EPT-20260506-01.  Companion to CIE-002.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.IFInfluenceFunctionalCauchyAdditiveBridge

open CATEPTMain.Integration.CausalImplementabilitySMatrixBridge

noncomputable section

/-- **Influence-functional carrier**: the imaginary part `S_IF^I` of the
SK influence action, indexed by closed-time-path field configurations
(at carrier level, smearing test functions on type `α`). -/
structure InfluenceFunctional (α : Type) where
  SI : (α → ℝ) → ℝ

namespace InfluenceFunctional

theorem exists_trivial : ∃ _ : InfluenceFunctional Unit, True :=
  ⟨{ SI := fun _ => 0 }, trivial⟩

end InfluenceFunctional

/-- **IF Cauchy-additivity** predicate: across every spacelike Cauchy
split, the imaginary action splits additively. -/
def IFCauchyAdditive {α : Type}
    (IF : InfluenceFunctional α) : Prop :=
  ∀ (split : CauchySplit α),
    split.futureSupport → split.pastSupport →
      IF.SI split.f = IF.SI split.f_plus + IF.SI split.f_minus

/-- **Hammerstein channel correction** (weakened additivity). -/
structure IFHammersteinCorrection {α : Type}
    (IF : InfluenceFunctional α) where
  delta                : CauchySplit α → ℝ
  additive_with_correction :
    ∀ (split : CauchySplit α),
      split.futureSupport → split.pastSupport →
        IF.SI split.f = IF.SI split.f_plus + IF.SI split.f_minus + delta split

/-- **Existence witness**: the zero influence functional is
Cauchy-additive (and trivially Hammerstein-corrected with `δ = 0`).
The proof body discharges the additive identity via `ring`. -/
theorem ifCauchyAdditive_zero_witness :
    ∃ IF : InfluenceFunctional Unit, IFCauchyAdditive IF := by
  refine ⟨{ SI := fun _ => 0 }, ?_⟩
  intro split _ _
  show (0 : ℝ) = 0 + 0
  ring

end -- noncomputable section

end CATEPTMain.Integration.IFInfluenceFunctionalCauchyAdditiveBridge
