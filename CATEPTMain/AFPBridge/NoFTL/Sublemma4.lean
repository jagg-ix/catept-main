import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Sublemma4

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sublemma4
Theorem id: No_FTL_observers_Gen_Rel.Sublemma4.sublemma4#1
Theorem name: sublemma4
Lean tactic class: arithmetic_norm_num
-/

theorem sublemma4 (x : NoFTLObj) (f : NoFTLObj) (h1 : affineApprox A f x) : (∃ δ, δ > 0 ∧  ∀ p, (p within δ of x) → (definedAt f p)) ∧ (cts f x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Sublemma4
