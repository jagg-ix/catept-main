--import Mathlib.RingTheory.Coalgebra
import HopfLean.Coalgebra
/-
Uncommenting the Mathlib coalgebra import and commenting out the
HopfLean import will also work, we use the HopfLean.coalgebra file only
for clarity (the Mathlib file has some extra pieces we don't need)
-/
import Mathlib.RingTheory.TensorProduct

/-!
# Bialgebras
In this file we define `Bialgebra`, and provide instances for:

* Commutative semirings: `CommSemiring.toBialgebra`
-/

universe u v

open scoped TensorProduct

/-- A bialgebra over a commutative (semi)ring `R` is both an algebra
and a coalgebra over `R`, such that the counit and comultiplication are
algebra morphisms. -/
class Bialgebra (R : Type u) (A : Type v) [CommSemiring R] [Semiring A]
    extends Algebra R A, Coalgebra R A where
  /-- The counit is an algebra morphism -/
  counit_mul : ∀ a₁ a₂ : A, counit (a₁ * a₂) = counit a₁ * counit a₂
  counit_one : counit 1 = 1
  /-- The comultiplication is an algebra morphism -/
  comul_mul : ∀ a₁ a₂ : A, comul (a₁ * a₂) =
      Algebra.TensorProduct.mul (comul a₁) (comul a₂)
  comul_one : comul 1 = 1

namespace Bialgebra
variable {R : Type u} {A : Type v}
variable [CommSemiring R] [Semiring A] [B : Bialgebra R A]

-- teach the simplifier these axioms
attribute [simp] counit_one counit_mul comul_one comul_mul

end Bialgebra

section CommSemiring
variable (R : Type u) [CommSemiring R]

open Bialgebra

namespace CommSemiring

/-- Every commutative (semi)ring is a bialgebra over itself -/
noncomputable
instance toBialgebra : Bialgebra R R where
  counit_mul := by simp
  counit_one := rfl
  comul_mul := by simp
  comul_one := rfl

end CommSemiring
