import CATEPTMain.Integration.EntropicCoercivityToUVCertificate

/-!
# Physical UV Convergence Certificate (T-FF Phase 15)

Closes the dependency graph for the *physical instantiation*
of the Phase-7 abstract `UVConvergenceCertificate` by
packaging the four named physics inputs from the user's plan:

* (#1) **Cutoff family** `Λ_N`, `Z_N`, `Z_∞`, `highModeTail_N`.
* (#4) **Coercivity** of the imaginary action
       `S_I[Φ] ≥ C · ‖Φ‖²_UV` with positive constant `C`.
* (#5) **Stokes spectral growth** `λ_k ~ |k|^α` (canonically
       `α = 2`).
* (#6) **Exponential cutoff-partition tail**
       `|Z_N − Z_∞| ≤ exp(−ε · N)`.

These are recorded as named structural fields of a single
bundled record `PhysicalEntropicModel`. The Lean content here
is the wiring lemma producing
`physical_uv_convergence_certificate`, **not** a derivation of
the four hypotheses from CAT/EPT first principles. The
physics obligations are taken as inputs and discharged
through the existing P11 bridge
`coercive_entropic_action_gives_uv_certificate`.

Exposed items:

* `CutoffFamily` — record for (#1) with derived
  `highModeTail_N := |Z_N − Z_∞|`.
* `EntropicActionCoercive` — record for (#4) with
  positive coercivity constant `C`.
* `StokesSpectralGrowth` — record for (#5) tagging the
  positive spectral exponent `α`.
* `PhysicalEntropicModel` — bundle of (#1)+(#4)+(#5) plus
  the (#6) exponential tail and continuum convergence.
* `physical_uv_convergence_certificate` — the bridge,
  producing the canonical `UVConvergenceCertificate`.
* Five kernel-only consequences:
  - `physical_uv_certificate_tail`,
  - `physical_uv_certificate_tendsto`,
  - `physical_uv_certificate_strength_eq_coercivity`,
  - `physical_uv_certificate_high_mode_tail_eq`,
  - `physical_uv_certificate_no_counterterm_needed`.

Honest scope: this is a **Lean-level wiring lemma** closing
the dependency graph at the structural level. The physical
derivations of (#4) (coercivity) and (#5) (Stokes spectrum)
from first principles remain external mathematical
obligations.

Terminology note for downstream audits: the exposed theorem
`physical_uv_certificate_no_counterterm_needed` is a no-renormalization
claim (`counterterm = 0`) once the physical certificate fields are
available. It is not a claim that probability normalization is obsolete;
normalization by a partition function remains the correct layer for
probabilistic expectations.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.PhysicalUVConvergenceCertificate

open CATEPTMain.CATEPT.CATEPT
open CATEPTMain.Integration.SimplexPathIntegralNoRenormUVCertBridge
open CATEPTMain.Integration.EntropicCoercivityToUVCertificate
open Filter Topology

noncomputable section

/-- (#1) **Physical cutoff family**: cutoff partition `Z_N`
indexed by UV cutoff level `N` and continuum value `Z_∞`. The
high-mode residual `highModeTail_N` is the absolute
difference `|Z_N − Z_∞|`. -/
structure CutoffFamily where
  Z_N : ℕ → ℝ
  Z_inf : ℝ

namespace CutoffFamily

/-- High-mode tail residual: `highModeTail_N := |Z_N − Z_∞|`. -/
def highModeTail (cf : CutoffFamily) (N : ℕ) : ℝ :=
  |cf.Z_N N - cf.Z_inf|

end CutoffFamily

/-- (#4) **Coercivity hypothesis**: the imaginary action
satisfies `S_I[Φ] ≥ C · ‖Φ‖²_UV` for a positive constant `C`.
Recorded here as a named structural field; not derived from
CAT/EPT primitives. -/
structure EntropicActionCoercive where
  C : ℝ
  C_pos : 0 < C

/-- (#5) **Stokes spectral growth marker**: positive spectral
exponent `α` controlling `λ_k ~ |k|^α`. Canonical Stokes /
Laplacian value is `α = 2`. -/
structure StokesSpectralGrowth where
  spectralExponent : ℝ
  spectralExponent_pos : 0 < spectralExponent

/-- **Bundled physical model**: the cutoff family (#1),
coercivity hypothesis (#4), spectral growth tag (#5), the
analytical exponential tail conclusion (#6), and the
continuum convergence statement. -/
structure PhysicalEntropicModel where
  cutoff : CutoffFamily
  coercivity : EntropicActionCoercive
  spectral : StokesSpectralGrowth
  exponentialTailBound :
    ∀ N, |cutoff.Z_N N - cutoff.Z_inf|
      ≤ Real.exp (-(coercivity.C * (N : ℝ)))
  tendsToContinuum :
    Tendsto cutoff.Z_N atTop (𝓝 cutoff.Z_inf)

/-- Project onto the abstract P11 physics-side input
`EntropicCoercivityModel`. -/
def toCoercivityModel (m : PhysicalEntropicModel) :
    EntropicCoercivityModel where
  cutoffPartition := m.cutoff.Z_N
  continuumPartition := m.cutoff.Z_inf
  coercivityConst := m.coercivity.C
  coercivityConst_pos := m.coercivity.C_pos

/-- Project onto the abstract P11 analysis-side input
`SpectralTailBound`. -/
def toSpectralTailBound (m : PhysicalEntropicModel) :
    SpectralTailBound (toCoercivityModel m) where
  exponentialTailBound := m.exponentialTailBound
  tendsToContinuum := m.tendsToContinuum

/-- **Physical instantiation** of the abstract Phase-7
`UVConvergenceCertificate`: package the four named physics
inputs (#1 cutoff family, #4 coercivity, #5 spectral growth,
#6 exponential tail) and discharge via the P11 bridge. -/
def physical_uv_convergence_certificate
    (m : PhysicalEntropicModel) : UVConvergenceCertificate :=
  coercive_entropic_action_gives_uv_certificate
    (toCoercivityModel m) (toSpectralTailBound m)

/-- The produced certificate's per-`N` exponential tail bound
is exactly the supplied physical (#6) tail. -/
theorem physical_uv_certificate_tail
    (m : PhysicalEntropicModel) (N : ℕ) :
    |(physical_uv_convergence_certificate m).cutoffPartition N
        - (physical_uv_convergence_certificate m).continuumPartition|
      ≤ Real.exp
          (-((physical_uv_convergence_certificate m).entropicRegStrength
              * (N : ℝ))) :=
  (physical_uv_convergence_certificate m).exponentialTailBound N

/-- The produced certificate's continuum convergence is
exactly the supplied tendsto witness. -/
theorem physical_uv_certificate_tendsto
    (m : PhysicalEntropicModel) :
    Tendsto (physical_uv_convergence_certificate m).cutoffPartition
        atTop
        (𝓝 (physical_uv_convergence_certificate m).continuumPartition) :=
  (physical_uv_convergence_certificate m).tendsToContinuum

/-- The produced certificate's regularization strength is
exactly the (#4) coercivity constant `C`. -/
theorem physical_uv_certificate_strength_eq_coercivity
    (m : PhysicalEntropicModel) :
    (physical_uv_convergence_certificate m).entropicRegStrength
      = m.coercivity.C := rfl

/-- The (#1) high-mode tail is exactly the absolute
difference `|Z_N − Z_∞|`. -/
theorem physical_uv_certificate_high_mode_tail_eq
    (m : PhysicalEntropicModel) (N : ℕ) :
    m.cutoff.highModeTail N
      = |m.cutoff.Z_N N - m.cutoff.Z_inf| := rfl

/-- **Composition with Phase 9**: lifting the produced
real-valued certificate through `ofUVConvergenceCertificate`
yields the Phase-8 complex no-counterterm conjunction —
ℂ-convergence to the continuum partition with the
counterterm pinned to zero. -/
theorem physical_uv_certificate_no_counterterm_needed
    (m : PhysicalEntropicModel) :
    Tendsto
        (ofUVConvergenceCertificate
            (physical_uv_convergence_certificate m)).cutoffPartition
        atTop
        (𝓝 (ofUVConvergenceCertificate
            (physical_uv_convergence_certificate m)).continuumPartition) ∧
      (ofUVConvergenceCertificate
          (physical_uv_convergence_certificate m)).counterterm = 0 :=
  ofUVConvergenceCertificate_no_counterterm_needed _

end

end CATEPTMain.Integration.PhysicalUVConvergenceCertificate
