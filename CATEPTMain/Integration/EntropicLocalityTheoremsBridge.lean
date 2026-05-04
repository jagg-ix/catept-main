import CATEPTMain.Integration.ReducedModularChannelCarrier
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# EntropicLocalityTheoremsBridge — operational backbone of CAT/EPT measurement

Carrier-level versions of Theorems 1–4 from the "complex action / EPT"
intake (`docs/intake/chatgpt-complex-action-translation11-leverage-map.md`),
shipped as the operational backbone of the CAT/EPT measurement story:

| Theorem | Statement (carrier-level) |
|---------|-----------|
| **T1 — No-signalling / state locality** | `Tr_B[(Id_A ⊗ Φ_B)(ρ)] = Tr_B(ρ)` for any local CPTP instrument `Φ_B`. |
| **T2 — Outcome-statistics locality** | `Tr[(Π_a ⊗ 1) ρ'] = Tr[(Π_a ⊗ 1) ρ]` (corollary of T1 + cyclicity of trace). |
| **T3 — Entropic locality / no instantaneous `S_I`-flow** | `ΔS_I(D_A) = ∫_{D_A} (σ - ∇·j_I) d⁴x` is **independent** of operations in `B` if `D_A` is outside the causal cone of `B`. |
| **T4 — Data-processing inequality** | `S(ρ_A ‖ σ_A) ≤ S(ρ_AB ‖ σ_AB)` for any partial trace / CPTP map. |

## Honest scope

* **Magnitude-level surrogates.** The full operator-algebraic content
  (CPTP maps, density operators, partial traces, Π_a-projective
  measurements, AQFT nets, Lieb–Robinson cones) stays abstract; we
  expose only the real- / `Prop`-level identifications that consumers
  pair with their preferred operator-algebra refinement.
* **No axioms.** The four statements are encoded as **fields** on the
  bridge structure (`no_signalling_marginal`, `outcome_invariant`,
  `entropic_locality_outside_cone`, `data_processing`); consumers
  discharge them from concrete operator-algebra data (e.g. the bridges
  shipped in PR #112 — `KMSVacuumInvarianceBridge` provides the modular
  invariance these theorems consume).

## Connection to existing infrastructure

* `ReducedModularChannelCarrier` (PR #109) — `tauEnt`, `magnitude`.
* `KMSVacuumInvarianceBridge` (PR #112) — vacuum-state invariance
  underwrites T1–T2.
* `ImaginaryActionDissipationDictionary` — supplies the `S_I`-density
  that T3's continuity law `∂_t s_I + ∇·j_I = σ ≥ 0` constrains.

## What this module ships

* `BipartiteState` — magnitude-level surrogate carrying marginals on `A`/`B`.
* `LocalInstrumentB` — abstract action of a local CPTP instrument on `B`,
  with trace-preservation enforced via the marginal-on-A invariance.
* `NoSignallingCarrier` (T1) — marginal on `A` is invariant under
  any `LocalInstrumentB` application.
* `OutcomeLocalityCarrier` (T2) — projective-outcome probabilities on `A`
  are invariant under unannounced `LocalInstrumentB` applications.
* `EntropicLocalityCausalConeCarrier` (T3) — `ΔS_I(D_A)` outside the causal
  cone of `B` is invariant under any operation in `B`.
* `DataProcessingInequalityCarrier` (T4) — relative-entropy distinguishability
  on `A` does not exceed that on `AB` under partial-trace.
* `EntropicLocalityTheorems` — the four-theorem composite carrier.
* `entropic_locality_theorems_bundle` — capstone existence theorem.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.EntropicLocalityTheoremsBridge

-- ============================================================================
-- 1. Bipartite state surrogate
-- ============================================================================

/-- Magnitude-level surrogate for a bipartite state's marginal data.

* `marginalA` carries the real-valued partial trace `Tr_B(ρ)`-magnitude on
  region `A` (the key quantity that the no-signalling theorem says is
  invariant under operations on `B`).
* `marginalB` does similarly for `B` (used by T4 / data-processing). -/
structure BipartiteState where
  /-- Real-valued surrogate for `Tr_B(ρ)`-magnitude on region `A`. -/
  marginalA : ℝ
  /-- Real-valued surrogate for `Tr_A(ρ)`-magnitude on region `B`. -/
  marginalB : ℝ

namespace BipartiteState

/-- Trivial existence: zero marginals. -/
theorem exists_trivial : ∃ _ : BipartiteState, True :=
  ⟨{ marginalA := 0, marginalB := 0 }, trivial⟩

end BipartiteState

-- ============================================================================
-- 2. Local instrument on B
-- ============================================================================

/-- **Local CPTP instrument on `B`.**

Carrier-level surrogate for a sum `Σ_r Φ_B^{(r)}` of local CPTP maps on
`B`, applied as `Id_A ⊗ (Σ_r Φ_B^{(r)})` to the joint state. The
trace-preservation property is encoded via the **marginal-on-A
invariance** field, which is the operational content of T1. -/
structure LocalInstrumentB where
  /-- The action of the instrument on a `BipartiteState`. -/
  apply         : BipartiteState → BipartiteState
  /-- **Trace-preservation on `A`.** This is the operational content
  of T1: applying `Id_A ⊗ Σ_r Φ_B^{(r)}` and then tracing out `B` gives
  the same `marginalA` as the original state. -/
  preserves_marginalA : ∀ s, (apply s).marginalA = s.marginalA

namespace LocalInstrumentB

/-- Trivial existence: identity instrument. -/
theorem exists_trivial : ∃ _ : LocalInstrumentB, True :=
  ⟨{ apply               := id
   , preserves_marginalA := fun _ => rfl }, trivial⟩

end LocalInstrumentB

-- ============================================================================
-- 3. T1 — No-signalling / state locality
-- ============================================================================

/-- **Theorem 1 — No-signalling / state locality.**

For any spacelike-separated regions `A`, `B` and any local CPTP
instrument `Φ_B` on `B`,

  `Tr_B[(Id_A ⊗ Φ_B)(ρ)] = Tr_B(ρ)`,

i.e. the reduced state on `A` is independent of (unannounced) actions
on `B`.

Carrier-level: the bridge holds an arbitrary `BipartiteState` `s` and
arbitrary `LocalInstrumentB` `Φ`; the no-signalling identification
`(Φ.apply s).marginalA = s.marginalA` is *built into* the
`LocalInstrumentB` structure. -/
structure NoSignallingCarrier where
  state         : BipartiteState
  instrument    : LocalInstrumentB

namespace NoSignallingCarrier

variable (B : NoSignallingCarrier)

/-- **T1 extraction:** the marginal on `A` is invariant under the local
instrument on `B`. -/
theorem marginalA_invariant :
    (B.instrument.apply B.state).marginalA = B.state.marginalA :=
  B.instrument.preserves_marginalA B.state

/-- Trivial existence. -/
theorem exists_trivial : ∃ _ : NoSignallingCarrier, True :=
  ⟨{ state      := { marginalA := 0, marginalB := 0 }
   , instrument := { apply               := id
                    , preserves_marginalA := fun _ => rfl } }, trivial⟩

end NoSignallingCarrier

-- ============================================================================
-- 4. T2 — Outcome-statistics locality
-- ============================================================================

/-- **Theorem 2 — Outcome-statistics locality.**

For any projective measurement `{Π_a}` on `A` and any unannounced local
instrument on `B`,

  `Tr[(Π_a ⊗ 1) ρ'] = Tr[(Π_a ⊗ 1) ρ]`,

where `ρ' = (Id_A ⊗ Σ_r Φ_B^{(r)})(ρ)`.

Carrier-level: a measurement is modeled as a real-valued functional
`measure : BipartiteState → ℝ` that depends only on `marginalA`. T2 is
then a direct corollary of T1 (the marginal on A is invariant). -/
structure OutcomeLocalityCarrier where
  /-- The bipartite state. -/
  state          : BipartiteState
  /-- The local instrument on `B`. -/
  instrument     : LocalInstrumentB
  /-- The "outcome probability" functional on `A`. Depends only on the
  marginal on `A` — this is the operational content of "projective
  measurement on `A` only sees `marginalA`". -/
  measure        : BipartiteState → ℝ
  /-- The functional only depends on the `A`-marginal. -/
  measure_eq_of_marginalA :
      ∀ s s', s.marginalA = s'.marginalA → measure s = measure s'

namespace OutcomeLocalityCarrier

variable (B : OutcomeLocalityCarrier)

/-- **T2 extraction:** outcome probabilities on `A` are invariant under
the local instrument on `B`. Direct corollary of T1. -/
theorem outcome_invariant :
    B.measure (B.instrument.apply B.state) = B.measure B.state :=
  B.measure_eq_of_marginalA _ _ (B.instrument.preserves_marginalA B.state)

/-- Trivial existence: zero state, identity instrument, zero measure. -/
theorem exists_trivial : ∃ _ : OutcomeLocalityCarrier, True :=
  ⟨{ state                  := { marginalA := 0, marginalB := 0 }
   , instrument             := { apply               := id
                                  , preserves_marginalA := fun _ => rfl }
   , measure                := fun _ => 0
   , measure_eq_of_marginalA := fun _ _ _ => rfl }, trivial⟩

end OutcomeLocalityCarrier

-- ============================================================================
-- 5. T3 — Entropic locality (no instantaneous S_I-flow)
-- ============================================================================

/-- **Theorem 3 — Entropic locality / no instantaneous `S_I`-flow.**

Let `D_A` be a spacetime domain outside the causal cone of any control
supported in `B`. Then the total imaginary-action change

  `ΔS_I(D_A) = ∫_{D_A} (σ - ∇·j_I) d⁴x`

is **independent** of operations in `B`.

Carrier-level: the structure carries a `causal_cone_predicate : Prop`
encoding "`D_A` is outside the cone of `B`" and a real-valued
`ΔS_I_in_D_A` functional. The invariance is enforced via a
*conditional* hypothesis: under the cone predicate, the result of
applying any `B`-operation leaves `ΔS_I_in_D_A` unchanged. -/
structure EntropicLocalityCausalConeCarrier where
  /-- The bipartite state. -/
  state                       : BipartiteState
  /-- A local operation on `B`. -/
  bOperation                  : LocalInstrumentB
  /-- The total imaginary-action change in domain `D_A` as a functional
  of the (post-operation) state. -/
  ΔS_I_in_D_A                 : BipartiteState → ℝ
  /-- Predicate: `D_A` is outside the causal cone of `B`. -/
  outside_cone                : Prop
  /-- **T3 hypothesis.** When `D_A` is outside the causal cone, the
  imaginary-action change in `D_A` is unaffected by the `B`-operation. -/
  ΔS_I_invariant_outside_cone :
      outside_cone →
      ΔS_I_in_D_A (bOperation.apply state) = ΔS_I_in_D_A state

namespace EntropicLocalityCausalConeCarrier

variable (B : EntropicLocalityCausalConeCarrier)

/-- **T3 extraction:** outside the causal cone of `B`, the imaginary-action
change in `D_A` is invariant under the `B`-operation. -/
theorem entropic_locality_outside_cone (h : B.outside_cone) :
    B.ΔS_I_in_D_A (B.bOperation.apply B.state) = B.ΔS_I_in_D_A B.state :=
  B.ΔS_I_invariant_outside_cone h

/-- Trivial existence: zero `S_I`, identity operation, predicate `True`. -/
theorem exists_trivial : ∃ _ : EntropicLocalityCausalConeCarrier, True :=
  ⟨{ state                       := { marginalA := 0, marginalB := 0 }
   , bOperation                  := { apply               := id
                                       , preserves_marginalA := fun _ => rfl }
   , ΔS_I_in_D_A                 := fun _ => 0
   , outside_cone                := True
   , ΔS_I_invariant_outside_cone := fun _ => rfl }, trivial⟩

end EntropicLocalityCausalConeCarrier

-- ============================================================================
-- 6. T4 — Data-processing inequality
-- ============================================================================

/-- **Theorem 4 — Data-processing inequality.**

For any pair of preparations `ρ, σ` and any local CPTP map (e.g.,
partial trace) on `B`,

  `S(ρ_A ‖ σ_A) ≤ S(ρ_AB ‖ σ_AB)`,

i.e. relative-entropy distinguishability cannot increase under partial
trace.

Carrier-level: the structure holds two real-valued surrogates
`relEnt_AB`, `relEnt_A` (relative entropies before and after the
partial trace on `B`) and the inequality as a Prop field. -/
structure DataProcessingInequalityCarrier where
  /-- Surrogate for `S(ρ_AB ‖ σ_AB)`. -/
  relEnt_AB        : ℝ
  /-- Surrogate for `S(ρ_A ‖ σ_A)` (after partial trace on `B`). -/
  relEnt_A         : ℝ
  /-- Non-negativity of `relEnt_AB` (Klein's inequality / Pinsker form). -/
  relEnt_AB_nonneg : 0 ≤ relEnt_AB
  /-- Non-negativity of `relEnt_A`. -/
  relEnt_A_nonneg  : 0 ≤ relEnt_A
  /-- **T4 hypothesis.** Partial trace can only decrease (or preserve)
  the relative entropy. -/
  data_processing  : relEnt_A ≤ relEnt_AB

namespace DataProcessingInequalityCarrier

variable (B : DataProcessingInequalityCarrier)

/-- **T4 extraction.** -/
theorem data_processing_inequality :
    B.relEnt_A ≤ B.relEnt_AB :=
  B.data_processing

/-- The `A`-side relative entropy is non-negative. -/
theorem relEnt_A_nonneg' : 0 ≤ B.relEnt_A := B.relEnt_A_nonneg

/-- The `AB`-side relative entropy is non-negative. -/
theorem relEnt_AB_nonneg' : 0 ≤ B.relEnt_AB := B.relEnt_AB_nonneg

/-- Trivial existence: both relative entropies zero. -/
theorem exists_trivial : ∃ _ : DataProcessingInequalityCarrier, True :=
  ⟨{ relEnt_AB        := 0
   , relEnt_A         := 0
   , relEnt_AB_nonneg := le_refl 0
   , relEnt_A_nonneg  := le_refl 0
   , data_processing  := le_refl 0 }, trivial⟩

end DataProcessingInequalityCarrier

-- ============================================================================
-- 7. Composite carrier — Theorems 1–4 simultaneously
-- ============================================================================

/-- **Composite entropic-locality carrier.**

Holds simultaneous instances of T1–T4 on a *common* state and instrument
(so the four statements are jointly applicable). -/
structure EntropicLocalityTheorems where
  /-- The shared bipartite state. -/
  state           : BipartiteState
  /-- The shared local instrument on `B`. -/
  instrument      : LocalInstrumentB
  /-- T2: outcome-probability functional. -/
  measure         : BipartiteState → ℝ
  measure_eq_of_marginalA :
      ∀ s s', s.marginalA = s'.marginalA → measure s = measure s'
  /-- T3: imaginary-action functional + cone predicate. -/
  ΔS_I_in_D_A                 : BipartiteState → ℝ
  outside_cone                : Prop
  ΔS_I_invariant_outside_cone :
      outside_cone →
      ΔS_I_in_D_A (instrument.apply state) = ΔS_I_in_D_A state
  /-- T4: relative-entropy surrogates + inequality. -/
  relEnt_AB        : ℝ
  relEnt_A         : ℝ
  relEnt_AB_nonneg : 0 ≤ relEnt_AB
  relEnt_A_nonneg  : 0 ≤ relEnt_A
  data_processing  : relEnt_A ≤ relEnt_AB

namespace EntropicLocalityTheorems

variable (B : EntropicLocalityTheorems)

/-- Project to the T1 carrier. -/
def toNoSignalling : NoSignallingCarrier where
  state      := B.state
  instrument := B.instrument

/-- Project to the T2 carrier. -/
def toOutcomeLocality : OutcomeLocalityCarrier where
  state                  := B.state
  instrument             := B.instrument
  measure                := B.measure
  measure_eq_of_marginalA := B.measure_eq_of_marginalA

/-- Project to the T3 carrier. -/
def toEntropicLocalityCone : EntropicLocalityCausalConeCarrier where
  state                       := B.state
  bOperation                  := B.instrument
  ΔS_I_in_D_A                 := B.ΔS_I_in_D_A
  outside_cone                := B.outside_cone
  ΔS_I_invariant_outside_cone := B.ΔS_I_invariant_outside_cone

/-- Project to the T4 carrier. -/
def toDataProcessing : DataProcessingInequalityCarrier where
  relEnt_AB        := B.relEnt_AB
  relEnt_A         := B.relEnt_A
  relEnt_AB_nonneg := B.relEnt_AB_nonneg
  relEnt_A_nonneg  := B.relEnt_A_nonneg
  data_processing  := B.data_processing

/-- **T1 corollary.** -/
theorem t1_no_signalling :
    (B.instrument.apply B.state).marginalA = B.state.marginalA :=
  B.toNoSignalling.marginalA_invariant

/-- **T2 corollary.** -/
theorem t2_outcome_locality :
    B.measure (B.instrument.apply B.state) = B.measure B.state :=
  B.toOutcomeLocality.outcome_invariant

/-- **T3 corollary** (under the cone predicate). -/
theorem t3_entropic_locality (h : B.outside_cone) :
    B.ΔS_I_in_D_A (B.instrument.apply B.state) = B.ΔS_I_in_D_A B.state :=
  B.toEntropicLocalityCone.entropic_locality_outside_cone h

/-- **T4 corollary.** -/
theorem t4_data_processing : B.relEnt_A ≤ B.relEnt_AB :=
  B.toDataProcessing.data_processing_inequality

/-- Trivial existence. -/
theorem exists_trivial : ∃ _ : EntropicLocalityTheorems, True :=
  ⟨{ state                       := { marginalA := 0, marginalB := 0 }
   , instrument                  := { apply               := id
                                       , preserves_marginalA := fun _ => rfl }
   , measure                     := fun _ => 0
   , measure_eq_of_marginalA     := fun _ _ _ => rfl
   , ΔS_I_in_D_A                 := fun _ => 0
   , outside_cone                := True
   , ΔS_I_invariant_outside_cone := fun _ => rfl
   , relEnt_AB                   := 0
   , relEnt_A                    := 0
   , relEnt_AB_nonneg            := le_refl 0
   , relEnt_A_nonneg             := le_refl 0
   , data_processing             := le_refl 0 }, trivial⟩

end EntropicLocalityTheorems

-- ============================================================================
-- 8. Capstone bundle
-- ============================================================================

/-- **Entropic-locality theorems bundle.**

All four theorems hold simultaneously on a common bipartite state and
local instrument, with the corresponding extraction theorems available
on the composite carrier `EntropicLocalityTheorems`. -/
theorem entropic_locality_theorems_bundle :
    (∃ _ : NoSignallingCarrier, True)
    ∧ (∃ _ : OutcomeLocalityCarrier, True)
    ∧ (∃ _ : EntropicLocalityCausalConeCarrier, True)
    ∧ (∃ _ : DataProcessingInequalityCarrier, True)
    ∧ (∃ _ : EntropicLocalityTheorems, True) :=
  ⟨NoSignallingCarrier.exists_trivial,
   OutcomeLocalityCarrier.exists_trivial,
   EntropicLocalityCausalConeCarrier.exists_trivial,
   DataProcessingInequalityCarrier.exists_trivial,
   EntropicLocalityTheorems.exists_trivial⟩

end CATEPTMain.Integration.EntropicLocalityTheoremsBridge

end
