import Mathlib.CategoryTheory.Category.Basic
import Mathlib.CategoryTheory.Functor.Basic
import Mathlib.CategoryTheory.Iso
import Mathlib.CategoryTheory.Functor.Category

namespace CATEPT.External.Category

open CategoryTheory

universe v u

-- Dimensional extension functor with a scaling natural transformation.
structure DimensionalScalingFunctor (Ban : Type u) [Category.{v} Ban] where
  F : Functor Ban Ban
  scale_nat_trans : NatTrans F (Functor.id Ban)

/-- Naturality relation for the scaling transformation. -/
theorem DimensionalScalingFunctor.scale_naturality
    {Ban : Type u} [Category.{v} Ban]
    (D : DimensionalScalingFunctor Ban) {X Y : Ban} (f : X ⟶ Y) :
    D.F.map f ≫ D.scale_nat_trans.app Y = D.scale_nat_trans.app X ≫ f := by
  simpa using D.scale_nat_trans.naturality f

-- L^p scaling as a natural isomorphism between two composites.
structure LpScalingIsomorphism
    (Meas : Type u) [Category.{v} Meas]
    (Ban : Type u) [Category.{v} Ban]
    (Lp : Functor Meas Ban) where
  T : Functor Meas Meas
  Sigma : Functor Ban Ban
  alpha : Iso (T ⋙ Lp) (Lp ⋙ Sigma)

/-- The forward and inverse components of the scaling isomorphism compose to identity. -/
theorem LpScalingIsomorphism.hom_inv_id
    {Meas : Type u} [Category.{v} Meas]
    {Ban : Type u} [Category.{v} Ban]
  {Lp : Functor Meas Ban}
    (I : LpScalingIsomorphism Meas Ban Lp) :
    I.alpha.hom ≫ I.alpha.inv = 𝟙 (I.T ⋙ Lp) := by
  exact I.alpha.hom_inv_id

/-- The inverse and forward components of the scaling isomorphism compose to identity. -/
theorem LpScalingIsomorphism.inv_hom_id
    {Meas : Type u} [Category.{v} Meas]
    {Ban : Type u} [Category.{v} Ban]
    {Lp : Functor Meas Ban}
    (I : LpScalingIsomorphism Meas Ban Lp) :
    I.alpha.inv ≫ I.alpha.hom = 𝟙 (Lp ⋙ I.Sigma) := by
  exact I.alpha.inv_hom_id

-- Endomorphism package for quadratic extension bookkeeping.
structure QuadraticFieldAdjunction (Field : Type u) [Category.{v} Field] where
  base_field : Field
  adjunction_hom : base_field ⟶ base_field

/-- Right-identity law for the distinguished endomorphism. -/
theorem QuadraticFieldAdjunction.hom_comp_id
    {Field : Type u} [Category.{v} Field]
    (Q : QuadraticFieldAdjunction Field) :
    Q.adjunction_hom ≫ 𝟙 Q.base_field = Q.adjunction_hom := by
  exact Category.comp_id Q.adjunction_hom

/-- Left-identity law for the distinguished endomorphism. -/
theorem QuadraticFieldAdjunction.id_comp_hom
    {Field : Type u} [Category.{v} Field]
    (Q : QuadraticFieldAdjunction Field) :
    𝟙 Q.base_field ≫ Q.adjunction_hom = Q.adjunction_hom := by
  exact Category.id_comp Q.adjunction_hom

end CATEPT.External.Category
