import CATEPTMain.Certification.RelativityGRWitnessFreeFaraday
import CATEPTMain.Certification.RelativityGRWitnessFreeFaradayFamily

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

/-! ## Modular curved-GR closure subpredicates

The umbrella `IsCertifiedCurvedGRData` predicate is built out of four
independent closure subpredicates, one per physical sector.  Each subpredicate
is a single-field `Prop` structure so that upstream consumers can require
exactly the obligations they need without dragging in the full bundle. -/

/-- Hodge `★★` involution closure on the electromagnetic tensor object
relative to the given metric. -/
structure HasHodgeClosure
    (metric : MetricTensor)
    (faraday : ElectromagneticTensor) : Prop where
  hodge_involutive :
    hodgeStarEM metric (hodgeStarEM metric faraday) = faraday

/-- Vanishing covariant divergence closure for the stress-energy tensor
relative to the given metric. -/
structure HasStressConservation
    (metric : MetricTensor)
    (stress : StressEnergyTensor) : Prop where
  divergence_zero :
    covariantDivergenceStressEnergy metric stress =
      Array.mkArray metric.dim (.lit 0)

/-- Einstein field-equation residual closure at the solver output for the
given metric, stress-energy, and source term. -/
structure HasEinsteinClosure
    (metric : MetricTensor)
    (stress : StressEnergyTensor)
    (sourceTerm : Gravitas.Expr) : Prop where
  einstein_residual :
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components sourceTerm
        (.var "G_N")

/-- ADM Hamiltonian/momentum residual closure at the solver outputs for the
given ADM decomposition, ADM stress-energy decomposition, and source term. -/
structure HasADMClosure
    (adm : ADMDecomposition)
    (admStress : ADMStressEnergyDecomposition)
    (sourceTerm : Gravitas.Expr) : Prop where
  hamiltonian_residual :
    (solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint
  momentum_residual :
    (solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm admStress sourceTerm).momentumConstraints

/-! ### Standard closure constructors

Constructors that build a sector closure subpredicate from an upstream
witness bundle.  These let `IsCertifiedCurvedGRData` consumers discharge each
sector through a named theoretical condition instead of an inline term. -/

/-- **Hodge closure constructor (Faraday-of-Metric family).**

Whenever the electromagnetic tensor is generated as
`ElectromagneticTensor.ofMetric g A μ₀` and the Faraday-of-Metric fixed
witness `h : FaradayOfMetricFixedWitness g A μ₀` certifies the 4D
antisymmetric block, the `★★` Hodge involution closure
`HasHodgeClosure g (ElectromagneticTensor.ofMetric g A μ₀)` follows directly
from `faraday_ofMetric_hodge_involutive`. -/
def hodgeClosure_of_faradayOfMetric
    (g : MetricTensor)
    (A : Array Expr)
    (μ₀ : Expr)
    (h : FaradayOfMetricFixedWitness g A μ₀) :
    HasHodgeClosure g (ElectromagneticTensor.ofMetric g A μ₀) where
  hodge_involutive := faraday_ofMetric_hodge_involutive g A μ₀ h

/-- Umbrella admissibility predicate bundling all obligations needed to assemble
a `CurvedGRDirectCertificate` from explicit metric/tensor/ADM/source data.

This is the modular form: each physical sector is carried by a dedicated
subpredicate (`HasHodgeClosure`, `HasStressConservation`, `HasEinsteinClosure`,
`HasADMClosure`), making it possible to introduce sector improvements one at
a time. -/
structure IsCertifiedCurvedGRData
    (metric : MetricTensor)
    (faraday : ElectromagneticTensor)
    (stress : StressEnergyTensor)
    (adm : ADMDecomposition)
    (admStress : ADMStressEnergyDecomposition)
    (sourceTerm : Gravitas.Expr) : Prop where
  hodgeClosure : HasHodgeClosure metric faraday
  stressClosure : HasStressConservation metric stress
  einsteinClosure : HasEinsteinClosure metric stress sourceTerm
  admClosure : HasADMClosure adm admStress sourceTerm

/-! ### Compatibility projections (legacy flat field names)

The pre-modular form of `IsCertifiedCurvedGRData` exposed five flat fields
`hodge_involutive`, `stress_divergence_zero`, `einstein_residual`,
`adm_hamiltonian`, `adm_momentum`.  These projection theorems keep the
historical names available so downstream proofs do not have to be rewritten
to thread through the new subbundles. -/

theorem certifiedData_has_hodge
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (h : IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm) :
    HasHodgeClosure metric faraday :=
  h.hodgeClosure

theorem certifiedData_has_stress
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (h : IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm) :
    HasStressConservation metric stress :=
  h.stressClosure

theorem certifiedData_has_einstein
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (h : IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm) :
    HasEinsteinClosure metric stress sourceTerm :=
  h.einsteinClosure

theorem certifiedData_has_adm
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (h : IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm) :
    HasADMClosure adm admStress sourceTerm :=
  h.admClosure

/-- Flat-field projection: Hodge involution. -/
theorem IsCertifiedCurvedGRData.hodge_involutive
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (h : IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm) :
    hodgeStarEM metric (hodgeStarEM metric faraday) = faraday :=
  h.hodgeClosure.hodge_involutive

/-- Flat-field projection: stress divergence vanishes. -/
theorem IsCertifiedCurvedGRData.stress_divergence_zero
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (h : IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm) :
    covariantDivergenceStressEnergy metric stress =
      Array.mkArray metric.dim (.lit 0) :=
  h.stressClosure.divergence_zero

/-- Flat-field projection: Einstein residual identity. -/
theorem IsCertifiedCurvedGRData.einstein_residual
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (h : IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm) :
    (solveEinsteinEquations stress sourceTerm).fieldEquations =
      EinsteinTensor.fieldEquations metric stress.components sourceTerm
        (.var "G_N") :=
  h.einsteinClosure.einstein_residual

/-- Flat-field projection: ADM Hamiltonian residual identity. -/
theorem IsCertifiedCurvedGRData.adm_hamiltonian
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (h : IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm) :
    (solveVacuumADMEquations adm).hamiltonianConstraint =
      (solveADMEquations adm admStress sourceTerm).hamiltonianConstraint :=
  h.admClosure.hamiltonian_residual

/-- Flat-field projection: ADM momentum residual identity. -/
theorem IsCertifiedCurvedGRData.adm_momentum
    {metric : MetricTensor}
    {faraday : ElectromagneticTensor}
    {stress : StressEnergyTensor}
    {adm : ADMDecomposition}
    {admStress : ADMStressEnergyDecomposition}
    {sourceTerm : Gravitas.Expr}
    (h : IsCertifiedCurvedGRData metric faraday stress adm admStress sourceTerm) :
    (solveVacuumADMEquations adm).momentumConstraints =
      (solveADMEquations adm admStress sourceTerm).momentumConstraints :=
  h.admClosure.momentum_residual

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
  hodgeClosure :=
    { hodge_involutive :=
        hodgeStarEM_involutive_of_fixedAntisymmetric4D metric faraday hFixed hHodgeFixed }
  stressClosure := { divergence_zero := hDiv }
  einsteinClosure := { einstein_residual := hEinstein }
  admClosure :=
    { hamiltonian_residual := hAdmHam
      momentum_residual := hAdmMom }

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
  hodgeClosure :=
    { hodge_involutive := canonical_faraday_minkowski_fixed_witness.hodge_fixed }
  stressClosure :=
    { divergence_zero := gravitasCanonicalStress_covariantDivergence_zero }
  einsteinClosure :=
    { einstein_residual := canonical_electrovac_einstein_equation_holds }
  admClosure :=
    { hamiltonian_residual := canonical_vacuum_adm_hamiltonian_constraint_holds
      momentum_residual := canonical_vacuum_adm_momentum_constraint_holds }

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
