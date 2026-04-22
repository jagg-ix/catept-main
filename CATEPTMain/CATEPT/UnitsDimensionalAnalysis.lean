import CATEPTMain.CATEPT.Foundations
import CATEPTMain.CATEPT.PathIntegrals

set_option autoImplicit false

namespace CATEPT

/-- Base-dimension exponent bookkeeping for CAT/EPT dimensional analysis. -/
@[ext] structure Dimension where
  mass : Int
  length : Int
  time : Int
  temperature : Int
deriving DecidableEq, Repr

namespace Dimension

/-- Dimensionless unit. -/
def one : Dimension := ⟨0, 0, 0, 0⟩

/-- Dimension multiplication adds exponents. -/
def mul (a b : Dimension) : Dimension :=
  ⟨a.mass + b.mass, a.length + b.length, a.time + b.time, a.temperature + b.temperature⟩

/-- Dimension inversion negates exponents. -/
def inv (a : Dimension) : Dimension :=
  ⟨-a.mass, -a.length, -a.time, -a.temperature⟩

/-- Dimension division subtracts exponents. -/
def div (a b : Dimension) : Dimension :=
  mul a (inv b)

/-- Integer power scales all exponents by n. -/
def pow (a : Dimension) (n : Int) : Dimension :=
  ⟨n * a.mass, n * a.length, n * a.time, n * a.temperature⟩

@[simp] theorem mul_assoc (a b c : Dimension) :
    mul (mul a b) c = mul a (mul b c) := by
  ext <;> simp [mul, Int.add_assoc]

@[simp] theorem mul_one (a : Dimension) : mul a one = a := by
  ext <;> simp [mul, one]

@[simp] theorem one_mul (a : Dimension) : mul one a = a := by
  ext <;> simp [mul, one]

@[simp] theorem mul_inv_cancel (a : Dimension) : mul a (inv a) = one := by
  ext <;> simp [mul, inv, one]

@[simp] theorem div_self (a : Dimension) : div a a = one := by
  simp [div, mul_inv_cancel]

@[simp] theorem pow_two (a : Dimension) : pow a 2 = mul a a := by
  ext <;> simp [pow, mul, two_mul]

end Dimension

/-- Mass dimension M. -/
def dimMass : Dimension := ⟨1, 0, 0, 0⟩

/-- Length dimension L. -/
def dimLength : Dimension := ⟨0, 1, 0, 0⟩

/-- Time dimension T. -/
def dimTime : Dimension := ⟨0, 0, 1, 0⟩

/-- Action dimension [S] = M L^2 T^-1. -/
def dimAction : Dimension := ⟨1, 2, -1, 0⟩

/-- Planck constant has action dimension. -/
def dimHbar : Dimension := dimAction

/-- Energy dimension [E] = M L^2 T^-2. -/
def dimEnergy : Dimension := ⟨1, 2, -2, 0⟩

/-- Inverse energy dimension, used for FK/thermal factors. -/
def dimInverseEnergy : Dimension := Dimension.inv dimEnergy

/-- Squared mass dimension. -/
def dimMassSq : Dimension := Dimension.mul dimMass dimMass

/-- Inverse mass dimension. -/
def dimInverseMass : Dimension := Dimension.inv dimMass

/-- Inverse squared mass dimension. -/
def dimInverseMassSq : Dimension := Dimension.inv dimMassSq

/-- Entropic-time dimension from S_I / hbar. -/
def dimEntropicTime : Dimension := Dimension.div dimAction dimHbar

/-- Exponent dimension in CAT/EPT damping exp(-S_I/hbar). -/
def dimPathIntegralExponent : Dimension := Dimension.div dimAction dimHbar

/-- FK exponent dimension for exp(-beta * V). -/
def dimFeynmanKacExponent : Dimension := Dimension.mul dimInverseEnergy dimEnergy

/-- Euclidean propagator output dimension from 1 / (mass^2). -/
def dimEuclideanPropagator : Dimension := Dimension.div Dimension.one dimMassSq

/-- Effective mass-squared argument dimension for sqrt(m_sq + lam). -/
def dimEffectiveMassSquaredArg : Dimension := dimMassSq

/-- Yukawa exponential argument dimension M_eff * r in natural units. -/
def dimYukawaExponentNaturalUnits : Dimension := Dimension.mul dimMass dimInverseMass

/-- Yukawa potential prefactor dimension 1 / r in natural units. -/
def dimYukawaPrefactorNaturalUnits : Dimension :=
  Dimension.div Dimension.one dimInverseMass

/-- tau_ent = S_I / hbar is dimensionless. -/
theorem dim_entropic_time_dimensionless :
    dimEntropicTime = Dimension.one := by
  simp [dimEntropicTime, dimHbar, Dimension.div, Dimension.mul, Dimension.inv, Dimension.one]

/-- S_I / hbar (path-integral exponent) is dimensionless. -/
theorem dim_path_integral_exponent_dimensionless :
    dimPathIntegralExponent = Dimension.one := by
  simp [dimPathIntegralExponent, dimHbar, Dimension.div, Dimension.mul, Dimension.inv, Dimension.one]

/-- FK exponent beta * V is dimensionless for beta : E^-1, V : E. -/
theorem dim_feynman_kac_exponent_dimensionless :
    dimFeynmanKacExponent = Dimension.one := by
  simp [dimFeynmanKacExponent, dimInverseEnergy, dimEnergy, Dimension.inv, Dimension.mul, Dimension.one]

/-- Euclidean propagator has inverse squared-mass dimension. -/
theorem dim_euclidean_propagator_inverse_mass_sq :
    dimEuclideanPropagator = dimInverseMassSq := by
  rfl

/-- Effective-mass argument m_sq + lam is mass-squared by homogeneity. -/
theorem dim_effective_mass_argument_mass_sq :
    dimEffectiveMassSquaredArg = dimMassSq := by
  rfl

/-- In natural units (c = hbar = 1), Yukawa exponent M_eff * r is dimensionless. -/
theorem dim_yukawa_exponent_dimensionless_natural_units :
    dimYukawaExponentNaturalUnits = Dimension.one := by
  simp [dimYukawaExponentNaturalUnits, dimMass, dimInverseMass, Dimension.mul, Dimension.inv, Dimension.one]

/-- In natural units, Yukawa prefactor 1 / r has mass dimension. -/
theorem dim_yukawa_prefactor_mass_natural_units :
    dimYukawaPrefactorNaturalUnits = dimMass := by
  simp [dimYukawaPrefactorNaturalUnits, dimInverseMass, dimMass, Dimension.div, Dimension.inv, Dimension.mul, Dimension.one]

/-- Compatibility theorem: core CAT/EPT damping and FK exponents are dimensionless. -/
theorem catept_fk_dimensional_consistency :
    dimPathIntegralExponent = Dimension.one ∧
    dimFeynmanKacExponent = Dimension.one := by
  constructor
  · exact dim_path_integral_exponent_dimensionless
  · exact dim_feynman_kac_exponent_dimensionless

/-! ## Direct Bridges To Core Definitions -/

/-- The `entropic_time` formula is dimensionally valid with action-normalized units. -/
theorem entropic_time_dimension_contract (ℏ S_I : ℝ) :
    entropic_time ℏ S_I = S_I / ℏ ∧ dimEntropicTime = Dimension.one := by
  constructor
  · rfl
  · exact dim_entropic_time_dimensionless

/-- CAT/EPT damping `exp(-S_I / hbar)` uses a dimensionless exponent. -/
theorem path_integral_damping_dimension_contract (ℏ S_I : ℝ) :
    path_integral_damping ℏ S_I = Real.exp (-S_I / ℏ) ∧
    dimPathIntegralExponent = Dimension.one := by
  constructor
  · rfl
  · exact dim_path_integral_exponent_dimensionless

/-- FK Gibbs weight `exp(-beta * V)` is dimensionless under `beta : E^-1`, `V : E`. -/
theorem feynman_kac_weight_dimension_contract {X : Type*}
    (V : X → ℝ) (β : ℝ) (x : X) :
    feynman_kac_weight V β x = Real.exp (-β * V x) ∧
    dimFeynmanKacExponent = Dimension.one := by
  constructor
  · rfl
  · exact dim_feynman_kac_exponent_dimensionless

/-- Euclidean propagator carries inverse squared-mass dimension. -/
theorem euclidean_propagator_dimension_contract (k_sq m_sq lam : ℝ) :
    euclidean_propagator k_sq m_sq lam = 1 / (k_sq + m_sq + lam) ∧
    dimEuclideanPropagator = dimInverseMassSq := by
  constructor
  · rfl
  · exact dim_euclidean_propagator_inverse_mass_sq

/-- Yukawa form has a dimensionless exponential argument in natural units. -/
theorem yukawa_potential_dimension_contract (M_eff r : ℝ) :
    yukawa_potential M_eff r = Real.exp (-M_eff * r) / r ∧
    dimYukawaExponentNaturalUnits = Dimension.one := by
  constructor
  · rfl
  · exact dim_yukawa_exponent_dimensionless_natural_units

end CATEPT
