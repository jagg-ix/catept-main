import Mathlib.Data.Fin.Basic
import CATEPTMain.Integration.LorentzInvariantInvariants

set_option autoImplicit false

/-!
# Lorentz-invariant symmetry actions

Permutation and parity actions on invariant carriers, with a structural
Lorentz-scalar kernel that is invariant under both.
-/

namespace CATEPTMain.Integration.LorentzInvariantSymmetryActions

noncomputable section

open CATEPTMain.Integration.LorentzInvariantInvariants

/-- Carrier for a minimal invariant list (s, t, u, Gram, tr5, Sigma5). -/
structure InvariantList where
  s : ℝ
  t : ℝ
  u : ℝ
  gram2 : ℝ
  tr5 : ℝ
  sigma5 : ℝ

/-- Access the `(s, t, u)` triple as a `Fin 3 → ℝ`. -/
def stuVec (inv : InvariantList) : Fin 3 → ℝ
  | ⟨0, _⟩ => inv.s
  | ⟨1, _⟩ => inv.t
  | ⟨2, _⟩ => inv.u

/-- Replace the `(s, t, u)` triple inside an invariant list. -/
def fromStuVec (stu : Fin 3 → ℝ) (inv : InvariantList) : InvariantList :=
  { inv with
    s := stu ⟨0, by decide⟩
    t := stu ⟨1, by decide⟩
    u := stu ⟨2, by decide⟩ }

/-- Permute the `(s, t, u)` block by a finite permutation. -/
def permuteSTU (σ : Equiv.Perm (Fin 3)) (inv : InvariantList) : InvariantList :=
  fromStuVec (fun i => stuVec inv (σ i)) inv

/-- Parity action on the invariant list (pseudoscalar `tr5` flips sign). -/
def parity (inv : InvariantList) : InvariantList :=
  { inv with tr5 := -inv.tr5 }

/-- Lorentz-scalar kernel invariant under permutation and parity actions. -/
structure LorentzScalarKernel where
  eval : InvariantList → ℝ
  perm_invariant : ∀ σ inv, eval (permuteSTU σ inv) = eval inv
  parity_invariant : ∀ inv, eval (parity inv) = eval inv

/-- Constant kernel is invariant under permutation and parity. -/
def constantKernel (c : ℝ) : LorentzScalarKernel :=
  { eval := fun _ => c
    perm_invariant := by intros; rfl
    parity_invariant := by intro; rfl }

/-- Convenience lemma: permutation invariance for any Lorentz-scalar kernel. -/
theorem kernel_perm_invariant (K : LorentzScalarKernel) (σ : Equiv.Perm (Fin 3))
    (inv : InvariantList) : K.eval (permuteSTU σ inv) = K.eval inv :=
  K.perm_invariant σ inv

/-- Convenience lemma: parity invariance for any Lorentz-scalar kernel. -/
theorem kernel_parity_invariant (K : LorentzScalarKernel) (inv : InvariantList) :
    K.eval (parity inv) = K.eval inv :=
  K.parity_invariant inv

end

end CATEPTMain.Integration.LorentzInvariantSymmetryActions
