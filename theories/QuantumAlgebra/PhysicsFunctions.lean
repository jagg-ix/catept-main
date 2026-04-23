import QuantumAlgebra.OperatorDefs
import QuantumAlgebra.NormalOrdering

namespace QuantumAlgebra.QuExpr

/-- Compute the commutator [A, B] = A B - B A -/
def commutator (A B : QuExpr) : QuExpr := A * B - B * A

/-- Compute the anticommutator {A, B} = A B + B A -/
def anticommutator (A B : QuExpr) : QuExpr := A * B + B * A

/--
Heisenberg Equation of Motion:
dO(t) / dt = i[H, O(t)]
(assuming hbar = 1 for symbolic manipulation)
-/
noncomputable def heisenberg_eom (H O : QuExpr) : QuExpr :=
  let comm := commutator H O
  normal_form (mul (scalar (Complex.I : ℂ)) comm)

/-- 
Helper for VEV: Extracts the constant c from a purely scalar expression.
All non-scalar terms are zeroed (as they contain a or a^\dagger).
-/
noncomputable def vev_core : QuExpr → ℂ
  | scalar c => c
  | add a b => vev_core a + vev_core b
  | _ => 0

/--
Vacuum Expectation Value: <0| expr |0>
It evaluates the normal form and extracts only the scalar terms.
Any annihilation operator on the right yields 0.
Any creation operator on the left yields 0.
-/
noncomputable def vev (expr : QuExpr) : ℂ :=
  vev_core (normal_form expr)

end QuantumAlgebra.QuExpr
