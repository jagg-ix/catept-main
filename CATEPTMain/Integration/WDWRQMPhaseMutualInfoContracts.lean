import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset

/-!
# WDWRQMPhaseMutualInfoContracts — Phase From Mutual-Information Accumulation

This file is a **contract landing pad** for the segment:

`# Phase as Accumulated Mutual Information` (around L9599) in

`(private intake doc)`.

Reusable core idea (rephrased without any “game universe” metaphor):

* Each actor/process has a phase-like internal coordinate `φᵢ`.
* The phase advances as **mutual information is accumulated** along edges:

  `φᵢ(τ) = φᵢ(0) + Σ_j ∫ γᵢⱼ dIᵢⱼ(τ)`.

For Lean reusability we provide a **discrete** model:

* a step index `n : ℕ`
* per-step increments `ΔIᵢⱼ(k) ≥ 0`
* nonnegative couplings `γᵢⱼ ≥ 0`

Then `φᵢ(n)` is defined by finite sums, and we can prove basic monotonicity.

Honest scope:

* This is **not** a physics theorem.
* It is a reusable algebraic shape used later to connect:
  - entropic-time accumulation,
  - vector-clock partial orders,
  - synchronization/coherence “cluster” predicates.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.WDWRQMPhaseMutualInfoContracts

-- ============================================================================
-- 1. Discrete mutual-information increments + couplings
-- ============================================================================

structure MutualInfoDiscrete (Actor : Type*) where
  dI : Actor → Actor → ℕ → ℝ
  dI_nonneg : ∀ i j k, 0 ≤ dI i j k

structure CouplingNonneg (Actor : Type*) where
  γ : Actor → Actor → ℝ
  γ_nonneg : ∀ i j, 0 ≤ γ i j

-- ============================================================================
-- 2. Phase definition (finite sums)
-- ============================================================================

section PhaseDef

variable {Actor : Type*}

/-!
Neighbors are represented by a `Finset` to keep the definition executable and
finite (matching the artifact’s “communication graph neighborhood”).
-/
variable (neighbors : Actor → Finset Actor)
variable (initPhase : Actor → ℝ)
variable (c : CouplingNonneg Actor)
variable (mi : MutualInfoDiscrete Actor)

/-!
Discrete phase:

`φᵢ(n) = φᵢ(0) + Σ_{j∈N(i)} Σ_{k<n} γᵢⱼ · ΔIᵢⱼ(k)`
-/
def phaseAt (i : Actor) (n : ℕ) : ℝ :=
  initPhase i +
    Finset.sum (neighbors i) (fun j =>
      Finset.sum (Finset.range n) (fun k => (c.γ i j) * (mi.dI i j k)))

theorem phaseAt_zero (i : Actor) : phaseAt neighbors initPhase c mi i 0 = initPhase i := by
  simp [phaseAt]

theorem phaseAt_succ_ge (i : Actor) (n : ℕ) :
    phaseAt neighbors initPhase c mi i n ≤ phaseAt neighbors initPhase c mi i (n + 1) := by
  -- `phaseAt i (n+1)` differs from `phaseAt i n` by adding one more (nonnegative) increment.
  unfold phaseAt
  -- Add the same constant `initPhase i` to both sides; it suffices to compare the sums.
  apply add_le_add_right
  -- Compare the neighbor-sum pointwise.
  refine Finset.sum_le_sum ?_
  intro j hj
  -- Compare the inner sums by monotonicity under `range n ⊆ range (n+1)` and nonnegativity.
  have hsubset : Finset.range n ⊆ Finset.range (n + 1) :=
    Finset.range_subset_range.2 (Nat.le_succ n)
  -- Each per-step increment is nonnegative.
  have hnonneg : ∀ k, 0 ≤ (c.γ i j) * (mi.dI i j k) := by
    intro k
    exact mul_nonneg (c.γ_nonneg i j) (mi.dI_nonneg i j k)
  -- Use `sum_le_sum_of_subset_of_nonneg` to add the missing tail term(s).
  refine Finset.sum_le_sum_of_subset_of_nonneg hsubset ?_
  intro k hk hks
  exact hnonneg k

end PhaseDef

-- ============================================================================
-- 3. Cluster coherence predicate (contract only)
-- ============================================================================

section Coherence

variable {Actor : Type*}

variable (neighbors : Actor → Finset Actor)
variable (initPhase : Actor → ℝ)
variable (c : CouplingNonneg Actor)
variable (mi : MutualInfoDiscrete Actor)

/-!
Artifact coherence definition:

`max_{i,j∈C} |φᵢ - φⱼ| < δ`.

We represent it as an explicit predicate over a finite cluster `C : Finset Actor`.
No claim is made that this predicate is decidable or stable under dynamics;
those become separate obligations in downstream modules.
-/
def ClusterCoherent (C : Finset Actor) (δ : ℝ) (n : ℕ) : Prop :=
  ∀ i ∈ C, ∀ j ∈ C,
    abs (phaseAt neighbors initPhase c mi i n - phaseAt neighbors initPhase c mi j n) ≤ δ

end Coherence

end CATEPTMain.Integration.WDWRQMPhaseMutualInfoContracts
