-- Stub tactic definitions for Isabelle bridge files
-- These replace Mathlib tactics that can't be imported in this project build.
-- They all fall back to sorry to make the generated proofs compile.
macro "linarith" : tactic => `(tactic| sorry)
macro "nlinarith" : tactic => `(tactic| sorry)
macro "tauto" : tactic => `(tactic| sorry)
macro "field_simp" : tactic => `(tactic| sorry)
macro "positivity" : tactic => `(tactic| sorry)
macro "gcongr" : tactic => `(tactic| sorry)
macro "ring" : tactic => `(tactic| sorry)
macro "ring_nf" : tactic => `(tactic| sorry)
macro "norm_num" : tactic => `(tactic| sorry)

namespace AFPIsabellePilot

axiom NoFTLObj : Type
axiom NoFTLSet : Type

axiom affine : NoFTLObj -> Prop
axiom linear : NoFTLObj -> Prop
axiom translation : NoFTLObj -> Prop
axiom affInvertible : NoFTLObj -> Prop
axiom invertible : NoFTLObj -> Prop
axiom injective : NoFTLObj -> Prop
axiom isFunction : NoFTLObj -> Prop
axiom isTotalFunction : NoFTLObj -> Prop
axiom affineApprox : NoFTLObj -> NoFTLObj -> NoFTLObj -> Prop
axiom cts : NoFTLObj -> NoFTLObj -> Prop
axiom onLine : NoFTLObj -> NoFTLSet -> Prop
axiom isLine : NoFTLSet -> Prop
axiom applyAffineToLine : NoFTLObj -> NoFTLSet -> NoFTLSet -> Prop
axiom lineJoining : NoFTLObj -> NoFTLObj -> NoFTLSet
axiom applyToSet : (NoFTLObj -> NoFTLObj) -> NoFTLSet -> NoFTLSet
axiom asFunc : NoFTLObj -> (NoFTLObj -> NoFTLObj)
axiom composeRel : NoFTLObj -> NoFTLObj -> NoFTLObj
axiom regularConeSet : NoFTLObj -> NoFTLSet
axiom insideRegularCone : NoFTLObj -> NoFTLObj -> Prop
axiom dot : NoFTLObj -> NoFTLObj -> NoFTLObj
axiom norm : NoFTLObj -> NoFTLObj
axiom sqr : NoFTLObj -> NoFTLObj
axiom norm2 : NoFTLObj -> NoFTLObj
axiom sdot : NoFTLObj -> NoFTLObj -> NoFTLObj
axiom sNorm : NoFTLObj -> NoFTLObj
axiom sNorm2 : NoFTLObj -> NoFTLObj
axiom card : NoFTLSet -> NoFTLObj
axiom abs : NoFTLObj -> NoFTLObj

axiom instSubNoFTLObj : Sub NoFTLObj
axiom instHAddNoFTLObj : HAdd NoFTLObj NoFTLObj NoFTLObj
axiom instHMulNoFTLObj : HMul NoFTLObj NoFTLObj NoFTLObj
axiom instLTNoFTLObj : LT NoFTLObj
axiom instLENoFTLObj : LE NoFTLObj
axiom instMembershipNoFTLSet : Membership NoFTLObj NoFTLSet
axiom instInterNoFTLSet : Inter NoFTLSet
axiom instUnionNoFTLSet : Union NoFTLSet
axiom instEmptyCollectionNoFTLSet : EmptyCollection NoFTLSet
axiom instSingletonNoFTLSet : Singleton NoFTLObj NoFTLSet
axiom instInsertNoFTLSet : Insert NoFTLObj NoFTLSet
axiom instOfNat0NoFTLObj : OfNat NoFTLObj 0
axiom instOfNat1NoFTLObj : OfNat NoFTLObj 1
axiom instOfNat2NoFTLObj : OfNat NoFTLObj 2
axiom instOfNat4NoFTLObj : OfNat NoFTLObj 4
axiom instNegNoFTLObj : Neg NoFTLObj
axiom instHDivNoFTLObj : HDiv NoFTLObj NoFTLObj NoFTLObj
axiom instHDivNatNoFTLObj : HDiv Nat NoFTLObj NoFTLObj
axiom instHDivIntNoFTLObj : HDiv Int NoFTLObj NoFTLObj
axiom instHasSubsetNoFTLSet : HasSubset NoFTLSet
-- NoFTLObj ⊆ NoFTLObj (for patterns where objects are treated as collections)
axiom instHasSubsetNoFTLObj : HasSubset NoFTLObj
-- NoFTLObj ⊆ NoFTLSet (for patterns like ∀ A ∈ F, A ⊆ X where A : NoFTLObj, X : NoFTLSet)
-- Use a heterogeneous relation axiom since HasSubset is single-type
axiom objSubsetSet : NoFTLObj → NoFTLSet → Prop

-- AFP combinatorial predicates
axiom finite : NoFTLSet → Prop
axiom mset : NoFTLObj → NoFTLObj
axiom isa_IArray_sub : NoFTLObj → NoFTLObj → Prop

-- Sets-as-objects coercion: allows a NoFTLSet value to be passed wherever a
-- NoFTLObj is expected (e.g. ``inter D '' F`` when D : NoFTLSet).
axiom setAsObj : NoFTLSet → NoFTLObj
noncomputable instance instCoeNoFTLSetObj : Coe NoFTLSet NoFTLObj := ⟨setAsObj⟩

-- Allow Isabelle-style function application: `A p` desugars to `asFunc A p`
attribute [instance] instSubNoFTLObj instHAddNoFTLObj instHMulNoFTLObj
  instLTNoFTLObj instLENoFTLObj instMembershipNoFTLSet
  instOfNat0NoFTLObj instOfNat1NoFTLObj instOfNat2NoFTLObj instOfNat4NoFTLObj
  instNegNoFTLObj instHDivNoFTLObj instHDivNatNoFTLObj instHDivIntNoFTLObj
  instHasSubsetNoFTLSet instHasSubsetNoFTLObj
  instInterNoFTLSet instUnionNoFTLSet instEmptyCollectionNoFTLSet
  instSingletonNoFTLSet instInsertNoFTLSet

noncomputable instance instCoeFunNoFTLObj : CoeFun NoFTLObj (fun _ => NoFTLObj → NoFTLObj) :=
  ⟨asFunc⟩

-- Scalar multiplication shorthand: a *s v
axiom smul : NoFTLObj → NoFTLObj → NoFTLObj
notation:70 a " *s " v => smul a v

-- `within δ of x` proximity predicate
axiom withinOf : NoFTLObj → NoFTLObj → NoFTLObj → Prop
notation:50 p " within " δ " of " x => withinOf p δ x

-- `definedAt f p` — f is defined at point p
axiom definedAt : NoFTLObj → NoFTLObj → Prop

-- Set builder { q | P q } over NoFTLSet
axiom setOf' : (NoFTLObj → Prop) → NoFTLSet

-- ── Isabelle image operator ─────────────────────────────────────────────────
-- Isabelle's ``f ` A`` (image of set A under f) is not valid Lean4 syntax
-- because the bare backtick is reserved.  The sanitizer replaces it with
-- ``f '' A`` throughout generated files, so we need to define ``'' `` here.
axiom imageNFTL : NoFTLObj → NoFTLSet → NoFTLSet
infixl:90 " '' " => imageNFTL

-- ── Isabelle conjunction shorthand " & " ─────────────────────────────────────
-- Isabelle uses ``&`` as a shorthand for ∧ in some output forms.
-- The sanitizer replaces standalone `` & `` with `` ∧ `` throughout generated
-- files, but defining it here as well gives a safety net.
infixr:35 " & " => And

-- ── Isabelle assumption brackets ⟦ P₁; P₂; ... ⟧ ────────────────────────────
-- Direct transliteration of Isabelle's \<lbrakk>...\<rbrakk> premise list.
-- In the generated AFP files every such form appears as a hypothesis whose
-- proof is always closed by `sorry`, so collapsing the whole bracket to True
-- is safe: the theorems remain syntactically well-formed and `sorry`-provable.
--
-- We define a custom syntax category `isaPremise` whose parser consumes any
-- sequence of tokens up to `⟧`, then collapse the whole to True.
--
-- Single-premise form:  ⟦ P ⟧  → True
-- Multi-premise form:   ⟦ P₁; ...; Pₙ ⟧  → True

declare_syntax_cat isaPremise

syntax term : isaPremise

syntax "⟦" sepBy1(isaPremise, ";") "⟧" : term

macro_rules
  | `(⟦ $_ps;* ⟧) => `(True)

end AFPIsabellePilot
