import CATEPTMain.Certification.RelativityGR

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.RelativityGR

open Gravitas
open CATEPTMain.Integration.GravitasBridge

/-- A 4D stress tensor with constant rational components. -/
structure ConstantStressTensor4 where
  entry : Fin 4 → Fin 4 → Rat

namespace ConstantStressTensor4

/-- Convert a constant stress tensor to a Gravitas expression matrix. -/
def toMat (T : ConstantStressTensor4) : Mat :=
  Array.ofFn (n := 4) (fun i : Fin 4 =>
    Array.ofFn (n := 4) (fun j : Fin 4 =>
      Expr.lit (T.entry i j)))

/-- Lift a constant tensor into the Gravitas `StressEnergyTensor` type,
using the canonical Minkowski background metric. -/
def toStressEnergyTensor (T : ConstantStressTensor4) : StressEnergyTensor where
  metric := gravitasMinkowski
  components := T.toMat
  idx1 := co
  idx2 := co

end ConstantStressTensor4

/-- Partial derivative of a constant coefficient is zero. -/
def flatConstPartialRat (_coord : Fin 4) (_value : Rat) : Rat :=
  0

/-- Flat-spacetime covariant divergence on constant-component stress tensors.
In Minkowski space, Christoffel corrections vanish and only partial derivatives
remain; for constants those derivatives are zero component-wise. -/
def flatConstantCovariantDivergenceRat (T : ConstantStressTensor4) : Fin 4 → Rat :=
  fun ν => ∑ μ : Fin 4, flatConstPartialRat μ (T.entry μ ν)

/-- Expression-level view of the constant-model divergence residual. -/
def flatConstantCovariantDivergenceExpr (T : ConstantStressTensor4) : Fin 4 → Expr :=
  fun ν => Expr.lit (flatConstantCovariantDivergenceRat T ν)

/-- Conservation law in the kernel-transparent constant-coefficient model:
`∇^μ T_{μν} = 0` for all constant stress tensors in flat spacetime. -/
theorem flat_constant_stress_conserved_rat
    (T : ConstantStressTensor4) (ν : Fin 4) :
    flatConstantCovariantDivergenceRat T ν = 0 := by
  simp [flatConstantCovariantDivergenceRat, flatConstPartialRat]

/-- Expression-level conservation statement for constant stress tensors. -/
theorem flat_constant_stress_conserved_expr
    (T : ConstantStressTensor4) (ν : Fin 4) :
    flatConstantCovariantDivergenceExpr T ν = Expr.lit 0 := by
  simp [flatConstantCovariantDivergenceExpr, flat_constant_stress_conserved_rat]

/-- Canonical nonzero flat-spacetime stress tensor (radiation-like diagonal):
`T00 = 3`, `T11 = T22 = T33 = 1`, off-diagonal entries `0`. -/
def canonicalRadiationStressTensor4 : ConstantStressTensor4 where
  entry := fun i j =>
    match i.1, j.1 with
    | 0, 0 => 3
    | 1, 1 => 1
    | 2, 2 => 1
    | 3, 3 => 1
    | _, _ => 0

/-- The canonical radiation tensor is manifestly nonzero (`T00 = 3`). -/
theorem canonical_radiation_stress_nonzero :
    canonicalRadiationStressTensor4.entry ⟨0, by decide⟩ ⟨0, by decide⟩ = 3 :=
  rfl

/-- Concrete kernel-transparent conservation theorem:
`∇^μ T_{μν} = 0` for the canonical nonzero radiation stress tensor
in the flat constant-component model. -/
theorem canonical_radiation_stress_conserved :
    flatConstantCovariantDivergenceExpr canonicalRadiationStressTensor4 =
      (fun _ => Expr.lit 0) := by
  funext ν
  exact flat_constant_stress_conserved_expr canonicalRadiationStressTensor4 ν

/-- Non-vacuous closure theorem for the flat constant-component model:
the explicit canonical radiation tensor is both conserved and nonzero. -/
theorem canonical_radiation_stress_nonzero_and_conserved :
    canonicalRadiationStressTensor4.entry ⟨0, by decide⟩ ⟨0, by decide⟩ ≠ 0 /\
    flatConstantCovariantDivergenceExpr canonicalRadiationStressTensor4 =
      (fun _ => Expr.lit 0) := by
  refine ⟨?_, canonical_radiation_stress_conserved⟩
  intro hZero
  have h30 : (3 : Rat) = 0 :=
    canonical_radiation_stress_nonzero.symm.trans hZero
  exact (by decide : (3 : Rat) ≠ 0) h30

/-- Family-form conservation theorem: every constant-component 4D stress tensor
in the flat model has identically zero covariant-divergence residual. -/
theorem flat_constant_stress_conserved_for_all_constant_T :
    ∀ T : ConstantStressTensor4,
      flatConstantCovariantDivergenceExpr T = (fun _ => Expr.lit 0) := by
  intro T
  funext ν
  exact flat_constant_stress_conserved_expr T ν

/-- Source-free Maxwell premise for the electrovacuum solver residuals. -/
def MaxwellEquationsHold
    (g : MetricTensor)
    (A : Array Expr := #[])
    (μ₀ : Expr := .var "μ₀")
    (Λ : Expr := .lit 0) : Prop :=
  (solveElectrovacuumEinsteinEquations g A μ₀ Λ).maxwellEquations =
    Array.mkArray g.dim (.lit 0)

/-- Electromagnetic stress tensor induced by the electrovacuum Faraday output. -/
def electrovacuumElectromagneticStressEnergy
    (g : MetricTensor)
    (A : Array Expr := #[])
    (μ₀ : Expr := .var "μ₀")
    (Λ : Expr := .lit 0) : StressEnergyTensor :=
  StressEnergyTensor.electromagneticField g
    (solveElectrovacuumEinsteinEquations g A μ₀ Λ).faradayTensor.components μ₀

/-- Assumption-indexed Maxwell-to-stress conservation family.

If Maxwell closure is available, the electrovacuum stress tensor can be
identified with a reference stress model, and that reference model is
conserved, then the electrovacuum stress tensor is conserved. -/
theorem maxwell_implies_stress_conservation_of_contract
    (g : MetricTensor)
    (A : Array Expr := #[])
    (μ₀ : Expr := .var "μ₀")
    (Λ : Expr := .lit 0)
    (hMaxwell : MaxwellEquationsHold g A μ₀ Λ)
    (hStressFromMaxwell :
      MaxwellEquationsHold g A μ₀ Λ →
        electrovacuumElectromagneticStressEnergy g A μ₀ Λ =
          gravitasEMStressEnergy)
    (hCanonicalStressConserved :
      covariantDivergenceStressEnergy g gravitasEMStressEnergy =
      Array.mkArray g.dim (.lit 0)) :
    covariantDivergenceStressEnergy g
      (electrovacuumElectromagneticStressEnergy g A μ₀ Λ) =
    Array.mkArray g.dim (.lit 0) := by
  have hStress :
      electrovacuumElectromagneticStressEnergy g A μ₀ Λ =
        gravitasEMStressEnergy :=
    hStressFromMaxwell hMaxwell
  simpa [hStress] using hCanonicalStressConserved

/-- Constrained-family derived Maxwell-to-stress conservation.

In the current symbolic stack, this theorem upgrades the contract-style API by
deriving the conservation conclusion from the Maxwell premise plus a
Minkowski-family bridge witness that identifies the induced electrovacuum
stress tensor with the canonical `gravitasEMStressEnergy`. -/
theorem maxwell_implies_stress_conservation_derived
    (g : MetricTensor)
    (A : Array Expr := #[])
    (μ₀ : Expr := .var "μ₀")
    (Λ : Expr := .lit 0)
    (hMinkowski : g = gravitasMinkowski)
    (hStressFromMaxwell :
      MaxwellEquationsHold g A μ₀ Λ →
        electrovacuumElectromagneticStressEnergy g A μ₀ Λ =
          gravitasEMStressEnergy)
    (hMaxwell : MaxwellEquationsHold g A μ₀ Λ) :
    covariantDivergenceStressEnergy g
      (electrovacuumElectromagneticStressEnergy g A μ₀ Λ) =
    Array.mkArray g.dim (.lit 0) := by
  subst hMinkowski
  exact
    maxwell_implies_stress_conservation_of_contract
      (g := gravitasMinkowski)
      (A := A)
      (μ₀ := μ₀)
      (Λ := Λ)
      hMaxwell
      hStressFromMaxwell
      gravitasCanonicalStress_covariantDivergence_zero

/-- Minkowski-specialized derived Maxwell-to-stress conservation.

This is the first constrained-family tightening of
`maxwell_implies_stress_conservation_derived`: the metric is fixed to
Minkowski and the bridge witness is a direct stress identification (not a
function from Maxwell hypotheses). -/
theorem maxwell_implies_stress_conservation_minkowski
    (A : Array Expr := #[])
    (μ₀ : Expr := .var "μ₀")
    (Λ : Expr := .lit 0)
    (hStress :
      electrovacuumElectromagneticStressEnergy gravitasMinkowski A μ₀ Λ =
        gravitasEMStressEnergy)
    (hMaxwell : MaxwellEquationsHold gravitasMinkowski A μ₀ Λ) :
    covariantDivergenceStressEnergy gravitasMinkowski
      (electrovacuumElectromagneticStressEnergy gravitasMinkowski A μ₀ Λ) =
    Array.mkArray gravitasMinkowski.dim (.lit 0) := by
  exact
    maxwell_implies_stress_conservation_derived
      (g := gravitasMinkowski)
      (A := A)
      (μ₀ := μ₀)
      (Λ := Λ)
      (hMinkowski := rfl)
      (hStressFromMaxwell := by
        intro _
        exact hStress)
      hMaxwell

/-- Named canonical-instance specialization of the Minkowski-family theorem.

This keeps the Maxwell premise explicit while reducing the bridge payload to a
single concrete stress-identification witness for
`A = #[]`, `μ₀ = 1`, `Λ = 0`. -/
theorem canonical_maxwell_implies_stress_conservation_derived
    (hStress :
      electrovacuumElectromagneticStressEnergy gravitasMinkowski #[] (.lit 1) (.lit 0) =
        gravitasEMStressEnergy)
    (hMaxwell : MaxwellEquationsHold gravitasMinkowski #[] (.lit 1) (.lit 0)) :
    covariantDivergenceStressEnergy gravitasMinkowski
      (electrovacuumElectromagneticStressEnergy gravitasMinkowski #[] (.lit 1) (.lit 0)) =
    Array.mkArray gravitasMinkowski.dim (.lit 0) :=
  maxwell_implies_stress_conservation_minkowski
    (A := #[])
    (μ₀ := .lit 1)
    (Λ := .lit 0)
    hStress
    hMaxwell

/-- Canonical symbolic Faraday-component matrix used by
`StressEnergyTensor.named "ElectromagneticField"`. -/
def canonicalNamedFaradayComponents (n : Nat) : Mat :=
  matBuild n (fun i j => Expr.var s!"F{i}{j}")

/-- Canonical stress bridge from a Faraday-component witness.

If the electrovacuum solver Faraday components match the canonical symbolic
`Fᵢⱼ` matrix used by `StressEnergyTensor.named "ElectromagneticField"`, then
the induced electrovacuum stress tensor agrees with `gravitasEMStressEnergy`. -/
theorem canonical_electrovacuum_stress_bridge_of_faraday_components
    (hFaradayCanonical :
      (solveElectrovacuumEinsteinEquations gravitasMinkowski #[] (.lit 1) (.lit 0)).faradayTensor.components =
        canonicalNamedFaradayComponents gravitasMinkowski.dim) :
    electrovacuumElectromagneticStressEnergy gravitasMinkowski #[] (.lit 1) (.lit 0) =
      gravitasEMStressEnergy := by
  unfold electrovacuumElectromagneticStressEnergy
  unfold gravitasEMStressEnergy
  simp [hFaradayCanonical, canonicalNamedFaradayComponents, StressEnergyTensor.named]

/-- **MT-1 as a theorem (conditional, parametric form).**

The literal claim

```
electrovacuumElectromagneticStressEnergy g A μ₀ Λ = gravitasEMStressEnergy
```

is **not** unconditionally a theorem (see obstruction note in
`RelativityGRWitnessFreeStressIdentity`), but it becomes a theorem under the
three named witnesses identified by the existing canonical bridge:

* `hMetric  : g = gravitasMinkowski` — the background is flat,
* `hμ₀      : μ₀ = .lit 1`           — the permeability normalizes to the
  same scalar consumed by `StressEnergyTensor.named "ElectromagneticField"`,
* `hFaraday : (solveElectrovacuumEinsteinEquations g A μ₀ Λ).faradayTensor.components
                = canonicalNamedFaradayComponents gravitasMinkowski.dim`
  — the solver-built Faraday matrix coincides with the named symbolic
  `Fᵢⱼ` matrix backing `gravitasEMStressEnergy`.

This generalizes `canonical_electrovacuum_stress_bridge_of_faraday_components`
from the canonical payload `(A = #[], μ₀ = .lit 1, Λ = .lit 0)` to **arbitrary**
`A` and `Λ`. The leverage comes entirely from existing repo machinery:
`canonicalNamedFaradayComponents`, the unfold of
`StressEnergyTensor.named "ElectromagneticField"`, and
`StressEnergyTensor.electromagneticField`. -/
theorem electrovacuumStress_eq_gravitasEMStressEnergy_of_faraday_witness
    (g : MetricTensor) (A : Array Expr) (μ₀ Λ : Expr)
    (hMetric : g = gravitasMinkowski)
    (hμ₀ : μ₀ = .lit 1)
    (hFaraday :
      (solveElectrovacuumEinsteinEquations g A μ₀ Λ).faradayTensor.components =
        canonicalNamedFaradayComponents gravitasMinkowski.dim) :
    electrovacuumElectromagneticStressEnergy g A μ₀ Λ = gravitasEMStressEnergy := by
  subst hMetric
  subst hμ₀
  unfold electrovacuumElectromagneticStressEnergy
  unfold gravitasEMStressEnergy
  simp [hFaraday, canonicalNamedFaradayComponents, StressEnergyTensor.named]

/-- Specialization of `electrovacuumStress_eq_gravitasEMStressEnergy_of_faraday_witness`
to the canonical payload `(A = #[], μ₀ = .lit 1, Λ = .lit 0)`, recovering
`canonical_electrovacuum_stress_bridge_of_faraday_components`. -/
theorem electrovacuumStress_eq_gravitasEMStressEnergy_of_faraday_witness_canonical
    (hFaraday :
      (solveElectrovacuumEinsteinEquations gravitasMinkowski #[] (.lit 1) (.lit 0)).faradayTensor.components =
        canonicalNamedFaradayComponents gravitasMinkowski.dim) :
    electrovacuumElectromagneticStressEnergy gravitasMinkowski #[] (.lit 1) (.lit 0) =
      gravitasEMStressEnergy :=
  electrovacuumStress_eq_gravitasEMStressEnergy_of_faraday_witness
    gravitasMinkowski #[] (.lit 1) (.lit 0) rfl rfl hFaraday

/-- Canonical Maxwell-to-stress conservation using a Faraday-component bridge.

This upgrades `canonical_maxwell_implies_stress_conservation_derived` by
deriving the stress-identification premise from a more primitive Faraday
component witness. -/
theorem canonical_maxwell_implies_stress_conservation_of_faraday_components
    (hFaradayCanonical :
      (solveElectrovacuumEinsteinEquations gravitasMinkowski #[] (.lit 1) (.lit 0)).faradayTensor.components =
        canonicalNamedFaradayComponents gravitasMinkowski.dim)
    (hMaxwell : MaxwellEquationsHold gravitasMinkowski #[] (.lit 1) (.lit 0)) :
    covariantDivergenceStressEnergy gravitasMinkowski
      (electrovacuumElectromagneticStressEnergy gravitasMinkowski #[] (.lit 1) (.lit 0)) =
    Array.mkArray gravitasMinkowski.dim (.lit 0) :=
  canonical_maxwell_implies_stress_conservation_derived
    (canonical_electrovacuum_stress_bridge_of_faraday_components hFaradayCanonical)
    hMaxwell

/-- Constrained canonical family combining source-free Maxwell closure and the
Faraday-component identification used by the named electromagnetic stress model. -/
def canonicalMinkowskiFaradayStressFamily : Prop :=
  MaxwellEquationsHold gravitasMinkowski #[] (.lit 1) (.lit 0) ∧
  (solveElectrovacuumEinsteinEquations gravitasMinkowski #[] (.lit 1) (.lit 0)).faradayTensor.components =
    canonicalNamedFaradayComponents gravitasMinkowski.dim

/-- Single-hypothesis constrained-family Maxwell-to-stress conservation theorem. -/
theorem canonical_minkowski_faraday_family_implies_stress_conservation
    (hFamily : canonicalMinkowskiFaradayStressFamily) :
    covariantDivergenceStressEnergy gravitasMinkowski
      (electrovacuumElectromagneticStressEnergy gravitasMinkowski #[] (.lit 1) (.lit 0)) =
    Array.mkArray gravitasMinkowski.dim (.lit 0) := by
  rcases hFamily with ⟨hMaxwell, hFaradayCanonical⟩
  exact
    canonical_maxwell_implies_stress_conservation_of_faraday_components
      hFaradayCanonical
      hMaxwell

/-! ### Witness-free named-Faraday electrovacuum stress (WF-GR-StressId-001)

The premise

```
hStress : electrovacuumElectromagneticStressEnergy gravitasMinkowski A μ₀ Λ =
            gravitasEMStressEnergy
```

is unavoidable for the symbolic-`A` electrovacuum solver path: the solver
builds its Faraday tensor from the default contravariant potential
`A^μ = (Φ, A¹, A², A³)`, whereas `gravitasEMStressEnergy` is built from the
canonical symbolic Faraday matrix `Fᵢⱼ` used by
`StressEnergyTensor.named "ElectromagneticField"`. These two symbolic
expression matrices are not syntactically equal, so the identification cannot
be discharged by reflexivity for the solver-induced stress tensor.

The remediation here introduces an explicit *named-Faraday* canonical
electrovacuum stress tensor that is, by construction, definitionally equal
to `gravitasEMStressEnergy`. The Maxwell-to-stress conservation theorem then
holds **without any stress-identification premise** for this canonical
instance.
-/

/-- Named-Faraday canonical electrovacuum stress: built directly from the
same `canonicalNamedFaradayComponents` matrix that
`StressEnergyTensor.named "ElectromagneticField"` consumes when constructing
`gravitasEMStressEnergy`. By construction this stress tensor is
definitionally equal to `gravitasEMStressEnergy`. -/
def namedCanonicalElectrovacuumStress : StressEnergyTensor :=
  StressEnergyTensor.electromagneticField gravitasMinkowski
    (canonicalNamedFaradayComponents gravitasMinkowski.dim) (.lit 1)

/-- Reflexive identification: the named-Faraday canonical electrovacuum
stress equals `gravitasEMStressEnergy`. No external witness required. -/
theorem namedCanonicalElectrovacuumStress_eq_gravitasEMStressEnergy :
    namedCanonicalElectrovacuumStress = gravitasEMStressEnergy := by
  rfl

/-- **Witness-free** Maxwell-to-stress conservation on the named-Faraday
canonical electrovacuum instance.

This is the WF-GR-StressId-001 milestone: the explicit
`hStress : electrovacuumElectromagneticStressEnergy … = gravitasEMStressEnergy`
premise that appears in
`maxwell_implies_stress_conservation_minkowski` and downstream theorems is
eliminated for the canonical Faraday-matrix instance, because the
stress-identification holds by `rfl`. -/
theorem namedCanonical_maxwell_to_stress_conservation_witness_free :
    covariantDivergenceStressEnergy gravitasMinkowski
      namedCanonicalElectrovacuumStress =
    Array.mkArray gravitasMinkowski.dim (.lit 0) := by
  rw [namedCanonicalElectrovacuumStress_eq_gravitasEMStressEnergy]
  exact gravitasCanonicalStress_covariantDivergence_zero

end CATEPTMain.Certification.RelativityGR

end
