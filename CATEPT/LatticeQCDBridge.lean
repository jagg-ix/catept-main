import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Complex.Log
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import NavierStokesClean.CATEPT.MeasurePathIntegral

/-!
# CAT/EPT Lattice-QCD Compatibility Bridge

Initial bridge layer between finite lattice-QCD style discretizations and the
CAT/EPT MTPI/discrete-kernel infrastructure.

This is the first scaffold for the Wilson/plaquette compatibility work package.
-/

set_option autoImplicit false

open BigOperators
open Filter
open MeasureTheory

namespace NavierStokesClean.CATEPT

noncomputable section

/-- Finite lattice-QCD Wilson-action data (discrete finite-dimensional setting). -/
structure LatticeWilsonData where
  nPlaquettes : Nat
  nPlaquettes_pos : 0 < nPlaquettes
  beta : ℝ
  beta_nonneg : 0 ≤ beta
  plaquetteAction : Fin nPlaquettes → ℝ

namespace LatticeWilsonData

variable (L : LatticeWilsonData)

/-- Finite Wilson action as sum over plaquette contributions. -/
def wilsonAction : ℝ := ∑ i : Fin L.nPlaquettes, L.plaquetteAction i

/-- Euclidean Boltzmann factor `exp(-β S_W)`. -/
def boltzmannFactor : ℝ := Real.exp (-L.beta * L.wilsonAction)

theorem boltzmannFactor_pos : 0 < L.boltzmannFactor := by
  unfold boltzmannFactor
  exact Real.exp_pos _

/-- If the Wilson action is nonnegative, damping factor stays in `(0,1]`. -/
theorem boltzmannFactor_le_one (h_nonneg : 0 ≤ L.wilsonAction) :
    L.boltzmannFactor ≤ 1 := by
  unfold boltzmannFactor
  rw [← Real.exp_zero]
  apply Real.exp_le_exp.mpr
  nlinarith [L.beta_nonneg, h_nonneg]

/-- Per-plaquette imaginary action contribution `β · S_p`. -/
def imaginaryAction (i : Fin L.nPlaquettes) : ℝ :=
  L.beta * L.plaquetteAction i

theorem imaginaryAction_nonneg
    (hPlaquette_nonneg : ∀ i, 0 ≤ L.plaquetteAction i) :
    ∀ i, 0 ≤ L.imaginaryAction i := by
  intro i
  unfold imaginaryAction
  nlinarith [L.beta_nonneg, hPlaquette_nonneg i]

/-- Finite-lattice Wilson model as a concrete CAT/EPT MTPI object over `Fin n`. -/
def toMeasurePathIntegralModel (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ i, 0 ≤ L.plaquetteAction i) :
    MeasurePathIntegralModel (Fin L.nPlaquettes) where
  μ := Measure.count
  hbar := hbar
  hbar_pos := hbar_pos
  actionRe := fun _ => 0
  actionIm := L.imaginaryAction
  measurable_actionRe := measurable_const
  measurable_actionIm := measurable_of_finite _
  actionIm_nonneg := L.imaginaryAction_nonneg hPlaquette_nonneg

/-- Finite-lattice partition is exactly a finite sum under counting measure. -/
theorem partition_eq_finset_sum (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ i, 0 ≤ L.plaquetteAction i) :
    (L.toMeasurePathIntegralModel hbar hbar_pos hPlaquette_nonneg).partition =
      ∑ i : Fin L.nPlaquettes,
        (L.toMeasurePathIntegralModel hbar hbar_pos hPlaquette_nonneg).weight i := by
  simp [MeasurePathIntegralModel.partition, toMeasurePathIntegralModel]

/-- Finite-lattice source-coupled partition is also exactly a finite counting sum. -/
theorem sourceCoupledPartition_eq_finset_sum (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ i, 0 ≤ L.plaquetteAction i)
    (J : Fin L.nPlaquettes → ℂ) :
    (L.toMeasurePathIntegralModel hbar hbar_pos hPlaquette_nonneg).sourceCoupledPartition J =
      ∑ i : Fin L.nPlaquettes,
        (L.toMeasurePathIntegralModel hbar hbar_pos hPlaquette_nonneg).sourceCoupledWeight J i := by
  simp [MeasurePathIntegralModel.sourceCoupledPartition, toMeasurePathIntegralModel]

/-- Finite-lattice source-coupled unnormalized expectation as a finite sum. -/
theorem sourceCoupledUnnormalizedExpectation_eq_finset_sum
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ i, 0 ≤ L.plaquetteAction i)
    (J O : Fin L.nPlaquettes → ℂ) :
    MeasurePathIntegralModel.sourceCoupledUnnormalizedExpectation
      (L.toMeasurePathIntegralModel hbar hbar_pos hPlaquette_nonneg) J O =
      ∑ i : Fin L.nPlaquettes,
        (L.toMeasurePathIntegralModel hbar hbar_pos hPlaquette_nonneg).sourceCoupledWeight J i * O i := by
  simp [MeasurePathIntegralModel.sourceCoupledUnnormalizedExpectation,
    MeasurePathIntegralModel.sourceCoupledWeight, toMeasurePathIntegralModel]

/-- Finite-lattice source-coupled normalized expectation as ratio of finite sums. -/
theorem sourceCoupledExpectation_eq_finset_ratio
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ i, 0 ≤ L.plaquetteAction i)
    (J O : Fin L.nPlaquettes → ℂ) :
    MeasurePathIntegralModel.sourceCoupledExpectation
      (L.toMeasurePathIntegralModel hbar hbar_pos hPlaquette_nonneg) J O =
      (∑ i : Fin L.nPlaquettes,
        (L.toMeasurePathIntegralModel hbar hbar_pos hPlaquette_nonneg).sourceCoupledWeight J i * O i) /
      (∑ i : Fin L.nPlaquettes,
        (L.toMeasurePathIntegralModel hbar hbar_pos hPlaquette_nonneg).sourceCoupledWeight J i) := by
  unfold MeasurePathIntegralModel.sourceCoupledExpectation
  rw [L.sourceCoupledUnnormalizedExpectation_eq_finset_sum hbar hbar_pos hPlaquette_nonneg J O]
  rw [L.sourceCoupledPartition_eq_finset_sum hbar hbar_pos hPlaquette_nonneg J]

/-- Explicit Wilson-Euclidean form: no oscillatory phase (`S_R = 0`) on the lattice model. -/
theorem weight_eq_wilson_damping (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ i, 0 ≤ L.plaquetteAction i)
    (i : Fin L.nPlaquettes) :
    (L.toMeasurePathIntegralModel hbar hbar_pos hPlaquette_nonneg).weight i =
      Complex.exp ((-(L.imaginaryAction i / hbar) : ℂ)) := by
  simp [MeasurePathIntegralModel.weight, MeasurePathIntegralModel.actionReScaled,
    MeasurePathIntegralModel.actionImScaled, toMeasurePathIntegralModel, imaginaryAction]

end LatticeWilsonData

/-! ### Continuum-limit contracts for lattice-QCD sequences -/

/-- Wilson continuum admissibility: lattice spacing tends to zero and coupling tends to UV limit. -/
structure WilsonContinuumAdmissible where
  latticeSpacing : ℕ → ℝ
  inverseCoupling : ℕ → ℝ
  h_spacing_to_zero : Tendsto latticeSpacing atTop (nhds 0)
  h_inverseCoupling_to_top : Tendsto inverseCoupling atTop atTop

/-- Sequence of source-coupled partitions from a family of finite-lattice Wilson models. -/
def latticeSourceCoupledPartitionSeq
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J : ∀ n, Fin (Ls n).nPlaquettes → ℂ) :
    ℕ → ℂ :=
  fun n => MeasurePathIntegralModel.sourceCoupledPartition
    ((Ls n).toMeasurePathIntegralModel hbar hbar_pos (hPlaquette_nonneg n)) (J n)

/-- Sequence of source-coupled unnormalized expectations from a lattice family. -/
def latticeSourceCoupledUnnormalizedExpectationSeq
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ) :
    ℕ → ℂ :=
  fun n => MeasurePathIntegralModel.sourceCoupledUnnormalizedExpectation
    ((Ls n).toMeasurePathIntegralModel hbar hbar_pos (hPlaquette_nonneg n)) (J n) (O n)

/-- Sequence of source-coupled normalized expectations from a lattice family. -/
def latticeSourceCoupledExpectationSeq
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ) :
    ℕ → ℂ :=
  fun n => MeasurePathIntegralModel.sourceCoupledExpectation
    ((Ls n).toMeasurePathIntegralModel hbar hbar_pos (hPlaquette_nonneg n)) (J n) (O n)

/-- Sequence of connected generating functionals `W_n[J] := log Z_n[J]`. -/
def latticeConnectedGeneratingFunctionalSeq
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J : ∀ n, Fin (Ls n).nPlaquettes → ℂ) :
    ℕ → ℂ :=
  fun n =>
    Complex.log
      (MeasurePathIntegralModel.sourceCoupledPartition
        ((Ls n).toMeasurePathIntegralModel hbar hbar_pos (hPlaquette_nonneg n)) (J n))

/-- Continuum-limit transfer contract:
if lattice numerator and partition converge and the limit partition is nonzero,
then the normalized source-coupled expectation converges to the quotient limit. -/
theorem latticeSourceCoupledExpectationSeq_tendsto_of_tendsto
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (unnormLimit partitionLimit : ℂ)
    (hUnorm :
      Tendsto
        (latticeSourceCoupledUnnormalizedExpectationSeq
          Ls hbar hbar_pos hPlaquette_nonneg J O)
        atTop (nhds unnormLimit))
    (hPartition :
      Tendsto
        (latticeSourceCoupledPartitionSeq Ls hbar hbar_pos hPlaquette_nonneg J)
        atTop (nhds partitionLimit))
    (hPartition_ne : partitionLimit ≠ 0) :
    Tendsto
      (latticeSourceCoupledExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J O)
      atTop (nhds (unnormLimit / partitionLimit)) := by
  have hdiv := hUnorm.div hPartition hPartition_ne
  simpa [latticeSourceCoupledExpectationSeq,
    latticeSourceCoupledUnnormalizedExpectationSeq,
    latticeSourceCoupledPartitionSeq,
    MeasurePathIntegralModel.sourceCoupledExpectation] using hdiv

/-- Continuum-limit transfer for connected generating functional:
if `Z_n[J] → Z∞[J]` with `Z∞[J] ≠ 0`, then `log Z_n[J] → log Z∞[J]`. -/
theorem latticeConnectedGeneratingFunctionalSeq_tendsto_of_partition_tendsto
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (partitionLimit : ℂ)
    (hPartition :
      Tendsto
        (latticeSourceCoupledPartitionSeq Ls hbar hbar_pos hPlaquette_nonneg J)
        atTop (nhds partitionLimit))
    (hPartition_slit : partitionLimit ∈ Complex.slitPlane) :
    Tendsto
      (latticeConnectedGeneratingFunctionalSeq Ls hbar hbar_pos hPlaquette_nonneg J)
      atTop (nhds (Complex.log partitionLimit)) := by
  simpa [latticeConnectedGeneratingFunctionalSeq] using hPartition.clog hPartition_slit

/-- Unified continuum contract bundle for lattice source-coupled observables. -/
structure LatticeQFTContinuumContract
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ) where
  partitionLimit : ℂ
  unnormLimit : ℂ
  hPartition :
    Tendsto (latticeSourceCoupledPartitionSeq Ls hbar hbar_pos hPlaquette_nonneg J)
      atTop (nhds partitionLimit)
  hUnnorm :
    Tendsto (latticeSourceCoupledUnnormalizedExpectationSeq
      Ls hbar hbar_pos hPlaquette_nonneg J O) atTop (nhds unnormLimit)
  hPartition_ne : partitionLimit ≠ 0
  hPartition_slit : partitionLimit ∈ Complex.slitPlane

/-- Evidence package: candidate continuum limits extracted from lattice data.
No theorem-level claims are attached at this stage. -/
structure LatticeQFTContinuumEvidence
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ) where
  partitionLimitCandidate : ℂ
  unnormLimitCandidate : ℂ

/-- Assumption envelope that upgrades raw evidence into theorem-usable hypotheses.
This is the boundary separating numerical/modeling evidence from formal claims. -/
structure LatticeQFTContinuumAssumptionEnvelope
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (E : LatticeQFTContinuumEvidence Ls hbar hbar_pos hPlaquette_nonneg J O) where
  hPartition :
    Tendsto (latticeSourceCoupledPartitionSeq Ls hbar hbar_pos hPlaquette_nonneg J)
      atTop (nhds E.partitionLimitCandidate)
  hUnnorm :
    Tendsto (latticeSourceCoupledUnnormalizedExpectationSeq
      Ls hbar hbar_pos hPlaquette_nonneg J O) atTop (nhds E.unnormLimitCandidate)
  hPartition_ne : E.partitionLimitCandidate ≠ 0
  hPartition_slit : E.partitionLimitCandidate ∈ Complex.slitPlane

/-- Theoremization map from an evidence+assumption boundary into the unified continuum contract. -/
def LatticeQFTContinuumAssumptionEnvelope.toContract
    {Ls : ℕ → LatticeWilsonData}
    {hbar : ℝ} {hbar_pos : 0 < hbar}
    {hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i}
    {J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ}
    {E : LatticeQFTContinuumEvidence Ls hbar hbar_pos hPlaquette_nonneg J O}
    (A : LatticeQFTContinuumAssumptionEnvelope
      Ls hbar hbar_pos hPlaquette_nonneg J O E) :
    LatticeQFTContinuumContract Ls hbar hbar_pos hPlaquette_nonneg J O where
  partitionLimit := E.partitionLimitCandidate
  unnormLimit := E.unnormLimitCandidate
  hPartition := A.hPartition
  hUnnorm := A.hUnnorm
  hPartition_ne := A.hPartition_ne
  hPartition_slit := A.hPartition_slit

/-- Boundary consequence: expectation convergence from the assumption envelope. -/
theorem LatticeQFTContinuumAssumptionEnvelope.expectation_tendsto
    {Ls : ℕ → LatticeWilsonData}
    {hbar : ℝ} {hbar_pos : 0 < hbar}
    {hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i}
    {J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ}
    {E : LatticeQFTContinuumEvidence Ls hbar hbar_pos hPlaquette_nonneg J O}
    (A : LatticeQFTContinuumAssumptionEnvelope
      Ls hbar hbar_pos hPlaquette_nonneg J O E) :
    Tendsto (latticeSourceCoupledExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J O)
      atTop (nhds (E.unnormLimitCandidate / E.partitionLimitCandidate)) := by
  exact latticeSourceCoupledExpectationSeq_tendsto_of_tendsto
    Ls hbar hbar_pos hPlaquette_nonneg J O
    E.unnormLimitCandidate E.partitionLimitCandidate
    A.hUnnorm A.hPartition A.hPartition_ne

/-- Boundary consequence: connected generating functional convergence from the assumption envelope. -/
theorem LatticeQFTContinuumAssumptionEnvelope.connectedGeneratingFunctional_tendsto
    {Ls : ℕ → LatticeWilsonData}
    {hbar : ℝ} {hbar_pos : 0 < hbar}
    {hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i}
    {J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ}
    {E : LatticeQFTContinuumEvidence Ls hbar hbar_pos hPlaquette_nonneg J O}
    (A : LatticeQFTContinuumAssumptionEnvelope
      Ls hbar hbar_pos hPlaquette_nonneg J O E) :
    Tendsto (latticeConnectedGeneratingFunctionalSeq Ls hbar hbar_pos hPlaquette_nonneg J)
      atTop (nhds (Complex.log E.partitionLimitCandidate)) := by
  exact latticeConnectedGeneratingFunctionalSeq_tendsto_of_partition_tendsto
    Ls hbar hbar_pos hPlaquette_nonneg J
    E.partitionLimitCandidate A.hPartition A.hPartition_slit

/-- Boundary consequence: paired QFT convergence from the assumption envelope. -/
theorem LatticeQFTContinuumAssumptionEnvelope.qft_pair_tendsto
    {Ls : ℕ → LatticeWilsonData}
    {hbar : ℝ} {hbar_pos : 0 < hbar}
    {hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i}
    {J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ}
    {E : LatticeQFTContinuumEvidence Ls hbar hbar_pos hPlaquette_nonneg J O}
    (A : LatticeQFTContinuumAssumptionEnvelope
      Ls hbar hbar_pos hPlaquette_nonneg J O E) :
    Tendsto (latticeSourceCoupledExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J O)
      atTop (nhds (E.unnormLimitCandidate / E.partitionLimitCandidate)) ∧
    Tendsto (latticeConnectedGeneratingFunctionalSeq Ls hbar hbar_pos hPlaquette_nonneg J)
      atTop (nhds (Complex.log E.partitionLimitCandidate)) := by
  exact ⟨A.expectation_tendsto, A.connectedGeneratingFunctional_tendsto⟩

/-- Contract consequence: normalized source-coupled expectations converge. -/
theorem LatticeQFTContinuumContract.expectation_tendsto
    {Ls : ℕ → LatticeWilsonData}
    {hbar : ℝ} {hbar_pos : 0 < hbar}
    {hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i}
    {J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ}
    (C : LatticeQFTContinuumContract Ls hbar hbar_pos hPlaquette_nonneg J O) :
    Tendsto (latticeSourceCoupledExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J O)
      atTop (nhds (C.unnormLimit / C.partitionLimit)) :=
  latticeSourceCoupledExpectationSeq_tendsto_of_tendsto
    Ls hbar hbar_pos hPlaquette_nonneg J O C.unnormLimit C.partitionLimit
    C.hUnnorm C.hPartition C.hPartition_ne

/-- Contract consequence: connected generating functional converges. -/
theorem LatticeQFTContinuumContract.connectedGeneratingFunctional_tendsto
    {Ls : ℕ → LatticeWilsonData}
    {hbar : ℝ} {hbar_pos : 0 < hbar}
    {hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i}
    {J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ}
    (C : LatticeQFTContinuumContract Ls hbar hbar_pos hPlaquette_nonneg J O) :
    Tendsto (latticeConnectedGeneratingFunctionalSeq Ls hbar hbar_pos hPlaquette_nonneg J)
      atTop (nhds (Complex.log C.partitionLimit)) :=
  latticeConnectedGeneratingFunctionalSeq_tendsto_of_partition_tendsto
    Ls hbar hbar_pos hPlaquette_nonneg J C.partitionLimit C.hPartition C.hPartition_slit

/-- Contract consequence: both expectation and connected functional converge. -/
theorem LatticeQFTContinuumContract.qft_pair_tendsto
    {Ls : ℕ → LatticeWilsonData}
    {hbar : ℝ} {hbar_pos : 0 < hbar}
    {hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i}
    {J O : ∀ n, Fin (Ls n).nPlaquettes → ℂ}
    (C : LatticeQFTContinuumContract Ls hbar hbar_pos hPlaquette_nonneg J O) :
    Tendsto (latticeSourceCoupledExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J O)
      atTop (nhds (C.unnormLimit / C.partitionLimit)) ∧
    Tendsto (latticeConnectedGeneratingFunctionalSeq Ls hbar hbar_pos hPlaquette_nonneg J)
      atTop (nhds (Complex.log C.partitionLimit)) := by
  exact ⟨C.expectation_tendsto, C.connectedGeneratingFunctional_tendsto⟩

/-- Finite-lattice quadrature form (left Riemann sum) used by the discrete kernel. -/
def latticeQuadrature (f : Rat → Rat) (T : Rat) : Rat :=
  (Finset.range (NavierStokesClean.DiscreteKernel.diSteps T)).sum
    (fun i => f ((i : Rat) * NavierStokesClean.DiscreteKernel.diH) *
      NavierStokesClean.DiscreteKernel.diH)

/-- The finite-lattice quadrature is exactly the certified discrete kernel integral. -/
theorem latticeQuadrature_eq_discreteKernel (f : Rat → Rat) (T : Rat) :
    latticeQuadrature f T = NavierStokesClean.DiscreteKernel.discreteIntegral f T := rfl

/-- Compatibility with the MTPI bridge theorem from `MeasurePathIntegral`. -/
theorem latticeQuadrature_eq_measurePathKernel (f : Rat → Rat) (T : Rat) :
    latticeQuadrature f T =
      (Finset.range (NavierStokesClean.DiscreteKernel.diSteps T)).sum
        (fun i => f ((i : Rat) * NavierStokesClean.DiscreteKernel.diH) *
          NavierStokesClean.DiscreteKernel.diH) := by
  simpa [latticeQuadrature] using
    (discreteKernel_quadrature_form f T).symm

end

end NavierStokesClean.CATEPT
