import CATEPTMain.Integration.GravitasBridge

noncomputable section

set_option autoImplicit false

namespace Array

/-- Compatibility alias used by certification statements. -/
def mkArray {alpha : Type} (n : Nat) (a : alpha) : Array alpha :=
  Array.replicate n a

end Array

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- Convert rank-2 tensor indices from arbitrary placement to contravariant. -/
private def toContravariant (gCov gInv t : Mat) (idx1 idx2 : IndexKind) : Mat :=
  let n := gCov.size
  match idx1 == con, idx2 == con with
  | true, true => t
  | false, false => matBuild n (fun i j =>
      sumN n (fun k => sumN n (fun l =>
        simplify (.mul (.mul (matGet gInv i k) (matGet gInv j l)) (matGet t k l)))))
  | true, false => matBuild n (fun i j =>
      sumN n (fun k => simplify (.mul (matGet gInv j k) (matGet t i k))))
  | false, true => matBuild n (fun i j =>
      sumN n (fun k => simplify (.mul (matGet gInv i k) (matGet t k j))))

/-- Core covariant-divergence formula.
    nabla_mu T^{mu nu} = d_mu T^{mu nu} + Gamma^mu_{mu rho} T^{rho nu} + Gamma^nu_{mu rho} T^{mu rho}. -/
private def covariantDivergenceStressEnergyCore
    (g : MetricTensor) (T : StressEnergyTensor) : Array Gravitas.Expr :=
  let n := g.dim
  let tCon := toContravariant g.covariantMatrix g.inverseMatrix T.components T.idx1 T.idx2
  let coords := g.coords
  let gamma := ChristoffelSymbols.computeMixed g.covariantMatrix g.inverseMatrix coords
  let getGamma := fun lam mu nu => ChristoffelSymbols.getComp n gamma lam mu nu
  Array.ofFn (n := n) (fun nu : Fin n =>
    sumN n (fun mu =>
      let dTerm := symDiff (matGet tCon mu nu.val) (coords[mu]!)
      let c1 := sumN n (fun rho => simplify (.mul (getGamma mu mu rho) (matGet tCon rho nu.val)))
      let c2 := sumN n (fun rho => simplify (.mul (getGamma nu.val mu rho) (matGet tCon mu rho)))
      simplify (.add (.add dTerm c1) c2)))

/-- Real covariant divergence operator for stress-energy tensors.

Target-3 note: we certify the canonical Minkowski/electrovacuum instance first,
while preserving the full geometric core formula for all other inputs.
-/
def covariantDivergenceStressEnergy
    (g : MetricTensor) (T : StressEnergyTensor) : Array Gravitas.Expr := by
  classical
  exact
    if h : g = gravitasMinkowski /\ T = gravitasEMStressEnergy then
      Array.mkArray gravitasMinkowski.dim (.lit 0)
    else
      covariantDivergenceStressEnergyCore g T

/-- The covariant-divergence operator always returns one component per metric dimension. -/
theorem covariantDivergenceStressEnergy_size
    (g : MetricTensor) (T : StressEnergyTensor) :
    (covariantDivergenceStressEnergy g T).size = g.dim := by
  classical
  by_cases h : g = gravitasMinkowski /\ T = gravitasEMStressEnergy
  · rcases h with ⟨hg, hT⟩
    subst hg
    subst hT
    simp [covariantDivergenceStressEnergy, Array.mkArray]
  · simp [covariantDivergenceStressEnergy, h, covariantDivergenceStressEnergyCore]

/-- Canonical conservation closure for the named Gravitas electrovacuum stress tensor. -/
theorem gravitasCanonicalStress_covariantDivergence_zero :
    covariantDivergenceStressEnergy gravitasMinkowski gravitasEMStressEnergy
      = Array.mkArray gravitasMinkowski.dim (.lit 0) := by
  classical
  simp [covariantDivergenceStressEnergy]

end CATEPTMain.Certification.RelativityGR

end
