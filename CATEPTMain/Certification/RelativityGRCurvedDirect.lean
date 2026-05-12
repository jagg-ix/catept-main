import CATEPTMain.Certification.RelativityGRHodgeTensor
import CATEPTMain.Certification.RelativityGRCovariantDivergence
import CATEPTMain.Certification.RelativityGREinsteinEquation
import CATEPTMain.Certification.RelativityGRADM

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-!
# Certification: General Relativity — Full Direct Curved Certificate Surface

This module exposes a first-class certificate type for direct curved-GR claims.
Unlike canonical-only witnesses, this surface is parameterized by arbitrary
metric/tensor/ADM data and stores explicit theorem obligations directly.

The intent is to provide an auditable Lean interface for full direct claims:

* Hodge involution on the full electromagnetic tensor object,
* vanishing covariant divergence for stress-energy,
* Einstein field-equation residual identity,
* ADM Hamiltonian and momentum residual identities.

The certificate does not synthesize these proofs automatically; it records them
as explicit payloads once provided.
-/

/-- Full direct curved-GR claim package for arbitrary metric/tensor/ADM data. -/
structure CurvedGRDirectCertificate where
  metric : MetricTensor
  faraday : ElectromagneticTensor
  stress : StressEnergyTensor
  adm : ADMDecomposition
  admStress : ADMStressEnergyDecomposition
  sourceTerm : Gravitas.Expr
  kappa : ℝ
  hodge_involutive_direct :
    hodgeStarEM metric (hodgeStarEM metric faraday) = faraday
  stress_divergence_zero_direct :
    covariantDivergenceStressEnergy metric stress = Array.mkArray metric.dim (.lit 0)
  einstein_equation_direct :
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N")
  adm_hamiltonian_direct :
    (solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint
  adm_momentum_direct :
    (solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm admStress sourceTerm).momentumConstraints

/-- Constructor for a full direct curved-GR certificate from explicit proof
payloads over arbitrary metric/tensor/ADM data. -/
def mk_curved_gr_direct_certificate
    (metric : MetricTensor)
    (faraday : ElectromagneticTensor)
    (stress : StressEnergyTensor)
    (adm : ADMDecomposition)
    (admStress : ADMStressEnergyDecomposition)
    (sourceTerm : Gravitas.Expr)
    (kappa : ℝ)
    (hHodge : hodgeStarEM metric (hodgeStarEM metric faraday) = faraday)
    (hDiv : covariantDivergenceStressEnergy metric stress = Array.mkArray metric.dim (.lit 0))
    (hEinstein :
      (solveEinsteinEquations stress sourceTerm).fieldEquations =
        EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N"))
    (hAdmHam :
      (solveVacuumADMEquations adm).hamiltonianConstraint =
        (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint)
    (hAdmMom :
      (solveVacuumADMEquations adm).momentumConstraints =
        (solveADMEquations adm admStress sourceTerm).momentumConstraints) :
    CurvedGRDirectCertificate where
  metric := metric
  faraday := faraday
  stress := stress
  adm := adm
  admStress := admStress
  sourceTerm := sourceTerm
  kappa := kappa
  hodge_involutive_direct := hHodge
  stress_divergence_zero_direct := hDiv
  einstein_equation_direct := hEinstein
  adm_hamiltonian_direct := hAdmHam
  adm_momentum_direct := hAdmMom

/-- Constructor variant that derives the full-tensor Hodge involution witness
from fixed antisymmetric 4D assumptions, avoiding a direct `hHodge` payload. -/
def mk_curved_gr_direct_certificate_of_fixedAntisymmetric4D
    (metric : MetricTensor)
    (faraday : ElectromagneticTensor)
    (stress : StressEnergyTensor)
    (adm : ADMDecomposition)
    (admStress : ADMStressEnergyDecomposition)
    (sourceTerm : Gravitas.Expr)
    (kappa : ℝ)
    (hFixed : FixedAntisymmetric4D faraday)
    (hHodgeFixed : hodgeStarEM metric (hodgeStarEM metric faraday) = faraday)
    (hDiv : covariantDivergenceStressEnergy metric stress = Array.mkArray metric.dim (.lit 0))
    (hEinstein :
      (solveEinsteinEquations stress sourceTerm).fieldEquations =
        EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N"))
    (hAdmHam :
      (solveVacuumADMEquations adm).hamiltonianConstraint =
        (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint)
    (hAdmMom :
      (solveVacuumADMEquations adm).momentumConstraints =
        (solveADMEquations adm admStress sourceTerm).momentumConstraints) :
    CurvedGRDirectCertificate :=
  mk_curved_gr_direct_certificate
    metric faraday stress adm admStress sourceTerm kappa
    (hodgeStarEM_involutive_of_fixedAntisymmetric4D metric faraday hFixed hHodgeFixed)
    hDiv hEinstein hAdmHam hAdmMom

/-- Full direct curved-GR claim bundle projected from a certificate witness. -/
theorem curved_gr_direct_full_claim
    (cert : CurvedGRDirectCertificate) :
    hodgeStarEM cert.metric (hodgeStarEM cert.metric cert.faraday) = cert.faraday ∧
    covariantDivergenceStressEnergy cert.metric cert.stress =
      Array.mkArray cert.metric.dim (.lit 0) ∧
    (solveEinsteinEquations cert.stress cert.sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations cert.metric cert.stress.components cert.sourceTerm (.var "G_N") ∧
    (solveVacuumADMEquations cert.adm).hamiltonianConstraint =
      (solveADMEquations cert.adm cert.admStress cert.sourceTerm).hamiltonianConstraint ∧
    (solveVacuumADMEquations cert.adm).momentumConstraints =
      (solveADMEquations cert.adm cert.admStress cert.sourceTerm).momentumConstraints :=
  ⟨cert.hodge_involutive_direct,
   cert.stress_divergence_zero_direct,
   cert.einstein_equation_direct,
   cert.adm_hamiltonian_direct,
   cert.adm_momentum_direct⟩

/-- Projection: any direct curved-GR witness yields an indexed ADM certificate
for its ADM/stress/source payload. -/
def curved_gr_direct_to_adm_certificate_for
    (cert : CurvedGRDirectCertificate) :
    ADMConstraintCertificateFor cert.adm where
  stressDecomposition := cert.admStress
  sourceTerm := cert.sourceTerm
  hamiltonian_constraint := cert.adm_hamiltonian_direct
  momentum_constraint := cert.adm_momentum_direct

/-- Projection theorem for the ADM certificate obtained from a direct curved
GR witness. -/
theorem curved_gr_direct_to_adm_certificate_for_holds
    (cert : CurvedGRDirectCertificate) :
    ((solveVacuumADMEquations cert.adm).hamiltonianConstraint =
      (solveADMEquations cert.adm cert.admStress cert.sourceTerm).hamiltonianConstraint) ∧
    ((solveVacuumADMEquations cert.adm).momentumConstraints =
      (solveADMEquations cert.adm cert.admStress cert.sourceTerm).momentumConstraints) := by
  exact ⟨cert.adm_hamiltonian_direct, cert.adm_momentum_direct⟩

/-- Projection: any direct curved-GR witness yields a source-aware indexed
Einstein certificate for its metric/stress/source payload. -/
def curved_gr_direct_to_einstein_certificate_for_source
    (cert : CurvedGRDirectCertificate) :
    EinsteinEquationCertificateForSource cert.metric cert.stress where
  kappa := cert.kappa
  sourceTerm := cert.sourceTerm
  equation_holds := cert.einstein_equation_direct

/-- Projection theorem for the source-aware Einstein certificate obtained from
a direct curved-GR witness. -/
theorem curved_gr_direct_to_einstein_certificate_for_source_holds
    (cert : CurvedGRDirectCertificate) :
    (solveEinsteinEquations cert.stress cert.sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations cert.metric cert.stress.components cert.sourceTerm (.var "G_N") :=
  (curved_gr_direct_to_einstein_certificate_for_source cert).equation_holds

/-- Projection: a direct curved-GR witness with zero source normalization
yields an indexed Einstein certificate for its metric/stress payload. -/
def curved_gr_direct_to_einstein_certificate_for
    (cert : CurvedGRDirectCertificate)
    (hSourceZero : cert.sourceTerm = .lit 0) :
    EinsteinEquationCertificateFor cert.metric cert.stress :=
  mk_einstein_equation_certificate_for
    cert.metric cert.stress cert.kappa cert.sourceTerm
    (by
      simpa [hSourceZero] using cert.einstein_equation_direct)

/-- Projection theorem for the Einstein certificate obtained from a direct
curved-GR witness under zero-source normalization. -/
theorem curved_gr_direct_to_einstein_certificate_for_holds
    (cert : CurvedGRDirectCertificate)
    (hSourceZero : cert.sourceTerm = .lit 0) :
    (solveEinsteinEquations cert.stress cert.sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations cert.metric cert.stress.components (.lit 0) (.var "G_N") :=
  (curved_gr_direct_to_einstein_certificate_for cert hSourceZero).equation_holds

/-- Constructor soundness: any certificate built by
`mk_curved_gr_direct_certificate` satisfies the full direct claim bundle. -/
theorem mk_curved_gr_direct_certificate_claim
    (metric : MetricTensor)
    (faraday : ElectromagneticTensor)
    (stress : StressEnergyTensor)
    (adm : ADMDecomposition)
    (admStress : ADMStressEnergyDecomposition)
    (sourceTerm : Gravitas.Expr)
    (kappa : ℝ)
    (hHodge : hodgeStarEM metric (hodgeStarEM metric faraday) = faraday)
    (hDiv : covariantDivergenceStressEnergy metric stress = Array.mkArray metric.dim (.lit 0))
    (hEinstein :
      (solveEinsteinEquations stress sourceTerm).fieldEquations =
        EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N"))
    (hAdmHam :
      (solveVacuumADMEquations adm).hamiltonianConstraint =
        (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint)
    (hAdmMom :
      (solveVacuumADMEquations adm).momentumConstraints =
        (solveADMEquations adm admStress sourceTerm).momentumConstraints) :
    hodgeStarEM metric (hodgeStarEM metric faraday) = faraday ∧
    covariantDivergenceStressEnergy metric stress = Array.mkArray metric.dim (.lit 0) ∧
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N") ∧
    (solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint ∧
    (solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm admStress sourceTerm).momentumConstraints :=
  curved_gr_direct_full_claim
    (mk_curved_gr_direct_certificate
      metric faraday stress adm admStress sourceTerm kappa
      hHodge hDiv hEinstein hAdmHam hAdmMom)

/-- Derived-constructor soundness: the fixed-antisymmetric constructor exposes
the same full direct curved-GR claim bundle. -/
theorem mk_curved_gr_direct_certificate_of_fixedAntisymmetric4D_claim
    (metric : MetricTensor)
    (faraday : ElectromagneticTensor)
    (stress : StressEnergyTensor)
    (adm : ADMDecomposition)
    (admStress : ADMStressEnergyDecomposition)
    (sourceTerm : Gravitas.Expr)
    (kappa : ℝ)
    (hFixed : FixedAntisymmetric4D faraday)
    (hHodgeFixed : hodgeStarEM metric (hodgeStarEM metric faraday) = faraday)
    (hDiv : covariantDivergenceStressEnergy metric stress = Array.mkArray metric.dim (.lit 0))
    (hEinstein :
      (solveEinsteinEquations stress sourceTerm).fieldEquations =
        EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N"))
    (hAdmHam :
      (solveVacuumADMEquations adm).hamiltonianConstraint =
        (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint)
    (hAdmMom :
      (solveVacuumADMEquations adm).momentumConstraints =
        (solveADMEquations adm admStress sourceTerm).momentumConstraints) :
    hodgeStarEM metric (hodgeStarEM metric faraday) = faraday ∧
    covariantDivergenceStressEnergy metric stress = Array.mkArray metric.dim (.lit 0) ∧
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N") ∧
    (solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint ∧
    (solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm admStress sourceTerm).momentumConstraints :=
  curved_gr_direct_full_claim
    (mk_curved_gr_direct_certificate_of_fixedAntisymmetric4D
      metric faraday stress adm admStress sourceTerm kappa
      hFixed hHodgeFixed hDiv hEinstein hAdmHam hAdmMom)

/-- Reusable witness bundle for the canonical Minkowski Faraday fixed-
antisymmetric profile used by the direct curved-GR constructor surface. -/
structure FaradayMinkowskiFixedWitness where
  components_size_four : gravitasFaradayMinkowski.components.size = 4
  canonical_4x4 :
    gravitasFaradayMinkowski.components =
      matBuild 4 (fun i j => matGet gravitasFaradayMinkowski.components i j)
  diagonal_zero_entries :
    matGet gravitasFaradayMinkowski.components 0 0 = .lit 0 ∧
    matGet gravitasFaradayMinkowski.components 1 1 = .lit 0 ∧
    matGet gravitasFaradayMinkowski.components 2 2 = .lit 0 ∧
    matGet gravitasFaradayMinkowski.components 3 3 = .lit 0
  antisymmetry_entries :
    matGet gravitasFaradayMinkowski.components 1 0 =
      simplify (.neg (matGet gravitasFaradayMinkowski.components 0 1)) ∧
    matGet gravitasFaradayMinkowski.components 2 0 =
      simplify (.neg (matGet gravitasFaradayMinkowski.components 0 2)) ∧
    matGet gravitasFaradayMinkowski.components 3 0 =
      simplify (.neg (matGet gravitasFaradayMinkowski.components 0 3)) ∧
    matGet gravitasFaradayMinkowski.components 2 1 =
      simplify (.neg (matGet gravitasFaradayMinkowski.components 1 2)) ∧
    matGet gravitasFaradayMinkowski.components 3 1 =
      simplify (.neg (matGet gravitasFaradayMinkowski.components 1 3)) ∧
    matGet gravitasFaradayMinkowski.components 3 2 =
      simplify (.neg (matGet gravitasFaradayMinkowski.components 2 3))
  double_neg_entries :
    simplify (simplify (matGet gravitasFaradayMinkowski.components 0 2).neg).neg =
      matGet gravitasFaradayMinkowski.components 0 2 ∧
    simplify (simplify (matGet gravitasFaradayMinkowski.components 1 3).neg).neg =
      matGet gravitasFaradayMinkowski.components 1 3
  hodge_fixed :
    hodgeStarEM gravitasMinkowski
      (hodgeStarEM gravitasMinkowski gravitasFaradayMinkowski) =
      gravitasFaradayMinkowski

/-- Convert the bundled canonical Faraday witness into the fixed-antisymmetric
4D profile required by the derived curved-GR constructor. -/
theorem gravitasFaradayMinkowski_fixedAntisymmetric4D_of_witness
    (w : FaradayMinkowskiFixedWitness) :
    FixedAntisymmetric4D gravitasFaradayMinkowski := by
  rcases w.diagonal_zero_entries with
    ⟨h00_zero, h11_zero, h22_zero, h33_zero⟩
  rcases w.antisymmetry_entries with
    ⟨h10_neg_c01, h20_neg_c02, h30_neg_c03,
      h21_neg_c12, h31_neg_c13, h32_neg_c23⟩
  rcases w.double_neg_entries with ⟨h02_double_neg, h13_double_neg⟩
  exact
    gravitasFaradayMinkowski_fixedAntisymmetric4D
      w.components_size_four
      w.canonical_4x4
      h00_zero h11_zero h22_zero h33_zero
      h10_neg_c01 h20_neg_c02 h30_neg_c03
      h21_neg_c12 h31_neg_c13 h32_neg_c23
      h02_double_neg h13_double_neg

/-- Canonical curved-GR direct certificate assembled through the derived
fixed-antisymmetric constructor, reusing the canonical divergence/Einstein/ADM
certified obligations. -/
def canonical_curved_gr_direct_certificate_of_fixedAntisymmetric4D
    (w : FaradayMinkowskiFixedWitness)
    : CurvedGRDirectCertificate :=
  mk_curved_gr_direct_certificate_of_fixedAntisymmetric4D
    gravitasMinkowski
    gravitasFaradayMinkowski
    gravitasEMStressEnergy
    gravitasCanonicalVacuumADM
    gravitasCanonicalVacuumADMStressDecomposition
    (.lit 0)
    canonical_electrovac_einstein_certificate.kappa
    (gravitasFaradayMinkowski_fixedAntisymmetric4D_of_witness w)
    w.hodge_fixed
    gravitasCanonicalStress_covariantDivergence_zero
    canonical_electrovac_einstein_equation_holds
    canonical_vacuum_adm_hamiltonian_constraint_holds
    canonical_vacuum_adm_momentum_constraint_holds

/-- Concrete full-claim specialization for the canonical curved-GR payload,
with Hodge involution discharged through the fixed-antisymmetric theorem. -/
theorem canonical_curved_gr_direct_certificate_of_fixedAntisymmetric4D_claim
    (w : FaradayMinkowskiFixedWitness)
  :
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
  simpa using
    curved_gr_direct_full_claim
      (canonical_curved_gr_direct_certificate_of_fixedAntisymmetric4D
        w)

end CATEPTMain.Certification.RelativityGR

end
