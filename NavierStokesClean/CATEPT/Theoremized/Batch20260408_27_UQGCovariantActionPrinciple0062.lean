import NavierStokesClean.CATEPT.BianchiComplexEFEContracts

/-!
# Batch 20260408 Theoremization - CATEPT Row 27 (UQG Covariant Action Principle 0062)

Contract-level covariant-action wrappers for pointwise complex-EFE closure and
contracted conservation propagation through the dual-Bianchi contract layer.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B27

noncomputable section

open MeasureTheory
open NavierStokesClean.CATEPT

/-- Pointwise EFE equality implies contract satisfaction. -/
theorem row27_pointwise_eq_implies_contract
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α)
    (h : ∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :
    C.HoldsPointwise :=
  C.holdsPointwise_of_eq h

/-- Contract predicate is equivalent to pointwise residual vanishing. -/
theorem row27_contract_iff_residual_zero
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α) :
    C.HoldsPointwise ↔ (∀ x : α, C.residual x = 0) :=
  C.holdsPointwise_iff_residual_zero

/-- Pointwise contract closure propagates to contracted conservation. -/
theorem row27_contracted_conservation_of_contract
    {α : Type*} [MeasurableSpace α]
    (D : ComplexFieldDivergence α)
    (C : ComplexEFEContract α)
    (hC : C.HoldsPointwise) :
    D.ContractedConservation C :=
  ComplexFieldDivergence.contractedConservation_of_holdsPointwise (D := D) C hC

/-- Combined row-27 covariant-action contract witness package. -/
theorem row27_covariant_action_contract_bundle
    {α : Type*} [MeasurableSpace α]
    (D : ComplexFieldDivergence α)
    (C : ComplexEFEContract α)
    (hEq : ∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :
    C.HoldsPointwise ∧ D.ContractedConservation C := by
  have hC : C.HoldsPointwise := row27_pointwise_eq_implies_contract C hEq
  exact ⟨hC, row27_contracted_conservation_of_contract D C hC⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B27
