import NavierStokesClean.CATEPT.MaxwellWaveEntropicTimeActivation
import NavierStokesClean.CATEPT.CFLClockEntropicBridge

/-!
# MaxwellWave Entropic-Time Public Surface

Public entropic-first API:

- fundamental time coordinate is `τ`,
- geometric time is derived via `t = t(τ)`,
- no Bool/`TimeMode` switch is required at call sites.

The toggle layer remains in `MaxwellWaveEntropicTimeActivation` as compatibility
infrastructure, but this module is the default interface for CAT/EPT usage.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

noncomputable section

namespace MaxwellWaveEntropicTimePublic

open MaxwellWaveEntropicTime

/-- Public spacetime type with fundamental entropic coordinate `τ`. -/
abbrev EntropicSpaceTime := EntropicFirstSpaceTime

/-- Public active geometric time in entropic-first mode (`t = t(τ)`). -/
def geometricTime (stτ : EntropicSpaceTime) (τ : ℝ) : ℝ :=
  activeGeometricTimeFromTau stτ .entropicProper τ

@[simp] theorem geometricTime_eq_composed (stτ : EntropicSpaceTime) (τ : ℝ) :
    geometricTime stτ τ = stτ.geometricTimeOfEntropic τ := rfl

/-- Public wave equation for `E` with `τ` as fundamental time. -/
theorem general_wave_equation_E_tau
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (sm : MaxwellWave.SufficientlySmooth sys)
    (stτ : EntropicSpaceTime)
    (τ : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.vectorLaplacian (sys.E (geometricTime stτ τ)) x j =
      m.μ * m.ε * MaxwellWave.timeDerivComp2 sys.E j (geometricTime stτ τ) x +
      m.μ * m.σ * MaxwellWave.timeDerivComp sys.E j (geometricTime stτ τ) x := by
  simpa [geometricTime] using
    (general_wave_equation_E_tau_fundamental (m := m) sys sm stτ .entropicProper τ x j)

/-- Public wave equation for `B` with `τ` as fundamental time. -/
theorem general_wave_equation_B_tau
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (sm : MaxwellWave.SufficientlySmooth sys)
    (stτ : EntropicSpaceTime)
    (τ : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.vectorLaplacian (sys.B (geometricTime stτ τ)) x j =
      m.μ * m.ε * MaxwellWave.timeDerivComp2 sys.B j (geometricTime stτ τ) x +
      m.μ * m.σ * MaxwellWave.timeDerivComp sys.B j (geometricTime stτ τ) x := by
  simpa [geometricTime] using
    (general_wave_equation_B_tau_fundamental (m := m) sys sm stτ .entropicProper τ x j)

/-- Public Gauss law form under entropic-first parameterization. -/
theorem gauss_simplified_tau
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : EntropicSpaceTime)
    (τ : ℝ) (x : MaxwellWave.Vec3) :
    MaxwellWave.divergence (sys.E (geometricTime stτ τ)) x = 0 := by
  simpa [geometricTime] using
    (gauss_simplified_at_active_time (m := m)
      sys
      { entropicProperTime := stτ.geometricTimeOfEntropic }
      .entropicProper τ x)

/-- Public Faraday law form under entropic-first parameterization. -/
theorem faraday_tau
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : EntropicSpaceTime)
    (τ : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.curl (sys.E (geometricTime stτ τ)) x j =
      -(MaxwellWave.timeDerivComp sys.B j (geometricTime stτ τ) x) := by
  simpa [geometricTime] using
    (faraday_at_active_time (m := m)
      sys
      { entropicProperTime := stτ.geometricTimeOfEntropic }
      .entropicProper τ x j)

/-- CFL invariance in the public entropic-first interface. -/
theorem cfl_invariant
    (dt dx a lam : ℝ) (hlam : 0 < lam) :
    (dt ≤ dx / a) ↔ (CFLClock.dtauFromDt dt lam ≤ lam * (dx / a)) :=
  CFLClock.cfl_invariant_under_entropic_reparam dt dx a lam hlam

/-- If a `dτ` bound is known, recover the corresponding coordinate-time CFL bound. -/
theorem dt_bound_from_dtau_bound
    (dtau dx a lam : ℝ) (hlam : 0 < lam)
    (h : dtau ≤ lam * (dx / a)) :
    CFLClock.dtFromDtau dtau lam ≤ dx / a :=
  CFLClock.dt_bound_from_dtau_bound dtau dx a lam hlam h

end MaxwellWaveEntropicTimePublic

end

end NavierStokesClean.CATEPT
