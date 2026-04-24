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

end NavierStokesClean.Sobolev.SpectralProjectionT3
