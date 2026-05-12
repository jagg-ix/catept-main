import CATEPTMain.Certification.RelativityGRCurvedDirect

noncomputable section

set_option autoImplicit false
set_option maxRecDepth 8192

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

deriving instance DecidableEq for Expr
deriving instance DecidableEq for MetricTensor
deriving instance DecidableEq for ElectromagneticTensor

/-- Canonical fixed-antisymmetric witness for the Gravitas Minkowski Faraday
tensor, discharged directly from concrete Gravitas data.

Following the upstream totalization of `Gravitas.simplify` / `Gravitas.symDiff`
in `catept-gravitas-port` v0.2.0, every field equality reduces to `rfl` at the
kernel level. This eliminates the six `native_decide` invocations (and their
`Lean.ofReduceBool` axiom dependency) from the canonical Faraday witness. -/
def canonical_faraday_minkowski_fixed_witness : FaradayMinkowskiFixedWitness where
  components_size_four := rfl
  canonical_4x4 := rfl
  diagonal_zero_entries := ⟨rfl, rfl, rfl, rfl⟩
  antisymmetry_entries := ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩
  double_neg_entries := ⟨rfl, rfl⟩
  hodge_fixed := rfl

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
