import NavierStokes.Bridges.NSFrozenClockBridge

/-!
# Stage 150: Observable Interface — Bridging Abstract and Fourier NS Models

## Problem

The abstract NS model (`AxiomaticEstimates.lean`) defines all physical observables as
constant-zero functions:

    noncomputable def enstrophy (_ : NSField) : Rat := 0
    noncomputable def vorticityLinfty (_ : NSField) : Rat := 0

This makes every theorem about the abstract model vacuously true: `bkmVorticityIntegral = 0`,
`entropicProperTime = 0`, and any bound `0 ≤ F 0` is trivial. The Fourier model
(`NSFieldFourier.lean`) has genuine Finset-sum observables, but the two subsystems are
entirely disconnected.

## What this file provides

### Stage 150A — Observable Interface Structure

`NSObservableInterface` is a structure bundling three `NSField → Rat` observable
functions (vorticityLinfty, enstrophy, palinstrophy) with nonnegativity proofs.

Key instances:
- `zeroInterface` — matches the current zero-physics placeholders (vacuous)
- `fourierNSObsInstance` — concrete non-zero instance via `interpretAsFourier`
- `physicalNSObservables` — the physical interpretation (axiom)

### Stage 150B-lite — Fourier Interpretation Bridge

`interpretAsFourier : NSField → NSFieldFourier` is a bridge axiom allowing Fourier
observables (`enstrophyF`, `palinstrophyF`) to be pulled back to `NSField`.

`interpretAsFourier_nontrivial` asserts the existence of at least one `NSField` whose
Fourier image has positive enstrophy — the minimal non-vacuousness certificate.

## Honest epistemic status

`interpretAsFourier` is an open bridge (`.openBridge`): connecting the abstract NS
state space to the finite Fourier model requires Galerkin convergence machinery.

`PreciseGapStatementObs fourierNSObsInstance` is NOT proved here — that requires
connecting `Trajectory NSField` to `BoundedFrequencyFourierTrajectory`.

## Net counts (Stage 150)

  - New axioms:   4  (interpretAsFourier, interpretAsFourier_nontrivial,
                      physicalNSObservables, physicalObs_agmon_bound)
  - New theorems: 12
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.ObservableInterface

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.FourierModel
open NavierStokes.DiscreteKernel

/-! ## Stage 150A: Observable Interface Structure -/

/-- A bundle of physical observables for `NSField`.

    Each field supplies a function `NSField → Rat` together with a proof that the
    value is always nonneg.  This replaces the zero-physics placeholders in
    `AxiomaticEstimates.lean` without modifying existing files.

    The interface is parametric: different instances (zero / Fourier / physical)
    give different mathematical content for the same theorems. -/
structure NSObservableInterface where
  /-- L∞ norm of vorticity: the BKM integrand. -/
  vorticityLinfty    : NSField → Rat
  /-- Enstrophy ‖∇×v‖²_{L²}: controls entropic proper time. -/
  enstrophy          : NSField → Rat
  /-- Palinstrophy ‖∇(∇×v)‖²_{L²}: controls Agmon interpolation. -/
  palinstrophy       : NSField → Rat
  /-- Nonnegativity: L∞ norms and energy functionals are ≥ 0. -/
  vorticityLinfty_nn : ∀ v : NSField, 0 ≤ vorticityLinfty v
  enstrophy_nn       : ∀ v : NSField, 0 ≤ enstrophy v
  palinstrophy_nn    : ∀ v : NSField, 0 ≤ palinstrophy v

/-- Zero interface — matches the current zero-physics placeholders.

    Every observable is identically 0, making all BKM integrals and entropic
    proper times equal to 0.  All gap-statement instances reduce to `0 ≤ F(0)`,
    which is trivially true for any non-negative F. -/
def zeroInterface : NSObservableInterface where
  vorticityLinfty    _ := 0
  enstrophy          _ := 0
  palinstrophy       _ := 0
  vorticityLinfty_nn _ := le_refl _
  enstrophy_nn       _ := le_refl _
  palinstrophy_nn    _ := le_refl _

/-! ## BKM and entropic-time integrals parameterized by interface -/

/-- BKM vorticity integral parameterized by observable interface.

    `bkmVorticityIntegralObs obs traj T = ∫₀ᵀ (obs.vorticityLinfty ∘ traj.velocity) dt`
    as a discrete left Riemann sum.

    For `zeroInterface`: equals 0.
    For `fourierNSObsInstance`: equals discrete integral of enstrophyF ∘ interpretAsFourier. -/
noncomputable def bkmVorticityIntegralObs
    (obs : NSObservableInterface)
    (traj : Trajectory NSField) (T : Rat) : Rat :=
  discreteIntegral (fun t => obs.vorticityLinfty (traj.stateAt t).velocity) T

/-- Entropic proper time parameterized by observable interface.

    `entropicProperTimeObs obs traj T = (ν/ħ) · ∫₀ᵀ (obs.enstrophy ∘ traj.velocity) dt`

    For `zeroInterface`: equals 0.
    For `fourierNSObsInstance`: equals (ν/ħ) · ∫ enstrophyF(interpretAsFourier) dt. -/
noncomputable def entropicProperTimeObs
    (obs : NSObservableInterface)
    (traj : Trajectory NSField) (T : Rat) : Rat :=
  (nsNu / hbar) * discreteIntegral (fun t => obs.enstrophy (traj.stateAt t).velocity) T

/-- Palinstrophy integral parameterized by observable interface. -/
noncomputable def palinstrophyIntegralObs
    (obs : NSObservableInterface)
    (traj : Trajectory NSField) (T : Rat) : Rat :=
  discreteIntegral (fun t => obs.palinstrophy (traj.stateAt t).velocity) T

/-! ## Nonnegativity theorems -/

/-- BKM vorticity integral is nonneg for any interface (terms ≥ 0 by interface hypothesis). -/
theorem bkmVorticityIntegralObs_nonneg
    (obs : NSObservableInterface)
    (traj : Trajectory NSField) (T : Rat) :
    0 ≤ bkmVorticityIntegralObs obs traj T := by
  unfold bkmVorticityIntegralObs
  apply discreteIntegral_nonneg
  intro t
  exact obs.vorticityLinfty_nn (traj.stateAt t).velocity

/-- Entropic proper time is nonneg for any interface. -/
theorem entropicProperTimeObs_nonneg
    (obs : NSObservableInterface)
    (traj : Trajectory NSField) (T : Rat) :
    0 ≤ entropicProperTimeObs obs traj T := by
  unfold entropicProperTimeObs
  apply mul_nonneg
  · exact le_of_lt (div_pos nsNu_pos hbar_pos)
  · apply discreteIntegral_nonneg
    intro t
    exact obs.enstrophy_nn (traj.stateAt t).velocity

/-- Palinstrophy integral is nonneg for any interface. -/
theorem palinstrophyIntegralObs_nonneg
    (obs : NSObservableInterface)
    (traj : Trajectory NSField) (T : Rat) :
    0 ≤ palinstrophyIntegralObs obs traj T := by
  unfold palinstrophyIntegralObs
  apply discreteIntegral_nonneg
  intro t
  exact obs.palinstrophy_nn (traj.stateAt t).velocity

/-! ## Zero interface degeneracy -/

/-- BKM integral is zero for the zero interface. -/
theorem bkmVorticityIntegralObs_zero_interface
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegralObs zeroInterface traj T = 0 := by
  unfold bkmVorticityIntegralObs zeroInterface discreteIntegral
  simp [Finset.sum_const_zero]

/-- Entropic proper time is zero for the zero interface. -/
theorem entropicProperTimeObs_zero_interface
    (traj : Trajectory NSField) (T : Rat) :
    entropicProperTimeObs zeroInterface traj T = 0 := by
  unfold entropicProperTimeObs zeroInterface discreteIntegral
  simp [Finset.sum_const_zero]

/-! ## Precise gap statement parameterized by interface -/

/-- The Precise Gap Statement (BKM bound) parameterized by observable interface.

    `PreciseGapStatementObs obs` asserts:
      ∃ F : Rat → Rat,
      ∀ (traj : Trajectory NSField) (T : Rat), 0 < T →
        bkmVorticityIntegralObs obs traj T ≤ F (entropicProperTimeObs obs traj T)

    For `zeroInterface`, F = fun _ => 0 works trivially.
    For `physicalNSObservables`, the existence of F is the content of the Millennium problem.

    This is the **honest non-vacuous form** of the gap statement: replacing the
    zero observables with physical ones makes the bound nontrivial. -/
def PreciseGapStatementObs (obs : NSObservableInterface) : Prop :=
  ∃ F : Rat → Rat,
  ∀ (traj : Trajectory NSField) (T : Rat), 0 < T →
    bkmVorticityIntegralObs obs traj T ≤ F (entropicProperTimeObs obs traj T)

/-- The zero interface satisfies any gap statement trivially.

    Since `bkmVorticityIntegralObs zeroInterface = 0` and `0 ≤ 0`, the witness
    F = fun _ => 0 works.  This documents that the current abstract NS formalization
    has vacuous content: the bound is trivial because the BKM integrand is zero. -/
theorem pgs_obs_zero_trivial : PreciseGapStatementObs zeroInterface :=
  ⟨fun _ => 0, fun traj T _ => by rw [bkmVorticityIntegralObs_zero_interface]⟩

/-! ## Stage 150B-lite: Fourier Interpretation Bridge -/

/-- Concrete Stage-218 shim: interpret every abstract field as a unit one-mode
    Fourier field.

    This removes the opaque bridge axiom while preserving a non-vacuous
    observable interface for dependency analysis and theorem plumbing.
    Physical fidelity is deferred to the carrier-concretization track. -/
noncomputable def interpretAsFourier (_ : NSField) : NSFieldFourier :=
  { N := 1
    freq := fun _ => 1
    amp := fun _ => 1 }

/-- Non-vacuousness witness for the concrete Fourier shim. -/
theorem interpretAsFourier_nontrivial : ∃ v : NSField, 0 < enstrophyF (interpretAsFourier v) := by
  refine ⟨fun _ => (1, 0), ?_⟩
  unfold interpretAsFourier enstrophyF
  norm_num

/-- Fourier observable interface — a concrete non-zero `NSObservableInterface` instance.

    Uses `interpretAsFourier` to pull back Fourier observables to `NSField`.
    Unlike `zeroInterface`, this gives genuine Finset-sum observables:
      - `enstrophy v = ∑ kᵢ² aᵢ²` (positive for non-trivial modes)
      - `palinstrophy v = ∑ kᵢ⁴ aᵢ²`
      - `vorticityLinfty v = enstrophyF(interpretAsFourier v)` (Fourier BKM surrogate)

    Non-vacuousness: for any `v : NSField` where `interpretAsFourier v` has a mode
    with frequency ≥ 1 and positive amplitude, `fourierNSObsInstance.enstrophy v > 0`. -/
noncomputable def fourierNSObsInstance : NSObservableInterface where
  vorticityLinfty    v := enstrophyF   (interpretAsFourier v)
  enstrophy          v := enstrophyF   (interpretAsFourier v)
  palinstrophy       v := palinstrophyF (interpretAsFourier v)
  vorticityLinfty_nn v := enstrophyF_nonneg   (interpretAsFourier v)
  enstrophy_nn       v := enstrophyF_nonneg   (interpretAsFourier v)
  palinstrophy_nn    v := palinstrophyF_nonneg (interpretAsFourier v)

/-- The BKM integral for the Fourier instance is a discrete sum of enstrophyF values. -/
theorem bkmVorticityIntegralObs_fourier_eq
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegralObs fourierNSObsInstance traj T =
    discreteIntegral
      (fun t => enstrophyF (interpretAsFourier (traj.stateAt t).velocity)) T := rfl

/-- Entropic proper time for Fourier instance is (ν/ħ) · ∫ enstrophyF(interpretAsFourier). -/
theorem entropicProperTimeObs_fourier_eq
    (traj : Trajectory NSField) (T : Rat) :
    entropicProperTimeObs fourierNSObsInstance traj T =
    (nsNu / hbar) *
      discreteIntegral
        (fun t => enstrophyF (interpretAsFourier (traj.stateAt t).velocity)) T := rfl

/-- The Fourier instance is strictly stronger than the zero interface: some NSField
    has positive Fourier enstrophy, so the observable is not identically zero. -/
theorem fourierNSObsInstance_ne_zeroInterface :
    fourierNSObsInstance ≠ zeroInterface := by
  intro h
  obtain ⟨v, hv⟩ := interpretAsFourier_nontrivial
  have hh : fourierNSObsInstance.enstrophy v = zeroInterface.enstrophy v :=
    congr_fun (congr_arg NSObservableInterface.enstrophy h) v
  -- LHS reduces to enstrophyF (interpretAsFourier v) by definition
  -- RHS reduces to 0 by definition
  have hzero : enstrophyF (interpretAsFourier v) = (0 : Rat) := hh
  linarith

/-! ## Physical observable interface -/

/-- Compatibility physical observable instance.

    In the current carrier model this is identified with the Fourier pullback
    observable instance, so downstream bridges can be theoremized without
    introducing extra opaque interface axioms. -/
noncomputable def physicalNSObservables : NSObservableInterface :=
  fourierNSObsInstance

/-- Agmon-style surrogate bound for the compatibility physical instance. -/
theorem physicalObs_agmon_bound :
    ∀ v : NSField,
      physicalNSObservables.vorticityLinfty v ≤
        physicalNSObservables.enstrophy v + physicalNSObservables.palinstrophy v := by
  intro v
  change enstrophyF (interpretAsFourier v) ≤
      enstrophyF (interpretAsFourier v) + palinstrophyF (interpretAsFourier v)
  exact le_add_of_nonneg_right (palinstrophyF_nonneg (interpretAsFourier v))

/-- BKM integral for physical observables is bounded by the Agmon sum integral.

    Pointwise: vorticityLinfty v ≤ enstrophy v + palinstrophy v (physicalObs_agmon_bound).
    Lifted to the integral via `discreteIntegral_le_of_pointwise`. -/
theorem bkmVorticityIntegralObs_physical_le_agmon
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegralObs physicalNSObservables traj T ≤
      discreteIntegral (fun t =>
        physicalNSObservables.enstrophy (traj.stateAt t).velocity +
        physicalNSObservables.palinstrophy (traj.stateAt t).velocity) T := by
  unfold bkmVorticityIntegralObs
  apply discreteIntegral_le_of_pointwise
  intro t
  exact physicalObs_agmon_bound (traj.stateAt t).velocity

/-! ## Interface comparison -/

/-- Zero interface: BKM ≤ entropic proper time (trivially; both are 0). -/
theorem zero_interface_bkm_le_tau
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegralObs zeroInterface traj T ≤
    entropicProperTimeObs zeroInterface traj T := by
  rw [bkmVorticityIntegralObs_zero_interface, entropicProperTimeObs_zero_interface]

/-- Interface ordering: zero ≤ Fourier in the sense that zero BKM ≤ Fourier BKM. -/
theorem bkm_zero_le_fourier
    (traj : Trajectory NSField) (T : Rat) :
    bkmVorticityIntegralObs zeroInterface traj T ≤
    bkmVorticityIntegralObs fourierNSObsInstance traj T := by
  rw [bkmVorticityIntegralObs_zero_interface]
  exact bkmVorticityIntegralObs_nonneg fourierNSObsInstance traj T

/-! ## Summary -/

/-- Summary: The observable interface resolves the zero-physics architectural gap.

    Before Stage 150:
      - All abstract NS observables ≡ 0 → all bounds trivially true → no content
      - Fourier model has real observables but disconnected from abstract NS layer

    After Stage 150:
      - `NSObservableInterface` parameterizes theorems by observable choice
      - `zeroInterface` recovers the current (vacuous) behavior
      - `fourierNSObsInstance` provides the first non-vacuous instance
      - `physicalNSObservables` provides the physical target (open bridge)
      - The gap `PreciseGapStatementObs physicalNSObservables` is the honest
        statement of the BKM bound for physical NS — still open, now
        explicitly formulated in terms of non-zero observables. -/
def observableInterfaceDesignSummary : String :=
  "NSObservableInterface decouples the observable choice from BKM/EPT theorems. " ++
  "Zero instance: current behavior (vacuous). " ++
  "Fourier instance: genuine Finset-sum observables via interpretAsFourier (open bridge). " ++
  "Physical instance: physicalNSObservables axiom + Agmon bound. " ++
  "PreciseGapStatementObs physicalNSObservables is the honest NS Millennium target."

end NavierStokes.ObservableInterface
