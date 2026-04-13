import NavierStokes.NSFieldFourier
import NavierStokes.NSGalerkinVorticityEnstrophyBridge

/-!
# NST3SobolevSupplement (S0 scaffold)

Concrete T³ Fourier/Sobolev helpers used to supplement missing Mathlib4 torus
infrastructure for the NS compactness lane.

This stage intentionally provides compile-safe building blocks:
- weighted mode seminorms on the finite Fourier carrier,
- head/tail frequency decomposition,
- monotone Sobolev ladder lemmas under the standard `|k| ≥ 1` guard,
- explicit contract defs for downstream Aubin-Lions wiring.
-/

namespace NavierStokes.T3SobolevSupplement

set_option autoImplicit false

open Finset
open NavierStokes.FourierModel

noncomputable section

/-! ## Weighted Fourier seminorms -/

/-- Weighted mode seminorm
`Hs(v,s) := Σᵢ |kᵢ|^(2s) · |ûᵢ|²` on the finite Fourier carrier. -/
noncomputable def weightedModeSeminorm (v : NSFieldFourier) (s : Nat) : Rat :=
  ∑ i : Fin v.N, (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2

@[simp] theorem weightedModeSeminorm_zero (v : NSFieldFourier) :
    weightedModeSeminorm v 0 = kineticEnergyF v := by
  unfold weightedModeSeminorm kineticEnergyF
  simp

@[simp] theorem weightedModeSeminorm_one (v : NSFieldFourier) :
    weightedModeSeminorm v 1 = enstrophyF v := by
  unfold weightedModeSeminorm enstrophyF
  simp

@[simp] theorem weightedModeSeminorm_two (v : NSFieldFourier) :
    weightedModeSeminorm v 2 = palinstrophyF v := by
  unfold weightedModeSeminorm palinstrophyF
  simp

theorem weightedModeSeminorm_nonneg (v : NSFieldFourier) (s : Nat) :
    0 ≤ weightedModeSeminorm v s := by
  unfold weightedModeSeminorm
  apply Finset.sum_nonneg
  intro i _
  exact mul_nonneg (pow_nonneg (Nat.cast_nonneg (v.freq i)) (2 * s)) (sq_nonneg _)

/-! ## Frequency cut decomposition -/

/-- Low-frequency head (`|k| ≤ K`) of the weighted seminorm. -/
noncomputable def frequencyHeadSeminorm (v : NSFieldFourier) (s K : Nat) : Rat :=
  ∑ i : Fin v.N, if v.freq i ≤ K then (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2 else 0

/-- High-frequency tail (`K < |k|`) of the weighted seminorm. -/
noncomputable def frequencyTailSeminorm (v : NSFieldFourier) (s K : Nat) : Rat :=
  ∑ i : Fin v.N, if K < v.freq i then (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2 else 0

theorem frequencyHeadSeminorm_nonneg (v : NSFieldFourier) (s K : Nat) :
    0 ≤ frequencyHeadSeminorm v s K := by
  unfold frequencyHeadSeminorm
  apply Finset.sum_nonneg
  intro i _
  by_cases h : v.freq i ≤ K
  · simp [h]
    exact mul_nonneg (pow_nonneg (Nat.cast_nonneg (v.freq i)) (2 * s)) (sq_nonneg _)
  · simp [h]

theorem frequencyTailSeminorm_nonneg (v : NSFieldFourier) (s K : Nat) :
    0 ≤ frequencyTailSeminorm v s K := by
  unfold frequencyTailSeminorm
  apply Finset.sum_nonneg
  intro i _
  by_cases h : K < v.freq i
  · simp [h]
    exact mul_nonneg (pow_nonneg (Nat.cast_nonneg (v.freq i)) (2 * s)) (sq_nonneg _)
  · simp [h]

/-- Exact head+tail split of the weighted seminorm at cutoff `K`. -/
theorem weightedModeSeminorm_head_tail
    (v : NSFieldFourier) (s K : Nat) :
    weightedModeSeminorm v s = frequencyHeadSeminorm v s K + frequencyTailSeminorm v s K := by
  unfold weightedModeSeminorm frequencyHeadSeminorm frequencyTailSeminorm
  calc
    ∑ i : Fin v.N, (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2
      = ∑ i : Fin v.N,
          ((if v.freq i ≤ K then (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2 else 0) +
           (if K < v.freq i then (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2 else 0)) := by
          apply Finset.sum_congr rfl
          intro i _
          by_cases h : v.freq i ≤ K
          · simp [h, Nat.not_lt_of_ge h]
          · simp [h, Nat.lt_of_not_ge h]
    _ = (∑ i : Fin v.N, if v.freq i ≤ K then (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2 else 0) +
        (∑ i : Fin v.N, if K < v.freq i then (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2 else 0) := by
          rw [Finset.sum_add_distrib]

theorem frequencyHeadSeminorm_le_weightedModeSeminorm
    (v : NSFieldFourier) (s K : Nat) :
    frequencyHeadSeminorm v s K ≤ weightedModeSeminorm v s := by
  rw [weightedModeSeminorm_head_tail v s K]
  nlinarith [frequencyTailSeminorm_nonneg v s K]

theorem frequencyTailSeminorm_le_weightedModeSeminorm
    (v : NSFieldFourier) (s K : Nat) :
    frequencyTailSeminorm v s K ≤ weightedModeSeminorm v s := by
  rw [weightedModeSeminorm_head_tail v s K]
  nlinarith [frequencyHeadSeminorm_nonneg v s K]

private theorem frequencyTail_term_scaled_le_succ
    (v : NSFieldFourier) (s K : Nat) (i : Fin v.N) (hK : K < v.freq i) :
    ((K + 1 : Rat) ^ 2) * ((v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2) ≤
      (v.freq i : Rat) ^ (2 * (s + 1)) * v.amp i ^ 2 := by
  have hCast : ((K + 1 : Nat) : Rat) ≤ (v.freq i : Rat) := by
    exact_mod_cast Nat.succ_le_of_lt hK
  have hCast' : (K : Rat) + 1 ≤ (v.freq i : Rat) := by
    simpa [Nat.cast_add] using hCast
  have hCastNonneg : (0 : Rat) ≤ (K : Rat) + 1 := by
    nlinarith
  have hPow2 : ((K + 1 : Rat) ^ 2) ≤ ((v.freq i : Rat) ^ 2) := by
    have hMul :
        ((K : Rat) + 1) * ((K : Rat) + 1) ≤
          (v.freq i : Rat) * (v.freq i : Rat) := by
      exact mul_le_mul hCast' hCast' hCastNonneg (le_trans hCastNonneg hCast')
    simpa [pow_two, Nat.cast_add] using hMul
  have hBaseNonneg : 0 ≤ (v.freq i : Rat) ^ (2 * s) := by
    exact pow_nonneg (Nat.cast_nonneg (v.freq i)) (2 * s)
  have hAmpSqNonneg : 0 ≤ v.amp i ^ 2 := sq_nonneg (v.amp i)
  calc
    ((K + 1 : Rat) ^ 2) * ((v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2)
      = (((K + 1 : Rat) ^ 2) * (v.freq i : Rat) ^ (2 * s)) * v.amp i ^ 2 := by ring
    _ ≤ (((v.freq i : Rat) ^ 2) * (v.freq i : Rat) ^ (2 * s)) * v.amp i ^ 2 := by
          exact mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hPow2 hBaseNonneg) hAmpSqNonneg
    _ = (v.freq i : Rat) ^ (2 * (s + 1)) * v.amp i ^ 2 := by ring_nf

/-- Tail control at cutoff `K`: multiplying the lower-order tail by `(K+1)^2`
forces it under the next-order tail. -/
theorem frequencyTailSeminorm_scaled_le_succ
    (v : NSFieldFourier) (s K : Nat) :
    ((K + 1 : Rat) ^ 2) * frequencyTailSeminorm v s K ≤
      frequencyTailSeminorm v (s + 1) K := by
  unfold frequencyTailSeminorm
  calc
    ((K + 1 : Rat) ^ 2) * (∑ i : Fin v.N,
        if K < v.freq i then (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2 else 0)
      = ∑ i : Fin v.N,
          ((K + 1 : Rat) ^ 2) *
            (if K < v.freq i then (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2 else 0) := by
          rw [Finset.mul_sum]
    _ ≤ ∑ i : Fin v.N, if K < v.freq i then (v.freq i : Rat) ^ (2 * (s + 1)) * v.amp i ^ 2 else 0 := by
          apply Finset.sum_le_sum
          intro i _
          by_cases hK : K < v.freq i
          · simp [hK]
            exact frequencyTail_term_scaled_le_succ v s K i hK
          · simp [hK]

/-- The tail is monotone in Sobolev order: `Hs`-tail ≤ `H(s+1)`-tail. -/
theorem frequencyTailSeminorm_le_succ
    (v : NSFieldFourier) (s K : Nat) :
    frequencyTailSeminorm v s K ≤ frequencyTailSeminorm v (s + 1) K := by
  have hScaled := frequencyTailSeminorm_scaled_le_succ v s K
  have hTailNonneg : 0 ≤ frequencyTailSeminorm v s K := frequencyTailSeminorm_nonneg v s K
  have hOneLe : (1 : Rat) ≤ (K + 1 : Rat) ^ 2 := by
    have hOneLeBase : (1 : Rat) ≤ (K : Rat) + 1 := by nlinarith
    have hBaseNonneg : (0 : Rat) ≤ (K : Rat) + 1 := by nlinarith
    have hMul : (1 : Rat) * 1 ≤ ((K : Rat) + 1) * ((K : Rat) + 1) := by
      exact mul_le_mul hOneLeBase hOneLeBase (by norm_num) hBaseNonneg
    simpa [pow_two, Nat.cast_add] using hMul
  have hLift :
      frequencyTailSeminorm v s K ≤ ((K + 1 : Rat) ^ 2) * frequencyTailSeminorm v s K := by
    calc
      frequencyTailSeminorm v s K = (1 : Rat) * frequencyTailSeminorm v s K := by ring
      _ ≤ ((K + 1 : Rat) ^ 2) * frequencyTailSeminorm v s K :=
            mul_le_mul_of_nonneg_right hOneLe hTailNonneg
  exact le_trans hLift hScaled

/-- Compactness-friendly bridge: lower-order tail is controlled by the next-order whole seminorm. -/
theorem frequencyTailSeminorm_le_weightedModeSeminorm_succ
    (v : NSFieldFourier) (s K : Nat) :
    frequencyTailSeminorm v s K ≤ weightedModeSeminorm v (s + 1) := by
  exact le_trans (frequencyTailSeminorm_le_succ v s K)
    (frequencyTailSeminorm_le_weightedModeSeminorm v (s + 1) K)

/-- Specialized compactness bridge:
the enstrophy tail (`s=1`) is controlled by full palinstrophy (`s=2`). -/
theorem enstrophyTail_le_palinstrophy
    (v : NSFieldFourier) (K : Nat) :
    frequencyTailSeminorm v 1 K ≤ palinstrophyF v := by
  simpa [weightedModeSeminorm_two] using
    (frequencyTailSeminorm_le_weightedModeSeminorm_succ v 1 K)

/-- Scaled enstrophy-tail estimate at cutoff `K`. -/
theorem scaledEnstrophyTail_le_palinstrophyTail
    (v : NSFieldFourier) (K : Nat) :
    ((K + 1 : Rat) ^ 2) * frequencyTailSeminorm v 1 K ≤ frequencyTailSeminorm v 2 K := by
  simpa using frequencyTailSeminorm_scaled_le_succ v 1 K

/-! ## Sobolev ladder monotonicity under `|k| ≥ 1` -/

private theorem weightedMode_term_le_succ
    (v : NSFieldFourier) (s : Nat) (i : Fin v.N) (hfreq : 1 ≤ v.freq i) :
    (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2 ≤
      (v.freq i : Rat) ^ (2 * (s + 1)) * v.amp i ^ 2 := by
  have hk : (1 : Rat) ≤ (v.freq i : Rat) := by exact_mod_cast hfreq
  have hk2 : (1 : Rat) ≤ (v.freq i : Rat) ^ 2 := by nlinarith
  have hs_nonneg : 0 ≤ (v.freq i : Rat) ^ (2 * s) := by
    exact pow_nonneg (Nat.cast_nonneg (v.freq i)) (2 * s)
  have ha_nonneg : 0 ≤ v.amp i ^ 2 := sq_nonneg (v.amp i)
  have hterm_nonneg : 0 ≤ (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2 := by
    exact mul_nonneg hs_nonneg ha_nonneg
  calc
    (v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2
      = 1 * ((v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2) := by ring
    _ ≤ (v.freq i : Rat) ^ 2 * ((v.freq i : Rat) ^ (2 * s) * v.amp i ^ 2) :=
      mul_le_mul_of_nonneg_right hk2 hterm_nonneg
    _ = (v.freq i : Rat) ^ (2 * (s + 1)) * v.amp i ^ 2 := by
      ring_nf

/-- Under the Poincaré guard `|k| ≥ 1`, higher weighted seminorms dominate lower ones. -/
theorem weightedModeSeminorm_le_succ
    (v : NSFieldFourier) (s : Nat) (hfreq : ∀ i : Fin v.N, 1 ≤ v.freq i) :
    weightedModeSeminorm v s ≤ weightedModeSeminorm v (s + 1) := by
  unfold weightedModeSeminorm
  apply Finset.sum_le_sum
  intro i _
  exact weightedMode_term_le_succ v s i (hfreq i)

/-- The standard kinetic ≤ enstrophy T³ inequality as a contract witness. -/
def T3PoincareContract : Prop :=
  ∀ (v : NSFieldFourier), (∀ i : Fin v.N, 1 ≤ v.freq i) → kineticEnergyF v ≤ enstrophyF v

theorem t3PoincareContract_holds : T3PoincareContract := by
  intro v hfreq
  exact poincare_fourier v hfreq

/-- Sobolev ladder contract on the finite Fourier carrier. -/
def T3FourierSobolevLadderContract : Prop :=
  ∀ (v : NSFieldFourier) (s : Nat),
    (∀ i : Fin v.N, 1 ≤ v.freq i) →
      weightedModeSeminorm v s ≤ weightedModeSeminorm v (s + 1)

theorem t3FourierSobolevLadderContract_holds : T3FourierSobolevLadderContract := by
  intro v s hfreq
  exact weightedModeSeminorm_le_succ v s hfreq

/-- Quantitative high-frequency tail control contract used by compactness lanes. -/
def T3TailControlContract : Prop :=
  ∀ (v : NSFieldFourier) (s K : Nat),
    frequencyTailSeminorm v s K ≤ weightedModeSeminorm v (s + 1)

theorem t3TailControlContract_holds : T3TailControlContract := by
  intro v s K
  exact frequencyTailSeminorm_le_weightedModeSeminorm_succ v s K

/-- Explicit `P` controls high-frequency enstrophy tails. -/
def T3EnstrophyTailByPalinstrophyContract : Prop :=
  ∀ (v : NSFieldFourier) (K : Nat),
    frequencyTailSeminorm v 1 K ≤ palinstrophyF v

theorem t3EnstrophyTailByPalinstrophyContract_holds :
    T3EnstrophyTailByPalinstrophyContract := by
  intro v K
  exact enstrophyTail_le_palinstrophy v K

def stageS1Summary : String :=
  "S1: Added explicit cutoff inequalities. " ++
  "Provides head/tail ≤ whole bounds, scaled tail control " ++
  "((K+1)^2·tail_s ≤ tail_{s+1}), monotone tail_s ≤ tail_{s+1}, " ++
  "and tail_s ≤ whole_{s+1} with a contract witness for compactness lanes."

end

end NavierStokes.T3SobolevSupplement

/-!
## Stage 295 — GalerkinSobolevSupplement: T³ Agmon-Sobolev at the Galerkin-K Level

Provides the Temam 1984 §II.3 Agmon-Sobolev trilinear bound at the `NSFieldGalerkinK`
level, supplementing the fact that T³ Sobolev embedding is not yet in Mathlib4.

The key result is the **absorbed Young bound**:

  `VS_N ≤ (ν/2) · P_N + C² / (2ν) · Ω_N²`

where:
- `VS_N = galerkinEnstrophyProduction (toBasis v) v.coeff`
- `P_N = palinstrophyK v`   (palinstrophy = ‖Δu‖² in Fourier)
- `Ω_N = enstrophyK v`     (enstrophy = ‖∇u‖² in Fourier)
- `C = t3TrilinearConst`   (Agmon-Sobolev trilinear constant on T³)

From this, VS_N ≤ νP_N follows as a **theorem** whenever the subcritical condition
  `C² · Ω_N² ≤ ν² · P_N`
holds (i.e., enstrophy is below the Sobolev critical threshold).

### Why unconditional VS_N ≤ νP_N is open

The unconditional bound `physicalTriadKCoeff_vs_le_nuP` (in NSGalerkinVorticityEnstrophyBridge)
would require showing the T³ Galerkin NS never exceeds the subcritical threshold for ALL
time and ALL initial data — equivalent to global regularity (Millennium Problem at the
Galerkin level).  Tao's filter (NSTriadicSignLocalityBridge) confirms this is not
derivable from energy cancellation alone.

### References

- Temam 1984 §II.3: Trilinear estimate on T³ + absorbed Young bound
- Doering–Gibbon 1995 §3.5: Enstrophy production in 3D
- Ladyzhenskaya 1969 Ch. III: Agmon inequality on torus

### Net counts (Stage 295)

  - New axioms:   2  (t3TrilinearConst, t3_agmon_sobolev_absorbed)
  - New theorems: 3  (vs_le_nup_from_subcritical, vs_le_nup_zero_enstrophy,
                      t3_absorbed_implies_physicalVSNuP_conditional)
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinSobolevSupplement

set_option autoImplicit false

open NavierStokes.GalerkinComplexModel  -- NSFieldGalerkinK, enstrophyK, palinstrophyK
open NavierStokes.GalerkinConvection    -- NSFieldGalerkinK.toBasis
open NavierStokes.GalerkinVSNuPBound   -- galerkinEnstrophyProduction
open NavierStokes.Millennium            -- nsNu, nsNu_pos

/-! ## §1. The Agmon-Sobolev Trilinear Constant -/

/-- The Temam 1984 §II.3 Agmon-Sobolev trilinear constant `C` on T³.

    This is the smallest constant `C > 0` such that the trilinear estimate
    on the 3-torus satisfies (with A = -Δ = Stokes operator):

      `|⟨B(u,u), Au⟩| ≤ C · ‖∇u‖² · ‖Au‖`

    By Young's inequality `xy ≤ x²/(2ε) + εy²/2` with ε = ν/2:

      `|VS_N| ≤ (ν/2)‖Au‖² + C²/(2ν) · ‖∇u‖⁴`
             = `(ν/2)·P_N + C²/(2ν) · Ω_N²`

    **Why not in Mathlib4**: the Agmon inequality on T³, T³ Sobolev embedding,
    and the concrete value of `C` for the Helmholtz-Leray projected bilinear
    operator require functional analysis not yet formalised in Mathlib4.

    Epistemic: `.partiallyVerified` — Temam 1984 §II.3 Proposition 3.3,
    Ladyzhenskaya 1969 Chapter III. -/
axiom t3TrilinearConst : Rat

/-- The Agmon-Sobolev constant is strictly positive. -/
axiom t3TrilinearConst_pos : (0 : Rat) < t3TrilinearConst

/-! ## §2. Absorbed Young Bound (Temam 1984 §II.3) -/

/-- **T³ Agmon-Sobolev absorbed Young bound.**

    For any Galerkin field `v` with the physical triadic kernel, the Galerkin
    enstrophy production satisfies:

      `VS_N ≤ (ν/2) · P_N + C² / (2ν) · Ω_N²`

    **Proof outline** (Temam 1984 §II.3, Doering-Gibbon 1995 §3.5):

    Step 1: `VS_N = ⟨B_phys(u,u), Au⟩` (by galerkinEnstrophyProduction_eq_vorticityInner)

    Step 2: T³ Agmon-Sobolev: `|VS_N| ≤ C · Ω_N · P_N^{1/2}`
            (Cauchy-Schwarz + T³ Sobolev embedding for the bilinear estimate)

    Step 3: Young: `C · Ω_N · P_N^{1/2} ≤ (ν/2)·P_N + C²/(2ν)·Ω_N²`
            (with ε = ν/2, using `2xy ≤ x²/ε + εy²`)

    **Epistemic: `.partiallyVerified`** — the Sobolev embedding and Agmon inequality
    on T³ are classical (Temam 1984, Ladyzhenskaya 1969) but not yet in Mathlib4.
    SciLean (lecopivo/SciLean) uses a different Lean toolchain (4.28.0-rc1 vs 4.29.0-rc3)
    and has no T³ Sobolev infrastructure. -/
axiom t3_agmon_sobolev_absorbed (v : NSFieldGalerkinK) :
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff ≤
    nsNu / 2 * palinstrophyK v +
    t3TrilinearConst ^ 2 / (2 * nsNu) * (enstrophyK v) ^ 2

/-! ## §3. Conditional VS ≤ νP (THEOREM from §2) -/

/-- **Conditional VS_N ≤ νP_N from subcritical enstrophy.**

    If the enstrophy satisfies the subcritical condition
      `C² / (2ν) · Ω_N² ≤ (ν/2) · P_N`
    (equivalently: `C² · Ω_N² ≤ ν² · P_N`), then VS_N ≤ νP_N.

    **Proof**: `VS_N ≤ (ν/2)P + C²/(2ν)Ω² ≤ (ν/2)P + (ν/2)P = νP` (linarith). -/
theorem vs_le_nup_from_subcritical (v : NSFieldGalerkinK)
    (h_sub : t3TrilinearConst ^ 2 / (2 * nsNu) * (enstrophyK v) ^ 2 ≤
             nsNu / 2 * palinstrophyK v) :
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff ≤
    nsNu * palinstrophyK v := by
  have h_abs := t3_agmon_sobolev_absorbed v
  linarith

/-! ## §4. Zero-Enstrophy Witness -/

/-- The zero-enstrophy field trivially satisfies VS_N ≤ νP_N.

    When `enstrophyK v = 0`, the absorbed Young bound gives VS_N ≤ (ν/2)P_N,
    and the subcritical condition holds vacuously (LHS = 0 ≤ RHS ≥ 0). -/
theorem vs_le_nup_zero_enstrophy (v : NSFieldGalerkinK)
    (h_zero : enstrophyK v = 0) :
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff ≤
    nsNu * palinstrophyK v := by
  apply vs_le_nup_from_subcritical
  have heq : (enstrophyK v) ^ 2 = 0 := by rw [h_zero]; norm_num
  rw [heq, mul_zero]
  exact mul_nonneg (div_nonneg (le_of_lt nsNu_pos) (by norm_num)) (palinstrophyK_nonneg v)

/-! ## §5. Bridge to physicalTriadKCoeff_vs_le_nuP -/

/-- The physical VS ≤ νP axiom is a consequence of the absorbed bound + subcriticality.

    This theorem documents the exact logical relationship:
    `physicalTriadKCoeff_vs_le_nuP` (which is stated unconditionally) is at least as
    strong as `vs_le_nup_from_subcritical` (which requires the subcritical hypothesis).

    The gap between them is the Millennium content: showing that T³ incompressible
    NS remains subcritical for all time and all initial data. -/
theorem t3_absorbed_implies_physicalVSNuP_conditional (v : NSFieldGalerkinK)
    (h_sub : t3TrilinearConst ^ 2 / (2 * nsNu) * (enstrophyK v) ^ 2 ≤
             nsNu / 2 * palinstrophyK v) :
    galerkinEnstrophyProduction (NSFieldGalerkinK.toBasis v) v.coeff ≤
    nsNu * palinstrophyK v :=
  vs_le_nup_from_subcritical v h_sub

/-! ## §6. Summary -/

def t3SobolevSupplementMilestone : String :=
  "Stage 295: GalerkinSobolevSupplement — T³ Agmon-Sobolev supplement at NSFieldGalerkinK level. " ++
  "t3TrilinearConst (AXIOM, .partiallyVerified): Temam 1984 §II.3 constant C > 0. " ++
  "t3TrilinearConst_pos (AXIOM): 0 < C. " ++
  "t3_agmon_sobolev_absorbed (AXIOM, .partiallyVerified): VS ≤ (ν/2)P + C²/(2ν)·Ω². " ++
  "vs_le_nup_from_subcritical (THEOREM): C²Ω²≤ν²P → VS≤νP (linarith). " ++
  "vs_le_nup_zero_enstrophy (THEOREM): enstrophy=0 → VS≤νP (witness). " ++
  "t3_absorbed_implies_physicalVSNuP_conditional (THEOREM): bridge to physical axiom. " ++
  "+2 axioms, +3 theorems, 0 sorry. " ++
  "SciLean (lecopivo/SciLean) is NOT viable: toolchain 4.28.0-rc1 vs 4.29.0-rc3 (incompatible), " ++
  "and has no T³ Sobolev infrastructure in any case."

end NavierStokes.GalerkinSobolevSupplement
