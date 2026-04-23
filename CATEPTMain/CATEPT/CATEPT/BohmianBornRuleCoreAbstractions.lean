import Mathlib
import CATEPTMain.CATEPT.CATEPT.Foundations

set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

noncomputable section

/-! # Bohmian and Born-Rule Core Abstractions

Core-safe contracts extracted from Bohmian/Madelung and Born-rule unification
integration lanes, with only lightweight dependencies.
-/

/-- Madelung polar decomposition data: `psi = R * exp(i S / hbar)`. -/
structure MadelungWaveFunction where
  amplitude : Real
  amplitude_nonneg : 0 <= amplitude
  phase : Real
  hbar : Real
  hbar_pos : 0 < hbar

/-- Madelung/Born density `rho = R^2`. -/
def madelungDensity (psi : MadelungWaveFunction) : Real :=
  psi.amplitude ^ 2

theorem madelungDensity_nonneg (psi : MadelungWaveFunction) :
    0 <= madelungDensity psi := by
  unfold madelungDensity
  positivity

theorem madelung_born_rule (psi : MadelungWaveFunction) :
    madelungDensity psi = psi.amplitude ^ 2 := rfl

theorem madelung_phase_factor_norm (theta : Real) :
    ‖Complex.exp ((theta : Complex) * Complex.I)‖ = 1 :=
  Complex.norm_exp_ofReal_mul_I theta

theorem madelung_wf_norm (psi : MadelungWaveFunction) :
    ‖(psi.amplitude : Complex) * Complex.exp (Complex.I * (psi.phase / psi.hbar))‖ =
      psi.amplitude := by
  rw [norm_mul, Complex.norm_real, Real.norm_of_nonneg psi.amplitude_nonneg, mul_comm,
      show Complex.I * ((psi.phase : Complex) / (psi.hbar : Complex)) =
          ((psi.phase / psi.hbar : Real) : Complex) * Complex.I by push_cast; ring,
      Complex.norm_exp_ofReal_mul_I, one_mul]

/-- Bohmian quantum-potential proxy `Q ~ -(hbar^2)/(2m) * (...)`. -/
structure BohmianQuantumPotential where
  mass : Real
  mass_pos : 0 < mass
  wf : MadelungWaveFunction
  laplacianAmplitude : Real

/-- Universal Bohmian quantum-potential scale factor. -/
def quantumPotentialScale (q : BohmianQuantumPotential) : Real :=
  -(q.wf.hbar ^ 2) / (2 * q.mass)

theorem quantumPotentialScale_neg (q : BohmianQuantumPotential) :
    quantumPotentialScale q < 0 := by
  unfold quantumPotentialScale
  apply div_neg_of_neg_of_pos
  · linarith [sq_pos_of_pos q.wf.hbar_pos]
  · exact mul_pos two_pos q.mass_pos

/-- Guidance-velocity proxy `v = S / (m * hbar)`. -/
def bohmianVelocityProxy (q : BohmianQuantumPotential) : Real :=
  q.wf.phase / (q.mass * q.wf.hbar)

theorem bohmianVelocity_denom_pos (q : BohmianQuantumPotential) :
    0 < q.mass * q.wf.hbar :=
  mul_pos q.mass_pos q.wf.hbar_pos

/-- Bohmian trajectory contract with guidance relation. -/
structure BohmianTrajectory where
  pilotWave : MadelungWaveFunction
  mass : Real
  mass_pos : 0 < mass
  position : Real → Real
  x0 : Real
  init_pos : position 0 = x0
  speedProxy : Real
  guidance_eq : speedProxy = pilotWave.phase / (mass * pilotWave.hbar)

theorem trajectory_guidance_matches_bohm (tr : BohmianTrajectory) :
    tr.speedProxy = tr.pilotWave.phase / (tr.mass * tr.pilotWave.hbar) :=
  tr.guidance_eq

theorem trajectory_initial_condition (tr : BohmianTrajectory) :
    tr.position 0 = tr.x0 :=
  tr.init_pos

/-- Entropic-time identity used in Bohmian bridge lanes. -/
theorem entropic_time_madelung_phase (S_I hbar_val : Real) :
    entropic_time hbar_val S_I = S_I / hbar_val := rfl

/-- Path-amplitude norm identity giving Born damping weight. -/
theorem catept_path_amplitude_norm
    (S_R S_I hbar_val : Real) (hh : 0 < hbar_val) :
    ‖Complex.exp (Complex.I * (S_R / hbar_val)) *
      (Real.exp (-S_I / hbar_val) : Complex)‖
      =
      Real.exp (-S_I / hbar_val) := by
  rw [norm_mul]
  rw [show Complex.I * ((S_R : Complex) / (hbar_val : Complex)) =
      ((S_R / hbar_val : Real) : Complex) * Complex.I by push_cast; ring]
  rw [Complex.norm_exp_ofReal_mul_I, one_mul]
  rw [Complex.norm_real]
  exact Real.norm_of_nonneg (Real.exp_nonneg _)

/-- Path-amplitude Born probability density `|A|^2 = exp(-2 S_I / hbar)`. -/
theorem catept_probability_density
    (S_R S_I hbar_val : Real) (hh : 0 < hbar_val) :
    ‖Complex.exp (Complex.I * (S_R / hbar_val)) *
      (Real.exp (-S_I / hbar_val) : Complex)‖ ^ 2
      =
      Real.exp (-2 * S_I / hbar_val) := by
  rw [catept_path_amplitude_norm S_R S_I hbar_val hh, sq, <- Real.exp_add]
  congr 1
  ring

/-- Entropic-time nonnegativity under nonnegative imaginary action. -/
theorem born_rule_entropic_nonneg (hbar_val S_I : Real)
    (hh : 0 < hbar_val) (hS : 0 <= S_I) :
    0 <= entropic_time hbar_val S_I :=
  eq003_entropic_time_nonneg hbar_val S_I hh hS

/-- Core observable identity: Euclidean square norm equals `Complex.normSq`. -/
theorem complex_observable_eq_normSq (z : Complex) :
    z.re ^ 2 + z.im ^ 2 = Complex.normSq z := by
  simpa [Complex.normSq_apply, sq, mul_comm, mul_left_comm, mul_assoc]

/-- Core born-rule unification bundle for observable + path-amplitude lanes. -/
theorem born_rule_unification
    (z : Complex)
    (S_R S_I hbar_val : Real)
    (hh : 0 < hbar_val) :
    (z.re ^ 2 + z.im ^ 2 = Complex.normSq z) ∧
      (‖Complex.exp (Complex.I * (S_R / hbar_val)) *
        (Real.exp (-S_I / hbar_val) : Complex)‖ ^ 2 =
        Real.exp (-2 * S_I / hbar_val)) := by
  exact ⟨complex_observable_eq_normSq z, catept_probability_density S_R S_I hbar_val hh⟩

/-- Lightweight compatibility witness for Bohmian/Born integration claims. -/
structure BohmianBornRuleCompatibilityWitness where
  madelungDensityAvailable : Prop
  quantumPotentialSignAvailable : Prop
  guidanceEquationAvailable : Prop
  pathAmplitudeBornWeightAvailable : Prop
  bornRuleUnificationAvailable : Prop

def bohmianBornRuleCompatibilityContract
    (w : BohmianBornRuleCompatibilityWitness) : Prop :=
  w.madelungDensityAvailable ∧
    w.quantumPotentialSignAvailable ∧
    w.guidanceEquationAvailable ∧
    w.pathAmplitudeBornWeightAvailable ∧
    w.bornRuleUnificationAvailable

theorem bohmianBornRuleCompatibility_contract_of_fields
    (w : BohmianBornRuleCompatibilityWitness)
    (h1 : w.madelungDensityAvailable)
    (h2 : w.quantumPotentialSignAvailable)
    (h3 : w.guidanceEquationAvailable)
    (h4 : w.pathAmplitudeBornWeightAvailable)
    (h5 : w.bornRuleUnificationAvailable) :
    bohmianBornRuleCompatibilityContract w :=
  ⟨h1, h2, h3, h4, h5⟩

end

end CATEPTMain.CATEPT.CATEPT
