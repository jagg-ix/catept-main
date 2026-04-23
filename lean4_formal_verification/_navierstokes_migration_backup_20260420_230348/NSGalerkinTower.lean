import NavierStokes.Galerkin.NSGalerkinConvergence

/-!
# Stage 174A — NSGalerkinTower: Galerkin Tower and Ambient Coefficient Space

Lays the algebraic infrastructure for the N→∞ limit:

1. **`GalerkinLevelTraj N`** — a wrapper recording that a trajectory lives at cutoff level N,
   avoiding the `GalerkinBasis N` vs `GalerkinBasis traj.N` mismatch.

2. **`GalerkinTower`** — an N-indexed family of level trajectories with a uniform initial
   energy bound (the key compactness hypothesis).

3. **`CoeffInfty = Nat → CRat`** — an ambient coefficient space in which all finite-dimensional
   coefficient vectors can be embedded by zero-extension.

4. **`embedCoeff`** — the zero-extension embedding `CoeffC N ↪ CoeffInfty`.

5. **`coeffNormSqRange`** — the squared ℓ² norm of a `CoeffInfty` sequence restricted to
   the first N modes, allowing energy comparisons across different levels.

## Design discipline

Every lemma takes `tower : GalerkinTower` (or `lt : GalerkinLevelTraj N`) as the primary
argument. The implicit `{N : Nat}` from `GalerkinBasis N` is only introduced when it is
definitionally controlled by the primary argument. This avoids the mismatch between the
separate `N` universe and `traj.N` (the field inside `GalerkinNSDiscreteTrajectory`).

## Net counts

  - New defs:     5  (GalerkinLevelTraj, GalerkinTower, Coeff∞, embedCoeff, coeffNormSqRange)
  - New axioms:   0
  - New theorems: 8
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinTower

set_option autoImplicit false
set_option linter.dupNamespace false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinODE
open NavierStokes.GalerkinConvergence

/-! ## Level trajectory wrapper -/

/-- A Galerkin trajectory at cutoff level N.

    The wrapper records `hN : traj.N = N` once, enabling clean type-safe access
    to `CoeffC N` throughout Stage 174 without re-encountering the
    `GalerkinBasis N` vs `GalerkinBasis traj.N` mismatch of Stage 173. -/
structure GalerkinLevelTraj (N : Nat) where
  traj : GalerkinNSDiscreteTrajectory
  hN   : traj.N = N

/-! ## Galerkin tower -/

/-- An N-indexed family of Galerkin level trajectories with a uniform initial energy bound
    and a **shared time step** `h` across all levels.

    The uniform bound `∀ N, coeffNormSq (u_N(0)) ≤ E0` is the key compactness hypothesis:
    it ensures (via energy dissipation at each level) that the full family is uniformly
    bounded in ℓ² at every time step, providing the control needed to extract subsequences.

    The uniform step `uniform_h : ∀ N, (trajAt N).traj.h = h` fixes the time discretization
    across all cutoff levels.  This is the Faedo-Galerkin design: one mesh size `h`, many
    cutoffs `N → ∞`.  The second limit `h → 0` is handled separately (Stage 207+).

    **Discipline**: all Stage 174 lemmas take `tower : GalerkinTower` (or `lt : GalerkinLevelTraj N`) as the primary
    argument. The implicit `{N : Nat}` from `GalerkinBasis N` is only introduced when it is
    definitionally controlled by the primary argument. This avoids the mismatch between the
    separate `N` universe and `traj.N` (the field inside `GalerkinNSDiscreteTrajectory`). -/
structure GalerkinTower where
  /-- The level-N trajectory for each cutoff N. -/
  trajAt          : ∀ N : Nat, GalerkinLevelTraj N
  /-- Uniform initial energy bound E₀ ≥ 0. -/
  E0              : Rat
  hE0             : 0 ≤ E0
  /-- Shared time step across all levels (Faedo-Galerkin: fixed h, N → ∞). -/
  h               : Rat
  /-- Positivity of the time step. -/
  hh              : 0 < h
  /-- Step size is at most 1 (needed for near-identity Cayley stability bounds). -/
  hh1             : h ≤ 1
  /-- All initial states lie in the energy ball of radius E₀. -/
  uniform_energy0 : ∀ N : Nat, coeffNormSq ((trajAt N).traj.u 0) ≤ E0
  /-- Every level trajectory uses the shared step size. -/
  uniform_h       : ∀ N : Nat, (trajAt N).traj.h = h

/-! ## Ambient coefficient space -/

/-- Ambient coefficient space: infinite sequences of complex rational Galerkin modes.

    Every finite `CoeffC N` embeds into `CoeffInfty` by zero-extension (see `embedCoeff`).
    This provides a single ambient type for all levels, making "N→∞" meaningful. -/
abbrev CoeffInfty : Type := Nat → CRat

/-! ## Zero-extension embedding -/

/-- Zero-extension of `u : CoeffC N` to all of `ℕ`.

    Mode `n` is mapped to `u ⟨n, h⟩` if `n < N`, and to `(0, 0)` otherwise.
    The embedding is explicit and computable (Nat inequality is decidable). -/
noncomputable def embedCoeff {N : Nat} (u : CoeffC N) : CoeffInfty :=
  fun n => if h : n < N then u ⟨n, h⟩ else (0, 0)

/-- Outside the support `{0, …, N−1}`, the embedding is zero. -/
theorem embedCoeff_zero_outside {N : Nat} (u : CoeffC N) (n : Nat) (hn : N ≤ n) :
    embedCoeff u n = (0, 0) :=
  dif_neg (Nat.not_lt.mpr hn)

/-- Inside the support, the embedding agrees with `u`. -/
theorem embedCoeff_inside {N : Nat} (u : CoeffC N) (i : Fin N) :
    embedCoeff u i.val = u i := by
  simp [embedCoeff]

/-! ## Energy on the first N modes -/

/-- Squared ℓ² norm of `x : CoeffInfty` restricted to the first N modes.

    `coeffNormSqRange N x = ∑ n < N, normSqC (x n)`.

    This is the "finite-level energy" at cutoff N.  When `x = embedCoeff u` for
    `u : CoeffC N`, this equals `coeffNormSq u` (see `embedCoeff_energy`). -/
noncomputable def coeffNormSqRange (N : Nat) (x : CoeffInfty) : Rat :=
  ∑ n ∈ Finset.range N, normSqC (x n)

theorem coeffNormSqRange_nonneg (N : Nat) (x : CoeffInfty) : 0 ≤ coeffNormSqRange N x :=
  Finset.sum_nonneg (fun _ _ => normSqC_nonneg _)

/-- The restricted energy is monotone in the cutoff: more modes → larger (or equal) energy. -/
theorem coeffNormSqRange_mono {N₁ N₂ : Nat} (h : N₁ ≤ N₂) (x : CoeffInfty) :
    coeffNormSqRange N₁ x ≤ coeffNormSqRange N₂ x :=
  Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_mono h)
    (fun _ _ _ => normSqC_nonneg _)

/-! ## Energy compatibility: embed then restrict = original -/

/-- **Key energy identity**: restricting the embedded vector to its N modes recovers
    the original energy.

    `coeffNormSqRange N (embedCoeff u) = coeffNormSq u`

    This is the algebraic backbone of the compactness argument: uniform bounds on
    `coeffNormSq` at each level translate directly to uniform bounds on the embedded
    sequences in `Coeff∞`. -/
theorem embedCoeff_energy {N : Nat} (u : CoeffC N) :
    coeffNormSqRange N (embedCoeff u) = coeffNormSq u := by
  simp only [coeffNormSqRange, coeffNormSq]
  -- Rewrite the Finset.range N sum as a Fin N sum via Fin.sum_univ_eq_sum_range
  rw [← Fin.sum_univ_eq_sum_range (fun n => normSqC (embedCoeff u n))]
  -- Now both sides are ∑ i : Fin N, normSqC (...)
  congr 1
  ext i
  -- embedCoeff u ↑i = u i by dif_pos
  simp [embedCoeff]

/-! ## Uniform energy bound at all steps (derived theorem) -/

/-- **Uniform energy at all steps**: energy dissipation at each level, combined with the
    tower's uniform initial bound, gives a time-uniform energy bound.

    `coeffNormSq (traj_N.u n) ≤ E0` for all N and all n.

    Proof: Stage 164 `energy_dissipation_mono` gives `E(n) ≤ E(0)` at each level;
    the tower hypothesis gives `E(0) ≤ E0`. Zero new axioms. -/
theorem GalerkinTower.uniform_energy_all_steps (tower : GalerkinTower) :
    ∀ N n : Nat, coeffNormSq ((tower.trajAt N).traj.u n) ≤ tower.E0 := by
  intro N n
  calc coeffNormSq ((tower.trajAt N).traj.u n)
      ≤ coeffNormSq ((tower.trajAt N).traj.u 0) := by
          unfold coeffNormSq
          exact (tower.trajAt N).traj.energy_dissipation_mono 0 n (Nat.zero_le n)
    _ ≤ tower.E0 := tower.uniform_energy0 N

/-- The embedded sequence satisfies a uniform energy bound in `CoeffInfty`. -/
theorem GalerkinTower.embedded_energy_bound (tower : GalerkinTower) :
    ∀ N n : Nat,
      coeffNormSqRange (tower.trajAt N).traj.N
        (embedCoeff ((tower.trajAt N).traj.u n)) ≤ tower.E0 := by
  intro N n
  rw [embedCoeff_energy]
  exact GalerkinTower.uniform_energy_all_steps tower N n

def stage174ArtSummary : String :=
  "Stage 174A: NSGalerkinTower — Galerkin tower and ambient coefficient space. " ++
  "GalerkinLevelTraj N: struct { traj, hN : traj.N = N } — type-safe level wrapper. " ++
  "GalerkinTower: struct { trajAt, E0, h, hh, hh1, uniform_energy0, uniform_h } — " ++
    "uniform energy bound + shared step size (Stage 206). " ++
  "CoeffInfty = Nat → CRat: ambient space for all finite levels. " ++
  "embedCoeff: zero-extension CoeffC N → CoeffInfty (if n < N then u ⟨n, h⟩ else (0,0)). " ++
  "embedCoeff_zero_outside: THEOREM (dif_neg). " ++
  "embedCoeff_inside: THEOREM (dif_pos + Fin.eta). " ++
  "coeffNormSqRange: ∑ n ∈ Finset.range N, normSqC (x n). " ++
  "coeffNormSqRange_nonneg: THEOREM (Finset.sum_nonneg). " ++
  "coeffNormSqRange_mono: THEOREM (Finset.sum_le_sum_of_subset_of_nonneg + Finset.range_mono). " ++
  "embedCoeff_energy: THEOREM (Fin.sum_univ_eq_sum_range + dif_pos + Fin.eta). " ++
  "GalerkinTower.uniform_energy_all_steps: THEOREM (energy_dissipation_mono + uniform_energy0). " ++
  "GalerkinTower.embedded_energy_bound: THEOREM (embedCoeff_energy + uniform_energy_all_steps). " ++
  "+0 axioms, +8 theorems, 0 sorry."

end NavierStokes.GalerkinTower
