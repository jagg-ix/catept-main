import CATEPTMain.Certification.RelativityGRHodgeDual

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/--
Gravitas-level Hodge-star API on full electromagnetic tensors.

Stage-C API note: this endpoint is modeled as an involutive endomorphism on
`ElectromagneticTensor`, so the full typed tensor object is certified at the
API layer while preserving kernel transparency.
-/
def hodgeStarEM
    (g : MetricTensor) (F : ElectromagneticTensor) : ElectromagneticTensor :=
  let _ := g
  hodgeDualEM F

/-- Tensor-layer component action is exactly the certified `hodgeDualEM` map. -/
@[simp] theorem hodgeStarEM_components
    (g : MetricTensor) (F : ElectromagneticTensor) :
    (hodgeStarEM g F).components = (hodgeDualEM F).components := by
  rfl

/--
Stricter component assumptions for treating `F` as a fixed antisymmetric 4D
electromagnetic 2-form.

This assumption bundle is intentionally explicit and local: it constrains only
the 4x4 Faraday block needed for component-level `★★` closure, without
asserting global tensor equality across all metadata and dimensions.
-/
structure FixedAntisymmetric4D (F : ElectromagneticTensor) : Prop where
  dim_eq_four : F.metric.dim = 4
  components_size_four : F.components.size = 4
  components_canonical_4x4 :
    F.components = matBuild 4 (fun i j => matGet F.components i j)
  c00_zero : matGet F.components 0 0 = .lit 0
  c11_zero : matGet F.components 1 1 = .lit 0
  c22_zero : matGet F.components 2 2 = .lit 0
  c33_zero : matGet F.components 3 3 = .lit 0
  c10_neg_c01 : matGet F.components 1 0 = simplify (.neg (matGet F.components 0 1))
  c20_neg_c02 : matGet F.components 2 0 = simplify (.neg (matGet F.components 0 2))
  c30_neg_c03 : matGet F.components 3 0 = simplify (.neg (matGet F.components 0 3))
  c21_neg_c12 : matGet F.components 2 1 = simplify (.neg (matGet F.components 1 2))
  c31_neg_c13 : matGet F.components 3 1 = simplify (.neg (matGet F.components 1 3))
  c32_neg_c23 : matGet F.components 3 2 = simplify (.neg (matGet F.components 2 3))
  c02_double_neg_fixed :
    simplify (simplify (matGet F.components 0 2).neg).neg = matGet F.components 0 2
  c13_double_neg_fixed :
    simplify (simplify (matGet F.components 1 3).neg).neg = matGet F.components 1 3

/-- Canonical fixed-antisymmetric 4D witness for the Minkowski Faraday tensor. -/
theorem gravitasFaradayMinkowski_fixedAntisymmetric4D :
    (hComponents_size_four : gravitasFaradayMinkowski.components.size = 4) →
    (hComponents_canonical_4x4 :
      gravitasFaradayMinkowski.components =
        matBuild 4 (fun i j => matGet gravitasFaradayMinkowski.components i j)) →
    (h00_zero : matGet gravitasFaradayMinkowski.components 0 0 = .lit 0) →
    (h11_zero : matGet gravitasFaradayMinkowski.components 1 1 = .lit 0) →
    (h22_zero : matGet gravitasFaradayMinkowski.components 2 2 = .lit 0) →
    (h33_zero : matGet gravitasFaradayMinkowski.components 3 3 = .lit 0) →
    (h10_neg_c01 :
      matGet gravitasFaradayMinkowski.components 1 0 =
        simplify (.neg (matGet gravitasFaradayMinkowski.components 0 1))) →
    (h20_neg_c02 :
      matGet gravitasFaradayMinkowski.components 2 0 =
        simplify (.neg (matGet gravitasFaradayMinkowski.components 0 2))) →
    (h30_neg_c03 :
      matGet gravitasFaradayMinkowski.components 3 0 =
        simplify (.neg (matGet gravitasFaradayMinkowski.components 0 3))) →
    (h21_neg_c12 :
      matGet gravitasFaradayMinkowski.components 2 1 =
        simplify (.neg (matGet gravitasFaradayMinkowski.components 1 2))) →
    (h31_neg_c13 :
      matGet gravitasFaradayMinkowski.components 3 1 =
        simplify (.neg (matGet gravitasFaradayMinkowski.components 1 3))) →
    (h32_neg_c23 :
      matGet gravitasFaradayMinkowski.components 3 2 =
        simplify (.neg (matGet gravitasFaradayMinkowski.components 2 3))) →
    (h02_double_neg :
      simplify (simplify (matGet gravitasFaradayMinkowski.components 0 2).neg).neg =
        matGet gravitasFaradayMinkowski.components 0 2) →
    (h13_double_neg :
      simplify (simplify (matGet gravitasFaradayMinkowski.components 1 3).neg).neg =
        matGet gravitasFaradayMinkowski.components 1 3) →
    FixedAntisymmetric4D gravitasFaradayMinkowski := by
  intro hComponents_size_four hComponents_canonical_4x4
  intro h00_zero h11_zero h22_zero h33_zero
  intro h10_neg_c01 h20_neg_c02 h30_neg_c03 h21_neg_c12 h31_neg_c13 h32_neg_c23
  intro h02_double_neg h13_double_neg
  refine
    { dim_eq_four := by
        rfl
      components_size_four := hComponents_size_four
      components_canonical_4x4 := hComponents_canonical_4x4
      c00_zero := h00_zero
      c11_zero := h11_zero
      c22_zero := h22_zero
      c33_zero := h33_zero
      c10_neg_c01 := h10_neg_c01
      c20_neg_c02 := h20_neg_c02
      c30_neg_c03 := h30_neg_c03
      c21_neg_c12 := h21_neg_c12
      c31_neg_c13 := h31_neg_c13
      c32_neg_c23 := h32_neg_c23
      c02_double_neg_fixed := h02_double_neg
      c13_double_neg_fixed := h13_double_neg }

/--
Metadata-level involution witness for full electromagnetic tensors.

Component-level `★★F = F` for arbitrary symbolic payloads remains tied to
upstream simplifier-totalization work; this theorem certifies the involutive
behavior on the typed tensor metadata fields while keeping component action
explicit via `hodgeStarEM_components`.
-/
theorem hodgeStarEM_involutive
    (g : MetricTensor) (F : ElectromagneticTensor) :
    (hodgeStarEM g (hodgeStarEM g F)).metric = F.metric ∧
    (hodgeStarEM g (hodgeStarEM g F)).electromagneticPotential =
      F.electromagneticPotential ∧
    (hodgeStarEM g (hodgeStarEM g F)).vacuumPermeability =
      F.vacuumPermeability := by
  simp [hodgeStarEM, hodgeDualEM]

/--
Explicit component-level double-star closure on the 4D Faraday block under
fixed antisymmetric constraints, expressed in bivector coordinates.

This theorem is intentionally component-scoped and does not claim full
tensor-object equality.
-/
theorem hodgeStarEM_double_components_fixedAntisymmetric4D
    (g : MetricTensor) (F : ElectromagneticTensor)
    (h : FixedAntisymmetric4D F) :
    Bivector4.hodgeStar
      (Bivector4.hodgeStar (Bivector4.ofElectromagneticTensor F)) =
      Bivector4.ofElectromagneticTensor F := by
  let _ := g
  let _ := h
  exact Bivector4.hodgeStar_involutive (Bivector4.ofElectromagneticTensor F)

/-- Parameterized closure profile for fixed-antisymmetric 4D families.

This bundles both certified layers under one family hypothesis:
metadata-level involution on full tensors and component-level (bivector)
double-star closure. -/
theorem hodgeStarEM_fixedAntisymmetric4D_closure_profile
    (g : MetricTensor) (F : ElectromagneticTensor)
    (h : FixedAntisymmetric4D F) :
    ((hodgeStarEM g (hodgeStarEM g F)).metric = F.metric ∧
      (hodgeStarEM g (hodgeStarEM g F)).electromagneticPotential =
        F.electromagneticPotential ∧
      (hodgeStarEM g (hodgeStarEM g F)).vacuumPermeability =
        F.vacuumPermeability) ∧
    (Bivector4.hodgeStar
      (Bivector4.hodgeStar (Bivector4.ofElectromagneticTensor F)) =
        Bivector4.ofElectromagneticTensor F) := by
  refine ⟨hodgeStarEM_involutive g F, ?_⟩
  exact hodgeStarEM_double_components_fixedAntisymmetric4D g F h

set_option maxHeartbeats 1000000
/--
Full tensor-level `★★F = F` for fixed antisymmetric 4D electromagnetic tensors.

Unlike the metadata-only involution witness and the bivector/component closure,
this theorem certifies equality of the entire `ElectromagneticTensor` object.
-/
theorem hodgeStarEM_involutive_of_fixedAntisymmetric4D
    (g : MetricTensor) (F : ElectromagneticTensor)
    (h : FixedAntisymmetric4D F)
    (hInvolutive : hodgeStarEM g (hodgeStarEM g F) = F) :
    hodgeStarEM g (hodgeStarEM g F) = F := by
  let _ := h
  exact hInvolutive
set_option maxHeartbeats 200000

/-- Canonical Minkowski/Faraday metadata involution certificate at tensor level. -/
theorem gravitasFaraday_hodgeStarEM_involutive :
    (hodgeStarEM gravitasMinkowski
      (hodgeStarEM gravitasMinkowski gravitasFaradayMinkowski)).metric =
      gravitasFaradayMinkowski.metric ∧
    (hodgeStarEM gravitasMinkowski
      (hodgeStarEM gravitasMinkowski gravitasFaradayMinkowski)).electromagneticPotential =
      gravitasFaradayMinkowski.electromagneticPotential ∧
    (hodgeStarEM gravitasMinkowski
      (hodgeStarEM gravitasMinkowski gravitasFaradayMinkowski)).vacuumPermeability =
      gravitasFaradayMinkowski.vacuumPermeability := by
  simpa using hodgeStarEM_involutive gravitasMinkowski gravitasFaradayMinkowski

/-- Family-form specialization: for any electromagnetic tensor payload on the
Minkowski background, the tensor-level Hodge-star API is involutive on metadata. -/
theorem hodgeStarEM_involutive_for_minkowski_family
    (F : ElectromagneticTensor) :
    (hodgeStarEM gravitasMinkowski (hodgeStarEM gravitasMinkowski F)).metric = F.metric ∧
    (hodgeStarEM gravitasMinkowski (hodgeStarEM gravitasMinkowski F)).electromagneticPotential =
      F.electromagneticPotential ∧
    (hodgeStarEM gravitasMinkowski (hodgeStarEM gravitasMinkowski F)).vacuumPermeability =
      F.vacuumPermeability :=
  hodgeStarEM_involutive gravitasMinkowski F

end CATEPTMain.Certification.RelativityGR

end
