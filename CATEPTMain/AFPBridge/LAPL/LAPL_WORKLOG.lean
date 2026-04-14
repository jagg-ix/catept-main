/-!
# LAPL Translation Worklog — Laplace_Transform → Lean 4
Source: AFP `Laplace_Transform`
  (Salomon Steck, Burkhart Wolff — 2021)
  https://www.isa-afp.org/entries/Laplace_Transform.html
Target: Lean 4 / CATEPTMain, Lean 4.29+  (namespace CATEPTMain.AFPBridge.LAPL)
License: BSD

Prior version: none — first translation.
Methodology note: The Laplace transform is not yet natively in Mathlib's core
  (as of Lean 4.29). Phase-1 defines it concretely via `MeasureTheory.integral`
  and `Complex.exp`, then axiomatically states properties.

AFP entry abstract:
  Defines the (one-sided) Laplace transform L{f}(s) = ∫₀^∞ f(t) e^{-st} dt.
  Proves convergence for abscissa of convergence, linearity, shift theorems,
  differentiation/integration rules, convolution theorem, and uniqueness
  (injectivity of the transform). The Bromwich inversion integral is stated
  axiomatically.

AFP session file order:
  1.  Laplace_Transform      (definition, linearity, basic properties)
  2.  Laplace_Shift          (time-shift and frequency-shift)
  3.  Laplace_Diff           (differentiation/integration rules)
  4.  Convolution_Theorem    (L{f*g} = F·G)
  5.  Inversion              (Bromwich integral, uniqueness)

AFP direct dependencies:
  - HOL-Analysis
  - HOL-Complex-Analysis

Mathlib modules used as semantic targets (phase-2):
  - Mathlib.MeasureTheory.Integral.Bochner.Basic
  - Mathlib.Analysis.SpecialFunctions.Complex.Circle
  - Mathlib.Analysis.Complex.Laplace  (if/when available)

BINDER RULES (LAPL-specific):
  B75: `laplace f s` → `laplaceTransform f s : ℂ`
  B76: abscissa of convergence `σ_abs f` → `laplaceAbscissa f : ℝ`
  B77: exponential order `|f(t)| ≤ M e^{σt}` → `IsExpOrder f M σ`

Phase record (cumulative):
  TH001–TH028: LAPL theorems translated
-/
