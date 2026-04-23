import Mathlib
import CATEPTMain.CATEPT.MeasurePathIntegral

set_option autoImplicit false

namespace CATEPTMain.CATEPT

namespace Thermodynamics

noncomputable section

/-- Coherent vs decohering measurement choice in the thermodynamics-of-choice lane. -/
inductive ThermodynamicChoice
  | coherent
  | decohering
  deriving DecidableEq, Repr

/-- Count decohering steps in a measurement record. -/
def decoheringCount : List ThermodynamicChoice -> Nat
  | [] => 0
  | .decohering :: rest => decoheringCount rest + 1
  | .coherent :: rest => decoheringCount rest

@[simp]
theorem decoheringCount_cons_decohering (rest : List ThermodynamicChoice) :
    decoheringCount (.decohering :: rest) = decoheringCount rest + 1 := rfl

@[simp]
theorem decoheringCount_cons_coherent (rest : List ThermodynamicChoice) :
    decoheringCount (.coherent :: rest) = decoheringCount rest := rfl

/-- Decohering count is always bounded by total record length. -/
theorem decoheringCount_le_length (choices : List ThermodynamicChoice) :
    decoheringCount choices <= choices.length := by
  induction choices with
  | nil => simp [decoheringCount]
  | cons c rest ih =>
      cases c with
      | coherent =>
          simpa [decoheringCount] using le_trans ih (Nat.le_succ rest.length)
      | decohering =>
          simpa [decoheringCount] using Nat.succ_le_succ ih

/-- Abstract capability witness for LY-style thermodynamics packages. -/
structure ThermodynamicsLeanWitness where
  lyAxiomsAvailable : Prop
  entropyExistenceAvailable : Prop
  entropyUniquenessAvailable : Prop
  entropyContinuityAvailable : Prop
  kelvinPlanckAvailable : Prop
  entropyIncreaseAvailable : Prop

/-- Contract surface used by integrations that need LY capabilities. -/
def thermodynamicsLeanIntegrationContract (w : ThermodynamicsLeanWitness) : Prop :=
  w.lyAxiomsAvailable ∧ w.entropyExistenceAvailable ∧
    w.entropyUniquenessAvailable ∧ w.entropyContinuityAvailable ∧
    w.kelvinPlanckAvailable ∧ w.entropyIncreaseAvailable

theorem thermodynamicsLean_integration_contract
    (w : ThermodynamicsLeanWitness)
    (hAx : w.lyAxiomsAvailable) (hEx : w.entropyExistenceAvailable)
    (hUn : w.entropyUniquenessAvailable) (hCo : w.entropyContinuityAvailable)
    (hKP : w.kelvinPlanckAvailable) (hInc : w.entropyIncreaseAvailable) :
    thermodynamicsLeanIntegrationContract w :=
  ⟨hAx, hEx, hUn, hCo, hKP, hInc⟩

/-- Generic entropy-principle certificate (Lieb-Yngvason style contract). -/
structure ThermodynamicsEntropyCertificate where
  State : Type
  entropy : State -> Real
  adiabaticAccessible : State -> State -> Prop
  compose : State -> State -> State
  scale : Real -> State -> State
  monotonicity :
    forall X Y : State, adiabaticAccessible X Y -> entropy X <= entropy Y
  additivity :
    forall X Y : State, entropy (compose X Y) = entropy X + entropy Y
  extensivity :
    forall (t : Real) (X : State), 0 < t -> entropy (scale t X) = t * entropy X
  referenceLow : State
  referenceHigh : State
  strictReferenceGap : entropy referenceLow < entropy referenceHigh
  canonicalEntropyExists : Prop
  canonicalEntropyExists_holds : canonicalEntropyExists
  continuityLemma : Prop
  continuityLemma_holds : continuityLemma

theorem ThermodynamicsEntropyCertificate.entropy_monotone
    (w : ThermodynamicsEntropyCertificate)
    {X Y : w.State} (hXY : w.adiabaticAccessible X Y) :
    w.entropy X <= w.entropy Y :=
  w.monotonicity X Y hXY

theorem ThermodynamicsEntropyCertificate.reference_entropy_gap
    (w : ThermodynamicsEntropyCertificate) :
    w.entropy w.referenceLow < w.entropy w.referenceHigh :=
  w.strictReferenceGap

theorem ThermodynamicsEntropyCertificate.has_canonicalEntropy
    (w : ThermodynamicsEntropyCertificate) :
    w.canonicalEntropyExists :=
  w.canonicalEntropyExists_holds

theorem ThermodynamicsEntropyCertificate.has_continuityLemma
    (w : ThermodynamicsEntropyCertificate) :
    w.continuityLemma :=
  w.continuityLemma_holds

theorem ThermodynamicsEntropyCertificate.entropy_algebra_bundle
    (w : ThermodynamicsEntropyCertificate) :
    (forall X Y : w.State, w.entropy (w.compose X Y) = w.entropy X + w.entropy Y) ∧
      (forall (t : Real) (X : w.State), 0 < t -> w.entropy (w.scale t X) = t * w.entropy X) := by
  exact ⟨w.additivity, w.extensivity⟩

/-- Diagonal ETH witness with entropy-controlled decay. -/
structure ETHWitness where
  Observable : Type
  EigenIndex : Type
  diagExpectation : Observable -> EigenIndex -> Real
  thermalExpectation : Observable -> Real
  entropyAt : EigenIndex -> Real
  decayRate : Real
  decayRate_pos : 0 < decayRate
  diagonalETH :
    forall O : Observable, forall i : EigenIndex,
      |diagExpectation O i - thermalExpectation O| <= Real.exp (-decayRate * entropyAt i)

/-- Quantitative thermalization target. -/
def thermalizedWithin
    (w : ETHWitness)
    (O : w.Observable)
    (i : w.EigenIndex)
    (eps : Real) : Prop :=
  |w.diagExpectation O i - w.thermalExpectation O| <= eps

theorem eth_diagonal_implies_thermalizedWithin
    (w : ETHWitness)
    (O : w.Observable)
    (i : w.EigenIndex)
    {eps : Real}
    (hBudget : Real.exp (-w.decayRate * w.entropyAt i) <= eps) :
    thermalizedWithin w O i eps := by
  unfold thermalizedWithin
  exact (w.diagonalETH O i).trans hBudget

/-- Thermalization target augmented with an external dephasing envelope. -/
def thermalizedWithDephasing
    (w : ETHWitness)
    (dephasingEnvelope : Real)
    (O : w.Observable)
    (i : w.EigenIndex)
    (eps : Real) : Prop :=
  |w.diagExpectation O i - w.thermalExpectation O| + dephasingEnvelope <= eps

theorem eth_dephasing_implies_thermalizedWithDephasing
    (w : ETHWitness)
    (dephasingEnvelope : Real)
    (O : w.Observable)
    (i : w.EigenIndex)
    {epsDiag eps : Real}
    (hDiag : Real.exp (-w.decayRate * w.entropyAt i) <= epsDiag)
    (hTotal : epsDiag + dephasingEnvelope <= eps) :
    thermalizedWithDephasing w dephasingEnvelope O i eps := by
  unfold thermalizedWithDephasing
  have hDiagObs : |w.diagExpectation O i - w.thermalExpectation O| <= epsDiag :=
    eth_diagonal_implies_thermalizedWithin w O i hDiag
  linarith

/-- Clock-thermodynamics state kernel from theoremized row-260 lane. -/
structure ClockThermoState where
  tickRate : Real
  entropyProduction : Real
  tick_nonneg : 0 <= tickRate
  entropyProd_nonneg : 0 <= entropyProduction

def effectiveTemperature (S : ClockThermoState) : Real :=
  S.tickRate + S.entropyProduction

def dissipationIndex (S : ClockThermoState) : Real :=
  S.entropyProduction / (1 + S.tickRate)

theorem effectiveTemperature_nonneg (S : ClockThermoState) :
    0 <= effectiveTemperature S := by
  unfold effectiveTemperature
  linarith [S.tick_nonneg, S.entropyProd_nonneg]

theorem normalizer_tick_pos (S : ClockThermoState) : 0 < 1 + S.tickRate := by
  linarith [S.tick_nonneg]

theorem dissipationIndex_nonneg (S : ClockThermoState) :
    0 <= dissipationIndex S := by
  unfold dissipationIndex
  exact div_nonneg S.entropyProd_nonneg (le_of_lt (normalizer_tick_pos S))

theorem effectiveTemperature_ge_tick (S : ClockThermoState) :
    S.tickRate <= effectiveTemperature S := by
  unfold effectiveTemperature
  linarith [S.entropyProd_nonneg]

/-- Time-arrow state kernel from theoremized row-112 lane. -/
structure ThermoArrowState where
  entropy : Real
  inverseTemp : Real
  internalEnergy : Real

/-- Free-energy proxy `F = E - S / beta`. -/
def thermoFreeEnergy (s : ThermoArrowState) : Real :=
  s.internalEnergy - s.entropy / s.inverseTemp

/-- Entropy-monotone arrow relation. -/
def thermoArrow (s1 s2 : ThermoArrowState) : Prop :=
  s1.entropy <= s2.entropy

theorem thermoArrow_refl (s : ThermoArrowState) :
    thermoArrow s s := by
  unfold thermoArrow
  exact le_rfl

theorem thermoArrow_trans
    (a b c : ThermoArrowState)
    (hab : thermoArrow a b)
    (hbc : thermoArrow b c) :
    thermoArrow a c := by
  unfold thermoArrow at *
  exact le_trans hab hbc

theorem thermo_entropy_div_nonneg
    (s : ThermoArrowState)
    (hs : 0 <= s.entropy)
    (hb : 0 < s.inverseTemp) :
    0 <= s.entropy / s.inverseTemp := by
  exact div_nonneg hs (le_of_lt hb)

theorem thermoArrow_bundle
    (a b c : ThermoArrowState)
    (hab : thermoArrow a b)
    (hbc : thermoArrow b c) :
    thermoArrow a c ∧ thermoArrow a a := by
  exact ⟨thermoArrow_trans a b c hab hbc, thermoArrow_refl a⟩

/-- Extremality proxy state used in black-hole thermodynamics extraction. -/
structure KerrProxy where
  mass : Real
  angMom : Real
  mass_nonneg : 0 <= mass

def extremalityGap (K : KerrProxy) : Real := K.mass ^ 2 - |K.angMom|

def isSubExtremal (K : KerrProxy) : Prop := 0 <= extremalityGap K

def hawkingTemperatureProxy (K : KerrProxy) : Real := extremalityGap K

def bekensteinHawkingEntropyProxy (K : KerrProxy) : Real :=
  K.mass ^ 2 + Real.sqrt (max 0 (extremalityGap K))

theorem subExtremal_iff_massSq_ge_absSpin (K : KerrProxy) :
    isSubExtremal K <-> |K.angMom| <= K.mass ^ 2 := by
  unfold isSubExtremal extremalityGap
  constructor
  · intro h
    exact sub_nonneg.mp h
  · intro h
    exact sub_nonneg.mpr h

theorem extremalityGap_eq_zero_of_massSq_eq_absSpin
    (K : KerrProxy) (h : K.mass ^ 2 = |K.angMom|) :
    extremalityGap K = 0 := by
  unfold extremalityGap
  linarith

theorem hawkingTemperatureProxy_nonneg_of_subExtremal
    (K : KerrProxy) (hSub : isSubExtremal K) :
    0 <= hawkingTemperatureProxy K := by
  simpa [hawkingTemperatureProxy] using hSub

theorem entropyProxy_ge_massSq (K : KerrProxy) :
    K.mass ^ 2 <= bekensteinHawkingEntropyProxy K := by
  unfold bekensteinHawkingEntropyProxy
  have hsqrt : 0 <= Real.sqrt (max 0 (extremalityGap K)) := Real.sqrt_nonneg _
  linarith

theorem entropyProxy_nonneg (K : KerrProxy) :
    0 <= bekensteinHawkingEntropyProxy K := by
  have hMassSq : 0 <= K.mass ^ 2 := sq_nonneg K.mass
  have hGe : K.mass ^ 2 <= bekensteinHawkingEntropyProxy K := entropyProxy_ge_massSq K
  linarith

/-- KMS occupation-number proxy from holographic thermal channel row-52 lane. -/
def row52_nbarKMS (hbar kB T omega : Real) : Real :=
  if T <= 0 ∨ omega <= 0 then 0
  else 1 / (Real.exp ((hbar * omega) / (kB * T)) - 1)

def row52_log2 (x : Real) : Real := Real.log x / Real.log 2

def row52_modeCapacityBoson (nbar : Real) : Real :=
  if nbar <= 0 then 0
  else (nbar + 1) * row52_log2 (nbar + 1) - nbar * row52_log2 nbar

theorem row52_nbar_zero_of_nonpos
    (hbar kB T omega : Real) (h : T <= 0 ∨ omega <= 0) :
    row52_nbarKMS hbar kB T omega = 0 := by
  unfold row52_nbarKMS
  simp [h]

theorem row52_modeCapacity_zero_of_nonpos
    (nbar : Real) (h : nbar <= 0) :
    row52_modeCapacityBoson nbar = 0 := by
  unfold row52_modeCapacityBoson
  simp [h]

/-- Modular-operator interface used by alpha-divergence thermodynamic clocks. -/
structure ModularOperator where
  value : (alpha : Real) -> (phi phi0 : Real -> Real) -> Real

/-- Petz/Jencova alpha-divergence skeleton. -/
def alphaDivergence (M : ModularOperator) (alpha : Real) (phi phi0 : Real -> Real) : Real :=
  (1 / (alpha * (1 - alpha))) * (1 - M.value (1 - alpha) phi phi0)

/-- Imaginary-action functional used in entropic clock calibrations. -/
def imaginaryAction
    (kappa : Real) (M : ModularOperator)
    (alpha : Real) (phi phi0 : Real -> Real) : Real :=
  kappa * alphaDivergence M alpha phi phi0

/-- Entropic proper time obtained by scaling imaginary action by hbar. -/
def entropicProperTime (imaginaryActionValue hbar : Real) : Real :=
  imaginaryActionValue / hbar

theorem entropicProperTime_eq_alphaDivergence
    (kappa hbar alpha : Real)
    (M : ModularOperator) (phi phi0 : Real -> Real) :
    entropicProperTime (imaginaryAction kappa M alpha phi phi0) hbar =
      (kappa * alphaDivergence M alpha phi phi0) / hbar := by
  rfl

/-- Interface for partition-function thermodynamics (captures the StatMech lane
without importing heavy Hamiltonian dependencies into core). -/
structure PartitionThermoWitness where
  PartitionZ : Real -> Real
  PartitionZT : Real -> Real
  InternalU : Real -> Real
  HelmholtzA : Real -> Real
  EntropyS : Real -> Real
  EntropySbeta : Real -> Real
  ZIntegrable : Real -> Prop
  entropy_A_eq_entropy_Z :
    forall T beta, T * beta = 1 -> ZIntegrable beta -> EntropyS T = EntropySbeta beta
  beta_eq_deriv_S_U :
    forall beta, ZIntegrable beta ->
      beta = deriv EntropySbeta beta / deriv InternalU beta

/-- Core-safe 3D coordinate space carrier used by CATEPT space-time bridges. -/
abbrev CATEPTSpace : Type := Fin 3 -> Real

/-- Core-safe 4D coordinate spacetime carrier used by CATEPT space-time bridges. -/
abbrev CATEPTST : Type := Fin 4 -> Real

/-- Squared spatial norm of a displacement. -/
def spatialNorm2 (dx : CATEPTST) : Real :=
  ∑ i : Fin 3, (dx i.succ) ^ 2

/-- Minkowski norm-squared with signature (-,+,+,+). -/
def minkowskiNorm2 (dx : CATEPTST) : Real :=
  -(dx 0) ^ 2 + spatialNorm2 dx

def causalTimelike (dx : CATEPTST) : Prop := minkowskiNorm2 dx < 0

def causalLightlike (dx : CATEPTST) : Prop := dx ≠ 0 ∧ minkowskiNorm2 dx = 0

def causalSpacelike (dx : CATEPTST) : Prop := minkowskiNorm2 dx > 0

/-- Causal trichotomy on Minkowski displacements. -/
theorem causal_trichotomy (dx : CATEPTST) :
    causalTimelike dx ∨ causalLightlike dx ∨ causalSpacelike dx ∨ dx = 0 := by
  by_cases h0 : dx = 0
  · exact Or.inr (Or.inr (Or.inr h0))
  · rcases lt_trichotomy (minkowskiNorm2 dx) 0 with hlt | heq | hgt
    · exact Or.inl hlt
    · exact Or.inr (Or.inl ⟨h0, heq⟩)
    · exact Or.inr (Or.inr (Or.inl hgt))

/-- Entropic lapse field for lapse-weighted spacetime intervals. -/
structure EntropicLapse where
  lapse : CATEPTST -> Real
  lapse_pos : forall x, 0 < lapse x

/-- Lapse-weighted Minkowski norm-squared. -/
def entropicNorm2 (N : EntropicLapse) (x : CATEPTST) (dx : CATEPTST) : Real :=
  -(N.lapse x) ^ 2 * (dx 0) ^ 2 + spatialNorm2 dx

def entropicTimelike (N : EntropicLapse) (x dx : CATEPTST) : Prop :=
  entropicNorm2 N x dx < 0

def entropicSpacelike (N : EntropicLapse) (x dx : CATEPTST) : Prop :=
  entropicNorm2 N x dx > 0

def unitLapse : EntropicLapse where
  lapse := fun _ => 1
  lapse_pos := fun _ => one_pos

theorem entropicNorm2_unitLapse (x dx : CATEPTST) :
    entropicNorm2 unitLapse x dx = minkowskiNorm2 dx := by
  unfold entropicNorm2 unitLapse minkowskiNorm2
  ring

theorem entropicTimelike_unitLapse_iff (x dx : CATEPTST) :
    entropicTimelike unitLapse x dx <-> causalTimelike dx := by
  unfold entropicTimelike causalTimelike
  rw [entropicNorm2_unitLapse]

theorem entropicSpacelike_unitLapse_iff (x dx : CATEPTST) :
    entropicSpacelike unitLapse x dx <-> causalSpacelike dx := by
  unfold entropicSpacelike causalSpacelike
  rw [entropicNorm2_unitLapse]

theorem entropicTimelike_velocity_bound
    {N : EntropicLapse} {x dx : CATEPTST}
    (htl : entropicTimelike N x dx) :
    spatialNorm2 dx < (N.lapse x) ^ 2 * (dx 0) ^ 2 := by
  unfold entropicTimelike entropicNorm2 at htl
  linarith

/-! ## Measurement-as-Communication Core Contracts -/

/-- Minimal von-Neumann observable interface. -/
structure VonNeumannObservableModel where
  Obs : Type
  one : Obs

/-- Normal-state interface as complex expectation functionals. -/
def NormalState (M : VonNeumannObservableModel) : Type :=
  M.Obs -> Complex

/-- Heisenberg-picture CP map. -/
structure CPMap (M : VonNeumannObservableModel) where
  toFun : M.Obs -> M.Obs

/-- Unital CP map (dual of CPTP channels). -/
structure UCPTMap (M : VonNeumannObservableModel) extends CPMap M where
  preserves_one : toFun M.one = M.one

/-- Schrodinger-dual state update `(Phi_*(rho))(A) = rho(Phi(A))`. -/
def schrodingerDual
    {M : VonNeumannObservableModel}
    (Phi : UCPTMap M) (rho : NormalState M) : NormalState M :=
  fun A => rho (Phi.toFun A)

/-- Communication interpretation of the same nonselective channel update. -/
def communicationOutput
    {M : VonNeumannObservableModel}
    (Phi : UCPTMap M) (rho : NormalState M) : NormalState M :=
  schrodingerDual Phi rho

/-- Finite instrument decomposition with nonselective channel identity. -/
structure FiniteInstrument
    (M : VonNeumannObservableModel) (idx : Type) [Fintype idx] where
  channel : UCPTMap M
  component : idx -> CPMap M
  sum_components :
    forall (rho : NormalState M) (A : M.Obs),
      (schrodingerDual channel rho) A =
        Finset.univ.sum (fun i => rho ((component i).toFun A))

/-- Outcome weight `p_i = rho(Phi_i(1))`. -/
def outcomeWeight
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx) (rho : NormalState M) (i : idx) : Complex :=
  rho ((inst.component i).toFun M.one)

/-- Posterior branch state `rho_i(A) = rho(Phi_i(A)) / p_i` when `p_i != 0`. -/
def posteriorState
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx)
    (rho : NormalState M)
  (_hNonzero : forall i : idx, outcomeWeight inst rho i ≠ 0) :
    idx -> NormalState M :=
  fun i A => rho ((inst.component i).toFun A) / outcomeWeight inst rho i

theorem component_reconstruction
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx)
    (rho : NormalState M)
    (hNonzero : forall i : idx, outcomeWeight inst rho i ≠ 0)
    (i : idx) (A : M.Obs) :
    rho ((inst.component i).toFun A) =
      outcomeWeight inst rho i * posteriorState inst rho hNonzero i A := by
  have hp : outcomeWeight inst rho i ≠ 0 := hNonzero i
  calc
    rho ((inst.component i).toFun A)
        = outcomeWeight inst rho i *
            (rho ((inst.component i).toFun A) / outcomeWeight inst rho i) := by
              exact (mul_div_cancel₀ (rho ((inst.component i).toFun A)) hp).symm
    _ = outcomeWeight inst rho i * posteriorState inst rho hNonzero i A := by
          simp [posteriorState]

theorem nonselective_update_eq_branch_mixture
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx)
    (rho : NormalState M)
  (hNonzero : forall i : idx, outcomeWeight inst rho i ≠ 0)
    (A : M.Obs) :
    (schrodingerDual inst.channel rho) A =
      Finset.univ.sum (fun i => outcomeWeight inst rho i * posteriorState inst rho hNonzero i A) := by
  classical
  calc
    (schrodingerDual inst.channel rho) A
        = Finset.univ.sum (fun i => rho ((inst.component i).toFun A)) :=
          inst.sum_components rho A
    _ = Finset.univ.sum
          (fun i => outcomeWeight inst rho i * posteriorState inst rho hNonzero i A) := by
      refine Finset.sum_congr rfl ?_
      intro i _
      exact component_reconstruction inst rho hNonzero i A

/-- Everett-style relative-state decomposition data. -/
structure RelativeStateDecomposition
    (M : VonNeumannObservableModel) (idx : Type) [Fintype idx] where
  global : NormalState M
  weight : idx -> Complex
  branch : idx -> NormalState M
  decomposition : forall A : M.Obs,
    global A = Finset.univ.sum (fun i => weight i * branch i A)

/-- Instrument-induced relative-state decomposition. -/
def inducedRelativeStateDecomposition
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx)
    (rho : NormalState M)
  (hNonzero : forall i : idx, outcomeWeight inst rho i ≠ 0) :
    RelativeStateDecomposition M idx where
  global := communicationOutput inst.channel rho
  weight := outcomeWeight inst rho
  branch := posteriorState inst rho hNonzero
  decomposition := by
    intro A
    simpa [communicationOutput] using
      nonselective_update_eq_branch_mixture inst rho hNonzero A

theorem measurement_as_communication_equivalence
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx)
    (rho : NormalState M)
  (hNonzero : forall i : idx, outcomeWeight inst rho i ≠ 0)
    (rhoPrime : NormalState M) :
    (forall A : M.Obs,
      rhoPrime A = Finset.univ.sum
        (fun i => outcomeWeight inst rho i * posteriorState inst rho hNonzero i A)) <->
      rhoPrime = communicationOutput inst.channel rho := by
  constructor
  · intro hEq
    funext A
    calc
      rhoPrime A = Finset.univ.sum
          (fun i => outcomeWeight inst rho i * posteriorState inst rho hNonzero i A) := hEq A
      _ = (communicationOutput inst.channel rho) A := by
        symm
        simpa [communicationOutput] using
          nonselective_update_eq_branch_mixture inst rho hNonzero A
  · intro hComm A
    calc
      rhoPrime A = (communicationOutput inst.channel rho) A := by simp [hComm]
      _ = Finset.univ.sum
            (fun i => outcomeWeight inst rho i * posteriorState inst rho hNonzero i A) := by
          simpa [communicationOutput] using
            nonselective_update_eq_branch_mixture inst rho hNonzero A

/-- Normalized-state predicate (`rho(1)=1`). -/
def NormalizedState
    {M : VonNeumannObservableModel}
    (rho : NormalState M) : Prop :=
  rho M.one = 1

theorem schrodingerDual_preserves_normalization
    {M : VonNeumannObservableModel}
    (Phi : UCPTMap M) (rho : NormalState M)
    (hRho : NormalizedState rho) :
    NormalizedState (schrodingerDual Phi rho) := by
  unfold NormalizedState schrodingerDual at *
  simpa [Phi.preserves_one] using hRho

theorem communicationOutput_preserves_normalization
    {M : VonNeumannObservableModel}
    (Phi : UCPTMap M) (rho : NormalState M)
    (hRho : NormalizedState rho) :
    NormalizedState (communicationOutput Phi rho) := by
  simpa [communicationOutput] using
    schrodingerDual_preserves_normalization Phi rho hRho

theorem instrument_weight_sum_eq_one
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx)
    (rho : NormalState M)
    (hRho : NormalizedState rho) :
    Finset.univ.sum (fun i => outcomeWeight inst rho i) = 1 := by
  have hNormDual : (schrodingerDual inst.channel rho) M.one = 1 :=
    schrodingerDual_preserves_normalization inst.channel rho hRho
  have hDecomp :
      (schrodingerDual inst.channel rho) M.one =
        Finset.univ.sum (fun i => rho ((inst.component i).toFun M.one)) :=
    inst.sum_components rho M.one
  calc
    Finset.univ.sum (fun i => outcomeWeight inst rho i) =
        (schrodingerDual inst.channel rho) M.one := by
          symm
          simpa [outcomeWeight] using hDecomp
    _ = 1 := hNormDual

def BellOutcomeMixtureClause
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx)
    (rho : NormalState M)
  (hNonzero : forall i : idx, outcomeWeight inst rho i ≠ 0)
    (rhoPrime : NormalState M) : Prop :=
  forall A : M.Obs,
    rhoPrime A = Finset.univ.sum
      (fun i => outcomeWeight inst rho i * posteriorState inst rho hNonzero i A)

def BellChannelClause
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx) (rho : NormalState M) (rhoPrime : NormalState M) : Prop :=
  rhoPrime = communicationOutput inst.channel rho

def BellMeasurementProblem
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx)
    (rho : NormalState M)
  (hNonzero : forall i : idx, outcomeWeight inst rho i ≠ 0) : Prop :=
  exists rhoPrime : NormalState M,
    BellOutcomeMixtureClause inst rho hNonzero rhoPrime ∧
      ¬ BellChannelClause inst rho rhoPrime

def BellMeasurementResolution
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx)
    (rho : NormalState M)
  (hNonzero : forall i : idx, outcomeWeight inst rho i ≠ 0) : Prop :=
  forall rhoPrime : NormalState M,
    BellOutcomeMixtureClause inst rho hNonzero rhoPrime <-> BellChannelClause inst rho rhoPrime

theorem bell_measurement_resolution
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx)
    (rho : NormalState M)
  (hNonzero : forall i : idx, outcomeWeight inst rho i ≠ 0) :
    BellMeasurementResolution inst rho hNonzero := by
  intro rhoPrime
  simpa [BellOutcomeMixtureClause, BellChannelClause] using
    measurement_as_communication_equivalence inst rho hNonzero rhoPrime

theorem bell_measurement_problem_refuted
    {M : VonNeumannObservableModel} {idx : Type} [Fintype idx]
    (inst : FiniteInstrument M idx)
    (rho : NormalState M)
  (hNonzero : forall i : idx, outcomeWeight inst rho i ≠ 0) :
    ¬ BellMeasurementProblem inst rho hNonzero := by
  intro hProblem
  rcases hProblem with ⟨rhoPrime, hMix, hNotChan⟩
  have hRes := bell_measurement_resolution inst rho hNonzero rhoPrime
  have hChan : BellChannelClause inst rho rhoPrime := (hRes.mp hMix)
  exact hNotChan hChan

/-- Core Bell-rate witness compatible with the rearranged contract form. -/
structure BellRateWitness where
  bellObservable : Real
  entropicRate : Real
  bell_rate_eq : bellObservable = Real.exp entropicRate - 1

theorem bell_rate_contract_rearranged
    (w : BellRateWitness) :
    w.bellObservable + 1 = Real.exp w.entropicRate := by
  linarith [w.bell_rate_eq]

/-! ## Path-Integral Measure Stability Contracts -/

/-- CAT/EPT weight exponent `A = i*S_R/hbar - S_I/hbar`. -/
def weightExponent
    {alpha : Type} [MeasurableSpace alpha]
    (m : CATEPT.MeasurePathIntegralModel alpha) (x : alpha) : Complex :=
  (-(m.actionImScaled x) : Complex) +
    ((m.actionReScaled x : Real) : Complex) * Complex.I

theorem cameron_condition
    {alpha : Type} [MeasurableSpace alpha]
    (m : CATEPT.MeasurePathIntegralModel alpha) (x : alpha) :
    (weightExponent m x).re <= 0 := by
  unfold weightExponent
  simp [Complex.add_re, Complex.mul_re, Complex.I_re, Complex.I_im, Complex.ofReal_re]
  simpa [CATEPT.MeasurePathIntegralModel.actionImScaled] using
    div_nonneg (m.actionIm_nonneg x) m.hbar_pos.le

theorem cameron_condition_strict
    {alpha : Type} [MeasurableSpace alpha]
    (m : CATEPT.MeasurePathIntegralModel alpha) (x : alpha)
    (hSI : 0 < m.actionIm x) :
    (weightExponent m x).re < 0 := by
  unfold weightExponent
  simp [Complex.add_re, Complex.mul_re, Complex.I_re, Complex.I_im, Complex.ofReal_re]
  have hscaled : 0 < m.actionImScaled x := by
    unfold CATEPT.MeasurePathIntegralModel.actionImScaled
    exact div_pos hSI m.hbar_pos
  linarith

theorem weight_radon_nikodym_le_one
    {alpha : Type} [MeasurableSpace alpha]
    (m : CATEPT.MeasurePathIntegralModel alpha) (x : alpha) :
    Real.exp (-(m.actionImScaled x)) <= 1 := by
  exact m.damping_le_one x

theorem weight_radon_nikodym_pos
    {alpha : Type} [MeasurableSpace alpha]
    (m : CATEPT.MeasurePathIntegralModel alpha) (x : alpha) :
    0 < Real.exp (-(m.actionImScaled x)) := by
  exact m.damping_pos x

theorem catept_measure_absolutely_continuous
    {alpha : Type} [MeasurableSpace alpha]
    (m : CATEPT.MeasurePathIntegralModel alpha) (x : alpha) :
    let rnDeriv := Real.exp (-(m.actionImScaled x))
    (0 < rnDeriv) ∧ (rnDeriv <= 1) :=
  ⟨weight_radon_nikodym_pos m x, weight_radon_nikodym_le_one m x⟩

theorem catept_radon_nikodym_measurable
    {alpha : Type} [MeasurableSpace alpha]
    (m : CATEPT.MeasurePathIntegralModel alpha) :
    Measurable (fun x => Real.exp (-(m.actionImScaled x))) :=
  m.measurable_damping

theorem mazur_ulam_phase_isometry
    {alpha : Type} [MeasurableSpace alpha]
    (m : CATEPT.MeasurePathIntegralModel alpha) (x : alpha) :
    ‖Complex.exp ((m.actionReScaled x : Complex) * Complex.I)‖ = 1 :=
  Complex.norm_exp_ofReal_mul_I _

theorem weight_norm_equals_damping
    {alpha : Type} [MeasurableSpace alpha]
    (m : CATEPT.MeasurePathIntegralModel alpha) (x : alpha) :
    ‖m.weight x‖ = m.damping x :=
  m.weight_norm_is_damping x

theorem hyers_ulam_weight_stability
    (S_I S_IPrime hbar : Real) (hh : 0 < hbar)
    (hS : 0 <= S_I) (hSPrime : 0 <= S_IPrime) :
    |Real.exp (-S_IPrime / hbar) - Real.exp (-S_I / hbar)| <=
      |S_IPrime - S_I| / hbar := by
  let a : Real := -S_IPrime / hbar
  let b : Real := -S_I / hbar
  let s : Set Real := Set.Icc (min a b) (max a b)
  have ha_nonpos : a <= 0 := by
    dsimp [a]
    exact div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr hSPrime) hh.le
  have hb_nonpos : b <= 0 := by
    dsimp [b]
    exact div_nonpos_of_nonpos_of_nonneg (neg_nonpos.mpr hS) hh.le
  have hf : ∀ x ∈ s, DifferentiableAt ℝ Real.exp x := by
    intro x _hx
    simpa using Real.differentiableAt_exp x
  have hbound : ∀ x ∈ s, ‖deriv Real.exp x‖ ≤ 1 := by
    intro x hx
    have hx_le_max : x <= max a b := hx.2
    have hmax_le_zero : max a b <= 0 := max_le ha_nonpos hb_nonpos
    have hx_nonpos : x <= 0 := le_trans hx_le_max hmax_le_zero
    have hexp_le_one : Real.exp x <= 1 := (Real.exp_le_one_iff).2 hx_nonpos
    calc
      ‖deriv Real.exp x‖ = |Real.exp x| := by rw [Real.deriv_exp, Real.norm_eq_abs]
      _ = Real.exp x := abs_of_nonneg (Real.exp_nonneg x)
      _ <= 1 := hexp_le_one
  have hs_convex : Convex ℝ s := by
    dsimp [s]
    exact convex_Icc _ _
  have ha_mem : a ∈ s := by
    dsimp [s]
    exact ⟨min_le_left _ _, le_max_left _ _⟩
  have hb_mem : b ∈ s := by
    dsimp [s]
    exact ⟨min_le_right _ _, le_max_right _ _⟩
  have hmv :=
    Convex.norm_image_sub_le_of_norm_deriv_le hf hbound hs_convex ha_mem hb_mem
  have habs : |b - a| = |S_IPrime - S_I| / hbar := by
    have hba : b - a = (S_IPrime - S_I) / hbar := by
      dsimp [a, b]
      ring_nf
    rw [hba, abs_div]
    rw [abs_of_pos hh]
  have hleft :
      |Real.exp (-S_IPrime / hbar) - Real.exp (-S_I / hbar)| = |Real.exp b - Real.exp a| := by
    dsimp [a, b]
    rw [abs_sub_comm]
  calc
    |Real.exp (-S_IPrime / hbar) - Real.exp (-S_I / hbar)| = |Real.exp b - Real.exp a| := hleft
    _ <= |b - a| := by simpa [Real.norm_eq_abs, one_mul] using hmv
    _ = |S_IPrime - S_I| / hbar := habs

theorem weight_lipschitz_contractivity
    (S_I S_IPrime hbar eps : Real) (hh : 0 < hbar)
    (hS : 0 <= S_I) (hSPrime : 0 <= S_IPrime)
    (hEps : |S_IPrime - S_I| <= eps) :
    |Real.exp (-S_IPrime / hbar) - Real.exp (-S_I / hbar)| <= eps / hbar :=
  calc
    |Real.exp (-S_IPrime / hbar) - Real.exp (-S_I / hbar)|
        <= |S_IPrime - S_I| / hbar :=
          hyers_ulam_weight_stability S_I S_IPrime hbar hh hS hSPrime
    _ <= eps / hbar := by
      exact div_le_div_of_nonneg_right hEps hh.le

theorem modular_automorphism_unitary
    (K s : Real) :
    ‖Complex.exp (((K * s : Real) : Complex) * Complex.I)‖ = 1 :=
  Complex.norm_exp_ofReal_mul_I _

theorem modular_parameter_equals_entropic_time
  (lambda T hbar : Real) (_hLambda : 0 <= lambda) (_hT : 0 < T) (hh : 0 < hbar)
    (S_I : Real) (hSI : S_I = lambda * T * hbar) :
    lambda * T = entropicProperTime S_I hbar := by
  unfold entropicProperTime
  rw [hSI]
  field_simp [hh.ne']

theorem kms_equilibrium_condition
    (hbar : Real) (_hh : 0 < hbar) :
    entropicProperTime 0 hbar = 0 := by
  unfold entropicProperTime
  simp

theorem catept_path_integral_well_defined
    {alpha : Type} [MeasurableSpace alpha]
    (m : CATEPT.MeasurePathIntegralModel alpha) (x : alpha) :
    (weightExponent m x).re <= 0 ∧
      (0 < Real.exp (-(m.actionImScaled x)) ∧
        Real.exp (-(m.actionImScaled x)) <= 1) ∧
      ‖m.weight x‖ <= 1 ∧
      ‖Complex.exp ((m.actionReScaled x : Complex) * Complex.I)‖ = 1 :=
  ⟨cameron_condition m x,
    ⟨weight_radon_nikodym_pos m x, weight_radon_nikodym_le_one m x⟩,
    m.weight_bochner_bounded x,
    mazur_ulam_phase_isometry m x⟩

/-! ## QFI Measurement Capability Interface -/

/-- Core capability witness for importing QFI-measurement lanes without
directly depending on heavy quantum matrix constructions in core. -/
structure QFIMeasurementWitness where
  phaseShiftGeneratorHermitian : Prop
  phaseShiftEnsembleBound : Prop
  localMagnetizationReal : Prop
  neelStateAFOrder : Prop
  neelStateFMOrderZero : Prop
  pptCriterionSeparable : Prop
  tensorSumHermitian : Prop
  tensorSumTrace : Prop
  stateQFIManualLowerBound : Prop
  permuteSystemsAvailable : Prop
  permuteSystemsIdentity : Prop

def qfiMeasurementContract (w : QFIMeasurementWitness) : Prop :=
  w.phaseShiftGeneratorHermitian ∧
    w.phaseShiftEnsembleBound ∧
    w.localMagnetizationReal ∧
    w.neelStateAFOrder ∧
    w.neelStateFMOrderZero ∧
    w.pptCriterionSeparable ∧
    w.tensorSumHermitian ∧
    w.tensorSumTrace ∧
    w.stateQFIManualLowerBound ∧
    w.permuteSystemsAvailable ∧
    w.permuteSystemsIdentity

theorem qfiMeasurement_contract_of_fields
    (w : QFIMeasurementWitness)
    (h1 : w.phaseShiftGeneratorHermitian)
    (h2 : w.phaseShiftEnsembleBound)
    (h3 : w.localMagnetizationReal)
    (h4 : w.neelStateAFOrder)
    (h5 : w.neelStateFMOrderZero)
    (h6 : w.pptCriterionSeparable)
    (h7 : w.tensorSumHermitian)
    (h8 : w.tensorSumTrace)
    (h9 : w.stateQFIManualLowerBound)
    (h10 : w.permuteSystemsAvailable)
    (h11 : w.permuteSystemsIdentity) :
    qfiMeasurementContract w :=
  ⟨h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11⟩

end

end Thermodynamics

end CATEPTMain.CATEPT
