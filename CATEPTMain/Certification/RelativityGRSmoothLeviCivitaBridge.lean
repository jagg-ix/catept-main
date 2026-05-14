/-
# Smooth Levi-Civita bridge — umbrella module

REPLYID 20260513-SMOOTH-LC-EXISTING-IMPLEMENTATION-PROCEED-001 →
Targets B, C, D, E, F, G.

This module is a single umbrella that re-exports the smooth
Levi-Civita layer (LC-001 … LC-011) for external consumers.  All the
underlying definitions and theorems already exist in dedicated
LC-step files; this file ships:

* a thin compatibility surface (`importing` all LC files, so a single
  `import CATEPTMain.Certification.RelativityGRSmoothLeviCivitaBridge`
  is sufficient);
* the canonical-name alias `certified_smooth_contracted_bianchi`
  (Target C) on top of the LC-006 theorem `smooth_contracted_bianchi`;
* the umbrella audit-pure surface needed by external PRs.

## Mapping to the LC-ladder

| Target | LC step | Definition / theorem |
|--------|---------|---------------------|
| A      | LC-001/002/003 | `SmoothPseudoRiemannianManifold`, `SmoothConnection`, `IsLeviCivitaConnection`, `SmoothTensorField` |
| A      | LC-003/004 | `smoothEinsteinTensor`, `leviCivitaDivergence`, `leviCivitaDivergenceEinsteinTensor` |
| A      | LC-005/006 | `SmoothSecondBianchiIdentity`, `smooth_contracted_bianchi` |
| C      | this file  | `certified_smooth_contracted_bianchi` (alias of LC-006) |
| D      | LC-007 | `GravitasRepresentsSmoothMetric`, `SymbolicEinsteinDivergenceRepresentsSmooth` |
| E      | LC-008 | `contractedBianchiCertificate_of_smooth_leviCivita` |
| F      | LC-009 | `hasStressConservation_of_smooth_leviCivita_einstein` |
| G      | LC-011 | `certifiedCurvedGRData_of_smooth_leviCivita`, `curvedGRDirectCertificate_of_smooth_leviCivita` |

## Acceptance

* `lake build CATEPTMain.Certification.RelativityGRSmoothLeviCivitaBridge`
  passes;
* every `#check` in `Tests/GRSmoothLeviCivitaBridge.lean` elaborates;
* `#print axioms certified_smooth_contracted_bianchi` is audit-pure
  (matches `smooth_contracted_bianchi`).
-/

import CATEPTMain.Certification.RelativityGRSmoothPseudoRiemannian
import CATEPTMain.Certification.RelativityGRSmoothConnection
import CATEPTMain.Certification.RelativityGRSmoothTensorField
import CATEPTMain.Certification.RelativityGRLeviCivitaDivergence
import CATEPTMain.Certification.RelativityGRSmoothBianchi
import CATEPTMain.Certification.RelativityGRSmoothContractedBianchi
import CATEPTMain.Certification.RelativityGRSmoothGravitasBridge
import CATEPTMain.Certification.RelativityGRSmoothContractedBianchiCertificate
import CATEPTMain.Certification.RelativityGRSmoothStressConservation
import CATEPTMain.Certification.RelativityGRSmoothCurvedDirect

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

/-- **Target C.** Certification-name alias for the smooth contracted
Bianchi theorem (LC-006).  Provided as a stable public surface name so
external consumers can rely on `certified_smooth_contracted_bianchi`
without depending on the LC-step numbering. -/
theorem certified_smooth_contracted_bianchi
    {X : SmoothPseudoRiemannianManifold}
    (connection : SmoothConnection X)
    (hLC : IsLeviCivitaConnection connection) :
    leviCivitaDivergenceEinsteinTensor connection hLC =
      zeroSmoothTensorField X 1 0 :=
  smooth_contracted_bianchi connection hLC

end CATEPTMain.Certification.RelativityGR

end
