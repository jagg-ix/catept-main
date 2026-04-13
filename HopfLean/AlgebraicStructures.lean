class Group₁ (G : Type u) where
  -- there is a binary product `G × G → G` (curried to `G → G → G`)
  mul : G → G → G
  -- there is an element `e`
  e : G
  -- `e` is a left identity
  e_mul : ∀ x : G, mul e x = x
  -- `e` is a right identity
  mul_e : ∀ x : G, mul x e = x
  -- every element has a left inverse
  left_inv : ∀ x : G, ∃ y : G, mul y x = e
  -- every element has a right inverse
  right_inv : ∀ x : G, ∃ y : G, mul x y = e
  -- the binary product is associative
  mul_assoc : ∀ x y z : G, mul x (mul y z) = mul (mul x y) z

-- define a ⋆ b := mul a b for ease of reading
infixl:65   " ⋆ " => Group₁.mul

/-
Any lemma `h` in the namespace below must be referred to as `Group₁.h`
outside of the namespace. Namespaces allow us to repeat names of axioms
and theorems (e.g. 'mul_assoc') for different structures, whilst still
giving them unique identifiers.
-/
namespace Group₁
/-
The code below can be read as "let `G` be a group". variable
{G : Type u} introduces the variable `G` (and gives it an arbitrary
type), and [Group₁ G] tells Lean to construct an instance of a group
`G` (as defined in Group₁).
-/
variable {G : Type u} [Group₁ G]

/-
In the lemmas below, we heavily use the tactic 'calc', which tells Lean
that we are about to construct a chain of equalities, starting from one
side of the goal and ending on the other. This tactic allows us to set
out proofs in a more readable and intuitive way. It also works on
inequalities, or any other transitive relation (but we will not need
to use it for anything other than equalities in this report).
-/

-- the identity of a group is unique
theorem e_unique_group₁ (e' : G) (mul_e' : ∀ x : G, x ⋆ e' = x) :
    e = e' := by
  calc
    e = e ⋆ e' := by rw [mul_e' e]
    _ = e' := e_mul e'

-- the left and right inverses of an element coincide
theorem left_inv_eq_right_inv_group₁ (x a b : G)
    (a_right_inv : x ⋆ a = e) (b_left_inv : b ⋆ x = e) : a = b := by
  calc
    a = e ⋆ a := by rw [e_mul a]
    _ = (b ⋆ x) ⋆ a := by rw [b_left_inv]
    _ = b ⋆ (x ⋆ a) := by rw [mul_assoc]
    _ = b ⋆ e := by rw [a_right_inv]
    _ = b := mul_e b

-- close the namespace
end Group₁

class Monoid₁ (M : Type u) where
  mul : M → M → M
  e : M
  e_mul : ∀ x : M, mul e x = x
  mul_e : ∀ x : M, mul x e = x
  mul_assoc : ∀ x y z : M, mul x (mul y z) = mul (mul x y) z

infixl:65   " ⋆ " => Monoid₁.mul

namespace Monoid₁
variable {M : Type u} [Monoid₁ M]

-- the identity of a monoid is unique
-- (note that the proof is exactly the same as for groups)
theorem e_unique_monoid₁ (e' : M) (mul_e' : ∀ x : M, x ⋆ e' = x) :
    e = e' := by
  calc
    e = e ⋆ e' := by rw [mul_e' e]
    _ = e' := e_mul e'

-- the left and right inverses of an element coincide if they exist
-- (the same proof as for groups, again)
theorem left_inv_eq_right_inv_monoid₁ (x a b : M)
    (a_right_inv : x ⋆ a = e) (b_left_inv : b ⋆ x = e) : a = b := by
  calc
    a = e ⋆ a := by rw [e_mul a]
    _ = (b ⋆ x) ⋆ a := by rw [b_left_inv]
    _ = b ⋆ (x ⋆ a) := by rw [mul_assoc]
    _ = b ⋆ e := by rw [a_right_inv]
    _ = b := mul_e b

end Monoid₁

/-
The 'extends' keyword tells Lean that an instance of Group₂ is an
instance of Monoid₁, satisfying the extra conditions below.
-/
class Group₂ (G : Type u) extends Monoid₁ G where
  left_inv : ∀ x : G, ∃ y : G, y ⋆ x = e
  right_inv : ∀ x : G, ∃ y : G, x ⋆ y = e

namespace Group₂
variable (G : Type u) [Group₂ G]

open Monoid₁

/-
We have already proven the lemmas below for monoids, so we know they
must be true for groups. We can therefore just give Lean the name of
the corresponding lemma for monoids as the proof.
-/

-- the identity of a group is unique
theorem e_unique_group₂ (e' : G) (mul_e' : ∀ x : G, x ⋆ e' = x) :
    e = e' := e_unique_monoid₁ _ mul_e'

-- the left and right inverses of an element coincide
theorem left_inv_eq_right_inv_group₂ (x a b : G)
    (a_right_inv : x ⋆ a = e) (b_left_inv : b ⋆ x = e) : a = b :=
  left_inv_eq_right_inv_monoid₁ _ _ _ a_right_inv b_left_inv

/-
Lean can actually guess some of the arguments for e_unique_monoid₁ and
left_inv_eq_right_inv_monoid₁ above, which is why we can just put
placeholders (underscores) there. This doesn't always work, but can be
a useful shortcut.
-/

end Group₂

class SemiGroup (S : Type u) where
  mul : S → S → S
  mul_assoc : ∀ x y z : S, mul x (mul y z) = mul (mul x y) z

infixl:65   " ⋆ " => SemiGroup.mul

namespace SemiGroup
variable {S : Type u} [SemiGroup S]

-- the identity of a semigroup is unique if it exists
theorem e_unique_semigroup (e₁ e₂ : S) (e₁_mul : ∀ x : S, e₁ ⋆ x = x)
    (mul_e₂ : ∀ x : S, x ⋆ e₂ = x) : e₁ = e₂ := by
  calc
    e₁ = e₁ ⋆ e₂ := by rw [mul_e₂ e₁]
    _  = e₂ := e₁_mul e₂

end SemiGroup

class Monoid₂ (M : Type u) extends SemiGroup M where
  e : M
  e_mul : ∀ x : M, e ⋆ x = x
  mul_e : ∀ x : M, x ⋆ e = x

class Group₃ (G : Type u) extends Monoid₂ G where
  left_inv : ∀ x : G, ∃ y : G, y ⋆ x = e
  right_inv : ∀ x : G, ∃ y : G, x ⋆ y = e

open SemiGroup

open Monoid₂

namespace Group₃
variable {G : Type u} [Group₃ G]

/-
We have shown that the identity of a semigroup is unique if it exists.
Since the identity of a group always exists, and a group is a special
semigroup, we can just feed Lean the proof for semigroups.
-/

-- the identity of a group is unique
theorem e_unique_group₃ (e' : G) (mul_e' : ∀ x : G, x ⋆ e' = x) :
    e = e' := e_unique_semigroup _ _ e_mul mul_e'
