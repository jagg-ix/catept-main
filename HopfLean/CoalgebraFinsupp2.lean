import Mathlib.RingTheory.TensorProduct

/-
Notation:
* `f ∘ₗ g` is the composition `f ∘ g` of two linear maps `f` and `g`, as
  a linear map (that is, it is a map, along with the proof that it is
  linear)
-/

universe u v

open scoped TensorProduct

class Coalgebra (R : Type u) (A : Type v) [CommRing R] [AddCommGroup A]
    [Module R A] where
  comul : A →ₗ[R] A ⊗[R] A
  counit : A →ₗ[R] R
  coassoc : TensorProduct.assoc R A A A ∘ₗ TensorProduct.map comul .id ∘ₗ
    comul = TensorProduct.map .id comul ∘ₗ comul
  counit_id : TensorProduct.lid R A ∘ₗ TensorProduct.map counit .id ∘ₗ
    comul = .id
  id_counit : TensorProduct.rid R A ∘ₗ TensorProduct.map .id counit ∘ₗ
    comul = .id

noncomputable
def Finsupp.Coalgebra (R : Type u) (S : Type v) [CommRing R] :
    Coalgebra R (S →₀ R) where
  comul := Finsupp.total S ((S →₀ R) ⊗[R] (S →₀ R)) R
    (fun s ↦ Finsupp.single s 1 ⊗ₜ Finsupp.single s 1)
  counit := Finsupp.total S R R (fun _ ↦ 1)
  coassoc := by
    ext; simp
  counit_id := by
    ext; simp
  id_counit := by
    ext; simp
