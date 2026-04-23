import UnifiedTheory.LayerB.BellTheorem
import CATEPTMain.Integration.AdSCFTEntropicEntanglementBridge
/-!
# UnifiedTheory Bell Bridge

Bridges the **proved** Bell theorem content from `UnifiedTheory.LayerB.BellTheorem`
(zero sorry, zero axioms) into catept-main's causal-entanglement infrastructure.

## What this replaces

catept-main's AFP port (`CHSH_Inequality.lean`, `Entanglement.lean`) axiomatizes:
- `chsh_classical_bound_law` (private axiom): |S| ≤ 2 for ±1 outcomes
- `chsh_quantum_bound_law` (private axiom): |chshExpect| ≤ 2√2
- `chsh_bell_achieves_tsirelson_law` (private axiom): Bell state achieves 2√2
- `bell00_not_sep` … `bell11_not_sep` (private axioms): Bell states are entangled

## What this provides (all proved, 0 sorry)

1. **Classical CHSH bound** for ℝ (coerced from the Int proof via exhaustive check)
2. **CHSH violation** S² = 8 > 4 from derived Born rule + singlet correlations
3. **Tsirelson value** S² = 8, i.e. |S| = 2√2
4. **Singlet antisymmetry** and uniqueness → entanglement from first principles
5. **ProvedBellViolationWitness** packaging all results for downstream consumers
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.UnifiedTheoryBell

open UnifiedTheory.LayerB.BellTheorem
open CATEPTMain.Integration.AdSCFT.EntropicEntanglement
open CATEPTMain.Integration.CATEPTSpaceTime
open NavierStokesClean.CATEPT
open Real

-- ── Part A: Classical CHSH bound (ℝ coercion) ────────────────────────────────

/-!
### A.1  Classical bound lifted from Int to ℝ

UnifiedTheory proves `classical_chsh_bound` for `Int` values ∈ {-1, +1}.
catept-main's `chsh_classical_bound` expects `ℝ` values ∈ {-1, +1}.

The bridge coerces: if `a : ℝ` satisfies `a = 1 ∨ a = -1`, cast to `Int`
and apply the proved bound.
-/

/-- Classical CHSH bound for ℝ-valued ±1 outcomes.

    **Proved** (not axiomatized): for any `a, a', b, b' ∈ {-1, +1} ⊆ ℝ`,
    `|a·b + a·b' + a'·b - a'·b'| ≤ 2`.

    This replaces the private axiom `chsh_classical_bound_law` in
    `CHSH_Inequality.lean`. -/
theorem proved_chsh_classical_bound (a b a' b' : ℝ)
    (ha : a = 1 ∨ a = -1) (hb : b = 1 ∨ b = -1)
    (ha' : a' = 1 ∨ a' = -1) (hb' : b' = 1 ∨ b' = -1) :
    |a * b + a * b' + a' * b - a' * b'| ≤ 2 := by
  rcases ha with rfl | rfl <;> rcases hb with rfl | rfl <;>
    rcases ha' with rfl | rfl <;> rcases hb' with rfl | rfl <;>
    norm_num

-- ── Part B: CHSH violation from derived quantum mechanics ────────────────────

/-!
### B.1  Proved CHSH violation

UnifiedTheory derives from the source functional φ:
- Complex structure (Frobenius → ℂ)
- Born rule (SO(2) invariance → |z|²)
- Singlet state (unique antisymmetric in ℝ²⊗ℝ²)
- Correlation E(θ_a,θ_b) = -cos(θ_a - θ_b)
- CHSH at optimal angles: S = -4cos(π/4), S² = 8 > 4

All proved. Zero sorry.
-/

/-- The quantum CHSH value squared equals 8 (Tsirelson). Proved. -/
theorem proved_tsirelson_value : chshValue ^ 2 = 8 := tsirelson_value

/-- The quantum CHSH value exceeds the classical bound. Proved.

    S² = 8 > 4, equivalently |S| = 2√2 > 2. -/
theorem proved_bell_violation : chshValue ^ 2 > 4 := bell_violation

/-- The CHSH value is computed from the Born-rule-derived correlations
    at optimal angles: a=0, a'=π/2, b=π/4, b'=-π/4.

    E(θ) = -cos(θ) (derived from singlet + Born rule). Proved. -/
theorem proved_chsh_from_correlations :
    -Real.cos (0 - π / 4) + (-Real.cos (0 - -(π / 4)))
    + (-Real.cos (π / 2 - π / 4)) - (-Real.cos (π / 2 - -(π / 4)))
    = chshValue :=
  chsh_from_born_rule

-- ── Part C: Singlet state — antisymmetry and uniqueness ──────────────────────

/-!
### C.1  Singlet entanglement from antisymmetry

The singlet state `|ψ⟩ = (|01⟩ - |10⟩)/√2` is:
1. **Antisymmetric**: ψ(j,i) = -ψ(i,j) [proved]
2. **Unique**: any antisymmetric state in ℝ²⊗ℝ² is proportional to it [proved]
3. **Non-separable**: a product state u⊗v satisfies (u⊗v)(j,i) = u(j)·v(i),
   which is symmetric under i↔j when u=v and antisymmetric only if u⊗v = 0.
   Since the singlet is nonzero and antisymmetric, it cannot be a product. [proved below]
-/

/-- The singlet state is antisymmetric. Proved from SU(2). -/
theorem proved_singlet_antisymmetric (i j : Fin 2) :
    singletState j i = -singletState i j :=
  singlet_antisymmetric i j

/-- The antisymmetric subspace of ℝ²⊗ℝ² is 1-dimensional.
    Any antisymmetric ψ is proportional to the singlet. Proved. -/
theorem proved_antisymmetric_unique (ψ : Fin 2 → Fin 2 → ℝ)
    (h : ∀ i j, ψ j i = -ψ i j) :
    ∀ i j, ψ i j = ψ 0 1 * (singletState i j * Real.sqrt 2) :=
  antisymmetric_unique ψ h

/-- A product state in ℝ²⊗ℝ² cannot be antisymmetric (unless zero).

    If ψ(i,j) = u(i)·v(j) and ψ(j,i) = -ψ(i,j), then:
    u(0)·v(1) = -u(1)·v(0) and u(0)·v(0) = -u(0)·v(0) → u(0)·v(0) = 0.
    Similarly u(1)·v(1) = 0. This forces the product to be zero or the
    relation u(0)·v(1) + u(1)·v(0) = 0, which for product states means
    ψ(0,1) = 0. -/
theorem product_state_not_antisymmetric
    (u v : Fin 2 → ℝ)
    (h_anti : ∀ i j : Fin 2, u j * v i = -(u i * v j))
    : ∀ i j : Fin 2, u i * v j = 0 := by
  have h00 : u 0 * v 0 = 0 := by have := h_anti 0 0; linarith
  have h11 : u 1 * v 1 = 0 := by have := h_anti 1 1; linarith
  have h01 : u 0 * v 1 = -(u 1 * v 0) := by have := h_anti 1 0; linarith
  -- From h00: u(0)=0 ∨ v(0)=0.
  -- From h11: u(1)=0 ∨ v(1)=0.
  -- In all 4 combinations, h01 forces remaining products to 0.
  have h10 : u 1 * v 0 = 0 := by
    rcases mul_eq_zero.mp h00 with hu0 | hv0
    · -- u(0)=0 → u(0)*v(1)=0 → by h01: u(1)*v(0)=0
      have : u 0 * v 1 = 0 := by rw [hu0, zero_mul]
      linarith
    · exact mul_eq_zero_of_right _ hv0
  have h01' : u 0 * v 1 = 0 := by linarith
  intro i j
  fin_cases i <;> fin_cases j <;> simp_all

/-- The singlet state is **nonzero**: ψ(0,1) = 1/√2 ≠ 0. -/
theorem singlet_nonzero : singletState 0 1 ≠ 0 := by
  unfold singletState; simp

/-- **The singlet is not a product state** (entangled).

    Proof: if ψ = u ⊗ v, then ψ is a product and antisymmetric, so by
    `product_state_not_antisymmetric` it's zero everywhere. But ψ(0,1) ≠ 0.
    Contradiction. -/
theorem singlet_entangled :
    ¬ ∃ (u v : Fin 2 → ℝ), ∀ i j : Fin 2, singletState i j = u i * v j := by
  intro ⟨u, v, h_prod⟩
  have h_anti : ∀ i j : Fin 2, u j * v i = -(u i * v j) := by
    intro i j
    have h1 := h_prod i j
    have h2 := h_prod j i
    have h3 := singlet_antisymmetric i j
    rw [h1, h2] at h3
    linarith
  have h_zero := product_state_not_antisymmetric u v h_anti
  have h01 := h_zero 0 1
  rw [← h_prod 0 1] at h01
  exact singlet_nonzero h01

-- ── Part D: Proved Bell Violation Witness ────────────────────────────────────

/-!
### D.1  Bundled proved witness

Packages the proved CHSH violation, classical bound, singlet entanglement,
and Born-rule-derived correlations into a single structure for downstream
consumers (AdSCFTEntropicEntanglementBridge, EntropicLocalityFullDischarge).
-/

/-- **Proved Bell violation witness**: all content derived from first principles.

    Every field is a theorem (not an axiom). The derivation chain:
    source functional φ → Frobenius → ℂ → Born rule → singlet → E = -cos(θ) → S² = 8 > 4.

    This parallels the axiom-based `SpacelikeCHSHWitness` but with proved content. -/
structure ProvedBellViolationWitness where
  /-- S² = 8 (Tsirelson value, proved). -/
  tsirelson : chshValue ^ 2 = 8
  /-- S² > 4 (violation of classical bound, proved). -/
  violation : chshValue ^ 2 > 4
  /-- Classical bound: ±1 outcomes give |S| ≤ 2 (proved by exhaustive check). -/
  classical_bound : ∀ (a b a' b' : ℝ),
    (a = 1 ∨ a = -1) → (b = 1 ∨ b = -1) →
    (a' = 1 ∨ a' = -1) → (b' = 1 ∨ b' = -1) →
    |a * b + a * b' + a' * b - a' * b'| ≤ 2
  /-- Singlet is not a product state (proved from antisymmetry). -/
  singlet_not_product :
    ¬ ∃ (u v : Fin 2 → ℝ), ∀ i j : Fin 2, singletState i j = u i * v j
  /-- Singlet correlation: E(θa,θb) = -cos(θa - θb) (proved from Born rule). -/
  correlation : ∀ θa θb : ℝ,
    P_upup θa θb - P_updown θa θb - P_downup θa θb + P_downdown θa θb =
    -Real.cos (θa - θb)

/-- Canonical construction — all fields are proved theorems. -/
noncomputable def provedBellViolationWitness : ProvedBellViolationWitness where
  tsirelson := proved_tsirelson_value
  violation := proved_bell_violation
  classical_bound := proved_chsh_classical_bound
  singlet_not_product := singlet_entangled
  correlation := correlation_from_born_rule

-- ── Part E: Integration with causal structure ────────────────────────────────

/-!
### E.1  Proved CHSH + causal structure compatibility

The proved Bell violation is compatible with the NoFTL causal structure:
- CHSH > 2 (nonlocality) ✓
- velocity bound |v| < 1 (causality) ✓
- No contradiction: entanglement doesn't enable signaling

This mirrors `chsh_compatible_with_noftl` but uses proved content
instead of axiom-based `SpacelikeCHSHWitness`.
-/

/-- A spacelike-separated pair with **proved** CHSH violation and NoFTL certificate.

    Unlike `SpacelikeCHSHWitness` (which consumes axiomatized Bell states),
    this uses the proved content from UnifiedTheory. -/
structure ProvedSpacelikeCHSHWitness where
  /-- Alice's spacetime event. -/
  alice : CATEPTST
  /-- Bob's spacetime event. -/
  bob : CATEPTST
  /-- The events are spacelike-separated. -/
  spacelike : OutsideLightcone alice bob
  /-- The proved Bell violation witness. -/
  bell : ProvedBellViolationWitness
  /-- No-FTL certificate (velocity bound from causal structure). -/
  noftl_certificate : MinkowskiNoFTLCertificate

/-- **Proved nonlocality is compatible with causality.**

    From the proved Bell violation: S² = 8 > 4, so quantum correlations
    exceed any local hidden variable model. Yet the NoFTL velocity bound
    holds and the events are spacelike-separated — no contradiction. -/
theorem proved_chsh_compatible_with_noftl (w : ProvedSpacelikeCHSHWitness) :
    -- 1. CHSH violation (proved, not axiomatized)
    chshValue ^ 2 > 4 ∧
    -- 2. Velocity bound holds (proved for Minkowski)
    (∀ (Δx : CATEPTST), CausalTimelike Δx → Δx 0 ≠ 0 →
      spatialNorm2 Δx / (Δx 0) ^ 2 < 1) ∧
    -- 3. Events are spacelike-separated
    CausalSpacelike (w.bob - w.alice) :=
  ⟨w.bell.violation, w.noftl_certificate.velocity_bound, w.spacelike⟩

/-- Construct a `ProvedSpacelikeCHSHWitness` from any two spacelike events.

    Uses the canonical `provedBellViolationWitness` (all content proved)
    and the Minkowski NoFTL certificate. -/
noncomputable def mkProvedSpacelikeCHSHWitness
    (alice bob : CATEPTST)
    (hsp : OutsideLightcone alice bob) :
    ProvedSpacelikeCHSHWitness where
  alice := alice
  bob := bob
  spacelike := hsp
  bell := provedBellViolationWitness
  noftl_certificate := minkowski_noftl_certificate

/-- **The full derivation chain in one theorem:**

    From the causal set postulate (source functional φ):
    1. Frobenius uniqueness → ℂ as the amplitude algebra
    2. SO(2) invariance → Born rule |z|² as the unique observable
    3. SU(2) derived from charge determinacy → spin states
    4. Singlet = unique antisymmetric state → entanglement
    5. Born rule + singlet → E(θ) = -cos(θ)
    6. Optimal angles → S = -4cos(π/4), S² = 8 > 4
    7. Exhaustive ±1 check → classical bound |S| ≤ 2

    All in one statement, all proved. -/
theorem bell_from_first_principles :
    -- The quantum CHSH value exceeds the classical bound
    chshValue ^ 2 > 4
    -- The classical bound holds for all deterministic ±1 theories
    ∧ (∀ a a' b b' : Int,
        (a = 1 ∨ a = -1) → (a' = 1 ∨ a' = -1) →
        (b = 1 ∨ b = -1) → (b' = 1 ∨ b' = -1) →
        -2 ≤ chshDet a a' b b' ∧ chshDet a a' b b' ≤ 2)
    -- The singlet is entangled (not a product state)
    ∧ (¬ ∃ (u v : Fin 2 → ℝ), ∀ i j : Fin 2, singletState i j = u i * v j)
    -- The CHSH value is computed from derived Born-rule correlations
    ∧ chshValue ^ 2 = 8 :=
  ⟨bell_violation,
   fun a a' b b' ha ha' hb hb' => classical_chsh_bound a a' b b' ha ha' hb hb',
   singlet_entangled,
   tsirelson_value⟩

end CATEPTMain.Integration.UnifiedTheoryBell
