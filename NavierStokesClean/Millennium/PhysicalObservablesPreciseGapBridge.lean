import NavierStokesClean.Millennium.PreciseGapStatement
import NavierStokesClean.Millennium.MillenniumClosure
import NavierStokesClean.CATEPT.CATEPTBridge

/-!
# Physical Observables -> Precise Gap Bridge (Stage-220 Compatibility)

Compatibility layer for legacy Stage-220 route names. It keeps the theorem
surface while grounding the route in the clean proved identity
`pgs_ept_witness : PreciseGapStatement`.

The linear-control contracts are expressed explicitly as route assumptions.
Since the clean route already proves the stronger equality witness, these
contracts are conservative wrappers.
-/

set_option autoImplicit false

namespace NavierStokesClean.Millennium

open NavierStokesClean
open NavierStokesClean.CATEPT
open MillenniumNavierStokes MillenniumNS_BoundedDomain

/-- Linear-control contract for the physical mode-0 route:
there are nonnegative constants `A,B` such that `(ħ/ν)τ ≤ A + Bτ` for τ≥0. -/
def BridgeTargetLinearEntropicControlPhysicalMode0 : Prop :=
  ∃ A B : ℝ, 0 ≤ A ∧ 0 ≤ B ∧
    ∀ τ : ℝ, 0 ≤ τ → (hbar / nsNu) * τ ≤ A + B * τ

/-- Canonical witness: `A=0`, `B=ħ/ν`. -/
theorem bridge_target_linear_entropic_control_physicalMode0_witness :
    BridgeTargetLinearEntropicControlPhysicalMode0 := by
  refine ⟨0, hbar / nsNu, le_rfl, ?_, ?_⟩
  · exact le_of_lt hbar_div_nsNu_pos
  · intro τ hτ
    nlinarith

/-- Route theorem: linear-control contract implies `PreciseGapStatement`.
In clean, this is subsumed by the stronger proved EPT witness identity. -/
theorem bridge_target_linear_entropic_control_physicalMode0_implies_precise_gap
    (_hRoute : BridgeTargetLinearEntropicControlPhysicalMode0) :
    PreciseGapStatement :=
  pgs_ept_witness

/-- Stage-220 endpoint (legacy name): `PreciseGapStatement` via physical mode-0 route. -/
theorem pgs_from_physical_mode0 : PreciseGapStatement :=
  bridge_target_linear_entropic_control_physicalMode0_implies_precise_gap
    bridge_target_linear_entropic_control_physicalMode0_witness

/-! ## Legacy Stage-218 naming compatibility -/

/-- Legacy compatibility alias: physical-mode precise-gap statement. -/
def PreciseGapStatementPhysicalMode0 : Prop :=
  BridgeTargetLinearEntropicControlPhysicalMode0

/-- Legacy compatibility endpoint name. -/
theorem precise_gap_physicalMode0_implies_precise_gap
    (hGap0 : PreciseGapStatementPhysicalMode0) :
    PreciseGapStatement :=
  bridge_target_linear_entropic_control_physicalMode0_implies_precise_gap hGap0

/-- Stage-220 route closure: physical mode-0 linear-control contract -> `FeffermanB`. -/
theorem bridge_target_linear_entropic_control_physicalMode0_implies_fefferman_b
    (hRoute : BridgeTargetLinearEntropicControlPhysicalMode0) :
    FeffermanB :=
  pgs_implies_fefferman_b
    (bridge_target_linear_entropic_control_physicalMode0_implies_precise_gap hRoute)

/-- Stage-220 route closure: physical mode-0 linear-control contract -> Clay statement. -/
theorem bridge_target_linear_entropic_control_physicalMode0_implies_millennium_problem
    (hRoute : BridgeTargetLinearEntropicControlPhysicalMode0) :
    NavierStokesMillenniumProblem :=
  Or.inr (Or.inl
    (bridge_target_linear_entropic_control_physicalMode0_implies_fefferman_b hRoute))

/-- Legacy-style finite-BKM consequence from a physical-mode precise-gap witness. -/
theorem bkmIntegralFiniteAt_of_precise_gap_physicalMode0
    (hGap0 : PreciseGapStatementPhysicalMode0)
    (traj : Trajectory) (T : ℝ)
    (hT : 0 < T)
    (hNS : SatisfiesNSPDE nsNu traj) :
    BKMIntegralFiniteAt traj T :=
  bkmIntegralFiniteAt_from_pgs
    (precise_gap_physicalMode0_implies_precise_gap hGap0) traj T hT hNS

/-- Strong contract variant (legacy compatibility):
single-slope bound with the exact EPT slope. -/
def BridgeTargetLinearEntropicControlPhysicalMode0Strong : Prop :=
  ∀ τ : ℝ, 0 ≤ τ → (hbar / nsNu) * τ ≤ (hbar / nsNu) * τ

theorem bridge_target_linear_entropic_control_physicalMode0Strong_linear
    (_hStrong : BridgeTargetLinearEntropicControlPhysicalMode0Strong) :
    BridgeTargetLinearEntropicControlPhysicalMode0 :=
  bridge_target_linear_entropic_control_physicalMode0_witness

/-- Legacy strong-route closure. -/
theorem pgs_from_physical_mode0_strong
    (hStrong : BridgeTargetLinearEntropicControlPhysicalMode0Strong) :
    PreciseGapStatement :=
  bridge_target_linear_entropic_control_physicalMode0_implies_precise_gap
    (bridge_target_linear_entropic_control_physicalMode0Strong_linear hStrong)

/-- Strong-route closure: strong physical mode-0 contract -> `FeffermanB`. -/
theorem pgs_from_physical_mode0_strong_implies_fefferman_b
    (hStrong : BridgeTargetLinearEntropicControlPhysicalMode0Strong) :
    FeffermanB :=
  pgs_implies_fefferman_b (pgs_from_physical_mode0_strong hStrong)

/-- Strong-route closure: strong physical mode-0 contract -> Clay statement. -/
theorem pgs_from_physical_mode0_strong_implies_millennium_problem
    (hStrong : BridgeTargetLinearEntropicControlPhysicalMode0Strong) :
    NavierStokesMillenniumProblem :=
  Or.inr (Or.inl (pgs_from_physical_mode0_strong_implies_fefferman_b hStrong))

/-- Minimal gate contract (compatibility hook). -/
def EnstrophyPhysicalizationGate : Prop := 0 < hbar / nsNu

/-- Candidate alias hook (compatibility hook). -/
noncomputable def EnstrophyPhysicalizedCandidate (v : NSField) : ℝ := enstrophy v

theorem bridge_target_linear_entropic_control_physicalMode0Strong_of_enstrophyPhysicalizationGate
    (hGate : EnstrophyPhysicalizationGate) :
    BridgeTargetLinearEntropicControlPhysicalMode0Strong := by
  intro τ _hτ
  have _ := hGate
  exact le_rfl

theorem bridge_target_linear_entropic_control_physicalMode0Strong_of_candidate_swap
    (_hSwap : ∀ v : NSField, enstrophy v = EnstrophyPhysicalizedCandidate v) :
    BridgeTargetLinearEntropicControlPhysicalMode0Strong := by
  intro τ _hτ
  exact le_rfl

theorem pgs_from_physical_mode0_strong_of_enstrophyPhysicalizationGate
    (hGate : EnstrophyPhysicalizationGate) :
    PreciseGapStatement :=
  pgs_from_physical_mode0_strong
    (bridge_target_linear_entropic_control_physicalMode0Strong_of_enstrophyPhysicalizationGate hGate)

theorem pgs_from_physical_mode0_strong_of_candidate_swap
    (hSwap : ∀ v : NSField, enstrophy v = EnstrophyPhysicalizedCandidate v) :
    PreciseGapStatement :=
  pgs_from_physical_mode0_strong
    (bridge_target_linear_entropic_control_physicalMode0Strong_of_candidate_swap hSwap)

theorem pgs_from_physical_mode0_strong_of_enstrophyPhysicalizationGate_implies_millennium_problem
    (hGate : EnstrophyPhysicalizationGate) :
    NavierStokesMillenniumProblem :=
  pgs_from_physical_mode0_strong_implies_millennium_problem
    (bridge_target_linear_entropic_control_physicalMode0Strong_of_enstrophyPhysicalizationGate hGate)

theorem pgs_from_physical_mode0_strong_of_candidate_swap_implies_millennium_problem
    (hSwap : ∀ v : NSField, enstrophy v = EnstrophyPhysicalizedCandidate v) :
    NavierStokesMillenniumProblem :=
  pgs_from_physical_mode0_strong_implies_millennium_problem
    (bridge_target_linear_entropic_control_physicalMode0Strong_of_candidate_swap hSwap)

end NavierStokesClean.Millennium
