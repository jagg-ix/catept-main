/-!
# CATEPT Plugin — Brownian-motion Integration Bridge

Sibling repo of `jagg-ix/catept-main`. Provides an abstract integration
contract for the `brownian-motion-inspect` package against CATEPT's
stochastic-analysis bridges.

**Toolchain status:** `bridge_upgrade_required` — the upstream
`brownian-motion-inspect` package targets Lean 4 v4.28.0-rc1; direct
import is blocked until that toolchain upgrade. This sibling defines
the abstract witness so that consumers can reason about the integration
contract without depending on the unavailable upstream.

## CATEPT leverage points

* **LAPL bridge** (`AFPBridge/LAPL`): The infinitesimal generator of the
  Brownian-motion semigroup is `A = ½ Δ` (Laplacian). Its Laplace transform
  is the heat-semigroup resolvent `R(λ) = (λ − ½Δ)⁻¹`, supplying a concrete
  `StronglyContinuousSemigroup` instance for the LAPL / HilleYosida bridge.

* **ODE bridge** (`AFPBridge/ODE`): Itô's formula provides stochastic analogues
  of ODE existence theorems; `BrownianMotion.Auxiliary.Adapted` and
  `IsStoppingTime` supply the measurable-adaptation conditions assumed in
  `ODE.Theories.Euler_Method`.

* **CPM bridge** (`AFPBridge/CPM`): Wiener measure is a prime example of a
  coproduct measure on a path space; `BrownianMotion.Auxiliary.Filtration`
  cross-validates the filtration structure in `CPM.Theories.Coproduct_Measure`.

## Re-import contract for `catept-main`

```lean
import CATEPTPluginBrownianMotion.IntegrationBridge

open CATEPTPluginBrownianMotion (
  BrownianMotionWitness BrownianMotionIntegrationContract
  brownianMotion_integration_contract)
```

## Phase status
Phase-1: abstract witness; bridge theorem term-proved.
Phase-2 work item: upgrade `brownian-motion-inspect` to v4.29.0, then
replace witness with `IsBrownianMotion` structure from that package.
-/

set_option autoImplicit false

namespace CATEPTPluginBrownianMotion

/-- Abstract capability witness for `brownian-motion-inspect`. -/
structure BrownianMotionWitness where
  /-- Gaussian law on ℝ-valued path space is characterised. -/
  gaussianLawAvailable : Prop
  /-- Natural filtration of a stochastic process is available. -/
  filtrationAvailable : Prop
  /-- Stopping-time predicate formalised. -/
  stoppingTimeAvailable : Prop
  /-- Adapted process predicate formalised. -/
  adaptedProcessAvailable : Prop
  /-- Jensen's inequality for conditional expectations (martingale form). -/
  jensenMartingaleAvailable : Prop
  /-- Brownian motion exists: there is a probability space supporting
      a process with the correct covariance structure. -/
  brownianMotionExists : Prop

/-- Integration contract. -/
def BrownianMotionIntegrationContract (w : BrownianMotionWitness) : Prop :=
  w.gaussianLawAvailable ∧ w.filtrationAvailable ∧
  w.stoppingTimeAvailable ∧ w.adaptedProcessAvailable ∧
  w.jensenMartingaleAvailable ∧ w.brownianMotionExists

theorem brownianMotion_integration_contract
    (w : BrownianMotionWitness)
    (hG  : w.gaussianLawAvailable) (hF : w.filtrationAvailable)
    (hST : w.stoppingTimeAvailable) (hAd : w.adaptedProcessAvailable)
    (hJ  : w.jensenMartingaleAvailable) (hBM : w.brownianMotionExists) :
    BrownianMotionIntegrationContract w :=
  ⟨hG, hF, hST, hAd, hJ, hBM⟩

end CATEPTPluginBrownianMotion
