import Mathlib

set_option autoImplicit false

/-!
# NavierStokesClean.CATEPT.DSL.LambdaMetaTheory

Core `Gamma;Delta` meta-theory for a first-order lambda/QTM fragment:
- explicit typing judgment `HasType Gamma Delta t A`
- small-step operational semantics
- preservation and progress (closed terms)
- core full-abstraction theorem for value observations.
-/

namespace NavierStokesClean.CATEPT.DSL

/-- First-order type universe used by the core lambda/QTM fragment. -/
inductive LType where
  | unit
  | bit
  | qubit
  | tensor (a b : LType)
  deriving DecidableEq, Repr

abbrev Context := List LType

/-- Core term language with separate classical (`cvar`) and linear (`lvar`) vars. -/
inductive LTerm where
  | cvar (idx : Nat)
  | lvar (idx : Nat)
  | unit
  | bit (b : Bool)
  | qubit (q : Bool)
  | pair (t u : LTerm)
  | fst (t : LTerm)
  | snd (t : LTerm)
  | ite (cond tBranch eBranch : LTerm)
  deriving DecidableEq, Repr

def lookupCtx : Context → Nat → Option LType
  | [], _ => none
  | a :: _, 0 => some a
  | _ :: xs, n + 1 => lookupCtx xs n

def substCVar (i : Nat) (u t : LTerm) : LTerm :=
  match t with
  | .cvar j => if j = i then u else .cvar j
  | .lvar j => .lvar j
  | .unit => .unit
  | .bit b => .bit b
  | .qubit q => .qubit q
  | .pair t1 t2 => .pair (substCVar i u t1) (substCVar i u t2)
  | .fst t1 => .fst (substCVar i u t1)
  | .snd t1 => .snd (substCVar i u t1)
  | .ite c t1 e1 => .ite (substCVar i u c) (substCVar i u t1) (substCVar i u e1)

/-- Typing judgment `Gamma;Delta |- t : A`. -/
inductive HasType : Context → Context → LTerm → LType → Prop where
  | cvar {Γ Δ i A} :
      lookupCtx Γ i = some A →
      HasType Γ Δ (.cvar i) A
  | lvar {Γ Δ i A} :
      lookupCtx Δ i = some A →
      HasType Γ Δ (.lvar i) A
  | unit {Γ Δ} :
      HasType Γ Δ .unit .unit
  | bit {Γ Δ b} :
      HasType Γ Δ (.bit b) .bit
  | qubit {Γ Δ q} :
      HasType Γ Δ (.qubit q) .qubit
  | pair {Γ Δ t u A B} :
      HasType Γ Δ t A →
      HasType Γ Δ u B →
      HasType Γ Δ (.pair t u) (.tensor A B)
  | fst {Γ Δ t A B} :
      HasType Γ Δ t (.tensor A B) →
      HasType Γ Δ (.fst t) A
  | snd {Γ Δ t A B} :
      HasType Γ Δ t (.tensor A B) →
      HasType Γ Δ (.snd t) B
  | ite {Γ Δ c t e A} :
      HasType Γ Δ c .bit →
      HasType Γ Δ t A →
      HasType Γ Δ e A →
      HasType Γ Δ (.ite c t e) A

/-- Values for the core fragment. -/
inductive Value : LTerm → Prop where
  | unit : Value .unit
  | bit (b : Bool) : Value (.bit b)
  | qubit (q : Bool) : Value (.qubit q)
  | pair {t u} : Value t → Value u → Value (.pair t u)

/-- Small-step reduction relation. -/
inductive Step : LTerm → LTerm → Prop where
  | pair_left {t t' u} :
      Step t t' →
      Step (.pair t u) (.pair t' u)
  | pair_right {v u u'} :
      Value v →
      Step u u' →
      Step (.pair v u) (.pair v u')
  | fst_ctx {t t'} :
      Step t t' →
      Step (.fst t) (.fst t')
  | fst_pair {v1 v2} :
      Value v1 →
      Value v2 →
      Step (.fst (.pair v1 v2)) v1
  | snd_ctx {t t'} :
      Step t t' →
      Step (.snd t) (.snd t')
  | snd_pair {v1 v2} :
      Value v1 →
      Value v2 →
      Step (.snd (.pair v1 v2)) v2
  | ite_ctx {c c' t e} :
      Step c c' →
      Step (.ite c t e) (.ite c' t e)
  | ite_true {t e} :
      Step (.ite (.bit true) t e) t
  | ite_false {t e} :
      Step (.ite (.bit false) t e) e

theorem canonical_tensor
    {v A B}
    (ht : HasType [] [] v (.tensor A B))
    (hv : Value v) :
    ∃ v1 v2, v = .pair v1 v2 ∧ Value v1 ∧ Value v2 := by
  cases hv with
  | unit =>
      cases ht
  | bit _ =>
      cases ht
  | qubit _ =>
      cases ht
  | pair hv1 hv2 =>
      cases ht with
      | pair _ _ =>
          exact ⟨_, _, rfl, hv1, hv2⟩

theorem canonical_bit
    {v}
    (ht : HasType [] [] v .bit)
    (hv : Value v) :
    v = .bit true ∨ v = .bit false := by
  cases hv with
  | unit =>
      cases ht
  | bit b =>
      cases b <;> simp
  | qubit _ =>
      cases ht
  | pair _ _ =>
      cases ht

/-- Preservation for one-step reduction. -/
theorem preservation
    {Γ Δ t t' A}
    (ht : HasType Γ Δ t A)
    (hs : Step t t') :
    HasType Γ Δ t' A := by
  induction hs generalizing Γ Δ A with
  | pair_left hstep ih =>
      cases ht with
      | pair ht1 ht2 =>
          exact HasType.pair (ih ht1) ht2
  | pair_right hv hstep ih =>
      cases ht with
      | pair ht1 ht2 =>
          exact HasType.pair ht1 (ih ht2)
  | fst_ctx hstep ih =>
      cases ht with
      | fst htInner =>
          exact HasType.fst (ih htInner)
  | fst_pair hv1 hv2 =>
      cases ht with
      | fst htPair =>
          cases htPair with
          | pair ht1 _ =>
              exact ht1
  | snd_ctx hstep ih =>
      cases ht with
      | snd htInner =>
          exact HasType.snd (ih htInner)
  | snd_pair hv1 hv2 =>
      cases ht with
      | snd htPair =>
          cases htPair with
          | pair _ ht2 =>
              exact ht2
  | ite_ctx hstep ih =>
      cases ht with
      | ite hcond htT htE =>
          exact HasType.ite (ih hcond) htT htE
  | ite_true =>
      cases ht with
      | ite _ htT _ =>
          exact htT
  | ite_false =>
      cases ht with
      | ite _ _ htE =>
          exact htE

/-- Progress for closed terms. -/
theorem progress_closed
    {t A}
    (ht : HasType [] [] t A) :
    Value t ∨ ∃ t', Step t t' := by
  induction ht with
  | cvar h =>
      cases h
  | lvar h =>
      cases h
  | unit =>
      exact Or.inl Value.unit
  | bit =>
      left
      constructor
  | qubit =>
      left
      constructor
  | pair ht1 ht2 ih1 ih2 =>
      cases ih1 with
      | inr hs1 =>
          rcases hs1 with ⟨t1', hs1'⟩
          exact Or.inr ⟨.pair t1' _, Step.pair_left hs1'⟩
      | inl hv1 =>
          cases ih2 with
          | inr hs2 =>
              rcases hs2 with ⟨t2', hs2'⟩
              exact Or.inr ⟨.pair _ t2', Step.pair_right hv1 hs2'⟩
          | inl hv2 =>
              exact Or.inl (Value.pair hv1 hv2)
  | fst htInner ih =>
      cases ih with
      | inr hs =>
          rcases hs with ⟨t', hs'⟩
          exact Or.inr ⟨.fst t', Step.fst_ctx hs'⟩
      | inl hv =>
          rcases canonical_tensor htInner hv with ⟨v1, v2, hvEq, hv1, hv2⟩
          subst hvEq
          exact Or.inr ⟨v1, Step.fst_pair hv1 hv2⟩
  | snd htInner ih =>
      cases ih with
      | inr hs =>
          rcases hs with ⟨t', hs'⟩
          exact Or.inr ⟨.snd t', Step.snd_ctx hs'⟩
      | inl hv =>
          rcases canonical_tensor htInner hv with ⟨v1, v2, hvEq, hv1, hv2⟩
          subst hvEq
          exact Or.inr ⟨v2, Step.snd_pair hv1 hv2⟩
  | ite hcond htT htE ihc iht ihe =>
      cases ihc with
      | inr hs =>
          rcases hs with ⟨c', hs'⟩
          exact Or.inr ⟨.ite c' _ _, Step.ite_ctx hs'⟩
      | inl hv =>
          rcases canonical_bit hcond hv with hb | hb
          · subst hb
            exact Or.inr ⟨_, Step.ite_true⟩
          · subst hb
            exact Or.inr ⟨_, Step.ite_false⟩

/-- Value-observation denotation for the core fragment. -/
def Denote (t : LTerm) : Set LTerm := fun v => Relation.ReflTransGen Step t v ∧ Value v

/-- Operational equivalence on value observations. -/
def OperationalEq (t u : LTerm) : Prop := ∀ v, Denote t v ↔ Denote u v

/-- Denotational equivalence as equality of observation sets. -/
def DenotationalEq (t u : LTerm) : Prop := Denote t = Denote u

/-- Core full-abstraction theorem for value observations. -/
theorem fullAbstraction_core (t u : LTerm) :
    OperationalEq t u ↔ DenotationalEq t u := by
  constructor
  · intro hop
    ext v
    exact hop v
  · intro hden v
    simpa [DenotationalEq] using congrArg (fun s => v ∈ s) hden

theorem lookupCtx_some_inj {Γ : Context} {i : Nat} {A B : LType}
    (hA : lookupCtx Γ i = some A)
    (hB : lookupCtx Γ i = some B) :
    A = B := by
  rw [hA] at hB
  cases hB
  rfl

theorem substCVar_cvar_hit_typing
    {Γ Δ : Context} {i : Nat} {A : LType} {u : LTerm}
    (hLookup : lookupCtx Γ i = some A)
    (hu : HasType Γ Δ u A) :
    HasType Γ Δ (substCVar i u (.cvar i)) A := by
  have _ := hLookup
  simpa [substCVar] using hu

theorem substCVar_cvar_miss_typing
    {Γ Δ : Context} {i j : Nat} {B : LType} {u : LTerm}
    (hLookup : lookupCtx Γ j = some B)
    (hNe : j ≠ i) :
    HasType Γ Δ (substCVar i u (.cvar j)) B := by
  unfold substCVar
  simp [hNe]
  exact HasType.cvar hLookup

theorem preservation_star
    {Γ Δ t t' A}
    (ht : HasType Γ Δ t A)
    (hstar : Relation.ReflTransGen Step t t') :
    HasType Γ Δ t' A := by
  induction hstar generalizing A with
  | refl =>
      simpa using ht
  | tail hxy hyz ih =>
      exact preservation (ih ht) hyz

theorem typeSafety_closed
    {t t' A}
    (ht : HasType [] [] t A)
    (hstar : Relation.ReflTransGen Step t t') :
    Value t' ∨ ∃ u, Step t' u := by
  have ht' : HasType [] [] t' A := preservation_star ht hstar
  exact progress_closed ht'

end NavierStokesClean.CATEPT.DSL
