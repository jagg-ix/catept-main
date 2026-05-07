import CATEPTMain.Quantum.HSTP.Spectral_Theorem
import CATEPTPluginDomainQuantum.HSTP.Trace_Class

/-!
# Trace_Class — re-export shim (sub-bundle `HSTP`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.HSTP.Trace_Class

export CATEPTPluginDomainQuantum.HSTP.Trace_Class (
  IsTraceClass
  hstpTrace
  hstpTraceNorm
  hstpTraceNorm_le_norm
  hstpTraceNorm_nonneg
  hstpTrace_basis_indep
  hstpTrace_cyclic
  traceClass_compact
)

end CATEPTMain.Quantum.HSTP.Trace_Class
