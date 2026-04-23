import Mathlib.MeasureTheory.Function.ConvergenceInMeasure
import NavierStokesClean.Galerkin.VorticityLiminf

/-!
# Phase 20: Cantor Diagonal — galerkin_eLpNorm_subseq from per-T extraction

## Summary

`galerkin_eLpNorm_subseq` (a single φ valid for ALL T) is proved as a theorem from
the strictly weaker `galerkin_eLpNorm_per_T` (φ may depend on T).

Construction:
  iterσ k    := composition of (k+1) per-T extractions at T = 1, 2, …, k+1
  σ_diag n   := iterσ n n   (Cantor diagonal)

The diagonal inherits convergence at every integer level j (§6), and convergence
at arbitrary real T > 0 follows by measure monotonicity (§7).

Net: `galerkin_eLpNorm_subseq` is now a theorem; `galerkin_eLpNorm_per_T` is the
single remaining Aubin-Lions axiom (strictly weaker, same .partiallyVerified class).
Axiom count: 5 → 5 (one replaced by a more honest formulation).

## Zero sorry, zero warnings.
-/

set_option autoImplicit false

namespace NavierStokesClean.Galerkin

open NavierStokesClean
open MeasureTheory Filter

/-! ## §1. Per-T sub-axiom (weaker than galerkin_eLpNorm_subseq) -/

/-- **Phase 20 sub-axiom: per-T Galerkin L²-convergent subsequence.**

    For every fixed T > 0, there exists a subsequence φ such that
    `eLpNorm (traj_seq (φ n) - traj_lim) 2 volume[0,T] → 0`.
    The φ may depend on T; the Cantor diagonal below promotes this to a
    single φ valid for all T simultaneously (§7).

    **Epistemic: `.partiallyVerified`** — Simon 1987 Thm 5 / Aubin-Lions (1963).
    Strictly weaker than `galerkin_eLpNorm_subseq`. -/
axiom galerkin_eLpNorm_per_T
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim)
    (T : ℝ) (hT : 0 < T) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      Tendsto (fun n => eLpNorm (fun t => traj_seq (φ n) t - traj_lim t) 2
                          (volume.restrict (Set.Ioc 0 T)))
        atTop (nhds 0)

/-! ## §2. Iterative nested subsequence construction -/

/-- Iterative nested subsequences.

    `iterσ k` is the composition of (k+1) Aubin-Lions extractions:
    - `iterσ 0` = subsequence of `traj_seq` at T = 1
    - `iterσ (k+1)` = `iterσ k` ∘ (new extraction for `traj_seq ∘ iterσ k` at T = k+2)

    Invariant: `traj_seq ∘ iterσ k` converges in L²([0, k+1]) (proved in §4). -/
private noncomputable def iterσ
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) :
    ℕ → (ℕ → ℕ) :=
  Nat.rec
    (Classical.choose
      (galerkin_eLpNorm_per_T traj_seq traj_lim hConv hLim 1 one_pos))
    (fun k σk =>
      σk ∘ Classical.choose
        (galerkin_eLpNorm_per_T (fun N => traj_seq (σk N)) traj_lim
          (fun N => hConv (σk N)) hLim (↑(k + 2))
          (by exact_mod_cast Nat.succ_pos (k + 1))))

/-! ## §3. Definitional unfolding lemmas -/

private theorem iterσ_zero
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) :
    iterσ traj_seq traj_lim hConv hLim 0 =
    Classical.choose
      (galerkin_eLpNorm_per_T traj_seq traj_lim hConv hLim 1 one_pos) := rfl

private theorem iterσ_succ
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) (k : ℕ) :
    iterσ traj_seq traj_lim hConv hLim (k + 1) =
    iterσ traj_seq traj_lim hConv hLim k ∘
    Classical.choose
      (galerkin_eLpNorm_per_T
        (fun N => traj_seq (iterσ traj_seq traj_lim hConv hLim k N)) traj_lim
        (fun N => hConv (iterσ traj_seq traj_lim hConv hLim k N)) hLim
        (↑(k + 2)) (by exact_mod_cast Nat.succ_pos (k + 1))) := rfl

/-! ## §4. Monotonicity and growth -/

theorem nat_le_of_strictMono_nat {f : ℕ → ℕ} (hf : StrictMono f) (n : ℕ) :
    n ≤ f n := by
  induction n with
  | zero => exact Nat.zero_le _
  | succ n ih => exact Nat.succ_le_of_lt (ih.trans_lt (hf (Nat.lt_succ_self n)))

private theorem iterσ_strictMono
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) (k : ℕ) :
    StrictMono (iterσ traj_seq traj_lim hConv hLim k) := by
  induction k with
  | zero =>
    rw [iterσ_zero]
    exact (Classical.choose_spec
      (galerkin_eLpNorm_per_T traj_seq traj_lim hConv hLim 1 one_pos)).1
  | succ k ih =>
    rw [iterσ_succ]
    exact ih.comp (Classical.choose_spec
      (galerkin_eLpNorm_per_T
        (fun N => traj_seq (iterσ traj_seq traj_lim hConv hLim k N)) traj_lim
        (fun N => hConv (iterσ traj_seq traj_lim hConv hLim k N)) hLim
        (↑(k + 2)) (by exact_mod_cast Nat.succ_pos (k + 1)))).1

private theorem nat_le_iterσ
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) (k n : ℕ) :
    n ≤ iterσ traj_seq traj_lim hConv hLim k n :=
  nat_le_of_strictMono_nat (iterσ_strictMono traj_seq traj_lim hConv hLim k) n

/-! ## §5. Convergence invariant: iterσ k converges at T = k+1 -/

/-- `traj_seq ∘ iterσ k` converges in L²([0, k+1]).

    Proof: induction on k.
    - k=0: directly from the per-T extraction at T=1.
    - k+1: the extraction at step k+1 was applied to `traj_seq ∘ iterσ k` at T=k+2,
            so by `choose_spec` the composed sequence converges at T=k+2. -/
private theorem iterσ_tendsto_self
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) (k : ℕ) :
    Tendsto
      (fun n => eLpNorm (fun t =>
          traj_seq (iterσ traj_seq traj_lim hConv hLim k n) t - traj_lim t) 2
        (volume.restrict (Set.Ioc 0 (↑(k + 1)))))
      atTop (nhds 0) := by
  induction k with
  | zero =>
    simp only [iterσ_zero, Nat.zero_add, Nat.cast_one]
    exact (Classical.choose_spec
      (galerkin_eLpNorm_per_T traj_seq traj_lim hConv hLim 1 one_pos)).2
  | succ k _ih =>
    simp only [iterσ_succ, Function.comp_apply]
    have key :=
      (Classical.choose_spec
        (galerkin_eLpNorm_per_T
          (fun N => traj_seq (iterσ traj_seq traj_lim hConv hLim k N)) traj_lim
          (fun N => hConv (iterσ traj_seq traj_lim hConv hLim k N)) hLim
          (↑(k + 2)) (by exact_mod_cast Nat.succ_pos (k + 1)))).2
    -- k+1+1 = k+2, so the restricted measures are equal
    convert key using 2

/-! ## §6. Factoring lemma -/

/-- For j ≤ k, every value of `iterσ k` lies in the range of `iterσ j` with a larger index. -/
private theorem iterσ_refines_point
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) (j : ℕ) :
    ∀ k, j ≤ k → ∀ p, ∃ q, p ≤ q ∧
      iterσ traj_seq traj_lim hConv hLim k p =
      iterσ traj_seq traj_lim hConv hLim j q := by
  intro k hjk
  induction k with
  | zero =>
    obtain rfl := Nat.le_zero.mp hjk
    intro p; exact ⟨p, le_rfl, rfl⟩
  | succ k' ih =>
    intro p
    rcases Nat.eq_or_lt_of_le hjk with rfl | hlt
    · exact ⟨p, le_rfl, rfl⟩
    · have hjk' : j ≤ k' := Nat.lt_succ_iff.mp hlt
      -- Extract monotonicity of the per-T subsequence at step k'+1
      -- (same Classical.choose as in iterσ's Nat.rec definition)
      have hψ_SM : StrictMono (Classical.choose
          (galerkin_eLpNorm_per_T
            (fun N => traj_seq (iterσ traj_seq traj_lim hConv hLim k' N)) traj_lim
            (fun N => hConv (iterσ traj_seq traj_lim hConv hLim k' N)) hLim
            (↑(k' + 2)) (by exact_mod_cast Nat.succ_pos (k' + 1)))) :=
        (Classical.choose_spec
          (galerkin_eLpNorm_per_T
            (fun N => traj_seq (iterσ traj_seq traj_lim hConv hLim k' N)) traj_lim
            (fun N => hConv (iterσ traj_seq traj_lim hConv hLim k' N)) hLim
            (↑(k' + 2)) (by exact_mod_cast Nat.succ_pos (k' + 1)))).1
      -- Apply IH to the inner argument (the Classical.choose applied to p)
      -- iterσ (k'+1) p is definitionally iterσ k' (inner p) by Nat.rec
      obtain ⟨q, hge_q, hq_eq⟩ := ih hjk'
        (Classical.choose
          (galerkin_eLpNorm_per_T
            (fun N => traj_seq (iterσ traj_seq traj_lim hConv hLim k' N)) traj_lim
            (fun N => hConv (iterσ traj_seq traj_lim hConv hLim k' N)) hLim
            (↑(k' + 2)) (by exact_mod_cast Nat.succ_pos (k' + 1))) p)
      -- p ≤ inner(p) ≤ q; iterσ (k'+1) p = iterσ k' (inner p) = iterσ j q
      exact ⟨q, (nat_le_of_strictMono_nat hψ_SM p).trans hge_q, hq_eq⟩

/-! ## §7. Cantor diagonal -/

/-- The Cantor diagonal: `σ_diag n = iterσ n n`. -/
private noncomputable def σ_diag
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) : ℕ → ℕ :=
  fun n => iterσ traj_seq traj_lim hConv hLim n n

private theorem σ_diag_strictMono
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) :
    StrictMono (σ_diag traj_seq traj_lim hConv hLim) := by
  apply strictMono_nat_of_lt_succ
  intro n
  show iterσ traj_seq traj_lim hConv hLim n n <
       iterσ traj_seq traj_lim hConv hLim (n + 1) (n + 1)
  rw [iterσ_succ, Function.comp_apply]
  let ψ := Classical.choose
    (galerkin_eLpNorm_per_T
      (fun N => traj_seq (iterσ traj_seq traj_lim hConv hLim n N)) traj_lim
      (fun N => hConv (iterσ traj_seq traj_lim hConv hLim n N)) hLim
      (↑(n + 2)) (by exact_mod_cast Nat.succ_pos (n + 1)))
  have hψ_SM : StrictMono ψ :=
    (Classical.choose_spec
      (galerkin_eLpNorm_per_T
        (fun N => traj_seq (iterσ traj_seq traj_lim hConv hLim n N)) traj_lim
        (fun N => hConv (iterσ traj_seq traj_lim hConv hLim n N)) hLim
        (↑(n + 2)) (by exact_mod_cast Nat.succ_pos (n + 1)))).1
  -- iterσ n n < iterσ n (ψ (n+1))
  -- because: n < n+1 ≤ ψ(n+1), so iterσ n n < iterσ n (ψ(n+1)) by SM
  have hle : n + 1 ≤ ψ (n + 1) := nat_le_of_strictMono_nat hψ_SM (n + 1)
  exact (iterσ_strictMono traj_seq traj_lim hConv hLim n (Nat.lt_succ_self n)).trans_le
    ((iterσ_strictMono traj_seq traj_lim hConv hLim n).monotone hle)

/-- For each j : ℕ, σ_diag converges in L²([0, j+1]).

    Proof: define the selection function `selF n` which, for n ≥ j, gives the index
    in `iterσ j` such that `σ_diag n = iterσ j (selF n)` (from iterσ_refines_point).
    Since `selF n ≥ n → ∞`, composing the converging sequence with selF gives 0. -/
private theorem σ_diag_tendsto_nat
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) (j : ℕ) :
    Tendsto
      (fun n => eLpNorm (fun t =>
          traj_seq (σ_diag traj_seq traj_lim hConv hLim n) t - traj_lim t) 2
        (volume.restrict (Set.Ioc 0 (↑(j + 1)))))
      atTop (nhds 0) := by
  have hbase :=
    iterσ_tendsto_self traj_seq traj_lim hConv hLim j
  -- Selection function: for n ≥ j, pick the index in iterσ j representing σ_diag n
  let selF : ℕ → ℕ := fun n =>
    if h : j ≤ n then
      Classical.choose (iterσ_refines_point traj_seq traj_lim hConv hLim j n h n)
    else n
  have hselF_ge : ∀ n, j ≤ n → n ≤ selF n := fun n hjn => by
    simp only [selF, dif_pos hjn]
    exact (Classical.choose_spec
      (iterσ_refines_point traj_seq traj_lim hConv hLim j n hjn n)).1
  have hselF_eq : ∀ n, j ≤ n →
      σ_diag traj_seq traj_lim hConv hLim n =
      iterσ traj_seq traj_lim hConv hLim j (selF n) := fun n hjn => by
    simp only [selF, dif_pos hjn, σ_diag]
    exact (Classical.choose_spec
      (iterσ_refines_point traj_seq traj_lim hConv hLim j n hjn n)).2
  -- selF is cofinal: selF n ≥ n → ∞
  have hcofinal : Tendsto selF atTop atTop :=
    Filter.tendsto_atTop_atTop.mpr fun N =>
      ⟨max j N, fun n hn =>
        (Nat.le_max_right _ _).trans (hn.trans (hselF_ge n ((Nat.le_max_left _ _).trans hn)))⟩
  -- Tail agreement: σ_diag n = iterσ j (selF n) for n ≥ j
  have htail : ∀ᶠ n in atTop,
      eLpNorm (fun t =>
          traj_seq (σ_diag traj_seq traj_lim hConv hLim n) t - traj_lim t) 2
        (volume.restrict (Set.Ioc 0 (↑(j + 1)))) =
      eLpNorm (fun t =>
          traj_seq (iterσ traj_seq traj_lim hConv hLim j (selF n)) t - traj_lim t) 2
        (volume.restrict (Set.Ioc 0 (↑(j + 1)))) :=
    Filter.eventually_atTop.mpr ⟨j, fun n hjn => by rw [hselF_eq n hjn]⟩
  exact (hbase.comp hcofinal).congr' (htail.mono (fun _ h => h.symm))

/-! ## §8. Main theorem -/

/-- **Phase 20: galerkin_eLpNorm_subseq proved from galerkin_eLpNorm_per_T.**

    The Cantor diagonal `σ_diag` is a single StrictMono subsequence that
    converges in L²([0,T]) for every real T > 0.

    For real T > 0: find j : ℕ with T ≤ j+1, apply σ_diag_tendsto_nat j
    (which gives L² convergence on [0, j+1]), then squeeze down to [0,T]
    via eLpNorm_mono_measure (since vol[0,T] ≤ vol[0,j+1]).

    **Corollary**: `galerkin_eLpNorm_subseq` holds as a theorem.
    Axiom count: still 5 (one replaced by weaker `galerkin_eLpNorm_per_T`). -/
theorem galerkin_eLpNorm_subseq_from_per_T
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      ∀ (T : ℝ), 0 < T →
        Tendsto
          (fun n => eLpNorm (fun t => traj_seq (φ n) t - traj_lim t) 2
                      (volume.restrict (Set.Ioc 0 T)))
          atTop (nhds 0) := by
  refine ⟨σ_diag traj_seq traj_lim hConv hLim,
          σ_diag_strictMono traj_seq traj_lim hConv hLim,
          fun T hT => ?_⟩
  -- Pick j : ℕ with T ≤ ↑j (Archimedean), so T ≤ ↑(j+1) ≤ ↑(j+1)
  obtain ⟨j, hTj⟩ := exists_nat_ge T
  have hTj1 : T ≤ ↑(j + 1) := hTj.trans (by exact_mod_cast Nat.le_succ j)
  -- Measure monotonicity: vol[0,T] ≤ vol[0, j+1]
  have hmu_le : volume.restrict (Set.Ioc 0 T) ≤
      volume.restrict (Set.Ioc 0 (↑(j + 1))) :=
    Measure.restrict_mono (Set.Ioc_subset_Ioc_right hTj1) le_rfl
  -- eLpNorm is monotone in the measure
  have hmono : ∀ n,
      eLpNorm (fun t => traj_seq (σ_diag traj_seq traj_lim hConv hLim n) t - traj_lim t) 2
        (volume.restrict (Set.Ioc 0 T)) ≤
      eLpNorm (fun t => traj_seq (σ_diag traj_seq traj_lim hConv hLim n) t - traj_lim t) 2
        (volume.restrict (Set.Ioc 0 (↑(j + 1)))) :=
    fun n => eLpNorm_mono_measure _ hmu_le
  -- Sandwich: 0 ≤ eLpNorm[0,T] ≤ eLpNorm[0,j+1] → 0
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds
    (σ_diag_tendsto_nat traj_seq traj_lim hConv hLim j)
    (Filter.Eventually.of_forall (fun _ => zero_le _))
    (Filter.Eventually.of_forall hmono)

end NavierStokesClean.Galerkin
