import CATEPTGravitasPort.ElectromagneticTensor

open Gravitas

def test_idx (F : ElectromagneticTensor) (i j : Nat) : Expr :=
  if h : i < F.components.size ∧ j < F.components.size then 
    (F.components[i]'h.left)[j]!
  else 
    .lit 0

