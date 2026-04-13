import Mathlib.RingTheory.TensorProduct

/-
Notation:
* `V ⊗[R] W` is the tensor product of `V` and `W` over `R`, with
  elements finite sums of pure tensors `v ⊗ₜ[R] w`
* `f : A →ₗ[R] B` is an `R`-linear map from `A` to `B`
* `f : A →₀ B` is a finitely supported function from `A` to `B`
* `fun₀ | x => 1` is the function which sends `x` to `1` and
  everything else to `0`

-/

-- allow local use of ⊗ notation
open scoped TensorProduct

-- allow us to write 'id' rather than 'LinearMap.id'
open LinearMap

/-
We use the canonical isomorphisms:
* TensorProduct.assoc R U V W : (U ⊗ V) ⊗ W ≅ U ⊗ (V ⊗ W)
* TensorProduct.lid R V : R ⊗ V ≅ V
* TensorProduct.rid R V : V ⊗ R ≅ V
-/

/-- A coalgebra over a commutative ring `R` is an `R`-module equipped
with a coassociative comultiplication and a counit obeying the left and
right conunitality laws. -/
class Coalgebra (R : Type u) (A : Type v) [CommRing R] [AddCommGroup A]
    [Module R A] where
  /-- The comultiplication of the coalgebra -/
  comul : A →ₗ[R] A ⊗[R] A
  /-- The counit of the coalgebra -/
  counit : A →ₗ[R] R
  /-- The comultiplication is coassociative -/
  coassoc : ∀ a : A,
    (TensorProduct.assoc R A A A) ((TensorProduct.map comul id)
    (comul a)) = ((TensorProduct.map id comul) (comul a))
  /-- The counit satisfies the left counitality law -/
  counit_id : ∀ a : A,
    (TensorProduct.lid R A) ((TensorProduct.map counit id) (comul a)) =
    a
  /-- The counit satisfies the right counitality law -/
  id_counit : ∀ a : A,
    (TensorProduct.rid R A) ((TensorProduct.map id counit) (comul a)) =
    a

/-
We use the definitions from Mathlib.LinearAlgebra.Finsupp:
* Finsupp.total α M R f : takes a function `f : α → M` defined on
  elements of `α` and extends it to an `R`-linear map
  `g : (α →₀ R) → M`. We use this so that we can define the
  comultiplication just on basis elements.
* Finsupp.single a b : the finitely supported function which takes
  value `b` at `a`, and `0` otherwise.
-/
noncomputable
def Finsupp.Coalgebra (R : Type u) (S : Type v) [CommRing R] :
    Coalgebra R (S →₀ R) where
  comul := Finsupp.total S ((S →₀ R) ⊗[R] (S →₀ R)) R
    (fun s ↦ Finsupp.single s 1 ⊗ₜ Finsupp.single s 1)
  counit := Finsupp.total S R R (fun _ ↦ 1)
  coassoc := by
    -- expand Finsupp.total into a finite sum
    intros b; rw [Finsupp.total_apply R b]
    -- move the summation symbol with a series of rewrites
    rw [map_finsupp_sum (TensorProduct.map
      (Finsupp.total S ((S →₀ R) ⊗[R] (S →₀ R)) R fun s =>
      (fun₀ | s => 1) ⊗ₜ[R] fun₀ | s => 1) LinearMap.id) b
      (fun i a => a • (fun₀ | i => 1) ⊗ₜ[R] fun₀ | i => 1)]; simp
    rw [map_finsupp_sum (TensorProduct.map LinearMap.id
      (Finsupp.total S ((S →₀ R) ⊗[R] (S →₀ R)) R fun s =>
      (fun₀ | s => 1) ⊗ₜ[R] fun₀ | s => 1)) b
      (fun i a => a • (fun₀ | i => 1) ⊗ₜ[R] fun₀ | i => 1)]; simp
    exact map_finsupp_sum (TensorProduct.assoc R (S →₀ R) (S →₀ R)
      (S →₀ R)) b fun a b => b • ((fun₀ | a => 1) ⊗ₜ[R] fun₀ | a => 1)
      ⊗ₜ[R] fun₀ | a => 1
  counit_id := by
    intros b; rw [Finsupp.total_apply R b]
    rw [map_finsupp_sum (TensorProduct.map
      (Finsupp.total S R R fun _ => 1) LinearMap.id) b
      (fun i a ↦ a • ((fun₀ | i => 1) ⊗ₜ[R] fun₀ | i => 1))]; simp
    rw [map_finsupp_sum (TensorProduct.lid R (S →₀ R)) b
      (fun i a ↦ a • 1 ⊗ₜ[R] fun₀ | i => 1)]; simp
  id_counit := by
    intros b; rw [Finsupp.total_apply R b]
    rw [map_finsupp_sum (TensorProduct.map LinearMap.id
      (Finsupp.total S R R fun _ => 1)) b
      (fun i a ↦ a • ((fun₀ | i => 1) ⊗ₜ[R] fun₀ | i => 1))]; simp
    rw [map_finsupp_sum (TensorProduct.rid R (S →₀ R)) b
      (fun i a ↦ a • (fun₀ | i => 1) ⊗ₜ[R] 1)]; simp

noncomputable
def Finsupp'.Coalgebra (R : Type u) (S : Type v) [CommRing R] :
    Coalgebra R (S →₀ R) where
  comul := Finsupp.total S ((S →₀ R) ⊗[R] (S →₀ R)) R
    (fun s ↦ Finsupp.single s 1 ⊗ₜ Finsupp.single s 1)
  counit := Finsupp.total S R R (fun _ ↦ 1)
  coassoc := by
    -- expand Finsupp.total into a finite sum
    intros b; rw [Finsupp.total_apply R b]
    -- move the summation symbol with a series of rewrites
    simp_rw [map_finsupp_sum]; simp
  counit_id := by
    intros b; rw [Finsupp.total_apply R b]
    simp_rw [map_finsupp_sum]; simp
  id_counit := by
    intros b; rw [Finsupp.total_apply R b]
    simp_rw [map_finsupp_sum]; simp
