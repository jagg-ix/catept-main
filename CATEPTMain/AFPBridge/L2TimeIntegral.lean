import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.MeasureTheory.Function.L2Space
import Mathlib.MeasureTheory.Integral.MeanInequalities
import Mathlib.MeasureTheory.Function.LocallyIntegrable
import Mathlib.MeasureTheory.Function.StronglyMeasurable.Basic
import Mathlib.MeasureTheory.Integral.IntegrableOn
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
import Mathlib.MeasureTheory.Constructions.Pi

/-!
# L² Bounds for Time Integrals (AFPBridge port from OSforGFF, CATEPTSpace-native)

Provides Cauchy-Schwarz and L² time-average bounds used in:
- Galerkin convergence (M2/M3 discharge): ½-Hölder trajectories → L² compactness
- CATEPT OS4 ergodicity: time averages of Galerkin observables → L² convergence
- `half_holder_from_l2_deriv_bound` companion lemmas

## Port source

Adapted from `OSforGFF/General/L2TimeIntegral.lean` (Douglas–Hoback–Mei–Nissim 2026,
v4.29.0, 0 sorry, Apache 2.0).

**CATEPTSpace specialization** (§2): the L² time average bound is stated for
`A : ℝ → CATEPTSpace → E` where `CATEPTSpace = Fin 3 → ℝ`. This uses the canonical
`MeasureSpace CATEPTSpace` (product Lebesgue measure) and avoids whnf kernel loops that
arise from the generic `EuclideanSpace ℝ (Fin 3)` path.

## Main results

1. `sq_norm_setIntegral_le_measure_mul_setIntegral_sq` — Cauchy-Schwarz:
   `‖∫_{[a,b]} f‖² ≤ (b-a) · ∫_{[a,b]} ‖f‖²`

2. `L2_time_average_bound_catept` — L² bound for CATEPTSpace time averages:
   if `∀ s ∈ [0,T], ∫ x : CATEPTSpace, ‖A_s x‖² ≤ M`, then
   `∫ x : CATEPTSpace, ‖(1/T) ∫₀ᵀ A_s(x) ds‖² ≤ M`

## References

- OSforGFF: L2TimeIntegral.lean (same proofs, specialized carrier)
- Billingsley, "Probability and Measure", Ch. 7 (Cauchy-Schwarz, Fubini)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.L2TimeIntegral

open MeasureTheory Set Filter Real

/-- Concrete CAT/EPT spatial carrier used by this module. -/
abbrev CATEPTSpace : Type := Fin 3 → ℝ

/-! ## §1. Abstract Cauchy-Schwarz for Bochner integrals on intervals -/

/-- **Cauchy-Schwarz for Bochner integrals on [a,b]** (general Banach space).

    For `f : ℝ → E` with `‖f‖²` integrable on `Icc a b`:
      `‖∫_{[a,b]} f(x) dx‖² ≤ (b-a) · ∫_{[a,b]} ‖f(x)‖² dx`

    **Port**: OSforGFF `sq_setIntegral_le_measure_mul_setIntegral_sq_proved`. -/
theorem sq_norm_setIntegral_le_measure_mul_setIntegral_sq
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {a b : ℝ} (hab : a ≤ b) (f : ℝ → E)
    (hf_sq : IntegrableOn (fun x => ‖f x‖^2) (Icc a b) volume) :
    ‖∫ x in Icc a b, f x‖^2 ≤ (b - a) * ∫ x in Icc a b, ‖f x‖^2 := by
  by_cases hf_aesm : AEStronglyMeasurable f (volume.restrict (Icc a b))
  · have hpq : (2 : ℝ).HolderConjugate 2 := HolderConjugate.two_two
    haveI : IsFiniteMeasure (volume.restrict (Icc a b)) :=
      Real.isFiniteMeasure_restrict_Icc a b
    -- Both h1 and hf2 are real-valued (‖·‖ ∈ ℝ), so integral_mul_norm_le_Lp_mul_Lq
    -- applies with E = ℝ (no universe mismatch with generic E).
    have h1 : MemLp (fun (_ : ℝ) => (1 : ℝ)) (ENNReal.ofReal 2) (volume.restrict (Icc a b)) := by
      rw [ENNReal.ofReal_ofNat]; exact memLp_const 1
    -- ‖f·‖ is AEStronglyMeasurable since f is
    have hf_norm_aesm : AEStronglyMeasurable (fun x => ‖f x‖) (volume.restrict (Icc a b)) :=
      hf_aesm.norm
    have hf2 : MemLp (fun x => ‖f x‖) (ENNReal.ofReal 2) (volume.restrict (Icc a b)) := by
      rw [ENNReal.ofReal_ofNat]
      exact (memLp_two_iff_integrable_sq hf_norm_aesm).mpr hf_sq
    -- Hölder: ∫ ‖1‖ * ‖‖f‖‖ ≤ (∫ ‖1‖²)^(1/2) * (∫ ‖‖f‖‖²)^(1/2)
    -- = ∫ ‖f‖ ≤ (b-a)^(1/2) * (∫ ‖f‖²)^(1/2)
    have hH := integral_mul_norm_le_Lp_mul_Lq hpq h1 hf2
    simp only [norm_one, one_mul, Real.norm_of_nonneg (norm_nonneg _)] at hH
    -- simplify ∫ (1:ℝ)^(2:ℝ) = b - a
    have hConst : ∫ x in Icc a b, (1 : ℝ)^(2:ℝ) = b - a := by
      simp only [one_rpow]
      rw [setIntegral_const, Measure.real, Real.volume_Icc,
          ENNReal.toReal_ofReal (sub_nonneg.mpr hab), smul_eq_mul, mul_one]
    rw [hConst] at hH
    -- hH is already: ∫ ‖f‖ ≤ (b-a)^(1/2) * (∫ ‖f‖^2)^(1/2)
    -- (simp at line above already simplified ‖‖f a‖‖ → ‖f a‖ and ^(2:ℝ) → ^2)
    -- chain: ‖∫ f‖ ≤ ∫ ‖f‖ ≤ (b-a)^(1/2) * (∫ ‖f‖^2)^(1/2), then square
    have hChain := le_trans (norm_integral_le_integral_norm (f := f)) hH
    have hSq := pow_le_pow_left₀ (norm_nonneg _) hChain 2
    rw [mul_pow] at hSq
    -- Prove the RHS collapses, then close via trans_eq.
    -- (simp only [Real.sq_sqrt hI] doesn't fire when hI has a different bound-var name
    --  than the a-bound integral in hSq; avoid that by proving key with x throughout.)
    -- hSq has ‖f a‖^(2:ℝ) (rpow from Hölder), goal has ‖f x‖^2 (npow from hf_sq).
    -- hI and key must use ^(2:ℝ) to match hSq; then hconv bridges to ^2 for the goal.
    have hI : 0 ≤ ∫ x in Icc a b, ‖f x‖^(2:ℝ) :=
      integral_nonneg (fun _ => Real.rpow_nonneg (norm_nonneg _) _)
    have key : ((b - a) ^ ((1:ℝ)/2)) ^ 2 * ((∫ x in Icc a b, ‖f x‖^(2:ℝ)) ^ ((1:ℝ)/2)) ^ 2 =
               (b - a) * ∫ x in Icc a b, ‖f x‖^(2:ℝ) := by
      simp only [← Real.sqrt_eq_rpow, Real.sq_sqrt (sub_nonneg.mpr hab), Real.sq_sqrt hI]
    have hconv : ∫ x in Icc a b, ‖f x‖^(2:ℝ) = ∫ x in Icc a b, ‖f x‖^2 :=
      setIntegral_congr_fun measurableSet_Icc (fun x _ => Real.rpow_natCast _ 2)
    exact (hSq.trans_eq key).trans_eq (by rw [hconv])
  · -- Not AEStronglyMeasurable ⟹ not integrable ⟹ Bochner integral = 0
    have hni : ¬Integrable f (volume.restrict (Icc a b)) := fun h => hf_aesm h.1
    have h0 : ∫ x in Icc a b, f x = 0 := by
      show ∫ x, f x ∂(volume.restrict (Icc a b)) = 0
      exact integral_undef hni
    rw [h0, norm_zero, zero_pow (by norm_num : 2 ≠ 0)]
    exact mul_nonneg (sub_nonneg.mpr hab) (setIntegral_nonneg measurableSet_Icc (fun x _ => sq_nonneg _))

/-- **Cauchy-Schwarz for time integrals** (pointwise-in-x version):
    for T > 0 and f : ℝ → E with ‖f‖² integrable on [0,T]:
      `‖∫₀ᵀ f(s) ds‖² ≤ T · ∫₀ᵀ ‖f(s)‖² ds` -/
lemma sq_norm_integral_le_T_mul_integral_sq
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    (f : ℝ → E) {T : ℝ} (hT : 0 < T)
    (hf_sq : IntegrableOn (fun s => ‖f s‖^2) (Icc 0 T) volume) :
    ‖∫ s in Icc 0 T, f s‖^2 ≤ T * ∫ s in Icc 0 T, ‖f s‖^2 := by
  have h := sq_norm_setIntegral_le_measure_mul_setIntegral_sq (le_of_lt hT) f hf_sq
  simpa using h

/-! ## §2. L² time average bound (CATEPTSpace-native, concrete Fubini) -/

/-- **Fubini swap for ℝ × CATEPTSpace** (Icc version, real-valued integrand).
    Uses concrete `volume : Measure CATEPTSpace` (product Lebesgue on `Fin 3 → ℝ`). -/
private lemma integral_swap_Icc_catept
    (f : ℝ → CATEPTSpace → ℝ) (T : ℝ)
    (hf : Integrable (fun p : ℝ × CATEPTSpace => f p.1 p.2)
      ((volume.restrict (Icc 0 T)).prod (volume : Measure CATEPTSpace))) :
    ∫ x : CATEPTSpace, ∫ s in Icc 0 T, f s x =
    ∫ s in Icc 0 T, ∫ x : CATEPTSpace, f s x := by
  haveI hFin : IsFiniteMeasure (volume.restrict (Icc 0 T)) :=
    Real.isFiniteMeasure_restrict_Icc 0 T
  haveI hSF : SFinite (volume.restrict (Icc 0 T)) := inferInstance
  -- integral_prod: ∫ p ∂(μ.prod ν) = ∫ s ∂μ, ∫ x ∂ν, f(s,x)
  have h1 : ∫ p : ℝ × CATEPTSpace, f p.1 p.2
        ∂((volume.restrict (Icc 0 T)).prod (volume : Measure CATEPTSpace)) =
      ∫ s in Icc 0 T, ∫ x : CATEPTSpace, f s x :=
    integral_prod _ hf
  -- integral_prod_symm: ∫ p ∂(μ.prod ν) = ∫ x ∂ν, ∫ s ∂μ, f(s,x)  [needs SFinite μ]
  have h2 : ∫ p : ℝ × CATEPTSpace, f p.1 p.2
        ∂((volume.restrict (Icc 0 T)).prod (volume : Measure CATEPTSpace)) =
      ∫ x : CATEPTSpace, ∫ s in Icc 0 T, f s x :=
    integral_prod_symm _ hf
  linarith [h2.symm.trans h1]

/-- **L² bound for time averages** (CATEPTSpace-native).

    For `A : ℝ → CATEPTSpace → E` with uniform L² bound per time slice,
    the rescaled time average satisfies:
      `∫ x : CATEPTSpace, ‖(1/T) · ∫₀ᵀ A_s(x) ds‖² ≤ M_sq`

    Uses `CATEPTSpace = Fin 3 → ℝ` with `MeasureSpace CATEPTSpace` (product Lebesgue),
    avoiding whnf issues from the generic `Ω` path.

    **Port**: OSforGFF `L2_time_average_bound`, specialized carrier `ℂ` → `E : Banach`,
    domain `ℂ`-process → `CATEPTSpace`-indexed spatial field. -/
theorem L2_time_average_bound_catept
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
    (A : ℝ → CATEPTSpace → E) {M_sq T : ℝ} (hT : 0 < T)
    -- Uniform L² bound per time slice
    (h_L2 : ∀ s ∈ Icc 0 T, ∫ x : CATEPTSpace, ‖A s x‖^2 ≤ M_sq)
    -- Product integrability for Fubini
    (h_prod : Integrable (fun p : ℝ × CATEPTSpace => ‖A p.1 p.2‖^2)
        ((volume.restrict (Icc 0 T)).prod (volume : Measure CATEPTSpace)))
    -- Time-slice Cauchy-Schwarz integrability (a.e. in x)
    (h_sq_slice : ∀ᵐ x : CATEPTSpace,
        IntegrableOn (fun s => ‖A s x‖^2) (Icc 0 T) volume)
    -- Measurability of the time average in x
    (h_avg_meas : AEStronglyMeasurable
        (fun x : CATEPTSpace => (1/T) • ∫ s in Icc 0 T, A s x))
    -- Integrability of slice L² norms (for the Fubini bound)
    (h_slice_int : IntegrableOn (fun s => ∫ x : CATEPTSpace, ‖A s x‖^2) (Icc 0 T) volume) :
    ∫ x : CATEPTSpace, ‖(1/T : ℝ) • ∫ s in Icc (0:ℝ) T, A s x‖^2 ≤ M_sq := by
  -- SFinite for volume.restrict (Icc 0 T) (needed by integral_prod_right)
  haveI hFin_T : IsFiniteMeasure (volume.restrict (Icc 0 T)) :=
    Real.isFiniteMeasure_restrict_Icc 0 T
  haveI hSF_T : SFinite (volume.restrict (Icc 0 T)) := inferInstance
  -- RHS: (1/T) * ∫₀ᵀ ‖A_s x‖² ds is integrable in x (from product integrability)
  have hRHS_int : Integrable
      (fun x : CATEPTSpace => (1/T) * ∫ s in Icc 0 T, ‖A s x‖^2) :=
    (h_prod.integral_prod_right).const_mul (1/T)
  -- LHS norm² is AEStronglyMeasurable (continuous composition)
  have hLHS_meas : AEStronglyMeasurable
      (fun x : CATEPTSpace => ‖(1/T : ℝ) • ∫ s in Icc 0 T, A s x‖^2) :=
    (continuous_pow 2).comp_aestronglyMeasurable h_avg_meas.norm
  -- LHS is integrable: bounded pointwise by RHS via Cauchy-Schwarz
  have hLHS_int : Integrable
      (fun x : CATEPTSpace => ‖(1/T : ℝ) • ∫ s in Icc 0 T, A s x‖^2) := by
    apply hRHS_int.mono hLHS_meas
    filter_upwards [h_sq_slice] with x hx
    rw [Real.norm_of_nonneg (sq_nonneg _),
        Real.norm_of_nonneg (mul_nonneg (by positivity)
          (integral_nonneg (fun _ => sq_nonneg _)))]
    rw [norm_smul, Real.norm_of_nonneg (by positivity), mul_pow]
    calc (1/T)^2 * ‖∫ s in Icc 0 T, A s x‖^2
        ≤ (1/T)^2 * (T * ∫ s in Icc 0 T, ‖A s x‖^2) := by
          apply mul_le_mul_of_nonneg_left
          · exact sq_norm_integral_le_T_mul_integral_sq (A · x) hT hx
          · positivity
      _ = 1/T * ∫ s in Icc 0 T, ‖A s x‖^2 := by field_simp
  -- Main calc: Cauchy-Schwarz → pull out (1/T) → Fubini → uniform bound
  calc ∫ x : CATEPTSpace, ‖(1/T : ℝ) • ∫ s in Icc (0:ℝ) T, A s x‖^2
      ≤ ∫ x : CATEPTSpace, (1/T) * ∫ s in Icc 0 T, ‖A s x‖^2 := by
          -- integral_mono_ae works here: MeasureSpace CATEPTSpace provides the instance
          apply integral_mono_ae hLHS_int hRHS_int
          filter_upwards [h_sq_slice] with x hx
          rw [norm_smul, Real.norm_of_nonneg (by positivity), mul_pow]
          calc (1/T)^2 * ‖∫ s in Icc 0 T, A s x‖^2
              ≤ (1/T)^2 * (T * ∫ s in Icc 0 T, ‖A s x‖^2) := by
                apply mul_le_mul_of_nonneg_left
                · exact sq_norm_integral_le_T_mul_integral_sq (A · x) hT hx
                · positivity
            _ = (1/T) * ∫ s in Icc 0 T, ‖A s x‖^2 := by field_simp
    _ = (1/T) * ∫ x : CATEPTSpace, ∫ s in Icc 0 T, ‖A s x‖^2 := by
          -- MeasureSpace CATEPTSpace is available, so integral_const_mul works
          rw [integral_const_mul]
    _ = (1/T) * ∫ s in Icc 0 T, ∫ x : CATEPTSpace, ‖A s x‖^2 := by
          congr 1
          exact integral_swap_Icc_catept (fun s x => ‖A s x‖^2) T h_prod
    _ ≤ (1/T) * (T * M_sq) := by
          apply mul_le_mul_of_nonneg_left _ (by positivity)
          have hVol : (volume : Measure ℝ) (Icc 0 T) ≠ ⊤ := by
            simp [Real.volume_Icc, ENNReal.ofReal_ne_top]
          calc ∫ s in Icc 0 T, ∫ x : CATEPTSpace, ‖A s x‖^2
              ≤ ∫ s in Icc 0 T, M_sq := by
                apply setIntegral_mono_on h_slice_int
                  (integrableOn_const hVol) measurableSet_Icc
                intro s hs; exact h_L2 s hs
            _ = T * M_sq := by
                rw [setIntegral_const]
                simp only [Measure.real, Real.volume_Icc,
                    ENNReal.toReal_ofReal (sub_nonneg.mpr (le_of_lt hT)), smul_eq_mul]
                ring
    _ = M_sq := by field_simp

/-! ## §3. Companion: interval Cauchy-Schwarz (Ioc variant for ODEHalfHolderBridge) -/

/-- Cauchy-Schwarz for `intervalIntegral` on `[s, t]` (real version):
      `‖∫_{[s,t]} g r dr‖ ≤ √(t-s) · √(∫_{[s,t]} ‖g r‖²)` -/
theorem interval_norm_le_sqrt_mul_sqrt_sq
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {s t : ℝ} (hst : s ≤ t) (g : ℝ → E)
    (hg_sq : IntegrableOn (fun r => ‖g r‖^2) (Icc s t) volume) :
    ‖∫ r in Icc s t, g r‖ ≤ Real.sqrt (t - s) * Real.sqrt (∫ r in Icc s t, ‖g r‖^2) := by
  have hCS := sq_norm_setIntegral_le_measure_mul_setIntegral_sq hst g hg_sq
  have hLHS_nn : 0 ≤ ‖∫ r in Icc s t, g r‖ := norm_nonneg _
  rw [← Real.sqrt_sq hLHS_nn, ← Real.sqrt_mul (sub_nonneg.mpr hst)]
  exact Real.sqrt_le_sqrt hCS

end CATEPTMain.AFPBridge.L2TimeIntegral
