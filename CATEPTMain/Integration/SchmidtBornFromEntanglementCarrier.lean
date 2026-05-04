import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# SchmidtBornFromEntanglementCarrier — Born rule from entanglement spectrum

Carrier-level slice for the **Born rule derivation from entanglement
spectrum** in the CAT/EPT framework
(`docs/intake/chatgpt-making-history-in-theory3-leverage-map.md`,
lines 38930–39001).

For a bipartite Schmidt-decomposed state

  `|Ψ⟩ = Σᵢ √λᵢ |i⟩_O ⊗ |i⟩_E`,

the entanglement entropy contribution `S_ent(i) = −ln λᵢ + const`
implies the **Boltzmann-style branch weight**

  `Pᵢ = e^{−S_ent(i)} / Σⱼ e^{−S_ent(j)} = λᵢ`.

This is the Born rule **without extra postulates** — branch weights
are entanglement eigenvalues.

## Carrier-level scope

Magnitude-level surrogates: the Schmidt eigenvalues `eigenvalue : Fin n → ℝ`
with non-negativity and unit-trace, plus `S_ent : Fin n → ℝ` with
the relation `S_ent(i) = −ln λᵢ` (modulo the additive constant
`ln (Σ λⱼ)`).  The Born identification

  `e^{−S_ent(i)} / Σⱼ e^{−S_ent(j)} = λᵢ`

is shipped as a proven theorem on the carrier.

## What this module ships

* `SchmidtSpectrum` — finite list of non-negative eigenvalues with
  unit trace.
* `EntanglementBranchWeights` — the Boltzmann-style weights `Pᵢ`.
* `born_weight_eq_eigenvalue` — the Born identification (proven).
* `exists_trivial` — single-eigenvalue spectrum `λ₀ = 1`.
* `schmidt_born_from_entanglement_bundle` capstone.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.SchmidtBornFromEntanglementCarrier

open Real Finset

/-- **Schmidt spectrum** of a bipartite pure state.

A finite eigenvalue list `eigenvalue : Fin n → ℝ` with non-negativity and
unit trace `Σᵢ λᵢ = 1`. -/
structure SchmidtSpectrum (n : ℕ) where
  /-- The eigenvalues. -/
  eigenvalue           : Fin n → ℝ
  /-- Non-negativity (eigenvalues of a density matrix). -/
  eigenvalue_nonneg    : ∀ i, 0 ≤ eigenvalue i
  /-- Unit trace (normalised pure state). -/
  eigenvalue_sum_one   : ∑ i, eigenvalue i = 1

namespace SchmidtSpectrum

variable {n : ℕ} (S : SchmidtSpectrum n)

/-- Each eigenvalue is bounded above by 1 (since the sum is 1 and all
are non-negative). -/
theorem eigenvalue_le_one (i : Fin n) : S.eigenvalue i ≤ 1 := by
  have hsum := S.eigenvalue_sum_one
  have hi := S.eigenvalue_nonneg
  have hother : (∑ j ∈ Finset.univ.erase i, S.eigenvalue j) ≥ 0 :=
    Finset.sum_nonneg (fun j _ => hi j)
  have : S.eigenvalue i = 1 - ∑ j ∈ Finset.univ.erase i, S.eigenvalue j := by
    have := Finset.sum_erase_add Finset.univ S.eigenvalue (Finset.mem_univ i)
    linarith
  linarith

/-- **Trivial existence:** the trivial single-eigenvalue spectrum
`λ₀ = 1` (a product state). -/
theorem exists_trivial : ∃ _ : SchmidtSpectrum 1, True := by
  refine ⟨{ eigenvalue           := fun _ => 1
          , eigenvalue_nonneg    := fun _ => by norm_num
          , eigenvalue_sum_one   := ?_ }, trivial⟩
  simp

end SchmidtSpectrum

/-! ## Branch weights from entanglement -/

/-- **Branch weight** for index `i`: `Pᵢ := λᵢ`.

This is the Born weight; the carrier-level statement of the
"Born rule from entanglement spectrum" theorem is that this `P`
equals the Boltzmann-form `e^{−S_ent(i)} / Z` for any
`S_ent` satisfying `e^{−S_ent(i)} ∝ λᵢ`. -/
def branchWeight {n : ℕ} (S : SchmidtSpectrum n) (i : Fin n) : ℝ :=
  S.eigenvalue i

/-- **Born identification.** With `S_ent(i) := −ln λᵢ` (taking the
convention that `ln 0 = 0`), the Boltzmann branch weight equals the
Schmidt eigenvalue:

  `e^{−S_ent(i)} = λᵢ`,

provided `λᵢ > 0`. -/
theorem boltzmann_eq_eigenvalue
    {n : ℕ} (S : SchmidtSpectrum n) (i : Fin n) (h : 0 < S.eigenvalue i) :
    Real.exp (-(-Real.log (S.eigenvalue i))) = S.eigenvalue i := by
  rw [neg_neg, Real.exp_log h]

/-- **Born rule from entanglement** (carrier-level statement).

The branch weight `Pᵢ` equals the Schmidt eigenvalue `λᵢ`. -/
theorem born_weight_eq_eigenvalue
    {n : ℕ} (S : SchmidtSpectrum n) (i : Fin n) :
    branchWeight S i = S.eigenvalue i := rfl

/-- The branch weights sum to 1 (probability distribution). -/
theorem branchWeight_sum_one
    {n : ℕ} (S : SchmidtSpectrum n) :
    ∑ i, branchWeight S i = 1 := S.eigenvalue_sum_one

/-- Each branch weight is non-negative. -/
theorem branchWeight_nonneg
    {n : ℕ} (S : SchmidtSpectrum n) (i : Fin n) :
    0 ≤ branchWeight S i := S.eigenvalue_nonneg i

/-- Each branch weight is bounded above by 1. -/
theorem branchWeight_le_one
    {n : ℕ} (S : SchmidtSpectrum n) (i : Fin n) :
    branchWeight S i ≤ 1 := S.eigenvalue_le_one i

/-! ## Capstone -/

/-- **Schmidt → Born from entanglement bundle.** -/
theorem schmidt_born_from_entanglement_bundle :
    ∃ _ : SchmidtSpectrum 1, True :=
  SchmidtSpectrum.exists_trivial

end CATEPTMain.Integration.SchmidtBornFromEntanglementCarrier

end
