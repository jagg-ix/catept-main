import NavierStokesClean.Core.Types

/-!
# Differential operators — Phase 0 stubs

All operators are opaque with nonnegativity axioms.
Phase 1 will replace with PhysLean.Electromagnetism concrete implementations.

## Key Phase 1 target

PhysLean.Electromagnetism.Kinematics.MagneticField provides:
  `magneticField_div_eq_zero : Space.div (A.magneticField c t) = 0`

This is the structural analogue of `div_curl_eq_zero` below.
The identification: NS vorticity ω = ∇ × u ↔ magnetic field B = ∇ × A.
-/

set_option autoImplicit false

namespace NavierStokesClean

/-! ## §1. Enstrophy and palinstrophy -/

/-- Enstrophy Ω[u] = ‖∇ × u‖²_{L²}.
    Nonneg by definition; axiom until Phase 1 provides the concrete norm. -/
opaque enstrophy : NSField → ℝ

axiom enstrophy_nonneg : ∀ u : NSField, (0 : ℝ) ≤ enstrophy u

/-- Palinstrophy P[u] = ‖∇ω‖²_{L²}. Stub. -/
opaque palinstrophy : NSField → ℝ

axiom palinstrophy_nonneg : ∀ u : NSField, (0 : ℝ) ≤ palinstrophy u

/-- Initial enstrophy Ω₀ of a trajectory. -/
noncomputable def initialEnstrophy (traj : Trajectory) : ℝ :=
  enstrophy (traj 0)

theorem initialEnstrophy_nonneg (traj : Trajectory) : 0 ≤ initialEnstrophy traj :=
  enstrophy_nonneg _

/-! ## §2. Bianchi identity (div ∘ curl = 0) -/

/-- Phase 1 target: replace with PhysLean.Electromagnetism.magneticField_div_eq_zero.
    Epistemic: .partiallyVerified (algebraic identity k·(k×u)=0). -/
axiom div_curl_eq_zero : ∀ _ : NSField, True  -- placeholder shape; Phase 1 target

end NavierStokesClean
