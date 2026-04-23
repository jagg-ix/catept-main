import NavierStokes.Core.NSFieldGalerkin

/-!
# Stage 162 — NSFieldFourierComplex: Complex Coefficients and Wavevectors

Enriches the Galerkin field model with:
* `CRat = Rat × Rat`            — complex rationals (all arithmetic stays in ℚ)
* `WaveVec = Int × Int × Int`   — full 3D integer wavevector k ∈ ℤ³
* `NSFieldGalerkinK`            — Galerkin field with complex coefficients and wavevectors
* `enstrophyK`, `palinstrophyK` — observables via `normSqC`
* `palinstrophyK_le_galerkinN2_enstrophyK` — 0-axiom bound from `freq_le`

## Motivation

`NSFieldGalerkin` (Stage 161A) uses real amplitudes `amp : Fin N → Rat` and
wavenumber magnitudes `freq : Fin N → Nat`.  These suffice for the ObsLand
Galerkin certificate but block the triadic energy cancellation identity:

  Re⟨B(u,u), u⟩_{L²} = 0    (Temam 1984, incompressibility antisymmetry)

This identity needs:
  (a) Complex coefficients û_k ∈ ℂ  — to track phases in the triadic sum
  (b) Full wavevectors k ∈ ℤ³       — for the resonance condition k + l + m = 0

Stage 162 supplies (a) and (b).
Stage 163 will define B and state `B_energy_cancel`.
Stage 164 will derive `energy_dissipation` as a theorem from `B_energy_cancel`.

## Net counts

  - New axioms:   0
  - New theorems: 8
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinComplexModel

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge  -- galerkinN, kmax, kmax_pos
open NavierStokes.GalerkinModel          -- NSFieldGalerkin
open NavierStokes.FourierModel           -- NSFieldFourier

/-! ## Complex rationals -/

/-- Complex rational: a pair `(re, im)` representing `re + im·i` with `re, im ∈ ℚ`.

    Using a transparent `abbrev` so that `(a, b) : CRat` unfolds definitionally. -/
abbrev CRat : Type := Rat × Rat

/-- Real part. -/
def CRat.re (z : CRat) : Rat := z.1

/-- Imaginary part. -/
def CRat.im (z : CRat) : Rat := z.2

/-- Complex conjugate: `conj(a + bi) = a - bi`. -/
def CRat.conj (z : CRat) : CRat := (z.re, -z.im)

/-- Norm squared: `|z|² = re² + im²`.  Stays in ℚ; always ≥ 0. -/
def normSqC (z : CRat) : Rat := z.re ^ 2 + z.im ^ 2

/-- Real part of the Hermitian inner product:
    `Re(z̄·w) = re(z)·re(w) + im(z)·im(w)`.

    This is the quantity that appears in the energy identity
    `d/dt ½ ‖u‖² = Re⟨∂_t u, u⟩`. -/
def realInnerC (z w : CRat) : Rat := z.re * w.re + z.im * w.im

/-- A family of complex Fourier coefficients indexed by mode index `Fin N`. -/
abbrev CoeffC (N : Nat) : Type := Fin N → CRat

/-! ## Algebraic identities for CRat -/

/-- Scalar multiplication `r • z = (r·re, r·im)` for `r : Rat`, `z : CRat`. -/
def CRat.smul (r : Rat) (z : CRat) : CRat := (r * z.re, r * z.im)

theorem CRat.smul_re (r : Rat) (z : CRat) : (CRat.smul r z).re = r * z.re := rfl
theorem CRat.smul_im (r : Rat) (z : CRat) : (CRat.smul r z).im = r * z.im := rfl

/-- Norm squared is nonnegative. -/
theorem normSqC_nonneg (z : CRat) : 0 ≤ normSqC z :=
  add_nonneg (sq_nonneg _) (sq_nonneg _)

/-- `normSqC z = realInnerC z z` (self-inner-product). -/
theorem normSqC_eq_inner_self (z : CRat) : normSqC z = realInnerC z z := by
  unfold normSqC realInnerC CRat.re CRat.im; ring

/-- Real inner product is symmetric. -/
theorem realInnerC_comm (z w : CRat) : realInnerC z w = realInnerC w z := by
  unfold realInnerC CRat.re CRat.im; ring

/-! ## 3D wavevectors -/

/-- Three-dimensional integer wavevector `k = (k₁, k₂, k₃) ∈ ℤ³`. -/
abbrev WaveVec : Type := Int × Int × Int

/-- `|k|² = k₁² + k₂² + k₃²` as a rational.

    Note: `Int` coerces to `Rat` cleanly; no `Real` needed. -/
def waveVecMag2 (k : WaveVec) : Rat :=
  (k.1 : Rat) ^ 2 + (k.2.1 : Rat) ^ 2 + (k.2.2 : Rat) ^ 2

/-- `|k|² ≥ 0`. -/
theorem waveVecMag2_nonneg (k : WaveVec) : 0 ≤ waveVecMag2 k :=
  add_nonneg (add_nonneg (sq_nonneg _) (sq_nonneg _)) (sq_nonneg _)

/-! ## The complex Galerkin field -/

/-- A Galerkin velocity field with full complex Fourier coefficients.

    Unlike `NSFieldGalerkin` (Stage 161A, real amplitudes + magnitude-only wavenumbers),
    this type tracks:
    * `wvec  : Fin N → WaveVec`  — full wavevector `k_i ∈ ℤ³` for each mode
    * `coeff : Fin N → CRat`     — complex coefficient `û_{k_i} = re_i + im_i·i`
    * `freq_le`                  — Galerkin cutoff: `|k_i|² ≤ galerkinN²`

    The cutoff bound `freq_le` uses `|k|²` (not `|k|` itself) because `waveVecMag2`
    is rational-valued and avoids square roots.  `galerkinN² = kmax = 1024²`.

    This is the minimal type needed to state `B_energy_cancel` in Stage 163. -/
structure NSFieldGalerkinK where
  N       : Nat
  wvec    : Fin N → WaveVec
  coeff   : Fin N → CRat
  freq_le : ∀ i : Fin N, waveVecMag2 (wvec i) ≤ (galerkinN : Rat) ^ 2

/-! ## Observables -/

/-- Kinetic energy: `∑_i |û_{k_i}|²`  (Parseval, factor ½ absorbed). -/
noncomputable def kineticEnergyK (v : NSFieldGalerkinK) : Rat :=
  ∑ i : Fin v.N, normSqC (v.coeff i)

/-- Enstrophy: `∑_i |k_i|² · |û_{k_i}|² = ‖ω‖²_{L²}` in Fourier. -/
noncomputable def enstrophyK (v : NSFieldGalerkinK) : Rat :=
  ∑ i : Fin v.N, waveVecMag2 (v.wvec i) * normSqC (v.coeff i)

/-- Palinstrophy: `∑_i |k_i|⁴ · |û_{k_i}|² = ‖∇ω‖²_{L²}` in Fourier. -/
noncomputable def palinstrophyK (v : NSFieldGalerkinK) : Rat :=
  ∑ i : Fin v.N, waveVecMag2 (v.wvec i) ^ 2 * normSqC (v.coeff i)

/-! ## Nonnegativity -/

theorem kineticEnergyK_nonneg (v : NSFieldGalerkinK) : 0 ≤ kineticEnergyK v :=
  Finset.sum_nonneg (fun _ _ => normSqC_nonneg _)

theorem enstrophyK_nonneg (v : NSFieldGalerkinK) : 0 ≤ enstrophyK v :=
  Finset.sum_nonneg (fun _ _ => mul_nonneg (waveVecMag2_nonneg _) (normSqC_nonneg _))

theorem palinstrophyK_nonneg (v : NSFieldGalerkinK) : 0 ≤ palinstrophyK v :=
  Finset.sum_nonneg (fun _ _ => mul_nonneg (sq_nonneg _) (normSqC_nonneg _))

/-! ## Palinstrophy bound from freq_le (0 axioms) -/

/-- `palinstrophyK(v) ≤ galerkinN² · enstrophyK(v)` for any complex Galerkin field.

    Proof: mode-by-mode.  For each mode `i`, `freq_le i : |k_i|² ≤ galerkinN²`,
    so `|k_i|⁴ = |k_i|² · |k_i|² ≤ galerkinN² · |k_i|²`, giving the pointwise bound.
    Sum over all modes.

    Parallel to `palinstrophyF_le_kmax_enstrophyF_galerkin` (Stage 161A), but for
    complex observables (`normSqC` instead of `amp i ^ 2`) and `waveVecMag2` instead
    of `(freq i : Rat) ^ 2`. -/
theorem palinstrophyK_le_galerkinN2_enstrophyK (v : NSFieldGalerkinK) :
    palinstrophyK v ≤ (galerkinN : Rat) ^ 2 * enstrophyK v := by
  unfold palinstrophyK enstrophyK
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  have hle : waveVecMag2 (v.wvec i) ≤ (galerkinN : Rat) ^ 2 := v.freq_le i
  have hnn : 0 ≤ normSqC (v.coeff i) := normSqC_nonneg _
  calc waveVecMag2 (v.wvec i) ^ 2 * normSqC (v.coeff i)
      = waveVecMag2 (v.wvec i) * (waveVecMag2 (v.wvec i) * normSqC (v.coeff i)) := by ring
    _ ≤ (galerkinN : Rat) ^ 2 * (waveVecMag2 (v.wvec i) * normSqC (v.coeff i)) :=
        mul_le_mul_of_nonneg_right hle (mul_nonneg (waveVecMag2_nonneg _) hnn)

def stage162Summary : String :=
  "Stage 162: NSFieldFourierComplex — CRat=Rat×Rat, normSqC, realInnerC, CoeffC, " ++
  "WaveVec=Int×Int×Int, waveVecMag2. NSFieldGalerkinK: complex Galerkin field with " ++
  "full wavevectors and freq_le cutoff. Observables: kineticEnergyK, enstrophyK, " ++
  "palinstrophyK (all nonneg, all 0-axiom). " ++
  "palinstrophyK_le_galerkinN2_enstrophyK: 0-axiom palinstrophy bound. " ++
  "+0 axioms, +8 theorems, 0 sorry."

end NavierStokes.GalerkinComplexModel
