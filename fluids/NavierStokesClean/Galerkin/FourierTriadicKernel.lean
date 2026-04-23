import NavierStokesClean.Core.Types

/-!
# Fourier Triadic Kernel for Galerkin NS on T³

## Overview

This file defines the **Leray-projected triadic kernel coefficient** `triadicKCoeff` for the
Galerkin Navier-Stokes system on T³, as a concrete `noncomputable def` (not an axiom).

This is the port of Stage 294 from the old `NavierStokes/NSGalerkinPhysicalTriadKernel.lean`
into the clean repo. The key discharge: `triadicKCoeff` is **no longer an axiom** but a
concrete formula.

## Mathematical content

For the Galerkin NS on T³, the nonlinear term decomposes into triadic interactions among
Fourier modes. In the Leray-projected system, the coefficient of the (k,j,l) triad is:

  `Bₖⱼₗ = (k · j) / |k|²` if `k = j + l` (resonant triad)
  `Bₖⱼₗ = 0`               otherwise (off-resonant)

where `k · j = Σᵢ kᵢ jᵢ` is the integer dot product and `|k|² = Σᵢ kᵢ²` is the
squared magnitude (rational-valued to avoid zero-division issues in Lean).

## Wave vector type

`WaveVec3 := Fin 3 → ℤ` — a Fourier wave vector on T³ = (ℝ/ℤ)³.
This is the clean-repo equivalent of `WaveVec = Int × Int × Int` from the old tree.

## SA-VS1: Off-resonance vanishing

`triadicKCoeff_off_resonance`: if `wvec k ≠ wvec j + wvec l`, then `triadicKCoeff = 0`.
This follows immediately from the `if_neg` branch of the definition.

## Zero sorry, zero axioms.
-/

set_option autoImplicit false

namespace NavierStokesClean.Galerkin

/-! ## §1. Wave vector arithmetic on T³ -/

/-- **Wave vector on T³** = a triple of integers `(k₀, k₁, k₂) : Fin 3 → ℤ`.
    T³ = (ℝ/ℤ)³ has Fourier basis indexed by `Fin 3 → ℤ`. -/
abbrev WaveVec3 : Type := Fin 3 → ℤ

/-- **Integer dot product** of two wave vectors `k · j = Σᵢ kᵢ · jᵢ`. -/
def waveVecDot3 (k j : WaveVec3) : ℤ :=
  Finset.univ.sum (fun i : Fin 3 => k i * j i)

/-- **Squared magnitude** `|k|² = Σᵢ kᵢ²` as a rational number.
    Using ℚ avoids division issues when |k|² = 0 (the zero mode). -/
noncomputable def waveVecMag2_3 (k : WaveVec3) : ℚ :=
  Finset.univ.sum (fun i : Fin 3 => (k i : ℚ) ^ 2)

/-- The squared magnitude is nonneg. -/
lemma waveVecMag2_3_nonneg (k : WaveVec3) : 0 ≤ waveVecMag2_3 k := by
  apply Finset.sum_nonneg
  intro i _
  positivity

/-- The zero wave vector has squared magnitude 0. -/
@[simp]
lemma waveVecMag2_3_zero : waveVecMag2_3 (fun _ => 0) = 0 := by
  simp [waveVecMag2_3]

/-- Wave vector addition is componentwise. -/
@[simp]
lemma waveVec3_add (k j : WaveVec3) (i : Fin 3) : (k + j) i = k i + j i := rfl

/-! ## §2. Triadic kernel coefficient (concrete def, not axiom) -/

/-- **Leray-projected triadic kernel coefficient** for Galerkin NS on T³.

    For an N-mode Galerkin system with wave vectors `wvec : Fin N → WaveVec3`, the
    coefficient of the (k,j,l) triadic interaction in the Leray-projected NS equation is:

      `triadicKCoeff wvec k j l =`
        `(k · j : ℚ) / |k|²`   if `wvec k = wvec j + wvec l` (resonant triad)
        `0`                     otherwise

    This is the **Fourier space form of the Leray projector** applied to the convective
    nonlinearity `u·∇u`. The resonance condition `k = j + l` is the triad selection rule
    from the convolution theorem on T³.

    **Stage 294 port**: this converts what was an axiom in the old tree into a concrete
    computable formula. No sorry, no axiom.

    **Reference**: Temam (1984) Navier-Stokes Equations, Ch. III §2; Constantin-Foias (1988)
    Navier-Stokes Equations, §3.2. -/
noncomputable def triadicKCoeff {N : ℕ} (wvec : Fin N → WaveVec3) :
    Fin N → Fin N → Fin N → ℚ :=
  fun k j l =>
    if wvec k = wvec j + wvec l then
      (waveVecDot3 (wvec k) (wvec j) : ℚ) / waveVecMag2_3 (wvec k)
    else 0

/-! ## §3. SA-VS1: Off-resonance vanishing (theorem, not axiom) -/

/-- **SA-VS1: Off-resonance vanishing.**

    If `wvec k ≠ wvec j + wvec l` (no triad resonance), then the triadic kernel
    coefficient is zero. This is immediate from the `else` branch of the definition.

    **Physical content**: the Leray projector couples only triads satisfying the
    wavenumber resonance condition `k = j + l`. Non-resonant triads contribute nothing. -/
theorem triadicKCoeff_off_resonance {N : ℕ} (wvec : Fin N → WaveVec3)
    (k j l : Fin N) (h : wvec k ≠ wvec j + wvec l) :
    triadicKCoeff wvec k j l = 0 := by
  unfold triadicKCoeff
  exact if_neg h

/-- **Resonant triad formula.**

    If `wvec k = wvec j + wvec l` (triad resonance), then the triadic kernel coefficient
    equals `(k · j) / |k|²`. This is immediate from the `then` branch of the definition. -/
theorem triadicKCoeff_resonant {N : ℕ} (wvec : Fin N → WaveVec3)
    (k j l : Fin N) (h : wvec k = wvec j + wvec l) :
    triadicKCoeff wvec k j l =
      (waveVecDot3 (wvec k) (wvec j) : ℚ) / waveVecMag2_3 (wvec k) := by
  unfold triadicKCoeff
  exact if_pos h

/-- **SA-VS1 (universal form)**: for every triad, the coefficient is either the
    resonant formula or zero. This is a simple `by_cases` from the definition. -/
theorem triadicKCoeff_cases {N : ℕ} (wvec : Fin N → WaveVec3) (k j l : Fin N) :
    triadicKCoeff wvec k j l = 0 ∨
    triadicKCoeff wvec k j l = (waveVecDot3 (wvec k) (wvec j) : ℚ) / waveVecMag2_3 (wvec k) := by
  by_cases h : wvec k = wvec j + wvec l
  · right; exact triadicKCoeff_resonant wvec k j l h
  · left; exact triadicKCoeff_off_resonance wvec k j l h

end NavierStokesClean.Galerkin
