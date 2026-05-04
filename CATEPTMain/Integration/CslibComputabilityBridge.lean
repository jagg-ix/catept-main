import CATEPTPluginCslib.IntegrationBridge

/-!
# CslibComputabilityBridge — B5: Cslib computability witness activator
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.CslibComputabilityBridge

open CATEPTPluginCslib

/-- **Cslib foundations package**: URM + automata + Ramsey hold
simultaneously when the Cslib witness is provided. -/
theorem cslib_foundations_package
    (w : CslibWitness)
    (hURM : w.urmModelAvailable) (hAuto : w.automataModelAvailable)
    (hRamsey : w.ramseyAvailable) :
    w.urmModelAvailable ∧ w.automataModelAvailable ∧ w.ramseyAvailable :=
  ⟨hURM, hAuto, hRamsey⟩

theorem witness_exists_trivial : ∃ w : CslibWitness,
    w.urmModelAvailable ∧ w.automataModelAvailable := by
  refine ⟨{ urmModelAvailable := True
          , automataModelAvailable := True
          , ramseyAvailable := True }, ?_, ?_⟩
  all_goals trivial

/-! ## Concrete URM-program theorems re-exposed from the upgraded plugin -/

/-- **Identity URM program at any input** (proven in plugin). -/
theorem identityURMProgram_id_via_plugin (n : ℕ) :
    identityURMProgram n = n :=
  proved_identityURMProgram_id n

/-- **Identity URM program at zero** (proven in plugin). -/
theorem identityURMProgram_zero_via_plugin :
    identityURMProgram 0 = 0 :=
  proved_identityURMProgram_zero

/-- **Identity URM program is monotone** (proven in plugin). -/
theorem identityURMProgram_monotone_via_plugin {m n : ℕ} (h : m ≤ n) :
    identityURMProgram m ≤ identityURMProgram n :=
  proved_identityURMProgram_monotone h

end CATEPTMain.Integration.CslibComputabilityBridge

end
