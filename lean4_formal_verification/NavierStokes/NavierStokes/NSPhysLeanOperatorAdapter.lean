import NavierStokes.AxiomaticEstimates

/-!
# NS PhysLean Operator Adapter (Stage 219)

This module introduces a PhysLean-shaped operator backend contract for the
current `NSField` carrier, without changing the existing `nsOps` API.

Why this file exists:
- We need a concrete integration point for physicalization work (G04/G05 lanes)
  that can be consumed by multiple helpers.
- The current NavierStokes package does not yet import PhysLean directly, so this
  file defines a compatibility layer with PhysLean-like operator contracts
  (`curl`, `div`, `laplace`, `div_of_curl_eq_zero`) and proves interoperability
  with current `nsOps`.

Immediate use:
- Keep all existing proofs using `nsOps`.
- Start implementing concrete operator backends behind this adapter.
- Preserve the bridge shape while reducing placeholder drift.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

/-- PhysLean-shaped operator backend on the current `NSField` carrier.
    The field names intentionally mirror vector-calculus operators used in
    external formal libraries (curl/div/laplacian contracts). -/
structure NSPhysLeanOperatorBackend where
  grad : NSField → NSField
  div : NSField → NSField
  laplace : NSField → NSField
  convection : NSField → NSField → NSField
  ddt : NSField → NSField
  curl : NSField → NSField
  /-- Compatibility contract matching the usual vector-calculus identity. -/
  div_of_curl_eq_zero : ∀ v : NSField, div (curl v) = nsZero

/-- Convert the backend to the existing PDE interface expected by the project. -/
def NSPhysLeanOperatorBackend.toFieldOps (backend : NSPhysLeanOperatorBackend) : FieldOps NSField where
  zero := nsZero
  add := nsAdd
  smul := nsSmul
  grad := backend.grad
  div := backend.div
  laplace := backend.laplace
  convection := backend.convection
  ddt := backend.ddt

/-- Predicate stating backend/operator-level compatibility with current `nsOps`. -/
def NSPhysLeanAdapterCompatible (backend : NSPhysLeanOperatorBackend) : Prop :=
  (∀ v : NSField, backend.grad v = nsGrad v) ∧
  (∀ v : NSField, backend.div v = nsDiv v) ∧
  (∀ v : NSField, backend.laplace v = nsLaplace v) ∧
  (∀ u v : NSField, backend.convection u v = nsConvection u v) ∧
  (∀ v : NSField, backend.ddt v = nsDdt v)

/-- Surrogate backend wired to the current concrete compatibility operators.
    This is the default bridge-preserving backend for Stage 219. -/
def nsPhysLeanSurrogateBackend : NSPhysLeanOperatorBackend where
  grad := nsGrad
  div := nsDiv
  laplace := nsLaplace
  convection := nsConvection
  ddt := nsDdt
  curl := fun _ => nsZero
  div_of_curl_eq_zero := by
    intro v
    ext n
    · unfold nsDiv nsZero
      simp
    · unfold nsDiv nsZero
      simp

/-- The surrogate backend is definitionally compatible with current `nsOps`. -/
theorem nsPhysLeanSurrogateBackend_compatible :
    NSPhysLeanAdapterCompatible nsPhysLeanSurrogateBackend := by
  constructor
  · intro v
    rfl
  constructor
  · intro v
    rfl
  constructor
  · intro v
    rfl
  constructor
  · intro u v
    rfl
  · intro v
    rfl

/-- For compatible backends, the incompressible NS proposition is unchanged. -/
theorem incompressibleNS_eq_of_physLean_adapter
    (backend : NSPhysLeanOperatorBackend)
    (nu : Rat)
    (st : State NSField)
    (hCompat : NSPhysLeanAdapterCompatible backend) :
    IncompressibleNS (backend.toFieldOps) nu st ↔ IncompressibleNS nsOps nu st := by
  rcases hCompat with ⟨hGrad, hDiv, hLaplace, hConvection, hDdt⟩
  have hGradP : backend.grad st.pressure = nsGrad st.pressure := hGrad st.pressure
  have hDivV : backend.div st.velocity = nsDiv st.velocity := hDiv st.velocity
  have hLapV : backend.laplace st.velocity = nsLaplace st.velocity := hLaplace st.velocity
  have hConvVV : backend.convection st.velocity st.velocity = nsConvection st.velocity st.velocity :=
    hConvection st.velocity st.velocity
  have hDdtV : backend.ddt st.velocity = nsDdt st.velocity := hDdt st.velocity
  simp [IncompressibleNS, NSPhysLeanOperatorBackend.toFieldOps, nsOps,
    hGradP, hDivV, hLapV, hConvVV, hDdtV]

/-- For compatible backends, trajectory-level NS satisfiability is unchanged. -/
theorem satisfiesNSPDE_eq_of_physLean_adapter
    (backend : NSPhysLeanOperatorBackend)
    (nu : Rat)
    (traj : Trajectory NSField)
    (hCompat : NSPhysLeanAdapterCompatible backend) :
    SatisfiesNSPDE (backend.toFieldOps) nu traj ↔ SatisfiesNSPDE nsOps nu traj := by
  constructor
  · intro h t
    exact (incompressibleNS_eq_of_physLean_adapter backend nu (traj.stateAt t) hCompat).1 (h t)
  · intro h t
    exact (incompressibleNS_eq_of_physLean_adapter backend nu (traj.stateAt t) hCompat).2 (h t)

/-- Discrete-time witness transport for the surrogate backend. -/
theorem exists_nspde_delta_witness_physLean_surrogate
    (nu h : Rat) :
    ∃ traj : Trajectory NSField,
      SatisfiesNSPDEΔ (nsPhysLeanSurrogateBackend.toFieldOps) nu h traj := by
  refine ⟨nsZeroTrajectory, ?_⟩
  simpa [NSPhysLeanOperatorBackend.toFieldOps, nsPhysLeanSurrogateBackend]
    using nsZeroTrajectory_satisfies_nspde_delta nu h

/-- Bridge-level backward bootstrap is invariant under compatible adapter backends. -/
theorem backward_bridge_obligation_bootstrap_physLean_transport
    (backend : NSPhysLeanOperatorBackend)
    (spaces : FunctionSpaceAssumptions NSField)
    (nu : Rat)
    (pi : PathIntegralInterface NSField)
    (_hCompat : NSPhysLeanAdapterCompatible backend)
    (hControl : VorticityBlowupControl (backend.toFieldOps) spaces nu pi) :
    (∀ st0 : State NSField, pi.PIWellPosed st0 → AdmissibleInitialData spaces st0) →
    BackwardBridgeObligation (backend.toFieldOps) spaces nu pi := by
  -- This is exactly the generic PDEInterfaces bootstrap theorem applied to
  -- the backend-provided `FieldOps`.
  intro hAdmissible
  exact backward_bridge_obligation_bootstrap (backend.toFieldOps) spaces nu pi hControl hAdmissible

end

end NavierStokes.Millennium
