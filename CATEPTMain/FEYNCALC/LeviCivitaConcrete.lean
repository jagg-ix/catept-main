import Mathlib.GroupTheory.Perm.Sign
import Mathlib.Data.Fintype.Perm
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

/-!
# Concrete Levi-Civita Symbol (Computable, ℤ-valued)

Provides a computable definition of the 4D Levi-Civita symbol using the
permutation-sign formula, replacing the axiomatic `leviCivita` in FCPrelude.

## Definition

  `leviCivitaInt μ ν ρ σ = Σ_π sign(π) · [π 0 = μ ∧ π 1 = ν ∧ π 2 = ρ ∧ π 3 = σ]`

where the sum runs over all 24 permutations of Fin 4.  At most one permutation
matches a given 4-tuple, so the value is ±1 (for permutations of (0,1,2,3))
or 0 (when any two indices coincide).

Source formula: lloca/utils/lorentz.py lines 109–121 (Levi-Civita via determinant).

## Key properties

All proved by `native_decide` — the definition is fully computable over ℤ.

| Name                              | Statement                       |
|-----------------------------------|---------------------------------|
| `leviCivitaInt_0123`              | ε(0,1,2,3) = 1                 |
| `leviCivitaInt_antisymm_01`       | ε(μ,ν,ρ,σ) = −ε(ν,μ,ρ,σ)      |
| `leviCivitaInt_antisymm_12`       | ε(μ,ν,ρ,σ) = −ε(μ,ρ,ν,σ)      |
| `leviCivitaInt_antisymm_last`     | ε(μ,ν,ρ,σ) = −ε(μ,ν,σ,ρ)      |
| `leviCivitaInt_self_contract`     | Σ ε²  = 24                     |
-/

set_option autoImplicit false

namespace CATEPTMain.FEYNCALC

/-- Levi-Civita symbol (integer-valued, computable).
    Sum of `sign(π)` over the unique permutation matching `(μ,ν,ρ,σ)`,
    or 0 if no permutation matches (i.e. indices repeat). -/
def leviCivitaInt (μ ν ρ σ : Fin 4) : ℤ :=
  Finset.univ.sum fun (π : Equiv.Perm (Fin 4)) =>
    (Equiv.Perm.sign π : ℤ) *
      if π 0 = μ ∧ π 1 = ν ∧ π 2 = ρ ∧ π 3 = σ then 1 else 0

/-- ε(0,1,2,3) = +1 (West convention). -/
theorem leviCivitaInt_0123 : leviCivitaInt 0 1 2 3 = 1 := by native_decide

/-- Antisymmetry: swapping positions 0 and 1 negates ε. -/
theorem leviCivitaInt_antisymm_01 (μ ν ρ σ : Fin 4) :
    leviCivitaInt μ ν ρ σ = -leviCivitaInt ν μ ρ σ := by
  revert μ ν ρ σ; native_decide

/-- Antisymmetry: swapping positions 1 and 2 negates ε. -/
theorem leviCivitaInt_antisymm_12 (μ ν ρ σ : Fin 4) :
    leviCivitaInt μ ν ρ σ = -leviCivitaInt μ ρ ν σ := by
  revert μ ν ρ σ; native_decide

/-- Antisymmetry: swapping positions 2 and 3 negates ε. -/
theorem leviCivitaInt_antisymm_last (μ ν ρ σ : Fin 4) :
    leviCivitaInt μ ν ρ σ = -leviCivitaInt μ ν σ ρ := by
  revert μ ν ρ σ; native_decide

/-- Self-contraction: Σ_{μνρσ} ε² = 4! = 24. -/
theorem leviCivitaInt_self_contract :
    Finset.univ.sum (fun μ : Fin 4 =>
      Finset.univ.sum (fun ν : Fin 4 =>
        Finset.univ.sum (fun ρ : Fin 4 =>
          Finset.univ.sum (fun σ : Fin 4 =>
            leviCivitaInt μ ν ρ σ * leviCivitaInt μ ν ρ σ)))) = 24 := by
  native_decide

/-- ε–ε single-index contraction (integer version).
    Σ_σ ε(μ,ν,ρ,σ)·ε(α,β,γ,σ) = det-formula in Kronecker deltas. -/
theorem leviCivitaInt_eps_eps_3 (μ ν ρ α β γ : Fin 4) :
    Finset.univ.sum (fun σ : Fin 4 =>
      leviCivitaInt μ ν ρ σ * leviCivitaInt α β γ σ) =
    (if μ = α then (1 : ℤ) else 0) *
      ((if ν = β then 1 else 0) * (if ρ = γ then 1 else 0)
       - (if ν = γ then 1 else 0) * (if ρ = β then 1 else 0))
    - (if μ = β then 1 else 0) *
      ((if ν = α then 1 else 0) * (if ρ = γ then 1 else 0)
       - (if ν = γ then 1 else 0) * (if ρ = α then 1 else 0))
    + (if μ = γ then 1 else 0) *
      ((if ν = α then 1 else 0) * (if ρ = β then 1 else 0)
       - (if ν = β then 1 else 0) * (if ρ = α then 1 else 0)) := by
  revert μ ν ρ α β γ; native_decide

end CATEPTMain.FEYNCALC
