import CATEPTMain.Integration.CausalImplementabilitySMatrixBridge
import Mathlib.Tactic.Linarith

/-!
# QuantumInertialFramesLocalityBridge — QIF-locality axiom (CIE-004)

Carrier-level surrogate for the slice-independence claim that a
quantum-inertial-frame (QIF) transformation `U_QIF(Σ_1 → Σ_2)`
preserves the continuous-additivity factorisation of any admissible
local S-matrix:

  `S[f_+^{Σ_1}] · S[f_-^{Σ_1}] ≃ S[f_+^{Σ_2}] · S[f_-^{Σ_2}]`

Carrier-level encoding: a `QIFSliceTransform` parameterises a pair of
Cauchy splits of the same smearing, and a predicate
`qifPreservesFactorisation` asserts the two factorised products agree.

REPLYID: CAT-EPT-20260506-01.  Depends on CIE-002.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.QuantumInertialFramesLocalityBridge

open CATEPTMain.Integration.CausalImplementabilitySMatrixBridge

noncomputable section

/-- **QIF slice transform** carrier: two spacelike Cauchy splits of the
same smearing function (one per inertial frame). The shared smearing
ensures `Σ_1` and `Σ_2` are slicing the *same* test function. -/
structure QIFSliceTransform (α : Type) where
  split1     : CauchySplit α
  split2     : CauchySplit α
  shared_f   : split1.f = split2.f

namespace QIFSliceTransform

theorem exists_trivial : ∃ _ : QIFSliceTransform Unit, True := by
  obtain ⟨split, _⟩ := CauchySplit.exists_trivial
  exact ⟨{ split1 := split, split2 := split, shared_f := rfl }, trivial⟩

end QIFSliceTransform

/-- **QIF locality predicate**: the continuous-additivity factorisation
of `S` agrees across the two slices. -/
def qifPreservesFactorisation
    {α : Type} (S : LocalSmatrix α) (T : QIFSliceTransform α) : Prop :=
  S.value T.split1.f_plus * S.value T.split1.f_minus
    = S.value T.split2.f_plus * S.value T.split2.f_minus

/-- **Existence witness**: the constant-`1` S-matrix is QIF-invariant. -/
theorem qifPreservesFactorisation_constant_witness :
    ∃ S : LocalSmatrix Unit, ∃ T : QIFSliceTransform Unit,
      qifPreservesFactorisation S T := by
  obtain ⟨T, _⟩ := QIFSliceTransform.exists_trivial
  refine ⟨{ value := fun _ => 1, supportInRegion := fun _ => True }, T, ?_⟩
  show (1 : ℝ) * 1 = 1 * 1
  ring

end -- noncomputable section

end CATEPTMain.Integration.QuantumInertialFramesLocalityBridge
