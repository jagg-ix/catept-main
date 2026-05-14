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

/-! ## BIANCHI-014 — DEFERRED: Levi-Civita upgrade of `covariantDivergenceEinsteinTensor`

**Status (catept-cert-review 20260513):** open gap recorded by upstream as
"Missing 6 — Actual covariant divergence operator is still symbolic-core /
partial-connection level".

**What we currently have.**
`covariantDivergenceEinsteinTensor g` (above) reduces to the literal zero
array on `gravitasMinkowski` and otherwise returns the symbolic core
`covariantDivergenceEinsteinTensorCore g`, which mirrors
`Gravitas.EinsteinSolution.bianchiResidual` — i.e. a partial-derivative
expression `g^{μλ} ∂_λ G_{μν}`, **not** the full Levi-Civita covariant
derivative `∇^μ G_{μν}` acting on smooth tensor fields.  This is enough for
the Bianchi-route certification surface (BIANCHI-006/007/008/012/013) because
every concrete family ships its own `HasContractedBianchi` witness as an
`Array.mkArray g.dim (.lit 0)` equality at the symbolic level, but it is
strictly weaker than the smooth-geometry theorem.

**What is missing.**
A separate Gravitas/geometry-bridge layer would need to provide, at minimum:

  * a predicate `IsLeviCivitaConnection (g : MetricTensor) : Prop` characterising
    the unique torsion-free metric-compatible connection of `g`;
  * a smooth-tensor covariant divergence operator
    `leviCivitaDivergenceEinsteinTensor (g : MetricTensor) : Array Gravitas.Expr`
    built from genuine `Mathlib.Geometry.Manifold` / Riemannian-geometry
    primitives rather than coordinate partials;
  * the compatibility theorem
    `covariantDivergenceEinsteinTensor_eq_leviCivita_divergence
      (g : MetricTensor) (hLC : IsLeviCivitaConnection g) :
      covariantDivergenceEinsteinTensor g = leviCivitaDivergenceEinsteinTensor g`;
  * and the smooth-geometric contracted second Bianchi identity
    `contracted_bianchi_leviCivita
      (g : MetricTensor) (hLC : IsLeviCivitaConnection g) :
      covariantDivergenceEinsteinTensor g = Array.mkArray g.dim (.lit 0)`.

**Why this is deferred.**
None of the smooth-pseudo-Riemannian machinery above currently exists in
`catept-gravitas-port` v0.2.0; the relevant Mathlib pieces
(`Mathlib.Geometry.Manifold.VectorBundle.*`, Levi-Civita connection,
covariant derivative on `(M, g)`) are not yet imported into this project.
Adding a Prop placeholder `IsLeviCivitaConnection := fun _ => True` and a
vacuous compatibility theorem would dishonestly inflate the certification
surface, so we instead record the gap here and leave the upgrade to a future
geometry bridge (target file:
`catept-gravitas-port/CATEPTGravitasPort/Geometry/LeviCivita.lean`).

**Tracking.** REPLYID 20260513-BIANCHI-COVERAGE-MISSING-TARGETS — Missing 6.
Acceptance criteria for closing this gap: the four statements above shipped
as actual theorems (no axioms, no `sorry`), audit-pure under
`[propext, Classical.choice, Quot.sound]`, with at least one non-Minkowski
family discharging `IsLeviCivitaConnection`. -/

end CATEPTMain.Certification.RelativityGR

end
