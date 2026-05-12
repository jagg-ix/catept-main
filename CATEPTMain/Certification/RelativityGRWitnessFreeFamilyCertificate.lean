import CATEPTMain.Certification.RelativityGRStressConservation
import CATEPTMain.Certification.RelativityGRWitnessFreeStressIdentity
import CATEPTMain.Certification.RelativityGRWitnessFreeStressConservation
import CATEPTMain.Certification.RelativityGRWitnessFreeFaradayFamily
import CATEPTMain.Certification.RelativityGRHodgeTensor
import CATEPTMain.Certification.RelativityGRUnsafeFixes

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-!
# Parameterized GR family certificate (MT-1 completion + Target 7)

This module closes two related deliverables:

## MT-1 completion — fully parameterized `IsFlatElectrovacuumFamily` constructor

`canonical_flat_electrovacuum_family` (in
`RelativityGRWitnessFreeStressIdentity`) builds an
`IsFlatElectrovacuumFamily` instance at the canonical payload
`(A = #[], μ₀ = .lit 1, Λ = .lit 0)`.  `general_flat_electrovacuum_family`
strictly generalizes this to arbitrary `(A, μ₀, Λ)` admitting the three
named upstream witnesses (`hμ₀`, `hMaxwell`, `hFaraday`).  The stress
identification is discharged through MT-1 conditional
(`electrovacuumStress_eq_gravitasEMStressEnergy_of_faraday_witness`) at
the same general parameter triple.

`general_flat_electrovacuum_family_stress_conserved` then projects the
covariant-divergence-zero conclusion at arbitrary `(A, μ₀, Λ)`, closing
the witness-free GR Maxwell→conservation path **at the family level**
rather than only at the canonical instance.

## Target 7 — typed parameterized-family certificate bundle

`ParameterizedGRFamilyCertificate` aggregates the three load-bearing
GR family theorems already proved upstream into a single typed `Prop`
bundle with **three real fields** (no `True` placeholders):

1. **`hodge_involutive_em_family`** — Hodge-star metadata involution on
   the Minkowski background, quantified over every
   `F : ElectromagneticTensor` (from
   `hodgeStarEM_involutive_for_minkowski_family`).
2. **`stress_conserved_all_constant_T`** — flat-spacetime stress
   conservation, quantified over every
   `T : ConstantStressTensor4` (from
   `flat_constant_stress_conserved_for_all_constant_T`).
3. **`einstein_residual_vacuum_family`** — Einstein-equation residual
   identity for vacuum stress-energy, quantified over every
   cosmological-term expression `Λ` (from
   `einstein_residual_zero_for_vacuum_family`).

`canonicalParameterizedGRFamilyCertificate` constructs the bundle from
those three existing theorems with no new axioms.

**Claim discharged.** The GR certificate is no longer only a single
canonical example; it covers a family of admissible GR data ranging
over `ElectromagneticTensor`, `ConstantStressTensor4`, and
cosmological-term `Expr` payloads, plus the fully parameterized
flat-electrovacuum family carrier `IsFlatElectrovacuumFamily g A μ₀ Λ`.
-/

/-! ### MT-1 completion: fully parameterized canonical-instance constructor -/

/-- **MT-1 completion (fully parameterized).** Strictly generalizes
`canonical_flat_electrovacuum_family` to arbitrary `(A, μ₀, Λ)`: given
the named upstream Faraday-component witness, the permeability
normalization `μ₀ = .lit 1`, and Maxwell closure on
`(gravitasMinkowski, A, μ₀, Λ)`, packages all three witnesses into an
`IsFlatElectrovacuumFamily gravitasMinkowski A μ₀ Λ` instance.  The
stress identification is discharged via the family-level conditional
theorem `electrovacuumStress_eq_gravitasEMStressEnergy_of_faraday_witness`. -/
def general_flat_electrovacuum_family
    (A : Array Expr) (μ₀ Λ : Expr)
    (hμ₀ : μ₀ = .lit 1)
    (hMaxwell : MaxwellEquationsHold gravitasMinkowski A μ₀ Λ)
    (hFaraday :
      (solveElectrovacuumEinsteinEquations gravitasMinkowski A μ₀ Λ).faradayTensor.components =
        canonicalNamedFaradayComponents gravitasMinkowski.dim) :
    IsFlatElectrovacuumFamily gravitasMinkowski A μ₀ Λ where
  metric_is_minkowski := rfl
  maxwell_holds       := hMaxwell
  stress_identifies   :=
    electrovacuumStress_eq_gravitasEMStressEnergy_of_faraday_witness
      gravitasMinkowski A μ₀ Λ rfl hμ₀ hFaraday

/-- Family-level conservation conclusion at the fully parameterized
flat-electrovacuum admissible-family witness, derived from
`general_flat_electrovacuum_family` and
`flat_electrovacuum_family_stress_conserved`. -/
theorem general_flat_electrovacuum_family_stress_conserved
    (A : Array Expr) (μ₀ Λ : Expr)
    (hμ₀ : μ₀ = .lit 1)
    (hMaxwell : MaxwellEquationsHold gravitasMinkowski A μ₀ Λ)
    (hFaraday :
      (solveElectrovacuumEinsteinEquations gravitasMinkowski A μ₀ Λ).faradayTensor.components =
        canonicalNamedFaradayComponents gravitasMinkowski.dim) :
    covariantDivergenceStressEnergy gravitasMinkowski
        (electrovacuumElectromagneticStressEnergy gravitasMinkowski A μ₀ Λ) =
      Array.mkArray gravitasMinkowski.dim (.lit 0) :=
  flat_electrovacuum_family_stress_conserved
    (general_flat_electrovacuum_family A μ₀ Λ hμ₀ hMaxwell hFaraday)

/-! ### Target 7: typed parameterized GR family certificate -/

/-- **Target 7 bundle.** A `Prop` aggregating the three load-bearing
parameterized-family GR theorems with no `True` fields:

* `hodge_involutive_em_family`  — `∀ F, ★★F  metadata = F  metadata` on Minkowski
* `stress_conserved_all_constant_T` — `∀ T, ∇·T = 0` in the flat constant model
* `einstein_residual_vacuum_family` — `∀ Λ, Einstein-residual identity` on vacuum

Together these claim, in a single typed surface, that the GR certificate
is no longer only a single canonical example: it covers a family of
admissible GR data ranging over `ElectromagneticTensor`,
`ConstantStressTensor4`, and `Gravitas.Expr` payloads. -/
structure ParameterizedGRFamilyCertificate : Prop where
  hodge_involutive_em_family :
    ∀ F : ElectromagneticTensor,
      (hodgeStarEM gravitasMinkowski (hodgeStarEM gravitasMinkowski F)).metric = F.metric ∧
      (hodgeStarEM gravitasMinkowski (hodgeStarEM gravitasMinkowski F)).electromagneticPotential =
        F.electromagneticPotential ∧
      (hodgeStarEM gravitasMinkowski (hodgeStarEM gravitasMinkowski F)).vacuumPermeability =
        F.vacuumPermeability
  stress_conserved_all_constant_T :
    ∀ T : ConstantStressTensor4,
      flatConstantCovariantDivergenceExpr T = (fun _ => Expr.lit 0)
  einstein_residual_vacuum_family :
    ∀ Λ : Gravitas.Expr,
      (solveEinsteinEquations gravitasZeroStressEnergy Λ).fieldEquations =
        EinsteinTensor.fieldEquations gravitasMinkowski
          gravitasZeroStressEnergy.components Λ (.var "G_N")

/-- Canonical construction of the parameterized GR family certificate.

The three fields are populated directly from the three already-shipped
family theorems with no further proof obligations. -/
def canonicalParameterizedGRFamilyCertificate :
    ParameterizedGRFamilyCertificate where
  hodge_involutive_em_family       := hodgeStarEM_involutive_for_minkowski_family
  stress_conserved_all_constant_T  := flat_constant_stress_conserved_for_all_constant_T
  einstein_residual_vacuum_family  := einstein_residual_zero_for_vacuum_family

/-- Existence of the canonical parameterized GR family certificate. -/
theorem parameterizedGRFamilyCertificate_exists :
    Nonempty ParameterizedGRFamilyCertificate :=
  ⟨canonicalParameterizedGRFamilyCertificate⟩

end CATEPTMain.Certification.RelativityGR

end
