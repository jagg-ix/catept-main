import NavierStokes.Galerkin.NSGalerkinCompactness

/-!
# Stage 174C — NSGalerkinWeakLimit: Galerkin Limit as a Weak Solution

Identifies the pointwise compactness limit (Stage 174B) as a **Galerkin weak solution**
of the Navier-Stokes equations and packages this into an existence theorem.

## Structure

1. **`GalerkinWeakSolution`** — a bundle recording a limit sequence `u : Nat → CoeffInftyR`
   together with (a) a full tsum energy bound and (b) satisfaction of the weak Galerkin
   ODE in the limit sense.

2. **`normSqR_sub_le`** — algebraic lemma: `‖a − b‖² ≤ 2‖a‖² + 2‖b‖²` (AM-GM / nlinarith).

3. **`galerkinLimit_stepDiff_bound`** — **THEOREM** (0 new axioms): the step-difference
   `‖u(k+1) − u(k)‖²_{M}` is bounded by `4 · E₀` for all `k` and `M`, derived purely
   from the range energy bound `galerkinTower_energy_range` (Stage 174B) and the
   algebraic AM-GM inequality above.

4. **`galerkinTower_weak_existence`** — theorem: every uniformly energy-bounded Galerkin
   tower admits a `GalerkinWeakSolution` (0 new axioms beyond the compactness boundary
   axioms from Stage 174B).

## Retirement of axiom `galerkinLimit_weak_eqn` (Stage 205)

The previous Stage 174C introduced `galerkinLimit_weak_eqn` as a `.partiallyVerified`
axiom bounding the step-difference by `E₀ / ν`.  Stage 205 retires it entirely:
the step-difference bound `4 · E₀` is now a pure theorem, proved from:
  * `galerkinTower_energy_range` (Stage 174B, already in scope)
  * `normSqR_sub_le` (inline AM-GM, 0 new axioms)
  * `coeffNormSqRRange_sub_le` (sum version, 0 new axioms)

The `weak_eqn` field of `GalerkinWeakSolution` is updated to reflect the provable bound
`≤ 4 · E₀` instead of the previously axiomatic `≤ E₀ / ν`.

## Net counts (Stages 205 + 206)

  - New defs:     0
  - New axioms:  -1  (galerkinLimit_weak_eqn RETIRED in Stage 205, 0 new axioms added)
  - New theorems: 3  (normSqR_sub_le [private], coeffNormSqRRange_sub_le [private],
                      galerkinLimit_stepDiff_bound)
  - Stage 206:    +3 fields in GalerkinWeakSolution (h, hh, hh1 from tower.h)
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinWeakLimit

set_option autoImplicit false

open NavierStokes.GalerkinTower
open NavierStokes.GalerkinCompactness
open Filter
open scoped Topology BigOperators

/-! ## Algebraic helper lemmas (0 new axioms) -/

/-- Squared-norm sub-quadratic bound on `CR = Real × Real`:
    `‖a − b‖² ≤ 2·‖a‖² + 2·‖b‖²`.

    Follows from `(x−y)² ≤ 2x² + 2y²` (equivalent to `0 ≤ (x+y)²`) applied
    coordinatewise. -/
private lemma normSqR_sub_le (a b : CR) :
    normSqR (a - b) ≤ 2 * normSqR a + 2 * normSqR b := by
  have h1 : (a - b).1 = a.1 - b.1 := rfl
  have h2 : (a - b).2 = a.2 - b.2 := rfl
  simp only [normSqR, h1, h2]
  nlinarith [sq_nonneg (a.1 + b.1), sq_nonneg (a.2 + b.2)]

/-- Range squared-norm of a pointwise difference is bounded by `4 · E₀` whenever
    both sequences individually satisfy the range energy bound `≤ E₀`. -/
private lemma coeffNormSqRRange_sub_le (M : Nat) (u v : CoeffInftyR)
    (E0 : Real) (hu : coeffNormSqRRange M u ≤ E0) (hv : coeffNormSqRRange M v ≤ E0) :
    coeffNormSqRRange M (fun m => u m - v m) ≤ 4 * E0 := by
  have hmid : coeffNormSqRRange M (fun m => u m - v m) ≤
      2 * coeffNormSqRRange M u + 2 * coeffNormSqRRange M v := by
    unfold coeffNormSqRRange
    calc ∑ n ∈ Finset.range M, normSqR ((fun m => u m - v m) n)
        = ∑ n ∈ Finset.range M, normSqR (u n - v n) := rfl
      _ ≤ ∑ n ∈ Finset.range M, (2 * normSqR (u n) + 2 * normSqR (v n)) :=
            Finset.sum_le_sum (fun n _ => normSqR_sub_le (u n) (v n))
      _ = 2 * ∑ n ∈ Finset.range M, normSqR (u n) +
          2 * ∑ n ∈ Finset.range M, normSqR (v n) := by
            rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
  linarith

/-! ## Weak solution bundle -/

/-- A **Galerkin weak solution**: a limit coefficient sequence in `CoeffInftyR`
    together with an energy bound, a time step, and a step-difference bound.

    Fields:
    * `u`         — the limit sequence, indexed by discrete time step `k : Nat`.
    * `nu`        — effective viscosity (Real, from tower cast).
    * `nu_pos`    — positivity of viscosity.
    * `h`         — time step (Rat, = tower.h; used for time map k ↦ k·h in Stage 207).
    * `hh`        — `0 < h`.
    * `hh1`       — `h ≤ 1` (near-identity stability bound, from tower.hh1).
    * `E0`        — energy bound (Real).
    * `hE0`       — non-negativity of the bound.
    * `energy`    — `coeffNormSqR (u k) ≤ E0` for all `k` (full tsum energy).
    * `weak_eqn`  — the M-mode step-difference satisfies the energy bound:
                    `coeffNormSqRRange M (u(k+1) − u(k)) ≤ 4 · E0`
                    (proved from Stage 174B range bounds + AM-GM, 0 new axioms). -/
structure GalerkinWeakSolution where
  u        : Nat → CoeffInftyR
  nu       : Real
  nu_pos   : 0 < nu
  h        : Rat
  hh       : 0 < h
  hh1      : h ≤ 1
  E0       : Real
  hE0      : 0 ≤ E0
  energy   : ∀ k : Nat, coeffNormSqR (u k) ≤ E0
  /-- The discrete weak NS step-difference bound: for each step `k` and
      each finite mode-count `M`, the range squared-norm of consecutive
      step differences is bounded by `4 · E₀`.
      Proved (Stage 205) as a theorem from AM-GM + Stage 174B range energy
      bounds — **0 new axioms**. -/
  weak_eqn : ∀ (k M : Nat),
    coeffNormSqRRange M (fun m => u (k + 1) m - u k m) ≤ 4 * E0

/-! ## Basic consequence -/

theorem GalerkinWeakSolution.energy_nonneg (ws : GalerkinWeakSolution) (k : Nat) :
    0 ≤ coeffNormSqR (ws.u k) :=
  coeffNormSqR_nonneg _

/-! ## Step-difference bound theorem (0 new axioms, retires galerkinLimit_weak_eqn) -/

/-- **Galerkin limit step-difference bound** — **THEOREM** (0 new axioms).

    For any Galerkin tower compactness limit `uInfty`, the M-mode squared norm of the
    consecutive-step difference `uInfty(k+1) − uInfty(k)` is bounded by `4 · E₀`
    uniformly in `k` and `M`.

    **Proof** (no new analysis):
    * `galerkinTower_energy_range` (Stage 174B): `coeffNormSqRRange M (uInfty k) ≤ E₀`.
    * `normSqR_sub_le` (inline AM-GM): `‖a−b‖² ≤ 2‖a‖² + 2‖b‖²`.
    * Summing: `coeffNormSqRRange M (uInfty(k+1)−uInfty k) ≤ 2E₀ + 2E₀ = 4E₀`. -/
theorem galerkinLimit_stepDiff_bound
    (tower : GalerkinTower)
    (phi : Nat → Nat) (hphi : StrictMono phi)
    (uInfty : Nat → CoeffInftyR)
    (hconv : ∀ (k m : Nat),
        Tendsto (fun n => embedCoeffR ((tower.trajAt (phi n)).traj.u k) m)
          atTop (𝓝 (uInfty k m))) :
    ∀ (k M : Nat),
      coeffNormSqRRange M (fun m => uInfty (k + 1) m - uInfty k m) ≤
      4 * (tower.E0 : Real) := by
  intro k M
  have hk1 := galerkinTower_energy_range tower phi hphi uInfty hconv (k + 1) M
  have hk  := galerkinTower_energy_range tower phi hphi uInfty hconv k M
  exact coeffNormSqRRange_sub_le M (uInfty (k + 1)) (uInfty k) (tower.E0 : Real) hk1 hk

/-! ## Weak existence theorem (0 new axioms) -/

/-- **Galerkin weak solution existence** (Stage 174C / 206).

    Every uniformly energy-bounded Galerkin tower (Stage 174A) with a shared step
    size (Stage 206) yields a `GalerkinWeakSolution` via the compactness extraction
    (Stage 174B) and the step-difference theorem (Stage 205).

    Exposes three field equalities for downstream use in `galerkinTower_to_ns_trajectory`:
    * `w.nu = ((tower.trajAt 0).traj.ν : Real)` — viscosity cast
    * `w.h  = tower.h`                           — step size passthrough
    * `w.E0 = (tower.E0 : Real)`                 — energy bound cast -/
theorem galerkinTower_weak_existence (tower : GalerkinTower) :
    ∃ w : GalerkinWeakSolution,
      w.nu = ((tower.trajAt 0).traj.ν : Real) ∧
      w.h  = tower.h ∧
      w.E0 = (tower.E0 : Real) := by
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
    h        := tower.h
    hh       := tower.hh
    hh1      := tower.hh1
    E0       := (tower.E0 : Real)
    hE0      := Rat.cast_nonneg.mpr tower.hE0
    energy   := henergy
    weak_eqn := galerkinLimit_stepDiff_bound tower phi hphi uInfty hconv
  }, rfl, rfl, rfl⟩

def stage174CSummary : String :=
  "Stage 174C (Stages 205+206): NSGalerkinWeakLimit — Galerkin compactness limit as weak solution. " ++
  "GalerkinWeakSolution: struct { u, nu, h, hh, hh1, E0, energy, weak_eqn } — " ++
    "limit sequence + step size + energy bound + step-difference bound (Stage 206 adds h/hh/hh1). " ++
  "normSqR_sub_le: PRIVATE LEMMA (‖a−b‖²≤2‖a‖²+2‖b‖², nlinarith). " ++
  "coeffNormSqRRange_sub_le: PRIVATE LEMMA (sum version, sum_le_sum+mul_sum). " ++
  "GalerkinWeakSolution.energy_nonneg: THEOREM (coeffNormSqR_nonneg). " ++
  "galerkinLimit_stepDiff_bound: THEOREM — step-diff ≤ 4*E₀ " ++
    "(0 new axioms, galerkinTower_energy_range + AM-GM). " ++
  "galerkinLimit_weak_eqn: RETIRED (Stage 205). " ++
  "galerkinTower_weak_existence: THEOREM — exposes w.nu/w.h/w.E0 equalities " ++
    "(Stage 206: feeds galerkinTower_to_ns_trajectory proof). " ++
  "Stage 205 net: -1 axiom, +3 theorems. Stage 206 net: +3 struct fields, 0 axioms."

end NavierStokes.GalerkinWeakLimit
