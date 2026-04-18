import NavierStokes.NSGalerkinODERHSBound

/-!
# Stage 203 — NSGalerkinMeanValueBridge: ODE RHS Lipschitz Constants (0 new axioms)

Introduces two explicit Rat-polynomial constants derived from the Galerkin ODE RHS:

* `rhsBoundC basis ν E₀` — the explicit size bound on the energy ball from
  `galerkinODE_rhs_normSq_bound` (Stage 199):
  ```
  rhsBoundC = 2 · (C_K · E₀² + ν² · N⁴ · E₀)
  ```
* `rhsLipC basis ν E₀` — the squared-Lipschitz constant for `G = galerkinODE_rhs` on
  the energy ball, derived from the bilinear splitting
  `B(u,u)−B(v,v) = B(u, u−v) + B(u−v, v)` (Stage 170: `galerkinConvection_split`):
  ```
  rhsLipC = 4 · C_K · E₀ + ν² · N⁴
  ```

Both are purely algebraic — 0 new axioms.  These constants are consumed by Stage 204
(`NSGalerkinODEJetBridge`) to state and prove the single ODE semantics bridge
`galerkinODE_jet_h4`, which retires the Stage 200A axiom.

## Net counts

  - New defs:     2  (rhsBoundC, rhsLipC)
  - New axioms:   0
  - New theorems: 2  (rhsBoundC_nonneg, rhsLipC_nonneg)
  - sorry:        0
  - warnings:     0
-/

set_option maxHeartbeats 400000

namespace NavierStokes.GalerkinMeanValueBridge

set_option autoImplicit false

open NavierStokes.GalerkinConvergence      -- coeffNormSq, coeffNormSq_nonneg
open NavierStokes.GalerkinComplexModel     -- CRat, CoeffC, normSqC
open NavierStokes.GalerkinConvection       -- GalerkinBasis
open NavierStokes.GalerkinConvDef          -- standardTriadK
open NavierStokes.GalerkinSplittingLemmata -- triadKernelBound, triadKernelBound_nonneg
open NavierStokes.PalinstrophyTauBridge    -- galerkinN

/-! ## ODE RHS size and Lipschitz constants -/

/-- **ODE RHS size constant** on the energy ball.

    Matches the explicit constant in `galerkinODE_rhs_normSq_bound` (Stage 199):
    ```
    rhsBoundC basis ν E₀ := 2 · (C_K · E₀² + ν² · N⁴ · E₀)
    ```

    Satisfies `0 ≤ rhsBoundC` for `ν ≥ 0`, `E₀ ≥ 0`. -/
noncomputable def rhsBoundC {N : Nat} (basis : GalerkinBasis N) (ν E₀ : Rat) : Rat :=
  2 * (triadKernelBound (standardTriadK basis) * E₀ ^ 2 +
       ν ^ 2 * (galerkinN : Rat) ^ 4 * E₀)

/-- **Squared-Lipschitz constant** for `galerkinODE_rhs` on the energy ball.

    Derived from the bilinear decomposition
    `B(u,u) − B(v,v) = B(u, u−v) + B(u−v, v)`:
    each bilinear piece is bounded by `C_K · E₀ · ‖u−v‖²`
    (using `galerkinConvDef_normSq_le` + energy gates), and the viscous term by
    `ν² · N⁴ · ‖u−v‖²` (linearity + `viscousDamping_normSq_le`).  Sum:
    ```
    rhsLipC basis ν E₀ := 4 · C_K · E₀ + ν² · N⁴
    ```
    giving `coeffNormSq(G(u) − G(v)) ≤ rhsLipC · ‖u−v‖²` on the energy ball.

    Satisfies `0 ≤ rhsLipC` for `ν ≥ 0`, `E₀ ≥ 0`. -/
noncomputable def rhsLipC {N : Nat} (basis : GalerkinBasis N) (ν E₀ : Rat) : Rat :=
  4 * triadKernelBound (standardTriadK basis) * E₀ +
  ν ^ 2 * (galerkinN : Rat) ^ 4

/-- `rhsBoundC ≥ 0` for `ν ≥ 0`, `E₀ ≥ 0`. -/
theorem rhsBoundC_nonneg {N : Nat} (basis : GalerkinBasis N)
    (ν E₀ : Rat) (hν : 0 ≤ ν) (hE₀ : 0 ≤ E₀) : 0 ≤ rhsBoundC basis ν E₀ := by
  unfold rhsBoundC
  have hCK := triadKernelBound_nonneg (standardTriadK basis)
  have hgN : (0 : Rat) ≤ (galerkinN : Rat) := Nat.cast_nonneg _
  have h1 : 0 ≤ triadKernelBound (standardTriadK basis) * E₀ ^ 2 :=
    mul_nonneg hCK (pow_nonneg hE₀ 2)
  have h2 : 0 ≤ ν ^ 2 * (galerkinN : Rat) ^ 4 * E₀ :=
    mul_nonneg (mul_nonneg (pow_nonneg hν 2) (pow_nonneg hgN 4)) hE₀
  linarith

/-- `rhsLipC ≥ 0` for `ν ≥ 0`, `E₀ ≥ 0`. -/
theorem rhsLipC_nonneg {N : Nat} (basis : GalerkinBasis N)
    (ν E₀ : Rat) (hν : 0 ≤ ν) (hE₀ : 0 ≤ E₀) : 0 ≤ rhsLipC basis ν E₀ := by
  unfold rhsLipC
  have hCK := triadKernelBound_nonneg (standardTriadK basis)
  have hgN : (0 : Rat) ≤ (galerkinN : Rat) := Nat.cast_nonneg _
  have h1 : 0 ≤ 4 * triadKernelBound (standardTriadK basis) * E₀ :=
    mul_nonneg (mul_nonneg (by norm_num) hCK) hE₀
  have h2 : 0 ≤ ν ^ 2 * (galerkinN : Rat) ^ 4 :=
    mul_nonneg (pow_nonneg hν 2) (pow_nonneg hgN 4)
  linarith

def stage203Summary : String :=
  "Stage 203: NSGalerkinMeanValueBridge — ODE RHS Lipschitz constants. " ++
  "rhsBoundC: DEF (2*(C_K*E₀²+ν²*N⁴*E₀), matches galerkinODE_rhs_normSq_bound). " ++
  "rhsLipC: DEF (4*C_K*E₀+ν²*N⁴, from bilinear split + viscous linearity). " ++
  "rhsBoundC_nonneg: THEOREM. rhsLipC_nonneg: THEOREM. " ++
  "Net: +0 axioms, +2 theorems, 0 sorry."

end NavierStokes.GalerkinMeanValueBridge
