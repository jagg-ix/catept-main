import CATEPTMain.Integration.PageWoottersWDWPathIntegralModularFlowSpine
import CATEPTMain.Integration.EuclideanActionHarmonicDiscrete
import CATEPTMain.Integration.DiscreteGaussianPathMeasure
import CATEPTMainExtracted.CATEPT.CATEPT.PathIntegrals
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# DiscreteHarmonicSpineInstance — concrete discrete-path-integral
instantiation of the WDW–PathIntegral–ModularFlow spine

Concrete-instantiation companion to `PageWoottersWDWPathIntegralModularFlowSpine`.
Demonstrates that the abstract spine carrier admits a *fully proven*
concrete instantiation built from:

* `DiscreteGaussianPathMeasure` — i.i.d. Gaussian path measure on
  `Fin N → ℝ` (probability measure proven via Mathlib's `gaussianReal`
  + `Measure.pi`).
* `EuclideanActionHarmonicDiscrete` — discrete harmonic Euclidean
  action with proven coercivity and non-negativity.
* `catept-core/PathIntegrals.lean` — `path_integral_damping`
  ladder providing `|damping| ≤ 1` (`eq054_damping_magnitude`)
  and coercivity-driven exponential decay (`eq057`/`eq058`).

The output is a single composite carrier
`DiscreteHarmonicSpineInstance` whose fields realize the spine's
abstract `matsubara.S_I` magnitude as the concrete discrete
Euclidean action `S_E_harmonic k dt γ`.

## Construction

```
DiscreteHarmonicSpineInstance
   ├── spine : PageWoottersWDWPathIntegralModularFlowSpine
   ├── (k, dt, ℏ) : ℝ × ℝ × ℝ                  -- physical parameters
   ├── (hk, hdt, hℏ) : 0 ≤ k ∧ 0 ≤ dt ∧ 0 < ℏ
   ├── γ : DPath N                              -- specific discrete path
   └── S_I_eq_S_E :
         spine.pwMat.matsubara.S_I = S_E_harmonic k dt γ
                                                -- the load-bearing
                                                -- identification
```

## Theorems shipped

* `spine_S_I_nonneg` — proven: under the identification, the spine's
  Matsubara `S_I` is non-negative.
* `spine_damping_le_one` — proven: the spine's path-integral damping
  factor at `S_I = S_E_harmonic` satisfies `|damping| ≤ 1`. This is
  the *concrete realization* of the spine's abstract path-integral
  bound.
* `spine_damping_at_zero_path_eq_one` — proven: at the origin path
  `γ ≡ 0`, the damping factor equals exactly `1`. Concrete instance
  of the Schrödinger-reduction theorem
  `schrodinger_reduction_under_no_clock_evolution`: zero path ⇒
  zero action ⇒ unit damping.
* `discrete_harmonic_spine_exists` — capstone existence: a concrete
  spine instance built from a degenerate (zero-path) discrete
  harmonic configuration.

## Honest scope

* The "load-bearing identification" `S_I = S_E_harmonic` is a Prop
  field of the carrier; it is *not* derived from the operator-side
  Wick rotation (that would require imaginary-time path-integral
  formalisation beyond carrier scope). What this module shows is
  that *given* such an identification, the spine's abstract bounds
  follow concretely from the discrete coercivity/damping ladder.
* The discrete Gaussian path measure (`DiscreteGaussianPathMeasure`)
  is the natural ambient measure but is not used in the
  identification itself; consumers wanting integrability lemmas
  against the Gaussian measure can use it directly.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.DiscreteHarmonicSpineInstance

open CATEPTMain.Integration.PageWoottersWDWPathIntegralModularFlowSpine
open CATEPTMain.Integration.PageWoottersMatsubaraEquivalenceBridge
open CATEPTMain.Integration.PageWoottersQuantumTimeCarrier
open CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
open CATEPTMain.Integration.KMSModularParameterBridge
open CATEPTMain.Integration.EuclideanActionHarmonicDiscrete
open CATEPTMain.CATEPT.CATEPT

/-- **Concrete discrete-harmonic instantiation** of the WDW-path-
integral-modular-flow spine.

Holds:
* a `PageWoottersWDWPathIntegralModularFlowSpine` carrier,
* discrete-harmonic-oscillator parameters `(N, k, dt, γ)`,
* positivity hypotheses on `(k, dt, ℏ)`,
* the identification `spine.pwMat.matsubara.S_I = S_E_harmonic k dt γ`. -/
structure DiscreteHarmonicSpineInstance where
  /-- Underlying abstract spine carrier. -/
  spine    : PageWoottersWDWPathIntegralModularFlowSpine
  /-- Number of time slices. -/
  N        : ℕ
  /-- Stiffness `k > 0` (harmonic potential coefficient `k/2`). -/
  k        : ℝ
  /-- Time step `Δt > 0`. -/
  dt       : ℝ
  /-- Specific discrete path. -/
  γ        : Fin N → ℝ
  /-- Non-negativity of `k`. -/
  hk       : 0 ≤ k
  /-- Non-negativity of `dt`. -/
  hdt      : 0 ≤ dt
  /-- **Load-bearing identification:** the spine's abstract Matsubara
  `S_I` is realized by the concrete discrete harmonic Euclidean action. -/
  S_I_eq_S_E : spine.pwMat.matsubara.S_I = S_E_harmonic k dt γ

namespace DiscreteHarmonicSpineInstance

variable (D : DiscreteHarmonicSpineInstance)

/-- **Proven:** under the discrete-harmonic identification, the
spine's Matsubara `S_I` is non-negative.

Direct from `EuclideanActionHarmonicDiscrete.S_E_harmonic_nonneg`
via the identification `S_I_eq_S_E`. -/
theorem spine_S_I_nonneg : 0 ≤ D.spine.pwMat.matsubara.S_I := by
  rw [D.S_I_eq_S_E]
  exact S_E_harmonic_nonneg D.hk D.hdt D.γ

/-- **Proven concrete realization** of the spine's path-integral
damping bound at the discrete harmonic action.

The catept-core `eq054_damping_magnitude` gives `|damping| ≤ 1` for
any non-negative `S_I`; under the discrete identification this
realizes as `|exp(−S_E_harmonic / ℏ)| ≤ 1`. -/
theorem spine_damping_le_one :
    |path_integral_damping D.spine.pwMat.pw.ℏ D.spine.pwMat.matsubara.S_I| ≤ 1 := by
  apply eq054_damping_magnitude
  · exact D.spine.pwMat.pw.ℏ_pos
  · exact D.spine_S_I_nonneg

/-- **Proven concrete realization** of the Schrödinger-reduction
theorem at the zero discrete path.

When `γ ≡ 0`, the discrete action `S_E_harmonic = 0`, so by the
identification `spine.matsubara.S_I = 0`, and the spine's
`schrodinger_reduction_under_no_clock_evolution` hypothesis
`τ_ent = 0` follows by the Matsubara identity `S_I = ℏ·τ_ent` plus
`ℏ > 0`.  Concrete instance: zero path ⇒ unit damping factor. -/
theorem spine_damping_at_zero_path_eq_one
    (h_zero : D.γ = fun _ : Fin D.N => 0) :
    path_integral_damping D.spine.pwMat.pw.ℏ D.spine.pwMat.matsubara.S_I = 1 := by
  -- Under the identification with S_E_harmonic at the zero path,
  -- S_I = 0 and the damping factor is exp(0) = 1.
  have hSI : D.spine.pwMat.matsubara.S_I = 0 := by
    rw [D.S_I_eq_S_E, h_zero]
    unfold S_E_harmonic pathNormSq
    simp
  unfold path_integral_damping
  rw [hSI]
  simp

/-- **Proven concrete derivation** of the entropic-clock-evolution
hypothesis `τ_ent = 0` from the zero discrete path.

This is the bridge step that lets a consumer apply the spine's
`schrodinger_reduction_under_no_clock_evolution` theorem starting
from the concrete physical condition "zero-amplitude oscillator
configuration". -/
theorem zero_path_implies_no_entropic_clock_evolution
    (h_zero : D.γ = fun _ : Fin D.N => 0) :
    D.spine.pwMat.matsubara.τ_ent = 0 := by
  have hSI : D.spine.pwMat.matsubara.S_I = 0 := by
    rw [D.S_I_eq_S_E, h_zero]
    unfold S_E_harmonic pathNormSq
    simp
  -- S_I = ℏ · τ_ent, ℏ > 0 ⇒ τ_ent = 0
  have hSeq := D.spine.pwMat.matsubara.S_I_eq_hbar_tauEnt
  have hℏne : D.spine.pwMat.matsubara.ℏ ≠ 0 :=
    ne_of_gt D.spine.pwMat.matsubara.ℏ_pos
  have h0 : D.spine.pwMat.matsubara.ℏ * D.spine.pwMat.matsubara.τ_ent = 0 := by
    rw [← hSeq, hSI]
  exact (mul_eq_zero.mp h0).resolve_left hℏne

end DiscreteHarmonicSpineInstance

/-! ## Capstone -/

/-- **Capstone existence**: a concrete `DiscreteHarmonicSpineInstance`
built from a fresh degenerate spine + a zero-path harmonic configuration
with `(k, dt) = (1, 1)` and `N = 1`.

Demonstrates that the abstract spine theorem admits a kernel-checked
concrete instantiation; consumers can cite this as the proof-of-
concept for "the spine is realizable, not just contractually
asserted". -/
theorem discrete_harmonic_spine_exists :
    ∃ _ : DiscreteHarmonicSpineInstance, True := by
  -- Build the inner Matsubara/PW/spine carriers inline so that
  -- their fields (in particular matsubara.S_I = 0) are visible.
  let M : MatsubaraLuttingerWardCarrier :=
    { β        := 1
    , ℏ        := 1
    , Ω        := 0
    , Z        := 1
    , S_I      := 0
    , τ_ent    := 0
    , β_pos    := by norm_num
    , ℏ_pos    := by norm_num
    , Z_eq_exp := by simp
    , τ_ent_eq := by ring
    , S_I_eq   := by ring }
  let pw : PageWoottersCarrier :=
    { t              := 1
    , ℏ              := 1
    , E_S            := 0
    , E_C            := 0
    , tauPW          := 1
    , phaseS         := 0
    , ℏ_pos          := by norm_num
    , WDW_constraint := by ring
    , tauPW_eq       := by ring
    , phaseS_eq      := by ring }
  let pwMat : PageWoottersMatsubaraEquivalenceBridge :=
    { pw                  := pw
    , matsubara           := M
    , t_eq_betaHbar       := by show (1 : ℝ) = 1 * 1; ring
    , hbar_eq             := by show (1 : ℝ) = 1; rfl
    , E_S_eq_Omega        := by show (0 : ℝ) = 0; rfl }
  let spine : PageWoottersWDWPathIntegralModularFlowSpine :=
    { pwMat            := pwMat
    , kmsBridge        :=
        { gammaI := fun _ => 0
        , tauEnt := fun _ => 0
        , tauEnt_eq_kmsStripWidth := fun _ => by
            rw [kmsStripWidth_eq]; simp }
    , matsubara_eq_kms := rfl }
  refine ⟨{ spine        := spine
          , N            := 1
          , k            := 1
          , dt           := 1
          , γ            := fun _ => 0
          , hk           := by norm_num
          , hdt          := by norm_num
          , S_I_eq_S_E   := ?_ }, trivial⟩
  -- spine.pwMat.matsubara.S_I = M.S_I = 0; S_E_harmonic 1 1 (fun _ => 0) = 0.
  show (0 : ℝ) = S_E_harmonic 1 1 (fun _ : Fin 1 => 0)
  unfold S_E_harmonic pathNormSq
  simp

end CATEPTMain.Integration.DiscreteHarmonicSpineInstance

end
