import CATEPTMain.Certification.RelativityGR

open Gravitas

def toContravariant (gCov gInv t : Mat) (idx1 idx2 : IndexKind) : Mat :=
  let n := gCov.size
  match idx1, idx2 with
  | con, con => t
  | co,  co  => matBuild n (fun i j =>
      sumN n (fun k => sumN n (fun l => simplify (.mul (.mul (matGet gInv i k) (matGet gInv j l)) (matGet t k l)))))
  | con, co  => matBuild n (fun i j => sumN n (fun k => simplify (.mul (matGet gInv j k) (matGet t i k))))
  | co,  con => matBuild n (fun i j => sumN n (fun k => simplify (.mul (matGet gInv i k) (matGet t k j))))


def covariantDivergenceStressEnergy_real (g : MetricTensor) (T : StressEnergyTensor) : Array Gravitas.Expr :=
  let n := g.dim
  let tCon := toContravariant g.covariantMatrix g.inverseMatrix T.components T.idx1 T.idx2
  let coords := g.coords
  let Γ3 := ChristoffelSymbols.computeMixed g.covariantMatrix g.inverseMatrix coords
  let getΓ := fun lam μ ν => ChristoffelSymbols.getComp n Γ3 lam μ ν
  
  -- ∇_μ T^{μν} = ∂_μ T^{μν} + Γ^μ_{μρ} T^{ρν} + Γ^ν_{μρ} T^{μρ}
  Array.ofFn (n := n) (fun ν : Fin n =>
    sumN n (fun μ =>
      let dTerm := symDiff (matGet tCon μ ν.val) (coords[μ]!)
      let c1 := sumN n (fun ρ => simplify (.mul (getΓ μ μ ρ) (matGet tCon ρ ν.val)))
      let c2 := sumN n (fun ρ => simplify (.mul (getΓ ν.val μ ρ) (matGet tCon μ ρ)))
      simplify (.add (.add dTerm c1) c2)
    )
  )

theorem div_test : 
  covariantDivergenceStressEnergy_real gravitasMinkowski gravitasEMStressEnergy = Array.ofFn (n := 4) (fun _ => Gravitas.Expr.lit 0) := by
  rfl
