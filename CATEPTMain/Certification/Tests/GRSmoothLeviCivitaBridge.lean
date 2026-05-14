/-
# Tests: smooth Levi-Civita bridge

REPLYID 20260513-SMOOTH-LC-EXISTING-IMPLEMENTATION-PROCEED-001 →
Tests for the umbrella bridge module.
-/

import CATEPTMain.Certification.RelativityGRSmoothLeviCivitaBridge
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiBianchi
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiCoordinateBridge
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiContractedCertificate
import CATEPTMain.Certification.RelativityGRSmoothMinkowskiStress

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRSmoothLeviCivitaBridge

open CATEPTMain.Certification.RelativityGR
open CATEPTMain.Integration.GravitasBridge
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

-- Target H — Non-vacuous Minkowski concrete-array witnesses.
#check smoothEinsteinTensor_minkowski_components_zero
#check leviCivitaDivergenceEinsteinTensor_minkowski_components_zero

example
    (connection : SmoothConnection smoothMinkowskiSpacetime)
    (hLC : IsLeviCivitaConnection connection) :
    (smoothEinsteinTensor smoothMinkowskiSpacetime connection hLC).components
      = Array.replicate 16 (Gravitas.Expr.lit 0) :=
  smoothEinsteinTensor_minkowski_components_zero connection hLC

example
    (connection : SmoothConnection smoothMinkowskiSpacetime)
    (hLC : IsLeviCivitaConnection connection) :
    (leviCivitaDivergenceEinsteinTensor connection hLC).components
      = Array.replicate 4 (Gravitas.Expr.lit 0) :=
  leviCivitaDivergenceEinsteinTensor_minkowski_components_zero connection hLC

-- Target I — Minkowski-specialized contracted Bianchi (PR1).
#check smoothMinkowski_leviCivitaDivergenceEinstein_zero
#check smoothMinkowski_contracted_bianchi_nonvacuous

example :
    leviCivitaDivergenceEinsteinTensor
      smoothMinkowskiConnection
      smoothMinkowski_isLeviCivita
    =
    zeroSmoothTensorField smoothMinkowskiSpacetime 1 0 :=
  smoothMinkowski_contracted_bianchi_nonvacuous

-- Target J — Minkowski-specialized coordinate-array bridge (PR3).
#check coordinateArrayOfSmoothMinkowskiEinsteinDivergence_zero
#check gravitasMinkowski_symbolic_divergence_matches_smooth
#check gravitasMinkowski_symbolicEinsteinDivergenceRepresentsSmooth

-- Target K — Minkowski ContractedBianchiCertificate from the smooth route (PR4).
#check gravitasMinkowski_symbolicRepresents_smooth
#check gravitasMinkowski_contractedBianchiCertificate_from_smooth

example : ContractedBianchiCertificate gravitasMinkowski :=
  gravitasMinkowski_contractedBianchiCertificate_from_smooth

-- Target L — Minkowski HasStressConservation from the smooth route (PR5).
#check kappa_var_ne_zero_lit
#check gravitasMinkowski_hasStressConservation_from_smooth

example :
    covariantDivergenceStressEnergy gravitasMinkowski gravitasEMStressEnergy =
      Array.mkArray gravitasMinkowski.dim (.lit 0) :=
  gravitasMinkowski_hasStressConservation_from_smooth.divergence_zero

end CATEPTMain.Certification.Tests.GRSmoothLeviCivitaBridge

end
