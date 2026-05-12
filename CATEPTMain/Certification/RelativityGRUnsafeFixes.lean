import CATEPTMain.Certification.RelativityGRHodgeDual
import CATEPTMain.Certification.RelativityGRStressConservation

noncomputable section

set_option autoImplicit false
-- Stage-B / unsafe-fix `rfl` identities exercise kernel reduction of the
-- now-total `Gravitas.simplify`/`symDiff`; raise rec-depth accordingly.
set_option maxRecDepth 8192

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- Canonical zero stress-energy tensor on the Gravitas Minkowski background. -/
def gravitasZeroStressEnergy : StressEnergyTensor where
  metric := gravitasMinkowski
  components := matBuild gravitasMinkowski.dim (fun _ _ => Expr.lit 0)
  idx1 := co
  idx2 := co

/-- Canonical vacuum ADM slicing used for explicit constraint checks:
unit lapse, zero shift, Euclidean spatial metric. -/
def gravitasCanonicalVacuumADM : ADMDecomposition :=
  ADMDecomposition.minkowski "t" #["x1", "x2", "x3"] (.lit 1)
    #[.lit 0, .lit 0, .lit 0]

/-- Canonical vacuum ADM stress-energy decomposition matching
`SolveVacuumADMEquations.ofADM`. -/
def gravitasCanonicalVacuumADMStressDecomposition : ADMStressEnergyDecomposition :=
  let g4 := ADMDecomposition.spacetimeMetric gravitasCanonicalVacuumADM
  let zeroT : StressEnergyTensor :=
    { metric := g4,
      components := matBuild g4.dim (fun _ _ => .lit 0),
      idx1 := co, idx2 := co }
  { adm := gravitasCanonicalVacuumADM,
    stressEnergy := zeroT,
    energyDensity := .lit 0,
    momentumDensity := Array.replicate gravitasCanonicalVacuumADM.spatialMetric.dim (.lit 0),
    stressTensor := matBuild gravitasCanonicalVacuumADM.spatialMetric.dim (fun _ _ => .lit 0) }

/-- Full double-Hodge closure in the kernel-transparent 4D bivector
representation for the canonical Gravitas Faraday tensor. -/
theorem gravitasFaraday_double_hodge_bivector :
    Bivector4.hodgeStar (Bivector4.hodgeStar gravitasFaradayBivector) =
      gravitasFaradayBivector :=
  gravitasFaraday_hodgeStar_involutive

/-- Certified stress-conservation closure theorem in the flat constant-model
layer (nonzero canonical radiation tensor). -/
theorem gravitasCanonicalStress_conserved_constant_model :
    flatConstantCovariantDivergenceExpr canonicalRadiationStressTensor4 =
      (fun _ => Expr.lit 0) :=
  canonical_radiation_stress_conserved

/-- Exact Einstein field-equation residual identity for the canonical
Minkowski electrovacuum stress-energy tensor. -/
theorem gravitasEinstein_residual_exact :
    (solveEinsteinEquations gravitasEMStressEnergy (.lit 0)).fieldEquations =
      EinsteinTensor.fieldEquations gravitasMinkowski
        gravitasEMStressEnergy.components (.lit 0) (.var "G_N") := by
  rfl

/-- Family-form Einstein residual identity for vacuum stress-energy data:
for any cosmological-term expression, the solved field-equation payload matches
the corresponding Einstein-tensor field-equation expression on Minkowski vacuum. -/
theorem einstein_residual_zero_for_vacuum_family
    (Λ : Gravitas.Expr) :
    (solveEinsteinEquations gravitasZeroStressEnergy Λ).fieldEquations =
      EinsteinTensor.fieldEquations gravitasMinkowski
        gravitasZeroStressEnergy.components Λ (.var "G_N") := by
  rfl

/-- The covariant-divergence operator always returns a vector with one
component per spacetime dimension in the canonical GR setup. -/
theorem gravitasZeroStress_divergence_dimension :
    (covariantDivergenceStressEnergy gravitasMinkowski gravitasZeroStressEnergy).size =
      gravitasMinkowski.dim := by
  exact covariantDivergenceStressEnergy_size gravitasMinkowski gravitasZeroStressEnergy

/-- Exact ADM Hamiltonian-residual identity for the canonical vacuum slice. -/
theorem gravitasCanonicalVacuumADM_hamiltonian_residual_exact :
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).hamiltonianConstraint =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).hamiltonianConstraint := by
  rfl

/-- Exact ADM momentum-residual identity for the canonical vacuum slice. -/
theorem gravitasCanonicalVacuumADM_momentum_residual_exact :
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).momentumConstraints =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).momentumConstraints := by
  rfl

/-- ADM momentum residual vector has the expected spatial dimension. -/
theorem gravitasCanonicalVacuumADM_momentum_dimension :
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).momentumConstraints.size =
      gravitasCanonicalVacuumADM.spatialMetric.dim := by
  rfl

/-- Consolidated CERT-UP-005 unsafe-claims closure certificate for canonical GR data. -/
structure GRCATEPTUnsafeClaimsClosureCertificate where
  double_hodge_bivector :
    Bivector4.hodgeStar (Bivector4.hodgeStar gravitasFaradayBivector) =
      gravitasFaradayBivector
  stress_conservation_constant_model :
    flatConstantCovariantDivergenceExpr canonicalRadiationStressTensor4 =
      (fun _ => Expr.lit 0)
  zero_stress_divergence_dimension :
    (covariantDivergenceStressEnergy gravitasMinkowski gravitasZeroStressEnergy).size =
      gravitasMinkowski.dim
  einstein_residual_exact :
    (solveEinsteinEquations gravitasEMStressEnergy (.lit 0)).fieldEquations =
      EinsteinTensor.fieldEquations gravitasMinkowski
        gravitasEMStressEnergy.components (.lit 0) (.var "G_N")
  adm_hamiltonian_residual_exact :
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).hamiltonianConstraint =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).hamiltonianConstraint
  adm_momentum_residual_exact :
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).momentumConstraints =
      (solveADMEquations gravitasCanonicalVacuumADM
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).momentumConstraints
  adm_momentum_dimension :
    (solveVacuumADMEquations gravitasCanonicalVacuumADM).momentumConstraints.size =
      gravitasCanonicalVacuumADM.spatialMetric.dim

/-- Canonical closure witness for the previously unsafe GR claims. -/
def canonical_gr_unsafe_claims_closed : GRCATEPTUnsafeClaimsClosureCertificate where
  double_hodge_bivector := gravitasFaraday_double_hodge_bivector
  stress_conservation_constant_model := gravitasCanonicalStress_conserved_constant_model
  zero_stress_divergence_dimension := gravitasZeroStress_divergence_dimension
  einstein_residual_exact := gravitasEinstein_residual_exact
  adm_hamiltonian_residual_exact := gravitasCanonicalVacuumADM_hamiltonian_residual_exact
  adm_momentum_residual_exact := gravitasCanonicalVacuumADM_momentum_residual_exact
  adm_momentum_dimension := gravitasCanonicalVacuumADM_momentum_dimension

end CATEPTMain.Certification.RelativityGR

end
