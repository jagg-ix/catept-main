import CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge
import CATEPTMain.CATEPT.CATEPT.ModularFlowKucharCoreAbstractions
import Mathlib.Data.Complex.Basic

/-!
# UV-Certificate Compatibility Bridge (T-FF Phase 9)

Phase-9 honest content: connect the **complex** counterterm-free
UV-limit packaging from Phase 8
(`SimplexPathIntegralNoRenormBridge.CountertermFreeUVLimit`) with
the pre-existing **real-valued** modular-flow / Kuchar lane
contract `UVConvergenceCertificate` defined in
`CATEPTMain.CATEPT.CATEPT.ModularFlowKucharCoreAbstractions`.

We provide the canonical embedding: every real-valued
`UVConvergenceCertificate` (with its exponential-tail bound and
explicit `Tendsto` field) lifts canonically to a
counterterm-free complex UV limit by composing the cutoff
partition with `Complex.ofReal` and pinning the counterterm to
`0`. The exponential tail bound is preserved because the norm
of a real number cast into `ℂ` agrees with its absolute value
(`Complex.norm_real`).

Three honest theorems:

* `ofUVConvergenceCertificate_continuumPartition_eq_ofReal`
  — the continuum partition of the lifted complex limit is the
  `ofReal` of the real continuum partition.
* `ofUVConvergenceCertificate_counterterm_eq_zero` — the
  lifted complex limit carries a zero counterterm.
* `ofUVConvergenceCertificate_no_counterterm_needed` — the
  lifted limit satisfies the Phase-8 main bridge: ℂ-convergence
  to the continuum partition with counterterm `= 0`.

Honest scope: this is the strict, fully formal compatibility
bridge between the two contract layers. It is *not* a derivation
of either certificate from physical first principles.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge

open CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge
open CATEPTMain.CATEPT.CATEPT
open Filter Topology

noncomputable section

/-- **Canonical lift** of a real-valued `UVConvergenceCertificate`
to a complex counterterm-free UV limit. The cutoff partition is
composed with `Complex.ofReal`, and the counterterm field is
pinned to `0`. The exponential-tail bound is transported via
`Complex.norm_real`. -/
def ofUVConvergenceCertificate (uv : UVConvergenceCertificate) :
    CountertermFreeUVLimit where
  cutoffPartition := fun N => ((uv.cutoffPartition N : ℝ) : ℂ)
  continuumPartition := ((uv.continuumPartition : ℝ) : ℂ)
  epsilonUV := uv.entropicRegStrength
  epsilonUV_pos := uv.entropicRegStrength_pos
  exponentialTail := by
    intro N
    have h := uv.exponentialTailBound N
    -- ‖(↑(Z_N) - ↑Z_∞ : ℂ)‖ = |Z_N - Z_∞| ≤ exp(-(ε N))
    have hcast :
        (((uv.cutoffPartition N : ℝ) : ℂ) - ((uv.continuumPartition : ℝ) : ℂ))
          = (((uv.cutoffPartition N - uv.continuumPartition : ℝ) : ℂ)) := by
      push_cast; ring
    rw [hcast, Complex.norm_real]
    exact h
  counterterm := 0
  counterterm_zero := rfl

/-- The continuum partition of the lifted complex limit is the
`ofReal` of the real continuum partition. -/
theorem ofUVConvergenceCertificate_continuumPartition_eq_ofReal
    (uv : UVConvergenceCertificate) :
    (ofUVConvergenceCertificate uv).continuumPartition
      = ((uv.continuumPartition : ℝ) : ℂ) := rfl

/-- The lifted complex limit carries a zero counterterm. -/
theorem ofUVConvergenceCertificate_counterterm_eq_zero
    (uv : UVConvergenceCertificate) :
    (ofUVConvergenceCertificate uv).counterterm = 0 := rfl

/-- **Compatibility bridge**: the canonical lift of a real
`UVConvergenceCertificate` discharges the Phase-8 main
no-counterterm theorem, simultaneously witnessing
ℂ-convergence to the continuum partition and the absence of a
counterterm. -/
theorem ofUVConvergenceCertificate_no_counterterm_needed
    (uv : UVConvergenceCertificate) :
    Tendsto (ofUVConvergenceCertificate uv).cutoffPartition atTop
        (𝓝 (ofUVConvergenceCertificate uv).continuumPartition) ∧
      (ofUVConvergenceCertificate uv).counterterm = 0 :=
  exponential_uv_tail_implies_no_counterterm_needed
    (ofUVConvergenceCertificate uv)

end

end CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge
