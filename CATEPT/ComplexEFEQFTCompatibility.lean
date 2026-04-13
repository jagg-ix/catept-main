import NavierStokesClean.CATEPT.MTPIEinsteinDerivationBridge
import NavierStokesClean.CATEPT.LatticeQCDBridge

/-!
# CAT/EPT Complex-EFE QFT Compatibility (WP4)

Compatibility layer connecting the MTPI->complex-EFE derivation stack with:

- curved-space MTPI base-measure rewrites
- lattice-QCD continuum contracts for source-coupled expectations

The central theorem shows that, under paired lattice continuum contracts and a
limit-level complex-EFE relation, the lattice complex-EFE expectation residual
converges to zero.
-/

set_option autoImplicit false

open Filter

namespace NavierStokesClean.CATEPT

noncomputable section

namespace CurvedMeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α]
variable (c : CurvedMeasurePathIntegralModel α)
variable (C : ComplexEFEContract α)

/-- Curved-space compatibility rewrite for the stress-connected functional in
flat-density limit (`ρ_g = 1`). -/
theorem stressConnectedFunctional_eq_base_log_of_density_one
    (hρ : c.geom.volumeDensity = fun _ => (1 : ℝ)) :
    c.stressConnectedFunctional C =
      Complex.log (∫ x, (c.toMeasurePathIntegralModel).sourceCoupledWeight C.sourceFromStress x
        ∂c.geom.baseMeasure) := by
  unfold stressConnectedFunctional
  simpa using c.connectedGeneratingFunctional_eq_base_log_of_density_one C.sourceFromStress hρ

end CurvedMeasurePathIntegralModel

namespace LatticeWilsonData

/-- Einstein-observable lattice expectation sequence (source-coupled). -/
def latticeEinsteinExpectationSeq
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (OEin : ∀ n, Fin (Ls n).nPlaquettes → ℂ) :
    ℕ → ℂ :=
  latticeSourceCoupledExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OEin

/-- Stress-observable lattice expectation sequence (source-coupled). -/
def latticeStressExpectationSeq
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (OStress : ∀ n, Fin (Ls n).nPlaquettes → ℂ) :
    ℕ → ℂ :=
  latticeSourceCoupledExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OStress

/-- Pair of lattice continuum contracts plus a complex-EFE limit relation. -/
structure LatticeComplexEFELimitCompatibility
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (OEin OStress : ∀ n, Fin (Ls n).nPlaquettes → ℂ) where
  einsteinContract : LatticeQFTContinuumContract Ls hbar hbar_pos hPlaquette_nonneg J OEin
  stressContract : LatticeQFTContinuumContract Ls hbar hbar_pos hPlaquette_nonneg J OStress
  coupling : ℂ
  limit_residual_zero :
    (einsteinContract.unnormLimit / einsteinContract.partitionLimit) -
      coupling * (stressContract.unnormLimit / stressContract.partitionLimit) = 0

/-- Lattice complex-EFE expectation residual sequence. -/
def latticeComplexEFEResidualSeq
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (OEin OStress : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (H : LatticeComplexEFELimitCompatibility
      Ls hbar hbar_pos hPlaquette_nonneg J OEin OStress) :
    ℕ → ℂ :=
  fun n =>
    latticeEinsteinExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OEin n -
      H.coupling * latticeStressExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OStress n

/-- Einstein expectation sequence convergence from its continuum contract. -/
theorem latticeEinsteinExpectationSeq_tendsto_of_contract
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (OEin : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (C : LatticeQFTContinuumContract Ls hbar hbar_pos hPlaquette_nonneg J OEin) :
    Tendsto
      (latticeEinsteinExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OEin)
      atTop (nhds (C.unnormLimit / C.partitionLimit)) :=
  C.expectation_tendsto

/-- Stress expectation sequence convergence from its continuum contract. -/
theorem latticeStressExpectationSeq_tendsto_of_contract
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (OStress : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (C : LatticeQFTContinuumContract Ls hbar hbar_pos hPlaquette_nonneg J OStress) :
    Tendsto
      (latticeStressExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OStress)
      atTop (nhds (C.unnormLimit / C.partitionLimit)) :=
  C.expectation_tendsto

/-- Under paired continuum contracts and a limit-level EFE relation,
the lattice complex-EFE residual sequence converges to zero. -/
theorem latticeComplexEFEResidualSeq_tendsto_zero
    (Ls : ℕ → LatticeWilsonData)
    (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hPlaquette_nonneg : ∀ n i, 0 ≤ (Ls n).plaquetteAction i)
    (J : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (OEin OStress : ∀ n, Fin (Ls n).nPlaquettes → ℂ)
    (H : LatticeComplexEFELimitCompatibility
      Ls hbar hbar_pos hPlaquette_nonneg J OEin OStress) :
    Tendsto
      (latticeComplexEFEResidualSeq Ls hbar hbar_pos hPlaquette_nonneg J OEin OStress H)
      atTop (nhds 0) := by
  let einLim : ℂ := H.einsteinContract.unnormLimit / H.einsteinContract.partitionLimit
  let stressLim : ℂ := H.stressContract.unnormLimit / H.stressContract.partitionLimit

  have hEin : Tendsto
      (latticeEinsteinExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OEin)
      atTop (nhds einLim) := by
    simpa [einLim] using
      latticeEinsteinExpectationSeq_tendsto_of_contract
        Ls hbar hbar_pos hPlaquette_nonneg J OEin H.einsteinContract

  have hStress : Tendsto
      (latticeStressExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OStress)
      atTop (nhds stressLim) := by
    simpa [stressLim] using
      latticeStressExpectationSeq_tendsto_of_contract
        Ls hbar hbar_pos hPlaquette_nonneg J OStress H.stressContract

  have hPair : Tendsto
      (fun n =>
        (latticeEinsteinExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OEin n,
         latticeStressExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OStress n))
      atTop (nhds (einLim, stressLim)) := by
    simpa [nhds_prod_eq] using (hEin.prodMk hStress)

  have hMap : Tendsto
      (fun n =>
        (fun p : ℂ × ℂ => p.1 - H.coupling * p.2)
          (latticeEinsteinExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OEin n,
           latticeStressExpectationSeq Ls hbar hbar_pos hPlaquette_nonneg J OStress n))
      atTop (nhds (einLim - H.coupling * stressLim)) := by
    exact (continuous_fst.sub (continuous_const.mul continuous_snd)).tendsto
      (einLim, stressLim) |>.comp hPair

  have hLimZero : einLim - H.coupling * stressLim = 0 := by
    simpa [einLim, stressLim] using H.limit_residual_zero

  simpa [latticeComplexEFEResidualSeq, hLimZero] using hMap

end LatticeWilsonData

end

end NavierStokesClean.CATEPT
