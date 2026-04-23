import Mathlib.Data.Real.Basic

/-!
# CATEPT External Interface: Carleson/Harmonic-Analysis Layer

Opt-in contract layer to leverage Carleson-style operator-control results
(for example spectral projection and weak/strong type bounds) without importing
the external Carleson repository directly.

Reference alignment points in the external project include:
- `Carleson/Classical/SpectralProjectionBound.lean`
- `Carleson/WeakType.lean`
- `Carleson/ForestOperator/L2Estimate.lean`
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.External

noncomputable section

/-- Certificate exposing Carleson-style spectral/dephasing control as a reusable
contract for ETH-style thermalization bounds. -/
structure CarlesonSpectralCertificate where
  Signal : Type*
  spectralProjection : ℕ → Signal → Signal
  norm : Signal → ℝ
  norm_nonneg : ∀ x : Signal, 0 ≤ norm x
  projection_contraction : ∀ N : ℕ, ∀ x : Signal, norm (spectralProjection N x) ≤ norm x
  projectionErrorEnvelope : ℝ
  projectionErrorEnvelope_nonneg : 0 ≤ projectionErrorEnvelope
  weakTypeBound : Prop
  strongTypeL2Bound : Prop
  weakTypeBound_holds : weakTypeBound
  strongTypeL2Bound_holds : strongTypeL2Bound

theorem CarlesonSpectralCertificate.projection_contracts
    (w : CarlesonSpectralCertificate) (N : ℕ) (x : w.Signal) :
    w.norm (w.spectralProjection N x) ≤ w.norm x :=
  w.projection_contraction N x

theorem CarlesonSpectralCertificate.projection_errorEnvelope_nonneg
    (w : CarlesonSpectralCertificate) :
    0 ≤ w.projectionErrorEnvelope :=
  w.projectionErrorEnvelope_nonneg

theorem CarlesonSpectralCertificate.has_weakTypeBound
    (w : CarlesonSpectralCertificate) :
    w.weakTypeBound :=
  w.weakTypeBound_holds

theorem CarlesonSpectralCertificate.has_strongTypeL2Bound
    (w : CarlesonSpectralCertificate) :
    w.strongTypeL2Bound :=
  w.strongTypeL2Bound_holds

theorem CarlesonSpectralCertificate.projectedNorm_le_withEnvelope
    (w : CarlesonSpectralCertificate) (N : ℕ) (x : w.Signal) :
    w.norm (w.spectralProjection N x) ≤ w.norm x + w.projectionErrorEnvelope := by
  calc
    w.norm (w.spectralProjection N x) ≤ w.norm x := w.projection_contracts N x
    _ ≤ w.norm x + w.projectionErrorEnvelope :=
      le_add_of_nonneg_right w.projection_errorEnvelope_nonneg

end

end NavierStokesClean.CATEPT.External
