import QuantumAlgebra.OperatorDefs
import QuantumAlgebra.NormalOrdering
import QuantumAlgebra.PhysicsFunctions
import QuantumAlgebra.ActionIntegration

open QuantumAlgebra
open QuantumAlgebra.QuExpr

def i_idx := Index.name "i"
def j_idx := Index.name "j"

-- Test 1: Simple commutation swap [a_i, a^\dagger_i] = a_i a^\dagger_i - a^\dagger_i a_i
noncomputable def comm := commutator (a i_idx) (adag i_idx)
#reduce normal_form comm

-- Test 2: Multi-term Wick contraction for VEV: <0| a_i a_i a_i^\dagger a_i^\dagger |0>
-- By Wick's theorem, there are 2! = 2 full contractions, so it should evaluate to exactly 2.
noncomputable def wick_test : QuExpr := 
  (a i_idx) * (a i_idx) * (adag i_idx) * (adag i_idx)

-- Let's observe the full normal ordered polynomial
#reduce normal_form wick_test

-- And now the isolated Vacuum Expectation Value
noncomputable def wick_vev := vev wick_test
#reduce wick_vev

-- Test 3: VEV of phi^4
-- \phi = a + a^\dagger. Wick contractions of \phi^4 give 3!/(2^1 1!) = 3
noncomputable def vev_phi_4_test := QuantumAlgebra.Integration.vev_phi_4 i_idx
#reduce vev_phi_4_test
