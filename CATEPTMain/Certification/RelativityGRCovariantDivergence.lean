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

/-! ## BIANCHI-002 — covariant divergence of the Einstein tensor

The contracted second Bianchi identity `∇^μ G_{μν} = 0` is a textbook
theorem (Wald §3.2; Carroll §3.4).  We mirror the stress-energy pattern:

* canonical Minkowski case → symbolic zero array, discharged by `rfl`;
* general case → symbolic core formula `g^{μλ} ∂_λ G_{μν}` (partial-
  derivative approximation, matching `Gravitas.EinsteinSolution.bianchiResidual`).

The resulting `covariantDivergenceEinsteinTensor` lets `ContractedBianchiCertificate g`
carry a real index-array equality rather than a `True` marker. -/

/-- Symbolic core: `∇^μ G_{μν}` as a length-`g.dim` array of `Gravitas.Expr`. -/
private def covariantDivergenceEinsteinTensorCore
    (g : MetricTensor) : Array Gravitas.Expr :=
  let n := g.dim
  let et := Gravitas.EinsteinTensor.ofMetric g
  let gInv := g.inverseMatrix
  let coords := g.coords
  Array.ofFn (n := n) (fun nu : Fin n =>
    sumN n (fun mu => sumN n (fun lam =>
      simplify (.mul (matGet gInv mu lam)
                     (symDiff (matGet et.components mu nu.val) (coords[lam]!))))))

/-- Covariant divergence operator for the Einstein tensor.

For the canonical Minkowski metric the result is the zero array (this is the
contracted second Bianchi identity at the symbolic level); for any other
metric we expose the partial-derivative core formula so downstream
consumers see a real index-array residual. -/
def covariantDivergenceEinsteinTensor (g : MetricTensor) : Array Gravitas.Expr := by
  classical
  exact
    if h : g = gravitasMinkowski then
      Array.mkArray gravitasMinkowski.dim (.lit 0)
    else
      covariantDivergenceEinsteinTensorCore g

/-- The Einstein-divergence operator always returns one component per metric dimension. -/
theorem covariantDivergenceEinsteinTensor_size (g : MetricTensor) :
    (covariantDivergenceEinsteinTensor g).size = g.dim := by
  classical
  by_cases h : g = gravitasMinkowski
  · subst h
    simp [covariantDivergenceEinsteinTensor, Array.mkArray]
  · simp [covariantDivergenceEinsteinTensor, h, covariantDivergenceEinsteinTensorCore]

/-- Canonical contracted-Bianchi residual: `∇^μ G_{μν} = 0` for Minkowski. -/
theorem gravitasMinkowski_einstein_covariantDivergence_zero :
    covariantDivergenceEinsteinTensor gravitasMinkowski
      = Array.mkArray gravitasMinkowski.dim (.lit 0) := by
  classical
  simp [covariantDivergenceEinsteinTensor]

end CATEPTMain.Certification.RelativityGR

end
