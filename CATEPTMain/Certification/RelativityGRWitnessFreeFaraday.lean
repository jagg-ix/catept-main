import CATEPTMain.Certification.RelativityGRCurvedDirect

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

deriving instance DecidableEq for Expr
deriving instance DecidableEq for MetricTensor
deriving instance DecidableEq for ElectromagneticTensor

/-- Canonical fixed-antisymmetric witness for the Gravitas Minkowski Faraday
tensor, discharged directly from concrete Gravitas data. -/
def canonical_faraday_minkowski_fixed_witness : FaradayMinkowskiFixedWitness where
  components_size_four := by
    native_decide
  canonical_4x4 := by
    native_decide
  diagonal_zero_entries := by
    native_decide
  antisymmetry_entries := by
    native_decide
  double_neg_entries := by
    native_decide
  hodge_fixed := by
    native_decide

/-- Soundness projection: the canonical witness yields the fixed-antisymmetric
4D profile consumed by the derived curved-GR constructor. -/
theorem canonical_faraday_minkowski_fixed_witness_claim :
    FixedAntisymmetric4D gravitasFaradayMinkowski := by
  exact
    gravitasFaradayMinkowski_fixedAntisymmetric4D_of_witness
      canonical_faraday_minkowski_fixed_witness

/-- Canonical curved-GR direct certificate assembled without external witness
inputs by deriving the Faraday witness from Gravitas data. -/
def canonical_curved_gr_direct_certificate_witness_free : CurvedGRDirectCertificate :=
  canonical_curved_gr_direct_certificate_of_fixedAntisymmetric4D
    canonical_faraday_minkowski_fixed_witness

/-- Concrete full-claim specialization for the witness-free canonical curved-GR
certificate assembly. -/
theorem canonical_curved_gr_direct_certificate_witness_free_claim :
    hodgeStarEM gravitasMinkowski
      (hodgeStarEM gravitasMinkowski gravitasFaradayMinkowski) =
      gravitasFaradayMinkowski ∧
    covariantDivergenceStressEnergy gravitasMinkowski gravitasEMStressEnergy =
      Array.mkArray gravitasMinkowski.dim (.lit 0) ∧
    (solveEinsteinEquations gravitasEMStressEnergy (.lit 0)).fieldEquations =
      EinsteinTensor.fieldEquations gravitasMinkowski
        gravitasEMStressEnergy.components (.lit 0) (.var "G_N") ∧
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).hamiltonianConstraint =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).hamiltonianConstraint ∧
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).momentumConstraints =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).momentumConstraints := by
  simpa [canonical_curved_gr_direct_certificate_witness_free] using
    canonical_curved_gr_direct_certificate_of_fixedAntisymmetric4D_claim
      canonical_faraday_minkowski_fixed_witness

end CATEPTMain.Certification.RelativityGR

end
