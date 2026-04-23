import Mathlib.Data.Complex.Basic

namespace QuantumAlgebra

inductive Index
  | int (i : Int)
  | name (s : String)
  deriving Repr, DecidableEq

inductive SpinOp
  | x
  | y
  | z
  | plus
  | minus
  deriving Repr, DecidableEq

inductive QuExpr
  | scalar (c : ℂ)
  | param (n : String) (idxs : List Index)
  | boson (idx : Index) (is_dagger : Bool)
  | fermion (idx : Index) (is_dagger : Bool)
  | spin (idx : Index) (op : SpinOp)
  | add (a b : QuExpr)
  | mul (a b : QuExpr)

namespace QuExpr

def a (idx : Index) := boson idx false
def adag (idx : Index) := boson idx true
def f (idx : Index) := fermion idx false
def fdag (idx : Index) := fermion idx true

instance : Add QuExpr := ⟨add⟩
instance : Mul QuExpr := ⟨mul⟩
instance : Sub QuExpr := ⟨fun a b => add a (mul (scalar (-1)) b)⟩

end QuExpr
end QuantumAlgebra
