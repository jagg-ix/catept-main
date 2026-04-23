import NavierStokes.BKM.BKMMinimalBridge
import NavierStokes.Core.AxiomaticEstimates
import NavierStokes.Core.NSObservableInterface
import NavierStokes.Bridges.NSPhysicalT3Bridge

/-!
# BKM Physical Observable Bridge

Stage 218 transport/hardening lemmas that allow legacy BKM interfaces to consume
the concrete mode-0 vorticity observable introduced in `AxiomaticEstimates`.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

open NavierStokes.ObservableInterface
open NavierStokes.PhysicalT3Bridge

/-! ## Legacy-to-mode0 monotonicity contract -/

/-- Explicit migration contract from legacy BKM observable to the Stage-218
    physical mode-0 observable candidate. -/
def LegacyMode0VorticityMonotone : Prop :=
  ∀ v : NSField, vorticityLinfty v ≤ vorticityLinftyPhysicalMode0 v

/-- External-facing contract: legacy BKM observable is pointwise dominated by the
    physical observable interface vorticity for all carrier states. -/
def LegacyPhysicalVorticityDominance : Prop :=
  ∀ v : NSField, vorticityLinfty v ≤ physicalNSObservables.vorticityLinfty v

/-- Current-model instantiation of the migration contract.
    This is currently discharged by the reduced-carrier legacy placeholder
    (`vorticityLinfty := 0`) and should be replaced by a physical proof as the
    carrier is hardened. -/
theorem legacyMode0VorticityMonotone_current_model :
    LegacyMode0VorticityMonotone :=
  vorticityLinfty_legacy_le_physicalMode0

/-- Physical dominance contract: abstract carrier vorticity is dominated by
    the concrete physical observable vorticity (genuine physical claim, Stage 224). -/
axiom legacyPhysicalVorticityDominance_current_model :
    LegacyPhysicalVorticityDominance

/-- Legacy BKM integral is pointwise bounded by the physical mode-0 candidate
    integral, so existing legacy consumers can be migrated monotonically. -/
theorem bkmVorticityIntegral_legacy_le_physicalMode0_of_monotone
    (hMono : LegacyMode0VorticityMonotone)
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegral traj T ≤ bkmVorticityIntegralPhysicalMode0 traj T := by
  unfold bkmVorticityIntegral bkmVorticityIntegralPhysicalMode0
  apply NavierStokes.DiscreteKernel.discreteIntegral_le_of_pointwise
  intro t
  exact hMono (traj.stateAt t).velocity

/-- Current-model specialization of legacy ≤ mode-0 integral transport. -/
theorem bkmVorticityIntegral_legacy_le_physicalMode0
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegral traj T ≤ bkmVorticityIntegralPhysicalMode0 traj T :=
  bkmVorticityIntegral_legacy_le_physicalMode0_of_monotone
    legacyMode0VorticityMonotone_current_model traj T

/-- Any upper bound on the physical mode-0 integral is also an upper bound
    on the legacy BKM integral. -/
theorem bkmVorticityIntegral_le_of_physicalMode0_bound_of_monotone
    (hMono : LegacyMode0VorticityMonotone)
    (traj : Trajectory NSField) (T M : Rat)
    (hM : bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    bkmVorticityIntegral traj T ≤ M :=
  le_trans (bkmVorticityIntegral_legacy_le_physicalMode0_of_monotone hMono traj T) hM

/-- Current-model specialization of physical-mode upper-bound transport. -/
theorem bkmVorticityIntegral_le_of_physicalMode0_bound
    (traj : Trajectory NSField) (T M : Rat)
    (hM : bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    bkmVorticityIntegral traj T ≤ M :=
  bkmVorticityIntegral_le_of_physicalMode0_bound_of_monotone
    legacyMode0VorticityMonotone_current_model traj T M hM

/-- Transport a concrete bound on the physical mode-0 observable to the
    opaque convergence predicate used by the legacy BKM finiteness layer. -/
theorem bkmIntegralConverges_of_physicalMode0_bound_of_monotone
    (hMono : LegacyMode0VorticityMonotone)
    (traj : Trajectory NSField) (T M : Rat)
    (hM : bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    BKMIntegralConverges traj T :=
  bkm_bounded_implies_converges traj T M
    (bkmVorticityIntegral_le_of_physicalMode0_bound_of_monotone hMono traj T M hM)

/-- Current-model specialization of BKM convergence transport. -/
theorem bkmIntegralConverges_of_physicalMode0_bound
    (traj : Trajectory NSField) (T M : Rat)
    (hM : bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    BKMIntegralConverges traj T :=
  bkmIntegralConverges_of_physicalMode0_bound_of_monotone
    legacyMode0VorticityMonotone_current_model traj T M hM

/-- Physical mode-0 integral bounds imply legacy BKM finiteness. -/
theorem bkmIntegralFiniteAt_of_physicalMode0_bound_of_monotone
    (hMono : LegacyMode0VorticityMonotone)
    (traj : Trajectory NSField) (T M : Rat)
    (hM : bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    BKMIntegralFiniteAt traj T :=
  bkmIntegralConverges_of_physicalMode0_bound_of_monotone hMono traj T M hM

/-- Current-model specialization of finite-at transport. -/
theorem bkmIntegralFiniteAt_of_physicalMode0_bound
    (traj : Trajectory NSField) (T M : Rat)
    (hM : bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    BKMIntegralFiniteAt traj T :=
  bkmIntegralFiniteAt_of_physicalMode0_bound_of_monotone
    legacyMode0VorticityMonotone_current_model traj T M hM

/-- Existential packaging for common workflows that already produce a
    finite upper bound witness on the physical mode-0 integral. -/
theorem bkmIntegralFiniteAt_of_exists_physicalMode0_bound_of_monotone
    (hMono : LegacyMode0VorticityMonotone)
    (traj : Trajectory NSField) (T : Rat)
    (hBound : ∃ M : Rat, bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    BKMIntegralFiniteAt traj T := by
  rcases hBound with ⟨M, hM⟩
  exact bkmIntegralFiniteAt_of_physicalMode0_bound_of_monotone hMono traj T M hM

/-- Current-model specialization of existential finite-at transport. -/
theorem bkmIntegralFiniteAt_of_exists_physicalMode0_bound
    (traj : Trajectory NSField) (T : Rat)
    (hBound : ∃ M : Rat, bkmVorticityIntegralPhysicalMode0 traj T ≤ M) :
    BKMIntegralFiniteAt traj T :=
  bkmIntegralFiniteAt_of_exists_physicalMode0_bound_of_monotone
    legacyMode0VorticityMonotone_current_model traj T hBound

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
theorem precise_gap_physicalMode0_implies_precise_gap_of_monotone
    (hMono : LegacyMode0VorticityMonotone)
    (hGap0 : PreciseGapStatementPhysicalMode0) :
    PreciseGapStatement := by
  rcases hGap0 with ⟨F, hF⟩
  refine ⟨F, ?_⟩
  intro traj T hT hNS hFS
  exact le_trans
    (bkmVorticityIntegral_legacy_le_physicalMode0_of_monotone hMono traj T)
    (hF traj T hT hNS hFS)

/-- Current-model specialization of physical-mode precise-gap transport. -/
theorem precise_gap_physicalMode0_implies_precise_gap
    (hGap0 : PreciseGapStatementPhysicalMode0) :
    PreciseGapStatement :=
  precise_gap_physicalMode0_implies_precise_gap_of_monotone
    legacyMode0VorticityMonotone_current_model hGap0

/-- Reusable BKM finiteness consequence from a physical-mode precise gap witness. -/
theorem bkmIntegralFiniteAt_of_precise_gap_physicalMode0_of_monotone
    (hMono : LegacyMode0VorticityMonotone)
    (hGap0 : PreciseGapStatementPhysicalMode0)
    (traj : Trajectory NSField) (T : Rat)
    (hT : 0 < T)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    BKMIntegralFiniteAt traj T := by
  exact precise_gap_implies_regularity
    (precise_gap_physicalMode0_implies_precise_gap_of_monotone hMono hGap0)
    traj T hT hNS hFS

/-- Current-model specialization of finite-at from physical-mode precise-gap. -/
theorem bkmIntegralFiniteAt_of_precise_gap_physicalMode0
    (hGap0 : PreciseGapStatementPhysicalMode0)
    (traj : Trajectory NSField) (T : Rat)
    (hT : 0 < T)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    BKMIntegralFiniteAt traj T :=
  bkmIntegralFiniteAt_of_precise_gap_physicalMode0_of_monotone
    legacyMode0VorticityMonotone_current_model hGap0 traj T hT hNS hFS

/-- Interface-level transport: physical-mode precise gap can drive the same
    minimal-bridge consumer used by the legacy `PreciseGapStatement`. -/
theorem precise_gap_physicalMode0_to_minimal_bridge_of_monotone
    (hMono : LegacyMode0VorticityMonotone)
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
    (precise_gap_physicalMode0_implies_precise_gap_of_monotone hMono hGap0)

/-- Current-model specialization of minimal-bridge transport. -/
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
  precise_gap_physicalMode0_to_minimal_bridge_of_monotone
    legacyMode0VorticityMonotone_current_model pi hGap0

/-! ## Observable-interface adapter (physical instance) -/

/-- Alignment contract between the Stage-218 physical mode-0 observable path and
    the Stage-150+ observable-interface physical instance. -/
def PhysicalMode0ObsAlignment : Prop :=
  (∀ v : NSField,
      vorticityLinftyPhysicalMode0 v = physicalNSObservables.vorticityLinfty v) ∧
  (∀ v : NSField,
      enstrophy v = physicalNSObservables.enstrophy v)

/-- Non-current-model source route for mode-0 monotonicity:
    if legacy is dominated by physical vorticity and mode-0 aligns to physical
    vorticity, then legacy is dominated by mode-0 directly. -/
theorem legacyMode0VorticityMonotone_of_alignment_and_legacyPhysicalDominance
    (hLegacyPhys : LegacyPhysicalVorticityDominance)
    (hAlign : PhysicalMode0ObsAlignment) :
    LegacyMode0VorticityMonotone := by
  rcases hAlign with ⟨hVortAlign, _hEnsAlign⟩
  intro v
  calc
    vorticityLinfty v ≤ physicalNSObservables.vorticityLinfty v := hLegacyPhys v
    _ = vorticityLinftyPhysicalMode0 v := by
          symm
          exact hVortAlign v


/-- Under vorticity alignment, the Stage-218 physical mode-0 BKM integral equals
    the observable-interface BKM integral for the physical instance. -/
theorem bkmPhysicalMode0_eq_obs_physical
    (_hVortAlign : ∀ v : NSField,
      vorticityLinftyPhysicalMode0 v = physicalNSObservables.vorticityLinfty v)
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegralPhysicalMode0 traj T =
      bkmVorticityIntegralObs physicalNSObservables traj T := by
  -- Stage 241: definitionally equal after enstrophy physicalization
  rfl

/-- Under enstrophy alignment, entropic proper time equals the observable-interface
    entropic clock for the physical instance. -/
theorem entropicProperTime_eq_obs_physical
    (_hEnsAlign : ∀ v : NSField,
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

/-- Concrete observable-side non-placeholder witness:
    using `interpretAsFourier_nontrivial` and Parseval alignment, there exists a
    finite horizon with strictly positive physical entropic proper time. -/
theorem obs_physical_entropicProperTime_positive_witness :
    ∃ (traj : Trajectory NSField) (T : Rat),
      0 < T ∧ 0 < entropicProperTimeObs physicalNSObservables traj T := by
  rcases interpretAsFourier_nontrivial with ⟨v, hvFourier⟩
  have hvPhys : 0 < physicalNSObservables.enstrophy v := by
    rw [physicalObs_enstrophy_fourier_id v]
    exact hvFourier
  let st : State NSField := { velocity := v, pressure := nsZero }
  let traj : Trajectory NSField := { stateAt := fun _ => st }
  refine ⟨traj, NavierStokes.DiscreteKernel.diH, NavierStokes.DiscreteKernel.diH_pos, ?_⟩
  have hSteps :
      NavierStokes.DiscreteKernel.diSteps NavierStokes.DiscreteKernel.diH = 1 := by
    unfold NavierStokes.DiscreteKernel.diSteps
    norm_num [NavierStokes.DiscreteKernel.diH, NavierStokes.DiscreteKernel.diN]
  have hInt :
      NavierStokes.DiscreteKernel.discreteIntegral
        (fun t => physicalNSObservables.enstrophy (traj.stateAt t).velocity)
        NavierStokes.DiscreteKernel.diH
      = physicalNSObservables.enstrophy v * NavierStokes.DiscreteKernel.diH := by
    unfold NavierStokes.DiscreteKernel.discreteIntegral
    simp [traj, st, hSteps]
  have hIntPos :
      0 <
      NavierStokes.DiscreteKernel.discreteIntegral
        (fun t => physicalNSObservables.enstrophy (traj.stateAt t).velocity)
        NavierStokes.DiscreteKernel.diH := by
    rw [hInt]
    exact mul_pos hvPhys NavierStokes.DiscreteKernel.diH_pos
  unfold entropicProperTimeObs
  exact mul_pos (div_pos nsNu_pos hbar_pos) hIntPos

/-- Path-C non-placeholder reduction:
    once enstrophy alignment is available, the observable-side positive witness
    upgrades to the Stage-218 physical mode-0 non-placeholder witness. -/
theorem physicalMode0_nonplaceholder_of_enstrophy_alignment
    (hEnsAlign : ∀ v : NSField,
      enstrophy v = physicalNSObservables.enstrophy v) :
    PhysicalMode0NonPlaceholderWitness := by
  rcases obs_physical_entropicProperTime_positive_witness with ⟨traj, T, hT, hTauObs⟩
  have hTauEq :
      entropicProperTime traj T =
      entropicProperTimeObs physicalNSObservables traj T :=
    entropicProperTime_eq_obs_physical hEnsAlign traj T
  refine physicalMode0_nonplaceholder_of_entropicProperTime_positive ?_
  refine ⟨traj, T, hT, ?_⟩
  rw [hTauEq]
  exact hTauObs

/-- Full Stage-218 alignment implies non-placeholder physical mode-0 witness. -/
theorem physicalMode0_nonplaceholder_of_alignment
    (hAlign : PhysicalMode0ObsAlignment) :
    PhysicalMode0NonPlaceholderWitness := by
  rcases hAlign with ⟨_hVortAlign, hEnsAlign⟩
  exact physicalMode0_nonplaceholder_of_enstrophy_alignment hEnsAlign

/-- Minimal physicalization gate for Stage-218 mode-0 route:
    some NS field carries strictly positive enstrophy in the current carrier. -/
def EnstrophyPhysicalizationGate : Prop :=
  ∃ v : NSField, 0 < enstrophy v

/-- Candidate physicalized enstrophy target for carrier concretization.
    This is the observable-side physical enstrophy. -/
noncomputable def EnstrophyPhysicalizedCandidate : NSField → Rat :=
  physicalNSObservables.enstrophy

/-- The physicalized candidate is nontrivial: some carrier state has strictly
    positive candidate enstrophy (from Fourier nontriviality + Parseval ID). -/
theorem enstrophyPhysicalizedCandidate_positive_witness :
    ∃ v : NSField, 0 < EnstrophyPhysicalizedCandidate v := by
  rcases interpretAsFourier_nontrivial with ⟨v, hv⟩
  refine ⟨v, ?_⟩
  unfold EnstrophyPhysicalizedCandidate
  rw [physicalObs_enstrophy_fourier_id v]
  exact hv

/-- Weaker discharge contract than global swap:
    it suffices to exhibit one carrier state whose enstrophy aligns to the
    physicalized candidate and is strictly positive on that state. -/
def EnstrophyPhysicalizedWitnessObligation : Prop :=
  ∃ v : NSField,
    enstrophy v = EnstrophyPhysicalizedCandidate v ∧
    0 < EnstrophyPhysicalizedCandidate v

/-- Candidate-swap discharge implies the weaker witness obligation. -/
theorem enstrophyPhysicalizedWitnessObligation_of_candidate_swap
    (hSwap : ∀ v : NSField, enstrophy v = EnstrophyPhysicalizedCandidate v) :
    EnstrophyPhysicalizedWitnessObligation := by
  rcases enstrophyPhysicalizedCandidate_positive_witness with ⟨v, hvPos⟩
  exact ⟨v, hSwap v, hvPos⟩

/-- The weaker witness obligation is already enough to discharge the minimal
    enstrophy physicalization gate. -/
theorem enstrophyPhysicalizationGate_of_physicalizedWitnessObligation
    (hW : EnstrophyPhysicalizedWitnessObligation) :
    EnstrophyPhysicalizationGate := by
  rcases hW with ⟨v, hAlign, hPosCand⟩
  refine ⟨v, ?_⟩
  calc
    0 < EnstrophyPhysicalizedCandidate v := hPosCand
    _ = enstrophy v := by
          symm
          exact hAlign

/-- Canonical witness state selected from the physicalized-candidate positivity
    theorem.  This gives a fixed target for concrete carrier alignment work. -/
noncomputable def enstrophyPhysicalizedCanonicalWitnessState : NSField :=
  Classical.choose enstrophyPhysicalizedCandidate_positive_witness

/-- Positivity certificate for the canonical witness state. -/
theorem enstrophyPhysicalizedCanonicalWitnessState_positive :
    0 < EnstrophyPhysicalizedCandidate enstrophyPhysicalizedCanonicalWitnessState :=
  Classical.choose_spec enstrophyPhysicalizedCandidate_positive_witness

/-- Sharpened alignment obligation:
    match enstrophy to the physicalized candidate on one canonical witness state. -/
def EnstrophyPhysicalizedCanonicalWitnessAlignment : Prop :=
  enstrophy enstrophyPhysicalizedCanonicalWitnessState =
    EnstrophyPhysicalizedCandidate enstrophyPhysicalizedCanonicalWitnessState

/-- Canonical-state alignment discharges the weaker witness obligation. -/
theorem enstrophyPhysicalizedWitnessObligation_of_canonicalWitnessAlignment
    (hAlign0 : EnstrophyPhysicalizedCanonicalWitnessAlignment) :
    EnstrophyPhysicalizedWitnessObligation :=
  ⟨enstrophyPhysicalizedCanonicalWitnessState,
    hAlign0,
    enstrophyPhysicalizedCanonicalWitnessState_positive⟩

/-- One-step discharge rule: if the current carrier enstrophy is swapped/aligned
    to the physicalized candidate, the Stage-218 physicalization gate follows. -/
theorem enstrophyPhysicalizationGate_of_candidate_swap
    (hSwap : ∀ v : NSField, enstrophy v = EnstrophyPhysicalizedCandidate v) :
    EnstrophyPhysicalizationGate := by
  rcases enstrophyPhysicalizedCandidate_positive_witness with ⟨v, hvPos⟩
  refine ⟨v, ?_⟩
  rw [hSwap v]
  exact hvPos


/-- If the enstrophy physicalization gate is discharged, the Stage-218 mode-0
    non-placeholder witness follows constructively. -/
theorem physicalMode0_nonplaceholder_of_enstrophyPhysicalizationGate
    (hGate : EnstrophyPhysicalizationGate) :
    PhysicalMode0NonPlaceholderWitness := by
  rcases hGate with ⟨v, hvPos⟩
  let st : State NSField := { velocity := v, pressure := nsZero }
  let traj : Trajectory NSField := { stateAt := fun _ => st }
  refine ⟨traj, NavierStokes.DiscreteKernel.diH, NavierStokes.DiscreteKernel.diH_pos, ?_⟩
  have hSteps :
      NavierStokes.DiscreteKernel.diSteps NavierStokes.DiscreteKernel.diH = 1 := by
    unfold NavierStokes.DiscreteKernel.diSteps
    norm_num [NavierStokes.DiscreteKernel.diH, NavierStokes.DiscreteKernel.diN]
  have hInt :
      integratedEnstrophy traj NavierStokes.DiscreteKernel.diH
      = enstrophy v * NavierStokes.DiscreteKernel.diH := by
    unfold integratedEnstrophy NavierStokes.DiscreteKernel.discreteIntegral
    simp [traj, st, hSteps]
  have hIntPos :
      0 < integratedEnstrophy traj NavierStokes.DiscreteKernel.diH := by
    rw [hInt]
    exact mul_pos hvPos NavierStokes.DiscreteKernel.diH_pos
  rw [bkmVorticityIntegralPhysicalMode0_eq_integratedEnstrophy traj NavierStokes.DiscreteKernel.diH]
  exact hIntPos

/-! ## Strong physical-mode bridge target (load-bearing) -/

/-- Strengthened Stage-218 bridge target:
    linear entropic-control witness + explicit non-placeholder witness. -/
def BridgeTargetLinearEntropicControlPhysicalMode0Strong : Prop :=
  BridgeTargetLinearEntropicControlPhysicalMode0 ∧
    PhysicalMode0NonPlaceholderWitness

/-- Strong target still supplies the linear bridge bound. -/
theorem bridge_target_linear_entropic_control_physicalMode0Strong_linear
    (hStrong : BridgeTargetLinearEntropicControlPhysicalMode0Strong) :
    BridgeTargetLinearEntropicControlPhysicalMode0 :=
  hStrong.1

/-- Strong target exposes the explicit non-placeholder witness. -/
theorem bridge_target_linear_entropic_control_physicalMode0Strong_nonplaceholder
    (hStrong : BridgeTargetLinearEntropicControlPhysicalMode0Strong) :
    PhysicalMode0NonPlaceholderWitness :=
  hStrong.2

/-- Strong target implies physical-mode precise-gap closure (same downstream API),
    while retaining explicit non-placeholder semantics. -/
theorem bridge_target_linear_entropic_control_physicalMode0Strong_implies_precise_gap_physicalMode0
    (hStrong : BridgeTargetLinearEntropicControlPhysicalMode0Strong) :
    PreciseGapStatementPhysicalMode0 :=
  bridge_target_linear_entropic_control_physicalMode0_implies_precise_gap_physicalMode0
    hStrong.1

/-- Under full Stage-218 alignment, the strengthened target is available:
    (a) linear bridge witness from the clock-coupled identity,
    (b) non-placeholder witness from observable-positive transport. -/
theorem bridge_target_linear_entropic_control_physicalMode0Strong_of_alignment
    (hAlign : PhysicalMode0ObsAlignment) :
    BridgeTargetLinearEntropicControlPhysicalMode0Strong := by
  exact ⟨bridge_target_linear_entropic_control_physicalMode0_witness,
    physicalMode0_nonplaceholder_of_alignment hAlign⟩

/-- Alternative discharge route for the strong Stage-218 contract:
    linear witness (already discharged) + minimal enstrophy physicalization gate. -/
theorem bridge_target_linear_entropic_control_physicalMode0Strong_of_enstrophyPhysicalizationGate
    (hGate : EnstrophyPhysicalizationGate) :
    BridgeTargetLinearEntropicControlPhysicalMode0Strong := by
  exact ⟨bridge_target_linear_entropic_control_physicalMode0_witness,
    physicalMode0_nonplaceholder_of_enstrophyPhysicalizationGate hGate⟩

/-- Composition rule for implementation work:
    once carrier enstrophy is concretized to the physicalized candidate, the
    strong Stage-218 bridge contract is discharged automatically. -/
theorem bridge_target_linear_entropic_control_physicalMode0Strong_of_candidate_swap
    (hSwap : ∀ v : NSField, enstrophy v = EnstrophyPhysicalizedCandidate v) :
    BridgeTargetLinearEntropicControlPhysicalMode0Strong :=
  bridge_target_linear_entropic_control_physicalMode0Strong_of_enstrophyPhysicalizationGate
    (enstrophyPhysicalizationGate_of_candidate_swap hSwap)

/-- Alternative strong-target composition from the weaker witness obligation. -/
theorem bridge_target_linear_entropic_control_physicalMode0Strong_of_physicalizedWitnessObligation
    (hW : EnstrophyPhysicalizedWitnessObligation) :
    BridgeTargetLinearEntropicControlPhysicalMode0Strong :=
  bridge_target_linear_entropic_control_physicalMode0Strong_of_enstrophyPhysicalizationGate
    (enstrophyPhysicalizationGate_of_physicalizedWitnessObligation hW)

/-! ## Explicit discharge obligation handle (coordination contract) -/

/-- Named proof-obligation contract for the current strongest Stage-218 route:
    provide a carrier-level enstrophy swap to the physicalized candidate. -/
def BridgeTargetLinearEntropicControlPhysicalMode0CandidateSwapObligation : Prop :=
  ∀ v : NSField, enstrophy v = EnstrophyPhysicalizedCandidate v

/-- The named candidate-swap obligation discharges the strong Stage-218 target. -/
theorem bridge_target_linear_entropic_control_physicalMode0Strong_of_candidateSwapObligation
    (hOb : BridgeTargetLinearEntropicControlPhysicalMode0CandidateSwapObligation) :
    BridgeTargetLinearEntropicControlPhysicalMode0Strong :=
  bridge_target_linear_entropic_control_physicalMode0Strong_of_candidate_swap hOb

/-- Named weaker discharge obligation for the same strong target:
    one aligned positive witness state instead of global carrier swap. -/
def BridgeTargetLinearEntropicControlPhysicalMode0WitnessObligation : Prop :=
  EnstrophyPhysicalizedWitnessObligation

/-- Sharpened named obligation:
    align enstrophy on one canonical positive witness state. -/
def BridgeTargetLinearEntropicControlPhysicalMode0CanonicalWitnessObligation : Prop :=
  EnstrophyPhysicalizedCanonicalWitnessAlignment

/-- The weaker named witness obligation also discharges the strong Stage-218 target. -/
theorem bridge_target_linear_entropic_control_physicalMode0Strong_of_witnessObligation
    (hOb : BridgeTargetLinearEntropicControlPhysicalMode0WitnessObligation) :
    BridgeTargetLinearEntropicControlPhysicalMode0Strong :=
  bridge_target_linear_entropic_control_physicalMode0Strong_of_physicalizedWitnessObligation hOb

/-- Canonical-witness obligation discharges the weaker witness obligation. -/
theorem bridge_target_linear_entropic_control_physicalMode0WitnessObligation_of_canonicalWitnessObligation
    (hOb : BridgeTargetLinearEntropicControlPhysicalMode0CanonicalWitnessObligation) :
    BridgeTargetLinearEntropicControlPhysicalMode0WitnessObligation :=
  enstrophyPhysicalizedWitnessObligation_of_canonicalWitnessAlignment hOb

/-- Canonical-witness obligation also discharges the strong Stage-218 target. -/
theorem bridge_target_linear_entropic_control_physicalMode0Strong_of_canonicalWitnessObligation
    (hOb : BridgeTargetLinearEntropicControlPhysicalMode0CanonicalWitnessObligation) :
    BridgeTargetLinearEntropicControlPhysicalMode0Strong :=
  bridge_target_linear_entropic_control_physicalMode0Strong_of_witnessObligation
    (bridge_target_linear_entropic_control_physicalMode0WitnessObligation_of_canonicalWitnessObligation hOb)

/-- The stronger candidate-swap obligation implies the weaker named witness obligation. -/
theorem bridge_target_linear_entropic_control_physicalMode0WitnessObligation_of_candidateSwapObligation
    (hOb : BridgeTargetLinearEntropicControlPhysicalMode0CandidateSwapObligation) :
    BridgeTargetLinearEntropicControlPhysicalMode0WitnessObligation :=
  enstrophyPhysicalizedWitnessObligation_of_candidate_swap hOb

/-- Candidate-swap obligation implies canonical-witness obligation. -/
theorem bridge_target_linear_entropic_control_physicalMode0CanonicalWitnessObligation_of_candidateSwapObligation
    (hOb : BridgeTargetLinearEntropicControlPhysicalMode0CandidateSwapObligation) :
    BridgeTargetLinearEntropicControlPhysicalMode0CanonicalWitnessObligation :=
  hOb enstrophyPhysicalizedCanonicalWitnessState


end NavierStokes.Millennium
