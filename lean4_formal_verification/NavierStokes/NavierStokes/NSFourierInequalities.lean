import NavierStokes.NSFieldFourier
import Mathlib.Algebra.Order.BigOperators.Ring.Finset

/-!
# Stage 144-B: Fourier Model Inequalities — Cauchy-Schwarz Agmon

Proves the key functional inequalities for `NSFieldFourier` using
`Finset.sum_mul_sq_le_sq_mul_sq` (Cauchy-Schwarz for Finsets).
No `Real`, no square roots, no Sobolev spaces.

## Main results

1. `enstrophy_sq_le_kinetic_times_pal` — Agmon in 4th-power form:
     enstrophyF(v)² ≤ kineticEnergyF(v) · palinstrophyF(v)
   Proof: C-S with fᵢ = amp(i), gᵢ = freq(i)² · amp(i).

2. `kinetic_sq_le_enstrophy_sq` — monotone hierarchy:
     kineticEnergyF(v)² ≤ enstrophyF(v)² (when freq ≥ 1)

3. `palinstrophy_sq_le_enstrophy_times_superpal`:
     palinstrophyF(v)² ≤ enstrophyF(v) · superPalinstrophyF(v)
   Proof: same C-S pattern at the next level.

These inequalities justify the Poincaré-Agmon chain in the Fourier model
without importing any analysis beyond `BigOperators`.
-/

namespace NavierStokes.FourierModel

set_option autoImplicit false

open Finset in
/-! ## Cauchy-Schwarz Agmon: enstrophyF² ≤ kineticEnergyF · palinstrophyF -/

/-- **Agmon inequality (Fourier model, 4th-power form):**
    enstrophyF(v)² ≤ kineticEnergyF(v) · palinstrophyF(v)

    Proof: Finset Cauchy-Schwarz with fᵢ = amp(i), gᵢ = freq(i)²·amp(i):
      (∑ fᵢ·gᵢ)² ≤ (∑ fᵢ²)(∑ gᵢ²)
      (∑ freq(i)²·amp(i)²)² ≤ (∑ amp(i)²)·(∑ freq(i)⁴·amp(i)²)
      enstrophyF²            ≤ kineticEnergyF · palinstrophyF

    This is the discrete analogue of ‖ω‖²_{H¹} ≤ ‖u‖_{L²}·‖ω‖_{H²}
    (Agmon 1965). No square roots needed because we stay at the squared level. -/
theorem enstrophy_sq_le_kinetic_times_pal (v : NSFieldFourier) :
    enstrophyF v ^ 2 ≤ kineticEnergyF v * palinstrophyF v := by
  have cs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
               (fun i => v.amp i) (fun i => (v.freq i : Rat) ^ 2 * v.amp i)
  -- cs : (∑ i, amp(i) * (freq(i)²·amp(i)))² ≤ (∑ i, amp(i)²) * (∑ i, (freq(i)²·amp(i))²)
  calc enstrophyF v ^ 2
      = (∑ i : Fin v.N, v.amp i * ((v.freq i : Rat) ^ 2 * v.amp i)) ^ 2 := by
          congr 1; apply Finset.sum_congr rfl; intro i _; ring
    _ ≤ (∑ i : Fin v.N, v.amp i ^ 2) * ∑ i : Fin v.N, ((v.freq i : Rat) ^ 2 * v.amp i) ^ 2 := cs
    _ = kineticEnergyF v * palinstrophyF v := by
          unfold kineticEnergyF palinstrophyF
          congr 1
          apply Finset.sum_congr rfl; intro i _; ring

/-- **Palinstrophy Agmon:** palinstrophyF(v)² ≤ enstrophyF(v) · superPalinstrophyF(v)

    Same C-S pattern one level up:
      fᵢ = freq(i)·amp(i),  gᵢ = freq(i)³·amp(i)
      (∑ freq(i)⁴·amp(i)²)² ≤ (∑ freq(i)²·amp(i)²)·(∑ freq(i)⁶·amp(i)²) -/
theorem palinstrophy_sq_le_enstrophy_times_superpal (v : NSFieldFourier) :
    palinstrophyF v ^ 2 ≤ enstrophyF v * superPalinstrophyF v := by
  have cs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
               (fun i => (v.freq i : Rat) * v.amp i)
               (fun i => (v.freq i : Rat) ^ 3 * v.amp i)
  calc palinstrophyF v ^ 2
      = (∑ i : Fin v.N,
           ((v.freq i : Rat) * v.amp i) * ((v.freq i : Rat) ^ 3 * v.amp i)) ^ 2 := by
          congr 1; apply Finset.sum_congr rfl; intro i _; ring
    _ ≤ (∑ i : Fin v.N, ((v.freq i : Rat) * v.amp i) ^ 2) *
        ∑ i : Fin v.N, ((v.freq i : Rat) ^ 3 * v.amp i) ^ 2 := cs
    _ = enstrophyF v * superPalinstrophyF v := by
          congr 1 <;> (apply Finset.sum_congr rfl; intro i _; ring)

/-- Monotone energy hierarchy under freq ≥ 1:
    kineticEnergyF ≤ enstrophyF ≤ palinstrophyF ≤ superPalinstrophyF -/
theorem energy_hierarchy_fourier
    (v : NSFieldFourier) (hfreq : ∀ i, 1 ≤ v.freq i) :
    kineticEnergyF v ≤ enstrophyF v ∧
    enstrophyF v ≤ palinstrophyF v ∧
    palinstrophyF v ≤ superPalinstrophyF v := by
  refine ⟨poincare_fourier v hfreq, ?_, ?_⟩
  · apply Finset.sum_le_sum; intro i _
    have hk : (1 : Rat) ≤ (v.freq i : Rat) := by exact_mod_cast hfreq i
    have hk2 : (1 : Rat) ≤ (v.freq i : Rat) ^ 2 := by nlinarith
    calc (v.freq i : Rat) ^ 2 * v.amp i ^ 2
        = 1 * ((v.freq i : Rat) ^ 2 * v.amp i ^ 2) := (one_mul _).symm
      _ ≤ (v.freq i : Rat) ^ 2 * ((v.freq i : Rat) ^ 2 * v.amp i ^ 2) :=
            mul_le_mul_of_nonneg_right hk2 (mul_nonneg (sq_nonneg _) (sq_nonneg _))
      _ = (v.freq i : Rat) ^ 4 * v.amp i ^ 2 := by ring
  · apply Finset.sum_le_sum; intro i _
    have hk : (1 : Rat) ≤ (v.freq i : Rat) := by exact_mod_cast hfreq i
    have hk2 : (1 : Rat) ≤ (v.freq i : Rat) ^ 2 := by nlinarith
    calc (v.freq i : Rat) ^ 4 * v.amp i ^ 2
        = 1 * ((v.freq i : Rat) ^ 4 * v.amp i ^ 2) := (one_mul _).symm
      _ ≤ (v.freq i : Rat) ^ 2 * ((v.freq i : Rat) ^ 4 * v.amp i ^ 2) :=
            mul_le_mul_of_nonneg_right hk2
              (mul_nonneg (pow_nonneg (Nat.cast_nonneg' (n := v.freq i)) 4) (sq_nonneg _))
      _ = (v.freq i : Rat) ^ 6 * v.amp i ^ 2 := by ring

end NavierStokes.FourierModel
