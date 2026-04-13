import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.ObserverConeLemma

/-!
Auto-generated theorem-indexed pilot file.
Theory: ObserverConeLemma
Theorem id: No_FTL_observers_Gen_Rel.ObserverConeLemma.lemConeOfObserved#1
Theorem name: lemConeOfObserved
Lean tactic class: arithmetic_norm_num
-/

theorem lemConeOfObserved (coneSet : NoFTLObj → NoFTLObj → NoFTLSet) (k : NoFTLObj) (A : NoFTLObj) (x : NoFTLObj) (h1 : affineApprox A (wvtFunc m k) x) (h2 : m sees k at x) : coneSet k (A x) = regularConeSet (A x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.ObserverConeLemma
