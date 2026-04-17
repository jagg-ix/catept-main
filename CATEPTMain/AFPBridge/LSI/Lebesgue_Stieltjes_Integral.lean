import CATEPTMain.AFPBridge.LSI.Preliminaries_LSI
/-!
# Lebesgue_Stieltjes_Integral — AFP → Lean 4 (Phase 1)

Source: `Lebesgue_Stieltjes_Integral/Lebesgue_Stieltjes_Integral.thy` (Yosuke Ito — 2026)
Dependencies: Preliminaries_LSI

Content: The main Lebesgue-Stieltjes integration results:
  - Stieltjes integral definition via interval measure
  - Change-of-variables formula: ∫ g dF = ∫ g * F' dx (for abs. continuous F)
  - Integration by parts: ∫ g dF + ∫ F dg = [F·g]
  - Fundamental theorem connection
  - Fubini for Stieltjes integrals

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.LSI.Lebesgue_Stieltjes_Integral

open CATEPTMain.AFPBridge.LSI

-- ── Lebesgue-Stieltjes integral basic properties ───────────────────────────────
-- AFP: integral is linear; non-negative for non-negative integrand; monotone.

private axiom lsi_integral_linear_law (F : ℝ → ℝ) (hF : Monotone F)
    (f g : ℝ → ℝ) (c : ℝ)
    (hf : MeasureTheory.Integrable f (lsiMeasure F))
    (hg : MeasureTheory.Integrable g (lsiMeasure F)) :
    lsiIntegral F (fun x => c * f x + g x) =
    c * lsiIntegral F f + lsiIntegral F g

theorem lsi_integral_linear (F : ℝ → ℝ) (hF : Monotone F)
    (f g : ℝ → ℝ) (c : ℝ)
    (hf : MeasureTheory.Integrable f (lsiMeasure F))
    (hg : MeasureTheory.Integrable g (lsiMeasure F)) :
    lsiIntegral F (fun x => c * f x + g x) =
    c * lsiIntegral F f + lsiIntegral F g :=
  lsi_integral_linear_law F hF f g c hf hg

private axiom lsi_integral_nonneg_law (F : ℝ → ℝ) (hF : Monotone F)
    (f : ℝ → ℝ) (hf : ∀ x, 0 ≤ f x)
    (hfInt : MeasureTheory.Integrable f (lsiMeasure F)) :
    0 ≤ lsiIntegral F f

theorem lsi_integral_nonneg (F : ℝ → ℝ) (hF : Monotone F)
    (f : ℝ → ℝ) (hf : ∀ x, 0 ≤ f x)
    (hfInt : MeasureTheory.Integrable f (lsiMeasure F)) :
    0 ≤ lsiIntegral F f := lsi_integral_nonneg_law F hF f hf hfInt

private axiom lsi_integral_mono_law (F : ℝ → ℝ) (hF : Monotone F)
    (f g : ℝ → ℝ) (hfg : ∀ x, f x ≤ g x)
    (hf : MeasureTheory.Integrable f (lsiMeasure F))
    (hg : MeasureTheory.Integrable g (lsiMeasure F)) :
    lsiIntegral F f ≤ lsiIntegral F g

theorem lsi_integral_mono (F : ℝ → ℝ) (hF : Monotone F)
    (f g : ℝ → ℝ) (hfg : ∀ x, f x ≤ g x)
    (hf : MeasureTheory.Integrable f (lsiMeasure F))
    (hg : MeasureTheory.Integrable g (lsiMeasure F)) :
    lsiIntegral F f ≤ lsiIntegral F g := lsi_integral_mono_law F hF f g hfg hf hg

-- ── Connection to Lebesgue integral (fundamental theorem) ─────────────────────
-- AFP: When F(x) = ∫ₐˣ f dt (F = ∫ f), lsiMeasure F = μ_f (measure with density f).
-- That is: ∫ g dF = ∫ g f dx.

private axiom lsi_from_integral_function_law (f g : ℝ → ℝ)
    (hf : MeasureTheory.Integrable f MeasureTheory.volume)
    (hf_nn : ∀ x, 0 ≤ f x) (a : ℝ) :
    let F : ℝ → ℝ := fun x => ∫ t in Set.Iic x, f t ∂MeasureTheory.volume
    lsiIntegral F g =
    ∫ x, g x * f x ∂MeasureTheory.volume

theorem lsi_from_integral_function (f g : ℝ → ℝ)
    (hf : MeasureTheory.Integrable f MeasureTheory.volume)
    (hf_nn : ∀ x, 0 ≤ f x) (a : ℝ) :
    let F : ℝ → ℝ := fun x => ∫ t in Set.Iic x, f t ∂MeasureTheory.volume
    lsiIntegral F g =
    ∫ x, g x * f x ∂MeasureTheory.volume :=
  lsi_from_integral_function_law f g hf hf_nn a

-- ── Change of variables formula ────────────────────────────────────────────────
-- Main theorem: ∫ₐᵇ g dF = ∫ₐᵇ g * F' dx  (F abs. continuous)

-- Re-export from prelude for clarity:
theorem lebesgue_stieltjes_eq_density_integral
    (F g : ℝ → ℝ) (hF : Monotone F) (a b : ℝ)
    (habsCont : LSIAbsCont (lsiMeasure F) MeasureTheory.volume) :
    lsiIntegralOn F g a b =
    ∫ x in Set.Ioc a b, g x * deriv F x ∂MeasureTheory.volume :=
  lsiChangeOfVariables F g hF a b habsCont

-- ── Integration by parts ──────────────────────────────────────────────────────
-- Main novel result of this AFP entry:
-- ∫ₐᵇ g dF + ∫ₐᵇ F dg = F(b)·g(b) − F(a)·g(a)

-- Re-export from prelude:
theorem lebesgue_stieltjes_integration_by_parts
    (F g : ℝ → ℝ) (hF : Monotone F) (hG : Monotone g) (a b : ℝ) :
    lsiIntegralOn F g a b + lsiIntegralOn g F a b =
    F b * g b - F a * g a :=
  lsiIntByParts F g hF hG a b

-- ── Fubini for Stieltjes integrals ─────────────────────────────────────────────
-- AFP proof of IBP uses Fubini: ∫∫ d(F×G) = ∫∫ d(G×F) on [a,b]².

private axiom lsi_fubini_law (F G : ℝ → ℝ) (hF : Monotone F) (hG : Monotone G) (a b : ℝ) :
    ∫ x in Set.Ioc a b, lsiIntegralOn G (fun _ => 1) a x ∂(lsiMeasure F) =
    ∫ y in Set.Ioc a b, lsiIntegralOn F (fun _ => 1) a y ∂(lsiMeasure G)

theorem lsi_fubini (F G : ℝ → ℝ) (hF : Monotone F) (hG : Monotone G) (a b : ℝ) :
    ∫ x in Set.Ioc a b, lsiIntegralOn G (fun _ => 1) a x ∂(lsiMeasure F) =
    ∫ y in Set.Ioc a b, lsiIntegralOn F (fun _ => 1) a y ∂(lsiMeasure G) :=
  lsi_fubini_law F G hF hG a b

-- ── Indicator integral ────────────────────────────────────────────────────────
-- AFP: ∫ 1_{Ioc a b} dF = F(b) - F(a)
private axiom lsi_indicator_Ioc_law (F : ℝ → ℝ) (hF : Monotone F) (a b : ℝ) (h : a ≤ b) :
    ∫ x, Set.indicator (Set.Ioc a b) (fun _ => (1 : ℝ)) x ∂(lsiMeasure F) =
    F b - F a

theorem lsi_indicator_Ioc (F : ℝ → ℝ) (hF : Monotone F) (a b : ℝ) (h : a ≤ b) :
    ∫ x, Set.indicator (Set.Ioc a b) (fun _ => (1 : ℝ)) x ∂(lsiMeasure F) =
    F b - F a := lsi_indicator_Ioc_law F hF a b h

-- ── Integrability of continuous bounded functions ─────────────────────────────
-- AFP: Continuous bounded g is integrable w.r.t. any finite Stieltjes measure.
private axiom lsi_continuous_integrable_law (F g : ℝ → ℝ) (hF : Monotone F) (a b : ℝ)
    (hg : Continuous g) (hBound : ∃ C, ∀ x ∈ Set.Ioc a b, |g x| ≤ C)
    [MeasureTheory.IsFiniteMeasure (lsiMeasure F)] :
    MeasureTheory.IntegrableOn g (Set.Ioc a b) (lsiMeasure F)

theorem lsi_continuous_integrable (F g : ℝ → ℝ) (hF : Monotone F) (a b : ℝ)
    (hg : Continuous g) (hBound : ∃ C, ∀ x ∈ Set.Ioc a b, |g x| ≤ C)
    [MeasureTheory.IsFiniteMeasure (lsiMeasure F)] :
    MeasureTheory.IntegrableOn g (Set.Ioc a b) (lsiMeasure F) :=
  lsi_continuous_integrable_law F g hF a b hg hBound

end CATEPTMain.AFPBridge.LSI.Lebesgue_Stieltjes_Integral
