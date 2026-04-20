import CATEPTMain.Integration.QuantumInfoBridge
import CATEPTMain.Integration.QuantumInfoFisherBridge

set_option autoImplicit false

/-!
# QuantumInfo Standalone Surface

Narrow standalone entry for the CATEPT quantum-information bridge lane,
without importing the full `CATEPTMain` root module.

This surface intentionally avoids direct `QuantumInfo` root imports because
that package path is currently in a mixed-version state in this workspace.
The bridge lane here remains compilable and stable for integration work.
-/
