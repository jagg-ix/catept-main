import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 122

Formal dissipation/core-statement layer extracted from
`0028_formal_derivation_and_core_statement.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G122

variable {Term : Type}

structure ActionPotential where
  energy : ℝ
  info : ℝ

abbrev State (Term : Type) := Term → ActionPotential

structure Process (Term : Type) where
  initialState : State Term
  finalState : State Term

/-- Deviation from a reference reversible map, measured on information coordinate. -/
def deviation (p : Process Term) (H_op : State Term → State Term) (t : Term) : ℝ :=
  (p.finalState t).info - (H_op p.initialState t).info

/-- Information content (cost) of deviation. -/
def informationContent (η : ℝ) : ℝ :=
  |η|

def isHamiltonian (p : Process Term) (H_op : State Term → State Term) : Prop :=
  ∀ t : Term, informationContent (deviation p H_op t) = 0

def isDissipative (p : Process Term) (H_op : State Term → State Term) : Prop :=
  ¬ isHamiltonian p H_op

theorem dissipation_iff_information_change
    (p : Process Term) (H_op : State Term → State Term) :
    isDissipative p H_op
      ↔ ∃ t : Term, (p.finalState t).info ≠ (H_op p.initialState t).info := by
  classical
  unfold isDissipative isHamiltonian informationContent deviation
  constructor
  · intro hnot
    by_contra hno
    apply hnot
    intro t
    have hEq : (p.finalState t).info = (H_op p.initialState t).info := by
      exact Classical.not_not.mp (not_exists.mp hno t)
    simp [hEq]
  · intro hExists hHam
    rcases hExists with ⟨t, ht⟩
    have h0 := hHam t
    have habs : |(p.finalState t).info - (H_op p.initialState t).info| = 0 := h0
    have hsub : (p.finalState t).info - (H_op p.initialState t).info = 0 := by
      exact abs_eq_zero.mp habs
    exact ht (sub_eq_zero.mp hsub)

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G122
