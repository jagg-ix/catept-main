import NavierStokes.Galerkin.NSGalerkinCompactness
import Mathlib.Topology.Algebra.InfiniteSum.Order
import Mathlib.Topology.Algebra.InfiniteSum.Real

/-!
# Stage 177 — NSGalerkinEnergyTransfer: Discharge B2 and B3

Promotes `galerkinTower_energy_range` (B2) and `galerkinTower_energy_tsum` (B3)
from axioms to **theorems**, removing 2 of the 8 `.partiallyVerified` axioms.

## Strategy

**B2** (`energy_range`): for fixed `(k, M)`,
1. For each `m ∈ Finset.range M`, `hconv k m` gives pointwise `Tendsto`.
2. `Continuous normSqR` → `Tendsto (normSqR ∘ ·)` for each coordinate.
3. `tendsto_finset_sum` → `Tendsto` of the whole `coeffNormSqRRange M` sum.
4. Each partial sum is `≤ tower.E0` (from Stage 174A's Rat bound, cast to Real).
5. `le_of_tendsto` → the limit `coeffNormSqRRange M (uInfty k) ≤ tower.E0`.

**B3** (`energy_tsum`): given B2,
1. `normSqR_nonneg` + `Real.tsum_le_of_sum_le`: reduce to bounding every `Finset` sum.
2. For any `s : Finset Nat`, embed into `Finset.range (s.sup id + 1)` and apply B2.

## Helper chain

1. `embedCoeffR_normSqR_eq`:  normSqR (embedCoeffR u i.val) = (normSqC (u i) : Real)
2. `embedCoeffR_normSqR_zero`: normSqR (embedCoeffR u m) = 0   when m ≥ N
3. `embedCoeffR_energy_eq`:   coeffNormSqRRange N (embedCoeffR u) = (coeffNormSq u : Real)
4. `coeffNormSqRRange_eq_of_ge`: coeffNormSqRRange M (embedCoeffR u) = coeffNormSqRRange N (embedCoeffR u) when M ≥ N
5. `embedCoeffR_energy_le`:   coeffNormSqRRange M (embedCoeffR u) ≤ (coeffNormSq u : Real)
6. `tower_embedCoeffR_energy_le`: bounds the per-step embedding in Real
7. `continuous_normSqR`:       Continuous normSqR
8. B2 as theorem
9. B3 as theorem (from B2 via `Real.tsum_le_of_sum_le`)

## Net counts

  - New defs:     0
  - New axioms:   0   (B2 and B3 are now theorems)
  - New theorems: 9   (7 helpers + B2 + B3)
  - sorry:        0
  - warnings:     0
  - Axioms eliminated: 2  (galerkinTower_energy_range, galerkinTower_energy_tsum)
-/

namespace NavierStokes.GalerkinEnergyTransfer

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinODE
open NavierStokes.GalerkinConvergence
open NavierStokes.GalerkinTower
open NavierStokes.GalerkinCompactness
open Filter
open scoped Topology BigOperators

/-! ## Helper 1: normSqR at embedded coordinate = cast of normSqC -/

/-- For `i : Fin N`, the real embedding of the i-th coefficient has squared norm equal to
    the rational squared norm cast to Real. -/
theorem embedCoeffR_normSqR_eq {N : Nat} (u : CoeffC N) (i : Fin N) :
    normSqR (embedCoeffR u i.val) = (normSqC (u i) : Real) := by
  simp only [embedCoeffR, dif_pos i.isLt]
  simp only [normSqR, CRat.toCR, normSqC, CRat.re, CRat.im]
  push_cast; ring

/-! ## Helper 2: normSqR is zero outside the support -/

theorem embedCoeffR_normSqR_zero {N : Nat} (u : CoeffC N) (m : Nat) (hm : N ≤ m) :
    normSqR (embedCoeffR u m) = 0 := by
  simp only [embedCoeffR, dif_neg (Nat.not_lt.mpr hm)]
  simp [normSqR]

/-! ## Helper 3: restricted energy identity at cutoff N -/

/-- The Real-valued restricted energy at cutoff N equals the Rat energy cast to Real. -/
theorem embedCoeffR_energy_eq {N : Nat} (u : CoeffC N) :
    coeffNormSqRRange N (embedCoeffR u) = (coeffNormSq u : Real) := by
  simp only [coeffNormSqRRange, coeffNormSq]
  -- LHS: ∑ n ∈ Finset.range N, normSqR (embedCoeffR u n)
  -- RHS: (∑ i : Fin N, normSqC (u i) : Rat) cast to Real
  --    = ∑ i : Fin N, (normSqC (u i) : Real)  by Rat.cast_sum
  rw [Rat.cast_sum]
  -- LHS: ∑ n ∈ Finset.range N, normSqR (embedCoeffR u n)
  -- RHS: ∑ i : Fin N, (normSqC (u i) : Real)
  rw [← Fin.sum_univ_eq_sum_range (fun n => normSqR (embedCoeffR u n))]
  -- Now LHS: ∑ i : Fin N, normSqR (embedCoeffR u i.val)
  congr 1; ext i
  exact embedCoeffR_normSqR_eq u i

/-! ## Helper 4: restricted energy unchanged when extending beyond support -/

/-- When `M ≥ N`, terms beyond N are zero so the range-M sum equals the range-N sum. -/
theorem coeffNormSqRRange_eq_of_ge {N : Nat} (u : CoeffC N) (M : Nat) (hM : N ≤ M) :
    coeffNormSqRRange M (embedCoeffR u) = coeffNormSqRRange N (embedCoeffR u) := by
  simp only [coeffNormSqRRange]
  -- Write range M = range N ∪ Ico N M (disjoint), and the Ico part sums to 0
  have hIco : ∑ x ∈ Finset.Ico N M, normSqR (embedCoeffR u x) = 0 :=
    Finset.sum_eq_zero fun x hx =>
      embedCoeffR_normSqR_zero u x (Finset.mem_Ico.mp hx).1
  have hsplit := Finset.sum_range_add_sum_Ico hM (f := fun n => normSqR (embedCoeffR u n))
  linarith

/-! ## Helper 5: restricted energy ≤ full energy for any cutoff -/

/-- For any `M`, the Real restricted energy is at most the full (Rat) energy cast to Real. -/
theorem embedCoeffR_energy_le {N : Nat} (u : CoeffC N) (M : Nat) :
    coeffNormSqRRange M (embedCoeffR u) ≤ (coeffNormSq u : Real) := by
  rw [← embedCoeffR_energy_eq u]
  by_cases h : M ≤ N
  · exact coeffNormSqRRange_mono h _
  · push_neg at h
    exact le_of_eq (coeffNormSqRRange_eq_of_ge u M (Nat.le_of_lt h))

/-! ## Helper 6: per-step tower bound in Real -/

/-- The restricted Real energy of the embedded Galerkin step is bounded by `tower.E0`. -/
theorem tower_embedCoeffR_energy_le
    (tower : GalerkinTower) (phi : Nat → Nat)
    (k M n : Nat) :
    coeffNormSqRRange M
      (embedCoeffR ((tower.trajAt (phi n)).traj.u k)) ≤ (tower.E0 : Real) :=
  le_trans
    (embedCoeffR_energy_le ((tower.trajAt (phi n)).traj.u k) M)
    (by exact_mod_cast GalerkinTower.uniform_energy_all_steps tower (phi n) k)

/-! ## Helper 7: continuity of normSqR -/

theorem continuous_normSqR : Continuous normSqR := by
  unfold normSqR
  fun_prop

/-! ## B2: galerkinTower_energy_range as a theorem -/

/-- **Energy range transfer** — promoted from axiom to theorem.

    Proof: for fixed `k M`, form the Tendsto limit of the partial-sum functional via
    `tendsto_finset_sum` + continuity of `normSqR`, then apply `le_of_tendsto` with
    the per-step bound `tower_embedCoeffR_energy_le`. -/
theorem galerkinTower_energy_range_thm
    (tower : GalerkinTower)
    (phi : Nat → Nat) (_hphi : StrictMono phi)
    (uInfty : Nat → CoeffInftyR)
    (hconv : ∀ (k m : Nat),
        Tendsto (fun n => embedCoeffR ((tower.trajAt (phi n)).traj.u k) m)
          atTop (𝓝 (uInfty k m))) :
    ∀ (k M : Nat), coeffNormSqRRange M (uInfty k) ≤ (tower.E0 : Real) := by
  intro k M
  simp only [coeffNormSqRRange]
  -- Form the Tendsto for the full sum over Finset.range M
  have hTendsto : Tendsto
      (fun n => ∑ m ∈ Finset.range M, normSqR (embedCoeffR ((tower.trajAt (phi n)).traj.u k) m))
      atTop
      (𝓝 (∑ m ∈ Finset.range M, normSqR (uInfty k m))) := by
    apply tendsto_finset_sum
    intro m _
    exact (continuous_normSqR.continuousAt.tendsto).comp (hconv k m)
  -- Apply le_of_tendsto': since each partial sum ≤ E0, the limit is ≤ E0
  exact le_of_tendsto' hTendsto (fun n => tower_embedCoeffR_energy_le tower phi k M n)

/-! ## B3: galerkinTower_energy_tsum as a theorem -/

/-- **Full tsum energy transfer** — promoted from axiom to theorem.

    Proof: apply `Real.tsum_le_of_sum_le` (nonneg terms, bound on every finset sum)
    using B2. For any `s : Finset Nat`, embed into `Finset.range (s.sup id + 1)`
    and apply `galerkinTower_energy_range_thm`. -/
theorem galerkinTower_energy_tsum_thm
    (tower : GalerkinTower)
    (phi : Nat → Nat) (_hphi : StrictMono phi)
    (uInfty : Nat → CoeffInftyR)
    (_hconv : ∀ (k m : Nat),
        Tendsto (fun n => embedCoeffR ((tower.trajAt (phi n)).traj.u k) m)
          atTop (𝓝 (uInfty k m)))
    (hrange : ∀ (k M : Nat), coeffNormSqRRange M (uInfty k) ≤ (tower.E0 : Real)) :
    ∀ k : Nat, coeffNormSqR (uInfty k) ≤ (tower.E0 : Real) := by
  intro k
  simp only [coeffNormSqR]
  apply Real.tsum_le_of_sum_le (fun n => normSqR_nonneg _)
  intro s
  -- Bound arbitrary finset sum by a range sum, then apply hrange
  calc ∑ m ∈ s, normSqR (uInfty k m)
      ≤ ∑ m ∈ Finset.range (s.sup id + 1), normSqR (uInfty k m) := by
          apply Finset.sum_le_sum_of_subset_of_nonneg
          · intro m hm
            simp only [Finset.mem_range]
            exact Nat.lt_succ_of_le (Finset.le_sup (f := id) hm)
          · intro m _ _; exact normSqR_nonneg _
    _ = coeffNormSqRRange (s.sup id + 1) (uInfty k) := rfl
    _ ≤ (tower.E0 : Real) := hrange k (s.sup id + 1)

def stage177Summary : String :=
  "Stage 177: NSGalerkinEnergyTransfer — discharge B2 and B3 as theorems. " ++
  "embedCoeffR_normSqR_eq: THEOREM (simp + push_cast + ring). " ++
  "embedCoeffR_normSqR_zero: THEOREM (dif_neg + simp). " ++
  "embedCoeffR_energy_eq: THEOREM (Rat.cast_sum + Fin.sum_univ_eq_sum_range + congr). " ++
  "coeffNormSqRRange_eq_of_ge: THEOREM (sum_range_add_sum_Ico + Finset.sum_eq_zero + linarith). " ++
  "embedCoeffR_energy_le: THEOREM (le_or_lt + coeffNormSqRRange_mono + eq_of_ge). " ++
  "tower_embedCoeffR_energy_le: THEOREM (embedCoeffR_energy_le + uniform_energy_all_steps). " ++
  "continuous_normSqR: THEOREM (fun_prop). " ++
  "galerkinTower_energy_range_thm: THEOREM (tendsto_finset_sum + le_of_tendsto). " ++
  "galerkinTower_energy_tsum_thm: THEOREM (Real.tsum_le_of_sum_le + Finset.sup). " ++
  "Axioms eliminated: galerkinTower_energy_range + galerkinTower_energy_tsum. " ++
  "+0 axioms, +9 theorems, 0 sorry."

end NavierStokes.GalerkinEnergyTransfer
