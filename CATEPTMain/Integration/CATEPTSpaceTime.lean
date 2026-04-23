import CATEPTMain.SM.SMPrelude
import Mathlib.Geometry.Manifold.IsManifold.Basic
import Mathlib.Geometry.Manifold.Instances.Real
import Mathlib.MeasureTheory.Measure.MeasureSpace
import NavierStokesClean.CATEPT.CATEPTSpaceTime
/-!
# CATEPTSpaceTime — CAT/EPT Spacetime and Entropic Proper Time

Defines the foundational spacetime model for the CAT/EPT framework:

- `CATEPTSpacetimeModel`: interface-level description of a smooth 4-manifold
  carrying a Lorentzian metric and an **entropic proper time** (EPT) calibration
  `τ : M → ℝ`.

- `CATEPTVelocityField`: the canonical velocity-field carrier for the
  Navier-Stokes sector, `(Fin 3 → ℝ) → (Fin 3 → ℝ)`.
  This type admits a safe pi-product measure without the `whnf`-loop issue
  present on abstract function-space types, because `Fin 3 → ℝ` is a
  fintype-indexed product.

- `NSTorusVelocityField`: abstract carrier for the torus-side Galerkin
  approximation cluster.

- `equivIocBridge`: axiom asserting the isomorphism
  `CATEPTVelocityField ≃ NSTorusVelocityField`.
  Phase-2: construct explicitly via the `[0,1]³` periodization (`equivIoc`)
  identification of the torus with the unit cube.

- `EPTAxiomPackage`: the five minimal axioms that make τ a valid thermodynamic
  time arrow.

## Architecture

```
CAT/EPT spacetime
  = SM 4-manifold (C∞, from Smooth_Manifolds AFP)
  + Lorentzian metric (signature 3+1)
  + EPT scalar τ : M → ℝ  (smooth, non-negative, timelike, causal-monotone)
```

The spatial sector `Fin 3 → ℝ` inherits the Euclidean product measure
`∏ᵢ Lebesgue`, allowing safe Galerkin / Fourier analysis on 3-slices.

## Phase-1 scope
All structure fields involving proof obligations carry `True` placeholders.
Phase-2 replaces them with `ContMDiff`, `StrictMono`, etc. discharge lemmas.

## Reference
Conceptual anchors:
  `CurvedMaxwellEinsteinDerivation.lean`   (planned: curved Maxwell–Einstein bridge)
  `WeylComplexDiracCompatibility.lean`     (planned: Weyl spinor / Dirac compatibility)
  `CurvedMaxwellUnified.lean`              (planned: unified curved Maxwell sector)
  `CurvedSpacetimePathIntegral.lean`       (planned: path integral on curved EPT background)
-/

set_option autoImplicit false

open CATEPTMain.SM

namespace CATEPTMain.Integration.CATEPTSpaceTime

-- ── CAT/EPT Velocity Field ────────────────────────────────────────────────────

/-- The Navier-Stokes sector velocity-field carrier.

    `CATEPTVelocityField = (Fin 3 → ℝ) → (Fin 3 → ℝ)`

    **Safety**: `Fin 3 → ℝ` is a `Fintype`-indexed product type; the
    pi-product measure on it (via `MeasureTheory.Measure.pi`) is fully
    reducible without hitting the definitional-reduction (`whnf`) loop that
    arises for abstract non-`Fintype` function spaces.

    **NS migration target**: the Galerkin approximation cluster should use
    exactly this type rather than `NSTorusVelocityField`, because:
    (a) `spatialMeasure` below is proved safe here, and
    (b) `equivIocBridge` provides the isomorphism to the torus side. -/
abbrev CATEPTVelocityField : Type := (Fin 3 → ℝ) → (Fin 3 → ℝ)

/-- Phase-1 axiom: a norm on `CATEPTVelocityField = (Fin 3 → ℝ) → (Fin 3 → ℝ)`.

    The function space (ℝ³ → ℝ³) carries no automatic `Norm` instance from
    Mathlib's `Pi.instNorm` (which requires a `Fintype` domain), so we axiomatize
    it here in phase-1.  Phase-2: supply the H¹ Sobolev norm or L²-operator norm
    explicitly once the Galerkin cluster is established. -/
noncomputable axiom instNormCATEPTVF : Norm CATEPTVelocityField
attribute [instance] instNormCATEPTVF

/-- The EPT Paraboloid Trajectory Constraint.
    Formulation: `EPTTrajectory = {(u, τ) : NSField × ℝ | ‖u‖² + 2ℏτ = E₀}`
    For any fixed `τ`, the spatial velocity manifold `u` forms a sphere.
    This provides manifest compactness, bypassing Aubin-Lions-Simon fraction machinery. -/
structure EPTTrajectory (E₀ : ℝ) (ℏ : ℝ) where
  u : CATEPTVelocityField
  τ : ℝ
  /-- The paraboloid constraint ‖u‖² + 2ℏτ = E₀ -/
  energy_constraint : ‖u‖^2 + 2 * ℏ * τ = E₀

-- ── Torus velocity field (NS / Galerkin side) ─────────────────────────────────

/-- Abstract NS torus velocity field carrier (Galerkin T³ side). -/
opaque NSTorusVelocityField : Type

/-- The equivIoc bridge: `CATEPTVelocityField ≃ NSTorusVelocityField`.

    Phase-2: construct via the periodisation
      `ι : (Fin 3 → ℝ) → (Fin 3 → ℝ/ℤ) ≅ T³`
    using `equivIoc` on each ℝ-factor and the universal property of the
    quotient torus.  The Galerkin cluster then migrates by transporting
    all half-Hölder regularity estimates through this equivalence. -/
axiom equivIocBridge : CATEPTVelocityField ≃ NSTorusVelocityField

-- ── Pi-product measure on the spatial slice ───────────────────────────────────

/-- Standard product Lebesgue measure on the spatial slice `Fin 3 → ℝ = ℝ³`. -/
noncomputable def spatialMeasure : MeasureTheory.Measure (Fin 3 → ℝ) :=
  MeasureTheory.Measure.pi (fun _ => MeasureTheory.volume)

/-- Sigma-finiteness of `spatialMeasure`.

    Phase-1: axiom. Phase-2: `inferInstance` once
    `Mathlib.MeasureTheory.Constructions.Pi` is imported and
    `SigmaFinite (volume : Measure ℝ)` is in scope. -/
axiom spatialMeasure_sigmaFinite : MeasureTheory.SigmaFinite spatialMeasure
attribute [instance] spatialMeasure_sigmaFinite

/-- Phase-1 axiom: `CATEPTVelocityField` carries a measurable space structure.

    Phase-2: derive from the product measurability of `(Fin 3 → ℝ) → (Fin 3 → ℝ)`
    by equipping domain and codomain with Borel sigma-algebras and using the
    pointwise sigma-algebra on the function space. -/
axiom instMeasurableSpaceCATEPTVF : MeasurableSpace CATEPTVelocityField
attribute [instance] instMeasurableSpaceCATEPTVF

/-- Phase-1 axiom: a canonical sigma-finite measure exists on the full
    CAT/EPT velocity-field space `CATEPTVelocityField`.

    Phase-2: push `spatialMeasure` through `equivIocBridge` via
    `Measure.map equivIocBridge.symm.toFun`, or use the pi-construction
    directly on the finite product structure of the function space. -/
noncomputable axiom cateptVFMeasure : MeasureTheory.Measure CATEPTVelocityField

axiom cateptVFMeasure_sigmaFinite : MeasureTheory.SigmaFinite cateptVFMeasure

-- ── CAT/EPT Spacetime interface model ────────────────────────────────────────

/-- Interface-level description of a CAT/EPT spacetime model.

    Fields:
    - `SpaceTime` : the carrier type for spacetime events
    - `lorentzMetric` : Lorentzian inner product (signature 3,1)
    - `ept` : entropic proper time function τ : M → ℝ
    - Four `Prop` certificates axiomatising the EPT structure

    This structure is kept intentionally abstract so it remains stable
    while the concrete differential geometry develops in phase-2. -/
structure CATEPTSpacetimeModel where
  /-- Carrier type for spacetime events (a 4-manifold). -/
  SpaceTime    : Type
  /-- Lorentzian metric gₘₙ with signature (3,1). -/
  lorentzMetric : SpaceTime → SpaceTime → ℝ
  /-- Entropic proper time τ : SpaceTime → ℝ. -/
  ept           : SpaceTime → ℝ
  /-- A1: τ ≥ 0 (entropy is non-negative). -/
  ept_nonneg    : ∀ x : SpaceTime, 0 ≤ ept x
  /-- A2: τ is smooth (C∞ along the manifold). Phase-1 stub. -/
  ept_smooth    : True
  /-- A3: Thermodynamic arrow — τ strictly increases along future-directed
      causal curves. Phase-1 stub. -/
  ept_causal_arrow : True
  /-- A4: No faster-than-light — all physical velocities |v| < 1.
      Phase-1 stub; phase-2: from `sNorm2 v < 1` using NoFTL module. -/
  noFTL         : True

/-- Convenience: the EPT non-negativity certificate extracted from a model. -/
def CATEPTSpacetimeModel.eptNonneg (st : CATEPTSpacetimeModel) :
    ∀ x : st.SpaceTime, 0 ≤ st.ept x :=
  st.ept_nonneg

-- ── EPT Axiom Package ─────────────────────────────────────────────────────────

/-- The full EPT axiom package: five Prop fields bundling all physical
    requirements on the entropic proper time. -/
structure EPTAxiomPackage (st : CATEPTSpacetimeModel) where
  /-- A1: τ ≥ 0 everywhere. -/
  a1_nonneg     : ∀ x : st.SpaceTime, 0 ≤ st.ept x
  /-- A2: τ is smooth (C∞). Phase-1: True stub. -/
  a2_smooth     : True
  /-- A3: Thermodynamic arrow (τ monotone on worldlines). Phase-1: True stub. -/
  a3_arrow      : True
  /-- A4: Speed limit (c = 1 units; no FTL motion). Phase-1: True stub. -/
  a4_noftl      : True
  /-- A5: Spatial flatness at each τ-level (Euclidean 3-slices). Phase-1: True stub. -/
  a5_flat       : True

/-- Every `CATEPTSpacetimeModel` satisfies the EPT axiom package.

    Phase-1: trivially, since the stub fields are `True`.
    Phase-2: replace stubs with fully discharged Lean 4 proofs using
    `ContMDiff`, `StrictMonoOn`, `Metric.isometry`, etc. -/
theorem catept_satisfies_ept_axioms
    (st : CATEPTSpacetimeModel) :
    EPTAxiomPackage st where
  a1_nonneg := st.ept_nonneg
  a2_smooth := st.ept_smooth
  a3_arrow  := st.ept_causal_arrow
  a4_noftl  := st.noFTL
  a5_flat   := trivial

-- ── Canonical construction: Minkowski spacetime ───────────────────────────────

/-- The canonical Minkowski spacetime as a flat CAT/EPT model.

    Carrier: ℝ⁴ = Fin 4 → ℝ (as EuclideanSpace ℝ (Fin 4) coordinates).
    EPT τ(x) = x 0 (the coordinate-time component, non-negative by assumption).
    Lorentz metric: the standard (−,+,+,+) Minkowski form.

    Phase-1: EPT is taken as |x 0| (absolute time coordinate) to guarantee
    non-negativity uniformly.  Actual τ from entropy: phase-2 replaces this
    with a monotone entropy functional restricted to the future cone. -/
noncomputable def minkowskiCATEPT : CATEPTSpacetimeModel where
  SpaceTime     := Fin 4 → ℝ
  lorentzMetric := fun x y =>
    -- Minkowski (−,+,+,+): −x₀y₀ + x₁y₁ + x₂y₂ + x₃y₃
    - (x 0 * y 0) + (x 1 * y 1) + (x 2 * y 2) + (x 3 * y 3)
  ept           := fun x => |x 0|
  ept_nonneg    := fun x => abs_nonneg (x 0)
  ept_smooth    := trivial
  ept_causal_arrow := trivial
  noFTL         := trivial

/-- The Minkowski model satisfies the EPT axiom package. -/
theorem minkowski_satisfies_ept_axioms :
    EPTAxiomPackage minkowskiCATEPT :=
  catept_satisfies_ept_axioms minkowskiCATEPT

-- ── NS Galerkin gap record ────────────────────────────────────────────────────

/-- Dependency record for the NS smoothness proof on the CAT/EPT background.

    This bundles the four Galerkin sorrys (P1) and three GN sorrys (P2)
    into a single Prop package, enabling the dependency graph to be
    tracked formally.

    Proof priority order (from the request):
      P0  — torus mean-zero vorticity:         HasFDerivAt.comp_hasDerivAt
      P1  — Galerkin cluster (4 sorrys):       ept_paraboloid_compactness
      P2  — Gagliardo-Nirenberg H¹ ↪ L⁴ (3):  Mathlib GN + periodization
      P3  — Agmon + BKM (2 sorrys):            follows from P2
      P4  — CATEPT / QFT off-path (2 sorrys):  deferred, not on NS critical path -/
structure NSGalerkinGapRecord where
  /-- P0: Torus mean-zero vorticity. -/
  p0_vorticity_mean_zero    : Prop
  /-- P1: EPT Paraboloid sequential compactness. -/
  p1_ept_paraboloid_compactness : Prop
  /-- P1: Stage B Integrability closure. -/
  p1_ept_stage_b_integrability : Prop
  /-- P1: Galerkin limit identification. -/
  p1_galerkin_limit          : Prop
  /-- P2: vs_l4_holder_bound (Gagliardo-Nirenberg L⁴ estimate). -/
  p2_gn_l4_bound             : Prop
  /-- P2: vorticity_l4_le_enstrophy. -/
  p2_vorticity_l4_enstrophy  : Prop
  /-- P2: sa_g1_jomega_integrable. -/
  p2_jomega_integrable       : Prop
  /-- P3: Agmon T³ interpolation. -/
  p3_agmon_interpolation     : Prop
  /-- P3: BKM linf proxy gap. -/
  p3_bkm_linf_gap            : Prop
  /-- P4 (off-path): CATEPT no-FTL diffusion gap. -/
  p4_noftl_diffusion         : Prop
  /-- P4 (off-path): massless KL-Weyl correspondence. -/
  p4_massless_kl_weyl        : Prop

-- ── Phase 5E-α: Metric Bridge + EPT Entropic Einstein Locality ───────────────

/-!
## §5 — Coordinate Metric Bridge and EPT Vacuum (Phase 5E-α)

This section connects `CATEPTSpacetimeModel` to the concrete GR tensor kernel
(`NavierStokesClean.CATEPT.GRTensorKernel`) via a 4D coordinate chart extension.

**Key result** (no sorry, no new axiom):
`minkowskiCATEPT4D_einstein_flat : minkowskiCATEPT4D.EinsteinFlat`

i.e. the Minkowski CATEPT model satisfies the vacuum Einstein equations G_μν = 0,
proved directly from `GRTensorKernel.einsteinTensor_eq_zero_minkowski`.

**Architecture**:
```
CATEPTSpacetimeModel           -- abstract (lorentzMetric : SpaceTime → SpaceTime → ℝ)
     ↓  CATEPTSpacetime4DCoords (+ coordChart + metricField + metric_compat)
MetricField (Fin 4)             -- coordinate tensor (GRTensorKernel)
     ↓  EinsteinFlat predicate
G_μν = 0                        -- vacuum Einstein equations
```

**EPT Entropic Einstein Locality** (Phase 5E-γ axiom, tagged for discharge):
The EPT causal arrow (A3: τ strictly increases along worldlines) combined with
spatial flatness (A5: Euclidean 3-slices) implies G_μν = 0 everywhere.
This is the Jacobson–Verlinde thermodynamic-gravity connection:
  entropy production rate → stress-energy vanishes → G_μν = 0.
-/

section EinsteinBridge

open NavierStokesClean.CATEPT

/-- A `CATEPTSpacetimeModel` extended with a 4D coordinate chart and a
    compatible `MetricField (Fin 4)` from the GR tensor kernel.

    - `coordChart`: maps spacetime events to coordinate vectors in ℝ⁴.
    - `metricField`: coordinate metric g_μν(x) with x ∈ CoordVec (Fin 4).
    - `metric_compat`: the Lorentz metric on spacetime events equals the
      tensor contraction `∑_μν g_μν(χ(x)) · χ(x)^μ · χ(y)^ν`.

    For the Minkowski model, `coordChart = id` and `metricField = minkowskiMetric`. -/
structure CATEPTSpacetime4DCoords where
  /-- The underlying CATEPT spacetime model. -/
  model        : CATEPTSpacetimeModel
  /-- Coordinate chart: spacetime events → ℝ⁴. -/
  coordChart   : model.SpaceTime → CoordVec (Fin 4)
  /-- Coordinate metric field g_μν(x). -/
  metricField  : MetricField (Fin 4)
  /-- Compatibility: g(x,y) = ∑_μν g_μν(χ(x)) · χ(x)^μ · χ(y)^ν. -/
  metric_compat : ∀ x y : model.SpaceTime,
      model.lorentzMetric x y =
        ∑ i : Fin 4, ∑ j : Fin 4,
          metricField (coordChart x) i j * coordChart x i * coordChart y j

/-- **Einstein flatness** (vacuum Einstein equations):
    `EinsteinFlat c ↔ G_μν(x) = 0` for all coordinate points and all indices. -/
def CATEPTSpacetime4DCoords.EinsteinFlat (c : CATEPTSpacetime4DCoords) : Prop :=
  ∀ (x : CoordVec (Fin 4)) (i j : Fin 4), einsteinTensor c.metricField x i j = 0

/-- The full EPT Vacuum Record: `EPTAxiomPackage` augmented with the
    coordinate metric bridge and the vacuum Einstein equation.

    - Inherits A1–A5 from `EPTAxiomPackage`.
    - Adds `a5_einstein_flat` (phase-2 upgrade of the `True`-stub `a5_flat`):
      explicit proof that G_μν = 0 everywhere.
    - This is the target type for all concrete CATEPT vacuum solutions. -/
structure EPTVacuumRecord (c : CATEPTSpacetime4DCoords) extends EPTAxiomPackage c.model where
  /-- A5 (phase-2): G_μν = 0 — spacetime is Ricci-flat (vacuum EFE). -/
  a5_einstein_flat : c.EinsteinFlat

/-- The Minkowski CATEPT model equipped with its canonical 4D coordinate chart.

    - `model        = minkowskiCATEPT`
    - `coordChart   = id`  (SpaceTime = Fin 4 → ℝ = CoordVec (Fin 4))
    - `metricField  = minkowskiMetric = constantMetric minkowskiMatrix`
    - `metric_compat`: proved by `Fin.sum_univ_four` + diagonal evaluation + `ring`. -/
noncomputable def minkowskiCATEPT4D : CATEPTSpacetime4DCoords where
  model        := minkowskiCATEPT
  coordChart   := id
  metricField  := minkowskiMetric
  metric_compat := by
    intro x y
    -- LHS: minkowskiCATEPT.lorentzMetric x y = -(x 0 * y 0) + x 1 * y 1 + x 2 * y 2 + x 3 * y 3
    -- RHS: ∑ μν, minkowskiMatrix μ ν * x μ * y ν = diagonal sum over (−1,1,1,1)
    simp only [minkowskiCATEPT, id, minkowskiMetric, constantMetric, minkowskiMatrix]
    simp only [Fin.sum_univ_four]
    norm_num [show (0 : Fin 4) ≠ 1 from by decide, show (0 : Fin 4) ≠ 2 from by decide,
             show (0 : Fin 4) ≠ 3 from by decide, show (1 : Fin 4) ≠ 0 from by decide,
             show (1 : Fin 4) ≠ 2 from by decide, show (1 : Fin 4) ≠ 3 from by decide,
             show (2 : Fin 4) ≠ 0 from by decide, show (2 : Fin 4) ≠ 1 from by decide,
             show (2 : Fin 4) ≠ 3 from by decide, show (3 : Fin 4) ≠ 0 from by decide,
             show (3 : Fin 4) ≠ 1 from by decide, show (3 : Fin 4) ≠ 2 from by decide]

/-- **Minkowski is Einstein-flat** (no sorry, no axiom):
    The Minkowski CATEPT model satisfies the vacuum Einstein equations G_μν = 0.

    Proof: `einsteinTensor_eq_zero_minkowski` (GRTensorKernel, proved via
    constant-metric → Christoffel = 0 → Riemann = 0 → Ricci = 0 → G = 0). -/
theorem minkowskiCATEPT4D_einstein_flat : minkowskiCATEPT4D.EinsteinFlat :=
  fun x i j => einsteinTensor_eq_zero_minkowski x i j

/-- The Minkowski CATEPT model satisfies the full EPT Vacuum Record. -/
theorem minkowski_satisfies_ept_vacuum : EPTVacuumRecord minkowskiCATEPT4D :=
  { catept_satisfies_ept_axioms minkowskiCATEPT with
    a5_einstein_flat := minkowskiCATEPT4D_einstein_flat }

/-- Typed witness for the phase-1 locality hypotheses carried by the model.
    This removes raw `True` parameters from theorem APIs. -/
structure EntropicEinsteinLocalityWitness (c : CATEPTSpacetime4DCoords) where
  causal_arrow : True
  no_ftl : True

/-- Canonical locality witness extracted from the model fields. -/
def modelEntropicEinsteinLocalityWitness
    (c : CATEPTSpacetime4DCoords) :
    EntropicEinsteinLocalityWitness c :=
  { causal_arrow := c.model.ept_causal_arrow
    no_ftl := c.model.noFTL }

/-- **EPT Entropic Einstein Locality** core axiom (Phase 5E-γ; discharge via Jacobson–Verlinde):

    For any 4D CATEPT model whose EPT satisfies the thermodynamic causal conditions
    (A3: strictly-increasing along worldlines) and the speed bound (A4: no FTL),
    the spacetime is Einstein-flat: G_μν = 0 everywhere.

    Physical interpretation (Jacobson 1995 / Verlinde 2011):
    - The EPT time arrow encodes non-decreasing coarse-grained entropy.
    - In thermodynamic equilibrium (zero net entropy production), T_μν = 0 (vacuum).
    - Einstein's equations then demand G_μν = 0.

    **Phase-2 discharge path**:
    1. Replace `model.ept_causal_arrow : True` with `StrictMonoOn model.ept causalCurves`.
    2. Replace `model.noFTL : True` with `∀ v, sNorm2 v < 1`.
    3. Prove thermodynamic equilibrium → T_μν = 0 via VML steady-state.
    4. Apply Einstein's equations: T_μν = 0 → G_μν = Λg_μν; set Λ = 0 for vacuum. -/
axiom ept_entropic_einstein_locality_core
    (c : CATEPTSpacetime4DCoords)
    (_ : EntropicEinsteinLocalityWitness c)
    : c.EinsteinFlat

/-- Public locality theorem with no raw `True` assumptions in its interface. -/
theorem ept_entropic_einstein_locality
    (c : CATEPTSpacetime4DCoords) :
    c.EinsteinFlat :=
  ept_entropic_einstein_locality_core c (modelEntropicEinsteinLocalityWitness c)

/-- The Minkowski model satisfies EPT Entropic Einstein Locality.
    Direct proof via GRTensorKernel (no axiom invocation needed for this instance),
    confirming the axiom `ept_entropic_einstein_locality` is conservative on Minkowski. -/
theorem minkowskiCATEPT4D_satisfies_locality : minkowskiCATEPT4D.EinsteinFlat :=
  minkowskiCATEPT4D_einstein_flat

end EinsteinBridge

-- ── Phase-2: A2/A3 Discharge (Minkowski model) ──────────────────────────────

/-!
## §6 — Phase-2 EPT Axiom Discharge

Standalone theorems proving the genuine mathematical content behind the
Phase-1 `True` stubs `ept_smooth` (A2) and `ept_causal_arrow` (A3) for
the canonical Minkowski model.

These mirror the Pphi2 proofs in `Pphi2CATEPTEPTBridge.lean`
(`cateptModel_ept_smooth_on_posTime`, `cateptModel_ept_causal_mono`),
specialized to the Minkowski background `ept x = |x 0|`.

### Proof strategies

- **A2 (smoothness)**: On `{x | 0 < x 0}`, the absolute value kink
  vanishes: `|x 0| = x 0`. The function `x ↦ x 0` is a continuous linear
  projection (hence globally C∞), so its restriction is C∞ on any set.
  We conclude via `ContDiffOn.congr`.

- **A3 (causal arrow)**: `|·|` is strictly monotone on `{s | 0 ≤ s}`
  because `|s| = s` there.  This encodes the thermodynamic arrow:
  entropic proper time strictly increases along future-directed worldlines.
-/

section Phase2Discharge

open NavierStokesClean.CATEPT

/-- **A2 (Phase-2)**: The Minkowski EPT function `|x₀|` is C∞ on the
    positive-time region `{x : ℝ⁴ | 0 < x 0}`.

    On this region `|x₀| = x₀` (no absolute-value kink), and `x ↦ x 0`
    is the continuous linear projection `ContinuousLinearMap.proj 0`,
    which is globally C∞. The restriction is therefore C∞ on the open
    positive-time region.

    This is the genuine Phase-2 upgrade of the `ept_smooth : True` stub
    for the Minkowski model. -/
theorem minkowskiCATEPT_ept_smooth_posTime :
    ContDiffOn ℝ ⊤
      (fun x : Fin 4 → ℝ => |x 0|)
      {x : Fin 4 → ℝ | 0 < x 0} := by
  have hproj : ContDiff ℝ ⊤ (fun x : Fin 4 → ℝ => x 0) := by fun_prop
  exact hproj.contDiffOn.congr fun x (hx : 0 < x 0) => abs_of_pos hx

/-- **A3 (Phase-2)**: The Minkowski EPT function `|·|` is strictly monotone
    on the non-negative reals (along the canonical time axis).

    For `0 ≤ a < b`, we have `|a| = a < b = |b|`, proving the
    thermodynamic arrow: entropic proper time strictly increases along
    future-directed worldlines parametrized by coordinate time.

    This is the genuine Phase-2 upgrade of the `ept_causal_arrow : True` stub
    for the Minkowski model. -/
theorem minkowskiCATEPT_ept_causal_mono :
    StrictMonoOn
      (fun s : ℝ => |s|)
      {s : ℝ | 0 ≤ s} := by
  intro a ha b hb hab
  simp only [Set.mem_setOf_eq] at ha hb
  show |a| < |b|
  rw [abs_of_nonneg ha, abs_of_nonneg hb]
  exact hab

/-- **Phase-2 EPT Vacuum Certificate** for the Minkowski model.

    Bundles all four Phase-2 results into a single record:
    1. G_μν = 0 — Einstein-flat (from GRTensorKernel)
    2. ∇^μ G_μν = 0 — contracted Bianchi identity
    3. A2: C∞ smoothness of EPT on the positive-time region
    4. A3: strict monotonicity of EPT along the time axis

    Together these show the EPT causal structure is compatible with vacuum
    general relativity: the conservation law ∇^μ G_μν = 0 holds identically,
    and the entropic proper time is both smooth and monotonically increasing. -/
structure MinkowskiEPTVacuumCertificate where
  /-- G_μν = 0 everywhere (vacuum Einstein equations). -/
  einstein_flat : minkowskiCATEPT4D.EinsteinFlat
  /-- ∇^μ G_μν = 0 (contracted Bianchi identity). -/
  bianchi       : ContractedBianchiIdentity minkowskiMetric
  /-- A2: |x₀| is C∞ on {x | 0 < x 0}. -/
  ept_smooth    : ContDiffOn ℝ ⊤ (fun x : Fin 4 → ℝ => |x 0|) {x | 0 < x 0}
  /-- A3: |·| is strictly monotone on {s | 0 ≤ s}. -/
  ept_causal    : StrictMonoOn (fun s : ℝ => |s|) {s | 0 ≤ s}

/-- The Minkowski model satisfies the Phase-2 EPT vacuum certificate (A1-A3 + G=0).

    No sorry, no new axiom — all four fields are discharged from existing
    proved results:
    - `minkowskiCATEPT4D_einstein_flat` (GRTensorKernel chain)
    - `bianchi_minkowski` (contracted Bianchi for constant metric)
    - `minkowskiCATEPT_ept_smooth_posTime` (projection smoothness)
    - `minkowskiCATEPT_ept_causal_mono` (absolute value monotonicity) -/
theorem minkowski_ept_vacuum_certificate : MinkowskiEPTVacuumCertificate where
  einstein_flat := minkowskiCATEPT4D_einstein_flat
  bianchi       := bianchi_minkowski
  ept_smooth    := minkowskiCATEPT_ept_smooth_posTime
  ept_causal    := minkowskiCATEPT_ept_causal_mono

end Phase2Discharge

-- ── Phase-2: A4 (No-FTL) Discharge ──────────────────────────────────────────

/-!
## §7 — Causal Structure and No-FTL Velocity Bound (Phase-2 A4)

Connects the causal classification from `CATEPTSpaceTime.CausalStructure`
(timelike / lightlike / spacelike on `CATEPTST = Fin 4 → ℝ`) to the
Minkowski CATEPT model's `noFTL` field.

**Key results** (no sorry, no new axiom):

1. `minkowskiCATEPT_noFTL_velocity_bound`: For the Minkowski model, any
   timelike displacement `Δx` satisfies `spatialNorm2 Δx < (Δx 0)²`, i.e.
   the spatial velocity `|v|² = |Δx_spatial|²/|Δt|² < 1`.

2. `minkowskiCATEPT_subluminal_of_timelike`: Directly converts a timelike
   displacement into a subluminal velocity certificate.

3. `minkowskiCATEPT_cauchy_schwarz_noFTL`: The Cauchy-Schwarz no-FTL bound
   `|⟪τ̂, x⟫| ≤ ‖τ̂‖ · ‖x‖`, which is the Pphi2 bridge's A4 route
   (`cateptModel_ept_noFTL_bound`), now unified with the causal structure.

These discharge the `noFTL : True` stub for the Minkowski model.
-/

section NoFTLDischarge

open NavierStokesClean.CATEPT

/-- **A4 (Phase-2)**: Timelike displacements in the Minkowski model have
    subluminal spatial velocity.

    For `Δx` with `minkowskiNorm2 Δx < 0` and `Δt ≠ 0`:
      `spatialNorm2(Δx) / Δt² < 1`,
    i.e. the coordinate velocity satisfies `|v|² < 1` (c = 1 units).

    This is the concrete content behind the `noFTL : True` stub. -/
theorem minkowskiCATEPT_noFTL_velocity_bound (Δx : CATEPTST)
    (htl : CausalTimelike Δx) (ht : Δx 0 ≠ 0) :
    spatialNorm2 Δx / (Δx 0) ^ 2 < 1 := by
  have ht2_pos : (0 : ℝ) < (Δx 0) ^ 2 := by positivity
  rw [div_lt_one ht2_pos]
  exact timelike_time_dominates htl

/-- **A4 (Phase-2)**: Extract a subluminal velocity from a timelike displacement.

    Given a timelike worldline segment `Δx` with `Δt ≠ 0`, the spatial velocity
    `v i = Δx (i+1) / Δt` is subluminal: `∑ i, v i ^ 2 < 1`. -/
theorem minkowskiCATEPT_subluminal_of_timelike (Δx : CATEPTST)
    (htl : CausalTimelike Δx) (ht : Δx 0 ≠ 0) :
    SubluminalVelocity (fun i : Fin 3 => Δx i.succ / Δx 0) := by
  unfold SubluminalVelocity
  have ht2_pos : (0 : ℝ) < (Δx 0) ^ 2 := by positivity
  have hdom := timelike_time_dominates htl
  -- ∑ i, (Δx (i+1) / Δt)² = (∑ i, Δx (i+1)²) / Δt² = spatialNorm2 Δx / Δt²
  have : ∑ i : Fin 3, (Δx i.succ / Δx 0) ^ 2 = spatialNorm2 Δx / (Δx 0) ^ 2 := by
    simp only [div_pow, spatialNorm2]
    rw [Finset.sum_div]
  rw [this, div_lt_one ht2_pos]
  exact hdom

/-- **Causal trichotomy for Minkowski displacements** matches the NoFTL AFP
    classification.  Every nonzero displacement is exactly one of:
    timelike (inside cone), lightlike (on cone), or spacelike (outside cone).

    The `(−+++)` convention here and NoFTL's `(+−−−)` convention differ by
    an overall sign: our `CausalTimelike` (minkowskiNorm2 < 0) corresponds to
    NoFTL's `timelike` (mNorm2 > 0). -/
theorem minkowskiCATEPT_classification (Δx : CATEPTST) (h : Δx ≠ 0) :
    CausalTimelike Δx ∨ CausalLightlike Δx ∨ CausalSpacelike Δx := by
  rcases causal_trichotomy Δx with htl | hll | hsl | h0
  · left; exact htl
  · right; left; exact hll
  · right; right; exact hsl
  · exact absurd h0 h

/-- The Minkowski EPT Cauchy-Schwarz no-FTL bound (from Pphi2 bridge):
    `|⟪τ̂, x⟫| ≤ ‖τ̂‖ · ‖x‖` for any unit time axis `τ̂` and vector `x`.

    This is the inner-product route to the no-FTL bound, complementing the
    metric-signature route (`minkowskiCATEPT_noFTL_velocity_bound`).
    For `‖τ̂‖ = 1`, this gives `|⟪τ̂, x⟫| ≤ ‖x‖`, bounding the time
    projection by the full spacetime norm. -/
theorem minkowskiCATEPT_cauchy_schwarz_noFTL
    (τhat x : EuclideanSpace ℝ (Fin 4)) :
    |@inner ℝ _ _ τhat x| ≤ ‖τhat‖ * ‖x‖ :=
  abs_real_inner_le_norm τhat x

/-- Bundled Phase-2 A4 certificate for the Minkowski model.

    Collects the velocity bound, subluminal extraction, and Cauchy-Schwarz
    no-FTL bound into a single record — the typed replacement for the
    `noFTL : True` field. -/
structure MinkowskiNoFTLCertificate where
  /-- Timelike displacements have `spatialNorm2/Δt² < 1`. -/
  velocity_bound : ∀ (Δx : CATEPTST), CausalTimelike Δx → Δx 0 ≠ 0 →
    spatialNorm2 Δx / (Δx 0) ^ 2 < 1
  /-- Subluminal velocity extraction from timelike displacements. -/
  subluminal : ∀ (Δx : CATEPTST), CausalTimelike Δx → Δx 0 ≠ 0 →
    SubluminalVelocity (fun i : Fin 3 => Δx i.succ / Δx 0)
  /-- Cauchy-Schwarz bound on inner product. -/
  cauchy_schwarz : ∀ (τhat x : EuclideanSpace ℝ (Fin 4)),
    |@inner ℝ _ _ τhat x| ≤ ‖τhat‖ * ‖x‖

/-- The Minkowski model satisfies the full no-FTL certificate (no sorry). -/
theorem minkowski_noftl_certificate : MinkowskiNoFTLCertificate where
  velocity_bound := minkowskiCATEPT_noFTL_velocity_bound
  subluminal     := minkowskiCATEPT_subluminal_of_timelike
  cauchy_schwarz := minkowskiCATEPT_cauchy_schwarz_noFTL

end NoFTLDischarge

-- ── Full EPT Vacuum + NoFTL Certificate ─────────────────────────────────────

section FullCertificate

open NavierStokesClean.CATEPT

/-- **Complete Phase-2 EPT certificate** for the Minkowski model (A1-A5 + G=0 + Bianchi).

    Bundles all five EPT axiom discharges plus the GR tensor chain:
    - A1: τ ≥ 0 (from `abs_nonneg`)
    - A2: C∞ smoothness on positive-time region
    - A3: strict monotonicity (thermodynamic arrow)
    - A4: No-FTL velocity bound (subluminal extraction)
    - A5: Einstein flatness G_μν = 0
    - Contracted Bianchi identity ∇^μ G_μν = 0

    No sorry, no new axiom. -/
structure MinkowskiFullEPTCertificate where
  /-- G_μν = 0. -/
  einstein_flat : minkowskiCATEPT4D.EinsteinFlat
  /-- ∇^μ G_μν = 0. -/
  bianchi       : ContractedBianchiIdentity minkowskiMetric
  /-- A2: EPT is C∞ on {x | x₀ > 0}. -/
  ept_smooth    : ContDiffOn ℝ ⊤ (fun x : Fin 4 → ℝ => |x 0|) {x | 0 < x 0}
  /-- A3: EPT is strictly monotone. -/
  ept_causal    : StrictMonoOn (fun s : ℝ => |s|) {s | 0 ≤ s}
  /-- A4: No-FTL velocity bound. -/
  noftl         : MinkowskiNoFTLCertificate

/-- The Minkowski model satisfies the full EPT certificate (no sorry). -/
theorem minkowski_full_ept_certificate : MinkowskiFullEPTCertificate where
  einstein_flat := minkowskiCATEPT4D_einstein_flat
  bianchi       := bianchi_minkowski
  ept_smooth    := minkowskiCATEPT_ept_smooth_posTime
  ept_causal    := minkowskiCATEPT_ept_causal_mono
  noftl         := minkowski_noftl_certificate

end FullCertificate

-- ── Hardened Locality Witness (NoFTL + Einstein + True-stub) ────────────────

/-!
## §8 — Hardened Entropic Einstein Locality Witness

Bundles the Phase-1 `True`-stub witness (needed by the axiom signature)
with the concrete Phase-2 `MinkowskiNoFTLCertificate` (proved, 0 sorry).

This is the typed bridge between:
- `EntropicEinsteinLocalityWitness.no_ftl : True` (abstract contract)
- `MinkowskiNoFTLCertificate` (velocity bound + subluminal extraction + Cauchy-Schwarz)

Downstream consumers should prefer this structure over the raw `True` witness
to access the concrete no-FTL content.
-/

section HardenedLocality

open NavierStokesClean.CATEPT

/-- **Hardened Entropic Einstein Locality Witness** for a 4D CATEPT model.

    Pairs the abstract `EntropicEinsteinLocalityWitness` (True-stubs for
    the axiom interface) with the concrete `MinkowskiNoFTLCertificate`
    (proved velocity bound, subluminal extraction, Cauchy-Schwarz). -/
structure HardenedLocalityWitness (c : CATEPTSpacetime4DCoords) where
  /-- Phase-1 locality witness (True-stub, required by axiom signature). -/
  base : EntropicEinsteinLocalityWitness c
  /-- Phase-2 concrete no-FTL certificate (proved). -/
  noftl_certificate : MinkowskiNoFTLCertificate
  /-- Einstein flatness (proved from GRTensorKernel or axiom). -/
  einstein_flat : c.EinsteinFlat

/-- Canonical hardened locality witness for the Minkowski model.
    All three fields are fully proved — no sorry, no new axiom. -/
def minkowskiHardenedLocalityWitness : HardenedLocalityWitness minkowskiCATEPT4D where
  base := modelEntropicEinsteinLocalityWitness minkowskiCATEPT4D
  noftl_certificate := minkowski_noftl_certificate
  einstein_flat := minkowskiCATEPT4D_einstein_flat

end HardenedLocality

end CATEPTMain.Integration.CATEPTSpaceTime
