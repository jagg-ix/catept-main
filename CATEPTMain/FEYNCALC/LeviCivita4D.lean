import CATEPTMain.FEYNCALC.LorentzAlgebra

/-!
# Levi-Civita Tensor in 4D (Lorentz indices)

This module provides a concrete 4D-facing API around the FEYNCALC Lorentz
Levi-Civita tensor `leviCivita : FCIdx -> FCIdx -> FCIdx -> FCIdx -> ℝ`.

It intentionally complements `LeviCivita3D.lean`, which covers Euclidean 3D
vector identities (`cross`, `curl`, BAC-CAB) over `Fin 3`.
-/

set_option autoImplicit false

namespace CATEPTMain.FEYNCALC

/-- Kronecker delta on 4D Lorentz indices. -/
def delta4 (mu nu : FCIdx) : ℝ := if mu = nu then 1 else 0

/-- Diagonal Kronecker value: δ^μ_μ = 1. -/
theorem delta4_refl (mu : FCIdx) : delta4 mu mu = 1 := by
  simp [delta4]

/-- Off-diagonal Kronecker value: μ ≠ ν implies δ^μ_ν = 0. -/
theorem delta4_eq_zero_of_ne {mu nu : FCIdx} (h : mu ≠ nu) : delta4 mu nu = 0 := by
  simp [delta4, h]

/-- Kronecker symmetry: δ^μ_ν = δ^ν_μ. -/
theorem delta4_symm (mu nu : FCIdx) : delta4 mu nu = delta4 nu mu := by
  by_cases h : mu = nu
  · rw [delta4, if_pos h, delta4, if_pos h.symm]
  · rw [delta4, if_neg h, delta4, if_neg (Ne.symm h)]

/-- Kronecker trace in 4D: Σ_μ δ^μ_μ = 4. -/
theorem delta4_trace :
    (Finset.univ : Finset FCIdx).sum (fun mu => delta4 mu mu) = 4 := by
  simp [delta4, FCIdx, Fin.sum_univ_four]

/-- Kronecker contraction: Σ_ρ δ^μ_ρ δ^ρ_ν = δ^μ_ν. -/
theorem delta4_contract (mu nu : FCIdx) :
    (Finset.univ : Finset FCIdx).sum (fun rho => delta4 mu rho * delta4 rho nu) = delta4 mu nu := by
  fin_cases mu <;> fin_cases nu <;> simp [delta4, FCIdx, Fin.sum_univ_four]

/-- Normalization convention: epsilon^{0123} = +1. -/
theorem leviCivita_0123_pos : leviCivita 0 1 2 3 = 1 :=
  leviCivita_0123

/-- One adjacent swap from 0123 gives ε^{1023} = -1. -/
theorem leviCivita_1023_neg : leviCivita 1 0 2 3 = -1 := by
  have h := leviCivita_antisymm_01 (μ := 0) (ν := 1) (ρ := 2) (σ := 3)
  rw [leviCivita_0123_pos] at h
  linarith

/-- One adjacent swap from 0123 gives ε^{0213} = -1. -/
theorem leviCivita_0213_neg : leviCivita 0 2 1 3 = -1 := by
  have h := leviCivita_antisymm_12 (μ := 0) (ν := 1) (ρ := 2) (σ := 3)
  rw [leviCivita_0123_pos] at h
  linarith

/-- One adjacent swap from 0123 gives ε^{0132} = -1. -/
theorem leviCivita_0132_neg : leviCivita 0 1 3 2 = -1 := by
  have h := leviCivita_antisymm_last (μ := 0) (ν := 1) (ρ := 2) (σ := 3)
  rw [leviCivita_0123_pos] at h
  linarith

/-- Antisymmetry under exchange of indices 0 and 1. -/
theorem leviCivita4_antisymm_01 (mu nu rho sigma : FCIdx) :
    leviCivita mu nu rho sigma = -leviCivita nu mu rho sigma :=
  leviCivita_antisymm_01 mu nu rho sigma

/-- Antisymmetry under exchange of indices 1 and 2. -/
theorem leviCivita4_antisymm_12 (mu nu rho sigma : FCIdx) :
    leviCivita mu nu rho sigma = -leviCivita mu rho nu sigma :=
  leviCivita_antisymm_12 mu nu rho sigma

/-- Antisymmetry under exchange of indices 2 and 3. -/
theorem leviCivita4_antisymm_23 (mu nu rho sigma : FCIdx) :
    leviCivita mu nu rho sigma = -leviCivita mu nu sigma rho :=
  leviCivita_antisymm_last mu nu rho sigma

/-- Levi-Civita vanishes when indices 0 and 1 coincide. -/
theorem leviCivita4_diagonal_01 (mu nu rho : FCIdx) :
    leviCivita mu mu nu rho = 0 :=
  leviCivita_diagonal_zero mu nu rho

/-- Levi-Civita vanishes when indices 1 and 2 coincide. -/
theorem leviCivita4_diagonal_12 (mu nu rho : FCIdx) :
    leviCivita mu nu nu rho = 0 :=
  leviCivita_diagonal_12 mu nu rho

/-- Levi-Civita vanishes when indices 2 and 3 coincide. -/
theorem leviCivita4_diagonal_23 (mu nu rho : FCIdx) :
    leviCivita mu nu rho rho = 0 :=
  leviCivita_diagonal_23 mu nu rho

/-- Vanishing when indices 0 and 2 coincide. -/
theorem leviCivita4_diagonal_02 (mu nu sigma : FCIdx) :
    leviCivita mu nu mu sigma = 0 := by
  rw [leviCivita4_antisymm_12 (mu := mu) (nu := nu) (rho := mu) (sigma := sigma)]
  simpa [leviCivita4_diagonal_01 (mu := mu) (nu := nu) (rho := sigma)]

/-- Vanishing when indices 0 and 3 coincide. -/
theorem leviCivita4_diagonal_03 (mu nu rho : FCIdx) :
    leviCivita mu nu rho mu = 0 := by
  rw [leviCivita4_antisymm_23 (mu := mu) (nu := nu) (rho := rho) (sigma := mu)]
  simpa [leviCivita4_diagonal_02 (mu := mu) (nu := nu) (sigma := rho)]

/-- Vanishing when indices 1 and 3 coincide. -/
theorem leviCivita4_diagonal_13 (mu nu rho : FCIdx) :
    leviCivita mu nu rho nu = 0 := by
  rw [leviCivita4_antisymm_23 (mu := mu) (nu := nu) (rho := rho) (sigma := nu)]
  simpa [leviCivita4_diagonal_12 (mu := mu) (nu := nu) (rho := rho)]

/-- Levi-Civita vanishes if any pair of indices coincide. -/
theorem leviCivita4_zero_of_repeated
    {mu nu rho sigma : FCIdx}
    (h : mu = nu ∨ mu = rho ∨ mu = sigma ∨ nu = rho ∨ nu = sigma ∨ rho = sigma) :
    leviCivita mu nu rho sigma = 0 := by
  rcases h with h01 | hrest
  · subst nu
    exact leviCivita4_diagonal_01 mu rho sigma
  rcases hrest with h02 | hrest
  · subst rho
    exact leviCivita4_diagonal_02 mu nu sigma
  rcases hrest with h03 | hrest
  · subst sigma
    exact leviCivita4_diagonal_03 mu nu rho
  rcases hrest with h12 | hrest
  · subst rho
    exact leviCivita4_diagonal_12 mu nu sigma
  rcases hrest with h13 | h23
  · subst sigma
    exact leviCivita4_diagonal_13 mu nu rho
  · subst sigma
    exact leviCivita4_diagonal_23 mu nu rho

/-- Single-index epsilon-epsilon contraction in 4D. -/
theorem leviCivita4_contract_single (mu nu rho alpha beta gamma : FCIdx) :
  (Finset.univ : Finset FCIdx).sum (fun sigma =>
      leviCivita mu nu rho sigma * leviCivita alpha beta gamma sigma) =
    delta4 mu alpha * (delta4 nu beta * delta4 rho gamma - delta4 nu gamma * delta4 rho beta)
    - delta4 mu beta * (delta4 nu alpha * delta4 rho gamma - delta4 nu gamma * delta4 rho alpha)
    + delta4 mu gamma * (delta4 nu alpha * delta4 rho beta - delta4 nu beta * delta4 rho alpha) := by
  simpa [delta4] using leviCivita_eps_eps_3 mu nu rho alpha beta gamma

/-- Double-index epsilon-epsilon contraction in 4D:
    Σ_{ρσ} ε^{μνρσ} ε^{αβ}{}_{ρσ} = 2(δ^{μα}δ^{νβ} - δ^{μβ}δ^{να}). -/
theorem leviCivita4_contract_double (mu nu alpha beta : FCIdx) :
    (Finset.univ : Finset FCIdx).sum (fun rho =>
      (Finset.univ : Finset FCIdx).sum (fun sigma =>
        leviCivita mu nu rho sigma * leviCivita alpha beta rho sigma))
    = 2 * (delta4 mu alpha * delta4 nu beta - delta4 mu beta * delta4 nu alpha) := by
  have hRho : ∀ rho : FCIdx,
      (Finset.univ : Finset FCIdx).sum (fun sigma =>
        leviCivita mu nu rho sigma * leviCivita alpha beta rho sigma)
      = delta4 mu alpha * (delta4 nu beta * delta4 rho rho - delta4 nu rho * delta4 rho beta)
        - delta4 mu beta * (delta4 nu alpha * delta4 rho rho - delta4 nu rho * delta4 rho alpha)
        + delta4 mu rho * (delta4 nu alpha * delta4 rho beta - delta4 nu beta * delta4 rho alpha) := by
    intro rho
    simpa using
      (leviCivita4_contract_single
        (mu := mu) (nu := nu) (rho := rho)
        (alpha := alpha) (beta := beta) (gamma := rho))
  simp_rw [hRho]
  fin_cases mu <;> fin_cases nu <;> fin_cases alpha <;> fin_cases beta <;>
    simp [delta4, FCIdx, Fin.sum_univ_four] <;> ring

/-- Triple-index epsilon-epsilon contraction in 4D:
    Σ_{νρσ} ε^{μνρσ} ε^{ανρσ} = 6 δ^{μα}. -/
theorem leviCivita4_contract_triple (mu alpha : FCIdx) :
    (Finset.univ : Finset FCIdx).sum (fun nu =>
      (Finset.univ : Finset FCIdx).sum (fun rho =>
        (Finset.univ : Finset FCIdx).sum (fun sigma =>
          leviCivita mu nu rho sigma * leviCivita alpha nu rho sigma)))
    = 6 * delta4 mu alpha := by
  have hNu : ∀ nu : FCIdx,
      (Finset.univ : Finset FCIdx).sum (fun rho =>
        (Finset.univ : Finset FCIdx).sum (fun sigma =>
          leviCivita mu nu rho sigma * leviCivita alpha nu rho sigma))
      = 2 * (delta4 mu alpha * delta4 nu nu - delta4 mu nu * delta4 nu alpha) := by
    intro nu
    simpa using (leviCivita4_contract_double (mu := mu) (nu := nu) (alpha := alpha) (beta := nu))
  simp_rw [hNu]
  fin_cases mu <;> fin_cases alpha <;>
    simp [delta4, FCIdx, Fin.sum_univ_four] <;> ring

/-- Fixed first index contraction: Σ_{νρσ} ε^{μνρσ} ε_{μνρσ} = 6. -/
theorem leviCivita4_contract_triple_diag (mu : FCIdx) :
    (Finset.univ : Finset FCIdx).sum (fun nu =>
      (Finset.univ : Finset FCIdx).sum (fun rho =>
        (Finset.univ : Finset FCIdx).sum (fun sigma =>
          leviCivita mu nu rho sigma * leviCivita mu nu rho sigma)))
    = 6 := by
  have h := leviCivita4_contract_triple (mu := mu) (alpha := mu)
  simpa [delta4_refl] using h

/-- Recover ε² norm from the triple contraction identity. -/
theorem leviCivita4_norm_from_triple :
    (Finset.univ : Finset FCIdx).sum (fun mu =>
      (Finset.univ : Finset FCIdx).sum (fun nu =>
        (Finset.univ : Finset FCIdx).sum (fun rho =>
          (Finset.univ : Finset FCIdx).sum (fun sigma =>
            leviCivita mu nu rho sigma * leviCivita mu nu rho sigma)))) = 24 := by
  simp_rw [leviCivita4_contract_triple_diag]
  simp [Finset.sum_const, FCIdx, Fintype.card_fin]
  norm_num

/-- Full self-contraction in 4D: sum_{mu,nu,rho,sigma} epsilon^2 = 24 = 4!. -/
theorem leviCivita4_norm :
    (Finset.univ : Finset FCIdx).sum (fun mu =>
      (Finset.univ : Finset FCIdx).sum (fun nu =>
        (Finset.univ : Finset FCIdx).sum (fun rho =>
          (Finset.univ : Finset FCIdx).sum (fun sigma =>
            leviCivita mu nu rho sigma * leviCivita mu nu rho sigma)))) = 24 :=
  leviCivita_self_contract

end CATEPTMain.FEYNCALC
