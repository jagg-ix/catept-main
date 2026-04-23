import Mathlib.Data.Real.Basic
import Mathlib.Data.NNReal.Basic

/-!
# CATEPT External Interface: Brownian-Motion Layer

Opt-in contract layer for leveraging Brownian-process and stochastic-integral
formalization results without importing the external `brownian-motion`
repository directly.

Reference alignment points in the external project include:
- `BrownianMotion/Gaussian/BrownianMotion.lean`
- `BrownianMotion/Continuity/KolmogorovChentsov.lean`
- `BrownianMotion/StochasticIntegral/*.lean`
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.External

noncomputable section

/-- Certificate exposing Brownian-process law, continuity, and stochastic
integration contracts. -/
structure BrownianMotionCertificate where
  Ω : Type*
  trajectory : NNReal → Ω → ℝ
  startsAtZero : ∀ ω : Ω, trajectory 0 ω = 0
  continuousModification : NNReal → Ω → ℝ
  continuousModification_eq_trajectory :
    ∀ t : NNReal, ∀ ω : Ω, continuousModification t ω = trajectory t ω
  hasIndependentIncrements : Prop
  hasGaussianFiniteDimensionalLaws : Prop
  hasPreBrownianLaw : Prop
  hasContinuousModification : Prop
  hasKolmogorovChentsovControl : Prop
  hasItoInfrastructure : Prop
  covarianceKernel : NNReal → NNReal → ℝ
  covariance_eq_min : ∀ s t : NNReal, covarianceKernel s t = min s t
  incrementSecondMoment : NNReal → NNReal → ℝ
  incrementSecondMoment_nonneg : ∀ s t : NNReal, 0 ≤ incrementSecondMoment s t
  incrementSecondMoment_eq_absTimeDiff :
    ∀ s t : NNReal, incrementSecondMoment s t = |(s : ℝ) - (t : ℝ)|
  holderExponent : ℝ
  holderExponent_pos : 0 < holderExponent
  holderExponent_lt_half : holderExponent < (1 / 2 : ℝ)
  momentEnvelope : NNReal → ℝ
  momentEnvelope_nonneg : ∀ t : NNReal, 0 ≤ momentEnvelope t
  trajectory_abs_le_envelope : ∀ t : NNReal, ∀ ω : Ω, |trajectory t ω| ≤ momentEnvelope t
  hasIndependentIncrements_holds : hasIndependentIncrements
  hasGaussianFiniteDimensionalLaws_holds : hasGaussianFiniteDimensionalLaws
  hasPreBrownianLaw_holds : hasPreBrownianLaw
  hasContinuousModification_holds : hasContinuousModification
  hasKolmogorovChentsovControl_holds : hasKolmogorovChentsovControl
  hasItoInfrastructure_holds : hasItoInfrastructure

theorem BrownianMotionCertificate.has_independent_increments
    (w : BrownianMotionCertificate) : w.hasIndependentIncrements :=
  w.hasIndependentIncrements_holds

theorem BrownianMotionCertificate.has_gaussian_fdd
    (w : BrownianMotionCertificate) : w.hasGaussianFiniteDimensionalLaws :=
  w.hasGaussianFiniteDimensionalLaws_holds

theorem BrownianMotionCertificate.has_preBrownian
    (w : BrownianMotionCertificate) : w.hasPreBrownianLaw :=
  w.hasPreBrownianLaw_holds

theorem BrownianMotionCertificate.has_continuous_modification
    (w : BrownianMotionCertificate) : w.hasContinuousModification :=
  w.hasContinuousModification_holds

theorem BrownianMotionCertificate.has_kolmogorovChentsov_control
    (w : BrownianMotionCertificate) : w.hasKolmogorovChentsovControl :=
  w.hasKolmogorovChentsovControl_holds

theorem BrownianMotionCertificate.has_ito_infrastructure
    (w : BrownianMotionCertificate) : w.hasItoInfrastructure :=
  w.hasItoInfrastructure_holds

theorem BrownianMotionCertificate.covariance_kernel_min
    (w : BrownianMotionCertificate) (s t : NNReal) :
    w.covarianceKernel s t = min s t :=
  w.covariance_eq_min s t

theorem BrownianMotionCertificate.starts_at_zero
    (w : BrownianMotionCertificate) (ω : w.Ω) :
    w.trajectory 0 ω = 0 :=
  w.startsAtZero ω

theorem BrownianMotionCertificate.continuousModification_matches
    (w : BrownianMotionCertificate) (t : NNReal) (ω : w.Ω) :
    w.continuousModification t ω = w.trajectory t ω :=
  w.continuousModification_eq_trajectory t ω

theorem BrownianMotionCertificate.increment_secondMoment_nonneg
    (w : BrownianMotionCertificate) (s t : NNReal) :
    0 ≤ w.incrementSecondMoment s t :=
  w.incrementSecondMoment_nonneg s t

theorem BrownianMotionCertificate.increment_secondMoment_absTimeDiff
    (w : BrownianMotionCertificate) (s t : NNReal) :
    w.incrementSecondMoment s t = |(s : ℝ) - (t : ℝ)| :=
  w.incrementSecondMoment_eq_absTimeDiff s t

theorem BrownianMotionCertificate.holder_exponent_range
    (w : BrownianMotionCertificate) :
    0 < w.holderExponent ∧ w.holderExponent < (1 / 2 : ℝ) :=
  ⟨w.holderExponent_pos, w.holderExponent_lt_half⟩

theorem BrownianMotionCertificate.trajectory_abs_bound
    (w : BrownianMotionCertificate) (t : NNReal) (ω : w.Ω) :
    |w.trajectory t ω| ≤ w.momentEnvelope t :=
  w.trajectory_abs_le_envelope t ω

theorem BrownianMotionCertificate.process_bundle
    (w : BrownianMotionCertificate) :
    w.hasIndependentIncrements ∧ w.hasGaussianFiniteDimensionalLaws ∧
      w.hasPreBrownianLaw ∧ w.hasContinuousModification ∧
      w.hasKolmogorovChentsovControl ∧ w.hasItoInfrastructure := by
  exact ⟨w.has_independent_increments, w.has_gaussian_fdd, w.has_preBrownian,
    w.has_continuous_modification, w.has_kolmogorovChentsov_control,
    w.has_ito_infrastructure⟩

theorem BrownianMotionCertificate.quantitative_bundle
    (w : BrownianMotionCertificate) :
    (∀ ω : w.Ω, w.trajectory 0 ω = 0) ∧
    (∀ s t : NNReal, w.incrementSecondMoment s t = |(s : ℝ) - (t : ℝ)|) ∧
    (0 < w.holderExponent ∧ w.holderExponent < (1 / 2 : ℝ)) ∧
    (∀ t : NNReal, ∀ ω : w.Ω, |w.trajectory t ω| ≤ w.momentEnvelope t) := by
  exact ⟨w.starts_at_zero, w.increment_secondMoment_absTimeDiff,
    w.holder_exponent_range, w.trajectory_abs_bound⟩

end

end NavierStokesClean.CATEPT.External
