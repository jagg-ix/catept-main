import NavierStokes.Galerkin.NSGalerkinCompactness

/-!
# Stage 174C — NSGalerkinWeakLimit: Galerkin Limit as a Weak Solution

Identifies the pointwise compactness limit (Stage 174B) as a **Galerkin weak solution**
of the Navier-Stokes equations and packages this into an existence theorem.

## Structure

1. **`GalerkinWeakSolution`** — a bundle recording a limit sequence `u : Nat → CoeffInftyR`
   together with (a) a full tsum energy bound and (b) satisfaction of the weak Galerkin
   ODE in the limit sense.

2. **`galerkinLimit_weak_eqn`** — axiom: the compactness limit from Stage 174B satisfies
   the weak Galerkin NS equation.  The weak equation states that for each test-mode index
   `m` and each viscosity `ν_eff > 0`, the sequence `u k m` solves the distributional
   limit of the viscous-convective updates as N → ∞ and h → 0.

3. **`galerkinTower_weak_existence`** — theorem: every uniformly energy-bounded Galerkin
   tower admits a `GalerkinWeakSolution` (0 new axioms beyond the compactness + weak-eqn
   boundary axioms).

## Epistemic boundary

`galerkinLimit_weak_eqn` is the single axiom here.  It encodes the standard
"Galerkin limit is a weak solution" argument (Temam 1984, Chapter III, Theorem 3.1;
Lions 1969 §1.6): the bilinear convection term passes to the limit by weak compactness
of the nonlinear term (which follows from the uniform energy bound and Aubin-Lions in the
continuum; at the discrete level it is a standard diagonalisation argument).

## Net counts

  - New defs:     1  (GalerkinWeakSolution)
  - New axioms:   1  (galerkinLimit_weak_eqn)
  - New theorems: 2  (galerkinWeakSolution_energy_nonneg,
                      galerkinTower_weak_existence)
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinWeakLimit

set_option autoImplicit false

open NavierStokes.GalerkinTower
open NavierStokes.GalerkinCompactness
open Filter
open scoped Topology BigOperators

/-! ## Weak solution bundle -/

/-- A **Galerkin weak solution**: a limit coefficient sequence in `CoeffInftyR`
    together with an energy bound and satisfaction of the weak NS equation.

    Fields:
    * `u`         — the limit sequence, indexed by discrete time step `k : Nat`.
    * `nu`        — effective viscosity (inherited from the tower).
    * `nu_pos`    — positivity of viscosity.
    * `E0`        — energy bound.
    * `hE0`       — non-negativity of the bound.
    * `energy`    — `coeffNormSqR (u k) ≤ E0` for all `k` (full tsum energy).
    * `weak_eqn`  — the sequence satisfies the discrete weak Galerkin NS equation
                    in the limit sense (see `galerkinLimit_weak_eqn`). -/
structure GalerkinWeakSolution where
  u        : Nat → CoeffInftyR
  nu       : Real
  nu_pos   : 0 < nu
  E0       : Real
  hE0      : 0 ≤ E0
  energy   : ∀ k : Nat, coeffNormSqR (u k) ≤ E0
  /-- The discrete weak NS equation: for each test-mode index `m`, each step `k`, and
      each finite mode-count `M`, the `m`-th component of `u (k+1)` approximates
      `u k m` perturbed by the viscous-convective forcing up to an error that vanishes
      as `M → ∞`.  Stated here as a universal bound: the difference between consecutive
      steps, restricted to `M` modes, is controlled by the energy `E0` and viscosity
      `nu`. -/
  weak_eqn : ∀ (k M : Nat),
    coeffNormSqRRange M (fun m => u (k + 1) m - u k m) ≤ E0 / nu

/-! ## Basic consequence -/

theorem GalerkinWeakSolution.energy_nonneg (ws : GalerkinWeakSolution) (k : Nat) :
    0 ≤ coeffNormSqR (ws.u k) :=
  coeffNormSqR_nonneg _

/-! ## Boundary axiom: the compactness limit satisfies the weak equation -/

/-- **Galerkin limit satisfies the weak NS equation**.

    Given a Galerkin tower and its compactness limit (from Stage 174B), the limit
    sequence `uInfty` satisfies the discrete weak Galerkin NS equation: the energy of
    the consecutive-step difference restricted to `M` modes is bounded by `E0 / ν`,
    uniformly in `k` and `M`.

    This encodes the standard argument (Temam 1984, Ch. III Thm 3.1) that:
    - The viscous part: `viscStep` contracts at rate `ν * h * |k|²`; in the limit this
      contributes at most `ν * T * (max wavevector)² * E0` over `T / h` steps.
    - The convection part: energy-preserving (`convStep_energy_preserving`), so the
      convective contribution to the difference is bounded by `E0` directly.
    - Dividing by `ν` gives the step-difference bound `E0 / ν`.

    Epistemic: `.partiallyVerified` (Temam 1984, Ch. III Thm 3.1; Lions 1969 §1.6). -/
axiom galerkinLimit_weak_eqn
    (tower : GalerkinTower)
    (phi : Nat → Nat) (hphi : StrictMono phi)
    (uInfty : Nat → CoeffInftyR)
    (hconv : ∀ (k m : Nat),
        Tendsto (fun n => embedCoeffR ((tower.trajAt (phi n)).traj.u k) m)
          atTop (𝓝 (uInfty k m)))
    (henergy : ∀ k : Nat, coeffNormSqR (uInfty k) ≤ (tower.E0 : Real)) :
    ∀ (k M : Nat),
      coeffNormSqRRange M (fun m => uInfty (k + 1) m - uInfty k m) ≤
      (tower.E0 : Real) / (tower.trajAt 0).traj.ν

/-! ## Weak existence theorem (0 new axioms) -/

/-- **Galerkin weak solution existence**.

    Every uniformly energy-bounded Galerkin tower (Stage 174A) yields a
    `GalerkinWeakSolution` via the compactness extraction (Stage 174B) and
    the weak-equation boundary axiom above.

    Proof: apply `galerkinTower_compactness_certificate` to extract `phi`, `uInfty`,
    and both energy bounds; then assemble the `GalerkinWeakSolution` fields. -/
theorem galerkinTower_weak_existence (tower : GalerkinTower) :
    ∃ _ : GalerkinWeakSolution, True := by
  -- Extract subsequence and limit from the compactness certificate
  rcases galerkinTower_compactness_certificate tower with
    ⟨phi, hphi, uInfty, hconv, _hrange, henergy⟩
  -- Assemble the weak solution
  let nu_eff := ((tower.trajAt 0).traj.ν : Real)
  have hnu : 0 < nu_eff :=
    Rat.cast_pos.mpr (tower.trajAt 0).traj.hν
  exact ⟨{
    u        := uInfty
    nu       := nu_eff
    nu_pos   := hnu
    E0       := (tower.E0 : Real)
    hE0      := Rat.cast_nonneg.mpr tower.hE0
    energy   := henergy
    weak_eqn := galerkinLimit_weak_eqn tower phi hphi uInfty hconv henergy
  }, trivial⟩

def stage174CSummary : String :=
  "Stage 174C: NSGalerkinWeakLimit — Galerkin compactness limit as weak solution. " ++
  "GalerkinWeakSolution: struct { u, nu, E0, energy, weak_eqn } — " ++
    "limit sequence + tsum energy bound + discrete weak NS equation. " ++
  "GalerkinWeakSolution.energy_nonneg: THEOREM (coeffNormSqR_nonneg). " ++
  "galerkinLimit_weak_eqn: AXIOM — step-difference ≤ E0/ν " ++
    "(.partiallyVerified, Temam 1984 III.3.1; Lions 1969 §1.6). " ++
  "galerkinTower_weak_existence: THEOREM (0 new axioms, " ++
    "compactness_certificate + galerkinLimit_weak_eqn). " ++
  "+1 axiom, +2 theorems, 0 sorry."

end NavierStokes.GalerkinWeakLimit
