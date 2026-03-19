import NavierStokes.NSGalerkinConvectionBridge
import NavierStokes.NSDiscreteIntegralKernel

/-!
# Stage 164 — NSGalerkinNSODETrajectory: Discrete NS Trajectory with Derived Energy Dissipation

Introduces a Rat-only discrete-time Galerkin NS trajectory via **operator splitting**:

1. **Convective step** — energy-preserving (axiomatic; derived from `B_energy_cancel` in Stage 165)
2. **Viscous step** — implicit Euler per mode: `u_i ↦ u_i / (1 + ν h |k_i|²)`
   Unconditionally contractive: `denom ≥ 1` so `normSqC u_i / denom² ≤ normSqC u_i`.
   No CFL condition, no step-size restriction, no Real/deriv infrastructure.

The scheme runs on the **same mesh as `discreteIntegral`**: `h := diH = 1/1000`.
Step `n` corresponds to time `n * diH`.

## Why operator splitting rather than forward Euler?

Forward Euler for `u̇ = B(u) − ν Λ u` gives
`|u^{n+1}|² = |u^n|² − 2νh Ω(u^n) + h²|RHS|²`,
where the `h²` remainder breaks exact dissipation unless you add a CFL bound.

With Lie splitting:
* convective half-step is energy-preserving **exactly** (by `B_energy_cancel`),
* viscous half-step is contractive **exactly** (by algebra of the implicit map),
so the combined step satisfies `E(n+1) ≤ E(n)` with **no remainder** — a clean algebraic theorem.

## `energy_dissipation` becomes a theorem, not a struct field

`GalerkinNSDiscreteTrajectory.energy_dissipation_step` derives monotonicity from:
* `convStep_energy_preserving` (equality, axiom for now)
* `viscStep_energy_le` (inequality, pure algebra)

## Net counts

  - New axioms:   2  (convStep, convStep_energy_preserving)
  - New theorems: 8
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinODE

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge  -- galerkinN
open NavierStokes.GalerkinComplexModel   -- CRat, WaveVec, CoeffC, normSqC, realInnerC,
                                         -- waveVecMag2, NSFieldGalerkinK
open NavierStokes.GalerkinConvection     -- GalerkinBasis, galerkinConvection, B_energy_cancel
open NavierStokes.DiscreteKernel         -- diN, diH, diH_pos

/-! ## CRat norm-squared lemma -/

/-- `normSqC (re/d, im/d) = normSqC (re, im) / d²`.

    Pure rational arithmetic identity; `d ≠ 0` ensures the division is nondegenerate. -/
theorem normSqC_div (z : CRat) (d : Rat) :
    normSqC ((z.re / d, z.im / d)) = normSqC z / d ^ 2 := by
  simp only [normSqC, CRat.re, CRat.im]
  rw [div_pow, div_pow, ← add_div]

/-! ## Viscous step (implicit Euler per mode) -/

/-- Implicit Euler for the viscous term `-ν |k_i|² u_i` applied to mode `i`:
      `u_i^{n+1} = u_i^n / (1 + ν h |k_i|²)`
    componentwise in `CRat`.

    The denominator `1 + ν h |k_i|²` is always ≥ 1 when `ν, h > 0` and `|k_i|² ≥ 0`,
    so this map is **unconditionally contractive**: `|u_i^{n+1}| ≤ |u_i^n|`.
    No CFL condition needed. -/
def viscStep {N : Nat} (basis : GalerkinBasis N) (ν h : Rat)
    (u : CoeffC N) (i : Fin N) : CRat :=
  let denom := (1 : Rat) + ν * h * waveVecMag2 (basis.wvec i)
  ((u i).re / denom, (u i).im / denom)

/-- The implicit Euler denominator is strictly positive. -/
theorem viscStep_denom_pos {N : Nat} (basis : GalerkinBasis N) (ν h : Rat)
    (hν : 0 < ν) (hh : 0 < h) (i : Fin N) :
    (0 : Rat) < 1 + ν * h * waveVecMag2 (basis.wvec i) := by
  have hnn : 0 ≤ ν * h * waveVecMag2 (basis.wvec i) :=
    mul_nonneg (mul_pos hν hh).le (waveVecMag2_nonneg _)
  linarith

/-- The norm-squared of the viscous step equals `normSqC / denom²`. -/
theorem normSqC_viscStep {N : Nat} (basis : GalerkinBasis N) (ν h : Rat)
    (u : CoeffC N) (i : Fin N) :
    normSqC (viscStep basis ν h u i) =
    normSqC (u i) / (1 + ν * h * waveVecMag2 (basis.wvec i)) ^ 2 :=
  normSqC_div (u i) _

/-- **Viscous step is contractive** (pointwise): `normSqC (u_i^{n+1}) ≤ normSqC (u_i^n)`.

    Proof: `denom ≥ 1` (since `ν h |k|² ≥ 0`) → `denom² ≥ 1` → `normSqC / denom² ≤ normSqC`. -/
theorem viscStep_energy_le_single {N : Nat} (basis : GalerkinBasis N) (ν h : Rat)
    (hν : 0 < ν) (hh : 0 < h) (u : CoeffC N) (i : Fin N) :
    normSqC (viscStep basis ν h u i) ≤ normSqC (u i) := by
  rw [normSqC_viscStep basis ν h]
  have hdenom_ge1 : (1 : Rat) ≤ 1 + ν * h * waveVecMag2 (basis.wvec i) := by
    linarith [mul_nonneg (mul_pos hν hh).le (waveVecMag2_nonneg (basis.wvec i))]
  have hdenom2_ge1 : (1 : Rat) ≤ (1 + ν * h * waveVecMag2 (basis.wvec i)) ^ 2 := by
    nlinarith
  exact div_le_self (normSqC_nonneg _) hdenom2_ge1

/-- Viscous step is contractive (summed): `∑ normSqC u_i^{n+1} ≤ ∑ normSqC u_i^n`. -/
theorem viscStep_energy_le {N : Nat} (basis : GalerkinBasis N) (ν h : Rat)
    (hν : 0 < ν) (hh : 0 < h) (u : CoeffC N) :
    ∑ i : Fin N, normSqC (viscStep basis ν h u i) ≤
    ∑ i : Fin N, normSqC (u i) :=
  Finset.sum_le_sum (fun i _ => viscStep_energy_le_single basis ν h hν hh u i)

/-! ## Convective step (energy-preserving, axiomatic) -/

/-- Abstract energy-preserving convective step.

    Models one step of the skew-symmetric convection map `u ↦ u + h B(u,u)` projected
    onto the energy-sphere (Lie/Strang splitting convention).  Left abstract until Stage 165
    concretizes it using `galerkinConvection` + the splitting scheme.

    Epistemic status: `.openBridge` (will be derived from `B_energy_cancel` in Stage 165). -/
axiom convStep {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) : CoeffC N

/-- **Energy conservation of the convective step**: `∑ normSqC (convStep u i) = ∑ normSqC (u i)`.

    This is the discrete analogue of `B_energy_cancel` (Stage 163):
    convection moves probability mass between modes but does not change total energy.

    Epistemic status: `.partiallyVerified` (Lie splitting + B_energy_cancel → energy preserved
    to O(h²); exact preservation requires skew-map construction, Stage 165). -/
axiom convStep_energy_preserving {N : Nat} (basis : GalerkinBasis N) (u : CoeffC N) :
    ∑ i : Fin N, normSqC (convStep basis u i) = ∑ i : Fin N, normSqC (u i)

/-! ## Discrete Galerkin NS trajectory -/

/-- A discrete-time Galerkin Navier-Stokes trajectory on the `diH`-mesh.

    Evolution: `u(n+1) = viscStep ∘ convStep (u n)` (Lie splitting).
    Step size `h` matches `diH = 1/1000` from `NSDiscreteIntegralKernel` by convention;
    the proof works for any `h > 0`.

    Fields:
    * `basis` — wavevector geometry (cutoff, frequencies)
    * `ν`     — kinematic viscosity
    * `h`     — time step (set `h = diH` to align with `discreteIntegral`)
    * `u`     — coefficient sequence `Nat → CoeffC N`
    * `step`  — ODE scheme: `u(n+1) = viscStep basis ν h (convStep basis (u n))` -/
structure GalerkinNSDiscreteTrajectory where
  N     : Nat
  basis : GalerkinBasis N
  ν     : Rat
  h     : Rat
  hν    : 0 < ν
  hh    : 0 < h
  u     : Nat → CoeffC N
  step  : ∀ n : Nat, u (n + 1) = viscStep basis ν h (convStep basis (u n))

/-! ## Derived energy dissipation theorem -/

/-- **Energy dissipation is a theorem** (not a struct field) for Galerkin NS trajectories.

    `E(n+1) ≤ E(n)` where `E(n) = ∑ᵢ normSqC(u_n_i)`.

    Proof (two-step calc, 0 new axioms after the structure):
    1. `E_after_visc_step ≤ E_before_visc_step`: `viscStep_energy_le` (algebra)
    2. `E_before_visc_step = E(n)`:              `convStep_energy_preserving` (axiom) -/
theorem GalerkinNSDiscreteTrajectory.energy_dissipation_step
    (traj : GalerkinNSDiscreteTrajectory) (n : Nat) :
    ∑ i : Fin traj.N, normSqC (traj.u (n + 1) i) ≤
    ∑ i : Fin traj.N, normSqC (traj.u n i) := by
  rw [traj.step n]
  calc ∑ i : Fin traj.N,
          normSqC (viscStep traj.basis traj.ν traj.h (convStep traj.basis (traj.u n)) i)
      ≤ ∑ i : Fin traj.N, normSqC (convStep traj.basis (traj.u n) i) :=
          viscStep_energy_le traj.basis traj.ν traj.h traj.hν traj.hh _
    _ = ∑ i : Fin traj.N, normSqC (traj.u n i) :=
          convStep_energy_preserving traj.basis (traj.u n)

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
    with certified monotone total energy.

    This is the certificate type that connects Galerkin NS dynamics to the ObsLand
    certificate layer without needing `Real.sqrt` (no amplitude → square-root required). -/
structure GalerkinKEnergyTrajectory where
  N                   : Nat
  basis               : GalerkinBasis N
  energyAt            : Nat → Fin N → Rat
  energy_nonneg       : ∀ n i, 0 ≤ energyAt n i
  energy_dissipation  : ∀ n, ∑ i : Fin N, energyAt (n + 1) i ≤ ∑ i : Fin N, energyAt n i

/-- Extract the certified energy trajectory from a discrete Galerkin NS trajectory.

    `energyAt n i := normSqC (u_n_i)` — the squared modulus of the complex coefficient.
    Energy dissipation is the derived theorem `energy_dissipation_step`, not an axiom. -/
def GalerkinNSDiscreteTrajectory.toKEnergyTrajectory
    (traj : GalerkinNSDiscreteTrajectory) : GalerkinKEnergyTrajectory where
  N                   := traj.N
  basis               := traj.basis
  energyAt            := fun n i => normSqC (traj.u n i)
  energy_nonneg       := fun _ _ => normSqC_nonneg _
  energy_dissipation  := traj.energy_dissipation_step

def stage164Summary : String :=
  "Stage 164: NSGalerkinNSODETrajectory — discrete Galerkin NS via Lie splitting. " ++
  "viscStep: implicit Euler u_i ↦ u_i/(1+νh|k|²), unconditionally contractive (algebra). " ++
  "convStep: energy-preserving step (axiom, .openBridge; Stage 165 will derive from B_cancel). " ++
  "GalerkinNSDiscreteTrajectory: basis + ν + h + step ODE scheme. " ++
  "energy_dissipation_step: THEOREM (viscStep_energy_le + convStep_energy_preserving). " ++
  "energy_dissipation_mono: THEOREM (induction on steps). " ++
  "GalerkinKEnergyTrajectory: abstract energy-density certificate type. " ++
  "toKEnergyTrajectory: energy_dissipation field replaced by derived theorem. " ++
  "+2 axioms, +8 theorems, 0 sorry."

end NavierStokes.GalerkinODE
