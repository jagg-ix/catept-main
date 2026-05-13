import CATEPTMain.Certification.RelativityGRBianchiBridge

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRBianchiBridge

open CATEPTMain.Certification.RelativityGR
open CATEPTMain.Integration.GravitasBridge
open Gravitas

/-! # Bianchi bridge surface tests (BIANCHI-001..006) -/

/-! ## BIANCHI-001 — inventory surface -/

#check BianchiBridgeSurface
#check bianchiBridgeSurface

/-! ## BIANCHI-002 — contracted-Bianchi residual + Minkowski witness -/

#check ContractedBianchiCertificate
#check covariantDivergenceEinsteinTensor
#check covariantDivergenceEinsteinTensor_size
#check gravitasMinkowski_einstein_covariantDivergence_zero
#check gravitasMinkowski_contractedBianchiCertificate

example : ContractedBianchiCertificate gravitasMinkowski :=
  gravitasMinkowski_contractedBianchiCertificate

example :
    covariantDivergenceEinsteinTensor gravitasMinkowski =
      Array.mkArray gravitasMinkowski.dim (.lit 0) :=
  gravitasMinkowski_einstein_covariantDivergence_zero

example :
    (covariantDivergenceEinsteinTensor gravitasMinkowski).size =
      gravitasMinkowski.dim :=
  covariantDivergenceEinsteinTensor_size gravitasMinkowski

/-! ## BIANCHI-003 — Bianchi + EFE ⇒ stress conservation -/

#check EinsteinEquationHolds
#check stress_conservation_of_contracted_bianchi_and_einstein
#check gravitasMinkowski_einsteinEquationHolds

example (κ : Gravitas.Expr) :
    EinsteinEquationHolds gravitasMinkowski gravitasEMStressEnergy κ :=
  gravitasMinkowski_einsteinEquationHolds κ

example
    (κ : Gravitas.Expr) (hκ : κ ≠ Gravitas.Expr.lit 0)
    (hB : ContractedBianchiCertificate gravitasMinkowski)
    (hE : EinsteinEquationHolds gravitasMinkowski gravitasEMStressEnergy κ) :
    covariantDivergenceStressEnergy gravitasMinkowski gravitasEMStressEnergy =
      Array.mkArray gravitasMinkowski.dim (Gravitas.Expr.lit 0) :=
  stress_conservation_of_contracted_bianchi_and_einstein
    gravitasMinkowski gravitasEMStressEnergy κ hκ hB hE

/-! ## BIANCHI-004 — Bianchi-derived `HasStressConservation` constructor -/

#check BianchiToStressConservation
#check hasStressConservation_of_bianchi_einstein
#check hasStressConservation_of_bianchiToStressConservation
#check gravitasMinkowski_bianchiToStressConservation
#check gravitasMinkowski_hasStressConservation_via_bianchi

example : HasStressConservation gravitasMinkowski gravitasEMStressEnergy :=
  gravitasMinkowski_hasStressConservation_via_bianchi

example
    (κ : Gravitas.Expr) (hκ : κ ≠ Gravitas.Expr.lit 0) :
    BianchiToStressConservation gravitasMinkowski gravitasEMStressEnergy κ :=
  gravitasMinkowski_bianchiToStressConservation κ hκ

example
    {g : MetricTensor} {T : StressEnergyTensor} {κ : Gravitas.Expr}
    (h : BianchiToStressConservation g T κ) :
    HasStressConservation g T :=
  hasStressConservation_of_bianchiToStressConservation h

/-! ## BIANCHI-005 — general (non-Minkowski) admissibility -/

#check HasContractedBianchi
#check contractedBianchiCertificate_of_hasContractedBianchi
#check gravitasMinkowski_hasContractedBianchi

example : HasContractedBianchi gravitasMinkowski :=
  gravitasMinkowski_hasContractedBianchi

example
    {g : MetricTensor} (h : HasContractedBianchi g) :
    ContractedBianchiCertificate g :=
  contractedBianchiCertificate_of_hasContractedBianchi h

/-! ## BIANCHI-006 — Bianchi route into `IsCertifiedCurvedGRData` -/

#check certifiedCurvedGRData_of_bianchi_stress

example
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (hHodge : HasHodgeClosure metric faraday)
    (hStress : HasStressConservation metric stress)
    (hEinstein : HasEinsteinClosure metric stress sourceTerm)
    (hADM : HasADMClosure adm admStress sourceTerm) :
    IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm :=
  certifiedCurvedGRData_of_bianchi_stress hHodge hStress hEinstein hADM

end CATEPTMain.Certification.Tests.GRBianchiBridge

end
