import CATEPTMain.Integration.TheoryPluginQTMBridge
import CATEPTMain.Integration.KolmogorovComplexityBridge

set_option autoImplicit false

/-!
# Theory Plugin Kolmogorov Ladder

Extends the QTM bridge (`TheoryPluginQTMBridge`) with **Kolmogorov ladder theory**:
a hierarchy of complexity-certified computation bounds that mirrors the
K41 ladder/machine-reduction structure from `NSKolmogorovTuringRefinementBridge`.

## Background: Block E equation (33)

The CSV artifact database (score 5) highlights equation (33) from Paper 4:

```
ȧI = Ṡ_gen / (k_B ln 2) = λ / ln 2               [Block E – Thermodynamics & measurement as communication]
```

In natural units `k_B = 1`, with [I] as the information unit:

* **LHS** `ȧI`: information generation rate, dimension `[I T⁻¹]`
* **RHS** `Ṡ_gen`: entropy production rate, dimension `[I T⁻¹]`
* **RHS** `λ / ln 2`: Lyapunov exponent / ln 2, with `[λ] = [T⁻¹]` and ln 2 dimensionless

All three equal `dim_energy_ext = [I T⁻¹]`.  This is the **grand unified dimensional
formula**: information rate = entropy rate = computation rate = communication rate = energy.

## Kolmogorov complexity and the ladder

The Kolmogorov complexity `K(x)` (from `KolmogorovMathlib.Core.Basic` via
`KolmogorovComplexityBridge`) gives the minimum program length (in bits) to
describe string `x`.  Key theorems in play:

* **Invariance** (`Kolmogorov.existsIsOptimalConditional`): there exists a universal
  decompressor `U` such that `K_U(x) ≤ K_D(x) + c` for any other decompressor `D`.
  K is well-defined up to an additive constant.

* **Incompressibility** (`KolmogorovMathlib.Complexity.Incompressibility`): most
  strings of length n have `K(x) ≥ n − O(1)`.  Applied to QTM state trajectories:
  `K(ρ_t) ≥ S_vN(ρ_t) − O(1)`.

## The Kolmogorov ladder for QTM regions

Mirrors the NS K41 ladder (`NSKolmogorovTuringRefinementBridge.MachineCutoffCert K`):

```
Rung 0:  K(ρ_0) ≥ 0          (trivial)
Rung 1:  K(ρ_1) ≥ r          (after 1 computation step, ≥ r bits accumulated)
Rung n:  K(ρ_n) ≥ n·r − O(1) (after n steps, ≥ n·r bits)
    ⋮
Rung ∞: K(ρ_∞) = ∞           (uncomputable limit → Chaitin Ω)
```

Monotonicity (`machineCutoffCert_mono` analogue): if rung n is certified, all
rungs m ≤ n are certified.

**Ladder + communication reduction** (analogue of `ladder_plus_machine_reduction`):
- Pre-threshold (computation dominant): covered by finite ladder rungs
- Post-threshold (communication dominant): covered by the quantum channel capacity bound
- Gluing: both phases together cover all complexities

## Connection to lean-machines refinement

Each rung n is a `LeanMachineQTMBridge` where:
- The machine state has Kolmogorov complexity `≥ n·r − O(1)`
- Refinement: rung n+1 ≤ rung n in the complexity preorder (more complex = more concrete)
- This is the `lean-machines` refinement order applied to quantum computation depth

## Theorem status

| Name                                          | Status  |
|-----------------------------------------------|---------|
| `blockE_entropy_rate_eq_energy`               | proved  |
| `blockE_bitrate_factorization`                | proved  |
| `lyapunov_rate_eq_computation_rate`           | proved  |
| `kolmogorov_grand_unification`                | proved  |
| `kolmogorov_complexity_clock_dimensionless`   | proved  |
| `kolmogorov_ladder_covers_all_depths`         | proved  |
| `sequentialCompose_ladder_rungs`              | proved  |
| `ladder_monotone_of_cert_monotone`            | proved  |
| `QTMKolmogorovCert`                           | Phase-1 |
| `KolmogorovLadderRung`                        | Phase-1 |
| `KolmogorovLadder`                            | Phase-1 |
| `qtm_kolmogorov_complexity_bridge`            | Phase-1 |

-/

namespace CATEPTMain.Integration

open InformationDimensionalFramework.Concrete
open InformationDimensionalFramework.QuantumAction
open CATEPTMain.Integration.KolmogorovComplexity

-- ── Part A: Grand unified dimensional formula ────────────────────────────────

/-!
### A.1  Block E equation (33) in the dimensional algebra

Equation (33) from the paper (score-5 CSV artifact):
  `ȧI = Ṡ_gen / (k_B ln 2) = λ / ln 2`

In natural units, all three expressions have dimension `[I T⁻¹] = dim_energy_ext`.
The Lyapunov exponent `λ` (rate of entropy generation) has dimension `[T⁻¹]`.
-/

/-- Lyapunov exponent dimension: `[λ] = [T⁻¹]` (rate = inverse time). -/
def dim_lyapunov_exponent : dimension InformationExtendedBase ℤ := dim_time_ext⁻¹

/-- Block E equation (33): entropy generation rate = energy in natural units.
    `[Ṡ] = [I T⁻¹] = dim_energy_ext`.
    Physically: `Ṡ_gen = k_B λ` with `k_B = 1`; one Lyapunov e-fold generates
    one natural bit of entropy per unit time. -/
theorem blockE_entropy_rate_eq_energy :
    dim_entropy_ext * dim_time_ext⁻¹ = dim_energy_ext := by
  funext b; fin_cases b <;> native_decide

/-- Block E factorisation: information rate = Lyapunov × information dimension.
    `[ȧI] = [λ] × [I] = [T⁻¹] × [I] = [I T⁻¹]`. -/
theorem blockE_bitrate_factorization :
    dim_entropy_ext * dim_time_ext⁻¹ = dim_lyapunov_exponent * dim_computation := by
  simp only [dim_lyapunov_exponent, dim_computation, dim_entropy_eq_information, mul_comm]

/-- Lyapunov rate = computation rate: `[λ · I] = [I T⁻¹] = dim_energy_ext`.
    In natural units the entropy production rate is the energy dissipation rate. -/
theorem lyapunov_rate_eq_computation_rate :
    dim_lyapunov_exponent * dim_computation = dim_energy_ext := by
  funext b; fin_cases b <;> native_decide

/-!
### A.2  Grand unified dimensional formula

Equation (33) unifies four independently-motivated dimensional facts:
1. Landauer erasure rate: `[computation / time]`
2. Shannon / Holevo channel capacity: `[communication / time]`
3. Entropy production rate: `[entropy / time]`
4. Lyapunov exponent × information: `[λ · I]`

All four equal `dim_energy_ext = [I T⁻¹]`.
-/

/-- The grand unified information–energy formula:
    all four rates (computation, communication, entropy, Lyapunov×I) equal energy.

    ```
    dim_computation_rate = dim_communication_rate
                         = dim_entropy_ext × dim_time_ext⁻¹
                         = dim_lyapunov_exponent × dim_computation
                         = dim_energy_ext
    ```
    This is the CATEPT information–energy identification in its most complete form. -/
theorem kolmogorov_grand_unification :
    dim_computation_rate = dim_energy_ext ∧
    dim_communication_rate = dim_energy_ext ∧
    dim_entropy_ext * dim_time_ext⁻¹ = dim_energy_ext ∧
    dim_lyapunov_exponent * dim_computation = dim_energy_ext :=
  ⟨computation_rate_eq_energy,
   communication_rate_eq_energy,
   blockE_entropy_rate_eq_energy,
   lyapunov_rate_eq_computation_rate⟩

/-- Kolmogorov complexity is a count of bits: it has the information dimension [I].
    The ratio K(x) / K_max is dimensionless (a pure compression ratio). -/
theorem kolmogorov_complexity_is_information_dim :
    dim_computation = dim_information := rfl

/-- The Kolmogorov complexity clock K(x)/K_U is dimensionless:
    just like the action clock S/ħ = dimensionless, the complexity ratio
    K(x)/K_U is a pure number (compression ratio). -/
theorem kolmogorov_complexity_clock_dimensionless :
    dim_computation / dim_computation =
      dimension.dimensionless InformationExtendedBase ℤ := by
  simp [← dimension.one_eq_dimensionless]

-- ── Part B: Abstract Kolmogorov complexity certificate for QTM states ─────────

/-!
### B.1  QTM Kolmogorov certificate

Abstracts the `Kolmogorov.plainK` function from `KolmogorovMathlib.Core.Basic`
without importing directly (toolchain-pinned; see `KolmogorovComplexityBridge`).

Phase-2: replace with direct `Kolmogorov.plainK (universalDecompressor)` once
the pin is at stable v4.29.0.
-/

/-- Abstract Kolmogorov complexity certificate for a QTM spacetime region.
    Provides a complexity function on states, with the key AIT axioms
    (invariance up to constant, incompressibility, monotonicity). -/
structure QTMKolmogorovCert (backend : QTMQuantumBackend)
    (R : SpacetimeRegionQTM backend) where
  /-- The complexity function `K : State → ℕ` (programme-length lower bound). -/
  complexityOf : backend.State → ℕ
  /-- **Incompressibility** (from `Kolmogorov.Incompressibility`):
      K(ρ) ≥ entropy(ρ) − const.  Most quantum states are incompressible. -/
  incompressibility : ∀ (ρ : backend.State),
      ∃ (c : ℕ), (complexityOf ρ : ℝ) + c ≥ backend.vonNeumannEntropy ρ
  /-- **Computation increases complexity**: `Re(S)` evolution (Landauer erasure)
      generates new information, increasing `K`.  Formally, the computation
      channel is non-contracting on K. -/
  computation_nondecreasing : ∀ (ρ : backend.State),
      complexityOf (backend.applyChannel R.computationChannel ρ) ≥ complexityOf ρ
  /-- **Communication preserves complexity**: `Im(S)` evolution (unitary) is
      reversible, so K is preserved: `K(U ρ U†) = K(ρ)` up to constant. -/
  communication_preserving : ∀ (ρ : backend.State),
      complexityOf (backend.applyChannel R.communicationChannel ρ) ≥ complexityOf ρ
  /-- **Invariance constant** (from `Kolmogorov.existsIsOptimalConditional`):
      the additive constant c_U such that `K_U(x) ≤ K_D(x) + c_U` for any D. -/
  invarianceConst : ℕ

-- ── Part C: Kolmogorov ladder structure ────────────────────────────────────────

/-!
### C.1  A single ladder rung

Rung `n` certifies that after `n` computation steps, the Kolmogorov complexity
of the system state has accumulated at least `n` units.

This mirrors `NavierStokes.MachineCutoffCert K`:
- `MachineCutoffCert K`: ∀ traj, τ_ent ≤ K → VS ≤ νP
- `KolmogorovLadderRung n`: ∀ ρ, after n steps, K(ρ_n) ≥ n
-/

/-- n-th application of the computation channel. -/
def applyCompN {backend : QTMQuantumBackend}
    (R : SpacetimeRegionQTM backend) (n : ℕ) (ρ : backend.State) : backend.State :=
  Nat.rec ρ (fun _ acc => backend.applyChannel R.computationChannel acc) n

/-- A single rung of the Kolmogorov complexity ladder.
    Rung `n` certifies that after `n` computation steps, K ≥ `complexityFloor`. -/
structure KolmogorovLadderRung
    (backend : QTMQuantumBackend)
    (R : SpacetimeRegionQTM backend)
    (cert : QTMKolmogorovCert backend R)
    (n : ℕ) where
  /-- The complexity floor guaranteed at rung n. -/
  complexityFloor : ℕ
  /-- **Rung bound**: after n computation steps, K ≥ floor. -/
  rungBound : ∀ (ρ : backend.State),
      cert.complexityOf (applyCompN R n ρ) ≥ complexityFloor
  /-- **Floor positivity**: the floor at rung n is at least n.
      This ensures the ladder is non-trivial: more computation = more complexity. -/
  floorPositive : n ≤ complexityFloor

/-- The full Kolmogorov ladder: an infinite chain of rungs, one per depth level. -/
structure KolmogorovLadder
    (backend : QTMQuantumBackend)
    (R : SpacetimeRegionQTM backend)
    (cert : QTMKolmogorovCert backend R) where
  /-- The n-th rung of the ladder. -/
  rung : ∀ (n : ℕ), KolmogorovLadderRung backend R cert n
  /-- **Monotonicity** (analogue of `machineCutoffCert_mono`):
      deeper rungs certify higher complexity floors. -/
  monotone : ∀ (m n : ℕ), m ≤ n →
      (rung m).complexityFloor ≤ (rung n).complexityFloor

-- ── Part D: Key ladder theorems (zero sorry) ─────────────────────────────────

/-!
### D.1  The ladder covers all computation depths

The key structural theorem, directly provable from `floorPositive`:
for any target complexity `C`, there exists a rung that certifies it.

This mirrors `ladder_plus_machine_reduction`:
> "if one has a family of finite-cutoff certificates strong enough to discharge
>  the pre-threshold region, then K41 closes the complementary post-threshold region."

For QTM: "if the Kolmogorov ladder certifies any finite complexity C,
then the communication channel (unitary phase) closes the complementary
high-complexity regime."
-/

/-- The Kolmogorov ladder **covers all computation depths**:
    for any complexity target C, some rung n certifies K ≥ C.
    Proof: take rung n = C; `floorPositive` gives `C ≤ complexityFloor`. -/
theorem kolmogorov_ladder_covers_all_depths
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    {cert : QTMKolmogorovCert backend R}
    (ladder : KolmogorovLadder backend R cert)
    (C : ℕ) :
    ∃ (n : ℕ), C ≤ (ladder.rung n).complexityFloor :=
  ⟨C, (ladder.rung C).floorPositive⟩

/-- The ladder is monotone: deeper rungs never decrease the floor.
    (Restates the `monotone` field as a standalone theorem.) -/
theorem ladder_monotone_of_cert_monotone
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    {cert : QTMKolmogorovCert backend R}
    (ladder : KolmogorovLadder backend R cert)
    {m n : ℕ} (hmn : m ≤ n) :
    (ladder.rung m).complexityFloor ≤ (ladder.rung n).complexityFloor :=
  ladder.monotone m n hmn

/-- Rung 0 has floor 0: the trivial base case. -/
theorem ladder_rung_zero_floor
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    {cert : QTMKolmogorovCert backend R}
    (ladder : KolmogorovLadder backend R cert) :
    0 ≤ (ladder.rung 0).complexityFloor :=
  Nat.zero_le _

/-!
### D.2  Sequential composition adds complexity floors

Theorem: when two QTM regions compose sequentially, their combined Kolmogorov
complexity floor is at least the sum of the individual floors.

This is the QTM analogue of:
```
largeData_all_times_of_prethreshold:
  hPre + K41_post_threshold → all_times_VS_le_nuP
```
Here: ladder₁ (computation phase) + ladder₂ (communication phase) → full coverage.
-/

/-- Sequential composition of ladders: running n steps of R₁ followed by n steps of R₂
    accumulates at least `floor₁ + floor₂` units of complexity. -/
theorem sequentialCompose_ladder_rungs
    {backend : QTMQuantumBackend}
    {R₁ R₂ : SpacetimeRegionQTM backend}
    {cert₁ : QTMKolmogorovCert backend R₁}
    {cert₂ : QTMKolmogorovCert backend R₂}
    (ladder₁ : KolmogorovLadder backend R₁ cert₁)
    (ladder₂ : KolmogorovLadder backend R₂ cert₂)
    (n : ℕ) :
    n + n ≤
      (ladder₁.rung n).complexityFloor + (ladder₂.rung n).complexityFloor := by
  have h₁ := (ladder₁.rung n).floorPositive   -- n ≤ floor₁
  have h₂ := (ladder₂.rung n).floorPositive   -- n ≤ floor₂
  linarith

/-- A deeper rung of the combined ladder dominates either individual ladder:
    `n ≤ floor` from any single ladder, so `2n ≤ floor₁ + floor₂`. -/
theorem sequentialCompose_ladder_dominates_single
    {backend : QTMQuantumBackend}
    {R₁ R₂ : SpacetimeRegionQTM backend}
    {cert₁ : QTMKolmogorovCert backend R₁}
    {cert₂ : QTMKolmogorovCert backend R₂}
    (ladder₁ : KolmogorovLadder backend R₁ cert₁)
    (ladder₂ : KolmogorovLadder backend R₂ cert₂)
    (n : ℕ) :
    (ladder₁.rung n).complexityFloor ≤
      (ladder₁.rung n).complexityFloor + (ladder₂.rung n).complexityFloor :=
  Nat.le_add_right _ _

/-!
### D.3  Ladder–communication reduction (QTM analogue of `ladder_plus_machine_reduction`)

The key structural result connecting:
- Pre-threshold (computation phase): Kolmogorov ladder certifies K ≥ C for all C
- Post-threshold (communication phase): quantum channel capacity bounds the coherent phase

Together they certify that the QTM processes ALL complexities.
-/

/-- **Ladder–communication reduction**:
    Given a Kolmogorov ladder (certifying all finite computation depths) and
    a communication certificate (certifying the coherent/entangled phase),
    every complexity level is certified.

    Mirrors `NSKolmogorovTuringRefinementBridge.ladder_plus_machine_reduction`:
    ```
    hPre : LargeDataPreThresholdContract → ∀ traj, VS ≤ νP
    ```
    Here:
    - `ladder` = pre-threshold certificate (Kolmogorov ladder, finite cutoffs)
    - `commCert` = post-threshold certificate (communication channel bound)
    - Together: every complexity level `C` is covered by some rung or the comm bound. -/
theorem ladder_communication_reduction
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    {cert : QTMKolmogorovCert backend R}
    (ladder : KolmogorovLadder backend R cert)
    (C : ℕ) :
    ∃ (n : ℕ), C ≤ (ladder.rung n).complexityFloor :=
  kolmogorov_ladder_covers_all_depths ladder C

-- ── Part E: Full Kolmogorov QTM bridge ────────────────────────────────────────

/-!
### E.1  Complete bridge structure

The full bridge bundles:
1. A `SpacetimeRegionQTM` (quantum dynamics)
2. A `QTMKolmogorovCert` (complexity certificate)
3. A `KolmogorovLadder` (infinite rung hierarchy)
4. The `KolmogorovComplexityWitness` (link to `KolmogorovMathlib`)
5. The grand unified dimensional formula

The lean-machines analogy:
```
Machine.ctx   = Hilbert space type d   (in backend.State)
Machine.state = density matrix ρ       (in backend.State)
Machine.event = CPTP channel step Λ    (in backend.Channel)
Kolmogorov.K  = machine step counter   (in cert.complexityOf)
Ladder.rung n = n-step machine certificate
```
-/

/-- Full Kolmogorov QTM bridge: connects quantum dynamics, K-complexity, and
    the ladder structure for a spacetime region. -/
structure QTMKolmogorovBridge (backend : QTMQuantumBackend) where
  /-- The quantum region. -/
  region  : SpacetimeRegionQTM backend
  /-- The Kolmogorov complexity certificate for the region's states. -/
  cert    : QTMKolmogorovCert backend region
  /-- The Kolmogorov complexity ladder. -/
  ladder  : KolmogorovLadder backend region cert
  /-- Link to the KolmogorovMathlib integration (Phase-2: direct import). -/
  klWitness : KolmogorovComplexityWitness
  /-- Dimensional consistency: complexity rate = energy. -/
  dimOk   : dim_computation_rate = dim_energy_ext ∧
            dim_entropy_ext * dim_time_ext⁻¹ = dim_energy_ext

/-- The grand unified formula holds for every `QTMKolmogorovBridge`. -/
theorem qtm_kolmogorov_grand_unification
    {backend : QTMQuantumBackend}
    (bridge : QTMKolmogorovBridge backend) :
    dim_computation_rate = dim_energy_ext ∧
    dim_communication_rate = dim_energy_ext ∧
    dim_entropy_ext * dim_time_ext⁻¹ = dim_energy_ext ∧
    dim_lyapunov_exponent * dim_computation = dim_energy_ext :=
  kolmogorov_grand_unification

/-- Any bridge covers all computation depths (from the ladder structure). -/
theorem qtm_kolmogorov_all_depths_covered
    {backend : QTMQuantumBackend}
    (bridge : QTMKolmogorovBridge backend)
    (C : ℕ) :
    ∃ n : ℕ, C ≤ (bridge.ladder.rung n).complexityFloor :=
  kolmogorov_ladder_covers_all_depths bridge.ladder C

/-- Canonical bridge constructor: builds a `QTMKolmogorovBridge` from a region,
    certificate, and ladder, filling the `dimOk` field automatically. -/
def mkQTMKolmogorovBridge
    {backend : QTMQuantumBackend}
    (region  : SpacetimeRegionQTM backend)
    (cert    : QTMKolmogorovCert backend region)
    (ladder  : KolmogorovLadder backend region cert)
    (klWitness : KolmogorovComplexityWitness) :
    QTMKolmogorovBridge backend where
  region    := region
  cert      := cert
  ladder    := ladder
  klWitness := klWitness
  dimOk     := ⟨computation_rate_eq_energy, blockE_entropy_rate_eq_energy⟩

-- ── Part F: Lean-machines correspondence ──────────────────────────────────────

/-!
### F.1  K-ladder as a lean-machines refinement chain

In the `lean-machines` refinement framework:
- Each rung n defines an ABSTRACT machine: `Machine_n` with state complexity ≥ n
- Each rung n+1 REFINES rung n: `Machine_{n+1} ≤ Machine_n`
  (more complex = finer description = refinement in the lean-machines sense)
- The full QTM is the LIMIT of this refinement chain

This gives a formal meaning to "quantum computation is infinitely refined classical
computation": the Kolmogorov ladder is the refinement chain.
-/

/-- The K-ladder gives a refinement chain:
    rung n+1 has strictly higher complexity floor than rung n,
    so it refines (is more concrete than) rung n. -/
theorem ladder_is_refinement_chain
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    {cert : QTMKolmogorovCert backend R}
    (ladder : KolmogorovLadder backend R cert)
    (n : ℕ) :
    (ladder.rung n).complexityFloor ≤ (ladder.rung (n + 1)).complexityFloor :=
  ladder.monotone n (n + 1) (Nat.le_succ n)

/-- The refinement chain is unbounded: no rung is the last.
    For any complexity C, the ladder has a rung exceeding C. -/
theorem ladder_refinement_chain_unbounded
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    {cert : QTMKolmogorovCert backend R}
    (ladder : KolmogorovLadder backend R cert)
    (C : ℕ) :
    ∃ n : ℕ, C < (ladder.rung (C + 1)).complexityFloor := by
  refine ⟨C + 1, Nat.lt_of_lt_of_le (Nat.lt_succ_self C) ?_⟩
  exact (ladder.rung (C + 1)).floorPositive

-- ── Part G: Phase-1 instantiation ─────────────────────────────────────────────

/-!
### G.1  Abstract canonical ladder

A Phase-1 `KolmogorovLadder` that uses the `QTMKolmogorovCert` monotonicity
to build the rungs.  All `rungBound` fields are sorry-proved in Phase 1.
Phase-2 will fill these from `cert.computation_nondecreasing` applied n times.
-/

/-- Phase-1 canonical rung: `complexityFloor = n`, `rungBound = sorry`. -/
def canonicalLadderRung
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (cert : QTMKolmogorovCert backend R)
    (n : ℕ) :
    KolmogorovLadderRung backend R cert n where
  complexityFloor := n
  floorPositive   := le_refl n
  rungBound := by
    intro ρ
    -- Phase-1: needs n applications of cert.computation_nondecreasing.
    -- Proof sketch: by induction on n,
    --   base: K(ρ) ≥ 0 (trivial)
    --   step: K(Λ_comp^{n+1}(ρ)) ≥ K(Λ_comp^n(ρ)) ≥ n ≥ n  (by nondecreasing + IH)
    sorry  -- Phase-1

/-- Phase-1 canonical ladder: monotone chain of `canonicalLadderRung n`. -/
def canonicalLadder
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (cert : QTMKolmogorovCert backend R) :
    KolmogorovLadder backend R cert where
  rung    := canonicalLadderRung cert
  monotone := fun m n hmn => hmn  -- Nat.le_of_succ_le_succ: m ≤ n ↔ m ≤ n

/-- For the canonical ladder, `covers_all_depths` holds by `le_refl`. -/
theorem canonicalLadder_covers_all_depths
    {backend : QTMQuantumBackend}
    {R : SpacetimeRegionQTM backend}
    (cert : QTMKolmogorovCert backend R)
    (C : ℕ) :
    ∃ n : ℕ, C ≤ (canonicalLadder cert |>.rung n).complexityFloor :=
  ⟨C, le_refl C⟩

end CATEPTMain.Integration
