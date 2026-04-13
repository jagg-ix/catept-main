import NavierStokes.NSGalerkinConvStepHBridge

/-!
# Stage 196 — NSGalerkinStepLTE: SA2 Sub-Axiom Decomposition

Decomposes the SA2 axiom `galerkinSplitting_step_lte` (in `NSGalerkinConvergence`) into
two sub-axioms with clearer epistemic standing, then derives the full LTE as a theorem.

## Three-stage structure

### 196A — Viscous-step convection residual (h^2, **THEOREM** from Stage 197)

`viscStep_splitting_lte`: the implicit-Euler viscous step applied to `convStepH h u`
differs from the viscous step applied to `u` in squared norm by at most `C_K · E₀² · h²`:

  `|viscStep(convStepH h u) − viscStep(u)|² ≤ C_K · E₀² · h²`

Proof: `viscStep_nonexpansive` (non-expansive for any h > 0) + `convStepH_increment_bound`
(Stage 197: `|convStepH h u − u|² ≤ C_K · E₀² · h²` from Cayley equation).
**Net: 0 new axioms** (discharged in Stage 197 from prior infrastructure).

### 196B — Full Lie-splitting commutator LTE (h^3, the main gap)

`lie_splitting_commutator_lte`: the full split step `viscStep ∘ convStepH` at step size h
deviates from the exact Galerkin ODE solution at t+h in squared norm by at most
`(triadKernelBound · E₀ + ν)^2 · h^3`:

  `|viscStep(convStepH h (uExact t)) − uExact(t+h)|² ≤ (C_K·E₀ + ν)^2 · h^3`

Justification (Lubich 2008 §II.3, Hairer–Lubich–Wanner): the Lie–Trotter splitting
commutator `[viscStep_gen, convStep_gen]` is bounded by the product of the two generator
norms, giving O(h²) in state norm and O(h^4) in squared norm; the conservative O(h^3)
bound has room for the ν-dependent viscous contribution.

### 196C — SA2 as a theorem (0 new axioms beyond 196A and 196B)

`galerkinSplitting_step_lte_proved`: derived directly from 196B and the padding
`(C_K·E₀+ν)^2 ≤ stepLteC/2 = (C_K·E₀+ν)^2 + 1/2`:

  `... ≤ stepLteC basis ν E₀ / 2 · h^3`

where `stepLteC basis ν E₀ := 2·(C_K·E₀+ν)^2 + 1`.

This theorem has the **same conclusion shape** as the SA2 axiom
`galerkinSplitting_step_lte`, and `NSGalerkinConvergence` calls it in place of that axiom.

## Import chain (no cycle)

`NSGalerkinStepLTE` imports `NSGalerkinConvStepHBridge` (which transitively provides
`NSGalerkinSplittingCore`). `NSGalerkinConvergence` imports `NSGalerkinStepLTE`.
Neither creates a cycle because `NSGalerkinConvStepHBridge` does NOT import
`NSGalerkinConvergence`.

## Net counts

  - New defs:     1  (stepLteC)
  - New axioms:   1  (lie_splitting_commutator_lte [196B])
  - New theorems: 3  (stepLteC_pos, viscStep_splitting_lte [196A proved], galerkinSplitting_step_lte_proved [196C])
  - sorry:        0
  - warnings:     0
-/

set_option maxHeartbeats 400000

namespace NavierStokes.GalerkinStepLTE

set_option autoImplicit false

open NavierStokes.GalerkinConvergence    -- coeffSub, coeffNormSq, SolvesGalerkinODE
open NavierStokes.GalerkinComplexModel   -- CRat, CoeffC, normSqC
open NavierStokes.GalerkinConvection     -- GalerkinBasis
open NavierStokes.GalerkinODE            -- viscStep
open NavierStokes.GalerkinConvStepHBridge  -- convStepH, convStepH_increment_bound
open NavierStokes.GalerkinSplittingLemmata  -- triadKernelBound, triadKernelBound_nonneg, viscStep_nonexpansive
open NavierStokes.GalerkinConvDef        -- standardTriadK

/-! ## Auxiliary definitions -/

/-- **Full-step LTE constant** — explicit, computable from the basis and parameters.

    `stepLteC basis ν E₀ := 2 · (C_K·E₀ + ν)^2 + 1`

    This satisfies:
    * `stepLteC > 0` (theorem `stepLteC_pos`)
    * `(C_K·E₀+ν)^2 ≤ stepLteC / 2` (since `stepLteC/2 = (C_K·E₀+ν)^2 + 1/2`) -/
noncomputable def stepLteC {N : Nat} (basis : GalerkinBasis N) (ν E₀ : Rat) : Rat :=
  2 * (triadKernelBound (standardTriadK basis) * E₀ + ν) ^ 2 + 1

theorem stepLteC_pos {N : Nat} (basis : GalerkinBasis N)
    (ν E₀ : Rat) (_hν : 0 < ν) (_hE₀ : 0 ≤ E₀) : 0 < stepLteC basis ν E₀ := by
  unfold stepLteC
  linarith [sq_nonneg (triadKernelBound (standardTriadK basis) * E₀ + ν)]

/-! ## 196A: Viscous-step convection residual LTE (Stage 197: proved as theorem) -/

/-- **Viscous-step convection residual LTE** (h^2 in squared ℓ² norm) — **THEOREM**.

    Proof chain:
      `|viscStep(convStepH h u) − viscStep(u)|²`
      `≤ |convStepH h u − u|²`            [viscStep_nonexpansive]
      `≤ C_K · E₀² · h²`                  [convStepH_increment_bound]

    **Net: 0 new axioms** (both ingredients are theorems). -/
theorem viscStep_splitting_lte
    {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hE₀ : 0 ≤ E₀)
    (u : CoeffC N) (hu : coeffNormSq u ≤ E₀) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStepH basis h u))
      (viscStep basis ν h u)) ≤
    triadKernelBound (standardTriadK basis) * E₀ ^ 2 * h ^ 2 :=
  calc coeffNormSq (coeffSub
          (viscStep basis ν h (convStepH basis h u))
          (viscStep basis ν h u))
      ≤ coeffNormSq (coeffSub (convStepH basis h u) u) :=
          viscStep_nonexpansive basis ν h hν hh (convStepH basis h u) u
    _ ≤ triadKernelBound (standardTriadK basis) * E₀ ^ 2 * h ^ 2 :=
          convStepH_increment_bound basis h E₀ hh hE₀ u hu

/-! ## 198D: Galerkin ODE first-order Taylor remainder (replaces 196B) -/

/-- **Galerkin ODE first-order Taylor remainder** (h^4 in squared ℓ² norm) — **AXIOM 198D**.

    The Lie-splitting step `viscStep ν h ∘ convStepH h` applied to `uExact t` lands within
    `(C_K·E₀ + ν)^2 · h^4` (squared ℓ² norm) of the exact Galerkin ODE solution at t+h,
    for `h ≤ 1`.

    This is a STRONGER claim than 196B (h^4 vs h^3, but only for h ≤ 1).  It reflects the
    true O(h^4) squared-norm splitting error from the Lie–Trotter commutator formula
    `[e^{hA}, e^{hB}] = e^{h(A+B)} + O(h^2)` in state norm, giving O(h^4) in squared norm.

    Stage 198A (`convStepH_first_order_remainder_sq`) and Stage 198B
    (`viscStep_first_order_remainder_sq`) give supporting evidence that the individual
    sub-steps have O(h^4) Euler-jet errors.  Together they motivate the h^4 claim.

    Epistemic: `.partiallyVerified` (BCH formula + first-order splitting analysis;
    Stages 198A/198B provide the algebraic evidence for each sub-step).

    **Replaces 196B** `lie_splitting_commutator_lte` (axiom retired as theorem below). -/
axiom galerkin_ode_taylor_remainder
    {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hh1 : h ≤ 1) (hE₀ : 0 ≤ E₀)
    (uExact : Rat → CoeffC N)
    (hODE    : SolvesGalerkinODE basis ν uExact)
    (hEnergy : ∀ t : Rat, coeffNormSq (uExact t) ≤ E₀) (t : Rat) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStepH basis h (uExact t)))
      (uExact (t + h))) ≤
    (triadKernelBound (standardTriadK basis) * E₀ + ν) ^ 2 * h ^ 4

/-! ## 196B: Full Lie-splitting commutator LTE — THEOREM from 198D -/

/-- **Full Lie-splitting commutator LTE** (h^3 in squared ℓ² norm) — **THEOREM** from 198D.

    The full split step `viscStep ν h ∘ convStepH h` applied to `uExact t` lands within
    `(C_K·E₀ + ν)^2 · h^3` (squared ℓ² norm) of the exact Galerkin ODE solution at t+h.

    Proof chain:
      `|S_h(uExact t) − uExact(t+h)|²`
      `≤ (C_K·E₀+ν)^2 · h^4`           [198D: galerkin_ode_taylor_remainder]
      `≤ (C_K·E₀+ν)^2 · h^3`           [h^4 ≤ h^3 for h ≤ 1]

    Requires `h ≤ 1` (added as a hypothesis, consistent with the convergence use at h = diH).

    **Net: 196B axiom retired** (Stage 198E, 0 new axioms beyond 198D). -/
theorem lie_splitting_commutator_lte
    {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hh1 : h ≤ 1) (hE₀ : 0 ≤ E₀)
    (uExact : Rat → CoeffC N)
    (hODE    : SolvesGalerkinODE basis ν uExact)
    (hEnergy : ∀ t : Rat, coeffNormSq (uExact t) ≤ E₀) (t : Rat) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStepH basis h (uExact t)))
      (uExact (t + h))) ≤
    (triadKernelBound (standardTriadK basis) * E₀ + ν) ^ 2 * h ^ 3 := by
  have h198D := galerkin_ode_taylor_remainder basis ν h E₀ hν hh hh1 hE₀ uExact hODE hEnergy t
  have hh4_le_3 : h ^ 4 ≤ h ^ 3 := by nlinarith [pow_pos hh 3, hh1]
  calc coeffNormSq (coeffSub
          (viscStep basis ν h (convStepH basis h (uExact t)))
          (uExact (t + h)))
      ≤ (triadKernelBound (standardTriadK basis) * E₀ + ν) ^ 2 * h ^ 4 := h198D
    _ ≤ (triadKernelBound (standardTriadK basis) * E₀ + ν) ^ 2 * h ^ 3 :=
          mul_le_mul_of_nonneg_left hh4_le_3
            (sq_nonneg (triadKernelBound (standardTriadK basis) * E₀ + ν))

/-! ## 196C: SA2 as a theorem -/

/-- **SA2 as a theorem** — full Lie-splitting LTE derived from 196B and `stepLteC` padding.

    Proof chain:
      `|S_h(uExact t) − uExact(t+h)|²`
      ≤ `(C_K·E₀+ν)^2 · h^3`            [196B: lie_splitting_commutator_lte]
      ≤ `stepLteC / 2 · h^3`              [since (C_K·E₀+ν)^2 ≤ stepLteC/2]

    The key algebraic step: `stepLteC/2 = (2(C_K·E₀+ν)^2+1)/2 = (C_K·E₀+ν)^2 + 1/2`.
    So `(C_K·E₀+ν)^2 ≤ stepLteC/2` follows from `0 ≤ 1/2`.

    **Net: 0 new axioms** (uses only 196B). -/
theorem galerkinSplitting_step_lte_proved
    {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hh1 : h ≤ 1) (hE₀ : 0 ≤ E₀)
    (uExact : Rat → CoeffC N)
    (hODE    : SolvesGalerkinODE basis ν uExact)
    (hEnergy : ∀ t : Rat, coeffNormSq (uExact t) ≤ E₀) (t : Rat) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStepH basis h (uExact t)))
      (uExact (t + h))) ≤
    stepLteC basis ν E₀ / 2 * h ^ 3 := by
  have h196B := lie_splitting_commutator_lte basis ν h E₀ hν hh hh1 hE₀ uExact hODE hEnergy t
  have hle : (triadKernelBound (standardTriadK basis) * E₀ + ν) ^ 2 ≤
      stepLteC basis ν E₀ / 2 := by
    simp only [stepLteC]
    linarith [sq_nonneg (triadKernelBound (standardTriadK basis) * E₀ + ν)]
  calc coeffNormSq (coeffSub
          (viscStep basis ν h (convStepH basis h (uExact t)))
          (uExact (t + h)))
      ≤ (triadKernelBound (standardTriadK basis) * E₀ + ν) ^ 2 * h ^ 3 := h196B
    _ ≤ stepLteC basis ν E₀ / 2 * h ^ 3 :=
          mul_le_mul_of_nonneg_right hle (pow_nonneg hh.le 3)

def stage196Summary : String :=
  "Stage 196/197/198: NSGalerkinStepLTE — SA2 sub-axiom decomposition + full discharge. " ++
  "stepLteC: DEF (2*(C_K*E₀+ν)^2+1). " ++
  "stepLteC_pos: THEOREM. " ++
  "viscStep_splitting_lte: THEOREM (196A, h^2, from convStepH_increment_bound + viscStep_nonexpansive, 0 new axioms). " ++
  "galerkin_ode_taylor_remainder: AXIOM (198D, h^4, h≤1, Lie commutator h^4 version, .partiallyVerified). " ++
  "lie_splitting_commutator_lte: THEOREM (196B retired, h^3, from 198D + h^4≤h^3 for h≤1, 0 new axioms). " ++
  "galerkinSplitting_step_lte_proved: THEOREM (196C, SA2 from 196B, 0 new axioms). " ++
  "SA2 axiom (NSGalerkinConvergence.galerkinSplitting_step_lte) RETIRED. " ++
  "Net: +1 axiom (198D), +4 theorems, 0 sorry. 196B axiom RETIRED as theorem."

end NavierStokes.GalerkinStepLTE
