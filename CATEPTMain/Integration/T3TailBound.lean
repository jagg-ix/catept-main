import CATEPTMain.Integration.RealSpectralEntropicModel
import CATEPTMain.Integration.T3SpectralPartition

/-!
# T³ Tail Bound (T-FF Phase 22)

Provides an **explicit multiplicative-constant exponential
tail bound** for the 3-D Stokes-spectral cube cutoff
`Z_N^{T³}` of P21:

  `|Z_∞^{T³} − Z_N^{T³}| ≤ 3 · Z_∞^{T³} · exp(-N)`.

This is the "Poisson-style" geometric tail bound for the T³
positive cone, derived elementary-style from the P19/P20
1-D bound and the algebraic factorization
`a³ - b³ = (a - b)(a² + a·b + b²)`.

## Mathematical content

Starting from the P20 1-D bound
`|Z_N − Z_∞| ≤ exp(-N) · Z_∞` and the P21 cube factorization
`Z_N^{T³} = Z_N^3`, `Z_∞^{T³} = Z_∞^3`:

1. `Z_∞³ − Z_N³ = (Z_∞ − Z_N) · (Z_N² + Z_N · Z_∞ + Z_∞²)`.
2. `0 ≤ Z_N ≤ Z_∞` ⇒
   `Z_N² + Z_N · Z_∞ + Z_∞² ≤ 3 · Z_∞²`.
3. `0 ≤ Z_∞ − Z_N ≤ exp(-N) · Z_∞` (from P20).
4. Combining: `Z_∞³ − Z_N³ ≤ 3 · Z_∞³ · exp(-N)`.

The bound therefore takes the **multiplicative form**
`M · exp(-C·N)` with `M = 3 · Z_∞^{T³}` and `C = 1`. Note
that this does **not** literally fit the abstract record
`PhysicalEntropicModel`, which demands the constant-free
shape `exp(-C·N)` (already a tight constraint at `N = 0`,
where the residual equals `Z_∞^{T³} > 1`). Lifting to a
proper instantiation requires extending the abstract record
with an explicit multiplicative tail constant `M`; that
structural extension is out of scope here.

## Honest scope

* This is the **elementary product-form geometric tail
  bound**, not the Fourier-analytic Poisson-summation
  identity
  `∑_{k ∈ ℤ³} e^{-|k|² t} = (π/t)^{3/2} ∑_{n ∈ ℤ³} e^{-π²|n|²/t}`.
  The latter would yield asymptotically sharper bounds at
  small `t`, but its proof requires Schwartz-class Fourier
  analysis on `ℝ³` which is not derived here.
* The bound is over the **positive cone** `ℕ³`; an analogous
  bound over the bilateral lattice `ℤ³` would multiply `M`
  by the eight-octant constant `8`.
* `PhysicalEntropicModel` instantiation is deferred (see the
  structural remark above).

## Output

* `cube_residual_factorization` — the algebraic identity
  `a³ - b³ = (a - b) · (a² + a·b + b² )`.
* `Z_inf_pow_three_sub_Z_N_pow_three_le` — the elementary
  3-D tail bound.
* `T3MultiplicativeTail` — record packaging the
  `(M, C)` pair and the bound.
* `t3_multiplicative_tail` — the constructed instance with
  `M = 3 · Z_∞^{T³}` and `C = 1`.
* Six kernel-only audit theorems exposing the bound's
  structural data.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.T3TailBound

open CATEPTMain.Integration.SpectralSumPartition
open CATEPTMain.Integration.RealSpectralEntropicModel
open CATEPTMain.Integration.T3SpectralPartition
open Filter Topology Real

noncomputable section

/-! ## Auxiliary algebraic identities and bounds. -/

/-- Classical factorization `a³ - b³ = (a - b) · (a² + a·b + b²)`. -/
lemma cube_residual_factorization (a b : ℝ) :
    a^3 - b^3 = (a - b) * (a^2 + a * b + b^2) := by ring

/-- For `0 ≤ b ≤ a`, `b² + b·a + a² ≤ 3 · a²`. -/
lemma cofactor_le_three_sq {a b : ℝ} (hb : 0 ≤ b) (hba : b ≤ a) :
    b^2 + b * a + a^2 ≤ 3 * a^2 := by
  have ha : 0 ≤ a := le_trans hb hba
  have hb_sq : b^2 ≤ a^2 := by nlinarith
  have hba_le : b * a ≤ a * a := by nlinarith
  have ha_sq : a * a = a^2 := by ring
  nlinarith [hb_sq, hba_le, ha_sq]

/-! ## The explicit 3-D tail bound. -/

/-- **Elementary 3-D tail bound** (positive form):
`Z_∞³ − Z_N³ ≤ 3 · Z_∞³ · exp(-N)`. -/
theorem Z_inf_pow_three_sub_Z_N_pow_three_le (N : ℕ) :
    Z_inf^3 - (Z_N N)^3
      ≤ 3 * Z_inf^3 * Real.exp (-(N : ℝ)) := by
  have hZ_N_le : Z_N N ≤ Z_inf := Z_N_le_Z_inf N
  have hZ_N_nonneg : 0 ≤ Z_N N := by
    unfold Z_N
    exact Finset.sum_nonneg (fun k _ => spectralTerm_nonneg k)
  have hZ_inf_pos : 0 < Z_inf := Z_inf_pos
  have hfact : Z_inf^3 - (Z_N N)^3
      = (Z_inf - Z_N N) * ((Z_N N)^2 + (Z_N N) * Z_inf + Z_inf^2) := by ring
  -- (a) Bound the first factor: Z_inf - Z_N ≤ exp(-N) · Z_inf
  have hres_le : Z_inf - Z_N N ≤ Real.exp (-(N : ℝ)) * Z_inf := by
    have h := abs_Z_N_sub_Z_inf_le N
    have hpos : 0 ≤ Z_inf - Z_N N := by linarith
    have habs : |Z_N N - Z_inf| = Z_inf - Z_N N := by
      rw [abs_sub_comm]; exact abs_of_nonneg hpos
    linarith [h, habs.symm ▸ h]
  have hres_nonneg : 0 ≤ Z_inf - Z_N N := by linarith
  -- (b) Bound the cofactor: (Z_N)² + Z_N·Z_inf + Z_inf² ≤ 3 Z_inf²
  have hcof_le : (Z_N N)^2 + Z_N N * Z_inf + Z_inf^2
      ≤ 3 * Z_inf^2 :=
    cofactor_le_three_sq hZ_N_nonneg hZ_N_le
  have hcof_nonneg : 0 ≤ (Z_N N)^2 + Z_N N * Z_inf + Z_inf^2 := by
    have h1 : 0 ≤ (Z_N N)^2 := sq_nonneg _
    have h2 : 0 ≤ Z_N N * Z_inf := mul_nonneg hZ_N_nonneg hZ_inf_pos.le
    have h3 : 0 ≤ Z_inf^2 := sq_nonneg _
    linarith
  -- (c) Multiply.
  have hZ_inf_sq_nonneg : 0 ≤ Z_inf^2 := sq_nonneg _
  have hexp_pos : 0 < Real.exp (-(N : ℝ)) := Real.exp_pos _
  have hexp_Z_inf_nonneg : 0 ≤ Real.exp (-(N : ℝ)) * Z_inf :=
    mul_nonneg hexp_pos.le hZ_inf_pos.le
  calc Z_inf^3 - (Z_N N)^3
      = (Z_inf - Z_N N) * ((Z_N N)^2 + (Z_N N) * Z_inf + Z_inf^2) := hfact
    _ ≤ (Real.exp (-(N : ℝ)) * Z_inf) * ((Z_N N)^2 + (Z_N N) * Z_inf + Z_inf^2) :=
          mul_le_mul_of_nonneg_right hres_le hcof_nonneg
    _ ≤ (Real.exp (-(N : ℝ)) * Z_inf) * (3 * Z_inf^2) :=
          mul_le_mul_of_nonneg_left hcof_le hexp_Z_inf_nonneg
    _ = 3 * Z_inf^3 * Real.exp (-(N : ℝ)) := by ring

/-- **Absolute 3-D tail bound**:
`|Z_∞^{T³} - Z_N^{T³}| ≤ 3 · Z_∞^{T³} · exp(-N)`. -/
theorem abs_Z_N_3D_sub_Z_inf_3D_le (N : ℕ) :
    |Z_N_3D N - Z_inf_3D|
      ≤ 3 * Z_inf_3D * Real.exp (-(N : ℝ)) := by
  rw [Z_N_3D_eq_Z_N_pow N, Z_inf_3D_eq_Z_inf_pow]
  have hZ_N_le : Z_N N ≤ Z_inf := Z_N_le_Z_inf N
  have hZ_N_nonneg : 0 ≤ Z_N N := by
    unfold Z_N
    exact Finset.sum_nonneg (fun k _ => spectralTerm_nonneg k)
  have hpow : (Z_N N)^3 ≤ Z_inf^3 :=
    pow_le_pow_left₀ hZ_N_nonneg hZ_N_le 3
  have habs : |(Z_N N)^3 - Z_inf^3| = Z_inf^3 - (Z_N N)^3 := by
    rw [abs_sub_comm]; exact abs_of_nonneg (by linarith)
  rw [habs]
  exact Z_inf_pow_three_sub_Z_N_pow_three_le N

/-! ## Multiplicative-form tail bound record. -/

/-- A bundled exponential tail bound of the form
`|Z_N - Z_∞| ≤ M · exp(-C · N)` with positive constants. -/
structure MultiplicativeUVTail where
  Z_N : ℕ → ℝ
  Z_inf : ℝ
  M : ℝ
  C : ℝ
  M_pos : 0 < M
  C_pos : 0 < C
  bound : ∀ N, |Z_N N - Z_inf| ≤ M * Real.exp (-(C * (N : ℝ)))
  tendsToContinuum : Tendsto Z_N atTop (𝓝 Z_inf)

/-- The 3-D Stokes-spectral cube cutoff packaged as a
multiplicative-form exponential tail bound, with
`M = 3 · Z_∞^{T³}` and `C = 1`. -/
def t3_multiplicative_tail : MultiplicativeUVTail where
  Z_N := Z_N_3D
  Z_inf := Z_inf_3D
  M := 3 * Z_inf_3D
  C := 1
  M_pos := by
    have : 0 < Z_inf_3D := Z_inf_3D_pos
    positivity
  C_pos := one_pos
  bound := by
    intro N
    have h := abs_Z_N_3D_sub_Z_inf_3D_le N
    have hsimp : (1 : ℝ) * (N : ℝ) = (N : ℝ) := one_mul _
    rw [hsimp]
    exact h
  tendsToContinuum := tendsto_Z_N_3D_atTop_Z_inf_3D

/-! ## Audit theorems. -/

/-- The 3-D tail's exponential decay constant is `1`. -/
theorem t3_tail_C_eq_one : t3_multiplicative_tail.C = 1 := rfl

/-- The 3-D tail's multiplicative magnitude is `3 · Z_∞^{T³}`. -/
theorem t3_tail_M_eq : t3_multiplicative_tail.M = 3 * Z_inf_3D := rfl

/-- The 3-D tail's cutoff partition is the cube of the 1-D
cutoff (via `Z_N_3D_eq_Z_N_pow`). -/
theorem t3_tail_Z_N_eq_pow (N : ℕ) :
    t3_multiplicative_tail.Z_N N = (Z_N N)^3 :=
  Z_N_3D_eq_Z_N_pow N

/-- The 3-D tail's continuum value is the cube of the 1-D
continuum value (via `Z_inf_3D_eq_Z_inf_pow`). -/
theorem t3_tail_Z_inf_eq_pow :
    t3_multiplicative_tail.Z_inf = Z_inf^3 :=
  Z_inf_3D_eq_Z_inf_pow

/-- The 3-D tail bound, restated through the bundled record. -/
theorem t3_tail_bound_holds (N : ℕ) :
    |t3_multiplicative_tail.Z_N N - t3_multiplicative_tail.Z_inf|
      ≤ t3_multiplicative_tail.M
          * Real.exp (-(t3_multiplicative_tail.C * (N : ℝ))) :=
  t3_multiplicative_tail.bound N

/-- The 3-D tail's continuum convergence, restated. -/
theorem t3_tail_tendsto :
    Tendsto t3_multiplicative_tail.Z_N atTop
      (𝓝 t3_multiplicative_tail.Z_inf) :=
  t3_multiplicative_tail.tendsToContinuum

end

end CATEPTMain.Integration.T3TailBound
