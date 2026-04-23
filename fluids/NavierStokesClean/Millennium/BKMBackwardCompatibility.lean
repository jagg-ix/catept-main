import NavierStokesClean.Millennium.MillenniumClosure
import NavierStokesClean.Millennium.PhysicalObservablesPreciseGapBridge

/-!
# BKM Backward Bridge Compatibility

Compatibility names for legacy `BKMBackwardBridge.lean`, mapped to the clean
pipeline endpoints already theoremized in `BKMContinuationPipeline`.

No new axioms are introduced.
-/

set_option autoImplicit false

namespace NavierStokesClean.Millennium

open MillenniumNavierStokes MillenniumNS_BoundedDomain

/-- Legacy endpoint name: global existence on T³ from the clean BKM route. -/
theorem bkm_t3_global_existence : FeffermanB :=
  pgs_implies_fefferman_b pgs_ept_witness

/-- Legacy endpoint name: global existence from physical-mode precise-gap contract. -/
theorem bkm_t3_global_existence_of_physicalMode0_precise_gap
    (hGap0 : BridgeTargetLinearEntropicControlPhysicalMode0) : FeffermanB :=
  bridge_target_linear_entropic_control_physicalMode0_implies_fefferman_b hGap0

/-- Legacy endpoint name: global existence from physical-mode linear bridge. -/
theorem bkm_t3_global_existence_of_physicalMode0_linear_bridge
    (hRoute : BridgeTargetLinearEntropicControlPhysicalMode0) : FeffermanB :=
  bridge_target_linear_entropic_control_physicalMode0_implies_fefferman_b hRoute

/-- Legacy endpoint name: global existence from strong physical-mode linear bridge. -/
theorem bkm_t3_global_existence_of_physicalMode0_linear_bridge_strong
    (hStrong : BridgeTargetLinearEntropicControlPhysicalMode0Strong) : FeffermanB :=
  pgs_from_physical_mode0_strong_implies_fefferman_b hStrong

/-- Legacy endpoint name: all-horizons closure (compatibility wrapper). -/
theorem bkm_t3_global_existence_with_bkm_all_horizons : FeffermanB :=
  bkm_t3_global_existence

/-- Legacy route name retained with explicit physical-mode witness argument. -/
theorem millennium_C_closed_via_physicalMode0_witness
    (hRoute : BridgeTargetLinearEntropicControlPhysicalMode0) :
    NavierStokesMillenniumProblem :=
  Or.inr (Or.inl
    (bridge_target_linear_entropic_control_physicalMode0_implies_fefferman_b hRoute))

/-- Legacy route name retained with explicit physical-mode witness argument. -/
theorem millennium_C_global_regularity_via_physicalMode0_witness
    (hRoute : BridgeTargetLinearEntropicControlPhysicalMode0) :
    NavierStokesMillenniumProblem :=
  Or.inr (Or.inl
    (bridge_target_linear_entropic_control_physicalMode0_implies_fefferman_b hRoute))

end NavierStokesClean.Millennium
