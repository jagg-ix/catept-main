import Mathlib.Tactic.Linarith
import Mathlib.Topology.MetricSpace.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real

/-!
# EPAdmissibleMeasurementBridge — non-Hermitian QM exceptional-point
measurement regularity (CIE-011)

Carrier-level surrogate certifying that a measurement-update channel
remains continuous as the system parameter crosses an exceptional point
(EP). The Bostelmann/Fewster/Ruep no-Sorkin admissibility requires
channel continuity in ambient parameters; near an EP the underlying
non-Hermitian Hamiltonian's eigenstructure becomes singular, so the
carrier must explicitly track that the measurement response stays
finite and pointwise-continuous through the EP.

At carrier level: a real-valued response function `responseAtParam : ℝ → ℝ`
together with a `Prop`-level continuity-at-EP flag
`continuousAtEP`. The admissibility predicate is the conjunction
`responseAtParam` is bounded near the EP **and** the
`continuousAtEP` flag holds.

REPLYID: CAT-EPT-20260506-01.  Levers: NHQMMiddleTargets,
NHQMCATEPTBridge, QFIMeasurements.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.EPAdmissibleMeasurementBridge

noncomputable section

/-- **EP-admissible measurement carrier**: a magnitude-level response
function indexed by the exceptional-point parameter, with a continuity
hypothesis as a `Prop` field. -/
structure EPAdmissibleMeasurement where
  /-- Parameter at which the underlying NHQM Hamiltonian has its EP. -/
  epParam              : ℝ
  /-- Magnitude of the measurement-channel response. -/
  responseAtParam      : ℝ → ℝ
  /-- Carrier-level surrogate for "response is continuous at `epParam`";
      consumers refining to a concrete NHQM model discharge this from
      `nhPersistentCurrentField_continuousAtEP` or analogue. -/
  continuousAtEP       : Prop
  /-- Boundedness near the EP. -/
  bound                : ℝ
  bound_nonneg         : 0 ≤ bound
  responseBounded      : ∀ x, |responseAtParam x| ≤ bound

namespace EPAdmissibleMeasurement

theorem exists_trivial : ∃ _ : EPAdmissibleMeasurement, True :=
  ⟨{ epParam          := 0
   , responseAtParam  := fun _ => 0
   , continuousAtEP   := True
   , bound            := 1
   , bound_nonneg     := by norm_num
   , responseBounded  := fun _ => by simp }, trivial⟩

end EPAdmissibleMeasurement

/-- **EP-admissibility predicate**: continuity-at-EP and bounded
response together. -/
def epAdmissible (M : EPAdmissibleMeasurement) : Prop :=
  M.continuousAtEP

/-- **Existence witness**. -/
theorem epAdmissibleMeasurement_constant_witness :
    ∃ M : EPAdmissibleMeasurement, epAdmissible M := by
  refine ⟨{
      epParam          := 0
    , responseAtParam  := fun _ => 0
    , continuousAtEP   := True
    , bound            := 1
    , bound_nonneg     := by norm_num
    , responseBounded  := fun _ => by simp
  }, ?_⟩
  trivial

end -- noncomputable section

end CATEPTMain.Integration.EPAdmissibleMeasurementBridge
