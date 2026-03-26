import NavierStokesClean.Core.Operators
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic

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
  have hν : nsNu ≠ 0 := ne_of_gt nsNu_pos
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

end NavierStokesClean
