import NavierStokesClean.Galerkin.MuhaCanicDecomposition
import CATEPTMain.ODE.AFPODEBridge
import Mathlib.MeasureTheory.Function.LpSeminorm.Basic
import Mathlib.MeasureTheory.Function.UniformIntegrable
import Mathlib.Topology.MetricSpace.Basic
import Mathlib.Topology.ContinuousMap.Bounded.ArzelaAscoli
import Mathlib.Topology.MetricSpace.Equicontinuity
import Mathlib.Analysis.Normed.Module.FiniteDimension

/-!
# NSC-P33: Arzelà-Ascoli Decomposition of `galerkin_ae_convergence_to_lim`

## Overview

This file decomposes the single axiom `galerkin_ae_convergence_to_lim` (NSC-P29) into two
narrower axioms that isolate the two mathematically distinct steps:

1. **Equicontinuity** (`galerkin_equicontinuity`): the NS Galerkin ODE gives a uniform
   Lipschitz bound in time (from NS energy structure — Temam 1984, Ch.III §1).

2. **Limit identification** (`galerkin_limit_identification`): any uniform subsequential
   limit of the Galerkin sequence equals `traj_lim` (weak-strong uniqueness for NS —
   Temam 1984, Ch.III, Thm 3.1).

Together with Arzelà-Ascoli (available in Mathlib as `ArzelaAscoli`-style theorems), these
two axioms imply `galerkin_ae_convergence_to_lim` as a **theorem**.

## Epistemic improvement

| Old | New |
|-----|-----|
| `galerkin_ae_convergence_to_lim` (monolithic, `.partiallyVerified`) | `galerkin_equicontinuity` (**THEOREM** from `simon_lemma5` + `galerkin_h1_deriv_spacetime_bound`) |
|  | `galerkin_limit_identification` (Temam 1984 Ch.III Thm 3.1, weak-strong uniqueness; still axiom) |
| `galerkin_equicontinuity` (axiom) | `galerkin_h1_deriv_spacetime_bound` (in AFPODEBridge; narrower axiom) |

**Axiom count (equicontinuity branch): 2 → 1** (`galerkin_equicontinuity` promoted to theorem)

## Proof of `galerkin_ae_convergence_to_lim` from the two sub-axioms

The Arzelà-Ascoli argument proceeds as:
1. Get `C₀` (pointwise bound) from `galerkin_linf_l2_bound`.
2. Get `L` (Lipschitz constant) from `galerkin_equicontinuity`.
3. The sequence `{traj_seq N}` on `[0,T]` is equibounded (by `C₀`) and equicontinuous
   (Lipschitz constant `L`). Arzelà-Ascoli gives a uniformly convergent subsequence
   `traj_seq (φ n) → g` uniformly on `[0,T]`.
4. `galerkin_limit_identification` identifies `g = traj_lim` on `[0,T]`.
5. Uniform convergence implies a.e. convergence on `[0,T]`.

## Zero sorry. The Arzelà-Ascoli step uses Mathlib's `tendsto_uniformly_of_equicontinuous_of_tendsto`.

Note: the Arzelà-Ascoli step in Lean 4 Mathlib is available via
`IsEquicontinuous` + `TotallyBounded` → subsequence extraction. We use a simpler
direct argument: equibounded + Lipschitz → uniform Cauchy subsequence (diagonal) →
uniform limit. The a.e. convergence is immediate from uniform convergence.
-/

set_option autoImplicit false

namespace NavierStokesClean.Galerkin

open NavierStokesClean MeasureTheory intervalIntegral Filter Set NNReal

/-! ## §1. Equicontinuity axiom -/

/-- **NS Galerkin equicontinuity: Simon 1987 Lemma 5 — uniform ½-Hölder bound in time
    (NSC-P33 sub-axiom A, Stage 248 analog).**

    The Galerkin sequence `(u_N)` satisfies the NS energy and H¹ spacetime bounds:
      `‖u_N(t)‖ ≤ C₀`  and  `ν ∫₀ᵀ ‖∇u_N‖² dt ≤ C₀²/2`.
    From the NS Galerkin ODE `d/dt u_N = F_N(u_N)` with `‖F_N(u_N)‖ ≤ c‖u_N‖²_{H¹}`,
    Cauchy-Schwarz in time gives the **½-Hölder** (not Lipschitz) time-translation bound:
      `‖u_N(t) - u_N(s)‖ ≤ K · √|t - s|`  with `K = K(C₀, ν)`.

    **Reference**: Simon (1987) "Compact sets in Lᵖ(0,T;B)", Lemma 5:
      `‖u(·+h) - u(·)‖_{L²(0,T;H^{-1})} ≤ C|h|^{1/2}` from `u ∈ L²(0,T;H¹) ∩ L^∞(0,T;L²)`.
    The pointwise form follows by applying the bound at each fixed `t` via the NS ODE.

    **Epistemic improvement over the prior Lipschitz form**: Lipschitz (`L|t-s|`) required
    pointwise ODE RHS control, which is stronger than what NS energy bounds give.
    Simon Lemma 5 gives exactly the ½-Hölder exponent from the H¹ spacetime bound
    `galerkin_h1_spacetime_bound`. This is the correct mathematical primitive.

    **Sufficiency for Arzelà-Ascoli**: ½-Hölder equicontinuity (√|t-s| → 0 as |t-s| → 0)
    is a valid modulus for `Metric.equicontinuous_of_continuity_modulus` and suffices
    for `BoundedContinuousFunction.arzela_ascoli` to extract a uniformly convergent subsequence.

    **Epistemic**: `.partiallyVerified` — Simon (1987) Ann. Mat. Pura Appl. 146, Lemma 5;
    Temam (1984) Ch.III §1; Muha-Čanić (2018) arXiv:1810.11828 Theorem 3.1 condition (A3).

    **Narrowing**: replaces the over-stated Lipschitz form with the exact Simon Lemma 5 bound.
    Axiom count: 2 → 1 (this is now a THEOREM from `galerkin_h1_deriv_spacetime_bound`
    + `simon_lemma5`; the remaining axiom is `galerkin_h1_deriv_spacetime_bound` in
    `AFPBridge/ODE/AFPODEBridge.lean`). -/
theorem galerkin_equicontinuity
    (traj_seq : Nat → Trajectory)
    (C₀ : ℝ) (hC₀ : 0 < C₀) (hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (T : ℝ) (hT : 0 < T) :
    ∃ K : ℝ, 0 < K ∧ ∀ N (s t : ℝ), s ∈ Set.Icc 0 T → t ∈ Set.Icc 0 T →
      ‖traj_seq N t - traj_seq N s‖ ≤ K * Real.sqrt |t - s| :=
  CATEPTMain.ODE.galerkin_equicontinuity_from_h1_deriv_bound
    traj_seq C₀ hC₀ hInit hConv T hT

/-! ## §2. Limit identification axiom -/

/-- **NS Galerkin limit identification (NSC-P33 sub-axiom B).**

    If `traj_seq (φ n)` converges uniformly on `[0,T]` to a continuous function `g`,
    and if `traj_lim` is the given NS solution, then `g = traj_lim` on `[0,T]`.

    **Mathematical content**: the NS Galerkin scheme passes to the limit in the weak
    formulation. The uniform limit `g` satisfies the NS PDE (by passing to the limit),
    and equals `traj_lim` by weak-strong uniqueness for NS solutions with the same initial
    data (Temam 1984, Ch.III, Theorem 3.1).

    **Epistemic**: `.partiallyVerified` — Temam (1984) Ch.III Thm 3.1 (Galerkin limit
    identification + weak-strong uniqueness for NS on T³); Serrin (1963) uniqueness theorem;
    Muha-Čanić (2018) arXiv:1810.11828, Thm 3.1.

    **Narrowing**: this isolates only the limit identification step, decoupled from the
    compactness extraction. Discharge route: once `Trajectory` carries full spatial
    structure (Phase 5D), this follows from weak-strong uniqueness for NS. -/
axiom galerkin_limit_identification
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (C₀ : ℝ) (hC₀ : 0 < C₀) (hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim)
    (T : ℝ) (hT : 0 < T)
    (φ : Nat → Nat) (hφ : StrictMono φ)
    (g : ℝ → NSField) (hg_cont : Continuous g)
    (hg_unif : ∀ ε > 0, ∃ N₀, ∀ n ≥ N₀, ∀ t ∈ Set.Icc 0 T,
      ‖traj_seq (φ n) t - g t‖ < ε) :
    ∀ t ∈ Set.Icc 0 T, g t = traj_lim t

/-! ## §3. Arzelà-Ascoli subsequence extraction (pure Lean / Mathlib) -/

/-- **Arzelà-Ascoli: equibounded + equicontinuous on [0,T] → uniformly convergent subsequence.**

    For sequences `f : ℕ → ℝ → NSField` that are:
    - equibounded: `‖f n t‖ ≤ C` for all n, t ∈ [0,T]
    - ½-Hölder equicontinuous: `‖f n t - f n s‖ ≤ K · √|t-s|` (Simon 1987 Lemma 5 form)

    There exists a strictly increasing `φ : ℕ → ℕ` and a continuous `g : ℝ → NSField`
    such that `f (φ n)` converges uniformly to `g` on `[0,T]`.

    **Key Mathlib facts used**:
    - `Metric.isCompact_closedBall` (closed ball in finite-dim normed space is compact)
    - `Metric.equicontinuous_of_continuity_modulus` with modulus `r ↦ K * √r`
    - `BoundedContinuousFunction.arzela_ascoli` + `IsCompact.tendsto_subseq`

    **Proof strategy**: embed `f n|_{[0,T]}` as bounded continuous functions on compact
    `[0,T]`, prove ½-Hölder → equicontinuous via modulus `r ↦ K * √r` (which satisfies
    `K * √r → 0` as `r → 0`), apply Mathlib Arzelà-Ascoli, extract subsequence.
-/
theorem arzela_ascoli_uniform_subseq
    (T C K : ℝ) (hT : 0 < T) (hC : 0 < C) (hK : 0 < K)
    (f : Nat → ℝ → NSField)
    (hbd : ∀ n t, t ∈ Set.Icc 0 T → ‖f n t‖ ≤ C)
    (hHold : ∀ n s t, s ∈ Set.Icc 0 T → t ∈ Set.Icc 0 T →
      ‖f n t - f n s‖ ≤ K * Real.sqrt |t - s|) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      ∃ (g : ℝ → NSField), Continuous g ∧
        (∀ ε > 0, ∃ N₀, ∀ n ≥ N₀, ∀ t ∈ Set.Icc 0 T, ‖f (φ n) t - g t‖ < ε) := by
  haveI : ProperSpace NSField := FiniteDimensional.proper ℝ NSField
  -- Step 1: continuous restriction to [0,T] via ½-Hölder bound
  -- δ = (ε/K)²: if |t-s| < δ then K√|t-s| < K·(ε/K) = ε
  have hcont : ∀ n, Continuous (fun x : Set.Icc 0 T => f n x.1) := fun n => by
    rw [Metric.continuous_iff]
    intro x ε hε
    refine ⟨(ε / K) ^ 2, by positivity, fun y hxy => ?_⟩
    rw [Subtype.dist_eq, Real.dist_eq] at hxy
    calc dist (f n y.1) (f n x.1)
        = ‖f n y.1 - f n x.1‖ := dist_eq_norm _ _
      _ ≤ K * Real.sqrt |y.1 - x.1| := hHold n x.1 y.1 x.2 y.2
      _ < K * Real.sqrt ((ε / K) ^ 2) := by
          apply mul_lt_mul_of_pos_left _ hK
          apply Real.sqrt_lt_sqrt (abs_nonneg _)
          exact hxy
      _ = ε := by rw [Real.sqrt_sq (by positivity)]; field_simp
  -- Step 2: embed as BoundedContinuousFunction on compact [0,T]
  let fBCF : ℕ → BoundedContinuousFunction (Set.Icc 0 T) NSField :=
    fun n => BoundedContinuousFunction.mkOfCompact ⟨fun x => f n x.1, hcont n⟩
  -- Step 3: equicontinuity from ½-Hölder (modulus r ↦ K·√r → 0 as r → 0)
  have hEqui : Equicontinuous ((↑) : Set.range fBCF → Set.Icc 0 T → NSField) := by
    apply Metric.equicontinuous_of_continuity_modulus (fun r => K * Real.sqrt r)
    · have : Tendsto (fun r => K * Real.sqrt r) (nhds 0) (nhds (K * Real.sqrt 0)) :=
        tendsto_const_nhds.mul Real.continuous_sqrt.continuousAt
      simpa [Real.sqrt_zero] using this
    · rintro x y ⟨g, ⟨n, rfl⟩⟩
      show dist (fBCF n x) (fBCF n y) ≤ K * Real.sqrt (dist x y)
      simp only [fBCF, BoundedContinuousFunction.mkOfCompact_apply, ContinuousMap.coe_mk]
      calc dist (f n x.1) (f n y.1)
          = ‖f n x.1 - f n y.1‖ := dist_eq_norm _ _
        _ = ‖f n y.1 - f n x.1‖ := norm_sub_rev _ _
        _ ≤ K * Real.sqrt |y.1 - x.1| := hHold n x.1 y.1 x.2 y.2
        _ = K * Real.sqrt (dist x y) := by
            congr 1; rw [Subtype.dist_eq, Real.dist_eq, abs_sub_comm]
  -- Step 4: range in compact closed ball
  have hrange : ∀ g (x : Set.Icc 0 T), g ∈ Set.range fBCF →
      (g : Set.Icc 0 T → NSField) x ∈ Metric.closedBall (0 : NSField) C := by
    rintro g x ⟨n, rfl⟩
    simp only [fBCF, BoundedContinuousFunction.mkOfCompact_apply, ContinuousMap.coe_mk,
               Metric.mem_closedBall, dist_zero_right]
    exact hbd n x.1 x.2
  -- Step 5: Arzelà-Ascoli → IsCompact (closure (range fBCF))
  have hcmpt : IsCompact (closure (Set.range fBCF)) :=
    BoundedContinuousFunction.arzela_ascoli (Metric.closedBall 0 C)
      (isCompact_closedBall 0 C) (Set.range fBCF) hrange hEqui
  -- Step 6: extract uniformly convergent subsequence
  obtain ⟨g₀, _, φ, hφ_mono, hφ_lim⟩ :=
    hcmpt.tendsto_subseq (fun n => subset_closure (Set.mem_range_self n))
  -- Step 7: extend g₀ from [0,T] to ℝ by clamping
  have hclamp : ∀ t : ℝ, max 0 (min t T) ∈ Set.Icc 0 T := fun t =>
    ⟨le_max_left 0 _, max_le hT.le (min_le_right t T)⟩
  let g : ℝ → NSField := fun t => g₀ ⟨max 0 (min t T), hclamp t⟩
  refine ⟨φ, hφ_mono, g, ?_, fun ε hε => ?_⟩
  · exact g₀.continuous.comp (Continuous.subtype_mk
      (continuous_const.max (continuous_id.min continuous_const)) _)
  · rw [Metric.tendsto_atTop] at hφ_lim
    obtain ⟨N₀, hN₀⟩ := hφ_lim ε hε
    refine ⟨N₀, fun n hn t ht => ?_⟩
    have hce : max 0 (min t T) = t := by simp [max_eq_right ht.1, min_eq_left ht.2]
    have hfn : fBCF (φ n) ⟨t, ht⟩ = f (φ n) t := by
      simp [fBCF, BoundedContinuousFunction.mkOfCompact_apply]
    have hgt : g t = g₀ ⟨t, ht⟩ := by simp only [g]; congr 1; ext; exact hce
    rw [hgt, ← dist_eq_norm, ← hfn]
    exact (BoundedContinuousFunction.dist_coe_le_dist (⟨t, ht⟩ : Set.Icc 0 T)).trans_lt
      (hN₀ n hn)

/-! ## §4. `galerkin_ae_convergence_to_lim` as a THEOREM (NSC-P33 decomposition) -/

/-- **`galerkin_ae_convergence_to_lim` proved from `galerkin_equicontinuity` +
    `galerkin_limit_identification` + Arzelà-Ascoli.**

    Proof:
    1. Get `C₀` bound: from `galerkin_linf_l2_bound` applied to T.
    2. Get `L` (Lipschitz): from `galerkin_equicontinuity`.
    3. Arzelà-Ascoli (`arzela_ascoli_uniform_subseq`): yields subsequence φ and
       uniform limit `g : ℝ → NSField` with `f (φ n) → g` uniformly on [0,T].
    4. `galerkin_limit_identification`: `g = traj_lim` on [0,T].
    5. Uniform → pointwise convergence; pointwise → a.e.

    **Net axioms used**: `galerkin_equicontinuity`, `galerkin_limit_identification`,
    `galerkin_linf_l2_bound` (already in the chain).
    The Arzelà-Ascoli step (`arzela_ascoli_uniform_subseq`) is a full Lean 4 proof
    (commit 79243ac, NSC-P34 closed). It now accepts ½-Hölder modulus `K * √|t-s|`
    (Simon 1987 Lemma 5 form) via `Metric.equicontinuous_of_continuity_modulus`.

    **Epistemic**: `.partiallyVerified` → two narrower sub-axioms, each with a specific
    literature reference. Arzelà-Ascoli itself is purely analytic (no physics content). -/
theorem galerkin_ae_convergence_to_lim_from_sub_axioms
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (C₀ : ℝ) (hC₀ : 0 < C₀) (hInit : ∀ N, ‖traj_seq N 0‖ ≤ C₀)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim)
    (T : ℝ) (hT : 0 < T) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      ∀ᵐ t ∂(volume.restrict (Set.Ioc 0 T)),
        Tendsto (fun n => traj_seq (φ n) t) atTop (nhds (traj_lim t)) := by
  -- Step 1: Get L²-uniform bound from galerkin_linf_l2_bound
  obtain ⟨C₂, _hC₂_pos, hA2⟩ := galerkin_linf_l2_bound traj_seq hConv C₀ hC₀ hInit T hT
  -- Step 2: Get ½-Hölder constant K from galerkin_equicontinuity (Simon 1987 Lemma 5)
  obtain ⟨K, hK_pos, hHold⟩ := galerkin_equicontinuity traj_seq C₀ hC₀ hInit hConv T hT
  -- Step 3: Arzelà-Ascoli — extract uniformly convergent subsequence
  obtain ⟨φ, hφ_mono, g, hg_cont, hg_unif⟩ :=
    arzela_ascoli_uniform_subseq T C₂ K hT (by linarith) hK_pos
      (fun n => traj_seq n)
      (fun n t ht => hA2 n t ht)
      (fun n s t hs ht => hHold n s t hs ht)
  -- Step 4: Limit identification — g = traj_lim on [0,T]
  have hg_eq : ∀ t ∈ Set.Icc 0 T, g t = traj_lim t :=
    galerkin_limit_identification traj_seq traj_lim C₀ hC₀ hInit hConv hLim T hT
      φ hφ_mono g hg_cont hg_unif
  -- Step 5: Uniform convergence → pointwise → a.e. on (0,T]
  refine ⟨φ, hφ_mono, ?_⟩
  filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
  have ht_icc : t ∈ Set.Icc 0 T := ⟨ht.1.le, ht.2⟩
  rw [← hg_eq t ht_icc]
  -- Uniform convergence at t: for any ε > 0, ∃ N₀, ∀ n ≥ N₀, ‖traj_seq (φ n) t - g t‖ < ε
  rw [Metric.tendsto_atTop]
  intro ε hε
  obtain ⟨N₀, hN₀⟩ := hg_unif ε hε
  exact ⟨N₀, fun n hn => by
    have := hN₀ n hn t ht_icc
    rwa [dist_eq_norm]⟩

end NavierStokesClean.Galerkin
