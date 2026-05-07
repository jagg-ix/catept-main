import CATEPTPluginVMLLandau.IntegrationBridge

/-!
# VML-Landau Bridge (catept-main shim)

Thin re-export of the [`catept-plugin-vml-landau`](https://github.com/jagg-ix/catept-plugin-vml-landau)
sibling's namespace `CATEPTPluginVMLLandau`, which itself re-aliases the
Aristotle / Clawristotle formalization of the Vlasov–Maxwell–Landau
steady-state rigidity theorem on $\mathbb{T}^3$ (Theorem 4.2, concrete
Coulomb form).

This shim lives at `CATEPTMain.Integration.VMLLandau` and surfaces
the kernel-clean (`propext`, `Classical.choice`, `Quot.sound` only)
re-exports under a stable catept-main–local name so downstream consumers
can depend on `CATEPTMain.Integration.VMLLandau.proved_*` without
referencing the plugin namespace directly.

See also `CATEPTMain.Integration.VMLSteadyState` (in
`VMLSteadyStateBridge.lean`) for the higher-level
`VMLSteadyStateIntegrationContract` semantic interface; this file is
the namespace-renaming layer that replaces the previous direct
`Aristotle.Landau.main.Theorem42` import path.
-/

namespace CATEPTMain.Integration.VMLLandau

export CATEPTPluginVMLLandau
  (proved_vml_steady_state_rigidity
   proved_vml_steady_state_classify_T
   proved_vml_theorem42_abstract
   proved_vml_steady_state_nonvacuous
   proved_vml_steady_state_roundtrip
   vml_landau_content_available)

end CATEPTMain.Integration.VMLLandau
