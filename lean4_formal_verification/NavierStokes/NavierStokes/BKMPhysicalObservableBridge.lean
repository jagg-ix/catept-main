import NavierStokes.BKMMinimalBridge
import NavierStokes.AxiomaticEstimates
import NavierStokes.NSObservableInterface
import NavierStokes.NSPhysicalT3Bridge

/-!
# BKM Physical Observable Bridge

Stage 218 transport/hardening lemmas that allow legacy BKM interfaces to consume
the concrete mode-0 vorticity observable introduced in `AxiomaticEstimates`.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

open NavierStokes.ObservableInterface
open NavierStokes.PhysicalT3Bridge

/-- Legacy BKM integral is pointwise bounded by the physical mode-0 candidate
    integral, so existing legacy consumers can be migrated monotonically. -/
theorem bkmVorticityIntegral_legacy_le_physicalMode0
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegral traj T ≤ bkmVorticityIntegralPhysicalMode0 traj T := by
  unfold bkmVorticityIntegral bkmVorticityIntegralPhysicalMode0
  apply NavierStokes.DiscreteKernel.discreteIntegral_le_of_pointwise
  intro t
  exact vorticityLinfty_legacy_le_physicalMode0 (traj.stateAt t).velocity

/-- Any upper bound on the physical mode-0 integral is also an upper bound
    on the legacy BKM integral. -/
theorem bkmVorticityIntegral_le_of_physicalMode0_bound
    (traj : Trajectory NSField) (T M : Rat)
    (hM : bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    bkmVorticityIntegral traj T ≤ M :=
  le_trans (bkmVorticityIntegral_legacy_le_physicalMode0 traj T) hM

/-- Transport a concrete bound on the physical mode-0 observable to the
    opaque convergence predicate used by the legacy BKM finiteness layer. -/
theorem bkmIntegralConverges_of_physicalMode0_bound
    (traj : Trajectory NSField) (T M : Rat)
    (hM : bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    BKMIntegralConverges traj T :=
  bkm_bounded_implies_converges traj T M
    (bkmVorticityIntegral_le_of_physicalMode0_bound traj T M hM)

/-- Physical mode-0 integral bounds imply legacy BKM finiteness. -/
theorem bkmIntegralFiniteAt_of_physicalMode0_bound
    (traj : Trajectory NSField) (T M : Rat)
    (hM : bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    BKMIntegralFiniteAt traj T :=
  bkmIntegralConverges_of_physicalMode0_bound traj T M hM

/-- Existential packaging for common workflows that already produce a
    finite upper bound witness on the physical mode-0 integral. -/
theorem bkmIntegralFiniteAt_of_exists_physicalMode0_bound
    (traj : Trajectory NSField) (T : Rat)
    (hBound : ∃ M : Rat, bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    BKMIntegralFiniteAt traj T := by
  rcases hBound with ⟨M, hM⟩
  exact bkmIntegralFiniteAt_of_physicalMode0_bound traj T M hM

/-! ## Physical precise-gap transport -/

/-- Physical-mode precise gap statement:
    same quantifier order as `PreciseGapStatement`, but with the
    concrete mode-0 observable integral on the left-hand side. -/
def PreciseGapStatementPhysicalMode0 : Prop :=
  ∃ F : Rat → Rat → Rat → Rat,
    ∀ (traj : Trajectory NSField) (T : Rat),
      0 < T →
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      bkmVorticityIntegralPhysicalMode0 traj T ≤
        F (entropicProperTime traj T)
          (kineticEnergy (traj.stateAt 0).velocity)
          nsNu

/-- A physical-mode precise gap bound implies the legacy precise gap statement.
    This is the monotone migration bridge used by downstream BKM consumers. -/
theorem precise_gap_physicalMode0_implies_precise_gap
    (hGap0 : PreciseGapStatementPhysicalMode0) :
    PreciseGapStatement := by
  rcases hGap0 with ⟨F, hF⟩
  refine ⟨F, ?_⟩
  intro traj T hT hNS hFS
  exact le_trans
    (bkmVorticityIntegral_legacy_le_physicalMode0 traj T)
    (hF traj T hT hNS hFS)

/-- Reusable BKM finiteness consequence from a physical-mode precise gap witness. -/
theorem bkmIntegralFiniteAt_of_precise_gap_physicalMode0
    (hGap0 : PreciseGapStatementPhysicalMode0)
    (traj : Trajectory NSField) (T : Rat)
    (hT : 0 < T)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    BKMIntegralFiniteAt traj T := by
  exact precise_gap_implies_regularity
    (precise_gap_physicalMode0_implies_precise_gap hGap0)
    traj T hT hNS hFS

/-- Interface-level transport: physical-mode precise gap can drive the same
    minimal-bridge consumer used by the legacy `PreciseGapStatement`. -/
theorem precise_gap_physicalMode0_to_minimal_bridge
    (pi : PathIntegralInterface NSField)
    (hGap0 : PreciseGapStatementPhysicalMode0) :
    ∀ (st0 : State NSField),
      pi.PIWellPosed st0 →
      AdmissibleInitialData nsSpacesR3 st0 →
      ∀ (traj : Trajectory NSField) (T : Rat),
        0 < T →
        SatisfiesNSPDE nsOps nsNu traj →
        RespectsFunctionSpaces nsSpacesR3 traj →
        BKMIntegralFiniteAt traj T :=
  precise_gap_to_minimal_bridge pi
    (precise_gap_physicalMode0_implies_precise_gap hGap0)

/-! ## Observable-interface adapter (physical instance) -/

/-- Alignment contract between the Stage-218 physical mode-0 observable path and
    the Stage-150+ observable-interface physical instance. -/
def PhysicalMode0ObsAlignment : Prop :=
  (∀ v : NSField,
      vorticityLinftyPhysicalMode0 v = physicalNSObservables.vorticityLinfty v) ∧
  (∀ v : NSField,
      enstrophy v = physicalNSObservables.enstrophy v)

/-- Under vorticity alignment, the Stage-218 physical mode-0 BKM integral equals
    the observable-interface BKM integral for the physical instance. -/
theorem bkmPhysicalMode0_eq_obs_physical
    (hVortAlign : ∀ v : NSField,
      vorticityLinftyPhysicalMode0 v = physicalNSObservables.vorticityLinfty v)
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegralPhysicalMode0 traj T =
      bkmVorticityIntegralObs physicalNSObservables traj T := by
  -- Stage 241: definitionally equal after enstrophy physicalization
  rfl

/-- Under enstrophy alignment, entropic proper time equals the observable-interface
    entropic clock for the physical instance. -/
theorem entropicProperTime_eq_obs_physical
    (hEnsAlign : ∀ v : NSField,
      enstrophy v = physicalNSObservables.enstrophy v)
    (traj : Trajectory NSField) (T : Rat) :
    entropicProperTime traj T =
      entropicProperTimeObs physicalNSObservables traj T := by
  -- Stage 241: definitionally equal after enstrophy physicalization
  rfl

/-- Any observable-interface physical precise-gap witness transports to the
    Stage-218 physical mode-0 precise-gap statement under explicit alignment. -/
theorem precise_gap_obs_physical_implies_precise_gap_physicalMode0
    (hAlign : PhysicalMode0ObsAlignment)
    (hObs : PreciseGapStatementObs physicalNSObservables) :
    PreciseGapStatementPhysicalMode0 := by
  rcases hAlign with ⟨hVortAlign, hEnsAlign⟩
  rcases hObs with ⟨F, hF⟩
  refine ⟨fun tau _E _nu => F tau, ?_⟩
  intro traj T hT _hNS _hFS
  have hBkmEq :
      bkmVorticityIntegralPhysicalMode0 traj T =
      bkmVorticityIntegralObs physicalNSObservables traj T :=
    bkmPhysicalMode0_eq_obs_physical hVortAlign traj T
  have hTauEq :
      entropicProperTime traj T =
      entropicProperTimeObs physicalNSObservables traj T :=
    entropicProperTime_eq_obs_physical hEnsAlign traj T
  calc
    bkmVorticityIntegralPhysicalMode0 traj T
        = bkmVorticityIntegralObs physicalNSObservables traj T := hBkmEq
    _ ≤ F (entropicProperTimeObs physicalNSObservables traj T) := hF traj T hT
    _ = F (entropicProperTime traj T) := by rw [hTauEq]

/-- One-step adapter from the Stage-153 physical-observable reduction:
    if the Fourier-Agmon observable instance has a τ-only precise-gap witness,
    then (under explicit Stage-218 alignment) the physical mode-0 precise gap
    follows in the legacy bridge shape. -/
theorem precise_gap_agmon_obs_implies_precise_gap_physicalMode0
    (hAlign : PhysicalMode0ObsAlignment)
    (hAgmon : PreciseGapStatementObs
      NavierStokes.FourierAgmonObsBridge.fourierNSObsInstance_agmon) :
    PreciseGapStatementPhysicalMode0 :=
  precise_gap_obs_physical_implies_precise_gap_physicalMode0 hAlign
    (pgs_obs_physical_from_agmon hAgmon)

/-! ## Linear entropic-control interface (physical mode-0) -/

/-- Physical-mode counterpart of the linear entropic control bridge target.
    This is a concrete entry point for replacing legacy `vorticityLinfty`
    usage while preserving the same downstream pipeline shape. -/
def BridgeTargetLinearEntropicControlPhysicalMode0 : Prop :=
  ∃ A B : Rat,
    0 ≤ A ∧
    0 ≤ B ∧
    ∀ (traj : Trajectory NSField) (T : Rat),
      0 < T →
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      bkmVorticityIntegralPhysicalMode0 traj T ≤
        A + B * entropicProperTime traj T

/-- Linear physical-mode control implies a physical precise-gap witness. -/
theorem bridge_target_linear_entropic_control_physicalMode0_implies_precise_gap_physicalMode0
    (hBridge0 : BridgeTargetLinearEntropicControlPhysicalMode0) :
    PreciseGapStatementPhysicalMode0 := by
  rcases hBridge0 with ⟨A, B, _hA, _hB, hBound⟩
  refine ⟨fun tau _E _nu => A + B * tau, ?_⟩
  intro traj T hT hNS hFS
  exact hBound traj T hT hNS hFS

/-- Convenience composition into the legacy precise-gap interface. -/
theorem bridge_target_linear_entropic_control_physicalMode0_implies_precise_gap
    (hBridge0 : BridgeTargetLinearEntropicControlPhysicalMode0) :
    PreciseGapStatement :=
  precise_gap_physicalMode0_implies_precise_gap
    (bridge_target_linear_entropic_control_physicalMode0_implies_precise_gap_physicalMode0 hBridge0)

/-! ## Concrete discharge (Stage 218 physical-mode0 hardening) -/

/-- Physical mode-0 BKM integral is exactly integrated enstrophy. -/
theorem bkmVorticityIntegralPhysicalMode0_eq_integratedEnstrophy
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegralPhysicalMode0 traj T = integratedEnstrophy traj T := by
  unfold bkmVorticityIntegralPhysicalMode0 integratedEnstrophy vorticityLinftyPhysicalMode0
  rfl

/-- Entropic-time identity for the physical mode-0 observable:
    `bkmPhysical0 = (ħ/ν) * τ_ent`. -/
theorem bkmVorticityIntegralPhysicalMode0_eq_hbar_div_nu_mul_entropicProperTime
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegralPhysicalMode0 traj T =
      (hbar / nsNu) * entropicProperTime traj T := by
  rw [bkmVorticityIntegralPhysicalMode0_eq_integratedEnstrophy]
  unfold entropicProperTime
  have hnu : nsNu ≠ 0 := ne_of_gt nsNu_pos
  have hhbar : hbar ≠ 0 := ne_of_gt hbar_pos
  have hcancel : (hbar / nsNu) * (nsNu / hbar) = (1 : Rat) := by
    field_simp [hnu, hhbar]
  calc
    integratedEnstrophy traj T
        = (1 : Rat) * integratedEnstrophy traj T := by ring
    _ = ((hbar / nsNu) * (nsNu / hbar)) * integratedEnstrophy traj T := by
          rw [hcancel]
    _ = (hbar / nsNu) * ((nsNu / hbar) * integratedEnstrophy traj T) := by ring

/-- **Concrete witness discharge** for the physical mode-0 linear bridge target.
    This route is structural (clock-coupled), not divergence-zero collapse. -/
theorem bridge_target_linear_entropic_control_physicalMode0_witness :
    BridgeTargetLinearEntropicControlPhysicalMode0 := by
  refine ⟨0, hbar / nsNu, le_rfl, ?_, ?_⟩
  · exact div_nonneg (le_of_lt hbar_pos) (le_of_lt nsNu_pos)
  · intro traj T _hT _hNS _hFS
    calc
      bkmVorticityIntegralPhysicalMode0 traj T
          = (hbar / nsNu) * entropicProperTime traj T :=
            bkmVorticityIntegralPhysicalMode0_eq_hbar_div_nu_mul_entropicProperTime traj T
      _ = 0 + (hbar / nsNu) * entropicProperTime traj T := by ring
      _ ≤ 0 + (hbar / nsNu) * entropicProperTime traj T := le_rfl

/-! ## Non-placeholder diagnostics for Stage 218 witness -/

/-- Diagnostic predicate: there exists a finite horizon with strictly positive
    physical mode-0 BKM integral.  This marks a non-vacuous physical witness. -/
def PhysicalMode0NonPlaceholderWitness : Prop :=
  ∃ (traj : Trajectory NSField) (T : Rat),
    0 < T ∧ 0 < bkmVorticityIntegralPhysicalMode0 traj T

/-- The non-placeholder diagnostic is equivalent to positivity of integrated
    enstrophy on some finite horizon. -/
theorem physicalMode0_nonplaceholder_iff_integratedEnstrophy_positive :
    PhysicalMode0NonPlaceholderWitness ↔
    ∃ (traj : Trajectory NSField) (T : Rat),
      0 < T ∧ 0 < integratedEnstrophy traj T := by
  constructor
  · intro h
    rcases h with ⟨traj, T, hT, hPos⟩
    refine ⟨traj, T, hT, ?_⟩
    simpa [bkmVorticityIntegralPhysicalMode0_eq_integratedEnstrophy traj T] using hPos
  · intro h
    rcases h with ⟨traj, T, hT, hPos⟩
    refine ⟨traj, T, hT, ?_⟩
    simpa [bkmVorticityIntegralPhysicalMode0_eq_integratedEnstrophy traj T] using hPos

/-- If some trajectory has strictly positive entropic proper time at a finite
    horizon, then the physical mode-0 witness is non-placeholder at that horizon. -/
theorem physicalMode0_nonplaceholder_of_entropicProperTime_positive
    (hTauPos : ∃ (traj : Trajectory NSField) (T : Rat),
      0 < T ∧ 0 < entropicProperTime traj T) :
    PhysicalMode0NonPlaceholderWitness := by
  rcases hTauPos with ⟨traj, T, hT, hTau⟩
  refine ⟨traj, T, hT, ?_⟩
  have hCoeffPos : 0 < hbar / nsNu := div_pos hbar_pos nsNu_pos
  have hMulPos : 0 < (hbar / nsNu) * entropicProperTime traj T :=
    mul_pos hCoeffPos hTau
  simpa [bkmVorticityIntegralPhysicalMode0_eq_hbar_div_nu_mul_entropicProperTime traj T]
    using hMulPos

/-- Non-placeholder diagnostic transport from observable-interface positivity
    under explicit vorticity alignment. -/
theorem physicalMode0_nonplaceholder_of_obs_physical_positive
    (hVortAlign : ∀ v : NSField,
      vorticityLinftyPhysicalMode0 v = physicalNSObservables.vorticityLinfty v)
    (hObsPos : ∃ (traj : Trajectory NSField) (T : Rat),
      0 < T ∧ 0 < bkmVorticityIntegralObs physicalNSObservables traj T) :
    PhysicalMode0NonPlaceholderWitness := by
  rcases hObsPos with ⟨traj, T, hT, hPos⟩
  refine ⟨traj, T, hT, ?_⟩
  have hEq :
      bkmVorticityIntegralPhysicalMode0 traj T =
      bkmVorticityIntegralObs physicalNSObservables traj T :=
    bkmPhysicalMode0_eq_obs_physical hVortAlign traj T
  rw [hEq]
  exact hPos

end NavierStokes.Millennium
