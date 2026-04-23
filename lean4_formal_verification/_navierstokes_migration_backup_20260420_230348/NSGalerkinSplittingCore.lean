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
open NavierStokes.GalerkinConvection    -- GalerkinBasis (needed for SolvesGalerkinODE)

/-! ## CoeffC operations -/

/-- Pointwise subtraction of Galerkin coefficient vectors. -/
def coeffSub {N : Nat} (u v : CoeffC N) : CoeffC N :=
  fun i => u i - v i

/-- Squared ℓ² norm of Galerkin coefficients. -/
def coeffNormSq {N : Nat} (u : CoeffC N) : Rat :=
  ∑ i : Fin N, normSqC (u i)

theorem coeffNormSq_nonneg {N : Nat} (u : CoeffC N) : 0 ≤ coeffNormSq u :=
  Finset.sum_nonneg (fun i _ => normSqC_nonneg (u i))

/-! ## Semantic ODE predicate (moved from NSGalerkinConvergence, Stage 196) -/

/-- **`SolvesGalerkinODE`** — opaque predicate: `uExact` is a (classical) solution of the
    finite-dimensional Galerkin Navier-Stokes ODE with viscosity `ν` and basis geometry `basis`.

    The ODE in coefficient space is:
      `d/dt (uExact t)_i = − ∑_j,l K(i,j,l)·uExact_j·uExact_l − ν·|k_i|²·(uExact t)_i`

    Declared as an opaque axiom (Prop-valued) because the continuous-time ODE infrastructure
    (derivatives, integrals over ℝ) is not yet internalized in this Rat-only formalization.
    All LTE bounds that depend on ODE consistency are gated on this predicate.

    Epistemic status: `.openBridge` (continuous ODE well-posedness in finite dimension;
    provable from standard Picard–Lindelöf for Galerkin truncations).

    Moved to SplittingCore (Stage 196) so that `NSGalerkinStepLTE` can reference it
    without importing `NSGalerkinConvergence` (which would create an import cycle). -/
axiom SolvesGalerkinODE {N : Nat} (basis : GalerkinBasis N) (ν : Rat)
    (uExact : Rat → CoeffC N) : Prop

def stage187CoreSummary : String :=
  "Stage 187/196 (Core): NSGalerkinSplittingCore — cycle-breaking infrastructure. " ++
  "coeffSub: DEF (moved from NSGalerkinConvergence). " ++
  "coeffNormSq: DEF (moved from NSGalerkinConvergence). " ++
  "coeffNormSq_nonneg: THEOREM (moved from NSGalerkinConvergence). " ++
  "SolvesGalerkinODE: AXIOM (moved from NSGalerkinConvergence, Stage 196). " ++
  "Net: +1 axiom, +1 theorem, 0 sorry."

end NavierStokes.GalerkinConvergence
