-- lines beginning with '--' are shorter comments
/-
Longer comments can be enclosed in '/- -/' as demonstrated here.
-/

-- import the file which defines rings from Mathlib
import Mathlib.Algebra.Ring.Basic

/-
In this file, we demonstrate some of the basic tactics in Lean which we
will use throughout this report.
-/

-- let `R` be a ring
variable {R : Type*} [Ring R]

/-
We first try to prove that addition in a ring is associative. Of course,
this just follows from the basic axioms for a ring, but trivial
theorems like this are a good way to become familiar with Lean tactics.

Our first proof uses 'intros', which when used on a goal of the form
`∀ x, P x` (where `P x` is a proposition about `x`), introduces an
arbitrary variable `x` and changes the goal to `P x`.

Further, given a theorem `h` of the form `h : x = y` and a goal `P x`,
the tactic 'rw [h]' rewrites the goal to `P y`.

We have available the axiom that in an additive group, addition is
associative:

add_assoc.{u_1} {G : Type u_1} [inst✝ : AddSemigroup G] (a b c : G) :
    a + b + c = a + (b + c)

The braces in the statement above denote implicit arguments (arguments
that Lean can infer), and the brackets denote explicit arguments (which
Lean must be given in general). We will explain the square brackets
further in the section on algebraic structures in Lean.
-/

theorem add_assoc₁ : ∀ a b c : R, a + (b + c) = (a + b) + c := by
  -- let a, b, c be elements of the ring R
  intros a b c
  -- we can now use add_assoc
  -- Lean can actually guess the variables here, but we include them
  -- for clarity
  rw [add_assoc a b c]

/-
Given a theorem `h` of the form `h : P x` and a goal which is exactly
`P x`, the tactic 'exact h' closes the goal.

The tactic symm on a goal of the form `x = y` changes the goal to
`y = x`. It works on all equivalence relations.

Tagging the theorem with the label @[simp] teaches the simplifier that
the theorem is true. We can then later use the tactic 'simp', which
tries to simplify the goal using the theorems it has been taught. The
simplifier in Mathlib knows a huge number of basic lemmas, not only the
ones we teach it here.
-/

@[simp]
theorem add_assoc₂ : ∀ a b c : R, a + (b + c) = (a + b) + c := by
  intros a b c
  -- swap the goal from `a + (b + c) = (a + b) + c` to
  -- `(a + b) + c = a + (b + c)`
  symm
  -- this is now exactly associativity of the underlying additive group
  exact add_assoc a b c

-- Note that the proof below would not work if we hadn't tagged
-- add_assoc₂ with simp
theorem add_assoc₃ : ∀ a b c : R, a + (b + c) = (a + b) + c := by
  simp

/-
We now prove something a little less trivial: that the underlying
additive group of a ring is necessarily abelian if the multiplication
distributes over addition. We introduce the new tactics 'have',
'simp_rw', 'simp only' and 'apply'.

The tactic 'have key : `P x`' creates a new subgoal `P x`. Once this
has been proven, we would then have available 'key : `P x`' as a
hypothesis, which we could use in the main proof. It is analogous to
introducing a lemma in the middle of a proof, and proving that first.

If we have a theorem or hypothesis of the form 'h : `P → Q`' (`P`
implies `Q`, literally 'h is a function which takes a proof of `P` to a
proof of `Q`') and our goal is `Q`, we can use 'apply h' to change the
goal to `P`.

The tactics 'simp_rw' and 'simp only' are weaker forms of 'simp'.
'simp_rw' attempts to simplify the goal by rewriting the arguments you
give it. 'simp only' uses only the theorems/hypotheses you give it to
simplify the goal, not everything it knows. We will see below why one
might choose to use 'simp_rw' over 'simp', and later (in the section on
monoidal categories) we will see why it can be better to use 'simp
only' rather than 'simp'.

We use the axioms of a ring in Mathlib below. Note that the arguments
given in braces and square brackets can, for simplicity, be read as
'let `R` be a ring', although they are often more general; for example,
the theorem 'right_distrib' only requires `R` to be a structure with a
notion of multiplication, addition, and the property of right
distributivity.

right_distrib.{x} {R : Type x} [inst✝ : Mul R] [inst✝¹ : Add R]
    [inst✝² : RightDistribClass R] (a b c : R) :
    (a + b) * c = a * c + b * c

left_distrib.{x} {R : Type x} [inst✝ : Mul R] [inst✝¹ : Add R]
    [inst✝² : LeftDistribClass R] (a b c : R) :
    a * (b + c) = a * b + a * c

mul_one.{u} {M : Type u} [inst✝ : MulOneClass M] (a : M) : a * 1 = a

We also use with the theorems that tell us we can (additively) left and
right cancel:

AddGroup.toAddCancelMonoid.proof_6.{u_1} {G : Type u_1}
    [inst✝ : AddGroup G] (a b c : G) (h : a + b = c + b) : a = c

AddGroup.toAddCancelMonoid.proof_1.{u_1} {G : Type u_1}
    [inst✝ : AddGroup G] (a b c : G) (h : a + b = a + c) : b = c
-/
theorem add_comm' {R : Type*} [Ring R] (a b : R) : a + b = b + a := by
  have key₁ : (a + b) * (1 + 1) = a + (a + b) + b := by
    -- We use simp_rw below because it respects the order of the
    -- arguments, unlike simp and simp only
    simp_rw [right_distrib, left_distrib, mul_one, add_assoc]
  have key₂ : (a + b) * (1 + 1) = a + (b + a) + b := by
    simp_rw [left_distrib, right_distrib, mul_one, add_assoc]
  rw [key₁] at key₂
  -- note that Lean can sometimes figure out even explicit arguments
  -- on its own, but in general we need to provide them
  apply AddGroup.toAddCancelMonoid.proof_6 (a + b) b
  apply AddGroup.toAddCancelMonoid.proof_1 a
  have key₃ : a + (a + b) + b = a + (a + b + b) := by
    simp only [add_assoc₂]
  -- the ← tells Lean to rewrite the left hand side of the equality
  rw [← key₃]
  have key₄ : a + (b + a) + b = a + (b + a + b) := by
    simp only [add_assoc₂]
  rw [← key₄]
  exact key₂
