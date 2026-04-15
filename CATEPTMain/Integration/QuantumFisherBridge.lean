import CATEPTMain.Integration.CATEPTSpaceTime
/-!
# Quantum Fisher Information Bridge

Ports the Quantum Fisher Information (QFI) S_I generator cluster from:
`mathematica/0062`

## Mathematical content

* **Metric-parameterised state**: `ρ_g(θ)` — a density matrix parameterised
  by a physical metric `g` and estimation parameter `θ`.
* **Symmetric logarithmic derivative (SLD)**: `L(θ)` satisfying
  `∂_θ ρ = ½ (L ρ + ρ L)`.
* **Quantum Fisher Information**:
  `F(θ) = Tr[ρ(θ) L(θ)²]`.
  This is the maximal Fisher information attainable by any quantum measurement
  (quantum Cramér–Rao bound: `Var(θ̂) ≥ 1/F(θ)`).
* **QFI as S_I generator**: the gradient of QFI along the metric-state family
  `ρ_{g(τ)}` constitutes the generator of the imaginary-action component `S_I`:
  `dS_I/dτ = (ℏ/4) F(θ(τ))`.
  This is the quantum-information counterpart of the Yoshida free-Fisher generator.
* **Relation to Bures metric**: `F(θ) dθ² = 4 d²_B(ρ(θ), ρ(θ+dθ))` where
  `d_B` is the Bures distance.
* **Wigner–Yanase vs. SLD**: for mixed states, the SLD-QFI upper-bounds
  the Wigner–Yanase skew information `I(ρ,H) = −½ Tr[[ρ^{1/2}, H]²]`.

## CATEPT leverage points

* `AFPBridge.CBO.CBOPrelude.cboNorm` — QFI gradient norms tie to operator
  norm estimates in the CBO bridge.
* `AFPBridge.PM.PMPrelude.IsFullDensityOp` — `ρ_g(θ)` must satisfy
  `IsFullDensityOp` (positive, trace-1).
* `CATEPTSpaceTime.CATEPTSpacetimeModel.ept_causal_arrow` — `dS_I/dτ ≥ 0`
  (QFI is non-negative) gives the causal-arrow witness.
* `YoshidaFreeFisherBridge` — QFI (commutative limit) and free Fisher distance
  (free-probability limit) are connected via the large-dimension limit.

## Phase status
Phase-1: abstract witness; all obligations trivially discharged.
Phase-2: use `Mathlib.Analysis.MeanInequalities` + `IsHermitian` to construct
the SLD concretely and prove `F(θ) ≥ 0` via `Finset.sum_nonneg`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.QuantumFisher

/-- Witness for the QFI S_I generator construction. -/
structure QuantumFisherWitness where
  /-- A density-matrix family `ρ_g(θ)` parameterised by metric `g` and `θ`
      is well-defined (positive, trace-1). -/
  densityFamily_defined : Prop
  /-- The symmetric logarithmic derivative `L(θ)` exists satisfying
      `∂_θ ρ = ½ (L ρ + ρ L)`. -/
  sld_exists : Prop
  /-- `F(θ) = Tr[ρ L²] ≥ 0` (QFI is non-negative). -/
  qfi_nonneg : Prop
  /-- Quantum Cramér–Rao bound: `Var ≥ 1/F(θ)`. -/
  cramerRao_bound : Prop
  /-- QFI gradient generates `S_I`: `dS_I/dτ = (ℏ/4) F(θ(τ))`. -/
  sImag_generator_identity : Prop
  /-- Bures distance relation: `F(θ) dθ² = 4 d²_B(ρ, ρ+dρ)`. -/
  bures_relation : Prop
  /-- SLD-QFI upper-bounds Wigner–Yanase skew information. -/
  wigner_yanase_bound : Prop
  /-- Phase-1 axiom audit. -/
  axiom_audit_phase1 : Prop

/-- Integration contract. -/
def QuantumFisherIntegrationContract
    (w : QuantumFisherWitness) : Prop :=
  w.densityFamily_defined ∧ w.sld_exists ∧ w.qfi_nonneg ∧
  w.cramerRao_bound ∧ w.sImag_generator_identity ∧
  w.bures_relation ∧ w.wigner_yanase_bound ∧ w.axiom_audit_phase1

/-- Phase-1 bridge theorem. -/
theorem quantumFisher_integration_contract
    (w : QuantumFisherWitness)
    (hD  : w.densityFamily_defined)
    (hS  : w.sld_exists)
    (hQ  : w.qfi_nonneg)
    (hCR : w.cramerRao_bound)
    (hG  : w.sImag_generator_identity)
    (hBu : w.bures_relation)
    (hWY : w.wigner_yanase_bound)
    (hA  : w.axiom_audit_phase1) :
    QuantumFisherIntegrationContract w :=
  ⟨hD, hS, hQ, hCR, hG, hBu, hWY, hA⟩

end CATEPTMain.Integration.QuantumFisher
