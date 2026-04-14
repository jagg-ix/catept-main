import CATEPTMain.AFPBridge.Framework.AFPBridgeFramework
import Mathlib.MeasureTheory.Function.LpSpace.Basic
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.Analysis.Fourier.FourierTransform
/-!
# FOU Prelude — Fourier (AFP) → Lean 4

Phase-1 opaque scaffold for `Fourier` (Lawrence Paulson — 2019).
https://www.isa-afp.org/entries/Fourier.html

AFP dependencies bridged here:
  Lp (AFP) → `MeasureTheory.Memℒp f 2 μ`  (Lp space membership)
  HOL-Analysis → Mathlib.Analysis imports

Module-specific content: periodic functions on ℝ, Lp(ℝ) space characterizations,
  square-integrable functions, Fourier coefficients, partial sums, L2 convergence,
  Parseval's identity, Riemann-Lebesgue lemma.

KEY TYPE NOTE:
  AFP `sq_integrable f` = `Memℒp f 2 μ_pi` (NOT a type, a Prop predicate).
  μ_pi = Lebesgue measure on [0, 2π] (or normalized: 1/(2π) * Lebesgue).

BINDER RULES:
  B29 (FOU): `sq_integrable f` → emit as `(hf : SqIntegrable f)` (Prop)
  B30 (FOU): `fourierCoeff f n` defined concretely in prelude (not free symbol)
  B31 (FOU): `periodic f t` → emit as `(hPer : IsPeriodic f t)` (Prop)

Phase-2 upgrade path:
  Replace μ_pi axiom with actual measure; connect fourierCoeff to Mathlib definition.

See: CATEPTMain/AFPBridge/FOU/FOU_WORKLOG.lean
-/

set_option autoImplicit false

open CATEPTMain.AFPBridgeFramework.TacticStubs

namespace CATEPTMain.AFPBridge.FOU

-- ── Underlying measure: normalized Lebesgue on [0, 2π] ───────────────────────
-- AFP: all integrals are over ℝ/(2π) with normalized measure dμ = dx/(2π).
-- Phase-1: axiom. Phase-2: volume.restrict on Icc 0 (2π) scaled by 1/(2π).
noncomputable axiom μ_pi : MeasureTheory.Measure ℝ
axiom μ_pi_prob : MeasureTheory.IsProbabilityMeasure μ_pi

-- ── Periodic function predicate ───────────────────────────────────────────────
-- AFP: `periodic f t` means f(x + t) = f(x) for all x.
-- BINDER RULE B31: always emitted as Prop predicate.
def IsPeriodic (f : ℝ → ℂ) (T : ℝ) : Prop :=
  ∀ x : ℝ, f (x + T) = f x

def IsPeriodicR (f : ℝ → ℝ) (T : ℝ) : Prop :=
  ∀ x : ℝ, f (x + T) = f x

-- 2π-periodic:
def Is2PiPeriodic (f : ℝ → ℂ) : Prop := IsPeriodic f (2 * Real.pi)

-- ── Square-integrable (L²) predicate ──────────────────────────────────────────
-- AFP `sq_integrable f` (in Lspace file)
-- BINDER RULE B29: Prop predicate, NOT a type.
-- Phase-1: using μ_pi axiom. Phase-2: MeasureTheory.Memℒp f 2 μ_pi.
def SqIntegrable (f : ℝ → ℂ) : Prop :=
  MeasureTheory.MemLp f 2 μ_pi

def SqIntegrableR (f : ℝ → ℝ) : Prop :=
  MeasureTheory.MemLp f 2 μ_pi

-- ── Fourier coefficients ───────────────────────────────────────────────────────
-- AFP: `fourier_series_coeff f n` = (1/2π) ∫₀²π f(x) e^{-inx} dx
-- BINDER RULE B30: defined concretely in prelude (not a free axiom symbol).
-- Phase-1: axiom (uses μ_pi). Phase-2: inline definition via ∫.
noncomputable axiom fourierCoeff : (ℝ → ℂ) → ℤ → ℂ

-- Key property: coefficient definition
axiom fourierCoeff_def (f : ℝ → ℂ) (n : ℤ) (hf : SqIntegrable f) :
    fourierCoeff f n =
    ∫ x, f x * Complex.exp (-Complex.I * n * x) ∂μ_pi

-- ── Fourier partial sum ────────────────────────────────────────────────────────
-- AFP: `fourier_partial_sum f N x` = ∑_{n=-N}^{N} cₙ(f) * e^{inx}
noncomputable def fourierPartialSum (f : ℝ → ℂ) (N : ℕ) (x : ℝ) : ℂ :=
  ∑ n ∈ Finset.Icc (-N : ℤ) N,
    fourierCoeff f n * Complex.exp (Complex.I * n * x)

-- ── L² norm via μ_pi ─────────────────────────────────────────────────────────
noncomputable def L2norm (f : ℝ → ℂ) : ℝ :=
  (∫ x, ‖f x‖^2 ∂μ_pi) ^ (1/2 : ℝ)

end CATEPTMain.AFPBridge.FOU
