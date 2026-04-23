import CATEPTMain.GaugeTheory.FEYNCALC.SpinorPropagator
import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral
import Mathlib.Analysis.Matrix.Normed
import Mathlib.MeasureTheory.Integral.Bochner.ContinuousLinearMap
import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.Tactic
/-!
# Loop Integral Bridge — Spinor Trace × CATEPT Curved Measure

This module bridges FEYNCALC spinor trace algebra and the CATEPT curved-spacetime
path integral measure, enabling Feynman loop amplitudes as CATEPT integrals.

## Architecture

```
FEYNCALC algebra                    CATEPT curved measure
────────────────                    ─────────────────────
spinorTrace : FCEnd → ℂ        ×    CurvedMeasurePathIntegralModel
     ↕ (linear, bounded)                    ↕
Tr(p̸ + m) = 4m                     dμ_g = ρ_g dμ  (curved volume form)
     ↕                                      ↕
     loopAmplitude = ∫ Tr[F(k) · w(k)] ρ_g(k) dγ(k)
```

## Key Features

- `loopAmplitude` defined over `CurvedMeasurePathIntegralModel` (curved spacetime)
- Flat limit: `volumeDensity = 1` ↔ standard Euclidean path integral
- `NormedAddCommGroup FCEnd` provided via `Matrix.normedAddCommGroup` (local instance)
- Trace–integral exchange via `ContinuousLinearMap.integral_comp_comm`
- Loop amplitude bounded by `partitionFunction × ‖Tr[F]‖_∞`

## Theorem status

| Name                                | Status | Notes                                          |
|-------------------------------------|--------|------------------------------------------------|
| `spinorTraceClm`                    | def    | `spinorTrace` as a `ℂ`-ContinuousLinearMap     |
| `spinorTrace_integral_comm`         | proved | Tr(∫ F dν) = ∫ Tr(F) dν (exchange theorem)    |
| `loopAmplitude`                     | def    | 𝒜 = ∫ Tr[F(k)·w(k)] ρ_g(k) dγ(k)            |
| `loop_amplitude_eq_catept_trace`    | proved | 𝒜 = Tr(∫ F·w dν_g) (main bridge)             |
| `loop_amplitude_bounded`            | proved | |𝒜| ≤ Z₀ · ‖Tr[F]‖_∞                         |
-/

set_option autoImplicit false

open Real Complex MeasureTheory Matrix
open NavierStokesClean.CATEPT
open CATEPTMain.GaugeTheory.FEYNCALC

-- Provide NormedAddCommGroup for FCEnd = Matrix (Fin 4) (Fin 4) ℂ locally.
-- Matrix.normedAddCommGroup uses the sup-of-sup (Pi) norm.
attribute [local instance] Matrix.normedAddCommGroup Matrix.normedSpace

namespace CATEPTMain.CATEPT.CATEPT

noncomputable section

-- ── spinorTrace as a ContinuousLinearMap ──────────────────────────────────────

/-- `spinorTrace` as a `ℂ`-ContinuousLinearMap.
    On a finite-dimensional space, all linear maps are continuous. -/
def spinorTraceClm : FCEnd →L[ℂ] ℂ :=
  (Matrix.traceLinearMap (Fin 4) ℂ ℂ).toContinuousLinearMap

theorem spinorTraceClm_apply (A : FCEnd) :
    spinorTraceClm A = spinorTrace A := by
  simp only [spinorTraceClm, LinearMap.coe_toContinuousLinearMap',
             Matrix.traceLinearMap_apply]
  rfl

-- ── Trace–Integral Exchange ───────────────────────────────────────────────────

/-- **Trace–Integral Exchange**: `spinorTrace` commutes with Bochner integration. -/
theorem spinorTrace_integral_comm
    {α : Type*} [MeasurableSpace α]
    (μ : Measure α)
    (F : α → FCEnd)
    (hF : Integrable F μ) :
    spinorTrace (∫ x, F x ∂μ) =
    ∫ x, spinorTrace (F x) ∂μ := by
  have := spinorTraceClm.integral_comp_comm hF
  simp only [spinorTraceClm_apply] at this
  exact this.symm

-- ── Loop Amplitude Definition (Curved Spacetime) ─────────────────────────────

/-- The **loop amplitude** for diagram `F` integrated against the CATEPT curved
    complex weight over `dμ_g = ρ_g dμ`:

      𝒜[F] := ∫ Tr[F(k) · w(k)] ρ_g(k) dγ(k)

    The `CurvedMeasurePathIntegralModel` carries the geometry via `geom.volumeMeasure
    = ρ_g dμ`. For flat spacetime (ρ_g = 1), this reduces to the standard loop integral.

    The scalar integral avoids requiring `NormedAddCommGroup FCEnd` in the definition,
    working directly with the `ℂ`-valued integrand `spinorTrace (w(k) · F(k))`. -/
noncomputable def loopAmplitude
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (F : α → FCEnd) : ℂ :=
  ∫ x, spinorTrace (smulEnd (c.toMeasurePathIntegralModel.weight x) (F x))
        ∂c.geom.volumeMeasure

-- ── Partition function and loop bound helpers ─────────────────────────────────

/-- Partition function `Z_g = ∫ damping(x) ρ_g(x) dγ(x)` for the curved model. -/
noncomputable def partitionFunction
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α) : ℝ :=
  ∫ x, c.toMeasurePathIntegralModel.damping x ∂c.geom.volumeMeasure

theorem partitionFunction_nonneg
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α) :
    0 ≤ partitionFunction c := by
  unfold partitionFunction
  apply integral_nonneg
  intro x
  exact (Real.exp_pos _).le

-- ── Main Bridge: Loop Amplitude = Trace of CATEPT Integral ────────────────────

/-- **Trace–weight factorization**: loop amplitude factors through spinorTrace. -/
theorem loop_amplitude_trace_weight_factoring
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (F : α → FCEnd)
    (traceVal : α → ℂ)
    (hF_trace : ∀ x, spinorTrace (F x) = traceVal x) :
    loopAmplitude c F = ∫ x, c.toMeasurePathIntegralModel.weight x * traceVal x
                              ∂c.geom.volumeMeasure := by
  unfold loopAmplitude
  congr 1; ext x
  rw [spinorTrace_smul, hF_trace]

/-- **Loop Integral Bridge** (main theorem):

    The loop amplitude equals the spinor trace of the complex measure integral:
      𝒜[F] = Tr(∫ F(k) · w(k) ρ_g(k) dγ(k))

    Proof: trace–integral exchange via `spinorTraceClm.integral_comp_comm`. -/
theorem loop_amplitude_eq_catept_trace
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (F : α → FCEnd)
    (hF : Integrable (fun x => smulEnd (c.toMeasurePathIntegralModel.weight x) (F x))
                     c.geom.volumeMeasure) :
    loopAmplitude c F =
    spinorTrace (∫ x, smulEnd (c.toMeasurePathIntegralModel.weight x) (F x)
                      ∂c.geom.volumeMeasure) := by
  unfold loopAmplitude
  rw [spinorTrace_integral_comm _ _ hF]

-- ── Loop Amplitude Bound ──────────────────────────────────────────────────────

/-- **Loop amplitude bound** via total variation:
    |𝒜[F]| ≤ Z₀ · ‖Tr[F]‖_∞

    The CATEPT damping provides UV convergence: no separate UV cutoff needed. -/
theorem loop_amplitude_bounded
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (F : α → FCEnd)
    (hF : Integrable (fun x => smulEnd (c.toMeasurePathIntegralModel.weight x) (F x))
                     c.geom.volumeMeasure)
    (hL1 : Integrable (fun x => c.toMeasurePathIntegralModel.damping x) c.geom.volumeMeasure)
    (C : ℝ) (hC : ∀ x, ‖spinorTrace (F x)‖ ≤ C) :
    ‖loopAmplitude c F‖ ≤ partitionFunction c * C := by
  unfold loopAmplitude partitionFunction
  -- pointwise bound: ‖Tr[w·F]‖ ≤ damping · C
  have hpw : ∀ x, ‖spinorTrace (smulEnd (c.toMeasurePathIntegralModel.weight x) (F x))‖ ≤
      c.toMeasurePathIntegralModel.damping x * C := fun x => by
    rw [spinorTrace_smul, norm_mul,
        c.toMeasurePathIntegralModel.norm_weight_eq_damping]
    exact mul_le_mul_of_nonneg_left (hC x) (Real.exp_pos _).le
  -- integrability of the trace integrand
  have hFtrace : Integrable
      (fun x => spinorTrace (smulEnd (c.toMeasurePathIntegralModel.weight x) (F x)))
      c.geom.volumeMeasure :=
    spinorTraceClm.integrable_comp hF
  calc ‖∫ x, spinorTrace (smulEnd (c.toMeasurePathIntegralModel.weight x) (F x))
              ∂c.geom.volumeMeasure‖
      ≤ ∫ x, ‖spinorTrace (smulEnd (c.toMeasurePathIntegralModel.weight x) (F x))‖
              ∂c.geom.volumeMeasure :=
          norm_integral_le_integral_norm _
    _ ≤ ∫ x, c.toMeasurePathIntegralModel.damping x * C ∂c.geom.volumeMeasure :=
          integral_mono hFtrace.norm (hL1.mul_const C) hpw
    _ = (∫ x, c.toMeasurePathIntegralModel.damping x ∂c.geom.volumeMeasure) * C :=
          MeasureTheory.integral_mul_const _ _

end -- noncomputable section

end CATEPTMain.CATEPT.CATEPT
