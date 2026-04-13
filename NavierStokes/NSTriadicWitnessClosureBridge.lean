import NavierStokes.NSSliceRotationalAssemblyBridge

/-!
# Stage 292 — NSTriadicWitnessClosureBridge: Triadic Witness Open Bridges → Theorems

Promotes three `.openBridge` contracts from `NSSliceRotationalAssemblyBridge` to
THEOREMS with **0 new axioms**, using only the structure fields of
`TriadicOrientedSliceAssemblyWitness`.

## The three promotions

### 1. `triadic_sign_locality_ordering_from_witness`

`TriadicSignLocalityOrderingContractProp w` is an existence claim: split
`w.triadicCoeff` into `(coeffLocal, coeffNonlocal)` with sign control.

**Proof**: take `coeffLocal := w.triadicCoeff, coeffNonlocal := 0`. Then:
  - `0 ≤ coeffLocal` = `w.triadicCoeff_nonneg`
  - `0 ≤ coeffNonlocal` = `le_refl 0`
  - `coeffNonlocal ≤ coeffLocal` = `w.triadicCoeff_nonneg`
  - `w.triadicCoeff = coeffLocal + coeffNonlocal` = `by ring`

The claim registry entry `.openBridge` was overly conservative: the field
`triadicCoeff_nonneg` in the witness already supplies everything needed.

### 2. `triadic_residual_core_estimate_components_from_witness`

`TriadicResidualCoreEstimateComponentsProp w` decomposes `w.residual` into
a sign component (≤ 0) and a cap component (≤ triadicProfile).

**Proof**: take `residualSign := fun _ _ => 0, residualCap := w.residual`. Then:
  - Sum: `w.residual traj t = 0 + w.residual traj t` = `(zero_add _).symm`
  - Sign: `0 ≤ 0` = `le_refl 0`
  - Cap: `w.residual traj t ≤ triadicCrossOrientationResidual w.triadicCoeff traj t`
      = `le_of_eq (w.residual_is_triadic traj t)`

The `residual_is_triadic` field provides the cap bound for free.

### 3. `cat_ept_ibp_residual_majorization_components_from_witness`

`CATEPTPathIntegralIBPResidualMajorizationComponentsProp w` is definitionally
equal to `TriadicResidualCoreEstimateComponentsProp w`, so the proof is
immediate from (2).

## Net: 3 open bridges promoted, 0 new axioms, +3 theorems

After Stage 292, the open bridges in `NSSliceRotationalAssemblyBridge` reduce
from 6 to 3:

| Was open | Now |
|----------|-----|
| `triadic_sign_locality_ordering_contract_prop` | THEOREM (this file) |
| `triadic_residual_core_estimate_components_prop` | THEOREM (this file) |
| `cat_ept_path_integral_ibp_residual_majorization_components_prop` | THEOREM (this file) |

Remaining open (requiring genuine new content):
| Still open | Reason |
|------------|--------|
| `triadic_oriented_slice_assembly_witness_from_concrete_3d_slice_pde` | Requires `SliceProjectedVSLeNuPPrimitiveProp` on abstract trajectories |
| `triadic_residual_competition_split_diagnostic_prop` | Deprioritized (Tao filter) |
| `helical_triadic_residual_decomposition_prop` | Deprioritized (Tao filter) |

## Net counts

  - New axioms:   0
  - New theorems: 3
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.TriadicWitnessClosure

set_option autoImplicit false

open NavierStokes.SliceDecomposition
open NavierStokes.SliceRotationalAssembly
open NavierStokes.Millennium

noncomputable section

/-! ## §1. Sign/Locality Ordering is Free from triadicCoeff_nonneg -/

/-- **Free promotion**: `TriadicSignLocalityOrderingContractProp w` holds for any
    `TriadicOrientedSliceAssemblyWitness`, with **0 new axioms**.

    Witness: `(coeffLocal, coeffNonlocal) := (w.triadicCoeff, 0)`.
    The ordering `coeffNonlocal ≤ coeffLocal` follows from `w.triadicCoeff_nonneg`.

    This shows the `.openBridge` label in the claim registry was conservative:
    the structural field `triadicCoeff_nonneg` already supplies the decomposition. -/
theorem triadic_sign_locality_ordering_from_witness
    (w : TriadicOrientedSliceAssemblyWitness) :
    TriadicSignLocalityOrderingContractProp w :=
  ⟨w.triadicCoeff, 0,
   w.triadicCoeff_nonneg,
   le_refl 0,
   w.triadicCoeff_nonneg,
   by ring⟩

/-! ## §2. Core Residual Components is Free from residual_is_triadic -/

/-- **Free promotion**: `TriadicResidualCoreEstimateComponentsProp w` holds for any
    `TriadicOrientedSliceAssemblyWitness`, with **0 new axioms**.

    Witness: `residualSign := fun _ _ => 0`, `residualCap := w.residual`.

    - Sum decomposition: `w.residual = 0 + w.residual` by `zero_add`.
    - Sign bound: `0 ≤ 0` trivially.
    - Cap bound: `w.residual traj t ≤ triadicCrossOrientationResidual w.triadicCoeff traj t`
        follows from `le_of_eq (w.residual_is_triadic traj t)`.

    The `residual_is_triadic` field is the key: it identifies the residual with the
    triadic profile, which is exactly what the cap bound requires. -/
theorem triadic_residual_core_estimate_components_from_witness
    (w : TriadicOrientedSliceAssemblyWitness) :
    TriadicResidualCoreEstimateComponentsProp w :=
  ⟨fun _ _ => 0,
   w.residual,
   fun traj t => (zero_add (w.residual traj t)).symm,
   fun _ _ _ _ => le_refl 0,
   fun traj t _ _ => le_of_eq (w.residual_is_triadic traj t)⟩

/-! ## §3. CAT/EPT IBP Components is Definitionally Equal to §2 -/

/-- **Free promotion**: `CATEPTPathIntegralIBPResidualMajorizationComponentsProp w` holds
    for any `TriadicOrientedSliceAssemblyWitness`, with **0 new axioms**.

    By definition, `CATEPTPathIntegralIBPResidualMajorizationComponentsProp w =
    TriadicResidualCoreEstimateComponentsProp w`, so this is immediate from §2. -/
theorem cat_ept_ibp_residual_majorization_components_from_witness
    (w : TriadicOrientedSliceAssemblyWitness) :
    CATEPTPathIntegralIBPResidualMajorizationComponentsProp w :=
  triadic_residual_core_estimate_components_from_witness w

/-! ## §4. Summary Corollary -/

/-- The three formerly-open contracts all hold for any triadic witness.
    Documents the Stage 292 closure in a single statement. -/
theorem stage292_three_open_bridges_closed (w : TriadicOrientedSliceAssemblyWitness) :
    TriadicSignLocalityOrderingContractProp w ∧
    TriadicResidualCoreEstimateComponentsProp w ∧
    CATEPTPathIntegralIBPResidualMajorizationComponentsProp w :=
  ⟨triadic_sign_locality_ordering_from_witness w,
   triadic_residual_core_estimate_components_from_witness w,
   cat_ept_ibp_residual_majorization_components_from_witness w⟩

end

def stage292Summary : String :=
  "Stage 292: NSTriadicWitnessClosureBridge — 3 open bridges promoted to theorems (0 new axioms). " ++
  "triadic_sign_locality_ordering_from_witness: TriadicSignLocalityOrderingContractProp w " ++
    "(coeffLocal=triadicCoeff, coeffNonlocal=0, from triadicCoeff_nonneg). " ++
  "triadic_residual_core_estimate_components_from_witness: TriadicResidualCoreEstimateComponentsProp w " ++
    "(residualSign=0, residualCap=residual, from residual_is_triadic). " ++
  "cat_ept_ibp_residual_majorization_components_from_witness: defn-equal to above. " ++
  "stage292_three_open_bridges_closed: conjunction of all three. " ++
  "+0 axioms, +4 theorems, 0 sorry. " ++
  "Remaining open (NSSliceRotationalAssemblyBridge): 3 bridges " ++
    "(triadic_oriented_slice_assembly_witness_from_concrete_3d_slice_pde, " ++
    "triadic_residual_competition_split_diagnostic_prop [deprioritized], " ++
    "helical_triadic_residual_decomposition_prop [deprioritized])."

end NavierStokes.TriadicWitnessClosure
