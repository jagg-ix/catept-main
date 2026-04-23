import NavierStokes.Galerkin.NSGalerkinViscStep
import NavierStokes.Galerkin.NSGalerkinConvStepHBridge

/-!
# Stage 164/189B — NSGalerkinNSODETrajectory: h-Parametric Discrete NS Trajectory

Introduces a Rat-only discrete-time Galerkin NS trajectory via **operator splitting**:

1. **Convective step** — `convStepH basis h u := cayleySolveDef basis h u`
   (h-parametric Cayley step; energy-preserving, Stage 188).
2. **Viscous step** — implicit Euler per mode: `u_i ↦ u_i / (1 + ν h |k_i|²)`
   (in `NSGalerkinViscStep`, Stage 189A lift).

Stage 189B changes from Stage 164:
- `convStep` axiom RETIRED; replaced by `noncomputable def convStep` in
  `NavierStokes.GalerkinCayley` (Stage 189A); backward-compat alias provided here.
- `convStep_energy_preserving` axiom RETIRED; now a theorem via Cayley identification.
- `GalerkinNSDiscreteTrajectory` gains `h_le_one : h ≤ 1` field (needed for near-identity).
- `step` field now uses `convStepH basis h (u n)` (h-parametric).
- `energy_dissipation_step` uses `convStepH_energy_preserving` (theorem, 0 new axioms).

## Net counts (Stage 189B)

  - Axioms eliminated:  2  (convStep, convStep_energy_preserving)
  - New axioms:         0
  - New theorems:       0  (same theorems, rephrased)
  - sorry:              0
  - warnings:           0
-/

namespace NavierStokes.GalerkinODE

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge  -- galerkinN
open NavierStokes.GalerkinComplexModel   -- CRat, WaveVec, CoeffC, normSqC, realInnerC,
                                         -- waveVecMag2, NSFieldGalerkinK
open NavierStokes.GalerkinConvection     -- GalerkinBasis, galerkinConvection, B_energy_cancel
open NavierStokes.GalerkinCayley         -- cayleySolve, convStep (noncomputable def)
open NavierStokes.GalerkinConvergence    -- coeffNormSq
open NavierStokes.GalerkinConvStepHBridge  -- convStepH, convStepH_energy_preserving
open NavierStokes.DiscreteKernel         -- diN, diH, diH_pos

/-! ## Backward-compat alias for convStep -/

/-- **`convStep`** — backward-compatibility alias for `NavierStokes.GalerkinCayley.convStep`.

    The Stage 164 `axiom convStep` has been retired; the concrete Cayley step at `diH` is
    now `NavierStokes.GalerkinCayley.convStep`.  This alias keeps downstream code working
    without modification. -/
noncomputable abbrev convStep {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) : CoeffC N :=
  NavierStokes.GalerkinCayley.convStep basis u

/-- **Energy conservation of the convective step** — now a theorem (0 new axioms). -/
theorem convStep_energy_preserving {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    ∑ i : Fin N, normSqC (convStep basis u i) = ∑ i : Fin N, normSqC (u i) :=
  NavierStokes.GalerkinCayley.convStep_energy_preserving_from_cayley basis u

/-! ## Discrete Galerkin NS trajectory (h-parametric, Stage 189B) -/

/-- A discrete-time Galerkin Navier-Stokes trajectory on an h-uniform mesh.

    Stage 189B upgrade: the convective substep is now `convStepH basis h`, the
    h-parametric Cayley step with proved near-identity stability (Stage 188).
    Adding `h_le_one : h ≤ 1` enables the near-identity bound.

    Fields:
    * `basis`     — wavevector geometry (cutoff, frequencies)
    * `ν`         — kinematic viscosity
    * `h`         — time step
    * `hν`        — `0 < ν`
    * `hh`        — `0 < h`
    * `h_le_one`  — `h ≤ 1` (for near-identity stability)
    * `u`         — coefficient sequence `Nat → CoeffC N`
    * `step`      — ODE scheme: `u(n+1) = viscStep basis ν h (convStepH basis h (u n))` -/
structure GalerkinNSDiscreteTrajectory where
  N         : Nat
  basis     : GalerkinBasis N
  ν         : Rat
  h         : Rat
  hν        : 0 < ν
  hh        : 0 < h
  h_le_one  : h ≤ 1
  u         : Nat → CoeffC N
  step      : ∀ n : Nat, u (n + 1) = viscStep basis ν h (convStepH basis h (u n))

/-! ## Derived energy dissipation theorem -/

/-- **Energy dissipation is a theorem** (not a struct field) for Galerkin NS trajectories.

    `E(n+1) ≤ E(n)` where `E(n) = ∑ᵢ normSqC(u_n_i)`.

    Proof (two-step calc, 0 new axioms):
    1. `E_after_visc_step ≤ E_before_visc_step`: `viscStep_energy_le` (algebra)
    2. `E_before_visc_step = E(n)`:              `convStepH_energy_preserving` (theorem) -/
theorem GalerkinNSDiscreteTrajectory.energy_dissipation_step
    (traj : GalerkinNSDiscreteTrajectory) (n : Nat) :
    ∑ i : Fin traj.N, normSqC (traj.u (n + 1) i) ≤
    ∑ i : Fin traj.N, normSqC (traj.u n i) := by
  rw [traj.step n]
  calc ∑ i : Fin traj.N,
          normSqC (viscStep traj.basis traj.ν traj.h (convStepH traj.basis traj.h (traj.u n)) i)
      ≤ ∑ i : Fin traj.N, normSqC (convStepH traj.basis traj.h (traj.u n) i) :=
          viscStep_energy_le traj.basis traj.ν traj.h traj.hν traj.hh _
    _ = ∑ i : Fin traj.N, normSqC (traj.u n i) :=
          convStepH_energy_preserving traj.basis traj.h (traj.u n)

/-- Energy is monotone nonincreasing over multiple steps. -/
theorem GalerkinNSDiscreteTrajectory.energy_dissipation_mono
    (traj : GalerkinNSDiscreteTrajectory) :
    ∀ n m : Nat, n ≤ m →
    ∑ i : Fin traj.N, normSqC (traj.u m i) ≤
    ∑ i : Fin traj.N, normSqC (traj.u n i) := by
  intro n m hle
  induction m with
  | zero =>
    rw [Nat.le_zero.mp hle]
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le hle with h | h
    · rw [← h]
    · have hnm : n ≤ m := Nat.lt_succ_iff.mp h
      exact le_trans (traj.energy_dissipation_step m) (ih hnm)

/-! ## Abstract energy density trajectory -/

/-- An abstract energy-density trajectory: `energyAt n i = normSqC (u_n_i) ∈ ℚ≥0`,
    with certified monotone total energy. -/
structure GalerkinKEnergyTrajectory where
  N                   : Nat
  basis               : GalerkinBasis N
  energyAt            : Nat → Fin N → Rat
  energy_nonneg       : ∀ n i, 0 ≤ energyAt n i
  energy_dissipation  : ∀ n, ∑ i : Fin N, energyAt (n + 1) i ≤ ∑ i : Fin N, energyAt n i

/-- Extract the certified energy trajectory from a discrete Galerkin NS trajectory. -/
def GalerkinNSDiscreteTrajectory.toKEnergyTrajectory
    (traj : GalerkinNSDiscreteTrajectory) : GalerkinKEnergyTrajectory where
  N                   := traj.N
  basis               := traj.basis
  energyAt            := fun n i => normSqC (traj.u n i)
  energy_nonneg       := fun _ _ => normSqC_nonneg _
  energy_dissipation  := traj.energy_dissipation_step

def stage164v189BSummary : String :=
  "Stage 164/189B: NSGalerkinNSODETrajectory — h-parametric discrete Galerkin NS. " ++
  "viscStep: DEF moved to NSGalerkinViscStep (Stage 189A). " ++
  "convStep: noncomputable abbrev = NavierStokes.GalerkinCayley.convStep (Stage 189A). " ++
  "convStep_energy_preserving: THEOREM (0 new axioms, via Cayley identification). " ++
  "GalerkinNSDiscreteTrajectory: h_le_one field added; step uses convStepH. " ++
  "energy_dissipation_step: THEOREM (viscStep_energy_le + convStepH_energy_preserving). " ++
  "energy_dissipation_mono: THEOREM (induction). " ++
  "GalerkinKEnergyTrajectory: abstract energy-density certificate type. " ++
  "toKEnergyTrajectory: unchanged. " ++
  "Net (Stage 189B): -2 axioms, +0 new axioms, 0 sorry."

end NavierStokes.GalerkinODE
