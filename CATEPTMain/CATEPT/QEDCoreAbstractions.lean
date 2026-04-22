import CATEPTMain.CATEPT.ElectromagnetismCoreAbstractions
import Mathlib

set_option autoImplicit false

namespace CATEPT

/-- 4-momentum carrier used by core QED kinematics. -/
abbrev FourMomentum : Type := Fin 4 → ℝ

/-- Minkowski inner product with signature `(+,-,-,-)`. -/
def minkowskiInner (p q : FourMomentum) : ℝ :=
  p ⟨0, by decide⟩ * q ⟨0, by decide⟩
    - p ⟨1, by decide⟩ * q ⟨1, by decide⟩
    - p ⟨2, by decide⟩ * q ⟨2, by decide⟩
    - p ⟨3, by decide⟩ * q ⟨3, by decide⟩

/-- Mandelstam variable `s = (p1 + p2)^2`. -/
def mandelstamS (p1 p2 : FourMomentum) : ℝ :=
  minkowskiInner (fun μ => p1 μ + p2 μ) (fun μ => p1 μ + p2 μ)

/-- Mandelstam variable `t = (p1 - p3)^2`. -/
def mandelstamT (p1 p3 : FourMomentum) : ℝ :=
  minkowskiInner (fun μ => p1 μ - p3 μ) (fun μ => p1 μ - p3 μ)

/-- Mandelstam variable `u = (p1 - p4)^2`. -/
def mandelstamU (p1 p4 : FourMomentum) : ℝ :=
  minkowskiInner (fun μ => p1 μ - p4 μ) (fun μ => p1 μ - p4 μ)

/-- Reduced Compton amplitude expression in massless normalization. -/
def comptonAmplitudeReduced (s u : ℝ) : ℝ :=
  -2 * (s / u + u / s)

theorem comptonAmplitudeReduced_eq_rational
    (s u : ℝ) (hs : s ≠ 0) (hu : u ≠ 0) :
    comptonAmplitudeReduced s u = -2 * (s ^ 2 + u ^ 2) / (s * u) := by
  unfold comptonAmplitudeReduced
  field_simp [hs, hu]
  ring

theorem compton_crossing_symmetry (s u : ℝ) :
    s / u + u / s = u / s + s / u := by
  ring

/-- Ward residual placeholder `k · M`. -/
def wardResidual (k contractedAmplitude : ℝ) : ℝ :=
  k * contractedAmplitude

theorem ward_identity_factorization
    (k contractedAmplitude : ℝ)
    (h : wardResidual k contractedAmplitude = 0) :
    k = 0 ∨ contractedAmplitude = 0 := by
  unfold wardResidual at h
  exact mul_eq_zero.mp h

/-- Compatibility witness for QED integration in core. -/
structure QEDCompatibilityWitness where
  mandelstamKinematicsAvailable : Prop
  comptonAmplitudeAvailable : Prop
  bhabhaAmplitudeAvailable : Prop
  mollerAmplitudeAvailable : Prop
  muonPairProductionAvailable : Prop
  wardIdentityAvailable : Prop

def qedCompatibilityContract (w : QEDCompatibilityWitness) : Prop :=
  w.mandelstamKinematicsAvailable ∧
    w.comptonAmplitudeAvailable ∧
    w.bhabhaAmplitudeAvailable ∧
    w.mollerAmplitudeAvailable ∧
    w.muonPairProductionAvailable ∧
    w.wardIdentityAvailable

theorem qedCompatibility_contract_of_fields
    (w : QEDCompatibilityWitness)
    (h1 : w.mandelstamKinematicsAvailable)
    (h2 : w.comptonAmplitudeAvailable)
    (h3 : w.bhabhaAmplitudeAvailable)
    (h4 : w.mollerAmplitudeAvailable)
    (h5 : w.muonPairProductionAvailable)
    (h6 : w.wardIdentityAvailable) :
    qedCompatibilityContract w :=
  ⟨h1, h2, h3, h4, h5, h6⟩

end CATEPT
