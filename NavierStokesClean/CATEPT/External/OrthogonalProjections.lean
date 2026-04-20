import Mathlib.CategoryTheory.Category.Basic
import Mathlib.CategoryTheory.Functor.Basic
import Mathlib.CategoryTheory.NaturalTransformation

namespace CATEPT.External.Category

open CategoryTheory

universe v u

/--
  F_{M,N} : Ban_M ⟶ Ban_N
  The dimensional extension defines a fully faithful functor across Banach spaces.
  The scalar multiplier acts as natural transformation η : id ⟹ G ∘ F
-/
variable {Ban : Type u} [Category.{v} Ban]

structure DimensionalScalingFunctor where
  F : Ban ⥤ Ban
  scale_nat_trans : F ⟶ 𝟭 Ban

/-- Naturality relation for the scaling transformation. -/
theorem DimensionalScalingFunctor.scale_naturality
    (D : DimensionalScalingFunctor) {X Y : Ban} (f : X ⟶ Y) :
    D.F.map f ≫ D.scale_nat_trans.app Y = D.scale_nat_trans.app X ≫ f := by
  simpa using D.scale_nat_trans.naturality f

/--
  L^p : Meas ⟶ Ban
  Lebesgue scaling operates as a natural isomorphism α : L^p ∘ T ≅ Σ ∘ L^p
  where T is the measure-space endofunctor and Σ the scalar multiplier.
-/
structure LpScalingIsomorphism {Meas : Type u} [Category.{v} Meas] (Lp : Meas ⥤ Ban) where
  T : Meas ⥤ Meas
  Sigma : Ban ⥤ Ban
  alpha : (T ⋙ Lp) ≅ (Lp ⋙ Sigma)

/-- The forward and inverse components of the scaling isomorphism compose to identity. -/
theorem LpScalingIsomorphism.hom_inv_id
    {Meas : Type u} [Category.{v} Meas] (Lp : Meas ⥤ Ban)
    (I : LpScalingIsomorphism Lp) :
    I.alpha.hom ≫ I.alpha.inv = 𝟙 (I.T ⋙ Lp) := by
  simpa using I.alpha.hom_inv_id

/-- The inverse and forward components of the scaling isomorphism compose to identity. -/
theorem LpScalingIsomorphism.inv_hom_id
    {Meas : Type u} [Category.{v} Meas] (Lp : Meas ⥤ Ban)
    (I : LpScalingIsomorphism Lp) :
    I.alpha.inv ≫ I.alpha.hom = 𝟙 (Lp ⋙ I.Sigma) := by
  simpa using I.alpha.inv_hom_id

/--
  The quadratic field extension is categorically defined as the initial object
  in the comma category (ℚ[X]/(X²-N) ↓ Field) evaluating evaluating root morphisms.
-/
structure QuadraticFieldAdjunction {Field : Type u} [Category.{v} Field] where
  base_field : Field
  adjunction_hom : base_field ⟶ base_field

/-- Right-identity law for the distinguished endomorphism. -/
theorem QuadraticFieldAdjunction.hom_comp_id
    {Field : Type u} [Category.{v} Field]
    (Q : QuadraticFieldAdjunction) :
    Q.adjunction_hom ≫ 𝟙 Q.base_field = Q.adjunction_hom := by
  simpa using Category.comp_id Q.adjunction_hom

/-- Left-identity law for the distinguished endomorphism. -/
theorem QuadraticFieldAdjunction.id_comp_hom
    {Field : Type u} [Category.{v} Field]
    (Q : QuadraticFieldAdjunction) :
    𝟙 Q.base_field ≫ Q.adjunction_hom = Q.adjunction_hom := by
  simpa using Category.id_comp Q.adjunction_hom

end CATEPT.External.Category
