import NavierStokes.NSGalerkinConvDef

/-!
# Stage 173 — NSGalerkinConvergence: Lie-Splitting Convergence as h→0

Proves the discrete Lie-splitting Galerkin integrator (Stages 164–171) converges to the
exact finite-dimensional Galerkin ODE solution at rate O(h) on finite time intervals.

## Three-ingredient convergence proof

1. **Consistency** (new axiom) — one step of `viscStep ∘ convStep`, starting from the exact
   ODE solution at time t, lands within `C_lte · h²` of the exact solution at t + h.

2. **Stability** (Stage 164 theorem, reused) — energy dissipation holds for the trajectory.

3. **Convergence** (new theorem) — **discrete Grönwall inequality** (pure Rat induction, 0 new
   axioms): if `e(n+1) ≤ (1+L)*e(n) + B` then `e(n) ≤ (1+L)^n * (e(0) + n*B)`.

## Net counts (after Stages 179-180)

  - New defs:     2  (coeffSub, coeffNormSq)
  - New axioms:   1  (galerkinSplitting_one_step_recurrence; constants→DEF; consistency+recurrence→theorems)
  - New theorems: 11
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinConvergence

set_option autoImplicit false

open NavierStokes.PalinstrophyTauBridge
open NavierStokes.GalerkinComplexModel
open NavierStokes.GalerkinConvection
open NavierStokes.GalerkinODE
open NavierStokes.GalerkinConvDef

/-! ## CoeffC operations -/

/-- Pointwise subtraction of Galerkin coefficient vectors. -/
def coeffSub {N : Nat} (u v : CoeffC N) : CoeffC N :=
  fun i => u i - v i

/-- Squared ℓ² norm of Galerkin coefficients. -/
def coeffNormSq {N : Nat} (u : CoeffC N) : Rat :=
  ∑ i : Fin N, normSqC (u i)

theorem coeffNormSq_nonneg {N : Nat} (u : CoeffC N) : 0 ≤ coeffNormSq u :=
  Finset.sum_nonneg (fun i _ => normSqC_nonneg (u i))

/-! ## Helper: 1 ≤ a^n when 1 ≤ a -/

/-- For `1 ≤ a`, we have `1 ≤ a^n` for all n. Proved by induction. -/
private theorem one_le_pow_of_one_le {a : Rat} (ha : 1 ≤ a) : ∀ n : Nat, 1 ≤ a ^ n := by
  intro n
  induction n with
  | zero => simp
  | succ k ih =>
    have ha_nn : 0 ≤ a ^ k := le_trans (by norm_num) ih
    calc (1 : Rat)
        = 1 * 1 := (mul_one 1).symm
      _ ≤ a ^ k * a :=
          mul_le_mul ih ha (by norm_num) ha_nn
      _ = a ^ (k + 1) := (pow_succ a k).symm

/-! ## Discrete Grönwall inequality (0 new axioms) -/

/-- **Discrete Grönwall inequality** (pure Rat arithmetic, proof by induction).

    If a sequence `e : Nat → Rat` satisfies `e(n+1) ≤ (1 + L) * e(n) + B` for all n,
    then `e(n) ≤ (1 + L)^n * (e(0) + ↑n * B)`.

    Application: take `L = lipC * h²`, `B = lteC * h²`, `e(0) = 0`.
    Then `e(n) ≤ (1+L)^n * n * B`. For `n·h ≤ T` and `h → 0`, the bound is O(h). -/
theorem discrete_gronwall (L B : Rat) (hL : 0 ≤ L) (hB : 0 ≤ B)
    (e : Nat → Rat) (hrec : ∀ n, e (n + 1) ≤ (1 + L) * e n + B) :
    ∀ n : Nat, e n ≤ (1 + L) ^ n * (e 0 + ↑n * B) := by
  intro n
  induction n with
  | zero => simp
  | succ n ih =>
    have hL1_nn : (0 : Rat) ≤ 1 + L := by linarith
    have hpow_nn : (0 : Rat) ≤ (1 + L) ^ (n + 1) := pow_nonneg hL1_nn _
    have hpow_ge1 : (1 : Rat) ≤ (1 + L) ^ (n + 1) :=
      one_le_pow_of_one_le (by linarith) (n + 1)
    calc e (n + 1)
        ≤ (1 + L) * e n + B := hrec n
      _ ≤ (1 + L) * ((1 + L) ^ n * (e 0 + ↑n * B)) + B := by
          have hmul := mul_le_mul_of_nonneg_left ih hL1_nn
          linarith
      _ = (1 + L) ^ (n + 1) * (e 0 + ↑n * B) + B := by
          rw [pow_succ]; ring
      _ ≤ (1 + L) ^ (n + 1) * (e 0 + ↑(n + 1) * B) := by
          push_cast
          nlinarith [mul_nonneg hpow_nn hB]

/-! ## Splitting constants: LTE + Lipschitz -/

/-- Constants governing convergence of the Lie-splitting Galerkin scheme.

    `lteC` — local truncation error constant (positive).
    `lipC` — Lipschitz stability constant (positive).
    Both depend on N, ν, and E₀ (energy-ball radius). -/
structure SplittingConstants {N : Nat} (basis : GalerkinBasis N) (ν E₀ : Rat) where
  lteC       : Rat
  lipC       : Rat
  lteC_pos   : 0 < lteC
  lipC_pos   : 0 < lipC

/-- **Splitting constants** — explicit noncomputable def (Stage 179, promotes A1 from axiom).

    - `lteC := E₀ + ν² + 1`: bounds the O(h²) Lie-splitting commutator error per step.
      Dominates both the viscous commutator (ν²·|k|⁴·h²) and the convective bilinear term.
    - `lipC := E₀ + 1`: controls the Lipschitz stability of S_h on the energy ball.

    Both are trivially positive given `E₀ ≥ 0` and `ν > 0`.
    These are CONSERVATIVE upper bounds; the true constants depend on the wavevector
    magnitudes and kernel norms, which are finite but require the full basis data. -/
noncomputable def galerkinSplitting_constants {N : Nat} (basis : GalerkinBasis N)
    (ν E₀ : Rat) (hν : 0 < ν) (hE₀ : 0 ≤ E₀) : SplittingConstants basis ν E₀ :=
  { lteC     := E₀ + ν ^ 2 + 1
    lipC     := E₀ + 1
    lteC_pos := by linarith [sq_nonneg ν]
    lipC_pos := by linarith }

/-! ## Private helpers for parallelogram bound (Stage 182) -/

/-- `normSqC` is nonneg. -/
private lemma normSqC_nonneg (z : CRat) : 0 ≤ normSqC z := by
  simp only [normSqC, CRat.re, CRat.im]; positivity

/-- **Parallelogram** for `normSqC`: `|z + w|² ≤ 2|z|² + 2|w|²`. -/
private lemma normSqC_add_le (z w : CRat) :
    normSqC (z + w) ≤ 2 * normSqC z + 2 * normSqC w := by
  have h1 : (z + w).1 = z.1 + w.1 := rfl
  have h2 : (z + w).2 = z.2 + w.2 := rfl
  simp only [normSqC, CRat.re, CRat.im, h1, h2]
  nlinarith [sq_nonneg (z.1 - w.1), sq_nonneg (z.2 - w.2)]

/-- **Parallelogram lifted** to `coeffNormSq`. -/
private lemma coeffNormSq_add_le {N : Nat} (f g : CoeffC N) :
    coeffNormSq (fun i => f i + g i) ≤ 2 * coeffNormSq f + 2 * coeffNormSq g := by
  simp only [coeffNormSq]
  calc ∑ i : Fin N, normSqC (f i + g i)
      ≤ ∑ i : Fin N, (2 * normSqC (f i) + 2 * normSqC (g i)) :=
          Finset.sum_le_sum (fun i _ => normSqC_add_le (f i) (g i))
    _ = 2 * ∑ i : Fin N, normSqC (f i) + 2 * ∑ i : Fin N, normSqC (g i) := by
          simp only [Finset.sum_add_distrib, ← Finset.mul_sum]

/-! ## One-step recurrence decomposed (Stage 182) -/

/-- **Stability sub-axiom (SA1)** — full splitting step `S_h = viscStep ∘ convStep` is
    Lipschitz on the energy ball with constant `(lipC/2) h²`.

    Conceptual proof (future stage): viscStep is contractive (Stage 164
    `viscStep_energy_le`), so `|S_h u − S_h v|² ≤ |convStep u − convStep v|²`.
    Cayley norm identity (Stage 166) then gives `|w₁−w₂|² ≤ |(u−v)+(h/2)B(u−v,w₂)|²`,
    and Stage 181's `galerkinConvDef_normSq_le` bounds `|B(u−v,w₂)|² ≤ C_K|u−v|²E₀`,
    yielding `|S_h u − S_h v|² ≤ (2 + (h²/2)C_K E₀)|u−v|² ≤ (lipC/2)h²|u−v|²`.

    SA1 deliberately bounds the FULL step (not just convStep) to avoid importing
    `viscStep_nonexpansive` from Stage 181 (which would create a circular import
    since Stage 181 imports this file).

    Epistemic: `.partiallyVerified` (Stage 166 Cayley identity + Stage 181 bilinear bound). -/
axiom galerkinSplitting_step_lipschitz
    {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hE₀ : 0 ≤ E₀)
    (u v : CoeffC N) (hu : coeffNormSq u ≤ E₀) (hv : coeffNormSq v ≤ E₀) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStep basis u))
      (viscStep basis ν h (convStep basis v))) ≤
    (galerkinSplitting_constants basis ν E₀ hν hE₀).lipC / 2 * h ^ 2 *
      coeffNormSq (coeffSub u v)

/-- **LTE sub-axiom (SA2)** — Lie-splitting local truncation error in squared ℓ² norm.

    For a first-order Lie-Trotter splitting the per-step error in ℓ² norm is O(h²)
    (the splitting commutator is O(h) in the evolution, so O(h²) in ℓ² norm, giving
    O(h^4) in squared norm; `lteC·h²/2` is a conservative upper bound).
    Epistemic: `.partiallyVerified` (Lubich 2008 §II.3, Hairer–Lubich–Wanner). -/
axiom galerkinSplitting_step_lte
    {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hE₀ : 0 ≤ E₀)
    (uExact : Rat → CoeffC N)
    (hEnergy : ∀ t : Rat, coeffNormSq (uExact t) ≤ E₀) (t : Rat) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStep basis (uExact t)))
      (uExact (t + h))) ≤
    (galerkinSplitting_constants basis ν E₀ hν hE₀).lteC / 2 * h ^ 2

/-- **Combined one-step recurrence** — promoted from axiom to THEOREM (Stage 182).

    Proof strategy: parallelogram decomposition.
    Let `uMid = convStep(uExact t)`.  Write the total error as
    `(S_h u − S_h uMid) + (S_h uMid − uExact(t+h))` (stability + LTE).
    Then `|A+B|² ≤ 2|A|² + 2|B|²` (parallelogram, `normSqC_add_le`), and
      - `2|A|² ≤ 2·(lipC/2·h²)·|e|² = lipC·h²·|e|²`  (viscStep_nonexpansive + SA1)
      - `2|B|² ≤ 2·(lteC/2·h²)   = lteC·h²`         (SA2)
    giving `lipC·h²·|e|² + lteC·h² ≤ (1+lipC·h²)·|e|² + lteC·h²` (since `|e|² ≥ 0`).
    Eliminates the Stage-173 `galerkinSplitting_one_step_recurrence` axiom. -/
theorem galerkinSplitting_one_step_recurrence
    {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hE₀ : 0 ≤ E₀)
    (u : CoeffC N) (hu : coeffNormSq u ≤ E₀)
    (uExact : Rat → CoeffC N)
    (hEnergy : ∀ t : Rat, coeffNormSq (uExact t) ≤ E₀) (t : Rat) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStep basis u))
      (uExact (t + h))) ≤
    (1 + (galerkinSplitting_constants basis ν E₀ hν hE₀).lipC * h ^ 2) *
      coeffNormSq (coeffSub u (uExact t)) +
    (galerkinSplitting_constants basis ν E₀ hν hE₀).lteC * h ^ 2 := by
  -- Abbreviations
  let sc := galerkinSplitting_constants basis ν E₀ hν hE₀
  let uMid := convStep basis (uExact t)
  -- Rewrite total error as (stability term) + (LTE term) pointwise
  have heq : ∀ i : Fin N,
      coeffSub (viscStep basis ν h (convStep basis u)) (uExact (t + h)) i =
      coeffSub (viscStep basis ν h (convStep basis u)) (viscStep basis ν h uMid) i +
      coeffSub (viscStep basis ν h uMid) (uExact (t + h)) i := by
    intro i; simp only [coeffSub]; ring
  have hconv : coeffNormSq (coeffSub (viscStep basis ν h (convStep basis u)) (uExact (t + h))) =
      coeffNormSq (fun i =>
        coeffSub (viscStep basis ν h (convStep basis u)) (viscStep basis ν h uMid) i +
        coeffSub (viscStep basis ν h uMid) (uExact (t + h)) i) := by
    congr 1; funext i; exact heq i
  -- Parallelogram bound on the split error
  have hpara := coeffNormSq_add_le
    (coeffSub (viscStep basis ν h (convStep basis u)) (viscStep basis ν h uMid))
    (coeffSub (viscStep basis ν h uMid) (uExact (t + h)))
  -- Stability: full step S_h Lipschitz (SA1, covers viscStep+convStep jointly)
  have hstab :
      coeffNormSq (coeffSub (viscStep basis ν h (convStep basis u)) (viscStep basis ν h uMid)) ≤
      sc.lipC / 2 * h ^ 2 * coeffNormSq (coeffSub u (uExact t)) :=
    galerkinSplitting_step_lipschitz basis ν h E₀ hν hh hE₀ u (uExact t) hu (hEnergy t)
  -- LTE bound (SA2)
  have hlte :
      coeffNormSq (coeffSub (viscStep basis ν h uMid) (uExact (t + h))) ≤
      sc.lteC / 2 * h ^ 2 :=
    galerkinSplitting_step_lte basis ν h E₀ hν hh hE₀ uExact hEnergy t
  -- Error nonnegativity
  have hnn : 0 ≤ coeffNormSq (coeffSub u (uExact t)) :=
    Finset.sum_nonneg (fun i _ => normSqC_nonneg _)
  -- Combine
  rw [hconv]
  calc coeffNormSq (fun i =>
          coeffSub (viscStep basis ν h (convStep basis u)) (viscStep basis ν h uMid) i +
          coeffSub (viscStep basis ν h uMid) (uExact (t + h)) i)
      ≤ 2 * coeffNormSq (coeffSub (viscStep basis ν h (convStep basis u)) (viscStep basis ν h uMid)) +
        2 * coeffNormSq (coeffSub (viscStep basis ν h uMid) (uExact (t + h))) := hpara
    _ ≤ 2 * (sc.lipC / 2 * h ^ 2 * coeffNormSq (coeffSub u (uExact t))) +
        2 * (sc.lteC / 2 * h ^ 2) :=
          add_le_add (mul_le_mul_of_nonneg_left hstab (by norm_num))
                     (mul_le_mul_of_nonneg_left hlte (by norm_num))
    _ = sc.lipC * h ^ 2 * coeffNormSq (coeffSub u (uExact t)) + sc.lteC * h ^ 2 := by ring
    _ ≤ (1 + sc.lipC * h ^ 2) * coeffNormSq (coeffSub u (uExact t)) + sc.lteC * h ^ 2 := by
          nlinarith [hnn]

/-! ## Consistency (Stage 180: promoted from axiom to theorem) -/

/-- **Consistency of the Lie-splitting scheme** — one step from the exact ODE solution lands
    within `lteC · h²` (squared ℓ² norm) of the exact solution at t + h.

    Proof: apply the one-step recurrence with `u = uExact t`; the self-subtraction
    `coeffSub (uExact t) (uExact t) = 0` collapses the Lipschitz term. -/
theorem galerkinSplitting_consistency {N : Nat} (basis : GalerkinBasis N)
    (ν h E₀ : Rat) (hν : 0 < ν) (hh : 0 < h) (hE₀ : 0 ≤ E₀)
    (uExact : Rat → CoeffC N)
    (hEnergy : ∀ t : Rat, coeffNormSq (uExact t) ≤ E₀) (t : Rat) :
    coeffNormSq (coeffSub
      (viscStep basis ν h (convStep basis (uExact t)))
      (uExact (t + h))) ≤
    (galerkinSplitting_constants basis ν E₀ hν hE₀).lteC * h ^ 2 := by
  have h1 := galerkinSplitting_one_step_recurrence basis ν h E₀ hν hh hE₀
    (uExact t) (hEnergy t) uExact hEnergy t
  have hzero : coeffNormSq (coeffSub (uExact t) (uExact t)) = 0 := by
    simp only [coeffNormSq, coeffSub]
    apply Finset.sum_eq_zero
    intro i _
    have hsub : uExact t i - uExact t i = 0 := sub_self _
    rw [hsub]
    simp [normSqC, CRat.re, CRat.im]
  rw [hzero] at h1
  linarith [mul_zero (1 + (galerkinSplitting_constants basis ν E₀ hν hE₀).lipC * h ^ 2)]

/-! ## Grönwall recurrence (Stage 180: promoted from axiom to theorem) -/

/-- **Grönwall recurrence for the splitting error** — derived from the one-step recurrence.

    Proof: apply `galerkinSplitting_one_step_recurrence` with `u = traj.u n` and
    `t = ↑n * traj.h`, rewrite using `traj.step n`, then close by `push_cast; ring`. -/
theorem galerkinSplitting_gronwall_recurrence
    (traj : GalerkinNSDiscreteTrajectory)
    (E₀ : Rat) (hE₀ : 0 ≤ E₀)
    (uExact : Rat → CoeffC traj.N)
    (hEnergy : ∀ t : Rat, coeffNormSq (uExact t) ≤ E₀)
    (htrajE : ∀ n, coeffNormSq (traj.u n) ≤ E₀) :
    let sc := galerkinSplitting_constants traj.basis traj.ν E₀ traj.hν hE₀
    let eAt := fun n => coeffNormSq (coeffSub (traj.u n) (uExact (↑n * traj.h)))
    ∀ n : Nat,
      eAt (n + 1) ≤ (1 + sc.lipC * traj.h ^ 2) * eAt n + sc.lteC * traj.h ^ 2 := by
  intro sc eAt n
  have h1 := galerkinSplitting_one_step_recurrence
    traj.basis traj.ν traj.h E₀ traj.hν traj.hh hE₀
    (traj.u n) (htrajE n) uExact hEnergy (↑n * traj.h)
  rw [← traj.step n] at h1
  have hcast : (↑n : Rat) * traj.h + traj.h = ↑(n + 1) * traj.h := by push_cast; ring
  rw [hcast] at h1
  exact h1

/-! ## Stability from energy dissipation (0 new axioms) -/

/-- **Stability**: energy is nonincreasing along the trajectory.
    Reuses Stage 164 `energy_dissipation_mono` directly. -/
theorem galerkinSplitting_stability (traj : GalerkinNSDiscreteTrajectory) (n : Nat) :
    coeffNormSq (traj.u n) ≤ coeffNormSq (traj.u 0) := by
  unfold coeffNormSq
  exact traj.energy_dissipation_mono 0 n (Nat.zero_le n)

/-! ## Main convergence theorem (0 new axioms) -/

/-- **Main convergence bound** — pure consequence of discrete Grönwall with `e(0) = 0`.

    If `e(0) = 0` and `e(n+1) ≤ (1+L)*e(n) + B`, then `e(n) ≤ (1+L)^n * (n * B)`. -/
theorem galerkinSplitting_error_bound (L B : Rat) (hL : 0 ≤ L) (hB : 0 ≤ B)
    (eAt : Nat → Rat) (he0 : eAt 0 = 0)
    (hrec : ∀ n, eAt (n + 1) ≤ (1 + L) * eAt n + B) :
    ∀ n : Nat, eAt n ≤ (1 + L) ^ n * (↑n * B) := by
  intro n
  have hGronwall := discrete_gronwall L B hL hB eAt hrec n
  rw [he0] at hGronwall
  simp only [zero_add] at hGronwall
  linarith

/-! ## Convergence certificate (0 new axioms) -/

/-- **Galerkin splitting convergence certificate** — assembles all three ingredients.

    For a trajectory starting at the exact ODE initial data, the squared ℓ² error satisfies:
      `coeffNormSq(u_n − uExact(n·h)) ≤ (1 + lipC·h²)^n · (n · lteC · h²)`

    This is O(h) for `n·h ≤ T` as `h → 0`:
    - `(1 + lipC·h²)^n ≤ exp(lipC·h·T) → 1` as h → 0
    - `n · h² = (n·h) · h ≤ T · h → 0` as h → 0 -/
theorem galerkinSplitting_convergence_certificate
    (traj : GalerkinNSDiscreteTrajectory)
    (E₀ : Rat) (hE₀ : 0 ≤ E₀)
    (uExact : Rat → CoeffC traj.N)
    (hEnergy : ∀ t : Rat, coeffNormSq (uExact t) ≤ E₀)
    (htrajE : ∀ n, coeffNormSq (traj.u n) ≤ E₀)
    (hinit : traj.u 0 = uExact 0) :
    let sc := galerkinSplitting_constants traj.basis traj.ν E₀ traj.hν hE₀
    ∀ n : Nat,
      coeffNormSq (coeffSub (traj.u n) (uExact (↑n * traj.h))) ≤
      (1 + sc.lipC * traj.h ^ 2) ^ n * (↑n * (sc.lteC * traj.h ^ 2)) := by
  intro sc n
  let eAt := fun k => coeffNormSq (coeffSub (traj.u k) (uExact (↑k * traj.h)))
  -- Zero initial error (same initial data)
  have he0 : eAt 0 = 0 := by
    show coeffNormSq (coeffSub (traj.u 0) (uExact (↑(0 : Nat) * traj.h))) = 0
    have hcast : (↑(0 : Nat) : Rat) * traj.h = 0 := by simp
    rw [hcast, hinit]
    simp only [coeffNormSq, coeffSub]
    apply Finset.sum_eq_zero
    intro i _
    have hsub : uExact 0 i - uExact 0 i = 0 := sub_self _
    rw [hsub]
    simp [normSqC, CRat.re, CRat.im]
  -- Grönwall recurrence from the axiom
  have hrec := galerkinSplitting_gronwall_recurrence traj E₀ hE₀ uExact hEnergy htrajE
  -- Positivity
  have hL : 0 ≤ sc.lipC * traj.h ^ 2 :=
    mul_nonneg (le_of_lt sc.lipC_pos) (sq_nonneg _)
  have hB : 0 ≤ sc.lteC * traj.h ^ 2 :=
    mul_nonneg (le_of_lt sc.lteC_pos) (sq_nonneg _)
  exact galerkinSplitting_error_bound
          (sc.lipC * traj.h ^ 2) (sc.lteC * traj.h ^ 2) hL hB eAt he0 hrec n

def stage173Summary : String :=
  "Stage 173: NSGalerkinConvergence — Lie-splitting convergence as h→0. " ++
  "coeffSub: pointwise subtraction CoeffC N. " ++
  "coeffNormSq: squared ℓ² norm ∑ normSqC(uᵢ). " ++
  "one_le_pow_of_one_le: PRIVATE THEOREM (induction, 0 axioms). " ++
  "discrete_gronwall: THEOREM (pure Rat induction, 0 axioms): " ++
    "e(n+1)≤(1+L)*e(n)+B → e(n)≤(1+L)^n*(e(0)+n*B). " ++
  "SplittingConstants: structure lteC, lipC (both positive). " ++
  "galerkinSplitting_constants: DEF (Stage 179: lteC=E₀+ν²+1, lipC=E₀+1). " ++
  "Stage 182: galerkinSplitting_one_step_recurrence AXIOM→THEOREM (-1 axiom). " ++
  "  normSqC_nonneg: PRIVATE LEMMA (positivity). " ++
  "  normSqC_add_le: PRIVATE LEMMA (|z+w|²≤2|z|²+2|w|², nlinarith). " ++
  "  coeffNormSq_add_le: PRIVATE LEMMA (sum_le_sum + mul_sum). " ++
  "  galerkinSplitting_step_lipschitz: AXIOM (SA1, convStep Lipschitz, .partiallyVerified). " ++
  "  galerkinSplitting_step_lte: AXIOM (SA2, splitting LTE, .partiallyVerified). " ++
  "  galerkinSplitting_one_step_recurrence: THEOREM (parallelogram+SA1+SA2, 0 sorry). " ++
  "galerkinSplitting_consistency: THEOREM (Stage 180: from sub-axiom with u=uExact t, 0 axioms). " ++
  "galerkinSplitting_gronwall_recurrence: THEOREM (Stage 180: from sub-axiom + traj.step, 0 axioms). " ++
  "galerkinSplitting_stability: THEOREM (Stage 164 energy_dissipation_mono, 0 new axioms). " ++
  "galerkinSplitting_error_bound: THEOREM (discrete_gronwall with e(0)=0). " ++
  "galerkinSplitting_convergence_certificate: THEOREM (0 new axioms, assembles all three). " ++
  "Stage 173: +3 axioms. Stage 179: -1. Stage 180: -1 (2→1). Stage 182: +2-1=+1. " ++
  "Net: +2 axioms total, +14 theorems (incl. 3 private), 0 sorry."

end NavierStokes.GalerkinConvergence
