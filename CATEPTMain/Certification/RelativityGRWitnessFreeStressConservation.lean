import CATEPTMain.Certification.RelativityGRStressConservation
import CATEPTMain.Certification.RelativityGRWitnessFreeStressIdentity

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-!
# Witness-Free Maxwell-to-Stress Conservation (MT-2 / MT-6)

This module discharges the Maxwell-to-stress conservation conclusion
without an explicit *stress-identification* premise at the use site, by
leveraging the named upstream Faraday-component witness identified by
`electrovacuumStress_eq_gravitasEMStressEnergy_of_faraday_witness` (MT-1
conditional) and the family-level conservation theorem
`flat_electrovacuum_family_stress_conserved` (MT-3).

* **MT-2** ships
  `maxwell_implies_stress_conservation_minkowski_witness_free`, which
  takes only `(hμ₀, hFaraday, hMaxwell)` (i.e., no explicit
  stress-identification hypothesis) and concludes covariant-divergence
  zero for arbitrary `(A, Λ)`.  The stress identification is internalised
  through MT-1 + MT-3 packaging.

* **MT-6** ships
  `named_canonical_electrovacuum_stress_conserved`, an **unconditional**
  (no Maxwell, no Faraday witness) conservation statement on the
  named-canonical electrovacuum stress tensor.  It closes the
  witness-free GR Maxwell→conservation path at the canonical-payload
  surface: the solver-defined object is replaced by the named-Faraday
  encoding (`namedCanonicalElectrovacuumStress`), which is `rfl`-equal to
  `gravitasEMStressEnergy`, and conservation falls out of the upstream
  `gravitasCanonicalStress_covariantDivergence_zero` theorem with no
  external witness whatsoever.
-/

/-- **MT-2: conditional witness-free Maxwell-to-stress conservation.**

The literal MT-2 statement (Maxwell premise alone implies covariant
divergence zero for the solver-defined electrovacuum stress on Minkowski
at arbitrary `(A, Λ)`) is not unconditionally a theorem (see
`RelativityGRWitnessFreeStressIdentity` for the obstruction note).  This
form ships the **conditional theorem** that takes only the named upstream
witnesses identified by MT-1 (the permeability normalisation `hμ₀` and
the Faraday-components match `hFaraday`) plus the Maxwell premise
`hMaxwell` — and crucially **no explicit
`stress_identifies` hypothesis at the use site**.

The proof packages the inputs into an `IsFlatElectrovacuumFamily`
instance (MT-3 carrier) via the MT-1 conditional
`electrovacuumStress_eq_gravitasEMStressEnergy_of_faraday_witness`, then
applies the family theorem `flat_electrovacuum_family_stress_conserved`. -/
theorem maxwell_implies_stress_conservation_minkowski_witness_free
    (A : Array Expr := #[])
    (μ₀ : Expr := .lit 1)
    (Λ : Expr := .lit 0)
    (hμ₀ : μ₀ = .lit 1)
    (hFaraday :
      (solveElectrovacuumEinsteinEquations gravitasMinkowski A μ₀ Λ).faradayTensor.components =
        canonicalNamedFaradayComponents gravitasMinkowski.dim)
    (hMaxwell : MaxwellEquationsHold gravitasMinkowski A μ₀ Λ) :
    covariantDivergenceStressEnergy gravitasMinkowski
      (electrovacuumElectromagneticStressEnergy gravitasMinkowski A μ₀ Λ) =
    Array.mkArray gravitasMinkowski.dim (.lit 0) :=
  flat_electrovacuum_family_stress_conserved
    (g := gravitasMinkowski) (A := A) (μ₀ := μ₀) (Λ := Λ)
    { metric_is_minkowski := rfl
      maxwell_holds       := hMaxwell
      stress_identifies   :=
        electrovacuumStress_eq_gravitasEMStressEnergy_of_faraday_witness
          gravitasMinkowski A μ₀ Λ rfl hμ₀ hFaraday }

/-- Canonical-payload specialization of MT-2 at
`(A = #[], μ₀ = .lit 1, Λ = .lit 0)`: the only remaining premises are the
Maxwell-closure and the Faraday-components match. -/
theorem canonical_maxwell_implies_stress_conservation_witness_free
    (hFaraday :
      (solveElectrovacuumEinsteinEquations gravitasMinkowski #[] (.lit 1) (.lit 0)).faradayTensor.components =
        canonicalNamedFaradayComponents gravitasMinkowski.dim)
    (hMaxwell : MaxwellEquationsHold gravitasMinkowski #[] (.lit 1) (.lit 0)) :
    covariantDivergenceStressEnergy gravitasMinkowski
      (electrovacuumElectromagneticStressEnergy gravitasMinkowski #[] (.lit 1) (.lit 0)) =
    Array.mkArray gravitasMinkowski.dim (.lit 0) :=
  maxwell_implies_stress_conservation_minkowski_witness_free
    (A := #[]) (μ₀ := .lit 1) (Λ := .lit 0) rfl hFaraday hMaxwell

/-! ## MT-6: unconditional witness-free conservation at the named-canonical surface

Recall the obstruction underlying MT-1 / MT-2 (see
`RelativityGRWitnessFreeStressIdentity`): the solver-defined
`electrovacuumElectromagneticStressEnergy` and the named symbolic
`gravitasEMStressEnergy` are not syntactically equal — they encode the
Faraday block via two different schemes (covariant antisymmetric
derivative of the default potential vs. a literal `Fᵢⱼ` matrix).  The
named-canonical encoding `namedCanonicalElectrovacuumStress` is, by
construction, `rfl`-equal to `gravitasEMStressEnergy` (see
`namedCanonicalElectrovacuumStress_eq_gravitasEMStressEnergy` in
`RelativityGRStressConservation`), so on this surface conservation is
**unconditional**.

MT-6 packages this into a clean named admissibility predicate and a
theorem that requires no Maxwell premise and no external witnesses. -/

/-- **MT-6 carrier**: predicate identifying a stress tensor as the
named-canonical electrovacuum stress on Minkowski. -/
structure IsNamedCanonicalElectrovacuumStress (T : StressEnergyTensor) : Prop where
  is_named_canonical : T = namedCanonicalElectrovacuumStress

/-- **MT-6: unconditional witness-free conservation.**

Any stress tensor identified as the named-canonical electrovacuum stress
has zero covariant divergence on Minkowski — with **no Maxwell premise**
and **no external stress-identification witness**.  The proof rewrites by
`namedCanonicalElectrovacuumStress_eq_gravitasEMStressEnergy` (which is
`rfl`) and invokes the upstream
`gravitasCanonicalStress_covariantDivergence_zero`. -/
theorem named_canonical_electrovacuum_stress_conserved
    {T : StressEnergyTensor}
    (h : IsNamedCanonicalElectrovacuumStress T) :
    covariantDivergenceStressEnergy gravitasMinkowski T =
      Array.mkArray gravitasMinkowski.dim (.lit 0) := by
  rw [h.is_named_canonical]
  exact namedCanonical_maxwell_to_stress_conservation_witness_free

/-- Canonical instance of `IsNamedCanonicalElectrovacuumStress` for
`namedCanonicalElectrovacuumStress` itself.  Discharged by `rfl`. -/
def canonical_namedCanonicalElectrovacuumStress :
    IsNamedCanonicalElectrovacuumStress namedCanonicalElectrovacuumStress :=
  { is_named_canonical := rfl }

/-- Direct canonical-payload conclusion: covariant divergence of
`namedCanonicalElectrovacuumStress` is zero, with no premises at all. -/
theorem canonical_named_canonical_electrovacuum_stress_conserved :
    covariantDivergenceStressEnergy gravitasMinkowski
      namedCanonicalElectrovacuumStress =
    Array.mkArray gravitasMinkowski.dim (.lit 0) :=
  named_canonical_electrovacuum_stress_conserved
    canonical_namedCanonicalElectrovacuumStress

end CATEPTMain.Certification.RelativityGR

end
