import NavierStokes.BKMMinimalBridge
import NavierStokes.AxiomaticEstimates

/-!
# BKM Physical Observable Bridge

Stage 217A transport lemmas that allow legacy BKM interfaces to consume
the concrete mode-0 vorticity observable introduced in `AxiomaticEstimates`.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

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

end NavierStokes.Millennium
