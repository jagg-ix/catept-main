import NavierStokesClean.CATEPT.MeasurePathIntegral

/-!
# CATEPT External Interface: No Faster Than Light (AFP)

Opt-in causality contracts for integrating AFP no-superluminal proofs with
CAT/EPT source-coupled expectation flow.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.External

noncomputable section

/-- A spacetime displacement satisfies a causal-separation inequality at speed `c`. -/
def CausalSeparated (c Δx Δt : ℝ) : Prop :=
  c * |Δt| ≤ |Δx|

/-- No-FTL certificate exported from an external formalization lane. -/
structure NoFasterThanLightCertificate where
  signalSpeed : ℝ
  lightSpeed : ℝ
  lightSpeed_pos : 0 < lightSpeed
  speed_le_light : signalSpeed ≤ lightSpeed
  microcausalityContract : Prop
  microcausalityHolds : microcausalityContract

/-- Core no-superluminal inequality from the certificate. -/
theorem NoFasterThanLightCertificate.no_superluminal
    (w : NoFasterThanLightCertificate) :
    w.signalSpeed ≤ w.lightSpeed :=
  w.speed_le_light

/-- Causal-separation transfer: if a point is light-causally separated, replacing
`c` by any smaller speed preserves separation. -/
theorem NoFasterThanLightCertificate.causal_transfer
    (w : NoFasterThanLightCertificate)
    {Δx Δt : ℝ}
    (hsep : CausalSeparated w.lightSpeed Δx Δt) :
    CausalSeparated w.signalSpeed Δx Δt := by
  unfold CausalSeparated at hsep ⊢
  have habs_nonneg : 0 ≤ |Δt| := abs_nonneg Δt
  calc
    w.signalSpeed * |Δt| ≤ w.lightSpeed * |Δt| :=
      mul_le_mul_of_nonneg_right w.speed_le_light habs_nonneg
    _ ≤ |Δx| := hsep

/-- Expose the external microcausality contract (commutation at spacelike separation). -/
theorem NoFasterThanLightCertificate.has_microcausality
    (w : NoFasterThanLightCertificate) :
    w.microcausalityContract :=
  w.microcausalityHolds

end

end NavierStokesClean.CATEPT.External
