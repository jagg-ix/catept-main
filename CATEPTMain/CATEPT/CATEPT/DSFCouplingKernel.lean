import CATEPTMain.CATEPT.CATEPT.GeometryGauge
import CATEPTMain.CATEPT.CATEPT.EntropicLambdaCoupler

set_option autoImplicit false

/-!
# DSF Coupling Kernel

Minimal CAT/EPT-facing kernel for the DSF reinterpretation of gravitational coupling:

- `dsfLambda`: `lambda(R, phi) = lambda0 * (1 + alpha/(R+eps) + gamma*phi^2)`
- `dsfLambdaInverseScale`: `(8*pi*lambda)^(-1)`
- `dsfLocalEntropyRate`: DSF-dressed local second-law rate built on Tolman scaling

This module is intentionally algebraic. It does not close the full Einstein-Klein-Gordon
system; it provides reusable definitions and inequalities to connect DSF notebooks to
existing CATEPT clock/entropy infrastructure.
-/

noncomputable section

namespace CATEPTMain.CATEPT.CATEPT

/-- DSF coupling kernel:
    `lambda(R, phi) = lambda0 * (1 + alpha/(R+eps) + gamma*phi^2)`. -/
def dsfLambda
    (lambda0 alpha eps gamma ricci phi : ℝ) : ℝ :=
  lambda0 * (1 + alpha / (ricci + eps) + gamma * phi ^ 2)

/-- Inverse DSF coupling scale:
  `(8*pi*lambda(R,phi))^(-1)`. -/
def dsfLambdaInverseScale
    (lambda0 alpha eps gamma ricci phi : ℝ) : ℝ :=
  1 / (8 * Real.pi * dsfLambda lambda0 alpha eps gamma ricci phi)

/-- If curvature/entropy feedback is disabled, DSF coupling reduces to `lambda0`. -/
theorem dsfLambda_no_feedback
    (lambda0 ricci eps phi : ℝ) :
    dsfLambda lambda0 0 eps 0 ricci phi = lambda0 := by
  unfold dsfLambda
  ring

/-- Entropy contribution is nonnegative when `gamma >= 0` (since `phi^2 >= 0`). -/
theorem dsfLambda_entropy_term_nonneg
    (gamma phi : ℝ) (hgamma : 0 <= gamma) :
    0 <= gamma * phi ^ 2 := by
  exact mul_nonneg hgamma (sq_nonneg phi)

/-- Positivity of the inverse DSF coupling scale from positivity of `lambda`. -/
theorem dsfLambdaInverseScale_pos
    (lambda0 alpha eps gamma ricci phi : ℝ)
    (hlam : 0 < dsfLambda lambda0 alpha eps gamma ricci phi) :
    0 < dsfLambdaInverseScale lambda0 alpha eps gamma ricci phi := by
  unfold dsfLambdaInverseScale
  have h8pi : 0 < 8 * Real.pi := by
    nlinarith [Real.pi_pos]
  exact one_div_pos.mpr (mul_pos h8pi hlam)

/-- Differential-feedback components used in DSF flow heuristics.

These match the notebook-level formulas:
`d lambda / dR = -lambda0*alpha/(R+eps)^2`,
`d lambda / dphi = 2*lambda0*gamma*phi`.
-/
def dsfLambda_dRicci
    (lambda0 alpha eps ricci : ℝ) : ℝ :=
  -lambda0 * alpha / (ricci + eps) ^ 2

def dsfLambda_dPhi
    (lambda0 gamma phi : ℝ) : ℝ :=
  2 * lambda0 * gamma * phi

/-- If `lambda0, alpha >= 0`, then `d lambda / dR <= 0`. -/
theorem dsfLambda_dRicci_nonpos
    (lambda0 alpha eps ricci : ℝ)
    (hlambda0 : 0 <= lambda0)
    (halpha : 0 <= alpha) :
    dsfLambda_dRicci lambda0 alpha eps ricci <= 0 := by
  unfold dsfLambda_dRicci
  have hdiv : 0 <= (lambda0 * alpha) / (ricci + eps) ^ 2 :=
    div_nonneg (mul_nonneg hlambda0 halpha) (sq_nonneg (ricci + eps))
  have hneg :
      -lambda0 * alpha / (ricci + eps) ^ 2 =
      -((lambda0 * alpha) / (ricci + eps) ^ 2) := by
    rw [neg_mul, neg_div]
  rw [hneg]
  exact neg_nonpos.mpr hdiv

/-- If `lambda0, gamma, phi >= 0`, then `d lambda / dphi >= 0`. -/
theorem dsfLambda_dPhi_nonneg
    (lambda0 gamma phi : ℝ)
    (hlambda0 : 0 <= lambda0)
    (hgamma : 0 <= gamma)
    (hphi : 0 <= phi) :
    0 <= dsfLambda_dPhi lambda0 gamma phi := by
  unfold dsfLambda_dPhi
  have h2l : 0 <= (2 : ℝ) * lambda0 :=
    mul_nonneg (by norm_num) hlambda0
  have h2lg : 0 <= ((2 : ℝ) * lambda0) * gamma :=
    mul_nonneg h2l hgamma
  exact mul_nonneg h2lg hphi

/-! ## Artifact-backed bridge scalars (CSV extraction set)

These definitions encode the equations extracted from the CSV-linked artifacts:

* `m_tau = hbar_tau * omega_tau / c^2` (dimensional bridge for mass scale)
* `Delta tau_n = (h / (m0 * c^2)) * sqrt(spectralTerm)`
-/

/-- Scalar mass map from the QCF bridge identity:
`m_tau = hbar_tau * omega_tau / c^2`. -/
def qcfMassFromTauFrequency
    (hbarTau omegaTau cLight : ℝ) : ℝ :=
  hbarTau * omegaTau / cLight ^ 2

/-- Nonnegativity of `m_tau` under nonnegative numerator and positive light-speed scale. -/
theorem qcfMassFromTauFrequency_nonneg
    (hbarTau omegaTau cLight : ℝ)
    (hhbar : 0 <= hbarTau)
    (homega : 0 <= omegaTau)
    (hc : 0 < cLight) :
    0 <= qcfMassFromTauFrequency hbarTau omegaTau cLight := by
  unfold qcfMassFromTauFrequency
  have hc2 : 0 < cLight ^ 2 := sq_pos_of_pos hc
  exact div_nonneg (mul_nonneg hhbar homega) (le_of_lt hc2)

/-- QCF proper-time increment kernel:
`Delta tau_n = (h / (m0 * c^2)) * sqrt(spectralTerm)`. -/
def qcfDeltaTau
    (h m0 cLight spectralTerm : ℝ) : ℝ :=
  (h / (m0 * cLight ^ 2)) * Real.sqrt spectralTerm

/-- Nonnegativity of the QCF proper-time increment under positivity assumptions. -/
theorem qcfDeltaTau_nonneg
    (h m0 cLight spectralTerm : ℝ)
    (hh : 0 <= h)
    (hm0 : 0 < m0)
    (hc : 0 < cLight)
    (hspec : 0 <= spectralTerm) :
    0 <= qcfDeltaTau h m0 cLight spectralTerm := by
  unfold qcfDeltaTau
  have hden : 0 < m0 * cLight ^ 2 :=
    mul_pos hm0 (sq_pos_of_pos hc)
  have hpref : 0 <= h / (m0 * cLight ^ 2) :=
    div_nonneg hh (le_of_lt hden)
  exact mul_nonneg hpref (Real.sqrt_nonneg _)

/-- Squared QCF increment removes the square root term. -/
theorem qcfDeltaTau_sq
    (h m0 cLight spectralTerm : ℝ)
    (hspec : 0 <= spectralTerm) :
    (qcfDeltaTau h m0 cLight spectralTerm) ^ 2
      =
      (h / (m0 * cLight ^ 2)) ^ 2 * spectralTerm := by
  unfold qcfDeltaTau
  calc
    ((h / (m0 * cLight ^ 2)) * Real.sqrt spectralTerm) ^ 2
        = (h / (m0 * cLight ^ 2)) ^ 2 * (Real.sqrt spectralTerm) ^ 2 := by ring
    _ = (h / (m0 * cLight ^ 2)) ^ 2 * spectralTerm := by
      rw [Real.sq_sqrt hspec]

/-- DSF-dressed local entropy-production/clock rate:
`rate = (8*pi*lambda)^(-1) * T_loc` with Tolman-redshifted `T_loc`. -/
def dsfLocalEntropyRate
    (c : PhysicalConstants)
    (betaInf minus_g00_sqrt : ℝ)
    (lambda0 alpha eps gamma ricci phi : ℝ) : ℝ :=
  dsfLambdaInverseScale lambda0 alpha eps gamma ricci phi *
    tolmanLocalTemperature c betaInf minus_g00_sqrt

/-- DSF local rate coupled to residual backreaction through the existing
`lambda_eff_coupled` adapter. -/
def dsfCoupledEntropyRate
    (c : PhysicalConstants)
    (betaInf minus_g00_sqrt residual gain : ℝ)
    (lambda0 alpha eps gamma ricci phi : ℝ) : ℝ :=
  lambda_eff_coupled
    (dsfLambdaInverseScale lambda0 alpha eps gamma ricci phi)
    (tolmanLocalTemperature c betaInf minus_g00_sqrt)
    residual gain

/-- One-step entropy increment using DSF local rate and the extracted QCF
proper-time increment. -/
def dsfEntropyIncrementOverQcfStep
    (c : PhysicalConstants)
    (betaInf minus_g00_sqrt : ℝ)
    (lambda0 alpha eps gamma ricci phi : ℝ)
    (h m0 cLight spectralTerm : ℝ) : ℝ :=
  dsfLocalEntropyRate c betaInf minus_g00_sqrt lambda0 alpha eps gamma ricci phi
    * qcfDeltaTau h m0 cLight spectralTerm

/-- Under standard positivity assumptions, the DSF entropy increment over one
QCF step is nonnegative. -/
theorem dsfEntropyIncrementOverQcfStep_nonneg
    (c : PhysicalConstants)
    (betaInf minus_g00_sqrt : ℝ)
    (lambda0 alpha eps gamma ricci phi : ℝ)
    (h m0 cLight spectralTerm : ℝ)
    (hLambdaInv : 0 <= dsfLambdaInverseScale lambda0 alpha eps gamma ricci phi)
    (hbeta : 0 < betaInf)
    (hg00 : 0 < minus_g00_sqrt)
    (hh : 0 <= h)
    (hm0 : 0 < m0)
    (hc : 0 < cLight)
    (hspec : 0 <= spectralTerm) :
    0 <= dsfEntropyIncrementOverQcfStep
      c betaInf minus_g00_sqrt lambda0 alpha eps gamma ricci phi
      h m0 cLight spectralTerm := by
  unfold dsfEntropyIncrementOverQcfStep
  have hLocalRateNonneg :
      0 <= dsfLocalEntropyRate c betaInf minus_g00_sqrt
        lambda0 alpha eps gamma ricci phi := by
    unfold dsfLocalEntropyRate
    exact mul_nonneg hLambdaInv
      (le_of_lt (tolmanTemperature_pos c betaInf minus_g00_sqrt hbeta hg00))
  exact mul_nonneg
    hLocalRateNonneg
    (qcfDeltaTau_nonneg h m0 cLight spectralTerm hh hm0 hc hspec)

/-- Coupled DSF rate is DSF local rate times the backreaction factor. -/
theorem dsfCoupledEntropyRate_eq_local_times_backreaction
    (c : PhysicalConstants)
    (betaInf minus_g00_sqrt residual gain : ℝ)
    (lambda0 alpha eps gamma ricci phi : ℝ) :
    dsfCoupledEntropyRate c betaInf minus_g00_sqrt residual gain
      lambda0 alpha eps gamma ricci phi
      =
      dsfLocalEntropyRate c betaInf minus_g00_sqrt lambda0 alpha eps gamma ricci phi
        * (1 + gain * residual) := by
  unfold dsfCoupledEntropyRate lambda_eff_coupled dsfLocalEntropyRate
  ring

/-- Local DSF second-law rate is nonnegative under positivity assumptions. -/
theorem dsfLocalEntropyRate_nonneg
    (c : PhysicalConstants)
    (betaInf minus_g00_sqrt : ℝ)
    (lambda0 alpha eps gamma ricci phi : ℝ)
    (hLambdaInv : 0 <= dsfLambdaInverseScale lambda0 alpha eps gamma ricci phi)
    (hbeta : 0 < betaInf)
    (hg00 : 0 < minus_g00_sqrt) :
    0 <= dsfLocalEntropyRate c betaInf minus_g00_sqrt lambda0 alpha eps gamma ricci phi := by
  unfold dsfLocalEntropyRate
  exact mul_nonneg hLambdaInv (le_of_lt (tolmanTemperature_pos c betaInf minus_g00_sqrt hbeta hg00))

/-- Local DSF second-law rate with residual coupling remains nonnegative
under nonnegative gain and residual. -/
theorem dsfCoupledEntropyRate_nonneg
    (c : PhysicalConstants)
    (betaInf minus_g00_sqrt residual gain : ℝ)
    (lambda0 alpha eps gamma ricci phi : ℝ)
    (hLambdaInv : 0 <= dsfLambdaInverseScale lambda0 alpha eps gamma ricci phi)
    (hbeta : 0 < betaInf)
    (hg00 : 0 < minus_g00_sqrt)
    (hgain : 0 <= gain)
    (hres : 0 <= residual) :
    0 <= dsfCoupledEntropyRate c betaInf minus_g00_sqrt residual gain
      lambda0 alpha eps gamma ricci phi := by
  unfold dsfCoupledEntropyRate
  have hTemp : 0 <= tolmanLocalTemperature c betaInf minus_g00_sqrt :=
    le_of_lt (tolmanTemperature_pos c betaInf minus_g00_sqrt hbeta hg00)
  exact lambda_eff_coupled_nonneg
    (dsfLambdaInverseScale lambda0 alpha eps gamma ricci phi)
    (tolmanLocalTemperature c betaInf minus_g00_sqrt)
    residual gain hLambdaInv hTemp hgain hres

/-- DSF local entropy rate has the same redshift profile as Tolman temperature,
up to multiplicative `(8*pi*lambda)^(-1)`. -/
theorem dsfLocalEntropyRate_eq_lambdaInverseScale_mul_flat_over_redshift
    (c : PhysicalConstants)
    (betaInf minus_g00_sqrt : ℝ)
    (lambda0 alpha eps gamma ricci phi : ℝ)
    (hbeta : 0 < betaInf)
    (hg00 : 0 < minus_g00_sqrt) :
    dsfLocalEntropyRate c betaInf minus_g00_sqrt lambda0 alpha eps gamma ricci phi
      =
      dsfLambdaInverseScale lambda0 alpha eps gamma ricci phi
        * (flatTemperature c betaInf / minus_g00_sqrt) := by
  unfold dsfLocalEntropyRate
  rw [tolmanTemperature_eq_flat_over_redshift c betaInf minus_g00_sqrt hbeta hg00 c.kB_pos]

/-- If entropy derivative is identified with the DSF local rate, the derivative is nonnegative.
This is the direct second-law bridge for trajectory-level use. -/
theorem dsfSecondLaw_from_rate_identification
    (c : PhysicalConstants)
    (betaInf minus_g00_sqrt : ℝ)
    (lambda0 alpha eps gamma ricci phi : ℝ)
    (entropy : ℝ -> ℝ)
    (hRate : forall t, deriv entropy t =
      dsfLocalEntropyRate c betaInf minus_g00_sqrt lambda0 alpha eps gamma ricci phi)
    (hLambdaInv : 0 <= dsfLambdaInverseScale lambda0 alpha eps gamma ricci phi)
    (hbeta : 0 < betaInf)
    (hg00 : 0 < minus_g00_sqrt) :
    forall t, 0 <= deriv entropy t := by
  intro t
  rw [hRate t]
  exact dsfLocalEntropyRate_nonneg c betaInf minus_g00_sqrt lambda0 alpha eps gamma ricci phi hLambdaInv hbeta hg00

/-- Coupled-rate variant of the second-law identification theorem. -/
theorem dsfSecondLaw_from_coupled_rate_identification
    (c : PhysicalConstants)
    (betaInf minus_g00_sqrt residual gain : ℝ)
    (lambda0 alpha eps gamma ricci phi : ℝ)
    (entropy : ℝ -> ℝ)
    (hRate : forall t, deriv entropy t =
      dsfCoupledEntropyRate c betaInf minus_g00_sqrt residual gain
        lambda0 alpha eps gamma ricci phi)
    (hLambdaInv : 0 <= dsfLambdaInverseScale lambda0 alpha eps gamma ricci phi)
    (hbeta : 0 < betaInf)
    (hg00 : 0 < minus_g00_sqrt)
    (hgain : 0 <= gain)
    (hres : 0 <= residual) :
    forall t, 0 <= deriv entropy t := by
  intro t
  rw [hRate t]
  exact dsfCoupledEntropyRate_nonneg
    c betaInf minus_g00_sqrt residual gain
    lambda0 alpha eps gamma ricci phi
    hLambdaInv hbeta hg00 hgain hres

end CATEPTMain.CATEPT.CATEPT
