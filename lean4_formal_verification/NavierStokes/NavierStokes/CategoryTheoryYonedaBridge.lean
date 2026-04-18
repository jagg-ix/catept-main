import Mathlib.CategoryTheory.Yoneda
import NavierStokes.CategoryTheoryLib

/-!
# Category-Theory Yoneda Bridge

Practical Yoneda helpers for the Navier-Stokes category layer.

This file keeps things lightweight and executable against the current
`CategoryTheoryLib` abstraction:
- `TopModuleCat ℝ` as the ambient category object type (native Mathlib)
- morphisms `X ⟶ Y` are continuous ℝ-linear maps via the native instance

The intent is to make Yoneda-native reasoning available for proof obligations
without introducing new semantic assumptions.
-/

namespace NavierStokes.Millennium.CategoryTheory

set_option autoImplicit false
open _root_.CategoryTheory
noncomputable section

abbrev BanSpPresheaf := (TopModuleCat ℝ)ᵒᵖ ⥤ Type _

/-- The representable presheaf of probes into `X`. -/
abbrev homPresheaf (X : TopModuleCat ℝ) : BanSpPresheaf := yoneda.obj X

/-- Yoneda converts natural transformations between representables into morphisms.

`NatTrans(hom(-,X), hom(-,Y)) ≃ Hom(X,Y)`

This is the key encoding for "observer/probe-based" obligations. -/
noncomputable def yoneda_natTrans_equiv_hom (X Y : TopModuleCat ℝ) :
    (homPresheaf X ⟶ homPresheaf Y) ≃ (X ⟶ Y) := by
  simpa [homPresheaf] using
    (_root_.CategoryTheory.yonedaEquiv
      (X := X) (F := (_root_.CategoryTheory.yoneda (C := TopModuleCat ℝ)).obj Y))

/-- Faithfulness corollary: two morphisms are equal if their Yoneda actions agree. -/
theorem hom_ext_via_yoneda_map {X Y : TopModuleCat ℝ} {f g : X ⟶ Y}
    (h : (_root_.CategoryTheory.yoneda (C := TopModuleCat ℝ)).map f =
         (_root_.CategoryTheory.yoneda (C := TopModuleCat ℝ)).map g) :
    f = g := by
  have happ := congrArg (fun α => α.app (Opposite.op X) (𝟙 X)) h
  simpa using happ

/-- Iso reconstruction from probe-level equivalence (Yoneda extensionality).

Use this to prove object-level equivalence by giving mutually inverse maps on all
incoming probes plus naturality. -/
noncomputable def iso_of_probe_equivalence
    (X Y : TopModuleCat ℝ)
    (p : ∀ {Z : TopModuleCat ℝ}, (Z ⟶ X) → (Z ⟶ Y))
    (q : ∀ {Z : TopModuleCat ℝ}, (Z ⟶ Y) → (Z ⟶ X))
    (h₁ : ∀ {Z : TopModuleCat ℝ} (f : Z ⟶ X), q (p f) = f)
    (h₂ : ∀ {Z : TopModuleCat ℝ} (f : Z ⟶ Y), p (q f) = f)
    (n : ∀ {Z Z' : TopModuleCat ℝ} (f : Z' ⟶ Z) (g : Z ⟶ X), p (f ≫ g) = f ≫ p g) :
    X ≅ Y :=
  _root_.CategoryTheory.Yoneda.ext (C := TopModuleCat ℝ) X Y p q h₁ h₂ n

/-- Small checklist object for wiring this file into theorem planning. -/
structure YonedaReadiness where
  hasNatTransToHomEquiv : Prop
  hasMorphExt : Prop
  hasIsoExt : Prop
  readyForObligationEncoding : Bool

/-- Current readiness status for this bridge layer. -/
def yonedaReadiness : YonedaReadiness where
  hasNatTransToHomEquiv := True
  hasMorphExt := True
  hasIsoExt := True
  readyForObligationEncoding := true

end

end NavierStokes.Millennium.CategoryTheory
