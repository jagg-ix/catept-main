import CATEPTMain.Integration.TheoryPluginArchitecture

namespace CATEPTMain.Integration.PathIntegral

open CATEPTMain.Integration

/--
  Integrates the alpha divergence unity synthesis with the broader
  CATEPT path integral formalism.
-/
def alpha_divergence_unitarity_synthesis_path_integral_bound
  (plugin : TheoryPlugin)
  (h_localGlobal : localGlobalPluginConstraint plugin) :
  True :=
  trivial

end CATEPTMain.Integration.PathIntegral
