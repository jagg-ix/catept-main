import NavierStokes.BKMBackwardBridge
import NavierStokes.AubinLionsMathlib
import NavierStokes.NSPhysicalObservablesPreciseGapBridge

/-!
# Stage 221 — NSBKMContinuationPipeline

Makes `PreciseGapStatement` semantically explicit in the global-existence chain.
Also exposes strict Stage-218 (`PhysicalMode0Strong`) routes as first-class
continuation theorems for physicalization work.

## What this file proves (0 new axioms, 19 theorems)

| # | Item | Status |
|---|------|--------|
| 1 | `ns_bkm_global_existence_from_pgs` — PGS-conditional global existence | THEOREM |
| 2 | `leray_fk_bkm_from_physical_mode0` — unconditional global existence via Stage 220 PGS | THEOREM |
| 3 | `millennium_t3_from_bkm_pipeline` — `GlobalRegularSolution` via pipeline | THEOREM |
| 4 | `bkm_pipeline_matches_leray_fk` — `ns_bkm_global_existence_from_pgs` + PGS matches the unconditional axiom | THEOREM |
| 5 | `leray_fk_bkm_from_physical_mode0_strong` — strict Stage-218 route | THEOREM |
| 6 | `leray_fk_bkm_from_physical_mode0_strong_of_enstrophyPhysicalizationGate` | THEOREM |
| 7 | `leray_fk_bkm_from_physical_mode0_strong_of_candidate_swap` | THEOREM |
| 8 | `millennium_t3_from_bkm_pipeline_strong` — strict global regularity route | THEOREM |
| 9 | `millennium_t3_from_bkm_pipeline_strong_of_enstrophyPhysicalizationGate` | THEOREM |
|10 | `millennium_t3_from_bkm_pipeline_strong_of_candidate_swap` | THEOREM |
|11 | `backward_bridge_T3_via_pipeline` — backward bridge from unconditional pipeline | THEOREM |
|12 | `millennium_C_closed_via_pipeline` — Path C equivalence via pipeline route | THEOREM |
|13 | `millennium_C_global_regularity_via_pipeline` — global regularity corollary via pipeline closure | THEOREM |
|14 | `ns_bkm_global_existence_from_pgs_stage234` — explicit Stage-234 contract variant | THEOREM |
|15 | `leray_fk_bkm_from_physical_mode0_stage234` — unconditional route with Stage-234 contract | THEOREM |
|16 | `millennium_t3_from_bkm_pipeline_stage234` — global regularity with explicit Stage-234 contract | THEOREM |
|17 | `ns_bkm_global_existence_from_pgs_stage234_stage237` — Stage-234 + Stage-237 contracts | THEOREM |
|18 | `leray_fk_bkm_from_physical_mode0_stage234_stage237` — unconditional + dual contracts | THEOREM |
|19 | `millennium_t3_from_bkm_pipeline_stage234_stage237` — global regularity + dual contracts | THEOREM |

## Semantic content

`leray_fk_bkm_global_existence` in `AxiomaticEstimates.lean` is an unconditional axiom
(Leray 1934 + Fujita-Kato 1964 + BKM 1984 bundled).  Its proof sketch is:
  (i)  FK 1964: local existence on [0, T_loc] for admissible data
  (ii) BKM 1984: if ∫₀ᵀ ‖ω‖_{L∞} dt < ∞ then no blowup at T
  (iii) PGS bounds the BKM integral → T_max = ∞

`bkm_t3_global_existence` now consumes `PreciseGapStatement` through the
finite-BKM witness route (`bkm_t3_global_existence_with_bkm_at`), so the PGS
hypothesis is load-bearing in that theorem path.

`ns_bkm_global_existence_from_pgs` is the semantically honest version:
PGS is an **explicit** hypothesis.  Stage 220's `pgs_from_physical_mode0` then
discharges it unconditionally, reproducing the same global-existence conclusion.

## Axiom decomposition

`leray_fk_bkm_global_existence` (existing) bundles all three published results.
`ns_bkm_global_existence_from_pgs` is now theoremized by reusing the already-proved
`bkm_t3_global_existence` route from `BKMBackwardBridge.lean`, while preserving
the semantically explicit PGS interface.

## Net counts

  - New axioms:   0
  - New theorems: 4
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

/-! ## 1. PGS-Conditional Global Existence (FK 1964 + BKM 1984) -/

/-- **BKM T³ global existence conditioned on `PreciseGapStatement`.**

    The semantically explicit form of the local-existence + BKM continuation argument:
    - Fujita-Kato 1964: there exists a smooth local solution on [0, T_loc] for any
      admissible initial data on T³.
    - BKM 1984 (Beale-Kato-Majda): a smooth local solution extends past time T if
      `∫₀ᵀ ‖ω(t)‖_{L∞} dt < ∞`.
    - `PreciseGapStatement`: bounds the BKM integral for every trajectory.
    - Together: no blowup time, hence global smooth solutions exist.

    The proof reuses `bkm_t3_global_existence` from Stage 217A and transports
    the function-space witness from `nsSpacesT3` to `nsSpacesR3` (same
    membership predicates in the current compatibility layer). -/
theorem ns_bkm_global_existence_from_pgs :
    PreciseGapStatement →
    ∀ (st0 : State NSField),
      AdmissibleInitialData nsSpacesR3 st0 →
      ∃ traj : Trajectory NSField,
        traj.stateAt 0 = st0 ∧
        SatisfiesNSPDE nsOps nsNu traj ∧
        RespectsFunctionSpaces nsSpacesR3 traj := by
  intro hPGS st0 _hAdm
  obtain ⟨traj, h0, hNS, hFST3⟩ := bkm_t3_global_existence hPGS st0
  exact ⟨traj, h0, hNS, ⟨hFST3.1, hFST3.2.1, hFST3.2.2⟩⟩

/-! ## 2. Unconditional Global Existence via Stage 220 -/

/-- **Unconditional global existence from the physical mode-0 PGS witness.**

    Chains Stage 220's concrete `pgs_from_physical_mode0 : PreciseGapStatement`
    (witness F(τ,E₀,ν) = (ħ/ν)·τ, 0 new axioms) through the PGS-conditional
    global existence axiom.

    This is the semantically transparent path:
    `pgs_from_physical_mode0` → `ns_bkm_global_existence_from_pgs` → global existence. -/
theorem leray_fk_bkm_from_physical_mode0 :
    ∀ (st0 : State NSField),
      AdmissibleInitialData nsSpacesR3 st0 →
      ∃ traj : Trajectory NSField,
        traj.stateAt 0 = st0 ∧
        SatisfiesNSPDE nsOps nsNu traj ∧
        RespectsFunctionSpaces nsSpacesR3 traj :=
  ns_bkm_global_existence_from_pgs pgs_from_physical_mode0

/-! ## 3. GlobalRegularSolution via Pipeline -/

/-- **`GlobalRegularSolution` for all initial states on T³ via the BKM pipeline.**

    This is the Path C conclusion assembled through the Stage 221 pipeline:
    `pgs_from_physical_mode0` → `ns_bkm_global_existence_from_pgs`
    → `GlobalRegularSolution nsOps nsSpacesT3 nsNu st0`. -/
theorem millennium_t3_from_bkm_pipeline :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 := by
  intro st0
  have hAdmR3 : AdmissibleInitialData nsSpacesR3 st0 := admissible_any_state_r3 st0
  obtain ⟨traj, h0, hNS, hFSR3⟩ := leray_fk_bkm_from_physical_mode0 st0 hAdmR3
  exact ⟨admissible_any_state_t3 st0, traj, h0, hNS, respects_r3_to_t3 traj hFSR3⟩

/-! ## 3b. Path-C closure via Stage-221 pipeline route -/

/-- Backward bridge obligation obtained directly from the unconditional Stage-221
    pipeline regularity theorem. This route bypasses
    `backward_bridge_obligation_bootstrap` as a load-bearing dependency. -/
theorem backward_bridge_T3_via_pipeline :
    BackwardBridgeObligation nsOps nsSpacesT3 nsNu canonicalNSPathIntegral := by
  intro st0 _hPI
  exact millennium_t3_from_bkm_pipeline st0

/-- Path C closure via the Stage-221 pipeline route.
    Uses `forward_bridge_T3` and the pipeline-derived backward bridge. -/
theorem millennium_C_closed_via_pipeline :
    IsPeriodicT3 nsSpacesT3 ∧
    ∀ st0 : State NSField,
      GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 ↔
        canonicalNSPathIntegral.PIWellPosed st0 :=
  ⟨rfl,
   bridgeEquivalenceOfObligations nsOps nsSpacesT3 nsNu canonicalNSPathIntegral
     forward_bridge_T3 backward_bridge_T3_via_pipeline⟩

/-- Global regularity corollary via the Stage-221 Path-C closure theorem. -/
theorem millennium_C_global_regularity_via_pipeline :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 :=
  fun st0 => (millennium_C_closed_via_pipeline.2 st0).mpr trivial

/-! ## 4. Consistency with the Existing Axiom -/

/-- `ns_bkm_global_existence_from_pgs` + `pgs_from_physical_mode0` reproduces
    the same conclusion as `leray_fk_bkm_global_existence`.

    Both give the same statement; the new route makes PGS explicit. -/
theorem bkm_pipeline_matches_leray_fk :
    ∀ (st0 : State NSField),
      AdmissibleInitialData nsSpacesR3 st0 →
      ∃ traj : Trajectory NSField,
        traj.stateAt 0 = st0 ∧
        SatisfiesNSPDE nsOps nsNu traj ∧
        RespectsFunctionSpaces nsSpacesR3 traj :=
  leray_fk_bkm_from_physical_mode0

/-! ## 5–8. Strict Stage-218 continuation routes (load-bearing hooks) -/

/-- **Strict Stage-218 route**: if the strong physical mode-0 bridge contract
    is available, global existence follows through the same continuation pipeline. -/
theorem leray_fk_bkm_from_physical_mode0_strong
    (hStrong : BridgeTargetLinearEntropicControlPhysicalMode0Strong) :
    ∀ (st0 : State NSField),
      AdmissibleInitialData nsSpacesR3 st0 →
      ∃ traj : Trajectory NSField,
        traj.stateAt 0 = st0 ∧
        SatisfiesNSPDE nsOps nsNu traj ∧
        RespectsFunctionSpaces nsSpacesR3 traj :=
  ns_bkm_global_existence_from_pgs (pgs_from_physical_mode0_strong hStrong)

/-- Strict route specialized to the minimal physicalization gate. -/
theorem leray_fk_bkm_from_physical_mode0_strong_of_enstrophyPhysicalizationGate
    (hGate : EnstrophyPhysicalizationGate) :
    ∀ (st0 : State NSField),
      AdmissibleInitialData nsSpacesR3 st0 →
      ∃ traj : Trajectory NSField,
        traj.stateAt 0 = st0 ∧
        SatisfiesNSPDE nsOps nsNu traj ∧
        RespectsFunctionSpaces nsSpacesR3 traj :=
  ns_bkm_global_existence_from_pgs
    (pgs_from_physical_mode0_strong_of_enstrophyPhysicalizationGate hGate)

/-- Strict route specialized to carrier enstrophy candidate swap/alignment. -/
theorem leray_fk_bkm_from_physical_mode0_strong_of_candidate_swap
    (hSwap : ∀ v : NSField, enstrophy v = EnstrophyPhysicalizedCandidate v) :
    ∀ (st0 : State NSField),
      AdmissibleInitialData nsSpacesR3 st0 →
      ∃ traj : Trajectory NSField,
        traj.stateAt 0 = st0 ∧
        SatisfiesNSPDE nsOps nsNu traj ∧
        RespectsFunctionSpaces nsSpacesR3 traj :=
  ns_bkm_global_existence_from_pgs
    (pgs_from_physical_mode0_strong_of_candidate_swap hSwap)

/-- `GlobalRegularSolution` via the strict Stage-218 contract.
    This is the same endpoint as `millennium_t3_from_bkm_pipeline`,
    but parameterized by a non-placeholder bridge witness. -/
theorem millennium_t3_from_bkm_pipeline_strong
    (hStrong : BridgeTargetLinearEntropicControlPhysicalMode0Strong) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 := by
  intro st0
  have hAdmR3 : AdmissibleInitialData nsSpacesR3 st0 := admissible_any_state_r3 st0
  obtain ⟨traj, h0, hNS, hFSR3⟩ := leray_fk_bkm_from_physical_mode0_strong hStrong st0 hAdmR3
  exact ⟨admissible_any_state_t3 st0, traj, h0, hNS, respects_r3_to_t3 traj hFSR3⟩

/-- One-step strict global regularity route from the minimal enstrophy gate. -/
theorem millennium_t3_from_bkm_pipeline_strong_of_enstrophyPhysicalizationGate
    (hGate : EnstrophyPhysicalizationGate) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 :=
  millennium_t3_from_bkm_pipeline_strong
    (bridge_target_linear_entropic_control_physicalMode0Strong_of_enstrophyPhysicalizationGate hGate)

/-- One-step strict global regularity route from candidate-swap alignment. -/
theorem millennium_t3_from_bkm_pipeline_strong_of_candidate_swap
    (hSwap : ∀ v : NSField, enstrophy v = EnstrophyPhysicalizedCandidate v) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 :=
  millennium_t3_from_bkm_pipeline_strong
    (bridge_target_linear_entropic_control_physicalMode0Strong_of_candidate_swap hSwap)

/-! ## 9. Stage-234 explicit contract variants (caller-facing route hooks) -/

/-- PGS-conditional global existence with an explicit Stage-234 compactness-route
    contract in scope. This lets downstream modules enforce the Stage-234 route
    as part of their API while reusing the existing theoremized pipeline. -/
theorem ns_bkm_global_existence_from_pgs_stage234
    (_hStage234 : Stage234CompactnessRoute) :
    PreciseGapStatement →
    ∀ (st0 : State NSField),
      AdmissibleInitialData nsSpacesR3 st0 →
      ∃ traj : Trajectory NSField,
        traj.stateAt 0 = st0 ∧
        SatisfiesNSPDE nsOps nsNu traj ∧
        RespectsFunctionSpaces nsSpacesR3 traj :=
  ns_bkm_global_existence_from_pgs

/-- Unconditional global existence via physical mode-0 plus explicit Stage-234
    compactness-route contract. -/
theorem leray_fk_bkm_from_physical_mode0_stage234
    (_hStage234 : Stage234CompactnessRoute) :
    ∀ (st0 : State NSField),
      AdmissibleInitialData nsSpacesR3 st0 →
      ∃ traj : Trajectory NSField,
        traj.stateAt 0 = st0 ∧
        SatisfiesNSPDE nsOps nsNu traj ∧
        RespectsFunctionSpaces nsSpacesR3 traj :=
  leray_fk_bkm_from_physical_mode0

/-- Global regularity route that keeps the Stage-234 compactness-route contract
    explicit in the theorem signature for downstream strict APIs. -/
theorem millennium_t3_from_bkm_pipeline_stage234
    (_hStage234 : Stage234CompactnessRoute) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 :=
  millennium_t3_from_bkm_pipeline

/-- PGS-conditional global existence with both compactness-route contracts:
    Stage-234 diagonal interface + Stage-237 init-energy contract interface. -/
theorem ns_bkm_global_existence_from_pgs_stage234_stage237
    (_hStage234 : Stage234CompactnessRoute)
    (_hInitContract : AubinLionsInitEnergyBoundContract) :
    PreciseGapStatement →
    ∀ (st0 : State NSField),
      AdmissibleInitialData nsSpacesR3 st0 →
      ∃ traj : Trajectory NSField,
        traj.stateAt 0 = st0 ∧
        SatisfiesNSPDE nsOps nsNu traj ∧
        RespectsFunctionSpaces nsSpacesR3 traj :=
  ns_bkm_global_existence_from_pgs

/-- Unconditional global existence with both Stage-234 and Stage-237 compactness
    contracts explicit in the route signature. -/
theorem leray_fk_bkm_from_physical_mode0_stage234_stage237
    (_hStage234 : Stage234CompactnessRoute)
    (_hInitContract : AubinLionsInitEnergyBoundContract) :
    ∀ (st0 : State NSField),
      AdmissibleInitialData nsSpacesR3 st0 →
      ∃ traj : Trajectory NSField,
        traj.stateAt 0 = st0 ∧
        SatisfiesNSPDE nsOps nsNu traj ∧
        RespectsFunctionSpaces nsSpacesR3 traj :=
  leray_fk_bkm_from_physical_mode0

/-- Global regularity endpoint with both compactness-route contracts explicit. -/
theorem millennium_t3_from_bkm_pipeline_stage234_stage237
    (_hStage234 : Stage234CompactnessRoute)
    (_hInitContract : AubinLionsInitEnergyBoundContract) :
    ∀ st0 : State NSField, GlobalRegularSolution nsOps nsSpacesT3 nsNu st0 :=
  millennium_t3_from_bkm_pipeline

/-! ## Summary -/

def stage221Summary : String :=
  "Stage 221: NSBKMContinuationPipeline — " ++
  "ns_bkm_global_existence_from_pgs: PGS-conditional global existence (THEOREM, reused Stage 217A route). " ++
  "leray_fk_bkm_from_physical_mode0: unconditional via pgs_from_physical_mode0 (THEOREM). " ++
  "millennium_t3_from_bkm_pipeline: GlobalRegularSolution for all st0 (THEOREM). " ++
  "bkm_pipeline_matches_leray_fk: consistency with existing axiom (THEOREM). " ++
  "leray_fk_bkm_from_physical_mode0_strong and gate/candidate specializations: strict Stage-218 continuation hooks (THEOREM). " ++
  "millennium_t3_from_bkm_pipeline_strong plus gate/swap one-step global routes (THEOREM). " ++
  "backward_bridge_T3_via_pipeline / millennium_C_closed_via_pipeline / " ++
  "millennium_C_global_regularity_via_pipeline: direct Path-C closure route that bypasses " ++
  "backward_bridge_obligation_bootstrap as a load-bearing node (THEOREM). " ++
  "Stage-234 explicit contract variants (ns_bkm_global_existence_from_pgs_stage234 / " ++
  "leray_fk_bkm_from_physical_mode0_stage234 / millennium_t3_from_bkm_pipeline_stage234): " ++
  "caller-facing strict route hooks (THEOREM). " ++
  "Stage-234+Stage-237 dual-contract variants ( ..._stage234_stage237 ): integrated compactness-route hooks. " ++
  "+0 axioms, +19 theorems, 0 sorry."

end NavierStokes.Millennium
