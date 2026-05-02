import CATEPTMain.Integration.EtaSpectralDensityCarrier
import CATEPTMain.Integration.NonHermitianQuantumCAT
import CATEPTMain.Integration.OpenSystemMasterEquationCarrier
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# PerturbativeApproximationCarrier — Tier-5 QuantumDynamics.jl Approximate Methods

Consolidates the **Tier-5** content of QuantumDynamics.jl
(`Approximate/`) into structural-carrier landing pads.  Tier 5
covers the *perturbative* and *semiclassical* approximations to the
open-system dynamics already captured in the exact (Tiers 1, 2, 4)
and master-equation (Tier 3) modules.

## Files leveraged

* `Approximate/Bare.jl` — bare dynamics with optional Lindblad jumps
  (`prop_RHS`).  Markov limit, no environment memory.
* `Approximate/BlochRedfield.jl` — Bloch-Redfield R-tensor `R[a,b,c,d]`
  built from Hamiltonian eigendecomposition + spectral density.
  Weak-coupling, Markov approximation.
* `Approximate/Forster.jl` — incoherent rate-transfer with line-shape
  function `g(t)` (cumulant expansion).  Strong-coupling /
  weak-electronic-coupling limit.
* `Approximate/Semiclassical/PLDM.jl` — Huo-Coker 2011 Partial
  Linearised Density Matrix dynamics (mapped variables).
* `Approximate/Semiclassical/LSC.jl` — Sun-Wang-Miller 1997/1998
  Linearised SemiClassical IVR.
* `Approximate/Semiclassical/SpinPLDM.jl` — spin variant of PLDM.
* `Approximate/Semiclassical/SpinLSC.jl` — spin variant of LSC.

## Bridge to existing CAT/EPT structure

Each of these methods is a **specialised regime** of the exact
non-Markovian framework:

* **Bare ↔ `NonHermitianQuantumCAT` with `expH_I = 0`**:
  no environment ⟹ no imaginary action ⟹ pure unitary (or pure
  GKLS if jumps `L` are present).
* **Bloch-Redfield ↔ Tier-3 `MemoryKernel rmax = 1`**:
  Markov limit of the GQME memory kernel — only the most recent
  past matters.
* **Förster ↔ Tier-1 `IdentifyEtaWithComplexAction`** at strong
  spectral-density coupling: the line-shape `g(t)` is the cumulant
  expansion of the imaginary action.
* **PLDM / LSC (semiclassical IVR) ↔ Tier-1 `QCPI`**:
  classical phase-space sampling of the path integral, which the
  Tier-1 `QuasiClassicalCarrier` already covers structurally.

The new module ships an *approximation hierarchy* carrier that
identifies each regime as a constraint on the Tier-1/Tier-3 carriers
already in scope.

## Honest scope

* This is **not** a derivation of Bloch-Redfield equations from
  perturbation theory, nor a Förster-rate expression from the
  cumulant expansion.  Those derivations live in the upstream
  Julia code; the Lean carrier exposes only the structural shape
  and the regime constraint.
* PLDM / LSC require quantum-classical phase-space machinery
  (mapped variables, Wigner sampling, Monte Carlo) that is well
  beyond Mathlib's current scope; we cover them as carriers.

## What this module ships

* `BareDynamicsRegime` — `expH_I ≡ 0` carrier (no environment).
* `BlochRedfieldRegime` — Markov limit: memory kernel of length
  `rmax = 1`, equivalent to the GQME with one-step memory.
* `ForsterRateRegime` — strong-coupling line-shape carrier with
  `lineShape : ℝ → ℝ` non-negative magnitude.
* `SemiclassicalIVRRegime` — classical-phase-space sampling
  carrier with `nSamples ≥ 1` and per-sample weight.
* `IdentifyApproximationsAsRegimes` — the unification bridge:
  each regime is a constraint on Tier-1 / Tier-3 carriers.
* `perturbative_approximation_bundle` — capstone existence theorem.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.PerturbativeApproximationCarrier

open CATEPTMain.Integration.EtaSpectralDensityCarrier
open CATEPTMain.Integration.NonHermitianQuantumCAT
open CATEPTMain.Integration.OpenSystemMasterEquationCarrier

-- ============================================================================
-- 1. Bare-dynamics regime (no environment)
-- ============================================================================

/-- **Bare-dynamics regime.**

Maps to `Approximate/Bare.jl::prop_RHS` (Bare.jl:12–25).  In the
absence of bath influence, the imaginary part of the Hamiltonian
vanishes (`H_I = 0`); the dynamics reduces to unitary (or, if
Lindblad jumps `L` are present, to plain GKLS).

Carrier: a `NonHermitianGenerator` from CAT/EPT plus the constraint
`expH_I ≡ 0` (vanishing dissipation expectation). -/
structure BareDynamicsRegime where
  /-- The underlying CAT/EPT non-Hermitian generator. -/
  generator         : NonHermitianGenerator
  /-- Bare regime constraint: `⟨H_I⟩(t) = 0` for all `t`. -/
  bare_constraint   : ∀ t, generator.expH_I t = 0

namespace BareDynamicsRegime

variable (B : BareDynamicsRegime)

/-- The norm-squared is constant in the bare regime — there is no
dissipation to drive decay.  We capture this via the existing
`norm_decay` invariant: combined with `bare_constraint`, the only
allowed evolution is non-increasing, but at zero rate.  We don't
prove constancy here (that would require strengthening
`NonHermitianGenerator`); we just expose the constraint. -/
theorem expH_I_at_zero : B.generator.expH_I 0 = 0 := B.bare_constraint 0

/-- Trivial existence: zero generator. -/
theorem exists_trivial : ∃ _ : BareDynamicsRegime, True :=
  ⟨{ generator       := { ℏ              := 1
                        , ℏ_pos          := by norm_num
                        , expH_I         := fun _ => 0
                        , expH_I_nonneg  := fun _ => le_refl 0
                        , normSq         := fun _ => 1
                        , normSq_nonneg  := fun _ => by norm_num
                        , norm_decay     := fun _ _ _ => le_refl 1 }
   , bare_constraint := fun _ => rfl }, trivial⟩

end BareDynamicsRegime

-- ============================================================================
-- 2. Bloch-Redfield regime (Markov limit)
-- ============================================================================

/-- **Bloch-Redfield regime.**

Maps to `Approximate/BlochRedfield.jl::get_Rtensor` (BlochRedfield.jl:11–32).
Bloch-Redfield is the Markov limit: only the most recent past matters,
equivalent to a GQME memory kernel of length 1.

Carrier: a `MemoryKernel` from Tier 3 with `rmax = 1`. -/
structure BlochRedfieldRegime where
  /-- The memory kernel (length-1 = Markov). -/
  memoryKernel         : MemoryKernel
  /-- Markov constraint: memory length is exactly 1. -/
  markov_constraint    : memoryKernel.rmax = 1

namespace BlochRedfieldRegime

variable (B : BlochRedfieldRegime)

/-- The Markov-limit memory kernel has at most one entry, which is
non-negative. -/
theorem rmax_eq_one : B.memoryKernel.rmax = 1 := B.markov_constraint

/-- Trivial existence: zero-kernel of length 1. -/
theorem exists_trivial : ∃ _ : BlochRedfieldRegime, True :=
  ⟨{ memoryKernel       := { rmax     := 1
                            , K        := fun _ => 0
                            , K_nonneg := fun _ => le_refl 0 }
   , markov_constraint  := rfl }, trivial⟩

end BlochRedfieldRegime

-- ============================================================================
-- 3. Förster rate regime (strong-coupling line-shape)
-- ============================================================================

/-- **Förster rate regime.**

Maps to `Approximate/Forster.jl::get_F_A` (Forster.jl:6–25).  The
line-shape function `g(t)` is the cumulant expansion of the imaginary
action; its magnitude bounds the rate of incoherent transfer.

Carrier: real-valued `lineShape : ℝ → ℝ` with `lineShape t ≥ 0`
(the magnitude of `g(t)`) and `lineShape 0 = 0` (vanishes at `t = 0`,
since `g(0) = 0` by the cumulant construction). -/
structure ForsterRateRegime where
  /-- Line-shape magnitude. -/
  lineShape             : ℝ → ℝ
  /-- Non-negativity. -/
  lineShape_nonneg      : ∀ t, 0 ≤ lineShape t
  /-- Vanishing at zero (cumulant boundary condition). -/
  lineShape_at_zero     : lineShape 0 = 0

namespace ForsterRateRegime

variable (F : ForsterRateRegime)

/-- The line shape at `t = 0` is non-negative (trivially, since it's
zero). -/
theorem lineShape_at_zero_nonneg : 0 ≤ F.lineShape 0 := F.lineShape_nonneg 0

/-- Trivial existence: zero line-shape. -/
theorem exists_trivial : ∃ _ : ForsterRateRegime, True :=
  ⟨{ lineShape         := fun _ => 0
   , lineShape_nonneg  := fun _ => le_refl 0
   , lineShape_at_zero := rfl }, trivial⟩

end ForsterRateRegime

-- ============================================================================
-- 4. Semiclassical IVR regime (PLDM, LSC, spin variants)
-- ============================================================================

/-- **Semiclassical IVR regime.**

Maps to `Approximate/Semiclassical/{PLDM,LSC,SpinPLDM,SpinLSC}.jl`
(Huo-Coker 2011, Sun-Wang-Miller 1997/1998).  All four methods sample
classical phase-space trajectories weighted by quantum phase factors.

Carrier: `nSamples ≥ 1`, per-sample magnitude `sampleWeight : Fin
nSamples → ℝ`, with the Monte Carlo / Wigner-sampling positivity
hypothesis. -/
structure SemiclassicalIVRRegime where
  /-- Number of Monte Carlo samples. -/
  nSamples              : ℕ
  /-- At least one sample. -/
  nSamples_pos          : 1 ≤ nSamples
  /-- Per-sample weight magnitude. -/
  sampleWeight          : Fin nSamples → ℝ
  /-- Sampling positivity. -/
  sampleWeight_nonneg   : ∀ i, 0 ≤ sampleWeight i

namespace SemiclassicalIVRRegime

variable (S : SemiclassicalIVRRegime)

/-- The total sampling weight is non-negative. -/
theorem sampleWeight_sum_nonneg :
    0 ≤ (Finset.univ : Finset (Fin S.nSamples)).sum S.sampleWeight := by
  apply Finset.sum_nonneg
  intro i _
  exact S.sampleWeight_nonneg i

/-- Trivial existence: single-sample, zero weight. -/
theorem exists_trivial : ∃ _ : SemiclassicalIVRRegime, True :=
  ⟨{ nSamples            := 1
   , nSamples_pos        := le_refl 1
   , sampleWeight        := fun _ => 0
   , sampleWeight_nonneg := fun _ => le_refl 0 }, trivial⟩

end SemiclassicalIVRRegime

-- ============================================================================
-- 5. Unification bridge — approximations as regimes of the exact framework
-- ============================================================================

/-- **Identification: approximations as regimes of the exact framework.**

Each Tier-5 method is a *constrained* version of the exact (Tier 1)
or master-equation (Tier 3) framework.  This carrier bundles all four
regime constraints into a single structure, asserting that the same
underlying CAT/EPT spine accommodates all of them via parameter
choices. -/
structure IdentifyApproximationsAsRegimes where
  /-- Bare-dynamics regime (no bath). -/
  bare              : BareDynamicsRegime
  /-- Bloch-Redfield regime (Markov memory kernel). -/
  blochRedfield     : BlochRedfieldRegime
  /-- Förster rate regime (strong-coupling line-shape). -/
  forster           : ForsterRateRegime
  /-- Semiclassical IVR regime (PLDM / LSC / spin variants). -/
  semiclassical     : SemiclassicalIVRRegime

namespace IdentifyApproximationsAsRegimes

variable (B : IdentifyApproximationsAsRegimes)

/-- Under the bridge, all four regimes' positivity invariants hold
simultaneously. -/
theorem all_positivities_hold :
    (∀ t, 0 ≤ B.bare.generator.expH_I t)
    ∧ (∀ r, 0 ≤ B.blochRedfield.memoryKernel.K r)
    ∧ (∀ t, 0 ≤ B.forster.lineShape t)
    ∧ (∀ i, 0 ≤ B.semiclassical.sampleWeight i) :=
  ⟨B.bare.generator.expH_I_nonneg,
   B.blochRedfield.memoryKernel.K_nonneg,
   B.forster.lineShape_nonneg,
   B.semiclassical.sampleWeight_nonneg⟩

/-- Trivial existence: assemble all four trivial regime instances. -/
theorem exists_trivial : ∃ _ : IdentifyApproximationsAsRegimes, True := by
  obtain ⟨bare, _⟩ := BareDynamicsRegime.exists_trivial
  obtain ⟨br, _⟩ := BlochRedfieldRegime.exists_trivial
  obtain ⟨fr, _⟩ := ForsterRateRegime.exists_trivial
  obtain ⟨sc, _⟩ := SemiclassicalIVRRegime.exists_trivial
  exact ⟨{ bare := bare, blochRedfield := br, forster := fr, semiclassical := sc },
         trivial⟩

end IdentifyApproximationsAsRegimes

-- ============================================================================
-- 6. Capstone bundle
-- ============================================================================

/-- **Perturbative-approximation carrier bundle.**

All structural deliverables for Tier-5 of QuantumDynamics.jl hold
simultaneously:

* A bare-dynamics regime exists.
* A Bloch-Redfield regime exists.
* A Förster rate regime exists.
* A semiclassical IVR regime exists.
* The unification bridge admits a trivial instance.

Phase-3 refinements (still open) would prove explicit derivation
relations: Bloch-Redfield from second-order perturbation theory,
Förster rate from cumulant expansion of the imaginary action, and
PLDM / LSC convergence theorems in the appropriate semiclassical
limit.  Those derivations belong upstream (in the Julia code) and
in dedicated math-physics formalisations beyond Mathlib's current
scope. -/
theorem perturbative_approximation_bundle :
    (∃ _ : BareDynamicsRegime, True)
    ∧ (∃ _ : BlochRedfieldRegime, True)
    ∧ (∃ _ : ForsterRateRegime, True)
    ∧ (∃ _ : SemiclassicalIVRRegime, True)
    ∧ (∃ _ : IdentifyApproximationsAsRegimes, True) :=
  ⟨BareDynamicsRegime.exists_trivial,
   BlochRedfieldRegime.exists_trivial,
   ForsterRateRegime.exists_trivial,
   SemiclassicalIVRRegime.exists_trivial,
   IdentifyApproximationsAsRegimes.exists_trivial⟩

end CATEPTMain.Integration.PerturbativeApproximationCarrier

end
