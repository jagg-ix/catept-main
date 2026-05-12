import CATEPTMain.Certification.RelativityGRWitnessFreeFaraday

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-!
# Witness-free curved-GR direct certificate from certified data
(WF-GR-009 / WF-GR-010)

This module exposes a single Prop-level umbrella predicate
`IsCertifiedCurvedGRData` that bundles the five obligations needed to
assemble a `CurvedGRDirectCertificate`:

* the Hodge `★★` involution on the full electromagnetic tensor object,
* vanishing covariant divergence of stress-energy,
* the Einstein field-equation residual identity at the solver output,
* the ADM Hamiltonian residual identity at the solver output,
* the ADM momentum residual identity at the solver output.

A caller that supplies any concrete metric/Faraday/stress/ADM/source payload
together with this umbrella predicate gets back a fully-assembled curved-GR
direct certificate. This is the realistic "full curved GR" milestone: it is
witness-free relative to a named admissibility predicate on certified data
inputs, rather than relative to arbitrary metrics.

The canonical Minkowski instance discharges the predicate from already-proved
sector theorems and from the witness-free canonical Faraday module.
-/

/-- Umbrella admissibility predicate bundling all obligations needed to assemble
a `CurvedGRDirectCertificate` from explicit metric/tensor/ADM/source data. -/
structure IsCertifiedCurvedGRData
    (metric : MetricTensor)
    (faraday : ElectromagneticTensor)
    (stress : StressEnergyTensor)
    (adm : ADMDecomposition)
    (admStress : ADMStressEnergyDecomposition)
    (sourceTerm : Gravitas.Expr) : Prop where
  hodge_involutive :
    hodgeStarEM metric (hodgeStarEM metric faraday) = faraday
  stress_divergence_zero :
    covariantDivergenceStressEnergy metric stress = Array.mkArray metric.dim (.lit 0)
  einstein_residual :
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N")
  adm_hamiltonian :
    (solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint
  adm_momentum :
    (solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm admStress sourceTerm).momentumConstraints

/-- Assemble a full `CurvedGRDirectCertificate` from any certified curved-GR
data bundle. -/
def curved_gr_direct_certificate_of_certified_data
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (kappa : ℝ)
    (h : IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm) :
    CurvedGRDirectCertificate :=
  mk_curved_gr_direct_certificate
    metric faraday stress adm admStress sourceTerm kappa
    h.hodge_involutive
    h.stress_divergence_zero
    h.einstein_residual
    h.adm_hamiltonian
    h.adm_momentum

/-- Full-claim theorem: any certified curved-GR data bundle directly
implies the five-conjunction direct curved-GR claim. -/
theorem certified_curved_gr_data_implies_full_direct_claim
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (h : IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm) :
    hodgeStarEM metric (hodgeStarEM metric faraday) = faraday ∧
    covariantDivergenceStressEnergy metric stress =
      Array.mkArray metric.dim (.lit 0) ∧
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N") ∧
    (solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint ∧
    (solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm admStress sourceTerm).momentumConstraints :=
  ⟨h.hodge_involutive, h.stress_divergence_zero, h.einstein_residual,
   h.adm_hamiltonian, h.adm_momentum⟩

/-- Builder lemma: a certified-curved-GR data bundle can be assembled from a
`FixedAntisymmetric4D` witness on the Faraday tensor together with the four
remaining residual identities. The Hodge involution is derived from the
fixed-antisymmetric profile. -/
theorem isCertifiedCurvedGRData_of_fixedAntisymmetric4D
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (hFixed : FixedAntisymmetric4D faraday)
    (hHodgeFixed : hodgeStarEM metric (hodgeStarEM metric faraday) = faraday)
    (hDiv : covariantDivergenceStressEnergy metric stress =
      Array.mkArray metric.dim (.lit 0))
    (hEinstein :
      (solveEinsteinEquations stress sourceTerm).fieldEquations =
        EinsteinTensor.fieldEquations metric stress.components sourceTerm (.var "G_N"))
    (hAdmHam :
      (solveVacuumADMEquations adm).hamiltonianConstraint =
        (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint)
    (hAdmMom :
      (solveVacuumADMEquations adm).momentumConstraints =
        (solveADMEquations adm admStress sourceTerm).momentumConstraints) :
    IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm where
  hodge_involutive :=
    hodgeStarEM_involutive_of_fixedAntisymmetric4D metric faraday hFixed hHodgeFixed
  stress_divergence_zero := hDiv
  einstein_residual := hEinstein
  adm_hamiltonian := hAdmHam
  adm_momentum := hAdmMom

/-- Canonical Minkowski instance of the certified-curved-GR data umbrella:
all five obligations are discharged from existing canonical sector theorems
plus the witness-free canonical Faraday derivation. -/
theorem canonical_certified_curved_gr_data :
    IsCertifiedCurvedGRData
      gravitasMinkowski
      gravitasFaradayMinkowski
      gravitasEMStressEnergy
      gravitasCanonicalVacuumADM
      gravitasCanonicalVacuumADMStressDecomposition
      (.lit 0) where
  hodge_involutive := canonical_faraday_minkowski_fixed_witness.hodge_fixed
  stress_divergence_zero := gravitasCanonicalStress_covariantDivergence_zero
  einstein_residual := canonical_electrovac_einstein_equation_holds
  adm_hamiltonian := canonical_vacuum_adm_hamiltonian_constraint_holds
  adm_momentum := canonical_vacuum_adm_momentum_constraint_holds

/-- Canonical witness-free curved-GR direct certificate assembled through the
umbrella admissibility predicate. -/
def canonical_curved_gr_direct_certificate_of_certified_data :
    CurvedGRDirectCertificate :=
  curved_gr_direct_certificate_of_certified_data
    canonical_electrovac_einstein_certificate.kappa
    canonical_certified_curved_gr_data

/-- Concrete full-claim specialization for the canonical certified-data
assembly. -/
theorem canonical_certified_curved_gr_data_full_claim :
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
        gravitasCanonicalVacuumADMStressDecomposition (.lit 0)).momentumConstraints :=
  certified_curved_gr_data_implies_full_direct_claim
    canonical_certified_curved_gr_data

end CATEPTMain.Certification.RelativityGR

end
