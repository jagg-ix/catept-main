import CATEPTMain.CATEPT.CATEPT.ModularFlowKucharCoreAbstractions
import CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge

/-!
# Entropic Coercivity → UV Convergence Certificate (T-FF Phase 11)

Phase-11 honest content: a clean abstract bridge that
**separates physics obligation from analysis machinery**, in
the spirit of the user's plan target

  `coercive_entropic_action_gives_uv_certificate`

The physics obligation (coercivity of the imaginary action
`S_I[Φ] ≥ C · ‖Φ‖²_UV`) and the analysis obligation (spectral
tail bound `‖Z_N − Z_∞‖ ≤ exp(−ε · N)`) are packaged as two
abstract input records. Nothing is derived from CAT/EPT
primitives here — both are taken as hypotheses.

What is honestly proven:

* `coercive_entropic_action_gives_uv_certificate` (def):
  given a model carrying the exponential UV scale `ε > 0` and
  a spectral-tail witness providing the per-cutoff bound and
  convergence, produces the canonical
  `UVConvergenceCertificate`.
* `coercive_entropic_action_yields_uv_certificate_tail`
  (theorem): the resulting certificate's per-`N` tail bound
  is exactly the supplied spectral tail.
* `coercive_entropic_action_yields_uv_certificate_tendsto`
  (theorem): the resulting certificate's continuum
  convergence is exactly the supplied tendsto witness.
* `coercive_entropic_action_yields_no_counterterm_needed`
  (theorem): composing the produced real certificate with
  Phase 9's `ofUVConvergenceCertificate`, the lifted complex
  Phase-8 limit converges to its continuum partition with the
  counterterm pinned to zero.

Honest scope: this is a **Lean-level wiring lemma**, not a
physics derivation. It records that *if* coercivity-driven
spectral-tail bounds are supplied at the appropriate UV scale,
*then* the existing `UVConvergenceCertificate` and Phase-8
no-counterterm bridge are immediate.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.EntropicCoercivityToUVCertificate

open CATEPTMain.CATEPT.CATEPT
open CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge
open CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge
open Filter Topology

noncomputable section

/-- **Physics-side input** (abstract): a cutoff-partition
family with a continuum value, sharing a positive UV scale
playing the role of the coercivity constant `C` in
`S_I[Φ] ≥ C · ‖Φ‖²_UV`. Nothing is derived here — the field
`coercivityConst` is taken as the hypothesized exponential UV
suppression strength. -/
structure EntropicCoercivityModel where
  /-- Cutoff partition `Z_N` indexed by UV cutoff level `N`. -/
  cutoffPartition : ℕ → ℝ
  /-- Continuum partition `Z_∞`. -/
  continuumPartition : ℝ
  /-- Exponential UV suppression strength `ε > 0`. -/
  coercivityConst : ℝ
  /-- Strict positivity of the UV suppression strength. -/
  coercivityConst_pos : 0 < coercivityConst

/-- **Analysis-side input** (abstract): given an
`EntropicCoercivityModel`, a spectral-tail witness providing
the per-`N` exponential bound and the convergence statement.
This is the lemma that physically would come from coercivity
plus the Stokes spectrum / Weyl mode count argument. -/
structure SpectralTailBound (m : EntropicCoercivityModel) where
  /-- Per-cutoff exponential tail bound. -/
  exponentialTailBound :
    ∀ N, |m.cutoffPartition N - m.continuumPartition|
      ≤ Real.exp (-(m.coercivityConst * (N : ℝ)))
  /-- Convergence of the cutoff family to the continuum value. -/
  tendsToContinuum :
    Tendsto m.cutoffPartition atTop (𝓝 m.continuumPartition)

/-- **Primary bridge**: physics obligation + analysis
obligation produce the canonical `UVConvergenceCertificate`. -/
def coercive_entropic_action_gives_uv_certificate
    (m : EntropicCoercivityModel) (h : SpectralTailBound m) :
    UVConvergenceCertificate where
  cutoffPartition := m.cutoffPartition
  continuumPartition := m.continuumPartition
  entropicRegStrength := m.coercivityConst
  entropicRegStrength_pos := m.coercivityConst_pos
  exponentialTailBound := h.exponentialTailBound
  tendsToContinuum := h.tendsToContinuum

/-- The produced certificate's per-`N` tail bound is exactly
the supplied spectral tail. -/
theorem coercive_entropic_action_yields_uv_certificate_tail
    (m : EntropicCoercivityModel) (h : SpectralTailBound m) (N : ℕ) :
    |(coercive_entropic_action_gives_uv_certificate m h).cutoffPartition N
        - (coercive_entropic_action_gives_uv_certificate m h).continuumPartition|
      ≤ Real.exp
          (-((coercive_entropic_action_gives_uv_certificate m h).entropicRegStrength
              * (N : ℝ))) :=
  (coercive_entropic_action_gives_uv_certificate m h).exponentialTailBound N

/-- The produced certificate's convergence statement is
exactly the supplied tendsto witness. -/
theorem coercive_entropic_action_yields_uv_certificate_tendsto
    (m : EntropicCoercivityModel) (h : SpectralTailBound m) :
    Tendsto (coercive_entropic_action_gives_uv_certificate m h).cutoffPartition
        atTop
        (𝓝 (coercive_entropic_action_gives_uv_certificate m h).continuumPartition) :=
  (coercive_entropic_action_gives_uv_certificate m h).tendsToContinuum

/-- **Composition with Phase 9**: lifting the produced
real-valued certificate through `ofUVConvergenceCertificate`
yields the Phase-8 complex no-counterterm conjunction —
ℂ-convergence to the continuum partition with the counterterm
pinned to zero. -/
theorem coercive_entropic_action_yields_no_counterterm_needed
    (m : EntropicCoercivityModel) (h : SpectralTailBound m) :
    Tendsto
        (ofUVConvergenceCertificate
            (coercive_entropic_action_gives_uv_certificate m h)).cutoffPartition
        atTop
        (𝓝 (ofUVConvergenceCertificate
            (coercive_entropic_action_gives_uv_certificate m h)).continuumPartition) ∧
      (ofUVConvergenceCertificate
          (coercive_entropic_action_gives_uv_certificate m h)).counterterm = 0 :=
  ofUVConvergenceCertificate_no_counterterm_needed
    (coercive_entropic_action_gives_uv_certificate m h)

end

end CATEPTMain.Integration.EntropicCoercivityToUVCertificate
