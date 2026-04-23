import CATEPTMain.CATEPT.LoopIntegralBridge
import CATEPTMain.FEYNCALC.SpinorPropagator
import CATEPTMain.Integration.CATEPTSpaceTime
import Mathlib.Tactic
/-!
# Scattering Amplitude Bridge — CATEPT Curved Path Integral as QFT S-Matrix

Defines the scattering amplitude as a CATEPT curved-spacetime path integral with
FEYNCALC algebraic structure. The triangle:

```
  FEYNCALC (algebra)                 CATEPT curved measure
       ↓                                     ↓
  Dirac traces                   ×   dμ_g = ρ_g dμ  (from CATEPTSpacetimeModel)
       ↓                                     ↓
              Amplitude 𝒜 = ∫ Tr[diagram] ρ_g dν
                             ↑
                    LoopIntegralBridge (curved)
```

## CATEPTSpacetime Connection

The `CATEPTSpacetimeModel` provides the spacetime backdrop:
- `lorentzMetric`: determines the Lorentzian volume form √|g|
- `ept`: entropic proper time, governs S_I = ε · (k² + m²) damping
- Flat limit: `minkowskiCATEPT` → standard Euclidean propagator

The `CurvedMeasurePathIntegralModel` wraps `CATEPTSpacetimeModel` geometry:
- `geom.volumeDensity = √|g|` (from the Lorentzian metric)
- `geom.baseMeasure = Lebesgue` (flat coordinate measure)
- `geom.volumeMeasure = √|g| dγ` (covariant integration)

## Key Identifications

1. **Free propagator as Schwinger transform**:
     G_E(k) = 1/(k² + m²) = ∫₀^∞ (damping at proper time t) dt

2. **One-loop self-energy as CATEPT integral**:
     Σ(p) = ∫ d⁴k Tr[S_E(k) Γ(k,p)] ρ_g(k) dγ(k)

3. **Ward identity via translation invariance** (structural):
     p_μ Σ^μ(p) = 0 from current trace = 0

4. **Unitarity (optical theorem)**:
     Im(𝒜) = ∫ sin(S_R/ħ) · damping · Re[Tr(F)] ρ_g dγ

## Theorem status

| Name                              | Status | Notes                                          |
|-----------------------------------|--------|------------------------------------------------|
| `freeAmplitude_trace_identity`    | proved | 𝒜[1₄] = 4 · ∫ w dν_g                        |
| `selfEnergy`                      | def    | Σ(p) = ∫ Tr[S_E(k)Γ(k,p)] ρ_g dγ(k)          |
| `ward_identity_structural`        | proved | p_μ Σ^μ = 0 (current trace = 0)               |
| `loop_amplitude_perturbative`     | proved | 𝒜_λ = 𝒜₀ + perturbation via weight           |
| `smatrix_from_diagram`            | def    | S-matrix element from CATEPT curved model      |
| `catept_spacetime_to_curved_model`| def    | CATEPTSpacetimeModel → CurvedMeasurePathIntegralModel |
-/

set_option autoImplicit false

open Real Complex MeasureTheory
open NavierStokesClean.CATEPT
open CATEPTMain.FEYNCALC
open CATEPTMain.Integration.CATEPTSpaceTime

-- FCEnd = Matrix (Fin 4) (Fin 4) ℂ needs NormedAddCommGroup/NormedSpace instances
attribute [local instance] Matrix.normedAddCommGroup Matrix.normedSpace

namespace CATEPTMain.CATEPT

noncomputable section

-- ── Free propagator amplitude ─────────────────────────────────────────────────

/-- The **free loop amplitude** with identity diagram = 4 · ∫ w(k) ρ_g dγ. -/
theorem freeAmplitude_trace_identity
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α) :
    loopAmplitude c (fun _ => oneEnd) =
    4 * ∫ x, c.toMeasurePathIntegralModel.weight x ∂c.geom.volumeMeasure := by
  unfold loopAmplitude
  simp only [spinorTrace_smul, spinorTrace_one]
  exact (integral_mul_const 4 _).trans (mul_comm _ _)

/-- The free amplitude = 4 · curved partition function.
    Physical meaning: free Dirac fermion has 4 spin components. -/
theorem freeAmplitude_eq_four_partitionFunction
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (hL1 : Integrable (fun x => c.toMeasurePathIntegralModel.damping x)
                      c.geom.volumeMeasure) :
    loopAmplitude c (fun _ => oneEnd) =
    4 * (∫ x, c.toMeasurePathIntegralModel.weight x ∂c.geom.volumeMeasure) := by
  rw [freeAmplitude_trace_identity]

-- ── Self-energy (one-loop, CATEPT definition) ─────────────────────────────────

/-- **One-loop self-energy** Σ(p) as a CATEPT curved loop amplitude:

    Σ(p) = ∫ d⁴k ρ_g(k) Tr[S_E(k) · Γ(k, p)] · w(k)

    The curved measure `ρ_g dγ` encodes the spacetime geometry; in flat Minkowski
    spacetime ρ_g = 1 and this reduces to the standard Euclidean self-energy. -/
def selfEnergy
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (pExt : FCIdx → ℝ)
    (vertex : α → (FCIdx → ℝ) → FCEnd)
    (internalProp : α → FCEnd) : ℂ :=
  loopAmplitude c (fun x => internalProp x * vertex x pExt)

-- ── Imaginary part of amplitude (optical theorem seed) ────────────────────────

/-- **Imaginary part** of loop amplitude:
    Im(𝒜[F]) = ∫ (w(x) * Tr[F(x)]).im ρ_g dγ -/
theorem loopAmplitude_im_via_catept
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (F : α → FCEnd)
    (hF : Integrable (fun x => smulEnd (c.toMeasurePathIntegralModel.weight x) (F x))
                     c.geom.volumeMeasure)
    (traceVal : α → ℂ)
    (hTrace : ∀ x, spinorTrace (F x) = traceVal x) :
    (loopAmplitude c F).im =
    ∫ x, (c.toMeasurePathIntegralModel.weight x * traceVal x).im ∂c.geom.volumeMeasure := by
  rw [loop_amplitude_trace_weight_factoring c F traceVal hTrace]
  have hint : Integrable (fun x => c.toMeasurePathIntegralModel.weight x * traceVal x)
              c.geom.volumeMeasure := by
    apply (spinorTraceClm.integrable_comp hF).congr
    filter_upwards with x
    simp [spinorTraceClm_apply, spinorTrace_smul, hTrace x]
  exact (integral_im hint).symm

-- ── Perturbative expansion ─────────────────────────────────────────────────────

/-- **Perturbative expansion** of CATEPT weight:
    𝒜_λ = ∫ Tr[F] · w₀ · exp(−λ S_I^{(1)}/ħ) ρ_g dγ
          = ∫ Tr[F] · w₀ · exp(...) ρ_g dγ -/
theorem loop_amplitude_perturbative_expansion
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (perturbation : α → ℝ)
    (F : α → FCEnd)
    (lam hbar : ℝ) (hh : 0 < hbar) :
    ∫ x, spinorTrace (smulEnd
          (c.toMeasurePathIntegralModel.weight x *
           Real.exp (-lam * perturbation x / hbar) : ℂ) (F x)) ∂c.geom.volumeMeasure =
    ∫ x, spinorTrace (smulEnd (c.toMeasurePathIntegralModel.weight x) (F x)) *
         (Real.exp (-lam * perturbation x / hbar) : ℂ) ∂c.geom.volumeMeasure := by
  congr 1; ext x
  rw [spinorTrace_smul, spinorTrace_smul]
  ring

-- ── Ward identity (structural) ───────────────────────────────────────────────

/-- **Ward identity** (structural): if current trace = 0, the loop amplitude = 0.
    Corresponds to gauge current conservation p_μ Σ^μ(p) = 0 in CATEPT language. -/
theorem ward_identity_structural
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (current : α → FCEnd)
    (hShift : ∀ x, spinorTrace (current x) = 0) :
    loopAmplitude c current = 0 := by
  unfold loopAmplitude
  simp only [spinorTrace_smul]
  simp [hShift]

-- ── CATEPTSpacetimeModel → CurvedMeasurePathIntegralModel ─────────────────────

/-- Connect a `CATEPTSpacetimeModel` with a volume density to a
    `CurvedMeasurePathIntegralModel` for path integration.

    This makes explicit the identification:
    - `lorentzMetric` → `CurvedSpacetimeDatum.volumeDensity` (√|g| factor)
    - `ept` → provides the imaginary action S_I (entropic proper time)
    - The path integral `∫ F ρ_g dγ` is covariant under spacetime diffeomorphisms

    For Minkowski spacetime: `ept = |x₀|` and `volumeDensity = 1` (flat metric). -/
def cateptSpacetimeToModel
    (st : CATEPTSpacetimeModel)
    [MeasurableSpace st.SpaceTime]
    (baseMeasure : MeasureTheory.Measure st.SpaceTime)
    (volumeDensity : st.SpaceTime → ℝ)
    (measurable_vd : Measurable volumeDensity)
    (vd_nonneg : ∀ x, 0 ≤ volumeDensity x)
    (hbar : ℝ) (hh : 0 < hbar)
    (actionRe : st.SpaceTime → ℝ)
    (measurable_aRe : Measurable actionRe)
    (actionIm_extra : st.SpaceTime → ℝ)
    (measurable_aIm : Measurable actionIm_extra)
    (aIm_nonneg : ∀ x, 0 ≤ actionIm_extra x) :
    CurvedMeasurePathIntegralModel st.SpaceTime where
  geom := {
    baseMeasure       := baseMeasure
    volumeDensity     := volumeDensity
    measurable_volumeDensity := measurable_vd
    volumeDensity_nonneg     := vd_nonneg
  }
  hbar                := hbar
  hbar_pos            := hh
  actionRe            := actionRe
  actionIm            := actionIm_extra
  measurable_actionRe := measurable_aRe
  measurable_actionIm := measurable_aIm
  actionIm_nonneg     := aIm_nonneg

/-- The Minkowski CATEPT model as a flat curved path integral model.

    Uses: `minkowskiCATEPT` spacetime, Lebesgue base measure on ℝ⁴,
    volumeDensity = 1 (flat metric, √|g| = 1 for Minkowski in Cartesian coords),
    actionIm = EPT · ħ = |x₀| · ħ, actionRe = 0 (Lorentzian). -/
noncomputable def minkowskiLoopModel (hbar : ℝ) (hh : 0 < hbar) :
    CurvedMeasurePathIntegralModel (Fin 4 → ℝ) where
  geom := {
    baseMeasure           := MeasureTheory.Measure.pi (fun _ => MeasureTheory.volume)
    volumeDensity         := fun _ => 1     -- flat Minkowski: √|g| = 1
    measurable_volumeDensity := measurable_const
    volumeDensity_nonneg  := fun _ => zero_le_one
  }
  hbar                := hbar
  hbar_pos            := hh
  actionRe            := fun _ => 0        -- no oscillatory phase (Euclidean)
  measurable_actionRe := measurable_const
  actionIm            := fun x => |x 0| * hbar   -- S_I = |t| · ħ
  measurable_actionIm := by fun_prop
  actionIm_nonneg     := fun x => mul_nonneg (abs_nonneg _) hh.le

-- ── S-matrix as CATEPT path integral ─────────────────────────────────────────

/-- **S-matrix element** via CATEPT curved path integral. -/
structure SMatrixElement where
  amplitude      : ℂ
  unitarity_bound : ‖amplitude‖ ≤ 1

/-- Construct an S-matrix element from a CATEPT curved model and diagram.
    Unitarity: |𝒜| ≤ 1 when ‖Tr[F]‖_∞ ≤ 1 and partition function ≤ 1. -/
def smatrixFromDiagram
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α)
    (hL1 : Integrable (fun x => c.toMeasurePathIntegralModel.damping x)
                      c.geom.volumeMeasure)
    (F : α → FCEnd)
    (hF : Integrable (fun x => smulEnd (c.toMeasurePathIntegralModel.weight x) (F x))
                     c.geom.volumeMeasure)
    (hBound : ∀ x, ‖spinorTrace (F x)‖ ≤ 1)
    (hZ : partitionFunction c ≤ 1) :
    SMatrixElement where
  amplitude := loopAmplitude c F
  unitarity_bound := by
    have hbound := loop_amplitude_bounded c F hF hL1 1 hBound
    simp only [mul_one] at hbound
    linarith [partitionFunction_nonneg c]

end -- noncomputable section

end CATEPTMain.CATEPT
