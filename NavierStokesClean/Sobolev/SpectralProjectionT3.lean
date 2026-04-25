import Mathlib.Analysis.Fourier.AddCircleMulti
import Mathlib.Analysis.InnerProductSpace.l2Space

/-!
# Phase 5D: Galerkin Spectral Projection on T^3

This file introduces the Fourier mode truncation set and the L^2 Galerkin
projection operator used in the Phase 5D Navier-Stokes development.

The contraction and coefficient-selection lemmas are intentionally left for a
follow-up patch after measure-instance alignment and projection API stabilization.
-/

set_option autoImplicit false

private noncomputable instance factPeriodOneSP : Fact (0 < (1 : ℝ)) := ⟨one_pos⟩

-- Match the measure normalization used by AddCircleMulti.
noncomputable local instance : MeasureTheory.MeasureSpace UnitAddCircle :=
  ⟨AddCircle.haarAddCircle⟩

namespace NavierStokesClean.Sobolev.SpectralProjectionT3

open MeasureTheory
open UnitAddTorus
open scoped BigOperators ENNReal NNReal

local notation "L²(" α ")" => Lp ℂ 2 (volume : Measure α)

/-- Galerkin mode finset at level `N`: all `k : Fin 3 → ℤ` with `|k i| ≤ N` for each coordinate. -/
noncomputable def galerkinModeFinset (N : ℕ) : Finset (Fin 3 → ℤ) :=
  Fintype.piFinset (fun _ => Finset.Icc (-(N : ℤ)) N)

theorem mem_galerkinModeFinset (N : ℕ) (k : Fin 3 → ℤ) :
    k ∈ galerkinModeFinset N ↔ ∀ i : Fin 3, -(N : ℤ) ≤ k i ∧ k i ≤ N := by
  simp [galerkinModeFinset, Fintype.mem_piFinset, Finset.mem_Icc]

theorem galerkinModeFinset_mono {N M : ℕ} (hNM : N ≤ M) :
    galerkinModeFinset N ⊆ galerkinModeFinset M := by
  intro k hk
  rw [mem_galerkinModeFinset] at hk ⊢
  intro i
  have h := hk i
  exact ⟨Int.neg_le_neg (Int.ofNat_le.mpr hNM) |>.trans h.1,
         h.2.trans (Int.ofNat_le.mpr hNM)⟩

/-- L^2 Galerkin spectral projection at level `N` (Fourier truncation to `galerkinModeFinset N`). -/
noncomputable def spectralProjL2 (N : ℕ) (f : L²(UnitAddTorus (Fin 3))) :
    L²(UnitAddTorus (Fin 3)) :=
  ∑ k ∈ galerkinModeFinset N, (mFourierCoeff f k : ℂ) • mFourierLp (d := Fin 3) 2 k

@[simp] theorem spectralProjL2_def (N : ℕ) (f : L²(UnitAddTorus (Fin 3))) :
    spectralProjL2 N f =
      ∑ k ∈ galerkinModeFinset N, (mFourierCoeff f k : ℂ) • mFourierLp (d := Fin 3) 2 k := rfl

/-! ## Continuous-linear-map packaging of the Galerkin projection

`spectralProjL2CLM N` is `spectralProjL2 N` packaged as a `ContinuousLinearMap`
over `ℂ`.  It is built as a finite sum of rank-one Riesz projections
`f ↦ ⟪mFourierLp 2 k, f⟫_ℂ • mFourierLp 2 k`, which equals
`mFourierCoeff f k • mFourierLp 2 k` by the orthonormality of the Fourier basis. -/

/-- Rank-one Riesz projection onto the `k`-th Fourier mode. -/
noncomputable def fourierModeProjCLM (k : Fin 3 → ℤ) :
    L²(UnitAddTorus (Fin 3)) →L[ℂ] L²(UnitAddTorus (Fin 3)) :=
  (innerSL ℂ (mFourierLp (d := Fin 3) 2 k)).smulRight
    (mFourierLp (d := Fin 3) 2 k)

theorem fourierModeProjCLM_apply (k : Fin 3 → ℤ) (f : L²(UnitAddTorus (Fin 3))) :
    fourierModeProjCLM k f =
      (mFourierCoeff f k : ℂ) • mFourierLp (d := Fin 3) 2 k := by
  -- ⟪mFourierLp 2 k, f⟫_ℂ = mFourierBasis.repr f k = mFourierCoeff f k
  unfold fourierModeProjCLM
  simp only [ContinuousLinearMap.smulRight_apply, innerSL_apply_apply]
  congr 1
  -- Goal: ⟪mFourierLp 2 k, f⟫_ℂ = mFourierCoeff f k
  have h1 : mFourierBasis.repr f k = mFourierCoeff f k := mFourierBasis_repr f k
  have h2 : mFourierBasis.repr f k =
      inner (𝕜 := ℂ) (mFourierBasis (d := Fin 3) k) f :=
    HilbertBasis.repr_apply_apply (b := mFourierBasis) f k
  have h3 : (mFourierBasis (d := Fin 3) k : L²(UnitAddTorus (Fin 3))) =
      mFourierLp (d := Fin 3) 2 k := by
    simp [coe_mFourierBasis]
  rw [← h1, h2, h3]

/-- The Galerkin spectral projection at level `N`, packaged as a
    `ContinuousLinearMap` over `ℂ`. -/
noncomputable def spectralProjL2CLM (N : ℕ) :
    L²(UnitAddTorus (Fin 3)) →L[ℂ] L²(UnitAddTorus (Fin 3)) :=
  ∑ k ∈ galerkinModeFinset N, fourierModeProjCLM k

theorem spectralProjL2CLM_apply (N : ℕ) (f : L²(UnitAddTorus (Fin 3))) :
    spectralProjL2CLM N f = spectralProjL2 N f := by
  simp [spectralProjL2CLM, spectralProjL2,
        ContinuousLinearMap.sum_apply, fourierModeProjCLM_apply]

end NavierStokesClean.Sobolev.SpectralProjectionT3
