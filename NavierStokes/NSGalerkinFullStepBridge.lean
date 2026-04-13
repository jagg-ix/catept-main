import NavierStokes.NSGalerkinCayleyNearIdentityBridge

/-!
# Stage 186 — NSGalerkinFullStepBridge: SA1 Retirement

Combines `viscStep_nonexpansive` (Stage 181) with `convStep_near_identity` (Stage 185)
to prove the full Lie-splitting step `S_h = viscStep ∘ convStep` is near-identity stable:

  `|S_h u − S_h v|² ≤ (1 + (diH/2)·(1 + 9·C_K·E₀)) · |u−v|²`

for **any** `h > 0` (the key: `viscStep_nonexpansive` is h-independent; the `diH` in the
coefficient comes only from `convStep_near_identity`).

This supersedes the SA1 axiom `galerkinSplitting_step_lipschitz` in
`NSGalerkinConvergence.lean`:

* For `h = diH` (the trajectory step), SA1 is a THEOREM with
  `lipC := 2/diH + 1 + 9·C_K·E₀`.
* The algebraic identity `(2/diH + 1 + 9·C_K·E₀)/2 · diH = 1 + diH/2·(1+9·C_K·E₀)`
  is proved by `ring` after substituting `diH = 1/1000` (norm_num).

## Stage 194: SA1 formally retired

The SA1 axiom `galerkinSplitting_step_lipschitz` has been **deleted** from
`NSGalerkinConvergence.lean` (Stage 194).  `NSGalerkinConvergence` now imports
`NSGalerkinConvStepHBridge` directly and calls `galerkinFullStepH_near_identity`
(Stage 188 theorem) in `galerkinSplitting_one_step_recurrence`.  The import cycle
is resolved because `NSGalerkinConvergence` imports `NSGalerkinNSODETrajectory` which
transitively provides `convStepH` and all stability theorems.

## Net counts

  - New defs:     0
  - New axioms:   0
  - New theorems: 3
  - sorry:        0
  - warnings:     0
-/

set_option maxHeartbeats 400000

namespace NavierStokes.GalerkinFullStepBridge

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinCayley
open NavierStokes.GalerkinODE
open NavierStokes.GalerkinConvergence
open NavierStokes.GalerkinConvDef
open NavierStokes.GalerkinSplittingLemmata
open NavierStokes.DiscreteKernel
open NavierStokes.GalerkinCayleyNearIdentityBridge

/-! ## Full-step near-identity bound -/

/-- **Full Galerkin step is near-identity stable** for any `h > 0`.

    `viscStep` is non-expansive (Stage 181 `viscStep_nonexpansive`) for any h > 0,
    and `convStep_near_identity` (Stage 185) gives the `diH`-explicit constant.
    Chaining gives the combined full-step bound with leading coefficient **1**. -/
theorem galerkinFullStep_near_identity {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h)
    (u v : CoeffC N) (hu : coeffNormSq u ≤ E₀) (hv : coeffNormSq v ≤ E₀) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStep basis u))
      (viscStep basis ν h (convStep basis v))) ≤
    (1 + diH / 2 * (1 + 9 * triadKernelBound (standardTriadK basis) * E₀)) *
      coeffNormSq (coeffSub u v) :=
  calc coeffNormSq (coeffSub
          (viscStep basis ν h (convStep basis u))
          (viscStep basis ν h (convStep basis v)))
      ≤ coeffNormSq (coeffSub (convStep basis u) (convStep basis v)) :=
          viscStep_nonexpansive basis ν h hν hh (convStep basis u) (convStep basis v)
    _ ≤ (1 + diH / 2 * (1 + 9 * triadKernelBound (standardTriadK basis) * E₀)) *
          coeffNormSq (coeffSub u v) :=
          convStep_near_identity basis E₀ u v hu hv

/-! ## SA1 as a theorem for h = diH -/

/-- **Algebraic identity**: `(2/diH + 1 + 9·C_K·E₀)/2 · diH = 1 + diH/2·(1+9·C_K·E₀)`.

    This is the key equality that lets us express the near-identity bound in the
    form `(lipC/2)·diH · |u-v|²` matching the SA1 axiom signature. -/
theorem galerkinSA1_lipC_identity {N : Nat} (basis : GalerkinBasis N) (E₀ : Rat) :
    (2 / diH + 1 + 9 * triadKernelBound (standardTriadK basis) * E₀) / 2 * diH =
    1 + diH / 2 * (1 + 9 * triadKernelBound (standardTriadK basis) * E₀) := by
  have hdiH : diH = 1 / 1000 := by norm_num [diH, diN]
  rw [hdiH]; ring

/-- **SA1 as a theorem** for `h = diH` with `lipC := 2/diH + 1 + 9·C_K·E₀`.

    This theorem has the **same conclusion shape** as the SA1 axiom
    `galerkinSplitting_step_lipschitz` in NSGalerkinConvergence.lean, specialized to
    `h = diH` with an explicit `lipC`. The SA1 axiom (for general h) is formally
    stronger (and remains an axiom); this theorem SUPERSEDES it for the specific
    trajectory step size.

    Proof chain:
      `|S_{diH} u − S_{diH} v|²`
      ≤ `(1 + diH/2·(1+9·C_K·E₀)) · |u−v|²`   [galerkinFullStep_near_identity]
      =  `(lipC/2)·diH · |u−v|²`                 [galerkinSA1_lipC_identity] -/
theorem galerkinSA1_at_diH {N : Nat} (basis : GalerkinBasis N)
    (ν E₀ : Rat) (hν : 0 < ν)
    (u v : CoeffC N) (hu : coeffNormSq u ≤ E₀) (hv : coeffNormSq v ≤ E₀) :
    coeffNormSq (coeffSub
      (viscStep basis ν diH (convStep basis u))
      (viscStep basis ν diH (convStep basis v))) ≤
    (2 / diH + 1 + 9 * triadKernelBound (standardTriadK basis) * E₀) / 2 * diH *
      coeffNormSq (coeffSub u v) := by
  rw [galerkinSA1_lipC_identity]
  exact galerkinFullStep_near_identity basis ν diH E₀ hν diH_pos u v hu hv

def stage186Summary : String :=
  "Stage 186: NSGalerkinFullStepBridge — SA1 retirement. " ++
  "galerkinFullStep_near_identity: THEOREM " ++
    "(|S_h u − S_h v|² ≤ (1+diH/2·(1+9C_K·E₀))·|u−v|², any h>0). " ++
  "galerkinSA1_lipC_identity: THEOREM " ++
    "((2/diH + 1 + 9C_K·E₀)/2·diH = 1+diH/2·(1+9C_K·E₀)). " ++
  "galerkinSA1_at_diH: THEOREM (SA1 for h=diH, lipC=2/diH+1+9C_K·E₀). " ++
  "SA1 axiom (NSGalerkinConvergence) now SUPERSEDED. " ++
  "Net: +0 axioms, +3 theorems, 0 sorry."

end NavierStokes.GalerkinFullStepBridge
