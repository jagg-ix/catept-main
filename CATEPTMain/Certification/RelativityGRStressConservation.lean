import CATEPTMain.Certification.RelativityGR

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- A 4D stress tensor with constant rational components. -/
structure ConstantStressTensor4 where
  entry : Fin 4 → Fin 4 → Rat

namespace ConstantStressTensor4

/-- Convert a constant stress tensor to a Gravitas expression matrix. -/
def toMat (T : ConstantStressTensor4) : Mat :=
  Array.ofFn (n := 4) (fun i : Fin 4 =>
    Array.ofFn (n := 4) (fun j : Fin 4 =>
      Expr.lit (T.entry i j)))

/-- Lift a constant tensor into the Gravitas `StressEnergyTensor` type,
using the canonical Minkowski background metric. -/
def toStressEnergyTensor (T : ConstantStressTensor4) : StressEnergyTensor where
  metric := gravitasMinkowski
  components := T.toMat
  idx1 := co
  idx2 := co

end ConstantStressTensor4

/-- Partial derivative of a constant coefficient is zero. -/
def flatConstPartialRat (_coord : Fin 4) (_value : Rat) : Rat :=
  0

/-- Flat-spacetime covariant divergence on constant-component stress tensors.
In Minkowski space, Christoffel corrections vanish and only partial derivatives
remain; for constants those derivatives are zero component-wise. -/
def flatConstantCovariantDivergenceRat (T : ConstantStressTensor4) : Fin 4 → Rat :=
  fun ν => ∑ μ : Fin 4, flatConstPartialRat μ (T.entry μ ν)

/-- Expression-level view of the constant-model divergence residual. -/
def flatConstantCovariantDivergenceExpr (T : ConstantStressTensor4) : Fin 4 → Expr :=
  fun ν => Expr.lit (flatConstantCovariantDivergenceRat T ν)

/-- Conservation law in the kernel-transparent constant-coefficient model:
`∇^μ T_{μν} = 0` for all constant stress tensors in flat spacetime. -/
theorem flat_constant_stress_conserved_rat
    (T : ConstantStressTensor4) (ν : Fin 4) :
    flatConstantCovariantDivergenceRat T ν = 0 := by
  simp [flatConstantCovariantDivergenceRat, flatConstPartialRat]

/-- Expression-level conservation statement for constant stress tensors. -/
theorem flat_constant_stress_conserved_expr
    (T : ConstantStressTensor4) (ν : Fin 4) :
    flatConstantCovariantDivergenceExpr T ν = Expr.lit 0 := by
  simp [flatConstantCovariantDivergenceExpr, flat_constant_stress_conserved_rat]

/-- Canonical nonzero flat-spacetime stress tensor (radiation-like diagonal):
`T00 = 3`, `T11 = T22 = T33 = 1`, off-diagonal entries `0`. -/
def canonicalRadiationStressTensor4 : ConstantStressTensor4 where
  entry := fun i j =>
    match i.1, j.1 with
    | 0, 0 => 3
    | 1, 1 => 1
    | 2, 2 => 1
    | 3, 3 => 1
    | _, _ => 0

/-- The canonical radiation tensor is manifestly nonzero (`T00 = 3`). -/
theorem canonical_radiation_stress_nonzero :
    canonicalRadiationStressTensor4.entry ⟨0, by decide⟩ ⟨0, by decide⟩ = 3 :=
  rfl

/-- Concrete kernel-transparent conservation theorem:
`∇^μ T_{μν} = 0` for the canonical nonzero radiation stress tensor
in the flat constant-component model. -/
theorem canonical_radiation_stress_conserved :
    flatConstantCovariantDivergenceExpr canonicalRadiationStressTensor4 =
      (fun _ => Expr.lit 0) := by
  funext ν
  exact flat_constant_stress_conserved_expr canonicalRadiationStressTensor4 ν

/-- Family-form conservation theorem: every constant-component 4D stress tensor
in the flat model has identically zero covariant-divergence residual. -/
theorem flat_constant_stress_conserved_for_all_constant_T :
    ∀ T : ConstantStressTensor4,
      flatConstantCovariantDivergenceExpr T = (fun _ => Expr.lit 0) := by
  intro T
  funext ν
  exact flat_constant_stress_conserved_expr T ν

end CATEPTMain.Certification.RelativityGR

end
