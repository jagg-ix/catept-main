import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp

set_option autoImplicit false

/-!
# ADM CAT/EPT entropy insertion (Reply 17)

Structural carrier for ADM entropic damping with the hypersurface
volume element `N * sqrt(h)`.
-/

namespace CATEPTMain.Integration.ADMEntropyPathIntegralBridge

noncomputable section

/-- Abstract time and space carriers. -/
axiom Time : Type
axiom SpacePoint : Type

/-- ADM fields, abstractly. -/
structure ADMState where
  lapse : Time → SpacePoint → ℝ
  sqrt_h : Time → SpacePoint → ℝ
  shift : Time → SpacePoint → ℝ
  lambda_damp : Time → SpacePoint → ℝ

/-- Formal spacetime integral over the ADM foliation. -/
axiom admIntegral : (Time → SpacePoint → ℝ) → ℝ

/-- Imaginary action `S_I = ℏ ∫ N * sqrt(h) * lambda`. -/
def SI_ADM (hbar : ℝ) (X : ADMState) : ℝ :=
  hbar * admIntegral (fun t x => X.lapse t x * X.sqrt_h t x * X.lambda_damp t x)

/-- Entropic proper time functional. -/
def tauEnt_ADM (X : ADMState) : ℝ :=
  admIntegral (fun t x => X.lapse t x * X.sqrt_h t x * X.lambda_damp t x)

/-- Local admissibility of damping source. -/
def lambdaNonnegative (X : ADMState) : Prop :=
  ∀ t x, 0 ≤ X.lambda_damp t x

/-- Positive lapse and volume element. -/
def admPositiveGeometry (X : ADMState) : Prop :=
  (∀ t x, 0 ≤ X.lapse t x) ∧ (∀ t x, 0 ≤ X.sqrt_h t x)

-- --------------------------------------------------------------------
-- Reply 17: explicit KMS / Petz+ / Fisher split for lambda_damp
-- --------------------------------------------------------------------

/-- KMS thermal rate `kB * T / hbar`. -/
def lambdaKMS (kB T hbar : ℝ) : ℝ :=
  kB * T / hbar

/-- Petz rate `c_alpha * dI_dt`. -/
def lambdaPetz (c_alpha dI_dt : ℝ) : ℝ :=
  c_alpha * dI_dt

/-- Positive Petz branch `max(lambda_petz, 0)`. -/
def lambdaPetzPos (c_alpha dI_dt : ℝ) : ℝ :=
  max (lambdaPetz c_alpha dI_dt) 0

/-- Fisher local rate `(eta / hbar) * I_F`. -/
def lambdaFisher (eta hbar I_F : ℝ) : ℝ :=
  (eta / hbar) * I_F

/-- Local damping rate `lambda_damp = lambda_KMS + lambda_Petz^+ + lambda_F`. -/
def lambdaDamp
    (kB hbar eta c_alpha : ℝ)
    (T dI_dt I_F : Time → SpacePoint → ℝ) : Time → SpacePoint → ℝ :=
  fun t x =>
    lambdaKMS kB (T t x) hbar +
    lambdaPetzPos c_alpha (dI_dt t x) +
    lambdaFisher eta hbar (I_F t x)

/-- Placeholder for the ADM normal derivative `∂_⊥`. -/
axiom normalDerivative :
  ADMState → (Time → SpacePoint → ℝ) → Time → SpacePoint → ℝ

/-- Petz source using the ADM normal derivative. -/
def lambdaPetzNormalPos
    (X : ADMState) (c_alpha : ℝ) (I_alpha : Time → SpacePoint → ℝ) :
    Time → SpacePoint → ℝ :=
  fun t x => max (c_alpha * normalDerivative X I_alpha t x) 0

/-- Local damping rate using the ADM normal derivative for Petz. -/
def lambdaDampNormal
    (X : ADMState) (kB hbar eta c_alpha : ℝ)
    (T I_alpha I_F : Time → SpacePoint → ℝ) : Time → SpacePoint → ℝ :=
  fun t x =>
    lambdaKMS kB (T t x) hbar +
    lambdaPetzNormalPos X c_alpha I_alpha t x +
    lambdaFisher eta hbar (I_F t x)

/-- Nonnegativity of the ADM imaginary action under positive data. -/
theorem SI_ADM_nonnegative
    (hbar : ℝ) (X : ADMState)
    (hbar_nonneg : 0 ≤ hbar)
    (hgeom : admPositiveGeometry X)
    (hlam : lambdaNonnegative X)
    (hint : 0 ≤ admIntegral
      (fun t x => X.lapse t x * X.sqrt_h t x * X.lambda_damp t x)) :
    0 ≤ SI_ADM hbar X := by
  have _ := hgeom
  have _ := hlam
  unfold SI_ADM
  exact mul_nonneg hbar_nonneg hint

/-- Amplitude-level ADM damping `exp(-S_I / hbar)`. -/
def admAmplitudeDamping (hbar : ℝ) (X : ADMState) : ℝ :=
  Real.exp (-(SI_ADM hbar X / hbar))

/-- Probability-level ADM damping `exp(-2 S_I / hbar)`. -/
def admProbabilityDamping (hbar : ℝ) (X : ADMState) : ℝ :=
  Real.exp (-(2 * SI_ADM hbar X / hbar))

/-- Placeholder for normal-direction entropic accumulation. -/
axiom entropicNormalAccumulation :
  (Time → SpacePoint → ℝ) → Time → SpacePoint → ℝ

/-- Entropic lapse factor `exp(-∫ N lambda dt)`. -/
def entropicLapse (X : ADMState) : Time → SpacePoint → ℝ :=
  fun t x =>
    Real.exp (-(entropicNormalAccumulation
      (fun t' x' => X.lapse t' x' * X.lambda_damp t' x') t x))

/-- Dressed lapse `N * N_ent`. -/
def dressedLapse (X : ADMState) (t : Time) (x : SpacePoint) : ℝ :=
  X.lapse t x * entropicLapse X t x

/-- Complex Hamiltonian constraint density (real + imaginary). -/
structure ADMComplexHamiltonianDensity where
  real : Time → SpacePoint → ℝ
  imag : Time → SpacePoint → ℝ

/-- Build the complex constraint density from real ADM data and damping. -/
def admComplexHamiltonianDensity
    (H_R : Time → SpacePoint → ℝ) (hbar : ℝ) (X : ADMState) :
    ADMComplexHamiltonianDensity :=
  { real := H_R
  , imag := fun t x => hbar * X.sqrt_h t x * X.lambda_damp t x }

/-- Lorentzian ADM weight `exp(i S_R/hbar - S_I/hbar)`. -/
def admLorentzianWeight
    (hbar : ℝ) (S_R : ADMState → ℝ) (X : ADMState) : ℂ :=
  Complex.exp ((S_R X / hbar : ℂ) * Complex.I - (SI_ADM hbar X / hbar : ℂ))

/-- Euclidean ADM weight `exp(-S_E/hbar - S_I/hbar)`. -/
def admEuclideanWeight
    (hbar : ℝ) (S_E : ADMState → ℝ) (X : ADMState) : ℝ :=
  Real.exp (-(S_E X / hbar) - (SI_ADM hbar X / hbar))

/-- GTD equilibrium limit for ADM damping. -/
theorem gtd_equilibrium_damping_ADM
    (X : ADMState) (deltaS kB : ℝ)
    (h : tauEnt_ADM X = deltaS / kB) :
    Real.exp (-(tauEnt_ADM X)) = Real.exp (-(deltaS / kB)) := by
  simp [h]

/-- Compatibility obligations for the ADM imaginary sector. -/
structure ADMCompatibilityObligations where
  scalarDensityCompatible : Prop
  hamiltonianConstraintClosure : Prop
  momentumConstraintClosure : Prop
  mixedRealImaginaryDHKTClosure : Prop
  bianchiCompatibleStress : Prop

end

end CATEPTMain.Integration.ADMEntropyPathIntegralBridge
