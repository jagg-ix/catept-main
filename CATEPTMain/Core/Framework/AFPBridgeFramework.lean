import CATEPTPluginAFPFramework.IntegrationBridge

/-!
# AFP Bridge Framework — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-afp-framework` under
[Target 6.1 / T61 step 0](../../../docs/architecture/targets/target-4-plan.md)
(prerequisite for the `catept-domain-quantum` bundle).

The 4 generic carrier opaque types (`AFPObj`, `AFPSet`, `AFPMat`, `AFPVec`)
and the matrix/vector axioms are authoritatively in
`CATEPTPluginAFPFramework.IntegrationBridge` under namespace
`CATEPTPluginAFPFramework`.

This file re-exports the carriers / axioms / `AFPTranslationPhase` enum
under the original namespace `CATEPTMain.Core.Framework` so that the
prelude files importing `CATEPTMain.Core.Framework.AFPBridgeFramework`
keep compiling unchanged.

## `TacticStubs` macros removed (zero-sorry policy)

Earlier versions of this shim re-declared 15 scoped macros (`linarith`,
`ring`, `norm_num`, `simp`, …) that expanded to `tactic| sorry` to
support a "phase-1 stubbing" workflow.  Those macros silently turned
every standard tactic into `sorry` whenever a downstream file did
`open CATEPTMain.Core.Framework.TacticStubs`, which violates the
repo's hard rule against `sorry` in proof obligations.

The local re-declarations are removed.  Phase-1 stubbing is no longer
supported here.  Any downstream that previously opened `TacticStubs`
from this namespace must:
  1. Move to phase-2 (real proofs against Mathlib's actual
     `linarith`/`ring`/etc.), OR
  2. Restate the obligation as a `Prop` field of a `Carrier` structure
     (carrier hypothesis pattern — consumers supply the hypothesis
     instead of the proof being stubbed).

The upstream plugin's `CATEPTPluginAFPFramework.TacticStubs` namespace
still exists; opening it directly remains discouraged by the same
policy.
-/

set_option autoImplicit false

namespace CATEPTMain.Core.Framework

export CATEPTPluginAFPFramework (
  AFPTranslationPhase
  AFPObj AFPSet AFPMat AFPVec
  afpDimRow afpDimCol afpDimVec
  afpIndexMat afpIndexVec
  afpMatMul afpMatAdd afpSmulMat afpOneMat afpZeroMat
  afpTranspose afpDagger afpColVec afpRowMat
  afpVecAdd afpSmulVec afpScalar afpInner afpVecNorm
  afpKetVec afpBraVec
  afpUnitary afpHermitian afpIsSquare)

end CATEPTMain.Core.Framework
