import Mathlib.Data.Real.Basic
import Mathlib.Data.NNReal.Basic
import NavierStokesClean.CATEPT.External.ETHQuantumThermalizationBridge
import NavierStokesClean.CATEPT.External.GibbsMeasureInterface
import NavierStokesClean.CATEPT.External.BrownianMotionInterface
import NavierStokesClean.CATEPT.External.KolmogorovComplexityInterface
import NavierStokesClean.CATEPT.External.QuantumInfoInterface
import NavierStokesClean.CATEPT.CATEPTSpaceTime
import NavierStokesClean.CATEPT.External.BellEntanglementRelativityBridge

/-!
# ETH-Gibbs-Brownian Integration

Integrates ETH thermalization contracts with Gibbs-measure and Brownian-process
external interfaces.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.External

noncomputable section

namespace ETHGibbsBrownianIntegration

open ETHQuantumThermalizationBridge

/-- Integrated contract:
ETH thermalization with dephasing plus Gibbs and Brownian certificates. -/
theorem eth_with_gibbs_and_brownian_certificate
    (wETH : ETHWitness)
    (wCarleson : CarlesonSpectralCertificate)
    (wOS : Pphi2OSCertificate)
    (wEntropy : ThermodynamicsEntropyCertificate)
    (wGibbs : GibbsMeasureCertificate)
    (wBrownian : BrownianMotionCertificate)
    (O : wETH.Observable)
    (i : wETH.EigenIndex)
    {εDiag ε : ℝ}
    (hDiag : Real.exp (-wETH.decayRate * wETH.entropyAt i) ≤ εDiag)
    (hTotal : εDiag + wCarleson.projectionErrorEnvelope ≤ ε) :
    ThermalizedWithDephasing wETH wCarleson O i ε ∧
      wOS.fullOS ∧
      wEntropy.canonicalEntropyExists ∧
      wGibbs.gibbsMeasureExists ∧
      wGibbs.productMeasureIsGibbs ∧
      wBrownian.hasIndependentIncrements ∧
      wBrownian.hasContinuousModification ∧
      0 < wGibbs.partitionFunction ∧
      (∀ ξ : wGibbs.Config, wGibbs.gibbsWeight ξ = Real.exp (-wGibbs.inverseTemperature * wGibbs.energy ξ)) ∧
      (∀ s t : NNReal, wBrownian.incrementSecondMoment s t = |(s : ℝ) - (t : ℝ)|) ∧
      0 < wBrownian.holderExponent ∧
      wBrownian.holderExponent < (1 / 2 : ℝ) := by
  refine ⟨
    eth_carleson_implies_thermalizedWithDephasing wETH wCarleson O i hDiag hTotal,
    wOS.fullOS_holds,
    wEntropy.has_canonicalEntropy,
    wGibbs.gibbs_measure_exists,
    wGibbs.product_measure_is_gibbs,
    wBrownian.has_independent_increments,
    wBrownian.has_continuous_modification,
    wGibbs.partitionFunction_positive,
    wGibbs.gibbs_weight_formula_eq,
    wBrownian.increment_secondMoment_absTimeDiff,
    wBrownian.holderExponent_pos,
    wBrownian.holderExponent_lt_half
  ⟩

/-- Stochastic-process side consequence used in thermodynamic-path arguments:
Brownian covariance kernel follows the `min` law. -/
theorem brownian_covariance_min_contract
    (wBrownian : BrownianMotionCertificate)
    (s t : NNReal) :
    wBrownian.covarianceKernel s t = min s t :=
  wBrownian.covariance_kernel_min s t

/-- External-certificate dependency theorem on the CAT/EPT spatial carrier:
if Bell informational-locality holds, then Gibbs and Brownian witness contracts
can be attached on `CATEPTSpace` for downstream bridge usage. -/
theorem cateptSpace_bell_locality_gibbs_brownian_contract
    (x : NavierStokesClean.CATEPT.CATEPTSpace)
    (wNoFTL : NoFasterThanLightCertificate)
    (wIso : IsabelleMarriesDiracCertificate)
    (wGibbs : GibbsMeasureCertificate)
    (wBrownian : BrownianMotionCertificate)
    (hLocal : BellEntanglementRelativityBridge.InformationalLocality wNoFTL wIso) :
    (∃ y : NavierStokesClean.CATEPT.CATEPTSpace, y = x) ∧
      wGibbs.gibbsMeasureExists ∧
      wGibbs.productMeasureIsGibbs ∧
      wBrownian.hasIndependentIncrements ∧
      wBrownian.hasContinuousModification ∧
      (∀ ξ : wGibbs.Config, wGibbs.normalizedDensity ξ = wGibbs.gibbsWeight ξ / wGibbs.partitionFunction) ∧
      (∀ s t : NNReal, wBrownian.incrementSecondMoment s t = |(s : ℝ) - (t : ℝ)|) := by
  rcases hLocal with ⟨_, _⟩
  refine ⟨⟨x, rfl⟩, wGibbs.gibbs_measure_exists, wGibbs.product_measure_is_gibbs,
    wBrownian.has_independent_increments, wBrownian.has_continuous_modification,
    wGibbs.normalized_density_eq, wBrownian.increment_secondMoment_absTimeDiff⟩

/-- Hardened CAT/EPT-space closure:
adds quantitative Gibbs/Brownian witness bundles on top of Bell-locality. -/
theorem cateptSpace_hardened_contract_bundle
    (x : NavierStokesClean.CATEPT.CATEPTSpace)
    (wNoFTL : NoFasterThanLightCertificate)
    (wIso : IsabelleMarriesDiracCertificate)
    (wGibbs : GibbsMeasureCertificate)
    (wBrownian : BrownianMotionCertificate)
    (hLocal : BellEntanglementRelativityBridge.InformationalLocality wNoFTL wIso) :
    (∃ y : NavierStokesClean.CATEPT.CATEPTSpace, y = x) ∧
      (wGibbs.hasSpecification ∧
        wGibbs.specificationConsistent ∧
        wGibbs.specificationProper ∧
        wGibbs.specificationMarkov ∧
        wGibbs.hasConditionalExpectationCharacterization) ∧
      ((∀ ξ : wGibbs.Config, wGibbs.gibbsWeight ξ = Real.exp (-wGibbs.inverseTemperature * wGibbs.energy ξ)) ∧
        0 < wGibbs.partitionFunction ∧
        (∀ ξ : wGibbs.Config, wGibbs.normalizedDensity ξ = wGibbs.gibbsWeight ξ / wGibbs.partitionFunction)) ∧
      (wBrownian.hasIndependentIncrements ∧
        wBrownian.hasGaussianFiniteDimensionalLaws ∧
        wBrownian.hasPreBrownianLaw ∧
        wBrownian.hasContinuousModification ∧
        wBrownian.hasKolmogorovChentsovControl ∧
        wBrownian.hasItoInfrastructure) ∧
      ((∀ ω : wBrownian.Ω, wBrownian.trajectory 0 ω = 0) ∧
        (∀ s t : NNReal, wBrownian.incrementSecondMoment s t = |(s : ℝ) - (t : ℝ)|) ∧
        (0 < wBrownian.holderExponent ∧ wBrownian.holderExponent < (1 / 2 : ℝ)) ∧
        (∀ t : NNReal, ∀ ω : wBrownian.Ω, |wBrownian.trajectory t ω| ≤ wBrownian.momentEnvelope t)) := by
  rcases hLocal with ⟨_, _⟩
  exact ⟨⟨x, rfl⟩, wGibbs.dlr_bundle, wGibbs.quantitative_bundle,
    wBrownian.process_bundle, wBrownian.quantitative_bundle⟩

/-- Hardened CAT/EPT + Bell-locality + AIT closure:
adds algorithmic-information (Kolmogorov/Chaitin) witness contracts on top of the
Gibbs/Brownian bundle. -/
theorem cateptSpace_hardened_contract_bundle_with_kolmogorov
    (x : NavierStokesClean.CATEPT.CATEPTSpace)
    (wNoFTL : NoFasterThanLightCertificate)
    (wIso : IsabelleMarriesDiracCertificate)
    (wGibbs : GibbsMeasureCertificate)
    (wBrownian : BrownianMotionCertificate)
    (wKolm : KolmogorovComplexityCertificate)
    (hLocal : BellEntanglementRelativityBridge.InformationalLocality wNoFTL wIso) :
    (∃ y : NavierStokesClean.CATEPT.CATEPTSpace, y = x) ∧
      (wGibbs.hasSpecification ∧
        wGibbs.specificationConsistent ∧
        wGibbs.specificationProper ∧
        wGibbs.specificationMarkov ∧
        wGibbs.hasConditionalExpectationCharacterization) ∧
      ((∀ ξ : wGibbs.Config, wGibbs.gibbsWeight ξ = Real.exp (-wGibbs.inverseTemperature * wGibbs.energy ξ)) ∧
        0 < wGibbs.partitionFunction ∧
        (∀ ξ : wGibbs.Config, wGibbs.normalizedDensity ξ = wGibbs.gibbsWeight ξ / wGibbs.partitionFunction)) ∧
      (wBrownian.hasIndependentIncrements ∧
        wBrownian.hasGaussianFiniteDimensionalLaws ∧
        wBrownian.hasPreBrownianLaw ∧
        wBrownian.hasContinuousModification ∧
        wBrownian.hasKolmogorovChentsovControl ∧
        wBrownian.hasItoInfrastructure) ∧
      ((∀ ω : wBrownian.Ω, wBrownian.trajectory 0 ω = 0) ∧
        (∀ s t : NNReal, wBrownian.incrementSecondMoment s t = |(s : ℝ) - (t : ℝ)|) ∧
        (0 < wBrownian.holderExponent ∧ wBrownian.holderExponent < (1 / 2 : ℝ)) ∧
        (∀ t : NNReal, ∀ ω : wBrownian.Ω, |wBrownian.trajectory t ω| ≤ wBrownian.momentEnvelope t)) ∧
      (wKolm.hasOptimalConditionalUniversal ∧
        wKolm.noComputableUnboundedLowerBound ∧
        wKolm.notComputablePlainKNat ∧
        wKolm.chaitinBound ∧
        wKolm.chaitinIncompleteness) ∧
      (∃ c : ℕ, ∀ b : wKolm.BitString,
        wKolm.plainK wKolm.universalMap b ≤ (wKolm.programLength b : ENat) + c) := by
  have hBase :=
    cateptSpace_hardened_contract_bundle x wNoFTL wIso wGibbs wBrownian hLocal
  rcases hBase with ⟨hx, hGibbsCore, hGibbsQuant, hBrownCore, hBrownQuant⟩
  refine ⟨hx, hGibbsCore, hGibbsQuant, hBrownCore, hBrownQuant,
    wKolm.ait_core_bundle, wKolm.plainK_le_length⟩

/-- Fully hardened CAT/EPT external closure:
Bell-locality + Gibbs/Brownian + Kolmogorov + finite-dimensional quantum info. -/
theorem cateptSpace_hardened_contract_bundle_with_quantumInfo
    (x : NavierStokesClean.CATEPT.CATEPTSpace)
    (wNoFTL : NoFasterThanLightCertificate)
    (wIso : IsabelleMarriesDiracCertificate)
    (wGibbs : GibbsMeasureCertificate)
    (wBrownian : BrownianMotionCertificate)
    (wKolm : KolmogorovComplexityCertificate)
    (wQI : QuantumInfoCertificate)
    (hLocal : BellEntanglementRelativityBridge.InformationalLocality wNoFTL wIso) :
    (∃ y : NavierStokesClean.CATEPT.CATEPTSpace, y = x) ∧
      (wGibbs.hasSpecification ∧
        wGibbs.specificationConsistent ∧
        wGibbs.specificationProper ∧
        wGibbs.specificationMarkov ∧
        wGibbs.hasConditionalExpectationCharacterization) ∧
      ((∀ ξ : wGibbs.Config, wGibbs.gibbsWeight ξ = Real.exp (-wGibbs.inverseTemperature * wGibbs.energy ξ)) ∧
        0 < wGibbs.partitionFunction ∧
        (∀ ξ : wGibbs.Config, wGibbs.normalizedDensity ξ = wGibbs.gibbsWeight ξ / wGibbs.partitionFunction)) ∧
      (wBrownian.hasIndependentIncrements ∧
        wBrownian.hasGaussianFiniteDimensionalLaws ∧
        wBrownian.hasPreBrownianLaw ∧
        wBrownian.hasContinuousModification ∧
        wBrownian.hasKolmogorovChentsovControl ∧
        wBrownian.hasItoInfrastructure) ∧
      ((∀ ω : wBrownian.Ω, wBrownian.trajectory 0 ω = 0) ∧
        (∀ s t : NNReal, wBrownian.incrementSecondMoment s t = |(s : ℝ) - (t : ℝ)|) ∧
        (0 < wBrownian.holderExponent ∧ wBrownian.holderExponent < (1 / 2 : ℝ)) ∧
        (∀ t : NNReal, ∀ ω : wBrownian.Ω, |wBrownian.trajectory t ω| ≤ wBrownian.momentEnvelope t)) ∧
      (wKolm.hasOptimalConditionalUniversal ∧
        wKolm.noComputableUnboundedLowerBound ∧
        wKolm.notComputablePlainKNat ∧
        wKolm.chaitinBound ∧
        wKolm.chaitinIncompleteness) ∧
      (∃ c : ℕ, ∀ b : wKolm.BitString,
        wKolm.plainK wKolm.universalMap b ≤ (wKolm.programLength b : ENat) + c) ∧
      ((∀ ρ : wQI.State, 0 ≤ wQI.vonNeumannEntropy ρ) ∧
        (∀ ρ σ : wQI.State, 0 ≤ wQI.fidelity ρ σ ∧ wQI.fidelity ρ σ ≤ 1) ∧
        (∀ Φ : wQI.Channel, ∀ ρ σ : wQI.State,
          wQI.relativeEntropy (wQI.applyChannel Φ ρ) (wQI.applyChannel Φ σ) ≤
            wQI.relativeEntropy ρ σ) ∧
        (∀ τ : wQI.TripartiteState, 0 ≤ wQI.qConditionalEntropy τ) ∧
        (∀ τ : wQI.TripartiteState, 0 ≤ wQI.qConditionalMutualInfo τ) ∧
        wQI.hasGeneralizedSteinsLemma ∧
        wQI.hasCapacityTheory ∧
        wQI.hasEntanglementTheory) := by
  have hBase :=
    cateptSpace_hardened_contract_bundle_with_kolmogorov
      x wNoFTL wIso wGibbs wBrownian wKolm hLocal
  rcases hBase with ⟨hx, hGibbsCore, hGibbsQuant, hBrownCore, hBrownQuant, hKolmCore, hKolmQuant⟩
  exact ⟨hx, hGibbsCore, hGibbsQuant, hBrownCore, hBrownQuant, hKolmCore, hKolmQuant,
    wQI.quantumInfo_core_bundle⟩

/-- Fully hardened CAT/EPT external closure + explicit channel-monotonicity lane:
extends the quantum-info bundle with Bell-locality-aligned CPTP monotonicity
facts (fidelity monotonicity, relative-entropy DPI, QCMI nonnegativity). -/
theorem cateptSpace_hardened_contract_bundle_with_quantumInfo_monotone
    (x : NavierStokesClean.CATEPT.CATEPTSpace)
    (wNoFTL : NoFasterThanLightCertificate)
    (wIso : IsabelleMarriesDiracCertificate)
    (wGibbs : GibbsMeasureCertificate)
    (wBrownian : BrownianMotionCertificate)
    (wKolm : KolmogorovComplexityCertificate)
    (wQI : QuantumInfoCertificate)
    (hLocal : BellEntanglementRelativityBridge.InformationalLocality wNoFTL wIso)
    (Φ : wQI.Channel)
    (ρ σ : wQI.State)
    (τ : wQI.TripartiteState) :
    ((∃ y : NavierStokesClean.CATEPT.CATEPTSpace, y = x) ∧
      (wGibbs.hasSpecification ∧
        wGibbs.specificationConsistent ∧
        wGibbs.specificationProper ∧
        wGibbs.specificationMarkov ∧
        wGibbs.hasConditionalExpectationCharacterization) ∧
      ((∀ ξ : wGibbs.Config, wGibbs.gibbsWeight ξ = Real.exp (-wGibbs.inverseTemperature * wGibbs.energy ξ)) ∧
        0 < wGibbs.partitionFunction ∧
        (∀ ξ : wGibbs.Config, wGibbs.normalizedDensity ξ = wGibbs.gibbsWeight ξ / wGibbs.partitionFunction)) ∧
      (wBrownian.hasIndependentIncrements ∧
        wBrownian.hasGaussianFiniteDimensionalLaws ∧
        wBrownian.hasPreBrownianLaw ∧
        wBrownian.hasContinuousModification ∧
        wBrownian.hasKolmogorovChentsovControl ∧
        wBrownian.hasItoInfrastructure) ∧
      ((∀ ω : wBrownian.Ω, wBrownian.trajectory 0 ω = 0) ∧
        (∀ s t : NNReal, wBrownian.incrementSecondMoment s t = |(s : ℝ) - (t : ℝ)|) ∧
        (0 < wBrownian.holderExponent ∧ wBrownian.holderExponent < (1 / 2 : ℝ)) ∧
        (∀ t : NNReal, ∀ ω : wBrownian.Ω, |wBrownian.trajectory t ω| ≤ wBrownian.momentEnvelope t)) ∧
      (wKolm.hasOptimalConditionalUniversal ∧
        wKolm.noComputableUnboundedLowerBound ∧
        wKolm.notComputablePlainKNat ∧
        wKolm.chaitinBound ∧
        wKolm.chaitinIncompleteness) ∧
      (∃ c : ℕ, ∀ b : wKolm.BitString,
        wKolm.plainK wKolm.universalMap b ≤ (wKolm.programLength b : ENat) + c) ∧
      ((∀ ρ : wQI.State, 0 ≤ wQI.vonNeumannEntropy ρ) ∧
        (∀ ρ σ : wQI.State, 0 ≤ wQI.fidelity ρ σ ∧ wQI.fidelity ρ σ ≤ 1) ∧
        (∀ Φ : wQI.Channel, ∀ ρ σ : wQI.State,
          wQI.relativeEntropy (wQI.applyChannel Φ ρ) (wQI.applyChannel Φ σ) ≤
            wQI.relativeEntropy ρ σ) ∧
        (∀ τ : wQI.TripartiteState, 0 ≤ wQI.qConditionalEntropy τ) ∧
        (∀ τ : wQI.TripartiteState, 0 ≤ wQI.qConditionalMutualInfo τ) ∧
        wQI.hasGeneralizedSteinsLemma ∧
        wQI.hasCapacityTheory ∧
        wQI.hasEntanglementTheory)) ∧
    wQI.fidelity (wQI.applyChannel Φ ρ) (wQI.applyChannel Φ σ) ≥ wQI.fidelity ρ σ ∧
    wQI.relativeEntropy (wQI.applyChannel Φ ρ) (wQI.applyChannel Φ σ) ≤
      wQI.relativeEntropy ρ σ ∧
    0 ≤ wQI.qConditionalMutualInfo τ := by
  have hBase :=
    cateptSpace_hardened_contract_bundle_with_quantumInfo
      x wNoFTL wIso wGibbs wBrownian wKolm wQI hLocal
  have hMon :=
    BellEntanglementRelativityBridge.informationalLocality_quantumInfo_monotone_bundle
      wNoFTL wIso wQI hLocal Φ ρ σ τ
  exact ⟨hBase, hMon.2.1, hMon.2.2.1, hMon.2.2.2⟩

end ETHGibbsBrownianIntegration

end

end NavierStokesClean.CATEPT.External
