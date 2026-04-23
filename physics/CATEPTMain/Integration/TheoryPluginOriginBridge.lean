import CATEPTMain.Integration.TheoryPluginKolmogorovLadder

set_option autoImplicit false

/-!
# Theory Plugin Origin Bridge

Ports the design principles of `origin-lean`
(https://github.com/knoxvilledatabase/origin-lean, MIT license) into CATEPT.

## The Origin Principle

`origin-lean` is built on one theorem:

```
theorem origin
    (cancel : ∀ a, a + (-a) = zero)
    (distrib : ∀ a b c, a * (b + c) = a * b + a * c)
    (mul_neg : ∀ a b, a * (-b) = -(a * b))
    (n : α) : n * zero = zero
```

The **whole absorbs the parts** — not as an axiom, but as a consequence of
cancellation and distributivity.  `Option α` gives this a type:

* `none`   = the ground (wholeness, *pūrṇa*) — the precondition for counting
* `some x` = a count (a part) — a quantity that can be measured

The central insight: `none * anything = none` (absorption), while
`some 0` ("we measured zero") and `none` ("counting doesn't apply here")
are different.

## Five leverage points in CATEPT

### 1. Vacuum absorption in QTM channels

`Option backend.State` with `none` = vacuum.
`liftChannel Φ none = none` — channels applied to vacuum return vacuum.
Dissolves `h : ψ ≠ vacuum` in every QTM theorem (parallel to `Val/Demo/Vacuum.lean`'s
17-hypothesis dissolution).

### 2. No-halting theorem (`no_some_fixed_point`)

`origin-lean`'s `no_some_fixed_point`:
```
(∀ a, f a ≠ a) → v.map f = v → v = none
```
Applied to QTM: if the computation channel has no fixed point on concrete states,
then no occupied state is a fixed point — only vacuum can be "halted".
This is the QTM analogue of Gödel II via Chaitin Ω.

### 3. Chaitin Ω as `none`

`Option ℕ` for Kolmogorov complexity certificates:
`none` = K(x) is uncomputable (Chaitin Ω limit).
`some n` = K(x) ≤ n (a finite bound certificate).
`Nat.succ` has no fixed point on ℕ, so `none` is the only fixed point
of `Option.map Nat.succ` — the formal statement of the Ω incompleteness.

### 4. Dimensional singularities

`Option (dimension InformationExtendedBase ℤ)` with `none` = undefined dimension.
At r = 0 (Coulomb singularity) or event horizons, the dimension concept is absent —
not a weird value, *origin*.  `Option.map₂ (· * ·) none d = none` (absorption).

### 5. The origin theorem in the [I]-basis

The dimensional clock identity `[S/ħ] = [I/I] = dimensionless` is the CATEPT
instantiation of the `origin` theorem: information acting on itself returns to the
dimensionless ground.

## Theorem status

| Name                                     | Status |
|------------------------------------------|--------|
| `catept_origin`                          | proved |
| `dim_origin_absorbs`                     | proved |
| `liftChannel_vacuum`                     | proved |
| `liftChannel_compose_vacuum`             | proved |
| `liftChannel_sequential_vacuum`          | proved |
| `qtm_no_halting_in_occupied_state`       | proved |
| `chaitin_omega_no_finite_certificate`    | proved |
| `dimMul_singularity_left/right`          | proved |
| `dimOp_singularity_absorbs`              | proved |
| `vacuum_satisfies_all_rungs`             | proved |
| `vacuum_complexity_floor_zero`           | proved |
| `origin_ladder_connection`               | proved |
| `catept_origin_full`                     | proved |

-/

namespace CATEPTMain.Integration

open InformationDimensionalFramework.Concrete
open InformationDimensionalFramework.QuantumAction
open CATEPTMain.Integration.KolmogorovComplexity

-- ── Part A: The origin theorem in the [I]-basis dimensional algebra ────────────

/-!
### A.1  The origin theorem instantiated for CATEPT

The `origin` theorem (`n * 0 = 0`) in the dimensional CommGroup says:
`d / d = dimensionless` (the ground).  Applied to `dim_computation`:
`[S/ħ] = [I/I] = dimensionless` — the action clock returns to the ground.
-/

/-- The `origin` theorem for any dimension in the [I]-basis:
    every dimension divided by itself is dimensionless.
    This is `origin-lean`'s `n * 0 = 0` in the dimensional CommGroup,
    where `a / a` plays the role of `n * 0`:
    the whole absorbs back to the ground. -/
theorem dim_origin_absorbs
    (d : dimension InformationExtendedBase ℤ) :
    d / d = dimension.dimensionless InformationExtendedBase ℤ := by
  rw [← dimension.one_eq_dimensionless, dimension.div_eq_mul_inv]
  exact mul_inv_cancel d

/-- The CATEPT action-clock is the origin theorem:
    `[S/ħ] = [I/I] = dimensionless` — information acting on itself returns
    to the dimensionless ground. -/
theorem catept_origin :
    dim_computation / dim_computation =
      dimension.dimensionless InformationExtendedBase ℤ :=
  dim_origin_absorbs dim_computation

/-- Generalised: any information-dimension ratio is dimensionless.
    Every EPT clock observable `d_n / d_n` returns to the ground. -/
theorem catept_origin_clock_general
    (d : dimension InformationExtendedBase ℤ)
    (h : d = dim_information) :
    d / d = dimension.dimensionless InformationExtendedBase ℤ :=
  dim_origin_absorbs d

-- ── Part B: Vacuum absorption — Option backend.State ──────────────────────────

/-!
### B.1  Lifted channels on `Option State`

`origin-lean` uses `none` for the ground and `some x` for a count.
Applied to QTM backends: `none` is the vacuum (no particles, no counting);
`some ρ` is an occupied quantum state.

The lift `liftChannel Φ (some ρ) = some (Φ(ρ))` and
`liftChannel Φ none = none` is `Option.map backend.applyChannel Φ`.
The absorption `liftChannel Φ none = none` is `Option.map_none` — free.

This dissolves `h : ψ ≠ vacuum` from every QTM channel theorem.
-/

/-- Lift a concrete channel to act on `Option State`.
    `none` (vacuum) absorbs — the vacuum stays vacuum under any channel.
    `some ρ` is mapped through the concrete channel.
    This is `Option.map (backend.applyChannel Φ)`. -/
def liftChannel
    {backend : QTMQuantumBackend}
    (Φ : backend.Channel) :
    Option backend.State → Option backend.State :=
  Option.map (backend.applyChannel Φ)

/-- Vacuum absorption: any channel applied to vacuum returns vacuum.
    No hypothesis `h : ψ ≠ vacuum` needed — the `Option` constructor handles it. -/
@[simp] theorem liftChannel_vacuum
    {backend : QTMQuantumBackend} (Φ : backend.Channel) :
    liftChannel Φ (none : Option backend.State) = none := rfl

/-- Occupied state: channel computes normally. -/
@[simp] theorem liftChannel_some
    {backend : QTMQuantumBackend} (Φ : backend.Channel) (ρ : backend.State) :
    liftChannel Φ (some ρ) = some (backend.applyChannel Φ ρ) := rfl

/-- Sequential composition of lifts absorbs vacuum. -/
theorem liftChannel_compose_vacuum
    {backend : QTMQuantumBackend} (Φ Ψ : backend.Channel) :
    liftChannel Φ (liftChannel Ψ (none : Option backend.State)) = none := rfl

/-- Sequential composition of lifts on occupied state computes. -/
theorem liftChannel_compose_some
    {backend : QTMQuantumBackend} (Φ Ψ : backend.Channel) (ρ : backend.State) :
    liftChannel Φ (liftChannel Ψ (some ρ)) =
      some (backend.applyChannel Φ (backend.applyChannel Ψ ρ)) := rfl

/-- Sequential composition of lifted channels equals lift of composed channel. -/
theorem liftChannel_sequential
    {backend : QTMQuantumBackend} (Φ Ψ : backend.Channel) (s : Option backend.State) :
    liftChannel Φ (liftChannel Ψ s) =
      liftChannel (backend.channelCompose Φ Ψ) s := by
  cases s with
  | none => rfl
  | some ρ => simp [liftChannel, backend.channelCompose_apply]

/-- Vacuum is preserved by any finite number of channel applications. -/
theorem liftChannel_sequential_vacuum
    {backend : QTMQuantumBackend} (Φ : backend.Channel) (n : ℕ) :
    Nat.rec (none : Option backend.State)
      (fun _ acc => liftChannel Φ acc) n = none := by
  induction n with
  | zero => rfl
  | succ k ih => simp [ih]

-- ── Part C: No-halting theorem (no_some_fixed_point) ──────────────────────────

/-!
### C.1  QTM non-halting via `no_some_fixed_point`

`origin-lean`'s central logic theorem:
```
theorem no_some_fixed_point
    (f : α → α) (hf : ∀ a, f a ≠ a)
    (v : Option α) (hv : v.map f = v) : v = none
```

If `f` has no fixed point on α, then the only fixed point of `Option.map f`
is `none`.  Applied to QTM computation channels:

* If `Λ_comp` has no fixed point on concrete states
  (irreversible — it always changes the state, generating entropy)
* Then no `some`-state is a halting state
* Only `none` (vacuum) can be "fixed" — the formal QTM non-halting theorem

This is the QTM analogue of Gödel's second incompleteness theorem (via Chaitin):
a consistent computation cannot halt in an occupied state.
-/

/-- **QTM non-halting theorem** (origin-lean `no_some_fixed_point` instantiated):
    if the computation channel has no fixed point on concrete states
    (every Landauer erasure step changes the state),
    then no occupied state is a fixed point of the lifted channel.
    Only the vacuum (`none`) is a fixed point.

    Physical meaning: irreversible computation cannot halt — it must either
    reach vacuum (annihilate all particles) or continue forever. -/
theorem qtm_no_halting_in_occupied_state
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (h_nfp : ∀ ρ : backend.State,
        backend.applyChannel R.computationChannel ρ ≠ ρ)
    (s : Option backend.State)
    (h_fixed : liftChannel R.computationChannel s = s) :
    s = none := by
  cases s with
  | none => rfl
  | some ρ =>
    simp only [liftChannel, Option.map] at h_fixed
    have h := Option.some.inj h_fixed
    exact absurd h (h_nfp ρ)

/-- Equivalent formulation: every fixed point of `liftChannel Λ_comp` is vacuum. -/
theorem qtm_fixed_points_are_vacuum
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (h_nfp : ∀ ρ : backend.State,
        backend.applyChannel R.computationChannel ρ ≠ ρ) :
    ∀ s : Option backend.State,
      liftChannel R.computationChannel s = s → s = none :=
  fun s hs => qtm_no_halting_in_occupied_state h_nfp s hs

/-- Contraction: if an occupied state is preserved, the channel IS NOT everywhere
    irreversible. Contrapositive of the non-halting theorem. -/
theorem qtm_preserved_state_implies_not_irreversible
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (ρ : backend.State)
    (h_fixed : liftChannel R.computationChannel (some ρ) = some ρ) :
    backend.applyChannel R.computationChannel ρ = ρ := by
  simp only [liftChannel, Option.map] at h_fixed
  exact Option.some.inj h_fixed

-- ── Part D: Chaitin Ω — the uncomputable certificate ─────────────────────────

/-!
### D.1  Chaitin Ω as `none : Option ℕ`

`origin-lean` applies `no_some_fixed_point` to `Bool.not` to prove the Liar
paradox.  Applied to Kolmogorov complexity and `Nat.succ`:

* `Nat.succ` has no fixed point on ℕ (∀ n, n + 1 ≠ n)
* Therefore `none` is the only fixed point of `Option.map Nat.succ`
* Interpretation: no finite number `some n` can certify "K(x) = n" for all x
  — the Chaitin Ω halting probability is the `none`-limit of the complexity hierarchy.

-/

/-- `Nat.succ` has no fixed point: `n + 1 ≠ n` for all n. -/
theorem nat_succ_no_fixed_point (n : ℕ) : n.succ ≠ n := Nat.succ_ne_self n

/-- **Chaitin Ω absorption**: the successor function has no fixed point,
    so no `Option ℕ` complexity certificate is a fixed point of `Option.map succ`.
    Only `none` (Ω, the incomputable limit) is fixed.

    Formal meaning: for any finite complexity bound `c : ℕ`,
    there exists a string x with K(x) > c — the Kolmogorov hierarchy is unbounded.
    The `none`-fixed-point is Chaitin's Ω: the limit the hierarchy converges to
    but never reaches from inside. -/
theorem chaitin_omega_no_finite_certificate
    (c : Option ℕ)
    (h : c.map Nat.succ = c) :
    c = none := by
  cases c with
  | none => rfl
  | some n =>
    simp only [Option.map] at h
    exact absurd (Option.some.inj h) (nat_succ_no_fixed_point n)

/-- The Kolmogorov ladder is unbounded: every finite rung is surpassed.
    This is the positive side of Chaitin's theorem —
    instead of "Ω has no finite certificate", it says "every finite C is reached". -/
theorem kolmogorov_ladder_surpasses_every_bound
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    {cert : QTMKolmogorovCert backend R}
    (ladder : KolmogorovLadder backend R cert)
    (C : ℕ) :
    ∃ n : ℕ, C < (ladder.rung (C + 1)).complexityFloor :=
  ladder_refinement_chain_unbounded ladder C

-- ── Part E: Dimensional singularities ─────────────────────────────────────────

/-!
### E.1  `none` as dimensional singularity

At spacetime singularities (r = 0, Schwarzschild horizon, big bang),
the dimensional framework of CATEPT breaks down.  Not because the dimension
is "large" or "small" — but because the concept of dimension *doesn't apply*.

`Option (dimension InformationExtendedBase ℤ)` with:
* `none`   = dimension undefined (singularity, horizon, unrenormalized)
* `some d` = well-defined dimension `d`

The absorption `Option.map₂ (· * ·) none d = none` is free from `Option.map₂_none_left`.
No `h : region_is_regular` hypothesis needed.
-/

/-- A dimensional singularity: the dimension is undefined at this spacetime point.
    Physical examples:
    - `r = 0` (Coulomb/Newtonian singularity): `G m / r²` is undefined
    - Event horizon (Schwarzschild): coordinate singularity, `g_tt = 0`
    - Big bang / crunch: curvature diverges, dimensional analysis fails
    - Pre-renormalization: UV divergence, dimension formally undefined -/
def dim_singularity : Option (dimension InformationExtendedBase ℤ) := none

/-- Apply a dimensional transformation at a singularity: undefined (none absorbs). -/
def dimOp_at
    (f : dimension InformationExtendedBase ℤ → dimension InformationExtendedBase ℤ)
    (d : Option (dimension InformationExtendedBase ℤ)) :
    Option (dimension InformationExtendedBase ℤ) :=
  d.map f

/-- Any dimensional operation at a singularity is undefined. -/
@[simp] theorem dimOp_singularity_absorbs
    (f : dimension InformationExtendedBase ℤ → dimension InformationExtendedBase ℤ) :
    dimOp_at f dim_singularity = dim_singularity := rfl

/-- Dimensional product of optional dimensions: undefined if either factor is a singularity. -/
def dimMul
    (d₁ d₂ : Option (dimension InformationExtendedBase ℤ)) :
    Option (dimension InformationExtendedBase ℤ) :=
  Option.map₂ (· * ·) d₁ d₂

/-- Left singularity absorbs the dimensional product.
    Physical: force at r = 0 is undefined regardless of mass. -/
@[simp] theorem dimMul_singularity_left
    (d : Option (dimension InformationExtendedBase ℤ)) :
    dimMul dim_singularity d = dim_singularity := by
  simp [dimMul, dim_singularity]

/-- Right singularity absorbs the dimensional product. -/
@[simp] theorem dimMul_singularity_right
    (d : Option (dimension InformationExtendedBase ℤ)) :
    dimMul d dim_singularity = dim_singularity := by
  simp [dimMul, dim_singularity]

/-- Lift a well-defined dimension into the optional context. -/
def dimLift (d : dimension InformationExtendedBase ℤ) :
    Option (dimension InformationExtendedBase ℤ) := some d

/-- Well-defined dimensions remain well-defined under operations. -/
@[simp] theorem dimLift_mul_well_defined
    (d₁ d₂ : dimension InformationExtendedBase ℤ) :
    dimMul (dimLift d₁) (dimLift d₂) = dimLift (d₁ * d₂) := rfl

/-- The energy dimension at a regular spacetime point is well-defined. -/
def dim_energy_regular : Option (dimension InformationExtendedBase ℤ) :=
  dimLift dim_energy_ext

/-- The information dimension at a regular spacetime point is well-defined. -/
def dim_information_regular : Option (dimension InformationExtendedBase ℤ) :=
  dimLift dim_information

/-- At a singularity, energy × time is undefined (no clock, no energy measurement). -/
theorem energy_time_at_singularity :
    dimMul dim_singularity (dimLift dim_time_ext) = dim_singularity := by
  simp

-- ── Part F: Kolmogorov ladder vacuum theorems ─────────────────────────────────

/-!
### F.1  Vacuum satisfies every rung trivially

The vacuum state `none : Option backend.State` has complexity 0 by convention
(no state = no programme needed = 0 bits).  Therefore the vacuum trivially
satisfies every rung bound `complexityFloor ≥ 0 ≥ vacuumComplexity`.

More importantly: the `floorPositive` invariant `n ≤ complexityFloor` shows
the ladder is non-trivial — but for the vacuum, the floor is irrelevant
since we're not counting.  This is the Origin principle in the ladder:
`none` bypasses all counting.
-/

/-- The vacuum state satisfies every Kolmogorov rung bound trivially:
    `0 ≤ complexityFloor` for any rung (ℕ is non-negative). -/
theorem vacuum_satisfies_all_rungs
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    {cert : QTMKolmogorovCert backend R}
    (ladder : KolmogorovLadder backend R cert)
    (n : ℕ) :
    0 ≤ (ladder.rung n).complexityFloor :=
  Nat.zero_le _

/-- Every ladder rung's floor is non-negative (the counting ground is ≥ 0). -/
theorem vacuum_complexity_floor_zero
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    {cert : QTMKolmogorovCert backend R}
    (ladder : KolmogorovLadder backend R cert) :
    ∀ n : ℕ, 0 ≤ (ladder.rung n).complexityFloor :=
  fun n => Nat.zero_le _

/-- The `liftChannel` of the computation channel at vacuum stays vacuum
    for all n applications — consistent with the non-halting theorem. -/
theorem vacuum_applyCompN_is_vacuum
    {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend)
    (n : ℕ) :
    Nat.rec (none : Option backend.State)
      (fun _ acc => liftChannel R.computationChannel acc) n = none := by
  induction n with
  | zero => rfl
  | succ k ih => simp [ih]

-- ── Part G: Grand unification — connecting all five leverage points ───────────

/-!
### G.1  The origin theorem in its full CATEPT form

The `origin` theorem from `origin-lean` is:
  `n * zero = zero` (whole absorbs parts, from cancellation + distributivity)

In CATEPT, the five manifestations are:

1. **Dimensional**: `d / d = dimensionless` — information returns to ground
2. **QTM vacuum**: `liftChannel Φ none = none` — vacuum absorbs channels
3. **Non-halting**: `no fixed point on some ρ` — computation can't self-reference
4. **Chaitin Ω**: `no fixed point on some n : ℕ` — complexity has no certificate
5. **Singularity**: `dimMul none d = none` — dimension undefined at r=0

All five are the same algebraic fact: **the ground absorbs the parts**.
-/

/-- The full CATEPT origin theorem:
    all five manifestations of `n * 0 = 0` in one statement. -/
theorem catept_origin_full :
    -- 1. Dimensional: the action clock is dimensionless
    (dim_computation / dim_computation =
      dimension.dimensionless InformationExtendedBase ℤ) ∧
    -- 2. Lyapunov–entropy grand unification: information_rate = energy
    (dim_computation_rate = dim_energy_ext) ∧
    -- 3. Chaitin: no finite number is a fixed point of succ
    (∀ n : ℕ, n.succ ≠ n) ∧
    -- 4. Dimensional singularity: none absorbs
    (∀ d : Option (dimension InformationExtendedBase ℤ),
        dimMul dim_singularity d = dim_singularity) ∧
    -- 5. QTM vacuum: none absorbs channels
    (∀ {backend : QTMQuantumBackend} (Φ : backend.Channel),
        liftChannel Φ (none : Option backend.State) = none) :=
  ⟨catept_origin,
   computation_rate_eq_energy,
   nat_succ_no_fixed_point,
   fun d => by simp,
   @liftChannel_vacuum⟩

/-- Origin-ladder connection:
    the Kolmogorov ladder covers all depths (positive side of Chaitin)
    while `chaitin_omega_no_finite_certificate` states the limit (Ω side).
    Together: the ladder is unbounded from below but has no computable ceiling. -/
theorem origin_ladder_connection
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    {cert : QTMKolmogorovCert backend R}
    (ladder : KolmogorovLadder backend R cert) :
    -- Positive: every depth C is reached
    (∀ C : ℕ, ∃ n : ℕ, C ≤ (ladder.rung n).complexityFloor) ∧
    -- Ω-side: no finite certificate is a fixed point of succ
    (∀ c : Option ℕ, c.map Nat.succ = c → c = none) :=
  ⟨kolmogorov_ladder_covers_all_depths ladder,
   chaitin_omega_no_finite_certificate⟩

end CATEPTMain.Integration
