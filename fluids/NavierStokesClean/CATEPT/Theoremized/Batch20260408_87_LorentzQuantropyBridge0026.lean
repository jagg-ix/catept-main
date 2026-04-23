import Mathlib

/-!
# Batch 20260408 Theoremization - Row 87 (Lorentz/Quantropy Bridge 0026)

Compile-safe bridge for expected-energy and quantropy-style functionals.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B87

open MeasureTheory

noncomputable section

/-- Expected-energy functional using provided Hamiltonian image `Hψ`. -/
def row87ExpectedEnergy
    {X : Type*}
    [MeasurableSpace X]
    (μ : Measure X)
    (ψ : X → ℂ)
    (Hψ : X → ℂ) : ℂ :=
  ∫ x, Complex.conj (ψ x) * Hψ x ∂μ

/-- Quantropy-style functional over real density field `ρ`. -/
def row87Quantropy
    {X : Type*}
    [MeasurableSpace X]
    (μ : Measure X)
    (ρ : X → ℝ) : ℝ :=
  -∫ x, ρ x * Real.log (ρ x) ∂μ

/-- Expected energy is additive in the Hamiltonian image under integrability assumptions. -/
theorem row87_expectedEnergy_add
    {X : Type*}
    [MeasurableSpace X]
    (μ : Measure X)
    (ψ H₁ H₂ : X → ℂ)
    (hInt1 : Integrable (fun x => Complex.conj (ψ x) * H₁ x) μ)
    (hInt2 : Integrable (fun x => Complex.conj (ψ x) * H₂ x) μ) :
    row87ExpectedEnergy μ ψ (fun x => H₁ x + H₂ x)
      = row87ExpectedEnergy μ ψ H₁ + row87ExpectedEnergy μ ψ H₂ := by
  simp [row87ExpectedEnergy, mul_add, integral_add hInt1 hInt2]

/-- Quantropy is invariant under almost-everywhere equality of the density. -/
theorem row87_quantropy_congr_ae
    {X : Type*}
    [MeasurableSpace X]
    (μ : Measure X)
    (ρ₁ ρ₂ : X → ℝ)
    (hAe : ρ₁ =ᵐ[μ] ρ₂) :
    row87Quantropy μ ρ₁ = row87Quantropy μ ρ₂ := by
  apply neg_injective
  apply integral_congr_ae
  exact hAe.mono (fun x hx => by simp [hx])

/-- Pointwise equality yields expected-energy equality. -/
theorem row87_expectedEnergy_congr
    {X : Type*}
    [MeasurableSpace X]
    (μ : Measure X)
    (ψ H₁ H₂ : X → ℂ)
    (hEq : H₁ = H₂) :
    row87ExpectedEnergy μ ψ H₁ = row87ExpectedEnergy μ ψ H₂ := by
  subst hEq
  rfl

/-- Row-87 bundle theorem joining additive and congruence properties. -/
theorem row87_lorentz_quantropy_bundle
    {X : Type*}
    [MeasurableSpace X]
    (μ : Measure X)
    (ψ H₁ H₂ : X → ℂ)
    (ρ₁ ρ₂ : X → ℝ)
    (hInt1 : Integrable (fun x => Complex.conj (ψ x) * H₁ x) μ)
    (hInt2 : Integrable (fun x => Complex.conj (ψ x) * H₂ x) μ)
    (hAe : ρ₁ =ᵐ[μ] ρ₂) :
    row87ExpectedEnergy μ ψ (fun x => H₁ x + H₂ x)
      = row87ExpectedEnergy μ ψ H₁ + row87ExpectedEnergy μ ψ H₂ ∧
      row87Quantropy μ ρ₁ = row87Quantropy μ ρ₂ := by
  exact ⟨
    row87_expectedEnergy_add μ ψ H₁ H₂ hInt1 hInt2,
    row87_quantropy_congr_ae μ ρ₁ ρ₂ hAe
  ⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B87
