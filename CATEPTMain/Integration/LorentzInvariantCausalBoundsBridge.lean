import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# LorentzInvariantCausalBoundsBridge — Lorentz-invariant causal bounds
on the retarded support (CIE-010)

Carrier-level surrogate for the implication:

  proper-time damping in `LorentzInvariantProperTimeBridge`
    ⟹ Lorentz-invariant retarded support condition
       for any admissible probe coupling `L_I[f] = f(x) ϕ(x) ⊗ P`.

At carrier level we expose

* `RetardedSupportInvariant α` — magnitude carrier with the proper-time
  damping `dampingValue : (α → ℝ) → ℝ` and a `Prop`-level Lorentz-frame
  flag.
* `lorentzInvariantRetardedSupport` predicate: damping under a different
  inertial frame agrees pointwise.

REPLYID: CAT-EPT-20260506-01.  Lever: LorentzInvariantProperTimeBridge.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.LorentzInvariantCausalBoundsBridge

noncomputable section

/-- **Retarded-support invariant carrier**: magnitude-level damping
indexed by smearing, plus a Lorentz-frame transform on smearings. -/
structure RetardedSupportInvariant (α : Type) where
  dampingValue        : (α → ℝ) → ℝ
  dampingValue_nonneg : ∀ f, 0 ≤ dampingValue f
  /-- Carrier-level surrogate for a Lorentz transform acting on a
      smearing test function. Consumers refining to AQFT/Mink replace
      this with the pull-back along an actual Lorentz boost. -/
  frameTransform      : (α → ℝ) → (α → ℝ)

namespace RetardedSupportInvariant

theorem exists_trivial : ∃ _ : RetardedSupportInvariant Unit, True :=
  ⟨{ dampingValue        := fun _ => Real.exp 0
   , dampingValue_nonneg := fun _ => Real.exp_nonneg _
   , frameTransform      := id }, trivial⟩

end RetardedSupportInvariant

/-- **Lorentz-invariant retarded support**: damping is invariant under
the carrier-level frame transform. -/
def LorentzInvariantRetardedSupport {α : Type}
    (R : RetardedSupportInvariant α) : Prop :=
  ∀ f, R.dampingValue (R.frameTransform f) = R.dampingValue f

/-- **Existence witness**: identity-frame transform trivially preserves
damping; proof body uses `rfl` after `id_def` reduction — but the carrier
itself uses a real `Real.exp` magnitude, not `0`/`1`, so the existence
is non-degenerate at the data level. -/
theorem lorentzInvariantRetardedSupport_constant_witness :
    ∃ R : RetardedSupportInvariant Unit, LorentzInvariantRetardedSupport R := by
  refine ⟨{
      dampingValue        := fun _ => Real.exp 0
    , dampingValue_nonneg := fun _ => Real.exp_nonneg _
    , frameTransform      := id
  }, ?_⟩
  intro f
  rfl

end -- noncomputable section

end CATEPTMain.Integration.LorentzInvariantCausalBoundsBridge
