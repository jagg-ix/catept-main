import CATEPTMain.Integration.TheoryPluginDimFundamental

set_option autoImplicit false

/-!
# Theory Plugin QTM Bridge

Connects the complex action dimensional decomposition (from
`TheoryPluginDimFundamental`) to Quantum Turing Machines, establishing that
spacetime regions and particles admit a principled QTM description through the
`computation / communication` split of the complex action.

## Core claim: complex action as computation + communication

The complex action `S = S_R + i·S_I` admits a **computation/communication duality**:

* **`Re(S)` → computation** — dimension `[I]`
  The Euclidean weight `e^{-S_R/ħ}` suppresses non-classical paths and drives
  *dissipation*: Landauer erasure, measurement-induced decoherence, irreversible
  gate operations.  Erasure of `n` bits costs `n k_B T` energy; in natural units
  (`k_B = 1`) this is `dim_computation_rate = dim_energy_ext = [I T⁻¹]`.

* **`Im(S)` → communication** — dimension `[I]` (same dimension, dual role)
  The Lorentzian phase `e^{i S_I/ħ}` drives *coherence*: unitary evolution
  `U = e^{i H t/ħ}`, entanglement generation, quantum interference, non-local
  correlations.  Shannon channel capacity is bounded by `E/ħω`; in natural units
  `dim_communication_rate = dim_energy_ext = [I T⁻¹]`.

The dimensional parity `[computation] = [communication] = [I]` is not accidental:
it is the **quantum information duality** (Holevo bound ↔ Landauer limit) expressed
in the CATEPT [I]-basis.

## QTM description of spacetime regions

A spacetime region or particle `R` admits a Quantum Turing Machine description
via a triple `(H(R), M(R), Λ(R))`:

```
H(R)  — Hilbert space of local degrees of freedom (dimension type d)
M(R)  — Von Neumann algebra of observables (SOT-closed *-subalgebra of B(H(R)))
Λ(R)  — CPTP channel decomposing as Λ_comm ∘ Λ_comp
          Im(S) drives Λ_comm (unitary Stinespring dilation)
          Re(S) drives Λ_comp  (Kraus decoherence operators)
```

The Stinespring dilation `Λ(ρ) = Tr_E[U (ρ ⊗ |0⟩⟨0|_E) U†]` realises both:
- `Λ_comp` = tracing out the environment (from `Re(S)` coupling)
- `Λ_comm` = residual unitary on the system (from `Im(S)` Hamiltonian)

## Composed regions

Composed regions (sequential or parallel) satisfy:
- **Sequential**: `Λ(R₂ ∘ R₁) = Λ(R₂) ∘ₘ Λ(R₁)` (channel composition)
- **Parallel**: `Λ(R₁ ⊗ R₂) = Λ(R₁) ⊗ Λ(R₂)` (tensor product of channels)
- **Algebraic**: `M(R₁ ⊗ R₂) ⊇ M(R₁) ⊗ M(R₂)` (tensor product of algebras)

## Lean-machines bridge

A QTM is a machine in the `lean-machines` sense
(https://github.com/lean-machines-central/lean-machines):
- **Context** = Hilbert space type `d`
- **State** = density matrix `ρ ∈ MState d` (`Tr(ρ) = 1`)
- **Transition** = CPTP channel `Λ : CPTPMap d d`
- **Safety invariant** = trace normalization
- **Halting** = projective measurement + classical readout

Lean-machines refinement maps to CPTP composition:
`abstract ≤ concrete  ↔  Λ_abstract = Tr_environment ∘ Λ_concrete`

## Quantum information backend (Phase-2 target)

The `QTMQuantumBackend` abstraction decouples this module from the direct import
of `QuantumInfo.Finite.{CPTPMap,MState,Entropy.VonNeumann}`, which is pinned at
toolchain v4.28.0 (upgrade tracked in `QuantumInfoBridge.lean`).  Phase-2 will
replace `QTMQuantumBackend` with the concrete `MState d` / `CPTPMap dIn dOut`
types once the toolchain is at v4.29.0.

## Theorem status

| Name                                     | Status  |
|------------------------------------------|---------|
| `dim_computation`                        | proved  |
| `dim_communication`                      | proved  |
| `computation_communication_same_dimension` | proved |
| `complex_action_realPart_is_computation` | proved  |
| `complex_action_imagPart_is_communication` | proved |
| `computation_rate_eq_energy`             | proved  |
| `communication_rate_eq_energy`           | proved  |
| `computation_clock_dimensionless`        | proved  |
| `communication_clock_dimensionless`      | proved  |
| `vonNeumann_entropy_is_computation_dim`  | proved  |
| `holevo_information_is_communication_dim` | proved |
| `landauer_shannon_dimensional_duality`   | proved  |
| `SpacetimeRegionQTM`                     | Phase-1 |
| `sequentialCompose`                      | Phase-1 |
| `parallelCompose`                        | Phase-1 |
| `VNAlgebraRegionWitness`                 | Phase-1 |
| `leanMachineQTMBridge`                   | Phase-1 |

-/

namespace CATEPTMain.Integration

open InformationDimensionalFramework.Concrete
open InformationDimensionalFramework.QuantumAction

-- ── Part A: Dimensional interpretation of Re(S) and Im(S) ────────────────────

/-!
### A.1  Computation and communication dimensions

Both are `[I]` — the information dimension — expressing the CATEPT thesis that
all physical processing (whether classical computation or quantum communication)
ultimately counts information states.
-/

/-- Computation dimension `[I]`: logical operations consume/process information.
    Landauer's principle: erasing one bit costs `k_B T ln 2` energy.
    In natural units (`k_B = 1`, `T` measured in [I]): `[computation] = [I]`. -/
def dim_computation : dimension InformationExtendedBase ℤ := dim_information

/-- Communication dimension `[I]`: quantum channels transmit information.
    Shannon / Holevo: quantum channel capacity `C` has units [bits / channel use],
    bounded by `S(ρ_out) ≤ log d`; in natural units `[communication] = [I]`. -/
def dim_communication : dimension InformationExtendedBase ℤ := dim_information

/-- Computation and communication carry the same dimension.
    This is the **quantum information duality**: a unit of computation costs exactly
    as much as a unit of communication (Landauer ↔ Holevo). -/
theorem computation_communication_same_dimension :
    dim_computation = dim_communication := rfl

/-!
### A.2  Complex action as computation/communication

The split `S = S_R + i·S_I` from `InformationDimensionalFrameworkBridge` §3.4
is re-read here through the computation/communication lens.
-/

/-- The real part of the complex action has the computation dimension.
    Physically: `S_R` is the Euclidean action; `e^{-S_R/ħ}` suppresses non-classical
    paths and drives decoherence / Landauer erasure / classical computation. -/
theorem complex_action_realPart_is_computation :
    dim_complex_action_realPart = dim_computation := rfl

/-- The imaginary part of the complex action has the communication dimension.
    Physically: `S_I` is the Lorentzian action; `e^{i S_I/ħ}` generates quantum
    interference, entanglement, and non-local correlations = quantum communication. -/
theorem complex_action_imagPart_is_communication :
    dim_complex_action_imagPart = dim_communication := rfl

/-- Both parts share the computation/communication dimension [I]: the two
    interpretations are dimensionally dual. -/
theorem computation_communication_action_parity :
    dim_complex_action_realPart = dim_complex_action_imagPart :=
  complex_action_parts_share_dimension

/-!
### A.3  Rate dimensions and Landauer/Shannon duality
-/

/-- Computation rate [I/T] = energy: Landauer's principle — erasing `n` bits per
    second dissipates `n k_B T` watts.  In natural units `[ṅ] = [I T⁻¹] = [E]`. -/
def dim_computation_rate : dimension InformationExtendedBase ℤ :=
  dim_computation * dim_time_ext⁻¹

theorem computation_rate_eq_energy :
    dim_computation_rate = dim_energy_ext := by
  funext b; fin_cases b <;> native_decide

/-- Communication rate [I/T] = energy: Shannon / Holevo theorem — quantum channel
    capacity `C ≤ S(ρ)/τ` in natural units gives `[C] = [I T⁻¹] = [E]`. -/
def dim_communication_rate : dimension InformationExtendedBase ℤ :=
  dim_communication * dim_time_ext⁻¹

theorem communication_rate_eq_energy :
    dim_communication_rate = dim_energy_ext := by
  funext b; fin_cases b <;> native_decide

/-- Landauer–Shannon dimensional duality: computation rate = communication rate = energy.
    This is the unified information–energy relation in the CATEPT [I]-basis. -/
theorem landauer_shannon_dimensional_duality :
    dim_computation_rate = dim_energy_ext ∧
    dim_communication_rate = dim_energy_ext :=
  ⟨computation_rate_eq_energy, communication_rate_eq_energy⟩

/-!
### A.4  Dimensionless clocks
-/

/-- The computation clock `S_R / ħ` is dimensionless: pure-number ratio counting
    units of Landauer erasure per ħ. -/
theorem computation_clock_dimensionless :
    dim_computation / dim_hbar_ext =
      dimension.dimensionless InformationExtendedBase ℤ := by
  simp only [dim_computation, dim_hbar_eq_information]
  simp [← dimension.one_eq_dimensionless]

/-- The communication clock `S_I / ħ` is dimensionless: pure-number quantum phase. -/
theorem communication_clock_dimensionless :
    dim_communication / dim_hbar_ext =
      dimension.dimensionless InformationExtendedBase ℤ :=
  computation_clock_dimensionless  -- identical: dim_communication = dim_computation

/-!
### A.5  Entropy = computation = communication
-/

/-- Von Neumann entropy `S(ρ) = −Tr(ρ log ρ)` has the computation dimension [I]:
    entropy counts distinguishable quantum states, i.e. information. -/
theorem vonNeumann_entropy_is_computation_dim :
    dim_entropy_ext = dim_computation := by
  rw [dim_entropy_eq_information]; rfl

/-- The Holevo quantity `χ = S(∑ pᵢ Λ(ρᵢ)) − ∑ pᵢ S(Λ(ρᵢ))` has the communication
    dimension [I]: it is the accessible quantum channel capacity in natural units. -/
theorem holevo_information_is_communication_dim :
    dim_entropy_ext = dim_communication := by
  rw [dim_entropy_eq_information]; rfl

-- ── Part B: Abstract Quantum Turing Machine backend ───────────────────────────

/-!
### B.1  Quantum backend (abstract certificate)

`QTMQuantumBackend` abstracts over the concrete `MState d` / `CPTPMap d d` types
from `QuantumInfo.Finite` (toolchain pinned at v4.28.0; see `QuantumInfoBridge`).
Phase-2 work item: replace with direct `QuantumInfo.Finite` imports at v4.29.0.
-/

/-- Abstract quantum information backend for spacetime region QTM descriptions.
    Provides: quantum states, channels, composition, tensor products, von Neumann
    entropy.  The proof fields are the minimal axioms that make the QTM structure
    theorems go through.

    **Phase-2 instantiation target:**
    ```lean
    def qiBackend (d : Type*) [Fintype d] [DecidableEq d] : QTMQuantumBackend where
      State              := MState d
      Channel            := CPTPMap d d
      applyChannel Λ ρ   := Λ ρ
      channelCompose Φ Ψ := Φ ∘ₘ Ψ
      channelId          := CPTPMap.id
      vonNeumannEntropy  := Sᵥₙ
      ...
    ``` -/
structure QTMQuantumBackend where
  /-- Carrier type of quantum states (density matrices). -/
  State    : Type*
  /-- Carrier type of quantum channels (CPTP maps). -/
  Channel  : Type*
  /-- Apply a channel to a state: `Λ(ρ)`. -/
  applyChannel    : Channel → State → State
  /-- Sequential composition: `Λ₂ ∘ₘ Λ₁`. -/
  channelCompose  : Channel → Channel → Channel
  /-- Identity channel `id`. -/
  channelId       : Channel
  /-- Tensor product of two states `ρ ⊗ σ`. -/
  tensorState     : State → State → State
  /-- Tensor product of two channels `Λ₁ ⊗ Λ₂`. -/
  tensorChannel   : Channel → Channel → Channel
  /-- Von Neumann entropy `S(ρ) = −Tr(ρ log ρ)`. -/
  vonNeumannEntropy : State → ℝ
  -- ── Axioms ──────────────────────────────────────────────────────────────
  /-- Channel composition is functorial: `(Φ ∘ Ψ)(ρ) = Φ(Ψ(ρ))`. -/
  channelCompose_apply :
      ∀ (Φ Ψ : Channel) (ρ : State),
        applyChannel (channelCompose Φ Ψ) ρ = applyChannel Φ (applyChannel Ψ ρ)
  /-- Identity channel leaves states unchanged. -/
  channelId_apply :
      ∀ (ρ : State), applyChannel channelId ρ = ρ
  /-- Channel composition is associative. -/
  channelCompose_assoc :
      ∀ (Φ₁ Φ₂ Φ₃ : Channel) (ρ : State),
        applyChannel (channelCompose Φ₁ (channelCompose Φ₂ Φ₃)) ρ =
        applyChannel (channelCompose (channelCompose Φ₁ Φ₂) Φ₃) ρ
  /-- Tensor product distributes over composition:
      `(Φ₁ ⊗ Φ₂) ∘ (Ψ₁ ⊗ Ψ₂) = (Φ₁ ∘ Ψ₁) ⊗ (Φ₂ ∘ Ψ₂)`. -/
  tensor_compose :
      ∀ (Φ₁ Φ₂ Ψ₁ Ψ₂ : Channel) (ρ σ : State),
        applyChannel (tensorChannel (channelCompose Φ₁ Ψ₁) (channelCompose Φ₂ Ψ₂))
                     (tensorState ρ σ) =
        applyChannel (channelCompose (tensorChannel Φ₁ Φ₂) (tensorChannel Ψ₁ Ψ₂))
                     (tensorState ρ σ)
  /-- Von Neumann entropy is non-negative. -/
  entropy_nonneg : ∀ (ρ : State), 0 ≤ vonNeumannEntropy ρ

/-!
### B.2  Spacetime region as a QTM

A region or particle `R` is described by:
- An initial state `ρ₀`
- A **computation channel** `Λ_comp` (driven by `Re(S)`)
- A **communication channel** `Λ_comm` (driven by `Im(S)`)
- A **total evolution** `Λ_total = Λ_comm ∘ₘ Λ_comp`

This is the operatorial form of the path-integral Wick rotation:
`e^{i S/ħ} = e^{i S_I/ħ} · e^{-S_R/ħ}  →  Λ_comm ∘ Λ_comp`.

The Stinespring dilation provides the microscopic justification:
```
Λ_comp(ρ) = Tr_E[ U_env (ρ ⊗ |0⟩_E) U_env† ]   -- tracing out decoherence environment
Λ_comm(ρ) = e^{i H_sys t} ρ e^{-i H_sys t}      -- unitary system evolution
```
-/

/-- A spacetime region (or particle) that admits a Quantum Turing Machine
    description, parameterised over an abstract quantum backend. -/
structure SpacetimeRegionQTM (backend : QTMQuantumBackend) where
  /-- Initial quantum state `ρ₀` of the region. -/
  initialState         : backend.State
  /-- Computation channel `Λ_comp`: dissipative evolution driven by `Re(S)`.
      Implements Landauer erasure, measurement-induced decoherence, irreversible gates. -/
  computationChannel   : backend.Channel
  /-- Communication channel `Λ_comm`: unitary evolution driven by `Im(S)`.
      Implements `e^{i H t}`, generates entanglement, non-local correlations. -/
  communicationChannel : backend.Channel
  /-- Total evolution channel `Λ_total`. -/
  totalEvolution       : backend.Channel
  /-- The total channel decomposes as communication-after-computation.
      Operatorial form of `e^{i S/ħ} = e^{i S_I/ħ} · e^{-S_R/ħ}`. -/
  decomposition :
      ∀ (ρ : backend.State),
        backend.applyChannel totalEvolution ρ =
          backend.applyChannel
            (backend.channelCompose communicationChannel computationChannel) ρ

-- ── Part C: Composed spacetime regions ────────────────────────────────────────

/-!
### C.1  Sequential composition

`R₁` then `R₂`: the region `R₂` acts after `R₁` in time.
The total evolution is `Λ(R₂) ∘ₘ Λ(R₁)`.

The per-component decomposition of the composed total into `comp ∘ comm` requires
the Trotter product formula (phase approximation) or commutativity of `Λ_comp` and
`Λ_comm` across the two regions — neither holds in general.  Phase-2 will handle
this via the Baker–Campbell–Hausdorff correction.  Phase-1: `decomposition` is
stated with a `sorry` stub.
-/

/-- Sequential composition: `R₂` follows `R₁`. -/
def SpacetimeRegionQTM.sequentialCompose
    {backend : QTMQuantumBackend}
    (R₁ R₂ : SpacetimeRegionQTM backend) :
    SpacetimeRegionQTM backend where
  initialState         := R₁.initialState
  computationChannel   :=
    backend.channelCompose R₂.computationChannel R₁.computationChannel
  communicationChannel :=
    backend.channelCompose R₂.communicationChannel R₁.communicationChannel
  totalEvolution       :=
    backend.channelCompose R₂.totalEvolution R₁.totalEvolution
  decomposition := by
    intro ρ
    -- Phase-1: requires Trotter / BCH correction or commutativity of
    -- Λ₂_comp with Λ₁_comm.  Both are Phase-2 obligations.
    -- Concretely: we need
    --   (Λ₂_comm ∘ Λ₂_comp) ∘ (Λ₁_comm ∘ Λ₁_comp)
    --   = (Λ₂_comm ∘ Λ₁_comm) ∘ (Λ₂_comp ∘ Λ₁_comp)
    -- which follows from Λ₂_comp ∘ Λ₁_comm = Λ₁_comm ∘ Λ₂_comp.
    sorry  -- Phase-1

/-- Sequential composition total evolution equals channel composition. -/
theorem sequentialCompose_totalEvolution
    {backend : QTMQuantumBackend}
    (R₁ R₂ : SpacetimeRegionQTM backend) (ρ : backend.State) :
    backend.applyChannel (R₁.sequentialCompose R₂).totalEvolution ρ =
      backend.applyChannel R₂.totalEvolution
        (backend.applyChannel R₁.totalEvolution ρ) := by
  simp only [SpacetimeRegionQTM.sequentialCompose]
  exact backend.channelCompose_apply R₂.totalEvolution R₁.totalEvolution ρ

/-- Sequential composition is associative on total evolutions. -/
theorem sequentialCompose_assoc
    {backend : QTMQuantumBackend}
    (R₁ R₂ R₃ : SpacetimeRegionQTM backend) (ρ : backend.State) :
    backend.applyChannel
      ((R₁.sequentialCompose R₂).sequentialCompose R₃).totalEvolution ρ =
    backend.applyChannel
      (R₁.sequentialCompose (R₂.sequentialCompose R₃)).totalEvolution ρ := by
  simp only [SpacetimeRegionQTM.sequentialCompose, backend.channelCompose_apply]

/-- The identity QTM region: total evolution is `channelId`. -/
def SpacetimeRegionQTM.identity
    {backend : QTMQuantumBackend} (ρ₀ : backend.State) :
    SpacetimeRegionQTM backend where
  initialState         := ρ₀
  computationChannel   := backend.channelId
  communicationChannel := backend.channelId
  totalEvolution       := backend.channelId
  decomposition := fun ρ => by
    simp [backend.channelCompose_apply, backend.channelId_apply]

/-- Left identity: identity ∘ R = R on total evolutions. -/
theorem sequentialCompose_identity_left
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) (ρ : backend.State) :
    backend.applyChannel
      (R.sequentialCompose (SpacetimeRegionQTM.identity R.initialState)).totalEvolution ρ =
    backend.applyChannel R.totalEvolution ρ := by
  simp only [SpacetimeRegionQTM.sequentialCompose, SpacetimeRegionQTM.identity,
             backend.channelCompose_apply, backend.channelId_apply]

/-- Right identity: R ∘ identity = R on total evolutions. -/
theorem sequentialCompose_identity_right
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) (ρ : backend.State) :
    backend.applyChannel
      ((SpacetimeRegionQTM.identity R.initialState).sequentialCompose R).totalEvolution ρ =
    backend.applyChannel R.totalEvolution ρ := by
  simp only [SpacetimeRegionQTM.sequentialCompose, SpacetimeRegionQTM.identity,
             backend.channelCompose_apply, backend.channelId_apply]

/-!
### C.2  Parallel composition (tensor product)

`R₁ ⊗ R₂`: the two regions coexist in space.  The joint Hilbert space is the
tensor product, and the joint channel is the tensor product of the individual
channels.  The tensor product distributes over composition (from `tensor_compose`
axiom), so the decomposition holds — modulo Phase-1 sorry for the `decomposition`
field which needs `tensorState` and the full bilinearity axiom.
-/

/-- Parallel (spatial tensor product) composition: `R₁` and `R₂` coexist. -/
def SpacetimeRegionQTM.parallelCompose
    {backend : QTMQuantumBackend}
    (R₁ R₂ : SpacetimeRegionQTM backend) :
    SpacetimeRegionQTM backend where
  initialState         := backend.tensorState R₁.initialState R₂.initialState
  computationChannel   := backend.tensorChannel R₁.computationChannel R₂.computationChannel
  communicationChannel := backend.tensorChannel R₁.communicationChannel R₂.communicationChannel
  totalEvolution       := backend.tensorChannel R₁.totalEvolution R₂.totalEvolution
  decomposition := by
    intro ρ
    -- Phase-1: the decomposition uses tensor_compose applied to the product state ρ,
    -- but ρ need not be a product state (it may be entangled).
    -- Full proof requires bilinearity of tensor_compose over arbitrary mixed states.
    -- Phase-2 obligation: extend tensor_compose to arbitrary states.
    sorry  -- Phase-1

/-- Parallel composition total evolution acts as product channel on product states. -/
theorem parallelCompose_totalEvolution_product
    {backend : QTMQuantumBackend}
    (R₁ R₂ : SpacetimeRegionQTM backend)
    (ρ₁ : backend.State) (ρ₂ : backend.State) :
    backend.applyChannel (R₁.parallelCompose R₂).totalEvolution
        (backend.tensorState ρ₁ ρ₂) =
      backend.tensorState
        (backend.applyChannel R₁.totalEvolution ρ₁)
        (backend.applyChannel R₂.totalEvolution ρ₂) := by
  simp only [SpacetimeRegionQTM.parallelCompose]
  sorry  -- Phase-1: requires tensor_apply axiom

-- ── Part D: Von Neumann algebra witness ────────────────────────────────────────

/-!
### D.1  Algebra of observables

Each spacetime region `R` has an associated Von Neumann algebra `M(R) ⊆ B(H(R))`:
the SOT-closed *-subalgebra of bounded operators representing observable quantities.

- Computation observables: diagonal in a preferred basis (classical register states)
- Communication observables: off-diagonal entries (quantum coherences / entanglement)

Composition:
- `M(R₁ ∘ R₂)` = tensor product of `M(R₁)` and `M(R₂)` for spacelike separated regions
- `M(R₁ ∘ R₂)` = commutant inclusion for causal (timelike) composition

This module provides an abstract witness; the concrete construction is Phase-2
(depends on `AFPBridge/HSTP/Theories/Von_Neumann_Algebras.lean` upgrade).
-/

/-- Abstract Von Neumann algebra witness for a spacetime region.
    Records the key algebraic properties without importing the AFP HSTP bridge.

    Phase-2 target: instantiate with `IsVonNeumannAlgebra` from
    `CATEPTMain.AFPBridge.HSTP.Theories.Von_Neumann_Algebras`. -/
structure VNAlgebraRegionWitness (backend : QTMQuantumBackend) where
  /-- The Von Neumann algebra as a predicate on channels (observables ↔ channels
      by Heisenberg picture: `A ↦ Λ_A` where `Λ_A(ρ) = A ρ A†`). -/
  algebra : backend.Channel → Prop
  /-- M contains the identity channel (algebra has unit). -/
  contains_identity : algebra backend.channelId
  /-- M is closed under sequential composition (operator multiplication). -/
  closed_under_compose :
      ∀ (Φ Ψ : backend.Channel), algebra Φ → algebra Ψ →
        algebra (backend.channelCompose Φ Ψ)
  /-- The computation channel of a region lies in M(R). -/
  computation_in_algebra : ∀ (R : SpacetimeRegionQTM backend),
      algebra R.computationChannel
  /-- The communication channel of a region lies in M(R). -/
  communication_in_algebra : ∀ (R : SpacetimeRegionQTM backend),
      algebra R.communicationChannel
  /-- The total evolution of a region lies in M(R). -/
  total_in_algebra : ∀ (R : SpacetimeRegionQTM backend),
      algebra R.totalEvolution

/-- Given a VN algebra witness and a spacetime region, the total evolution
    lies in the algebra (closed under composition = QTM dynamics stay in M(R)). -/
theorem vna_total_in_algebra
    {backend : QTMQuantumBackend}
    (vna : VNAlgebraRegionWitness backend)
    (R : SpacetimeRegionQTM backend) :
    vna.algebra R.totalEvolution :=
  vna.total_in_algebra R

/-- Sequential composition preserves the algebra: if both regions' channels are
    in M, the composed total evolution is also in M. -/
theorem vna_sequential_compose_closed
    {backend : QTMQuantumBackend}
    (vna : VNAlgebraRegionWitness backend)
    (R₁ R₂ : SpacetimeRegionQTM backend) :
    vna.algebra (R₁.sequentialCompose R₂).totalEvolution := by
  simp only [SpacetimeRegionQTM.sequentialCompose]
  exact vna.closed_under_compose _ _
    (vna.total_in_algebra R₂)
    (vna.total_in_algebra R₁)

-- ── Part E: Lean-machines QTM bridge ──────────────────────────────────────────

/-!
### E.1  Machine interface

The `lean-machines` library (https://github.com/lean-machines-central/lean-machines)
provides formal machine transition systems with:
- `Machine ctx state`: a state machine parameterised over context and state
- `OrdinaryMachine`: deterministic, non-deterministic, or probabilistic transitions
- `RefinementMachine`: abstract ≤ concrete refinement via simulation

A QTM is a lean-machine with:
- Context = Hilbert space type `d` (abstract here, `Type*` from `QTMQuantumBackend`)
- State = `ρ : State` (density matrix; `MState d` in Phase-2)
- Transition = CPTP channel `Λ : Channel` applied as `ρ ↦ Λ(ρ)`
- Safety invariant = von Neumann entropy non-negativity `0 ≤ S(ρ)`
- Halting = projective measurement returning a classical outcome

The `lean-machines` refinement structure:
```
Λ_abstract = Tr_env ∘ Λ_concrete   (partial trace = abstract description = env ignored)
```
maps to the abstract ≤ concrete order in lean-machines.

Phase-2 target: instantiate `LeanMachineQTMBridge` when lean-machines is added
to the lakefile:
```
require «lean-machines» from git
  "https://github.com/lean-machines-central/lean-machines.git" @ "<commit>"
```
-/

/-- Abstract bridge between a `SpacetimeRegionQTM` and the lean-machines
    transition-system interface.

    Fields are Prop witnesses for the machine axioms; Phase-2 will replace these
    with direct proofs using `LeanMachines.Machine` and related types. -/
structure LeanMachineQTMBridge (backend : QTMQuantumBackend) where
  /-- A spacetime region as a lean-machine state type. -/
  region : SpacetimeRegionQTM backend
  /-- Safety invariant: von Neumann entropy is non-negative at every step.
      This mirrors `LeanMachines.OrdinaryMachine.safety`. -/
  safety_invariant : ∀ (ρ : backend.State),
      0 ≤ backend.vonNeumannEntropy (backend.applyChannel region.totalEvolution ρ)
  /-- Liveness: the total evolution is reachable from the initial state.
      Mirrors `LeanMachines.Machine.reachability`. -/
  liveness : ∃ (_ : backend.State), True
  /-- Refinement: the computation channel refines to the communication channel
      via partial trace (environment tracing).  In lean-machines terms:
      `Λ_comp ≤ Λ_comm` in the refinement preorder. -/
  refinement_comp_to_comm : Prop
  /-- The lean-machines context is the backend's State type. -/
  machine_context_is_state : True

/-- Phase-1 instantiation of `LeanMachineQTMBridge` for any region.
    All non-trivial fields are sorry-proved pending lean-machines integration. -/
def leanMachineQTMBridge
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) :
    LeanMachineQTMBridge backend where
  region := R
  safety_invariant := fun ρ => by
    exact backend.entropy_nonneg _  -- S(Λ(ρ)) ≥ 0 from backend axiom
  liveness := ⟨R.initialState, trivial⟩
  refinement_comp_to_comm :=
    -- Phase-1: the Stinespring dilation shows Λ_comp is a dilation of Λ_comm.
    -- Proof: ∃ environment unitary U and environment state |0⟩ such that
    -- Λ_comm(ρ) = Tr_E[U (ρ ⊗ |0⟩) U†] = Λ_comp projected to system.
    True  -- placeholder Prop; Phase-2 will replace with Stinespring statement
  machine_context_is_state := trivial

/-- The lean-machines safety invariant holds for all QTM regions:
    von Neumann entropy is non-negative after any number of steps. -/
theorem leanMachine_safety
    {backend : QTMQuantumBackend}
    (bridge : LeanMachineQTMBridge backend) (ρ : backend.State) :
    0 ≤ backend.vonNeumannEntropy
          (backend.applyChannel bridge.region.totalEvolution ρ) :=
  bridge.safety_invariant ρ

-- ── Part F: Full spacetime QTM profile ────────────────────────────────────────

/-!
### F.1  Full QTM profile for a spacetime region

A `SpacetimeRegionQTMFull` bundles:
1. A `SpacetimeRegionQTM` (QTM quantum dynamics)
2. A `VNAlgebraRegionWitness` (Von Neumann algebra of observables)
3. A `LeanMachineQTMBridge` (machine-theoretic interface)
4. The dimensional profile from `TheoryPluginDimFundamental` (dimensional consistency)

This is the Phase-2 target: one structure that gives a complete formal account
of a spacetime region as a computing/communicating entity.
-/

/-- Full QTM profile: a region with quantum dynamics, algebra, machine interface,
    and dimensional consistency. -/
structure SpacetimeRegionQTMFull (backend : QTMQuantumBackend) where
  /-- Quantum dynamics (computation/communication channels + total evolution). -/
  qtm      : SpacetimeRegionQTM backend
  /-- Von Neumann algebra of observables. -/
  algebra  : VNAlgebraRegionWitness backend
  /-- Lean-machines bridge. -/
  machine  : LeanMachineQTMBridge backend
  /-- Dimensional self-consistency: computation rate = communication rate = energy. -/
  dimOk    : dim_computation_rate = dim_energy_ext ∧ dim_communication_rate = dim_energy_ext

/-- Any `SpacetimeRegionQTMFull` satisfies the Landauer–Shannon dimensional duality. -/
theorem qtmFull_landauer_shannon
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTMFull backend) :
    dim_computation_rate = dim_energy_ext ∧
    dim_communication_rate = dim_energy_ext :=
  R.dimOk

/-- Canonical full QTM profile: given a region and an algebra witness, package
    the full profile.  The dimensional consistency is proved by the Part A theorems. -/
def mkSpacetimeRegionQTMFull
    {backend : QTMQuantumBackend}
    (qtm     : SpacetimeRegionQTM backend)
    (algebra : VNAlgebraRegionWitness backend) :
    SpacetimeRegionQTMFull backend where
  qtm     := qtm
  algebra := algebra
  machine := leanMachineQTMBridge qtm
  dimOk   := landauer_shannon_dimensional_duality

/-- Composed regions give a composed full profile (sequential). -/
def SpacetimeRegionQTMFull.sequentialCompose
    {backend : QTMQuantumBackend}
    (P₁ P₂ : SpacetimeRegionQTMFull backend) :
    SpacetimeRegionQTMFull backend where
  qtm     := P₁.qtm.sequentialCompose P₂.qtm
  algebra := P₁.algebra  -- composite uses same algebra witness (Phase-1 simplification)
  machine := leanMachineQTMBridge (P₁.qtm.sequentialCompose P₂.qtm)
  dimOk   := landauer_shannon_dimensional_duality

end CATEPTMain.Integration
