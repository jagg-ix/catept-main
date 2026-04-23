import QuantumAlgebra.OperatorDefs
import QuantumAlgebra.NormalOrdering
import QuantumAlgebra.PhysicsFunctions

namespace QuantumAlgebra.Integration

open QuantumAlgebra.QuExpr

/--
A basic demonstration of mapping a VEV evaluation to a physical Action parameter.
Suppose we have an interaction Lagrangian L_int = lambda * phi^4.
We can formalize the perturbative expectation <0| L_int |0>.
-/
def phi_field (idx : Index) : QuExpr :=
  -- A discrete mode approximation: phi_i ~ a_i + a^\dagger_i
  add (a idx) (adag idx)

def phi_field_4 (idx : Index) : QuExpr :=
  let phi := phi_field idx
  phi * phi * phi * phi

/--
The vacuum expectation of the phi^4 interaction term at a single spatial site.
<0| phi_i^4 |0> evaluates the Wick contractions of (a + a^\dagger)^4.
-/
noncomputable def vev_phi_4 (idx : Index) : ℂ :=
  vev (phi_field_4 idx)

/--
A \phi^6 interaction term for higher-order perturbative expansions.
-/
def phi_field_6 (idx : Index) : QuExpr :=
  let phi := phi_field idx
  phi * phi * phi * phi * phi * phi

/--
The vacuum expectation of the phi^6 interaction term at a single spatial site.
Evaluating the Wick contractions of (a + a^\dagger)^6.
-/
noncomputable def vev_phi_6 (idx : Index) : ℂ :=
  vev (phi_field_6 idx)

/--
A Yukawa coupling between a scalar boson and a fermion pair: g \phi \bar{\psi} \psi.
We model this as a boson 'a' interacting with a fermion 'f'.
-/
def yukawa_interaction (idx : Index) (g : ℂ) : QuExpr :=
  let phi := phi_field idx
  let f_bar_f := add (mul (fdag idx) (f idx)) (scalar 0) -- Simplified local term
  mul (scalar g) (mul phi f_bar_f)

/--
Yukawa interaction VEV. Should typically be 0 without fermion loops.
-/
noncomputable def vev_yukawa (idx : Index) (g : ℂ) : ℂ :=
  vev (yukawa_interaction idx g)

end QuantumAlgebra.Integration
