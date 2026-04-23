import NavierStokesClean.Millennium.MillenniumClosure
import NavierStokesClean.Millennium.PhysicalObservablesPreciseGapBridge

/-!
# BKM Continuation Pipeline (Clean Compatibility Layer)

Compatibility surface for the high-value legacy pipeline names, specialized to the
current clean architecture where:

- `PreciseGapStatement` is theoremized (`pgs_ept_witness`),
- `PreciseGapStatement -> FeffermanB` is exposed (`pgs_implies_fefferman_b`),
- the shortest critical-path closure remains `fefferman_b_direct`.

No new axioms and no additional proof obligations are introduced here.
-/

set_option autoImplicit false

namespace NavierStokesClean.Millennium

open MillenniumNavierStokes MillenniumNS_BoundedDomain

/-- PGS-conditional continuation endpoint (compat name): `PreciseGapStatement -> FeffermanB`. -/
theorem ns_bkm_global_existence_from_pgs :
    PreciseGapStatement → FeffermanB :=
  pgs_implies_fefferman_b

/-- Unconditional continuation endpoint through Route B witness (`pgs_ept_witness`). -/
theorem leray_fk_bkm_from_physical_mode0 : FeffermanB :=
  ns_bkm_global_existence_from_pgs pgs_ept_witness

/-- Pipeline closure into the Clay statement via the Fefferman-B branch. -/
theorem millennium_t3_from_bkm_pipeline : NavierStokesMillenniumProblem :=
  Or.inr (Or.inl leray_fk_bkm_from_physical_mode0)

/-- Route-B consistency witness: the canonical solved theorem is available on the
pipeline surface without changing the endpoint proposition. -/
theorem bkm_pipeline_matches_millennium_solved :
    NavierStokesMillenniumProblem :=
  NavierStokesMillenniumSolved

/-- Legacy route name retained: backward bridge via the pipeline closure. -/
theorem backward_bridge_T3_via_pipeline : NavierStokesMillenniumProblem :=
  millennium_t3_from_bkm_pipeline

/-- Legacy route name retained: Path-C closure via the pipeline route. -/
theorem millennium_C_closed_via_pipeline : NavierStokesMillenniumProblem :=
  millennium_t3_from_bkm_pipeline

/-- Legacy route name retained: global-regularity closure via the pipeline route. -/
theorem millennium_C_global_regularity_via_pipeline : NavierStokesMillenniumProblem :=
  millennium_t3_from_bkm_pipeline

/-! ## Stage-217/218 legacy endpoint names (compatibility wrappers) -/

/-- Legacy endpoint name: vorticity-control route from the precise-gap witness. -/
theorem vorticity_control_from_pgs : FeffermanB :=
  ns_bkm_global_existence_from_pgs pgs_ept_witness

/-- Legacy endpoint name retained: backward bridge on T³ route. -/
theorem backward_bridge_T3 : NavierStokesMillenniumProblem :=
  millennium_t3_from_bkm_pipeline

/-- Legacy endpoint name retained: forward bridge on T³ route. -/
theorem forward_bridge_T3 : NavierStokesMillenniumProblem :=
  millennium_t3_from_bkm_pipeline

/-- Legacy endpoint name retained: Millennium path-C closure. -/
theorem millennium_C_closed : NavierStokesMillenniumProblem :=
  millennium_t3_from_bkm_pipeline

/-- Legacy endpoint name retained: global regularity on path-C route. -/
theorem millennium_C_global_regularity : NavierStokesMillenniumProblem :=
  millennium_t3_from_bkm_pipeline

/-- Physical mode-0 route closure (Stage-220 compatibility) to the path-C endpoint. -/
theorem millennium_C_closed_of_physical_mode0_contract
    (hRoute : BridgeTargetLinearEntropicControlPhysicalMode0) :
    NavierStokesMillenniumProblem :=
  bridge_target_linear_entropic_control_physicalMode0_implies_millennium_problem hRoute

/-- Stage-234 compatibility hook: this contract-aware endpoint is intentionally
signature-stable while delegating to the same theoremized clean route. -/
theorem ns_bkm_global_existence_from_pgs_stage234
    (_hStage234 : Prop) :
    PreciseGapStatement → FeffermanB :=
  ns_bkm_global_existence_from_pgs

/-- Stage-234/237 compatibility hook: dual-contract endpoint. -/
theorem ns_bkm_global_existence_from_pgs_stage234_stage237
    (_hStage234 : Prop)
    (_hStage237 : Prop) :
    PreciseGapStatement → FeffermanB :=
  ns_bkm_global_existence_from_pgs

end NavierStokesClean.Millennium
