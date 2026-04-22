import QuantumAlgebra.OperatorDefs

namespace QuantumAlgebra

open QuExpr

def Index.toString : Index → String
  | .int i => reprStr i
  | .name s => s

instance : ToString Index := ⟨Index.toString⟩

def SpinOp.toString : SpinOp → String
  | .x => "x"
  | .y => "y"
  | .z => "z"
  | .plus => "+"
  | .minus => "-"

instance : ToString SpinOp := ⟨SpinOp.toString⟩

partial def QuExpr.toString : QuExpr → String
  | scalar _ => "c" -- For now, avoid Complex toString as it might be noncomputable
  | param n idxs => s!"{n}_{idxs.map Index.toString}"
  | boson idx false => s!"a_{Index.toString idx}"
  | boson idx true => s!"a^†_{Index.toString idx}"
  | fermion idx false => s!"f_{Index.toString idx}"
  | fermion idx true => s!"f^†_{Index.toString idx}"
  | spin idx op => s!"σ^{SpinOp.toString op}_{Index.toString idx}"
  | add a b => s!"({QuExpr.toString a} + {QuExpr.toString b})"
  | mul a b => s!"({QuExpr.toString a} * {QuExpr.toString b})"

instance : ToString QuExpr := ⟨QuExpr.toString⟩
instance : Repr QuExpr := ⟨fun e _ => e.toString⟩

end QuantumAlgebra
