import CATEPTMain.Integration.LorentzInvariantSymmetryActions

set_option autoImplicit false

/-!
# Collinear/soft limit stability carriers

Structural carriers for collinear and soft limits expressed in
Lorentz-invariant variables.
-/

namespace CATEPTMain.Integration.LorentzInvariantLimitStability

noncomputable section

open CATEPTMain.Integration.LorentzInvariantSymmetryActions

/-- Family of invariant lists parameterized by a limit variable. -/
structure InvariantFamily where
  Param : Type
  family : Param -> InvariantList

/-- Structural claim that a kernel remains stable along a limit family. -/
structure LimitStabilityClaim where
  kernel : InvariantList -> ℝ
  family : InvariantFamily
  stable : Prop

/-- Bundle of collinear and soft stability claims. -/
structure CollinearSoftStability where
  collinear : LimitStabilityClaim
  soft : LimitStabilityClaim

/-- Carrier witnessing both collinear and soft stability. -/
structure CollinearSoftStabilityWitness where
  claims : CollinearSoftStability
  collinear_holds : claims.collinear.stable
  soft_holds : claims.soft.stable

/-- Build a witness from explicit stability proofs. -/
def mkCollinearSoftStabilityWitness (claims : CollinearSoftStability)
    (h1 : claims.collinear.stable) (h2 : claims.soft.stable) :
    CollinearSoftStabilityWitness :=
  { claims := claims
    collinear_holds := h1
    soft_holds := h2 }

end

end CATEPTMain.Integration.LorentzInvariantLimitStability
