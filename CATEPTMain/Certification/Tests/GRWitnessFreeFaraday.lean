import CATEPTMain.Certification.RelativityGRWitnessFreeFaraday
import CATEPTMain.Certification.RelativityGRWitnessFreeFaradayFamily
import CATEPTMain.Certification.RelativityGRWitnessFreeCurvedDirect
import CATEPTMain.Certification.RelativityGRWitnessFreeEinstein
import CATEPTMain.Certification.RelativityGRWitnessFreeADM
import CATEPTMain.Certification.RelativityGRVMLFamily

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRWitnessFreeFaraday

open CATEPTMain.Certification.RelativityGR
open CATEPTMain.Integration.GravitasBridge
open Gravitas

#check canonical_faraday_minkowski_fixed_witness
#check canonical_faraday_minkowski_fixed_witness_claim
#check canonical_curved_gr_direct_certificate_witness_free
#check canonical_curved_gr_direct_certificate_witness_free_claim

example : FixedAntisymmetric4D gravitasFaradayMinkowski :=
  canonical_faraday_minkowski_fixed_witness_claim

example : CurvedGRDirectCertificate :=
  canonical_curved_gr_direct_certificate_witness_free

example :
    hodgeStarEM gravitasMinkowski
      (hodgeStarEM gravitasMinkowski gravitasFaradayMinkowski) =
      gravitasFaradayMinkowski :=
  (canonical_curved_gr_direct_certificate_witness_free_claim).1

-- Family-level fixed-antisymmetric theorem and canonical instance
#check @faraday_ofMetric_is_fixedAntisymmetric4D
#check canonical_faraday_ofMetric_witness_minkowski

example :
    FixedAntisymmetric4D
      (Gravitas.ElectromagneticTensor.ofMetric gravitasMinkowski #[]
        (Gravitas.Expr.var "μ₀")) :=
  faraday_ofMetric_is_fixedAntisymmetric4D _ _ _
    canonical_faraday_ofMetric_witness_minkowski

-- WF-GR-009/10: certified-curved-GR data umbrella
#check @IsCertifiedCurvedGRData
#check @curved_gr_direct_certificate_of_certified_data
#check @certified_curved_gr_data_implies_full_direct_claim
#check canonical_certified_curved_gr_data
#check canonical_curved_gr_direct_certificate_of_certified_data
#check canonical_certified_curved_gr_data_full_claim

example : CurvedGRDirectCertificate :=
  canonical_curved_gr_direct_certificate_of_certified_data

example :
    IsCertifiedCurvedGRData
      gravitasMinkowski
      gravitasFaradayMinkowski
      gravitasEMStressEnergy
      gravitasCanonicalVacuumADM
      gravitasCanonicalVacuumADMStressDecomposition
      (Gravitas.Expr.lit 0) :=
  canonical_certified_curved_gr_data

-- WF-GR-005/6: Einstein-electrovacuum solution umbrella
#check @IsEinsteinElectrovacuumSolution
#check @einsteinElectrovacuumStress
#check @einstein_certificate_for_solution
#check @einstein_electrovacuum_solution_full_claim
#check canonical_minkowski_is_einstein_electrovacuum_solution
#check canonical_einstein_certificate_of_electrovacuum_solution
#check canonical_einstein_electrovacuum_solution_full_claim

example :
    IsEinsteinElectrovacuumSolution
      gravitasMinkowski #[] (Gravitas.Expr.var "μ₀")
      (Gravitas.Expr.lit 0) (Gravitas.Expr.lit 0) :=
  canonical_minkowski_is_einstein_electrovacuum_solution

example :
    EinsteinEquationCertificateForSource
      gravitasMinkowski
      (einsteinElectrovacuumStress gravitasMinkowski #[]
        (Gravitas.Expr.var "μ₀") (Gravitas.Expr.lit 0)) :=
  canonical_einstein_certificate_of_electrovacuum_solution

-- WF-GR-007/8: ADM-constraint data umbrella
#check @IsCertifiedADMData
#check @adm_certificate_for_data
#check @adm_data_full_claim
#check canonical_minkowski_is_certified_adm_data
#check canonical_adm_certificate_of_data
#check canonical_adm_data_full_claim

example :
    IsCertifiedADMData
      gravitasCanonicalVacuumADM
      gravitasCanonicalVacuumADMStressDecomposition
      (Gravitas.Expr.lit 0) :=
  canonical_minkowski_is_certified_adm_data

example :
    ADMConstraintCertificateFor gravitasCanonicalVacuumADM :=
  canonical_adm_certificate_of_data

-- WF-GR-StressId-001: witness-free named-Faraday stress-identification reduction
#check namedCanonicalElectrovacuumStress
#check namedCanonicalElectrovacuumStress_eq_gravitasEMStressEnergy
#check namedCanonical_maxwell_to_stress_conservation_witness_free
#check @vml_equilibrium_supports_named_canonical_electrovacuum_family_witness_free

example :
    namedCanonicalElectrovacuumStress = gravitasEMStressEnergy :=
  namedCanonicalElectrovacuumStress_eq_gravitasEMStressEnergy

example :
    covariantDivergenceStressEnergy gravitasMinkowski
      namedCanonicalElectrovacuumStress =
    Array.mkArray gravitasMinkowski.dim (Gravitas.Expr.lit 0) :=
  namedCanonical_maxwell_to_stress_conservation_witness_free

end CATEPTMain.Certification.Tests.GRWitnessFreeFaraday
