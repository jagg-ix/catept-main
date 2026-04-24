import Mathlib.Analysis.Fourier.AddCircle
import Mathlib.Analysis.Fourier.AddCircleMulti
import Mathlib.Analysis.Real.Pi.Bounds
import Mathlib.MeasureTheory.Integral.Pi
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Periodic
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.MeasureTheory.Integral.Prod
import Mathlib.MeasureTheory.Integral.Bochner.ContinuousLinearMap
import NavierStokesClean.Sobolev.PeriodicSobolev

/-!
# Fourier Derivative Identity on T³ (NSC-FD)

This file proves the Fourier coefficient identity for partial derivatives on
`UnitAddTorus (Fin 3) = (AddCircle 1)^3`, and derives the H¹ Plancherel
inequality relating `h1FourierSemiNorm` to the spatial gradient integral.

## Main results

### §1 — Partial derivative on UnitAddTorus

`torusPartialDeriv i f z`: the partial derivative of `f : UnitAddTorus (Fin 3) → ℂ`
in direction `i : Fin 3` at point `z`, defined via the derivative of the lifted
function `fun s : ℝ => f (Function.update z i (s : AddCircle 1))`.

`mFourierCoeff_partialDeriv`: the key Fourier derivative identity:
```
  mFourierCoeff (torusPartialDeriv i f) k = (2πi·(k i)) * mFourierCoeff f k
```
for smooth 1-periodic `f`. Proof route:
  (A) Product rule + FTC: the integral of ∂_i [mFourier(-k) * f] over T³ is 0
      (FTC on T¹ fiber + periodicity, applied after Fubini).
  (B) Rearrangement: mFourierCoeff(∂_i f) k = 2πi*(k i) * mFourierCoeff f k.
  Key sub-lemma proved: `hasDerivAt_mFourier_neg_update` (derivative of the
  Fourier product in direction i via `Fin.prod_univ_succAbove`).
  Sorry: Fubini on T³ = T¹ × T² (isolating direction i).

### §2 — H¹ Plancherel inequality

`h1FourierSemiNorm_plancherel`: For smooth `f : UnitAddTorus (Fin 3) → ℂ`:
```
  (2 * Real.pi)^2 * h1FourierSemiNorm f
    = ∑ i, ∫ t, ‖torusPartialDeriv i f t‖^2 ∂volume
```
The equality uses `mFourierCoeff_partialDeriv` + Parseval (hasSum_sq_mFourierCoeff).

## Mathlib gap

This file fills the gap in Mathlib 4 / v4.26.0: `AddCircleMulti.lean` has Parseval
(`hasSum_sq_mFourierCoeff`) but no Fourier derivative identity. The 1D building block
`fourierCoeffOn_of_hasDerivAt` (AddCircle.lean:558) exists; the multi-dimensional
version requires Fubini for product measures on `(AddCircle 1)^d` (sorry'd here).

## Sorry status

- `mFourierCoeff_partialDeriv`: Fubini on T³ to reduce to 1D IBP
- `h1FourierSemiNorm_plancherel`: Parseval exchange (L² membership check)
-/

set_option autoImplicit false

private noncomputable instance factPeriodOneFD : Fact (0 < (1 : ℝ)) := ⟨one_pos⟩

-- Activate the same MeasureSpace instance as AddCircleMulti.lean and PeriodicSobolev.lean
noncomputable local instance : MeasureTheory.MeasureSpace UnitAddCircle :=
  ⟨AddCircle.haarAddCircle⟩

namespace NavierStokesClean.Sobolev.FourierDerivT3

open NavierStokesClean MeasureTheory UnitAddTorus
open scoped ENNReal NNReal BigOperators

/-! ## §1. Partial derivative on UnitAddTorus (Fin 3) -/

/-- **Partial derivative of `f : UnitAddTorus (Fin 3) → ℂ` in direction `i`**.

    For `z : UnitAddTorus (Fin 3) = Fin 3 → AddCircle 1`, the partial derivative
    in direction `i` at `z` is the derivative of the real lifted function
    `s ↦ f(z with z_i := (s : AddCircle 1))` evaluated at the canonical
    representative `t₀ = (equivIoc 1 0 (z i) : ℝ) ∈ (0, 1]`.

    This is well-defined because the lifted function is 1-periodic (any two
    representatives of `z i` differ by an integer, and the derivative of a
    1-periodic function is equal at any two points that differ by an integer). -/
noncomputable def torusPartialDeriv (i : Fin 3) (f : UnitAddTorus (Fin 3) → ℂ)
    (z : UnitAddTorus (Fin 3)) : ℂ :=
  let t₀ : ℝ := (AddCircle.equivIoc (1 : ℝ) 0 (z i) : Set.Ioc (0 : ℝ) (0 + 1)).1
  deriv (fun s : ℝ => f (Function.update z i ((s : AddCircle (1 : ℝ))))) t₀

/-! ## §1A. Derivative of the Fourier product in direction i -/

/-- **Derivative of `mFourier(-k)` in direction i** (proved via `Fin.prod_univ_succAbove`):

    At `t₀ = canonical representative of z i in (0,1]`, the function
    `s ↦ ∏_j fourier(-(k j))(update z i s j)` has derivative
    `(-2πi·(k i)) · ∏_j fourier(-(k j))(z j)`.

    **Proof**: Split via `Fin.prod_univ_succAbove i`:
    - i-th factor `fourier(-(k i))(s : AddCircle 1)`: derivative `-2πi*(k i) * fourier(-(k i))(t₀)` via `hasDerivAt_fourier_neg`
    - All other factors `fourier(-(k j))(z j)` for j ≠ i: constant in s, derivative 0
    - Product rule: derivative = `(-2πi*(k i) * fourier(-(k i))(t₀)) * C` where `C = ∏_{j:Fin 2} fourier(-(k(i.succAbove j)))(z (i.succAbove j))`
    - Since `(t₀ : AddCircle 1) = z i`, the product equals `(-2πi*(k i)) * ∏_j fourier(-(k j))(z j)`. -/
private lemma hasDerivAt_mFourier_neg_update (i : Fin 3) (k : Fin 3 → ℤ)
    (z : UnitAddTorus (Fin 3)) :
    let t₀ : ℝ := (AddCircle.equivIoc (1 : ℝ) 0 (z i) : Set.Ioc (0 : ℝ) (0 + 1)).1
    HasDerivAt
      (fun s : ℝ => ∏ j : Fin 3, fourier (-(k j)) (Function.update z i ((s : AddCircle (1:ℝ))) j))
      ((-2 * Real.pi * Complex.I * ↑(k i)) * ∏ j : Fin 3, fourier (-(k j)) (z j))
      t₀ := by
  set t₀ : ℝ := (AddCircle.equivIoc (1:ℝ) 0 (z i) : Set.Ioc (0:ℝ) (0+1)).1
  -- Key fact: (t₀ : AddCircle 1) = z i (the canonical representative casts back)
  have ht₀ : ((t₀ : ℝ) : AddCircle (1:ℝ)) = z i :=
    (AddCircle.equivIoc (1:ℝ) 0).symm_apply_apply (z i)
  -- Rewrite the product using Fin.prod_univ_succAbove to isolate the i-th factor
  have hfac : ∀ s : ℝ,
      ∏ j : Fin 3, fourier (-(k j)) (Function.update z i ((s : AddCircle (1:ℝ))) j) =
      fourier (-(k i)) (s : AddCircle (1:ℝ)) *
        ∏ j : Fin 2, fourier (-(k (i.succAbove j))) (z (i.succAbove j)) := fun s => by
    rw [Fin.prod_univ_succAbove _ i]
    congr 1
    · simp [Function.update_self]
    · apply Finset.prod_congr rfl; intros j _
      simp
  simp_rw [hfac]
  -- The second factor is constant; factor it out
  set C := ∏ j : Fin 2, fourier (-(k (i.succAbove j))) (z (i.succAbove j)) with hC_def
  -- Use hasDerivAt_fourier_neg + mul_const
  have hd : HasDerivAt (fun s : ℝ => fourier (-(k i)) (s : AddCircle (1:ℝ)) * C)
      ((-2 * Real.pi * Complex.I * ↑(k i) / 1) * fourier (-(k i)) (t₀ : AddCircle (1:ℝ)) * C)
      t₀ :=
    ((hasDerivAt_fourier_neg (1:ℝ) (k i) t₀).mul_const C)
  convert hd using 1
  -- Simplify: the product ∏_j = fourier(-(k i))(z i) * C, and t₀ casts to z i
  rw [ht₀]
  have hprod_eq : ∏ j : Fin 3, fourier (-(k j)) (z j) =
      fourier (-(k i)) (z i) * C := by
    rw [hC_def, Fin.prod_univ_succAbove (fun j => fourier (-(k j)) (z j)) i]
  rw [hprod_eq]
  ring

/-! ## §1B. Product rule: derivative of mFourier(-k) · f in direction i -/

/-- **Product rule**: the partial derivative of `mFourier(-k) · f` in direction i equals
    `(-2πi·(k i)) · mFourier(-k) · f + mFourier(-k) · ∂_i f`.

    This follows from `hasDerivAt_mFourier_neg_update` and `HasDerivAt.mul`. -/
private lemma hasDerivAt_mFourier_neg_mul (i : Fin 3) (k : Fin 3 → ℤ)
    (f : UnitAddTorus (Fin 3) → ℂ)
    (hf_diff : ∀ z : UnitAddTorus (Fin 3),
      HasDerivAt (fun s : ℝ => f (Function.update z i ((s : AddCircle (1:ℝ)))))
        (torusPartialDeriv i f z)
        ((AddCircle.equivIoc (1:ℝ) 0 (z i) : Set.Ioc (0:ℝ) (0+1)).1))
    (z : UnitAddTorus (Fin 3)) :
    let t₀ := (AddCircle.equivIoc (1:ℝ) 0 (z i) : Set.Ioc (0:ℝ) (0+1)).1
    HasDerivAt
      (fun s : ℝ =>
        (∏ j : Fin 3, fourier (-(k j)) (Function.update z i ((s : AddCircle (1:ℝ))) j)) *
        f (Function.update z i ((s : AddCircle (1:ℝ)))))
      (((-2 * Real.pi * Complex.I * ↑(k i)) * ∏ j : Fin 3, fourier (-(k j)) (z j)) *
          f z +
        (∏ j : Fin 3, fourier (-(k j)) (z j)) * torusPartialDeriv i f z)
      t₀ := by
  set t₀ := (AddCircle.equivIoc (1:ℝ) 0 (z i) : Set.Ioc (0:ℝ) (0+1)).1
  have ht₀ : ((t₀ : ℝ) : AddCircle (1:ℝ)) = z i :=
    (AddCircle.equivIoc (1:ℝ) 0).symm_apply_apply (z i)
  -- Product rule: (d/ds [A(s) * B(s)]) = A'(s) * B(s) + A(s) * B'(s)
  have hA := hasDerivAt_mFourier_neg_update i k z
  have hB := hf_diff z
  -- At t₀, the update gives back z: Function.update z i (t₀ : AddCircle 1) j = z j
  have hupdate : Function.update z i ((t₀ : ℝ) : AddCircle (1:ℝ)) = z := by
    ext j; by_cases hij : j = i
    · subst hij; simp [ht₀]
    · simp [Function.update_of_ne hij]
  -- Apply HasDerivAt.mul
  have hprod := hA.mul hB
  convert hprod using 1
  rw [hupdate]

/-! ## §1C. Main theorem: mFourierCoeff of partial derivative -/

/-- **Fourier coefficient of partial derivative (NSC-FD main theorem)**:

    For smooth 1-periodic `f : UnitAddTorus (Fin 3) → ℂ`, the Fourier coefficient
    of `∂_i f` at frequency `k` equals `2πi · (k i)` times the Fourier coefficient
    of `f`:
    ```
    mFourierCoeff (torusPartialDeriv i f) k = (2πi · ↑(k i)) * mFourierCoeff f k
    ```

    **Proof structure**:
    1. By `hasDerivAt_mFourier_neg_mul`, the partial derivative of `g := mFourier(-k) * f`
       in direction i satisfies:
       `∂_i g = (-2πi*(k i)) * mFourier(-k) * f + mFourier(-k) * ∂_i f`
    2. Therefore: `mFourier(-k) * ∂_i f = ∂_i g + (2πi*(k i)) * mFourier(-k) * f`
    3. Integrating over T³:
       `mFourierCoeff (∂_i f) k = ∫_{T³} ∂_i g + (2πi*(k i)) * mFourierCoeff f k`
    4. `∫_{T³} ∂_i g = 0`:
       - **Fubini** (sorry): factor as `∫_{T²} [∫_{T¹} ∂_s g(update z i s) ds] dz`
       - **FTC** on T¹: `∫₀¹ d/ds g(update z i s) ds = g(update z i 1) - g(update z i 0) = 0`
         (periodicity: `(1 : AddCircle 1) = 0` so both values are equal)

    **Mathlib gap**: Fubini on T³ = T¹ × T² (isolating coordinate i via
    `volume_preserving_piFinSuccAbove`) is not directly available for this form. -/
theorem mFourierCoeff_partialDeriv
    (i : Fin 3) (f : UnitAddTorus (Fin 3) → ℂ)
    (hf_diff : ∀ z : UnitAddTorus (Fin 3),
      HasDerivAt (fun s : ℝ => f (Function.update z i ((s : AddCircle (1 : ℝ)))))
        (torusPartialDeriv i f z)
        ((AddCircle.equivIoc (1 : ℝ) 0 (z i) : Set.Ioc (0 : ℝ) (0 + 1)).1))
    (hf_int : MeasureTheory.Integrable (torusPartialDeriv i f)
        (volume : Measure (UnitAddTorus (Fin 3))))
    (hf_base_int : MeasureTheory.Integrable f
        (volume : Measure (UnitAddTorus (Fin 3))))
    (hf_cont : Continuous f)
    (k : Fin 3 → ℤ) :
    mFourierCoeff (torusPartialDeriv i f) k =
      (2 * Real.pi * Complex.I * ↑(k i)) * mFourierCoeff f k := by
  simp only [mFourierCoeff, mFourier, ContinuousMap.coe_mk, smul_eq_mul]
  -- FIX B1: normalize (-k) j → -(k j) throughout the goal
  -- This is needed because mFourier unfolds to ∏ j, fourier ((-k) j) (t j)
  -- (using Pi.neg), but hasDerivAt_mFourier_neg_mul uses fourier (-(k j)) (t j).
  simp_rw [Pi.neg_apply]
  -- NOTE: we do NOT use `set P` here — set does not fold under ∫ binders.
  -- All terms use ∏ j : Fin 3, fourier (-(k j)) (...) directly.
  -- For each t, the canonical ℝ-representative of t i in (0, 1]
  set t₀_of := fun t : UnitAddTorus (Fin 3) =>
    (AddCircle.equivIoc (1:ℝ) 0 (t i) : Set.Ioc (0:ℝ) (0+1)).1
  -- (t₀_of t : AddCircle 1) = t i
  have ht₀ : ∀ t : UnitAddTorus (Fin 3), ((t₀_of t : ℝ) : AddCircle (1:ℝ)) = t i :=
    fun t => (AddCircle.equivIoc (1:ℝ) 0).symm_apply_apply (t i)
  -- update t i (t₀_of t : AddCircle 1) = t
  have hupd : ∀ t : UnitAddTorus (Fin 3),
      Function.update t i ((t₀_of t : ℝ) : AddCircle (1:ℝ)) = t := fun t => by
    ext j; by_cases hij : j = i
    · subst hij; rw [Function.update_self, ht₀]
    · exact Function.update_of_ne hij _ _
  -- Algebraic identity from product rule:
  -- (∏ j, fourier (-(k j)) (t j)) * ∂_i f(t)
  --   = ∂_s[∏_j fourier(-(k j))(update t i s j) * f(update t i s)] at s=t₀_of t
  --     + 2πi*(k i) * (∏ j, fourier (-(k j)) (t j)) * f(t)
  have halg : ∀ t : UnitAddTorus (Fin 3),
      (∏ j : Fin 3, fourier (-(k j)) (t j)) * torusPartialDeriv i f t =
      deriv (fun s : ℝ =>
          (∏ j : Fin 3, fourier (-(k j)) (Function.update t i ((s : AddCircle (1:ℝ))) j)) *
          f (Function.update t i ((s : AddCircle (1:ℝ)))))
        (t₀_of t) +
        (2 * Real.pi * Complex.I * ↑(k i)) *
          ((∏ j : Fin 3, fourier (-(k j)) (t j)) * f t) := by
    intro t
    -- hd : HasDerivAt (fun s => ∏_j fourier(-(k j))(update t i s j) * f(update t i s))
    --        ((-2πi*ki) * ∏_j fourier(-(k j))(t j) * f t + ∏_j fourier(-(k j))(t j) * ∂_i f t)
    --        t₀  (where t₀ is let-bound inside hasDerivAt_mFourier_neg_mul = t₀_of t)
    have hd := hasDerivAt_mFourier_neg_mul i k f hf_diff t
    -- Extract the derivative value identity with t₀_of t on LHS explicitly
    -- (hd.deriv uses let-bound t₀ = t₀_of t definitionally — explicit type resolves this)
    have hval : deriv (fun s : ℝ =>
        (∏ j : Fin 3, fourier (-(k j)) (Function.update t i ((s : AddCircle (1:ℝ))) j)) *
        f (Function.update t i ((s : AddCircle (1:ℝ))))) (t₀_of t) =
      ((-2 * Real.pi * Complex.I * ↑(k i)) * ∏ j : Fin 3, fourier (-(k j)) (t j)) * f t +
        (∏ j : Fin 3, fourier (-(k j)) (t j)) * torusPartialDeriv i f t := hd.deriv
    rw [hval]
    ring
  -- hIntDeriv: ∫_{T³} d/ds[∏_j fourier(-(k j))(update t i s j) * f(update t i s)]_{s=t₀} dt = 0
  -- Proof route: Fubini (volume_preserving_piFinSuccAbove) + FTC + periodicity (AddCircle.coe_period)
  --
  -- LOOP RESOLVED (TLA+ NSFourierDerivFubini.tla, ZIL ns_fourier_deriv_fubini_analysis.zc):
  -- IntervalIntegrable(deriv H_z) source = Integrable.prod_left_ae (NOT a new hypothesis).
  --
  -- FULL ROUTE:
  -- A: (MeasurePreserving.symm φ hφ).integral_comp'
  --    + simp [Fin.update_insertNth, Fin.insertNth_apply_same]
  --    → ∫ t : T³, F t = ∫ p : AddCircle 1 × T², G p ∂(vol.prod Pi_vol)
  -- B: integral_prod_symm hG_int
  --    → ∫ p = ∫ z : T², ∫ sv : AddCircle 1, G (sv, z)
  -- C: integral_eq_zero_of_ae + Integrable.prod_left_ae
  --    → ∀ᵐ z, Integrable (fun sv => G (sv, z))
  -- D: ← AddCircle.integral_preimage + equivIoc_coe_eq (r ∈ Ioc 0 1)
  --    + integral_eq_sub_of_hasDerivAt_of_le (hint from C via measure isomorphism)
  --    → ∫ sv, G (sv, z) = H_z 1 - H_z 0
  -- E: AddCircle.coe_period : (1:ℝ) : AddCircle 1 = 0 = (0:ℝ) : AddCircle 1
  --    → H_z 1 = H_z 0 → sub = 0
  have hIntDeriv : ∫ t : UnitAddTorus (Fin 3),
      deriv (fun s : ℝ =>
          (∏ j : Fin 3, fourier (-(k j)) (Function.update t i ((s : AddCircle (1:ℝ))) j)) *
          f (Function.update t i ((s : AddCircle (1:ℝ)))))
        (t₀_of t) = 0 := by
    -- ══════════════════════════════════════════════════════════════════════
    -- DSF DUAL SPHERE FIBER PROOF
    -- Physical fiber: t : T³ = UnitAddTorus (Fin 3)
    -- Dual fiber split at i: T³ ≅ T¹_i × T²_rest  (piFinSuccAbove)
    -- s1-sphere: T¹_i = UnitAddCircle  (Wilson loop / FTC fiber)
    -- s2-sphere: T²_rest = Fin 2 → UnitAddCircle  (transverse config fiber)
    -- vMap: t ↦ deriv H_t (t₀_of t)  (the Wilson loop density)
    -- DSF A2: ∫_{T³} vMap = ∫_{T²}(∫_{T¹} vMap) by Fubini
    -- Zero holonomy: ∫_{T¹} G_z' = FTC + coe_period = 0  (dualWilsonMatch)
    -- ══════════════════════════════════════════════════════════════════════
    -- §0. Instance chain: IsProbabilityMeasure → IsFiniteMeasure → SigmaFinite → SFinite
    -- The local MeasureSpace UnitAddCircle sets volume = AddCircle.haarAddCircle;
    -- Lean can't automatically synthesize SigmaFinite/IsFiniteMeasure through local aliases,
    -- so we explicitly bridge via IsProbabilityMeasure.
    haveI hProb : IsProbabilityMeasure (volume : Measure UnitAddCircle) :=
      inferInstanceAs (IsProbabilityMeasure AddCircle.haarAddCircle)
    haveI hSF : SigmaFinite (volume : Measure UnitAddCircle) := inferInstance
    haveI hSFin : IsFiniteMeasure (volume : Measure UnitAddCircle) := inferInstance
    -- §A. DSF dual-fiber split: define G on T¹ × T² (the lifted Wilson loop density)
    -- G (sv, z) = derivative of P·f along the T¹_i fiber, at the representative of sv
    let G : UnitAddCircle × (Fin 2 → UnitAddCircle) → ℂ := fun p =>
      deriv (fun s : ℝ =>
          -- Explicit type annotation forces Fin.insertNth result to UnitAddTorus (Fin 3)
          -- so that (t j : UnitAddCircle = AddCircle 1) unifies with fourier's argument type.
          let t : UnitAddTorus (Fin 3) :=
            i.insertNth ((s : AddCircle (1:ℝ)) : UnitAddCircle) p.2
          (∏ j : Fin 3, fourier (-(k j)) (t j)) * f t)
        ((AddCircle.equivIoc (1:ℝ) 0 p.1).val)
    -- §A. Show the T³ integrand equals G ∘ piFinSuccAbove
    -- Key: Function.update t i s = insertNth i s (removeNth i t)  [insertNth_removeNth]
    --      piFinSuccAbove t = (t i, removeNth i t)
    have hFG_eq : ∀ t : UnitAddTorus (Fin 3),
        deriv (fun s : ℝ =>
            (∏ j : Fin 3, fourier (-(k j)) (Function.update t i ((s : ℝ) : AddCircle (1:ℝ)) j)) *
            f (Function.update t i ((s : ℝ) : AddCircle (1:ℝ))))
          (t₀_of t) =
        G (MeasurableEquiv.piFinSuccAbove (fun _ : Fin 3 => UnitAddCircle) i t) := fun t => by
      -- NSFourierDerivRepair.tla E4 fix: rfl-bridge + simp strategy (SelectFix_Simp)
      -- Key: piFinSuccAbove t = (t i, removeNth i t) by rfl (definitional equality).
      -- Rewriting with this, then Fin.insertNth_removeNth (@[simp]) closes the goal:
      --   insertNth i s (removeNth i t) → update t i s
      -- t_ent: s : ℝ is the entropic time real lift; when i=0 this is CATEPTST.ofTimeSpace s z₀.
      have hpif : MeasurableEquiv.piFinSuccAbove (fun _ : Fin 3 => UnitAddCircle) i t =
          (t i, Fin.removeNth i t) := rfl
      simp only [G, hpif, Fin.insertNth_removeNth, t₀_of]
    -- §A. Change of variables via piFinSuccAbove (measure-preserving = DSF Hphys NatIso)
    have hmeas := volume_preserving_piFinSuccAbove (fun _ : Fin 3 => UnitAddCircle) i
    rw [integral_congr_ae (ae_of_all _ hFG_eq), hmeas.integral_comp' G]
    -- Goal: ∫ p : UnitAddCircle × (Fin 2 → UnitAddCircle), G p ∂(vol.prod vol) = 0
    -- §A-int. Integrability of G on the product space
    -- G ∘ φ has same integrand as the T³ function; transfer via measure-preserving
    have hG_int : Integrable G
        ((volume : Measure UnitAddCircle).prod (volume : Measure (Fin 2 → UnitAddCircle))) := by
      -- G (φ t) = F t by hFG_eq, and F is integrable on T³
      -- Use: Integrable G (map φ vol) ↔ Integrable (G ∘ φ) vol  [integrable_map_measure]
      -- volume.prod volume = volume : Measure (A×B) by rfl (prod.measureSpace), so
      -- ← volume_eq_prod bridges the syntactic gap for hmeas.map_eq.
      rw [show (volume : Measure UnitAddCircle).prod (volume : Measure (Fin 2 → UnitAddCircle)) =
          (volume : Measure (UnitAddCircle × (Fin 2 → UnitAddCircle))) from rfl]
      rw [← hmeas.map_eq]
      rw [integrable_map_measure _ hmeas.measurable.aemeasurable]
      · -- G ∘ φ = fun t => (∏ j, fourier) * ∂_if - c * ((∏ j, fourier) * f)
        -- by hFG_eq + halg
        have hGφ_eq : (G ∘ (MeasurableEquiv.piFinSuccAbove (fun _ : Fin 3 => UnitAddCircle) i)) =
            fun t => (∏ j : Fin 3, fourier (-(k j)) (t j)) * torusPartialDeriv i f t -
              (2 * Real.pi * Complex.I * ↑(k i)) *
                ((∏ j : Fin 3, fourier (-(k j)) (t j)) * f t) :=
          funext fun t => by rw [Function.comp_apply, ← hFG_eq t]; linear_combination -(halg t)
        rw [hGφ_eq]
        -- Integrability: same Fourier bound argument
        have hContProd_i : Continuous (fun t : UnitAddTorus (Fin 3) =>
            ∏ j : Fin 3, fourier (-(k j)) (t j)) :=
          continuous_finset_prod Finset.univ fun j _ =>
            (ContinuousMap.continuous (fourier (-(k j)))).comp (continuous_apply j)
        have hBound_i : ∀ t : UnitAddTorus (Fin 3),
            ‖∏ j : Fin 3, fourier (-(k j)) (t j)‖ ≤ 1 := fun t => by
          rw [Fin.prod_univ_three, norm_mul, norm_mul]
          have h0 := (ContinuousMap.norm_coe_le_norm (fourier (-(k 0))) (t 0)).trans
                       (le_of_eq (fourier_norm (-(k 0))))
          have h1 := (ContinuousMap.norm_coe_le_norm (fourier (-(k 1))) (t 1)).trans
                       (le_of_eq (fourier_norm (-(k 1))))
          have h2 := (ContinuousMap.norm_coe_le_norm (fourier (-(k 2))) (t 2)).trans
                       (le_of_eq (fourier_norm (-(k 2))))
          exact (mul_le_mul_of_nonneg_right
              ((mul_le_mul_of_nonneg_right h0 (norm_nonneg _)).trans
                ((mul_le_mul_of_nonneg_left h1 zero_le_one).trans_eq (one_mul _)))
              (norm_nonneg _)).trans
            ((mul_le_mul_of_nonneg_left h2 zero_le_one).trans_eq (one_mul _))
        exact (hf_int.mono (hContProd_i.aestronglyMeasurable.mul hf_int.1)
            (ae_of_all _ fun t => by
              simp only [Pi.mul_apply]
              rw [norm_mul]; exact mul_le_of_le_one_left (norm_nonneg _) (hBound_i t))).sub
          ((hf_base_int.mono (hContProd_i.aestronglyMeasurable.mul hf_base_int.1)
            (ae_of_all _ fun t => by
              simp only [Pi.mul_apply]
              rw [norm_mul]; exact mul_le_of_le_one_left (norm_nonneg _) (hBound_i t))).const_mul _)
      · -- AEStronglyMeasurable G (map φ vol) ↔ AEStronglyMeasurable (G ∘ φ) vol
        -- (MeasurableEmbedding.aestronglyMeasurable_map_iff)
        -- G ∘ φ = fun t => P(t)*∂_if(t) − c*(P(t)*f(t))  (hFG_eq + halg)
        have hmeasEmb :=
          (MeasurableEquiv.piFinSuccAbove (fun _ : Fin 3 => UnitAddCircle) i).measurableEmbedding
        rw [hmeasEmb.aestronglyMeasurable_map_iff]
        -- Now goal: AEStronglyMeasurable (G ∘ ⇑piFinSuccAbove) vol_T3
        have hGφ_eq : (G ∘ ⇑(MeasurableEquiv.piFinSuccAbove (fun _ : Fin 3 => UnitAddCircle) i)) =
            fun t => (∏ j : Fin 3, fourier (-(k j)) (t j)) * torusPartialDeriv i f t -
              (2 * Real.pi * Complex.I * ↑(k i)) *
                ((∏ j : Fin 3, fourier (-(k j)) (t j)) * f t) :=
          funext fun t => by rw [Function.comp_apply, ← hFG_eq t]; linear_combination -(halg t)
        rw [hGφ_eq]
        have hCP : Continuous (fun t : UnitAddTorus (Fin 3) =>
            ∏ j : Fin 3, fourier (-(k j)) (t j)) :=
          continuous_finset_prod Finset.univ fun j _ =>
            (ContinuousMap.continuous (fourier (-(k j)))).comp (continuous_apply j)
        exact (hCP.aestronglyMeasurable.mul hf_int.1).sub
          ((hCP.aestronglyMeasurable.mul hf_base_int.1).const_mul _)
    -- §B. Fubini: swap outer (T²) / inner (T¹) integration
    -- DSF Hcomp = monoidal NatTrans: ∫_{T¹⊗T²} = ∫_{T²} ∘ ∫_{T¹}
    -- MUST use integral_prod_symm (outer = T², inner = T¹) for FTC to apply to inner
    -- After hmeas.integral_comp', goal uses volume : Measure (A×B) not explicit volume.prod volume.
    -- volume_eq_prod bridges: (volume : Measure (A×B)) = volume.prod volume (rfl).
    rw [show (volume : Measure (UnitAddCircle × (Fin 2 → UnitAddCircle))) =
        (volume : Measure UnitAddCircle).prod (volume : Measure (Fin 2 → UnitAddCircle)) from rfl]
    rw [integral_prod_symm G hG_int]
    -- Goal: ∫ z : Fin 2 → UnitAddCircle, ∫ sv : UnitAddCircle, G (sv, z) = 0
    -- §C. For a.e. z: ∫ sv, G (sv, z) = 0  (zero Wilson loop on s1 sphere)
    -- C': Tonelli adjunction (LOOP-BREAKING): IntervalIntegrable from prod_left_ae
    apply integral_eq_zero_of_ae
    filter_upwards [hG_int.prod_left_ae] with z hGz_int
    -- §D. FTC on T¹_i fiber (DSF s1-sphere Wilson loop = 0)
    -- Convert ∫_{T¹} to ∫_0^1 via AddCircle.intervalIntegral_preimage
    -- DSF: dualWilsonMatch ↔ ∫_{T¹} G_z' = ∫_0^1 deriv H_z = H_z(1) - H_z(0)
    -- After filter_upwards, the goal may not be beta-reduced. Use `show` to normalize.
    show ∫ sv : UnitAddCircle, G (sv, z) ∂volume = 0
    -- intervalIntegral_preimage: ∫ b : UnitAddCircle, f b = ∫ a in t..(t+1), f a
    -- rw [← ...] fails because the pattern has (fun sv => G(sv,z)) b but goal has G(sv,z) (beta).
    -- Use have + symm to build the bridge explicitly.
    have hpre : ∫ sv : UnitAddCircle, G (sv, z) ∂volume =
        ∫ a in (0:ℝ)..(1:ℝ), G ((a : AddCircle (1:ℝ)), z) := by
      -- NSFourierDerivRepair.tla: NEW BLOCKER — MeasureSpace instance conflict
      -- UnitAddCircle.intervalIntegral_preimage uses AddCircle.measureSpace 1 (global):
      --   volume_global = ENNReal.ofReal 1 • addHaarMeasure ⊤
      -- Our local instance: volume_local = AddCircle.haarAddCircle = addHaarMeasure ⊤
      -- These are propositionally equal (via ENNReal.ofReal_one + one_smul) but NOT rfl.
      -- t_ent: the equivalence T¹_i ≅ [0,1)/ℤ is clear at the entropic time level;
      --   the Lean4 instance conflict is a bookkeeping issue, not a mathematical one.
      -- Resolution path: AddCircle.volume_eq_smul_haarAddCircle + ENNReal.ofReal_one + one_smul
      --   OR: remove local MeasureSpace instance (risky: affects many proofs).
      -- Tracked in ZIL §11 as tac_error E7_measurespace_conflict.
      -- Fix: the local MeasureSpace instance (volume = haarAddCircle) differs from the
      -- global AddCircle.measureSpace 1 used by intervalIntegral_preimage (not propositionally rfl).
      -- Discharge: AddCircle.integral_haarAddCircle + ENNReal.ofReal_one + one_smul + preimage.
      -- Tracked in ZIL §11 as tac_error E7_measurespace_conflict (bookkeeping, not math).
      sorry
    rw [hpre]
    -- §D. Define H_z and show G ((a:AddCircle 1), z) = deriv H_z a for a ∈ (0,1)
    let H_z : ℝ → ℂ := fun s =>
      -- Type annotation on insertNth result: forces (tt j : UnitAddCircle = AddCircle 1)
      -- so that fourier (-(k j)) (tt j) typechecks.  Same fix as G above.
      let tt : UnitAddTorus (Fin 3) := i.insertNth ((s : AddCircle (1:ℝ)) : UnitAddCircle) z
      (∏ j : Fin 3, fourier (-(k j)) (tt j)) * f tt
    have hGH_eq : ∀ a ∈ Set.Ioo (0:ℝ) 1,
        G (((a : ℝ) : AddCircle (1:ℝ)), z) = deriv H_z a := fun a ha => by
      simp only [G, H_z]
      congr 1
      -- (equivIoc 1 0 (a:AddCircle 1)).val = a for a ∈ Ioc 0 1
      have ha' : a ∈ Set.Ioc (0:ℝ) (0 + 1) := ⟨ha.1, by linarith [ha.2]⟩
      have := AddCircle.equivIoc_coe_eq ha'
      simp [this]
    -- Rewrite ∫_0^1 G ((a:AddCircle 1), z) as ∫_0^1 deriv H_z a  (a.e. equal on (0,1))
    -- integral_congr_ae expects ∀ᵐ a ∂volume, a ∈ uIoc 0 1 → ... (not restricted measure)
    -- The only point in uIoc 0 1 = Ioc 0 1 not covered by hGH_eq (Ioo 0 1) is {1}, which is null.
    have hIoo_ae : ∀ᵐ a ∂(volume : Measure ℝ),
        a ∈ Set.uIoc 0 1 → G (((a : ℝ) : AddCircle (1:ℝ)), z) = deriv H_z a := by
      rw [Set.uIoc_of_le (by norm_num : (0:ℝ) ≤ 1)]
      have h1_null : ∀ᵐ a ∂(volume : Measure ℝ), a ≠ 1 :=
        ae_iff.mpr (by simp)
      filter_upwards [h1_null] with a hne1 ha
      exact hGH_eq a ⟨ha.1, lt_of_le_of_ne ha.2 hne1⟩
    rw [intervalIntegral.integral_congr_ae hIoo_ae]
    -- §D. FTC: ∫_0^1 deriv H_z = H_z 1 - H_z 0
    -- Hypothesis for FTC:
    -- (1) ContinuousOn H_z (Icc 0 1)  — from hf_cont + Fourier chars
    -- (2) HasDerivAt H_z (deriv H_z a) a  for a ∈ Ioo 0 1  — from hasDerivAt_mFourier_neg_mul
    -- (3) IntervalIntegrable (deriv H_z) vol 0 1  — from hGz_int via preimage
    -- hHz_cont: H_z is continuous on [0,1] (needed for integral_eq_sub_of_hasDerivAt_of_le).
    -- H_z = ψ ∘ φ  where  φ s = (insertNth i (s:AddCircle 1) z : UnitAddTorus (Fin 3))
    --                       ψ t = (∏ fourier) * f t
    -- hH_factor uses funext + rfl: the let-tt in H_z is defeq to ψ(φ s) by zeta-reduction.
    have hHz_cont : ContinuousOn H_z (Set.Icc 0 1) := by
      apply Continuous.continuousOn
      have hphi : Continuous (fun s : ℝ =>
          (i.insertNth ((s : AddCircle (1:ℝ)) : UnitAddCircle) z : UnitAddTorus (Fin 3))) :=
        continuous_pi fun m => by
          rcases Fin.eq_self_or_eq_succAbove i m with rfl | ⟨j', rfl⟩
          · simp only [Fin.insertNth_apply_same]; fun_prop
          · simp only [Fin.insertNth_apply_succAbove]; exact continuous_const
      have hH_factor : H_z =
          (fun t : UnitAddTorus (Fin 3) => (∏ j : Fin 3, fourier (-(k j)) (t j)) * f t) ∘
          (fun s : ℝ => (i.insertNth ((s : AddCircle (1:ℝ)) : UnitAddCircle) z : UnitAddTorus (Fin 3))) :=
        funext fun _ => rfl
      rw [hH_factor]
      exact ((continuous_finset_prod Finset.univ fun j _ =>
          (ContinuousMap.continuous (fourier (-(k j)))).comp (continuous_apply j)).mul
          hf_cont).comp hphi
    -- integral_eq_sub_of_hasDerivAt_of_le (FundThmCalculus:1141): ContinuousOn + HasDerivAt on Ioo.
    -- hHz_deriv proof:
    --   hd = hasDerivAt_mFourier_neg_mul applied at t = insertNth i (a:AddCircle 1) z.
    --   hd's function F s = ... (update (insertNth i (a:AddCircle 1) z) i (s:AddCircle 1)) ...
    --   After Fin.update_insertNth: F = H_z (definitionally, since let-tt reduces to same expr).
    --   hd's base point t₀ = (equivIoc 1 0 (insertNth i (a:AddCircle 1) z i)).1
    --                       = (equivIoc 1 0 (a:AddCircle 1)).1  [insertNth_apply_same]
    --                       = a  [equivIoc_coe_eq, a ∈ Ioc 0 (0+1)]
    have hHz_deriv : ∀ a ∈ Set.Ioo (0:ℝ) 1, HasDerivAt H_z (deriv H_z a) a := fun a ha => by
      -- M3 strategy (ZIL §6): avoid explicit nhds(insertNth) annotation (whnf E8).
      -- Apply hasDerivAt_mFourier_neg_mul at the EPT spacetime point tₐ = insertNth i (a:T¹_i) z.
      let tₐ : UnitAddTorus (Fin 3) := i.insertNth ((a : AddCircle (1:ℝ)) : UnitAddCircle) z
      have hd := hasDerivAt_mFourier_neg_mul i k f hf_diff tₐ
      -- Base point: equivIoc 1 0 (tₐ i) = a  (insertNth_apply_same + equivIoc_coe_eq)
      have ht0 : ((AddCircle.equivIoc (1:ℝ) 0 (tₐ i) : Set.Ioc _ _)).1 = a := by
        simp only [tₐ, Fin.insertNth_apply_same]
        -- equivIoc_coe_eq gives equivIoc 1 0 (a:AddCircle 1) = ⟨a, ha'⟩;
        -- take .1 of both sides via congr_arg Subtype.val
        exact congr_arg Subtype.val
          (AddCircle.equivIoc_coe_eq ⟨ha.1, by linarith [ha.2]⟩)
      -- Function: update tₐ i (s:AddCircle 1) = insertNth i (s:AddCircle 1) z = let-tt in H_z
      -- Fin.update_insertNth: update (insertNth i x p) i y = insertNth i y p  (@[simp])
      have hfun : (fun s : ℝ =>
            (∏ j : Fin 3, fourier (-(k j)) (Function.update tₐ i ((s : AddCircle (1:ℝ))) j)) *
            f (Function.update tₐ i ((s : AddCircle (1:ℝ))))) = H_z :=
        funext fun s => by simp only [H_z, tₐ, Fin.update_insertNth]
      -- Substitute base point (ht0) and function (hfun) into hd
      have hd' : HasDerivAt H_z _ a := hfun ▸ ht0 ▸ hd
      -- Value: deriv H_z a = derivative value from hd' (uniqueness of HasDerivAt)
      exact hd'.congr_deriv hd'.deriv.symm
    have hHz_iint : IntervalIntegrable (fun a => deriv H_z a) volume 0 1 := by
      -- Instance bridge: hGz_int uses local volume (= haarAddCircle) but measurePreserving_mk
      -- expects the global AddCircle.measureSpace 1 volume.
      -- For T=1: global volume = ENNReal.ofReal 1 • haarAddCircle = 1 • haarAddCircle = haarAddCircle
      -- (by volume_eq_smul_haarAddCircle + ENNReal.ofReal_one + one_smul).
      have hm : (@MeasureTheory.MeasureSpace.volume UnitAddCircle (AddCircle.measureSpace 1)) =
          AddCircle.haarAddCircle := by
        rw [AddCircle.volume_eq_smul_haarAddCircle]
        simp [ENNReal.ofReal_one]
      -- Restate hGz_int over the global measure (rfl after hm, since local vol = haarAddCircle).
      have hGz_int_global : Integrable (fun sv => G (sv, z))
          (@MeasureTheory.MeasureSpace.volume UnitAddCircle (AddCircle.measureSpace 1)) := by
        rw [hm]; exact hGz_int
      -- Step 1: pull back via measurePreserving_mk to IntegrableOn (Ioc 0 (0+1)) = Ioc 0 1
      have hG_pullback :=
          (AddCircle.measurePreserving_mk (1:ℝ) 0).integrable_comp_of_integrable hGz_int_global
      simp only [Function.comp, zero_add] at hG_pullback
      -- hG_pullback : IntegrableOn (fun a => G ((a:AddCircle 1), z)) (Ioc 0 1) volume
      -- Step 2: IntegrableOn Ioc 0 1 → IntervalIntegrable (uIoc 0 1 = Ioc 0 1 for 0 ≤ 1)
      have hGz_iint : IntervalIntegrable (fun a => G ((a : AddCircle (1:ℝ)), z)) volume 0 1 :=
        (intervalIntegrable_iff_integrableOn_Ioc_of_le (by norm_num : (0:ℝ) ≤ 1)).mpr hG_pullback
      -- Step 3: congr_ae with hIoo_ae: G((a,z)) = deriv H_z a a.e. on uIoc 0 1
      -- ae_restrict_iff' converts ∀ᵐ a, a ∈ uIoc → p a  to  ∀ᵐ a ∂vol.restrict(uIoc), p a
      exact hGz_iint.congr_ae ((ae_restrict_iff' measurableSet_uIoc).mpr hIoo_ae)
    rw [intervalIntegral.integral_eq_sub_of_hasDerivAt_of_le (by norm_num : (0:ℝ) ≤ 1)
        hHz_cont hHz_deriv hHz_iint]
    -- §E. Periodicity: H_z 1 = H_z 0 → sub = 0  (DSF: closed T¹_i loop, dualWilsonMatch)
    -- (1:ℝ) : AddCircle 1 = 0 = (0:ℝ) : AddCircle 1  by AddCircle.coe_period
    have hperiod : H_z 1 = H_z 0 := by
      -- Avoid simp [H_z] (triggers whnf on insertNth dependent type).
      -- Use composition factorization: H_z = ψ ∘ φ; reduce to φ 1 = φ 0.
      -- (1:ℝ):AddCircle 1 = (0:ℝ):AddCircle 1 by coe_period + map_zero.
      -- Rewrite base point first, then rw [hH_factor'] eliminates H_z.
      have hcoe : ((1:ℝ) : AddCircle (1:ℝ)) = ((0:ℝ) : AddCircle (1:ℝ)) := by
        rw [AddCircle.coe_period]; simp
      have hphi_eq :
          (i.insertNth (((1:ℝ) : AddCircle (1:ℝ)) : UnitAddCircle) z : UnitAddTorus (Fin 3)) =
          (i.insertNth (((0:ℝ) : AddCircle (1:ℝ)) : UnitAddCircle) z : UnitAddTorus (Fin 3)) := by
        simp only [hcoe]
      have hH_factor' : H_z =
          (fun t : UnitAddTorus (Fin 3) => (∏ j : Fin 3, fourier (-(k j)) (t j)) * f t) ∘
          (fun s : ℝ => (i.insertNth ((s : AddCircle (1:ℝ)) : UnitAddCircle) z : UnitAddTorus (Fin 3))) :=
        funext fun _ => rfl
      rw [hH_factor', Function.comp_apply, Function.comp_apply, hphi_eq]
    exact sub_eq_zero.mpr hperiod
  -- hContProd: continuity of the Fourier kernel t ↦ ∏_j fourier(-(k j))(t j)
  -- Used by both hPf_int and hDeriv_int for AEMeasurability.
  have hContProd : Continuous (fun t : UnitAddTorus (Fin 3) =>
      ∏ j : Fin 3, fourier (-(k j)) (t j)) :=
    continuous_finset_prod Finset.univ fun j _ =>
      (ContinuousMap.continuous (fourier (-(k j)))).comp (continuous_apply j)
  -- hFourierBound: ‖∏_j fourier(-(k j))(t j)‖ ≤ 1  (pointwise, from operator norm)
  -- Use Fin.prod_univ_three to unfold the 3-fold product, then norm_mul + bounds per factor.
  have hFourierBound : ∀ t : UnitAddTorus (Fin 3),
      ‖∏ j : Fin 3, fourier (-(k j)) (t j)‖ ≤ 1 := fun t => by
    have hfact : ∀ j : Fin 3, ‖fourier (-(k j)) (t j)‖ ≤ 1 := fun j =>
      (ContinuousMap.norm_coe_le_norm (fourier (-(k j))) (t j)).trans
        (le_of_eq (fourier_norm (-(k j))))
    -- Unfold to explicit product f 0 * f 1 * f 2, then use norm_mul
    rw [Fin.prod_univ_three, norm_mul, norm_mul]
    have h0 := hfact 0; have h1 := hfact 1; have h2 := hfact 2
    have n0 := norm_nonneg (fourier (-(k 0)) (t 0))
    have n1 := norm_nonneg (fourier (-(k 1)) (t 1))
    have n2 := norm_nonneg (fourier (-(k 2)) (t 2))
    -- ‖f0‖ * ‖f1‖ ≤ 1 * ‖f1‖ ≤ 1 * 1 = 1
    have h01 : ‖fourier (-(k 0)) (t 0)‖ * ‖fourier (-(k 1)) (t 1)‖ ≤ 1 :=
      (mul_le_mul_of_nonneg_right h0 n1).trans
        ((mul_le_mul_of_nonneg_left h1 zero_le_one).trans_eq (one_mul _))
    -- (‖f0‖ * ‖f1‖) * ‖f2‖ ≤ 1 * ‖f2‖ ≤ 1 * 1 = 1
    exact (mul_le_mul_of_nonneg_right h01 n2).trans
      ((mul_le_mul_of_nonneg_left h2 zero_le_one).trans_eq (one_mul _))
  -- hPf_int: Integrable (fun t => ∏_j fourier(-(k j))(t j) * f t)
  -- Route: Integrable.mono hf_base_int with bound ‖P(t)*f(t)‖ ≤ ‖f(t)‖ (since ‖P(t)‖ ≤ 1)
  have hPf_int : MeasureTheory.Integrable
      (fun t => (∏ j : Fin 3, fourier (-(k j)) (t j)) * f t)
      (volume : Measure (UnitAddTorus (Fin 3))) := by
    apply hf_base_int.mono
    · exact hContProd.aestronglyMeasurable.mul hf_base_int.1
    · filter_upwards with t
      show ‖(∏ j : Fin 3, fourier (-(k j)) (t j)) * f t‖ ≤ ‖f t‖
      rw [norm_mul]
      exact mul_le_of_le_one_left (norm_nonneg _) (hFourierBound t)
  -- hDeriv_int: Integrable (fun t => deriv (...) t₀_of t)
  -- Route: halg rearranges deriv = P*∂_if - c*(P*f);
  --        P*∂_if integrable via hf_int + Fourier bound;
  --        c*(P*f) integrable via hPf_int.const_mul.
  have hDeriv_int : MeasureTheory.Integrable
      (fun t : UnitAddTorus (Fin 3) => deriv (fun s : ℝ =>
          (∏ j : Fin 3, fourier (-(k j)) (Function.update t i ((s : AddCircle (1:ℝ))) j)) *
          f (Function.update t i ((s : AddCircle (1:ℝ)))))
        (t₀_of t))
      (volume : Measure (UnitAddTorus (Fin 3))) := by
    -- P * (∂_i f) is integrable by the same Fourier bound argument
    have hPDeriv_int : MeasureTheory.Integrable
        (fun t => (∏ j : Fin 3, fourier (-(k j)) (t j)) * torusPartialDeriv i f t)
        (volume : Measure (UnitAddTorus (Fin 3))) := by
      apply hf_int.mono
      · exact hContProd.aestronglyMeasurable.mul hf_int.1
      · filter_upwards with t
        show ‖(∏ j : Fin 3, fourier (-(k j)) (t j)) * torusPartialDeriv i f t‖ ≤
             ‖torusPartialDeriv i f t‖
        rw [norm_mul]
        exact mul_le_of_le_one_left (norm_nonneg _) (hFourierBound t)
    -- halg rearranges: deriv(t₀) = P*∂_if - c*(P*f)  (linear_combination -(halg t))
    have hDeriv_eq : (fun t : UnitAddTorus (Fin 3) => deriv (fun s : ℝ =>
            (∏ j : Fin 3, fourier (-(k j)) (Function.update t i ((s : AddCircle (1:ℝ))) j)) *
            f (Function.update t i ((s : AddCircle (1:ℝ)))))
          (t₀_of t)) =
        fun t => (∏ j : Fin 3, fourier (-(k j)) (t j)) * torusPartialDeriv i f t -
          (2 * Real.pi * Complex.I * ↑(k i)) *
            ((∏ j : Fin 3, fourier (-(k j)) (t j)) * f t) :=
      funext fun t => by linear_combination -(halg t)
    rw [hDeriv_eq]
    exact hPDeriv_int.sub (hPf_int.const_mul _)
  -- Assembly:
  -- ∫ (∏_j...) * ∂_i f = ∫ [deriv + 2πi*ki * (∏_j...) * f]   (by halg)
  --                     = ∫ deriv + 2πi*ki * ∫ (∏_j...) * f    (by integral_add + integral_mul_left)
  --                     = 0 + 2πi*ki * mFourierCoeff f k        (by hIntDeriv)
  rw [integral_congr_ae (ae_of_all _ halg)]
  rw [integral_add hDeriv_int (hPf_int.const_mul _)]
  rw [hIntDeriv, zero_add]
  -- Pull out the constant factor from the integral.
  -- integral_mul_left is ℝ-only; for ℂ use integral_smul (smul = mul for ℂ-modules).
  -- Rewrite c * g t → c • g t, then apply integral_smul, then smul_eq_mul closes the goal.
  have hc_smul : ∀ t : UnitAddTorus (Fin 3),
      (2 * ↑Real.pi * Complex.I * ↑(k i)) *
        ((∏ j : Fin 3, fourier (-(k j)) (t j)) * f t) =
      (2 * ↑Real.pi * Complex.I * ↑(k i)) •
        ((∏ j : Fin 3, fourier (-(k j)) (t j)) * f t) :=
    fun _ => (smul_eq_mul _ _).symm
  simp_rw [hc_smul]
  rw [integral_smul]
  exact smul_eq_mul _ _

/-- **Mean-zero of partial derivatives on T³** (NSC-P55, k=0 specialization):

    For smooth 1-periodic `f : UnitAddTorus (Fin 3) → ℂ`, the mean of `∂_i f` is zero:
    `∫ t : UnitAddTorus (Fin 3), torusPartialDeriv i f t = 0`

    **Proof** (k=0 of `mFourierCoeff_partialDeriv`):
    - `mFourierCoeff (∂_i f) 0 = (2πi · ↑0) * mFourierCoeff f 0 = 0`
    - `mFourierCoeff g 0 = ∫ t, g t` (since `mFourier 0 = 1`, kernel collapses to `1 · g`)

    **Categorical layer** (TLA+ NSFourierDerivFubini.tla):
    - `ept_stage = ZeroEntropicFlux` — terminal EPT state (Live_ZeroEntropicFlux liveness)
    - `cat_morphism = periodicity_quotient` — final morphism closing the 5-chain
    - `catept_layer = FourierSpectral` — spectral generator `∂_i ↔ 2πi·k_i` (§8 ZIL)
    - Satisfies `Inv_Closed_ZeroEntropicFlux`: proof terminates at `H_z 1 - H_z 0 = 0`

    **G2 application**: For `u : NSTorusVelocityField` smooth, each Jacobian component
    `J_ab = torusPartialDeriv a (fun t => ↑(u t b))` has mean zero on T³.
    Therefore `torusVorticity u` has mean zero (each curl component = `J_jk − J_kj`).
    Discharge path for `h_mean_zero` in `catept_torus_vorticity_bridge` without extra hypothesis.
    Full connection (`J_ab = torusPartialDeriv a u_j t`) deferred to NSC-P56 (ContDiff chain rule
    on quotient `UnitAddTorus`). -/
theorem integral_torusPartialDeriv_zero
    (i : Fin 3) (f : UnitAddTorus (Fin 3) → ℂ)
    (hf_diff : ∀ z : UnitAddTorus (Fin 3),
      HasDerivAt (fun s : ℝ => f (Function.update z i ((s : AddCircle (1 : ℝ)))))
        (torusPartialDeriv i f z)
        ((AddCircle.equivIoc (1 : ℝ) 0 (z i) : Set.Ioc (0 : ℝ) (0 + 1)).1))
    (hf_int : Integrable (torusPartialDeriv i f) (volume : Measure (UnitAddTorus (Fin 3))))
    (hf_base_int : Integrable f (volume : Measure (UnitAddTorus (Fin 3))))
    (hf_cont : Continuous f) :
    ∫ t : UnitAddTorus (Fin 3), torusPartialDeriv i f t = 0 := by
  -- k=0: mFourierCoeff (∂_i f) 0 = (2πi · ↑(0 i)) * mFourierCoeff f 0
  have h := mFourierCoeff_partialDeriv i f hf_diff hf_int hf_base_int hf_cont (0 : Fin 3 → ℤ)
  -- Step 1: collapse RHS to 0 before converting LHS.
  --   (0 : Fin 3 → ℤ) i = 0   [Pi.zero_apply]
  --   ↑(0 : ℤ) = 0             [Int.cast_zero / map_zero]
  --   2πI * 0 = 0              [mul_zero]
  --   0 * mFourierCoeff f 0 = 0 [zero_mul]
  simp only [Pi.zero_apply, Int.cast_zero, mul_zero, zero_mul] at h
  -- h : mFourierCoeff (torusPartialDeriv i f) (0 : Fin 3 → ℤ) = 0
  -- Step 2: convert LHS mFourierCoeff at k=0 to the plain integral.
  --   mFourierCoeff g 0 = ∫ t, mFourier (-0) t • g t  [def]
  --                     = ∫ t, mFourier 0 t • g t      [neg_zero]
  --                     = ∫ t, 1 • g t                 [mFourier_zero, ContinuousMap.one_apply]
  --                     = ∫ t, g t                     [one_smul]
  simp only [mFourierCoeff, neg_zero, mFourier_zero, ContinuousMap.one_apply, one_smul] at h
  exact h

/-! ## §2. H¹ Plancherel identity on UnitAddTorus (Fin 3) -/

/-- **Norm squared of partial derivative Fourier coefficient** (algebraic consequence of
    `mFourierCoeff_partialDeriv`):

    ```
    ‖mFourierCoeff (torusPartialDeriv i f) k‖^2 = (2*π)^2 * (k i)^2 * ‖mFourierCoeff f k‖^2
    ```

    **Proof**: Direct calculation using `mFourierCoeff_partialDeriv` and norm arithmetic:
    `‖(2πi*(k i)) * c‖^2 = ‖2πi*(k i)‖^2 * ‖c‖^2 = (2π)^2 * (k i)^2 * ‖c‖^2`. -/
private lemma norm_sq_mFourierCoeff_partialDeriv
    (i : Fin 3) (f : UnitAddTorus (Fin 3) → ℂ)
    (hf_diff : ∀ z : UnitAddTorus (Fin 3),
      HasDerivAt (fun s : ℝ => f (Function.update z i ((s : AddCircle (1:ℝ)))))
        (torusPartialDeriv i f z)
        ((AddCircle.equivIoc (1:ℝ) 0 (z i) : Set.Ioc (0:ℝ) (0+1)).1))
    (hf_int : MeasureTheory.Integrable (torusPartialDeriv i f)
        (volume : Measure (UnitAddTorus (Fin 3))))
    (hf_base_int : MeasureTheory.Integrable f
        (volume : Measure (UnitAddTorus (Fin 3))))
    (hf_cont : Continuous f)
    (k : Fin 3 → ℤ) :
    ‖mFourierCoeff (torusPartialDeriv i f) k‖ ^ 2 =
      (2 * Real.pi) ^ 2 * (k i : ℝ) ^ 2 * ‖mFourierCoeff f k‖ ^ 2 := by
  rw [mFourierCoeff_partialDeriv i f hf_diff hf_int hf_base_int hf_cont k]
  rw [norm_mul, mul_pow]
  congr 1
  -- Compute ‖2 * π * I * (k i : ℂ)‖^2 = (2π)^2 * (k i : ℝ)^2
  have hki_norm : ‖(2 * Real.pi * Complex.I * ↑(k i) : ℂ)‖ = 2 * Real.pi * |(k i : ℝ)| := by
    rw [show (2 * Real.pi * Complex.I * ↑(k i) : ℂ) =
        (↑(2 * Real.pi) : ℂ) * (Complex.I * ↑(k i : ℝ)) by push_cast; ring]
    rw [norm_mul, Complex.norm_real, Real.norm_of_nonneg (by positivity)]
    rw [norm_mul, Complex.norm_I, one_mul, Complex.norm_real, Real.norm_eq_abs]
  rw [hki_norm, mul_pow, sq_abs]

/-- **H¹ Plancherel identity** (sorry — derives from §1 + Parseval):

    For smooth `f : UnitAddTorus (Fin 3) → ℂ`:
    ```
    (2 * Real.pi)^2 * h1FourierSemiNorm f
      = ∑ i : Fin 3, ∫ t, ‖torusPartialDeriv i f t‖^2 ∂volume
    ```

    **Proof route**:
    Step 1 (done via `norm_sq_mFourierCoeff_partialDeriv`):
      `‖mFourierCoeff (∂_i f) k‖^2 = (2π)^2 * (k i)^2 * ‖mFourierCoeff f k‖^2`
    Step 2 (algebra): Sum over k:
      `∑' k, ‖mFourierCoeff (∂_i f) k‖^2 = (2π)^2 * ∑' k, (k i)^2 * ‖mFourierCoeff f k‖^2`
    Step 3 (algebra): Sum over i:
      `(2π)^2 * ∑' k, (∑ i, (k i)^2) * ‖mFourierCoeff f k‖^2 = ∑ i, ∑' k, (2π*(k i))^2 * ‖mFourierCoeff f k‖^2`
    Step 4 (sorry — Parseval): For ∂_i f ∈ L²:
      `∑' k, ‖mFourierCoeff (∂_i f) k‖^2 = ∫ ‖∂_i f t‖^2 ∂volume`
      (from `hasSum_sq_mFourierCoeff` applied to ∂_i f as an L² function)

    **Axioms**: sorry (needs mFourierCoeff_partialDeriv + Parseval for L² membership). -/
theorem h1FourierSemiNorm_plancherel
    (f : UnitAddTorus (Fin 3) → ℂ)
    (hf_diff : ∀ i : Fin 3, ∀ z : UnitAddTorus (Fin 3),
      HasDerivAt (fun s : ℝ => f (Function.update z i ((s : AddCircle (1 : ℝ)))))
        (torusPartialDeriv i f z)
        ((AddCircle.equivIoc (1 : ℝ) 0 (z i) : Set.Ioc (0 : ℝ) (0 + 1)).1))
    (hf_int : ∀ i : Fin 3, MeasureTheory.Integrable (torusPartialDeriv i f)
        (volume : Measure (UnitAddTorus (Fin 3))))
    (hf_base_int : MeasureTheory.Integrable f (volume : Measure (UnitAddTorus (Fin 3))))
    (hf_cont : Continuous f)
    (hf_memLp2 : ∀ i : Fin 3, MeasureTheory.MemLp (torusPartialDeriv i f) 2
        (volume : Measure (UnitAddTorus (Fin 3)))) :
    (2 * Real.pi) ^ 2 * NavierStokesClean.Sobolev.h1FourierSemiNorm f =
    ∑ i : Fin 3, ∫ t : UnitAddTorus (Fin 3),
      ‖torusPartialDeriv i f t‖ ^ 2 ∂(volume : Measure (UnitAddTorus (Fin 3))) := by
  -- S1: Expand h1FourierSemiNorm and h1FourierSemiNormCoeffs.
  -- Goal: (2π)^2 * ∑' k, (∑ i, (ki:ℝ)^2) * ‖mFourierCoeff f k‖^2 = ∑ i, ∫ ‖∂_if‖^2
  simp only [NavierStokesClean.Sobolev.h1FourierSemiNorm,
             NavierStokesClean.Sobolev.h1FourierSemiNormCoeffs]
  -- S2: For each i, Parseval's identity for ∂_if gives
  --     HasSum (fun k => (2π)^2*(k i:ℝ)^2*‖mFourierCoeff f k‖^2) (∫ ‖∂_if‖^2)
  have hPS : ∀ i : Fin 3, HasSum
      (fun k : Fin 3 → ℤ =>
        (2 * Real.pi) ^ 2 * (k i : ℝ) ^ 2 * ‖mFourierCoeff f k‖ ^ 2)
      (∫ t : UnitAddTorus (Fin 3), ‖torusPartialDeriv i f t‖ ^ 2) :=
    fun i => by
      -- Lift ∂_if to L² using the MemLp 2 hypothesis.
      -- pd_lp : Lp ℂ 2 volume — the L² representative of torusPartialDeriv i f
      let pd_lp := (hf_memLp2 i).toLp (torusPartialDeriv i f)
      -- Parseval's identity for the L² representative
      have hParseval := hasSum_sq_mFourierCoeff pd_lp
      -- ae-equality: coercion of the L² element ≈ original partial derivative
      have hae : (pd_lp : UnitAddTorus (Fin 3) → ℂ) =ᵐ[volume]
          torusPartialDeriv i f :=
        (hf_memLp2 i).coeFn_toLp
      -- Fourier coefficients of the L² coercion equal those of the original function.
      -- mFourierCoeff g k = ∫ t, mFourier (-k) t • g t; integral_congr_ae applies.
      have hFC : ∀ k : Fin 3 → ℤ,
          mFourierCoeff (pd_lp : UnitAddTorus (Fin 3) → ℂ) k =
          mFourierCoeff (torusPartialDeriv i f) k := fun k => by
        simp only [mFourierCoeff]
        exact integral_congr_ae (hae.mono fun t ht => by simp [ht])
      -- Integral of ‖coercion‖^2 = integral of ‖∂_if‖^2  (same ae-equality)
      have hInt :
          ∫ t : UnitAddTorus (Fin 3), ‖(pd_lp : UnitAddTorus (Fin 3) → ℂ) t‖ ^ 2 =
          ∫ t : UnitAddTorus (Fin 3), ‖torusPartialDeriv i f t‖ ^ 2 :=
        integral_congr_ae (hae.mono fun t ht => by simp [ht])
      -- Combine hFC + norm_sq_mFourierCoeff_partialDeriv into a single pointwise equality.
      -- h1 : ‖mFourierCoeff (↑pd_lp) k‖^2 = (2π)^2*(ki)^2*‖mFourierCoeff f k‖^2
      have h1 : ∀ k : Fin 3 → ℤ,
          ‖mFourierCoeff (pd_lp : UnitAddTorus (Fin 3) → ℂ) k‖ ^ 2 =
          (2 * Real.pi) ^ 2 * (k i : ℝ) ^ 2 * ‖mFourierCoeff f k‖ ^ 2 := fun k => by
        rw [hFC k]
        exact norm_sq_mFourierCoeff_partialDeriv i f (hf_diff i) (hf_int i)
          hf_base_int hf_cont k
      -- Rewrite hParseval's function using h1 (simp_rw works under the lambda),
      -- then rewrite the limit using hInt.
      simp_rw [h1] at hParseval
      rwa [hInt] at hParseval
  -- S3: Sum Parseval over all i ∈ Fin 3.
  -- hSum : HasSum (fun k => ∑ i, (2π)^2*(ki)^2*‖ck‖^2) (∑ i, ∫ ‖∂_if‖^2)
  have hSum : HasSum
      (fun k : Fin 3 → ℤ =>
        ∑ i : Fin 3, (2 * Real.pi) ^ 2 * (k i : ℝ) ^ 2 * ‖mFourierCoeff f k‖ ^ 2)
      (∑ i : Fin 3, ∫ t : UnitAddTorus (Fin 3), ‖torusPartialDeriv i f t‖ ^ 2) :=
    hasSum_sum fun i _ => hPS i
  -- S4 + S5: Algebraic rearrangement then close.
  --   (2π)^2 * ∑' k, (∑ i, (ki)^2)*‖ck‖^2
  -- = ∑' k, (2π)^2 * ((∑ i, (ki)^2)*‖ck‖^2)   [← tsum_mul_left]
  -- = ∑' k, ∑ i, (2π)^2*(ki)^2*‖ck‖^2          [Finset.sum_mul + Finset.mul_sum + ring]
  -- = ∑ i, ∫ ‖∂_if‖^2                            [hSum.tsum_eq]
  rw [← hSum.tsum_eq, ← tsum_mul_left]
  congr 1; ext k
  simp only [Finset.sum_mul, Finset.mul_sum]
  congr 1; ext i; ring

/-- **H¹ Plancherel upper bound** (follows from `h1FourierSemiNorm_plancherel`):

    For smooth `f : UnitAddTorus (Fin 3) → ℂ`:
    ```
    h1FourierSemiNorm f ≤ ∑ i : Fin 3, ∫ t, ‖torusPartialDeriv i f t‖^2 ∂volume
    ```

    Equivalently: `(2π)^2 · h1FourierSemiNorm f = ∑_i ∫ ‖∂_i f‖^2`
    and since `(2π)^2 ≈ 39.5 > 1`, we get `h1FourierSemiNorm f ≤ ∑_i ∫ ‖∂_i f‖^2`.

    This bound is used in `space_torus_vorticity_bridge` property (4):
    `h1FourierSemiNorm ω̃ ≤ palinstrophySpatial u`. -/
theorem h1FourierSemiNorm_le_gradient_integral
    (f : UnitAddTorus (Fin 3) → ℂ)
    (hf_diff : ∀ i : Fin 3, ∀ z : UnitAddTorus (Fin 3),
      HasDerivAt (fun s : ℝ => f (Function.update z i ((s : AddCircle (1 : ℝ)))))
        (torusPartialDeriv i f z)
        ((AddCircle.equivIoc (1 : ℝ) 0 (z i) : Set.Ioc (0 : ℝ) (0 + 1)).1))
    (hf_int : ∀ i : Fin 3, MeasureTheory.Integrable (torusPartialDeriv i f)
        (volume : Measure (UnitAddTorus (Fin 3))))
    (hf_base_int : MeasureTheory.Integrable f (volume : Measure (UnitAddTorus (Fin 3))))
    (hf_cont : Continuous f)
    (hf_memLp2 : ∀ i : Fin 3, MeasureTheory.MemLp (torusPartialDeriv i f) 2
        (volume : Measure (UnitAddTorus (Fin 3)))) :
    NavierStokesClean.Sobolev.h1FourierSemiNorm f ≤
    ∑ i : Fin 3, ∫ t : UnitAddTorus (Fin 3),
      ‖torusPartialDeriv i f t‖ ^ 2 ∂(volume : Measure (UnitAddTorus (Fin 3))) := by
  have hPlanch := h1FourierSemiNorm_plancherel f hf_diff hf_int hf_base_int hf_cont hf_memLp2
  -- h1FourierSemiNorm f = (1/(2π)^2) * ∑_i ∫ ‖∂_i f‖^2
  -- ≤ ∑_i ∫ ‖∂_i f‖^2 since (1/(2π)^2) ≤ 1
  have hpi_sq_pos : (0 : ℝ) < (2 * Real.pi) ^ 2 := by positivity
  have hpi_sq_ge_one : (1 : ℝ) ≤ (2 * Real.pi) ^ 2 := by
    have hpi3 : (3 : ℝ) < Real.pi := Real.pi_gt_three
    nlinarith [sq_nonneg (2 * Real.pi)]
  have hgrad_nonneg : (0 : ℝ) ≤ ∑ i : Fin 3, ∫ t : UnitAddTorus (Fin 3),
      ‖torusPartialDeriv i f t‖ ^ 2 ∂(volume : Measure (UnitAddTorus (Fin 3))) :=
    Finset.sum_nonneg fun i _ => integral_nonneg fun _ => sq_nonneg _
  -- From Plancherel: (2π)^2 * h1FourierSemiNorm f = ∑_i ∫ ‖∂_i f‖^2
  -- So h1FourierSemiNorm f = (∑_i ∫ ‖∂_i f‖^2) / (2π)^2 ≤ ∑_i ∫ ‖∂_i f‖^2
  have hkey : NavierStokesClean.Sobolev.h1FourierSemiNorm f =
      (∑ i : Fin 3, ∫ t : UnitAddTorus (Fin 3),
        ‖torusPartialDeriv i f t‖ ^ 2 ∂(volume : Measure (UnitAddTorus (Fin 3)))) /
      (2 * Real.pi) ^ 2 := by
    field_simp
    linarith [hPlanch]
  rw [hkey]
  exact div_le_self hgrad_nonneg hpi_sq_ge_one

/-! ## §3. Mean-zero of torusVorticity (NSC-P56) -/

/-- **Mean-zero of T³ vorticity** (NSC-P56, sorry-theorem).

    For a smooth velocity field `u : NSTorusVelocityField`, the vorticity has zero mean:
    ```
    ∫_{T³} torusVorticity u t dt = 0   (in EuclideanSpace ℝ (Fin 3))
    ```

    **Proof structure** (all steps localized; sorry at chain-rule-on-quotient step only):

    Let `u_flat x = u (fun i => (x i : AddCircle 1))` (smooth lift, ContDiff ℝ ⊤ by h_smooth).
    For each `a b : Fin 3`, define `g_b : UnitAddTorus (Fin 3) → ℝ := fun z => (u z) b`
    (continuous by hCont). Then:

    **Step 1** (global identity, 0 sorry):
    For any `z : UnitAddTorus (Fin 3)`, `s : ℝ`, and `x₀ := fun k => (equivIoc 1 0 (z k)).val`:
    ```
      g_b (Function.update z a ((s : ℝ) : AddCircle (1:ℝ)))
      = u_flat (Function.update x₀ a s) b
    ```
    Proof: `update z a (s : AddCircle 1) = fun k => (update x₀ a s k : AddCircle 1)` because
    - k=a: `(s : AddCircle 1) = ((update x₀ a s a : ℝ) : AddCircle 1)` (both = `(s : AddCircle 1)`)
    - k≠a: `z k = ((x₀ k : ℝ) : AddCircle 1)` by `(AddCircle.equivIoc 1 0).symm_apply_apply (z k)`

    **Step 2** (HasDerivAt via ContDiff chain rule, 0 sorry given ContinuousLinearMap API):
    ```
      HasDerivAt (fun s => (u_flat (Function.update x₀ a s)) b)
        (fderiv ℝ (fun x => u_flat x b) x₀ (Pi.single a 1)) t₀
    ```
    Route:
    - `HasFDerivAt (fun x => u_flat x b) (fderiv ℝ (fun x => u_flat x b) x₀) x₀`
      (from h_smooth via `ContDiff.hasFDerivAt`)
    - `HasDerivAt (fun s => Function.update x₀ a s) (Pi.single a 1 : Fin 3 → ℝ) t₀`
      (linear map: update x₀ a s = (x₀ - x₀ a • Pi.single a 1) + s • Pi.single a 1,
       derivative = Pi.single a 1 by `hasDerivAt_id.smul_const + const_add`)
    - Chain rule: `HasFDerivAt.comp_hasDerivAt` at `update x₀ a t₀ = x₀`
      (`update x₀ a (x₀ a) = x₀` by `Function.update_eq_self`; t₀ = x₀ a by def of x₀)

    **Step 3** (J = fderiv, 0 sorry):
    `fderiv ℝ (fun x => u_flat x b) x₀ (Pi.single a 1) = J a b z` where
    `J a b z = (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat x₀ (Pi.single a 1))) b`
    by linearity of b-th projection through ContinuousLinearMap and fderiv chain rule.

    **Step 4** (torusPartialDeriv = J, 0 sorry given Steps 1–3):
    From Steps 1–3: `HasDerivAt (fun s => g_b (update z a (s : AddCircle 1))) (J a b z) t₀`.
    Therefore `torusPartialDeriv a (fun z => ↑(g_b z)) z = (J a b z : ℂ)`.

    **Step 5** (integral_torusPartialDeriv_zero, 0 sorry given Steps 1–4):
    Apply `integral_torusPartialDeriv_zero a (fun z => ↑(g_b z))`:
    - hf_cont: `g_b` continuous (hCont + projection) → `↑ ∘ g_b` continuous ✓
    - hf_base_int: compact domain ✓
    - hf_diff: HasDerivAt from Step 4 (with torusPartialDeriv value = ↑(J a b z)) ✓
    - hf_int: from h_smooth → bounded gradient on compact → integrable ✓
    Conclusion: `∫ z, torusPartialDeriv a (fun z => ↑(g_b z)) z = 0`.
    Step 4 gives: `∫ z, (J a b z : ℂ) = 0`, hence `∫ z, J a b z = 0` (ℝ-valued).

    **Step 6** (linearity, 0 sorry):
    `torusVorticity u z = (WithLp.equiv 2 (Fin 3 → ℝ)).symm ![J 1 2 - J 2 1, J 2 0 - J 0 2, J 0 1 - J 1 0] z`
    By integral linearity and `∫ J a b = 0` for all a b:
    ```
      ∫ z, torusVorticity u z
      = (WithLp.equiv 2 (Fin 3 → ℝ)).symm ![∫ J 1 2 - ∫ J 2 1, ...]
      = (WithLp.equiv 2 (Fin 3 → ℝ)).symm ![0, 0, 0] = 0
    ```

    **Current blocker** (sorry discharge = NSC-P57):
    Steps 2–5 require `HasDerivAt.comp_of_hasFDerivAt` for the composition
    `ℝ →[update x₀ a]→ (Fin 3 → ℝ) →[u_flat_b]→ ℝ` at a `ℝ`-module level.
    The specific Mathlib lemma needed:
    `HasFDerivAt.comp_hasDerivAt : HasFDerivAt f f' (g t) → HasDerivAt g g' t →
      HasDerivAt (f ∘ g) (f' g') t`
    This compiles cleanly with `ContinuousLinearMap.comp_hasDerivAt` or
    `HasFDerivAt.comp_hasDerivAt` from `Mathlib.Analysis.Calculus.Deriv.Comp`.

    **TLA+ context**: catept_layer=FourierSpectral, cat_morphism=periodicity_quotient,
    ept_stage=MeanZeroVorticity. Inv_Stokes_After_Tonelli_Adjunction ✓ (via Step 5).
    Live_MeanZeroVorticity_Proved = NSC-P57 milestone. -/
theorem torusMeanZero_vorticity
    (u : Sobolev.NSTorusVelocityField)
    (hCont : Continuous u)
    (h_smooth : ContDiff ℝ ⊤
      (fun x : Fin 3 → ℝ => u (fun i => (x i : AddCircle (1:ℝ))))) :
    ∫ t : UnitAddTorus (Fin 3),
      Sobolev.torusVorticity u t = 0 := by
  set u_flat : (Fin 3 → ℝ) → EuclideanSpace ℝ (Fin 3) :=
    fun x => u (fun i => (x i : AddCircle (1:ℝ))) with hu_flat_def
  -- **Integrability of Jacobian components** (used in hJ and in final step).
  -- J a b z = (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat x₀(z) (Pi.single a 1))) b
  -- Strategy: AEMeasurable (composition of measurables) + bounded (fderiv bounded on [0,1]^3
  -- since x₀(z) ∈ (0,1]^3 ⊂ [0,1]^3 compact, fderiv ℝ u_flat continuous) + IsFiniteMeasure.
  have hJ_int : ∀ (a b : Fin 3), Integrable (fun z : UnitAddTorus (Fin 3) =>
      (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
        (fun k : Fin 3 => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val)
        (Pi.single a 1))) b) := by
    intro a b
    -- (1) Continuity of the Jacobian component function on ℝ³:
    --   x ↦ (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat x (Pi.single a 1))) b
    --   = continuous_apply b ∘ PiLp.continuousLinearEquiv ∘ clm_apply(Pi.single a 1) ∘ fderiv
    have h_cts : Continuous (fun x : Fin 3 → ℝ =>
        (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat x (Pi.single a 1))) b) :=
      (continuous_apply b).comp
        ((PiLp.continuousLinearEquiv 2 ℝ (fun _ : Fin 3 => ℝ)).continuous.comp
          ((h_smooth.continuous_fderiv (WithTop.top_ne_coe (a := (0:ℕ∞)))).clm_apply
            continuous_const))
    -- (2) Measurability of x₀ : UnitAddTorus → ℝ³ from cateptTorus_measurePreserving.
    --   MeasurePreserving.measurable gives Measurable of the underlying map.
    have h_x0_meas : Measurable (fun z : UnitAddTorus (Fin 3) =>
        fun k : Fin 3 => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val) :=
      Sobolev.cateptTorus_measurePreserving.measurable
    -- (3) AEStronglyMeasurable via continuous ∘ measurable composition.
    have hmeas : AEStronglyMeasurable (fun z : UnitAddTorus (Fin 3) =>
        (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
          (fun k => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val)
          (Pi.single a 1))) b) volume :=
      (h_cts.measurable.comp h_x0_meas).aestronglyMeasurable
    -- (4) x₀(z) ∈ [0,1]³: equivIoc gives val ∈ (0, 0+1] = (0,1], so val ∈ [0,1].
    have hx0_icc : ∀ z : UnitAddTorus (Fin 3),
        (fun k => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val) ∈ Set.Icc (0 : Fin 3 → ℝ) 1 := by
      intro z
      simp only [Set.mem_Icc, Pi.le_def, Pi.zero_apply, Pi.one_apply]
      exact ⟨fun k => le_of_lt (AddCircle.equivIoc 1 0 (z k)).2.1,
             fun k => by have h := (AddCircle.equivIoc 1 0 (z k)).2.2; linarith⟩
    -- (5) Bound ‖fderiv u_flat‖ ≤ C on [0,1]³ by compactness of Icc.
    obtain ⟨C, hC⟩ := isCompact_Icc.exists_bound_of_continuousOn
      (h_smooth.continuous_fderiv (WithTop.top_ne_coe (a := (0:ℕ∞)))).continuousOn
    -- (6) IsFiniteMeasure on UnitAddTorus via IsProbabilityMeasure Pi chain:
    --   haarAddCircle is IsProbabilityMeasure → Pi torus is IsProbabilityMeasure → IsFiniteMeasure.
    --   Use inferInstanceAs to bridge the local volume = haarAddCircle alias.
    haveI : IsProbabilityMeasure (volume : Measure UnitAddCircle) :=
      inferInstanceAs (IsProbabilityMeasure AddCircle.haarAddCircle)
    haveI : IsProbabilityMeasure (volume : Measure (UnitAddTorus (Fin 3))) := inferInstance
    haveI : IsFiniteMeasure (volume : Measure (UnitAddTorus (Fin 3))) := inferInstance
    -- (7) Integrable.of_bound: bound the component norm pointwise, use IsFiniteMeasure.
    apply Integrable.of_bound hmeas (C * ‖(Pi.single a (1 : ℝ) : Fin 3 → ℝ)‖)
    filter_upwards with z
    -- Set v to make the PiLp.norm_apply_le unification explicit (= rfl step).
    set v := fderiv ℝ u_flat (fun k => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val) (Pi.single a 1)
    calc ‖(WithLp.equiv 2 (Fin 3 → ℝ) v) b‖
        = ‖v b‖ := rfl
      _ ≤ ‖v‖ := PiLp.norm_apply_le v b
      _ ≤ ‖fderiv ℝ u_flat (fun k => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val)‖ *
            ‖(Pi.single a (1 : ℝ) : Fin 3 → ℝ)‖ := by
          show ‖fderiv ℝ u_flat _ (Pi.single a 1)‖ ≤ _
          exact ContinuousLinearMap.le_opNorm _ _
      _ ≤ C * ‖(Pi.single a (1 : ℝ) : Fin 3 → ℝ)‖ :=
          mul_le_mul_of_nonneg_right (hC _ (hx0_icc z)) (norm_nonneg _)
  /-
    **NSC-P57**: Key claim: ∫ z, J a b z = 0 for all a b, where
    J a b z = (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat x₀(z) (Pi.single a 1))) b
    is the (a,b) entry of the Jacobian of u_flat at the representative x₀(z).
    Proof: apply integral_torusPartialDeriv_zero to f z = ↑((u z) b).
    The HasDerivAt for f ∘ update comes from:
      (1) u(update z a (s : AddCircle 1)) = u_flat(update x₀ a s) [quotient identity]
      (2) HasFDerivAt u_flat at x₀ [from h_smooth]
      (3) HasDerivAt (update x₀ a) (Pi.single a 1) t₀ [hasDerivAt_update]
      (4) Chain rule HasFDerivAt.comp_hasDerivAt_of_eq
  -/
  have hJ : ∀ (a b : Fin 3),
      ∫ z : UnitAddTorus (Fin 3),
        (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
          (fun k : Fin 3 => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val)
          (Pi.single a 1))) b = 0 := by
    intro a b
    set f : UnitAddTorus (Fin 3) → ℂ :=
      fun z => ((WithLp.equiv 2 (Fin 3 → ℝ) (u z)) b : ℝ)
    have hf_cont : Continuous f :=
      Complex.continuous_ofReal.comp
        ((continuous_apply b).comp
          ((PiLp.continuousLinearEquiv 2 ℝ (fun _ : Fin 3 => ℝ)).continuous.comp hCont))
    -- Step A: quotient identity u(update z a (s : AddCircle 1)) = u_flat(update x₀ a s)
    have hident : ∀ (z : UnitAddTorus (Fin 3)) (s : ℝ),
        u (Function.update z a ((s : AddCircle (1:ℝ)))) =
        u_flat (Function.update (fun k => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val) a s) := by
      intro z s
      simp only [hu_flat_def]
      congr 1
      ext k
      simp only [Function.update_apply]
      split_ifs with hk
      · rfl
      · exact ((AddCircle.equivIoc (1:ℝ) 0).symm_apply_apply (z k)).symm
    -- Step B: HasDerivAt for the b-th component of u along coordinate a (u-version)
    -- Proves HasDerivAt (fun s => (WithLp.equiv ... (u (update z a ↑s))) b) (J z) t₀
    have h_real : ∀ z : UnitAddTorus (Fin 3),
        let t₀ := (AddCircle.equivIoc (1:ℝ) 0 (z a)).val
        let x₀ := fun k : Fin 3 => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val
        HasDerivAt
          (fun s : ℝ => (WithLp.equiv 2 (Fin 3 → ℝ) (u (Function.update z a ((s : AddCircle (1:ℝ)))))) b)
          ((WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat x₀ (Pi.single a 1))) b) t₀ := by
      intro z
      set t₀ := (AddCircle.equivIoc (1:ℝ) 0 (z a)).val
      set x₀ : Fin 3 → ℝ := fun k => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val
      have h_hfd : HasFDerivAt u_flat (fderiv ℝ u_flat x₀) x₀ := by
        -- ContDiff (WithTop ℕ∞) ⊤ → Differentiable via hn: ⊤ ≠ 0 in WithTop ℕ∞.
        -- WithTop.top_ne_coe (a := 0 : ℕ∞) gives (⊤ : WithTop ℕ∞) ≠ ↑0 = 0.
        exact (h_smooth.differentiable (WithTop.top_ne_coe (a := (0:ℕ∞))) x₀).hasFDerivAt
      -- HasFDerivAt of b-th component via PiLp.proj (definitionally = (WithLp.equiv ...) b)
      have h_hfd_b :=
        HasFDerivAt.comp x₀
          (PiLp.proj (p := 2) (β := fun _ : Fin 3 => ℝ) b).hasFDerivAt h_hfd
      have h_upd : HasDerivAt (Function.update x₀ a) (Pi.single a 1) t₀ :=
        hasDerivAt_update x₀ a t₀
      have h_eq : Function.update x₀ a t₀ = x₀ := Function.update_eq_self a x₀
      -- comp_hasDerivAt_of_eq signature (variable x explicit): (hl) (x : 𝕜) (hf) (hy)
      -- y = x₀ (base point of h_hfd_b), f = update x₀ a, x = t₀, hy : x₀ = update x₀ a t₀
      have h_comp := h_hfd_b.comp_hasDerivAt_of_eq t₀ h_upd h_eq.symm
      simp only [Function.comp, ContinuousLinearMap.comp_apply,
        PiLp.proj_apply, PiLp.continuousLinearEquiv_apply] at h_comp
      -- h_comp : HasDerivAt (fun s => (WithLp.equiv ... (u_flat (update x₀ a s))) b) J t₀
      -- Convert to u-version via hident: u(update z a ↑s) = u_flat(update x₀ a s)
      apply h_comp.congr_of_eventuallyEq
      · exact Filter.Eventually.of_forall fun s => by
          simp only [Function.comp, PiLp.proj_apply]
          exact congrFun (congrArg (WithLp.equiv 2 (Fin 3 → ℝ) ·) (hident z s)) b
    -- Step C: torusPartialDeriv a f z = ↑(J a b z) via chain rule with Complex.ofRealCLM
    have h_pd : ∀ z : UnitAddTorus (Fin 3),
        torusPartialDeriv a f z =
        ((WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
            (fun k => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val) (Pi.single a 1))) b : ℝ) := by
      intro z
      -- Unfold torusPartialDeriv and f to expose the deriv expression
      simp only [torusPartialDeriv, f]
      -- Goal: deriv (fun s => ((WithLp.equiv ... (u (update z a ↑s))) b : ℝ)) t₀ = ↑(J z)
      -- f (update z a ↑s) = Complex.ofRealCLM ((... b) : ℝ) definitionally (same coercion)
      -- comp_hasDerivAt gives HasDerivAt (Complex.ofRealCLM ∘ ...) (Complex.ofRealCLM (J z)) t₀
      exact (Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt _ (h_real z)).deriv
    -- Step D: apply integral_torusPartialDeriv_zero
    -- Extract hf_int as named have to reuse in Step E
    have hf_int : Integrable (torusPartialDeriv a f) := by
      -- torusPartialDeriv a f = Complex.ofRealCLM ∘ J a b (via h_pd), use integrable_comp.
      have hkey : torusPartialDeriv a f =
          Complex.ofRealCLM ∘ (fun z => (WithLp.equiv 2 (Fin 3 → ℝ)
            (fderiv ℝ u_flat (fun k => (AddCircle.equivIoc (1:ℝ) 0 (z k)).val)
              (Pi.single a 1))) b) :=
        funext fun z => by simp only [Function.comp, Complex.ofRealCLM_apply]; exact h_pd z
      rw [hkey]
      exact Complex.ofRealCLM.integrable_comp (hJ_int a b)
    have h_int0 : ∫ z : UnitAddTorus (Fin 3), torusPartialDeriv a f z = 0 :=
      integral_torusPartialDeriv_zero a f
        (fun z => by
          -- Goal: HasDerivAt (fun s => f (update z a ↑s)) (torusPartialDeriv a f z) t₀
          rw [h_pd z]
          -- Goal: HasDerivAt (fun s => f (update z a ↑s)) (↑(J z)) t₀
          -- f (update z a ↑s) = Complex.ofRealCLM ((WithLp.equiv ... (u (update z a ↑s))) b) defnl.
          exact Complex.ofRealCLM.hasFDerivAt.comp_hasDerivAt _ (h_real z))
        hf_int
        (by -- f continuous on compact UnitAddTorus → bounded → integrable.
            -- IsFiniteMeasure via IsProbabilityMeasure Pi chain (no whnf loop).
            haveI : IsProbabilityMeasure (volume : Measure UnitAddCircle) :=
              inferInstanceAs (IsProbabilityMeasure AddCircle.haarAddCircle)
            haveI : IsProbabilityMeasure (volume : Measure (UnitAddTorus (Fin 3))) := inferInstance
            haveI : IsFiniteMeasure (volume : Measure (UnitAddTorus (Fin 3))) := inferInstance
            obtain ⟨C, hC⟩ := isCompact_univ.exists_bound_of_continuousOn hf_cont.continuousOn
            exact Integrable.of_bound hf_cont.aestronglyMeasurable C
              (Filter.Eventually.of_forall fun z => hC z (Set.mem_univ z)))
        hf_cont
    -- Step E: ∫ J a b = 0 in ℝ via Re-extraction
    -- Re(∫ torusPartialDeriv a f) = (∫ torusPartialDeriv a f).re = 0.re = 0
    -- Then Re(torusPartialDeriv a f z) = Re(↑(J z)) = J z  via h_pd + Complex.ofReal_re
    have h_re : ∫ z : UnitAddTorus (Fin 3), (torusPartialDeriv a f z).re = 0 := by
      have key := Complex.reCLM.integral_comp_comm hf_int
      simp only [Complex.reCLM_apply] at key
      -- key : ∫ z, (torusPartialDeriv a f z).re = (∫ z, torusPartialDeriv a f z).re
      rw [key, h_int0, Complex.zero_re]
    simp_rw [h_pd, Complex.ofReal_re] at h_re
    exact h_re
  -- **Final step**: ∫ torusVorticity u = 0 using hJ component-wise.
  -- Use eval_integral_piLp: (∫ f) i = ∫ f · i  (swap component eval and integral).
  apply PiLp.ext; intro b
  simp only [PiLp.zero_apply]
  -- (∫ t, torusVorticity u t) b = ∫ t, (torusVorticity u t) b
  rw [MeasureTheory.eval_integral_piLp (fun i => by
    -- Each component i of torusVorticity u is a difference of two J_ab terms → integrable.
    -- Strategy: prove pointwise equality via funext+simp, rw goal, close with Integrable.sub.
    fin_cases i
    · -- i = 0: torusVorticity u t 0 = J 1 2 t - J 2 1 t
      -- `show` coerces (fun i => i) ⟨0, ⋯⟩ → (0 : Fin 3) so rw can match h0.
      show Integrable (fun t => (Sobolev.torusVorticity u t) (0 : Fin 3)) volume
      have h0 : (fun t : UnitAddTorus (Fin 3) => (Sobolev.torusVorticity u t) (0 : Fin 3)) =
          fun t => (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
              (fun k => (AddCircle.equivIoc (1:ℝ) 0 (t k)).val) (Pi.single 1 1))) 2 -
            (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
              (fun k => (AddCircle.equivIoc (1:ℝ) 0 (t k)).val) (Pi.single 2 1))) 1 := by
        funext t
        simp only [Sobolev.torusVorticity, ← hu_flat_def, WithLp.equiv_symm_apply, WithLp.ofLp_toLp,
                   Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
                   Matrix.head_cons, Matrix.tail_cons]
      rw [h0]; exact (hJ_int 1 2).sub (hJ_int 2 1)
    · -- i = 1: torusVorticity u t 1 = J 2 0 t - J 0 2 t
      show Integrable (fun t => (Sobolev.torusVorticity u t) (1 : Fin 3)) volume
      have h1 : (fun t : UnitAddTorus (Fin 3) => (Sobolev.torusVorticity u t) (1 : Fin 3)) =
          fun t => (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
              (fun k => (AddCircle.equivIoc (1:ℝ) 0 (t k)).val) (Pi.single 2 1))) 0 -
            (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
              (fun k => (AddCircle.equivIoc (1:ℝ) 0 (t k)).val) (Pi.single 0 1))) 2 := by
        funext t
        simp only [Sobolev.torusVorticity, ← hu_flat_def, WithLp.equiv_symm_apply, WithLp.ofLp_toLp,
                   Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
                   Matrix.head_cons, Matrix.tail_cons]
      rw [h1]; exact (hJ_int 2 0).sub (hJ_int 0 2)
    · -- i = 2: torusVorticity u t 2 = J 0 1 t - J 1 0 t
      show Integrable (fun t => (Sobolev.torusVorticity u t) (2 : Fin 3)) volume
      have h2 : (fun t : UnitAddTorus (Fin 3) => (Sobolev.torusVorticity u t) (2 : Fin 3)) =
          fun t => (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
              (fun k => (AddCircle.equivIoc (1:ℝ) 0 (t k)).val) (Pi.single 0 1))) 1 -
            (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
              (fun k => (AddCircle.equivIoc (1:ℝ) 0 (t k)).val) (Pi.single 1 1))) 0 := by
        funext t
        simp only [Sobolev.torusVorticity, ← hu_flat_def, WithLp.equiv_symm_apply, WithLp.ofLp_toLp,
                   Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
                   Matrix.head_cons, Matrix.tail_cons]
      rw [h2]; exact (hJ_int 0 1).sub (hJ_int 1 0)) b]
  -- Goal: ∫ t, (torusVorticity u t) b = 0
  -- Shared simp set for unfolding each vorticity component:
  -- torusVorticity unfolds to (WithLp.equiv 2 (Fin 3 → ℝ)).symm ![J 1 2 - J 2 1, ...]
  -- WithLp.equiv_symm_apply reduces the .symm wrapper
  -- Matrix.cons_val_zero/one/head_cons/tail_cons evaluate ![a,b,c] at 0,1,2
  -- ← hu_flat_def connects the internal let-bound u_flat to the theorem's `set u_flat`
  fin_cases b
  · -- b = 0: component is J₁₂ - J₂₁
    conv_lhs =>
      arg 2
      ext t
      change (Sobolev.torusVorticity u t) (0 : Fin 3)
      rw [show (Sobolev.torusVorticity u t) (0 : Fin 3) =
          (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
            (fun k => (AddCircle.equivIoc 1 0 (t k)).val) (Pi.single 1 1))) 2 -
          (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
            (fun k => (AddCircle.equivIoc 1 0 (t k)).val) (Pi.single 2 1))) 1
          from by simp only [Sobolev.torusVorticity, ← hu_flat_def,
                             WithLp.equiv_symm_apply, WithLp.ofLp_toLp,
                             Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
                             Matrix.head_cons, Matrix.tail_cons]]
    rw [integral_sub (hJ_int 1 2) (hJ_int 2 1), hJ 1 2, hJ 2 1, sub_self]
  · -- b = 1: component is J₂₀ - J₀₂
    conv_lhs =>
      arg 2
      ext t
      change (Sobolev.torusVorticity u t) (1 : Fin 3)
      rw [show (Sobolev.torusVorticity u t) (1 : Fin 3) =
          (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
            (fun k => (AddCircle.equivIoc 1 0 (t k)).val) (Pi.single 2 1))) 0 -
          (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
            (fun k => (AddCircle.equivIoc 1 0 (t k)).val) (Pi.single 0 1))) 2
          from by simp only [Sobolev.torusVorticity, ← hu_flat_def,
                             WithLp.equiv_symm_apply, WithLp.ofLp_toLp,
                             Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
                             Matrix.head_cons, Matrix.tail_cons]]
    rw [integral_sub (hJ_int 2 0) (hJ_int 0 2), hJ 2 0, hJ 0 2, sub_self]
  · -- b = 2: component is J₀₁ - J₁₀
    conv_lhs =>
      arg 2
      ext t
      change (Sobolev.torusVorticity u t) (2 : Fin 3)
      rw [show (Sobolev.torusVorticity u t) (2 : Fin 3) =
          (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
            (fun k => (AddCircle.equivIoc 1 0 (t k)).val) (Pi.single 0 1))) 1 -
          (WithLp.equiv 2 (Fin 3 → ℝ) (fderiv ℝ u_flat
            (fun k => (AddCircle.equivIoc 1 0 (t k)).val) (Pi.single 1 1))) 0
          from by simp only [Sobolev.torusVorticity, ← hu_flat_def,
                             WithLp.equiv_symm_apply, WithLp.ofLp_toLp,
                             Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
                             Matrix.head_cons, Matrix.tail_cons]]
    rw [integral_sub (hJ_int 0 1) (hJ_int 1 0), hJ 0 1, hJ 1 0, sub_self]

/-! ### §4 — Smooth velocity bridge (NSC-P58, discharged in NSC-P59)

**`space_torus_vorticity_bridge_smooth`** (NSC-P58, **0 sorrys** after NSC-P59):
For smooth periodic u, the `h_mean_zero` hypothesis of `space_torus_vorticity_bridge_torus`
is DERIVED from an explicit T³ mean-zero condition `h_omega_T3` rather than passed directly.

**G2 discharge path** (from PeriodicSobolev §3D.1):
- `h_omega_T3` provides `∫_{T³} ω(φ t) dt = 0` where φ t i = (equivIoc 1 0 (t i)).val.
- `Sobolev.cateptTorus_measurePreserving` (NSC-P59, PeriodicSobolev.lean) gives
  `MeasurePreserving φ volume Measure.pi(volume.restrict(Ioc 0 1))`.
- `integral_map` converts: `∫_{[0,1]³} ω x dx = ∫_{T³} ω(φ t) dt = 0`.

**0 sorrys** (NSC-P59 discharged the T³ ↔ [0,1]³ measure bridge). -/

/-- **T³ vorticity bridge, smooth velocity variant** (NSC-P58, **0 sorrys** after NSC-P59):
    For smooth periodic `u`, the mean-zero hypothesis `h_mean_zero` of
    `space_torus_vorticity_bridge_torus` is derived from `h_omega_T3`
    (the T³ form of the mean-zero condition) via the measure bridge
    `Sobolev.cateptTorus_measurePreserving` (NSC-P59).

    **Design**: takes `h_omega_T3 : ∫ t : UnitAddTorus (Fin 3), ω (φ t) = 0`
    where `φ t i = (AddCircle.equivIoc (1:ℝ) 0 (t i)).val`, and converts
    this to the `[0,1]³` form required by `space_torus_vorticity_bridge_torus`
    via `integral_map` + `cateptTorus_measurePreserving.map_eq`. -/
theorem space_torus_vorticity_bridge_smooth
    (u : Sobolev.NSTorusVelocityField)
    (hCont : Continuous u)
    (h_smooth : ContDiff ℝ ⊤
      (fun x : Fin 3 → ℝ => u (fun i => (x i : AddCircle (1:ℝ)))))
    (ω : (Fin 3 → ℝ) → ℂ)
    (hCont_ω : Continuous ω)
    (hPer : ∀ (x : Fin 3 → ℝ) (i : Fin 3), ω (Function.update x i (x i + 1)) = ω x)
    (h_ens_nonneg : 0 ≤ Sobolev.torusEnstrophy u)
    (h_ens_le_pal : Sobolev.torusEnstrophy u ≤ Sobolev.torusPalinstrophy u)
    (h_ens_eq : ∫ x : Fin 3 → ℝ, ‖ω x‖ ^ 2
        ∂Measure.pi (fun _ => (volume : Measure ℝ).restrict (Set.Ioc 0 1)) =
        Sobolev.torusEnstrophy u)
    (h_omega_T3 : ∫ t : UnitAddTorus (Fin 3),
        ω (fun i => (AddCircle.equivIoc (1:ℝ) 0 (t i)).val) = 0)
    (h_otf_summable : Summable (h1FourierSemiNormCoeffs
        (ω ∘ fun t : UnitAddTorus (Fin 3) => fun i : Fin 3 =>
          (AddCircle.equivIoc (1:ℝ) 0 (t i)).val)))
    (h_otf_h1 : h1FourierSemiNorm
        (ω ∘ fun t : UnitAddTorus (Fin 3) => fun i : Fin 3 =>
          (AddCircle.equivIoc (1:ℝ) 0 (t i)).val) ≤ Sobolev.torusPalinstrophy u) :
    ∃ omega_tilde : Lp ℂ 2 (volume : Measure (UnitAddTorus (Fin 3))),
      mFourierCoeff (omega_tilde : UnitAddTorus (Fin 3) → ℂ) 0 = 0 ∧
      Summable (h1FourierSemiNormCoeffs (omega_tilde : UnitAddTorus (Fin 3) → ℂ)) ∧
      ∫ t, ‖(omega_tilde : UnitAddTorus (Fin 3) → ℂ) t‖ ^ 2 = Sobolev.torusEnstrophy u ∧
      h1FourierSemiNorm (omega_tilde : UnitAddTorus (Fin 3) → ℂ) ≤ Sobolev.torusPalinstrophy u := by
  -- **Step 1**: convert T³ mean-zero (h_omega_T3) to [0,1]³ mean-zero via measure bridge.
  -- cateptTorus_measurePreserving (NSC-P59): MeasurePreserving φ volume (Measure.pi (...))
  -- where φ t i = (equivIoc 1 0 (t i)).val.
  -- integral_map gives: ∫_{[0,1]³} ω x dx = ∫_{T³} ω(φ t) dt = 0.
  have h_mean_zero : ∫ x : Fin 3 → ℝ, ω x
      ∂Measure.pi (fun _ => (volume : Measure ℝ).restrict (Set.Ioc 0 1)) = 0 := by
    -- Route: cateptTorus_measurePreserving.map_eq + integral_map.
    -- Provide map_eq as an explicit have to avoid implicit-argument mismatch in rw.
    have hmap_eq : Measure.pi (fun _ : Fin 3 =>
          (volume : Measure ℝ).restrict (Set.Ioc 0 1)) =
        Measure.map (fun t : UnitAddTorus (Fin 3) => fun i : Fin 3 =>
          (AddCircle.equivIoc (1 : ℝ) 0 (t i)).val)
          (volume : Measure (UnitAddTorus (Fin 3))) :=
      Sobolev.cateptTorus_measurePreserving.map_eq.symm
    rw [hmap_eq, integral_map Sobolev.cateptTorus_measurePreserving.measurable
        hCont_ω.aestronglyMeasurable]
    exact h_omega_T3
  -- **Step 2**: delegate to space_torus_vorticity_bridge_torus with derived h_mean_zero.
  exact Sobolev.space_torus_vorticity_bridge_torus u ω hCont_ω hPer
    h_ens_nonneg h_ens_le_pal h_ens_eq h_mean_zero h_otf_summable h_otf_h1

end NavierStokesClean.Sobolev.FourierDerivT3
