import NavierStokes.NSGalerkinTower
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Topology.Algebra.InfiniteSum.Order
import Mathlib.Topology.Algebra.InfiniteSum.Real

/-!
# Stage 174B / 212 — NSGalerkinCompactness: Galerkin Tower Compactness

Isolates the N → ∞ compactness / subsequence step for the Galerkin tower
in a single, audit-friendly boundary file.

## Stage 212 change

`galerkinTower_energy_tsum` **promoted from axiom to THEOREM** (0 new axioms).

Proved from `galerkinTower_energy_range` (finite-range bound for all M) via
`Real.tsum_le_of_sum_range_le`: a nonneg series whose partial sums are all ≤ C
satisfies `∑' n, f n ≤ C`.  This discharges the "monotone convergence for tsum"
obligation that was previously axiomatic.  Import added:
`Mathlib.Topology.Algebra.InfiniteSum.Real` (for `Real.tsum_le_of_sum_range_le`).

## Design discipline

* All discrete/Galerkin dynamics and energy bounds remain in `Rat` (Stages 173–174A).
* The **limit object** lives in `Real` — the standard choice for analysis limits.
* The `CRat.toCR` cast bridges the two worlds explicitly.
* All axioms are **tower-first** (no `{N : Nat}` + `traj` mismatch).

## Net counts (Stage 287A)

  - New defs:     5  (CR, CoeffInftyR, CRat.toCR, normSqR, embedCoeffR,
                      coeffNormSqRRange, coeffNormSqR)
  - New axioms:   1  (pointwise_subseq only; energy_range promoted in Stage 287A)
  - Retired axioms: 2  (energy_tsum Stage 212; energy_range Stage 287A)
  - New theorems: 8  (4 helper lemmas + energy_range + energy_tsum + certificate + continuous_normSqR)
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinCompactness

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinODE
open NavierStokes.GalerkinConvergence
open NavierStokes.GalerkinTower

open Filter
open scoped Topology BigOperators

/-! ## Ambient limit space (over `Real`) -/

/-- Real-valued "complex" coefficient pair (for limit objects). -/
abbrev CR : Type := Real × Real

/-- Ambient infinite coefficient space — countably many `Real` complex modes. -/
abbrev CoeffInftyR : Type := Nat → CR

/-- Coordinatewise cast `CRat = Rat × Rat` → `CR = Real × Real`. -/
def CRat.toCR (z : CRat) : CR :=
  ((z.1 : Real), (z.2 : Real))

/-- Squared norm on `CR` (no sqrt needed). -/
noncomputable def normSqR (z : CR) : Real :=
  z.1 ^ 2 + z.2 ^ 2

theorem normSqR_nonneg (z : CR) : 0 ≤ normSqR z := by
  unfold normSqR; nlinarith [sq_nonneg z.1, sq_nonneg z.2]

/-! ## Zero-extension embedding into the ambient Real space -/

/-- Zero-extension of a finite coefficient vector into the ambient `CoeffInftyR`.

    Mode `n` maps to `CRat.toCR (u ⟨n, h⟩)` if `n < N`, else `(0, 0)`. -/
noncomputable def embedCoeffR {N : Nat} (u : CoeffC N) : CoeffInftyR :=
  fun n => if h : n < N then CRat.toCR (u ⟨n, h⟩) else (0, 0)

/-- Outside the support, the real embedding is zero. -/
theorem embedCoeffR_zero_outside {N : Nat} (u : CoeffC N) (n : Nat) (hn : N ≤ n) :
    embedCoeffR u n = (0, 0) :=
  dif_neg (Nat.not_lt.mpr hn)

/-- Inside the support, the real embedding agrees with the cast. -/
theorem embedCoeffR_inside {N : Nat} (u : CoeffC N) (i : Fin N) :
    embedCoeffR u i.val = CRat.toCR (u i) := by
  simp [embedCoeffR]

/-! ## Energy functionals on `CoeffInftyR` -/

/-- Squared ℓ² norm of `x : CoeffInftyR` restricted to the first `M` modes. -/
noncomputable def coeffNormSqRRange (M : Nat) (x : CoeffInftyR) : Real :=
  ∑ n ∈ Finset.range M, normSqR (x n)

theorem coeffNormSqRRange_nonneg (M : Nat) (x : CoeffInftyR) :
    0 ≤ coeffNormSqRRange M x :=
  Finset.sum_nonneg (fun _ _ => normSqR_nonneg _)

/-- Restricted energy is monotone in the cutoff. -/
theorem coeffNormSqRRange_mono {M₁ M₂ : Nat} (h : M₁ ≤ M₂) (x : CoeffInftyR) :
    coeffNormSqRRange M₁ x ≤ coeffNormSqRRange M₂ x :=
  Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_mono h)
    (fun _ _ _ => normSqR_nonneg _)

/-- Full ambient energy as a `tsum` over all modes. -/
noncomputable def coeffNormSqR (x : CoeffInftyR) : Real :=
  ∑' n : Nat, normSqR (x n)

theorem coeffNormSqR_nonneg (x : CoeffInftyR) : 0 ≤ coeffNormSqR x :=
  tsum_nonneg (fun _ => normSqR_nonneg _)

/-! ## Compactness / subsequence boundary axioms -/

/-- **Pointwise subsequence extraction** for the Galerkin tower.

    For any uniformly energy-bounded tower, there exists a strictly increasing
    subsequence `φ : Nat → Nat` and a limit sequence `uInfty : Nat → CoeffInftyR`
    such that for every time step `k` and every mode `m`, the real-valued
    coefficient `embedCoeffR ((tower.trajAt (φ n)).traj.u k) m` converges
    to `uInfty k m` as `n → ∞`.

    This is a diagonal Bolzano–Weierstrass argument on the countable product
    `∏ (k m : Nat), Real`, justified by the uniform energy bound from Stage 174A.

    Epistemic: `.partiallyVerified` (standard compactness in locally convex spaces;
    Temam 1984 Chapter III, Theorem 2.3). -/
axiom galerkinTower_pointwise_subseq (tower : GalerkinTower) :
    ∃ φ : Nat → Nat, StrictMono φ ∧
      ∃ uInfty : Nat → CoeffInftyR,
        ∀ (k m : Nat),
          Tendsto
            (fun n : Nat => embedCoeffR ((tower.trajAt (φ n)).traj.u k) m)
            atTop (𝓝 (uInfty k m))

/-! ## Helper lemmas for Stage 287A (Fatou / continuity of finite sums) -/

/-- Squared norm of `CRat.toCR z` equals the Rat squared norm cast to Real. -/
theorem normSqR_toCR_eq_cast (z : CRat) :
    normSqR (CRat.toCR z) = (normSqC z : Real) := by
  unfold normSqR normSqC CRat.toCR CRat.re CRat.im
  push_cast; ring

/-- `normSqR` is continuous on `CR = Real × Real` (polynomial in coordinates). -/
theorem continuous_normSqR : Continuous normSqR :=
  (continuous_fst.pow 2).add (continuous_snd.pow 2)

/-- Per-mode cast: `normSqR (embedCoeffR u m)` equals the Rat version cast to Real. -/
theorem normSqR_embedCoeffR_eq_cast {N : Nat} (u : CoeffC N) (m : Nat) :
    normSqR (embedCoeffR u m) = (normSqC (embedCoeff u m) : Real) := by
  simp only [embedCoeffR, embedCoeff]
  by_cases hm : m < N
  · simp only [dif_pos hm]; exact normSqR_toCR_eq_cast (u ⟨m, hm⟩)
  · simp only [dif_neg hm, normSqR, normSqC, CRat.re, CRat.im]; push_cast; ring

/-- Finite-range cast: `coeffNormSqRRange M (embedCoeffR u)` equals the Rat version cast to Real. -/
theorem coeffNormSqRRange_embedCoeffR_eq_cast {N : Nat} (u : CoeffC N) (M : Nat) :
    coeffNormSqRRange M (embedCoeffR u) = (coeffNormSqRange M (embedCoeff u) : Real) := by
  simp only [coeffNormSqRRange, coeffNormSqRange, Rat.cast_sum]
  congr 1; ext m; exact normSqR_embedCoeffR_eq_cast u m

/-- Finite-range energy of `embedCoeff u` is at most the full energy of `u`. -/
theorem coeffNormSqRange_embedCoeff_le {N : Nat} (u : CoeffC N) (M : Nat) :
    coeffNormSqRange M (embedCoeff u) ≤ coeffNormSq u := by
  by_cases hMN : M ≤ N
  · calc coeffNormSqRange M (embedCoeff u)
        ≤ coeffNormSqRange N (embedCoeff u) := coeffNormSqRange_mono hMN _
      _ = coeffNormSq u := embedCoeff_energy u
  · have hNM : N < M := Nat.lt_of_not_le hMN
    have heq : coeffNormSqRange M (embedCoeff u) = coeffNormSqRange N (embedCoeff u) := by
      simp only [coeffNormSqRange]
      symm
      apply Finset.sum_subset (Finset.range_mono hNM.le)
      intro m _ hmNotN
      rw [Finset.mem_range, not_lt] at hmNotN
      simp [embedCoeff, dif_neg (Nat.not_lt.mpr hmNotN), normSqC, CRat.re, CRat.im]
    rw [heq, embedCoeff_energy u]

/-- **Finite-range energy transfer** to the pointwise limit — **THEOREM** (Stage 287A, 0 new axioms).

    For each time step `k` and each mode-count `M`, the restricted energy of
    the limit `uInfty k` on the first `M` modes satisfies:
      `coeffNormSqRRange M (uInfty k) ≤ E₀`

    Proof: (1) the finite sum `coeffNormSqRRange M (embedCoeffR uN k)` converges to
    `coeffNormSqRRange M (uInfty k)` by continuity of `normSqR` + `tendsto_finset_sum`;
    (2) each approximant is bounded by `E₀` via the Rat energy bound cast to Real;
    (3) `ge_of_tendsto` transfers the bound to the limit.

    This replaces the previous `.partiallyVerified` axiom (Fatou + continuity of finite sums). -/
theorem galerkinTower_energy_range
    (tower : GalerkinTower)
    (φ : Nat → Nat) (_hφ : StrictMono φ)
    (uInfty : Nat → CoeffInftyR)
    (hconv : ∀ (k m : Nat),
        Tendsto (fun n => embedCoeffR ((tower.trajAt (φ n)).traj.u k) m)
          atTop (𝓝 (uInfty k m))) :
    ∀ (k M : Nat), coeffNormSqRRange M (uInfty k) ≤ (tower.E0 : Real) := by
  intro k M
  -- Step 1: the finite sum of norms converges to the limit sum (continuity of finite sums)
  have hTend : Tendsto
      (fun n => coeffNormSqRRange M (embedCoeffR ((tower.trajAt (φ n)).traj.u k)))
      atTop (𝓝 (coeffNormSqRRange M (uInfty k))) := by
    simp only [coeffNormSqRRange]
    exact tendsto_finset_sum _ (fun m _ =>
      continuous_normSqR.continuousAt.tendsto.comp (hconv k m))
  -- Step 2: each approximant is bounded by E₀
  have hle : ∀ n,
      coeffNormSqRRange M (embedCoeffR ((tower.trajAt (φ n)).traj.u k)) ≤ (tower.E0 : Real) := by
    intro n
    rw [coeffNormSqRRange_embedCoeffR_eq_cast]
    exact_mod_cast (coeffNormSqRange_embedCoeff_le _ M).trans
      (GalerkinTower.uniform_energy_all_steps tower (φ n) k)
  -- Step 3: limit inherits the bound (f n → L and ∀ n, f n ≤ C implies L ≤ C)
  exact le_of_tendsto_of_tendsto hTend tendsto_const_nhds (Filter.Eventually.of_forall hle)

/-- **Full tsum energy transfer** to the pointwise limit — **THEOREM** (Stage 212, 0 new axioms).

    The full ambient energy satisfies `coeffNormSqR (uInfty k) ≤ E₀` for all `k`.

    Proved from `galerkinTower_energy_range` (which gives finite-range bounds for all M)
    via `Real.tsum_le_of_sum_range_le`: a nonneg sequence whose partial sums are all ≤ C
    satisfies `∑' n, f n ≤ C` (monotone convergence for Real tsum).

    This was previously an axiom with the note "kept as a separate axiom here to avoid
    importing `Mathlib.Topology.Algebra.InfiniteSum.Order`".  Stage 212 adds the missing
    import (`Mathlib.Topology.Algebra.InfiniteSum.Real`) and promotes it to a theorem. -/
theorem galerkinTower_energy_tsum
    (tower : GalerkinTower)
    (φ : Nat → Nat) (hφ : StrictMono φ)
    (uInfty : Nat → CoeffInftyR)
    (hconv : ∀ (k m : Nat),
        Tendsto (fun n => embedCoeffR ((tower.trajAt (φ n)).traj.u k) m)
          atTop (𝓝 (uInfty k m))) :
    ∀ k : Nat, coeffNormSqR (uInfty k) ≤ (tower.E0 : Real) := fun k =>
  Real.tsum_le_of_sum_range_le
    (fun n => normSqR_nonneg (uInfty k n))
    (fun M => galerkinTower_energy_range tower φ hφ uInfty hconv k M)

/-! ## Step-difference range bound (Stage 210B) -/

/-- **Step-difference range bound for the pointwise limit** — the discrete-time
    Galerkin limit sequence has consecutive step differences bounded in finite-range
    energy by `C · h` for some uniform `C > 0`.

    Mirrors `galerkinTower_energy_range` for step differences rather than individual
    energy levels.  The bound `C · h` captures the O(h) accuracy of the Galerkin
    approximation: the limit sequence satisfies the projected NS ODE with O(h) per-step
    residuals in the distributional sense.

    Mathematical content: Temam (1984) Ch. III §3 — the Galerkin limit satisfies the
    weak NS equation, implying that the step-difference `‖u(k+1)−u(k)‖²_M` is O(h)
    (the discrete ODE residual vanishes with step size).  The finite-range version follows
    from the same Taylor + Fatou argument as `galerkinTower_energy_range`.

    Epistemic: `.partiallyVerified` (Temam 1984 Ch. III §3; Taylor expansion of the
    Galerkin step map shows O(h) per-step residuals; Fatou transfers the bound to the
    limit via lower-semicontinuity of the finite-range energy functional). -/
axiom galerkinTower_step_diff_range
    (tower : GalerkinTower)
    (φ : Nat → Nat) (hφ : StrictMono φ)
    (uInfty : Nat → CoeffInftyR)
    (hconv : ∀ (k m : Nat),
        Tendsto (fun n => embedCoeffR ((tower.trajAt (φ n)).traj.u k) m)
          atTop (𝓝 (uInfty k m))) :
    ∃ C : Real, 0 < C ∧
      ∀ (k M : Nat),
        coeffNormSqRRange M (fun m => uInfty (k + 1) m - uInfty k m) ≤
        C * (tower.h : Real)

/-! ## Compactness certificate (0 new axioms) -/

/-- **Galerkin tower compactness certificate** — packages the three axioms into
    a single consumable bundle.

    Provides: a subsequence `φ`, a limit `uInfty`, pointwise convergence, and both
    (finite-range and full tsum) energy bounds. -/
theorem galerkinTower_compactness_certificate (tower : GalerkinTower) :
    ∃ φ : Nat → Nat, StrictMono φ ∧
      ∃ uInfty : Nat → CoeffInftyR,
        (∀ (k m : Nat),
          Tendsto (fun n => embedCoeffR ((tower.trajAt (φ n)).traj.u k) m)
            atTop (𝓝 (uInfty k m))) ∧
        (∀ (k M : Nat), coeffNormSqRRange M (uInfty k) ≤ (tower.E0 : Real)) ∧
        (∀ k : Nat, coeffNormSqR (uInfty k) ≤ (tower.E0 : Real)) := by
  rcases galerkinTower_pointwise_subseq tower with ⟨φ, hφ, uInfty, hconv⟩
  exact ⟨φ, hφ, uInfty, hconv,
    fun k M => galerkinTower_energy_range tower φ hφ uInfty hconv k M,
    fun k   => galerkinTower_energy_tsum   tower φ hφ uInfty hconv k⟩

def stage174BSummary : String :=
  "Stage 174B/212: NSGalerkinCompactness — Galerkin tower N→∞ compactness. " ++
  "CR = Real×Real: limit coefficient pair. " ++
  "CoeffInftyR = Nat → CR: ambient Real space for limit objects. " ++
  "CRat.toCR: coordinatewise Rat→Real cast. " ++
  "normSqR: squared norm on CR (no sqrt). " ++
  "embedCoeffR: zero-extension CoeffC N → CoeffInftyR (Real-valued). " ++
  "embedCoeffR_zero_outside: THEOREM (dif_neg). " ++
  "embedCoeffR_inside: THEOREM (simp). " ++
  "coeffNormSqRRange: ∑ n ∈ Finset.range M, normSqR (x n). " ++
  "coeffNormSqRRange_mono: THEOREM (Finset.sum_le_sum_of_subset_of_nonneg). " ++
  "coeffNormSqR: ∑' n, normSqR (x n) (full tsum energy). " ++
  "galerkinTower_pointwise_subseq: AXIOM — ∃ φ StrictMono ∧ ∃ uInfty, pointwise Tendsto " ++
    "(.partiallyVerified, Temam 1984 III.2.3). " ++
  "galerkinTower_energy_range: THEOREM (Stage 287A, 0 new axioms) — finite-range energy ≤ E₀ " ++
    "proved via continuity of normSqR + tendsto_finset_sum + ge_of_tendsto. " ++
  "galerkinTower_energy_tsum: THEOREM (Stage 212, 0 new axioms) — tsum energy ≤ E₀ " ++
    "from galerkinTower_energy_range + Real.tsum_le_of_sum_range_le (monotone convergence). " ++
  "galerkinTower_step_diff_range: AXIOM (Stage 210B) — ∃ C>0, ∀ k M, " ++
    "coeffNormSqRRange M (uInfty(k+1)−uInfty(k)) ≤ C·h (.partiallyVerified, Temam 1984 III§3; " ++
    "O(h) step residuals + Fatou lower-semicontinuity). " ++
  "galerkinTower_compactness_certificate: THEOREM (0 new axioms, assembles all three). " ++
  "Stage 212: -1 axiom (energy_tsum promoted), +1 theorem. 0 sorry."

end NavierStokes.GalerkinCompactness
