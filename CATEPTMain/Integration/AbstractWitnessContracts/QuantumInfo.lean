import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# CATEPT Plugin — Quantum-Information Integration Bridge

Sibling repo of `jagg-ix/catept-main`. Provides an abstract integration
contract for the `lean-quantuminfo` package (Lean-QuantumInfo by SIO)
against CATEPT's quantum bridges.

**Toolchain status:** the upstream `lean-quantuminfo` package targets
Lean 4 v4.28.0; direct import is currently blocked. This sibling defines
only the abstract witness so consumers can reason about the integration
contract without depending on the unavailable upstream. Phase-2 work
(after upstream toolchain bump): replace witness fields with direct
imports from `QuantumInfo` / `ClassicalInfo`.

## CATEPT leverage points

* **IMD bridge** (`AFPBridge/IMD`): `QuantumInfo.Finite.CPTPMap` —
  completely-positive trace-preserving maps; bridges to
  `IMD.Theories.Quantum` unitary/measurement channels.
* `QuantumInfo.Finite.Braket` — typed ket/bra; cross-validates
  `IMDPrelude`'s `QVec`/`QMat` representation choices.
* `QuantumInfo.Finite.AxiomatizedEntropy.Renyi` — Rényi entropy used in
  `No_Cloning` (information-theoretic proof).
* **HSTP bridge** (`AFPBridge/HSTP`): `QuantumInfo` von Neumann entropy
  aligns with `HSTP.Theories.Trace_Class` and `Partial_Trace`.
* **Classical info layer**: `ClassicalInfo.Entropy` (Shannon) and
  `ClassicalInfo.Channel`/`Capacity` ground the CAT/EPT mutual-info
  side-conditions.

## Re-import contract for `catept-main`

```lean
import CATEPTPluginQuantumInfo.IntegrationBridge

open CATEPTPluginQuantumInfo (
  QuantumInfoWitness QuantumInfoIntegrationContract
  quantumInfo_integration_contract)
```
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTPluginQuantumInfo

/-! ## Concrete Shannon and Rényi entropy definitions

In addition to the abstract `QuantumInfoWitness` contract, this
module exposes **proven theorems** about classical Shannon and
Rényi entropy on finite probability vectors.  These are concrete
content (no upstream `lean-quantuminfo` dependency) — Mathlib's
`Real.log` plus `Finset.sum` machinery suffice. -/

open Finset

/-- **Shannon entropy** for a probability vector `p : Fin n → ℝ`:
    `H(p) = −∑ pᵢ · log pᵢ`.

    Uses Mathlib's convention `Real.log 0 = 0`, so the standard
    `0 · log 0 = 0` rule for entropy is automatic. -/
noncomputable def shannonEntropy {n : ℕ} (p : Fin n → ℝ) : ℝ :=
  -∑ i, p i * Real.log (p i)

/-- **Proven:** Shannon entropy of the zero probability vector is `0`. -/
theorem proved_shannon_entropy_zero {n : ℕ} :
    shannonEntropy (fun _ : Fin n => (0 : ℝ)) = 0 := by
  unfold shannonEntropy
  simp

/-- **Proven:** Shannon entropy of the *one-hot* distribution (all
    mass on a single index) is `0`.

    For `δ : Fin n → ℝ` with `δ k = 1` and `δ i = 0` for `i ≠ k`,
    each summand `δ i · log (δ i)` is `0`: at `i = k` we have
    `1 · log 1 = 0`, and at `i ≠ k` we have `0 · log 0 = 0`. -/
theorem proved_shannon_entropy_dirac {n : ℕ} [NeZero n] (k : Fin n) :
    shannonEntropy (fun i : Fin n => if i = k then 1 else 0) = 0 := by
  unfold shannonEntropy
  rw [neg_eq_zero]
  apply Finset.sum_eq_zero
  intro i _
  by_cases h : i = k
  · simp [h]
  · simp [h]

/-- **Rényi entropy** of order `α` for a probability vector.
    For `α = 1`, falls through to Shannon entropy.
    For `α ≠ 1`,
        `H_α(p) = (1/(1−α)) · log (∑ pᵢ^α)`. -/
noncomputable def renyiEntropy {n : ℕ} (α : ℝ) (p : Fin n → ℝ) : ℝ :=
  if α = 1 then shannonEntropy p
  else (1 / (1 - α)) * Real.log (∑ i, (p i) ^ α)

/-- **Proven:** Rényi entropy at `α = 1` equals Shannon entropy.

    Direct from the definition's `if α = 1 then …`. -/
theorem proved_renyi_at_one_eq_shannon {n : ℕ} (p : Fin n → ℝ) :
    renyiEntropy 1 p = shannonEntropy p := by
  unfold renyiEntropy
  simp

/-- **Proven:** at `α = 0` and `p i ≡ 1`, the Rényi entropy is
    `log n`.

    Direct calculation:
    `(1/(1-0)) * log (∑ 1^0) = 1 * log (∑ 1) = log n`. -/
theorem proved_renyi_zero_eq_log_n {n : ℕ} :
    renyiEntropy (0 : ℝ) (fun _ : Fin n => (1 : ℝ)) = Real.log (n : ℝ) := by
  unfold renyiEntropy
  have h01 : (0 : ℝ) ≠ 1 := by norm_num
  rw [if_neg h01]
  have hsub : (1 : ℝ) - 0 = 1 := by norm_num
  rw [hsub]
  have hone : (1 : ℝ) / 1 = 1 := by norm_num
  rw [hone, one_mul]
  congr 1
  -- Goal: ∑ i : Fin n, (1 : ℝ) ^ (0 : ℝ) = (n : ℝ)
  simp [Real.rpow_zero]

/-! ## Witness contract (preserved) -/

/-- Abstract capability witness for `lean-quantuminfo`. -/
structure QuantumInfoWitness where
  /-- `QuantumInfo.Finite.CPTPMap`: CPTP channels on finite-dimensional
      Hilbert spaces are available. -/
  cptpMapAvailable : Prop
  /-- `QuantumInfo.Finite.Braket`: typed ket/bra Dirac notation available. -/
  braketAvailable : Prop
  /-- Von Neumann entropy `S(ρ) = −tr(ρ log ρ)` formally stated. -/
  vonNeumannEntropyAvailable : Prop
  /-- Rényi entropy (order α) formally stated. -/
  renyiEntropyAvailable : Prop
  /-- `ClassicalInfo.Entropy`: Shannon entropy `H(p) = −∑ pᵢ log pᵢ`
      formally stated. -/
  shannonEntropyAvailable : Prop
  /-- `ClassicalInfo.Capacity`: classical channel capacity theorem available. -/
  channelCapacityAvailable : Prop

/-- Integration contract: CATEPT's IMD and HSTP bridges obtain quantum-info
    entropy and channel witnesses once `QuantumInfoWitness` is satisfied. -/
def QuantumInfoIntegrationContract (w : QuantumInfoWitness) : Prop :=
  w.cptpMapAvailable ∧ w.braketAvailable ∧
  w.vonNeumannEntropyAvailable ∧ w.renyiEntropyAvailable ∧
  w.shannonEntropyAvailable ∧ w.channelCapacityAvailable

/-- Phase-1 bridge theorem (term-proved, structurally trivial). -/
theorem quantumInfo_integration_contract
    (w : QuantumInfoWitness)
    (hC : w.cptpMapAvailable) (hB : w.braketAvailable)
    (hV : w.vonNeumannEntropyAvailable) (hR : w.renyiEntropyAvailable)
    (hS : w.shannonEntropyAvailable) (hCap : w.channelCapacityAvailable) :
    QuantumInfoIntegrationContract w :=
  ⟨hC, hB, hV, hR, hS, hCap⟩

end CATEPTPluginQuantumInfo

end
