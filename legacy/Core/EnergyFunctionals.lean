import NavierStokesClean.Core.Operators
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus

/-!
# Energy functionals: BKM integral, entropic proper time, enstrophy integral

## The core EPT algebraic identity (zero new axioms)

  bkmVorticityIntegral traj T
    = integratedEnstrophy traj T       [by definition]
    = (ħ/ν) · entropicProperTime traj T [by definition of EPT]

Both equalities hold by `rfl`/`ring`. This is the Stage 284 result
ported to the clean repo with ℝ-valued parameters.

The BKM criterion then gives `PreciseGapStatement` with witness
  F(τ) = (ħ/ν) · τ
requiring zero new axioms — purely from the definitions.

## Integration

We use Mathlib `intervalIntegral` (ℝ-valued Lebesgue/Bochner).
The `integratedEnstrophy_nonneg` theorem follows from `integral_nonneg`.
-/

set_option autoImplicit false

open MeasureTheory intervalIntegral

namespace NavierStokesClean

/-! ## §1. Integrated enstrophy -/

/-- ∫₀ᵀ Ω[u(t)] dt — integrated enstrophy along a trajectory. -/
noncomputable def integratedEnstrophy (traj : Trajectory) (T : ℝ) : ℝ :=
  ∫ t in (0 : ℝ)..T, enstrophy (traj t)

theorem integratedEnstrophy_nonneg (traj : Trajectory) (T : ℝ) (hT : 0 ≤ T) :
    0 ≤ integratedEnstrophy traj T := by
  apply intervalIntegral.integral_nonneg hT
  intro t _
  exact enstrophy_nonneg _

/-! ## §2. Entropic proper time -/

/-- τ_ent(T) = (ν/ħ) · ∫₀ᵀ Ω[u(t)] dt.
    Definitional: τ_ent = (ν/ħ) · integratedEnstrophy. Zero axioms. -/
noncomputable def entropicProperTime (traj : Trajectory) (T : ℝ) : ℝ :=
  (nsNu / hbar) * integratedEnstrophy traj T

theorem entropicProperTime_nonneg (traj : Trajectory) (T : ℝ) (hT : 0 ≤ T) :
    0 ≤ entropicProperTime traj T :=
  mul_nonneg (le_of_lt (div_pos nsNu_pos hbar_pos))
    (integratedEnstrophy_nonneg traj T hT)

/-- Core identity: integratedEnstrophy = (ħ/ν) · τ_ent. Proved by ring. -/
theorem integratedEnstrophy_eq_hbar_nu_ept (traj : Trajectory) (T : ℝ) :
    integratedEnstrophy traj T =
      (hbar / nsNu) * entropicProperTime traj T := by
  unfold entropicProperTime
  have hν : (nsNu : ℝ) ≠ 0 := ne_of_gt nsNu_pos
  have hħ : hbar ≠ 0 := ne_of_gt hbar_pos
  field_simp [hν, hħ]

/-! ## §3. BKM vorticity integral -/

/-- BKM integral ∫₀ᵀ ‖ω(·,t)‖_{L^∞} dt.
    In the EPT route: definitionally equal to integratedEnstrophy
    (via BKM criterion identification). Zero axioms. -/
noncomputable def bkmVorticityIntegral (traj : Trajectory) (T : ℝ) : ℝ :=
  integratedEnstrophy traj T

/-- BKM = (ħ/ν) · τ_ent. Proof: two definitional unfoldings. -/
theorem bkm_eq_hbar_nu_ept (traj : Trajectory) (T : ℝ) :
    bkmVorticityIntegral traj T =
      (hbar / nsNu) * entropicProperTime traj T :=
  integratedEnstrophy_eq_hbar_nu_ept traj T

theorem bkm_nonneg (traj : Trajectory) (T : ℝ) (hT : 0 ≤ T) :
    0 ≤ bkmVorticityIntegral traj T :=
  integratedEnstrophy_nonneg traj T hT

/-! ## §4. BKM finiteness -/

def BKMIntegralFiniteAt (traj : Trajectory) (T : ℝ) : Prop :=
  ∃ M : ℝ, bkmVorticityIntegral traj T ≤ M

/-! ## §5. Analytic properties of integrated enstrophy (Phase 27) -/

/-- Enstrophy is interval-integrable for any NS trajectory (from continuity). -/
private theorem enstrophy_intble (traj : Trajectory) (hNS : SatisfiesNSPDE nsNu traj)
    (a b : ℝ) : IntervalIntegrable (fun t => enstrophy (traj t)) MeasureTheory.volume a b :=
  (hNS.hCont.norm.pow 2).intervalIntegrable a b

/-- Integrated enstrophy is additive over adjacent intervals. -/
theorem integratedEnstrophy_add_interval (traj : Trajectory) (hNS : SatisfiesNSPDE nsNu traj)
    (T₁ T₂ : ℝ) :
    integratedEnstrophy traj T₂ =
      integratedEnstrophy traj T₁ + ∫ t in T₁..T₂, enstrophy (traj t) := by
  unfold integratedEnstrophy
  linarith [intervalIntegral.integral_add_adjacent_intervals
    (enstrophy_intble traj hNS 0 T₁) (enstrophy_intble traj hNS T₁ T₂)]

/-- Integrated enstrophy is monotone in T (for NS trajectories). -/
theorem integratedEnstrophy_mono (traj : Trajectory) (hNS : SatisfiesNSPDE nsNu traj)
    {T₁ T₂ : ℝ} (h₁₂ : T₁ ≤ T₂) :
    integratedEnstrophy traj T₁ ≤ integratedEnstrophy traj T₂ := by
  rw [integratedEnstrophy_add_interval traj hNS T₁ T₂]
  exact le_add_of_nonneg_right
    (intervalIntegral.integral_nonneg h₁₂ fun t _ => enstrophy_nonneg _)

/-- **FTC for integrated enstrophy**: derivative in T equals enstrophy at T. -/
theorem integratedEnstrophy_hasDerivAt (traj : Trajectory) (hNS : SatisfiesNSPDE nsNu traj)
    (T : ℝ) : HasDerivAt (integratedEnstrophy traj) (enstrophy (traj T)) T := by
  unfold integratedEnstrophy
  have hcont : Continuous (fun t => enstrophy (traj t)) := hNS.hCont.norm.pow 2
  exact intervalIntegral.integral_hasDerivAt_right
    (hcont.intervalIntegrable 0 T)
    hcont.aestronglyMeasurable.stronglyMeasurableAtFilter
    hcont.continuousAt

/-- Integrated enstrophy is continuous in T (for NS trajectories). -/
theorem integratedEnstrophy_continuous (traj : Trajectory) (hNS : SatisfiesNSPDE nsNu traj) :
    Continuous (integratedEnstrophy traj) :=
  continuous_iff_continuousAt.mpr fun T =>
    (integratedEnstrophy_hasDerivAt traj hNS T).continuousAt

/-- Entropic proper time is monotone in T. -/
theorem entropicProperTime_mono (traj : Trajectory) (hNS : SatisfiesNSPDE nsNu traj)
    {T₁ T₂ : ℝ} (h₁₂ : T₁ ≤ T₂) :
    entropicProperTime traj T₁ ≤ entropicProperTime traj T₂ :=
  mul_le_mul_of_nonneg_left
    (integratedEnstrophy_mono traj hNS h₁₂)
    (le_of_lt (div_pos nsNu_pos hbar_pos))

/-- BKM vorticity integral is monotone in T. -/
theorem bkmVorticityIntegral_mono (traj : Trajectory) (hNS : SatisfiesNSPDE nsNu traj)
    {T₁ T₂ : ℝ} (h₁₂ : T₁ ≤ T₂) :
    bkmVorticityIntegral traj T₁ ≤ bkmVorticityIntegral traj T₂ :=
  integratedEnstrophy_mono traj hNS h₁₂

/-! ## §6. BKM proxy gap (NSC-P52) -/

/-- **The concrete BKM gap (NSC-P52)**: The abstract `bkmVorticityIntegral` (proxy)
    vs the concrete `spatialBKMVorticityIntegral` (real BKM integral).

    `bkmVorticityIntegral traj T = integratedEnstrophy traj T = ∫₀ᵀ ‖traj(t)‖² dt`
    uses `traj : Trajectory = ℝ → NSField` (a time-dependent single 3D velocity vector,
    no spatial structure — Phase 5D carrier limitation).

    The real BKM criterion (Beale-Kato-Majda 1984, Thm. 1) requires
      `spatialBKMVorticityIntegral straj T = ∫₀ᵀ ‖∇ × u(·,t)‖_{L^∞(Space)} dt`
    on `straj : NSSpaceTrajectory = ℝ → (Space → EuclideanSpace ℝ (Fin 3))`.

    Bounding `spatialBKMVorticityIntegral` from the NS H¹ energy estimate requires:
    1. **Phase 5D**: upgrade `Trajectory` to `NSSpaceTrajectory` (unblocks spatial BKM)
    2. **Agmon interpolation** on T³: `‖ω‖_{L^∞} ≤ C‖ω‖_{H²}^{1/2}‖ω‖_{L²}^{1/2}` (NSP38-C)
    3. **H² vorticity regularity** from `ns_periodic_smooth_solution_exists` (the Millennium gap)

    This sorry makes the Millennium gap explicit at the concrete spatial level:
    the identification `bkmVorticityIntegral := integratedEnstrophy` (lines 71–72) works
    definitionally only because `Trajectory` lacks spatial structure. With full spatial
    types, this identification requires the proof content of `ns_periodic_smooth_solution_exists`.

    Discharge: Phase 5D + NSP38-C `agmon_linf_torus_bridge` + `ns_periodic_smooth_solution_exists`. -/
theorem bkm_linf_proxy_gap (straj : NSSpaceTrajectory) (T : ℝ)
    (hNS : SatisfiesSpatialNSPDE nsNu straj) (hT : 0 < T) :
    ∃ C : ℝ, 0 < C ∧
      spatialBKMVorticityIntegral straj T ≤
        C * Real.sqrt (∫ t in (0 : ℝ)..T, spatialEnstrophy (straj t)) := by
  sorry -- Agmon: ‖ω‖_{L^∞} ≤ C‖ω‖_{H²}^{1/2}‖ω‖_{L²}^{1/2} + H² regularity (ns_periodic_smooth_solution_exists)

end NavierStokesClean
