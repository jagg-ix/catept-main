import QuantumAlgebra.OperatorDefs

namespace QuantumAlgebra.QuExpr

/-- Checks if an expression is a pure scalar. -/
def isScalar : QuExpr → Bool
  | scalar _ => true
  | _ => false

/-- Extract the scalar value if it is one, else 1. -/
def getScalar : QuExpr → ℂ
  | scalar c => c
  | _ => 1

/--
A basic comparison to order operators for normal ordering.
True means `a` should come before `b` in a product.
Normal ordering places daggers (creation) BEFORE non-daggers (annihilation).
-/
def less_than_op : QuExpr → QuExpr → Bool
  | boson _ true, boson _ false => true
  | fermion _ true, fermion _ false => true
  | spin _ SpinOp.plus, spin _ SpinOp.minus => true
  | _, _ => false

/--
Applies Canonical Commutation Relations (CCR) and Canonical Anticommutation Relations (CAR)
to adjacent operators. Returns a list of resulting terms.
-/
def swap_adjacent (left : QuExpr) (right : QuExpr) : List QuExpr :=
  match left, right with
  | boson i false, boson j true =>
      if i == j then
        [mul (boson i true) (boson i false), scalar 1]
      else
        [mul right left]
  | fermion i false, fermion j true =>
      if i == j then
        [add (mul (scalar (-1)) (mul (fermion i true) (fermion i false))) (scalar 1)]
      else
        [mul (scalar (-1)) (mul right left)]
  | a, b => [mul a b]

/--
A fueled recursive normal form engine.
Expands products and applies normal ordering rules.
-/
noncomputable def normal_form_fuel : Nat → QuExpr → QuExpr
  | 0, expr => expr
  | fuel + 1, expr =>
      match expr with
      | add a b => add (normal_form_fuel fuel a) (normal_form_fuel fuel b)
      | mul a b =>
          let na := normal_form_fuel fuel a
          let nb := normal_form_fuel fuel b
          match na, nb with
          | add c d, right => add (normal_form_fuel fuel (mul c right)) (normal_form_fuel fuel (mul d right))
          | left, add c d => add (normal_form_fuel fuel (mul left c)) (normal_form_fuel fuel (mul left d))
          | scalar c, scalar d => scalar (c * d)
          | scalar c, right => mul (scalar c) right
          | left, scalar c => mul (scalar c) left
          | left, right =>
              if !isScalar left && !isScalar right && less_than_op right left then
                let swapped := swap_adjacent left right
                swapped.foldl (fun acc e =>
                  match acc with
                  | scalar c => if c = 0 then normal_form_fuel fuel e else add acc (normal_form_fuel fuel e)
                  | _ => add acc (normal_form_fuel fuel e)
                ) (scalar 0)
              else
                mul left right
      | _ => expr

noncomputable def normal_form (expr : QuExpr) : QuExpr :=
  normal_form_fuel 5 expr

end QuantumAlgebra.QuExpr
