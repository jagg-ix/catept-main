import CATEPTMain.Integration.LorentzInvariantInvariants

set_option autoImplicit false

/-!
# Gram determinant invariants

Symmetry and positivity claims for the 2x2 Gram determinant carrier.
-/-

namespace CATEPTMain.Integration.LorentzInvariantGramDetLemmas

noncomputable section

open CATEPTMain.Integration.LorentzInvariantInvariants

/-- Symmetry claim for `gramDet2`. -/
def gramDet2SymmetryClaim : Prop :=
  ∀ p q : FourMomentum, gramDet2 p q = gramDet2 q p

/-- Positivity claim for `gramDet2` (structure-level placeholder). -/
def gramDet2NonnegClaim : Prop :=
  ∀ p q : FourMomentum, 0 ≤ gramDet2 p q

/-- Bundle of Gram determinant symmetry/positivity claims. -/
structure GramDet2InvariantClaims where
  symmetry : Prop
  nonneg : Prop

/-- Default bundle using the standard claims. -/
def gramDet2Claims : GramDet2InvariantClaims :=
  { symmetry := gramDet2SymmetryClaim
    nonneg := gramDet2NonnegClaim }

/-- Symmetry holds if the Lorentz product is symmetric. -/
theorem gramDet2_symm_of_lorentzProduct_comm
    (h : ∀ p q : FourMomentum, lorentzProduct p q = lorentzProduct q p) :
    gramDet2SymmetryClaim := by
  intro p q
  simp [gramDet2, h, mul_comm, mul_left_comm, mul_assoc]

end

end CATEPTMain.Integration.LorentzInvariantGramDetLemmas
