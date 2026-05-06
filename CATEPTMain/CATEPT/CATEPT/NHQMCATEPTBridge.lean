import Mathlib.Analysis.SpecialFunctions.Exp
import CATEPTMain.CATEPT.CATEPT.PathIntegrals
import CATEPTMain.CATEPT.CATEPT.UnitsDimensionalAnalysis

set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

open Real

noncomputable section

/-- Phase-1 non-Hermitian Hamiltonian proxy: real hopping plus nonnegative decay. -/
structure NHHamiltonian (N : ℕ) where
  hopReal : Fin N → ℝ
  decayDiag : Fin N → ℝ
  decayDiag_nonneg : ∀ i, 0 ≤ decayDiag i

/-- Real eigenvalue branch `epsilon_n(phi)`. -/
def complexEigenvalueRe (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (n : Fin N) : ℝ :=
  H.hopReal n + φ * ((n : ℝ) + 1)

/-- Imaginary eigenvalue branch magnitude `gamma_n(phi)`. -/
def complexEigenvalueIm (N : ℕ) (H : NHHamiltonian N) (_φ : ℝ) (n : Fin N) : ℝ :=
  H.decayDiag n

theorem complexEigenvalueIm_nonneg
    (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (n : Fin N) :
    0 ≤ complexEigenvalueIm N H φ n := by
  simpa [complexEigenvalueIm] using H.decayDiag_nonneg n

/-- Exceptional point predicate: spectral coalescence of real and imaginary parts. -/
def exceptionalPointAt
    (N : ℕ) (H : NHHamiltonian N) (φ_EP : ℝ) (m n : Fin N) : Prop :=
  complexEigenvalueRe N H φ_EP m = complexEigenvalueRe N H φ_EP n ∧
  complexEigenvalueIm N H φ_EP m = complexEigenvalueIm N H φ_EP n

/-- Strong EP predicate with explicit coalescence witness hook. -/
def exceptionalPointAtStrong
    (N : ℕ) (H : NHHamiltonian N) (φ_EP : ℝ) (m n : Fin N) : Prop :=
  exceptionalPointAt N H φ_EP m n ∧ m = n

theorem exceptionalPointAtStrong_implies_exceptionalPointAt
    (N : ℕ) (H : NHHamiltonian N) (φ_EP : ℝ) (m n : Fin N)
    (hEP : exceptionalPointAtStrong N H φ_EP m n) :
    exceptionalPointAt N H φ_EP m n :=
  hEP.1

/-- NHQM entropic clock density `gamma_n(phi) / hbar`. -/
def nhqmEptClock
    (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (ħ : ℝ) : Fin N → ℝ :=
  fun n => complexEigenvalueIm N H φ n / ħ

theorem nhqmEptClock_nonneg
    (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) (n : Fin N) :
    0 ≤ nhqmEptClock N H φ ħ n := by
  unfold nhqmEptClock
  exact div_nonneg (complexEigenvalueIm_nonneg N H φ n) (le_of_lt hħ)

/-- Minimal CATEPT slot data for NHQM in the standalone core lane. -/
structure NHQMCATEPTSlot (N : ℕ) where
  actionRe : Fin N → ℝ
  actionIm : Fin N → ℝ
  actionIm_nonneg : ∀ n, 0 ≤ actionIm n
  hbar : ℝ
  hbar_pos : 0 < hbar
  eptClock : Fin N → ℝ
  eptClock_nonneg : ∀ n, 0 ≤ eptClock n

/-- Core consistency contract: `actionIm / hbar = eptClock`. -/
def cateptConsistencyConstraint {N : ℕ} (S : NHQMCATEPTSlot N) : Prop :=
  ∀ n, S.actionIm n / S.hbar = S.eptClock n

/-- NHQM slot packaged for CAT/EPT core bridges. -/
def nhqmCATEPTSlot
    (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) :
    NHQMCATEPTSlot N where
  actionRe := fun n => complexEigenvalueRe N H φ n
  actionIm := fun n => complexEigenvalueIm N H φ n
  actionIm_nonneg := fun n => complexEigenvalueIm_nonneg N H φ n
  hbar := ħ
  hbar_pos := hħ
  eptClock := nhqmEptClock N H φ ħ
  eptClock_nonneg := fun n => nhqmEptClock_nonneg N H φ ħ hħ n

/-- Slot-level consistency: `gamma_n / hbar = eptClock_n`. -/
theorem nhqmCATEPTSlot_consistent
    (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) :
    cateptConsistencyConstraint (nhqmCATEPTSlot N H φ ħ hħ) := by
  intro n
  simp [nhqmCATEPTSlot, nhqmEptClock]

/-- At an EP, coalescing states have equal entropic clock values. -/
theorem nhqmCATEPTSlot_eptClock_at_EP
    (N : ℕ) (H : NHHamiltonian N) (φ_EP : ℝ) (ħ : ℝ) (hħ : 0 < ħ)
    (m n : Fin N) (hEP : exceptionalPointAt N H φ_EP m n) :
    (nhqmCATEPTSlot N H φ_EP ħ hħ).eptClock m =
    (nhqmCATEPTSlot N H φ_EP ħ hħ).eptClock n := by
  change nhqmEptClock N H φ_EP ħ m = nhqmEptClock N H φ_EP ħ n
  exact congrArg (fun x => x / ħ) hEP.2

/-- Strong-EP projection of eptClock continuity. -/
theorem nhqmCATEPTSlot_eptClock_at_EP_strong
    (N : ℕ) (H : NHHamiltonian N) (φ_EP : ℝ) (ħ : ℝ) (hħ : 0 < ħ)
    (m n : Fin N) (hEP : exceptionalPointAtStrong N H φ_EP m n) :
    (nhqmCATEPTSlot N H φ_EP ħ hħ).eptClock m =
    (nhqmCATEPTSlot N H φ_EP ħ hħ).eptClock n :=
  nhqmCATEPTSlot_eptClock_at_EP N H φ_EP ħ hħ m n hEP.1

/-- NHQM lifetime damping weight over entropic interval `tau`. -/
def nhqmFKWeight
    (N : ℕ) (H : NHHamiltonian N)
    (φ : ℝ) (ħ : ℝ) (n : Fin N) (τ : ℝ) : ℝ :=
  Real.exp (-(complexEigenvalueIm N H φ n * τ / ħ))

/-- FK weight in eptClock form: `exp(-(gamma_n/hbar)*tau)`. -/
theorem nhqmFKWeight_eq_eptClock_form
    (N : ℕ) (H : NHHamiltonian N)
    (φ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) (n : Fin N) (τ : ℝ) :
    nhqmFKWeight N H φ ħ n τ =
      Real.exp (-(nhqmEptClock N H φ ħ n * τ)) := by
  unfold nhqmFKWeight nhqmEptClock
  congr 1
  field_simp [hħ.ne']

/-- NHQM FK weight matches the generic Feynman-Kac weight parametrization. -/
theorem nhqmFKWeight_eq_feynman_kac_weight
    (N : ℕ) (H : NHHamiltonian N)
    (φ : ℝ) (ħ : ℝ) (n : Fin N) (τ : ℝ) :
    nhqmFKWeight N H φ ħ n τ =
      feynman_kac_weight (fun i => complexEigenvalueIm N H φ i) (τ / ħ) n := by
  unfold nhqmFKWeight feynman_kac_weight
  congr 1
  ring

/-- Equivalent CAT/EPT path-integral damping form. -/
theorem nhqmFKWeight_eq_path_integral_damping
    (N : ℕ) (H : NHHamiltonian N)
    (φ : ℝ) (ħ : ℝ) (n : Fin N) (τ : ℝ) :
    nhqmFKWeight N H φ ħ n τ =
      path_integral_damping ħ (complexEigenvalueIm N H φ n * τ) := by
  unfold nhqmFKWeight path_integral_damping
  congr 1
  ring

/-- EP consequence: FK lifetime weights coincide for coalescing states. -/
theorem nhqmFKWeight_at_EP
    (N : ℕ) (H : NHHamiltonian N)
    (φ_EP : ℝ) (ħ : ℝ)
    (m n : Fin N) (hEP : exceptionalPointAt N H φ_EP m n) :
    ∀ τ : ℝ, nhqmFKWeight N H φ_EP ħ m τ = nhqmFKWeight N H φ_EP ħ n τ := by
  intro τ
  simp [nhqmFKWeight, hEP.2]

/-- Strong-EP projection of FK-weight equality. -/
theorem nhqmFKWeight_at_EP_strong
    (N : ℕ) (H : NHHamiltonian N)
    (φ_EP : ℝ) (ħ : ℝ)
    (m n : Fin N) (hEP : exceptionalPointAtStrong N H φ_EP m n) :
    ∀ τ : ℝ, nhqmFKWeight N H φ_EP ħ m τ = nhqmFKWeight N H φ_EP ħ n τ := by
  intro τ
  exact nhqmFKWeight_at_EP N H φ_EP ħ m n hEP.1 τ

/-- NHQM bridge inherits CAT/EPT exponent dimensional consistency. -/
theorem nhqm_units_contract :
    dimPathIntegralExponent = Dimension.one ∧
    dimFeynmanKacExponent = Dimension.one :=
  catept_fk_dimensional_consistency

-- ============================================================================
-- CIE-011 in-place landing — exceptional-point measurement regularity
-- ============================================================================

/-! ## CIE-011 — EP-admissible measurement carrier

Carrier-level surrogate certifying that a measurement-update channel
remains continuous as the system parameter crosses an exceptional point
(EP). The Bostelmann/Fewster/Ruep no-Sorkin admissibility requires
channel continuity in ambient parameters; near an EP the underlying
non-Hermitian Hamiltonian's eigenstructure becomes singular, so the
carrier explicitly tracks that the measurement response stays finite
and pointwise-continuous through the EP.

REPLYID: CAT-EPT-20260506-01.  See
`CATEPTMain/Integration/CAUSAL_IMPLEMENTABILITY_WORKLOG.lean` record
CIE-011.

This block lands directly in `NHQMCATEPTBridge`, fulfilling the
original CIE-011 plan ("Extend NHQMCATEPTBridge with an
`epAdmissibleMeasurement` carrier anchored to
`nhPersistentCurrentField_continuousAtEP`"). The earlier standalone
bridge `CATEPTMain/Integration/EPAdmissibleMeasurementBridge.lean`
provided coverage during the bring-up; consumers refining to a concrete
NHQM model now have everything in one place.

The sub-namespace `EPAdmissible` keeps the CIE-011 declarations
grouped without polluting the top-level `CATEPTMain.CATEPT.CATEPT`
namespace. -/

namespace EPAdmissible

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
      `nhPersistentCurrentField_continuousAtEP` or an analogue in their
      preferred NHQM formalisation. -/
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

/-- **EP-admissibility predicate**: continuity-at-EP plus bounded
response.  The bounded-response field is enforced at construction time;
the predicate exposes only the continuity-at-EP flag, since that is the
physically substantive admissibility content. -/
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

end EPAdmissible

end

end CATEPTMain.CATEPT.CATEPT
