import NavierStokesClean.CATEPT.ComplexEinsteinMTPIBridge

/-!
# CAT/EPT Dual-Bianchi Contracts for Complex EFE (WP2)

This module formalizes the dual-Bianchi contract layer needed by the complex
Einstein bridge:

- abstract first/second Bianchi contract bundle
- abstract divergence operator laws (linearity over subtraction and constants)
- propagation theorem: pointwise complex-EFE equality implies contracted
  conservation under the divergence laws
- explicit PhysLean seed theorems for the div/curl and curl/curl identities

The geometric tensor-calculus realization can later instantiate these contracts.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

noncomputable section

open Space

/-- Abstract dual-Bianchi contract bundle.

`contractedConservation` is intentionally explicit so downstream files can record
whether it is obtained from the second Bianchi identity or provided separately. -/
structure DualBianchiContracts where
  firstBianchi : Prop
  secondBianchi : Prop
  contractedConservation : Prop
  secondImpliesContracted : secondBianchi → contractedConservation

/-- Contracted conservation follows whenever the second Bianchi contract is available. -/
theorem DualBianchiContracts.contracted_of_second
    (B : DualBianchiContracts) (h2 : B.secondBianchi) :
    B.contractedConservation :=
  B.secondImpliesContracted h2

/-- Abstract divergence operator on complex-valued fields with the laws needed
for EFE-to-conservation propagation. -/
structure ComplexFieldDivergence (α : Type*) where
  div : (α → ℂ) → (α → ℂ)
  map_sub : ∀ f g, div (fun x => f x - g x) = fun x => div f x - div g x
  map_const_mul : ∀ (κ : ℂ) f, div (fun x => κ * f x) = fun x => κ * div f x
  map_zero : div (fun _ => (0 : ℂ)) = fun _ => (0 : ℂ)

namespace ComplexFieldDivergence

variable {α : Type*} [MeasurableSpace α] (D : ComplexFieldDivergence α)

/-- Contracted conservation statement for a complex-EFE contract under `D`. -/
def ContractedConservation (C : ComplexEFEContract α) : Prop :=
  ∀ x, D.div C.einsteinComplex x = C.coupling * D.div C.stressComplex x

/-- If the pointwise complex-EFE residual vanishes, contracted conservation follows
for any divergence operator satisfying the contract laws in `ComplexFieldDivergence`. -/
theorem contractedConservation_of_holdsPointwise
    (C : ComplexEFEContract α)
    (hC : C.HoldsPointwise) :
    D.ContractedConservation C := by
  have hRes : C.residual = fun _ => (0 : ℂ) := funext hC
  have hDivEq :
      D.div (fun x => C.einsteinComplex x - C.coupling * C.stressComplex x) =
        D.div (fun _ => (0 : ℂ)) := by
    simpa [ComplexEFEContract.residual] using congrArg D.div hRes
  have hExpanded :
      (fun x => D.div C.einsteinComplex x - C.coupling * D.div C.stressComplex x)
        = fun _ => (0 : ℂ) := by
    simpa [D.map_sub, D.map_const_mul, D.map_zero] using hDivEq
  intro x
  have hx : D.div C.einsteinComplex x - C.coupling * D.div C.stressComplex x = 0 := by
    simpa using congrArg (fun f => f x) hExpanded
  exact sub_eq_zero.mp hx

end ComplexFieldDivergence

/-- PhysLean first-Bianchi seed analogue used in this program:
`div (curl f) = 0`. -/
theorem physlean_first_bianchi_seed
    (f : Space → EuclideanSpace ℝ (Fin 3))
    (hf : ContDiff ℝ 2 f) :
  ∇ ⬝ (∇ ⨯ f) = 0 :=
  NavierStokesClean.PhysLeanBridge.ns_div_curl_zero f hf

/-- PhysLean second-Bianchi seed analogue used in this program:
`curl (curl f) = grad(div f) - Δ f`. -/
theorem physlean_second_bianchi_seed
    (f : Space → EuclideanSpace ℝ (Fin 3))
    (hf : ContDiff ℝ 2 f) :
  ∇ ⨯ (∇ ⨯ f) = ∇ (∇ ⬝ f) - Δ f :=
  NavierStokesClean.PhysLeanBridge.ns_curl_of_curl f hf

end

end NavierStokesClean.CATEPT
