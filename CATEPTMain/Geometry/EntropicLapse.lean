import CATEPTMain.Geometry.FiniteMinkowski

/-!
# Entropic Lapse — Lapse-Weighted Minkowski Geometry

§3c harvest from `NavierStokesClean/CATEPT/CATEPTSpaceTime.lean` —
ADM-style **lapse-weighted Minkowski geometry** with the lapse function

  `N : CATEPTST → ℝ`  (positive everywhere)

playing the role of ADM lapse converting coordinate-time intervals to
proper-time intervals via `dτ = N dt`.  In the CAT/EPT framework the
canonical lapse is

  `N_ent(x) = Ω(x) / (2 ν)` (enstrophy / twice viscosity)

— the entropic time scaling rate.  This module provides the geometric
carrier; the dynamical content (Ω, ν, the actual entropic-time
accumulation) lives in NS-specific bridge layers.

## Provenance

Direct harvest of §3c of `NavierStokesClean/CATEPT/CATEPTSpaceTime.lean`,
restricted to the lapse-weighted geometry (no NS-specific dynamics).
Builds on `CATEPTMain.Geometry.FiniteMinkowski` (PR #17) for the
underlying `CATEPTST` carrier and Minkowski causal structure.

## Architectural fit

```text
Mathlib only
    ↓
FiniteMinkowski   (PR #17)              — pure geometry
    ↓
EntropicLapse    (this PR)              — lapse-weighted geometry
    ↓
MISNoFTLBridge   (next PR, NS-specific) — composes EntropicLapse +
                                          palinstrophy (P27b) for
                                          MIS correction
```

## Link to the path-integral chain (next in queue: P28)

The entropic-lapse identification `dτ_ent = N dt` with
`N_ent = Ω / (2 ν)` is the *geometric carrier* for the path-integral
phase-1 chain that has already shipped on `origin/main`:

  - T-S  `heat_semigroup_entropic_time`     (heat-semigroup ↔ τ_ent at t=0)
  - T-T  `heatMode_integral_eq_entropicProperTime`  (L¹-norm ↔ τ_ent)
  - T-U  `heatMode_semigroup` (one-parameter abelian semigroup law)
  - T-V, T-W (sourced / shifted heat-integral identities)
  - T-FF Phase 22-26 (T³ spectral partition + lattice-action chain)

Specifically: `entropicNorm2 N x Δx` is the natural Lorentzian metric
under which the path-integral heat semigroup `exp(-(2 ν) t)` —
equivalently `exp(-S_visc[Φ] / ℏ)` per the Constantin-Iyer
identification `ℏ = 2 ν` — has its time variable.  The next path-integral
task **P28** (higher-degree T³ tail for `exp(-k^d)` series at `d ≥ 3`)
provides the analysis-side analogue of P26 + P27b at the lattice level;
this geometry layer provides the *spacetime* carrier on which those
modes live.

## What is honestly proven

* `EntropicLapse` (structure): lapse function `N : CATEPTST → ℝ` with
  pointwise positivity.
* `entropicNorm2` (def): the lapse-weighted Minkowski norm-squared
  `−N(x)² · Δx₀² + spatialNorm² Δx`.
* `EntropicTimelike` / `EntropicSpacelike` (defs): causal predicates
  under the lapse-weighted norm.
* `unitLapse` (def): the trivial lapse `N ≡ 1`.
* `entropicNorm2_unitLapse` (theorem): unit lapse reduces to standard
  Minkowski norm-squared.
* `entropicTimelike_unitLapse_iff` / `entropicSpacelike_unitLapse_iff`
  (theorems): unit-lapse causal classification = standard Minkowski.
* `entropicTimelike_mono` (theorem): higher lapse widens the timelike
  cone — `N₁ ≤ N₂ ⟹ EntropicTimelike N₁ ⊆ EntropicTimelike N₂`.
* `entropicTimelike_velocity_bound` (theorem): timelike under lapse `N`
  ⟹ `|v|² < N(x)²` (entropic local speed of light).

## Honest scope

Pure structural harvest with two-line provenance per definition.
The dynamical entropic-time content (`Ω`, `ν`, NS coupling) lives in
NS-specific bridges; this module is the *geometric carrier* only.
NS-MIS / parabolic-diffusion content is intentionally NOT here —
slated for `MISNoFTLBridge.lean`.
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.EntropicLapse

open CATEPTMain.Geometry.FiniteMinkowski

-- ═══════════════════════════════════════════════════════════════════════
-- Entropic Lapse Field
-- ═══════════════════════════════════════════════════════════════════════

/-- **Entropic lapse field**: a positive function on `CATEPTST` that
scales coordinate-time intervals to entropic-time intervals via the ADM
formula `dτ = N dt`.

For Minkowski (flat, no entropic gradient): `N(x) = 1`.
For NS / CAT/EPT (canonical): `N(x) = Ω(x) / (2 ν)` (enstrophy / twice
viscosity), the entropic time scaling rate.  -/
structure EntropicLapse where
  /-- The lapse value at each spacetime event. -/
  lapse : CATEPTST → ℝ
  /-- Lapse is strictly positive everywhere. -/
  lapse_pos : ∀ x, 0 < lapse x

-- ═══════════════════════════════════════════════════════════════════════
-- Lapse-Weighted Minkowski Norm
-- ═══════════════════════════════════════════════════════════════════════

/-- **Entropic spacetime interval** (lapse-weighted Minkowski norm-squared):

  `η_ent(N, x, Δx) = −N(x)² · (Δx₀)² + (Δx₁)² + (Δx₂)² + (Δx₃)²`.

The lapse scales the time component: faster entropic evolution (higher
`N`) makes the time separation more dominant, pushing the interval
toward timelike. -/
def entropicNorm2 (N : EntropicLapse) (x : CATEPTST) (Δx : CATEPTST) : ℝ :=
  -(N.lapse x) ^ 2 * (Δx 0) ^ 2 + spatialNorm2 Δx

/-- **Entropic timelike**: the lapse-weighted interval is negative
(time-dominated). -/
def EntropicTimelike (N : EntropicLapse) (x Δx : CATEPTST) : Prop :=
  entropicNorm2 N x Δx < 0

/-- **Entropic spacelike**: the lapse-weighted interval is positive
(space-dominated). -/
def EntropicSpacelike (N : EntropicLapse) (x Δx : CATEPTST) : Prop :=
  entropicNorm2 N x Δx > 0

-- ═══════════════════════════════════════════════════════════════════════
-- Unit Lapse Reduction
-- ═══════════════════════════════════════════════════════════════════════

/-- The **unit lapse** `N(x) = 1`, recovering standard Minkowski geometry. -/
def unitLapse : EntropicLapse where
  lapse := fun _ => 1
  lapse_pos := fun _ => one_pos

/-- With unit lapse, the entropic norm-squared coincides with the standard
Minkowski norm-squared. -/
theorem entropicNorm2_unitLapse (x Δx : CATEPTST) :
    entropicNorm2 unitLapse x Δx = minkowskiNorm2 Δx := by
  unfold entropicNorm2 unitLapse minkowskiNorm2
  ring

/-- Unit-lapse entropic-timelike = standard Minkowski timelike. -/
theorem entropicTimelike_unitLapse_iff (x Δx : CATEPTST) :
    EntropicTimelike unitLapse x Δx ↔ CausalTimelike Δx := by
  unfold EntropicTimelike CausalTimelike
  rw [entropicNorm2_unitLapse]

/-- Unit-lapse entropic-spacelike = standard Minkowski spacelike. -/
theorem entropicSpacelike_unitLapse_iff (x Δx : CATEPTST) :
    EntropicSpacelike unitLapse x Δx ↔ CausalSpacelike Δx := by
  unfold EntropicSpacelike CausalSpacelike
  rw [entropicNorm2_unitLapse]

-- ═══════════════════════════════════════════════════════════════════════
-- Lapse Monotonicity & Velocity Bound
-- ═══════════════════════════════════════════════════════════════════════

/-- **Higher lapse widens the timelike cone**: if `N₁(x) ≤ N₂(x)` and
`Δx` is timelike under `N₁`, then `Δx` is also timelike under `N₂`.

More entropic evolution rate ⟹ more displacements qualify as timelike. -/
theorem entropicTimelike_mono {N₁ N₂ : EntropicLapse} {x Δx : CATEPTST}
    (hle : N₁.lapse x ≤ N₂.lapse x)
    (h₁ : EntropicTimelike N₁ x Δx) :
    EntropicTimelike N₂ x Δx := by
  unfold EntropicTimelike entropicNorm2 at *
  have hN₁ := N₁.lapse_pos x
  have hsq : N₁.lapse x ^ 2 ≤ N₂.lapse x ^ 2 :=
    sq_le_sq' (by linarith) hle
  nlinarith [sq_nonneg (Δx 0)]

/-- **Entropic local speed of light**: for displacements timelike under
lapse `N`, the squared spatial norm is bounded by `N(x)² · Δx₀²` —
i.e. the *coordinate* velocity satisfies `|v|² < N(x)²`.

The entropic lapse sets the *local* speed of light (in coordinate
units): signals propagate at most at speed `N(x)`. -/
theorem entropicTimelike_velocity_bound {N : EntropicLapse} {x Δx : CATEPTST}
    (htl : EntropicTimelike N x Δx) :
    spatialNorm2 Δx < (N.lapse x) ^ 2 * (Δx 0) ^ 2 := by
  unfold EntropicTimelike entropicNorm2 at htl
  linarith

end CATEPTMain.Geometry.EntropicLapse
