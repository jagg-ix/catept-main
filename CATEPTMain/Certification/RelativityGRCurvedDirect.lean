import CATEPTMain.Certification.RelativityGRHodgeTensor
import CATEPTMain.Certification.RelativityGRCovariantDivergence
import CATEPTMain.Certification.RelativityGREinsteinEquation
import CATEPTMain.Certification.RelativityGRADM

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas

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

end CATEPTMain.Certification.RelativityGR

end
