import CATEPTMain.Integration.KrausEntropicDampingBridge
import Mathlib.Tactic.Linarith

/-!
# ResponseTemplatePointerBridge — pointer-probe carrier (CIE-012)

Carrier-level surrogate for the von Neumann interaction

  `L_I[f] = f(x) ϕ(x) ⊗ P`

(where `f` is the smearing, `ϕ(x)` is the field operator, and `P` is
the pointer-probe momentum) and its induced Kraus family on the system
side. At carrier level, we expose a magnitude-valued
`PointerProbeCarrier` and a wiring lemma to `FactorisedKraus`.

REPLYID: CAT-EPT-20260506-01.  Depends on CIE-007.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.ResponseTemplatePointerBridge

open CATEPTMain.Integration.KrausEntropicDampingBridge

noncomputable section

/-- **Pointer-probe carrier**: magnitude-level surrogate for the von
Neumann pointer-probe interaction. Stores the smearing-indexed
response template `responseTemplate : (α → ℝ) → ℝ` and the pointer
momentum scale `pointerScale`. -/
structure PointerProbeCarrier (α : Type) where
  responseTemplate          : (α → ℝ) → ℝ
  responseTemplate_nonneg   : ∀ f, 0 ≤ responseTemplate f
  pointerScale              : ℝ
  pointerScale_pos          : 0 < pointerScale

namespace PointerProbeCarrier

theorem exists_trivial : ∃ _ : PointerProbeCarrier Unit, True :=
  ⟨{ responseTemplate         := fun _ => 1
   , responseTemplate_nonneg  := fun _ => by norm_num
   , pointerScale             := 1
   , pointerScale_pos         := by norm_num }, trivial⟩

end PointerProbeCarrier

/-- **Wiring** to the CIE-007 factorised-Kraus carrier:
the pointer-probe response equals the Kraus squared-norm. -/
def WiredToKraus {α : Type}
    (P : PointerProbeCarrier α) (K : FactorisedKraus α) : Prop :=
  ∀ f, P.responseTemplate f = K.normSq f

/-- **Existence witness**: constant-1 response wires to the constant-1
Kraus carrier. -/
theorem pointerProbe_kraus_witness :
    ∃ P : PointerProbeCarrier Unit, ∃ K : FactorisedKraus Unit,
      WiredToKraus P K := by
  refine ⟨{
      responseTemplate         := fun _ => 1
    , responseTemplate_nonneg  := fun _ => by norm_num
    , pointerScale             := 1
    , pointerScale_pos         := by norm_num
  }, {
      normSq         := fun _ => 1
    , normSq_nonneg  := fun _ => by norm_num
    , S_I            := fun _ => 0
    , S_I_nonneg     := fun _ => le_refl 0
    , hbar           := 1
    , hbar_pos       := by norm_num
  }, ?_⟩
  intro f
  rfl

end -- noncomputable section

end CATEPTMain.Integration.ResponseTemplatePointerBridge
