import Mathlib.Data.Complex.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Tactic.Ring
import NavierStokesClean.CATEPT.ModularFlowKucharBridge

/-!
# Measurement-as-Communication Everett Bridge (Clean Surface)

This module ports the core non-vacuous instrument/channel formalization into
`NavierStokesClean` and keeps it independent from legacy repo-specific NS objects.

It provides:
- finite instrument decomposition over a von-Neumann-style observable carrier,
- measurement-as-communication equivalence theorem,
- Bell inconsistency formulation and refutation theorem.
-/

set_option autoImplicit false

open scoped BigOperators

namespace NavierStokesClean.CATEPT
namespace MeasurementCommunicationEverettBridge

noncomputable section

/-- Minimal von-Neumann-style observable interface. -/
structure VonNeumannObservableModel where
  Obs : Type
  one : Obs

/-- Normal-state interface as complex expectation functionals. -/
def NormalState (M : VonNeumannObservableModel) : Type :=
  M.Obs → ℂ

/-- Heisenberg-picture CP map (interface layer). -/
structure CPMap (M : VonNeumannObservableModel) where
  toFun : M.Obs → M.Obs

/-- Unital CP map (Heisenberg dual of CPTP). -/
structure UCPTMap (M : VonNeumannObservableModel) extends CPMap M where
  preserves_one : toFun M.one = M.one

/-- Schrödinger-dual state update `(Φ_*(ρ))(A) = ρ(Φ(A))`. -/
def schrodingerDual
    {M : VonNeumannObservableModel}
    (Φ : UCPTMap M) (ρ : NormalState M) : NormalState M :=
  fun A => ρ (Φ.toFun A)

/-- Communication interpretation of the same nonselective update. -/
def communicationOutput
    {M : VonNeumannObservableModel}
    (Φ : UCPTMap M) (ρ : NormalState M) : NormalState M :=
  schrodingerDual Φ ρ

/-- Finite instrument decomposition with nonselective channel identity. -/
structure FiniteInstrument
    (M : VonNeumannObservableModel) (ι : Type) [Fintype ι] where
  channel : UCPTMap M
  component : ι → CPMap M
  sum_components :
    ∀ (ρ : NormalState M) (A : M.Obs),
      (schrodingerDual channel ρ) A = ∑ i, ρ ((component i).toFun A)

/-- Outcome weight `pᵢ = ρ(Φᵢ(1))`. -/
def outcomeWeight
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι) (ρ : NormalState M) (i : ι) : ℂ :=
  ρ ((inst.component i).toFun M.one)

/-- Posterior branch state `ρᵢ(A) = ρ(Φᵢ(A))/pᵢ` when `pᵢ ≠ 0`. -/
def posteriorState
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι)
    (ρ : NormalState M)
    (_hNonzero : ∀ i : ι, outcomeWeight inst ρ i ≠ 0) :
    ι → NormalState M :=
  fun i A => ρ ((inst.component i).toFun A) / outcomeWeight inst ρ i

/-- Component reconstruction `ρ(Φᵢ(A)) = pᵢ·ρᵢ(A)`. -/
theorem component_reconstruction
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι)
    (ρ : NormalState M)
    (hNonzero : ∀ i : ι, outcomeWeight inst ρ i ≠ 0)
    (i : ι) (A : M.Obs) :
    ρ ((inst.component i).toFun A) =
      outcomeWeight inst ρ i * posteriorState inst ρ hNonzero i A := by
  have hp : outcomeWeight inst ρ i ≠ 0 := hNonzero i
  calc
    ρ ((inst.component i).toFun A)
        = outcomeWeight inst ρ i * (ρ ((inst.component i).toFun A) / outcomeWeight inst ρ i) := by
            exact (mul_div_cancel₀ (ρ ((inst.component i).toFun A)) hp).symm
    _ = outcomeWeight inst ρ i * posteriorState inst ρ hNonzero i A := by
          simp [posteriorState]

/-- Nonselective update equals affine mixture over posterior branches. -/
theorem nonselective_update_eq_branch_mixture
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι)
    (ρ : NormalState M)
    (hNonzero : ∀ i : ι, outcomeWeight inst ρ i ≠ 0)
    (A : M.Obs) :
    (schrodingerDual inst.channel ρ) A =
      ∑ i, outcomeWeight inst ρ i * posteriorState inst ρ hNonzero i A := by
  classical
  calc
    (schrodingerDual inst.channel ρ) A
        = ∑ i, ρ ((inst.component i).toFun A) := inst.sum_components ρ A
    _ = ∑ i, outcomeWeight inst ρ i * posteriorState inst ρ hNonzero i A := by
      refine Finset.sum_congr rfl ?_
      intro i _
      exact component_reconstruction inst ρ hNonzero i A

/-- Everett relative-state decomposition data. -/
structure RelativeStateDecomposition
    (M : VonNeumannObservableModel) (ι : Type) [Fintype ι] where
  global : NormalState M
  weight : ι → ℂ
  branch : ι → NormalState M
  decomposition : ∀ A : M.Obs, global A = ∑ i, weight i * branch i A

/-- Instrument-induced relative-state decomposition. -/
def inducedRelativeStateDecomposition
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι)
    (ρ : NormalState M)
    (hNonzero : ∀ i : ι, outcomeWeight inst ρ i ≠ 0) :
    RelativeStateDecomposition M ι where
  global := communicationOutput inst.channel ρ
  weight := outcomeWeight inst ρ
  branch := posteriorState inst ρ hNonzero
  decomposition := by
    intro A
    simpa [communicationOutput] using
      nonselective_update_eq_branch_mixture inst ρ hNonzero A

/-- Core theorem: branch-mixture clause iff channel-output clause. -/
theorem measurement_as_communication_equivalence
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι)
    (ρ : NormalState M)
    (hNonzero : ∀ i : ι, outcomeWeight inst ρ i ≠ 0)
    (ρ' : NormalState M) :
    (∀ A : M.Obs,
      ρ' A = ∑ i, outcomeWeight inst ρ i * posteriorState inst ρ hNonzero i A) ↔
    ρ' = communicationOutput inst.channel ρ := by
  constructor
  · intro hEq
    funext A
    calc
      ρ' A = ∑ i, outcomeWeight inst ρ i * posteriorState inst ρ hNonzero i A := hEq A
      _ = (communicationOutput inst.channel ρ) A := by
        symm
        simpa [communicationOutput] using
          nonselective_update_eq_branch_mixture inst ρ hNonzero A
  · intro hComm A
    calc
      ρ' A = (communicationOutput inst.channel ρ) A := by simp [hComm]
      _ = ∑ i, outcomeWeight inst ρ i * posteriorState inst ρ hNonzero i A := by
        simpa [communicationOutput] using
          nonselective_update_eq_branch_mixture inst ρ hNonzero A

/-- Normalized-state predicate (`ρ(1)=1`). -/
def NormalizedState
    {M : VonNeumannObservableModel}
    (ρ : NormalState M) : Prop :=
  ρ M.one = 1

/-- Channel dual preserves normalization under unitality. -/
theorem schrodingerDual_preserves_normalization
    {M : VonNeumannObservableModel}
    (Φ : UCPTMap M) (ρ : NormalState M)
    (hρ : NormalizedState ρ) :
    NormalizedState (schrodingerDual Φ ρ) := by
  unfold NormalizedState schrodingerDual at *
  simpa [Φ.preserves_one] using hρ

/-- Communication output preserves normalization. -/
theorem communicationOutput_preserves_normalization
    {M : VonNeumannObservableModel}
    (Φ : UCPTMap M) (ρ : NormalState M)
    (hρ : NormalizedState ρ) :
    NormalizedState (communicationOutput Φ ρ) := by
  simpa [communicationOutput] using
    schrodingerDual_preserves_normalization Φ ρ hρ

/-- Born-weight conservation for finite instruments on normalized inputs. -/
theorem instrument_weight_sum_eq_one
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι)
    (ρ : NormalState M)
    (hρ : NormalizedState ρ) :
    ∑ i, outcomeWeight inst ρ i = 1 := by
  have hNormDual : (schrodingerDual inst.channel ρ) M.one = 1 :=
    schrodingerDual_preserves_normalization inst.channel ρ hρ
  have hDecomp : (schrodingerDual inst.channel ρ) M.one =
      ∑ i, ρ ((inst.component i).toFun M.one) :=
    inst.sum_components ρ M.one
  calc
    ∑ i, outcomeWeight inst ρ i = (schrodingerDual inst.channel ρ) M.one := by
      symm
      simpa [outcomeWeight] using hDecomp
    _ = 1 := hNormDual

/-- Branch-mixture side of Bell's measurement problem. -/
def BellOutcomeMixtureClause
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι)
    (ρ : NormalState M)
    (hNonzero : ∀ i : ι, outcomeWeight inst ρ i ≠ 0)
    (ρ' : NormalState M) : Prop :=
  ∀ A : M.Obs,
    ρ' A = ∑ i, outcomeWeight inst ρ i * posteriorState inst ρ hNonzero i A

/-- Channel side of Bell's measurement problem. -/
def BellChannelClause
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι) (ρ : NormalState M) (ρ' : NormalState M) : Prop :=
  ρ' = communicationOutput inst.channel ρ

/-- Bell inconsistency form (existence of a mismatch post-state). -/
def BellMeasurementProblem
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι)
    (ρ : NormalState M)
    (hNonzero : ∀ i : ι, outcomeWeight inst ρ i ≠ 0) : Prop :=
  ∃ ρ' : NormalState M,
    BellOutcomeMixtureClause inst ρ hNonzero ρ' ∧
    ¬ BellChannelClause inst ρ ρ'

/-- Bell resolution principle (mixture iff channel for every post-state). -/
def BellMeasurementResolution
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι)
    (ρ : NormalState M)
    (hNonzero : ∀ i : ι, outcomeWeight inst ρ i ≠ 0) : Prop :=
  ∀ ρ' : NormalState M,
    BellOutcomeMixtureClause inst ρ hNonzero ρ' ↔ BellChannelClause inst ρ ρ'

/-- Bell resolution follows from measurement-as-communication equivalence. -/
theorem bell_measurement_resolution
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι)
    (ρ : NormalState M)
    (hNonzero : ∀ i : ι, outcomeWeight inst ρ i ≠ 0) :
    BellMeasurementResolution inst ρ hNonzero := by
  intro ρ'
  simpa [BellOutcomeMixtureClause, BellChannelClause] using
    measurement_as_communication_equivalence inst ρ hNonzero ρ'

/-- Bell inconsistency form is refuted under the bridge semantics. -/
theorem bell_measurement_problem_refuted
    {M : VonNeumannObservableModel} {ι : Type} [Fintype ι]
    (inst : FiniteInstrument M ι)
    (ρ : NormalState M)
    (hNonzero : ∀ i : ι, outcomeWeight inst ρ i ≠ 0) :
    ¬ BellMeasurementProblem inst ρ hNonzero := by
  intro hProblem
  rcases hProblem with ⟨ρ', hMix, hNotChan⟩
  have hRes := bell_measurement_resolution inst ρ hNonzero ρ'
  have hChan : BellChannelClause inst ρ ρ' := (hRes.mp hMix)
  exact hNotChan hChan

/-- Compatibility with existing CAT/EPT Bell-rate contract (`eq:Bell_k`). -/
theorem bell_rate_contract_rearranged
    (w : CurvedMeasurePathIntegralModel.BellWitness) :
    w.bellObservable + 1 = Real.exp w.entropicRate := by
  calc
    w.bellObservable + 1 = (Real.exp w.entropicRate - 1) + 1 := by
      simpa [CurvedMeasurePathIntegralModel.paper5_eq_Bell_k w]
    _ = Real.exp w.entropicRate := by ring

end
end MeasurementCommunicationEverettBridge
end NavierStokesClean.CATEPT
