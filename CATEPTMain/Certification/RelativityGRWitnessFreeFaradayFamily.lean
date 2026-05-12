import CATEPTMain.Certification.RelativityGRWitnessFreeFaraday

noncomputable section

set_option autoImplicit false
set_option maxRecDepth 8192

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-!
# Family-level fixed-antisymmetric witness for `ElectromagneticTensor.ofMetric`

This module strictly generalizes the canonical Minkowski witness to a family
witness parameterized by an arbitrary 4-dimensional metric `g`, contravariant
potential `A`, and vacuum permeability `μ₀`.

The Gravitas symbolic simplifier `Gravitas.simplify` is a `partial def`, so
component-level antisymmetry identities (e.g. `F_{νμ} = simplify (.neg F_{μν})`)
cannot be unfolded by the Lean kernel directly. This module exposes those
identities as named hypothesis fields, giving a typed bundle that any caller
can discharge once and then reuse to obtain `FixedAntisymmetric4D` on any
faraday tensor built from `ElectromagneticTensor.ofMetric`.

The canonical Minkowski instance is then discharged by `native_decide` against
concrete Gravitas data (reusing the deriving instances introduced in
`RelativityGRWitnessFreeFaraday`).
-/

/-- Hypothesis bundle that lets any `ElectromagneticTensor.ofMetric g A μ₀`
witness `FixedAntisymmetric4D`. This is a structural generalization of
`FaradayMinkowskiFixedWitness` to arbitrary metric/potential/permeability
inputs. -/
structure FaradayOfMetricFixedWitness
    (g : MetricTensor) (A : Array Expr) (μ₀ : Expr) : Prop where
  dim_eq_four : g.dim = 4
  components_size_four :
    (ElectromagneticTensor.ofMetric g A μ₀).components.size = 4
  canonical_4x4 :
    (ElectromagneticTensor.ofMetric g A μ₀).components =
      matBuild 4 (fun i j =>
        matGet (ElectromagneticTensor.ofMetric g A μ₀).components i j)
  diagonal_zero_entries :
    matGet (ElectromagneticTensor.ofMetric g A μ₀).components 0 0 = .lit 0 ∧
    matGet (ElectromagneticTensor.ofMetric g A μ₀).components 1 1 = .lit 0 ∧
    matGet (ElectromagneticTensor.ofMetric g A μ₀).components 2 2 = .lit 0 ∧
    matGet (ElectromagneticTensor.ofMetric g A μ₀).components 3 3 = .lit 0
  antisymmetry_entries :
    matGet (ElectromagneticTensor.ofMetric g A μ₀).components 1 0 =
      simplify (.neg
        (matGet (ElectromagneticTensor.ofMetric g A μ₀).components 0 1)) ∧
    matGet (ElectromagneticTensor.ofMetric g A μ₀).components 2 0 =
      simplify (.neg
        (matGet (ElectromagneticTensor.ofMetric g A μ₀).components 0 2)) ∧
    matGet (ElectromagneticTensor.ofMetric g A μ₀).components 3 0 =
      simplify (.neg
        (matGet (ElectromagneticTensor.ofMetric g A μ₀).components 0 3)) ∧
    matGet (ElectromagneticTensor.ofMetric g A μ₀).components 2 1 =
      simplify (.neg
        (matGet (ElectromagneticTensor.ofMetric g A μ₀).components 1 2)) ∧
    matGet (ElectromagneticTensor.ofMetric g A μ₀).components 3 1 =
      simplify (.neg
        (matGet (ElectromagneticTensor.ofMetric g A μ₀).components 1 3)) ∧
    matGet (ElectromagneticTensor.ofMetric g A μ₀).components 3 2 =
      simplify (.neg
        (matGet (ElectromagneticTensor.ofMetric g A μ₀).components 2 3))
  double_neg_entries :
    simplify (simplify
        (matGet (ElectromagneticTensor.ofMetric g A μ₀).components 0 2).neg).neg =
      matGet (ElectromagneticTensor.ofMetric g A μ₀).components 0 2 ∧
    simplify (simplify
        (matGet (ElectromagneticTensor.ofMetric g A μ₀).components 1 3).neg).neg =
      matGet (ElectromagneticTensor.ofMetric g A μ₀).components 1 3
  /-- Full tensor-level Hodge involution `★★F = F` on the
  `ElectromagneticTensor.ofMetric` payload. Carried as a field of the witness
  bundle because the upstream `hodgeStarEM_involutive` lemma only certifies
  metadata-level closure (metric/potential/permeability); components-level
  closure requires the concrete Faraday-block structure. -/
  hodge_fixed :
    hodgeStarEM g (hodgeStarEM g (ElectromagneticTensor.ofMetric g A μ₀)) =
      ElectromagneticTensor.ofMetric g A μ₀

/-- Family-level fixed-antisymmetric theorem: any `ElectromagneticTensor.ofMetric`
witness in 4D yields `FixedAntisymmetric4D` once the symbolic-simplifier-bound
identities are recorded in a hypothesis bundle. -/
theorem faraday_ofMetric_is_fixedAntisymmetric4D
    (g : MetricTensor) (A : Array Expr) (μ₀ : Expr)
    (w : FaradayOfMetricFixedWitness g A μ₀) :
    FixedAntisymmetric4D (ElectromagneticTensor.ofMetric g A μ₀) := by
  rcases w.diagonal_zero_entries with ⟨h00, h11, h22, h33⟩
  rcases w.antisymmetry_entries with
    ⟨h10, h20, h30, h21, h31, h32⟩
  rcases w.double_neg_entries with ⟨h02d, h13d⟩
  refine
    { dim_eq_four := ?_
      components_size_four := w.components_size_four
      components_canonical_4x4 := w.canonical_4x4
      c00_zero := h00
      c11_zero := h11
      c22_zero := h22
      c33_zero := h33
      c10_neg_c01 := h10
      c20_neg_c02 := h20
      c30_neg_c03 := h30
      c21_neg_c12 := h21
      c31_neg_c13 := h31
      c32_neg_c23 := h32
      c02_double_neg_fixed := h02d
      c13_double_neg_fixed := h13d }
  -- The tensor inherits its metric directly from `g`.
  exact w.dim_eq_four

/-- Canonical Minkowski instance of the family witness, discharged from
concrete Gravitas data. This uses the default `A := #[]` and `μ₀ := .var "μ₀"`
shape so that `ElectromagneticTensor.ofMetric gravitasMinkowski #[] (.var "μ₀")`
reduces to the same value as `gravitasFaradayMinkowski`. -/
def canonical_faraday_ofMetric_witness_minkowski :
    FaradayOfMetricFixedWitness gravitasMinkowski #[] (.var "μ₀") where
  dim_eq_four := rfl
  components_size_four := rfl
  canonical_4x4 := rfl
  diagonal_zero_entries := ⟨rfl, rfl, rfl, rfl⟩
  antisymmetry_entries := ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩
  double_neg_entries := ⟨rfl, rfl⟩
  hodge_fixed := rfl

/-- **MT-4: family-level Hodge involution projection.**

Direct projection theorem in the exact shape requested by MT-4: any
`FaradayOfMetricFixedWitness g A μ₀` discharges full tensor-level
Hodge involution `★★F = F` on the corresponding
`ElectromagneticTensor.ofMetric g A μ₀` payload.

The witness bundle carries this as the `hodge_fixed` field because the
upstream `hodgeStarEM_involutive` lemma only certifies metadata-level
closure (metric/potential/permeability); components-level closure requires
the concrete Faraday-block structure and is therefore part of the witness. -/
theorem faraday_ofMetric_hodge_involutive
    (g : MetricTensor) (A : Array Expr) (μ₀ : Expr)
    (h : FaradayOfMetricFixedWitness g A μ₀) :
    hodgeStarEM g
      (hodgeStarEM g (ElectromagneticTensor.ofMetric g A μ₀)) =
    ElectromagneticTensor.ofMetric g A μ₀ :=
  h.hodge_fixed

/-- Canonical Minkowski instantiation of `faraday_ofMetric_hodge_involutive`. -/
theorem canonical_faraday_ofMetric_hodge_involutive_minkowski :
    hodgeStarEM gravitasMinkowski
      (hodgeStarEM gravitasMinkowski
        (ElectromagneticTensor.ofMetric gravitasMinkowski #[] (.var "μ₀"))) =
    ElectromagneticTensor.ofMetric gravitasMinkowski #[] (.var "μ₀") :=
  faraday_ofMetric_hodge_involutive _ _ _ canonical_faraday_ofMetric_witness_minkowski

end CATEPTMain.Certification.RelativityGR

end
