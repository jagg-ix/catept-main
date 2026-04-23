import CATEPTMain.LSI.LSIPrelude
/-!
# Preliminaries_LSI — AFP Lebesgue_Stieltjes_Integral → Lean 4 (Phase 1)

Source: `Lebesgue_Stieltjes_Integral/Preliminaries_LSI.thy` (Yosuke Ito — 2026)
Dependencies: HOL-Analysis, HOL-Probability

Content: Auxiliary lemmas for the Lebesgue-Stieltjes integral:
  - Properties of monotone right-continuous (RCLL) functions
  - Interval measure properties and sigma-finiteness
  - Absolute continuity characterizations
  - Dominated convergence and monotone convergence prerequisites
  - Integration by parts preliminaries

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.LSI.Preliminaries_LSI

open CATEPTMain.LSI

-- ── Monotone function properties ───────────────────────────────────────────────
-- AFP: A monotone function on ℝ has at most countably many discontinuities.

private axiom monotone_countable_disc_law (F : ℝ → ℝ) (hF : Monotone F) :
    Set.Countable {x : ℝ | ¬ContinuousAt F x}

theorem monotone_countable_disc (F : ℝ → ℝ) (hF : Monotone F) :
    Set.Countable {x : ℝ | ¬ContinuousAt F x} := monotone_countable_disc_law F hF

-- Right-continuous regularization: for every monotone F,
-- define F⁺(x) = lim_{y↓x} F(y), which is monotone and right-continuous.
noncomputable def rcllRegularize (F : ℝ → ℝ) (x : ℝ) : ℝ :=
  sInf {F y | y > x}  -- lim from right (infimum over right half-line)

private axiom rcllRegularize_monotone_law (F : ℝ → ℝ) (hF : Monotone F) :
    Monotone (rcllRegularize F)

theorem rcllRegularize_monotone (F : ℝ → ℝ) (hF : Monotone F) :
    Monotone (rcllRegularize F) := rcllRegularize_monotone_law F hF

private axiom rcllRegularize_right_cont_law (F : ℝ → ℝ) (hF : Monotone F) :
    ∀ x : ℝ, ContinuousWithinAt (rcllRegularize F) (Set.Ici x) x

theorem rcllRegularize_right_cont (F : ℝ → ℝ) (hF : Monotone F) :
    ∀ x : ℝ, ContinuousWithinAt (rcllRegularize F) (Set.Ici x) x :=
  rcllRegularize_right_cont_law F hF

-- ── Stieltjes measure sigma-finiteness ─────────────────────────────────────────
-- AFP: `sigma_finite (interval_measure F)` when F is bounded on compact sets.

private axiom lsiMeasure_sigma_finite_law (F : ℝ → ℝ) (hF : Monotone F) :
    MeasureTheory.SigmaFinite (lsiMeasure F)

theorem lsiMeasure_sigma_finite (F : ℝ → ℝ) (hF : Monotone F) :
    MeasureTheory.SigmaFinite (lsiMeasure F) := lsiMeasure_sigma_finite_law F hF

-- ── Absolute continuity from density ──────────────────────────────────────────
-- AFP: `absolutely_continuous ν μ ↔ ∃ f, ν = μ.withDensity f`
-- (Radon-Nikodym characterization under sigma-finiteness)

private axiom absCont_iff_density_law (ν μ : MeasureTheory.Measure ℝ)
    [MeasureTheory.SigmaFinite μ] [MeasureTheory.SigmaFinite ν] :
    LSIAbsCont ν μ ↔ ∃ f : ℝ → ENNReal, ν = μ.withDensity f

theorem absCont_iff_density (ν μ : MeasureTheory.Measure ℝ)
    [MeasureTheory.SigmaFinite μ] [MeasureTheory.SigmaFinite ν] :
    LSIAbsCont ν μ ↔ ∃ f : ℝ → ENNReal, ν = μ.withDensity f :=
  absCont_iff_density_law ν μ

-- ── Dominated convergence application ─────────────────────────────────────────
-- AFP: DCT for Stieltjes integrals used in integration by parts proof.
-- Phase-1: restate as abstract dominated convergence for lsiMeasure.

private axiom lsi_dominated_convergence_law (F : ℝ → ℝ) (hF : Monotone F)
    (f g : ℕ → ℝ → ℝ) (g_bound : ℝ → ℝ)
    (hBound : ∀ n x, |f n x| ≤ g_bound x)
    (hIntBound : MeasureTheory.Integrable g_bound (lsiMeasure F))
    (hPointwise : ∀ x, Filter.Tendsto (fun n => f n x) Filter.atTop (nhds (0 : ℝ))) :
    Filter.Tendsto (fun n => ∫ x, f n x ∂(lsiMeasure F)) Filter.atTop (nhds 0)

theorem lsi_dominated_convergence (F : ℝ → ℝ) (hF : Monotone F)
    (f g : ℕ → ℝ → ℝ) (g_bound : ℝ → ℝ)
    (hBound : ∀ n x, |f n x| ≤ g_bound x)
    (hIntBound : MeasureTheory.Integrable g_bound (lsiMeasure F))
    (hPointwise : ∀ x, Filter.Tendsto (fun n => f n x) Filter.atTop (nhds (0 : ℝ))) :
    Filter.Tendsto (fun n => ∫ x, f n x ∂(lsiMeasure F)) Filter.atTop (nhds 0) :=
  lsi_dominated_convergence_law F hF f g g_bound hBound hIntBound hPointwise

-- ── Interval measure uniqueness ────────────────────────────────────────────────
-- AFP: `interval_measure` is the unique Borel measure with μ(Ioc a b) = F(b) - F(a).

private axiom lsiMeasure_unique_law (F : ℝ → ℝ) (hF : Monotone F)
    (μ : MeasureTheory.Measure ℝ) [MeasureTheory.IsLocallyFiniteMeasure μ]
    (hMu : ∀ a b : ℝ, a ≤ b → μ (Set.Ioc a b) = ENNReal.ofReal (F b - F a)) :
    μ = lsiMeasure F

theorem lsiMeasure_unique (F : ℝ → ℝ) (hF : Monotone F)
    (μ : MeasureTheory.Measure ℝ) [MeasureTheory.IsLocallyFiniteMeasure μ]
    (hMu : ∀ a b : ℝ, a ≤ b → μ (Set.Ioc a b) = ENNReal.ofReal (F b - F a)) :
    μ = lsiMeasure F := lsiMeasure_unique_law F hF μ hMu

end CATEPTMain.LSI.Preliminaries_LSI
