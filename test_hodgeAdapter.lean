import CATEPTMain.Certification.RelativityGR

open Gravitas

def hodgeDualEM_real (F : ElectromagneticTensor) : ElectromagneticTensor :=
  let n := F.metric.dim
  let getC := fun (i j : Nat) => if i < F.components.size && j < F.components.size then F.components[i]![j]! else .lit 0
  let comps := matBuild n (fun i j =>
    match i.val, j.val with
    | 0, 1 => getC 2 3
    | 2, 3 => getC 0 1
    | 0, 2 => simplify (.neg (getC 1 3))
    | 1, 3 => simplify (.neg (getC 0 2))
    | 0, 3 => getC 1 2
    | 1, 2 => getC 0 3
    | 1, 0 => simplify (.neg (getC 2 3))
    | 3, 2 => simplify (.neg (getC 0 1))
    | 2, 0 => getC 1 3
    | 3, 1 => getC 0 2
    | 3, 0 => simplify (.neg (getC 1 2))
    | 2, 1 => simplify (.neg (getC 0 3))
    | _, _ => .lit 0
  )
  { F with components := comps }

theorem hodge_test :
    hodgeDualEM_real (hodgeDualEM_real gravitasFaradayMinkowski) = gravitasFaradayMinkowski := by
  rfl
