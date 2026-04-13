import Mathlib.Algebra.Category.ModuleCat.Basic
import HopfLean.Bialgebra

suppress_compilation

universe u v

open scoped TensorProduct

/-
This section mirrors Mathlib.RingTheory.TensorProduct, lines 197-231
and 300-301, where some of the structure of the tensor product of
algebras is built.

Note that the bialgebra is labelled `Q` below, whilst `B` is
technically the underlying ring. When talking about the bialgebra, we
will normally refer to it as `B` with the understanding that we are
also including the extra structure, but Lean does not allow for this.
-/

section Bmul

variable [CommRing F]
variable [Ring B] [Algebra F B] [Q : Bialgebra F B]
variable [AddCommGroup M] [Module B M] [Module F M]
  [IsScalarTower F B M]
variable [AddCommGroup N] [Module B N] [Module F N]
  [IsScalarTower F B N]

-- Scalar multiplication by `B` is a linear map
def leftActByB (b : B) : M →ₗ[F] M where
  toFun := (b • ·)
  -- toFun preserves addition, since scalar multiplication does
  map_add' := smul_add b
  -- toFun preserves scalar multiplication
  map_smul' := by intros r x; exact smul_algebra_smul_comm r b x

-- Scalar multiplication by `B ⊗ B` on `M ⊗ N`, defined on pure
-- tensors
noncomputable
def BmulAux (b₁ b₂ : B) : M ⊗[F] N →ₗ[F] M ⊗[F] N :=
  TensorProduct.map (leftActByB b₁) (leftActByB b₂)

@[simp]
theorem BmulAux_apply (b₁ b₂ : B) (n : N) (m : M) :
    (BmulAux b₁ b₂) (n ⊗ₜ[F] m) = (b₁ • n) ⊗ₜ[F] (b₂ • m) :=
  rfl

open TensorProduct

/-
Scalar multiplication by `B ⊗ B` on `M ⊗ N` as an `F`-bilinear map,
extended (using TensorProduct.lift) from BmulAux, the scalar
multiplication defined only on pure tensors.

LinearMap.mk₂, the constructor for bilinear maps, requires four proofs
(two for linearity in each entry). Recall that a proof of the form
`∀ x, P x` in Lean is a map sending `x` to a proof of `P x`, and thus
a constructor requiring `(∀ x, P x)` will accept `(fun x => P x)`,
which is what we do here.
-/
noncomputable
def Bmul : B ⊗[F] B →ₗ[F] M ⊗[F] N →ₗ[F] M ⊗[F] N :=
  TensorProduct.lift <|
    LinearMap.mk₂ F BmulAux
      -- `∀ (b₁ b₂ b : B) ((b₁ + b₂) • _ )⊗(b • _) = (b₁ • _)⊗(b • _)
      -- + (b₂ • _)⊗(b • _)`
      (fun b₁ b₂ b =>
        -- we prove these maps agree on all elements of M and N
        TensorProduct.ext' fun m n => by
          -- distributivity of *, ⊗, and • over addition
          simp only [BmulAux_apply, LinearMap.add_apply, add_mul,
            add_tmul, add_smul])
      -- `∀ (c : F) (b₁ b₂ : B) ((cb₁) • _ )⊗(b₂ • _) =
      -- c(b₁ • _)⊗(b₂ • _)`
      (fun c b₁ b₂ =>
        TensorProduct.ext' fun m n => by
          -- associativity of •
          simp only [BmulAux_apply, LinearMap.smul_apply, smul_tmul',
            smul_mul_assoc, smul_assoc])
      -- `∀ (b b₁ b₂ : B) (b • _ )⊗((b₁ + b₂) • _) = (b • _)⊗(b₁ • _)
      -- + (b • _)⊗(b₂ • _)`
      (fun b b₁ b₂ =>
        TensorProduct.ext' fun m n => by
          -- distributivity of *, ⊗, and • over addition
          simp only [BmulAux_apply, LinearMap.add_apply, add_mul,
            tmul_add, add_smul])
      -- `∀ (c : F) (b₁ b₂ : B) (b₁ • _ )⊗((cb₂) • _) =
      -- c(b₁ • _)⊗(b₂ • _)`
      fun c b₁ b₂ =>
        TensorProduct.ext' fun m n => by
          -- associativity of •
          simp only [BmulAux_apply, LinearMap.smul_apply, smul_tmul,
            smul_tmul', smul_mul_assoc, smul_assoc]

@[simp]
theorem Bmul_apply (b₁ b₂ : B) (m : M) (n : N) :
    Bmul (b₁ ⊗ₜ[F] b₂) (m ⊗ₜ[F] n) = (b₁ • m) ⊗ₜ[F] (b₂ • n) :=
  rfl

/-
The simp lemmas below are needed for the instance of `M ⊗ N` as a
`B`-module, for two `B`-modules `M` and `N`.

The method we use for proving both lemmas below is induction on
arbitary elements of a tensor product. For example, if our proposition
is of the form `∀ a : M ⊗[F] N, P a`, inducting on `a` means we only
have to show the following:
* `P` is true for `0`
* `P` is true for an arbitrary pure tensor
* If `P` is true for two arbitrary elements of `M ⊗[F] N`, then it is
  true for their sum

This works because elements of `M ⊗[F] N` are exactly finite sums of
pure tensors. In both cases below (but especially the first), we see
that Lean's automation (simp and aesop) is very good at taking care of
these partial goals. The command '<;> aesop' tells Lean to repeat
'aesop' until it closes the goal.

The tactic 'refine' is a generalisation of 'exact', where we allow
placeholders '?_' for proof terms. Lean then creates subgoals
corresponding to the proof terms we didn't provide.
-/

-- `1 • a = a`
@[simp]
theorem Bmul_one (a : M ⊗[F] N) : Bmul (1 : B ⊗[F] B) a = a := by
  -- the unit of `B ⊗ B` is `1 ⊗ 1`
  rw [Algebra.TensorProduct.one_def]
  refine TensorProduct.induction_on a ?_ ?_ ?_ <;> aesop

-- `(x * y) • a = x • (y • a)`
@[simp]
theorem Bmul_mul (x y : B ⊗[F] B) (a : M ⊗[F] N) :
    Bmul (Algebra.TensorProduct.mul x y) a = Bmul x (Bmul y a) := by
  -- induct on `a`, and note it is immediately true for `a = 0`
  refine TensorProduct.induction_on a ?_ ?_ ?_; simp only [map_zero]
  · intros m n
    -- induct on `x`, and note it is immediately true for `x = 0`
    refine TensorProduct.induction_on x ?_ ?_ ?_
    simp only [map_zero, LinearMap.zero_apply]
    · intros b₁ b₂
      -- induct on `y`, and note it is immediately true for `y = 0`
      refine TensorProduct.induction_on y ?_ ?_ ?_
      simp only [map_zero, LinearMap.zero_apply]
      · intros b₃ b₄
        /- now we are only working with pure tensors, we apply the
        definitions of multiplication and left action by `b`, along
        with associativity of • and * -/
        simp only [Algebra.TensorProduct.mul_apply, Bmul_apply,
          mul_smul]
      -- Lean's automation can deal with the remaining cases
      intros x y hyp₁ hyp₂; aesop
    intros x y hyp₁ hyp₂; aesop
  intros c d hyp₁ hyp₂; aesop

end Bmul

open CategoryTheory

namespace ModuleCat

variable {R : Type u₁} [CommRing R]
variable {B : Type u₂} [Ring B] [Q : Bialgebra R B]
variable (M N : ModuleCat B) [Module R M] [Module R N]
  [IsScalarTower R B M] [IsScalarTower R B N]

open TensorProduct

/-
This section is set up so that the instance of the monoidal category
`B`-Mod can be immediately constructed below, though we do not include
this here.

Given a bialgebra `B` and two `B`-modules `M`, `N`, their tensor
product `M ⊗ N` is also a `B`-module, with action given by
`b • (m ⊗ n) := Δ(b) • (m ⊗ n)`

There are other instances of `M ⊗ N` as a `B`-module, e.g. setting
`b • (m ⊗ n)` = `(b • m) ⊗ n` or `b • (m ⊗ n) = m ⊗ (b • n)`.
Clearly neither of those is what we would want if we want to build the
instance of the monoidal category `B`-Mod later, so we may need to set
the 'canonical' instance at a higher priority so that Lean can find it.
-/

@[default_instance 200]
instance tprod_BModule : Module B (M ⊗[R] N) where
  smul := fun b ↦ (Bmul ∘ₗ Q.comul) b
  /- Note that when proving one_smul and mul_smul, the simplifier needs
  Bmul_one and Bmul_mul, which is why we proved them earlier. -/
  one_smul := by
    intros a; unfold instHSMul SMul.smul
    /- 'LinearMap.coe_comp' says that for two linear maps `f` and `g`,
    we can either compose them as linear maps and then look at the
    underlying function, or compose the underlying functions of both,
    and the result is the same function. This is a technical lemma
    needed by Lean, since it considers maps and linear maps to
    technically be different types. The lemma 'Function.comp_apply'
    says that (f ∘ g) (x) = f(g(x)). -/
    simp only [LinearMap.coe_comp, Function.comp_apply,
      Bialgebra.comul_one, Bmul_one]
  mul_smul := by
    intros b₁ b₂ a; unfold instHSMul SMul.smul
    simp only [LinearMap.coe_comp, Function.comp_apply,
      Bialgebra.comul_mul, Bmul_mul]
  smul_zero := by
    intros b; unfold instHSMul SMul.smul
    simp only [LinearMap.coe_comp, Function.comp_apply, map_zero]
  smul_add := by
    intros b a c; unfold instHSMul SMul.smul
    simp only [LinearMap.coe_comp, Function.comp_apply, map_add]
  add_smul := by
    intros b₁ b₂ a; unfold instHSMul SMul.smul
    simp only [LinearMap.coe_comp, Function.comp_apply, map_add,
      LinearMap.add_apply]
  zero_smul := by
    intros a; unfold instHSMul SMul.smul
    simp only [LinearMap.coe_comp, Function.comp_apply, map_zero,
      LinearMap.zero_apply]
