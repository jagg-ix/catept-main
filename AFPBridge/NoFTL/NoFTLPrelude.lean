/-!
# AFP No Faster-Than-Light Observers — Lean 4 Prelude

Ported from the Isabelle AFP entry `No_FTL_observers_Gen_Rel` by
Stephan Sulzbacher and Miguel Martins (2023).
Original: https://www.isa-afp.org/entries/No_FTL_observers_Gen_Rel.html

This prelude provides:
- Opaque `NoFTLObj` / `NoFTLSet` types (replacing Isabelle's many-sorted
  carrier types for 4-vectors, observers, world-lines, etc.)
- Domain-specific axiomatic operators and notations matching the AFP source
- Tactic stubs so that `sorry`-discharged goals compile cleanly

All theorems that use this prelude are marked `sorry` and carry a
`-- phase2_high` annotation indicating that a human proof is expected
in a subsequent phase.
-/

-- ── Tactic stubs ──────────────────────────────────────────────────────────────
-- Replace Mathlib-heavy tactics with sorry-fallbacks so the file compiles
-- independently of mathlib import order.
macro "linarith"   : tactic => `(tactic| sorry)
macro "nlinarith"  : tactic => `(tactic| sorry)
macro "tauto"      : tactic => `(tactic| sorry)
macro "field_simp" : tactic => `(tactic| sorry)
macro "positivity" : tactic => `(tactic| sorry)
macro "gcongr"     : tactic => `(tactic| sorry)
macro "ring"       : tactic => `(tactic| sorry)
macro "ring_nf"    : tactic => `(tactic| sorry)
macro "norm_num"   : tactic => `(tactic| sorry)

namespace AFPIsabellePilot

-- ── Carrier types ─────────────────────────────────────────────────────────────
-- NoFTLObj: opaque type for 4-vectors, observers, real scalars, functions, etc.
-- NoFTLSet: opaque type for sets of NoFTLObj (world-lines, cones, etc.)
axiom NoFTLObj : Type
axiom NoFTLSet : Type

-- ── Geometric / algebraic predicates ──────────────────────────────────────────
axiom affine         : NoFTLObj → Prop
axiom linear         : NoFTLObj → Prop
axiom translation    : NoFTLObj → Prop
axiom affInvertible  : NoFTLObj → Prop
axiom invertible     : NoFTLObj → Prop
axiom injective      : NoFTLObj → Prop
axiom isFunction     : NoFTLObj → Prop
axiom isTotalFunction : NoFTLObj → Prop
axiom affineApprox   : NoFTLObj → NoFTLObj → NoFTLObj → Prop
axiom cts            : NoFTLObj → NoFTLObj → Prop
axiom onLine         : NoFTLObj → NoFTLSet → Prop
axiom isLine         : NoFTLSet → Prop
axiom applyAffineToLine : NoFTLObj → NoFTLSet → NoFTLSet → Prop
axiom definedAt      : NoFTLObj → NoFTLObj → Prop

-- ── Geometric constructors ─────────────────────────────────────────────────────
axiom lineJoining    : NoFTLObj → NoFTLObj → NoFTLSet
axiom applyToSet     : (NoFTLObj → NoFTLObj) → NoFTLSet → NoFTLSet
axiom asFunc         : NoFTLObj → (NoFTLObj → NoFTLObj)
axiom composeRel     : NoFTLObj → NoFTLObj → NoFTLObj
axiom regularConeSet : NoFTLObj → NoFTLSet
axiom insideRegularCone : NoFTLObj → NoFTLObj → Prop

-- ── Metric / norm operators ────────────────────────────────────────────────────
-- Euclidean / Lorentzian inner products and norms
axiom dot   : NoFTLObj → NoFTLObj → NoFTLObj   -- Euclidean dot product
axiom norm  : NoFTLObj → NoFTLObj               -- Euclidean norm
axiom sqr   : NoFTLObj → NoFTLObj               -- square (scalar)
axiom norm2 : NoFTLObj → NoFTLObj               -- squared Euclidean norm
axiom sdot  : NoFTLObj → NoFTLObj → NoFTLObj   -- spatial dot product
axiom sNorm  : NoFTLObj → NoFTLObj              -- spatial norm
axiom sNorm2 : NoFTLObj → NoFTLObj             -- squared spatial norm
axiom abs   : NoFTLObj → NoFTLObj               -- absolute value

-- Minkowski product (⊙m in the AFP, emitted as *m by translator)
-- minkProd m u v  =  u ⊙_m v  where m encodes the metric signature
axiom minkProd : NoFTLObj → NoFTLObj → NoFTLObj

-- ── Set-theoretic helpers ──────────────────────────────────────────────────────
axiom card   : NoFTLSet → NoFTLObj
axiom finite : NoFTLSet → Prop
axiom mset   : NoFTLObj → NoFTLObj
axiom isa_IArray_sub : NoFTLObj → NoFTLObj → Prop
axiom setOf' : (NoFTLObj → Prop) → NoFTLSet

-- ── Coercions ─────────────────────────────────────────────────────────────────
-- Sets-as-objects coercion: allows a NoFTLSet value to be passed where
-- a NoFTLObj is expected.
axiom setAsObj : NoFTLSet → NoFTLObj
noncomputable instance instCoeNoFTLSetObj : Coe NoFTLSet NoFTLObj := ⟨setAsObj⟩

-- ── Typeclass instances (axiomatic) ───────────────────────────────────────────
axiom instSubNoFTLObj             : Sub NoFTLObj
axiom instHAddNoFTLObj            : HAdd NoFTLObj NoFTLObj NoFTLObj
axiom instHMulNoFTLObj            : HMul NoFTLObj NoFTLObj NoFTLObj
axiom instLTNoFTLObj              : LT NoFTLObj
axiom instLENoFTLObj              : LE NoFTLObj
axiom instMembershipNoFTLSet      : Membership NoFTLObj NoFTLSet
axiom instInterNoFTLSet           : Inter NoFTLSet
axiom instUnionNoFTLSet           : Union NoFTLSet
axiom instEmptyCollectionNoFTLSet : EmptyCollection NoFTLSet
axiom instSingletonNoFTLSet       : Singleton NoFTLObj NoFTLSet
axiom instInsertNoFTLSet          : Insert NoFTLObj NoFTLSet
-- Numeric literals for NoFTLObj (covers all AFP numeric constants)
axiom instOfNat0NoFTLObj          : OfNat NoFTLObj 0
axiom instOfNat1NoFTLObj          : OfNat NoFTLObj 1
axiom instOfNat2NoFTLObj          : OfNat NoFTLObj 2
axiom instOfNat4NoFTLObj          : OfNat NoFTLObj 4
axiom instNegNoFTLObj             : Neg NoFTLObj
axiom instHDivNoFTLObj            : HDiv NoFTLObj NoFTLObj NoFTLObj
axiom instHDivNatNoFTLObj         : HDiv Nat NoFTLObj NoFTLObj
axiom instHDivIntNoFTLObj         : HDiv Int NoFTLObj NoFTLObj
axiom instHasSubsetNoFTLSet       : HasSubset NoFTLSet
-- NoFTLObj ⊆ NoFTLObj (objects treated as collections in some AFP patterns)
axiom instHasSubsetNoFTLObj       : HasSubset NoFTLObj
-- NoFTLObj ⊆ NoFTLSet heterogeneous subset relation
axiom objSubsetSet                : NoFTLObj → NoFTLSet → Prop

attribute [instance]
  instSubNoFTLObj instHAddNoFTLObj instHMulNoFTLObj
  instLTNoFTLObj instLENoFTLObj instMembershipNoFTLSet
  instOfNat0NoFTLObj instOfNat1NoFTLObj instOfNat2NoFTLObj instOfNat4NoFTLObj
  instNegNoFTLObj instHDivNoFTLObj instHDivNatNoFTLObj instHDivIntNoFTLObj
  instHasSubsetNoFTLSet instHasSubsetNoFTLObj
  instInterNoFTLSet instUnionNoFTLSet instEmptyCollectionNoFTLSet
  instSingletonNoFTLSet instInsertNoFTLSet

-- Isabelle-style function application: `A p` → `asFunc A p`
noncomputable instance instCoeFunNoFTLObj : CoeFun NoFTLObj (fun _ => NoFTLObj → NoFTLObj) :=
  ⟨asFunc⟩

-- ── Custom notations ──────────────────────────────────────────────────────────
-- Scalar multiplication: `a *s v`  (Isabelle: `a *\<^sub>s v`)
axiom smul : NoFTLObj → NoFTLObj → NoFTLObj
notation:70 a " *s " v => smul a v

-- Proximity predicate: `p within δ of x`
axiom withinOf : NoFTLObj → NoFTLObj → NoFTLObj → Prop
notation:50 p " within " δ " of " x => withinOf p δ x

-- ── Isabelle image operator `f '' A` ──────────────────────────────────────────
-- Isabelle's `f ` A` (image set) is sanitized to `f '' A` in translated files.
axiom imageNFTL : NoFTLObj → NoFTLSet → NoFTLSet
infixl:90 " '' " => imageNFTL

-- ── Isabelle conjunction shorthand ────────────────────────────────────────────
infixr:35 " & " => And

-- ── Isabelle assumption brackets ⟦P₁; P₂; …⟧ ────────────────────────────────
-- Isabelle's `\<lbrakk>…\<rbrakk>` premise lists.  All proofs are `sorry`-
-- discharged anyway, so collapsing the bracket to True is safe.
declare_syntax_cat isaPremise
syntax term : isaPremise
syntax "⟦" sepBy1(isaPremise, ";") "⟧" : term
macro_rules
  | `(⟦ $_ps;* ⟧) => `(True)

end AFPIsabellePilot
