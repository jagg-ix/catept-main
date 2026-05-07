import CATEPTMain.Integration.LorentzInvariantInvariants

set_option autoImplicit false

/-!
# Lorentz-invariant slice constraints

Structural carrier for momentum conservation, on-shell constraints,
and an invariant-variable slice witness.
-/

namespace CATEPTMain.Integration.LorentzInvariantSliceConstraints

noncomputable section

open CATEPTMain.Integration.LorentzInvariantInvariants

/-- Carrier for momentum-constraint data in invariant variables. -/
structure InvariantConstraintSystem where
  momenta : List FourMomentum
  totalMomentum : FourMomentum
  momentumConservation : Prop
  onShell : Prop
  invariantSlice : Prop

/-- Bundle of constraint hypotheses for an invariant slice. -/
def InvariantSliceClaim (S : InvariantConstraintSystem) : Prop :=
  S.momentumConservation ∧ S.onShell ∧ S.invariantSlice

theorem invariantSliceClaim_intro (S : InvariantConstraintSystem)
    (h1 : S.momentumConservation) (h2 : S.onShell) (h3 : S.invariantSlice) :
    InvariantSliceClaim S := by
  exact ⟨h1, h2, h3⟩

/-- Carrier witnessing that an invariant slice can be chosen. -/
structure InvariantSliceWitness where
  system : InvariantConstraintSystem
  witness : InvariantSliceClaim system

/-- Build a witness from explicit constraint proofs. -/
def mkInvariantSliceWitness (S : InvariantConstraintSystem)
    (h1 : S.momentumConservation) (h2 : S.onShell) (h3 : S.invariantSlice) :
    InvariantSliceWitness :=
  { system := S
    witness := invariantSliceClaim_intro S h1 h2 h3 }

end

end CATEPTMain.Integration.LorentzInvariantSliceConstraints
