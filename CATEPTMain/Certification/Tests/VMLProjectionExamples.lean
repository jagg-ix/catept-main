import CATEPTMain.Certification.RelativityGRVMLMaxwell

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.VMLProjectionExamples

open CATEPTMain.Certification.RelativityGR
open CATEPTMain.Integration.VMLLandau

#check vml_equilibrium_implies_E_zero
#check vml_equilibrium_implies_B_constant
#check vml_equilibrium_implies_global_maxwellian
#check vml_equilibrium_projection_bundle

example
    {X : Type*}
    {f : X → (Fin 3 → ℝ) → ℝ}
    {E B : X → Fin 3 → ℝ}
    {ρ_ion : ℝ}
    (hRigidity :
      ∃ (T_eq : ℝ) (B0 : Fin 3 → ℝ), 0 < T_eq ∧
      (∀ x v, f x v = VML.equilibriumMaxwellian ρ_ion T_eq v) ∧
      (∀ x, E x = 0) ∧
      (∀ x, B x = B0)) :
    ∀ x, E x = 0 :=
  vml_equilibrium_implies_E_zero hRigidity

example
    {X : Type*}
    {f : X → (Fin 3 → ℝ) → ℝ}
    {E B : X → Fin 3 → ℝ}
    {ρ_ion : ℝ}
    (hRigidity :
      ∃ (T_eq : ℝ) (B0 : Fin 3 → ℝ), 0 < T_eq ∧
      (∀ x v, f x v = VML.equilibriumMaxwellian ρ_ion T_eq v) ∧
      (∀ x, E x = 0) ∧
      (∀ x, B x = B0)) :
    ∃ B0 : Fin 3 → ℝ, ∀ x, B x = B0 :=
  vml_equilibrium_implies_B_constant hRigidity

example
    {X : Type*}
    {f : X → (Fin 3 → ℝ) → ℝ}
    {E B : X → Fin 3 → ℝ}
    {ρ_ion : ℝ}
    (hRigidity :
      ∃ (T_eq : ℝ) (B0 : Fin 3 → ℝ), 0 < T_eq ∧
      (∀ x v, f x v = VML.equilibriumMaxwellian ρ_ion T_eq v) ∧
      (∀ x, E x = 0) ∧
      (∀ x, B x = B0)) :
    ∃ T_eq : ℝ, 0 < T_eq ∧
      (∀ x v, f x v = VML.equilibriumMaxwellian ρ_ion T_eq v) :=
  vml_equilibrium_implies_global_maxwellian hRigidity

example
    {X : Type*}
    {f : X → (Fin 3 → ℝ) → ℝ}
    {E B : X → Fin 3 → ℝ}
    {ρ_ion : ℝ}
    (hRigidity :
      ∃ (T_eq : ℝ) (B0 : Fin 3 → ℝ), 0 < T_eq ∧
      (∀ x v, f x v = VML.equilibriumMaxwellian ρ_ion T_eq v) ∧
      (∀ x, E x = 0) ∧
      (∀ x, B x = B0)) :
    (∀ x, E x = 0) ∧
    (∃ B0 : Fin 3 → ℝ, ∀ x, B x = B0) ∧
    (∃ T_eq : ℝ, 0 < T_eq ∧
      (∀ x v, f x v = VML.equilibriumMaxwellian ρ_ion T_eq v)) :=
  vml_equilibrium_projection_bundle hRigidity

end CATEPTMain.Certification.Tests.VMLProjectionExamples
