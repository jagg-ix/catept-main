import CATEPTMain.Integration.LorentzInvariantInvariants

set_option autoImplicit false

/-!
# Spinor-bracket grammar carriers

Minimal AST for angle, square, and mixed brackets with expansion over
momentum sums.
-/

namespace CATEPTMain.Integration.LorentzInvariantSpinorBrackets

noncomputable section

open CATEPTMain.Integration.LorentzInvariantInvariants

/-- Particle index carrier for bracket endpoints. -/
abbrev ParticleIdx : Type := Nat

/-- Symbolic momentum expression used inside mixed brackets. -/
inductive MomentumExpr
| atom : FourMomentum -> MomentumExpr
| add : MomentumExpr -> MomentumExpr -> MomentumExpr
| sub : MomentumExpr -> MomentumExpr -> MomentumExpr

/-- Evaluate a symbolic momentum expression to a concrete four-momentum. -/
def evalMomentumExpr : MomentumExpr -> FourMomentum
| MomentumExpr.atom p => p
| MomentumExpr.add p q => fun mu => evalMomentumExpr p mu + evalMomentumExpr q mu
| MomentumExpr.sub p q => fun mu => evalMomentumExpr p mu - evalMomentumExpr q mu

/-- Spinor-bracket expression AST. -/
inductive SpinorBracketExpr
| angle : ParticleIdx -> ParticleIdx -> SpinorBracketExpr
| square : ParticleIdx -> ParticleIdx -> SpinorBracketExpr
| mixed : ParticleIdx -> MomentumExpr -> ParticleIdx -> SpinorBracketExpr
| add : SpinorBracketExpr -> SpinorBracketExpr -> SpinorBracketExpr
| sub : SpinorBracketExpr -> SpinorBracketExpr -> SpinorBracketExpr

/-- Angle bracket carrier. -/
def angleBracket (i j : ParticleIdx) : SpinorBracketExpr :=
  SpinorBracketExpr.angle i j

/-- Square bracket carrier. -/
def squareBracket (i j : ParticleIdx) : SpinorBracketExpr :=
  SpinorBracketExpr.square i j

/-- Mixed bracket carrier. -/
def mixedBracket (i : ParticleIdx) (p : MomentumExpr) (j : ParticleIdx) : SpinorBracketExpr :=
  SpinorBracketExpr.mixed i p j

/-- Expand a mixed bracket across a momentum sum/difference. -/
def expandMixed (i : ParticleIdx) (p : MomentumExpr) (j : ParticleIdx) : SpinorBracketExpr :=
  match p with
  | MomentumExpr.atom q => SpinorBracketExpr.mixed i (MomentumExpr.atom q) j
  | MomentumExpr.add p q => SpinorBracketExpr.add (expandMixed i p j) (expandMixed i q j)
  | MomentumExpr.sub p q => SpinorBracketExpr.sub (expandMixed i p j) (expandMixed i q j)

@[simp] theorem expandMixed_add (i : ParticleIdx) (p q : MomentumExpr) (j : ParticleIdx) :
    expandMixed i (MomentumExpr.add p q) j =
      SpinorBracketExpr.add (expandMixed i p j) (expandMixed i q j) := rfl

@[simp] theorem expandMixed_sub (i : ParticleIdx) (p q : MomentumExpr) (j : ParticleIdx) :
    expandMixed i (MomentumExpr.sub p q) j =
      SpinorBracketExpr.sub (expandMixed i p j) (expandMixed i q j) := rfl

end

end CATEPTMain.Integration.LorentzInvariantSpinorBrackets
