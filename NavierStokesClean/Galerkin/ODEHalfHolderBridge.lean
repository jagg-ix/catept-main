import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Function.LpSeminorm.CompareExp
import Mathlib.MeasureTheory.Function.L2Space
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Data.Real.ConjExponents
import NavierStokesClean.Galerkin.GalerkinVelocityDerivative

/-!
# AFP ODE Bridge: Abstract ½-Hölder bound (Simon 1987 Lemma 5)

## Purpose

This file provides the **abstract** ½-Hölder time-translation bound:

  `‖f(t) - f(s)‖ ≤ M · √|t-s|`

for any Banach-space curve `f : ℝ → E` whose derivative satisfies
an L²-in-time bound `∫_s^t ‖f'(r)‖² dr ≤ M²`.

This is the mathematical core of **Simon (1987) Lemma 5** (Ann. Mat. Pura
Appl. 146), extracted from the Galerkin-NS context into a purely analytic
statement that can be proved using only Mathlib's ODE/integral infrastructure.

## Proof strategy (Simon 1987 Lemma 5, abstract form)

```
1. FTC:          f(t) - f(s) = ∫_s^t f'(r) dr
2. Norm-integral: ‖f(t)-f(s)‖ ≤ ∫_s^t ‖f'(r)‖ dr
3. Cauchy-Schwarz for L² on [s,t]:
     ∫_s^t ‖f'(r)‖ dr ≤ √(t-s) · (∫_s^t ‖f'(r)‖² dr)^(1/2)
   (Mathlib: integral_mul_le_Lp_mul_Lq_of_nonneg, HolderConjugate.two_two)
4. L² bound:     (∫_s^t ‖f'(r)‖² dr)^(1/2) ≤ M
5. Conclude:     ‖f(t)-f(s)‖ ≤ M · √(t-s)
```

## Discharge plan for `galerkin_velocity_derivative_bound`

Once `half_holder_from_l2_deriv_bound` is fully proved (the CS step below
needs `MemLp` conditions), discharge `galerkin_velocity_derivative_bound` by:
  - Supplying `f = traj_seq N`, `f' = d/dt traj_seq N` from the Galerkin ODE
  - The L² bound `∫₀ᵀ ‖(d/dt u_N)(r)‖² dr ≤ C₀²/(2ν)` from the NS energy
    identity + spectral estimate (requires Phase 5D spatial carrier)

## References

- Simon (1987) Ann. Mat. Pura Appl. 146, Lemma 5
- Temam (1984) Ch.III §1, Galerkin energy estimate
- Muha-Čanić (2018) arXiv:1810.11828, Theorem 3.1 condition (A3)
-/

set_option autoImplicit false

namespace NavierStokesClean.Galerkin.ODEHalfHolderBridge

open MeasureTheory intervalIntegral Set Real

/-! ## §1. Cauchy-Schwarz auxiliary (L1 ≤ √T · L2 for interval integrals) -/

/-- **Cauchy-Schwarz for interval integrals**: the L¹ norm of a nonneg function over [s,t]
    is bounded by `√(t-s) · (L² norm)`.

    This follows from `integral_mul_le_Lp_mul_Lq_of_nonneg` (Hölder p=q=2) applied
    to f=1, g=φ on the restricted measure, plus `integral_const = t-s`.

    **Discharge**: `integral_mul_le_Lp_mul_Lq_of_nonneg` with `HolderConjugate.two_two`,
    `hf_nonneg = eventually_of_forall (fun _ => le_refl 1)`,
    `hg_nonneg = eventually_of_forall (fun _ => norm_nonneg _)`,
    and `measure_Ioc_eq_ofReal (hst)` for the constant integral. -/
lemma integral_norm_le_sqrt_mul_sqrt_integral_norm_sq
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {s t : ℝ} (hst : s ≤ t) (g : ℝ → E)
    (hint_sq : IntervalIntegrable (fun r => ‖g r‖^2) volume s t) :
    ∫ r in s..t, ‖g r‖ ≤ Real.sqrt (t - s) * Real.sqrt (∫ r in s..t, ‖g r‖^2) := by
  rw [intervalIntegral.integral_of_le hst, intervalIntegral.integral_of_le hst]
  set μ := volume.restrict (Ioc s t)
  -- IntegrableOn (‖g·‖²) from hint_sq
  have hg_intOn : IntegrableOn (fun r => ‖g r‖^2) (Ioc s t) volume :=
    (intervalIntegrable_iff_integrableOn_Ioc_of_le hst).mp hint_sq
  -- AEStronglyMeasurable (‖g·‖): ‖g r‖ = √(‖g r‖²) and √ is continuous
  have hg_meas : AEStronglyMeasurable (fun r => ‖g r‖) μ := by
    have hm2 := hg_intOn.aestronglyMeasurable
    have heq : (fun r => ‖g r‖) = fun r => Real.sqrt (‖g r‖^2) := by
      ext r; exact (Real.sqrt_sq (norm_nonneg _)).symm
    rw [heq]
    exact Real.continuous_sqrt.comp_aestronglyMeasurable hm2
  -- MemLp conditions for Hölder (convert 2 : ℝ≥0∞ ↔ ENNReal.ofReal 2)
  have hg_memLp2 : MemLp (fun r => ‖g r‖) 2 μ :=
    (memLp_two_iff_integrable_sq_norm hg_meas).mpr (by
      simp only [Real.norm_eq_abs, abs_of_nonneg (norm_nonneg _)]; exact hg_intOn)
  have hg_memLpR : MemLp (fun r => ‖g r‖) (ENNReal.ofReal 2) μ := by
    have : ENNReal.ofReal 2 = 2 := by norm_num
    rwa [this]
  have h1_memLpR : MemLp (fun _ : ℝ => (1:ℝ)) (ENNReal.ofReal 2) μ := by
    have : ENNReal.ofReal 2 = 2 := by norm_num
    rw [this]; exact memLp_const 1
  -- Apply Hölder (CS p=q=2): ∫ 1·‖g r‖ ≤ (∫ 1^2)^(1/2) · (∫ ‖g r‖^2)^(1/2)
  have hCS := MeasureTheory.integral_mul_le_Lp_mul_Lq_of_nonneg
    (HolderConjugate.two_two) (μ := μ)
    (f := fun _ => (1:ℝ)) (g := fun r => ‖g r‖)
    (Filter.Eventually.of_forall fun _ => zero_le_one)
    (Filter.Eventually.of_forall fun _ => norm_nonneg _)
    h1_memLpR hg_memLpR
  simp only [one_mul, one_rpow] at hCS
  -- ∫ 1 ∂(volume.restrict (Ioc s t)) = t - s
  have hConst : ∫ _ : ℝ, (1:ℝ) ∂μ = t - s := by
    rw [MeasureTheory.integral_const, smul_eq_mul, mul_one,
        measureReal_restrict_apply_univ, Measure.real,
        Real.volume_Ioc, ENNReal.toReal_ofReal (sub_nonneg.mpr hst)]
  rw [hConst] at hCS
  -- ‖g a‖^(2:ℝ) = ‖g a‖^2 (npow) via Real.rpow_natCast
  have hEq : (fun a => ‖g a‖ ^ (2:ℝ)) = (fun a => ‖g a‖ ^ 2) := by
    ext r; exact_mod_cast Real.rpow_natCast (‖g r‖) 2
  simp_rw [hEq] at hCS
  rwa [← Real.sqrt_eq_rpow, ← Real.sqrt_eq_rpow] at hCS

/-! ## §2. Main abstract ½-Hölder theorem -/

/-- **Abstract Simon Lemma 5: ½-Hölder bound from L² derivative control**.

    For any Banach-space curve `f` with derivative `f'` satisfying
    `∫_s^t ‖f'(r)‖² dr ≤ M²`, we get the ½-Hölder bound:
      `‖f(t) - f(s)‖ ≤ M · √(t - s)`

    This is the analytical core of Simon (1987) Lemma 5.
    The proof uses FTC + norm-integral bound + Cauchy-Schwarz.

    **Status**: Steps 1, 2, 4 fully proved; step 3 (CS) leaves `sorry`
    in `integral_norm_le_sqrt_mul_sqrt_integral_norm_sq` above.
    Closes once `MemLp` conditions are formalized for the restricted measure. -/
theorem half_holder_from_l2_deriv_bound
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
    {s t : ℝ} (hst : s ≤ t)
    {f f' : ℝ → E} {M : ℝ} (hM : 0 ≤ M)
    (hDiff : ∀ x ∈ uIcc s t, HasDerivAt f (f' x) x)
    (hint : IntervalIntegrable f' volume s t)
    (hint_sq : IntervalIntegrable (fun r => ‖f' r‖^2) volume s t)
    (hL2 : ∫ r in s..t, ‖f' r‖^2 ≤ M^2) :
    ‖f t - f s‖ ≤ M * Real.sqrt (t - s) := by
  -- Step 1: FTC — f(t) - f(s) = ∫_s^t f'(r) dr
  have hFTC : ∫ r in s..t, f' r = f t - f s :=
    intervalIntegral.integral_eq_sub_of_hasDerivAt hDiff hint
  -- Step 2: Norm-integral bound
  have hNorm : ‖f t - f s‖ ≤ ∫ r in s..t, ‖f' r‖ := by
    calc ‖f t - f s‖
        = ‖∫ r in s..t, f' r‖ := by rw [hFTC]
      _ ≤ ∫ r in s..t, ‖f' r‖ := intervalIntegral.norm_integral_le_integral_norm hst
  -- Step 3: Cauchy-Schwarz: ∫_s^t ‖f'(r)‖ ≤ √(t-s) · √(∫_s^t ‖f'(r)‖²)
  have hCS := integral_norm_le_sqrt_mul_sqrt_integral_norm_sq hst f' hint_sq
  -- Step 4: L² bound: √(∫_s^t ‖f'(r)‖²) ≤ M
  have hL2sq : Real.sqrt (∫ r in s..t, ‖f' r‖^2) ≤ M := by
    have hIntNonneg : 0 ≤ ∫ r in s..t, ‖f' r‖^2 :=
      intervalIntegral.integral_nonneg hst (fun r _ => sq_nonneg _)
    calc Real.sqrt (∫ r in s..t, ‖f' r‖^2)
        ≤ Real.sqrt (M^2) := Real.sqrt_le_sqrt hL2
      _ = M := Real.sqrt_sq hM
  -- Step 5: Combine
  have hTsqrt : 0 ≤ Real.sqrt (t - s) := Real.sqrt_nonneg _
  calc ‖f t - f s‖
      ≤ ∫ r in s..t, ‖f' r‖ := hNorm
    _ ≤ Real.sqrt (t - s) * Real.sqrt (∫ r in s..t, ‖f' r‖^2) := hCS
    _ ≤ Real.sqrt (t - s) * M := by
        apply mul_le_mul_of_nonneg_left hL2sq hTsqrt
    _ = M * Real.sqrt (t - s) := mul_comm _ _

/-! ## §3. Connection to galerkin_velocity_derivative_bound -/

/-- **Discharge route for `galerkin_velocity_derivative_bound`**.

    This theorem shows that `galerkin_velocity_derivative_bound` follows from
    `half_holder_from_l2_deriv_bound` once the NS Galerkin ODE L² derivative
    bound is established.

    The remaining gap: we need
      `hDeriv_l2 : ∫ r in 0..T, ‖(d/dt traj N)(r)‖² ≤ (C₀ / √(2ν))² * |t - s| / (t - s)`
    which requires:
      - Phase 5D spatial carrier (∇, div, H¹ norms, spectral projection P_N)
      - NS energy identity: `ν ∫₀ᵀ ‖∇u_N‖² dt ≤ ‖u_N(0)‖²/2 ≤ C₀²/2`
      - Galerkin ODE: `d/dt u_N = P_N(νΔu_N - (u_N·∇)u_N)` → H^{-1} bound on u_N'
      - Simon's duality argument: `‖u_N'‖_{H^{-1}} ≤ ν‖∇u_N‖ + ‖u_N‖·‖∇u_N‖`
        → `∫ ‖u_N'‖² ≤ C₀²/(2ν)` by Cauchy-Schwarz + energy bound.

    **Task**: `afp_leverage_ode_galerkin_equicont_20260408` -/
theorem galerkin_velocity_derivative_bound_from_abstract
    (traj : NavierStokesClean.Trajectory)
    (hNS : NavierStokesClean.SatisfiesNSPDE NavierStokesClean.nsNu traj)
    (C₀ : ℝ) (hC₀ : 0 < C₀) (hInit : ‖traj 0‖ ≤ C₀)
    (T : ℝ) (hT : 0 < T)
    -- The gap: L² derivative bound from NS energy identity (Phase 5D)
    (hDerivL2 : ∀ s t : ℝ, s ∈ Icc 0 T → t ∈ Icc 0 T → s ≤ t →
      ∀ traj_deriv : ℝ → NavierStokesClean.NSField,
      IntervalIntegrable traj_deriv volume s t →
      IntervalIntegrable (fun r => ‖traj_deriv r‖^2) volume s t →
      (∀ x ∈ uIcc s t, HasDerivAt traj (traj_deriv x) x) →
      ∫ r in s..t, ‖traj_deriv r‖^2 ≤
        (C₀ / Real.sqrt (2 * (NavierStokesClean.nsNu : ℝ)))^2) :
    ∀ s t : ℝ, s ∈ Icc 0 T → t ∈ Icc 0 T →
      ‖traj t - traj s‖ ≤
        (C₀ / Real.sqrt (2 * (NavierStokesClean.nsNu : ℝ))) * Real.sqrt |t - s| := by
  intro s t hs ht
  -- Route through `half_holder_from_l2_deriv_bound`
  -- The s ≤ t and t ≤ s cases are symmetric via |t - s|
  -- Remaining: supply HaDerivAt, IntervalIntegrable from hNS.hCont + Galerkin ODE
  -- and close with hDerivL2.
  sorry -- Blocked on Phase 5D: HasDerivAt traj from Galerkin ODE

end NavierStokesClean.Galerkin.ODEHalfHolderBridge
