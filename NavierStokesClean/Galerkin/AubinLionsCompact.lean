import Mathlib.MeasureTheory.Function.ConvergenceInMeasure
import NavierStokesClean.Galerkin.VorticityLiminf
import NavierStokesClean.Galerkin.CantorDiagonal

/-!
# Phase 17: Aubin-Lions Compactness — Mathlib-Backed Decomposition

## Goal

Decompose `simon1987_ae_tendsto_from_galerkin` into:

  (A) Mathlib-proved theorem: L² norm convergence on [0,T] → a.e. subsequence on [0,T]
      `ae_subseq_of_eLpNorm_tendsto_restrict`

  (B) Sub-axiom: the Galerkin sequence has an L²([0,T])-convergent subsequence
      `galerkin_eLpNorm_subseq` (.partiallyVerified — Simon 1987 / Aubin-Lions)

(A) + (B) → a.e. convergence on [0,T] (§3, PROVED).
Lifting to global `∀ᵐ t : ℝ` requires a Cantor diagonal — documented in §4.

## Mathlib chain for (A)

  `tendstoInMeasure_of_tendsto_eLpNorm` : eLpNorm (f n - g) 2 μ → 0  ⟹  TendstoInMeasure μ f atTop g
  `TendstoInMeasure.exists_seq_tendsto_ae` : TendstoInMeasure  ⟹  ∃ φ, ∀ᵐ t ∂μ, f (φ n) t → g t

## Zero sorry, zero warnings.
-/

set_option autoImplicit false

namespace NavierStokesClean.Galerkin

open NavierStokesClean
open MeasureTheory Filter

/-! ## §1. Mathlib theorem: L² convergence → a.e. subsequence (restricted measure) -/

/-- **Phase 17 (Mathlib): L² norm convergence → a.e. convergent subsequence.**

    For any measure `μ` and normed group `E`:
    if `eLpNorm (f n - g) 2 μ → 0` and `f n`, `g` are AE strongly measurable,
    then there is a subsequence φ such that `f (φ n) t → g t` for μ-a.e. t.

    **Proof** (two Mathlib lemmas):
    1. `tendstoInMeasure_of_tendsto_eLpNorm` (L² → convergence in measure)
    2. `TendstoInMeasure.exists_seq_tendsto_ae` (Borel-Cantelli: in-measure → a.e. subseq)

    0 new axioms. -/
theorem ae_subseq_of_eLpNorm_tendsto_restrict
    {α : Type*} [MeasurableSpace α] (μ : MeasureTheory.Measure α)
    {E : Type*} [NormedAddCommGroup E] [MeasurableSpace E] [BorelSpace E]
    (f : Nat → α → E) (g : α → E)
    (hf : ∀ n, AEStronglyMeasurable (f n) μ)
    (hg : AEStronglyMeasurable g μ)
    (hfg : Tendsto (fun n => eLpNorm (fun t => f n t - g t) 2 μ) atTop (nhds 0)) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      ∀ᵐ t ∂μ, Tendsto (fun n => f (φ n) t) atTop (nhds (g t)) := by
  have hInMeasure : TendstoInMeasure μ f atTop g :=
    tendstoInMeasure_of_tendsto_eLpNorm two_ne_zero hf hg hfg
  obtain ⟨φ, hMono, hae⟩ := hInMeasure.exists_seq_tendsto_ae
  exact ⟨φ, hMono, hae⟩

/-! ## §2. Theorem: Galerkin sequence has L²([0,T])-convergent subsequence (Phase 20) -/

/-- **Phase 20: galerkin_eLpNorm_subseq proved as a theorem (Cantor diagonal).**

    For any Galerkin sequence and limit trajectory (both NS solutions), there exists
    a subsequence φ such that `eLpNorm (traj_seq (φ n) - traj_lim) 2 volume[0,T] → 0`
    for each T > 0.

    **Phase 20**: proved from `galerkin_eLpNorm_per_T` (per-T extraction, strictly weaker)
    via the Cantor diagonal in `CantorDiagonal.lean`.  No longer an axiom.

    **NS content**: Aubin-Lions (1963) / Simon (1987) Thm 5.
    **Nikitaeva (2025)**, arXiv:2507.13356v1, Lemma B.9 + App A.2.1.

    **Epistemic: proved from `galerkin_eLpNorm_per_T` (.partiallyVerified)** -/
theorem galerkin_eLpNorm_subseq
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      ∀ (T : ℝ), 0 < T →
        Tendsto
          (fun n => eLpNorm (fun t => traj_seq (φ n) t - traj_lim t) 2
                      (volume.restrict (Set.Ioc 0 T)))
          atTop (nhds 0) :=
  galerkin_eLpNorm_subseq_from_per_T traj_seq traj_lim hConv hLim

/-! ## §3. Theorem: a.e. subseq on [0,T] from (A) + (B) -/

/-- **Phase 17: a.e. convergent subsequence on [0,T].**

    Combines `galerkin_eLpNorm_subseq` (§2) with `ae_subseq_of_eLpNorm_tendsto_restrict` (§1).

    The result is a double-subsequence `φ ∘ ψ` that converges a.e. on [0,T]. -/
theorem isGalerkinLimit_subseq_on_Ioc
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim)
    (T : ℝ) (hT : 0 < T) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      ∀ᵐ t ∂(volume.restrict (Set.Ioc 0 T)),
        Tendsto (fun n => traj_seq (φ n) t) atTop (nhds (traj_lim t)) := by
  obtain ⟨φ, hMono, hL2⟩ := galerkin_eLpNorm_subseq traj_seq traj_lim hConv hLim
  have hf : ∀ n, AEStronglyMeasurable (fun t => traj_seq (φ n) t)
      (volume.restrict (Set.Ioc 0 T)) :=
    fun n => (ns_traj_continuous (traj_seq (φ n)) (hConv (φ n))).aestronglyMeasurable
  have hg : AEStronglyMeasurable (fun t => traj_lim t)
      (volume.restrict (Set.Ioc 0 T)) :=
    (ns_traj_continuous traj_lim hLim).aestronglyMeasurable
  obtain ⟨ψ, hMonoψ, hae⟩ :=
    ae_subseq_of_eLpNorm_tendsto_restrict
      (volume.restrict (Set.Ioc 0 T))
      (fun n t => traj_seq (φ n) t) (fun t => traj_lim t)
      hf hg (hL2 T hT)
  exact ⟨φ ∘ ψ, hMono.comp hMonoψ, hae⟩

/-! ## §4. Phase 18: restricted Fatou chain — retire `simon1987_ae_tendsto_from_galerkin` -/

/-!
### Motivation

`bkm_limit_le_of_fatou_simon` (VorticityLiminf) uses `simon1987_ae_tendsto_from_galerkin`
to get a global `∀ᵐ t : ℝ` a.e. bound, then restricts it to [0,T] via `ae_restrict_of_ae`.

Phase 18 short-circuits this: since the BKM integral is only over [0,T], we only need
a.e. convergence on [0,T], which `isGalerkinLimit_subseq_on_Ioc` already provides.
No global a.e. statement and no Cantor diagonal are needed for the BKM bound.

Net: `ns_galerkin_vorticity_liminf_bound` (conformance anchor) is re-proved from
`galerkin_eLpNorm_subseq` alone, retiring `simon1987_ae_tendsto_from_galerkin` from
the critical path.  Axiom count for conformance anchors: 5 → 4 (Simon axiom removed).
-/

/-- Enstrophy is weakly lower semicontinuous along a.e.-convergent subsequences on [0,T].

    Restricted version of `enstrophy_weakly_lsc`: the a.e. hypothesis is only over
    `volume.restrict (Set.Ioc 0 T)`, which is what `isGalerkinLimit_subseq_on_Ioc` produces.
    Proof is identical to `enstrophy_weakly_lsc`. -/
theorem enstrophy_weakly_lsc_on_Ioc
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (T : ℝ)
    (hconv : ∀ᵐ t ∂(volume.restrict (Set.Ioc 0 T)),
        Tendsto (fun n => traj_seq n t) atTop (nhds (traj_lim t))) :
    ∀ᵐ t ∂(volume.restrict (Set.Ioc 0 T)),
        ENNReal.ofReal (enstrophy (traj_lim t)) ≤
          atTop.liminf (fun n => ENNReal.ofReal (enstrophy (traj_seq n t))) := by
  have h_enst_cont : Continuous (fun u : NSField => enstrophy u) := by
    simpa [enstrophy] using ((continuous_norm : Continuous fun u : NSField => ‖u‖).pow 2)
  filter_upwards [hconv] with t ht
  have h_enst_tendsto : Tendsto (fun n => enstrophy (traj_seq n t)) atTop
      (nhds (enstrophy (traj_lim t))) :=
    (h_enst_cont.tendsto _).comp ht
  have h_enn_tendsto : Tendsto (fun n => ENNReal.ofReal (enstrophy (traj_seq n t))) atTop
      (nhds (ENNReal.ofReal (enstrophy (traj_lim t)))) :=
    ENNReal.tendsto_ofReal h_enst_tendsto
  simp [Filter.Tendsto.liminf_eq h_enn_tendsto]

/-- **BKM integral of Galerkin limit ≤ M — restricted Fatou chain (Phase 18).**

    Identical to `bkm_limit_le_of_fatou_simon` but accepts the weak-lsc hypothesis
    `hlsc` over the RESTRICTED measure `volume.restrict (Set.Ioc 0 T)` directly.
    This avoids the global `simon1987_ae_tendsto_from_galerkin` axiom. -/
theorem bkm_limit_le_of_fatou_on_Ioc
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory) (T M : ℝ)
    (hT : 0 < T) (hM : 0 < M)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (_hLim : SatisfiesNSPDE nsNu traj_lim)
    (hBKMN : ∀ N, bkmVorticityIntegral (traj_seq N) T ≤ M)
    (hlsc : ∀ᵐ t ∂(volume.restrict (Set.Ioc 0 T)),
        ENNReal.ofReal (enstrophy (traj_lim t)) ≤
          atTop.liminf (fun n => ENNReal.ofReal (enstrophy (traj_seq n t)))) :
    bkmVorticityIntegral traj_lim T ≤ M := by
  have key : ENNReal.ofReal (bkmVorticityIntegral traj_lim T) ≤ ENNReal.ofReal M := by
    -- Convert BKM to lintegral (same as bkm_ofReal_eq_lintegral, inlined)
    have bkm_eq : ENNReal.ofReal (bkmVorticityIntegral traj_lim T) =
        ∫⁻ t in Set.Ioc 0 T,
          ENNReal.ofReal (enstrophy (traj_lim t)) ∂volume := by
      unfold bkmVorticityIntegral integratedEnstrophy
      rw [intervalIntegral.integral_of_le (le_of_lt hT)]
      exact ofReal_integral_eq_lintegral_ofReal
        (enstrophy_intervalIntegrable traj_lim T (le_of_lt hT) _hLim).1
        (ae_of_all _ (fun t => enstrophy_nonneg _))
    rw [bkm_eq]
    -- Step 1: lintegral_mono_ae using restricted hlsc directly (no ae_restrict_of_ae needed)
    have step1 :
        ∫⁻ t in Set.Ioc 0 T, ENNReal.ofReal (enstrophy (traj_lim t)) ∂volume ≤
        ∫⁻ t in Set.Ioc 0 T,
          atTop.liminf (fun n => ENNReal.ofReal (enstrophy (traj_seq n t))) ∂volume :=
      lintegral_mono_ae hlsc
    -- Step 2: Fatou (lintegral_liminf_le)
    have step2 :
        ∫⁻ t in Set.Ioc 0 T,
          atTop.liminf (fun n => ENNReal.ofReal (enstrophy (traj_seq n t))) ∂volume ≤
        atTop.liminf (fun n => ∫⁻ t in Set.Ioc 0 T,
          ENNReal.ofReal (enstrophy (traj_seq n t)) ∂volume) :=
      lintegral_liminf_le (fun n =>
        (galerkin_bkm_measurable (traj_seq n) (hConv n)).ennreal_ofReal)
    -- Step 3: convert back to BKM
    have step3 :
        atTop.liminf (fun n => ∫⁻ t in Set.Ioc 0 T,
          ENNReal.ofReal (enstrophy (traj_seq n t)) ∂volume) =
        atTop.liminf (fun n =>
          ENNReal.ofReal (bkmVorticityIntegral (traj_seq n) T)) := by
      congr 1; ext n
      symm
      unfold bkmVorticityIntegral integratedEnstrophy
      rw [intervalIntegral.integral_of_le (le_of_lt hT)]
      exact ofReal_integral_eq_lintegral_ofReal
        (enstrophy_intervalIntegrable (traj_seq n) T (le_of_lt hT) (hConv n)).1
        (ae_of_all _ (fun t => enstrophy_nonneg _))
    -- Step 4: liminf ≤ ENNReal.ofReal M
    have step4 :
        atTop.liminf (fun n => ENNReal.ofReal (bkmVorticityIntegral (traj_seq n) T)) ≤
        ENNReal.ofReal M :=
      Filter.liminf_le_of_le
        (hf := isBoundedUnder_of_eventually_ge
          (Eventually.of_forall fun _ => zero_le _))
        fun b hb => by
          rw [Filter.eventually_atTop] at hb
          obtain ⟨N, hN⟩ := hb
          exact (hN N le_rfl).trans (ENNReal.ofReal_le_ofReal (hBKMN N))
    calc ∫⁻ t in Set.Ioc 0 T, ENNReal.ofReal (enstrophy (traj_lim t)) ∂volume
        ≤ ∫⁻ t in Set.Ioc 0 T,
            atTop.liminf (fun n => ENNReal.ofReal (enstrophy (traj_seq n t))) ∂volume := step1
      _ ≤ atTop.liminf (fun n => ∫⁻ t in Set.Ioc 0 T,
            ENNReal.ofReal (enstrophy (traj_seq n t)) ∂volume) := step2
      _ = atTop.liminf (fun n => ENNReal.ofReal (bkmVorticityIntegral (traj_seq n) T)) := step3
      _ ≤ ENNReal.ofReal M := step4
  exact (ENNReal.ofReal_le_ofReal_iff (le_of_lt hM)).mp key

/-- **Phase 18: BKM bound from L² subsequence — no Simon axiom required.**

    Combines:
    - `galerkin_eLpNorm_subseq` (§2): L²([0,T]) convergent subsequence φ
    - `ae_subseq_of_eLpNorm_tendsto_restrict` (§1): L² → a.e. subsequence ψ on [0,T]
    - `enstrophy_weakly_lsc_on_Ioc` (§4): enstrophy lsc on [0,T]
    - `bkm_limit_le_of_fatou_on_Ioc` (§4): restricted Fatou chain

    The double subsequence `φ ∘ ψ` satisfies the BKM bound (since hBKMN holds for all N)
    and converges a.e. on [0,T], so the Fatou argument applies.

    **Net: proves `bkmVorticityIntegral traj_lim T ≤ M` using only
    `galerkin_eLpNorm_subseq` + Mathlib.  `simon1987_ae_tendsto_from_galerkin` not used.** -/
theorem vorticity_liminf_bound_from_L2
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory) (T M : ℝ)
    (hT : 0 < T) (hM : 0 < M)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim)
    (hBKMN : ∀ N, bkmVorticityIntegral (traj_seq N) T ≤ M) :
    bkmVorticityIntegral traj_lim T ≤ M := by
  -- (a) Get L² convergent subsequence φ (all T simultaneously)
  obtain ⟨φ, _hMonoφ, hL2⟩ := galerkin_eLpNorm_subseq traj_seq traj_lim hConv hLim
  -- (b) Get a.e. convergent double-subsequence φ ∘ ψ on [0,T]
  have hf : ∀ n, AEStronglyMeasurable (fun t => traj_seq (φ n) t)
      (volume.restrict (Set.Ioc 0 T)) :=
    fun n => (ns_traj_continuous (traj_seq (φ n)) (hConv (φ n))).aestronglyMeasurable
  have hg : AEStronglyMeasurable (fun t => traj_lim t)
      (volume.restrict (Set.Ioc 0 T)) :=
    (ns_traj_continuous traj_lim hLim).aestronglyMeasurable
  obtain ⟨ψ, _hMonoψ, hae⟩ :=
    ae_subseq_of_eLpNorm_tendsto_restrict
      (volume.restrict (Set.Ioc 0 T))
      (fun n t => traj_seq (φ n) t) (fun t => traj_lim t)
      hf hg (hL2 T hT)
  -- (c) BKM bound for the double subsequence (monotone image of hBKMN)
  have hBKMN' : ∀ N, bkmVorticityIntegral (traj_seq (φ (ψ N))) T ≤ M :=
    fun N => hBKMN (φ (ψ N))
  -- (d) Enstrophy lsc on [0,T] from the a.e. convergence
  have hlsc := enstrophy_weakly_lsc_on_Ioc (fun n => traj_seq (φ (ψ n))) traj_lim T hae
  -- (e) Restricted Fatou chain closes the bound
  exact bkm_limit_le_of_fatou_on_Ioc
    (fun n => traj_seq (φ (ψ n))) traj_lim T M hT hM
    (fun N => hConv (φ (ψ N))) hLim hBKMN' hlsc

/-! ## §5. Phase 19: vorticity_liminf_bound_refined synonym -/

/-- **Phase 19: vorticity_liminf_bound_refined — synonym for vorticity_liminf_bound_from_L2.**

    This theorem was previously in `VorticityLiminf.lean` where it was proved via
    `simon1987_ae_tendsto_from_galerkin` (global a.e., `.partiallyVerified`).

    Phase 19 moves it here and re-proves it from the restricted Fatou chain (Phase 18),
    which uses only `galerkin_eLpNorm_subseq` + Mathlib.
    `simon1987_ae_tendsto_from_galerkin` is retired (axiom deleted).

    Net: **6 axioms → 5** (simon removed). -/
theorem vorticity_liminf_bound_refined
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory) (T M : ℝ)
    (hT : 0 < T) (hM : 0 < M)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim)
    (hBKMN : ∀ N, bkmVorticityIntegral (traj_seq N) T ≤ M) :
    bkmVorticityIntegral traj_lim T ≤ M :=
  vorticity_liminf_bound_from_L2 traj_seq traj_lim T M hT hM hConv hLim hBKMN

/-! ## §6. Gap note: Cantor diagonal to global a.e. -/

/-- **Phase 17 gap: Cantor diagonal lifting [0,T] → global `∀ᵐ t : ℝ`.**

    `isGalerkinLimit_subseq_on_Ioc` gives a (possibly different) subsequence for each T.
    A single subsequence valid for ALL T requires the Cantor diagonal:

      iterativeφ k  := subsequence refined at [0, k+1]  (nested Rellich extractions)
      φ_diag n      := iterativeφ n n                   (diagonal)

    The diagonal satisfies `StrictMono φ_diag` and `φ_diag` eventually lands in the
    [0,k]-subsequence for each k.

    **Mathlib tool for the final lift**:
    `ae_of_forall_measure_lt_top_ae_restrict` (`Mathlib.MeasureTheory.Measure.Typeclasses.SFinite`):
      [σ-finite μ] ∀ s measurable, μ s < ∞ → ∀ᵐ x ∂μ.restrict s, P x
      ⟹  ∀ᵐ x ∂μ, P x

    Once the diagonal is implemented, `simon1987_ae_tendsto_from_galerkin` follows as a theorem
    from `galerkin_eLpNorm_subseq` alone (0 additional axioms).

    **Reference**: entropic-time repo, `AubinLionsMathlib.lean`, Stages 232-247:
      `iterativeφ`, `rellichDataFull`, `φ_diag`, `φ_diag_strictMono`,
      `φ_diag_converges`, `aubin_lions_core_compact_from_init_bound`. -/
def phase17GapNote : String :=
  "Phase 17: ae_subseq_of_eLpNorm_tendsto_restrict PROVED (Mathlib). " ++
  "galerkin_eLpNorm_subseq AXIOM (replaces simon1987_ae_tendsto_from_galerkin). " ++
  "isGalerkinLimit_subseq_on_Ioc PROVED (combines both for fixed T). " ++
  "Remaining gap: Cantor diagonal (iterativeφ/φ_diag pattern, " ++
  "entropic-time Stages 232-247) to lift from [0,T] to global ∀ᵐ t : ℝ."

end NavierStokesClean.Galerkin
