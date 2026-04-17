import CATEPTMain.AFPBridge.CATEPT.CATEPTPrelude
import CATEPTMain.AFPBridge.CATEPT.ComplexMeasureBridge
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.MeasureTheory.Integral.Bochner.ContinuousLinearMap
/-!
# CATEPT Port — Feynman–Kac ↔ CAT/EPT Bridge

Formal link between the Feynman–Kac formula (Euclidean path integral) and the
CAT/EPT complex path integral through entropic proper time τ_ent = S_I/ħ.

## The Feynman–Kac formula (Kac 1949)

  u(x,t) = 𝔼[exp(−∫ₜᵀ V(Xₛ,s)ds) · ψ(X_T) | X_t = x]

where u solves the backward parabolic PDE:

  ∂u/∂t + μ ∂u/∂x + ½σ² ∂²u/∂x² − V·u = 0.

## The CAT/EPT identification

  τ_ent = S_I[φ]/ħ  ↔  ∫ₜᵀ V(Xₛ,s) ds   (cumulative potential)
  H_I               ↔  V(x,t)             (pointwise FK potential)
  exp(−τ_ent)        ↔  exp(−∫V ds)       (FK damping factor)

## Source

Ported from:
  `navier-stokes-project-clean-translator/NavierStokesClean/CATEPT/FeynmanKacBridge.lean`

## Theorem status

| Name                                    | Status   | Notes                               |
|-----------------------------------------|----------|-------------------------------------|
| `euclidean_weight_is_real_positive`     | proved   | S_R=0 → weight is real positive     |
| `entropic_time_is_cumulative_potential` | proved   | τ_ent = ∫V ds (constant V)          |
| `fk_weight_equals_catept_damping`       | proved   | exp(−VT) = exp(−τ_ent)              |
| `damping_satisfies_decay_ODE`           | proved   | d/dt[exp(−Vt)] = −V·exp(−Vt)       |
| `decay_ODE_initial_condition`           | proved   | w(0) = 1                            |
| `catept_fk_euclidean_correspondence`    | proved   | |w| = exp(−τ_ent) (main)            |
| `complex_FK_bridge`                     | axiom    | Complex case: open (Glimm–Jaffe)    |
| `fk_path_integral_eq_complex_measure`   | proved   | ∫_A w dγ = ν(A) (canonical link)    |
| `euclidean_fk_measure_is_real_valued`   | proved   | Im(ν(A)) = 0 when S_R = 0          |
| `fk_partition_bounds_total_variation`   | proved   | ‖ν(univ)‖ ≤ Z₀ (FK normalization)  |
| `fk_complex_measure_from_finite_space`  | proved   | [IsFiniteMeasure] → ∃ ν             |
-/

set_option autoImplicit false

open Real Complex MeasureTheory

namespace CATEPTMain.AFPBridge.CATEPT

-- ── Euclidean case: S_R = 0 → pure FK ────────────────────────────────────────

/-- When S_R = 0 (Euclidean rotation), the complex weight reduces to a real
    positive FK weight: w(φ) = exp(−τ_ent) ∈ ℝ, w > 0. (Kac 1949) -/
theorem euclidean_weight_is_real_positive
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    (hRe : ∀ x, m.actionRe x = 0) (x : α) :
    m.weight x = (Real.exp (-(m.actionImScaled x)) : ℂ) := by
  rw [MeasurePathIntegralModel.weight_factorizes]
  have : m.actionReScaled x = 0 := by
    unfold MeasurePathIntegralModel.actionReScaled
    simp [hRe x]
  simp [this]

/-- In the Euclidean case the damping is strictly positive. -/
theorem euclidean_weight_pos
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    (hRe : ∀ x, m.actionRe x = 0) (x : α) :
    (0 : ℝ) < m.damping x :=
  m.damping_pos x

-- ── Entropic time as cumulative FK potential ──────────────────────────────────

/-- For constant potential V over [0,T]:
      exp(−∫₀ᵀ V ds) = exp(−VT) = exp(−τ_ent)
    when τ_ent = VT = S_I/ħ. -/
theorem entropic_time_is_cumulative_potential
    (V T hbar : ℝ) (hV : 0 ≤ V) (hT : 0 < T) (hh : 0 < hbar)
    (S_I : ℝ) (hSI : S_I = V * T * hbar) :
    entropicTime hbar S_I = V * T := by
  unfold entropicTime
  rw [hSI]; field_simp [hh.ne']

/-- FK weight exp(−VT) equals CAT/EPT damping exp(−τ_ent). -/
theorem fk_weight_equals_catept_damping
    (V T hbar : ℝ) (hh : 0 < hbar) (S_I : ℝ) (hSI : S_I = V * T * hbar) :
    Real.exp (-(V * T)) = Real.exp (-(entropicTime hbar S_I)) := by
  congr 1; rw [neg_inj]; unfold entropicTime
  rw [hSI]; field_simp [hh.ne']

-- ── Decay ODE: FK backward equation ──────────────────────────────────────────

/-- The FK damping w(t) = exp(−Vt) satisfies dw/dt = −V·w.
    This is the eigenmode version of the FK backward equation.
    CAT/EPT damping exp(−τ_ent) satisfies the same with V = H_I/ħ. -/
theorem damping_satisfies_decay_ODE (V : ℝ) (hV : 0 ≤ V) :
    ∀ t : ℝ, HasDerivAt (fun t => Real.exp (-V * t))
                        (-V * Real.exp (-V * t)) t := by
  intro t
  have hf : HasDerivAt (fun t => -V * t) (-V) t := by
    simpa using (hasDerivAt_id t).const_mul (-V)
  have hg := (Real.hasDerivAt_exp (-V * t)).comp t hf
  simp only [Function.comp] at hg
  rwa [mul_comm] at hg

/-- Initial condition w(0) = 1. -/
theorem decay_ODE_initial_condition (V : ℝ) (t : ℝ) (ht : t = 0) :
    Real.exp (-V * t) = 1 := by simp [ht]

-- ── Main Euclidean correspondence ─────────────────────────────────────────────

/-- **Main correspondence** (proved half):
    The CAT/EPT weight norm equals the FK damping factor: |w| = exp(−τ_ent). -/
theorem catept_fk_euclidean_correspondence
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) :
    ∀ x : α, ‖m.weight x‖ = Real.exp (-(m.actionImScaled x)) :=
  m.weight_norm_is_damping

-- ── Complex FK bridge (open problem) ─────────────────────────────────────────

/-- **Complex FK Bridge** (axiom — open mathematical problem).

    The CAT/EPT complex path integral with weight
      w(φ) = exp(i S_R[φ]/ħ − S_I[φ]/ħ)
    is conjectured to be a FK representation of the complex parabolic PDE:
      ∂u/∂t + (A − V)u = 0,   A = ½σ²∂², V = H_I/ħ − i H_R/ħ

    STATUS: Open. Explicitly identified as an open problem in the literature.
    "The complex case, needed in quantum mechanics, is still an open question."
    — Glimm & Jaffe, "Quantum Physics: A Functional Integral Point of View"
      (2nd ed., 1987), pp. 43–44. -/
axiom complex_FK_bridge
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    (obs : α → ℂ) (m_obs : Measurable obs) :
    True  -- phase2_research: requires Itô diffusion on α + complex FK theorem

-- ── ComplexMeasureBridge: FK structural links ────────────────────────────────

/-- The FK path integral over a measurable set A equals the complex measure ν(A).
    This is the canonical identification: the FK integral IS the complex measure. -/
theorem fk_path_integral_eq_complex_measure
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    (hL1 : Integrable (fun x => m.damping x) m.μ)
    (s : Set α) (hs : MeasurableSet s) :
    ∫ x in s, m.weight x ∂m.μ = catept_complex_measure m hL1 s :=
  (catept_complex_measure_apply m hL1 s hs).symm

/-- In the Euclidean sector (S_R = 0), the FK complex measure ν(A) is real-valued:
    ν(A) = ∫_A exp(−τ_ent(x)) dγ ∈ ℝ ⊆ ℂ.
    The Kac formula gives purely real positive FK weights when there is no phase. -/
theorem euclidean_fk_measure_is_real_valued
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    (hL1 : Integrable (fun x => m.damping x) m.μ)
    (hRe : ∀ x, m.actionRe x = 0)
    (s : Set α) (hs : MeasurableSet s) :
    (catept_complex_measure m hL1 s).im = 0 := by
  rw [catept_complex_measure_apply m hL1 s hs]
  have hweq : ∀ x, m.weight x = (m.damping x : ℂ) :=
    fun x => euclidean_weight_is_real_positive m hRe x
  simp_rw [hweq]
  -- ∫_A (damping x : ℂ) dμ = ↑(∫_A damping x dμ) since damping is real-valued
  rw [show ∫ x in s, (m.damping x : ℂ) ∂m.μ =
          ↑(∫ x in s, m.damping x ∂m.μ) from integral_ofReal (𝕜 := ℂ)]
  exact Complex.ofReal_im _

/-- The FK partition function Z₀ = ∫ exp(−S_I/ħ) dγ bounds the total variation of ν.
    This is the Feynman–Kac normalization: |ν|(α) ≤ Z₀ < ∞. -/
theorem fk_partition_bounds_total_variation
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    (hL1 : Integrable (fun x => m.damping x) m.μ) :
    ‖catept_complex_measure m hL1 Set.univ‖ ≤ partitionFunction m :=
  catept_complex_measure_norm_le m hL1 Set.univ MeasurableSet.univ

/-- The CAT/EPT complex measure exists on any finite FK state space.
    The FK potential gives exp(−V/ħ) ≤ 1 pointwise; finiteness gives L¹. -/
theorem fk_complex_measure_from_finite_space
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α)
    [IsFiniteMeasure m.μ] :
    ∃ ν : VectorMeasure α ℂ, ∀ s : Set α, MeasurableSet s →
        ν s = ∫ x in s, m.weight x ∂m.μ :=
  ⟨catept_complex_measure m (catept_measure_exists_from_finite_reference m),
   fun s hs => catept_complex_measure_apply m _ s hs⟩

end CATEPTMain.AFPBridge.CATEPT
