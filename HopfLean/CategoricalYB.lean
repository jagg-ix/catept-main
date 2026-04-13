import Mathlib.CategoryTheory.Monoidal.Braided

/-
Notation

* α_ : the associator for a monoidal category
* 𝟙 : the identity morphism
* β_ : the braiding for a braided monoidal category
* ≫ : composition of morphisms in a category (the reverse of usual
  composition, i.e. g ≫ f := f ∘ g)
-/

namespace CategoryTheory

open Category

open MonoidalCategory

open BraidedCategory

theorem cat_yang_baxter {C : Type u} [Category.{v, u}    C]
    [MonoidalCategory C] [self : BraidedCategory C] :
    ∀ X Y Z : C, (α_ X Y Z).hom ≫ (((𝟙 X) ⊗ (β_ Y Z).hom) ≫
    ((α_ X Z Y).inv ≫ (((β_ X Z).hom ⊗ (𝟙 Y)) ≫ ((α_ Z X Y).hom ≫
    ((𝟙 Z) ⊗ (β_ X Y).hom))))) = ((β_ X Y).hom ⊗ (𝟙 Z)) ≫
    ((α_ Y X Z).hom ≫ (((𝟙 Y) ⊗ (β_ X Z).hom) ≫ ((α_ Y Z X).inv ≫
    (((β_ Y Z).hom ⊗ (𝟙 X)) ≫ (α_ Z Y X).hom)))) := by
  intros X Y Z
  /- this key follows immediately from the reverse hexagon axiom, but
  associativity and post/precomposition of morphisms complicate it -/
  have key : ∀ X Y Z : C, (α_ X Y Z).hom ≫ (((𝟙 X) ⊗ (β_ Y Z).hom) ≫
      ((α_ X Z Y).inv ≫ (((β_ X Z).hom ⊗ (𝟙 Y)) ≫ (α_ Z X Y).hom))) =
      (β_ (X ⊗ Y) Z).hom := by
    intros X Y Z
    -- postcomposing the reverse hexagon axiom with α_ Z X Y
    have this₁ : ((α_ X Y Z).inv ≫ (β_ (X ⊗ Y) Z).hom ≫
        (α_ Z X Y).inv) ≫ (α_ Z X Y).hom = ((𝟙 X) ⊗ (β_ Y Z).hom) ≫
        ((α_ X Z Y).inv ≫ (((β_ X Z).hom ⊗ (𝟙 Y)) ≫
        (α_ Z X Y).hom)) := by
      rw [eq_whisker (hexagon_reverse X Y Z) (α_ Z X Y).hom]; simp
    simp only [assoc, Iso.inv_hom_id, comp_id] at this₁
    -- precomposing this₁ with α_ X Y Z
    have this₂ : (α_ X Y Z).hom ≫ (((α_ X Y Z).inv ≫
        (β_ (X ⊗ Y) Z).hom ≫ (α_ Z X Y).inv) ≫ (α_ Z X Y).hom) =
        (α_ X Y Z).hom ≫ (((𝟙 X) ⊗ (β_ Y Z).hom) ≫ ((α_ X Z Y).inv ≫
        (((β_ X Z).hom ⊗ (𝟙 Y)) ≫ (α_ Z X Y).hom))) := by
      rw [← whisker_eq (α_ X Y Z).hom this₁]; simp
    /- simplify using associativity of morphism composition, the
    definition of inverses, and identity axioms -/
    simp only [assoc, Iso.inv_hom_id, comp_id, Iso.hom_inv_id_assoc]
      at this₂
    rw [this₂]
  -- rearrange brackets, simp can close this immediately
  have aux : (α_ X Y Z).hom ≫ (𝟙 X ⊗ (β_ Y Z).hom) ≫ (α_ X Z Y).inv ≫
      ((β_ X Z).hom ⊗ 𝟙 Y) ≫ (α_ Z X Y).hom ≫ (𝟙 Z ⊗ (β_ X Y).hom) =
      ((α_ X Y Z).hom ≫ (𝟙 X ⊗ (β_ Y Z).hom) ≫ (α_ X Z Y).inv ≫
      ((β_ X Z).hom ⊗ 𝟙 Y) ≫ (α_ Z X Y).hom) ≫
      (𝟙 Z ⊗ (β_ X Y).hom) := by
    simp only [assoc]
  /- two applications of the reverse hexagon axiom and naturality of
  the braiding closes the goal -/
  rw [aux, key X Y Z, key Y X Z, braiding_naturality (β_ X Y).hom (𝟙 Z)]

end CategoryTheory
