import Mathlib.MeasureTheory.Function.ConvergenceInMeasure
import NavierStokesClean.Galerkin.VorticityLiminf

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

/-! ## §2. Sub-axiom: Galerkin sequence has L²([0,T])-convergent subsequence -/

/-- **Phase 17 sub-axiom: Galerkin sequences have L²-convergent subsequences.**

    For any Galerkin sequence and limit trajectory (both NS solutions), there exists
    a subsequence φ such that `eLpNorm (traj_seq (φ n) - traj_lim) 2 volume[0,T] → 0`
    for each T > 0.

    **Why smaller than `simon1987_ae_tendsto_from_galerkin`**:
    - Conclusion is L² norm convergence (not a.e.) — measurably weaker.
    - Output is a subsequence φ — the full sequence need not converge.
    - The a.e. direction is a THEOREM (§1) from Mathlib, not an axiom.

    **NS content**: Aubin-Lions (1963) / Simon (1987) Thm 5:
    energy bound ‖u_N‖_{L²H¹} ≤ C + time-derivative bound ‖∂_t u_N‖_{L²H⁻¹} ≤ D
    → compact embedding H¹ ↪↪ L² (Rellich-Kondrachov)
    → strong L²([0,T]) convergence of a subsequence.

    **Nikitaeva (2025)**, arXiv:2507.13356v1, Lemma B.9 + App A.2.1.

    **Epistemic: `.partiallyVerified`** -/
axiom galerkin_eLpNorm_subseq
    (traj_seq : Nat → Trajectory) (traj_lim : Trajectory)
    (hConv : ∀ N, SatisfiesNSPDE nsNu (traj_seq N))
    (hLim : SatisfiesNSPDE nsNu traj_lim) :
    ∃ (φ : Nat → Nat), StrictMono φ ∧
      ∀ (T : ℝ), 0 < T →
        Tendsto
          (fun n => eLpNorm (fun t => traj_seq (φ n) t - traj_lim t) 2
                      (volume.restrict (Set.Ioc 0 T)))
          atTop (nhds 0)

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

/-! ## §4. Gap note: Cantor diagonal to global a.e. -/

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
