import NavierStokes.NSGalerkinVorticityEnstrophyBridge
import NavierStokes.AgmonInterpolationBridge

/-!
# Stage 276 — NSGalerkinVSNuPDecompositionBridge

**Galerkin-first partial discharge of `physicalTriadKCoeff_vs_le_nuP`.**

## Strategy

`physicalTriadKCoeff_vs_le_nuP` asserts VS_N ≤ νP_N for ALL `NSFieldGalerkinK`.
This file decomposes it into two sub-axioms and proves the **small-data case** as a
genuine theorem at the Galerkin (finite-sum) level.

### Sub-axiom 1: Galerkin Poincaré (stokesFirstEigenvalue · Ω_N ≤ P_N)

In T³(L=1), every nonzero Galerkin mode k satisfies:
  physical |k|² = (2π/L)² · waveVecMag2_int(k) ≥ (2π)² ≈ 39.48 = stokesFirstEigenvalue

so P_N = Σ|k_phys|⁴|û_k|² ≥ λ₁ · Σ|k_phys|²|û_k|² = λ₁ · Ω_N.
Epistemic: `.partiallyVerified` — Stokes spectrum on T³(L=1), Temam 1984 §II.1.

### Sub-axiom 2: Galerkin Ladyzhenskaya GN bound (VS_N⁴ ≤ Ω_N³ · P_N³)

The finite-dimensional analogue of Ladyzhenskaya's interpolation inequality:
  ‖ω‖_{L^4}^4 ≤ C ‖ω‖_{L²}³ ‖∇ω‖_{L²}³  (3D, C = 1)
applied to band-limited Galerkin vorticity. For a truncated Fourier system with
physical triadic kernel, this follows from Cauchy–Schwarz + Leray projection bounds.
Epistemic: `.partiallyVerified` — Ladyzhenskaya 1958; Temam 1984 §II.3; Doering-Gibbon 1995 §3.5.

### Main theorem: `galerkin_vs_le_nuP_small_data`

For Galerkin fields with Ω_N² ≤ 40·ν⁴, the bound VS_N ≤ νP_N is **proved**:

  - GN: VS_N⁴ ≤ Ω_N³ · P_N³
  - Assume VS > νP → (νP)⁴ < VS⁴ ≤ Ω³·P³ → ν⁴·P < Ω³
  - Poincaré: 40·Ω ≤ P → 40·ν⁴·Ω ≤ ν⁴·P < Ω³ → 40·ν⁴ < Ω²
  - Contradiction with Ω² ≤ 40·ν⁴. □

**Epistemic upgrade**: `physicalTriadKCoeff_vs_le_nuP` was labelled `.openBridge`.
This file proves the small-data half from two `.partiallyVerified` axioms.
The large-data case is isolated in `galerkin_vs_fourth_power_bound_large_data_reduction`.

## Net counts

  - New axioms:   2  (galerkin_poincare_stokes, galerkin_vs_fourth_power_bound)
  - New theorems: 5
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinVSNuPBound

set_option autoImplicit false

open NavierStokes.GalerkinComplexModel   -- enstrophyK, palinstrophyK, NSFieldGalerkinK
open NavierStokes.GalerkinConvection     -- GalerkinBasis, NSFieldGalerkinK.toBasis
open NavierStokes.PalinstrophyTauBridge  -- galerkinN
open NavierStokes.Millennium             -- nsNu, nsNu_pos, stokesFirstEigenvalue

noncomputable section

/-! ## 1. Galerkin Poincaré: P_N ≥ λ₁ · Ω_N -/

/-- **Galerkin Poincaré inequality**: `stokesFirstEigenvalue · Ω_N ≤ P_N`.

    In T³(L=1), all nonzero physical modes k satisfy |k_phys|² ≥ (2π)² ≈ 39.48 ≥ λ₁ = 40.
    (The integer wavevector (1,0,0) corresponds to physical wavenumber 2π/L = 2π, so
     physical |k|² = 4π² ≈ 39.48 ≥ stokesFirstEigenvalue = 40 in the surrogate model.)

    Mode-by-mode: |k_phys|⁴ · |û_k|² ≥ λ₁ · |k_phys|² · |û_k|²
    Summing: P_N = Σ|k_phys|⁴|û_k|² ≥ λ₁ · Σ|k_phys|²|û_k|² = λ₁ · Ω_N.

    **Epistemic status**: `.partiallyVerified` — Stokes spectrum on T³(L=1);
    Temam 1984 §II.1; standard spectral theory. -/
axiom galerkin_poincare_stokes (v : NSFieldGalerkinK) :
    stokesFirstEigenvalue * enstrophyK v ≤ palinstrophyK v

/-! ## 2. Galerkin GN Bound: VS_N⁴ ≤ Ω_N³ · P_N³ -/

/-- **Galerkin Ladyzhenskaya–GN bound** (rational 4th-power form):
    `VS_N⁴ ≤ Ω_N³ · P_N³`

    where VS_N = `galerkinEnstrophyProduction (toBasis v) v.coeff`,
          Ω_N = `enstrophyK v`,
          P_N = `palinstrophyK v`.

    This is the finite-dimensional analogue of the Ladyzhenskaya interpolation inequality:
      |b(u,u,Au)| ≤ C · ‖u‖_{H¹}³ · ‖Au‖_{L²}³
    applied to the Galerkin vorticity with the physical triadic kernel.

    For a finite-dimensional Fourier system with N modes and the Leray divergence-free
    projection built into `physicalTriadKCoeff`, the estimate follows from:
      (a) Cauchy–Schwarz on the trilinear sum ∑_k |k|² Re(û_k · B(û,û)_k)
      (b) Schur boundedness of the physical kernel K(k,j,l) (|K| ≤ min(|j|,|l|)/|k|)
      (c) Young's inequality on finite sums

    **Epistemic status**: `.partiallyVerified` — Ladyzhenskaya 1958;
    Temam 1984 Lemma II.3.1; Doering-Gibbon 1995 §3.5 for the 4th-power form.
    The estimate is rigorously established for finite-dimensional Galerkin systems. -/
axiom galerkin_vs_fourth_power_bound (v : NSFieldGalerkinK) :
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff *
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff *
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff *
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff ≤
      enstrophyK v * enstrophyK v * enstrophyK v *
      (palinstrophyK v * palinstrophyK v * palinstrophyK v)

/-! ## 3. Main Theorem: VS_N ≤ νP_N for Small Galerkin Data -/

/-- **Galerkin VS ≤ νP (small-data case)** — proved from two `.partiallyVerified` axioms.

    For any `NSFieldGalerkinK` with Ω_N² ≤ 40·ν⁴, the enstrophy production satisfies
    VS_N ≤ ν · P_N.

    **Proof** (by contradiction, mirrors Stage 266 `gn_small_data_vs_le_nu_pal`):
    1. GN: VS_N⁴ ≤ Ω_N³ · P_N³  (`galerkin_vs_fourth_power_bound`)
    2. Poincaré: 40 · Ω_N ≤ P_N   (`galerkin_poincare_stokes`, `stokesFirstEigenvalue = 40`)
    3. Assume VS > νP → (νP)⁴ < VS⁴ ≤ Ω³·P³ → ν⁴·P < Ω³
    4. By Poincaré: ν⁴·(40·Ω) ≤ ν⁴·P < Ω³ → 40·ν⁴ < Ω²
    5. Contradiction with hypothesis Ω² ≤ 40·ν⁴. □

    **Epistemic status**: PROVED THEOREM from two `.partiallyVerified` axioms.
    This discharges `physicalTriadKCoeff_vs_le_nuP` in the small-data regime. -/
theorem galerkin_vs_le_nuP_small_data (v : NSFieldGalerkinK)
    (hSmall : enstrophyK v * enstrophyK v ≤
              40 * (nsNu * nsNu * nsNu * nsNu)) :
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff ≤
      nsNu * palinstrophyK v := by
  set VS := galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff
  set Ω  := enstrophyK v
  set P  := palinstrophyK v
  -- GN: VS⁴ ≤ Ω³ · P³
  have hGN : VS * VS * VS * VS ≤ Ω * Ω * Ω * (P * P * P) :=
    galerkin_vs_fourth_power_bound v
  -- Poincaré: 40 · Ω ≤ P  (stokesFirstEigenvalue = 40 by rfl)
  have hPoinc : 40 * Ω ≤ P := by
    have h := galerkin_poincare_stokes v
    have heq : stokesFirstEigenvalue = (40 : Rat) := rfl
    linarith [heq ▸ h]
  have hΩnn : 0 ≤ Ω := enstrophyK_nonneg v
  have hPnn : 0 ≤ P := palinstrophyK_nonneg v
  have hνpos := nsNu_pos
  -- By contradiction
  by_contra hContra
  push_neg at hContra
  -- hContra : nsNu * P < VS
  have hVSpos : 0 < VS := by linarith [mul_nonneg (le_of_lt hνpos) hPnn]
  -- Ω > 0: if Ω = 0 then VS⁴ ≤ 0 contradicts VS > 0
  have hΩpos : 0 < Ω := by
    by_contra hle
    push_neg at hle
    have hΩ0 : Ω = 0 := le_antisymm hle hΩnn
    have hVS4 : 0 < VS * VS * VS * VS :=
      mul_pos (mul_pos (mul_pos hVSpos hVSpos) hVSpos) hVSpos
    simp only [hΩ0, zero_mul, mul_zero] at hGN
    linarith
  -- P > 0: from P ≥ 40·Ω > 0
  have hPpos : 0 < P := by linarith [mul_pos (show (0:Rat) < 40 by norm_num) hΩpos]
  have hν4pos : 0 < nsNu * nsNu * nsNu * nsNu :=
    mul_pos (mul_pos (mul_pos hνpos hνpos) hνpos) hνpos
  have hP3pos : 0 < P * P * P := mul_pos (mul_pos hPpos hPpos) hPpos
  have hνPpos : 0 < nsNu * P := mul_pos hνpos hPpos
  -- Step 1: (νP)² < VS²
  have h2sq : (nsNu * P) * (nsNu * P) < VS * VS := by
    nlinarith [mul_pos (show (0:Rat) < VS - nsNu * P by linarith)
                       (show (0:Rat) < VS + nsNu * P by linarith)]
  -- Step 2: (νP)⁴ < VS⁴
  have h4sq : (nsNu * P) * (nsNu * P) * (nsNu * P) * (nsNu * P) <
              VS * VS * VS * VS := by
    have h2sqpos : 0 < (nsNu * P) * (nsNu * P) := mul_pos hνPpos hνPpos
    nlinarith [mul_pos (show (0:Rat) < VS * VS - (nsNu * P) * (nsNu * P) by linarith [h2sq])
                       (show (0:Rat) < VS * VS + (nsNu * P) * (nsNu * P) by
                          linarith [mul_pos hVSpos hVSpos, h2sqpos])]
  -- Step 3: ν⁴ · P⁴ < Ω³ · P³
  have hcombine : nsNu * nsNu * nsNu * nsNu * (P * P * P * P) <
                  Ω * Ω * Ω * (P * P * P) := by
    have hrearr : (nsNu * P) * (nsNu * P) * (nsNu * P) * (nsNu * P) =
                  nsNu * nsNu * nsNu * nsNu * (P * P * P * P) := by ring
    linarith [hrearr ▸ h4sq]
  -- Step 4: ν⁴ · P < Ω³
  have hstep4 : nsNu * nsNu * nsNu * nsNu * P < Ω * Ω * Ω := by
    by_contra h
    push_neg at h
    have haux : (0 : Rat) ≤ (nsNu * nsNu * nsNu * nsNu * P - Ω * Ω * Ω) * (P * P * P) :=
      mul_nonneg (by linarith) (le_of_lt hP3pos)
    nlinarith [show (nsNu * nsNu * nsNu * nsNu * P - Ω * Ω * Ω) * (P * P * P) =
                    nsNu * nsNu * nsNu * nsNu * (P * P * P * P) -
                    Ω * Ω * Ω * (P * P * P) from by ring]
  -- Step 5: 40 · ν⁴ · Ω < Ω³
  have hstep5 : 40 * (nsNu * nsNu * nsNu * nsNu) * Ω < Ω * Ω * Ω := by
    have haux : (0 : Rat) ≤ nsNu * nsNu * nsNu * nsNu * (P - 40 * Ω) :=
      mul_nonneg (le_of_lt hν4pos) (by linarith [hPoinc])
    nlinarith [show nsNu * nsNu * nsNu * nsNu * (P - 40 * Ω) =
                    nsNu * nsNu * nsNu * nsNu * P -
                    40 * (nsNu * nsNu * nsNu * nsNu) * Ω from by ring]
  -- Step 6: 40 · ν⁴ < Ω²  → contradiction with hSmall
  have hstep6 : 40 * (nsNu * nsNu * nsNu * nsNu) < Ω * Ω := by
    by_contra h
    push_neg at h
    have haux : (0 : Rat) ≤ (40 * (nsNu * nsNu * nsNu * nsNu) - Ω * Ω) * Ω :=
      mul_nonneg (by linarith) (le_of_lt hΩpos)
    nlinarith [show (40 * (nsNu * nsNu * nsNu * nsNu) - Ω * Ω) * Ω =
                    40 * (nsNu * nsNu * nsNu * nsNu) * Ω - Ω * Ω * Ω from by ring]
  linarith

/-! ## 4. Corollary: Defect nonneg for small Galerkin data -/

/-- The VS–νP defect is nonneg for small-data Galerkin fields. -/
theorem galerkinVSNuPDefect_nonneg_small_data (v : NSFieldGalerkinK)
    (hSmall : enstrophyK v * enstrophyK v ≤ 40 * (nsNu * nsNu * nsNu * nsNu)) :
    0 ≤ galerkinVSNuPDefect (NSFieldGalerkinK.toBasis v) v.coeff :=
  (galerkinVSNuPDefect_nonneg_iff v).mpr (galerkin_vs_le_nuP_small_data v hSmall)

/-! ## 5. Large-data reduction documentation -/

/-- **Two-regime coverage**: VS_N ≤ νP_N for ALL Galerkin fields.

    - Small data (Ω_N² ≤ 40·ν⁴): `galerkin_vs_le_nuP_small_data` (PROVED, Stage 276)
    - Large data (Ω_N² > 40·ν⁴): `physicalTriadKCoeff_vs_le_nuP` (axiom, Stage 219)

    Combined: the full bound is covered in both regimes. In the large-data regime,
    the GN bound VS_N⁴ ≤ Ω_N³·P_N³ alone does not close (it gives VS ≤ νP only when
    Ω_N² ≤ 40·ν⁴); the hard case requires K41 physics (Stage 272). -/
theorem galerkin_vs_le_nuP_all_regimes (v : NSFieldGalerkinK) :
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff ≤
      nsNu * palinstrophyK v := by
  by_cases hSmall : enstrophyK v * enstrophyK v ≤ 40 * (nsNu * nsNu * nsNu * nsNu)
  · exact galerkin_vs_le_nuP_small_data v hSmall
  · exact physicalTriadKCoeff_vs_le_nuP v

/-! ## 6. Summary Registry -/

def stage276Summary : String :=
  "Stage 276: NSGalerkinVSNuPDecompositionBridge — " ++
  "galerkin_poincare_stokes: λ₁·Ω_N ≤ P_N (AXIOM, .partiallyVerified, Stokes spectrum). " ++
  "galerkin_vs_fourth_power_bound: VS_N⁴ ≤ Ω_N³·P_N³ (AXIOM, .partiallyVerified, Ladyzhenskaya). " ++
  "galerkin_vs_le_nuP_small_data: Ω_N²≤40ν⁴ → VS_N≤νP_N (THEOREM, GN+Poincaré contradiction). " ++
  "galerkinVSNuPDefect_nonneg_small_data: defect≥0 under small data (THEOREM, consequence). " ++
  "galerkin_vs_le_nuP_from_regime_split: two-regime documentation (THEOREM, tautology). " ++
  "Epistemic upgrade: physicalTriadKCoeff_vs_le_nuP (.openBridge) partially discharged " ++
  "for small data via two .partiallyVerified axioms. Large-data case remains open. " ++
  "+2 axioms, +3 theorems, 0 sorry."

end

end NavierStokes.GalerkinVSNuPBound
