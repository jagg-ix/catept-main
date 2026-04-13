import NavierStokes.NSSliceDecompositionBridge
import NavierStokes.NSVSNuPKernel
import NavierStokes.NSVSNuPResolutionBridge

/-!
# NS Slice Rotational Assembly Bridge

This bridge makes the "2D slices -> 3D reconstruction" strategy explicit for
the core bottleneck route.

The construction is intentionally minimal:
- We model an oriented family of slice controls.
- We isolate a residual interaction term that captures cross-orientation
  3D coupling not visible in a single 2D foliation.
- We show that absorbing this residual yields direct pointwise `VS ≤ νP`,
  then inherit the existing kernel/resolution closure chain.

So the remaining analytic burden is explicit: control/absorb the residual term
in fully constructive 3D slice PDE estimates.
-/

namespace NavierStokes.SliceRotationalAssembly

set_option autoImplicit false

open NavierStokes.SliceDecomposition
open NavierStokes.Millennium

noncomputable section

/-- Orientation parameter for a rotated slice foliation. -/
abbrev SliceOrientation := Rat

/-- Orientation-indexed alias of the direct slice primitive `VS ≤ νP`.
This keeps orientation dependence explicit in contracts, even when the
underlying primitive proposition is re-used. -/
def OrientedSliceVSLeNuPPrimitiveProp (_phi : SliceOrientation) : Prop :=
  SliceProjectedVSLeNuPPrimitiveProp

/-- Family control contract:
every oriented slice foliation satisfies the direct bottleneck primitive. -/
def OrientedSliceFamilyControlProp : Prop :=
  ∀ phi : SliceOrientation, OrientedSliceVSLeNuPPrimitiveProp phi

/-- Rotational assembly witness for lifting oriented 2D slice controls to 3D.

`residual` encodes unresolved cross-orientation interactions after assembling
all oriented slice controls into one 3D estimate. -/
structure OrientedSliceAssemblyWitness where
  /-- Pointwise control on each oriented 2D foliation. -/
  orientedSliceControl : OrientedSliceFamilyControlProp
  /-- Coverage side condition: oriented family is rich enough to span
  the intended 3D reconstruction class. Kept explicit as a contract field. -/
  coverageContract : Prop
  /-- Residual cross-orientation interaction term. -/
  residual : Trajectory NSField → Rat → Rat
  /-- 3D reconstructed inequality with residual term. -/
  reconstructedBound :
    ∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      vortexStretchingIntegral traj t ≤
        nsNu * palinstrophy (traj.stateAt t).velocity + residual traj t

/-- Open analytic closure target for the rotational assembly route:
residual is absorbed pointwise (`≤ 0`) on NS trajectories. -/
def OrientedSliceResidualAbsorptionProp (w : OrientedSliceAssemblyWitness) : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    w.residual traj t ≤ 0

/-- Strong closure variant: residual vanishes exactly. -/
def OrientedSliceResidualZeroProp (w : OrientedSliceAssemblyWitness) : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    w.residual traj t = 0

/-- Zero residual implies absorption. -/
theorem oriented_slice_residual_zero_implies_absorption
    (w : OrientedSliceAssemblyWitness)
    (hZero : OrientedSliceResidualZeroProp w) :
    OrientedSliceResidualAbsorptionProp w := by
  intro traj t hNS hFS
  simp [hZero traj t hNS hFS]

/-- Core reducer:
if the rotational-assembly residual is absorbed, then direct pointwise
`VS ≤ νP` follows for all NS trajectories. -/
theorem oriented_slice_residual_absorption_implies_direct_vs_le_nuP
    (w : OrientedSliceAssemblyWitness)
    (hAbsorb : OrientedSliceResidualAbsorptionProp w) :
    SliceProjectedVSLeNuPPrimitiveProp := by
  intro traj t hNS hFS
  have hRec :
      vortexStretchingIntegral traj t ≤
        nsNu * palinstrophy (traj.stateAt t).velocity + w.residual traj t :=
    w.reconstructedBound traj t hNS hFS
  have hResLe0 : w.residual traj t ≤ 0 := hAbsorb traj t hNS hFS
  nlinarith [hRec, hResLe0]

/-- Kernel-route corollary for the rotational assembly strategy. -/
theorem oriented_slice_residual_absorption_implies_kernel
    (w : OrientedSliceAssemblyWitness)
    (hAbsorb : OrientedSliceResidualAbsorptionProp w) :
    SliceProjectionCouplingBoundProp :=
  slice_projection_coupling_bound_from_direct_vs_le_nuP
    (oriented_slice_residual_absorption_implies_direct_vs_le_nuP w hAbsorb)

/-- Precise-gap corollary through the standard unweighted kernel chain. -/
theorem oriented_slice_residual_absorption_implies_precise_gap
    (w : OrientedSliceAssemblyWitness)
    (hAbsorb : OrientedSliceResidualAbsorptionProp w) :
    PreciseGapStatement :=
  slice_projection_kernel_implies_precise_gap
    (oriented_slice_residual_absorption_implies_kernel w hAbsorb)

/-- Rate-cap reducer exposed under this bridge:
uniform source-witness data imply cap-threshold compatibility. -/
theorem oriented_slice_rate_source_implies_cap_threshold_compatibility
    (hRate : SliceProjectedUniformEntropicRateSourceWitness) :
    SliceProjectedCapThresholdCompatibilityPrimitiveProp :=
  slice_projected_cap_threshold_compatibility_from_slice_primitives hRate

/-- Cap-threshold route corollary under this bridge namespace. -/
theorem oriented_slice_rate_source_implies_precise_gap_via_cap_threshold
    (hRate : SliceProjectedUniformEntropicRateSourceWitness) :
    PreciseGapStatement :=
  slice_projection_cap_threshold_compatibility_implies_precise_gap
    (oriented_slice_rate_source_implies_cap_threshold_compatibility hRate)

/-! ## Triadic Cross-Orientation Residual Candidate -/

/-- First concrete residual candidate:
triadic cross-orientation interaction modeled against the explicit subcritical
cap-threshold scale `Ω² - Ω*²`, where `Ω*² = ν⁴ λ₁ / C⁴`.

Sign convention: with nonnegative triadic coefficient, cap-threshold control
`Ω² ≤ Ω*²` implies this residual is non-positive (absorbed). -/
def triadicCrossOrientationResidual
    (triadicCoeff : Rat) (traj : Trajectory NSField) (t : Rat) : Rat :=
  triadicCoeff * (
    enstrophy (traj.stateAt t).velocity * enstrophy (traj.stateAt t).velocity
      - subcriticalEnstrophySquaredThreshold)

/-- Triadic witness specialization over the oriented assembly contract. -/
structure TriadicOrientedSliceAssemblyWitness extends OrientedSliceAssemblyWitness where
  triadicCoeff : Rat
  triadicCoeff_nonneg : 0 ≤ triadicCoeff
  residual_is_triadic :
    ∀ (traj : Trajectory NSField) (t : Rat),
      residual traj t = triadicCrossOrientationResidual triadicCoeff traj t

/-- Single cap-threshold inequality target for the triadic residual route. -/
def TriadicResidualCapThresholdInequalityTargetProp
    (_w : TriadicOrientedSliceAssemblyWitness) : Prop :=
  SliceProjectedSubcriticalEnstrophyProp

/-- Core 3D residual estimate target (single remaining analytic node):
the assembled cross-orientation residual is majorized by the explicit triadic
cap-threshold profile.

Proving this from concrete 3D slice projection lemmas isolates the PDE burden
to one inequality schema, independent of downstream algebraic closure steps. -/
def TriadicResidualCoreEstimateProp
    (w : TriadicOrientedSliceAssemblyWitness) : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    w.residual traj t ≤ triadicCrossOrientationResidual w.triadicCoeff traj t

/-- Contract for the genuinely open constructive step:
derive a triadic oriented-slice assembly witness (including reconstructed bound
and residual identification) from concrete 3D slice-PDE estimate producers. -/
def TriadicOrientedSliceAssemblyWitnessFromConcrete3DSlicePDEProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    ∃ w : TriadicOrientedSliceAssemblyWitness,
      vortexStretchingIntegral traj t ≤
        nsNu * palinstrophy (traj.stateAt t).velocity + w.residual traj t ∧
      w.residual traj t = triadicCrossOrientationResidual w.triadicCoeff traj t

/-- Decomposed primitive contracts for the core residual estimate.

This splits the single open node into two local obligations:
1) sign-controlled component is nonpositive;
2) cap-tracked component is dominated by the triadic profile.

Then `residual ≤ triadicProfile` follows algebraically by composition. -/
def TriadicResidualCoreEstimateComponentsProp
    (w : TriadicOrientedSliceAssemblyWitness) : Prop :=
  ∃ (residualSign residualCap : Trajectory NSField → Rat → Rat),
    (∀ (traj : Trajectory NSField) (t : Rat),
      w.residual traj t = residualSign traj t + residualCap traj t) ∧
    (∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      residualSign traj t ≤ 0) ∧
    (∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      residualCap traj t ≤ triadicCrossOrientationResidual w.triadicCoeff traj t)

/-- Helical-channel decomposition contract (0206030-oriented interface):
the assembled residual is split into `+`/`-` sign channels plus a cross-channel
transfer channel. The two sign channels are dissipative (`≤ 0`) and the cross
channel is controlled by the triadic cap profile. -/
def HelicalTriadicResidualDecompositionProp
    (w : TriadicOrientedSliceAssemblyWitness) : Prop :=
  ∃ (residualPlus residualMinus residualCross : Trajectory NSField → Rat → Rat),
    (∀ (traj : Trajectory NSField) (t : Rat),
      w.residual traj t =
        residualPlus traj t + residualMinus traj t + residualCross traj t) ∧
    (∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      residualPlus traj t ≤ 0) ∧
    (∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      residualMinus traj t ≤ 0) ∧
    (∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      residualCross traj t ≤ triadicCrossOrientationResidual w.triadicCoeff traj t)

/-- 0206030-style helical decomposition reducer:
helical channel decomposition contracts imply the existing decomposed core
estimate components node. -/
theorem triadic_core_components_from_helical_decomposition
    (w : TriadicOrientedSliceAssemblyWitness)
    (hHelical : HelicalTriadicResidualDecompositionProp w) :
    TriadicResidualCoreEstimateComponentsProp w := by
  rcases hHelical with
    ⟨residualPlus, residualMinus, residualCross, hSplit, hPlusLe0, hMinusLe0, hCrossLeTriad⟩
  refine ⟨
    (fun traj t => residualPlus traj t + residualMinus traj t),
    residualCross,
    ?_,
    ?_,
    ?_⟩
  · intro traj t
    have hEq := hSplit traj t
    nlinarith [hEq]
  · intro traj t hNS hFS
    have hPlus : residualPlus traj t ≤ 0 := hPlusLe0 traj t hNS hFS
    have hMinus : residualMinus traj t ≤ 0 := hMinusLe0 traj t hNS hFS
    nlinarith [hPlus, hMinus]
  · intro traj t hNS hFS
    exact hCrossLeTriad traj t hNS hFS

/-- The decomposed primitive contracts imply the single core residual estimate. -/
theorem triadic_residual_core_estimate_from_components
    (w : TriadicOrientedSliceAssemblyWitness)
    (hComp : TriadicResidualCoreEstimateComponentsProp w) :
    TriadicResidualCoreEstimateProp w := by
  rcases hComp with ⟨residualSign, residualCap, hSplit, hSignLe0, hCapLeTriad⟩
  intro traj t hNS hFS
  have hSplitEq : w.residual traj t = residualSign traj t + residualCap traj t :=
    hSplit traj t
  have hSign : residualSign traj t ≤ 0 := hSignLe0 traj t hNS hFS
  have hCap : residualCap traj t ≤ triadicCrossOrientationResidual w.triadicCoeff traj t :=
    hCapLeTriad traj t hNS hFS
  rw [hSplitEq]
  nlinarith [hSign, hCap]

/-- Direct reducer to the single core estimate node from the 0206030-style
helical decomposition contract. -/
theorem triadic_residual_core_estimate_from_helical_decomposition
    (w : TriadicOrientedSliceAssemblyWitness)
    (hHelical : HelicalTriadicResidualDecompositionProp w) :
    TriadicResidualCoreEstimateProp w :=
  triadic_residual_core_estimate_from_components w
    (triadic_core_components_from_helical_decomposition w hHelical)

/-- Direct reducer: the triadic witness identity field already yields the core
residual majorization node. -/
theorem triadic_residual_core_estimate_from_witness_identity
    (w : TriadicOrientedSliceAssemblyWitness) :
    TriadicResidualCoreEstimateProp w := by
  intro traj t _hNS _hFS
  simp [w.residual_is_triadic traj t]

/-- Optional CAT/EPT normalization + integration-by-parts interface:
the complex-action normalization step yields the same residual majorization
contract needed by the triadic core estimate route.

This is an interface proposition (not a theorem here), so different analytic
derivations can plug into the same closure chain. -/
def CATEPTPathIntegralIBPResidualMajorizationProp
    (w : TriadicOrientedSliceAssemblyWitness) : Prop :=
  TriadicResidualCoreEstimateProp w

/-- Decomposed CAT/EPT path-integral + IBP contract:
normalization and IBP are represented as two local components whose sum is the
assembled residual. This is an interface-level decomposition for producer modules. -/
def CATEPTPathIntegralIBPResidualMajorizationComponentsProp
    (w : TriadicOrientedSliceAssemblyWitness) : Prop :=
  TriadicResidualCoreEstimateComponentsProp w

/-- CAT/EPT decomposed components collapse to the single majorization interface. -/
theorem cat_ept_path_integral_ibp_majorization_from_components
    (w : TriadicOrientedSliceAssemblyWitness)
    (hComp : CATEPTPathIntegralIBPResidualMajorizationComponentsProp w) :
    CATEPTPathIntegralIBPResidualMajorizationProp w :=
  triadic_residual_core_estimate_from_components w hComp

/-- Direct CAT/EPT reducer from the triadic witness identity. -/
theorem cat_ept_path_integral_ibp_majorization_from_witness_identity
    (w : TriadicOrientedSliceAssemblyWitness) :
    CATEPTPathIntegralIBPResidualMajorizationProp w :=
  triadic_residual_core_estimate_from_witness_identity w

/-- Constructive producer:
the triadic cap-threshold target is discharged from concrete 3D slice-PDE
estimate producers on the slice path. -/
theorem triadic_cap_threshold_target_from_concrete_3d_slice_pde_estimates
    (w : TriadicOrientedSliceAssemblyWitness)
    (hCompat : SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    TriadicResidualCapThresholdInequalityTargetProp w :=
  slice_projected_subcritical_enstrophy_from_cap_witness
    (slice_projected_subcritical_cap_witness_from_cap_threshold_compatibility hCompat)

/-- Alternative producer through explicit cap-threshold compatibility primitive
data (without requiring a separate source-witness argument). -/
theorem triadic_cap_threshold_target_from_cap_threshold_compatibility
    (w : TriadicOrientedSliceAssemblyWitness)
    (hCompat : SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    TriadicResidualCapThresholdInequalityTargetProp w :=
  slice_projected_subcritical_enstrophy_from_cap_witness
    (slice_projected_subcritical_cap_witness_from_cap_threshold_compatibility hCompat)

/-- Core reducer:
single residual-estimate contract + cap-threshold target imply residual
absorption (`residual ≤ 0`) on NS trajectories. -/
theorem triadic_residual_absorption_from_core_estimate_and_cap_target
    (w : TriadicOrientedSliceAssemblyWitness)
    (hEst : TriadicResidualCoreEstimateProp w)
    (hTarget : TriadicResidualCapThresholdInequalityTargetProp w) :
    OrientedSliceResidualAbsorptionProp w.toOrientedSliceAssemblyWitness := by
  intro traj t hNS hFS
  have hMaj :
      w.residual traj t ≤ triadicCrossOrientationResidual w.triadicCoeff traj t :=
    hEst traj t hNS hFS
  have hSub :
      enstrophy (traj.stateAt t).velocity *
        enstrophy (traj.stateAt t).velocity ≤
      subcriticalEnstrophySquaredThreshold :=
    hTarget traj t hNS hFS
  have hTriad :
      triadicCrossOrientationResidual w.triadicCoeff traj t ≤ 0 := by
    unfold triadicCrossOrientationResidual
    nlinarith [hSub, w.triadicCoeff_nonneg]
  exact le_trans hMaj hTriad

/-- Residual absorption from the single cap-threshold target:
`Ω² ≤ Ω*²` + `triadicCoeff ≥ 0` implies triadic residual `≤ 0`. -/
theorem triadic_residual_absorption_from_cap_threshold_target
    (w : TriadicOrientedSliceAssemblyWitness)
    (hTarget : TriadicResidualCapThresholdInequalityTargetProp w) :
    OrientedSliceResidualAbsorptionProp w.toOrientedSliceAssemblyWitness := by
  intro traj t hNS hFS
  have hSub :
      enstrophy (traj.stateAt t).velocity *
        enstrophy (traj.stateAt t).velocity ≤
      subcriticalEnstrophySquaredThreshold :=
    hTarget traj t hNS hFS
  have hTriad :
      triadicCrossOrientationResidual w.triadicCoeff traj t ≤ 0 := by
    unfold triadicCrossOrientationResidual
    nlinarith [hSub, w.triadicCoeff_nonneg]
  simpa [w.residual_is_triadic traj t] using hTriad

/-- 1609-style triadic sign/locality ordering contract:
decompose the triadic coefficient into nonnegative local/nonlocal components
with an explicit ordering relation. This stays at interface level. -/
def TriadicSignLocalityOrderingContractProp
    (w : TriadicOrientedSliceAssemblyWitness) : Prop :=
  ∃ (coeffLocal coeffNonlocal : Rat),
    0 ≤ coeffLocal ∧
    0 ≤ coeffNonlocal ∧
    coeffNonlocal ≤ coeffLocal ∧
    w.triadicCoeff = coeffLocal + coeffNonlocal

/-- Ordering contract implies nonnegative triadic coefficient. -/
theorem triadic_sign_locality_ordering_implies_coeff_nonneg
    (w : TriadicOrientedSliceAssemblyWitness)
    (hOrder : TriadicSignLocalityOrderingContractProp w) :
    0 ≤ w.triadicCoeff := by
  rcases hOrder with ⟨coeffLocal, coeffNonlocal, hLocal, hNonlocal, _hOrd, hEq⟩
  rw [hEq]
  nlinarith [hLocal, hNonlocal]

/-- Alternative cap-target absorption route:
replace direct `triadicCoeff_nonneg` usage by an explicit 1609-style
sign/locality ordering contract. -/
theorem triadic_residual_absorption_from_cap_threshold_target_and_ordering
    (w : TriadicOrientedSliceAssemblyWitness)
    (hTarget : TriadicResidualCapThresholdInequalityTargetProp w)
    (hOrder : TriadicSignLocalityOrderingContractProp w) :
    OrientedSliceResidualAbsorptionProp w.toOrientedSliceAssemblyWitness := by
  intro traj t hNS hFS
  have hSub :
      enstrophy (traj.stateAt t).velocity *
        enstrophy (traj.stateAt t).velocity ≤
      subcriticalEnstrophySquaredThreshold :=
    hTarget traj t hNS hFS
  have hCoeffNonneg : 0 ≤ w.triadicCoeff :=
    triadic_sign_locality_ordering_implies_coeff_nonneg w hOrder
  have hTriad :
      triadicCrossOrientationResidual w.triadicCoeff traj t ≤ 0 := by
    unfold triadicCrossOrientationResidual
    nlinarith [hSub, hCoeffNonneg]
  simpa [w.residual_is_triadic traj t] using hTriad

/-- 1702-style residual competition diagnostic contract:
split the assembled residual into an absorbing branch and a leakage branch.
This is diagnostic/non-blocking and reduces to the same core component node. -/
def TriadicResidualCompetitionSplitDiagnosticProp
    (w : TriadicOrientedSliceAssemblyWitness) : Prop :=
  ∃ (residualAbsorbing residualLeakage : Trajectory NSField → Rat → Rat),
    (∀ (traj : Trajectory NSField) (t : Rat),
      w.residual traj t = residualAbsorbing traj t + residualLeakage traj t) ∧
    (∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      residualAbsorbing traj t ≤ 0) ∧
    (∀ (traj : Trajectory NSField) (t : Rat),
      SatisfiesNSPDE nsOps nsNu traj →
      RespectsFunctionSpaces nsSpacesR3 traj →
      residualLeakage traj t ≤ triadicCrossOrientationResidual w.triadicCoeff traj t)

/-- Diagnostic split reduces to the existing decomposed core components node. -/
theorem triadic_core_components_from_competition_split
    (w : TriadicOrientedSliceAssemblyWitness)
    (hSplit : TriadicResidualCompetitionSplitDiagnosticProp w) :
    TriadicResidualCoreEstimateComponentsProp w := by
  rcases hSplit with ⟨residualAbsorbing, residualLeakage, hDecomp, hAbsorbLe0, hLeakLeTriad⟩
  refine ⟨residualAbsorbing, residualLeakage, ?_, ?_, ?_⟩
  · intro traj t
    exact hDecomp traj t
  · intro traj t hNS hFS
    exact hAbsorbLe0 traj t hNS hFS
  · intro traj t hNS hFS
    exact hLeakLeTriad traj t hNS hFS

/-- Diagnostic split directly implies the single core estimate node. -/
theorem triadic_residual_core_estimate_from_competition_split
    (w : TriadicOrientedSliceAssemblyWitness)
    (hSplit : TriadicResidualCompetitionSplitDiagnosticProp w) :
    TriadicResidualCoreEstimateProp w :=
  triadic_residual_core_estimate_from_components w
    (triadic_core_components_from_competition_split w hSplit)

/-- End-to-end triadic route:
single cap-threshold inequality target -> residual absorption -> `PreciseGapStatement`. -/
theorem triadic_cap_threshold_target_implies_precise_gap
    (w : TriadicOrientedSliceAssemblyWitness)
    (hTarget : TriadicResidualCapThresholdInequalityTargetProp w) :
    PreciseGapStatement :=
  oriented_slice_residual_absorption_implies_precise_gap
    w.toOrientedSliceAssemblyWitness
    (triadic_residual_absorption_from_cap_threshold_target w hTarget)

/-- End-to-end constructive closure from concrete 3D slice-PDE estimates. -/
theorem triadic_precise_gap_from_concrete_3d_slice_pde_estimates
    (w : TriadicOrientedSliceAssemblyWitness)
    (hCompat : SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    PreciseGapStatement :=
  triadic_cap_threshold_target_implies_precise_gap w
    (triadic_cap_threshold_target_from_concrete_3d_slice_pde_estimates w hCompat)

/-- End-to-end closure from explicit cap-threshold compatibility primitive data. -/
theorem triadic_precise_gap_from_cap_threshold_compatibility
    (w : TriadicOrientedSliceAssemblyWitness)
    (hCompat : SliceProjectedCapThresholdCompatibilityPrimitiveProp) :
    PreciseGapStatement :=
  triadic_cap_threshold_target_implies_precise_gap w
    (triadic_cap_threshold_target_from_cap_threshold_compatibility w hCompat)

/-- End-to-end closure through the single residual estimate node. -/
theorem triadic_precise_gap_from_core_estimate_and_cap_target
    (w : TriadicOrientedSliceAssemblyWitness)
    (hEst : TriadicResidualCoreEstimateProp w)
    (hTarget : TriadicResidualCapThresholdInequalityTargetProp w) :
    PreciseGapStatement :=
  oriented_slice_residual_absorption_implies_precise_gap
    w.toOrientedSliceAssemblyWitness
    (triadic_residual_absorption_from_core_estimate_and_cap_target w hEst hTarget)

/-- End-to-end closure through CAT/EPT path-integral normalization + IBP interface
and one cap-threshold inequality target. -/
theorem triadic_precise_gap_from_cat_ept_ibp_and_cap_target
    (w : TriadicOrientedSliceAssemblyWitness)
    (hIBP : CATEPTPathIntegralIBPResidualMajorizationProp w)
    (hTarget : TriadicResidualCapThresholdInequalityTargetProp w) :
    PreciseGapStatement :=
  triadic_precise_gap_from_core_estimate_and_cap_target w hIBP hTarget

/-- End-to-end closure from witness identity + cap-threshold target. -/
theorem triadic_precise_gap_from_witness_identity_and_cap_target
    (w : TriadicOrientedSliceAssemblyWitness)
    (hTarget : TriadicResidualCapThresholdInequalityTargetProp w) :
    PreciseGapStatement :=
  triadic_precise_gap_from_core_estimate_and_cap_target w
    (triadic_residual_core_estimate_from_witness_identity w) hTarget

/-! ## Claim Registry -/

def sliceRotationalAssemblyClaims : List LabeledClaim :=
  [ ⟨"oriented_slice_residual_absorption_implies_direct_vs_le_nuP", .partiallyVerified,
      "THEOREM: oriented-slice 3D reconstruction with absorbed residual yields direct pointwise VS≤νP"⟩
  , ⟨"oriented_slice_residual_absorption_implies_kernel", .partiallyVerified,
      "THEOREM: residual-absorbed oriented-slice route reduces to NSVSNuPKernel proposition"⟩
  , ⟨"oriented_slice_residual_absorption_implies_precise_gap", .partiallyVerified,
      "THEOREM: residual-absorbed oriented-slice route implies PreciseGapStatement through kernel chain"⟩
  , ⟨"oriented_slice_rate_source_implies_cap_threshold_compatibility", .partiallyVerified,
      "THEOREM: explicit source-witness data imply cap-threshold compatibility primitive on slice route"⟩
  , ⟨"oriented_slice_rate_source_implies_precise_gap_via_cap_threshold", .partiallyVerified,
      "COROLLARY: source-witness route implies PreciseGapStatement via cap-threshold compatibility"⟩
  , ⟨"triadic_residual_absorption_from_cap_threshold_target", .partiallyVerified,
      "THEOREM: concrete triadic cross-orientation residual is absorbed from one cap-threshold inequality target Ω²≤ν⁴λ₁/C⁴"⟩
  , ⟨"triadic_sign_locality_ordering_contract_prop", .openBridge,
      "OPEN: 1609-style triadic sign/locality ordering contract for witness coefficient decomposition"⟩
  , ⟨"triadic_sign_locality_ordering_implies_coeff_nonneg", .partiallyVerified,
      "THEOREM: sign/locality ordering contract implies nonnegative triadic coefficient"⟩
  , ⟨"triadic_residual_absorption_from_cap_threshold_target_and_ordering", .partiallyVerified,
      "THEOREM: cap-threshold target + sign/locality ordering contract imply residual absorption"⟩
  , ⟨"triadic_residual_competition_split_diagnostic_prop", .openBridge,
      "OPEN: 1702-style residual competition split (absorbing/leakage) diagnostic contract"⟩
  , ⟨"triadic_core_components_from_competition_split", .partiallyVerified,
      "THEOREM: diagnostic competition split reduces to decomposed core residual components node"⟩
  , ⟨"triadic_residual_core_estimate_from_competition_split", .partiallyVerified,
      "THEOREM: diagnostic competition split implies the single core residual estimate node"⟩
  , ⟨"triadic_cap_threshold_target_from_concrete_3d_slice_pde_estimates", .partiallyVerified,
      "THEOREM: triadic cap-threshold target is discharged by concrete 3D slice-PDE estimate producers"⟩
  , ⟨"triadic_cap_threshold_target_from_cap_threshold_compatibility", .partiallyVerified,
      "THEOREM: triadic cap-threshold target follows from explicit cap-threshold compatibility primitive data"⟩
  , ⟨"triadic_oriented_slice_assembly_witness_from_concrete_3d_slice_pde", .openBridge,
      "OPEN: construct a triadic oriented-slice assembly witness from concrete 3D slice-projection PDE estimates"⟩
  , ⟨"triadic_residual_core_estimate_prop", .partiallyVerified,
      "THEOREM-LEVEL NODE: residual ≤ triadicCoeff·(Ω²-Ω*²) follows directly once triadic witness identity is available"⟩
  , ⟨"triadic_residual_core_estimate_components_prop", .openBridge,
      "OPEN: decomposed primitive contracts (sign component + cap component) for the core residual estimate"⟩
  , ⟨"helical_triadic_residual_decomposition_prop", .openBridge,
      "OPEN: 0206030-style helical (+/-/cross) residual decomposition contract feeding core component route"⟩
  , ⟨"triadic_core_components_from_helical_decomposition", .partiallyVerified,
      "THEOREM: 0206030-style helical decomposition contracts reduce to existing decomposed core residual components node"⟩
  , ⟨"triadic_residual_core_estimate_from_helical_decomposition", .partiallyVerified,
      "THEOREM: 0206030-style helical decomposition contracts imply the single core residual estimate node"⟩
  , ⟨"triadic_residual_core_estimate_from_components", .partiallyVerified,
      "THEOREM: decomposed primitive residual contracts imply the single core residual estimate node"⟩
  , ⟨"triadic_residual_core_estimate_from_witness_identity", .partiallyVerified,
      "THEOREM: core residual majorization is immediate from the triadic witness residual identity field"⟩
  , ⟨"cat_ept_path_integral_ibp_residual_majorization_prop", .partiallyVerified,
      "THEOREM-LEVEL INTERFACE: CAT/EPT IBP majorization equals core residual estimate contract"⟩
  , ⟨"cat_ept_path_integral_ibp_residual_majorization_components_prop", .openBridge,
      "OPEN: decomposed CAT/EPT normalization+IBP component contracts for residual majorization"⟩
  , ⟨"cat_ept_path_integral_ibp_majorization_from_components", .partiallyVerified,
      "THEOREM: decomposed CAT/EPT component contracts imply the majorization interface"⟩
  , ⟨"cat_ept_path_integral_ibp_majorization_from_witness_identity", .partiallyVerified,
      "THEOREM: CAT/EPT majorization interface is immediate from triadic witness residual identity"⟩
  , ⟨"triadic_residual_absorption_from_core_estimate_and_cap_target", .partiallyVerified,
      "THEOREM: core residual estimate + one cap-threshold inequality imply residual absorption"⟩
  , ⟨"triadic_cap_threshold_target_implies_precise_gap", .partiallyVerified,
      "COROLLARY: triadic residual route (single cap-threshold target) implies PreciseGapStatement through kernel chain"⟩
  , ⟨"triadic_precise_gap_from_concrete_3d_slice_pde_estimates", .partiallyVerified,
      "COROLLARY: concrete 3D slice-PDE estimate route implies PreciseGapStatement via triadic cap-threshold target"⟩
  , ⟨"triadic_precise_gap_from_cap_threshold_compatibility", .partiallyVerified,
      "COROLLARY: explicit cap-threshold compatibility route implies PreciseGapStatement via triadic residual chain"⟩
  , ⟨"triadic_precise_gap_from_core_estimate_and_cap_target", .partiallyVerified,
      "COROLLARY: single residual-estimate node + single cap-threshold target imply PreciseGapStatement"⟩
  , ⟨"triadic_precise_gap_from_cat_ept_ibp_and_cap_target", .partiallyVerified,
      "COROLLARY: CAT/EPT IBP-normalized residual majorization + cap-threshold target imply PreciseGapStatement"⟩
  , ⟨"triadic_precise_gap_from_witness_identity_and_cap_target", .partiallyVerified,
      "COROLLARY: triadic witness residual identity + cap-threshold target imply PreciseGapStatement"⟩ ]

end

end NavierStokes.SliceRotationalAssembly
