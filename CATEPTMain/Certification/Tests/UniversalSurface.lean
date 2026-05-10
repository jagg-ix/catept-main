import CATEPTMain.Certification.UniversalCertificate

/-!
# Universal Certificate Tests

These tests ensure the production universal certificate remains constructible.
-/

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.UniversalSurface

open CATEPTMain.Certification

#check CATEPTUniversalConsistencyCertificate
#check universalConsistencyCertificate

/-- The universal certificate must remain constructible. -/
noncomputable example : CATEPTUniversalConsistencyCertificate :=
  universalConsistencyCertificate

-- The common-clock field must remain present.
#check universalConsistencyCertificate.commonClock

end CATEPTMain.Certification.Tests.UniversalSurface
