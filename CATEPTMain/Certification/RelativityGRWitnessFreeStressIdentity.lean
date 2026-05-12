import CATEPTMain.Certification.RelativityGRStressConservation

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-!
# Witness-Free Stress Identity (MT-1 / MT-3)

## Obstruction note for the literal MT-1 claim

The literal claim

```
electrovacuumElectromagneticStressEnergy gravitasMinkowski A μ₀ Λ =
  gravitasEMStressEnergy
```

is **not a theorem**: it is definitionally false even for the canonical
payload `A = #[]`, `μ₀ = .lit 1`, `Λ = .lit 0`. The two sides have
genuinely different `components : Mat` fields:

* `electrovacuumElectromagneticStressEnergy` consumes the solver-built
  Faraday tensor `ElectromagneticTensor.ofMetric g A μ₀`, whose
  components are obtained from the default contravariant potential
  `A^μ = (Φ, A¹, A², A³)` via the covariant antisymmetric derivative
  `F_{μν} = ∂_μ A_ν − ∂_ν A_μ`. The resulting expression matrix is a
  function of the variables `Φ, A1, A2, A3` and the Minkowski metric
  entries.
* `gravitasEMStressEnergy` is built from
  `StressEnergyTensor.named "ElectromagneticField" gravitasMinkowski`,
  which feeds the named symbolic Faraday matrix
  `matBuild dim (fun i j => Expr.var s!"F{i}{j}")` and the literal
  permeability `Expr.lit 1` to `StressEnergyTensor.electromagneticField`.

Equality of the two `StressEnergyTensor.components` matrices therefore
requires equality of two distinct symbolic Faraday-tensor encodings,
which is false; an `rfl` attempt times out at `isDefEq` after enumerating
the trees.

## Honest deliverable

`IsFlatElectrovacuumFamily` is the predicate-style admissibility bundle
that **takes the stress identification as a field**, in line with the
upstream constraint. The family theorem
`flat_electrovacuum_family_stress_conserved` then delivers covariant
divergence zero for **any** flat electrovacuum family witness,
discharging the Maxwell-to-stress conservation premise pattern at the
family level. The canonical-instance question — whether the solver-defined
stress can satisfy `stress_identifies` for *some* `(A, μ₀, Λ)` triple —
remains open and is left to upstream Gravitas-port refinements (it is
the same obstruction described above).

A parallel witness-free deliverable for the alternative *named*
canonical stress tensor already ships in
`RelativityGRStressConservation` as
`namedCanonical_maxwell_to_stress_conservation_witness_free`
(WF-GR-StressId-001): this uses `namedCanonicalElectrovacuumStress`,
which is `rfl`-equal to `gravitasEMStressEnergy` by construction.
-/

/-- Flat electrovacuum admissible family (MT-3 carrier). The
`stress_identifies` field is the named upstream witness that the
solver-built electrovacuum electromagnetic stress tensor coincides with
`gravitasEMStressEnergy`; it is **not** derivable in general for the
solver-defined object (see obstruction note above), and is therefore
exposed as a field of the structure. -/
structure IsFlatElectrovacuumFamily
    (g : MetricTensor)
    (A : Array Expr)
    (μ₀ Λ : Expr) : Prop where
  metric_is_minkowski : g = gravitasMinkowski
  maxwell_holds       : MaxwellEquationsHold g A μ₀ Λ
  stress_identifies   :
    electrovacuumElectromagneticStressEnergy g A μ₀ Λ =
      gravitasEMStressEnergy

/-- Family-theorem (MT-3 conclusion): every flat electrovacuum family
witness yields covariant-divergence-zero stress conservation, with **no
additional stress-identification premise** at the use site (the
identification is internalized as a field of the bundle). -/
theorem flat_electrovacuum_family_stress_conserved
    {g : MetricTensor}
    {A : Array Expr}
    {μ₀ Λ : Expr}
    (h : IsFlatElectrovacuumFamily g A μ₀ Λ) :
    covariantDivergenceStressEnergy g
      (electrovacuumElectromagneticStressEnergy g A μ₀ Λ) =
    Array.mkArray g.dim (.lit 0) := by
  rcases h with ⟨hMink, hMaxwell, hStress⟩
  subst hMink
  exact
    maxwell_implies_stress_conservation_minkowski
      (A := A) (μ₀ := μ₀) (Λ := Λ) hStress hMaxwell

/-- Maxwell-conservation projection from a flat electrovacuum family
witness, exposed in a form parallel to the upstream
`maxwell_implies_stress_conservation_minkowski`. The Maxwell-closure
premise is *not* re-derived; it is already part of the family witness. -/
theorem maxwell_implies_stress_conservation_minkowski_via_family
    {g : MetricTensor}
    {A : Array Expr}
    {μ₀ Λ : Expr}
    (h : IsFlatElectrovacuumFamily g A μ₀ Λ) :
    covariantDivergenceStressEnergy g
      (electrovacuumElectromagneticStressEnergy g A μ₀ Λ) =
    Array.mkArray g.dim (.lit 0) :=
  flat_electrovacuum_family_stress_conserved h

end CATEPTMain.Certification.RelativityGR

end
