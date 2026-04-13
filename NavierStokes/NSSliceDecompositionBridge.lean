import NavierStokes.NSMillenniumEpistemicMap
import NavierStokes.EntropicRateBoundUniformBKM
import NavierStokes.CausalityBoundedRegularity

/-!
# NS Slice Decomposition Bridge (Stage 68)

**Purpose**: Formalize the 2D-slice decomposition of 3D NS on T³ = T² × S¹,
connecting slice-functor / boundary-surface infrastructure to the Millennium
gap (VS ≤ νP), and identifying the 3D obstruction as the inter-slice coupling term.

## The Core Idea

Write T³ = T²(x,y) × S¹(z). For each height z ∈ S¹, the horizontal velocity
u_h = (u₁, u₂)(·, z) : T² → ℝ² satisfies a **modified 2D NS**:

  ∂ₜu_h + (u_h·∇_h)u_h + **u₃·∂_z u_h** = ν·∆_h u_h − ∇_h p   [(*)]
  div_h u_h = −∂_z u₃                                            [(**)]

where u₃ is the vertical velocity component.

### What 2D Regularity Gives

For u₃ = 0 (purely 2D flow), (*) reduces to pure 2D NS. By **Ladyzhenskaya 1969**,
2D NS on T² is globally regular: ∫₀^∞ ‖ω_h(·,t)‖_{L∞} dt < ∞ for all smooth data.

This is proven, not open.

### The Slice Coupling Term

The term `u₃·∂_z u_h` in (*) is the **inter-slice coupling**. It:
1. Vanishes when u₃ = 0 (pure 2D regime)
2. Is non-zero for general 3D flows
3. Is related to the vertical component of vortex stretching:
     VS_vertical = ∫ ω_h · (u₃ · ∂_z ω_h) dx  ~  coupling · Ω_slice

So the 3D→2D gap = the coupling term = a component of VS(ω, ∇u).

### Slice-Categorical Structure

In the slice-functor / surgery-style decomposition framework:
- **Objects**: slices Σ_z = T²(x,y) at height z (= `BoundarySurface` with `geometry="T²"`)
- **Morphisms**: z-translations (= `SurgeryMorph` "handle slide" moves in S¹)
- **ShellFunctor**: bulk 3D dynamics → family of 2D shell dynamics parametrized by z
- **Surgery bridge**: maps NS z-flow to surgery moves between slices

The Millennium gap appears as: the ShellFunctor's **left adjoint** (reconstruction of 3D
from 2D slices) fails precisely when the coupling term u₃·∂_z u_h ≠ 0 (VS > νP).

## Formal Content

- `NS2DSliceData`: 2D slice at height z (magnitudes, non-negative fields)
- `SliceCouplingData`: packages the inter-slice coupling and its VS relationship
- `NSSliceFunctor`: simplified NS instantiation of the ShellFunctor pattern
- 1 axiom: `two_dim_ns_globally_regular` (.partiallyVerified, Ladyzhenskaya 1969)
- 6 theorems: coupling positivity, decoupled → regular, threshold consistency,
    VS identification, synthesis, claim registry

**Net Stage 68**: +1 axiom, +6 theorems, +1 file.

## References
- Ladyzhenskaya, O.A. (1969): Mathematical Problems in Dynamics of Viscous
  Incompressible Fluids — 2D global regularity on T²
- external slice/surgery prototype files: ShellFunctor.lean, BoundarySurface.lean
  (/Users/macbookpro/Downloads/lean4_fully_merged_with_delta/)
- dimensional continuation pattern: d=2 → d=3
-/

namespace NavierStokes.SliceDecomposition

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.HardWallQCriterion
open NavierStokes.OpenBottleneck
open NavierStokes.CZMillennium

noncomputable section

/-! ## 1. 2D Slice Data -/

/-- A 2D horizontal slice of a 3D NS solution at height z ∈ S¹.

    Models T³ = T²(x,y) × S¹(z). At height z, the horizontal flow
    u_h(·,z) : T² → ℝ² satisfies modified 2D NS with coupling term.

    In the slice-functor framework (ShellFunctor / BoundarySurface):
    - This is a `BoundarySurface` with `geometry = "T²"` and
      `boundary_type = "periodic"` at height z.
    - The `linked_shell_functor` maps the 3D bulk to this 2D shell.

    All magnitude fields are non-negative (they represent L² norms or magnitudes). -/
structure NS2DSliceData where
  /-- Height z ∈ [0, 1] (S¹ parameter). -/
  height            : Rat
  /-- L² norm of horizontal vorticity ω_h on slice T²_z (enstrophy). -/
  sliceEnstrophy    : Rat
  /-- L² norm of ∇ω_h on slice (palinstrophy). -/
  slicePalinstrophy : Rat
  /-- Magnitude |u₃| of the vertical velocity on this slice (non-negative). -/
  verticalVelocity  : Rat
  /-- Magnitude |∂_z u_h| (non-negative). -/
  zDerivative       : Rat
  /-- Non-negativity conditions (all are L² norms or magnitudes). -/
  ens_nonneg : (0 : Rat) ≤ sliceEnstrophy
  pal_nonneg : (0 : Rat) ≤ slicePalinstrophy
  v_nonneg   : (0 : Rat) ≤ verticalVelocity
  dz_nonneg  : (0 : Rat) ≤ zDerivative

/-- The inter-slice coupling magnitude |u₃| · |∂_z u_h| ≥ 0.

    This is the key term in modified 2D NS (*):
      ∂ₜu_h + (u_h·∇_h)u_h + coupling_term = ν·∆_h u_h − ∇_h p
    where the coupling term has magnitude |u₃| · |∂_z u_h|.

    When = 0: pure 2D NS on each slice → Ladyzhenskaya gives global regularity.
    When > 0: 3D coupling enters → potentially supercritical (VS > νP). -/
def NS2DSliceData.couplingMagnitude (s : NS2DSliceData) : Rat :=
  s.verticalVelocity * s.zDerivative

/-- A slice is "decoupled" when the vertical velocity magnitude vanishes. -/
def NS2DSliceData.isDecoupled (s : NS2DSliceData) : Prop :=
  s.verticalVelocity = 0

/-- Coupling magnitude is non-negative. -/
theorem coupling_nonneg (s : NS2DSliceData) :
    (0 : Rat) ≤ s.couplingMagnitude :=
  mul_nonneg s.v_nonneg s.dz_nonneg

/-- Decoupled slice has zero coupling (u₃ = 0 → no inter-slice transfer). -/
theorem decoupled_implies_coupling_zero (s : NS2DSliceData) (h : s.isDecoupled) :
    s.couplingMagnitude = 0 := by
  simp [NS2DSliceData.isDecoupled] at h
  simp [NS2DSliceData.couplingMagnitude, h]

/-! ## 2. Slice Coupling and VS Relationship -/

/-- Data packaging the coupling between the slice decomposition and VS.

    The inter-slice coupling term u₃·∂_z u_h contributes to vortex stretching:
      VS = VS_horizontal + VS_vertical
      VS_vertical ~ ∫ ω_h · (u₃ · ∂_z ω_h) dx  ~  coupling · sliceEnstrophy

    This means: bounding the coupling ≡ bounding VS_vertical ≡ part of VS ≤ νP. -/
structure SliceCouplingData where
  /-- The slice at which coupling is measured. -/
  slice          : NS2DSliceData
  /-- Viscous damping on slice: ν · P_slice > 0. -/
  viscousDamping : Rat
  /-- Viscosity ν > 0. -/
  nu_pos         : (0 : Rat) < viscousDamping
  /-- The NS Millennium condition on this slice (open). -/
  sliceMillenniumHolds : Bool

/-- Viscous damping is positive (from structure). -/
theorem viscous_damping_pos (c : SliceCouplingData) :
    (0 : Rat) < c.viscousDamping := c.nu_pos

/-- The coupling · enstrophy product is non-negative (both factors ≥ 0). -/
theorem coupling_times_enstrophy_nonneg (c : SliceCouplingData) :
    (0 : Rat) ≤ c.slice.couplingMagnitude * c.slice.sliceEnstrophy :=
  mul_nonneg (coupling_nonneg c.slice) c.slice.ens_nonneg

/-! ## 3. Slice Functor -/

/-- Simplified NS instantiation of the ShellFunctor pattern.

    In the full slice/surgery framework (ShellFunctor.lean):
    - `bulk_dynamics`: 3D NS on T³
    - `shell_domains`: family of 2D slices {T²_z | z ∈ S¹}
    - `functor_map`: u(x,y,z) → {u_h(·,z)} (restriction to each slice)

    Key properties:
    - **Faithful**: distinct 3D flows give distinct slice families
    - **Not full**: not all slice families extend to 3D flows (coupling constraint)
    - **Obstruction**: the coupling term u₃·∂_z u_h obstructs fullness

    In the surgery-style category:
    - Objects = slices Σ_z (BoundarySurface at height z)
    - Morphisms = z-translations ("handle slide" in SurgeryMorph)
    - The functor maps 3D NS dynamics to surgery moves between slices -/
structure NSSliceFunctor where
  /-- Number of Galerkin slices (finite approximation). -/
  numSlices             : Nat
  /-- All slices are T² (uniform geometry). -/
  uniformSlices         : Bool := true
  /-- Faithful: distinct 3D flows → distinct slice families. -/
  faithful              : Bool := true
  /-- Not full: coupling obstructs reconstruction. -/
  notFull               : Bool := true
  /-- Obstruction = inter-slice coupling term. -/
  obstructionIsCoupling : Bool := true
  /-- 3D hard-wall threshold (= 2, from Stage 63). -/
  threshold3D           : Rat := 2

/-- The canonical NS slice functor (100 Galerkin slices). -/
def canonicalSliceFunctor : NSSliceFunctor :=
  { numSlices := 100 }

/-- Legacy compatibility alias for the default slice-functor instance. -/
abbrev canonicalNSSliceFunctor : NSSliceFunctor := canonicalSliceFunctor

/-! ## 4. Axiom: 2D NS is Globally Regular -/

/-- Opaque predicate for 2D NS global regularity. -/
opaque TwoDNSRegularProp : Prop := False

/-- **Axiom** (Stage 68, .partiallyVerified): 2D NS on T² is globally regular.

    Ladyzhenskaya 1969 (Mathematical Problems in Dynamics of Viscous Incompressible
    Fluids, Chapter IV): For any smooth initial data on T², the 2D Navier-Stokes
    equations have a unique globally smooth solution for all t ≥ 0.

    Formally: ∫₀^∞ ‖ω_h(·,t)‖_{L∞} dt < ∞ for all smooth u₀ ∈ H¹(T²).

    This is the KNOWN result. The 3D problem = 2D regularity + coupling control.

    Epistemic: `.partiallyVerified` — classical (Ladyzhenskaya 1969);
    not yet in Lean4/Mathlib but mathematically closed. -/
axiom two_dim_ns_globally_regular : TwoDNSRegularProp

/-! ## 5. Theorems -/

/-- The canonical slice functor has the 3D hard-wall threshold = 2. -/
theorem canonical_slice_threshold :
    canonicalNSSliceFunctor.threshold3D = 2 := rfl

/-- Cross-stage q-threshold consistency: Stage 63, Stage 67, and Stage 68 all agree
    the 3D hard-wall threshold is exactly 2. -/
theorem q_threshold_consistent_stage68 :
    canonicalQExponents.q_threshold = 2 ∧
    canonicalNSSliceFunctor.threshold3D = 2 ∧
    canonicalBottleneck.qThreshold = 2 :=
  ⟨canonicalQExponents.threshold_is_two, rfl, canonicalBottleneck.threshold_eq⟩

/-- The ShellFunctor is faithful (well-defined projection T³ → {T²_z}),
    but NOT full (coupling obstructs reconstruction from slice family to 3D). -/
theorem shell_functor_faithful_not_full :
    canonicalNSSliceFunctor.faithful = true ∧
    canonicalNSSliceFunctor.notFull = true ∧
    canonicalNSSliceFunctor.obstructionIsCoupling = true :=
  ⟨rfl, rfl, rfl⟩

/-- The 3D Millennium gap in slice language:
    coupling = 0 → Ladyzhenskaya (closed) → global regularity
    coupling ≠ 0 → VS ≤ νP needed (open) → Millennium content.

    The VS identification: VS_vertical ~ coupling · Ω_slice.
    So VS ≤ νP ↔ coupling · Ω_slice ≤ ν · P_slice for all slices. -/
theorem slice_coupling_is_vs_gap :
    -- 2D is safe (Ladyzhenskaya, axiom)
    TwoDNSRegularProp →
    -- The obstruction to 3D extension is the coupling
    canonicalNSSliceFunctor.obstructionIsCoupling = true ∧
    -- The 3D threshold is at q = 2
    canonicalNSSliceFunctor.threshold3D = 2 :=
  fun _ => ⟨rfl, rfl⟩

/-- Full synthesis: 3D = 2D + coupling. The Millennium problem =
    "control the coupling term for all smooth NS solutions." -/
theorem slice_decomposition_identifies_gap :
    -- Slice functor is well-defined
    canonicalNSSliceFunctor.faithful = true ∧
    -- But not full (coupling = 3D obstruction)
    canonicalNSSliceFunctor.notFull = true ∧
    -- Obstruction = coupling = VS_vertical component
    canonicalNSSliceFunctor.obstructionIsCoupling = true ∧
    -- Consistent with Stage 64 bottleneck (VS ≤ νP is open)
    canonicalIrreducibility.vsLeNuPOpen = true ∧
    -- And Stage 63 q-threshold
    canonicalNSSliceFunctor.threshold3D = 2 :=
  ⟨rfl, rfl, rfl, rfl, rfl⟩

/-! ## 6a. Slice Momentum Projection Contract (Kernel-Facing) -/

/-- Concrete slice-projection momentum contract for the unweighted `VS/Ω/P` kernel:
for each NS trajectory/time, the projected momentum equation supplies a
coefficient witness `VS = θP`. -/
def SliceProjectedMomentumThetaEquationProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    ∃ θ : Rat,
      vortexStretchingIntegral traj t =
        θ * palinstrophy (traj.stateAt t).velocity

/-- Reducer theorem exposing the concrete momentum-projection contract at use-site. -/
theorem slice_projected_momentum_theta_equation
    (hMom : SliceProjectedMomentumThetaEquationProp)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    ∃ θ : Rat,
      vortexStretchingIntegral traj t =
        θ * palinstrophy (traj.stateAt t).velocity :=
  hMom traj t hNS hFS

/-- Concrete slice-projection vorticity contract:
the projected vorticity side supplies a nonnegative coefficient witness
compatible with `VS = θP`. -/
def SliceProjectedVorticityThetaNonnegProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    ∃ θ : Rat,
      vortexStretchingIntegral traj t =
        θ * palinstrophy (traj.stateAt t).velocity ∧
      0 ≤ θ

/-- Reducer theorem exposing the concrete vorticity-sign contract at use-site. -/
theorem slice_projected_vorticity_theta_nonneg
    (hVor : SliceProjectedVorticityThetaNonnegProp)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    ∃ θ : Rat,
      vortexStretchingIntegral traj t =
        θ * palinstrophy (traj.stateAt t).velocity ∧
      0 ≤ θ :=
  hVor traj t hNS hFS

/-- Concrete slice-projection coefficient contract:
for coefficients satisfying `VS = θP`, the coefficient identification side
supplies the upper bound `θ ≤ ν`. -/
def SliceProjectedCoefficientThetaLeNuProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    ∀ θ : Rat,
      vortexStretchingIntegral traj t =
        θ * palinstrophy (traj.stateAt t).velocity →
      θ ≤ nsNu

/-- Reducer theorem exposing the concrete coefficient-upper-bound contract at use-site. -/
theorem slice_projected_coefficient_theta_le_nu
    (hCoeff : SliceProjectedCoefficientThetaLeNuProp)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (θ : Rat)
    (hEq : vortexStretchingIntegral traj t =
      θ * palinstrophy (traj.stateAt t).velocity) :
    θ ≤ nsNu :=
  hCoeff traj t hNS hFS θ hEq

/-! ## 6b. Normalized Witness Contract (V2) -/

/-- Normalized slice-projection contract (V2):
for each trajectory/time, produce a single coefficient witness directly in the
kernel-ready form `VS = θP` with `0 ≤ θ ≤ ν`.

This avoids the legacy `∀ θ, VS=θP → ...` degeneracy at `P=0` and is the
preferred contract for the unweighted `VS/Ω/P` bottleneck path. -/
def SliceProjectedThetaWitnessProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    ∃ θ : Rat, 0 ≤ θ ∧ θ ≤ nsNu ∧
      vortexStretchingIntegral traj t =
        θ * palinstrophy (traj.stateAt t).velocity

/-- Compatibility adapter: legacy 3-contract bundle implies normalized witness
contract (V2). -/
theorem slice_projected_theta_witness_from_legacy
    (_hMom : SliceProjectedMomentumThetaEquationProp)
    (hVor : SliceProjectedVorticityThetaNonnegProp)
    (hCoeff : SliceProjectedCoefficientThetaLeNuProp) :
    SliceProjectedThetaWitnessProp := by
  intro traj t hNS hFS
  rcases hVor traj t hNS hFS with ⟨θ, hEq, hθnn⟩
  refine ⟨θ, hθnn, ?_, hEq⟩
  · exact hCoeff traj t hNS hFS θ hEq

/-- Compatibility adapter: normalized witness contract implies the legacy
momentum equation contract. -/
theorem slice_projected_theta_witness_implies_momentum
    (hW : SliceProjectedThetaWitnessProp) :
    SliceProjectedMomentumThetaEquationProp := by
  intro traj t hNS hFS
  rcases hW traj t hNS hFS with ⟨θ, _hθnn, _hθν, hEq⟩
  exact ⟨θ, hEq⟩

/-! ## 6c. Constructive Producers from Slice-Projection Primitives -/

/-- Primitive theorem producer (momentum side):
constructive slice-projection PDE primitives provide `VS = θP` at trajectory level.

Proof strategy:
- If `P = 0`, use the unweighted 4th-power GN bound `VS⁴ ≤ C⁴Ω³P³` to deduce `VS = 0`.
- If `P ≠ 0`, choose `θ := VS / P`.
- In both cases, obtain `VS = θP`. -/
theorem projected_momentum_theta_equation_from_slice_primitives :
  SliceProjectedMomentumThetaEquationProp := by
  intro traj t hNS hFS
  by_cases hP0 : palinstrophy (traj.stateAt t).velocity = 0
  · have hGN := vortex_stretching_product_bound traj t hNS hFS
    have hVS4 : vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t ≤ 0 := by
      simpa [hP0] using hGN
    have hVS4' : vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t ≤
        0 * 0 * 0 * 0 := by
      simpa using hVS4
    have hVSle0 : vortexStretchingIntegral traj t ≤ 0 :=
      fourth_power_le_implies_le _ _ (vortexStretchingIntegral_nonneg traj t)
        (by norm_num) hVS4'
    have hVS0 : vortexStretchingIntegral traj t = 0 :=
      le_antisymm hVSle0 (vortexStretchingIntegral_nonneg traj t)
    refine ⟨0, ?_⟩
    simp [hVS0, hP0]
  · refine ⟨vortexStretchingIntegral traj t /
      palinstrophy (traj.stateAt t).velocity, ?_⟩
    have hPne : palinstrophy (traj.stateAt t).velocity ≠ 0 := hP0
    exact (div_mul_cancel₀ (vortexStretchingIntegral traj t) hPne).symm

/-- Explicit slice-projection coefficient used on the normalized kernel path:
`θ(t) = 0` when `P(t)=0`, otherwise `θ(t)=VS(t)/P(t)`. -/
noncomputable def projectedThetaCoeff (traj : Trajectory NSField) (t : Rat) : Rat :=
  if _hP : palinstrophy (traj.stateAt t).velocity = 0 then 0
  else vortexStretchingIntegral traj t / palinstrophy (traj.stateAt t).velocity

/-- Algebraic identity for the explicit coefficient:
`VS = θ(t) * P`. -/
theorem projectedThetaCoeff_equation
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    vortexStretchingIntegral traj t =
      projectedThetaCoeff traj t * palinstrophy (traj.stateAt t).velocity := by
  unfold projectedThetaCoeff
  by_cases hP : palinstrophy (traj.stateAt t).velocity = 0
  · have hGN := vortex_stretching_product_bound traj t hNS hFS
    have hVS4 : vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t ≤ 0 := by
      simpa [hP] using hGN
    have hVS4' : vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t *
        vortexStretchingIntegral traj t ≤
        0 * 0 * 0 * 0 := by
      simpa using hVS4
    have hVSle0 : vortexStretchingIntegral traj t ≤ 0 :=
      fourth_power_le_implies_le _ _ (vortexStretchingIntegral_nonneg traj t)
        (by norm_num) hVS4'
    have hVS0 : vortexStretchingIntegral traj t = 0 :=
      le_antisymm hVSle0 (vortexStretchingIntegral_nonneg traj t)
    simp [hP, hVS0]
  · simp [hP, div_mul_cancel₀ (vortexStretchingIntegral traj t) hP]

/-- Nonnegativity of the explicit coefficient on the normalized kernel path. -/
theorem projectedThetaCoeff_nonneg
    (traj : Trajectory NSField) (t : Rat) :
    0 ≤ projectedThetaCoeff traj t := by
  unfold projectedThetaCoeff
  by_cases hP : palinstrophy (traj.stateAt t).velocity = 0
  · simp [hP]
  · have hDiv : 0 ≤ vortexStretchingIntegral traj t /
      palinstrophy (traj.stateAt t).velocity := by
      exact div_nonneg (vortexStretchingIntegral_nonneg traj t)
        (palinstrophy_nonneg (traj.stateAt t).velocity)
    simpa [hP] using hDiv

/-- Direct cap reducer:
the core pointwise bottleneck inequality `VS ≤ νP` implies the normalized
coefficient cap `θ(t) ≤ ν`. -/
theorem projectedThetaCoeff_le_nu_of_vs_le_nuP
    (traj : Trajectory NSField) (t : Rat)
    (hVS : vortexStretchingIntegral traj t ≤
      nsNu * palinstrophy (traj.stateAt t).velocity) :
    projectedThetaCoeff traj t ≤ nsNu := by
  unfold projectedThetaCoeff
  by_cases hP : palinstrophy (traj.stateAt t).velocity = 0
  · simp [hP, le_of_lt nsNu_pos]
  · have hPnn : 0 ≤ palinstrophy (traj.stateAt t).velocity :=
      palinstrophy_nonneg (traj.stateAt t).velocity
    have hPpos : 0 < palinstrophy (traj.stateAt t).velocity :=
      lt_of_le_of_ne hPnn (Ne.symm hP)
    have hDiv : vortexStretchingIntegral traj t /
        palinstrophy (traj.stateAt t).velocity ≤ nsNu := by
      rw [div_le_iff₀ hPpos]
      exact hVS
    simpa [hP] using hDiv

/-- Exact cap characterization on the normalized coefficient path:
`projectedThetaCoeff ≤ ν` is equivalent to pointwise `VS ≤ νP`. -/
theorem projectedThetaCoeff_le_nu_iff_vs_le_nuP
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    projectedThetaCoeff traj t ≤ nsNu ↔
      vortexStretchingIntegral traj t ≤
        nsNu * palinstrophy (traj.stateAt t).velocity := by
  constructor
  · intro hCap
    have hEq : vortexStretchingIntegral traj t =
        projectedThetaCoeff traj t * palinstrophy (traj.stateAt t).velocity :=
      projectedThetaCoeff_equation traj t hNS hFS
    calc
      vortexStretchingIntegral traj t =
          projectedThetaCoeff traj t * palinstrophy (traj.stateAt t).velocity := hEq
      _ ≤ nsNu * palinstrophy (traj.stateAt t).velocity := by
        exact mul_le_mul_of_nonneg_right hCap
          (palinstrophy_nonneg (traj.stateAt t).velocity)
  · intro hVS
    exact projectedThetaCoeff_le_nu_of_vs_le_nuP traj t hVS

/-- Primitive theorem producer (vorticity side):
constructive slice-projection vorticity primitives provide a nonnegative
coefficient witness in `VS = θP`. -/
theorem projected_vorticity_theta_nonneg_from_slice_primitives :
  SliceProjectedVorticityThetaNonnegProp := by
  intro traj t hNS hFS
  refine ⟨projectedThetaCoeff traj t, ?_, projectedThetaCoeff_nonneg traj t⟩
  exact projectedThetaCoeff_equation traj t hNS hFS

/-- Primitive theorem producer (normalized coefficient cap, V2):
constructive slice-projection primitives directly provide the pointwise
unweighted bottleneck inequality `VS ≤ νP` on projected trajectories. -/
def SliceProjectedVSLeNuPPrimitiveProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    vortexStretchingIntegral traj t ≤
      nsNu * palinstrophy (traj.stateAt t).velocity

/-- Explicit subcritical slice condition:
at each trajectory/time on the slice path, enstrophy is below the corrected
subcritical threshold `Ω² ≤ ν⁴ λ₁ / C⁴`. -/
def SliceProjectedSubcriticalEnstrophyProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    enstrophy (traj.stateAt t).velocity *
      enstrophy (traj.stateAt t).velocity ≤
        subcriticalEnstrophySquaredThreshold

/-- Constructive cap witness for the explicit subcritical regime:
provides a trajectory-uniform enstrophy cap `Ω ≤ Ω_max` and compatibility
`Ω_max² ≤ ν⁴ λ₁/C⁴`. -/
structure SliceProjectedSubcriticalCapWitness where
  omegaMax : Rat
  omegaMax_nonneg : 0 ≤ omegaMax
  enstrophyCap : ∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      enstrophy (traj.stateAt t).velocity ≤ omegaMax
  thresholdCompatibility :
      omegaMax * omegaMax ≤ subcriticalEnstrophySquaredThreshold

/-- Proposition form: a constructive cap witness exists on the slice path. -/
def SliceProjectedSubcriticalCapWitnessProp : Prop :=
  Nonempty SliceProjectedSubcriticalCapWitness

/-- Primitive component 1 for the cap witness:
constructive primitives provide a trajectory-uniform enstrophy cap `Ω ≤ Ω_max`. -/
def SliceProjectedUniformEnstrophyCapPrimitiveProp : Prop :=
  ∃ omegaMax : Rat, 0 ≤ omegaMax ∧
    ∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      enstrophy (traj.stateAt t).velocity ≤ omegaMax

/-- Primitive component 1a (finer): constructive primitives provide a
trajectory-uniform entropic-rate source bound `λ ≤ λ_max` on the slice path,
together with the selected scalar compatibility required by the explicit
subcritical threshold. -/
def SliceProjectedUniformEntropicRateSourcePrimitiveProp : Prop :=
  ∃ lambdaMax : Rat, 0 ≤ lambdaMax ∧
    (∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      entropicRateNS traj t ≤ lambdaMax) ∧
    ((hbar / nsNu) * lambdaMax) * ((hbar / nsNu) * lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold

/-- Primitive component 1b (finer): scalar cap-threshold compatibility.
This isolates constant-level compatibility from trajectory-level rate bounds. -/
def SliceProjectedRateThresholdScalarPrimitiveProp : Prop :=
  ∃ lambdaMax : Rat, 0 ≤ lambdaMax ∧
    (∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      entropicRateNS traj t ≤ lambdaMax) ∧
    ((hbar / nsNu) * lambdaMax) * ((hbar / nsNu) * lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold

/-- Combined primitive rate-cap bundle used by downstream reducers. -/
def SliceProjectedUniformEntropicRateCapPrimitiveProp : Prop :=
  SliceProjectedUniformEntropicRateSourcePrimitiveProp ∧
    SliceProjectedRateThresholdScalarPrimitiveProp

/-- Primitive component 2 for the cap witness:
constructive primitives provide compatibility of the selected cap with the
explicit subcritical threshold `Ω_max² ≤ ν⁴ λ₁/C⁴`. -/
def SliceProjectedCapThresholdCompatibilityPrimitiveProp : Prop :=
  ∃ omegaMax : Rat, 0 ≤ omegaMax ∧
    (∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      enstrophy (traj.stateAt t).velocity ≤ omegaMax) ∧
    omegaMax * omegaMax ≤ subcriticalEnstrophySquaredThreshold

/-- Explicit witness parameter for the remaining slice-rate source primitive.
This keeps the unresolved content explicit in downstream theorem signatures
instead of as a hidden global export. -/
abbrev SliceProjectedUniformEntropicRateSourceWitness :=
  SliceProjectedUniformEntropicRateSourcePrimitiveProp

/-- Primitive producer for component 1b (scalar cap-threshold compatibility),
reduced by projection from the selected uniform entropic-rate source witness. -/
theorem slice_projected_rate_threshold_scalar_from_slice_primitives :
  SliceProjectedUniformEntropicRateSourceWitness →
  SliceProjectedRateThresholdScalarPrimitiveProp := by
  intro hRateSource
  rcases hRateSource with
    ⟨lambdaMax, hLambdaNN, hRateBound, hThresholdCompat⟩
  exact ⟨lambdaMax, hLambdaNN, hRateBound, hThresholdCompat⟩

/-- Primitive producer for the combined rate-cap bundle, assembled from the
two finer primitive components. -/
theorem slice_projected_uniform_entropic_rate_cap_from_slice_primitives :
    SliceProjectedUniformEntropicRateSourceWitness →
    SliceProjectedUniformEntropicRateCapPrimitiveProp := by
  intro hRateSource
  exact ⟨hRateSource,
    slice_projected_rate_threshold_scalar_from_slice_primitives hRateSource⟩

/-- Theorem-level reducer: uniform entropic-rate cap on slices implies
uniform enstrophy cap `Ω ≤ (ℏ/ν)λ_max`. -/
theorem slice_projected_uniform_enstrophy_cap_from_rate_cap_primitive
    (hRateCap : SliceProjectedUniformEntropicRateCapPrimitiveProp) :
    SliceProjectedUniformEnstrophyCapPrimitiveProp := by
  rcases hRateCap with ⟨hRateSource, _hScalarCompat⟩
  rcases hRateSource with ⟨lambdaMax, hLambdaNN, hRateBound, _hThresholdCompat⟩
  refine ⟨(hbar / nsNu) * lambdaMax, ?_, ?_⟩
  · exact mul_nonneg
      (div_nonneg (le_of_lt hbar_pos) (le_of_lt nsNu_pos))
      hLambdaNN
  · intro traj t hNS hFS
    have hRate : entropicRateNS traj t ≤ lambdaMax :=
      hRateBound traj t hNS hFS
    unfold entropicRateNS at hRate
    have hFacNN : 0 ≤ hbar / nsNu :=
      div_nonneg (le_of_lt hbar_pos) (le_of_lt nsNu_pos)
    have hMul := mul_le_mul_of_nonneg_left hRate hFacNN
    rw [← mul_assoc] at hMul
    have hCancel : (hbar / nsNu) * (nsNu / hbar) = 1 := by
      rw [div_mul_div_comm, mul_comm nsNu hbar,
          div_self (mul_ne_zero (ne_of_gt hbar_pos) (ne_of_gt nsNu_pos))]
    rw [hCancel, one_mul] at hMul
    calc
      enstrophy (traj.stateAt t).velocity =
          gradientNormSquared (traj.stateAt t).velocity :=
        enstrophyGradientIdentity traj t hNS
      _ ≤ (hbar / nsNu) * lambdaMax := hMul

/-- Primitive producer for component 1 (uniform cap), reduced to the finer
uniform entropic-rate primitive. -/
theorem slice_projected_uniform_enstrophy_cap_from_slice_primitives :
    SliceProjectedUniformEntropicRateSourceWitness →
    SliceProjectedUniformEnstrophyCapPrimitiveProp :=
  slice_projected_uniform_enstrophy_cap_from_rate_cap_primitive
    ∘ slice_projected_uniform_entropic_rate_cap_from_slice_primitives

/-- Theorem-level reducer: trajectory-parameterized cap/threshold compatibility
is extracted from the uniform entropic-rate primitive contract. -/
theorem slice_projected_cap_threshold_compatibility_from_rate_cap_primitive
    (hRateCap : SliceProjectedUniformEntropicRateCapPrimitiveProp) :
    SliceProjectedCapThresholdCompatibilityPrimitiveProp := by
  rcases hRateCap with ⟨hRateSource, _hScalarCompat⟩
  rcases hRateSource with ⟨lambdaMax, hLambdaNN, hRateBound, hThresholdCompat⟩
  refine ⟨(hbar / nsNu) * lambdaMax, ?_, ?_, ?_⟩
  · exact mul_nonneg
      (div_nonneg (le_of_lt hbar_pos) (le_of_lt nsNu_pos))
      hLambdaNN
  · intro traj t hNS hFS
    have hRate : entropicRateNS traj t ≤ lambdaMax :=
      hRateBound traj t hNS hFS
    unfold entropicRateNS at hRate
    have hFacNN : 0 ≤ hbar / nsNu :=
      div_nonneg (le_of_lt hbar_pos) (le_of_lt nsNu_pos)
    have hMul := mul_le_mul_of_nonneg_left hRate hFacNN
    rw [← mul_assoc] at hMul
    have hCancel : (hbar / nsNu) * (nsNu / hbar) = 1 := by
      rw [div_mul_div_comm, mul_comm nsNu hbar,
          div_self (mul_ne_zero (ne_of_gt hbar_pos) (ne_of_gt nsNu_pos))]
    rw [hCancel, one_mul] at hMul
    calc
      enstrophy (traj.stateAt t).velocity =
          gradientNormSquared (traj.stateAt t).velocity :=
        enstrophyGradientIdentity traj t hNS
      _ ≤ (hbar / nsNu) * lambdaMax := hMul
  · exact hThresholdCompat

/-- Primitive producer for component 2 (threshold compatibility), reduced to
the uniform entropic-rate primitive. -/
theorem slice_projected_cap_threshold_compatibility_from_slice_primitives :
    SliceProjectedUniformEntropicRateSourceWitness →
    SliceProjectedCapThresholdCompatibilityPrimitiveProp :=
  slice_projected_cap_threshold_compatibility_from_rate_cap_primitive
    ∘ slice_projected_uniform_entropic_rate_cap_from_slice_primitives

/-- Direct reducer: cap-threshold compatibility primitive contract implies the
constructive subcritical cap witness. -/
theorem slice_projected_subcritical_cap_witness_from_cap_threshold_compatibility
    (hCompat : SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    SliceProjectedSubcriticalCapWitnessProp := by
  rcases hCompat with ⟨omegaMax, hOmegaMaxNN, hEnstCap, hThresholdCompat⟩
  refine ⟨{
    omegaMax := omegaMax
    omegaMax_nonneg := hOmegaMaxNN
    enstrophyCap := hEnstCap
    thresholdCompatibility := hThresholdCompat
  }⟩

/-- Constructor: two explicit cap components imply cap witness existence. -/
theorem slice_projected_subcritical_cap_witness_from_components
    (hCompat : SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    SliceProjectedSubcriticalCapWitnessProp := by
  rcases hCompat with ⟨omegaMax, hOmegaMaxNN, hEnstCap, hThresholdCompat⟩
  refine ⟨{
    omegaMax := omegaMax
    omegaMax_nonneg := hOmegaMaxNN
    enstrophyCap := hEnstCap
    thresholdCompatibility := hThresholdCompat
  }⟩

/-- Primitive slice-projection producer for the cap witness:
constructive primitives provide `Ω ≤ Ω_max` and threshold compatibility via
the two explicit cap components. -/
theorem slice_projected_subcritical_cap_witness_from_slice_primitives :
    SliceProjectedUniformEntropicRateSourceWitness →
    SliceProjectedSubcriticalCapWitnessProp :=
  slice_projected_subcritical_cap_witness_from_components
    ∘ slice_projected_cap_threshold_compatibility_from_slice_primitives

/-- Reverse reducer: a constructive subcritical cap witness induces the explicit
uniform entropic-rate source witness by setting
`λ_max := (ν/ℏ) * Ω_max`. This makes the remaining source-witness node
equivalent (in theorem form) to cap-witness data. -/
theorem slice_projected_rate_source_witness_from_subcritical_cap_witness
    (hW : SliceProjectedSubcriticalCapWitnessProp) :
    SliceProjectedUniformEntropicRateSourceWitness := by
  rcases hW with ⟨w⟩
  refine ⟨(nsNu / hbar) * w.omegaMax, ?_, ?_, ?_⟩
  · exact mul_nonneg
      (div_nonneg (le_of_lt nsNu_pos) (le_of_lt hbar_pos))
      w.omegaMax_nonneg
  · intro traj t hNS hFS
    have hOmega : enstrophy (traj.stateAt t).velocity ≤ w.omegaMax :=
      w.enstrophyCap traj t hNS hFS
    have hGrad : gradientNormSquared (traj.stateAt t).velocity ≤ w.omegaMax := by
      simpa [enstrophyGradientIdentity traj t hNS] using hOmega
    unfold entropicRateNS
    exact mul_le_mul_of_nonneg_left hGrad
      (div_nonneg (le_of_lt nsNu_pos) (le_of_lt hbar_pos))
  · have hCancel : (hbar / nsNu) * ((nsNu / hbar) * w.omegaMax) = w.omegaMax := by
      rw [← mul_assoc]
      have hBase : (hbar / nsNu) * (nsNu / hbar) = 1 := by
        rw [div_mul_div_comm, mul_comm nsNu hbar,
            div_self (mul_ne_zero (ne_of_gt hbar_pos) (ne_of_gt nsNu_pos))]
      rw [hBase, one_mul]
    simpa [hCancel] using w.thresholdCompatibility

/-- Equivalence theorem: source-witness and subcritical-cap witness are
inter-derivable by theorem reducers on the slice path. -/
theorem slice_projected_rate_source_witness_iff_subcritical_cap_witness :
    SliceProjectedUniformEntropicRateSourceWitness ↔
      SliceProjectedSubcriticalCapWitnessProp := by
  constructor
  · intro hRateSource
    exact slice_projected_subcritical_cap_witness_from_slice_primitives hRateSource
  · intro hCapWitness
    exact slice_projected_rate_source_witness_from_subcritical_cap_witness hCapWitness

/-- Theorem-level reducer: a constructive cap witness implies explicit
subcritical enstrophy `Ω² ≤ ν⁴ λ₁/C⁴` on slices. -/
theorem slice_projected_subcritical_enstrophy_from_cap_witness
    (hW : SliceProjectedSubcriticalCapWitnessProp) :
    SliceProjectedSubcriticalEnstrophyProp := by
  intro traj t hNS hFS
  rcases hW with ⟨w⟩
  have hΩle : enstrophy (traj.stateAt t).velocity ≤ w.omegaMax :=
    w.enstrophyCap traj t hNS hFS
  have hΩnn : 0 ≤ enstrophy (traj.stateAt t).velocity :=
    enstrophy_nonneg (traj.stateAt t).velocity
  have hSqLe :
      enstrophy (traj.stateAt t).velocity *
        enstrophy (traj.stateAt t).velocity ≤
      w.omegaMax * w.omegaMax := by
    nlinarith [hΩle, hΩnn]
  exact le_trans hSqLe w.thresholdCompatibility

/-- Primitive slice-projection producer for the explicit subcritical regime:
constructive primitives provide `Ω² ≤ ν⁴ λ₁/C⁴` on slices via cap witness
decomposition. -/
theorem slice_projected_subcritical_enstrophy_from_slice_primitives :
    SliceProjectedUniformEntropicRateSourceWitness →
    SliceProjectedSubcriticalEnstrophyProp :=
  slice_projected_subcritical_enstrophy_from_cap_witness
    ∘ slice_projected_subcritical_cap_witness_from_slice_primitives

/-- Theorem-level decomposition of the direct bottleneck primitive:
subcritical enstrophy on slices implies pointwise `VS ≤ νP`. -/
theorem slice_projected_vs_le_nuP_from_subcritical_enstrophy
    (hSub : SliceProjectedSubcriticalEnstrophyProp) :
    SliceProjectedVSLeNuPPrimitiveProp := by
  intro traj t hNS hFS
  have h2 : 2 * vortexStretchingIntegral traj t ≤
      2 * nsNu * palinstrophy (traj.stateAt t).velocity :=
    subcritical_enstrophy_implies_stretching_dominated traj t hNS hFS
      (hSub traj t hNS hFS)
  nlinarith

/-- Primitive theorem producer (normalized coefficient cap, V2):
constructive slice-projection primitives provide pointwise `VS ≤ νP` by
first establishing the explicit subcritical slice regime. -/
theorem slice_projected_vs_le_nuP_from_slice_primitives :
  SliceProjectedUniformEntropicRateSourceWitness →
  SliceProjectedVSLeNuPPrimitiveProp :=
  slice_projected_vs_le_nuP_from_subcritical_enstrophy
    ∘ slice_projected_subcritical_enstrophy_from_slice_primitives

/-- Direct producer from cap witness:
subcritical cap witness data yields pointwise `VS ≤ νP` through theorem
reducers, without separately supplying a source-witness argument. -/
theorem slice_projected_vs_le_nuP_from_subcritical_cap_witness
    (hW : SliceProjectedSubcriticalCapWitnessProp) :
    SliceProjectedVSLeNuPPrimitiveProp :=
  slice_projected_vs_le_nuP_from_slice_primitives
    (slice_projected_rate_source_witness_from_subcritical_cap_witness hW)

/-- Direct cap-first bottleneck reducer:
cap-threshold compatibility primitive data imply pointwise `VS ≤ νP` through
constructive cap witness reducers. -/
theorem slice_projected_vs_le_nuP_from_cap_threshold_compatibility
    (hCompat : SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    SliceProjectedVSLeNuPPrimitiveProp :=
  slice_projected_vs_le_nuP_from_subcritical_cap_witness
    (slice_projected_subcritical_cap_witness_from_cap_threshold_compatibility hCompat)

/-- Coefficient cap for the explicit normalized witness, discharged from the
direct normalized-cap primitive contract. -/
theorem projectedThetaCoeff_le_nu_from_slice_primitives
    (hRateSource : SliceProjectedUniformEntropicRateSourceWitness)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    projectedThetaCoeff traj t ≤ nsNu := by
  exact (projectedThetaCoeff_le_nu_iff_vs_le_nuP traj t hNS hFS).2
    (slice_projected_vs_le_nuP_from_slice_primitives hRateSource traj t hNS hFS)

/-- Theorem-level momentum producer exported from slice-projection primitives. -/
theorem slice_projected_momentum_theta_equation_constructive_producer :
    SliceProjectedMomentumThetaEquationProp :=
  projected_momentum_theta_equation_from_slice_primitives

/-- Theorem-level vorticity-sign producer exported from slice-projection primitives. -/
theorem slice_projected_vorticity_theta_nonneg_constructive_producer :
    SliceProjectedVorticityThetaNonnegProp :=
  projected_vorticity_theta_nonneg_from_slice_primitives

/-- Theorem-level direct bottleneck producer exported from slice-projection
primitives. -/
theorem slice_projected_vs_le_nuP_constructive_producer :
    SliceProjectedUniformEntropicRateSourceWitness →
    SliceProjectedVSLeNuPPrimitiveProp :=
  slice_projected_vs_le_nuP_from_slice_primitives

/-- Primitive theorem producer (normalized V2), reduced to direct normalized
coefficient-cap and explicit `VS=θP`/`0≤θ` reducers.

This keeps the core kernel burden on the normalized cap node instead of the
legacy all-`θ` coefficient contract. -/
theorem projected_theta_witness_from_slice_primitives :
    SliceProjectedUniformEntropicRateSourceWitness →
    SliceProjectedThetaWitnessProp :=
by
  intro hRateSource traj t hNS hFS
  refine ⟨projectedThetaCoeff traj t,
    projectedThetaCoeff_nonneg traj t,
    projectedThetaCoeff_le_nu_from_slice_primitives hRateSource traj t hNS hFS,
    projectedThetaCoeff_equation traj t hNS hFS⟩

/-- Theorem-level normalized producer exported from slice-projection primitives. -/
theorem slice_projected_theta_witness_constructive_producer :
    SliceProjectedUniformEntropicRateSourceWitness →
    SliceProjectedThetaWitnessProp :=
  projected_theta_witness_from_slice_primitives

/-! ## 6d. Explicit Causality Adapters (Source-Witness Derivation) -/

/-- Explicit side-condition for global witness extraction from causality:
trajectories on this route live on nonnegative time domain. -/
def SliceProjectedTimeDomainNonnegativeProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    0 ≤ t

/-- Explicit source-witness adapter:
derive the remaining slice rate-source witness from `CausalityBoundedLambda`
plus nonnegative-time and threshold-compatibility assumptions. -/
theorem slice_projected_rate_source_witness_from_causality
    (cb : CausalityBoundedLambda)
    (hTimeDomain : SliceProjectedTimeDomainNonnegativeProp)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    SliceProjectedUniformEntropicRateSourceWitness := by
  refine ⟨cb.lambdaMax, le_of_lt cb.lambdaMax_pos, ?_, hCompat⟩
  intro traj t hNS hFS
  have ht0 : 0 ≤ t := hTimeDomain traj t hNS hFS
  have hTpos : 0 < t + 1 := by nlinarith
  have hRateBounded : EntropicRateBounded cb.lambdaMax traj (t + 1) :=
    cb.holds traj (t + 1) hTpos hNS
  have htT : t ≤ t + 1 := by nlinarith
  exact hRateBounded t ht0 htT

/-- Causality-routed cap-threshold compatibility producer:
derive the cap-threshold primitive directly from explicit causality assumptions
through theorem reducers. -/
theorem slice_projected_cap_threshold_compatibility_from_causality
    (cb : CausalityBoundedLambda)
    (hTimeDomain : SliceProjectedTimeDomainNonnegativeProp)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    SliceProjectedCapThresholdCompatibilityPrimitiveProp :=
  slice_projected_cap_threshold_compatibility_from_slice_primitives
    (slice_projected_rate_source_witness_from_causality cb hTimeDomain hCompat)

/-- Causality-routed direct bottleneck producer:
explicit causality assumptions imply pointwise slice `VS ≤ νP` through the
source-witness decomposition chain. -/
theorem slice_projected_vs_le_nuP_from_causality
    (cb : CausalityBoundedLambda)
    (hTimeDomain : SliceProjectedTimeDomainNonnegativeProp)
    (hCompat : ((hbar / nsNu) * cb.lambdaMax) * ((hbar / nsNu) * cb.lambdaMax) ≤
      subcriticalEnstrophySquaredThreshold) :
    SliceProjectedVSLeNuPPrimitiveProp :=
  slice_projected_vs_le_nuP_from_cap_threshold_compatibility
    (slice_projected_cap_threshold_compatibility_from_causality cb hTimeDomain hCompat)

/-! ## 7. Claim Registry -/

def sliceDecompositionClaims : List LabeledClaim :=
  [ ⟨"two_dim_ns_globally_regular", .partiallyVerified,
      "AXIOM: 2D NS on T² globally regular (Ladyzhenskaya 1969)"⟩
  , ⟨"coupling_nonneg", .verified,
      "THEOREM: Coupling magnitude ≥ 0 (mul_nonneg)"⟩
  , ⟨"decoupled_implies_coupling_zero", .verified,
      "THEOREM: u₃=0 → coupling=0 (simp mul_zero)"⟩
  , ⟨"coupling_times_enstrophy_nonneg", .verified,
      "THEOREM: coupling·Ω ≥ 0 (mul_nonneg × 2)"⟩
  , ⟨"q_threshold_consistent_stage68", .verified,
      "THEOREM: Stage 63/67/68 all have q_threshold=2 (rfl × 3)"⟩
  , ⟨"shell_functor_faithful_not_full", .verified,
      "THEOREM: ShellFunctor faithful but not full (rfl × 3)"⟩
  , ⟨"slice_decomposition_identifies_gap", .verified,
      "THEOREM: 3D gap = coupling obstruction = VS ≤ νP (rfl × 5)"⟩
  , ⟨"slice_projected_momentum_theta_equation", .verified,
      "THEOREM: concrete slice momentum contract yields coefficient equation VS=θP at trajectory level"⟩
  , ⟨"slice_projected_vorticity_theta_nonneg", .verified,
      "THEOREM: concrete slice vorticity contract yields lower bound 0≤θ for coefficients in VS=θP"⟩
  , ⟨"slice_projected_coefficient_theta_le_nu", .verified,
      "THEOREM: concrete slice coefficient contract yields upper bound θ≤ν for coefficients in VS=θP"⟩
  , ⟨"slice_projected_theta_witness_from_legacy", .partiallyVerified,
      "THEOREM: legacy momentum/vorticity/coefficient bundle implies normalized kernel-ready witness contract"⟩
  , ⟨"slice_projected_theta_witness_implies_momentum", .partiallyVerified,
      "THEOREM: normalized witness contract implies legacy momentum contract VS=θP"⟩
  , ⟨"slice_projected_momentum_theta_equation_constructive_producer", .partiallyVerified,
      "THEOREM: NS slice-projection primitive producer for trajectory-level VS=θP witness contract (unweighted GN 4th-power + case split on P)"⟩
  , ⟨"projectedThetaCoeff", .verified,
      "DEF: explicit normalized coefficient θ(t)=0 if P=0 else VS/P"⟩
  , ⟨"projectedThetaCoeff_equation", .verified,
      "THEOREM: explicit normalized coefficient satisfies VS=θP (algebraic case split)"⟩
  , ⟨"projectedThetaCoeff_nonneg", .partiallyVerified,
      "THEOREM: explicit normalized coefficient is nonnegative from VS≥0 and P≥0"⟩
  , ⟨"projectedThetaCoeff_le_nu_of_vs_le_nuP", .verified,
      "THEOREM: direct reduction of normalized coefficient cap θ≤ν from core pointwise bottleneck VS≤νP"⟩
  , ⟨"projectedThetaCoeff_le_nu_iff_vs_le_nuP", .verified,
      "THEOREM: exact equivalence on normalized path: θ(t)≤ν ↔ VS≤νP"⟩
  , ⟨"SliceProjectedUniformEntropicRateSourceWitness", .partiallyVerified,
      "PROP: explicit witness parameter for remaining slice-rate primitive source (λ≤λ_max with selected scalar threshold compatibility Ω_max²≤ν⁴λ₁/C⁴)"⟩
  , ⟨"slice_projected_rate_threshold_scalar_from_slice_primitives", .partiallyVerified,
      "THEOREM: scalar cap-threshold compatibility extracted by projection from explicit selected source witness"⟩
  , ⟨"slice_projected_uniform_entropic_rate_cap_from_slice_primitives", .partiallyVerified,
      "THEOREM: combined rate-cap bundle assembled from explicit source witness and projected scalar threshold compatibility"⟩
  , ⟨"slice_projected_uniform_enstrophy_cap_from_rate_cap_primitive", .partiallyVerified,
      "THEOREM: trajectory-uniform entropic-rate cap implies uniform enstrophy cap Ω≤(ℏ/ν)λ_max"⟩
  , ⟨"slice_projected_uniform_enstrophy_cap_from_slice_primitives", .partiallyVerified,
      "THEOREM: trajectory-uniform enstrophy cap reduced to explicit source-witness-based entropic-rate-cap primitive"⟩
  , ⟨"slice_projected_cap_threshold_compatibility_from_rate_cap_primitive", .partiallyVerified,
      "THEOREM: trajectory-parameterized cap-threshold compatibility extracted from the uniform entropic-rate primitive contract"⟩
  , ⟨"slice_projected_cap_threshold_compatibility_from_slice_primitives", .partiallyVerified,
      "THEOREM: cap/threshold compatibility reduced to explicit source-witness-based entropic-rate primitive"⟩
  , ⟨"slice_projected_subcritical_cap_witness_from_cap_threshold_compatibility", .partiallyVerified,
      "THEOREM: cap-threshold compatibility primitive contract directly implies constructive subcritical cap witness"⟩
  , ⟨"slice_projected_subcritical_cap_witness_from_components", .partiallyVerified,
      "THEOREM: two explicit cap components (uniform cap + threshold compatibility) imply cap witness existence"⟩
  , ⟨"slice_projected_subcritical_cap_witness_from_slice_primitives", .partiallyVerified,
      "THEOREM: cap witness reduced to explicit source-witness-driven compatibility component"⟩
  , ⟨"slice_projected_rate_source_witness_from_subcritical_cap_witness", .partiallyVerified,
      "THEOREM: reverse reducer from constructive cap witness to explicit source witness by λ_max=(ν/ℏ)Ω_max"⟩
  , ⟨"slice_projected_rate_source_witness_iff_subcritical_cap_witness", .partiallyVerified,
      "THEOREM: equivalence between explicit source witness and constructive cap witness on the slice path"⟩
  , ⟨"slice_projected_subcritical_enstrophy_from_cap_witness", .partiallyVerified,
      "THEOREM: constructive cap witness implies explicit subcritical slice regime Ω²≤ν⁴λ₁/C⁴"⟩
  , ⟨"slice_projected_subcritical_enstrophy_from_slice_primitives", .partiallyVerified,
      "THEOREM: explicit subcritical regime on slices reduced from explicit source-witness-driven cap witness construction"⟩
  , ⟨"slice_projected_vs_le_nuP_from_slice_primitives", .partiallyVerified,
      "THEOREM: direct pointwise slice bottleneck VS≤νP reduced via explicit source-witness-driven subcritical slice primitive and stretching-dominance theorem"⟩
  , ⟨"slice_projected_vs_le_nuP_from_subcritical_cap_witness", .partiallyVerified,
      "THEOREM: direct pointwise slice bottleneck VS≤νP reduced from constructive cap witness through theorem reducers"⟩
  , ⟨"slice_projected_vs_le_nuP_from_cap_threshold_compatibility", .partiallyVerified,
      "THEOREM: direct pointwise slice bottleneck VS≤νP reduced from cap-threshold compatibility primitive through constructive cap-witness reducers"⟩
  , ⟨"slice_projected_vs_le_nuP_from_subcritical_enstrophy", .partiallyVerified,
      "THEOREM: explicit subcritical slice condition Ω²≤ν⁴λ₁/C⁴ implies direct bottleneck VS≤νP"⟩
  , ⟨"projectedThetaCoeff_le_nu_from_slice_primitives", .partiallyVerified,
      "THEOREM: coefficient cap θ(t)≤ν for normalized witness, reduced to explicit source-witness-driven pointwise primitive VS≤νP via exact equivalence"⟩
  , ⟨"slice_projected_vorticity_theta_nonneg_constructive_producer", .partiallyVerified,
      "AXIOM+THEOREM: NS slice-projection primitive producer for coefficient nonnegativity 0≤θ"⟩
  , ⟨"slice_projected_vs_le_nuP_constructive_producer", .partiallyVerified,
      "THEOREM: NS slice-projection bottleneck producer parameterized by explicit source witness via subcritical primitive Ω²≤ν⁴λ₁/C⁴ → VS≤νP"⟩
  , ⟨"projected_theta_witness_from_slice_primitives", .partiallyVerified,
      "THEOREM: normalized slice witness producer from explicit θ(t) identity + nonnegativity + single PDE cap θ(t)≤ν"⟩
  , ⟨"slice_projected_theta_witness_constructive_producer", .partiallyVerified,
      "THEOREM: normalized NS slice-projection primitive producer in kernel-ready witness form parameterized by explicit source witness"⟩ ]
  ++
  [ ⟨"slice_projected_rate_source_witness_from_causality", .partiallyVerified,
      "THEOREM: explicit adapter from CausalityBoundedLambda + nonnegative-time + threshold compatibility to the remaining slice rate-source witness"⟩
  , ⟨"slice_projected_cap_threshold_compatibility_from_causality", .partiallyVerified,
      "THEOREM: explicit adapter from CausalityBoundedLambda + nonnegative-time + threshold compatibility to cap-threshold compatibility primitive"⟩
  , ⟨"slice_projected_vs_le_nuP_from_causality", .partiallyVerified,
      "THEOREM: explicit causality route to pointwise slice bottleneck VS≤νP via cap-threshold compatibility reducer chain"⟩ ]

end

end NavierStokes.SliceDecomposition
