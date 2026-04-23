import NavierStokes.Galerkin.NSGalerkinConvDef

/-!
# Stage 187 — NSGalerkinSplittingCore: Shared Coefficient-Norm Infrastructure

Extracts `coeffSub`, `coeffNormSq`, and `coeffNormSq_nonneg` from
`NSGalerkinConvergence` into a file that sits BELOW the cycle, so that
`NSGalerkinSplittingLemmata` can import this file instead of
`NSGalerkinConvergence`.

## Import cycle (before Stage 187)

```
NSGalerkinConvergence
  → NSGalerkinSplittingLemmata          (imports Convergence for coeffSub/coeffNormSq)
    → NSGalerkinCayleyStabilityBridge
      → NSGalerkinCayleyNearIdentityBridge
        → NSGalerkinFullStepBridge
```

If `NSGalerkinConvergence` tried to import `NSGalerkinFullStepBridge` the last
arrow would close a cycle.  After Stage 187 the relevant part of the graph is:

```
NSGalerkinConvDef
  → NSGalerkinSplittingCore             (NEW — defines coeffSub, coeffNormSq)
    → NSGalerkinSplittingLemmata        (imports Core, NOT Convergence)
      → NSGalerkinCayleyStabilityBridge
        → NSGalerkinCayleyNearIdentityBridge
          → NSGalerkinFullStepBridge
```

`NSGalerkinConvergence` now imports `NSGalerkinSplittingCore` (dropping its own
duplicate defs) and may freely import `NSGalerkinFullStepBridge` — no cycle.

## Net counts

  - New defs:     2  (coeffSub, coeffNormSq — moved from NSGalerkinConvergence)
  - New axioms:   0
  - New theorems: 1  (coeffNormSq_nonneg — moved from NSGalerkinConvergence)
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinConvergence

set_option autoImplicit false

open NavierStokes.GalerkinComplexModel

/-! ## CoeffC operations -/

/-- Pointwise subtraction of Galerkin coefficient vectors. -/
def coeffSub {N : Nat} (u v : CoeffC N) : CoeffC N :=
  fun i => u i - v i

/-- Squared ℓ² norm of Galerkin coefficients. -/
def coeffNormSq {N : Nat} (u : CoeffC N) : Rat :=
  ∑ i : Fin N, normSqC (u i)

theorem coeffNormSq_nonneg {N : Nat} (u : CoeffC N) : 0 ≤ coeffNormSq u :=
  Finset.sum_nonneg (fun i _ => normSqC_nonneg (u i))

def stage187CoreSummary : String :=
  "Stage 187 (Core): NSGalerkinSplittingCore — cycle-breaking infrastructure. " ++
  "coeffSub: DEF (moved from NSGalerkinConvergence). " ++
  "coeffNormSq: DEF (moved from NSGalerkinConvergence). " ++
  "coeffNormSq_nonneg: THEOREM (moved from NSGalerkinConvergence). " ++
  "Net: +0 axioms, +1 theorem, 0 sorry."

end NavierStokes.GalerkinConvergence
