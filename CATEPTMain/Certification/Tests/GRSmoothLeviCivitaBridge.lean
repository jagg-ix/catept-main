/-
# Tests: smooth Levi-Civita bridge

REPLYID 20260513-SMOOTH-LC-EXISTING-IMPLEMENTATION-PROCEED-001 →
Tests for the umbrella bridge module.
-/

import CATEPTMain.Certification.RelativityGRSmoothLeviCivitaBridge

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRSmoothLeviCivitaBridge

open CATEPTMain.Certification.RelativityGR
open Gravitas

-- Target A — Inventory: all canonical names elaborate.
#check SmoothPseudoRiemannianManifold
#check SmoothConnection
#check IsLeviCivitaConnection
#check SmoothTensorField
#check smoothEinsteinTensor
#check leviCivitaDivergence
#check leviCivitaDivergenceEinsteinTensor
#check SmoothSecondBianchiIdentity
#check smooth_contracted_bianchi

-- Target C — Certification alias.
#check certified_smooth_contracted_bianchi

-- Target D — Representation bridge.
#check GravitasRepresentsSmoothMetric
#check SymbolicEinsteinDivergenceRepresentsSmooth

-- Target E — ContractedBianchiCertificate from smooth Levi-Civita.
#check contractedBianchiCertificate_of_smooth_leviCivita

-- Target F — HasStressConservation from smooth Levi-Civita.
#check hasStressConservation_of_smooth_leviCivita_einstein

-- Target G — CurvedDirect from smooth Levi-Civita.
#check certifiedCurvedGRData_of_smooth_leviCivita
#check curvedGRDirectCertificate_of_smooth_leviCivita

-- Target C example: the alias matches the LC-006 theorem usage.
example
    {X : SmoothPseudoRiemannianManifold}
    (connection : SmoothConnection X)
    (hLC : IsLeviCivitaConnection connection) :
    leviCivitaDivergenceEinsteinTensor connection hLC =
      zeroSmoothTensorField X 1 0 :=
  certified_smooth_contracted_bianchi connection hLC

end CATEPTMain.Certification.Tests.GRSmoothLeviCivitaBridge

end
