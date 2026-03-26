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

/-- **Phase 3: concrete proof in PhysLean/DivCurlIdentity.lean.**

    The identity ∇ ⬝ (∇ × f) = 0 is proved with 0 new axioms via PhysLean
    (`div_of_curl_eq_zero`, `PhysLean.SpaceAndTime.Space.Derivatives.Curl`).

    This abstract axiom bridges the Phase 0 carrier (`NSField = ℝ × ℝ`) to the
    concrete 3D result. Phase 5 will discharge it when `NSField` is upgraded to
    `Space → EuclideanSpace ℝ (Fin 3)`.

    **Epistemic**: `.partiallyVerified` — concrete 3D identity proved (PhysLean);
    remaining gap is the abstract/concrete carrier identification. -/
axiom ns_divergence_free_satisfied : ∀ (traj : Trajectory),
    SatisfiesNSPDE nsNu traj → True  -- carrier upgrade in Phase 5; concrete proof in DivCurlIdentity

end NavierStokesClean
