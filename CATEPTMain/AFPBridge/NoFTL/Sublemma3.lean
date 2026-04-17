import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Sublemma3

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sublemma3
Theorem id: No_FTL_observers_Gen_Rel.Sublemma3.sublemma3#1
Theorem name: sublemma3
Lean tactic class: arithmetic_norm_num
-/

theorem sublemma3 (origin : NoFTLObj) (wl : NoFTLSet) (p : NoFTLObj) (h1 : onLine p l) (h2 : norm2 p = 1) (h3 : tangentLine l wl origin) : ∀ ε, ε > 0 →  ∃ δ, δ > 0 ∧  ∀ y ny, ( ((y within δ of origin) ∧ (y ≠ origin) ∧ (y ∈ wl) ∧ (norm y = ny)) → ( (((1/ny) * y) within ε of p) ∨ (((-1/ny) * y) within ε of p)) ) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sublemma3
Theorem id: No_FTL_observers_Gen_Rel.Sublemma3.sublemma3Translation#1
Theorem name: sublemma3Translation
Lean tactic class: arithmetic_norm_num
-/

theorem sublemma3Translation (x : NoFTLObj) (wl : NoFTLSet) (p : NoFTLObj) (h1 : onLine p l) (h2 : norm2 (p - x) = 1) (h3 : tangentLine l wl x) : ∀ ε, ε > 0 →  ∃ δ, δ > 0 ∧  ∀ y nyx, ((y within δ of x) ∧ (y ≠ x) ∧ (y ∈ wl) ∧ (norm (y-x) = nyx)) → (((1/nyx)*(y-x)) within ε of (p-x)) ∨ (((-1/nyx)*(y-x)) within ε of (p-x)) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Sublemma3
