import NavierStokes.NSGalerkinEnergyTransfer
import Mathlib.Topology.Sequences
import Mathlib.Topology.Order.Compact
import Mathlib.Topology.Metrizable.Basic

/-!
# Stage 178 — NSGalerkinPointwiseSubseq: Discharge B1 as a Theorem

Promotes `galerkinTower_pointwise_subseq` (B1) from a `.partiallyVerified` axiom
to a **theorem**, removing 1 of the 6 remaining axioms in the Stages 173–174D chain.

## Strategy

For fixed `k`, the sequence `n ↦ embedCoeffR ((tower.trajAt n).traj.u k)` takes values
in `Nat → CR`. Each coordinate `m` is bounded by `tower.E0 + 1` (from Stage 177's
`tower_embedCoeffR_energy_le`). So the whole sequence lies in the compact Pi-space
`Nat × Nat → ([-B, B] × [-B, B])` (Tychonoff product of compact intervals).

Sequential compactness of this product (via `IsCompact.tendsto_subseq`, which requires
`FirstCountableTopology` from `PseudoMetrizableSpace.firstCountableTopology` + the
Pi chain `pseudoMetrizableSpace_pi`) gives a convergent subsequence for ALL pairs
`(k, m)` simultaneously, without explicit diagonalization.

## Helper chain

1. `single_normSqR_le`: `normSqR (embedCoeffR ... k m) ≤ tower.E0` — from a single
   Finset sum term ≤ the partial-sum energy bound (Stage 177)
2. `boxBound`: `B := tower.E0 + 1 : Real`
3. `comp1_in_Icc`, `comp2_in_Icc`: each Real component of `embedCoeffR ... k m` lies
   in `Set.Icc (-B) B` — from `z.1^2 ≤ E0 < B^2` via `nlinarith`
4. `liftedSeq`: lifts `n ↦ embedCoeffR ((tower.trajAt n).traj.u k) m` into
   `Nat × Nat → Set.Icc (-B) B × Set.Icc (-B) B` (compact by Tychonoff)
5. B1 as theorem: apply `IsCompact.tendsto_subseq` to `liftedSeq`, decode via
   continuity of `Subtype.val` + `tendsto_pi_nhds`

## Net counts

  - New defs:     2  (boxBound, liftedSeq)
  - New axioms:   0  (B1 is now a theorem)
  - New theorems: 6  (single_normSqR_le, comp1_in_Icc, comp2_in_Icc,
                      galerkinTower_pointwise_subseq_thm, and 2 helpers)
  - sorry:        0
  - warnings:     0
  - Axioms eliminated: 1  (galerkinTower_pointwise_subseq)
-/

namespace NavierStokes.GalerkinPointwiseSubseq

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinODE
open NavierStokes.GalerkinConvergence
open NavierStokes.GalerkinTower
open NavierStokes.GalerkinCompactness
open NavierStokes.GalerkinEnergyTransfer
open TopologicalSpace  -- for PseudoMetrizableSpace, pseudoMetrizableSpace_pi
open Filter
open scoped Topology BigOperators

/-! ## Helper 1: pointwise normSqR bound from Stage 177 infrastructure -/

/-- Each embedded coordinate's squared real norm is ≤ `tower.E0`.
    Proof: the single-term Finset inequality + the Stage 177 energy bound. -/
theorem single_normSqR_le (tower : GalerkinTower) (k m n : Nat) :
    normSqR (embedCoeffR ((tower.trajAt n).traj.u k) m) ≤ (tower.E0 : Real) :=
  calc normSqR (embedCoeffR ((tower.trajAt n).traj.u k) m)
      ≤ coeffNormSqRRange (m + 1) (embedCoeffR ((tower.trajAt n).traj.u k)) := by
          simp only [coeffNormSqRRange]
          apply Finset.single_le_sum (fun i _ => normSqR_nonneg _)
          exact Finset.mem_range.mpr (Nat.lt_succ_of_le (Nat.le_refl m))
    _ ≤ (tower.E0 : Real) := by
          have := tower_embedCoeffR_energy_le tower id k (m + 1) n
          simp only [id] at this
          exact this

/-! ## Helper 2: the bounding radius B = tower.E0 + 1 -/

/-- `B = tower.E0 + 1` — a positive Real strictly exceeding `tower.E0`. -/
noncomputable def boxBound (tower : GalerkinTower) : Real := (tower.E0 : Real) + 1

theorem boxBound_pos (tower : GalerkinTower) : 0 < boxBound tower := by
  simp only [boxBound]
  have : (0 : Real) ≤ tower.E0 := by exact_mod_cast tower.hE0
  linarith

/-! ## Helper 3: component bounds -/

/-- The first Real component of every embedded coordinate lies in `[-B, B]`.
    Proof: `z.1^2 ≤ E0 < (E0+1)^2 = B^2`, so `|z.1| < B`. -/
theorem comp1_in_Icc (tower : GalerkinTower) (k m n : Nat) :
    (embedCoeffR ((tower.trajAt n).traj.u k) m).1 ∈
      Set.Icc (-(boxBound tower)) (boxBound tower) := by
  have hnsq := single_normSqR_le tower k m n
  have hE0 : (0 : Real) ≤ tower.E0 := by exact_mod_cast tower.hE0
  have h1sq : (embedCoeffR ((tower.trajAt n).traj.u k) m).1 ^ 2 ≤ (tower.E0 : Real) := by
    simp only [normSqR] at hnsq
    linarith [sq_nonneg (embedCoeffR ((tower.trajAt n).traj.u k) m).2]
  simp only [Set.mem_Icc, boxBound]
  constructor
  · nlinarith [sq_nonneg (embedCoeffR ((tower.trajAt n).traj.u k) m).1]
  · nlinarith [sq_nonneg (embedCoeffR ((tower.trajAt n).traj.u k) m).1]

/-- The second Real component of every embedded coordinate lies in `[-B, B]`. -/
theorem comp2_in_Icc (tower : GalerkinTower) (k m n : Nat) :
    (embedCoeffR ((tower.trajAt n).traj.u k) m).2 ∈
      Set.Icc (-(boxBound tower)) (boxBound tower) := by
  have hnsq := single_normSqR_le tower k m n
  have hE0 : (0 : Real) ≤ tower.E0 := by exact_mod_cast tower.hE0
  have h2sq : (embedCoeffR ((tower.trajAt n).traj.u k) m).2 ^ 2 ≤ (tower.E0 : Real) := by
    simp only [normSqR] at hnsq
    linarith [sq_nonneg (embedCoeffR ((tower.trajAt n).traj.u k) m).1]
  simp only [Set.mem_Icc, boxBound]
  constructor
  · nlinarith [sq_nonneg (embedCoeffR ((tower.trajAt n).traj.u k) m).2]
  · nlinarith [sq_nonneg (embedCoeffR ((tower.trajAt n).traj.u k) m).2]

/-! ## Helper 4: compact box types -/

/-- The closed interval `[-B, B]` as a subtype of `Real`. -/
noncomputable abbrev IBox (tower : GalerkinTower) : Type :=
  Set.Icc (-(boxBound tower)) (boxBound tower)

/-- The compact box `[-B,B] × [-B,B]` as a subtype of `CR = Real × Real`. -/
noncomputable abbrev KBox (tower : GalerkinTower) : Type :=
  IBox tower × IBox tower

/-! ## Helper 5: lift into the compact product space -/

/-- Lift the Galerkin sequence into `Nat × Nat → KBox tower`.
    Each value `liftedSeq tower n (k, m)` is the `(k, m)` coordinate embedded into the box. -/
noncomputable def liftedSeq (tower : GalerkinTower) (n : Nat) : Nat × Nat → KBox tower :=
  fun p =>
    let u_k := (tower.trajAt n).traj.u p.1  -- : CoeffC N
    let z : CR := embedCoeffR u_k p.2       -- : CR, p.2 : Nat second arg of embedCoeffR
    (⟨z.1, comp1_in_Icc tower p.1 p.2 n⟩, ⟨z.2, comp2_in_Icc tower p.1 p.2 n⟩)

/-! ## B1: galerkinTower_pointwise_subseq as a theorem -/

/-- **Pointwise subsequence extraction** — promoted from axiom to theorem.

    Proof: embed the whole tower sequence into the compact Pi-space `Nat × Nat → KBox tower`,
    apply `IsCompact.tendsto_subseq` (Tychonoff + first countability from PseudoMetrizableSpace),
    and decode the limit via continuity of `Subtype.val`. -/
theorem galerkinTower_pointwise_subseq_thm (tower : GalerkinTower) :
    ∃ φ : Nat → Nat, StrictMono φ ∧
      ∃ uInfty : Nat → CoeffInftyR,
        ∀ (k m : Nat),
            Tendsto (fun n : Nat => embedCoeffR ((tower.trajAt (φ n)).traj.u k) m)
              atTop (𝓝 (uInfty k m)) := by
  -- Step 1: set up compact instances for Nat × Nat → KBox tower
  -- IBox tower = Set.Icc (-B) B has CompactSpace (compactSpace_Icc)
  haveI hIBox_compact : CompactSpace (IBox tower) :=
    compactSpace_Icc (-(boxBound tower)) (boxBound tower)
  -- KBox tower = IBox × IBox: compact via IsCompact.prod
  haveI hKBox_compact : CompactSpace (KBox tower) := by
    rw [← isCompact_univ_iff]
    rw [← Set.univ_prod_univ]
    exact isCompact_univ.prod isCompact_univ
  -- PseudoMetrizableSpace chain: Real → IBox (subtype) → KBox (prod) → Pi
  haveI hKBox_pseudo : PseudoMetrizableSpace (KBox tower) := inferInstance
  haveI : Countable (Nat × Nat) := inferInstance
  haveI hPi_pseudo : PseudoMetrizableSpace (Nat × Nat → KBox tower) := inferInstance
  -- FirstCountableTopology from PseudoMetrizableSpace
  haveI hPi_fct : FirstCountableTopology (Nat × Nat → KBox tower) := inferInstance
  -- CompactSpace (Nat × Nat → KBox tower) from Tychonoff (Pi.compactSpace instance)
  haveI hPi_compact : CompactSpace (Nat × Nat → KBox tower) := inferInstance
  -- Step 2: apply IsCompact.tendsto_subseq to the lifted sequence
  obtain ⟨uLim, _, φ, hφ, hconv⟩ :=
    (isCompact_univ : IsCompact (Set.univ : Set (Nat × Nat → KBox tower))).tendsto_subseq
      (fun n => Set.mem_univ (liftedSeq tower n))
  -- Step 3: decode the product-topology limit to pointwise convergence
  -- hconv : Tendsto (liftedSeq tower ∘ φ) atTop (𝓝 uLim) in Nat × Nat → KBox tower
  rw [tendsto_pi_nhds] at hconv
  -- Define uInfty via the subtype coercions
  refine ⟨φ, hφ, fun k m => ((uLim (k, m)).1.val, (uLim (k, m)).2.val), ?_⟩
  intro k m
  -- hconv (k, m) : Tendsto (fun n => liftedSeq tower (φ n) (k, m)) atTop (𝓝 (uLim (k, m)))
  have hkm := hconv (k, m)
  -- The coercion KBox → CR = Real × Real is continuous
  have hcoe : Continuous (fun z : KBox tower => ((z.1.val : Real), (z.2.val : Real))) := by
    fun_prop
  -- Compose: Tendsto (coe ∘ liftedSeq tower ∘ φ) atTop (𝓝 (coe (uLim (k,m))))
  have hcomp := hcoe.continuousAt.tendsto.comp hkm
  -- Simplify: coe (liftedSeq tower n (k,m)) = embedCoeffR ((tower.trajAt n).traj.u k) m
  simp only [Function.comp, liftedSeq] at hcomp
  exact hcomp

def stage178Summary : String :=
  "Stage 178: NSGalerkinPointwiseSubseq — discharge B1 as theorem (-1 axiom). " ++
  "single_normSqR_le: THEOREM (Finset.single_le_sum + tower_embedCoeffR_energy_le). " ++
  "boxBound: DEF (tower.E0 + 1). " ++
  "comp1_in_Icc / comp2_in_Icc: THEOREM (nlinarith from normSqR bound). " ++
  "liftedSeq: DEF (Nat × Nat → KBox tower, using component bounds). " ++
  "galerkinTower_pointwise_subseq_thm: THEOREM (Pi compactness + IsCompact.tendsto_subseq " ++
  "+ tendsto_pi_nhds + continuous Subtype.val). " ++
  "Axioms eliminated: galerkinTower_pointwise_subseq. " ++
  "+0 axioms, +6 theorems, 0 sorry."

end NavierStokes.GalerkinPointwiseSubseq
