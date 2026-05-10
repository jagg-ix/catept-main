import CATEPTMain.Certification

/-!
# Certification Surface Tests

This file fails to build if a public certification declaration is deleted,
renamed, or moved out of the expected namespace.
-/

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.Surface

-- Universal layer
#check CATEPTMain.Certification.CATEPTUniversalConsistencyCertificate
#check CATEPTMain.Certification.universalConsistencyCertificate

-- Sector layer
#check CATEPTMain.Certification.Quantum.QuantumCATEPTCertificate
#check CATEPTMain.Certification.ClassicalMechanics.ClassicalMechanicsCATEPTCertificate
#check CATEPTMain.Certification.RelativitySR.PhyslibSRSpinorBridgeCertificate
#check CATEPTMain.Certification.Bell.BellCATEPTCertificate
#check CATEPTMain.Certification.PathIntegral.PathIntegralCATEPTCertificate
#check CATEPTMain.Certification.ModularThermal.ModularThermalCATEPTCertificate

end CATEPTMain.Certification.Tests.Surface
