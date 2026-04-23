import CATEPTMain.NHQM.NHQMPrelude
import CATEPTMain.Integration.TheoryPluginArchitecture
/-!
# NHQM CATEPT Bridge — Non-Hermitian Quantum Mechanics Plugin Slot

Connects the Non-Hermitian Fermi-Dirac distribution theory
(Shen, Lu, Lado, Trif, PRL 133, 086301, 2024) to the unified
`CATEPTPluginSlot` / `TheoryPlugin` architecture.

## Physical interpretation

For an N-eigenstate non-Hermitian open quantum system:

  • Configuration space: `Fin N`  (eigenstate index)
  • `actionRe n`  = εₙ(φ)      (real part of eigenvalue = energy)
  • `actionIm n`  = γₙ(φ) ≥ 0  (decay rate = imaginary part magnitude)
  • `hbar`        = ħ            (Planck's constant)
  • `eptClock n`  = γₙ(φ)/ħ    (irreversibility rate of state n)

The consistency constraint `actionIm n / hbar = eptClock n` is trivially
`γₙ/ħ = γₙ/ħ`, satisfied by definition.

## CATEPT interpretation

The Feynman-Kac weight exp(−S_I/ħ) = exp(−γₙt) is the lifetime damping
factor for eigenstate n.  This is precisely the non-Hermitian modification
of the Boltzmann weight: in the zero-temperature limit the modified
Fermi-Dirac distribution becomes a weighted step function where each state's
weight is exp(−γₙΔτ) over an entropic time interval Δτ.

## Exceptional point → eptClock continuity

At an exceptional point (EP) where γₙ = γₘ, the eptClock values agree:
  eptClock n = γₙ/ħ = γₘ/ħ = eptClock m
The persistent current's continuity at the EP (the paper's main theorem)
is captured by `nhFermiDirac_continuousAtEP`.

## Theorem status

| Name                               | Status | Notes                              |
|------------------------------------|--------|------------------------------------|
| `nhqmCATEPTSlot`                   | proved | CATEPTPluginSlot for N eigenstates |
| `nhqmCATEPTSlot_consistent`        | proved | cateptConsistencyConstraint        |
| `nhqmCATEPTSlot_eptClock_at_EP`    | proved | eptClock continuous at EP          |
| `nhqmFKWeight_at_EP`               | proved | FK weights agree at EP             |
| `nhqmPlugin`                       | proved | full TheoryPlugin instance         |
| `nhqmPlugin_catept_consistent`     | proved | cateptSpineConstraint              |
-/

set_option autoImplicit false

open CATEPTMain.Integration

namespace CATEPTMain.NHQM.NHQMCATEPTBridge

noncomputable section

-- ── NHQM CATEPT slot ──────────────────────────────────────────────────────────

/-- The NHQM CATEPT plugin slot for an N-eigenstate open quantum system at
    magnetic flux φ and Planck constant ħ.

    The imaginary action S_I(n) = γₙ(φ) is the decay rate of eigenstate n,
    guaranteed nonneg by `complexEigenvalueIm_nonneg`.

    The Feynman-Kac weight exp(−S_I(n)) = exp(−γₙ(φ)) is the lifetime
    damping — this IS the non-Hermitian Fermi-Dirac occupation weight in the
    zero-temperature dissipation-dominated regime.

    The entropic clock τ_ent(n) = γₙ(φ)/ħ measures per-eigenstate irreversibility. -/
def nhqmCATEPTSlot
    (N : ℕ) (H : CATEPTMain.NHQM.NHHamiltonian N) (φ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) :
    CATEPTPluginSlot where
  ConfigSpaceTy   := Fin N
  actionRe        := fun n => CATEPTMain.NHQM.complexEigenvalueRe N H φ n
  actionIm        := fun n => CATEPTMain.NHQM.complexEigenvalueIm N H φ n
  actionIm_nonneg := fun n => CATEPTMain.NHQM.complexEigenvalueIm_nonneg N H φ n
  hbar            := ħ
  hbar_pos        := hħ
  eptClock        := fun n => CATEPTMain.NHQM.complexEigenvalueIm N H φ n / ħ
  eptClock_nonneg := fun n =>
    div_nonneg (CATEPTMain.NHQM.complexEigenvalueIm_nonneg N H φ n) (le_of_lt hħ)

-- ── Consistency constraint ────────────────────────────────────────────────────

/-- The NHQM slot satisfies the CATEPT consistency constraint:
    γₙ(φ) / ħ = γₙ(φ) / ħ  (entropic clock = scaled imaginary action). -/
theorem nhqmCATEPTSlot_consistent
    (N : ℕ) (H : CATEPTMain.NHQM.NHHamiltonian N) (φ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) :
    cateptConsistencyConstraint (nhqmCATEPTSlot N H φ ħ hħ) := by
  intro n
  simp [nhqmCATEPTSlot]

-- ── Exceptional point → eptClock agreement ───────────────────────────────────

/-- At an exceptional point, the two coalescing eigenstates have equal
    entropic clock values.  The persistent current's continuity at the EP
    (paper's main theorem) is consistent with eptClock continuity. -/
theorem nhqmCATEPTSlot_eptClock_at_EP
    (N : ℕ) (H : CATEPTMain.NHQM.NHHamiltonian N) (φ_EP : ℝ) (ħ : ℝ) (hħ : 0 < ħ)
    (m n : Fin N) (hEP : CATEPTMain.NHQM.exceptionalPointAt N H φ_EP m n) :
    (nhqmCATEPTSlot N H φ_EP ħ hħ).eptClock m =
    (nhqmCATEPTSlot N H φ_EP ħ hħ).eptClock n := by
  simp [nhqmCATEPTSlot]
  exact congrArg (· / ħ) hEP.2

/-- Strong EP variant: the same eptClock equality follows from the stronger
    EP predicate by projection to the spectral coalescence part. -/
theorem nhqmCATEPTSlot_eptClock_at_EP_strong
    (N : ℕ) (H : CATEPTMain.NHQM.NHHamiltonian N) (φ_EP : ℝ) (ħ : ℝ) (hħ : 0 < ħ)
    (m n : Fin N) (hEP : CATEPTMain.NHQM.exceptionalPointAtStrong N H φ_EP m n) :
    (nhqmCATEPTSlot N H φ_EP ħ hħ).eptClock m =
    (nhqmCATEPTSlot N H φ_EP ħ hħ).eptClock n :=
  nhqmCATEPTSlot_eptClock_at_EP N H φ_EP ħ hħ m n hEP.1

-- ── Exceptional point → FK-weight equality ────────────────────────────────────

/-- FK weight along entropic time interval `τ` for eigenstate `n`.
    This uses the slot's eptClock density directly. -/
def nhqmFKWeight
    (N : ℕ) (H : CATEPTMain.NHQM.NHHamiltonian N)
    (φ : ℝ) (ħ : ℝ) (hħ : 0 < ħ)
    (n : Fin N) (τ : ℝ) : ℝ :=
  Real.exp (-((nhqmCATEPTSlot N H φ ħ hħ).eptClock n * τ))

/-- EP consequence: if two states coalesce at `φ_EP`, their FK weights are equal
    for every entropic interval `τ`. -/
theorem nhqmFKWeight_at_EP
    (N : ℕ) (H : CATEPTMain.NHQM.NHHamiltonian N)
    (φ_EP : ℝ) (ħ : ℝ) (hħ : 0 < ħ)
    (m n : Fin N) (hEP : CATEPTMain.NHQM.exceptionalPointAt N H φ_EP m n) :
    ∀ τ : ℝ, nhqmFKWeight N H φ_EP ħ hħ m τ = nhqmFKWeight N H φ_EP ħ hħ n τ := by
  intro τ
  unfold nhqmFKWeight
  simp [nhqmCATEPTSlot_eptClock_at_EP N H φ_EP ħ hħ m n hEP]

/-- Strong-EP variant of FK-weight equality. -/
theorem nhqmFKWeight_at_EP_strong
    (N : ℕ) (H : CATEPTMain.NHQM.NHHamiltonian N)
    (φ_EP : ℝ) (ħ : ℝ) (hħ : 0 < ħ)
    (m n : Fin N) (hEP : CATEPTMain.NHQM.exceptionalPointAtStrong N H φ_EP m n) :
    ∀ τ : ℝ, nhqmFKWeight N H φ_EP ħ hħ m τ = nhqmFKWeight N H φ_EP ħ hħ n τ := by
  intro τ
  exact nhqmFKWeight_at_EP N H φ_EP ħ hħ m n hEP.1 τ

-- ── Full TheoryPlugin instance ────────────────────────────────────────────────

/-- A `TheoryPlugin` built from the NHQM CATEPT slot.

    The quantum type fields carry physically meaningful witnesses:
    - `QuantumOpTy = ℝ` represents the persistent current I(φ)
    - `quantumOps` is empty (phase-1); phase-2: [persistentCurrentOp]
    All other physics slots carry unit witnesses (phase-2 targets).

    CATEPT spine: `nhqmCATEPTSlot N H φ ħ hħ` carries the eigenstate
    path-integral model where FK weights are the NH lifetime factors. -/
def nhqmPlugin
    (N : ℕ) (hN : 0 < N) (H : CATEPTMain.NHQM.NHHamiltonian N)
    (β μ : ℝ) (φ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) :
    TheoryPlugin where
  name               := "NHQMPersistentCurrentPlugin"
  -- Model space: ℝ (spectral parameter space, phase-1)
  ModelSpaceTy       := ℝ
  -- Spacetime point: magnetic flux value
  SpacetimePointTy   := ℝ
  -- Field: eigenstate amplitudes (phase-1 scalar proxy)
  FieldTy            := ℝ
  -- Particle: eigenstate index
  ParticleTy         := Fin N
  -- Gauge group: U(1) flux gauge (phase-1 unit)
  GaugeGroupTy       := Unit
  -- Diffeomorphism: flux reparametrization (phase-1 unit)
  DiffeoTy           := Unit
  -- Unified action: complex eigenvalue (real part)
  UnifiedActionTy    := ℝ
  -- Metric: phase-1 unit
  MetricTy           := Unit
  -- Curvature: phase-1 unit
  CurvatureTy        := Unit
  -- Stress-energy: phase-1 unit
  StressEnergyTy     := Unit
  -- EM field: persistent current (real-valued)
  EMFieldTy          := ℝ
  -- Quantum operators: persistent current observable
  QuantumOpTy        := ℝ
  -- Fourier field: phase-1 unit
  FourierFieldTy     := Unit
  particles          := List.ofFn id   -- all N eigenstates
  quantumOps         := []
  quantize           := fun _ => ⟨0, hN⟩  -- phase-1: map to ground state
  gaugeInvariant     := fun _ _ => True
  diffeoInvariant    := fun _ _ => True
  locallyFlat        := fun _ _ => True
  globallyCurved     := fun _ => True
  fourierLimit       := fun _ _ => True
  lowEnergyLimit     := fun a => a
  highEnergyLimit    := fun a => a
  classicalTarget    := CATEPTMain.NHQM.complexEigenvalueRe N H φ ⟨0, hN⟩
  quantumTarget      := CATEPTMain.NHQM.complexEigenvalueRe N H φ ⟨0, hN⟩
  emDualityInvariant := fun _ => True
  stressConserved    := fun _ => True
  matterGeometryCoupling := fun _ _ => True
  symmetryConstraint := fun _ => True
  couplingConstraint := fun _ _ _ => True
  semiclassicalCorrespondence := fun _ _ => True
  unifiedAction      := CATEPTMain.NHQM.complexEigenvalueRe N H φ ⟨0, hN⟩
  metric             := ()
  curvature          := ()
  stressEnergy       := ()
  emField            := CATEPTMain.NHQM.persistentCurrentFromSpec N H β μ φ
  manifoldWitness    := True.intro
  catept             := nhqmCATEPTSlot N H φ ħ hħ

/-- The NHQM plugin satisfies the CATEPT spine constraint. -/
theorem nhqmPlugin_catept_consistent
    (N : ℕ) (hN : 0 < N) (H : CATEPTMain.NHQM.NHHamiltonian N)
    (β μ : ℝ) (φ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) :
    cateptSpineConstraint (nhqmPlugin N hN H β μ φ ħ hħ) :=
  nhqmCATEPTSlot_consistent N H φ ħ hħ

/-- Flux-indexed EM field extracted from `nhqmPlugin`.
    This is the same current field as `nhPersistentCurrentField`. -/
def nhqmPlugin_emFieldOverFlux
    (N : ℕ) (hN : 0 < N) (H : CATEPTMain.NHQM.NHHamiltonian N)
    (β μ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) : ℝ → ℝ :=
  fun φ => (nhqmPlugin N hN H β μ φ ħ hħ).emField

theorem nhqmPlugin_emFieldOverFlux_eq_currentField
    (N : ℕ) (hN : 0 < N) (H : CATEPTMain.NHQM.NHHamiltonian N)
    (β μ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) :
    nhqmPlugin_emFieldOverFlux N hN H β μ ħ hħ =
      CATEPTMain.NHQM.nhPersistentCurrentField N H β μ := by
  funext φ
  rfl

/-- Plugin-level continuity witness at EP: the flux-indexed EM field
    is continuous at exceptional points. -/
theorem nhqmPlugin_emFieldOverFlux_continuousAtEP
    (N : ℕ) (hN : 0 < N) (H : CATEPTMain.NHQM.NHHamiltonian N)
    (β μ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) (m n : Fin N) (φ_EP : ℝ)
    (hEP : CATEPTMain.NHQM.exceptionalPointAt N H φ_EP m n) :
    ContinuousAt (nhqmPlugin_emFieldOverFlux N hN H β μ ħ hħ) φ_EP := by
  simpa [nhqmPlugin_emFieldOverFlux] using
    (CATEPTMain.NHQM.nhPersistentCurrentField_continuousAtEP
      N H β μ m n φ_EP hEP)

theorem nhqmPlugin_emFieldOverFlux_continuousAtEP_strong
    (N : ℕ) (hN : 0 < N) (H : CATEPTMain.NHQM.NHHamiltonian N)
    (β μ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) (m n : Fin N) (φ_EP : ℝ)
    (hEP : CATEPTMain.NHQM.exceptionalPointAtStrong N H φ_EP m n) :
    ContinuousAt (nhqmPlugin_emFieldOverFlux N hN H β μ ħ hħ) φ_EP :=
  nhqmPlugin_emFieldOverFlux_continuousAtEP N hN H β μ ħ hħ m n φ_EP hEP.1

/-- Backward-compatible plugin constructor with the previous call shape:
    fixes `(β, μ) = (1, 0)`. -/
def nhqmPlugin_legacy
    (N : ℕ) (hN : 0 < N) (H : CATEPTMain.NHQM.NHHamiltonian N)
    (φ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) :
    TheoryPlugin :=
  nhqmPlugin N hN H (1 : ℝ) (0 : ℝ) φ ħ hħ

theorem nhqmPlugin_legacy_catept_consistent
    (N : ℕ) (hN : 0 < N) (H : CATEPTMain.NHQM.NHHamiltonian N)
    (φ : ℝ) (ħ : ℝ) (hħ : 0 < ħ) :
    cateptSpineConstraint (nhqmPlugin_legacy N hN H φ ħ hħ) :=
  nhqmPlugin_catept_consistent N hN H (1 : ℝ) (0 : ℝ) φ ħ hħ

end  -- noncomputable section

end CATEPTMain.NHQM.NHQMCATEPTBridge
