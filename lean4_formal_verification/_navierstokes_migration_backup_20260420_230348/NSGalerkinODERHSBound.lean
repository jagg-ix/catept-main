import NavierStokes.Galerkin.NSGalerkinSplittingLemmata

/-!
# Stage 199 — NSGalerkinODERHSBound: Galerkin ODE Right-Hand Side Energy Bound

Proves that the Galerkin ODE right-hand side
  `G(u) = galerkinConvection basis u u + viscousDamping basis ν u`
satisfies an explicit squared-ℓ² norm bound in terms of the energy E₀ and viscosity ν.

## Main results (0 new axioms)

1. **`viscousDamping_normSqC`** — Per-mode: `normSqC(viscousDamping u i) = (ν·k²_i)² · normSqC(u i)`
2. **`viscousDamping_normSqC_le`** — Per-mode: `≤ ν² · galerkinN^4 · normSqC(u i)`
3. **`viscousDamping_normSq_le`** — Total: `coeffNormSq(viscousDamping u) ≤ ν² · galerkinN^4 · coeffNormSq u`
4. **`viscousDamping_normSq_bound`** — Energy-gated: `≤ ν² · galerkinN^4 · E₀`
5. **`galerkinConvection_normSq_bound`** — `coeffNormSq(B(u,u)) ≤ C_K · E₀²`
6. **`galerkinODE_rhs_normSq_bound`** — `coeffNormSq(G(u)) ≤ 2·(C_K·E₀² + ν²·galerkinN^4·E₀)`

## Role in the proof chain

These bounds provide the explicit ODE Taylor constant that motivates
`galerkin_ode_taylor_remainder` (Stage 198D): the O(h^4) splitting error
arises from the BCH commutator `[e^{hA}, e^{hB}]`, which is proportional
to `h^2·‖[A,B]‖ ≤ h^2·‖A‖·‖B‖`.  Stage 199 bounds `‖A‖` (viscous) and
`‖B‖` (convective) explicitly, confirming the order-of-magnitude validity
of `(C_K·E₀ + ν)^2 · h^4`.

## Net counts

  - New defs:     1  (galerkinODE_rhs)
  - New axioms:   0
  - New theorems: 6  (viscousDamping_normSqC, viscousDamping_normSqC_le,
                      viscousDamping_normSq_le, viscousDamping_normSq_bound,
                      galerkinConvection_normSq_bound,
                      galerkinODE_rhs_normSq_bound)
  - sorry:        0
  - warnings:     0
-/

set_option maxHeartbeats 400000

namespace NavierStokes.GalerkinODERHSBound

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge   -- galerkinN
open NavierStokes.GalerkinComplexModel    -- CRat, CoeffC, normSqC, waveVecMag2
open NavierStokes.GalerkinConvection      -- GalerkinBasis, viscousDamping, galerkinConvection
open NavierStokes.GalerkinConvergence     -- coeffNormSq, coeffNormSq_nonneg
open NavierStokes.GalerkinConvDef         -- standardTriadK, galerkinConvDef, galerkinConvDef_is_galerkinConvection
open NavierStokes.GalerkinSplittingLemmata -- triadKernelBound, triadKernelBound_nonneg, galerkinConvDef_normSq_le

/-! ## 1. Viscous damping per-mode norm (exact equality) -/

/-- **Per-mode viscous damping norm** — exact equality.

    `normSqC(viscousDamping basis ν u i) = (ν · waveVecMag2(wvec i))² · normSqC(u i)`

    Proof: `viscousDamping i = (−ν·k²·re, −ν·k²·im)`, so
    `normSqC = (ν·k²)² · re² + (ν·k²)² · im² = (ν·k²)² · normSqC(u i)`. -/
theorem viscousDamping_normSqC {N : Nat} (basis : GalerkinBasis N)
    (ν : Rat) (u : CoeffC N) (i : Fin N) :
    normSqC (viscousDamping basis ν u i) =
    (ν * waveVecMag2 (basis.wvec i)) ^ 2 * normSqC (u i) := by
  simp only [viscousDamping, normSqC, CRat.re, CRat.im]
  ring

/-! ## 2. Viscous damping per-mode bound -/

/-- **Per-mode viscous damping bound**: `normSqC(viscousDamping u i) ≤ ν² · galerkinN^4 · normSqC(u i)`.

    Proof: `waveVecMag2(wvec i) ≤ galerkinN^2` (from `basis.freq_le`) →
    `(ν · k²_i)² ≤ ν² · galerkinN^4`  →  multiply both sides by `normSqC(u i) ≥ 0`. -/
theorem viscousDamping_normSqC_le {N : Nat} (basis : GalerkinBasis N)
    (ν : Rat) (hν : 0 ≤ ν) (u : CoeffC N) (i : Fin N) :
    normSqC (viscousDamping basis ν u i) ≤
    ν ^ 2 * (galerkinN : Rat) ^ 4 * normSqC (u i) := by
  rw [viscousDamping_normSqC]
  have hk    : waveVecMag2 (basis.wvec i) ≤ (galerkinN : Rat) ^ 2 := basis.freq_le i
  have hk_nn : (0 : Rat) ≤ waveVecMag2 (basis.wvec i) := waveVecMag2_nonneg _
  have hgN   : (0 : Rat) ≤ galerkinN := by norm_num [galerkinN]
  -- (ν · k²_i)^2 ≤ ν^2 · galerkinN^4
  have h_prod_le : ν * waveVecMag2 (basis.wvec i) ≤ ν * (galerkinN : Rat) ^ 2 :=
    mul_le_mul_of_nonneg_left hk hν
  have h_prod_nn : (0 : Rat) ≤ ν * waveVecMag2 (basis.wvec i) := mul_nonneg hν hk_nn
  have h_sq_le : (ν * waveVecMag2 (basis.wvec i)) ^ 2 ≤ (ν * (galerkinN : Rat) ^ 2) ^ 2 :=
    pow_le_pow_left₀ h_prod_nn h_prod_le 2
  have h_rhs : (ν * (galerkinN : Rat) ^ 2) ^ 2 = ν ^ 2 * (galerkinN : Rat) ^ 4 := by ring
  exact mul_le_mul_of_nonneg_right (h_rhs ▸ h_sq_le) (normSqC_nonneg _)

/-! ## 3. Total viscous damping norm bound -/

/-- **Total viscous damping bound**: `coeffNormSq(viscousDamping basis ν u) ≤ ν² · galerkinN^4 · coeffNormSq u`.

    Proof: sum the per-mode bound over all modes, then pull the constant outside. -/
theorem viscousDamping_normSq_le {N : Nat} (basis : GalerkinBasis N)
    (ν : Rat) (hν : 0 ≤ ν) (u : CoeffC N) :
    coeffNormSq (viscousDamping basis ν u) ≤
    ν ^ 2 * (galerkinN : Rat) ^ 4 * coeffNormSq u := by
  simp only [coeffNormSq]
  calc ∑ i : Fin N, normSqC (viscousDamping basis ν u i)
      ≤ ∑ i : Fin N, (ν ^ 2 * (galerkinN : Rat) ^ 4 * normSqC (u i)) :=
          Finset.sum_le_sum (fun i _ => viscousDamping_normSqC_le basis ν hν u i)
    _ = ν ^ 2 * (galerkinN : Rat) ^ 4 * ∑ i : Fin N, normSqC (u i) := by
          rw [← Finset.mul_sum]

/-! ## 4. Energy-gated viscous damping bound -/

/-- **Energy-gated viscous bound**: `coeffNormSq(viscousDamping u) ≤ ν² · galerkinN^4 · E₀`
    when `coeffNormSq u ≤ E₀`.

    Proof: apply `viscousDamping_normSq_le` then `mul_le_mul_of_nonneg_left hu`. -/
theorem viscousDamping_normSq_bound {N : Nat} (basis : GalerkinBasis N)
    (ν E₀ : Rat) (hν : 0 ≤ ν) (u : CoeffC N) (hu : coeffNormSq u ≤ E₀) :
    coeffNormSq (viscousDamping basis ν u) ≤ ν ^ 2 * (galerkinN : Rat) ^ 4 * E₀ :=
  le_trans (viscousDamping_normSq_le basis ν hν u)
    (mul_le_mul_of_nonneg_left hu
      (mul_nonneg (pow_nonneg hν 2)
        (pow_nonneg (by norm_num [galerkinN] : (0 : Rat) ≤ galerkinN) 4)))

/-! ## 5. Convective term energy bound -/

/-- **Convective term energy bound**: `coeffNormSq(B(u,u)) ≤ C_K · E₀²`
    when `coeffNormSq u ≤ E₀`.

    Proof:
    1. Identify `galerkinConvection = galerkinConvDef (standardTriadK basis)` (pointwise).
    2. Apply `galerkinConvDef_normSq_le` to get `≤ C_K · (coeffNormSq u)²`.
    3. Chain with `E₀² ≤ E₀^2` and `coeffNormSq u ≤ E₀` via `mul_le_mul`. -/
theorem galerkinConvection_normSq_bound {N : Nat} (basis : GalerkinBasis N)
    (E₀ : Rat) (u : CoeffC N) (hu : coeffNormSq u ≤ E₀) :
    coeffNormSq (fun i => galerkinConvection basis u u i) ≤
    triadKernelBound (standardTriadK basis) * E₀ ^ 2 := by
  -- Step 1: rewrite galerkinConvection as galerkinConvDef via identification
  have hid : (fun i => galerkinConvection basis u u i) =
      fun i => galerkinConvDef (standardTriadK basis) u u i :=
    funext fun i => (galerkinConvDef_is_galerkinConvection basis u u i).symm
  rw [hid]
  -- Step 2: apply the bilinear Cauchy-Schwarz bound
  have hcs := galerkinConvDef_normSq_le (standardTriadK basis) u u
  -- hcs : coeffNormSq(B(u,u)) ≤ C_K * coeffNormSq(u) * coeffNormSq(u)
  have hnn : (0 : Rat) ≤ coeffNormSq u := coeffNormSq_nonneg u
  have hu2 : coeffNormSq u * coeffNormSq u ≤ E₀ ^ 2 := by
    nlinarith [sq_nonneg (E₀ - coeffNormSq u)]
  have hC_nn := triadKernelBound_nonneg (standardTriadK basis)
  calc coeffNormSq (fun i => galerkinConvDef (standardTriadK basis) u u i)
      ≤ triadKernelBound (standardTriadK basis) * coeffNormSq u * coeffNormSq u := hcs
    _ = triadKernelBound (standardTriadK basis) * (coeffNormSq u * coeffNormSq u) := by ring
    _ ≤ triadKernelBound (standardTriadK basis) * E₀ ^ 2 :=
          mul_le_mul_of_nonneg_left hu2 hC_nn

/-! ## 6. Galerkin ODE right-hand side -/

/-- The Galerkin ODE right-hand side: convective + viscous forcing. -/
noncomputable def galerkinODE_rhs {N : Nat} (basis : GalerkinBasis N) (ν : Rat)
    (u : CoeffC N) : CoeffC N :=
  fun i => galerkinConvection basis u u i + viscousDamping basis ν u i

/-! ## 7. ODE RHS energy bound -/

/-- **Galerkin ODE RHS squared norm bound** — 0 new axioms.

    For `coeffNormSq u ≤ E₀`:
      `coeffNormSq(G(u)) ≤ 2 · (C_K · E₀² + ν² · galerkinN^4 · E₀)`

    Proof:
    1. **Triangle** `|a+b|² ≤ 2|a|² + 2|b|²` (from `0 ≤ |a-b|²`; nlinarith mode-wise)
    2. **Convective** `coeffNormSq(B(u,u)) ≤ C_K · E₀²`  (Theorem 5)
    3. **Viscous** `coeffNormSq(viscousDamping u) ≤ ν² · galerkinN^4 · E₀`  (Theorem 4)

    This provides an explicit constant for the ODE Taylor expansion supporting
    `galerkin_ode_taylor_remainder` (Stage 198D): the BCH commutator bound gives
    `(C_K·E₀ + ν)^2 · h^4`, consistent with G's component norms above. -/
theorem galerkinODE_rhs_normSq_bound {N : Nat} (basis : GalerkinBasis N)
    (ν E₀ : Rat) (hν : 0 ≤ ν) (u : CoeffC N) (hu : coeffNormSq u ≤ E₀) :
    coeffNormSq (galerkinODE_rhs basis ν u) ≤
    2 * (triadKernelBound (standardTriadK basis) * E₀ ^ 2 +
         ν ^ 2 * (galerkinN : Rat) ^ 4 * E₀) := by
  -- Step 1: triangle inequality |a+b|² ≤ 2|a|² + 2|b|²  (per mode, then sum)
  have htri : coeffNormSq (galerkinODE_rhs basis ν u) ≤
      2 * coeffNormSq (fun i => galerkinConvection basis u u i) +
      2 * coeffNormSq (viscousDamping basis ν u) := by
    simp only [galerkinODE_rhs, coeffNormSq]
    -- mode-wise triangle
    have hmode : ∀ i : Fin N,
        normSqC (galerkinConvection basis u u i + viscousDamping basis ν u i) ≤
        2 * normSqC (galerkinConvection basis u u i) +
        2 * normSqC (viscousDamping basis ν u i) := fun i => by
      simp only [normSqC, CRat.re, CRat.im, Prod.fst_add, Prod.snd_add]
      nlinarith [sq_nonneg ((galerkinConvection basis u u i).1 -
                            (viscousDamping basis ν u i).1),
                 sq_nonneg ((galerkinConvection basis u u i).2 -
                            (viscousDamping basis ν u i).2)]
    -- sum the mode-wise inequalities then split the sums
    have hsum := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) => hmode i)
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum] at hsum ⊢
    linarith
  -- Step 2: convective bound
  have hconv := galerkinConvection_normSq_bound basis E₀ u hu
  -- Step 3: viscous bound
  have hvisc := viscousDamping_normSq_bound basis ν E₀ hν u hu
  -- Combine
  linarith

def stage199Summary : String :=
  "Stage 199: NSGalerkinODERHSBound — Galerkin ODE RHS energy bound. " ++
  "viscousDamping_normSqC: THEOREM (exact, ring: normSqC(visc u i) = (ν*k²)^2 * normSqC(u i)). " ++
  "viscousDamping_normSqC_le: THEOREM (≤ ν^2*galerkinN^4*normSqC(u i), freq_le+pow_le_pow_left₀). " ++
  "viscousDamping_normSq_le: THEOREM (total, Finset.sum_le_sum + Finset.mul_sum). " ++
  "viscousDamping_normSq_bound: THEOREM (energy-gated, le_trans + mul_le_mul_of_nonneg_left). " ++
  "galerkinConvection_normSq_bound: THEOREM (B(u,u)≤C_K*E₀², " ++
    "galerkinConvDef_is_galerkinConvection + galerkinConvDef_normSq_le + nlinarith). " ++
  "galerkinODE_rhs: DEF (convective + viscous ODE RHS). " ++
  "galerkinODE_rhs_normSq_bound: THEOREM (|G(u)|²≤2*(C_K*E₀²+ν²*galerkinN^4*E₀), " ++
    "triangle+conv+visc+linarith). " ++
  "Net: +1 def, +0 axioms, +6 theorems, 0 sorry. " ++
  "Epistemic role: explicit ODE Taylor constant supporting galerkin_ode_taylor_remainder (198D)."

end NavierStokes.GalerkinODERHSBound
