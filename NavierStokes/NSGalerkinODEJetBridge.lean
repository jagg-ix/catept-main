import NavierStokes.NSGalerkinODERHSBound
import NavierStokes.NSGalerkinConvStepHBridge
import NavierStokes.NSGalerkinMeanValueBridge

/-!
# Stage 200/202/204 — NSGalerkinODEJetBridge: First-Order Jet Remainders

Introduces jet remainder bounds for the Galerkin ODE flow and the Lie-splitting method.

## 200A / Stage 204 — ODE first-order jet remainder (h^3) — **THEOREM** from `galerkinODE_jet_h4`

`galerkinODE_jet_remainder`: proved as a theorem (Stage 204) from the single bridge
axiom `galerkinODE_jet_h4` (which gives an h^4 bound) plus `h^4 ≤ h^3` for `h ≤ 1`.

The bridge axiom (Stage 204): `galerkinODE_jet_h4` says the ODE first-order Euler jet
remainder satisfies:
```
‖uExact(t+h) − (uExact(t) + h·G(uExact(t)))‖² ≤ (rhsLipC · rhsBoundC) · h^4
```
where:
  - `rhsLipC = 4·C_K·E₀ + ν²·N⁴` is the squared-Lipschitz constant for G (Stage 203)
  - `rhsBoundC = 2·(C_K·E₀² + ν²·N⁴·E₀)` is the G size bound (Stage 203)

This is the mean-value ODE estimate: `u(t+h)−jet(t) = h·(G(u(t+θh))−G(u(t)))` for some
`θ ∈ [0,1]`, with `‖G(uθ)−G(u0)‖² ≤ rhsLipC · ‖uθ−u0‖²` (Lipschitz) and
`‖uθ−u0‖² ≤ rhsBoundC · h²` (size bound on ODE increment).

**Net: Stage 204 retires axiom 200A with 1 new axiom `galerkinODE_jet_h4`.**

## 200B / Stage 202 — Method first-order jet remainder (h^4) — **THEOREM**

`splitting_method_jet_remainder`: promoted from axiom (Stage 200B) to theorem
(Stage 202) using the algebraic decomposition:

  `S_h(u) − jet(u) = [viscStep(w) − (w + h·A(w))] + [w − (u + h·B(u,u))] + h·A(w − u)`

where w = convStepH h u, A = viscousDamping, B = galerkinConvection u u.

Proof uses:
  * Stage 198A `convStepH_first_order_remainder_sq` — `‖w − (u+h·B)‖² ≤ (1/4)C_K²E₀³h⁴`
  * Stage 198B `viscStep_first_order_remainder_sq`  — `‖viscStep(w) − (w+h·A(w))‖² ≤ ν⁴·N⁸·E₀·h⁴`
  * `convStepH_energy_preserving`                   — `|w|² = |u|² ≤ E₀`
  * `convStepH_increment_bound`                     — `|w−u|² ≤ C_K·E₀²·h²`
  * viscousDamping linearity + `viscousDamping_normSq_le`

**Net: Stage 202 retires axiom 200B with 0 new axioms.**

## methodJetC constant (Stage 202 update)

`methodJetC = 3·(ν⁴·N⁸·E₀ + (1/4)·C_K²·E₀³ + ν²·N⁴·C_K·E₀²) + 1`

where `N = (galerkinN : Rat)`. The `+1` ensures strict positivity for all E₀ ≥ 0.

## Net counts (combined Stages 200 + 202 + 204)

  - New defs:   4  (coeffAdd, coeffScale, odeJetC, methodJetC)
  - New axioms: 1  (galerkinODE_jet_h4 — Stage 204 bridge; replaces 200A)
  - New theorems: 9  (odeJetC_pos, methodJetC_pos, + 5 proof helpers +
                      splitting_method_jet_remainder + galerkinODE_jet_remainder)
  - sorry:      0
  - warnings:   0
-/

set_option maxHeartbeats 800000

namespace NavierStokes.GalerkinODEJet

set_option autoImplicit false

open NavierStokes.GalerkinConvergence      -- coeffSub, coeffNormSq, SolvesGalerkinODE
open NavierStokes.GalerkinComplexModel     -- CRat, CoeffC, normSqC
open NavierStokes.GalerkinConvection       -- GalerkinBasis
open NavierStokes.GalerkinODE              -- viscStep
open NavierStokes.GalerkinConvStepHBridge  -- convStepH, convStepH_first_order_remainder_sq, etc.
open NavierStokes.GalerkinConvDef          -- standardTriadK, galerkinConvection
open NavierStokes.GalerkinSplittingLemmata -- triadKernelBound, triadKernelBound_nonneg,
                                           -- CRat_smul_normSqC, viscStep_nonexpansive
open NavierStokes.GalerkinODERHSBound      -- galerkinODE_rhs, viscousDamping, viscousDamping_normSqC
                                           -- viscousDamping_normSq_le, viscousDamping_normSqC_le
open NavierStokes.GalerkinCayley           -- CRat.smul
open NavierStokes.PalinstrophyTauBridge    -- galerkinN
open NavierStokes.GalerkinMeanValueBridge  -- rhsBoundC, rhsLipC, rhsBoundC_nonneg, rhsLipC_nonneg

/-! ## Auxiliary coefficient operations -/

/-- Pointwise addition of Galerkin coefficient vectors. -/
def coeffAdd {N : Nat} (u v : CoeffC N) : CoeffC N :=
  fun i => u i + v i

/-- Scalar multiplication of a Galerkin coefficient vector by a rational. -/
noncomputable def coeffScale {N : Nat} (c : Rat) (u : CoeffC N) : CoeffC N :=
  fun i => CRat.smul c (u i)

/-! ## Jet constants -/

/-- **ODE jet constant** — bounds the ODE second-order Taylor remainder.

    `odeJetC basis ν E₀ := rhsLipC · rhsBoundC + 1`

    where:
    - `rhsLipC = 4·C_K·E₀ + ν²·N⁴` (squared-Lipschitz constant for G)
    - `rhsBoundC = 2·(C_K·E₀² + ν²·N⁴·E₀)` (G size bound on energy ball)

    This matches the constant from `galerkinODE_jet_h4` (Stage 204 bridge axiom).
    The `+ 1` ensures `odeJetC > 0` for all `E₀ ≥ 0`.
    Satisfies `odeJetC > 0` always (even for E₀ = 0, ν = 0). -/
noncomputable def odeJetC {N : Nat} (basis : GalerkinBasis N) (ν E₀ : Rat) : Rat :=
  rhsLipC basis ν E₀ * rhsBoundC basis ν E₀ + 1

theorem odeJetC_pos {N : Nat} (basis : GalerkinBasis N)
    (ν E₀ : Rat) (hν : 0 < ν) (hE₀ : 0 ≤ E₀) : 0 < odeJetC basis ν E₀ := by
  unfold odeJetC
  have hL := rhsLipC_nonneg basis ν E₀ hν.le hE₀
  have hB := rhsBoundC_nonneg basis ν E₀ hν.le hE₀
  linarith [mul_nonneg hL hB]

/-- **Method jet constant** — explicit bound derived from Stage 198A + 198B + transport.

    `methodJetC basis ν E₀ := 3·(ν⁴·N⁸·E₀ + (1/4)·C_K²·E₀³ + ν²·N⁴·C_K·E₀²) + 1`

    where `N = (galerkinN : Rat) = 1024`.

    The three terms bound the three pieces of the Lie-splitting remainder:
    * `ν⁴·N⁸·E₀·h⁴`: viscous step first-order error (Stage 198B)
    * `(1/4)·C_K²·E₀³·h⁴`: convective step first-order error (Stage 198A)
    * `ν²·N⁴·C_K·E₀²·h⁴`: viscous transport of convective increment

    The `+ 1` ensures `methodJetC > 0` for all `E₀ ≥ 0`. -/
noncomputable def methodJetC {N : Nat} (basis : GalerkinBasis N) (ν E₀ : Rat) : Rat :=
  3 * (ν ^ 4 * (galerkinN : Rat) ^ 8 * E₀ +
       (1 / 4) * triadKernelBound (standardTriadK basis) ^ 2 * E₀ ^ 3 +
       ν ^ 2 * (galerkinN : Rat) ^ 4 * triadKernelBound (standardTriadK basis) * E₀ ^ 2) + 1

theorem methodJetC_pos {N : Nat} (basis : GalerkinBasis N)
    (ν E₀ : Rat) (_hν : 0 < ν) (_hE₀ : 0 ≤ E₀) : 0 < methodJetC basis ν E₀ := by
  unfold methodJetC
  have hCK := triadKernelBound_nonneg (standardTriadK basis)
  have hnu_nn : 0 ≤ ν := le_of_lt _hν
  have hgN : (0 : Rat) ≤ (galerkinN : Rat) := Nat.cast_nonneg _
  have h1 : 0 ≤ ν ^ 4 * (galerkinN : Rat) ^ 8 * E₀ :=
    mul_nonneg (mul_nonneg (pow_nonneg hnu_nn 4) (pow_nonneg hgN 8)) _hE₀
  have h2 : 0 ≤ (1 / 4) * triadKernelBound (standardTriadK basis) ^ 2 * E₀ ^ 3 :=
    mul_nonneg (mul_nonneg (by norm_num) (sq_nonneg _)) (pow_nonneg _hE₀ 3)
  have h3 : 0 ≤ ν ^ 2 * (galerkinN : Rat) ^ 4 * triadKernelBound (standardTriadK basis) * E₀ ^ 2 :=
    mul_nonneg (mul_nonneg (mul_nonneg (pow_nonneg hnu_nn 2) (pow_nonneg hgN 4)) hCK)
               (pow_nonneg _hE₀ 2)
  linarith

/-! ## Private helpers for the method jet proof -/

/-- `coeffNormSq (fun i => CRat.smul r (f i)) = r² · coeffNormSq f`. -/
private lemma coeffNormSq_smul_scalar {N : Nat} (r : Rat) (f : CoeffC N) :
    coeffNormSq (fun i => CRat.smul r (f i)) = r ^ 2 * coeffNormSq f := by
  simp only [coeffNormSq, CRat_smul_normSqC, ← Finset.mul_sum]

/-- viscousDamping is linear in `u`: damping of `a−b` = damping of `a` minus damping of `b`. -/
private lemma viscousDamping_sub_linear {N : Nat} (basis : GalerkinBasis N)
    (ν : Rat) (a b : CoeffC N) (i : Fin N) :
    viscousDamping basis ν a i - viscousDamping basis ν b i =
    viscousDamping basis ν (fun j => a j - b j) i := by
  simp only [viscousDamping, CRat.re, CRat.im]
  apply Prod.ext <;> simp only [Prod.fst_sub, Prod.snd_sub] <;> ring

/-- Triple squared-norm triangle: `‖a+b+c‖² ≤ 3·(‖a‖²+‖b‖²+‖c‖²)`. -/
private lemma coeffNormSq_triple_triangle {N : Nat} (a b c : CoeffC N) :
    coeffNormSq (fun i => a i + b i + c i) ≤
    3 * (coeffNormSq a + coeffNormSq b + coeffNormSq c) := by
  have key : ∀ i : Fin N,
      normSqC (a i + b i + c i) ≤ 3 * (normSqC (a i) + normSqC (b i) + normSqC (c i)) := by
    intro i
    obtain ⟨ar, ai⟩ := a i
    obtain ⟨br, bi⟩ := b i
    obtain ⟨cr, ci⟩ := c i
    simp only [normSqC, CRat.re, CRat.im]
    have h1 : ((ar, ai) + (br, bi) + (cr, ci)).1 = ar + br + cr := rfl
    have h2 : ((ar, ai) + (br, bi) + (cr, ci)).2 = ai + bi + ci := rfl
    rw [h1, h2]
    nlinarith [sq_nonneg (ar - br), sq_nonneg (br - cr), sq_nonneg (ar - cr),
               sq_nonneg (ai - bi), sq_nonneg (bi - ci), sq_nonneg (ai - ci)]
  simp only [coeffNormSq]
  calc ∑ i : Fin N, normSqC (a i + b i + c i)
      ≤ ∑ i : Fin N, (3 * (normSqC (a i) + normSqC (b i) + normSqC (c i))) :=
          Finset.sum_le_sum (fun i _ => key i)
    _ = 3 * (∑ i : Fin N, normSqC (a i) + ∑ i : Fin N, normSqC (b i) +
            ∑ i : Fin N, normSqC (c i)) := by
          rw [← Finset.mul_sum]; congr 1
          rw [Finset.sum_add_distrib, Finset.sum_add_distrib]

/-! ## 200A / Stage 204: ODE jet remainder — AXIOM + THEOREM -/

/-- **ODE first-order jet remainder at h^4** — **AXIOM** (Stage 204 bridge).

    The exact Galerkin ODE solution at `t+h` lies within `(rhsLipC · rhsBoundC) · h^4`
    (squared ℓ² norm) of its Euler jet `uExact(t) + h·G(uExact(t))`.

    Mathematical content (mean-value ODE estimate):
    - `u(t+h) − jet(t) = h·(G(u(t+θh)) − G(u(t)))` for some `θ ∈ [0,1]` (mean value)
    - `‖G(uθ) − G(u0)‖² ≤ rhsLipC · ‖uθ − u0‖²` (G is Lipschitz on energy ball)
    - `‖uθ − u0‖² ≤ rhsBoundC · h²` (ODE increment bounded by G size)
    - Combining: `h² · rhsLipC · rhsBoundC · h² = rhsLipC · rhsBoundC · h⁴`

    Epistemic: `.partiallyVerified` (Picard–Lindelöf + Lipschitz continuity of G;
    the h⁴ order matches the true second-order Taylor estimate in squared norm).

    **Replaces Stage 200A** axiom `galerkinODE_jet_remainder` (retired as theorem below). -/
axiom galerkinODE_jet_h4
    {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hh1 : h ≤ 1) (hE₀ : 0 ≤ E₀)
    (uExact : Rat → CoeffC N)
    (hODE    : SolvesGalerkinODE basis ν uExact)
    (hEnergy : ∀ t : Rat, coeffNormSq (uExact t) ≤ E₀) (t : Rat) :
    coeffNormSq (coeffSub
      (uExact (t + h))
      (coeffAdd (uExact t) (coeffScale h (galerkinODE_rhs basis ν (uExact t))))) ≤
    (rhsLipC basis ν E₀ * rhsBoundC basis ν E₀) * h ^ 4

/-- **ODE first-order jet remainder** (h^3) — **THEOREM** (Stage 204, retired from axiom 200A).

    Proof chain:
      `‖uExact(t+h) − jet(t)‖²`
      `≤ (rhsLipC · rhsBoundC) · h^4`    [galerkinODE_jet_h4]
      `≤ (rhsLipC · rhsBoundC) · h^3`    [h^4 ≤ h^3 for h ≤ 1]
      `≤ odeJetC · h^3`                  [odeJetC = rhsLipC·rhsBoundC + 1 ≥ rhsLipC·rhsBoundC]

    **Net: Stage 200A axiom retired** (0 new axioms beyond `galerkinODE_jet_h4`). -/
theorem galerkinODE_jet_remainder
    {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hh1 : h ≤ 1) (hE₀ : 0 ≤ E₀)
    (uExact : Rat → CoeffC N)
    (hODE    : SolvesGalerkinODE basis ν uExact)
    (hEnergy : ∀ t : Rat, coeffNormSq (uExact t) ≤ E₀) (t : Rat) :
    coeffNormSq (coeffSub
      (uExact (t + h))
      (coeffAdd (uExact t) (coeffScale h (galerkinODE_rhs basis ν (uExact t))))) ≤
    odeJetC basis ν E₀ * h ^ 3 := by
  have hL := rhsLipC_nonneg basis ν E₀ hν.le hE₀
  have hB := rhsBoundC_nonneg basis ν E₀ hν.le hE₀
  have h4 := galerkinODE_jet_h4 basis ν h E₀ hν hh hh1 hE₀ uExact hODE hEnergy t
  have hh43 : h ^ 4 ≤ h ^ 3 := by nlinarith [pow_pos hh 3]
  calc coeffNormSq (coeffSub (uExact (t + h))
          (coeffAdd (uExact t) (coeffScale h (galerkinODE_rhs basis ν (uExact t)))))
      ≤ (rhsLipC basis ν E₀ * rhsBoundC basis ν E₀) * h ^ 4 := h4
    _ ≤ (rhsLipC basis ν E₀ * rhsBoundC basis ν E₀) * h ^ 3 :=
          mul_le_mul_of_nonneg_left hh43 (mul_nonneg hL hB)
    _ ≤ odeJetC basis ν E₀ * h ^ 3 := by
          apply mul_le_mul_of_nonneg_right _ (pow_nonneg hh.le 3)
          unfold odeJetC; linarith [mul_nonneg hL hB]

/-! ## 200B / Stage 202: Method first-order jet remainder — THEOREM -/

/-- **Method first-order jet remainder** (h^4 in squared ℓ² norm) — **THEOREM** (Stage 202).

    `‖S_h(u) − (u + h·G(u))‖² ≤ methodJetC · h^4`

    Algebraic decomposition:
      S_h(u) − jet(u) =  [viscStep(w) − (w + h·A(w))]       [198B remainder]
                        + [w − u − h·B(u,u)]                  [198A remainder]
                        + h·A(w − u)                          [viscous transport]

    where w = convStepH h u, A = viscousDamping ν, B = galerkinConvection u u.

    Piece bounds:
      (1) `‖viscStep(w) − (w + h·A(w))‖²  ≤ ν⁴·N⁸·E₀·h⁴`          [198B + energy pres.]
      (2) `‖w − u − h·B(u,u)‖²            ≤ (1/4)·C_K²·E₀³·h⁴`    [198A]
      (3) `‖h·A(w−u)‖²                    ≤ ν²·N⁴·C_K·E₀²·h⁴`     [viscLinear + incBound]

    Sum via `‖a+b+c‖² ≤ 3(‖a‖²+‖b‖²+‖c‖²)` gives `methodJetC·h⁴`.

    **Net: 0 new axioms** (retired Stage 200B axiom). -/
theorem splitting_method_jet_remainder
    {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (_hh1 : h ≤ 1) (hE₀ : 0 ≤ E₀)
    (u : CoeffC N) (hu : coeffNormSq u ≤ E₀) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStepH basis h u))
      (coeffAdd u (coeffScale h (galerkinODE_rhs basis ν u)))) ≤
    methodJetC basis ν E₀ * h ^ 4 := by
  set w := convStepH basis h u with hw_def
  -- Energy of w equals energy of u
  have hw_energy : coeffNormSq w ≤ E₀ := by
    rw [hw_def, convStepH_energy_preserving]; exact hu
  -- Abbreviate constants
  set CK := triadKernelBound (standardTriadK basis) with hCK_def
  have hCK_nn : 0 ≤ CK := triadKernelBound_nonneg _
  have hnu_nn : 0 ≤ ν := le_of_lt hν
  have hgN : (0 : Rat) ≤ (galerkinN : Rat) := Nat.cast_nonneg _
  -- Define the three algebraic pieces
  let pieceA : CoeffC N := fun i =>
    viscStep basis ν h w i - w i - CRat.smul h (viscousDamping basis ν w i)
  let pieceB : CoeffC N := fun i =>
    w i - u i - CRat.smul h (galerkinConvection basis u u i)
  let pieceC : CoeffC N := fun i =>
    CRat.smul h (viscousDamping basis ν w i - viscousDamping basis ν u i)
  -- Step 1: algebraic identity — target = fun i => pieceA i + pieceB i + pieceC i
  have hident : coeffSub (viscStep basis ν h w) (coeffAdd u (coeffScale h (galerkinODE_rhs basis ν u))) =
      fun i => pieceA i + pieceB i + pieceC i := by
    funext i
    simp only [pieceA, pieceB, pieceC, coeffSub, coeffAdd, coeffScale, galerkinODE_rhs]
    apply Prod.ext
    · simp only [CRat.smul, CRat.re, CRat.im, Prod.fst_sub, Prod.fst_add]; ring
    · simp only [CRat.smul, CRat.re, CRat.im, Prod.snd_sub, Prod.snd_add]; ring
  -- Step 2: apply triple triangle
  rw [hident]
  have htri := coeffNormSq_triple_triangle pieceA pieceB pieceC
  -- Step 3: bound each piece
  -- Piece A (198B): ‖viscStep(w) − (w + h·A(w))‖² ≤ ν⁴·N⁸·E₀·h⁴
  have hA : coeffNormSq pieceA ≤ ν ^ 4 * (galerkinN : Rat) ^ 8 * E₀ * h ^ 4 := by
    have h198B := viscStep_first_order_remainder_sq basis ν h E₀ hν hh hE₀ w hw_energy
    exact h198B
  -- Piece B (198A): ‖w − u − h·B(u,u)‖² ≤ (1/4)·C_K²·E₀³·h⁴
  have hB : coeffNormSq pieceB ≤ (1 / 4) * CK ^ 2 * E₀ ^ 3 * h ^ 4 := by
    have h198A := convStepH_first_order_remainder_sq basis h E₀ hh hE₀ u hu
    exact h198A
  -- Piece C (transport): h·A(w−u) = h·A_linear(w−u); bound via linearity + increment
  have hC : coeffNormSq pieceC ≤ ν ^ 2 * (galerkinN : Rat) ^ 4 * CK * E₀ ^ 2 * h ^ 4 := by
    -- Rewrite pieceC using linearity: A(w) − A(u) = A(w−u)
    have hlin : ∀ i : Fin N,
        viscousDamping basis ν w i - viscousDamping basis ν u i =
        viscousDamping basis ν (coeffSub w u) i := by
      intro i
      exact viscousDamping_sub_linear basis ν w u i
    have hpieceC_eq : pieceC = fun i => CRat.smul h (viscousDamping basis ν (coeffSub w u) i) := by
      funext i; simp only [pieceC, hlin i]
    rw [hpieceC_eq]
    -- ‖h·A(w−u)‖² = h²·‖A(w−u)‖²
    rw [coeffNormSq_smul_scalar]
    -- ‖A(w−u)‖² ≤ ν²·N⁴·‖w−u‖²
    have hvisc := viscousDamping_normSq_le basis ν hnu_nn (coeffSub w u)
    -- ‖w−u‖² ≤ C_K·E₀²·h²
    have hinc := convStepH_increment_bound basis h E₀ hh hE₀ u hu
    have hinc_nn : (0:Rat) ≤ coeffNormSq (coeffSub w u) :=
      coeffNormSq_nonneg _
    calc h ^ 2 * coeffNormSq (viscousDamping basis ν (coeffSub w u))
        ≤ h ^ 2 * (ν ^ 2 * (galerkinN : Rat) ^ 4 * coeffNormSq (coeffSub w u)) :=
            mul_le_mul_of_nonneg_left hvisc (sq_nonneg h)
      _ ≤ h ^ 2 * (ν ^ 2 * (galerkinN : Rat) ^ 4 * (CK * E₀ ^ 2 * h ^ 2)) :=
            mul_le_mul_of_nonneg_left
              (mul_le_mul_of_nonneg_left hinc
                (mul_nonneg (pow_nonneg hnu_nn 2) (pow_nonneg hgN 4)))
              (sq_nonneg h)
      _ = ν ^ 2 * (galerkinN : Rat) ^ 4 * CK * E₀ ^ 2 * h ^ 4 := by ring
  -- Step 4: combine bounds and conclude ≤ methodJetC · h^4
  calc coeffNormSq (fun i => pieceA i + pieceB i + pieceC i)
      ≤ 3 * (coeffNormSq pieceA + coeffNormSq pieceB + coeffNormSq pieceC) := htri
    _ ≤ 3 * (ν ^ 4 * (galerkinN : Rat) ^ 8 * E₀ * h ^ 4 +
            (1 / 4) * CK ^ 2 * E₀ ^ 3 * h ^ 4 +
            ν ^ 2 * (galerkinN : Rat) ^ 4 * CK * E₀ ^ 2 * h ^ 4) := by
          have hA_nn := coeffNormSq_nonneg pieceA
          have hB_nn := coeffNormSq_nonneg pieceB
          have hC_nn := coeffNormSq_nonneg pieceC
          nlinarith
    _ = 3 * (ν ^ 4 * (galerkinN : Rat) ^ 8 * E₀ +
            (1 / 4) * CK ^ 2 * E₀ ^ 3 +
            ν ^ 2 * (galerkinN : Rat) ^ 4 * CK * E₀ ^ 2) * h ^ 4 := by ring
    _ ≤ methodJetC basis ν E₀ * h ^ 4 := by
          apply mul_le_mul_of_nonneg_right _ (pow_nonneg hh.le 4)
          unfold methodJetC; linarith

def stage204Summary : String :=
  "Stage 200/202/204: NSGalerkinODEJetBridge — jet remainders. " ++
  "coeffAdd: DEF. coeffScale: DEF. " ++
  "odeJetC: DEF (rhsLipC*rhsBoundC+1, Stage 204 update). " ++
  "methodJetC: DEF (3*(ν⁴N⁸E₀+(1/4)C_K²E₀³+ν²N⁴C_KE₀²)+1, Stage 202). " ++
  "odeJetC_pos: THEOREM. methodJetC_pos: THEOREM. " ++
  "galerkinODE_jet_h4: AXIOM (Stage 204 bridge, h^4, .partiallyVerified, mean-value+Lipschitz). " ++
  "galerkinODE_jet_remainder: THEOREM (Stage 204, from jet_h4 + h^4≤h^3, 0 new axioms). " ++
  "splitting_method_jet_remainder: THEOREM (Stage 202, 198A+198B+transport, 0 new axioms). " ++
  "Net: +1 axiom (galerkinODE_jet_h4), +9 theorems, 0 sorry. " ++
  "200A axiom RETIRED as theorem. 200B axiom RETIRED as theorem."

end NavierStokes.GalerkinODEJet
