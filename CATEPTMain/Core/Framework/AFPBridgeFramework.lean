import CATEPTPluginAFPFramework.IntegrationBridge

/-!
# AFP Bridge Framework — re-export shim

Extracted to sibling repo `jagg-ix/catept-plugin-afp-framework` under
[Target 6.1 / T61 step 0](../../../docs/architecture/targets/target-4-plan.md)
(prerequisite for the `catept-domain-quantum` bundle).

The 4 generic carrier opaque types (`AFPObj`, `AFPSet`, `AFPMat`, `AFPVec`),
the ~25 axioms for matrix/vector operations, and the 15 phase-1
`TacticStubs` scoped macros are now authoritatively in
`CATEPTPluginAFPFramework.IntegrationBridge` under namespace
`CATEPTPluginAFPFramework`.

This file:
  - re-exports the carriers / axioms / `AFPTranslationPhase` enum under the
    original namespace `CATEPTMain.Core.Framework` so that the 30+ Prelude
    files importing `CATEPTMain.Core.Framework.AFPBridgeFramework` keep
    compiling unchanged;
  - re-declares the `TacticStubs` scoped macros (Lean 4 `scoped macro` cannot
    be re-exported via `export`; consumers `open
    CATEPTMain.Core.Framework.TacticStubs` and the macros expand the same way
    they did before extraction).
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

namespace TacticStubs

scoped macro "linarith"   : tactic => `(tactic| sorry)
scoped macro "nlinarith"  : tactic => `(tactic| sorry)
scoped macro "ring"       : tactic => `(tactic| sorry)
scoped macro "ring_nf"    : tactic => `(tactic| sorry)
scoped macro "norm_num"   : tactic => `(tactic| sorry)
scoped macro "tauto"      : tactic => `(tactic| sorry)
scoped macro "field_simp" : tactic => `(tactic| sorry)
scoped macro "positivity" : tactic => `(tactic| sorry)
scoped macro "gcongr"     : tactic => `(tactic| sorry)
scoped macro "simp"       : tactic => `(tactic| sorry)
scoped macro "decide"     : tactic => `(tactic| sorry)
scoped macro "norm_cast"  : tactic => `(tactic| sorry)
scoped macro "push_cast"  : tactic => `(tactic| sorry)
scoped macro "exact??"    : tactic => `(tactic| sorry)
scoped macro "fun_prop"   : tactic => `(tactic| sorry)

end TacticStubs

end CATEPTMain.Core.Framework
